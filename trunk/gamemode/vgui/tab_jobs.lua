--[[
<xml>
	<module>
		<name>vgui_tab_jobs</name>
		<instance>CLIENT</instance>
		<require>menu_loader</require>
	</module>
</xml>
]]

local JOBTAB = {}
JOBTAB.name = "Jobs"
JOBTAB.icon = "icon16/user_red.png"
JOBTAB.make = function( panel )
	
end
JOBTAB.update = function( panel )
	
end
NRP.AddMenuTab( JOBTAB )