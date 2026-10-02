-- Keep the namespace stable across Lua reloads and avoid polluting globals with
-- individual functions. ZCL_Main.lua consumes the public functions below.
ZbdCombatLock = ZbdCombatLock or {}

local ZCL = ZbdCombatLock

-- Runtime-only state. Nothing in this table is written to the save or sent to
-- the server.
ZCL.State = ZCL.State or {
    -- Mirrors the native force-aim flag and controls the on-screen indicator.
    enabled = false,
    -- Retained so the native aim state can be cleared during disconnection.
    lastPlayer = nil,
    -- Recorded for diagnostics only; the mod never writes options.ini.
    previousToggleToAim = nil,
    -- Prevents unnecessary attempts to enable the native toggle every frame.
    ownsNativeToggle = false,
    -- Suppresses duplicate log messages if the same failure repeats.
    lastError = nil,
}

-- Report a runtime compatibility problem once instead of flooding console.txt.
local function reportError(message)
    if ZCL.State.lastError == message then return end
    ZCL.State.lastError = message
    print("[ZbdCombatLock] " .. message)
end

-- Enable Project Zomboid's native toggle-to-aim behavior. This is called while
-- client Lua is loading so CharacterInputComponent sees the option before the
-- local IsoPlayer is created. The setting is changed in memory only.
function ZCL.startSession()
    -- Build 42 minor releases may change exposed methods. Keep API calls inside
    -- pcall so a compatibility issue disables the feature without breaking the
    -- rest of the game's Lua update loop.
    local ok, result = pcall(function()
        local core = getCore()
        if not core then return false end

        -- Capture the user's original value once for diagnostics. Repeated
        -- calls must not replace it with the temporary value set by the mod.
        if ZCL.State.previousToggleToAim == nil then
            ZCL.State.previousToggleToAim = core:isToggleToAim()
        end
        core:setToggleToAim(true)
        return core:isToggleToAim()
    end)

    if not ok or result ~= true then
        reportError("nao foi possivel ativar a alternancia nativa de mira: " .. tostring(result))
        ZCL.State.ownsNativeToggle = false
        return false
    end

    ZCL.State.ownsNativeToggle = true
    ZCL.State.lastError = nil
    print("[ZbdCombatLock] alternancia nativa de mira habilitada para esta sessao")
    return true
end

-- Read the authoritative native state instead of maintaining a second toggle
-- in Lua. This keeps the indicator synchronized with the actual combat input.
function ZCL.syncFromPlayer(player)
    if not player then
        ZCL.State.enabled = false
        return false
    end

    local ok, forcedAim = pcall(function()
        return player:isForceAim()
    end)

    if not ok then
        ZCL.State.enabled = false
        reportError("nao foi possivel consultar isForceAim: " .. tostring(forcedAim))
        return false
    end

    ZCL.State.enabled = forcedAim == true
    ZCL.State.lastError = nil
    return true
end

-- Release any active aim state when the player dies or leaves the session.
-- The native toggle preference remains an in-memory option while the mod is
-- loaded; options.ini is not saved or modified here.
function ZCL.endSession(player)
    local target = player or ZCL.State.lastPlayer
    if target then
        pcall(function()
            target:setForceAim(false)
            target:setIsAiming(false)
        end)
    end

    ZCL.State.enabled = false
    ZCL.State.lastPlayer = nil
end
