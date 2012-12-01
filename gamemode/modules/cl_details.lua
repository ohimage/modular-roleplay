--[[
<xml>
	<module>
		<name>cl_details</name>
		<author>TheLastPenguin</author>
		<desc>Functions for frequently used effects</desc>
		<instance>CLIENT</instance>
		<require>cl_hud</require>
	</module>
</xml>
]]

local scalelist = {}

local lastrun = RealTime()
function GM:Think()
	local steplen = RealTime() - lastrun
	lastrun = RealTime()
	for k,v in pairs( scalelist )do
		if( not IsValid( v.e ) )then
			table.remove( scalelist, k )
		else
			local dir = v.f - v.b
			local prog = ( steplen / v.t ) * dir
			v.s = v.s + prog
			if( v.s < math.min( v.b, v.f ) or v.s > math.max( v.b, v.f ) )then
				v.e:SetModelScale( v.f, 0)
				table.remove( scalelist, k )
				print("Finished scaleing prop!")
			else
				v.e:SetModelScale( v.s, 0)
			end
		end
	end
end
function NRP:ChangeModelScale( ent, begin, finish, time)
	if( type( ent ) == 'table' )then
		NRP:ChangeModelScale( ent.ent, ent.begin, ent.finish, ent.time )
		return
	end
	print("Adding entity to changemodelscale.")
	ent:SetModelScale( begin, 0 )
	local n = {}
	n.e = ent -- entity.
	n.b = begin -- start size.
	n.f = finish -- finish size.
	n.t = time -- time for the effect to run.
	n.s = begin
	table.insert( scalelist, n )
end