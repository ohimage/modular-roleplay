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
NRP.color.white = Color(255,255,255,255)

/*==========================
| MODULE SPECIFIC SETTINGS |
==========================*/

-- MENU SETTINGS
cfg.menu_widthRatio = 0.8
cfg.menu_heightRatio = 0.8
cfg.MenuKey = 'F4' -- Can be F1, F2, F3, F4

-- DOOR SETTINGS
cfg.DoorPrice = 50
cfg.DoorSellReturn = 35
cfg.CanEditDoors = function( ply )
	return ply:IsSuperAdmin()
end

-- JAIL SYSTEM
cfg.JailTimer = 120
cfg.CanSetJailPos = function( ply ) -- this makes it so only CP can set the jail position.
	if( ply:IsSuperAdmin() )then return true end
	if( not ply:TeamTbl() or ply:TeamTbl().CanSetJail ~= true )then
		NRP.Notice( ply, 5, "You do not have permission to set the jail.")
		return false
	end
	return true
end

-- TEAM SETTINGS
cfg.PayDayTimer = 120
cfg.DefaultWeapons = {
	'weapon_physgun',
	'weapon_physcannon',
	'gmod_tool',
	'nrp_keys'
	}
cfg.RunSpeed = 350
cfg.WalkSpeed = 250
cfg.StrictModels = true
cfg.RequireRespawn = true

-- SHOP SETTINGS
cfg.ShipmentSpawnTime = 3 -- set this to false to disable.
cfg.WeaponSpawnTime = 3 -- set this to false to disable.

-- ECONOMY
cfg.StartingBalance = 750

-- CHAT
cfg.BlockedCommands = {} -- add a command here to disable it. EX: { 'ooc', '/', 'oc' } will disable OCC chat.
cfg.ChatRadious = 250

-- ANTI MINGE
cfg.CanGiveSWEP = function( ply ) return ply:IsNRPDeveloper() end
cfg.CanSpawnSENT = function( ply ) return ply:IsNRPDeveloper() end
cfg.CanSpawnNPC = function( ply ) return ply:IsNRPDeveloper() end

-- Data Manager - CHANGING THEASE VALUES MAY BREAK STUFF AND IS NOT ADVISED
cfg.TablePrefix = 'NeoRP_'