fx_version 'cerulean'

Description 'ac-yacht-heist created by nowiex'

author 'nw | nowiex'

game 'gta5'

dependency {
	'oxmysql',
	'ox_inventory',
	'es_extended'
}

shared_script {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
	'shared/config.lua',
}

client_script {
	'client/client.lua',
	'shared/scenes.lua',
}

server_script {
	'@oxmysql/lib/MySQL.lua',
	'server/server.lua',
}

lua54 'yes'