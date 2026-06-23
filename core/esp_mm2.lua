-- MM2 ESP — 角色高亮透视
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

local HIGHLIGHTS = {}
local ROLE_COLORS = {
    Murderer = Color3.fromRGB(255, 60, 60),
    Sheriff  = Color3.fromRGB(60, 60, 255),
    Innocent = Color3.fromRGB(60, 255, 60),
    Unknown  = Color3.fromRGB(200, 200, 200),
}

local _enabled = false
local _stealthESP = false
local _thread = nil

local function getRoleData()
    local ok, crc = pcall(function()
        return require(game:GetService("ReplicatedStorage").Modules.CurrentRoundClient)
    end)
    if ok and crc and crc.PlayerData then return crc.PlayerData end
    return nil
end

local function updateAll()
    local data = getRoleData()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp then
            local char = player.Character
            if char then
                local hl = HIGHLIGHTS[player]
                if not hl or not hl.Parent then
                    if hl then pcall(function() hl:Destroy() end) end
                    hl = Instance.new("Highlight")
                    hl.Name = "MM2_ESP"
                    hl.FillTransparency = 0.55
                    hl.OutlineTransparency = 0
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Enabled = true
                    hl.Parent = char
                    HIGHLIGHTS[player] = hl
                elseif hl.Parent ~= char then
                    pcall(function() hl.Parent = char end)
                end

                local role = "Unknown"
                if data then
                    for k, v in pairs(data) do
                        if type(v) == "table" and (k == player.Name or k == tostring(player.UserId)) then
                            role = v.Role or v.role or "Unknown"
                            break
                        end
                    end
                end
                local color = ROLE_COLORS[role] or ROLE_COLORS.Unknown
                hl.FillColor = color
                hl.OutlineColor = color

                if _stealthESP and role == "Murderer" then
                    for _, part in ipairs(char:GetChildren()) do
                        if part:IsA("BasePart") and part.Transparency > 0.5 then
                            pcall(function() part.Transparency = 0.15 end)
                        end
                    end
                    for _, obj in ipairs(char:GetDescendants()) do
                        if obj:IsA("Highlight") and obj.Name ~= "MM2_ESP" then
                            pcall(function() obj:Destroy() end)
                        end
                    end
                end
            end
        end
    end
end

local function toggleESP(state)
    _enabled = state
    if state then
        if not _thread then
            _thread = task.spawn(function()
                while _enabled do
                    pcall(updateAll)
                    task.wait(0.15)
                end
            end)
        end
    else
        _stealthESP = false
        if _thread then task.cancel(_thread); _thread = nil end
        for _, hl in pairs(HIGHLIGHTS) do
            pcall(function() hl:Destroy() end)
        end
        HIGHLIGHTS = {}
    end
end

local function toggleStealthESP(state)
    _stealthESP = state
end

_G.BFH = _G.BFH or {}
_G.BFH.MM2 = _G.BFH.MM2 or {}
_G.BFH.MM2.ESP = {
    toggleESP = toggleESP,
    toggleStealthESP = toggleStealthESP,
}

for _, p in ipairs(Players:GetPlayers()) do
    p.CharacterAdded:Connect(function()
        if _enabled then task.wait(0.3); pcall(updateAll) end
    end)
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        if _enabled then task.wait(0.3); pcall(updateAll) end
    end)
end)

return {}
