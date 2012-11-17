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

-- encode IP Addresses to save data.
function NRP:IP_ToNumber( str )
	if( str == 'loopback' )then
		return 0
	end
	local parts = string.Explode( '.', str )
	PrintTable( parts )
	local num = 0
	for k,v in SortedPairs( parts )do
		num = num * 255 + tonumber( v )
	end
	return num
end
function NRP:IP_ToString( num )
	local parts = {}
	while( num ~= 0 )do
		local rem = num % 255
		table.insert( parts,1, rem )
		num = math.floor( num / 255 )
	end
	return table.concat( parts, '.' )
end