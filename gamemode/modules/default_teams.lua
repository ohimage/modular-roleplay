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

if(SERVER)then
	NRP:AddChatCommand( 'listmodels', function( ply )
		if( ply:IsNRPDeveloper() )then
			PrintTable( NRP.MODELS )
		end
	end)
end

TEAM_DEVELOPER = NRP:AddCustomTeam( 'Developer', {
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

TEAM_CITIZEN = NRP:AddCustomTeam( 'Citizen', {
	model = NRP.CITIZEN_MODELS,
	color = Color( 0, 155, 0, 255),
	weapons = {'weapon_physgun'},
	vote = false,
	command = 'citizen',
	limit = -1
})

TEAM_GANG = NRP:AddCustomTeam( 'Gangster', {
	model = NRP.SHADY_MODELS,
	color = Color( 155, 155, 155, 255),
	weapons = {
		'weapon_crowbar',
		'weapon_smg1'
		},
	vote = false,
	command = 'gangster',
	limit = 6
})

TEAM_MOBBOSS = NRP:AddCustomTeam( 'Mob Boss', {
	model = NRP.SHADY_MODELS,
	color = Color( 15, 15, 15, 255),
	vote = false,
	command = 'mobboss',
	limit = 1
})


-- the default team for players who have just joined.
NRP.cfg.DefaultTeam = TEAM_CITIZEN