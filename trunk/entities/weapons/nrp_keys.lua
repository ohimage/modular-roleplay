NRP.LoadMessage(Color(0,0,255),"Loaded Keys")
if CLIENT then
	SWEP.PrintName = "Keys"
	SWEP.Slot = 1
	SWEP.SlotPos = 3
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
	SWEP.Category = "NeoRP Weapons"
end

SWEP.Author = "TheLastPenguin"
SWEP.Instructions = "Left click to lock door. Right click to unlock."
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.ViewModel = Model("models/weapons/v_hands.mdl")
SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "rpg"

SWEP.Spawnable = false
SWEP.AdminSpawnable = true
SWEP.Sound = "doors/door_latch3.wav"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false 
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:Initialize()
	self:SetWeaponHoldType("normal")
end

function SWEP:Deploy()
	if SERVER then
		self.Owner:DrawWorldModel(false)
	end
end

local function PlayerHasTeamAccess( ply, door )
	if( not ply:TeamTbl() )then return false end
	if( door:Door_GetFlag( '_'..ply:TeamTbl().command ) == 1 )then
		print("Player has access!")
		return true
	end
	print("Player doesnt have access!")
	return false
end

local function PlayerCanOpenDoorMenu( ply, door )
	if( NRP.cfg.CanEditDoors( ply ) )then
		return true -- overrides to true.
	elseif( door:Door_GetFlag("disabled") == 1 )then
		return false
	elseif( door:Door_GetFlag("team_access") == 1 )then
		return false
	elseif( IsValid( door:GetNWEntity( "owner" ) ) and door:GetNWEntity( "owner" ) ~= ply )then
		return false -- if the door is owned and the player isnt the owner... no menu for you.
	end
	return true -- defaults to true.
end

local function PlayerCanBuyDoor( ply, door )
	if( IsValid( door:GetNWEntity('owner' ) ) )then return false end
	if( door:Door_GetFlag("team_access") == 1 )then return false end
	if( door:Door_GetFlag("disabled") == 1 )then return false end
	return true
end

local function PlayerCanLockDoor( ply, door )
	if( PlayerHasTeamAccess( ply, door ) )then
		return true
	end
	if( IsValid( door:GetNWEntity('owner' ) ) and door:GetNWEntity('owner') == ply )then
		return true
	end
	if( door.DoorUsers and table.HasValue( door.DoorUsers, ply ) )then
		return true
	end
	return false
end

hook.Add("NeoRP_IsLockable", "If Its a Door", function( ent )
	if( ent:IsDoor() )then return true end
end)
function SWEP:PrimaryAttack()
	if( CLIENT )then return end
	local trace = self.Owner:GetEyeTrace()
	if( trace.StartPos:Distance( trace.HitPos ) > 50 )then return end
	if( not IsValid( trace.Entity ) )then return end
	local lockable = hook.Call("NeoRP_IsLockable",GAMEMODE, trace.Entity )
	if( lockable ~= true )then return end
	local ent = trace.Entity
	local owner = ent:GetNWEntity("owner")
	if( not PlayerCanLockDoor( self.Owner, ent ))then
		NRP.Notice( self.Owner, 6, "You dont own this door.", NOTIFY_ERROR )
		self.Owner:EmitSound("physics/wood/wood_crate_impact_hard2.wav", 100, math.random(90, 110))
		return
	end
	if( ent:GetNWBool("locked") == false )then
		self.Owner:EmitSound("npc/metropolice/gear".. math.floor(math.Rand(1,7)) ..".wav")
		NRP.Notice( self.Owner, 6, "Locked door.", NOTIFY_ERROR )
		ent:SetNWBool("locked", true)
		ent:Fire("lock", "", 0)
	end
end

