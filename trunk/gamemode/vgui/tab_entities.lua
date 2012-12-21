--[[
<xml>
	<module>
		<name>vgui_tab_entities</name>
		<instance>CLIENT</instance>
		<require>menu_loader</require>
	</module>
</xml>
]]

local ENTTAB = {}
ENTTAB.name = "Entities"
ENTTAB.icon = "icon16/cart.png"

local function MakeShipmentIcon( item, parent )
	local icon = vgui.Create( "NRP_SpawnIcon" ) -- SpawnIcon
	icon:SetSize( 128, 128 )
	icon:InvalidateLayout( true );
	icon:SetModel( item.model )
	icon:SetText( item.name )
	icon:AddButton( "Buy 1 for $"..(item.price * 1 ), function()
		LocalPlayer():ConCommand("say /buy "..item.id.." 1")
	end)
	icon:AddButton( "Buy 5 for $"..(item.price * 5 ), function()
		LocalPlayer():ConCommand("say /buy "..item.id.." 5")
	end)
	icon:AddButton( "Buy 10 for $"..(item.price * 10 ), function()
		LocalPlayer():ConCommand("say /buy "..item.id.." 10")
	end)
	return icon
end

ENTTAB.make = function( panel )
	
end
ENTTAB.update = function( panel )
	panel:Clear()
	
	local w, h = panel:GetWide(), panel:GetTall()
	-- the list that the entities will be shown in.
	local dlist = vgui.Create( "DPanelList", panel )
	dlist:SetPos( 5, 5 )
	dlist:SetSize( w - 10, h - 10)
	dlist:SetSpacing( 5 )
	dlist:EnableHorizontal( false )
	dlist:EnableVerticalScrollbar( true )
	
	local categories = {} -- table of the VGUI categories for shipments.
	for k,v in pairs( NRP.shipments )do
		local canbuy = hook.Call("NeoRP_CanBuyShipment",GAMEMODE, LocalPlayer(), v, '' )
		if( canbuy == true or canbuy == nil )then
			if( not categories[ v.category or '' ] )then
				print("Creating category panel. "..( v.category or 'default' ) )
				local cat = vgui.Create("DPanelList", dlist )
				cat:SetTall( 128 )
				cat:EnableHorizontal( true )
				categories[ v.category or '' ] = cat
				dlist:AddItem( cat )
			end
		end
	end
	for k,v in pairs( NRP.shipments )do
		local canbuy = hook.Call("NeoRP_CanBuyShipment",GAMEMODE, LocalPlayer(), v, '' )
		if( canbuy == true or canbuy == nil )then
			local icon = MakeShipmentIcon( v, categories[ v.category or '' ] )
			categories[ v.category or '' ]:AddItem( icon )
		end
	end
end

NRP.AddMenuTab( ENTTAB )