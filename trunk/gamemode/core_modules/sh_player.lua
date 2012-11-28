--[[
<xml>
	<module>
		<name>sh_player</name>
		<author>TheLastPenguin</author>
		<desc>Player functions</desc>
		<instance>SHARED</instance>
	</module>
</xml>
]]
local plymeta = FindMetaTable( 'Player' )
if(SERVER)then
	function plymeta:GetEyeTrace()
		local pos = self:GetShootPos()
		local ang = self:GetAimVector()
		local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = pos+(ang*20000)
		tracedata.filter = self.Entity
		local trace = util.TraceLine(tracedata)
		return trace
	end
	function plymeta:GetLimitedEyeTrace( dist )
		local pos = self:GetShootPos()
		local ang = self:GetAimVector()
		local tracedata = {}
		tracedata.start = pos
		tracedata.endpos = pos+(ang*dist)
		tracedata.filter = self.Entity
		local trace = util.TraceLine(tracedata)
		return trace
	end
end