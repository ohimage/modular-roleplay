--[[
<xml>
	<module>
		<name>jails</name>
		<instance>SHARED</instance>
		<desc>Handles player aresting and unarresting etc.</desc> 
	</module>
</xml>
]]

local DBI = NRP.DBI
if(SERVER)then
	local jails = {}
	local res = DBI.Query( "SELECT * FROM prefix_jails WHERE map = "..sql.SQLStr( game.GetMap() ) )
	if( res )then
		for k,v in pairs( res )do
			local vector = Vector( tonumber( v.x ), tonumber( v.y ), tonumber( v.z ) )
			table.insert( jails, vector )
		end
	end
	local function SaveJailPos( vector )
		DBI.Query( string.format( "INSERT INTO prefix_jails ( map, x, y, z ) VALUES ( %s, %s, %s, %s )",
				sql.SQLStr( game.GetMap() ), sql.SQLStr( vector.x ), sql.SQLStr( vector.y ), sql.SQLStr( vector.z) ) )
	end
	
	NRP.AddChatCommand( "addjailpos", function( ply, args )
		if( not NRP.cfg.CanSetJailPos( ply ) )then return end -- make sure they have permission to set the jail pos.
		SaveJailPos( ply:GetPos() )
		table.insert( jails, ply:GetPos() )
		PrintTable( jails )
		NRP.Notice( ply, 6, "Added a jail point at your current position.")
	end)
	NRP.AddChatCommand( "setjailpos", function( ply, args )
		if( not NRP.cfg.CanSetJailPos( ply ) )then return end -- make sure they have permission to set the jail pos.
		DBI.Query( "DELETE * FROM prefix_jails WHERE map = "..sql.SQLStr( game.GetMap() ) )
		SaveJailPos( ply:GetPos() )
		jails = {}
		table.insert( jails, ply:GetPos() )
		NRP.Notice( ply, 6, "Set jail position here and removed all other jails.")
	end)
	local Player = FindMetaTable("Player")
	util.AddNetworkString("NRP_JailTime")
	local cjailid = 0
	function Player:Arrest( time )
		if( #jails ~= 0 )then
			self:SetPos( jails[ cjailid % #jails + 1 ] )
			cjailid = cjailid + 1
		end
		self:StripWeapons()
		self.Arrested = true
		print("Sending jail time to player.")
		net.Start( "NRP_JailTime" )
			net.WriteDouble( time )
		net.Send( self.Entity )
		timer.Simple( time, function()
			if( self.Entity:IsArrested() )then
				self:UnArrest()
				NRP.Notice( player.GetAll(), 6, "Player "..self.Entity:Name().." has been released from jail.")
			end
		end)
	end
	function Player:IsArrested()
		if( self.Arrested )then
			return true
		else
			return false
		end
	end
	function Player:UnArrest()
		hook.Call("PlayerSpawn",GAMEMODE, self.Entity )
		local info_playerspawn = hook.Call("PlayerSelectSpawn",GAMEMODE, self.Entity)
		self.Entity:SetPos( info_playerspawn:GetPos() )
		self.Arrested = false
	end
	
	function GM:CanPlayerSuicide( ply )
		if( ply:IsArrested() )then
			return false
		end
	end
end
if(CLIENT)then
	print("Loading client side.")
	NRP.ChatAutocomplete( 'setjailpos', function()
		return "setjailpos", {"Remove all other jails and make this the new one" }
	end)
	
	local FONT_JAILTIMER = NRP.RequestFont( 50, 2000 )
	function GM:HUDPaint()
		if( LocalPlayer().JailTimer )then
			local xpos, ypos =  ScrW() / 2, ScrH() * 0.7
			local tleft = math.Round(LocalPlayer().JailTimer - RealTime() )
			if( tleft < 0 )then
				LocalPlayer().JailTimer = nil
				return
			end
			local str = "You have been arrested for "..tleft
			draw.SimpleText(str, FONT_JAILTIMER, xpos + 2, ypos + 2, Color( 0, 0, 0, 200 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText(str, FONT_JAILTIMER, xpos, ypos, Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	net.Receive("NRP_JailTime",function()
		print("GOT JAIL TIMER!")
		local time = net.ReadDouble()
		if( time == -1 )then
			LocalPlayer().JailTimer = nil
		else
			LocalPlayer().JailTimer = RealTime() + time
		end
	end)
end