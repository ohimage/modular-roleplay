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
elseif(SERVER)then
	print("Adding serverside menu bind.")
	local KeyToHook = {
		F1 = "ShowHelp",
		F2 = "ShowTeam",
		F3 = "ShowSpare1",
		F4 = "ShowSpare2",
		None = "ThisHookDoesNotExist"
	}
	hook.Add( KeyToHook[ NRP.cfg.MenuKey or "F4" ] or "ShowSpare2"  , "NRP_MenuOpen",function( ply )
		print("OPEN MENU!")
		ply:ConCommand( "NRP_Menu" )
		return true
	end)
end