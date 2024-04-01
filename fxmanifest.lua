fx_version 'cerulean'

Description 'ac-yacht-heist created by nowiex'

author 'nw | nowiex | Developer @ AquaCity'

game 'gta5'

ui_page "web/index.html"

dependency {
	'oxmysql',
	'ox_inventory',
	'es_extended',
	'bob74_ipl',
}

shared_script {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
	'shared/config.lua',
}

client_script {
	'client/client.lua',
	'shared/scenes.lua',
	'client/prop_tables.lua'
}

server_script {
	'@oxmysql/lib/MySQL.lua',
	'server/server.lua',
}

files {
	"web/index.html",
	"web/script.js",
}

lua54 'yes'