--[[
<xml>
	<module>
		<name>doors</name>
		<instance>SHARED</instance>
		<desc>Handle the locking, unlocking, and loading of door data.</desc> 
	</module>
</xml>
]]

local DBI = NRP.DBI

local Entity = FindMetaTable("Entity")
function Entity:IsDoor(  )
	local class = self:GetClass()
	return class == 'func_door' or class == 'func_door_rotating' or class == 'prop_door_rotating'
end
function Entity:Door_GetFlag( flag )
	return self:GetNWInt( flag ) or false
end
function Entity:Door_SetFlag( flag, value )
	if( not self.DoorFlags )then 
		self.DoorFlags = {} 
	end
	self.DoorFlags[ flag ] = value
	self:SetNWInt( flag, value )
	DBI.Query(string.format( "REPLACE INTO prefix_door_flags( id, flag, value ) VALUES ( %s, %s, %s )",
		sql.SQLStr( self.id ), sql.SQLStr( flag ), sql.SQLStr( value ) ) )
end
function Entity:SaveDoorData()
	if( not self:IsDoor() )then
		Error("Entity is not a door!")
		return
	end
	local locked = 0
	if( self:GetNWBool( "locked" ) == true )then
		locked = 1
	end
	if( not self.DoorFlags )then self.DoorFlags = {} end
	DBI.Query( string.format( "REPLACE INTO prefix_doors( map, x, y, z, title, locked ) VALUES ( %s, %s, %s, %s, %s, %s )", sql.SQLStr( game.GetMap() ),
						sql.SQLStr( math.Round( self:GetPos().x ) ), sql.SQLStr( math.Round( self:GetPos().y ) ), sql.SQLStr( math.Round( self:GetPos().z ) ),
						sql.SQLStr( self:GetNWString('title') or '' ), sql.SQLStr( locked ) ) )
end
function Entity:LoadDoorData()
	local res = DBI.Query( string.format("SELECT * FROM prefix_doors WHERE x = %s AND y = %s AND z = %s AND map = %s",
		sql.SQLStr( math.Round( self:GetPos().x )), sql.SQLStr( math.Round( self:GetPos().y )), sql.SQLStr( math.Round( self:GetPos().z )), sql.SQLStr( game.GetMap() ) ) )
	if( not res or not res[1] )then return nil end
	local dat = res[1]
	self.DoorUsers = {} -- table of alternate door users.
	
	self:SetNWString( 'title', dat.title )
	if( tonumber( dat.locked ) == 0 )then
		self:SetNWBool( 'locked', false)
		self:Fire("unlock", "", 0)
	else
		self:SetNWBool( 'locked', true )
		self:Fire("lock", "", 0)
	end
	
	self.DoorFlags = {}
	local flags = DBI.Query(string.format( "SELECT * FROM prefix_door_flags WHERE id = "..sql.SQLStr( self.id ) ) )
	if( flags )then
		for k,v in pairs( flags )do
			self.DoorFlags[ v.flag ] = v.value
			self:SetNWInt( v.flag, tonumber( v.value ) )
		end
	end
	return dat
end

if(SERVER)then

	local function GetAimDoor( ply )
		local trace = ply:GetEyeTrace()
		if( not IsValid( trace.Entity ) )then return end
		local lockable = hook.Call("NeoRP_IsLockable",GAMEMODE, trace.Entity )
		if( lockable ~= true )then return end
		local door = trace.Entity
		return door
	end
	
	util.AddNetworkString("NRP_SendDoorUser")
	util.AddNetworkString("NRP_SendDoorUserTBL")
	util.AddNetworkString("NRP_RequestDoorUsers")
	NRP.AddChatCommand( 'dooradduser', function( ply, arg )
		local door = GetAimDoor( ply )
		if( not IsValid( door ) )then return end
		
		local uid = tonumber( arg )
		local user = NULL
		for k,v in pairs(player.GetAll())do
			if( IsValid( v ) and v:UserID() == uid )then
				user = v
			end
		end
		if( not IsValid( user ) )then return end
		if( table.HasValue( door.DoorUsers, user ) )then return end
		table.insert( door.DoorUsers, user )
		
		net.Start("NRP_SendDoorUser")
			net.WriteEntity( door )
			net.WriteEntity( user )
		net.Send( player.GetAll() )
	end)
	
	NRP.AddChatCommand( 'doordeluser', function( ply, arg )
		local door = GetAimDoor( ply )
		if( not IsValid( door ) )then return end
		
		local uid = tonumber( arg )
		local user = NULL
		for k,v in pairs(door.DoorUsers)do
			if( IsValid( v ) and v:UserID() == uid )then
				table.remove( door.DoorUsers, k )
				break
			end
		end
		
		net.Start("NRP_SendDoorUserTBL")
			net.WriteEntity( door )
			net.WriteTable( door.DoorUsers )
		net.Send( player.GetAll() )
	end)
	
	net.Receive("NRP_RequestDoorUsers",function(length, ply)
		if( length > 255 )then return end
		local door = GetAimDoor( ply )
		if( not door )then return end

		net.Start("NRP_SendDoorUserTBL")
			net.WriteEntity( door )
			net.WriteTable( door.DoorUsers )
		net.Send( ply )
	end)
