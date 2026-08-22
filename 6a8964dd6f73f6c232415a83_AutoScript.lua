--[[

    ============================================================
     矿场全自动脚本 - Mobile Edition
     基于WindUI框架 | 全功能自动化
    ============================================================
     功能列表:
       1. 自动出售代币 (循环)
       2. 自动购买硬件 (单件/全部/循环)
       3. 自动购买数据市场 (单件/全部/循环)
       4. 自动转生
       5. 自动防御小游戏 (start->hit->done)
       6. USB Hack (prox/arm)
       7. 持有/放下平板
       8. 自动分配技能点 (Money/Security)
       9. 快速传送 (Sell/Home/Shops)
      10. 背包布局管理
      11. 一键全自动化 (整合循环)
    ============================================================
--]]

-- ========== 加载WindUI ==========
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/finendss/VowLibrary/refs/heads/main/WINDUI.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- ========== Remote 引用 ==========
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local UiTrack = Remotes:WaitForChild("UiTrack")
local Warp = Remotes:WaitForChild("Warp")
local SellTokens = Remotes:WaitForChild("SellTokens")
local BuyItem = Remotes:WaitForChild("BuyItem")
local SetInvLayout = Remotes:WaitForChild("SetInvLayout")
local HackDefend = Remotes:WaitForChild("HackDefend")
local SetTabletHeld = Remotes:WaitForChild("SetTabletHeld")
local SpendSkillPoints = Remotes:WaitForChild("SpendSkillPoints")
local UsbHackStart = Remotes:WaitForChild("UsbHackStart")

-- ========== 全局状态控制 ==========
local Flags = {
    autoSellTokens = false,
    autoRebirth = false,
    autoHackDefend = false,
    autoBuyHardware = false,
    autoBuyDataMarket = false,
    autoSkillMoney = false,
    autoSkillSecurity = false,
    masterAutoFarm = false,
    autoUsbHack = false,
}

-- ========== 物品列表 ==========
local HardwareItems = {
    "USB Stick", "Old Laptop", "Office PC", "Gaming PC",
    "Mining Rig", "GPU Server", "GPU Rack", "TPU Pod",
    "Inference Rack", "Liquid Cluster", "Server Tower",
    "Quantum Node", "Tensor Spire", "Web Scraper", "Data Center Feed"
}

local DataMarketItems = {
    "RSS Harvester", "Crawler Farm", "Sensor Network",
    "Satellite Uplink", "Orbital Dish Array", "Neural Data Mine"
}

local SkillTypes = {"Money", "Security"}

-- ========== 默认背包布局 ==========
local DefaultInvLayout = {
    ["USB Stick"] = 1,
    ["Old Laptop"] = 2,
    ["Office PC"] = 3,
    ["Gaming PC"] = 4,
    ["Mining Rig"] = 5,
    ["GPU Server"] = 6,
    ["GPU Rack"] = 7,
    ["Inference Rack"] = 8,
    ["TPU Pod"] = 9,
    ["Server Tower"] = 10,
    ["Liquid Cluster"] = 11,
    ["Quantum Node"] = 12,
    ["Web Scraper"] = 13,
    ["RSS Harvester"] = 14,
    ["Data Center Feed"] = 15,
    ["Crawler Farm"] = 16,
    ["Sensor Network"] = 17,
    ["Orbital Dish Array"] = 18,
    ["Neural Data Mine"] = 19,
}

-- ========== 辅助函数 ==========
local function safeNotify(title, content)
    pcall(function()
        WindUI:Notify({
            Title = title,
            Content = content or "",
            Duration = 4
        })
    end)
end

local function fireUiTrack(state, window)
    pcall(function()
        UiTrack:FireServer(state, window)
    end)
end

local function fireWarp(dest)
    pcall(function()
        Warp:FireServer(dest)
    end)
end

local function invokeBuy(category, item)
    pcall(function()
        BuyItem:InvokeServer(category, item)
    end)
end

local function fireSellTokens()
    pcall(function()
        SellTokens:FireServer()
    end)
end

local function fireHackDefend(state)
    pcall(function()
        HackDefend:FireServer(state)
    end)
end

local function fireSetTabletHeld(state)
    pcall(function()
        SetTabletHeld:FireServer(state)
    end)
end

