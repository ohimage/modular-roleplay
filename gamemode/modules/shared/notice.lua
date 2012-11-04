--[[
<info>
<name>notice</name>
<author>TheLastPenguin</author>
<desc>Provides notification functionality like chat text, and console printing.</desc>
<instance>SHARED</instance>
<require>table</require>
</info>
]]
if(SERVER)then
	util.AddNetworkString("MORP_ChatMessage")
	util.AddNetworkString("MORP_ConMessage")
	local function BuildMessage( tbl )
		table.flaten( tbl )
		return tbl
	end
	function MORP:ChatMessage( targs, ... )
		local message = BuildMessage( {...} )
		net.Start("MORP_ChatMessage")
		net.WriteTable( message )
		net.Send( targs )
	end
	function MORP:ConsoleMessage( targs, ... )
		local message = BuildMessage( {...} )
		net.Start("MORP_ConMessage")
		net.WriteTable( message )
		net.Send( targs )
	end
else
	net.Receive("MORP_ChatMessage",function()
		local tbl = net.ReadTable()
		chat.AddText( unpack( tbl ) )
	end)
	net.Receive("MORP_ConMessage",function()
		local tbl = net.ReadTable()
		MsgCTBL( unpack( tbl ) )
	end)
end