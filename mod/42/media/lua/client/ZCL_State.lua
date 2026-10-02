-- Zbd Combat Lock
-- Author: Cristian Privat - privat.tecnologia@gmail.com
-- Copyright (c) 2026 Cristian Privat
-- SPDX-License-Identifier: MIT
-- License: MIT; see LICENSE in the project source and distribution.

-- Keep the namespace stable across Lua reloads and avoid polluting globals with
-- individual functions. ZCL_Main.lua consumes the public functions below.
ZbdCombatLock = ZbdCombatLock or {}

local ZCL = ZbdCombatLock

-- Runtime-only state. Nothing in this table is written to the save or sent to
-- the server.
ZCL.State = ZCL.State or {}

-- Assign defaults individually so a Lua reload can upgrade a state table that
-- was created by an older version of the mod.
if ZCL.State.enabled == nil then ZCL.State.enabled = false end
if ZCL.State.featureEnabled == nil then ZCL.State.featureEnabled = true end
if ZCL.State.ownsNativeToggle == nil then ZCL.State.ownsNativeToggle = false end
if ZCL.State.keyBindingRegistered == nil then ZCL.State.keyBindingRegistered = false end
if ZCL.State.noticeUntil == nil then ZCL.State.noticeUntil = 0 end
if ZCL.State.noticeFrames == nil then ZCL.State.noticeFrames = 0 end

-- Report a runtime compatibility problem once instead of flooding console.txt.
local function reportError(message)
    if ZCL.State.lastError == message then return end
    ZCL.State.lastError = message
    print("[ZbdCombatLock] " .. message)
end

local function currentTimeMillis()
    if not getTimestampMs then return nil end

    local ok, value = pcall(getTimestampMs)
    if not ok or type(value) ~= "number" then return nil end
    return value
end

-- Keep transition feedback temporary so the HUD remains unobtrusive.
function ZCL.showNotice(message)
    ZCL.State.noticeText = message

    local now = currentTimeMillis()
    if now then
        ZCL.State.noticeUntil = now + 2500
        ZCL.State.noticeFrames = 0
    else
        -- Defensive fallback for a Build 42 release that does not expose the
        -- timestamp helper to Lua.
        ZCL.State.noticeUntil = 0
        ZCL.State.noticeFrames = 150
    end
end

function ZCL.getNotice()
    if not ZCL.State.noticeText then return nil end

    local now = currentTimeMillis()
    if now then
        if now <= ZCL.State.noticeUntil then return ZCL.State.noticeText end
    elseif ZCL.State.noticeFrames > 0 then
        ZCL.State.noticeFrames = ZCL.State.noticeFrames - 1
        return ZCL.State.noticeText
    end

    ZCL.State.noticeText = nil
    ZCL.State.noticeUntil = 0
    ZCL.State.noticeFrames = 0
    return nil
end

-- Release only the active stance. This is separate from changing toggleToAim
-- so death, mode transitions and disconnection can use the same safe cleanup.
function ZCL.clearAim(player)
    local target = player or ZCL.State.lastPlayer
    if target then
        pcall(function()
            target:setForceAim(false)
            target:setIsAiming(false)
        end)
    end

    ZCL.State.enabled = false
end

local function setNativeToggle(enabled)
    local ok, result = pcall(function()
        local core = getCore()
        if not core then return false end

        -- Capture the user's original value once. False is a valid value, so
        -- nil specifically means it has not been captured yet.
        if ZCL.State.previousToggleToAim == nil then
            ZCL.State.previousToggleToAim = core:isToggleToAim()
        end

        core:setToggleToAim(enabled)
        return core:isToggleToAim() == enabled
    end)

    if not ok or result ~= true then
        reportError("nao foi possivel alterar a alternancia nativa de mira para "
            .. tostring(enabled) .. ": " .. tostring(result))
        ZCL.State.ownsNativeToggle = false
        return false
    end

    ZCL.State.ownsNativeToggle = enabled
    ZCL.State.lastError = nil
    return true
end

-- Enable Project Zomboid's native toggle-to-aim behavior. This is called while
-- client Lua is loading so CharacterInputComponent sees the option before the
-- local IsoPlayer is created. The setting is changed in memory only.
function ZCL.startSession()
    if not ZCL.State.featureEnabled then return false end

    local changed = setNativeToggle(true)
    if changed then
        print("[ZbdCombatLock] alternancia nativa de mira habilitada para esta sessao")
    end
    return changed
end

function ZCL.enableFeature(player)
    ZCL.clearAim(player)
    ZCL.State.featureEnabled = true

    if not setNativeToggle(true) then
        ZCL.State.featureEnabled = false
        ZCL.showNotice("ZCL: FALHA AO HABILITAR")
        return false
    end

    ZCL.showNotice("ZCL: HABILITADO")
    print("[ZbdCombatLock] funcionalidade habilitada")
    return true
end

function ZCL.disableFeature(player)
    ZCL.clearAim(player)
    ZCL.State.featureEnabled = false

    local changed = setNativeToggle(false)
    if changed then
        ZCL.showNotice("ZCL: DESATIVADO")
        print("[ZbdCombatLock] funcionalidade desativada; mira nativa exige tecla mantida")
    else
        ZCL.showNotice("ZCL: FALHA AO DESATIVAR")
    end
    return changed
end

function ZCL.toggleFeature(player)
    if ZCL.State.featureEnabled then
        return ZCL.disableFeature(player)
    end
    return ZCL.enableFeature(player)
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
    ZCL.clearAim(player)
    ZCL.State.lastPlayer = nil
end

-- Restore the option that was present before the mod took ownership. The value
-- remains in memory only; the mod never asks Core to save options.ini.
function ZCL.finishSession(player)
    ZCL.endSession(player)

    if ZCL.State.previousToggleToAim ~= nil then
        pcall(function()
            local core = getCore()
            if core then core:setToggleToAim(ZCL.State.previousToggleToAim) end
        end)
    end

    ZCL.State.previousToggleToAim = nil
    ZCL.State.ownsNativeToggle = false
    ZCL.State.featureEnabled = true
    ZCL.State.noticeText = nil
end
