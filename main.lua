-- Orion Library is much more stable for Delta Mobile
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "Flick Mobile v4", HidePremium = false, SaveConfig = true, ConfigFolder = "OrionTest"})

local Settings = {
    Aimbot = false,
    ESP = false,
    FOV = 150
}

local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddToggle({
    Name = "Enable Aimbot",
    Default = false,
    Callback = function(Value)
        Settings.Aimbot = Value
    end    
})

MainTab:AddToggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(Value)
        Settings.ESP = Value
        if not Value then
            for _, v in pairs(game.Players:GetPlayers()) do
                if v.Character and v.Character:FindFirstChild("Highlight") then
                    v.Character.Highlight:Destroy()
                end
            end
        end
    end    
})

-- The loop that makes it work
game:GetService("RunService").RenderStepped:Connect(function()
    if Settings.Aimbot then
        local nearest = nil
        local last = math.huge
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                local pos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(v.Character.Head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)).Magnitude
                    if dist < last and dist < Settings.FOV then
                        last = dist
                        nearest = v
                    end
                end
            end
        end
        if nearest then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, nearest.Character.Head.Position)
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

OrionLib:Init()
