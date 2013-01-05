--[[
<xml>
	<module>
		<name>vgui_tab_entities</name>
		<instance>CLIENT</instance>
		<require>menu_loader,vgui_tab_jobs</require>
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
	icon:SetTitle( item.name )
	if( item.isEntity )then
		icon:AddButton( "Buy for $"..(item.price * 1 ), function()
			LocalPlayer():ConCommand("say /buy "..item.id.." 1")
		end)
	else
		for k,v in SortedPairs( item.amounts )do
			icon:AddButton( "Buy "..k.." for $"..(item.price * k * v ), function()
				LocalPlayer():ConCommand("say /buy "..item.id.." "..k)
			end)
		end
	end
	return icon
end

ENTTAB.make = function( panel )
	
end
surface.CreateFont( "NRP_CatTitle",
	{
		font      = "roboto",
		size      = 18,
		weight    = 100
	}
 )

local function PaintCatTitle( self )
	local title = self.title
	if( not title )then return end
	draw.SimpleText( title, "NRP_CatTitle", 0, 0, Color(0, 0, 0), TEXT_ALIGN_LEFT)
end

ENTTAB.update = function( panel )
	print("Updateing Entity List!")
	panel:Clear()
	
	local w, h = panel:GetWide(), panel:GetTall()
	-- the list that the entities will be shown in.
	local dlist = vgui.Create( "DPanelList", panel )
	dlist:SetPos( 5, 5 )
	dlist:SetSize( w - 10, h - 30)
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
				cat.title = v.category
				cat.Paint = PaintCatTitle
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
