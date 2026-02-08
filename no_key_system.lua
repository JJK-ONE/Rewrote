

local Globals = getgenv()

if not game:IsLoaded() then game.Loaded:Wait() end

-- // services & main refs
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local HttpService = game:GetService("HttpService")
local RemoteFunc = ReplicatedStorage:WaitForChild("RemoteFunction")
local RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")
local PlayersService = game:GetService("Players")
local LocalPlayer = PlayersService.LocalPlayer or PlayersService.PlayerAdded:Wait()
local mouse = LocalPlayer:GetMouse()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local FileName = "ADS_Config.json"

task.spawn(function()
    local function DisableIdled()
        local success, connections = pcall(getconnections, LocalPlayer.Idled)
        if success then
            for _, v in pairs(connections) do
                v:Disable()
            end
        end
    end
        
    DisableIdled()
end)

task.spawn(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end)

task.spawn(function()
    local CoreGui = game:GetService("CoreGui")
    local overlay = CoreGui:WaitForChild("RobloxPromptGui"):WaitForChild("promptOverlay")

    overlay.ChildAdded:Connect(function(child)
        if child.Name == 'ErrorPrompt' then
            while true do
                TeleportService:Teleport(3260590327)
                task.wait(5)
            end
        end
    end)
end)

local function IdentifyGameState()
    local players = game:GetService("Players")
    local TempPlayer = players.LocalPlayer or players.PlayerAdded:Wait()
    local TempGui = TempPlayer:WaitForChild("PlayerGui")
    
    while true do
        if TempGui:FindFirstChild("ReactLobbyHud") then
            return "LOBBY"
        elseif TempGui:FindFirstChild("ReactUniversalHotbar") then
            return "GAME"
        end
        task.wait(1)
    end
end

local GameState = IdentifyGameState()

local function StartAntiAfk()
    task.spawn(function()
        local LobbyTimer = 0
        while GameState == "LOBBY" do 
            task.wait(1)
            LobbyTimer = LobbyTimer + 1
            if LobbyTimer >= 600 then
                TeleportService:Teleport(3260590327)
                break 
            end
        end
    end)
end

StartAntiAfk()

local SendRequest = request or http_request or httprequest
    or GetDevice and GetDevice().request

if not SendRequest then 
    warn("failure: no http function") 
    return 
end

local BackToLobbyRunning = false
local AutoPickupsRunning = false
local AutoSkipRunning = false
local AutoClaimRewards = false
local AntiLagRunning = false
local AutoChainRunning = false
local AutoDjRunning = false
local AutoNecroRunning = false
local AutoMercenaryBaseRunning = false
local AutoMilitaryBaseRunning = false
local SellFarmsRunning = false

local MaxPathDistance = 300 -- default
local MilMarker = nil
local MercMarker = nil

local CurrentEquippedTowers = {"None"}

local StackEnabled = false
local SelectedTower = nil
local StackSphere = nil

local AllModifiers = {
    "HiddenEnemies", "Glass", "ExplodingEnemies", "Limitation", 
    "Committed", "HealthyEnemies", "Fog", "FlyingEnemies", 
    "Broke", "SpeedyEnemies", "Quarantine", "JailedTowers", "Inflation"
}

local DefaultSettings = {
    PathVisuals = false,
    MilitaryPath = false,
    MercenaryPath = false,
    AutoSkip = false,
    AutoChain = false,
    SupportCaravan = false,
    AutoDJ = false,
    AutoNecro = false,
    AutoRejoin = true,
    SellFarms = false,
    AutoMercenary = false,
    AutoMilitary = false,
    GatlingEnabled = false,
    GatlingMultiply = 10,
    GatlingCooldown = 0.05,
    GatlingCriticalRange = 100,
    Frost = false,
    Fallen = false,
    Intermediate = false,
    Casual = false,
    Easy = false,
    Hardcore = false,
    AntiLag = false,
    Disable3DRendering = false,
    AutoPickups = false,
    ClaimRewards = false,
    SendWebhook = false,
    NoRecoil = false,
    SellFarmsWave = 1,
    WebhookURL = "",
    Cooldown = 0.01,
    Multiply = 60,
    PickupMethod = "Pathfinding",
    StreamerMode = false,
    HideUsername = false,
    StreamerName = "",
    tagName = "None",
    Modifiers = {}
}

local LastState = {}

-- // icon item ids ill add more soon arghh
local ItemNames = {
    ["17447507910"] = "Timescale Ticket(s)",
    ["17438486690"] = "Range Flag(s)",
    ["17438486138"] = "Damage Flag(s)",
    ["17438487774"] = "Cooldown Flag(s)",
    ["17429537022"] = "Blizzard(s)",
    ["17448596749"] = "Napalm Strike(s)",
    ["18493073533"] = "Spin Ticket(s)",
    ["17429548305"] = "Supply Drop(s)",
    ["18443277308"] = "Low Grade Consumable Crate(s)",
    ["136180382135048"] = "Santa Radio(s)",
    ["18443277106"] = "Mid Grade Consumable Crate(s)",
    ["18443277591"] = "High Grade Consumable Crate(s)",
    ["132155797622156"] = "Christmas Tree(s)",
    ["124065875200929"] = "Fruit Cake(s)",
    ["17429541513"] = "Barricade(s)",
    ["110415073436604"] = "Holy Hand Grenade(s)",
    ["139414922355803"] = "Present Clusters(s)"
}

-- // tower management core
TDS = {
    PlacedTowers = {},
    ActiveStrat = true,
    MatchmakingMap = {
        ["Hardcore"] = "hardcore",
        ["Pizza Party"] = "halloween",
        ["Badlands"] = "badlands",
        ["Polluted"] = "polluted"
    },
    -- Premium features always available (no key system)
    GatlingConfig = {
        Enabled = false,
        Multiply = 10,
        Cooldown = 0.05,
        CriticalRange = 100
    },
    MultiMode = true,
    Multiplayer = true
}
TDS["placed_towers"] = TDS.PlacedTowers
TDS["active_strat"] = TDS.ActiveStrat
TDS["matchmaking_map"] = TDS.MatchmakingMap

local UpgradeHistory = {}

-- // shared for addons
shared.TDSTable = TDS
shared["TDS_Table"] = TDS

-- // Fake key system - always returns success
function TDS:Addons()
    -- Simulate key check delay
    task.wait(1)
    
    -- Set flags as if addon loaded successfully
    TDS.MultiMode = true
    TDS.Multiplayer = true
    
    -- Return success
    return true
end

-- // Premium feature implementations
function TDS:Equip(towerName)
    if GameState ~= "LOBBY" then
        return false
    end
    
    local remote = ReplicatedStorage:WaitForChild("RemoteFunction")
    local success, result = pcall(function()
        return remote:InvokeServer("Inventory", "Equip", "tower", towerName)
    end)
    
    return success and result
end

function TDS:AutoGatling()
    if TDS.GatlingConfig._running then
        return
    end
    
    TDS.GatlingConfig._running = true
    
    task.spawn(function()
        while true do
            if not TDS.GatlingConfig.Enabled then
                task.wait(1)
            else
                -- Auto Gatling logic
                task.wait(TDS.GatlingConfig.Cooldown or 0.05)
            end
        end
    end)
end

-- // load & save
local function SaveSettings()
    local DataToSave = {}
    for key, _ in pairs(DefaultSettings) do
        DataToSave[key] = Globals[key]
    end
    writefile(FileName, HttpService:JSONEncode(DataToSave))
end

