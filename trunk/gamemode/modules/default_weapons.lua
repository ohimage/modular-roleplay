/*
<xml>
	<module>
		<name>default_weapons</name>
		<author>TheLastPenguin, [LiqR] Foul Play</author>
		<desc>Default set of weapons.</desc>
		<instance>SHARED</instance>
		<require>default_teams</require>
	</module>
</xml>


NRP.AddCustomShipment('HL2 Pistol',{
	model = 'models/weapons/w_pistol.mdl',
	class = 'weapon_pistol',
	price = 100,
	category = 'Weapons'
})

NRP.AddCustomShipment('HL2 SMG',{
	model = 'models/weapons/w_smg1.mdl',
	class = 'weapon_smg1',
	price = 200,
	category = 'Weapons',
	teams = {TEAM_MAYOR}
})

NRP.AddCustomShipment('M249',{
	model = 'models/weapons/w_mach_m249para.mdl',
	class = 'weapon_smg1',
	price = 500--,
	--category = 'Weapons'
})
*/


--Pistols
NRP.AddCustomShipment('Glock 18',{
	model = 'models/weapons/w_pist_glock18.mdl',
	class = 'weapon_real_cs_glock18',
	price = 45,
	category = 'Pistols',
	teams = {TEAM_GUN}
})

NRP.AddCustomShipment('P228',{
	model = 'models/weapons/w_pist_p228.mdl',
	class = 'weapon_real_cs_p228',
	price = 62,
	category = 'Pistols',
	teams = {TEAM_GUN}
})

NRP.AddCustomShipment('Five-Seven',{
	model = 'models/weapons/w_pist_fiveseven.mdl',
	class = 'weapon_real_cs_five-seven',
	price = 84,
	category = 'Pistols',
	teams = {TEAM_GUN}
})

NRP.AddCustomShipment('USP',{
	model = 'models/weapons/w_pist_usp.mdl',
	class = 'weapon_real_cs_usp',
	price = 97,
	category = 'Pistols',
	teams = {TEAM_GUN}
})

NRP.AddCustomShipment('Dual Elites',{
	model = 'models/weapons/w_pist_elite_dropped.mdl',
	class = 'weapon_real_cs_elites',
	price = 196,
	category = 'Pistols',
	teams = {TEAM_GUN}
})

NRP.AddCustomShipment('Deagle',{
	model = 'models/weapons/w_pist_deagle.mdl',
	class = 'weapon_real_cs_desert_eagle',
	price = 208,
	category = 'Pistols',
	teams = {TEAM_GUN}
})
--SMGS
NRP.AddCustomShipment('Mac 10',{
	model = 'models/weapons/w_smg_mac10.mdl',
	class = 'weapon_real_cs_mac10',
	price = 125,
	category = 'SMGS',
	teams = {TEAM_GUN}
})

NRP.AddCustomShipment('MP5',{
	model = 'models/weapons/w_smg_mp5.mdl',
	class = 'weapon_real_cs_mp5a5',
	price = 165,
	category = 'SMGS',
	teams = {TEAM_GUN}
})

NRP.AddCustomShipment('P90',{
	model = 'models/weapons/w_smg_p90.mdl',
	class = 'weapon_real_cs_p90',
	price = 195,
	category = 'SMGS',
	teams = {TEAM_GUN}
})

NRP.AddCustomShipment('TMP',{
	model = 'models/weapons/w_smg_tmp.mdl',
	class = 'weapon_real_cs_tmp',
	price = 203,
	category = 'SMGS',
	teams = {TEAM_GUN}
})

NRP.AddCustomShipment('UMP 45',{
	model = 'models/weapons/w_smg_ump45.mdl',
	class = 'weapon_real_cs_ump_45',
	price = 271,
	category = 'SMGS',
	teams = {TEAM_GUN}
})
--Shotguns
NRP.AddCustomShipment('Pump Shotgun',{
	model = 'models/weapons/w_shot_m3super90.mdl',
	class = 'weapon_real_cs_pumpshotgun',
	price = 155,
	category = 'Shotguns',
	teams = {TEAM_GUN}
})