function SWEP:SecondaryAttack()
	if( CLIENT )then return end
	local trace = self.Owner:GetEyeTrace()
	if( trace.StartPos:Distance( trace.HitPos ) > 50 )then return end
	if( not IsValid( trace.Entity ) )then return end
	local lockable = hook.Call("NeoRP_IsLockable",GAMEMODE, trace.Entity )
	if( lockable ~= true )then return end
	local ent = trace.Entity
	local owner = ent:GetNWEntity("owner")
	if( not PlayerCanLockDoor( self.Owner, ent ))then
		NRP.Notice( self.Owner, 6, "You dont own this door.", NOTIFY_ERROR )
		self.Owner:EmitSound("physics/wood/wood_crate_impact_hard2.wav", 100, math.random(90, 110))
		return
	end
	if( ent:GetNWBool("locked") == true )then
		NRP.Notice( self.Owner, 4, "Unlocked door." )
		self.Owner:EmitSound("npc/metropolice/gear".. math.floor(math.Rand(1,7)) ..".wav")
		ent:SetNWBool("locked", false)
		ent:Fire("unlock", "", 0)
	end
	ent:SaveDoorData()
end

function SWEP:Reload()
	if( CLIENT )then return end
	if( self.NextReload and self.NextReload > CurTime() )then return end
	local trace = self.Owner:GetEyeTrace()
	if( trace.StartPos:Distance( trace.HitPos ) > 50 )then return end
	if( not IsValid( trace.Entity ) )then return end
	local lockable = hook.Call("NeoRP_IsLockable",GAMEMODE, trace.Entity )
	if( lockable ~= true )then return end
	local ent = trace.Entity
	local canOpen, message = PlayerCanOpenDoorMenu( self.Owner, ent )
	if( not canOpen )then 
		if( message )then
			NRP.Notice( ply, 6, message, NOTIFY_ERROR )
		end
		return
	end
	
	self:ShowKeyMenu( ent )
	self.NextReload = CurTime() + 1
end

if(SERVER)then
	util.AddNetworkString("NRP_ShowKeyMenu")
	function SWEP:ShowKeyMenu( door )
		net.Start("NRP_ShowKeyMenu")
			net.WriteEntity( door )
		net.Send( self.Owner )
	end
	local function GetAimDoor( ply )
		local trace = ply:GetEyeTrace()
		if( not IsValid( trace.Entity ) )then return end
		local lockable = hook.Call("NeoRP_IsLockable",GAMEMODE, trace.Entity )
		if( lockable ~= true )then return end
		local door = trace.Entity
		return door
	end
	NRP.AddChatCommand( 'buydoor', function( ply, arg )
		local door = GetAimDoor( ply )
		if( not IsValid( door ) )then return end
		if( not PlayerCanBuyDoor( ply, door ) )then return end
		
		if( ply:CanAfford( NRP.cfg.DoorPrice ) )then
			ply:TakeMoney( NRP.cfg.DoorPrice )
			NRP.Notice( ply, 6, "Bought door for $"..NRP.cfg.DoorPrice..".")
			door:SetNWEntity("owner", ply )
		else
			NRP.Notice( ply, 6, "You need $"..NRP.cfg.DoorPrice.." to buy this door!", NOTIFY_ERROR)
		end
	end)
	
	NRP.AddChatCommand( 'selldoor', function( ply, arg )
		local door = GetAimDoor( ply )
		if( not IsValid( door ) )then return end
		if( not IsValid( door:GetNWEntity( "owner" ) ) or not door:GetNWEntity( "owner" ) == ply )then return end -- the player must own the door.
		ply:GiveMoney( NRP.cfg.DoorSellReturn )
		NRP.Notice( ply, 6, "Sold door $"..NRP.cfg.DoorSellReturn..".")
		door:SetNWEntity("owner", NULL )
	end)
	
	NRP.AddChatCommand( 'setdoortitle', function( ply, arg )
		local door = GetAimDoor( ply )
		if( not IsValid( door ) )then return end
		if(not IsValid( door:GetNWEntity( "owner" ) ) or not door:GetNWEntity( "owner" ) == ply)then return end
		
		if( not arg )then return end
		
		door:SetNWString("title", arg )
		door:SaveDoorData()
	end)
	
	NRP.AddChatCommand( 'doorsetflag', function( ply, arg )
		local door = GetAimDoor( ply )
		if( not NRP.cfg.CanEditDoors( ply ) )then
			print("Player cant edit doors!")
		return end
		if( not IsValid( door ) )then return end
		if( not arg or string.len( arg ) < 3 )then return end
		local eq = string.find( arg, '=' )
		if( not eq )then return end
		local flag = string.sub( arg, 1, eq - 1 )
		local value = string.sub( arg, eq + 1 )
		print("Flag "..flag.." = "..value )
		door:Door_SetFlag( flag, tonumber( value ) )
		
		if( flag[1] == '_' )then -- if we are working with a team flag there's a bit more to do.
			local teams = NRP.GetAllTeams()
			for k,v in pairs( teams )do
				if( door:Door_GetFlag( '_'..v.command ) == 1 )then
					door:Door_SetFlag( "team_access", 1 )
					return
				end
			end
			door:Door_SetFlag( "team_access", 0 )
		end
	end)
	
