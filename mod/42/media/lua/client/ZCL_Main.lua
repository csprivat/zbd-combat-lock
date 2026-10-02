-- Load the shared namespace and state helpers before registering event hooks.
require "ZCL_State"

local ZCL = ZbdCombatLock

local FEATURE_KEY_BINDING = "Zbd Combat Lock"
local FEATURE_KEY_CATEGORY = "[Zbd Combat Lock]"
local DEFAULT_FEATURE_KEY = Keyboard and Keyboard.KEY_F8 or 66

-- Build 42 exposes key bindings through Core, so the feature switch appears in
-- the native key-binding screen and does not require another mod.
local function registerFeatureKeyBinding()
    local ok, registered = pcall(function()
        local core = getCore()
        if not core then return false end

        -- MainOptions builds its visible list from the Lua keyBinding table,
        -- then mirrors those entries to Core. Add both records only once so a
        -- Lua reload cannot duplicate the category or action.
        if type(keyBinding) == "table" then
            local hasCategory = false
            local hasAction = false
            for _, binding in ipairs(keyBinding) do
                if binding.value == FEATURE_KEY_CATEGORY then hasCategory = true end
                if binding.value == FEATURE_KEY_BINDING then hasAction = true end
            end

            if not hasCategory then
                table.insert(keyBinding, { value = FEATURE_KEY_CATEGORY })
            end
            if not hasAction then
                table.insert(keyBinding, { value = FEATURE_KEY_BINDING, key = DEFAULT_FEATURE_KEY })
            end
        end

        if not core:getKeyBinding(FEATURE_KEY_BINDING) then
            core:addKeyBinding(FEATURE_KEY_BINDING, DEFAULT_FEATURE_KEY, 0, false, false, false)
        end
        return type(keyBinding) == "table"
            and core:getKeyBinding(FEATURE_KEY_BINDING) ~= nil
    end)

    ZCL.State.keyBindingRegistered = ok and registered == true
    if not ZCL.State.keyBindingRegistered then
        print("[ZbdCombatLock] nao foi possivel registrar a tecla de habilitar/desabilitar")
    end
end

-- Enable the native toggle while client Lua is loading, before IsoPlayer and
-- its CharacterInputComponent are created for the game session.
registerFeatureKeyBinding()
ZCL.startSession()

-- A missing player is expected in menus. A dead player is treated as blocked
-- so the mod can release the native aim state immediately.
local function isUsablePlayer(player)
    if not player then return false end

    local ok, dead = pcall(function()
        return player:isDead()
    end)

    return not ok or dead ~= true
end

-- Observe only the first local player. Combat, movement, attacks, stamina and
-- networking remain entirely owned by Project Zomboid.
local function onPlayerUpdate(player)
    if not player or player:getPlayerNum() ~= 0 then return end

    if not isUsablePlayer(player) then
        ZCL.clearAim(player)
        ZCL.State.lastPlayer = nil
        return
    end

    if ZCL.State.featureEnabled and not ZCL.State.ownsNativeToggle then
        ZCL.startSession()
    end

    ZCL.State.lastPlayer = player
    if ZCL.State.featureEnabled then
        ZCL.syncFromPlayer(player)
    else
        ZCL.State.enabled = false
    end
end

-- Draw a status label only after the game confirms that force aim is active.
-- The label is informational and does not intercept mouse or keyboard input.
local function drawIndicator()
    if not getTextManager or not getCore then return end

    local textManager = getTextManager()
    local core = getCore()
    if not textManager or not core then return end

    local y = core:getScreenHeight() - 42
    local notice = ZCL.getNotice()
    if notice then
        textManager:DrawString(UIFont.Small, 18, y, notice, 1.0, 0.82, 0.35, 0.95)
    elseif ZCL.State.enabled then
        textManager:DrawString(UIFont.Small, 18, y, "ZCL: COMBATE ATIVO", 0.40, 1.0, 0.40, 0.90)
    end
end

local function uiHasInputPriority()
    if isGamePaused then
        local ok, paused = pcall(isGamePaused)
        if ok and paused == true then return true end
    end

    if UIManager and UIManager.isModalVisible then
        local ok, modalVisible = pcall(UIManager.isModalVisible)
        if ok and modalVisible == true then return true end
    end

    return false
end

-- OnKeyPressed is edge-triggered by the game. This handler never eats the key;
-- it only reacts after checking that gameplay, rather than UI, owns the input.
local function onKeyPressed(key)
    if not ZCL.State.keyBindingRegistered or uiHasInputPriority() then return end

    local ok, matches = pcall(function()
        local core = getCore()
        return core and core:isKey(FEATURE_KEY_BINDING, key)
    end)
    if not ok or matches ~= true then return end

    local player = nil
    if getSpecificPlayer then
        local playerOk, result = pcall(getSpecificPlayer, 0)
        if playerOk then player = result end
    end
    if not isUsablePlayer(player) then return end

    ZCL.toggleFeature(player)
end

-- Reassert the in-memory option when a game session starts. startSession() is
-- idempotent, so calling it both at load time and here is safe.
local function onGameStart()
    ZCL.State.featureEnabled = true
    registerFeatureKeyBinding()
    ZCL.startSession()
end

-- Clear the active stance before the local player object is discarded.
local function onDisconnect()
    ZCL.finishSession()
end

-- Register long-lived function references with the Build 42 event system.
Events.OnPlayerUpdate.Add(onPlayerUpdate)
Events.OnPostUIDraw.Add(drawIndicator)
Events.OnGameStart.Add(onGameStart)

if Events.OnKeyPressed then
    Events.OnKeyPressed.Add(onKeyPressed)
end

if Events.OnDisconnect then
    Events.OnDisconnect.Add(onDisconnect)
end

print("[ZbdCombatLock] 0.3.0 carregado")
