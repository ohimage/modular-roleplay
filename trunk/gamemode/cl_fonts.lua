local fonts = {}
function NRP.RequestFont( size, weight, base)
	local name = "NRP"..size
	if( weight )then
		name = name.."_"..weight
	end
	if( base )then
		name = name.."_"..base
	end
	weight = weight or 100
	if( fonts[ name ] )then return end
	surface.CreateFont( name,
		{
			font      = base or "roboto",
			size      = size,
			weight    = weight
		}
	 )
	 return name
end