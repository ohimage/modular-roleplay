MORP = {} -- global table for gamemode variables.

-- Checking if counterstrike is installed correctly
if table.Count(file.Find("*", "cstrike")) == 0 then
	timer.Create("TheresNoCSS", 10, 0, function()
		chat.AddText(Color(255,0,0),"CSS isn't installed correctly! You need it for "..GM.Name.." to work correctly.")
		print("Counter Strike: Source is incorrectly installed!\nYou need it for DarkRP to work!")
	end)
end

include("shared.lua") -- load shared.lua first. Only extreamly general global functions should go there.
include("module_loader.lua")