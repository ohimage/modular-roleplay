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
		if( not NRP.mainmenu or not ValidPanel( NRP.mainmenu ) )then
			NRP.MakeMainMenu()
		end
		if( ValidPanel( NRP.mainmenu ) )then
			if( NRP.mainmenu:IsVisible()) then
				NRP.mainmenu:OnClose( )
				return
			end
			print("Showing menu!")
			NRP.mainmenu:MoveTo( ScrW() / 4, ScrH() / 4, 0.5, 0, 1, nil )
			NRP.mainmenu:SetVisible( true )
			NRP.mainmenu:MakePopup()
		end
		NRP.UpdateMenuTabs( )
		hook.Call("NeoRP_MenuOpened",GAMEMODE, menu )
	end
	concommand.Add("NRP_Menu",function( ply, cmd, args )
		ClientMenu()
	end)
end