elseif(CLIENT)then
	local function DoorTeamsMenu( door )
		local teams = NRP.GetAllTeams()
		
		-- select to add or remove teams.
		local EditType = DermaMenu() -- Creates the menu
		EditType:AddOption("Add Teams", function()
			timer.Simple(0,function()
				print("Addin teams")
				local TeamChoices = DermaMenu()
				for k,v in pairs( teams )do
					if( door:Door_GetFlag( '_'..v.command ) ~= 1 )then
						print("Adding team "..v.name )
						TeamChoices:AddOption( v.name, function()
							LocalPlayer():ConCommand("say /doorsetflag _"..v.command.."=1")
						end)
					end
				end
				TeamChoices:Open()
			end)
		end )
		EditType:AddOption("Remove Teams", function()
			timer.Simple(0,function()
				local TeamChoices = DermaMenu()
				for k,v in pairs( teams )do
					if( door:Door_GetFlag( "_"..v.command ) == 1 )then
						TeamChoices:AddOption( v.name, function()
							LocalPlayer():ConCommand("say /doorsetflag _"..v.command.."=0")
						end)
					end
				end 
				TeamChoices:Open()
			end)
		end )
		EditType:Open()
	end
	
	local function UserManagmentMenu( door )
		local ChooseMode = DermaMenu() -- Creates the menu
		ChooseMode:AddOption("Add Users",function()
			timer.Simple(0,function()
				Users = DermaMenu()
				for k,v in pairs( player.GetAll() )do
					if( v ~= LocalPlayer() and not table.HasValue( door.DoorUsers, v ) )then
						Users:AddOption( v:Name(), function()
							LocalPlayer():ConCommand("say /dooradduser "..v:UserID())
						end)
					end
				end
				Users:Open()
			end)
		end)
		ChooseMode:AddOption("Remove Users", function()
			timer.Simple(0,function()
				Users = DermaMenu()
				for k,v in pairs( door.DoorUsers )do
					Users:AddOption( v:Name(), function()
						LocalPlayer():ConCommand("say /doordeluser "..v:UserID() )
					end)
				end
				Users:Open()
			end)
		end)
		ChooseMode:Open()
	end
	
	net.Receive( "NRP_ShowKeyMenu", function()
		local door = net.ReadEntity()
		
		local menu = vgui.Create("DFrame")
			menu:SetSize( 200, 400 )
			menu:SetPos( ScrW() / 2 - menu:GetWide() / 2, ScrH() / 2 - menu:GetTall() / 2 )
			menu:SetVisible( true )
			menu.Paint = function() end
			menu:SetTitle("")
			menu:SetSkin("neorp")
			menu:MakePopup()
		local dlist = vgui.Create("DPanelList", menu)
			dlist:SetSize( menu:GetWide() - 6, menu:GetTall() - 30 )
			dlist:SetPos( 3, 25 )
			dlist:SetPadding( 5 )
			
		if( IsValid( door:GetNWEntity("owner") ) )then
			-- door is owned so we show the door settings menu.
			local b_Sell = vgui.Create("DButton")
			b_Sell:SetImage( "icon16/door.png" )
			b_Sell:SetTall( 40 )
			b_Sell:SetFont( "NRP_DoorInfo" )
			b_Sell:SetText( "Sell door foor $"..NRP.cfg.DoorSellReturn)
			function b_Sell:DoClick()
				LocalPlayer():ConCommand("say /selldoor")
				menu:Close()
			end
			dlist:AddItem( b_Sell )  
			
			local b_SetTitle = vgui.Create("DButton")
			b_SetTitle:SetImage( "icon16/book_edit.png" )
			b_SetTitle:SetTall( 40 )
			b_SetTitle:SetFont( "NRP_DoorInfo" )
			b_SetTitle:SetText( "Set Door Title")
			function b_SetTitle:DoClick()
				title = door:GetNWString("title")
				Derma_StringRequest( "Title?", "Enter new door title: ",  title or "A Door", function( str )
						LocalPlayer():ConCommand("say /setdoortitle "..str )
					end)
				menu:Close()
			end
			dlist:AddItem( b_SetTitle )
			
			
			local b_ManageUsers = vgui.Create("DButton")
			b_ManageUsers:SetImage( "icon16/book_edit.png" )
			b_ManageUsers:SetTall( 40 )
			b_ManageUsers:SetFont( "NRP_DoorInfo" )
			b_ManageUsers:SetText( "Add Door Owner")
			function b_ManageUsers:DoClick()
				UserManagmentMenu( door )
			end
			dlist:AddItem( b_ManageUsers )
		else-- door is unowned so we show the buy menu.
			local b_Buy = vgui.Create("DButton")
			b_Buy:SetImage( "icon16/door.png" )
			b_Buy:SetTall( 40 )
			b_Buy:SetFont( "NRP_DoorInfo" )
			b_Buy:SetText( "Buy Door for $"..NRP.cfg.DoorPrice)
			if( not LocalPlayer():CanAfford( NRP.cfg.DoorPrice ))then
				b_Buy:SetEnabled( false )
			end
			function b_Buy:DoClick()
				LocalPlayer():ConCommand("say /buydoor")
				menu:Close()
			end
			dlist:AddItem( b_Buy )
			
			if( not NRP.cfg.CanEditDoors( LocalPlayer() ) )then return end
			
			/*==========================================
			DISABLE DOOR BUTTON
			==========================================*/
			local b_Disable = vgui.Create("DButton")
			b_Disable:SetTall( 40 )
			b_Disable:SetFont( "NRP_DoorInfo" )
			if( door:Door_GetFlag("disabled") == 1 )then
				b_Disable:SetText( "Enable ownership" )
				b_Disable:SetImage( "icon16/accept.png" )
			else
				b_Disable:SetText( "Disable ownership" )
				b_Disable:SetImage( "icon16/cross.png" )
			end
			function b_Disable:DoClick()
				if( door:Door_GetFlag("disabled") == 1 )then
					LocalPlayer():ConCommand("say /doorsetflag disabled=0\n") 
				else
					LocalPlayer():ConCommand("say /doorsetflag disabled=1\n")
				end
				menu:Close()
			end
			dlist:AddItem( b_Disable )
			
			/*========================================
			DOOR GROUP BUTTON
			========================================*/
			local b_SetDoorTeams = vgui.Create("DButton")
			b_SetDoorTeams:SetText("Set Team Access")
			b_SetDoorTeams:SetTall( 40 )
			b_SetDoorTeams:SetFont( "NRP_DoorInfo" )
			function b_SetDoorTeams:DoClick()
				DoorTeamsMenu( door )
			end
			dlist:AddItem( b_SetDoorTeams )
		end 
	end)
end