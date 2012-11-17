--[[
  _   _            _____  _____  
 | \ | |          |  __ \|  __ \ 
 |  \| | ___  ___ | |__) | |__) |
 | . ` |/ _ \/ _ \|  _  /|  ___/ 
 | |\  |  __/ (_) | | \ \| |     
 |_| \_|\___|\___/|_|  \_\_|  
 
    _____             __ _       
  / ____|           / _(_)      
 | |     ___  _ __ | |_ _  __ _ 
 | |    / _ \| '_ \|  _| |/ _` |
 | |___| (_) | | | | | | | (_| |
  \_____\___/|_| |_|_| |_|\__, |
                           __/ |
                          |___/ 
]]

local cfg = {}
NRP.cfg = cfg

-- colors
NRP.color = {}
NRP.color.red = Color(255,0,0)
NRP.color.orange = Color(255,155,0)
NRP.color.yellow = Color(255,255,0)
NRP.color.green = Color(0,255,0)
NRP.color.lightgreen = Color(255,100,100)
NRP.color.blue = Color(0,0,255)
NRP.color.cyan = Color(0,255,255)
NRP.color.black = Color(0,0,0)
NRP.color.grey = Color(155,155,155)
NRP.color.white = Color(255,255,255)

/*==========================
| MODULE SPECIFIC SETTINGS |
==========================*/

-- LANGUAGE SETTINGS
cfg.Curency = '$'

-- TEAM SETTINGS
cfg.DefaultWeapons = {
	'weapon_physgun',
	'weapon_gravgun',
	'gmod_tool'
	}
cfg.RunSpeed = 350
cfg.WalkSpeed = 250
cfg.StrictModels = true
cfg.RequireRespawn = true

-- ECONOMY
cfg.StartingBalance = 750

-- CHAT
cfg.BlockedCommands = {} -- add a command here to disable it. EX: { 'ooc', '/', 'oc' } will disable OCC chat.
cfg.ChatFilters = {
	['fuck'] = 'f***',
	['gay'] = 'happy',
	['bitch'] = 'b****',
	['hell'] = 'heaven'
}
-- Data Manager - CHANGING THEASE VALUES MAY BREAK STUFF AND IS NOT ADVISED
cfg.TablePrefix = 'NeoRP_'
cfg.ChatRadious = 400