local config = require 'config'

local function getLocale()
    if config.language and config.language ~= '' then return config.language end

    local oxLocale = GetConvar('ox:locale', '')
    return oxLocale ~= '' and oxLocale or 'en'
end

lib.locale(getLocale())
