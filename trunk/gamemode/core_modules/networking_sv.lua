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

function GM:PlayerReadyForData( ply )
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
<<<<<<< .mine

util.AddNetworkString("NRP_CanReceive")
util.AddNetworkString("NRP_IBeReady")
local function isDataReady( ply, count )
	if( ply.dataReady )then
		ply.dataReady = nil
		NRP.LoadMessage(NRP.color.white,"Player "..ply:Name().." is ready to receive data.")
		hook.Call("PlayerReadyForData",GAMEMODE, ply )
	else
		net.Start("NRP_CanReceive")
		net.Send( ply )
		timer.Simple( 1, function()
			isDataReady( ply, count + 1 )
		end)
	end
end

net.Receive( "NRP_IBeReady", function( length, ply )
	if( length > 10 )then
		ply:Kick("Error Net responce overflow.")
	end
	ply.dataReady = true
end)

=======

util.AddNetworkString("NRP_CanReceive")
util.AddNetworkString("NRP_IBeReady")
local function isDataReady( ply, count )
	if( ply.dataReady )then
		ply.dataReady = nil
		NRP.LoadMessage(NRP.color.white,"Player "..ply:Name().." is ready to receive data.")
		hook.Call("PlayerReadyForData",GAMEMODE, ply )
	elseif( count > 10 )then
		ply:Kick("Player did not receive data pack after 10 retries.")
	else
		net.Start("NRP_CanReceive")
		net.Send( ply )
		timer.Simple( 1, function()
			isDataReady( ply, count + 1 )
		end)
	end
end

net.Receive( "NRP_IBeReady", function( length, ply )
	if( length > 10 )then
		ply:Kick("Error Net responce overflow.")
	end
	ply.dataReady = true
end)

>>>>>>> .r25
function GM:PlayerInitialSpawn( ply )
	isDataReady( ply, 0 )
end