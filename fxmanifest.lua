fx_version 'cerulean'
games {'gta5'}
author 'Ethereal'
description 'Ethereal Gang Scripts'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua', 
    '@es_extended/imports.lua' , 
}


client_scripts{
    -- Config --
    'config.lua',
    'client/cl_functions.lua',
    'client/npc.lua',
    'client/main.lua',
    'client/protection.lua'
}

server_scripts{
    -- Core --
    '@oxmysql/lib/MySQL.lua',

    -- Config --
    'config.lua',
    'server/sv_functions.lua',
    'server/main.lua'
}
