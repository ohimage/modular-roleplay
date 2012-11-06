--[[
<info>
<name>sh_teams</name>
<author>TheLastPenguin</author>
<desc>Functions to create and manage teams.</desc>
<instance>SHARED</instance>
<require>notice,chat</require>
</info>
]]

local teams = {}
MORP.CustomTeams = teams


local requiredValues = {
	{'name', nil },
	{'model', nil },
	{'vote', false },
	{'CustomCheck', function( ply )
		return hook.Run("MORP_ChangeTeam", ply)
	end },
	{'command', nil },
	{'color', nil }
}
function MORP:AddCustomTeam( name, tbl )
	MsgCTBL(MORP.color.white,"Registered team "..name )
	tbl['name'] = name
	for k,v in pairs( requiredValues )do
		if( tbl[ v[1] ] == nil )then
			if( v[2] == nil )then
				MsgCTBL( MORP.color.red, "TEAM ERROR: MISSING REQUIRED PROPERTY "..v[1].. " IN TEAM "..name )
				ErrorNoHalt("Team Error.")
				return
			else
				MsgCTBL( MORP.color.orange, "Set Property "..v[1].." to default "..tostring( v[2]))
				tbl[ v[1] ] = v[2] 
			end
		end
	end
	tbl.id = #teams + 1
	teams[ id ] = tbl
	team.SetUp( id, name, tbl.color )
	if(SERVER)then
		MORP:AddChatCommand( tbl.command, function( ply )
			ply:SetTeam( id )
		end)
	end
end