fx_version 'cerulean'
game 'gta5'

author 'm4teuszek'
description 'playtime'
version '1.0.0'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

server_only 'yes'

dependencies {
    'oxmysql'
}

escrow_ignore {
    'server/server.lua'
}