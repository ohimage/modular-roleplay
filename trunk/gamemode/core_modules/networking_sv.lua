--[[
<xml>
	<module>
		<name>networking</name>
		<author>TheLastPenguin</author>
		<desc>Networked data libraries</desc>
		<instance>SERVER</instance>
		<require>sv_data</require>
	</module>
</xml>
]]
/*=================================
NETWORKING DATA
=================================*/
util.AddNetworkString('NRP_NWPlayerValue')
function SendValueUpdate( targ, ply, key, value )
	net.Start( "NRP_NWPlayerValue" )
		net.WriteEntity( ply )
		-- send the key.
		if( type( key ) == 'string' )then
			net.WriteInt( 1, 4 )
			net.WriteString( key )
		elseif( type( key ) == 'number')then
			net.WriteInt( 2, 4 )
			net.WriteInt( key, 4 )
		else
			return
		end
		
		-- send the value.
		if( type( value ) == 'string' )then
			net.WriteInt( 1, 4 )
			net.WriteString( value )
		elseif( type( value ) == 'number')then
			net.WriteInt( 2, 4 )
			net.WriteDouble( value )
		else
			return
		end
	net.Send( targ )
end

/*==================================================
META TABLES TO LET US DETECT CHANGES IN TABLES
==================================================*/
local INDEX = function( self, index)
		local data = rawget( self, 'data' )
		return data[ index ]
	end
local NEWINDEX = function( self, key, value )
		local data = rawget( self, 'data' )
		data[ key ] = value
		print("SENDING NETVALUE "..key.." == "..value )
		SendValueUpdate( player.GetAll(), self.Entity, key, value )
	end
/*=====================================
SETTUP THE DATA TABLE FOR EVERY PLAYER
AND SEND THEM VALUES FROM OTHER PLAYERS
======================================*/

function DelayedInitialSpawn( ply )
	local data = {}
	data.Entity = ply
	data.money = ply.SQLDATA.money
	
	ply.NETDATA = {}
	ply.NETDATA.data = data
	
	ply.NETDATA.__index = INDEX
	ply.NETDATA.__newindex = NEWINDEX
	setmetatable( ply.NETDATA, ply.NETDATA )
	for k,v in pairs( player.GetAll() )do
		if( v.NETDATA )then
			for i, j in pairs( rawget( v.NETDATA, 'data' ) )do
				SendValueUpdate( ply, v, i, j )
			end
		end
	end
end
function GM:PlayerInitialSpawn( ply )
	timer.Simple(1,function() DelayedInitialSpawn( ply ) end )
end