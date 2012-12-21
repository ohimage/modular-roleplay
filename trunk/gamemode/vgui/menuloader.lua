--[[
<xml>
	<module>
		<name>menu_loader</name>
		<author>TheLastPenguin</author>
		<desc>Creates the MENU VGUI</desc>
		<instance>CLIENT</instance>
	</module>
</xml>
]]

local tabs = {}

NRP.AddMenuTab = function( tbl )
	NRP.LoadMessage(NRP.color.grey, "Adding Main Menu tab "..( tbl.name or "<unknown>") )
	table.insert( tabs, tbl )
end
NRP.UpdateMenuTabs = function( )
	for k,v in pairs( tabs )do
		v.update( v.panel )
	end
end

local widthRatio = NRP.cfg.menu_widthRatio
local heightRatio = NRP.cfg.menu_heightRatio

NRP.OpenMainMenu = function()
	local w, h = ScrW(), ScrH()
	if( not NRP.mainmenu or not ValidPanel( NRP.mainmenu ) )then
		NRP.MakeMainMenu()
	end
	if( ValidPanel( NRP.mainmenu ) )then
		if( NRP.mainmenu:IsVisible()) then
			NRP.mainmenu:OnClose( )
			return
		end
		print("Showing menu!")
		NRP.mainmenu:MoveTo( w * (1 - widthRatio) / 2, h * (1 - heightRatio) / 2, 0.5, 0)
		NRP.mainmenu:SetVisible( true )
		NRP.mainmenu:MakePopup()
		NRP.UpdateMenuTabs( )
		hook.Call("NeoRP_MenuOpened",GAMEMODE, menu )
	else
		chat.AddText(Color(255,0,0),"ERROR! FAILED TO OPEN MENU! CONTACT A NeoRP DEVELOPER!")
	end
end

NRP.MakeMainMenu = function()
	local w, h = ScrW(), ScrH()
	/*=======================================
	MAKE THE MENU PANELS
	=======================================*/
	if( ValidPanel( NRP.mainmenu ))then
		NRP.mainmenu:Remove()
	end
	
	print("Making a new menu.")
	local menu = vgui.Create("NRP_Frame")
	menu:SetSize( w * 0.8, h * 0.8)
	menu:SetPos( w * (1 - widthRatio) / 2, h, 0.5, 0, 1, nil )
	menu:SetDeleteOnClose( false )
	menu:SetDraggable( false )
	menu.OnClose = function( panel )
		menu:SetVisible( true )
		print("Menu close!")
		menu:MoveTo( w * (1 - widthRatio) / 2, h, 0.5, 0, 1, nil )
		timer.Simple(0.5,function()
			menu:SetVisible( false )
		end)
		hook.Call("NRP_MainMenuClosed",GAMEMODE, menu )
		return true
	end
	menu.Paint = function() end
	menu:SetTitle("")
	menu:SetVisible( false )

	/*=========================
	ADD THE TAB SET
	=========================*/
	local propsheet = vgui.Create( "DPropertySheet", menu )
	propsheet:SetPos( 5, 30 )
	propsheet:SetSize( menu:GetWide() - 10, menu:GetTall() - 35 )

	menu.propsheet = propsheet

	/*====================================
	TAB SYSTEM
	====================================*/
	local customDraw = function( panel ) -- custom look for the Property Sheet Tabs.
		surface.SetDrawColor( Color( 255, 255, 255 ) )
		local x,y = panel:GetPos()
		local w, h = panel:GetSize()
		surface.DrawOutlinedRect( 0, 0, w, h )
	end
	
	-- DRAW THE TABS.
	for k,v in pairs( tabs )do
		-- CREATE THE PANEL FOR THE TAB.
		local panel = vgui.Create( "DPanel", menu.propsheet )
		panel:SetPos( 5, 5 )
		panel:SetSize( menu.propsheet:GetWide() - 10, menu.propsheet:GetTall() - 10 )
		panel:StretchToParent()
		panel.Paint = customDraw
		panel.NRP = v
		-- VGUI tab shouldnt be needed for much but i figure we should keep a hold of it.
		v.vguitab = menu.propsheet:AddSheet( v.name, panel, v.icon or "gui/silkicons/user", 
				false, false, nil)
		-- Store the panel in the tab's table incase it's needed.
		v.panel = panel
		
		v.make( panel )
	end
	
	NRP.mainmenu = menu
end