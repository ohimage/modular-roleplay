NRP = {} -- global table for gamemode variables.
DeriveGamemode("sandbox")

-- Checking if counterstrike is installed correctly
if table.Count(file.Find("*", "cstrike")) == 0 then
	timer.Create("TheresNoCSS", 10, 0, function()
		chat.AddText(Color(255,0,0),"CSS isn't installed correctly! You need it for "..GM.Name.." to work correctly.")
		print("Counter Strike: Source is incorrectly installed!\nYou need it for "..GM.Name.." to work!")
	end)
end

/*================
INCLUDE FILES
================*/
include("shared.lua") -- load shared.lua first. Only extreamly general global functions should go there.
include("cl_fonts.lua")
include("loader_sh.lua")
include("loader_cl.lua")