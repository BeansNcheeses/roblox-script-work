local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Flick Mobile", "Midnight")

local Main = Window:NewTab("Combat")
local Section = Main:NewSection("Aimbot")

local Settings = {
    Aimbot = false,
    Freezing = false,
    FOV = 150
}

-- The actual Aim Function
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

Section:NewToggle("Enable Aimbot", "Locks camera to head", function(state)
    Settings.Aimbot = state
end)

Section:NewSlider("FOV Range", "Size of the aim circle", 500, 50, function(s)
    Settings.FOV = s
end)

-- Loop to run the aimbot
game:GetService("RunService").RenderStepped:Connect(function()
    if Settings.Aimbot then
        local target = GetClosest()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)
