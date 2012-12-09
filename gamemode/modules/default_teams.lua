--[[
<xml>
	<module>
		<name>default_teams</name>
		<author>TheLastPenguin</author>
		<desc>Default set of teams.</desc>
		<instance>SHARED</instance>
		<require>sh_teams</require>
	</module>
</xml>
]]

NRP.CITIZEN_MODELS = {
	"models/player/Group01/Female_01.mdl",
	"models/player/Group01/Female_02.mdl",
	"models/player/Group01/Female_03.mdl",
	"models/player/Group01/Female_04.mdl",
	"models/player/Group01/Female_06.mdl",
	"models/player/Group01/Female_07.mdl",
	"models/player/group01/male_01.mdl",
	"models/player/Group01/Male_02.mdl",
	"models/player/Group01/male_03.mdl",
	"models/player/Group01/Male_04.mdl",
	"models/player/Group01/Male_05.mdl",
	"models/player/Group01/Male_06.mdl",
	"models/player/Group01/Male_07.mdl",
	"models/player/Group01/Male_08.mdl",
	"models/player/Group01/Male_09.mdl"}
	
NRP.SHADY_MODELS = {
	"models/player/Group03/Female_01.mdl",
	"models/player/Group03/Female_02.mdl",
	"models/player/Group03/Female_03.mdl",
	"models/player/Group03/Female_04.mdl",
	"models/player/Group03/Female_06.mdl",
	"models/player/Group03/Female_07.mdl",
	"models/player/group03/male_01.mdl",
	"models/player/Group03/Male_02.mdl",
	"models/player/Group03/male_03.mdl",
	"models/player/Group03/Male_04.mdl",
	"models/player/Group03/Male_05.mdl",
	"models/player/Group03/Male_06.mdl",
	"models/player/Group03/Male_07.mdl",
	"models/player/Group03/Male_08.mdl",
	"models/player/Group03/Male_09.mdl"}

NRP.ALL_MODELS = {}
NRP.MODELS = player_manager.AllValidModels()
for k,v in pairs( NRP.MODELS )do
	table.insert( NRP.ALL_MODELS, v )
end

/*=============================
DEFAULT TEAMS
=============================*/

TEAM_DEVELOPER = NRP.AddCustomTeam( 'Developer', {
	model = NRP.ALL_MODELS,
	color = NRP.color.cyan,
	vote = false,
	weapons = {
		'weapon_crowbar',
		'weapon_pistol',
		'weapon_smg1',
		'weapon_crossbow',
		'weapon_ar2',
		'weapon_375',
		'weapon_stunstick',
		'weapon_rpg',
		'weapon_frag',
		'weapon_slam'
		},
	ModelColor = Color( 0, 0, 255 ),
	command = 'developer',
	limit = -1,
	CustomCheck = function( ply )
		if( ply:IsNRPDeveloper( ) )then
			return true
		else
			return false, "You must be a NeoRP Developer to use this team."
		end
	end
})

TEAM_CITIZEN = NRP.AddCustomTeam( 'Citizen', {
	model = NRP.CITIZEN_MODELS,
	color = Color( 0, 155, 0, 255),
	vote = false,
	command = 'citizen',
	limit = -1
})

/*=============================
SHADY TEAMS
=============================*/
GROUP_UNDERWORLD = NRP.AddTeamGroup("Under World", { } )

TEAM_GANG = NRP.AddCustomTeam( 'Gangster', {
	model = NRP.SHADY_MODELS,
	color = Color( 155, 155, 155, 255),
	weapons = {
		'weapon_crowbar',
		'weapon_pistol'
		},
	vote = false,
	command = 'gangster',
	limit = 6,
	group = GROUP_UNDERWORLD
})

TEAM_MOBBOSS = NRP.AddCustomTeam( 'Mob Boss', {
	model = "models/gman_high.mdl",
	color = Color( 15, 15, 15, 255),
	vote = false,
	command = 'mobboss',
	limit = 1,
	group = GROUP_UNDERWORLD
})

/*=============================
POLICE TEAMS
=============================*/
GROUP_POLICE = NRP.AddTeamGroup("Police", { } )

TEAM_MAYOR = NRP.AddCustomTeam( 'Mayor', {
	model = "models/breen.mdl",
	color = Color( 175, 0, 0, 255),
	vote = true,
	command = 'mayor',
	limit = 1,
	group = GROUP_POLICE
})

TEAM_POLICE = NRP.AddCustomTeam( 'Police', {
	model = "models/breen.mdl",
	color = Color( 0, 0, 175, 255),
	vote = true,
	command = 'police',
	limit = 1,
	group = GROUP_POLICE
})

TEAM_CHIEF = NRP.AddCustomTeam( 'Chief', {
	model = "models/breen.mdl",
	color = Color( 0, 55, 175, 255),
	vote = true,
	command = 'chief',
	limit = 1,
	group = GROUP_POLICE
})


-- the default team for players who have just joined.
NRP.cfg.DefaultTeam = TEAM_CITIZEN