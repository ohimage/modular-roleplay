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
local entities = {}

NRP.shipments = shipments
NRP.customEnts = entities

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
		if( not ply:CanAfford( cost ) )then -- make sure the player can afford the price.
			NRP:Notice( ply, 4, 'You cant afford this shipment!', NOTIFY_ERROR )
		end
		
		-- call hook to allow developers to modify the buy checks.
		local canbuy = hook.Call("NeoRP_CanBuyShipment",GAMEMODE, ply, curShip, arg )
		if( not( canbuy == true or canbuy == nil ) )then
			if( type( canbuy ) == 'string') then
				NRP:Notice( ply, 4, canbuy, NOTIFY_ERROR )
			else
				NRP:Notice( ply, 4, "You cant buy this shipment.", NOTIFY_ERROR )
			end
			return
		end
					
		
		ply:TakeMoney( cost )
		
		NRP:Notice( ply, 4, 'You bought a shipment of '.. curShip.name .. ' for '.. ( cost ) ) 
		
		
		local e = ents.Create("shipment")
		e:SetPos( ply:GetLimitedEyeTrace( 100 ).HitPos )
		e.dt.item = id
		e.dt.owner = ply
		e.dt.count = count
		e.spawnfunc = curShip.spawnfunc
		
		e:SetModel( curShip.crate )
		e:Spawn()
		e:Activate()
	end)
	
	hook.Add("NeoRP_CanBuyShipment","TeamCheck",function(ply, ship, arg)
		if( ship.teams )then
			if( type( ship.teams ) == 'table' )then
				if( not table.HasValue( ship.teams, ply:Team() ) )then
					return "You arn't the right team to buy this!"
				end
			elseif( type( ship.teams ) == 'number' )then
				if( ship.teams ~= ply:Team() )then
					return "You arnt the right team to buy this!"
				end
			end
		end
	end)
elseif( CLIENT )then
	
end
/*
 TEST SHIPMENT
*/
NRP:AddCustomShipment('HL2 Pistol',{
	model = 'models/weapons/w_pistol.mdl',
	class = 'weapon_pistol',
	price = 100
})

NRP:AddCustomShipment('HL2 SMG',{
	model = 'models/weapons/w_smg1.mdl',
	class = 'weapon_smg1',
	price = 100,
	teams = {TEAM_DEVELOPER}
})