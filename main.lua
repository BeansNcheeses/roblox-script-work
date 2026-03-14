local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
-- The 'Default' theme is usually the most stable for dragging on mobile
local Window = Library.CreateLib("Flick Mobile v3", "Default")

-- This ensures the UI can be moved around by dragging the top bar
local Main = Window:NewTab("Combat")
local CombatSection = Main:NewSection("Aimbot")
local VisualSection = Main:NewSection("Visuals")

local Settings = {
    Aimbot = false,
    FOV = 150,
    ESP = false
}

-- Keybind to toggle the menu visibility (Useful for mobile)
Main:NewKeybind("Toggle UI", "Press to hide/show", Enum.KeyCode.RightControl, function()
	Library:ToggleUI()
end)

-- Aimbot Logic (No FOV Zoom)
local function GetClosest()
    local nearest = nil
    local last = math.huge
    for i, v in pairs(game.Players:GetPlayers()) do
        if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)).Magnitude
                if dist < last and dist < Settings.FOV then
                    last = dist
                    nearest = v
                end
            end
        end
    end
    return nearest
end

CombatSection:NewToggle("Enable Aimbot", "Lock camera to head", function(state)
    Settings.Aimbot = state
end)

CombatSection:NewSlider("Aimbot Range", "Detection radius", 500, 50, function(s)
    Settings.FOV = s
end)

-- ESP Toggle
VisualSection:NewToggle("Player ESP", "See through walls", function(state)
    Settings.ESP = state
    if not state then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("Highlight") then
                v.Character.Highlight:Destroy()
            end
        end
    end
end)

-- Main Loop (Aimbot & ESP)
game:GetService("RunService").RenderStepped:Connect(function()
    if Settings.Aimbot then
        local target = GetClosest()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local camPos = workspace.CurrentCamera.CFrame.Position
            workspace.CurrentCamera.CFrame = CFrame.new(camPos, target.Character.Head.Position)
        end
    end
    
    if Settings.ESP then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character and not v.Character:FindFirstChild("Highlight") then
                local hl = Instance.new("Highlight", v.Character)
                hl.FillColor = Color3.fromRGB(255, 0, 0)
            end
        end
    end
end)
