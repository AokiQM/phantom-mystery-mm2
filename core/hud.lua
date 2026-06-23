local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local hud = {}
local _sg = nil; local _labels = {}

function hud.init()
    if _sg then return end
    _sg = Instance.new("ScreenGui")
    _sg.Name = "MM2_HUD"; _sg.ResetOnSpawn = false
    _sg.Parent = lp:WaitForChild("PlayerGui")
    local main = Instance.new("TextLabel")
    main.Size = UDim2.new(0, 300, 0, 80)
    main.Position = UDim2.new(1, -310, 0, 10)
    main.BackgroundTransparency = 0.7
    main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    main.TextColor3 = Color3.fromRGB(255, 255, 255)
    main.TextSize = 13; main.Font = Enum.Font.Code
    main.TextXAlignment = Enum.TextXAlignment.Left
    main.Text = "破坏者谜团 v1.0"
    main.Parent = _sg
    _labels.main = main
end

function hud.update(text)
    if _labels.main then _labels.main.Text = text end
end

function hud.destroy()
    if _sg then _sg:Destroy(); _sg = nil; _labels = {} end
end

_G.BFH = _G.BFH or {}; _G.BFH.HUD = hud
return hud
