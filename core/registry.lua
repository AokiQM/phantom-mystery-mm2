local Registry = {}

Registry._features = {}  
Registry._state = {}     

function Registry.register(key, handlers)
    
    local existing = Registry._features[key]
    if existing and existing.active then
        if existing.handlers.onStop then
            existing.handlers.onStop()
        end
        Registry._state[key] = false
    end

    Registry._features[key] = {
        handlers = handlers,
        active = false,
    }
end

function Registry.set(key, state)
    local feature = Registry._features[key]
    if not feature then
        warn(string.format("[BFH][Registry] key '%s' 未注册，无法设置状态为 %s",
            tostring(key), tostring(state)))
        return
    end

    if state == feature.active then
        return  
    end

    if state then
        if feature.handlers.onStart then
            feature.handlers.onStart()
        end
        feature.active = true
        Registry._state[key] = true
    else
        if feature.handlers.onStop then
            feature.handlers.onStop()
        end
        feature.active = false
        Registry._state[key] = false
    end
end

function Registry.get(key)
    local feature = Registry._features[key]
    if not feature then
        return false
    end
    return feature.active
end

function Registry.cleanupAll()
    
    local activeKeys = {}
    for key, feature in pairs(Registry._features) do
        if feature.active then
            table.insert(activeKeys, key)
        end
    end

    
    for _, key in ipairs(activeKeys) do
        local feature = Registry._features[key]
        if feature and feature.active then
            if feature.handlers.onStop then
                local ok, err = pcall(feature.handlers.onStop)
                if not ok then
                    warn(string.format("[BFH][Registry] cleanupAll: key '%s' onStop 出错: %s",
                        tostring(key), tostring(err)))
                end
            end
            feature.active = false
        end
    end

    
    Registry._features = {}
    Registry._state = {}

    return #activeKeys
end

_G._BFH_STOP_ALL = _G._BFH_STOP_ALL or {}
table.insert(_G._BFH_STOP_ALL, function()
    Registry.cleanupAll()
end)

_G.BFH.Core = _G.BFH.Core or {}; _G.BFH.Core.REGISTRY = Registry
return Registry
