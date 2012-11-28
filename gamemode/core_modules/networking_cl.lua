--[[
<xml>
	<module>
		<name>networking</name>
		<author>TheLastPenguin</author>
		<desc>Networked data libraries</desc>
		<instance>CLIENT</instance>
	</module>
</xml>
]]

/*================================
RECEIVE DATA FROM SERVER
================================*/
function ReceiveNetValue()
	local ent = net.ReadEntity()
	local key, value
	-- receive the key
	local keyType = net.ReadInt( 4 )
	if( keyType == 1 )then
		key = net.ReadString( )
	elseif( keyType == 2 )then
		key = net.ReadInt( 4 )
	end
	
	-- send the value.
	local valueType = net.ReadInt( 4 )
	if( valueType == 1 )then
		value = net.ReadString( )
	elseif( valueType == 2 )then
		value = net.ReadDouble( )
	end
	
	if( not ent.NETDATA )then ent.NETDATA = {} end
	print("NET: Received ".. key .. ' = '.. value )
	ent.NETDATA[ key ] = value
end

net.Receive( 'NRP_NWPlayerValue', ReceiveNetValue )