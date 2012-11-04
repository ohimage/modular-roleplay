MORP = {} -- global table for gamemode variables.
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

AddCSLuaFile("shared.lua")
AddCSLuaFile("config.lua")
AddCSLuaFile("module_loader.lua")

include("shared.lua") -- load shared.lua first. Only extreamly general global functions should go there.
include("module_loader.lua")

function GM:PlayerInitialSpawn( ply )
	self.BaseClass:PlayerInitialSpawn( ply )
end

function GM:PlayerLoadout( ply )
	self.BaseClass:PlayerLoadout( ply )
end