local function fireSpendSkill(skillType, amount)
    pcall(function()
        SpendSkillPoints:FireServer(skillType, amount)
    end)
end

local function fireUsbHack(index, hackType)
    pcall(function()
        UsbHackStart:FireServer(index, hackType)
    end)
end

local function fireSetInvLayout(layout)
    pcall(function()
        SetInvLayout:FireServer(layout)
    end)
end

-- ========== 创建窗口 ==========
local Window = WindUI:CreateWindow({
    Title = "Mining Tycoon XJW脚本",
    Icon = "sparkles",
    Author = "Full Auto XJW脚本",
    Folder = "AIMiningAuto",
    Size = UDim2.fromOffset(420, 500),
    Theme = "Pink",
    HideSearchBar = false,
})

-- ========== 边框流动效果 ==========
local mainContainer = Window.UIElements and Window.UIElements.Main
if mainContainer then
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = Color3.new(1, 1, 1)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
        ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 100, 200)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(100, 200, 255)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(100, 255, 100)),
        ColorSequenceKeypoint.new(0.8, Color3.fromRGB(255, 200, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 50)),
    })
    gradient.Enabled = true
    gradient.Parent = stroke
    stroke.Parent = mainContainer

    task.spawn(function()
        local speed = 8
        while stroke and stroke.Parent do
            task.wait()
            gradient.Rotation = (gradient.Rotation + speed) % 360
        end
    end)
end

-- ========== 时间标签 ==========
local TimeTag = Window:Tag({
    Title = "00:00",
    Color = Color3.fromRGB(255, 255, 255)
})

local hue = 0
task.spawn(function()
    while true do
        local now = os.date("*t")
        local hours = string.format("%02d", now.hour)
        local minutes = string.format("%02d", now.min)
        local seconds = string.format("%02d", now.sec)

        hue = (hue + 0.01) % 1
        local rainbowColor = Color3.fromHSV(hue, 1, 1)

        TimeTag:SetTitle(hours .. ":" .. minutes .. ":" .. seconds)
        TimeTag:SetColor(rainbowColor)
        task.wait(0.06)
    end
end)

Window:Tag({
    Title = "v2.0 Full Auto",
    Color = Color3.fromHex("#7FDBFF")
})

Window:EditOpenButton({
    Title = "AI Mining Tycoon",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("FF6B6B")),
    Draggable = true,
})

-- ================================================================
-- Tab 1: 自动化农场 (主控制台)
-- ================================================================
local TabFarm = Window:Tab({
    Title = "自动农场",
    Icon = "rocket",
})

TabFarm:Section({Title = "一键全自动化", TextXAlignment = "Left", TextSize = 17})

TabFarm:Paragraph({
    Title = "一键全自动",
    Desc = "开启后自动: 出售代币 -> 购买硬件 -> 购买数据市场 -> 转生 -> 防御 -> 分配技能点",
})

TabFarm:Toggle({
    Title = "一键全自动化",
    Default = false,
    Callback = function(state)
        Flags.masterAutoFarm = state
        if state then
            -- 同时开启所有子功能
            Flags.autoSellTokens = true
            Flags.autoBuyHardware = true
            Flags.autoBuyDataMarket = true
            Flags.autoHackDefend = true
            Flags.autoSkillMoney = true
            Flags.autoSkillSecurity = true
            safeNotify("全自动已开启", "所有自动化循环已启动")
        else
            Flags.autoSellTokens = false
            Flags.autoBuyHardware = false
            Flags.autoBuyDataMarket = false
            Flags.autoHackDefend = false
            Flags.autoSkillMoney = false
            Flags.autoSkillSecurity = false
            safeNotify("全自动已关闭", "所有自动化循环已停止")
        end
    end
})

-- 主循环
local farmDelay = 3
TabFarm:Slider({
    Title = "主循环间隔(秒)",
    Value = {Min = 1, Max = 30, Default = 3},
    Increment = 1,
    Callback = function(value)
        farmDelay = value
    end
})

TabFarm:Section({Title = "单项自动化", TextXAlignment = "Left", TextSize = 17})

-- 自动出售代币
TabFarm:Toggle({
    Title = "自动出售代币",
    Default = false,
    Callback = function(state)
        Flags.autoSellTokens = state
        if state then
            safeNotify("自动出售", "开始循环出售代币")
        else
            safeNotify("已停止", "自动出售已停止")
        end
    end
})