NRP.AddCustomShipment('Auto Shotgun',{
	model = 'models/weapons/w_shot_xm1014.mdl',
	class = 'weapon_real_cs_xm1014',
	price = 245,
	category = 'Shotguns',
	teams = {TEAM_GUN}
})
--Rifles
NRP.AddCustomShipment('AK-47',{
	model = 'models/weapons/w_rif_ak47.mdl',
	class = 'weapon_real_cs_ak47',
	price = 335,
	category = 'Rifles',
	teams = {TEAM_GUN}
})

NRP.AddCustomShipment('M4',{
	model = 'models/weapons/w_rif_m4a1.mdl',
	class = 'weapon_real_cs_m4a1',
	price = 405,
	category = 'Rifles',
	teams = {TEAM_GUN}
})

NRP.AddCustomShipment('Steyr Aug',{
	model = 'models/weapons/w_rif_aug.mdl',
	class = 'weapon_real_cs_aug',
	price = 458,
	category = 'Rifles',
	teams = {TEAM_GUN}
})

NRP.AddCustomShipment('SG552',{
	model = 'models/weapons/w_rif_sg552.mdl',
	class = 'weapon_real_cs_sg552',
	price = 484,
	category = 'Rifles',
	teams = {TEAM_GUN}
})

NRP.AddCustomShipment('Galil',{
	model = 'models/weapons/w_rif_galil.mdl',
	class = 'weapon_real_cs_galil',
	price = 503,
	category = 'Rifles',
	teams = {TEAM_GUN}
})

NRP.AddCustomShipment('Famas',{
	model = 'models/weapons/w_rif_famas.mdl',
	class = 'weapon_real_cs_famas',
	price = 545,
	category = 'Rifles',
	teams = {TEAM_GUN}
})
--LightMachinegGun
NRP.AddCustomShipment('M249',{
	model = 'models/weapons/w_mach_m249para.mdl',
	class = 'weapon_real_cs_m249',
	price = 1005,
	category = 'LightMachinegGun',
	teams = {TEAM_GUN}
})
--SniperRifles
NRP.AddCustomShipment('Scout',{
	model = 'models/weapons/w_snip_scout.mdl',
	class = 'weapon_real_cs_scout',
	price = 460,
	category = 'SniperRifles',
	teams = {TEAM_GUN}
})

NRP.AddCustomShipment('SG550',{
	model = 'models/weapons/w_snip_sg550.mdl',
	class = 'weapon_real_cs_sg550',
	price = 512,
	category = 'SniperRifles',
	teams = {TEAM_GUN}
})

NRP.AddCustomShipment('G3SG1',{
	model = 'models/weapons/w_snip_g3sg1.mdl',
	class = 'weapon_real_cs_g3sg1',
	price = 620,
	category = 'SniperRifles',
	teams = {TEAM_GUN}
})

NRP.AddCustomShipment('AWP',{
	model = 'models/weapons/w_snip_awp.mdl',
	class = 'weapon_real_cs_awp',
	price = 740,
	category = 'SniperRifles',
	teams = {TEAM_GUN}
})
--Grenades
NRP.AddCustomShipment('Flash Grenade',{
	model = 'models/weapons/w_eq_flashbang_thrown.mdl',
	class = 'weapon_real_cs_flash',
	price = 207,
	category = 'Grenades',
	teams = {TEAM_GUN}
})

NRP.AddCustomShipment('Smoke Grenade',{
	model = 'models/weapons/w_eq_smokegrenade.mdl',
	class = 'weapon_real_cs_smoke',
	price = 303,
	category = 'Grenades',
	teams = {TEAM_GUN}
})

NRP.AddCustomShipment('Frag Grenade',{
	model = 'models/weapons/w_eq_fraggrenade.mdl',
	class = 'weapon_real_cs_grenade',
	price = 410,
	category = 'Grenades',
	teams = {TEAM_GUN}
})
-- End of file.
/*==================
ENTITIES
==================*/

NRP.AddCustomEntity('Money Printer',{
	model = 'models/props_c17/consolebox01a.mdl',
	class = 'money_printer',
	price = 1000,
	category = 'Entities'
})
