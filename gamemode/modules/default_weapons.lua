--[[
<xml>
	<module>
		<name>default_weapons</name>
		<author>TheLastPenguin</author>
		<desc>Default set of weapons.</desc>
		<instance>SHARED</instance>
	</module>
</xml>
]]

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