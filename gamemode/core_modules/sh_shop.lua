--[[
<xml>
	<module>
		<name>sh_shop</name>
		<author>TheLastPenguin</author>
		<desc>Shop System. Buy Items you need</desc>
		<instance>SHARED</instance>
		<require>sh_teams,sh_economy,sv_data,sv_chat,sh_player</require>
	</module>
</xml>
]]

local shipments = {}
local ammoTypes = {}

NRP.shipments = shipments
NRP.ammoTypes = ammoTypes

/*===================================
List of required values on shipments:
 * name - the name of the shipments
 * model - the image of the item to be spawned.
 * class - the class name of the item to be spawned.
 * quantity - number of items in a shipment.
 * price - the amount it costs.
 * teams - the teams that can buy the shipment.
===================================*/
local shipReqVals = {
	{'name', nil },
	{'model', nil },
	{'crate', 'models/items/item_item_crate.mdl'},
	{'class', nil },
	{'price', nil }
}

function NRP:AddCustomShipment( name, tbl )
	if( type( name ) == 'table' )then tbl = name end
	if( not tbl.name )then tbl.name = name end
	NRP:LoadMessage(NRP.color.white, "Loading Shipment ".. tbl.name )
	for k,v in pairs( shipReqVals )do
		if( not tbl[ v[1] ] )then
			if( v[2] == nil )then
				NRP:MsgC( NRP.color.red, "SHIPMENT ERROR: MISSING REQUIRED PROPERTY "..v[1].. " IN TEAM "..name )
				ErrorNoHalt("Team Error.")
				return
			else
				NRP:MsgC( NRP.color.orange, "Set Property "..v[1].." to default "..tostring( v[2]))
				tbl[ v[1] ] = v[2] 
			end
		end
	end
	tbl.id = #shipments + 1
	shipments[ tbl.id ] = tbl
end

local ammoReqVals = {
	{'name', nil },
	{'iconmodel', nil },
	{'type', nil },
	{'quantity', 10 },
	{'price', nil }
}
function NRP:ShopAddAmmoType( name, tbl )
	if( type( name ) == 'table' )then tbl = name end
	if( not tbl.name )then tbl.name = name end
	NRP:LoadMessage(NRP.color.white, "Loading Ammo Type ".. tbl.name )
	for k,v in pairs( ammoReqVals )do
		if( not tbl[ v[1] ] )then
			if( v[2] == nil )then
				NRP:MsgC( NRP.color.red, "AMMO TYPE ERROR: MISSING REQUIRED PROPERTY "..v[1].. " IN TEAM "..name )
				ErrorNoHalt("Team Error.")
				return
			else
				NRP:MsgC( NRP.color.orange, "Set Property "..v[1].." to default "..tostring( v[2]))
				tbl[ v[1] ] = v[2] 
			end
		end
	end
	tbl.id = #ammoTypes + 1
	ammoTypes[ tbl.id ] = tbl
end

/*=====================================
BUYING SHIPMENTS
=====================================*/
if(SERVER)then
	NRP:AddChatCommand( 'buy', function(ply, arg)
		print("Did someone say buy?")
		local tbl = string.Explode( ' ', arg )
		if( not ( tbl[1] and tbl[2] ) )then
			NRP:Notice( ply, 4, 'Expected /Buy <id> <amount>', NOTIFY_ERROR )
			return
		end
		local id = tonumber( tbl[1] )
		local count = tonumber( tbl[2] )
		if( not id or not count or not shipments[ id ] )then
			NRP:Notice( ply, 4, 'Invalid item ID or Count Given.', NOTIFY_ERROR )
			return
		end
		local curShip = shipments[ id ]
		local cost = curShip.price * count
		if( not ply:CanAfford( cost ) )then
			NRP:Notice( ply, 4, 'You cant afford this shipment!', NOTIFY_ERROR )
		end
		
		NRP:Notice( ply, 4, 'You bought a shipment of '.. curShip.name .. ' for '.. ( cost ) ) 
		
		local e = ents.Create("shipment")
		e:SetPos( ply:GetEyeTrace().HitPos)
		e.dt.item = id
		e.dt.owner = ply
		e.dt.count = count
		e.spawnfunc = curShip.spawnfunc
		
		e:SetModel( curShip.crate )
		e:Spawn()
		e:Activate()
	end)
elseif( CLIENT )then
	
end
/*
 TEST SHIPMENT
*/
NRP:AddCustomShipment('Saw Blades',{
	model = 'models/props_junk/sawblade001a.mdl',
	class = 'weapon_pistol',
	price = 100
})

NRP:AddCustomShipment('Heli Bombs',{
	model = 'models/Combine_Helicopter/helicopter_bomb01.mdl',
	class = 'weapon_smg1',
	price = 100
})