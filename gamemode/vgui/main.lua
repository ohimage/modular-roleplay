--[[
<xml>
	<module>
		<name>mainmenu</name>
		<author>TheLastPenguin</author>
		<desc>Client side sexyness</desc>
		<instance>CLIENT</instance>
	</module>
</xml>
]]
local w = 0
local h = 0
local menu = nil
local function ClientMenu()
	w, h = ScrW(), ScrH() 
	if( not menu or not ValidPanel( menu ) )then
		print("Making a new menu.")
		menu = vgui.Create("NRP_Frame")
		menu:SetSize( w / 2, h / 2 )
		menu:SetPos( w / 4, h / 4 )
		menu:SetDeleteOnClose( false )
		menu.OnClose = function( panel )
			menu:SetVisible( true )
			print("Menu close!")
			menu:MoveTo( w / 4, h, 0.5, 0, 1, nil )
			timer.Simple(0.5,function()
				menu:SetVisible( false )
			end)
			return true
		end
		menu:SetVisible( false )
	end
	if( ValidPanel( menu ) )then
		if( menu:IsVisible()) then
			menu.OnClose( menu )
			return
		end
		print("Showing menu!")
		menu:MoveTo( w / 4, h / 4, 0.5, 0, 1, nil )
		menu:SetVisible( true )
		menu:MakePopup()
	end
end
concommand.Add("NeoRP_OpenMenu",function()
	ClientMenu()
end)