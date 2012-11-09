--[[
<info>
<name>util</name>
<author>TheLastPenguin</author>
<desc>MISC Useful Functions</desc>
<instance>SHARED</instance>
</info>
]]

function MORP:IP_ToNumber( str )
	local parts = string.Explode( '.', str )
	PrintTable( parts )
	local num = 0
	for k,v in SortedPairs( parts )do
		num = num * 255 + tonumber( v )
	end
	return num
end
function MORP:IP_ToString( num )
	local parts = {}
	while( num > 0 )do
		local rem = num % 255
		table.insert( parts, rem )
	end
	return table.concat( parts, '.' )
end
local encoded = MORP:IP_ToNumber('1.1.1.1')
local decoded = MORP:IP_ToString( encoded )
print( decoded )