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
	{'price', nil },
	{'isEntity', false },
	{'amounts', {[5] = 1, [10] = 0.9, [25] = 0.8} }
}

NRP.AddCustomShipment = function( name, tbl )
	if( type( name ) == 'table' )then tbl = name end
	if( not tbl.name )then tbl.name = name end
	NRP.LoadMessage(NRP.color.white, "Loading Shipment ".. tbl.name )
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
 
NRP.AddCustomEntity = function( name, tbl )
	tbl.isEntity = true
	NRP.AddCustomShipment( name, tbl )
end

/*=====================================
BUYING SHIPMENTS
=====================================*/
if(SERVER)then
	local function DoPlayerEntitySpawn( player, entity_name, model, distance )
		local vStart = player:GetShootPos()
		local vForward = player:GetAimVector()

		local trace = {}
		trace.start = vStart
		trace.endpos = vStart + (vForward * ( distance or 2048 ))
		trace.filter = player
		
		local tr = util.TraceLine( trace )

		-- PrintTable( tr )

		-- Prevent spawning too close
		--if ( !tr.Hit || tr.Fraction < 0.05 ) then 
		--	return 
		--end
		local ent = ents.Create( entity_name )
		if ( !IsValid( ent ) ) then return end

		local ang = player:EyeAngles()
		ang.yaw = ang.yaw + 180 -- Rotate it 180 degrees in my favour
		ang.roll = 0
		ang.pitch = 0
		
		if (entity_name == "prop_ragdoll") then
			ang.pitch = -90
			tr.HitPos = tr.HitPos
		end
		if( model )then
			ent:SetModel( model )
		end
		ent:SetSkin( iSkin )
		ent:SetAngles( ang )
		ent:SetBodyGroups( strBody )
		ent:SetPos( tr.HitPos )

		-- Attempt to move the object so it sits flush
		-- We could do a TraceEntity instead of doing all 
		-- of this - but it feels off after the old way

		local vFlushPoint = tr.HitPos - ( tr.HitNormal * 512 )	-- Find a point that is definitely out of the object in the direction of the floor
			vFlushPoint = ent:NearestPoint( vFlushPoint )			-- Find the nearest point inside the object to that point
			vFlushPoint = ent:GetPos() - vFlushPoint				-- Get the difference
			vFlushPoint = tr.HitPos + vFlushPoint					-- Add it to our target pos
		return ent
	end
	
	NRP.AddChatCommand('buy', function(ply, arg)
		print("Did someone say buy?")
		local tbl = string.Explode( ' ', arg )
		if( not ( tbl[1] and tbl[2] ) )then
			NRP:Notice( ply, 4, 'Expected /Buy <id> <amount>', NOTIFY_ERROR )
			return
		end
		local id = tonumber( tbl[1] )
		local count = tonumber( tbl[2] ) or 1
		if( not id or not count or not shipments[ id ] )then
			NRP.Notice( ply, 4, 'Invalid item ID or Count Given.', NOTIFY_ERROR )
			return
		end
		local curShip = shipments[ id ]
		if( curShip.CanBuy )then
			local res, message = curShip.CanBuy( ply, arg )
			if( res == false )then
				if( message )then
					NRP.Notice( ply, 4, message, NOTIFY_ERROR )
				else
					NRP.Notice( ply, 4, "You can not buy this shipment.", NOTIFY_ERROR )
				end
				return
			end
		end
		if( curShip.isEntity == true )then
			if( count ~= 1 )then
				NRP.Notice( ply, 4, 'Item is an entity. Only buy 1 at a time.', NOTIFY_ERROR )
				return
			end
		elseif( not curShip.amounts[ count ] )then
			NRP.Notice( ply, 4, 'Invalid item quantity given.', NOTIFY_ERROR )
			return
		end
		local cost = curShip.price * count * ( curShip.amounts[ count ] or 1 )
		if( not ply:CanAfford( cost ) )then -- make sure the player can afford the price.
			NRP.Notice( ply, 4, 'You cant afford this shipment!', NOTIFY_ERROR )
			return
		end
		
		-- call hook to allow developers to modify the buy checks.
		local canbuy = hook.Call("NeoRP_CanBuyShipment",GAMEMODE, ply, curShip, arg )
		if( not( canbuy == true or canbuy == nil ) )then
			if( type( canbuy ) == 'string') then
				NRP.Notice( ply, 4, canbuy, NOTIFY_ERROR )
			else
				NRP.Notice( ply, 4, "You cant buy this shipment.", NOTIFY_ERROR )
			end
			return
		end
					
		ply:TakeMoney( cost )
		NRP.Notice( ply, 4, 'You bought a shipment of '.. curShip.name .. ' for '.. ( cost ) ) 
		
		if( curShip.isEntity )then -- allows for selling entities.
			local e = DoPlayerEntitySpawn( ply, curShip.class, nil, 100 )
			if( e.dt )then
				e.dt.owner = ply
				e.dt.owning_ent = ply
			end
			e:Spawn()
			e:Activate()
		else
			local e = DoPlayerEntitySpawn( ply, 'shipment', curShip.crate, 100 )
			e.dt.item = id
			e.dt.owner = ply
			e.dt.count = count
			e.spawnfunc = curShip.spawnfunc
			
			e:Spawn()
			e:Activate()
		end
	end)
elseif( CLIENT )then
	
end

hook.Add("NeoRP_CanBuyShipment","TeamCheck",function(ply, ship, arg)
	if( ship.teams )then
		if( type( ship.teams ) == 'table' )then
			if( not table.HasValue( ship.teams, ply:Team() ) )then
				return "You arn't the right team to buy this!"
			end
			return true
		elseif( type( ship.teams ) == 'number' )then
			if( ship.teams ~= ply:Team() )then
				return "You arnt the right team to buy this!"
			end
		end
	end
end)