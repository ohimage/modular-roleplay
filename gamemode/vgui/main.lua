--[[
<xml>
	<module>
		<name>mainmenu</name>
		<author>TheLastPenguin</author>
		<desc>Menu system and some of it's serverside parts.</desc>
		<instance>SHARED</instance>
	</module>
</xml>
]]

if(CLIENT)then
	local function ClientMenu()
		NRP.OpenMainMenu()
	end
	concommand.Add("NRP_Menu",function( ply, cmd, args )
		ClientMenu()
	end)
end