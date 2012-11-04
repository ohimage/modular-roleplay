--[[
<info>
<name>notice</name>
<author>TheLastPenguin</author>
<desc>Provides notification functionality like chat text, and console printing.</desc>
<instance>SHARED</instance>
</info>
]]
 
if( SERVER )then
	function BuildNotice( ply, ... )
		local arg = { ... }
		if( not arg )then
			print("Notify: arg is nil. Return end")
			return
		end
		table.flaten( arg )
		if( not ply or ( not type( ply ) == "table" and player.IsConsole( ply ) ))then
			table.insert( arg, 1, "PAdmin: " )
			table.insert( arg, "\n" )
			MsgCTBL( unpack( arg ) )
			return
		end
		if( type( ply ) == "table" and #ply == #player.GetAll())then
			local arg = table.Copy( arg )
			table.insert( arg, 1, "PAdmin: " )
			table.insert( arg, "\n" )
			MsgCTBL( unpack( arg ) )
		end
		return arg
	end
	
	util.AddNetworkString( "PAdmin.ChatPrint" )
	-- both are the same, its just a matter of preference.
	function MORP:Notice( ply, ... )
		local tbl = BuildNotice( ply, ... )
		net.Start( "PAdmin.ChatPrint" )
		net.WriteTable( tbl )
		net.Send( ply )
	end
	function PAdmin:Notify( ply, ... )
		MORP:Notice( ply, ... )
	end
	function MORP:ConMessage( ply, ... )
		local tbl = BuildNotice( ply, ... )
		net.Start( "PAdmin.ConPrint" )
		net.WriteTable( tbl )
		net.Send( ply )
	end
	-- this is just for testing stuff.
	hook.Add("PlayerInitialSpawn","PAdmin.SpawnNotice",function( ply )
		MORP:Notice( player.GetAll(), {Color( 100, 100, 100 ),"Player "..ply:Nick().." spawned." } )
	end)
elseif( CLIENT )then
	-- chat brodcasts system.
	net.Receive( "PAdmin.ChatPrint", function( length )
		local tbl  = net.ReadTable()
		local lastCol = Color( 255, 255, 255, 255 )
		for k,v in pairs(tbl)do
			if( type( v ) == "Player" )then
				local ntbl = {team.GetColor(v:Team()),v:Name() }
				ntbl[#ntbl + 1 ] = lastCol
				tbl[ k ] = ntbl
			elseif( type( v ) == "table" and v.r and v.g and v.b and v.a )then
				lastCol = v
			end
		end
		table.flaten( tbl )
		chat.AddText( unpack( tbl ) )
	end )
	
	net.Receive( "PAdmin.ConPrint", function( length )
		local tbl  = net.ReadTable()
		local lastCol = Color( 255, 255, 255, 255 )
		for k,v in pairs(tbl)do
			if( type( v ) == "Player" )then
				local ntbl = {team.GetColor(v:Team() ),v:Name() }
				ntbl[#ntbl + 1 ] = lastCol
				tbl[ k ] = ntbl
			elseif( type( v ) == "table" and v.r and v.g and v.b and v.a )then
				lastCol = v
			end
		end
		table.flaten( tbl )
		MsgCTBL( unpack( tbl ) )
	end )
end