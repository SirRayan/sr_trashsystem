local config = require 'config'

CreateThread(function()
    exports.ox_target:addModel(config.models, {
        {
            label = locale('target.label'),
            icon = 'fa-solid fa-trash',
            distance = 2.0,
            onSelect = function(data)
                local entity = data.entity
                local target = NetworkGetEntityIsNetworked(entity) and NetworkGetNetworkIdFromEntity(entity) or GetEntityCoords(entity)
                TriggerServerEvent('sr_trashsystem:server:openTrash', target)
            end
        }
    })
end)
