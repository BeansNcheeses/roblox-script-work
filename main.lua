-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Flick Mobile Hub",
   LoadingTitle = "Loading Features...",
   LoadingSubtitle = "By Gemini",
   ConfigurationSaving = {
      Enabled = false,
   },
   KeySystem = false -- No annoying key systems
})

local Settings = { Aimbot = false, FOV = 150, ESP = false }

-- --- TABS ---
local CombatTab = Window:CreateTab("Combat")
local VisualsTab = Window:CreateTab("Visuals")
local PlayerTab = Window:CreateTab("Player")

-- --- COMBAT FEATURES ---
CombatTab:CreateToggle({
   Name = "Enable Aimbot",
   CurrentValue = false,
   Callback = function(Value)
      Settings.Aimbot = Value
   end,
})

CombatTab:CreateSlider({
   Name = "Aimbot FOV Range",
   Range = {50, 500},
   Increment = 10,
   Suffix = "Radius",
   CurrentValue = 150,
   Callback = function(Value)
      Settings.FOV = Value
   end,
})

-- --- VISUAL FEATURES ---
VisualsTab:CreateToggle({
   Name = "Enable Player ESP",
   CurrentValue = false,
   Callback = function(Value)
      Settings.ESP = Value
      -- Clean up highlights when turned off
      if not Value then
         for _, v in pairs(game.Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("Highlight") then
               v.Character.Highlight:Destroy()
            end
         end
      end
   end,
})

-- --- PLAYER FEATURES ---
PlayerTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 150},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Callback = function(Value)
      if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
         game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

PlayerTab:CreateSlider({
   Name = "JumpPower",
   Range = {50, 300},
   Increment = 5,
   Suffix = "Power",
   CurrentValue = 50,
   Callback = function(Value)
      if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
         game.Players.LocalPlayer.Character.Humanoid.UseJumpPower = true
         game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
      end
   end,
})

-- --- THE CORE LOOP (Makes Aimbot & ESP Work) ---
game:GetService("RunService").RenderStepped:Connect(function()
    -- Aimbot
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

    -- ESP
    if Settings.ESP then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v ~= game.Players.LocalPlayer and v.Character and not v.Character:FindFirstChild("Highlight") then
                local hl = Instance.new("Highlight", v.Character)
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.FillTransparency = 0.5
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            end
        end
    end
end)
