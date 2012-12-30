--[[
<xml>
	<module>
		<name>resource_sh</name>
		<author>TheLastPenguin</author>
		<desc>Shared resource system.</desc>
		<instance>SHARED</instance>
	</module>
</xml>
]]

NRP.RES = {} -- resource table
local RES = NRP.RES

/*==================================
ENUM
==================================*/
RESOURCE_NETWORK = 1 -- network resources like energy.
RESOURCE_SUPPLY = 2 -- resources like paper, feul etc.

local resources = {}
RES.resources = resources
function NRP.RegisterResource( name, tbl )
	tbl.id = tbl.name
	resources[ name ] = tbl
	NRP.LoadMessage(NRP.color.white, "Loaded resource "..name )
end

NRP.RegisterResource( "Energy", {
	PrintName = "Electricity",
	Icon = "icon16/lightning.png",
	type = RESOURCE_NETWORK,
})