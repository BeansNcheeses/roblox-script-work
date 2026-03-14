print("--- LOADING FLICK SCRIPT ---")

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Flick Mobile", "Default")

local Main = Window:NewTab("Main")
local Section = Main:NewSection("Features")

local Settings = { Aimbot = false, ESP = false, FOV = 150 }

Section:NewToggle("Aimbot", "Locks onto heads", function(state)
    Settings.Aimbot = state
end)

Section:NewToggle("ESP", "Highlights players", function(state)
    Settings.ESP = state
    if not state then
        for _, v in pairs(game.Players:GetPlayers()) do
            if v.Character and v.Character:FindFirstChild("Highlight") then
                v.Character.Highlight:Destroy()
            end
        end
    end
end)

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
                Instance.new("Highlight", v.Character)
            end
        end
    end
end)

print("--- SCRIPT LOADED SUCCESSFULLY ---")
