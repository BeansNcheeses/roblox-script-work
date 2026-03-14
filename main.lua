local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Flick Chaos Hub - Mobile", "Midnight")

local Settings = {
    Aimbot = false,
    ESP = false,
    FOV = 150,
    ShowFOV = true,
    HitboxSize = 2,
    FlySpeed = 50,
    NoClip = false
}

-- FLOATING TOGGLE
local ScreenGui = Instance.new("ScreenGui")
local OpenBtn = Instance.new("TextButton")
ScreenGui.Parent = game:GetService("CoreGui")
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
OpenBtn.Position = UDim2.new(0, 10, 0, 200)
OpenBtn.Size = UDim2.new(0, 70, 0, 30)
OpenBtn.Text = "TOGGLE"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Draggable = true
OpenBtn.MouseButton1Click:Connect(function() Library:ToggleUI() end)

-- FOV CIRCLE (STRICT OUTLINE)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5 -- Thin outline
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false -- THIS ENSURES IT IS ONLY AN OUTLINE
FOVCircle.Transparency = 1
FOVCircle.NumSides = 64 -- Makes it look like a smooth circle

-- TABS
local Combat = Window:NewTab("Combat")
local Visuals = Window:NewTab("Visuals")
local Movement = Window:NewTab("Movement")
local Misc = Window:NewTab("Misc")

-- COMBAT
local AimSec = Combat:NewSection("Aimbot")
AimSec:NewToggle("Enable Aimbot", "Visible Only", function(state) Settings.Aimbot = state end)
AimSec:NewSlider("Aimbot Range", "FOV Size", 800, 50, function(s) Settings.FOV = s end)
AimSec:NewToggle("Show FOV Circle", "Toggle Circle Visibility", function(state) Settings.ShowFOV = state end)

local HitSec = Combat:NewSection("Hitboxes")
HitSec:NewSlider("Head Size", "Expand enemy heads", 20, 2, function(s) Settings.HitboxSize = s end)

-- VISUALS
local EspSec = Visuals:NewSection("ESP")
EspSec:NewToggle("Player Names & HP", "See everyone", function(state)
    Settings.ESP = state
    if not state then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("Head") and v.Character.Head:FindFirstChild("MobileESP") then
                v.Character.Head.MobileESP:Destroy()
            end
        end
    end
end)

-- MOVEMENT
local MoveSec = Movement:NewSection("Speed & Physics")
MoveSec:NewSlider("WalkSpeed", "Go fast", 250, 16, function(s)
    if game.Players.LocalPlayer.Character then game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s end
end)
MoveSec:NewSlider("Gravity", "Normal is 196", 196, 0, function(s) workspace.Gravity = s end)
MoveSec:NewToggle("NoClip", "Walk through walls", function(state) Settings.NoClip = state end)

-- MISC
local MiscSec = Misc:NewSection("Utilities")
MiscSec:NewButton("Server Hop", "Join a different game", function()
    local x = game:GetService("TeleportService")
    local y = game:GetService("HttpService")
    local z = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
    local function Hop()
        local s = y:JSONDecode(game:HttpGet(z))
        for _, v in pairs(s.data) do
            if v.playing < v.maxPlayers then
                x:TeleportToPlaceInstance(game.PlaceId, v.id)
            end
        end
    end
    Hop()
end)

MiscSec:NewButton("Full Bright", "No shadows", function()
    game:GetService("Lighting").Brightness = 2
    game:GetService("Lighting").ClockTime = 14
    game:GetService("Lighting").GlobalShadows = false
end)

-- WALL CHECK
local function IsVisible(targetPart)
    local char = game.Players.LocalPlayer.Character
    local cam = workspace.CurrentCamera
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char, targetPart.Parent}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(cam.CFrame.Position, targetPart.Position - cam.CFrame.Position, params)
    return result == nil
end

-- CORE LOOP
game:GetService("RunService").RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    local lp = game.Players.LocalPlayer
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    
    FOVCircle.Visible = Settings.ShowFOV
    FOVCircle.Radius = Settings.FOV
    FOVCircle.Position = center

    if Settings.NoClip and lp.Character then
        for _, v in pairs(lp.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    if Settings.Aimbot and lp.Character then
        local nearestEnemy = nil
        local shortestDistance = math.huge
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
                local headPos, onScreen = cam:WorldToScreenPoint(v.Character.Head.Position)
                if onScreen then
                    local screenDist = (Vector2.new(headPos.X, headPos.Y) - center).Magnitude
                    if screenDist < Settings.FOV then
                        local worldDist = (v.Character.Head.Position - lp.Character.Head.Position).Magnitude
                        if worldDist < shortestDistance and IsVisible(v.Character.Head) then
                            shortestDistance = worldDist
                            nearestEnemy = v
                        end
                    end
                end
                v.Character.Head.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
            end
        end
        if nearestEnemy then
            cam.CFrame = CFrame.new(cam.CFrame.Position, nearestEnemy.Character.Head.Position)
        end
    end

    if Settings.ESP then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("Head") then
                local esp = v.Character.Head:FindFirstChild("MobileESP")
                if not esp then
                    local bill = Instance.new("BillboardGui", v.Character.Head)
                    bill.Name = "MobileESP"
                    bill.AlwaysOnTop = true
                    bill.Size = UDim2.new(0, 100, 0, 50)
                    local lbl = Instance.new("TextLabel", bill)
                    lbl.Name = "Tag"
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = Color3.fromRGB(255, 0, 0)
                    lbl.TextSize = 14
                    lbl.Font = Enum.Font.SourceSansBold
                else
                    esp.Tag.Text = v.Name .. " [" .. math.floor(v.Character.Humanoid.Health) .. "]"
                end
            end
        end
    end
end)