-- 自动购买硬件
TabFarm:Toggle({
    Title = "自动购买硬件(全部)",
    Default = false,
    Callback = function(state)
        Flags.autoBuyHardware = state
        if state then
            safeNotify("自动购买硬件", "循环购买所有硬件物品")
        else
            safeNotify("已停止", "自动购买硬件已停止")
        end
    end
})

-- 自动购买数据市场
TabFarm:Toggle({
    Title = "自动购买数据市场(全部)",
    Default = false,
    Callback = function(state)
        Flags.autoBuyDataMarket = state
        if state then
            safeNotify("自动购买数据", "循环购买所有数据市场物品")
        else
            safeNotify("已停止", "自动购买数据已停止")
        end
    end
})

-- 自动转生
local rebirthDelay = 5
TabFarm:Toggle({
    Title = "自动转生",
    Default = false,
    Callback = function(state)
        Flags.autoRebirth = state
        if state then
            safeNotify("自动转生", "每" .. rebirthDelay .. "秒尝试转生一次")
        else
            safeNotify("已停止", "自动转生已停止")
        end
    end
})

TabFarm:Slider({
    Title = "转生间隔(秒)",
    Value = {Min = 3, Max = 120, Default = 5},
    Increment = 1,
    Callback = function(value)
        rebirthDelay = value
    end
})

-- 主自动化循环
task.spawn(function()
    while true do
        if Flags.masterAutoFarm or Flags.autoSellTokens then
            fireUiTrack("WindowOpened", "TokenExchange")
            task.wait(0.1)
            fireSellTokens()
            task.wait(0.1)
            fireUiTrack("WindowClosed", "TokenExchange")
        end

        if Flags.autoBuyHardware then
            fireUiTrack("WindowOpened", "Shop")
            task.wait(0.1)
            for _, item in ipairs(HardwareItems) do
                invokeBuy("Hardware", item)
                task.wait(0.05)
            end
            task.wait(0.1)
            fireUiTrack("WindowClosed", "Shop")
        end

        if Flags.autoBuyDataMarket then
            fireUiTrack("WindowOpened", "Shop")
            task.wait(0.1)
            for _, item in ipairs(DataMarketItems) do
                invokeBuy("DataMarket", item)
                task.wait(0.05)
            end
            task.wait(0.1)
            fireUiTrack("WindowClosed", "Shop")
        end

        if Flags.masterAutoFarm or Flags.autoSkillMoney then
            fireSpendSkill("Money", 1)
            task.wait(0.05)
        end

        if Flags.masterAutoFarm or Flags.autoSkillSecurity then
            fireSpendSkill("Security", 1)
            task.wait(0.05)
        end

        if Flags.masterAutoFarm or Flags.autoSellTokens or Flags.autoBuyHardware or Flags.autoBuyDataMarket or Flags.autoSkillMoney or Flags.autoSkillSecurity then
            task.wait(farmDelay)
        else
            task.wait(0.5)
        end
    end
end)

-- 转生循环
task.spawn(function()
    while true do
        if Flags.autoRebirth or Flags.masterAutoFarm then
            fireUiTrack("WindowOpened", "Rebirth")
            task.wait(0.2)
            -- 尝试触发转生
            pcall(function()
                local rebirthRemote = Remotes:FindFirstChild("Rebirth")
                if rebirthRemote then
                    if rebirthRemote:IsA("RemoteFunction") then
                        rebirthRemote:InvokeServer()
                    else
                        rebirthRemote:FireServer()
                    end
                end
            end)
            task.wait(0.2)
            fireUiTrack("WindowClosed", "Rebirth")
            task.wait(rebirthDelay)
        else
            task.wait(1)
        end
    end
end)

-- 自动防御循环
task.spawn(function()
    while true do
        if Flags.autoHackDefend or Flags.masterAutoFarm then
            fireHackDefend("start")
            task.wait(0.1)
            fireHackDefend("hit")
            task.wait(0.1)
            fireHackDefend("done")
        end
        task.wait(0.5)
    end
end)

-- ================================================================
-- Tab 2: 硬件商店
-- ================================================================
local TabHardware = Window:Tab({
    Title = "硬件商店",
    Icon = "monitor",
})

