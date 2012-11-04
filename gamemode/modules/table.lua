<info>
<name>table</name>
<author>TheLastPenguin</author>
<desc>Provides functionality involving tables.</desc>
<instance>SHARED</instance>
</info>


table.flaten = function( tbl )
	for k,v in pairs( tbl )do
		if( type( v ) == "table" and not ( v.r and v.g and v.b and v.a ) )then
			local nested = v
			-- clear value of current tbl at k
			tbl[ k ] = nil
			table.flaten( nested )
			local c = 0
			for j,l in pairs( nested )do
				if( type( j ) == "number" )then
					-- insert new values into old position
					table.insert( tbl,k + c, l )
					c = c + 1
				else
					tbl[ j ] = l
				end
			end
		end
	end
end
