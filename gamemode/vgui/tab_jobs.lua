--[[
<xml>
	<module>
		<name>vgui_tab_jobs</name>
		<instance>CLIENT</instance>
		<require>menu_loader</require>
	</module>
</xml>
]]

local JOBTAB = {}
JOBTAB.name = "Jobs"
JOBTAB.icon = "icon16/user_red.png"

local drawFill = function( panel ) -- custom look for the Property Sheet Tabs.
	surface.SetDrawColor( panel.fillColor or Color( 255, 255, 255 ) )
	local x,y = panel:GetPos()
	local w, h = panel:GetSize()
	surface.DrawRect( 0, 0, w, h )
end


JOBTAB.make = function( panel )
	local w, h = panel:GetWide(), panel:GetTall()
	print( w .. ', '..  h )
	local dlist = vgui.Create( "DPanelList", panel )
	dlist:SetPos( 5, 5 )
	dlist:SetSize( w / 2 - 3, h - 10)
	dlist:SetSpacing( 5 )
	dlist:EnableHorizontal( false )
	dlist:EnableVerticalScrollbar( true )
	panel.dlist = dlist
	
	local teams = NRP.GetAllTeams()
	local vteams = {} -- table of team VGUI panels.
	
	for k,v in pairs( teams )do
		local p = vgui.Create( "DPanel", panel )
		--p.fillColor = Color( 155, 155, 155 )
		--p.Paint = drawFill
		dlist:AddItem( p )
		table.insert( vteams, p )
	end
	
	panel.vteams = vteams
end
JOBTAB.update = function( panel )
	
end
NRP.AddMenuTab( JOBTAB )