TabHardware:Section({Title = "快速购买", TextXAlignment = "Left", TextSize = 17})

TabHardware:Button({
    Title = "购买全部硬件",
    Callback = function()
        fireUiTrack("WindowOpened", "Shop")
        task.wait(0.1)
        for _, item in ipairs(HardwareItems) do
            invokeBuy("Hardware", item)
            task.wait(0.05)
        end
        task.wait(0.1)
        fireUiTrack("WindowClosed", "Shop")
        safeNotify("购买完成", "已尝试购买全部硬件")
    end
})

TabHardware:Dropdown({
    Title = "选择硬件物品",
    Values = HardwareItems,
    Value = "USB Stick",
    Callback = function(item)
        TabHardware.selectedHardware = item
    end
})

TabHardware:Button({
    Title = "购买选中物品",
    Callback = function()
        local item = TabHardware.selectedHardware or "USB Stick"
        invokeBuy("Hardware", item)
        safeNotify("购买", "已购买: " .. item)
    end
})

TabHardware:Section({Title = "批量购买", TextXAlignment = "Left", TextSize = 17})

local hwBuyCount = 10
TabHardware:Slider({
    Title = "购买次数",
    Value = {Min = 1, Max = 100, Default = 10},
    Increment = 1,
    Callback = function(value)
        hwBuyCount = value
    end
})

TabHardware:Dropdown({
    Title = "批量选择物品",
    Values = HardwareItems,
    Value = "Office PC",
    Callback = function(item)
        TabHardware.bulkHardware = item
    end
})

TabHardware:Button({
    Title = "开始批量购买",
    Callback = function()
        local item = TabHardware.bulkHardware or "Office PC"
        task.spawn(function()
            for i = 1, hwBuyCount do
                invokeBuy("Hardware", item)
                task.wait(0.03)
            end
            safeNotify("批量购买完成", item .. " x" .. hwBuyCount)
        end)
    end
})

-- ================================================================
-- Tab 3: 数据市场
-- ================================================================
local TabData = Window:Tab({
    Title = "数据市场",
    Icon = "database",
})

TabData:Section({Title = "快速购买", TextXAlignment = "Left", TextSize = 17})

TabData:Button({
    Title = "购买全部数据市场",
    Callback = function()
        fireUiTrack("WindowOpened", "Shop")
        task.wait(0.1)
        for _, item in ipairs(DataMarketItems) do
            invokeBuy("DataMarket", item)
            task.wait(0.05)
        end
        task.wait(0.1)
        fireUiTrack("WindowClosed", "Shop")
        safeNotify("购买完成", "已尝试购买全部数据市场物品")
    end
})

TabData:Dropdown({
    Title = "选择数据物品",
    Values = DataMarketItems,
    Value = "RSS Harvester",
    Callback = function(item)
        TabData.selectedData = item
    end
})

TabData:Button({
    Title = "购买选中物品",
    Callback = function()
        local item = TabData.selectedData or "RSS Harvester"
        invokeBuy("DataMarket", item)
        safeNotify("购买", "已购买: " .. item)
    end
})

TabData:Section({Title = "批量购买", TextXAlignment = "Left", TextSize = 17})

local dataBuyCount = 10
TabData:Slider({
    Title = "购买次数",
    Value = {Min = 1, Max = 100, Default = 10},
    Increment = 1,
    Callback = function(value)
        dataBuyCount = value
    end
})

TabData:Dropdown({
    Title = "批量选择物品",
    Values = DataMarketItems,
    Value = "Sensor Network",
    Callback = function(item)
        TabData.bulkData = item
    end
})

TabData:Button({
    Title = "开始批量购买",
    Callback = function()
        local item = TabData.bulkData or "Sensor Network"
        task.spawn(function()
            for i = 1, dataBuyCount do
                invokeBuy("DataMarket", item)
                task.wait(0.03)
            end
            safeNotify("批量购买完成", item .. " x" .. dataBuyCount)
        end)
    end
})

-- ================================================================
-- Tab 4: 技能与转生
-- ================================================================
local TabSkill = Window:Tab({
    Title = "技能转生",
    Icon = "star",
})

TabSkill:Section({Title = "技能点分配", TextXAlignment = "Left", TextSize = 17})

