local toc, data = ...
local AddonId = toc.identifier

-- Local config options ---------------------------------------------------------
local standardFrameWidth = 176
local standardFrameTopBarHeight = 30
local standardFrameBottomBarHeight = 16
local standardFrameMargin = 2
local standardFrameHeight = standardFrameTopBarHeight + standardFrameBottomBarHeight + 2 
---------------------------------------------------------------------------------

-- Frame Configuration Options --------------------------------------------------
local StandardFrame = WT.UnitFrame:Template("StandardFrameUpsideDown")
StandardFrame.Configuration.Name = "Default Unit Frame Upside Down"
StandardFrame.Configuration.RaidSuitable = false
StandardFrame.Configuration.FrameType = "Frame"
StandardFrame.Configuration.Width = standardFrameWidth + 2
StandardFrame.Configuration.Height = standardFrameHeight
StandardFrame.Configuration.Resizable = { 140, 40, 300, 70 }
---------------------------------------------------------------------------------

-- Override the buff filter to hide some buffs ----------------------------------
local buffPriorities = 
{
	["Track Wood"] = 0,
	["Track Ore"] = 0,
	["Track Plants"] = 0,
	["Rested"] = 0,
	["Prismatic Glory"] = 0,
	["Looking for Group Cooldown"] = 0,
}
function StandardFrame:GetBuffPriority(buff)
	if not buff then return 2 end
	return buffPriorities[buff.name] or 2
end
---------------------------------------------------------------------------------


local function configDialog(container)
	return WT.Dialog(container)
		:Heading("Standard Unit Frame Template")
		:Label("There are no additional options for this template")
end