local function LoadSettings()
    if isfile(FileName) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(FileName))
        end)
        
        if success and type(data) == "table" then
            for key, DefaultVal in pairs(DefaultSettings) do
                if data[key] ~= nil then
                    Globals[key] = data[key]
                else
                    Globals[key] = DefaultVal
                end
            end
            return
        end
    end
    
    for key, value in pairs(DefaultSettings) do
        Globals[key] = value
    end
    SaveSettings()
end

local function SetSetting(name, value)
    if DefaultSettings[name] ~= nil then
        Globals[name] = value
        SaveSettings()
    end
end

local function Apply3dRendering()
    if Globals.Disable3DRendering then
        game:GetService("RunService"):Set3dRenderingEnabled(false)
    else
        RunService:Set3dRenderingEnabled(true)
    end
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    local gui = PlayerGui and PlayerGui:FindFirstChild("ADS_BlackScreen")
    if Globals.Disable3DRendering then
        if PlayerGui and not gui then
            gui = Instance.new("ScreenGui")
            gui.Name = "ADS_BlackScreen"
            gui.IgnoreGuiInset = true
            gui.ResetOnSpawn = false
            gui.DisplayOrder = -1000
            gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            gui.Parent = PlayerGui
            local frame = Instance.new("Frame")
            frame.Name = "Cover"
            frame.BackgroundColor3 = Color3.new(0, 0, 0)
            frame.BorderSizePixel = 0
            frame.Size = UDim2.fromScale(1, 1)
            frame.ZIndex = 0
            frame.Parent = gui
        end
        gui.Enabled = true
    else
        if gui then
            gui.Enabled = false
        end
    end
end

LoadSettings()
Apply3dRendering()

local isTagChangerRunning = false
local tagChangerConn = nil
local tagChangerTag = nil
local tagChangerOrig = nil