elseif(CLIENT)then
	net.Receive("NRP_SendDoorUser",function()
		local door = net.ReadEntity( )
		local ply = net.ReadEntity( )
		if( not door.DoorUsers )then door.DoorUsers = {} end
		if( not IsValid( ply ) )then return end -- there are no users yet, we just needed to init the table.
		table.insert( door.DoorUsers, ply )
	end)
	net.Receive("NRP_SendDoorUserTBL",function()
		local door = net.ReadEntity( )
		local plys = net.ReadTable( )
		door.DoorUsers = plys
	end)
end

/*================================
LOAD ALL OF THE DOORS ON THE MAP!
================================*/
if(SERVER)then
	timer.Simple(5, function()
		for k,v in pairs( ents.GetAll() )do
			if( v:IsDoor() )then
				v.id = ( v:GetPos().z * 1000 + v:GetPos().y ) * 1000 + v:GetPos().x -- it is extreamly unlikely two doors will have the same id. Should this occure however it is still unlikely it will cause many errors, only some unpredictable behayvor and weirdness.
				local dat = v:LoadDoorData()
				if( dat )then
					
				else
					v:SaveDoorData()
					v:LoadDoorData() -- we reload the data since some stuff is settup in the load process that isnt done in saving.
				end
			end
		end
	end)
end

