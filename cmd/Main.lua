-- Prevent multiple instances
if getgenv().GAG_AUTOBUY_RUNNING then
    warn("Another instance is running! Stopping this one...")
    return
end
getgenv().GAG_AUTOBUY_RUNNING = true

-- Only run in Grow a Garden
if game.PlaceId ~= 126884695634066 then
    warn("This script only works in Grow a Garden!")
    return
end

-- Load Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- Config Save/Load
local ConfigFolder = "GAG_AFK"
local ConfigFile = ConfigFolder.."/DropWatchConfig.json"
if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
local Config = {}

local function saveConfig()
    writefile(ConfigFile, HttpService:JSONEncode(Config))
end

local function loadConfig()
    if isfile(ConfigFile) then
        local data = readfile(ConfigFile)
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(data)
        end)
        if success and type(decoded) == "table" then
            Config = decoded
        end
    end
end

loadConfig()

-- Default Config values
Config.AutoBuyEnabled = Config.AutoBuyEnabled or false
Config.AntiAFK = Config.AntiAFK ~= false
Config.SelectedSeeds = Config.SelectedSeeds or {}
Config.SelectedEggs = Config.SelectedEggs or {}
Config.SelectedGears = Config.SelectedGears or {}
Config.BuyInterval = Config.BuyInterval or 0.1
Config.Theme = Config.Theme or "Amethyst"
Config.ModifyWalkSpeed = Config.ModifyWalkSpeed or false
Config.ModifyJumpPower = Config.ModifyJumpPower or false
Config.WalkSpeedValue = Config.WalkSpeedValue or 16
Config.JumpPowerValue = Config.JumpPowerValue or 50

-- Timer
local TIMER = { StartTime = 0 }
local function resetTimer() TIMER.StartTime = tick() end

-- Items
local SEEDS = {"Apple","Bamboo","Beanstalk","Blueberry","Burning Bud","Cacao","Cactus","Carrot","Coconut","Corn","Daffodil","Dragon Fruit","Elder Strawberry","Ember Lily","Giant Pinecone","Grape","Mango","Mushroom","Orange Tulip","Pepper","Pumpkin","Romanesco","Strawberry","Sugar Apple","Tomato","Watermelon"}
local EGGS = {"Bug Egg","Common Egg","Legendary Egg","Mythical Egg","Rare Egg","Uncommon Egg"}
local GEARS = {"Advanced Sprinkler","Basic Sprinkler","Cleaning Spray","Cleansing Pet Shard","Favorite Tool","Friendship Pot","Godly Sprinkler","Grandmaster Sprinkler","Harvest Tool","Levelup Lollipop","Magnifying Glass","Master Sprinkler","Recall Wrench","Trading Ticket","Trowel","Watering Can"}

-- Rayfield Window
local Window = Rayfield:CreateWindow({
    Name = "GAG Auto-Buy",
    LoadingTitle = "Loading Script...",
    LoadingSubtitle = "by MART JOHN LABACO",
    ConfigurationSaving = { Enabled=false }, -- handled manually
    KeySystem = false,
    Theme = Config.Theme
})

-- Tabs & Labels
local MainTab = Window:CreateTab("Main", 4483362458)
local StatusLabel = MainTab:CreateLabel("Status: Stopped — by MART JOHN LABACO")
local SelectionLabel = MainTab:CreateLabel("Selected: None")
local TimerLabel = MainTab:CreateLabel("AFK Timer: 0s")
MainTab:CreateLabel("Welcome " .. LocalPlayer.Name .. "!")

-- Dropdowns
local SeedDropdown = MainTab:CreateDropdown({
    Name="Select Seeds", Options=SEEDS, MultipleOptions=true, Search=true,
    CurrentOption = Config.SelectedSeeds,
    Callback=function(opts) Config.SelectedSeeds=opts; saveConfig() end
})
local EggDropdown = MainTab:CreateDropdown({
    Name="Select Eggs", Options=EGGS, MultipleOptions=true, Search=true,
    CurrentOption = Config.SelectedEggs,
    Callback=function(opts) Config.SelectedEggs=opts; saveConfig() end
})
local GearDropdown = MainTab:CreateDropdown({
    Name="Select Gear", Options=GEARS, MultipleOptions=true, Search=true,
    CurrentOption = Config.SelectedGears,
    Callback=function(opts) Config.SelectedGears=opts; saveConfig() end
})

-- Auto-Buy Toggle
MainTab:CreateToggle({
    Name="Auto-Buy (Seeds, Eggs, Gear)",
    CurrentValue=Config.AutoBuyEnabled,
    Callback=function(state)
        Config.AutoBuyEnabled=state
        saveConfig()
        if state then 
            StatusLabel:Set("Status: Running ("..Config.BuyInterval.."s interval)")
            resetTimer()
        else 
            StatusLabel:Set("Status: Stopped — by MART JOHN LABACO") 
            TimerLabel:Set("AFK Timer: 0s")
        end
    end
})

