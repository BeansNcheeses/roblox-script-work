-- Re-defining the Library and Window
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Flick Chaos Hub", "Midnight")

local Settings = {
    Aimbot = false,
    ESP = false,
    FOV = 150,
    ShowFOV = true,
    NoClip = false
}

-- 1. STABLE TOGGLE (Failsafe)
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Name = "FlickToggle"
OpenBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
OpenBtn.Position = UDim2.new(0, 10, 0, 200)
OpenBtn.Size = UDim2.new(0, 70, 0, 30)
OpenBtn.Text = "TOGGLE"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Draggable = true

OpenBtn.MouseButton1Click:Connect(function()
    local target = game:GetService("CoreGui"):FindFirstChild("Flick Chaos Hub")
    if target then
        target.Enabled = not target.Enabled
    end
end)

-- 2. FOV CIRCLE (Stable UI)
local FOVGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local FOVFrame = Instance.new("Frame", FOVGui)
local UIStroke = Instance.new("UIStroke", FOVFrame)
Instance.new("UICorner", FOVFrame).CornerRadius = UDim.new(1, 0)

FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 2

-- 3. TABS (Ensuring they load in order)
local Combat = Window:NewTab("Combat")
local Visuals = Window:NewTab("Visuals")
local Movement = Window:NewTab("Movement")
local Misc = Window:NewTab("Misc")

-- COMBAT
local AimSec = Combat:NewSection("Aimbot")
AimSec:NewToggle("Enable Aimbot", "Locks onto visible", function(state) Settings.Aimbot = state end)
AimSec:NewSlider("FOV Size", "Circle Radius", 500, 50, function(s) Settings.FOV = s end)
AimSec:NewToggle("Show FOV Circle", "Outline Visibility", function(state) Settings.ShowFOV = state end)

-- VISUALS
local EspSec = Visuals:NewSection("ESP")
EspSec:NewToggle("Names & HP ESP", "Billboard ESP", function(state) Settings.ESP = state end)

-- MOVEMENT
local MoveSec = Movement:NewSection("Movement")
MoveSec:NewSlider("WalkSpeed", "Go fast", 250, 16, function(s)
    if game.Players.LocalPlayer.Character then game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s end
end)
MoveSec:NewToggle("NoClip", "Walk through walls", function(state) Settings.NoClip = state end)

-- MISC
local MiscSec = Misc:NewSection("Misc Features")
MiscSec:NewButton("Full Bright", "Lighting Fix", function()
    game:GetService("Lighting").Brightness = 2
    game:GetService("Lighting").ClockTime = 14
end)
MiscSec:NewButton("Server Hop", "Join New Server", function()
    local ts = game:GetService("TeleportService")
    local hs = game:GetService("HttpService")
    local servers = hs:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    for _, v in pairs(servers.data) do
        if v.playing < v.maxPlayers then
            ts:TeleportToPlaceInstance(game.PlaceId, v.id)
            break
        end
    end
end)

-- 4. CORE ENGINE
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
        local nearest = nil
        local lastDist = math.huge
        local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)

        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("Head") and v.Character.Humanoid.Health > 0 then
                local pos, onScreen = cam:WorldToScreenPoint(v.Character.Head.Position)
                if onScreen then
                    local screenDist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if screenDist < Settings.FOV and screenDist < lastDist then
                        if IsVisible(v.Character.Head) then
                            lastDist = screenDist
                            nearest = v
                        end
                    end
                end
            end
        end
        if nearest then
            cam.CFrame = CFrame.new(cam.CFrame.Position, nearest.Character.Head.Position)
        end
    end

    if Settings.ESP then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("Head") then
                local head = v.Character.Head
                if not head:FindFirstChild("MobileESP") then
                    local bill = Instance.new("BillboardGui", head)
                    bill.Name = "MobileESP"
                    bill.AlwaysOnTop = true
                    bill.Size = UDim2.new(0, 100, 0, 50)
                    local lbl = Instance.new("TextLabel", bill)
                    lbl.Size = UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = Color3.fromRGB(255, 0, 0)
                    lbl.Text = v.Name
                end
            end
        end
    end
end)
