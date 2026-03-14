local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Flick Mobile God Menu", "Midnight")

local Settings = {
    Aimbot = false,
    ESP = false,
    FOV = 150
}

-- 1. FLOATING TOGGLE BUTTON (Since you're on mobile)
local ScreenGui = Instance.new("ScreenGui")
local OpenBtn = Instance.new("TextButton")
ScreenGui.Parent = game:GetService("CoreGui")
OpenBtn.Parent = ScreenGui
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
OpenBtn.BackgroundTransparency = 0.5
OpenBtn.Position = UDim2.new(0, 10, 0, 200)
OpenBtn.Size = UDim2.new(0, 60, 0, 30)
OpenBtn.Text = "SHOW/HIDE"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.TextSize = 10
OpenBtn.Draggable = true -- Drag this button anywhere you want

OpenBtn.MouseButton1Click:Connect(function()
    Library:ToggleUI()
end)

-- 2. TABS
local Main = Window:NewTab("Combat")
local Visuals = Window:NewTab("Visuals")
local Player = Window:NewTab("Movement")

-- 3. COMBAT
local AimSec = Main:NewSection("Aimbot")
AimSec:NewToggle("Enable Aimbot", "Lock to Head", function(state)
    Settings.Aimbot = state
end)

-- 4. VISUALS (Name Tag ESP)
local EspSec = Visuals:NewSection("Text ESP")
EspSec:NewToggle("Show Names", "Works on all phones", function(state)
    Settings.ESP = state
    if not state then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("Head") and v.Character.Head:FindFirstChild("MobileESP") then
                v.Character.Head.MobileESP:Destroy()
            end
        end
    end
end)

-- 5. MOVEMENT
local MoveSec = Player:NewSection("Cheats")
MoveSec:NewSlider("Speed", "WalkSpeed", 150, 16, function(s)
    if game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s
    end
end)

-- 6. THE CORE LOOP
game:GetService("RunService").RenderStepped:Connect(function()
    -- Aimbot Logic
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

    -- Name Tag ESP Logic
    if Settings.ESP then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                if not v.Character.Head:FindFirstChild("MobileESP") then
                    local bill = Instance.new("BillboardGui", v.Character.Head)
                    bill.Name = "MobileESP"
                    bill.AlwaysOnTop = true
                    bill.Size = UDim2.new(0, 100, 0, 50)
                    bill.Adornee = v.Character.Head
                    bill.ExtentsOffset = Vector3.new(0, 3, 0)

                    local lbl = Instance.new("TextLabel", bill)
                    lbl.Text = v.Name
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = Color3.fromRGB(255, 0, 0)
                    lbl.TextStrokeTransparency = 0
                    lbl.Font = Enum.Font.SourceSansBold
                    lbl.TextSize = 14
                end
            end
        end
    end
end)
