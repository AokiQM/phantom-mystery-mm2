-- 破坏者谜团 Loader — Murder Mystery 2
_G.BFH = _G.BFH or {}
_G._BFH_STOP_ALL = _G._BFH_STOP_ALL or {}

local BASE = "https://raw.githubusercontent.com/AokiQM/phantom-mystery-mm2/main/"

local codes = {}
local remaining = 0
local function download(name, url)
    remaining = remaining + 1
    task.spawn(function()
        for retry = 1, 3 do
            local ok, c = pcall(function() return game:HttpGet(url) end)
            if ok and c and #c > 50 then codes[name] = c; break end
            if retry < 3 then task.wait(0.3) end
        end
        remaining = remaining - 1
    end)
end

download("ui", BASE .. "ui.lua")
download("bridge", BASE .. "bridge.lua")

local coreModules = {
    "chat_config", "feedback_config", "registry",
    "esp_mm2", "commands", "hud",
    "f_stealth_esp", "f_speed",
}
for _, modName in ipairs(coreModules) do
    download("core_" .. modName, BASE .. "core/" .. modName .. ".lua")
end

while remaining > 0 do task.wait() end

_G.BFH.Core = _G.BFH.Core or {}
_G.BFH.Core.FEATURES = {}
_G.BFH.Core._th = {}
_G.BFH.Core._vals = {}

for _, modName in ipairs(coreModules) do
    local code = codes["core_" .. modName]
    if code then
        local preamble = "_G.BFH=_G.BFH or {};_G.BFH.Core=_G.BFH.Core or {};"
        local fn, err = loadstring(preamble .. code)
        if fn then
            local ok, M = pcall(fn)
            if ok and type(M) == "table" then
                _G.BFH.Core[modName:upper()] = M
            elseif type(M) == "function" then
                pcall(M, _G.BFH.Core.FEATURES)
            end
        end
    end
end

if codes.bridge then pcall(function() loadstring(codes.bridge)() end) end
if codes.ui then pcall(function() loadstring(codes.ui)() end) end

print("[破坏者谜团] 加载完成")