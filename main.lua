local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Flick Chaos Hub - Mobile", "Midnight")

local Settings = {
    Aimbot = false,
    ESP = false,
    FOV = 150,
    ShowFOV = true,
    NoClip = false,
    MenuOpen = true -- Track if menu is open
}

-- 1. FLOATING TOGGLE (The Fix)
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
OpenBtn.Position = UDim2.new(0, 10, 0, 200)
OpenBtn.Size = UDim2.new(0, 70, 0, 30)
OpenBtn.Text = "TOGGLE"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Draggable = true

-- This part fixes the "clicking through hidden menu" bug
OpenBtn.MouseButton1Click:Connect(function()
    Settings.MenuOpen = not Settings.MenuOpen
    Library:ToggleUI()
    
    -- If menu is closed, we move the UI container way off screen 
    -- so your fingers can't accidentally touch invisible sliders.
    local coreGui = game:GetService("CoreGui")
    local mainUI = coreGui:FindFirstChild("Flick Chaos Hub - Mobile") or coreGui:FindFirstChild("Midnight")
    
    if mainUI then
        if Settings.MenuOpen then
            mainUI.Enabled = true
        else
            mainUI.Enabled = false -- Disables all input to the menu
        end
    end
end)

-- 2. UI-BASED FOV CIRCLE
local FOVGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local FOVFrame = Instance.new("Frame", FOVGui)
local UICorner = Instance.new("UICorner", FOVFrame)
local UIStroke = Instance.new("UIStroke", FOVFrame)

FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 2
UICorner.CornerRadius = UDim.new(1, 0)

-- --- TABS ---
local Combat = Window:NewTab("Combat")
local Visuals = Window:NewTab("Visuals")
local Movement = Window:NewTab("Movement")
local Misc = Window:NewTab("Misc")

-- COMBAT
local AimSec = Combat:NewSection("Aimbot Settings")
AimSec:NewToggle("Enable Aimbot", "Visible Only", function(state) Settings.Aimbot = state end)
AimSec:NewSlider("FOV Size", "Circle Radius", 500, 50, function(s) Settings.FOV = s end)
AimSec:NewToggle("Show FOV Circle", "Toggle Circle Visibility", function(state) Settings.ShowFOV = state end)

-- VISUALS
local EspSec = Visuals:NewSection("Player ESP")
EspSec:NewToggle("Names & HP ESP", "Billboard Tracking", function(state)
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
local MoveSec = Movement:NewSection("Movement Cheats")
MoveSec:NewSlider("WalkSpeed", "Go fast", 250, 16, function(s)
    if Settings.MenuOpen and game.Players.LocalPlayer.Character then 
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s 
    end
end)
MoveSec:NewToggle("NoClip", "Walk through walls", function(state) Settings.NoClip = state end)

-- MISC
local MiscSec = Misc:NewSection("Extra Features")
MiscSec:NewButton("Full Bright", "Brightness Fix", function()
    game:GetService("Lighting").Brightness = 2
    game:GetService("Lighting").ClockTime = 14
    game:GetService("Lighting").GlobalShadows = false
end)

-- --- LOGIC ---
local function IsVisible(targetPart)
    local char = game.Players.LocalPlayer.Character
    local cam = workspace.CurrentCamera
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char, targetPart.Parent}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(cam.CFrame.Position, targetPart.Position - cam.CFrame.Position, params)
    return result == nil
end

game:GetService("RunService").RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    local lp = game.Players.LocalPlayer
    
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

    if Settings.ESP then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("Head") then
                local head = v.Character.Head
                local esp = head:FindFirstChild("MobileESP")
                if not esp then
                    local bill = Instance.new("BillboardGui", head)
                    bill.Name = "MobileESP"
                    bill.AlwaysOnTop = true
                    bill.Size = UDim2.new(0, 100, 0, 50)
                    bill.ExtentsOffset = Vector3.new(0, 3, 0)
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
