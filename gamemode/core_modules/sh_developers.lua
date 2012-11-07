--[[
<info>
<name>sh_developers</name>
<author>TheLastPenguin</author>
<desc>List of Gamemode Devs. Gives access to debug features.</desc>
<instance>SHARED</instance>
<require>table</require>
</info>
]]

local developers = {
	['2327752029'] = 'Project Leader and Head Coder',
	['3991656016'] = 'Content Developer and Coder'
}

local plymeta = FindMetaTable('Player')
function plymeta:IsMORPDeveloper( )
	local r = developers[ util.CRC(self:SteamID()) ]
	if( r )then
		return true, r
	else
		return false, nil
	end
end
if(SERVER)then
	function GM:PlayerInitialSpawn( ply )
		local isDev, role = ply:IsMORPDeveloper()
		if( isDev )then
			MORP:ChatMessage( player.GetAll(), MORP.color.cyan, 'MoRP ', MORP.color.orange, role, ', '..ply:Name(), MORP.color.cyan," joined the game. Make sure to thank him for helping make this incredible gamemode.")
		end
	end
end