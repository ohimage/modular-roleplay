NRP = {} -- global table for gamemode variables.
DeriveGamemode("sandbox")

-- Checking if counterstrike is installed correctly
if table.Count(file.Find("*", "cstrike")) == 0 then
	timer.Create("TheresNoCSS", 10, 0, function()
		for k,v in pairs(player.GetAll()) do
			v:ChatPrint("CSS isn't installed correctly! You need it for "..GM.Name.." to work correctly.")
			print("Counter Strike: Source is incorrectly installed!\nYou need it for DarkRP to work!")
		end
	end)
end

/*================
ADD CS LUA FILES
================*/

AddCSLuaFile("shared.lua")
AddCSLuaFile("config.lua")
AddCSLuaFile("loader_cl.lua")
AddCSLuaFile("loader_sh.lua")
AddCSLuaFile("cl_fonts.lua")

/*================
INCLUDE FILES
================*/
include("shared.lua") -- load shared.lua first. Only extreamly general global functions should go there.
include("loader_sh.lua")
include("loader_sv.lua")

/*===============
RESOURCES
===============*/
resource.AddSingleFile( "materials/neorp/neorp_gwen.png")