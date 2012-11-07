--[[
<info>
<name>sh_teams</name>
<author>TheLastPenguin</author>
<desc>Functions to create and manage teams.</desc>
<instance>SHARED</instance>
<require>sh_notice,sv_chat</require>
</info>
]]

local teams = {}
MORP.CustomTeams = teams


local requiredValues = {
	{'name', nil },
	{'model', nil },
	{'vote', false },
	{'command', nil },
	{'color', Color(155,0,155) },
	{'limit',nil}
}
--[[
OTHER VALUES:
CustomCheck - function passed the player as the only arguement.
IsVisible - can it be seen on the menu. Default will be true.
MustChangeFrom - list of teams that are required to be this one.
HOOK_<name> - hooks coming soon
]]
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
	teams[ tbl.id ] = tbl.id
	team.SetUp( tbl.id, tbl.name, tbl.color )
	if(SERVER)then
		MORP:AddChatCommand( tbl.command, function( ply )
			print("OH SNAP DAWG")
			MORP:ChatMessage(player.GetAll(), ply, " changed job to ", tbl.color, tbl.name )
			ply:SetTeam( tbl.id )
		end)
	end
end


MORP:AddCustomTeam( 'Developer', {
	model = 'models/breen.mdl',
	color = MORP.color.cyan,
	vote = false,
	command = 'developer',
	limit = -1,
	CustomCheck = function( ply )
		return ply:IsMORPDeveloper( )
	end
})