TabSkill:Button({
    Title = "分配全部到金钱",
    Callback = function()
        task.spawn(function()
            for i = 1, 50 do
                fireSpendSkill("Money", 1)
                task.wait(0.03)
            end
            safeNotify("技能分配", "已分配50点金钱技能")
        end)
    end
})

TabSkill:Button({
    Title = "分配全部到安全",
    Callback = function()
        task.spawn(function()
            for i = 1, 50 do
                fireSpendSkill("Security", 1)
                task.wait(0.03)
            end
            safeNotify("技能分配", "已分配50点安全技能")
        end)
    end
})

TabSkill:Toggle({
    Title = "自动分配金钱技能",
    Default = false,
    Callback = function(state)
        Flags.autoSkillMoney = state
        if state then
            safeNotify("自动技能", "持续分配金钱技能点")
        end
    end
})

TabSkill:Toggle({
    Title = "自动分配安全技能",
    Default = false,
    Callback = function(state)
        Flags.autoSkillSecurity = state
        if state then
            safeNotify("自动技能", "持续分配安全技能点")
        end
    end
})

TabSkill:Section({Title = "转生", TextXAlignment = "Left", TextSize = 17})

TabSkill:Button({
    Title = "立即转生",
    Callback = function()
        fireUiTrack("WindowOpened", "Rebirth")
        task.wait(0.3)
        pcall(function()
            local rebirthRemote = Remotes:FindFirstChild("Rebirth")
            if rebirthRemote then
                if rebirthRemote:IsA("RemoteFunction") then
                    rebirthRemote:InvokeServer()
                else
                    rebirthRemote:FireServer()
                end
            end
        end)
        task.wait(0.2)
        fireUiTrack("WindowClosed", "Rebirth")
        safeNotify("转生", "已尝试转生")
    end
})

local rebirthLoopDelay = 10
TabSkill:Toggle({
    Title = "自动转生循环",
    Default = false,
    Callback = function(state)
        Flags.autoRebirth = state
        if state then
            safeNotify("自动转生", "每" .. rebirthLoopDelay .. "秒转生一次")
        else
            safeNotify("已停止", "自动转生已停止")
        end
    end
})

TabSkill:Slider({
    Title = "转生循环间隔(秒)",
    Value = {Min = 3, Max = 120, Default = 10},
    Increment = 1,
    Callback = function(value)
        rebirthLoopDelay = value
        rebirthDelay = value
    end
})

-- ================================================================
-- Tab 5: Hack 系统
-- ================================================================
local TabHack = Window:Tab({
    Title = "Hack系统",
    Icon = "shield",
})

TabHack:Section({Title = "防御小游戏", TextXAlignment = "Left", TextSize = 17})

TabHack:Button({
    Title = "一键完成防御",
    Callback = function()
        fireHackDefend("start")
        task.wait(0.1)
        fireHackDefend("hit")
        task.wait(0.1)
        fireHackDefend("done")
        safeNotify("防御完成", "防御小游戏已完成")
    end
})

TabHack:Toggle({
    Title = "自动防御(循环)",
    Default = false,
    Callback = function(state)
        Flags.autoHackDefend = state
        if state then
            safeNotify("自动防御", "自动完成防御小游戏")
        end
    end
})

local hackDelay = 0.5
TabHack:Slider({
    Title = "防御间隔(秒)",
    Value = {Min = 0.1, Max = 10, Default = 0.5},
    Increment = 0.1,
    Callback = function(value)
        hackDelay = value
    end
})

TabHack:Section({Title = "USB Hack", TextXAlignment = "Left", TextSize = 17})

local usbIndex = 6
TabHack:Slider({
    Title = "USB目标编号",
    Value = {Min = 1, Max = 20, Default = 6},
    Increment = 1,
    Callback = function(value)
        usbIndex = value
    end
})

TabHack:Button({
    Title = "Prox Hack",
    Callback = function()
        fireUsbHack(usbIndex, "prox")
        safeNotify("USB Hack", "已发送 Prox Hack (目标:" .. usbIndex .. ")")
    end
})

TabHack:Button({
    Title = "Arm Hack",
    Callback = function()
        fireUsbHack(usbIndex, "arm")
        safeNotify("USB Hack", "已发送 Arm Hack (目标:" .. usbIndex .. ")")
    end
})

