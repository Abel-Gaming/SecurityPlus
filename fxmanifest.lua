fx_version 'cerulean'
game 'gta5'
description 'Security Plus - Become a security guard of LS!'
author 'Abel Gaming'
version '1.0'

server_scripts {
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'config.lua',
	'client/main.lua',
	'client/functions.lua',
	'client/menus.lua'
}

ui_page 'nui/index.html'
files { 
'nui/index.html', 
'nui/index.css', 
'nui/index.js'
}

dependencies {
    'nh-context', -- https://github.com/nerohiro/nh-context
    'nh-keyboard' -- https://github.com/nerohiro/nh-keyboard
}