-- drawing the wonderful door labels.
if(CLIENT)then
	local doors = {}
	local function DoorCalculations( door )
		if( door.frontCenter and door.backCenter and door.forwardAngle and door.backwardAngle and door.lastAngle and door.lastAngle == door:GetAngles() and door.lastPos == door:GetPos() )then
			return end
		local doorAngles = door:GetAngles()
		door.lastAngle = doorAngles
		door.lastPos = door:GetPos()
		
		local smallFrontVec = Vector( 0, 0, 0)
		local _mins = door:OBBMins()
		local _maxs = door:OBBMaxs()
		local maxS = Vector( 0, 0, 0 )
		maxS.x = math.max( math.abs( _mins.x ), math.abs( _maxs.x ) )
		maxS.y = math.max( math.abs( _mins.y ), math.abs( _maxs.y ) )
		maxS.z = math.max( math.abs( _mins.z ), math.abs( _maxs.z ) )
		
		if( maxS.z == 0 )then maxS.z = 1000 end
		if( maxS.x == 0 )then maxS.x = 1000 end
		if( maxS.y == 0 )then maxS.y = 1000 end
		
		if( maxS.x < maxS.y and maxS.x < maxS.z )then
			smallFrontVec.x = maxS.x
		elseif( maxS.y < maxS.z )then
			smallFrontVec.y = maxS.y
		else
			smallFrontVec.z = maxS.z
		end
		door.frontVec = smallFrontVec
		
		door.center = door:LocalToWorld( door:OBBCenter() )
		door.frontCenter = door:LocalToWorld( door:OBBCenter() + door.frontVec )
		door.backCenter = door:LocalToWorld( door:OBBCenter() - door.frontVec )
		
		local forwardAngle = ( door.frontCenter - door.center ):Angle()
		local backwardAngle = ( door.backCenter - door.center ):Angle()
		forwardAngle:RotateAroundAxis( doorAngles:Up(), 90 )
		backwardAngle:RotateAroundAxis( doorAngles:Up(), 90 )
		door.forwardAngle = forwardAngle + Angle( 0, 0, 90 )
		door.backwardAngle = backwardAngle + Angle( 0, 0, 90 )
	end
	local function CollectDoorTable()
		for k,v in pairs( ents.GetAll() )do
			if( v:IsDoor() and not doors[ v:EntIndex() ])then
				local door = v
				doors[ v:EntIndex() ] = door
			end
		end
		timer.Simple( 5, function()
			CollectDoorTable()
		end)
	end
	CollectDoorTable()
	
	surface.CreateFont( "NRP_DoorLabel",
		{
			font      = "roboto",
			size      = 30,
			weight    = 300
		}
	 )
	 surface.CreateFont( "NRP_DoorLabel_Hand",
		{
			font      = "akbar",
			size      = 30,
			weight    = 300
		}
	 )
	 surface.CreateFont( "NRP_DoorInfo", -- this is not for 2D3D info.
		{
			font      = "roboto",
			size      = 22,
			weight    = 300
		}
	 )
	
	local gradient = Material("gui/center_gradient")
	local function DrawDoor( door, alpha )
		local OBB = door:OBBMaxs() - door:OBBMins()
		local wide = math.max( math.abs( OBB.y ), math.abs( OBB.x ) ) * 10
		--print( OBB2.x.."-"..OBB2.y.."-"..OBB2.z )
		surface.SetMaterial( gradient )
		surface.SetDrawColor(Color( 155,155,155, 255) )
		surface.DrawTexturedRect( -wide / 2, 0, wide , 60 )
		if( IsValid( door:GetNWEntity("owner" ) ) )then
			draw.DrawText( door:GetNWEntity("owner"):Name().."'s Door",  "NRP_DoorLabel",  0,  0,Color( 55, 55, 55, 255 ) ,  TEXT_ALIGN_CENTER )
		elseif( door:Door_GetFlag("disabled" ) == 1 )then
			draw.DrawText( "Unownable Door",  "NRP_DoorLabel",  0,  0,Color( 55, 55, 55, 255 ) ,  TEXT_ALIGN_CENTER )
		elseif( door:Door_GetFlag("team_access" ) == 1 )then
			local pos = 0
			for k,v in pairs( NRP.GetAllTeams() )do
				if( door:Door_GetFlag( "_"..v.command ) == 1 )then
					draw.DrawText( v.name, "NRP_DoorLabel",  0,  pos, team.GetColor( v.id ) ,  TEXT_ALIGN_CENTER )
					pos = pos + 30
				end 
			end
		else
			draw.DrawText( "Unowned Door",  "NRP_DoorLabel",  0,  0,Color( 255, 0, 0, 255 ) ,  TEXT_ALIGN_CENTER )
		end
		draw.DrawText( door:GetNWString("title"),  "NRP_DoorLabel_Hand",  0,  30,Color( 55, 55, 55, 255 ) ,  TEXT_ALIGN_CENTER )
	end
	
	function GM:PostDrawOpaqueRenderables()
		lPos = LocalPlayer():EyePos()
		for k,v in pairs( doors )do
			local dist = v:GetPos():Distance( lPos )
			if( dist < 1000 )then
				local alpha = math.Clamp( 1000 - dist, 0, 255 )
				DoorCalculations( v )
				-- just think about it... the closest surface will be the forward facing one.
				-- so why render the one facing backward?.. this if statement lets us skip it.
				if( lPos:Distance( v.frontCenter ) < lPos:Distance( v.backCenter ))then
					cam.Start3D2D(v.frontCenter, v.forwardAngle, 0.1)
						DrawDoor( v )
					cam.End3D2D()
				else
					cam.Start3D2D(v.backCenter, v.backwardAngle, 0.1)
						DrawDoor( v )
					cam.End3D2D()
				end
			end
		end
	end
	
	
	function GM:HUDPaint()
		local trace = LocalPlayer():GetEyeTrace()
		if( not IsValid( trace.Entity ) )then return end
		local lockable = hook.Call("NeoRP_IsLockable",GAMEMODE, trace.Entity ) -- this hook is handled by the key swep by default.
		if( lockable ~= true )then return end
		local ent = trace.Entity
		if( not IsValid( ent:GetNWEntity("owner")) and not ent:Door_GetFlag("disabled" ) == 1 )then -- stuff to draw when the door is owned.
			draw.SimpleText( "Door is unowned. Press 'Reload' With keys to own.", "NRP_DoorInfo", ScrW() / 2 + 3, ScrH() * 0.6 + 3, Color( 0,0,0,155), TEXT_ALIGN_CENTER)
			draw.SimpleText( "Door is unowned. Press 'Reload' With keys to own.", "NRP_DoorInfo", ScrW() / 2, ScrH() * 0.6, Color( 155,0,0,255), TEXT_ALIGN_CENTER)
		end
		if( not ent.DoorUsers )then
			if( not ent.PendingData )then
				net.Start("NRP_RequestDoorUsers")
				net.SendToServer()
				ent.PendingData = true
				timer.Simple( 2, function()
					ent.PendingData = nil
				end)
			end
		elseif( table.Count( ent.DoorUsers ) > 0 )then
			local dy = ScrH() / 3 * 2 -- y delta.
			surface.SetFont("NRP_DoorInfo")
			surface.SetTextColor( Color( 255, 255, 255 ) )
			surface.SetTextPos( ScrW() / 2 - 50, dy )
			surface.DrawText( "Co-Owners" )
			dy = dy + 30
			for k,v in pairs( ent.DoorUsers )do
				local w, h = surface.GetTextSize( v:Name() )
				surface.SetTextPos( ScrW() / 2 - w/2, dy )
				surface.DrawText( v:Name() )
				dy = dy + h
			end
		end
	end
end

