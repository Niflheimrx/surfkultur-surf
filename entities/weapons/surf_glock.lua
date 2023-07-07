SWEP.PrintName				= "Glock 18"			
SWEP.Author					= "Fresh"
SWEP.Instructions			= ""

SWEP.Spawnable 				= true
SWEP.AdminOnly 				= false
SWEP.Category				= "BHOP"
SWEP.UseHands 				= true
SWEP.ViewModelFlip 			= false
SWEP.CSMuzzleFlashes		= true
SWEP.BobScale 				= 0.2
SWEP.SwayScale 				= 0.2

SWEP.Primary.ClipSize		= 20
SWEP.Primary.DefaultClip	= 20
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Primary.Sound			= Sound( "Weapon_Glock.Single" )
SWEP.Primary.SoundBurst		= Sound( "Weapon_Glock.Burst" )
SWEP.IsBurst				= false
SWEP.BurstDelay				= 0.5

SWEP.Weight					= 5
SWEP.AutoSwitchTo			= true
SWEP.AutoSwitchFrom			= false

SWEP.Slot					= 1
SWEP.SlotPos				= 2
SWEP.DrawAmmo				= false
SWEP.DrawCrosshair			= true

SWEP.ViewModel				= "models/weapons/cstrike/c_pist_glock18.mdl"
SWEP.WorldModel				= "models/weapons/w_pist_glock18.mdl"

SWEP.Reloading 				= false

function SWEP:PrimaryAttack()
	if self.Reloading then return end
	if self.Weapon:Clip1() <= 0 then return end

	local bullet = {}
	bullet.Num = 1
	bullet.Src = self.Owner:GetShootPos()
	bullet.Dir = self.Owner:GetAimVector()
	bullet.Spread = Vector(0.01,0.01,0)
	bullet.Tracer = 1	
	bullet.Force = 2
	bullet.Damage = 100

	if self.IsBurst then
		self.Weapon:EmitSound( self.Primary.Sound )
		timer.Simple(0.02, function() self.Weapon:EmitSound( self.Primary.Sound ) end)
		timer.Simple(0.04, function() self.Weapon:EmitSound( self.Primary.Sound ) end)
		bullet.Num = 3
		self:TakePrimaryAmmo( 3 )
		self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK ) 
		self.Weapon:FireBullets( bullet, false )
		self.Weapon:SetNextPrimaryFire( CurTime() + self.BurstDelay )
		self.Weapon:SetNextSecondaryFire( CurTime() + self.BurstDelay )
	else
		self.Weapon:EmitSound( self.Primary.Sound )
		self:TakePrimaryAmmo( 1 )
		self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Weapon:FireBullets( bullet, false )
		self.Weapon:SetNextPrimaryFire( CurTime() + 0.1 )
		self.Weapon:SetNextSecondaryFire( CurTime() + 0.1 )
	end

	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	self.Owner:MuzzleFlash()
end
 
function SWEP:SecondaryAttack()
	if self.Reloading then return end
	self.IsBurst = !self.IsBurst

	if self.IsBurst then
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Switched to Burst-Fire mode" )
	else
		self.Owner:PrintMessage( HUD_PRINTCENTER, "Switched to Semi-Automatic" )
	end

	self.Weapon:SetNextSecondaryFire( CurTime() + 0.25 )
end

function SWEP:Reload()
	if self.Reloading then return end
	if self.Weapon:Clip1() >= 20 then return end

	self.Reloading = true
	self.Weapon:DefaultReload( ACT_VM_RELOAD )
	self.Weapon:SetNextPrimaryFire( CurTime() + 1.7 )
	self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
	self.Weapon:SetClip1( 20 )
	self.Owner:SetAnimation( PLAYER_RELOAD )

	timer.Simple(1.7, function()
		if IsValid(self) then
			self.Reloading = false
		end
	end)
end

function SWEP:GetViewModelPosition( pos, ang ) 
	pos = pos + (ang:Forward()*-2) + (ang:Up()*-2) + (ang:Right()*2)

	return pos, ang
end