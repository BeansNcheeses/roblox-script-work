local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Flick Chaos Hub - Mobile", "Midnight")

local Settings = {
    Aimbot = false,
    ESP = false,
    FOV = 150,
    ShowFOV = true,
    HitboxSize = 2,
    FlySpeed = 50
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

-- FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Transparency = 0.7

-- TABS
local Combat = Window:NewTab("Combat")
local Visuals = Window:NewTab("Visuals")
local Player = Window:NewTab("Movement")
local Misc = Window:NewTab("Misc")

-- COMBAT (Everyon is a target)
local AimSec = Combat:NewSection("Hardcore Aimbot")
AimSec:NewToggle("Enable Aimbot (Visible Only)", "Locks onto ANYONE you see", function(state)
    Settings.Aimbot = state
end)

AimSec:NewSlider("Aimbot Range", "FOV Size", 800, 50, function(s)
    Settings.FOV = s
end)

local HitSec = Combat:NewSection("Hitboxes")
HitSec:NewSlider("Expand Hitboxes", "Make heads massive", 20, 2, function(s)
    Settings.HitboxSize = s
end)

-- VISUALS
local EspSec = Visuals:NewSection("Full ESP")
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
local MoveSec = Player:NewSection("Speed & Fly")
MoveSec:NewSlider("WalkSpeed", "Go fast", 250, 16, function(s)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s
end)

MoveSec:NewButton("Fly (Mobile)", "Enables Fly script", function()
    local player = game.Players.LocalPlayer
    local char = player.Character
    local root = char.HumanoidRootPart
    local camera = workspace.CurrentCamera
    local flying = true
    
    local bg = Instance.new("BodyGyro", root)
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.cframe = root.CFrame
    
    local bv = Instance.new("BodyVelocity", root)
    bv.velocity = Vector3.new(0,0.1,0)
    bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
    
    spawn(function()
        while flying do
            wait()
            bv.velocity = camera.CFrame.LookVector * Settings.FlySpeed
            bg.cframe = camera.CFrame
        end
    end)
end)

-- MISC
local MiscSec = Misc:NewSection("Utilities")
MiscSec:NewButton("Infinite Jump", "Spam jump to fly", function()
    game:GetService("UserInputService").JumpRequest:Connect(function()
        game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end)
end)

MiscSec:NewButton("Teleport to Random Player", "TP to a target", function()
    local players = game.Players:GetPlayers()
    local randomPlayer = players[math.random(1, #players)]
    if randomPlayer ~= game.Players.LocalPlayer and randomPlayer.Character then
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = randomPlayer.Character.HumanoidRootPart.CFrame
    end
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
                
                -- Hitbox Expander Logic
                v.Character.Head.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                v.Character.Head.Transparency = 0.5
                v.Character.Head.CanCollide = false
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
                    lbl.Font = "SourceSansBold"
                else
                    esp.Tag.Text = v.Name .. " [" .. math.floor(v.Character.Humanoid.Health) .. "]"
                end
            end
        end
    end
end)