TabHack:Button({
    Title = "全部Hack(Prox+Arm)",
    Callback = function()
        fireUsbHack(usbIndex, "prox")
        task.wait(0.2)
        fireUsbHack(usbIndex, "arm")
        safeNotify("USB Hack", "已发送 Prox + Arm (目标:" .. usbIndex .. ")")
    end
})

TabHack:Toggle({
    Title = "自动USB Hack循环",
    Default = false,
    Callback = function(state)
        Flags.autoUsbHack = state
        if state then
            safeNotify("自动USB Hack", "循环发送Prox+Arm")
        end
    end
})

-- USB Hack 循环
task.spawn(function()
    while true do
        if Flags.autoUsbHack then
            fireUsbHack(usbIndex, "prox")
            task.wait(0.2)
            fireUsbHack(usbIndex, "arm")
            task.wait(hackDelay)
        else
            task.wait(0.5)
        end
    end
end)

TabHack:Section({Title = "平板控制", TextXAlignment = "Left", TextSize = 17})

TabHack:Button({
    Title = "持有平板",
    Callback = function()
        fireSetTabletHeld(true)
        safeNotify("平板", "已持有平板")
    end
})

TabHack:Button({
    Title = "放下平板",
    Callback = function()
        fireSetTabletHeld(false)
        safeNotify("平板", "已放下平板")
    end
})

-- ================================================================
-- Tab 6: 传送与背包
-- ================================================================
local TabWarp = Window:Tab({
    Title = "传送背包",
    Icon = "map",
})

TabWarp:Section({Title = "快速传送", TextXAlignment = "Left", TextSize = 17})

TabWarp:Button({
    Title = "传送到出售区",
    Callback = function()
        fireWarp("Sell")
        safeNotify("传送", "已传送到出售区")
    end
})

TabWarp:Button({
    Title = "传送到家",
    Callback = function()
        fireWarp("Home")
        safeNotify("传送", "已传送到家")
    end
})

TabWarp:Button({
    Title = "传送到商店",
    Callback = function()
        fireWarp("Shops")
        safeNotify("传送", "已传送到商店")
    end
})

TabWarp:Section({Title = "出售代币", TextXAlignment = "Left", TextSize = 17})

TabWarp:Button({
    Title = "立即出售代币",
    Callback = function()
        fireUiTrack("WindowOpened", "TokenExchange")
        task.wait(0.1)
        fireSellTokens()
        task.wait(0.1)
        fireUiTrack("WindowClosed", "TokenExchange")
        safeNotify("出售", "已出售代币")
    end
})

TabWarp:Button({
    Title = "传送到出售区并出售",
    Callback = function()
        fireWarp("Sell")
        task.wait(0.3)
        fireUiTrack("WindowOpened", "TokenExchange")
        task.wait(0.1)
        fireSellTokens()
        task.wait(0.1)
        fireUiTrack("WindowClosed", "TokenExchange")
        safeNotify("完成", "已传送并出售代币")
    end
})

TabWarp:Section({Title = "背包布局", TextXAlignment = "Left", TextSize = 17})

TabWarp:Button({
    Title = "应用默认背包布局",
    Callback = function()
        fireSetInvLayout(DefaultInvLayout)
        safeNotify("背包", "已应用默认布局")
    end
})

TabWarp:Button({
    Title = "自动整理背包(循环刷新)",
    Callback = function()
        fireSetInvLayout(DefaultInvLayout)
        safeNotify("背包", "已刷新背包布局")
    end
})

local invRefreshDelay = 5
TabWarp:Slider({
    Title = "背包刷新间隔(秒)",
    Value = {Min = 1, Max = 60, Default = 5},
    Increment = 1,
    Callback = function(value)
        invRefreshDelay = value
    end
})

local autoInvRefresh = false
TabWarp:Toggle({
    Title = "自动刷新背包",
    Default = false,
    Callback = function(state)
        autoInvRefresh = state
        if state then
            safeNotify("背包", "每" .. invRefreshDelay .. "秒刷新一次")
        end
    end
})

-- 背包刷新循环
task.spawn(function()
    while true do
        if autoInvRefresh then
            fireSetInvLayout(DefaultInvLayout)
            task.wait(invRefreshDelay)
        else
            task.wait(0.5)
        end
    end
end)

