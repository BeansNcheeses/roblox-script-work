local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Flick Mobile God Menu", "Midnight")

-- Variables
local Settings = {
    Aimbot = false,
    ESP = false,
    FOV = 150
}

-- CREATE FLOATING TOGGLE BUTTON
local ScreenGui = Instance.new("ScreenGui")
local OpenBtn = Instance.new("TextButton")
ScreenGui.Parent = game:GetService("CoreGui")
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
OpenBtn.Position = UDim2.new(0, 10, 0, 150)
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Text = "MENU"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Draggable = true
OpenBtn.MouseButton1Click:Connect(function() Library:ToggleUI() end)

-- TABS
local Main = Window:NewTab("Combat")
local Visuals = Window:NewTab("Visuals")
local Player = Window:NewTab("Movement")

-- COMBAT SECTION
local AimSec = Main:NewSection("Aimbot")
AimSec:NewToggle("Enable Aimbot", "Locks onto heads", function(state)
    Settings.Aimbot = state
end)

AimSec:NewSlider("Aimbot Range", "FOV Radius", 500, 50, function(s)
    Settings.FOV = s
end)

-- VISUALS SECTION (FIXED ESP)
local EspSec = Visuals:NewSection("ESP")
EspSec:NewToggle("Player ESP", "Highlights everyone", function(state)
    Settings.ESP = state
    if not state then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("Highlight") then
                v.Character.Highlight:Destroy()
            end
        end
    end
end)

-- PLAYER SECTION
local MoveSec = Player:NewSection("Movement")
MoveSec:NewSlider("WalkSpeed", "Speed", 150, 16, function(s)
    if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s
    end
end)

MoveSec:NewButton("Infinite Jump", "Jump in air", function()
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end)
end)

-- THE LOOP (Aimbot & Fixed ESP)
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
                -- MOBILE FIX: Fill must not be 0 or 1 transparency to show up correctly
                hl.FillTransparency = 0.5 
                hl.OutlineTransparency = 0 -- Outlines may still be invisible on low-end phones
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            end
        end
    end
end)
