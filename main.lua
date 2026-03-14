local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Flick Mobile God Menu", "Midnight")

local Settings = {
    Aimbot = false,
    ESP = false,
    FOV = 150,
    ShowFOV = true,
    TeamCheck = true
}

-- FLOATING TOGGLE
local ScreenGui = Instance.new("ScreenGui")
local OpenBtn = Instance.new("TextButton")
ScreenGui.Parent = game:GetService("CoreGui")
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
OpenBtn.BackgroundTransparency = 0.5
OpenBtn.Position = UDim2.new(0, 10, 0, 200)
OpenBtn.Size = UDim2.new(0, 70, 0, 30)
OpenBtn.Text = "SHOW/HIDE"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.TextSize = 10
OpenBtn.Draggable = true
OpenBtn.MouseButton1Click:Connect(function() Library:ToggleUI() end)

-- FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7

-- TABS
local Main = Window:NewTab("Combat")
local Visuals = Window:NewTab("Visuals")
local Player = Window:NewTab("Movement")

local AimSec = Main:NewSection("Aimbot")
AimSec:NewToggle("Enable Aimbot", "Locks to Closest Enemy", function(state)
    Settings.Aimbot = state
end)

AimSec:NewToggle("Team Check", "Ignore Teammates", function(state)
    Settings.TeamCheck = state
end)

AimSec:NewSlider("Aimbot FOV", "Detection Range", 500, 50, function(s)
    Settings.FOV = s
end)

local EspSec = Visuals:NewSection("Visuals")
EspSec:NewToggle("Name/Health ESP", "See through walls", function(state)
    Settings.ESP = state
    if not state then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("Head") and v.Character.Head:FindFirstChild("MobileESP") then
                v.Character.Head.MobileESP:Destroy()
            end
        end
    end
end)

-- IMPROVED WALL CHECK
local function IsVisible(targetPart)
    local char = game.Players.LocalPlayer.Character
    local cam = workspace.CurrentCamera
    if not char or not targetPart then return false end
    
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

    if Settings.Aimbot and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local nearestEnemy = nil
        local shortestDistance = math.huge

        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                
                -- Team Check Logic
                if Settings.TeamCheck and v.Team == lp.Team then 
                    continue 
                end

                local headPos, onScreen = cam:WorldToScreenPoint(v.Character.Head.Position)
                
                if onScreen then
                    -- Check if they are inside the FOV circle first
                    local screenDist = (Vector2.new(headPos.X, headPos.Y) - center).Magnitude
                    
                    if screenDist < Settings.FOV then
                        -- Check actual 3D distance to find the CLOSEST enemy
                        local worldDist = (v.Character.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
                        
                        if worldDist < shortestDistance then
                            if IsVisible(v.Character.Head) then
                                shortestDistance = worldDist
                                nearestEnemy = v
                            end
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
            if v ~= lp and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") then
                local esp = v.Character.Head:FindFirstChild("MobileESP")
                if not esp then
                    local bill = Instance.new("BillboardGui", v.Character.Head)
                    bill.Name = "MobileESP"
                    bill.AlwaysOnTop = true
                    bill.Size = UDim2.new(0, 100, 0, 50)
                    bill.ExtentsOffset = Vector3.new(0, 3, 0)
                    local lbl = Instance.new("TextLabel", bill)
                    lbl.Name = "Tag"
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = (Settings.TeamCheck and v.Team == lp.Team) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
                    lbl.TextStrokeTransparency = 0
                    lbl.Font = Enum.Font.SourceSansBold
                    lbl.TextSize = 14
                else
                    esp.Tag.Text = v.Name .. " [" .. math.floor(v.Character.Humanoid.Health) .. " HP]"
                end
            end
        end
    end
end)
