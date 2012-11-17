--[[
<xml>
	<module>
		<name>sh_developers</name>
		<author>TheLastPenguin</author>
		<desc>List of Gamemode Devs. Gives access to debug features.</desc>
		<instance>SHARED</instance>
		<require>table</require>
	</module>
</xml>
]]

local developers = {
	['2327752029'] = 'NeoRP Project Leader and Head Coder',
	['3991656016'] = 'NeoRP Content Developer and Coder'
}

local plymeta = FindMetaTable('Player')
function plymeta:IsNRPDeveloper( )
	local r = developers[ util.CRC(self:SteamID()) ]
	if( r )then
		return true, r
	else
		return false, nil
	end
end
if(SERVER)then
	function GM:PlayerInitialSpawn( ply )
		local isDev, role = ply:IsNRPDeveloper()
		if( isDev )then
			NRP:ChatMessage( player.GetAll(), NRP.color.cyan, 'NRP ', NRP.color.orange, role, ', '..ply:Name(), NRP.color.cyan," joined the game. Make sure to thank him for helping make this incredible gamemode.")
		end
	end
end