function StandardFrame:Construct(options)

	local elements = 
	{
		{
			id="frameBackdrop", type="Frame", parent="frame", layer=0,
			attach = 
			{ 
				{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
				{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" } 
			}, 				
			visibilityBinding="id",
			texAddon = AddonId, texFile = "img/wtMiniFrame_bg.png", alpha=0.8,
			color={r=0,g=0,b=0,a=0.4}, colorBinding="aggroColor",
		}, 
		{
			id="frameBlocked", type="Frame", parent="frameBackdrop", layer=15, visibilityBinding="blocked",
			color={r=0,g=0,b=0},alpha=0.6,
			attach = 
			{ 
				{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=1, offsetY=1 },
				{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT", offsetX=-1, offsetY=-1 } 
			},
		}, 
		{
			id="barResource", type="Bar", parent="frameBackdrop", layer=10,
			attach = 
			{
				{ point="BOTTOMLEFT", element="frameBackdrop", targetPoint="BOTTOMLEFT", offsetX=1, offsetY=-1 },
				{ point="RIGHT", element="frameBackdrop", targetPoint="RIGHT", offsetX=-1 },
			},
			binding="resourcePercent", height=standardFrameBottomBarHeight, colorBinding="resourceColor",
			texAddon=AddonId, texFile="img/Diagonal.png",
			backgroundColor={r=0, g=0, b=0, a=1}
		},
		{
			id="barHealth", type="Bar", parent="frameBackdrop", layer=10,
			attach = {
				{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT", offsetX=1, offsetY=1 },
				{ point="BOTTOMRIGHT", element="barResource", targetPoint="TOPRIGHT" },
			},
			growthDirection="right",
			binding="healthPercent", color={r=0,g=0.7,b=0,a=1}, 
			texAddon=AddonId, texFile="img/Diagonal.png", 
			backgroundColor={r=0, g=0, b=0, a=1}
		},
		{
			id="labelHealth", type="Label", parent="barHealth", layer=20,
			attach = {{ point="CENTERLEFT", element="barHealth", targetPoint="CENTERLEFT" }},
			visibilityBinding="health",
			text=" {health}/{healthMax}", default="",
			--linkedHeightElement = "barHealth",
			--linkedHeightScale = 0.5, 
			fontSize=12
		},
		{
			id="labelHealthR", type="Label", parent="barHealth", layer=20,
			attach = {{ point="CENTERRIGHT", element="barHealth", targetPoint="CENTERRIGHT" }},
			visibilityBinding="health",
			text="{healthPercent}%", default="", fontSize=12
		},
		{
			id="imgRole", type="ImageSet", parent="frameBackdrop", layer=20,
			attach = {{ point="TOPLEFT", element="frameBackdrop", targetPoint="BOTTOMLEFT", offsetX=3, offsetY=3 }}, visibilityBinding="role",
			-- Type Specific Element Configuration
			texAddon=AddonId, texFile="img/Roles12.png", nameBinding="role", cols=1, rows=5, 
			names = { ["tank"] = 0, ["heal"] = 1, ["dps"] = 2, ["support"] = 3 }, defaultIndex = "hide"
		},
		{
			id="imgRank", type="ImageSet", parent="frame", layer=50, 
			attach = {{ point="CENTER", element="frameBackdrop", targetPoint="TOPRIGHT", offsetX=-2, offsetY=2 }}, visibilityBinding="rank",
			texAddon=AddonId, texFile="img/RankPips.png", nameBinding="rank", cols=3, rows=3, 
			names ={ 
				["neutralnormal"] = 0, ["neutralgroup"] = 1, ["neutralraid"] = 2,
				["hostilenormal"] = 3, ["hostilegroup"] = 4, ["hostileraid"] = 5,
				["friendlynormal"] = 6, ["friendlygroup"] = 7, ["friendlyraid"] = 8,
				 }, defaultIndex = "hide"
		},
		{
			id="labelName", type="Label", parent="frameBackdrop", layer=20,
			attach = {{ point="CENTERLEFT", element="imgRole", targetPoint="CENTERRIGHT" }},
			visibilityBinding="name",
			text="{nameShort}", default="", fontSize=14
		},
		{
			id="labelresource", type="Label", parent="barResource", layer=20,
			attach = {{ point="CENTERLEFT", element="barResource", targetPoint="CENTERLEFT" }},
			visibilityBinding="resource",
			text=" {resource}/{resourceMax}", default="", fontSize=10
		},
		{
			id="labelresourceR", type="Label", parent="barResource", layer=20,
			attach = {{ point="CENTERRIGHT", element="barResource", targetPoint="CENTERRIGHT" }},
			visibilityBinding="resource",
			text="{resourcePercent}%", default="", fontSize=10
		},
		{
			id="labelDetails", type="Label", parent="frameBackdrop", layer=20,
			attach = {{ point="TOPRIGHT", element="frameBackdrop", targetPoint="BOTTOMRIGHT", offsetX=0, offsetY=-2 }},
			visibilityBinding="level",
			text="{level} {callingText}", default="", fontSize=10
		},
		{
			id="barCast", type="Bar", parent="frameBackdrop", layer=25,
			attach = {
				{ point="TOPLEFT", element="barResource", targetPoint="TOPLEFT" },
				{ point="BOTTOMRIGHT", element="barResource", targetPoint="BOTTOMRIGHT" },
			},
			visibilityBinding="castName",
			binding="castPercent",
			texAddon=AddonId, texFile="img/BantoBar.png", colorBinding="castColor",
			backgroundColor={r=0, g=0, b=0, a=0.7}
		},
		{
			id="labelCast", type="Label", parent="frameBackdrop", layer=26,
			attach = {{ point="CENTERLEFT", element="barCast", targetPoint="CENTERLEFT", offsetX=6, offsetY=0 }},
			visibilityBinding="castName",
			text="{castName}", default="", fontSize=11
		},

		{
			id="labelMark", type="Label", parent="frameBackdrop", layer=30,
			attach = {{ point="CENTER", element="frameBackdrop", targetPoint="CENTER", offsetX=20, offsetY=0 }},
			visibilityBinding="mark",alpha=0.6,
			text="{mark}", default="X", fontSize=24
		},
		{
			id="imgReady", type="ImageSet", parent="frameBackdrop", layer=30,
			attach = {{ point="CENTER", element="frame", targetPoint="CENTER" }}, -- visibilityBinding="id",
			texAddon=AddonId, texFile="img/wtReady.png", nameBinding="readyStatus", cols=1, rows=2, 
			names = { ["ready"] = 0, ["notready"] = 1 }, defaultIndex = "hide"
		},
		{
			id="buffPanelBuffs", type="BuffPanel", parent="HorizontalBar", layer=30,
			attach = {{ point="BOTTOMLEFT", element="frameBackdrop", targetPoint="TOPLEFT", offsetX=0, offsetY=0 }},
			rows=3, cols=4, iconSize=26, iconSpacingHorizontal=0, iconSpacingVertical=13, borderThickness=1,
			acceptLowPriorityBuffs=true, acceptMediumPriorityBuffs=true, acceptHighPriorityBuffs=true, acceptCriticalPriorityBuffs=true,
			acceptLowPriorityDebuffs=false, acceptMediumPriorityDebuffs=false, acceptHighPriorityDebuffs=false, acceptCriticalPriorityDebuffs=false,
			growthDirection = "right_up", selfCast=false,
			timerSize=10, timerOffsetX=0, timerOffsetY=-19,
			stackSize=12, stackOffsetX=0, stackOffsetY=0, stackBackgroundColor={r=0,g=0,b=0,a=0.7},
			borderColor={r=0,g=0,b=0,a=1},
			sweepOverlay=true,
		},
		{
			id="buffPanelDebuffs", type="BuffPanel", parent="HorizontalBar", layer=30,
			attach = {{ point="BOTTOMRIGHT", element="frameBackdrop", targetPoint="TOPRIGHT", offsetX=0, offsetY=0 }},
			rows=3, cols=2, iconSize=26, iconSpacingHorizontal=0, iconSpacingVertical=13, borderThickness=1, 
			acceptLowPriorityBuffs=false, acceptMediumPriorityBuffs=false, acceptHighPriorityBuffs=false, acceptCriticalPriorityBuffs=false,
			acceptLowPriorityDebuffs=true, acceptMediumPriorityDebuffs=true, acceptHighPriorityDebuffs=true, acceptCriticalPriorityDebuffs=true,
			growthDirection = "left_up",
			timerSize=10, timerOffsetX=0, timerOffsetY=-19,
			stackSize=12, stackOffsetX=0, stackOffsetY=0, stackBackgroundColor={r=0,g=0,b=0,a=0.7},
			borderColor={r=1,g=0,b=0,a=1},
			sweepOverlay=true,
		},
	}
	
	for idx,element in ipairs(elements) do
		if options.excludeBuffs and element.type=="BuffPanel" then
			-- Don't add buff panels if excluding them
		else
			self:CreateElement(element)
		end 
	end
	
	if options.showBackground then
		self:SetBackgroundColor(0,0,0,0.2)
	end
	self:SetSecureMode("restricted")
	self:SetMouseoverUnit(self.UnitSpec)
	self.Event.LeftClick = "target @" .. self.UnitSpec
	self.Event.RightClick = function() if self.UnitId then Command.Unit.Menu(self.UnitId) end end
	
	self.ConfigurationDialog = configDialog
end