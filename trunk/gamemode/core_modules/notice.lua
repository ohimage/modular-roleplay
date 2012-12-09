--[[
<xml>
	<module>
		<name>sh_notice</name>
		<author>TheLastPenguin</author>
		<desc>Provides notification functionality like chat text, and console printing.</desc>
		<instance>SHARED</instance>
		<require>table</require>
	</module>
</xml>
]]

local NRP = NRP
local cfg = NRP.cfg
function NRP.FormatString( str )
	str = string.gsub( str, '<cur>', cfg.Curency )
	return str
end

if(SERVER)then
	util.AddNetworkString("NRP_ChatMessage")
	util.AddNetworkString("NRP_ConMessage")
	util.AddNetworkString("NRP_Notice")
	local function BuildMessage( tbl )
		table.flaten( tbl )
		return tbl
	end
	NRP.ChatMessage = function( targs, ... )
		local message = BuildMessage( {...} )
		net.Start("NRP_ChatMessage")
		net.WriteTable( message )
		net.Send( targs )
	end
	NRP.ConsoleMessage = function( targs, ... )
		local message = BuildMessage( {...} )
		net.Start("NRP_ConMessage")
		net.WriteTable( message )
		net.Send( targs )
	end
	
	NOTIFY_GENERIC = 0
	NOTIFY_ERROR = 1
	NOTIFY_UNDO = 2
	NOTIFY_HINT = 3
	NOTIFY_CLEANUP = 4
	NRP.Notice = function( targs, time, text, icon )
		net.Start( "NRP_Notice" )
			net.WriteString( text )
			net.WriteInt( icon or NOTIFY_GENERIC, 4 )
			net.WriteInt( math.min( time, 8 ), 4 )
		net.Send( targs )
	end
else
	net.Receive("NRP_ChatMessage",function()
		local tbl = net.ReadTable()
		chat.AddText( unpack( tbl ) )
	end)
	net.Receive("NRP_ConMessage",function()
		local tbl = net.ReadTable()
		NRP.MsgC( unpack( tbl ) )
	end)
	net.Receive("NRP_Notice",function()
								-- text				icon id		time
		notification.AddLegacy( net.ReadString(), net.ReadInt( 4 ), net.ReadInt(4))
		surface.PlaySound("buttons/button15.wav")
	end)
end