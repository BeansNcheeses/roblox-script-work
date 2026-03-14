local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Flick Chaos Hub - Mobile", "Midnight")

local Settings = {
    Aimbot = false,
    ESP = false,
    FOV = 150,
    ShowFOV = true,
    HitboxSize = 2,
    NoClip = false
}

-- 1. FLOATING TOGGLE
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
OpenBtn.Position = UDim2.new(0, 10, 0, 200)
OpenBtn.Size = UDim2.new(0, 70, 0, 30)
OpenBtn.Text = "TOGGLE"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Draggable = true
OpenBtn.MouseButton1Click:Connect(function() Library:ToggleUI() end)

-- 2. NEW UI-BASED FOV CIRCLE (HOLLOW)
local FOVGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local FOVFrame = Instance.new("Frame", FOVGui)
local UICorner = Instance.new("UICorner", FOVFrame)
local UIStroke = Instance.new("UIStroke", FOVFrame)

FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FOVFrame.BackgroundTransparency = 1 -- Transparent inside
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 2
UICorner.CornerRadius = UDim.new(1, 0) -- Makes it a perfect circle

-- TABS
local Combat = Window:NewTab("Combat")
local Visuals = Window:NewTab("Visuals")
local Movement = Window:NewTab("Movement")
local Misc = Window:NewTab("Misc")

-- COMBAT
local AimSec = Combat:NewSection("Aimbot")
AimSec:NewToggle("Enable Aimbot", "Visible Only", function(state) Settings.Aimbot = state end)
AimSec:NewSlider("Aimbot Range", "FOV Size", 800, 50, function(s) Settings.FOV = s end)
AimSec:NewToggle("Show FOV Circle", "Toggle Circle", function(state) Settings.ShowFOV = state end)

local ModSec = Combat:NewSection("Gun Mods")
ModSec:NewButton("No Recoil / No Spread", "Perfect Accuracy", function()
    for _, v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Recoil") then
            v.Recoil = 0
            v.Spread = 0
        end
    end
end)

-- MOVEMENT
local MoveSec = Movement:NewSection("Physics")
MoveSec:NewSlider("WalkSpeed", "Go fast", 250, 16, function(s)
    if game.Players.LocalPlayer.Character then game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s end
end)
MoveSec:NewSlider("Gravity", "Normal is 196", 196, 0, function(s) workspace.Gravity = s end)
MoveSec:NewToggle("NoClip", "Walk through walls", function(state) Settings.NoClip = state end)

-- VISUALS
local EspSec = Visuals:NewSection("ESP")
EspSec:NewToggle("Names & HP", "See everyone", function(state) Settings.ESP = state end)

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
    
    -- Update FOV UI
    FOVFrame.Visible = Settings.ShowFOV
    FOVFrame.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2)

    if Settings.NoClip and lp.Character then
        for _, v in pairs(lp.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    if Settings.Aimbot and lp.Character then
        local nearestEnemy = nil
        local shortestDistance = math.huge
        local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)

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
            end
        end
        if nearestEnemy then
            cam.CFrame = CFrame.new(cam.CFrame.Position, nearestEnemy.Character.Head.Position)
        end
    end
end)
