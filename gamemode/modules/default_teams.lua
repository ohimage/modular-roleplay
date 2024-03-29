--[[
<xml>
	<module>
		<name>default_teams</name>
		<author>TheLastPenguin</author>
		<desc>Default set of teams.</desc>
		<instance>SHARED</instance>
	</module>
</xml>
]]

NRP.CITIZEN_MODELS = {
	"models/player/Group01/Female_01.mdl",
	"models/player/Group01/Female_02.mdl",
	"models/player/Group01/Female_03.mdl",
	"models/player/Group01/Female_04.mdl",
	"models/player/Group01/Female_06.mdl",
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

TEAM_CITIZEN = NRP.AddCustomTeam( 'Citizen', {
	model = NRP.CITIZEN_MODELS,
	color = Color( 0, 155, 0, 255),
	vote = false,
	command = 'citizen',
	limit = -1,
	desc = [[
Citizens are the basic units of society.
You have no special role or special abilities or weapons. The Citizen is the core unit of society. You may create a business or find a job with a merchant class. You may also take payed roles for other classes like the police or gang if they are interested in paying you.
Citizens may form groups or stage protests if they do not like the status of the city.]]
})

/*=============================
SHADY TEAMS
=============================*/
GROUP_UNDERWORLD = NRP.AddTeamGroup("Under World", { } )

TEAM_GANG = NRP.AddCustomTeam( 'Gangster', {
	model = NRP.SHADY_MODELS,
	color = Color( 155, 155, 155, 255),
	vote = false,
	command = 'gangster',
	limit = 6,
	desc = [[
The common Gangster is amongst the middle ranks of the organised crime world.
Gangsters must obey the Mob Boss who is the leader of the organised crime world. You may not kill without the Mob Boss's permission. 
You act as a thug for the Mob Boss carying out his dirty work while bringing the spoils back to him.
Gangsters can not act on their own and require a mob boss to function.
]]
})

TEAM_THIEF = NRP.AddCustomTeam( 'Thief', {
	model = {'models/player/t_arctic.mdl','models/player/t_phoenix.mdl'},
	color = Color( 155, 155, 155, 255),
	weapons = {'lockpick'},
	vote = false,
	command = 'thief',
	limit = 3,
	desc = [[
A common thief. The loest skum in the crime world, stealing the work of others.
Thifs prowl the streets where the CP dare not roam, be it gang territory or deep tunnel networks, robbing unwitting people as they pass.
Smarter thifs may find valuable loot by robbing homes and working with gangs to find targets. A thief should never have need of a gun, for his presence should not be noticed until the stolen items are discovered.
]]
})

TEAM_MOBBOSS = NRP.AddCustomTeam( 'Mob Boss', {
	model = "models/player/gman_high.mdl",
	color = Color( 15, 15, 15, 255),
	vote = false,
	command = 'mobboss',
	limit = 1,
	weapons = {'unarrest_stick','weapon_crowbar','lockpick'},
	desc = [[
The Mob Boss is the leader of the Underworld of criminals and other dispicible charactors.
He is the worst of the criminals and keeps the order and organises shady activities with his brutal tactics. The Mob Boss may order killings however he should not kill himself.
The Mob Boss should turn crime into a business by selling protection perhalps, or getting his fingers into the profitable drug and illegal weapons trades. Stealing and killing is left to the more specialised groups.

The Mob Boss is responsible for redestributing profits to the Gangsters and giving 'gifts' or bribs to police as needed.

YOU MAY NOT RDM OR DECLARE WAR ON CITIZENS (police wars are ok if casualties are avoided.)
]]
})

/*=============================
POLICE TEAMS
=============================*/

TEAM_MAYOR = NRP.AddCustomTeam( 'Mayor', {
	model = "models/player/breen.mdl",
	color = Color( 175, 0, 0, 255),
	vote = true,
	command = 'mayor',
	limit = 1,
	desc = [[
Tme Mayor are in charge of the city acting as the voice of the people.
It is your duty to represent the public rule and keep the public happy while maintaining safety and helping the economy if needed.
The Mayor must humanise the police and make sure they are rained in and kept on task protecting the people without going to far.
The Mayor may set taxes, require searches, ban some weapons and items, and place other laws as needed so long as they dont violate server rules.
]]
})

TEAM_POLICE = NRP.AddCustomTeam( 'Police', {
	model = "models/player/Police.mdl",
	color = Color( 0, 0, 175, 255),
	vote = true,
	command = 'police',
	weapons = {'weapon_real_cs_glock18' , 'arrest_stick', 'unarrest_stick'},
	limit = 6,
	IsCP = true,
	desc = [[
As a police officer it is your duty to keep law and order.
You carry out the mayor's orders and uphold the laws of the land.
Should you find anyone breaking these laws you may arrest them to keep them off the streets.

You may not arrest anyone without just cause!!!]]
})

TEAM_CHIEF = NRP.AddCustomTeam( 'Chief', {
	model = "models/player/Combine_Soldier_PrisonGuard.mdl",
	color = Color( 0, 55, 175, 255),
	command = 'chief',
	weapons = { 'weapon_real_cs_desert_eagle','weapon_real_cs_xm1014', 'arrest_stick', 'unarrest_stick' },
	limit = 1,
	IsCP = true,
	CanSetJail = true,
	desc = [[
As police Chief you must listen to informants and keep track of the crime paturns.
The Chief must organise police Patrols, instruct investigations, keep track of suspisicous players and reported activities, and investigate possibly dirty cops.
You are also required to give reports to the mayor and obey his instructions should he give you any.

YOU MAY NOT WORK WITH CRIME ORGANISATIONS OR OVERTHROW THE MAYOR.
]],
	vote = true
})

TEAM_GUN = NRP.AddCustomTeam( 'Gun Dealer', {
	model = "models/player/monk.mdl",
	color = Color( 255, 155, 0, 255),
	command = 'gundealer',
	limit = 4,
	desc = [[
Gun Dealers are responcible for the weapon supply to the city. 
They are required to setup shops and take clients selling guns. They may sell their services entirely to one group such as a gang of the police but they may not use guns them selves.
Gun Dealers may be arrested for selling guns that are specified as illegal by the city police!
]]
})

TEAM_DRUG = NRP.AddCustomTeam( 'Drug Dealer', {
	model = "models/player/soldier_stripped.mdl",
	color = Color( 200, 0, 255, 255),
	command = 'drug',
	limit = 4,
	desc = [[
Drug dealers are the true skum of the city corrupting the youth population.
You sell drugs to anyone who will buy, but will be hunted relentlessly by police if they catch you selling.
A Successful Drug Dealer must be sly with their advertisements making it hard for CP to get any conclusive evidance.

A Drug Dealer may also create more legitimate trades if you wish selling beer and cigarettes to bars.
]]
})

-- the default team for players who have just joined.
NRP.cfg.DefaultTeam = TEAM_CITIZEN