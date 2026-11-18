fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

author 'SirRayan'
name 'sr_trashsystem'
description 'Temporary trash bins that delete their items on close'
version '1.0.0'
repository 'https://github.com/SirRayan/sr_trashsystem'

dependencies { '/onesync', 'ox_lib', 'ox_inventory', 'ox_target' }

shared_scripts { '@ox_lib/init.lua', 'init.lua' }
client_scripts { 'client/client.lua' }
server_scripts { 'server/server.lua' }
files { 'config.lua', 'locales/*.json' }