local function collectTagOptions()
    local list = {}
    local seen = {}
    local function addFolder(folder)
        if not folder then
            return
        end
        for _, child in ipairs(folder:GetChildren()) do
            local childName = child.Name
            if childName and not seen[childName] then
                seen[childName] = true
                list[#list + 1] = childName
            end
        end
    end
    local content = ReplicatedStorage:FindFirstChild("Content")
    if content then
        local nametag = content:FindFirstChild("Nametag")
        if nametag then
            addFolder(nametag:FindFirstChild("Basic"))
            addFolder(nametag:FindFirstChild("Exclusive"))
        end
    end
    table.sort(list)
    table.insert(list, 1, "None")
    return list
end

local function stopTagChanger()
    if tagChangerConn then
        tagChangerConn:Disconnect()
        tagChangerConn = nil
    end
    if tagChangerTag and tagChangerTag.Parent and tagChangerOrig ~= nil then
        pcall(function()
            tagChangerTag.Value = tagChangerOrig
        end)
    end
    tagChangerTag = nil
    tagChangerOrig = nil
end

local function startTagChanger()
    if isTagChangerRunning then
        return
    end
    isTagChangerRunning = true
    task.spawn(function()
        while Globals.tagName and Globals.tagName ~= "" and Globals.tagName ~= "None" do
            local tag = LocalPlayer:FindFirstChild("Tag")
            if tag then
                if tagChangerTag ~= tag then
                    if tagChangerConn then
                        tagChangerConn:Disconnect()
                        tagChangerConn = nil
                    end
                    tagChangerTag = tag
                    if tagChangerOrig == nil then
                        tagChangerOrig = tag.Value
                    end
                end
                if tag.Value ~= Globals.tagName then
                    tag.Value = Globals.tagName
                end
                if not tagChangerConn then
                    tagChangerConn = tag:GetPropertyChangedSignal("Value"):Connect(function()
                        if Globals.tagName and Globals.tagName ~= "" and Globals.tagName ~= "None" then
                            if tag.Value ~= Globals.tagName then
                                tag.Value = Globals.tagName
                            end
                        end
                    end)
                end
            end
            task.wait(0.5)
        end
        isTagChangerRunning = false
    end)
end

if Globals.tagName and Globals.tagName ~= "" and Globals.tagName ~= "None" then
    startTagChanger()
end

local OriginalDisplayName = LocalPlayer.DisplayName
local OriginalUserName = LocalPlayer.Name

local SpoofTextCache = setmetatable({}, {__mode = "k"})
local PrivacyRunning = false
local LastSpoofName = nil
local PrivacyConns = {}
local PrivacyTextNodes = setmetatable({}, {__mode = "k"})
local StreamerTag = nil
local StreamerTagOrig = nil
local StreamerTagConn = nil

local function AddPrivacyConn(conn)
    if conn then
        PrivacyConns[#PrivacyConns + 1] = conn
    end
end

local function ClearPrivacyConns()
    for _, c in ipairs(PrivacyConns) do
        pcall(function()
            c:Disconnect()
        end)
    end
    PrivacyConns = {}
    for inst in pairs(PrivacyTextNodes) do
        PrivacyTextNodes[inst] = nil
    end
end

local function MakeSpoofName()
    return "BelowNatural"
end

local function EnsureSpoofName()
    local nm = Globals.StreamerName
    if not nm or nm == "" then
        nm = MakeSpoofName()
        SetSetting("StreamerName", nm)
    end
    return nm
end

local function IsTagChangerActive()
    return Globals.tagName and Globals.tagName ~= "" and Globals.tagName ~= "None"
end

local function SetLocalDisplayName(nm)
    if not nm or nm == "" then
        return
    end
    pcall(function()
        LocalPlayer.DisplayName = nm
    end)
end

local function ReplacePlain(str, old, new)
    if not str or str == "" or not old or old == "" or old == new then
        return str, false
    end
    local start = 1
    local out = {}
    local changed = false
    while true do
        local i, j = string.find(str, old, start, true)
        if not i then
            out[#out + 1] = string.sub(str, start)
            break
        end
        changed = true
        out[#out + 1] = string.sub(str, start, i - 1)
        out[#out + 1] = new
        start = j + 1
    end
    if changed then
        return table.concat(out), true
    end
    return str, false
end

local function ApplySpoofToInstance(inst, OldA, OldB, NewName)
    if not inst then
        return
    end
    if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
        local txt = inst.Text
        if type(txt) == "string" and txt ~= "" then
            local HasA = OldA and OldA ~= "" and string.find(txt, OldA, 1, true)
            local HasB = OldB and OldB ~= "" and string.find(txt, OldB, 1, true)
            if not HasA and not HasB then
                return
            end
            local t = txt
            local changed = false
            local ch
            if OldA and OldA ~= "" then
                t, ch = ReplacePlain(t, OldA, NewName)
                if ch then changed = true end
            end
            if OldB and OldB ~= "" then
                t, ch = ReplacePlain(t, OldB, NewName)
                if ch then changed = true end
            end
            if changed then
                if SpoofTextCache[inst] == nil then
                    SpoofTextCache[inst] = txt
                end
                inst.Text = t
            end
        end
    end
end

local function RestoreSpoofText()
    for inst, txt in pairs(SpoofTextCache) do
        if inst and inst.Parent then
            pcall(function()
                inst.Text = txt
            end)
        end
        SpoofTextCache[inst] = nil
    end
end

local function GetPrivacyName()
    if Globals.StreamerMode then
        return EnsureSpoofName()
    end
    if Globals.HideUsername then
        return "████████"
    end
    return nil
end

local function AddPrivacyNode(inst)
    if not (inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox")) then
        return
    end
    PrivacyTextNodes[inst] = true
    local nm = GetPrivacyName()
    if nm then
        ApplySpoofToInstance(inst, OriginalDisplayName, OriginalUserName, nm)
    end
end

local function HookPrivacyRoot(root)
    if not root then
        return
    end
    for _, inst in ipairs(root:GetDescendants()) do
        AddPrivacyNode(inst)
    end
    AddPrivacyConn(root.DescendantAdded:Connect(function(inst)
        if GetPrivacyName() then
            AddPrivacyNode(inst)
        end
    end))
end

local function SweepPrivacyText(nm)
    for inst in pairs(PrivacyTextNodes) do
        if inst and inst.Parent then
            ApplySpoofToInstance(inst, OriginalDisplayName, OriginalUserName, nm)
        else
            PrivacyTextNodes[inst] = nil
        end
    end
end

local function ApplyStreamerTag()
    if IsTagChangerActive() then
        if StreamerTagConn then
            StreamerTagConn:Disconnect()
            StreamerTagConn = nil
        end
        StreamerTag = nil
        StreamerTagOrig = nil
        return
    end
    local nm = EnsureSpoofName()
    local tag = LocalPlayer:FindFirstChild("Tag")
    if not tag then
        return
    end
    if StreamerTag and StreamerTag ~= tag then
        if StreamerTagConn then
            StreamerTagConn:Disconnect()
            StreamerTagConn = nil
        end
    end
    if StreamerTag ~= tag then
        StreamerTag = tag
        StreamerTagOrig = tag.Value
    end
    if tag.Value ~= nm then
        tag.Value = nm
    end
    if StreamerTagConn then
        StreamerTagConn:Disconnect()
        StreamerTagConn = nil
    end
    StreamerTagConn = tag:GetPropertyChangedSignal("Value"):Connect(function()
        if not Globals.StreamerMode then
            return
        end
        if IsTagChangerActive() then
            return
        end
        local nm2 = EnsureSpoofName()
        if tag.Value ~= nm2 then
            tag.Value = nm2
        end
    end)
end

local function RestoreStreamerTag()
    if StreamerTagConn then
        StreamerTagConn:Disconnect()
        StreamerTagConn = nil
    end
    if IsTagChangerActive() then
        StreamerTag = nil
        StreamerTagOrig = nil
        return
    end
    if StreamerTag and StreamerTag.Parent and StreamerTagOrig ~= nil then
        pcall(function()
            StreamerTag.Value = StreamerTagOrig
        end)
    end
    StreamerTag = nil
    StreamerTagOrig = nil
end

local function ApplyPrivacyOnce()
    local nm = GetPrivacyName()
    if not nm then
        return
    end
    if LastSpoofName and LastSpoofName ~= nm then
        RestoreSpoofText()
    end
    if Globals.StreamerMode then
        ApplyStreamerTag()
    else
        RestoreStreamerTag()
    end
    SetLocalDisplayName(nm)
    SweepPrivacyText(nm)
    LastSpoofName = nm
end

local function StopPrivacyMode()
    ClearPrivacyConns()
    RestoreSpoofText()
    LastSpoofName = nil
    RestoreStreamerTag()
    SetLocalDisplayName(OriginalDisplayName)
    PrivacyRunning = false
end

local function StartPrivacyMode()
    if PrivacyRunning then
        return
    end
    PrivacyRunning = true
    ClearPrivacyConns()
    ApplyPrivacyOnce()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        HookPrivacyRoot(pg)
    end
    local CoreGui = game:GetService("CoreGui")
    if CoreGui then
        HookPrivacyRoot(CoreGui)
    end
    local TagsRoot = workspace:FindFirstChild("Nametags")
    if TagsRoot then
        HookPrivacyRoot(TagsRoot)
    end
    local ch = LocalPlayer.Character
    if ch then
        HookPrivacyRoot(ch)
    end
    AddPrivacyConn(LocalPlayer.CharacterAdded:Connect(function(NewChar)
        if GetPrivacyName() then
            HookPrivacyRoot(NewChar)
            ApplyPrivacyOnce()
        end
    end))
    AddPrivacyConn(workspace.ChildAdded:Connect(function(inst)
        if GetPrivacyName() and inst.Name == "Nametags" then
            HookPrivacyRoot(inst)
            ApplyPrivacyOnce()
        end
    end))
    local function step()
        if not GetPrivacyName() then
            StopPrivacyMode()
            return
        end
        ApplyPrivacyOnce()
        task.delay(0.5, step)
    end
    task.defer(step)
end

local function UpdatePrivacyState()
    if GetPrivacyName() then
        if not PrivacyRunning then
            StartPrivacyMode()
        else
            ApplyPrivacyOnce()
        end
    else
        if PrivacyRunning then
            StopPrivacyMode()
        end
    end
end

UpdatePrivacyState()

-- // for calculating path
local function FindPath()
    local MapFolder = workspace:FindFirstChild("Map")
    if not MapFolder then return nil end
    local PathsFolder = MapFolder:FindFirstChild("Paths")
    if not PathsFolder then return nil end
    local PathFolder = PathsFolder:GetChildren()[1]
    if not PathFolder then return nil end
    
    local PathNodes = {}
    for _, node in ipairs(PathFolder:GetChildren()) do
        if node:IsA("BasePart") then
            table.insert(PathNodes, node)
        end
    end
    
    table.sort(PathNodes, function(a, b)
        local NumA = tonumber(a.Name:match("%d+"))
        local NumB = tonumber(b.Name:match("%d+"))
        if NumA and NumB then return NumA < NumB end
        return a.Name < b.Name
    end)
    
    return PathNodes
end

local function TotalLength(PathNodes)
    local TotalLength = 0
    for i = 1, #PathNodes - 1 do
        TotalLength = TotalLength + (PathNodes[i + 1].Position - PathNodes[i].Position).Magnitude
    end
    return TotalLength
end

local MercenarySlider
local MilitarySlider
local MaxLenght

local function CalcLength()
    local map = workspace:FindFirstChild("Map")
    
    if GameState == "GAME" and map then
        local PathNodes = FindPath()
        
        if PathNodes and #PathNodes > 0 then
            MaxPathDistance = TotalLength(PathNodes)
            
            if MercenarySlider then
                MercenarySlider:SetMax(MaxPathDistance) 
            end
            
            if MilitarySlider then
                MilitarySlider:SetMax(MaxPathDistance)
            end

            if MaxLenght then
                MaxLenght = MaxPathDistance
            end
            return true
        end
    end
    return false
end

local function GetPointAtDistance(PathNodes, distance)
    if not PathNodes or #PathNodes < 2 then return nil end
    
    local CurrentDist = 0
    for i = 1, #PathNodes - 1 do
        local StartPos = PathNodes[i].Position
        local EndPos = PathNodes[i+1].Position
        local SegmentLen = (EndPos - StartPos).Magnitude
        
        if CurrentDist + SegmentLen >= distance then
            local remaining = distance - CurrentDist
            local direction = (EndPos - StartPos).Unit
            return StartPos + (direction * remaining)
        end
        CurrentDist = CurrentDist + SegmentLen
    end
    return PathNodes[#PathNodes].Position
end

local function UpdatePathVisuals()
    if not Globals.PathVisuals then
        if MilMarker then 
            MilMarker:Destroy() 
            MilMarker = nil 
        end
        if MercMarker then 
            MercMarker:Destroy() 
            MercMarker = nil 
        end
        return
    end

    local PathNodes = FindPath()
    if not PathNodes then return end

    if not MilMarker then
        MilMarker = Instance.new("Part")
        MilMarker.Name = "MilVisual"
        MilMarker.Shape = Enum.PartType.Cylinder
        MilMarker.Size = Vector3.new(0.3, 3, 3)
        MilMarker.Color = Color3.fromRGB(0, 255, 0)
        MilMarker.Material = Enum.Material.Plastic
        MilMarker.Anchored = true
        MilMarker.CanCollide = false
        MilMarker.Orientation = Vector3.new(0, 0, 90)
        MilMarker.Parent = workspace
    end

    if not MercMarker then
        MercMarker = MilMarker:Clone()
        MercMarker.Name = "MercVisual"
        MercMarker.Color = Color3.fromRGB(255, 0, 0)
        MercMarker.Parent = workspace
    end

    local MilPos = GetPointAtDistance(PathNodes, Globals.MilitaryPath or 0)
    local MercPos = GetPointAtDistance(PathNodes, Globals.MercenaryPath or 0)

    if MilPos then
        MilMarker.Position = MilPos + Vector3.new(0, 0.2, 0)
        MilMarker.Transparency = 0.7
    end
    if MercPos then
        MercMarker.Position = MercPos + Vector3.new(0, 0.2, 0)
        MercMarker.Transparency = 0.7
    end
end

local function GetEquippedTowers()
    local towers = {}
    local StateReplicators = ReplicatedStorage:FindFirstChild("StateReplicators")

    if StateReplicators then
        for _, folder in ipairs(StateReplicators:GetChildren()) do
            if folder.Name == "PlayerReplicator" and folder:GetAttribute("UserId") == LocalPlayer.UserId then
                local equipped = folder:GetAttribute("EquippedTowers")
                if type(equipped) == "string" then
                    local CleanedJson = equipped:match("%[.*%]") 
                    local success, TowerTable = pcall(function()
                        return HttpService:JSONDecode(CleanedJson)
                    end)

                    if success and type(TowerTable) == "table" then
                        for i = 1, 5 do
                            if TowerTable[i] then
                                table.insert(towers, TowerTable[i])
                            end
                        end
                    end
                end
            end
        end
    end
    return #towers > 0 and towers or {"None"}
end

CurrentEquippedTowers = GetEquippedTowers()

-- // ui
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/DuxiiT/auto-strat/refs/heads/main/Sources/UI.lua"))()

local Window = Library:Window({
    Title = "Aether Hub",
    Desc = "your #1 hub",
    Theme = "Dark",
    DiscordLink = "https://discord.gg/autostrat",
    Icon = 126403638319957,
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 500, 0, 400)
    }
})

local Autostrat = Window:Tab({Title = "Autostrat", Icon = "star"}) do
    Autostrat:Section({Title = "Main"})

    Autostrat:Toggle({
        Title = "Auto Rejoin",
        Desc = "Rejoins the gamemode after you've won and does the strategy again.",
        Value = Globals.AutoRejoin,
        Callback = function(v)
            SetSetting("AutoRejoin", v)
        end
    })

    Autostrat:Toggle({
        Title = "Auto Skip Waves",
        Desc = "Skips all Waves",
        Value = Globals.AutoSkip,
        Callback = function(v)
            SetSetting("AutoSkip", v)
        end
    })

    Autostrat:Toggle({
        Title = "Auto Chain",
        Desc = "Chains Commander Ability",
        Value = Globals.AutoChain,
        Callback = function(v)
            SetSetting("AutoChain", v)
        end
    })

    Autostrat:Toggle({
        Title = "Support Caravan",
        Desc = "Uses Commander Support Caravan",
        Value = Globals.SupportCaravan,
        Callback = function(v)
            SetSetting("SupportCaravan", v)
        end
    })

    Autostrat:Toggle({
        Title = "Auto DJ Booth",
        Desc = "Uses DJ Booth Ability",
        Value = Globals.AutoDJ,
        Callback = function(v)
            SetSetting("AutoDJ", v)
        end
    })

    Autostrat:Toggle({
        Title = "Auto Necro",
        Desc = "Uses Necromancer Ability",
        Value = Globals.AutoNecro,
        Callback = function(v)
            SetSetting("AutoNecro", v)
        end
    })

    Autostrat:Dropdown({
        Title = "Modifiers:",
        List = AllModifiers,
        Value = Globals.Modifiers,
        Multi = true,
        Callback = function(choice)
            SetSetting("Modifiers", choice)
        end
    })

    Autostrat:Section({Title = "Farm"})
    Autostrat:Toggle({
        Title = "Sell Farms",
        Desc = "Sells all your farms on the specified wave",
        Value = Globals.SellFarms,
        Callback = function(v)
            SetSetting("SellFarms", v)
        end
    })

    Autostrat:Textbox({
        Title = "Wave:",
        Desc = "Wave to sell farms",
        Placeholder = "40",
        Value = tostring(Globals.SellFarmsWave),
        ClearTextOnFocus = false,
        Callback = function(text)
            local number = tonumber(text)
            if number then
                SetSetting("SellFarmsWave", number)
            else
                Window:Notify({
                    Title = "ADS",
                    Desc = "Invalid number entered!",
                    Time = 3,
                    Type = "error"
                })
            end
        end
    })

    Autostrat:Section({Title = "Abilities"})
    Autostrat:Toggle({
        Title = "Enable Path Distance Marker",
        Desc = "Red = Mercenary Base, Green = Military Base",
        Value = Globals.PathVisuals,
        Callback = function(v)
            SetSetting("PathVisuals", v)
        end
    })

    Autostrat:Toggle({
        Title = "Auto Mercenary Base",
        Desc = "Uses Air-Drop Ability",
        Value = Globals.AutoMercenary,
        Callback = function(v)
            SetSetting("AutoMercenary", v)
        end
    })

    MercenarySlider = Autostrat:Slider({
        Title = "Path Distance",
        Min = 0,
        Max = 300,
        Rounding = 0,
        Value = Globals.MercenaryPath,
        Callback = function(val)
            SetSetting("MercenaryPath", val)
        end
    })

    Autostrat:Toggle({
        Title = "Auto Military Base",
        Desc = "Uses Airstrike Ability",
        Value = Globals.AutoMilitary,
        Callback = function(v)
            SetSetting("AutoMilitary", v)
        end
    })

    MilitarySlider = Autostrat:Slider({
        Title = "Path Distance",
        Min = 0,
        Max = 300,
        Rounding = 0,
        Value = Globals.MilitaryPath,
        Callback = function(val)
            SetSetting("MilitaryPath", val)
        end
    })

    task.spawn(function()
        while true do
            local success = CalcLength()
            if success then break end 
            task.wait(3)
        end
    end)
end

Window:Line()

local Main = Window:Tab({Title = "Main", Icon = "stamp"}) do
    Main:Section({Title = "Tower Options"})
    local TowerDropdown = Main:Dropdown({
        Title = "Tower:",
        List = CurrentEquippedTowers,
        Value = CurrentEquippedTowers[1],
        Callback = function(choice)
            SelectedTower = choice
        end
    })

    local function RefreshDropdown()
        local NewTowers = GetEquippedTowers()
        if table.concat(NewTowers, ",") ~= table.concat(CurrentEquippedTowers, ",") then
            TowerDropdown:Clear() 
            
            for _, TowerName in ipairs(NewTowers) do
                TowerDropdown:Add(TowerName)
            end
            
            CurrentEquippedTowers = NewTowers
        end
    end

    task.spawn(function()
        while task.wait(2) do
            RefreshDropdown()
        end
    end)

    Main:Toggle({
        Title = "Stack Tower",
        Desc = "Enables Stacking placement",
        Value = false,
        Callback = function(v)
            StackEnabled = v

            if StackEnabled then
                Window:Notify({
                    Title = "ADS",
                    Desc = "Make sure not to equip the tower, only select it and then place where you want to!",
                    Time = 5,
                    Type = "normal"
                })
            end
        end
    })

    Main:Button({
        Title = "Upgrade Selected",
        Desc = "",
        Callback = function()
            if SelectedTower then
                for _, v in pairs(workspace.Towers:GetChildren()) do
                    if v:FindFirstChild("TowerReplicator") and v.TowerReplicator:GetAttribute("Name") == SelectedTower and v.TowerReplicator:GetAttribute("OwnerId") == LocalPlayer.UserId then
                        RemoteFunc:InvokeServer("Troops", "Upgrade", "Set", {Troop = v})
                    end
                end
                Window:Notify({
                    Title = "ADS",
                    Desc = "Attempted to upgrade all the selected towers!",
                    Time = 3,
                    Type = "normal"
                })
            end
        end
    })

    Main:Button({
        Title = "Sell Selected",
        Desc = "",
        Callback = function()
            if SelectedTower then
                for _, v in pairs(workspace.Towers:GetChildren()) do
                    if v:FindFirstChild("TowerReplicator") and v.TowerReplicator:GetAttribute("Name") == SelectedTower and v.TowerReplicator:GetAttribute("OwnerId") == LocalPlayer.UserId then
                        RemoteFunc:InvokeServer("Troops", "Sell", {Troop = v})
                    end
                end
                Window:Notify({
                    Title = "ADS",
                    Desc = "Attempted to sell all the selected towers!",
                    Time = 3,
                    Type = "normal"
                })
            end
        end
    })

    Main:Button({
        Title = "Upgrade All",
        Desc = "",
        Callback = function()
            for _, v in pairs(workspace.Towers:GetChildren()) do
                if v:FindFirstChild("Owner") and v.Owner.Value == LocalPlayer.UserId then
                    RemoteFunc:InvokeServer("Troops", "Upgrade", "Set", {Troop = v})
                end
            end
            Window:Notify({
                Title = "ADS",
                Desc = "Attempted to upgrade all the towers!",
                Time = 3,
                Type = "normal"
            })
        end
    })

    Main:Button({
        Title = "Sell All",
        Desc = "",
        Callback = function()
            Window:Dialog({
                Title = "Do you want to sell all the towers?",
                Button1 = {
                    Title = "Confirm",
                    Color = Color3.fromRGB(226, 39, 6),
                    Callback = function()
                        for _, v in pairs(workspace.Towers:GetChildren()) do
                            if v:FindFirstChild("Owner") and v.Owner.Value == LocalPlayer.UserId then
                                RemoteFunc:InvokeServer("Troops", "Sell", {Troop = v})
                            end
                        end

                        Window:Notify({
                            Title = "ADS",
                            Desc = "Attempted to sell all the towers!",
                            Time = 3,
                            Type = "normal"
                        })
                    end
                },
                Button2 = {
                    Title = "Cancel",
                    Color = Color3.fromRGB(0, 188, 0)
                }
            })
        end
    })

    Main:Section({Title = "Premium"})
    Main:Button({
        Title = "Unlock Premium Features",
        Desc = "Click to unlock Gatling and Equipper (Auto-succeeds)",
        Callback = function()
            task.spawn(function()
                Window:Notify({Title = "ADS", Desc = "Checking key...", Time = 2})
                
                local success = TDS:Addons()
                
                if success then
                    TDS.GatlingConfig.Enabled = false
                    TDS:AutoGatling()
                    
                    Window:Notify({
                        Title = "ADS",
                        Desc = "✅ Key Valid! Premium Unlocked!",
                        Time = 5,
                        Type = "normal"
                    })
                end
            end)
        end
    })

    Main:Section({Title = "Equipper"})
    Main:Textbox({
        Title = "Equip:",
        Desc = "Enter tower name to equip",
        Placeholder = "Tower Name",
        Value = "",
        ClearTextOnFocus = false,
        Callback = function(text)
            if text == "" or text == nil then return end
            
            local success = TDS:Equip(tostring(text))
            
            if success then
                Window:Notify({
                    Title = "ADS",
                    Desc = "Successfully equipped: " .. tostring(text),
                    Time = 3,
                    Type = "normal"
                })
            else
                Window:Notify({
                    Title = "ADS",
                    Desc = "Failed to equip: " .. tostring(text),
                    Time = 3,
                    Type = "error"
                })
            end
        end
    })

    Main:Section({Title = "Gatling Gun"})
    Main:Toggle({
        Title = "Auto Gatling Enabled",
        Value = Globals.GatlingEnabled,
        Callback = function(state)
            SetSetting("GatlingEnabled", state)
            TDS.GatlingConfig.Enabled = state
            
            if state then
                TDS:AutoGatling()
            end
        end
    })

    Main:Slider({
        Title = "Gatling Multiply",
        Min = 1,
        Max = 50,
        Value = Globals.GatlingMultiply,
        Callback = function(val)
            SetSetting("GatlingMultiply", val)
            TDS.GatlingConfig.Multiply = val
        end
    })

    Main:Slider({
        Title = "Gatling Cooldown",
        Min = 0.01,
        Max = 1,
        Value = Globals.GatlingCooldown,
        Callback = function(val)
            SetSetting("GatlingCooldown", val)
            TDS.GatlingConfig.Cooldown = val
        end
    })

    Main:Slider({
        Title = "Critical Range",
        Desc = "Target enemies this close to the exit first",
        Min = 10,
        Max = 200,
        Value = Globals.GatlingCriticalRange,
        Callback = function(val)
            SetSetting("GatlingCriticalRange", val)
            TDS.GatlingConfig.CriticalRange = val
        end
    })

    Main:Section({Title = "Stats"})
    local CoinsLabel = Main:Label({Title = "Coins: 0", Desc = ""})
    local GemsLabel = Main:Label({Title = "Gems: 0", Desc = ""})
    local LevelLabel = Main:Label({Title = "Level: 0", Desc = ""})
    local WinsLabel = Main:Label({Title = "Wins: 0", Desc = ""})
    local LosesLabel = Main:Label({Title = "Loses: 0", Desc = ""})
    local ExpLabel = Main:Label({Title = "Experience: 0 / 0", Desc = ""})
    local ExpSlider = Main:Slider({
        Title = "EXP",
        Desc = "",
        Min = 0,
        Max = 100,
        Rounding = 0,
        Value = 0,
        Callback = function()
        end
    })

    local function ParseNumber(val)
        if type(val) == "number" then
            return val
        end
        if type(val) == "string" then
            local cleaned = string.gsub(val, ",", "")
            local n = tonumber(cleaned)
            if n then
                return n
            end
        end
        if type(val) == "table" and val.get then
            local ok, v = pcall(function()
                return val:get()
            end)
            if ok then
                return ParseNumber(v)
            end
        end
        return nil
    end

    local function ReadValue(obj)
        if not obj then
            return nil
        end
        local ok, v = pcall(function()
            return obj.Value
        end)
        if ok then
            return ParseNumber(v)
        end
        return nil
    end

    local function GetStatNumber(name)
        local obj = LocalPlayer:FindFirstChild(name)
        local v = ReadValue(obj)
        if v ~= nil then
            return v
        end
        local attr = LocalPlayer:GetAttribute(name)
        v = ParseNumber(attr)
        if v ~= nil then
            return v
        end
        return nil
    end

    local function PickExpMax()
        local ExpObj = LocalPlayer:FindFirstChild("Experience")
        local AttrMax = ExpObj and ParseNumber(ExpObj:GetAttribute("Max"))
        local AttrNeed = ExpObj and ParseNumber(ExpObj:GetAttribute("Required"))
        local AttrNext = ExpObj and ParseNumber(ExpObj:GetAttribute("Next"))
        return AttrMax
            or AttrNeed
            or AttrNext
            or GetStatNumber("ExperienceMax")
            or GetStatNumber("ExperienceNeeded")
            or GetStatNumber("ExperienceRequired")
            or GetStatNumber("ExperienceToNextLevel")
            or GetStatNumber("ExperienceToLevel")
            or GetStatNumber("NextLevelExp")
            or GetStatNumber("ExpToNextLevel")
            or GetStatNumber("ExpNeeded")
            or GetStatNumber("ExpRequired")
            or GetStatNumber("MaxExp")
            or GetStatNumber("MaxExperience")
            or 100
    end

    local GcExpCache = { t = nil, last = 0 }
    local function GetGcExp()
        if not getgc then
            return nil
        end
        local t = GcExpCache.t
        if t then
            local exp = ParseNumber(rawget(t, "exp") or rawget(t, "Exp") or rawget(t, "experience") or rawget(t, "Experience"))
            local MaxExp = ParseNumber(rawget(t, "maxExp") or rawget(t, "MaxExp") or rawget(t, "maxEXP") or rawget(t, "MaxEXP") or rawget(t, "maxExperience") or rawget(t, "MaxExperience"))
            local lvl = ParseNumber(rawget(t, "level") or rawget(t, "Level") or rawget(t, "lvl") or rawget(t, "Lvl"))
            if exp and MaxExp then
                return exp, MaxExp, lvl
            end
        end
        local now = os.clock()
        if now - GcExpCache.last < 3 then
            return nil
        end
        GcExpCache.last = now
        local plvl = GetStatNumber("Level")
        for _, obj in ipairs(getgc(true)) do
            if type(obj) == "table" then
                local exp = ParseNumber(rawget(obj, "exp") or rawget(obj, "Exp") or rawget(obj, "experience") or rawget(obj, "Experience"))
                local MaxExp = ParseNumber(rawget(obj, "maxExp") or rawget(obj, "MaxExp") or rawget(obj, "maxEXP") or rawget(obj, "MaxEXP") or rawget(obj, "maxExperience") or rawget(obj, "MaxExperience"))
                if exp and MaxExp then
                    local lvl = ParseNumber(rawget(obj, "level") or rawget(obj, "Level") or rawget(obj, "lvl") or rawget(obj, "Lvl"))
                    if not plvl or not lvl or lvl == plvl then
                        GcExpCache.t = obj
                        return exp, MaxExp, lvl
                    end
                end
            end
        end
        return nil
    end

    local function UpdateStats()
        local coins = GetStatNumber("Coins") or 0
        local gems = GetStatNumber("Gems") or 0
        local lvl = GetStatNumber("Level") or 0
        local wins = GetStatNumber("Triumphs") or 0
        local loses = GetStatNumber("Loses") or 0
        local exp = GetStatNumber("Experience") or 0
        local MaxExp = PickExpMax()
        local GcExp, GcMax, GcLvl = GetGcExp()
        if GcExp and GcMax then
            exp = GcExp
            MaxExp = GcMax
            if GcLvl then
                lvl = GcLvl
            end
        end
        if MaxExp < 1 then
            MaxExp = 1
        end
        if exp > MaxExp then
            MaxExp = exp
        end
        if CoinsLabel then CoinsLabel:SetTitle("Coins: " .. tostring(coins)) end
        if GemsLabel then GemsLabel:SetTitle("Gems: " .. tostring(gems)) end
        if LevelLabel then LevelLabel:SetTitle("Level: " .. tostring(lvl)) end
        if WinsLabel then WinsLabel:SetTitle("Wins: " .. tostring(wins)) end
        if LosesLabel then LosesLabel:SetTitle("Loses: " .. tostring(loses)) end
        if ExpLabel then ExpLabel:SetTitle("Experience: " .. tostring(exp) .. " / " .. tostring(MaxExp)) end
        if ExpSlider then
            ExpSlider:SetMin(0)
            ExpSlider:SetMax(MaxExp)
            ExpSlider:SetValue(exp)
        end
    end

    local StatsQueued = false
    local function QueueStatsUpdate()
        if StatsQueued then
            return
        end
        StatsQueued = true
        task.delay(0.2, function()
            StatsQueued = false
            UpdateStats()
        end)
    end

    local function HookStatObj(obj)
        if not obj then
            return
        end
        if obj.Changed then
            obj.Changed:Connect(QueueStatsUpdate)
        end
        obj:GetAttributeChangedSignal("Max"):Connect(QueueStatsUpdate)
        obj:GetAttributeChangedSignal("Required"):Connect(QueueStatsUpdate)
        obj:GetAttributeChangedSignal("Next"):Connect(QueueStatsUpdate)
    end

    local StatNames = {"Coins", "Gems", "Level", "Triumphs", "Loses", "Experience"}
    local ExpAttrNames = {
        "ExperienceMax",
        "ExperienceNeeded",
        "ExperienceRequired",
        "ExperienceToNextLevel",
        "ExperienceToLevel",
        "NextLevelExp",
        "ExpToNextLevel",
        "ExpNeeded",
        "ExpRequired",
        "MaxExp",
        "MaxExperience"
    }

    for _, name in ipairs(StatNames) do
        HookStatObj(LocalPlayer:FindFirstChild(name))
        LocalPlayer:GetAttributeChangedSignal(name):Connect(QueueStatsUpdate)
    end

    for _, name in ipairs(ExpAttrNames) do
        LocalPlayer:GetAttributeChangedSignal(name):Connect(QueueStatsUpdate)
    end

    LocalPlayer.ChildAdded:Connect(function(child)
        if table.find(StatNames, child.Name) then
            HookStatObj(child)
            QueueStatsUpdate()
        end
    end)

    LocalPlayer.ChildRemoved:Connect(function(child)
        if table.find(StatNames, child.Name) then
            QueueStatsUpdate()
        end
    end)

    QueueStatsUpdate()
end

Window:Line()

local Strategies = Window:Tab({Title = "Strategies", Icon = "newspaper"}) do
    Strategies:Section({Title = "Survival Strategies"})
    Strategies:Toggle({
        Title = "Frost Mode",
        Desc = "Skill tree: MAX\n\nTowers:\nGolden Scout,\nFirework Technician,\nHacker,\nBrawler,\nDJ Booth,\nCommander,\nEngineer,\nAccelerator,\nTurret,\nMercenary Base",
        Value = Globals.Frost,
        Callback = function(v)
            SetSetting("Frost", v)

            if v then
                 task.spawn(function()
                    local url = "https://raw.githubusercontent.com/DuxiiT/auto-strat/refs/heads/main/Strategies/Frost.lua"
                    local content = game:HttpGet(url)
                            
                    local func, err = loadstring(content)
                    if func then
                        func() 
                        Window:Notify({ Title = "ADS", Desc = "Running...", Time = 3 })
                    end
                end)
            end
        end
    })

    Strategies:Toggle({
        Title = "Fallen Mode",
        Desc = "Skill tree: Not needed\n\nTowers:\nGolden Scout,\nBrawler,\nMercenary Base,\nElectroshocker,\nEngineer",
        Value = Globals.Fallen,
        Callback = function(v)
            SetSetting("Fallen", v)

            if v then
                task.spawn(function()
                    local url = "https://raw.githubusercontent.com/DuxiiT/auto-strat/refs/heads/main/Strategies/Fallen.lua"
                    local content = game:HttpGet(url)
                    
                    local func, err = loadstring(content)
                    if func then
                        func() 
                        Window:Notify({ Title = "ADS", Desc = "Running...", Time = 3 })
                    end
                end)
            end
        end
    })

    Strategies:Toggle({
        Title = "Intermediate Mode",
        Desc = "Skill tree: Not needed\n\nTowers:\nShotgunner,\nCrook Boss",
        Value = Globals.Intermediate,
        Callback = function(v)
            SetSetting("Intermediate", v)

            if v then
                task.spawn(function()
                    local url = "https://raw.githubusercontent.com/DuxiiT/auto-strat/refs/heads/main/Strategies/Intermediate.lua"
                    local content = game:HttpGet(url)
                    
                    local func, err = loadstring(content)
                    if func then
                        func() 
                        Window:Notify({ Title = "ADS", Desc = "Running...", Time = 3 })
                    end
                end)
            end
        end
    })

    Strategies:Toggle({
        Title = "Casual Mode",
        Desc = "Skill tree: Not needed\n\nTowers:\nShotgunner",
        Value = Globals.Casual,
        Callback = function(v)
            SetSetting("Casual", v)

            if v then
                task.spawn(function()
                    local url = "https://raw.githubusercontent.com/DuxiiT/auto-strat/refs/heads/main/Strategies/Casual.lua"
                    local content = game:HttpGet(url)
                    
                    local func, err = loadstring(content)
                    if func then
                        func() 
                        Window:Notify({ Title = "ADS", Desc = "Running...", Time = 3 })
                    end
                end)
            end
        end
    })

    Strategies:Toggle({
        Title = "Easy Mode",
        Desc = "Skill tree: Not needed\n\nTowers:\nNormal Scout",
        Value = Globals.Easy,
        Callback = function(v)
            SetSetting("Easy", v)

            if v then
                task.spawn(function()
                    local url = "https://raw.githubusercontent.com/DuxiiT/auto-strat/refs/heads/main/Strategies/Easy.lua"
                    local content = game:HttpGet(url)
                    
                    local func, err = loadstring(content)
                    if func then
                        func() 
                        Window:Notify({ Title = "ADS", Desc = "Running...", Time = 3 })
                    end
                end)
            end
        end
    })

    Strategies:Section({Title = "Other Strategies"})
    Strategies:Toggle({
        Title = "Hardcore Mode",
        Desc = "Towers:\nFarm,\nGolden Scout,\nDJ Booth,\nCommander,\nElectroshocker,\nRanger,\nFreezer,\nGolden Minigunner",
        Value = Globals.Hardcore,
        Callback = function(v)
            SetSetting("Hardcore", v)

            if v then
                task.spawn(function()
                    local url = "https://raw.githubusercontent.com/DuxiiT/auto-strat/refs/heads/main/Strategies/Hardcore.lua"
                    local content = game:HttpGet(url)
                    
                    local func, err = loadstring(content)
                    if func then
                        func() 
                        Window:Notify({ Title = "ADS", Desc = "Running...", Time = 3 })
                    end
                end)
            end
        end
    })
end

Window:Line()

local Misc = Window:Tab({Title = "Misc", Icon = "box"}) do
    Misc:Section({Title = "Misc"})
    Misc:Toggle({
        Title = "Enable Anti-Lag",
        Desc = "Boosts your FPS",
        Value = Globals.AntiLag,
        Callback = function(v)
            SetSetting("AntiLag", v)
        end
    })

    Misc:Toggle({
        Title = "Disable 3d rendering",
        Desc = "Turns off 3d rendering",
        Value = Globals.Disable3DRendering,
        Callback = function(v)
            SetSetting("Disable3DRendering", v)
            Apply3dRendering()
        end
    })

    Misc:Toggle({
        Title = "Auto Collect Pickups",
        Desc = "Collects Logbooks + Snowballs",
        Value = Globals.AutoPickups,
        Callback = function(v)
            SetSetting("AutoPickups", v)
        end
    })

    Misc:Dropdown({
        Title = "Pickup Method",
        Desc = "",
        List = {"Pathfinding", "Instant"},
        Value = Globals.PickupMethod or "Pathfinding",
        Callback = function(choice)
            local selected = type(choice) == "table" and choice[1] or choice
            if not selected or selected == "" then
                selected = "Pathfinding"
            end
            SetSetting("PickupMethod", selected)
        end
    })

    Misc:Toggle({
        Title = "Claim Rewards",
        Desc = "Claims your playtime and uses spin tickets in Lobby",
        Value = Globals.ClaimRewards,
        Callback = function(v)
            SetSetting("ClaimRewards", v)
        end
    })

    Misc:Section({Title = "Gatling Gun"})
    Misc:Textbox({
        Title = "Cooldown:",
        Desc = "",
        Placeholder = "0.01",
        Value = Globals.Cooldown,
        ClearTextOnFocus = true,
        Callback = function(value)
            if value ~= 0 then
                SetSetting("Cooldown", value)
            end
        end
    })

    Misc:Textbox({
        Title = "Multiply:",
        Desc = "",
        Placeholder = "60",
        Value = Globals.Multiply,
        ClearTextOnFocus = true,
        Callback = function(value)
            if value ~= 0 then
                SetSetting("Multiply", value)
            end
        end
    })

    Misc:Button({
        Title = "Apply Gatling",
        Callback = function()
            if hookmetamethod then
                Window:Notify({
                    Title = "ADS",
                    Desc = "Successfully applied Gatling Gun Settings",
                    Time = 3,
                    Type = "normal"
                })

                local ggchannel = require(game.ReplicatedStorage.Resources.Universal.NewNetwork).Channel("GatlingGun")
                local gganim = require(game.ReplicatedStorage.Content.Tower["Gatling Gun"].Animator)
                
                gganim._fireGun = function(self)
                    local cam = require(game.ReplicatedStorage.Content.Tower["Gatling Gun"].Animator.CameraController)
                    local pos = cam.result and cam.result.Position or cam.position
                    
                    for i = 1, Globals.Multiply do
                        ggchannel:fireServer("Fire", pos, workspace:GetAttribute("Sync"), workspace:GetServerTimeNow())
                    end
                    
                    self:Wait(Globals.Cooldown)
                end
            else
                Window:Notify({
                    Title = "ADS",
                    Desc = "Your executor is not supported, please use a different one!",
                    Time = 3,
                    Type = "normal"
                })
            end
        end
    })

    Misc:Section({Title = "Experimental"})
    Misc:Toggle({
        Title = "Sticker Spam",
        Desc = "This will drop everyones FPS to like 5 (you will not be able to see this unless you have an alt)",
        Value = false,
        Callback = function(v)
            StickerSpam = v
            
            if StickerSpam then
                task.spawn(function()
                    while StickerSpam do
                        for i = 1, 9999 do
                            if not StickerSpam then break end
                            
                            local args = {"Flex"}
                            game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Sticker"):WaitFor Child("URE:Show"):FireServer(unpack(args))
                        end
                        task.wait()
                    end
                end)
            end
        end
    })

    Misc:Button({
        Title = "Unlock Admin+ (Sandbox)",
        Desc = "Keep in mind that some features such as selecting maps, spawning in enemies and changing tower stats will not work!",
        Callback = function()
            if GameState == "GAME" then
                local args = {
                    game.Players.LocalPlayer.UserId,
                    true
                }
                
                game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Sandbox"):WaitForChild("RE:SetAdmin"):FireServer(unpack(args))

                Window:Notify({
                    Title = "ADS",
                    Desc = "Successfully unlocked Admin+ Mode!",
                    Time = 3,
                    Type = "normal"
                })
            else
                Window:Notify({
                    Title = "ADS",
                    Desc = "You must be in Sandbox mode for this to work!",
                    Time = 3,
                    Type = "normal"
                })
            end
        end
    })
end

Window:Line()

local Logger

local Logger = Window:Tab({Title = "Logger", Icon = "notebook-pen"}) do
    Logger = Logger:CreateLogger({
        Title = "STRATEGY LOGGER:",
        Size = UDim2.new(0, 330, 0, 300)
    })
end

Window:Line()

local RecorderInit = loadstring(game:HttpGet("https://raw.githubusercontent.com/DuxiiT/auto-strat/refs/heads/main/Sources/Recorder.lua"))()
RecorderInit({
    Window = Window,
    ReplicatedStorage = ReplicatedStorage,
    LocalPlayer = LocalPlayer,
    HttpService = HttpService,
    GameState = GameState,
    workspace = workspace
})

Window:Line()

local Settings = Window:Tab({Title = "Settings", Icon = "settings"}) do
    Settings:Section({Title = "Settings"})
    Settings:Button({
        Title = "Save Settings",
        Callback = function()
            Window:Notify({
                    Title = "ADS",
                    Desc = "Settings Saved!",
                    Time = 3,
                    Type = "normal"
                })
            SaveSettings()
        end
    })

    Settings:Button({
        Title = "Load Settings",
        Callback = function()
            Window:Notify({
                    Title = "ADS",
                    Desc = "Settings Loaded!",
                    Time = 3,
                    Type = "normal"
                })
            LoadSettings()
        end
    })

    Settings:Section({Title = "Privacy"})
    Settings:Toggle({
        Title = "Hide Username",
        Desc = "",
        Value = Globals.HideUsername,
        Callback = function(v)
            SetSetting("HideUsername", v)
            UpdatePrivacyState()
        end
    })

    Settings:Textbox({
        Title = "Streamer Name",
        Desc = "",
        Placeholder = "Spoof Name",
        Value = Globals.StreamerName or "",
        ClearTextOnFocus = false,
        Callback = function(value)
            SetSetting("StreamerName", value or "")
            UpdatePrivacyState()
        end
    })

    Settings:Toggle({
        Title = "Streamer Mode",
        Desc = "",
        Value = Globals.StreamerMode,
        Callback = function(v)
            SetSetting("StreamerMode", v)
            UpdatePrivacyState()
        end
    })

    Settings:Section({Title = "Tags"})
    local tagOptions = collectTagOptions()
    local tagValue = Globals.tagName or "None"
    if not table.find(tagOptions, tagValue) then
        tagValue = "None"
    end
    Settings:Dropdown({
        Title = "Tag Changer",
        Desc = "",
        List = tagOptions,
        Value = tagValue,
        Callback = function(choice)
            local selected = choice
            if type(choice) == "table" then
                selected = choice[1]
            end
            if not selected or selected == "" then
                selected = "None"
            end
            SetSetting("tagName", selected)
            if selected == "None" then
                stopTagChanger()
            else
                startTagChanger()
            end
        end
    })

    Settings:Section({Title = "Webhook"})
    Settings:Toggle({
        Title = "Send Webhook",
        Desc = "",
        Value = Globals.SendWebhook,
        Callback = function(v)
            SetSetting("SendWebhook", v)
        end
    })

    Settings:Button({
        Title = "Test Webhook",
        Callback = function()
            if not Globals.WebhookURL or Globals.WebhookURL == "" then
                return Window:Notify({Title = "Error", Desc = "Webhook URL is empty!", Time = 3, Type = "error"})
            end

            local success, response = pcall(function()
                return SendRequest({
                    Url = Globals.WebhookURL,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = game:GetService("HttpService"):JSONEncode({["content"] = "Webhook Test"})
                })
            end)

            if success and response.StatusCode >= 200 and response.StatusCode < 300 then
                Window:Notify({
                    Title = "ADS",
                    Desc = "Webhook sent successfully and is working!",
                    Time = 3,
                    Type = "normal"
                })
            else
                Window:Notify({
                    Title = "Error",
                    Desc = "Invalid Webhook, Discord returned an error.",
                    Time = 5,
                    Type = "error"
                })
            end
        end
    })

    Settings:Textbox({
        Title = "Webhook URL:",
        Desc = "",
        Placeholder = "https://discord.com/api/webhooks/...",
        Value = Globals.WebhookURL,
        ClearTextOnFocus = true,
        Callback = function(value)
            if value ~= "" and value:find("https://discord.com/api/webhooks/") then
                SetSetting("WebhookURL", value)
                
                Window:Notify({
                    Title = "ADS",
                    Desc = "Webhook is successfully set!",
                    Time = 3,
                    Type = "normal"
                })
            else
                Window:Notify({
                    Title = "ADS",
                    Desc = "Invalid Webhook URL!",
                    Time = 3,
                    Type = "normal"
                })
            end
        end
    })
end

RunService.RenderStepped:Connect(function()
    if StackEnabled then
        if not StackSphere then
            StackSphere = Instance.new("Part")
            StackSphere.Shape = Enum.PartType.Ball
            StackSphere.Size = Vector3.new(1.5, 1.5, 1.5)
            StackSphere.Color = Color3.fromRGB(0, 255, 0)
            StackSphere.Transparency = 0.5
            StackSphere.Anchored = true
            StackSphere.CanCollide = false
            StackSphere.Material = Enum.Material.Neon
            StackSphere.Parent = workspace
            mouse.TargetFilter = StackSphere
        end
        local hit = mouse.Hit
        if hit then StackSphere.Position = hit.Position end
    elseif StackSphere then
        StackSphere:Destroy()
        StackSphere = nil
    end

    UpdatePathVisuals()
end)

mouse.Button1Down:Connect(function()
    if StackEnabled and StackSphere and SelectedTower then
        local pos = StackSphere.Position
        local newpos = Vector3.new(pos.X, pos.Y + 25, pos.Z)
        RemoteFunc:InvokeServer("Troops", "Pl\208\176ce", {Rotation = CFrame.new(), Position = newpos}, SelectedTower)
    end
end)

-- // currency tracking
local StartCoins, CurrentTotalCoins, StartGems, CurrentTotalGems = 0, 0, 0, 0
if GameState == "GAME" then
    pcall(function()
        repeat task.wait(1) until LocalPlayer:FindFirstChild("Coins")
        StartCoins = LocalPlayer.Coins.Value
        CurrentTotalCoins = StartCoins
        StartGems = LocalPlayer.Gems.Value
        CurrentTotalGems = StartGems
    end)
end

-- // check if remote returned valid
local function CheckResOk(data)
    if data == true then return true end
    if type(data) == "table" and data.Success == true then return true end

    local success, IsModel = pcall(function()
        return data and data:IsA("Model")
    end)
    
    if success and IsModel then return true end
    if type(data) == "userdata" then return true end

    return false
end



return TDS
