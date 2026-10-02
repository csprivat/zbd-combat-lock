-- Load the shared namespace and state helpers before registering event hooks.
require "ZCL_State"

local ZCL = ZbdCombatLock

-- Enable the native toggle while client Lua is loading, before IsoPlayer and
-- its CharacterInputComponent are created for the game session.
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
        ZCL.endSession(player)
        return
    end

    if not ZCL.State.ownsNativeToggle then
        ZCL.startSession()
    end

    ZCL.State.lastPlayer = player
    ZCL.syncFromPlayer(player)
end

-- Draw a status label only after the game confirms that force aim is active.
-- The label is informational and does not intercept mouse or keyboard input.
local function drawIndicator()
    if not ZCL.State.enabled then return end
    if not getTextManager or not getCore then return end

    local textManager = getTextManager()
    local core = getCore()
    if not textManager or not core then return end

    local y = core:getScreenHeight() - 42
    textManager:DrawString(UIFont.Small, 18, y, "ZCL: COMBATE ATIVO", 0.40, 1.0, 0.40, 0.90)
end

-- Reassert the in-memory option when a game session starts. startSession() is
-- idempotent, so calling it both at load time and here is safe.
local function onGameStart()
    ZCL.startSession()
end

-- Clear the active stance before the local player object is discarded.
local function onDisconnect()
    ZCL.endSession()
end

-- Register long-lived function references with the Build 42 event system.
Events.OnPlayerUpdate.Add(onPlayerUpdate)
Events.OnPostUIDraw.Add(drawIndicator)
Events.OnGameStart.Add(onGameStart)

if Events.OnDisconnect then
    Events.OnDisconnect.Add(onDisconnect)
end

print("[ZbdCombatLock] 0.2.1 carregado")
