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
function MsgCTBL( ... )
	local arg = {...}
	table.insert( arg, 1 , instanceColor )
	table.insert( arg, 2 , '[MoRP]' )
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
	print('')
end