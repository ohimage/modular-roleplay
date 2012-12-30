GM.Version = "1.0.0 Beta"
GM.Name = "NeoRP"
GM.Author = "By TheLastPenguin"

include("config.lua")

local instanceColor -- used in MsgCTBL to show if a message is being printed by clientside or server.
if( SERVER )then
	instanceColor = Color( 255, 155, 0 ) -- orange for server.
else
	instanceColor = Color( 0, 255, 255 ) -- cyan for clients.
end

/*====================================
LIBRARY FUNCTIONS NEEDED BY SHARED.lua
====================================*/
table.flaten = function( tbl )
	for k,v in pairs( tbl )do
		if( type( v ) == "table" and not ( v.r and v.g and v.b and v.a ) )then
			local nested = v
			-- clear value of current tbl at k
			tbl[ k ] = nil
			table.flaten( nested )
			local c = 0
			for j,l in pairs( nested )do
				if( type( j ) == "number" )then
					-- insert new values into old position
					table.insert( tbl,k + c, l )
					c = c + 1
				else
					tbl[ j ] = l
				end
			end
		end
	end
end

/*===========================
CONSOLE PRINTING STUFF MOSTLY
===========================*/
local MsgCOLD = MsgC
function MsgC( ... )
	local arg = {...}
	local color = Color( 255, 255, 255 )
	for k,v in SortedPairs( arg )do
		if( type( v ) == 'table' and v.r and v.g and v.b and v.a )then
			color = v
		else
			if( type( v ) == 'number' )then
				MsgCOLD(color,tostring( v ) )
			elseif( type( v ) == 'Player' )then
				MsgCOLD( team.GetColor( v:Team() ), v:Name() )
			elseif( type( v ) == 'Entity' )then
				MsgCOLD( color, v:GetClass())
			else
				MsgCOLD( color, tostring( v ) )
			end
		end
	end
end

NRP.MsgC = function( ... )
	MsgC( instanceColor, '[NeoRP] ', ..., '\n')
end

if( not file.IsDir("NeoRP", 'LUA' ) )then
	file.CreateDir("NeoRP" )
end
if(SERVER)then
	file.Write("NeoRP/sv_debuglog.txt", "INITALISED SERVER DEBUG LOGGING\n" )
else
	file.Write("NeoRP/cl_debuglog.txt", "INITALISED CLIENT DEBUG LOGGING\n" )
end

NRP.DebugMsgRAW = function( ... )
	MsgC( ... )
	local msg = {...}
	table.flaten( msg )
	for k,v in pairs( msg )do
		if( v == nil )then
			table.remove( msg, v )
		elseif( type( v ) ~= 'string' )then
			table.remove( msg, k )
		end
	end
	if( not msg[1] )then return end
	local str = table.concat( msg, '')
	if( SERVER )then
		file.Append("NeoRP/sv_debuglog.txt", str )
	else
		file.Append("NeoRP/cl_debuglog.txt", str )
	end
end

NRP.DebugMsg = function( ... )
	NRP.DebugMsgRAW( instanceColor, '[NeoRP Debug]', ... )
end

/*=========================
SMEXY LOOKING LOAD MESSAGES
=========================*/
local lastbig = 0
local function LoadMessage( ... )
	local msg = {...}
	local msgLen = 0
	for k,v in pairs( msg )do
		if( type( v ) == 'string' )then
			msgLen = msgLen + string.len( v )
		end
	end
	if( msgLen <= 1 )then return end
	NRP.DebugMsgRAW(instanceColor,'| ')
	NRP.DebugMsgRAW(...)
	NRP.DebugMsgRAW(string.format('%'..math.max(76 - msgLen,1)..'s', ''),instanceColor,' |\n' )
end

NRP.LoadMessage = function(...)
	lastbig = 0
	LoadMessage( ... )
end

NRP.LoadMessageBig = function( ... )
	local msg = {...}
	local msgLen = 0
	for k,v in pairs( msg )do
		if( type( v ) == 'string' )then
			msgLen = msgLen + string.len( v )
		end
	end
	NRP.DebugMsgRAW(instanceColor,'================================================================================\n')
	LoadMessage( ... )
	if( RealTime() ~= lastbig) then
		NRP.DebugMsgRAW(instanceColor,'================================================================================\n')
	end
	lastbig = RealTime()
end
NRP.LoadErrorMessage = function( ... )
	NRP.LoadMessage( NRP.color.red,'    [ERROR]', ... )
end

/*========================================
Yes, the AskII art. What did you expect...
========================================*/

NRP.DebugMsgRAW( instanceColor, [==[
  _   _            _____  _____  
 | \ | |          |  __ \|  __ \ 
 |  \| | ___  ___ | |__) | |__) |
 | . ` |/ _ \/ _ \|  _  /|  ___/ 
 | |\  |  __/ (_) | | \ \| |     
 |_| \_|\___|\___/|_|  \_\_|  
	 __          __   ___       __                        
	|__) \ /    |__) |__  |\ | / _` |  | | |\ |
	|__)  |     |    |___ | \| \__> \__/ | | \|

DEVELOPERS:
 * TheLastPenguin (Penguin) - Project Lead.
]==] )