-- ================================================================
-- Tab 7: 设置
-- ================================================================
local TabSettings = Window:Tab({
    Title = "设置",
    Icon = "settings",
})

TabSettings:Section({Title = "一键操作", TextXAlignment = "Left", TextSize = 17})

TabSettings:Button({
    Title = "一键全流程(出售+购买+技能+转生)",
    Callback = function()
        task.spawn(function()
            safeNotify("全流程", "开始执行一键全流程...")
            -- 出售代币
            fireWarp("Sell")
            task.wait(0.3)
            fireUiTrack("WindowOpened", "TokenExchange")
            task.wait(0.1)
            fireSellTokens()
            task.wait(0.1)
            fireUiTrack("WindowClosed", "TokenExchange")
            safeNotify("全流程", "步骤1/4: 代币已出售")

            -- 购买硬件
            fireWarp("Shops")
            task.wait(0.3)
            fireUiTrack("WindowOpened", "Shop")
            task.wait(0.1)
            for _, item in ipairs(HardwareItems) do
                invokeBuy("Hardware", item)
                task.wait(0.05)
            end
            safeNotify("全流程", "步骤2/4: 硬件已购买")

            -- 购买数据市场
            for _, item in ipairs(DataMarketItems) do
                invokeBuy("DataMarket", item)
                task.wait(0.05)
            end
            task.wait(0.1)
            fireUiTrack("WindowClosed", "Shop")
            safeNotify("全流程", "步骤3/4: 数据市场已购买")

            -- 分配技能点
            for i = 1, 20 do
                fireSpendSkill("Money", 1)
                task.wait(0.02)
            end
            for i = 1, 20 do
                fireSpendSkill("Security", 1)
                task.wait(0.02)
            end
            safeNotify("全流程", "步骤4/4: 技能点已分配")

            -- 转生
            fireUiTrack("WindowOpened", "Rebirth")
            task.wait(0.3)
            pcall(function()
                local rebirthRemote = Remotes:FindFirstChild("Rebirth")
                if rebirthRemote then
                    if rebirthRemote:IsA("RemoteFunction") then
                        rebirthRemote:InvokeServer()
                    else
                        rebirthRemote:FireServer()
                    end
                end
            end)
            task.wait(0.2)
            fireUiTrack("WindowClosed", "Rebirth")

            -- 防御
            fireHackDefend("start")
            task.wait(0.1)
            fireHackDefend("hit")
            task.wait(0.1)
            fireHackDefend("done")

            safeNotify("全流程完成", "所有步骤执行完毕!")
        end)
    end
})

TabSettings:Button({
    Title = "停止所有自动化",
    Callback = function()
        Flags.masterAutoFarm = false
        Flags.autoSellTokens = false
        Flags.autoRebirth = false
        Flags.autoHackDefend = false
        Flags.autoBuyHardware = false
        Flags.autoBuyDataMarket = false
        Flags.autoSkillMoney = false
        Flags.autoSkillSecurity = false
        Flags.autoUsbHack = false
        autoInvRefresh = false
        safeNotify("紧急停止", "所有自动化已停止")
    end
})

TabSettings:Section({Title = "脚本信息", TextXAlignment = "Left", TextSize = 17})

TabSettings:Paragraph({
    Title = "AI Mining Tycoon - Full Auto",
    Desc = "版本: v2.0\n平台: Mobile/PC\n框架: WindUI\n\n功能:\n- 自动出售代币\n- 自动购买硬件\n- 自动购买数据市场\n- 自动转生\n- 自动防御小游戏\n- USB Hack\n- 自动技能分配\n- 传送快捷\n- 背包布局管理\n- 一键全自动化",
})

TabSettings:Button({
    Title = "一个通知",
    Callback = function()
        WindUI:Notify({
            Title = "AI Mining Tycoon",
            Content = "脚本已加载成功! 感谢使用",
            Duration = 5
        })
    end
})

-- ========== 启动通知 ==========
task.wait(0.5)
safeNotify("脚本已加载", "AI Mining Tycoon Full Auto v2.0")
print("[AI Mining] 脚本已加载完成!")
print("[AI Mining] Remote列表:")
print("  - UiTrack, Warp, SellTokens, BuyItem, SetInvLayout")
print("  - HackDefend, SetTabletHeld, SpendSkillPoints, UsbHackStart")