-- UI Keybind
MainTab:CreateKeybind({
    Name="Toggle UI",
    CurrentKeybind="RightShift",
    HoldToInteract=false,
    Callback=function() Rayfield:Toggle() end
})

-- Buy Functions
local function buySeed(name)
    pcall(function() ReplicatedStorage.GameEvents.BuySeedStock:FireServer("Tier 1", name) end)
end
local function buyEgg(name)
    pcall(function() ReplicatedStorage.GameEvents.BuyPetEgg:FireServer(name) end)
end
local function buyGear(name)
    pcall(function() ReplicatedStorage.GameEvents.BuyGearStock:FireServer(name) end)
end

-- Auto-Buy Loop
task.spawn(function()
    while task.wait(Config.BuyInterval) do
        if Config.AutoBuyEnabled then
            for _,s in ipairs(Config.SelectedSeeds) do buySeed(s) end
            for _,e in ipairs(Config.SelectedEggs) do buyEgg(e) end
            for _,g in ipairs(Config.SelectedGears) do buyGear(g) end

            -- Update Selection Label
            local parts={}
            if #Config.SelectedSeeds>0 then table.insert(parts,#Config.SelectedSeeds.." Seeds") end
            if #Config.SelectedEggs>0 then table.insert(parts,#Config.SelectedEggs.." Eggs") end
            if #Config.SelectedGears>0 then table.insert(parts,#Config.SelectedGears.." Gears") end
            SelectionLabel:Set(#parts>0 and ("Selected: "..table.concat(parts,", ")) or "Selected: None")  

            -- Update Timer Label
            local elapsed = math.floor(tick() - TIMER.StartTime)
            TimerLabel:Set("AFK Timer: "..elapsed.."s")
        end
    end
end)

-- Anti-AFK
if Config.AntiAFK then
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
        task.wait(0.5)
        VirtualUser:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
    end)
end

-- Rejoin Button
MainTab:CreateButton({
    Name="Rejoin / Hop Server",
    Callback=function()
        Rayfield:Notify({
            Title="Teleport",
            Content="Attempting to rejoin/hop server...",
            Duration=4
        })
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

-- Theme Selector
MainTab:CreateDropdown({
    Name="UI Theme", Options={"Amethyst","Ocean","Crimson","Dark","Light"},
    CurrentOption=Config.Theme,
    Callback=function(theme) Config.Theme=theme; Rayfield:SetTheme(theme); saveConfig() end
})

-- PLAYER TAB (Movement Mods)
local PlayerTab = Window:CreateTab("Player", 4483362458)

-- WalkSpeed Toggle
PlayerTab:CreateToggle({
    Name = "Modify WalkSpeed",
    CurrentValue = Config.ModifyWalkSpeed,
    Callback = function(Value)
        Config.ModifyWalkSpeed = Value
        if Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeedValue
        elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
        saveConfig()
    end,
})

-- WalkSpeed Slider
PlayerTab:CreateSlider({
    Name = "WalkSpeed Value",
    Range = {16, 200},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = Config.WalkSpeedValue,
    Callback = function(Value)
        Config.WalkSpeedValue = Value
        if Config.ModifyWalkSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
        saveConfig()
    end,
})

-- JumpPower Toggle
PlayerTab:CreateToggle({
    Name = "Modify JumpPower",
    CurrentValue = Config.ModifyJumpPower,
    Callback = function(Value)
        Config.ModifyJumpPower = Value
        if Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = Config.JumpPowerValue
        elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = 50
        end
        saveConfig()
    end,
})

-- JumpPower Slider
PlayerTab:CreateSlider({
    Name = "JumpPower Value",
    Range = {50, 300},
    Increment = 1,
    Suffix = "Jump",
    CurrentValue = Config.JumpPowerValue,
    Callback = function(Value)
        Config.JumpPowerValue = Value
        if Config.ModifyJumpPower and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
        saveConfig()
    end,
})

-- Restore values on load
task.defer(function()
    if Config.ModifyWalkSpeed and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Config.WalkSpeedValue
    end
    if Config.ModifyJumpPower and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid.UseJumpPower = true
        LocalPlayer.Character.Humanoid.JumpPower = Config.JumpPowerValue
    end
end)

-- Notify Welcome
Rayfield:Notify({
    Title="Welcome "..LocalPlayer.Name,
    Content="by MART JOHN LABACO — Multi-AutoBuy + Player Tab Ready",
    Duration=6,
    Image=4483362458
})
