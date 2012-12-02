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

function NRP:AddMenuTab( tbl )
	NRP:LoadMessage(NRP.color.grey, "Adding Main Menu tab "..( tbl.name or "<unknown>") )
	table.insert( tabs, tbl )
end
function NRP:UpdateMenuTabs( )
	for k,v in pairs( tabs )do
		v.update( v.panel )
	end
end

function NRP:MakeMainMenu()
	local w = ScrW()
	local h = ScrH()
	/*=======================================
	MAKE THE MENU PANELS
	=======================================*/
	if( ValidPanel( NRP.mainmenu ))then
		NRP.mainmenu:Remove()
	end
	
	print("Making a new menu.")
	local menu = vgui.Create("NRP_Frame")
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
		panel:SetSize( 250, 250 )
		panel:StretchToParent()
		panel.Paint = customDraw
		panel.NRP = v
		-- VGUI tab shouldnt be needed for much but i figure we should keep a hold of it.
		v.vguitab = menu.propsheet:AddSheet( v.name, panel, v.icon or "gui/silkicons/user", 
				false, false, nil)
		PrintTable( sheet )
		-- Store the panel in the tab's table incase it's needed.
		v.panel = panel
		
		v.make( panel )
	end
	
	NRP.mainmenu = menu
end