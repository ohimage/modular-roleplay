GM.Version = "0.0.1"
GM.Name = "ModularRP"
GM.Author = "By TheLastPenguin, Dev DotEXE"

include("config.lua")
local instanceColor -- used in MsgCTBL to show if a message is being printed by clientside or server.
if( SERVER )then
	instanceColor = Color( 255, 155, 0 ) -- orange for server.
else
	instanceColor = Color( 0, 255, 255 ) -- cyan for clients.
end 
function MsgCTBLRaw( ... )
	local arg = {...}
	local color = MORP.color.white
	for k,v in SortedPairs( arg )do
		if( type( v ) == 'table' and v.r and v.g and v.b and v.a )then
			color = v
		else
			if( type( v ) == 'number' )then
				MsgC(color,tostring( v ) )
			elseif( type( v ) == 'Player' )then
				MsgC( team.GetColor( v:Team() ), v:Name() )
			elseif( type( v ) == 'Entity' )then
				MsgC( color, v:GetClass())
			else
				MsgC( color, tostring( v ) )
			end
		end
	end
end

function MsgCTBL( ... )
	MsgCTBLRaw( instanceColor, '[MoRP] ', ... )
	print('')
end

-- Gotta have our sexy looking load messages for the load process.
function MORP:LoadMessage( ... )
	local msg = {...}
	local msgLen = 0
	for k,v in pairs( msg )do
		if( type( v ) == 'string' )then
			msgLen = msgLen + string.len( v )
		end
	end
	MsgCTBLRaw(instanceColor,'| ')
	MsgCTBLRaw(...)
	MsgCTBLRaw(string.format('%'..math.max(76 - msgLen,1)..'s', ''),instanceColor,' |\n' )
end
function MORP:LoadMessageBig( ... )
	local msg = {...}
	local msgLen = 0
	for k,v in pairs( msg )do
		if( type( v ) == 'string' )then
			msgLen = msgLen + string.len( v )
		end
	end
	MsgCTBLRaw(instanceColor,'================================================================================\n')
	MORP:LoadMessage( ... )
	MsgCTBLRaw(instanceColor,'================================================================================\n')
end