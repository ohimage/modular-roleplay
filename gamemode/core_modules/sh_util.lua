--[[
<xml>
	<module>
		<name>util</name>
		<author>TheLastPenguin</author>
		<desc>MISC Useful Functions</desc>
		<instance>SHARED</instance>
	</module>
</xml>
]]

local NRP = NRP

local Player = FindMetaTable("Player")
local CoolDowns = {}

function Player:CoolDownTimer( id, time )
	if( not CoolDowns[ self:UserID() ] )then
		CoolDowns[ self:UserID() ] = {}
	end
	CoolDowns[ self:UserID() ][ id ] = RealTime() + time
	timer.Simple( time, function()
		if( CoolDowns[ self:UserID() ] )then
			CoolDowns[ self:UserID() ][ id ] = nil
		end
	end)
end

function Player:IsCooledDown( id )
	if( not CoolDowns[ self:UserID() ] )then return true end
	if( CoolDowns[ self:UserID() ][ id ] == nil )then return true end
	local timeLeft = CoolDowns[ self:UserID() ][ id ] - RealTime()
	return false, timeLeft
end
hook.Add("PlayerDisconnected","NRP_RemoveCoolDWN",function( ply )
	CoolDowns[ ply:UserID() ] = nil
end)