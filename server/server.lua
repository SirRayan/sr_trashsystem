local dependencies = {
    { 'ox_lib', '3.19.0' },
    { 'ox_inventory', '2.34.3' },
    { 'ox_target', '1.6.5' },
}

for i = 1, #dependencies do
    local ok, err = lib.checkDependency(dependencies[i][1], dependencies[i][2])
    if not ok then return print(err) end
end

lib.versionCheck('SirRayan/sr_trashsystem')

local config = require 'config'

local COOLDOWN_MS <const> = 1000

local allowedModels = {}
for i = 1, #config.models do
    local model = config.models[i]
    allowedModels[(tonumber(model) or joaat(model)) & 0xFFFFFFFF] = true
end

local cooldowns = {}

---@type table<string, number> stashId -> owner
local trashes = {}
---@type table<number, string> owner -> stashId
local playerTrash = {}
local openingStash

local function removeTrash(src)
    local stashId = playerTrash[src]
    if not stashId then return end

    playerTrash[src] = nil
    trashes[stashId] = nil
    exports.ox_inventory:RemoveInventory(stashId)
end

local function getTrashCoords(target)
    local targetType = type(target)

    if targetType == 'number' then
        local entity = NetworkGetEntityFromNetworkId(target)
        if entity == 0 or not DoesEntityExist(entity) then return end
        if not allowedModels[GetEntityModel(entity) & 0xFFFFFFFF] then return end
        return GetEntityCoords(entity)
    end

    if targetType == 'vector3' then
        return target
    end
end

RegisterNetEvent('sr_trashsystem:server:openTrash', function(target)
    local src = source

    local now = GetGameTimer()
    if cooldowns[src] and now - cooldowns[src] < COOLDOWN_MS then return end
    cooldowns[src] = now

    local ped = GetPlayerPed(src)
    if ped == 0 or not DoesEntityExist(ped) then return end

    local trashCoords = getTrashCoords(target)
    if not trashCoords then return end

    if #(GetEntityCoords(ped) - trashCoords) > config.maxDistance then return end

    removeTrash(src)

    local stashId = exports.ox_inventory:CreateTemporaryStash({
        label = locale('stash.label'),
        slots = config.stash.slots,
        maxWeight = config.stash.maxWeight,
    })
    if not stashId then return end

    trashes[stashId] = src
    playerTrash[src] = stashId

    openingStash = stashId
    local opened = exports.ox_inventory:forceOpenInventory(src, 'stash', stashId)
    openingStash = nil

    if not opened then removeTrash(src) end
end)

-- Only the forceOpenInventory call above may open a trash stash
exports.ox_inventory:registerHook('openInventory', function(payload)
    if trashes[payload.inventoryId] and payload.inventoryId ~= openingStash then return false end
end, { inventoryFilter = { '^temp%-' } })

AddEventHandler('ox_inventory:closedInventory', function(playerId, inventoryId)
    if inventoryId and trashes[inventoryId] == playerId then
        removeTrash(playerId)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    cooldowns[src] = nil
    removeTrash(src)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end

    for stashId in pairs(trashes) do
        exports.ox_inventory:RemoveInventory(stashId)
    end
end)
