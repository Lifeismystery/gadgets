--[[ 
	This file is part of Wildtide's WT Addon Framework 
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com

	WT.UnitFrame
	
		Inherits from Frame
		
		Provides a base class for the implementation of unit frames. A unit frame is linked to a
		unit specifier, and provides a mechanism for binding properties on a unit to function calls
		allowing a unit frame to automatically update itself as the underlying unit state changes.

	API
	
		Static Methods
		
			WT.UnitFrame.CreateFromTemplate(templateName, unitSpec)
				Creates an instance of a unit frame based on the requested template, linked to the requested
				unit specifier.
		
			WT.UnitFrame:Create(unitSpec)
				Create an instance of a unit frame and attach it to @unitSpec

			WT.UnitFrame.UniqueName()
				Generates a unique frame name (utility method to ease creation of frames)

			WT.UnitFrame:Template(templateName)
				Creates a subclass of WT.UnitFrame, which is expected to provide a template for
				new unit frame create.

		Instance Methods

			unitFrame:CreateBinding(property, bindToObject, bindToMethod, default, converter)
				Creates a binding between the property, and a method on an object. Whenever the property
				changes, the binding method will be called with the value of the property, unless the value 
				is nil/false where the default is used.
				If a converter function is provided, any non-default values will be passed through this
				function prior to the method being called. 

			unitFrame:CreateTokenBinding(tokenString, bindToObject, bindToMethod, default, converter)
				Creates a binding between a token string and an object method. The token string can contain
				plain text and tokens wrapped in braces {}. Tokens are replaced by the property with the same 
				name, e.g. {name} will be replaced by the unit's name.
				Note: Every token in the token string must be backed by a property with a value. If any
				of the properties are not available, the default value is returned.
				Example usage: uf:CreateTokenBinding("{health}/{healthMax}", txtHealth, txtHealth.SetText, "") 

			unitFrame:CreateTextField(property, default, parentFrame)
				Creates a new Text frame, automatically bound to the provided property.
				The default value is "" if not provided.
				The parentFrame defaults to the UnitFrame itself.

			unitFrame:CreateTokenField(tokenString, default, parentFrame)
				Creates a new Text frame, automatically bound to the provided token string.
				The default value is "" if not provided.
				The parentFrame defaults to the UnitFrame itself.

			unitFrame:CreateHorizontalBar(width, height, textureAddon, textureFile, parent)
				Creates a bar frame, which can be used to show health/mana etc. The width and height of the bar
				must be provided, along with the details of a texture to apply to the bar.
				The parent is optional, and will default to the WT.UnitFrame if not provided.
				The returned frame is a Mask, with a Texture frame linked to it. This object has the following
				additional methods to effect the bar:
					:SetPercent(percentage)
						This will set the width of the bar to the provided percentage of its full width
					:SetColor(r,g,b,a)
						This will set the background color of the associated Texture frame. Bar textures have to
						be designed with appropriate transparency for this to have an effect. 

		Subclass Override Methods
		
			unitFrame:OnUnitSet(unitId)
			unitFrame:OnUnitCleared()
			unitframe:OnBuffAdded(buffId, buff, priority)
			unitframe:OnBuffChanged(buffId, buff, priority)
			unitframe:OnBuffRemoved(buffId, buff, priority)
			unitframe:OnCastBegin(castbarDetails)
			unitframe:OnCastEnd()
			
		Instance Properties
		
			Unit		References a Unit from the UnitDatabase, or nil if no current unit
			UnitSpec	The UnitSpec associated with the frame. Do not change this value

		Notes
		
			It is not expected that a client addon will directly create a UnitFrame instance. A WT.UnitFrameTemplate
			should be defined that handles the construction of a specific UnitFrame, and it is this template that will
			implement methods as required.
			
			A client will therefore use WT.CreateUnitFrame(templateName, unitSpec) to create an instance of a unit frame.
			
			For complex bindings to multiple source properties, use a virtual property. These are defined within the 
			unit database, using WT.UnitDatabase.CreateVirtualProperty(...)
--]]

local toc, data = ...
local AddonId = toc.identifier

WT.UnitFrame = {}
WT.UnitFrames = {}
WT.UnitFrame.Templates = {}

-- namespaces for element implementations
WT.Element = {} 
WT.ElementFactories = {}

WT.UnitFrame_mt = 
{ 	
	__index = function(tbl, name)
		-- Check for a property in the class if one is set
		if tbl._class and tbl._class[name] then return tbl._class[name] end
		-- Otherwise check the UI.Frame class for the name and use it
		if WT.UnitFrame._uiFrame_index[name] then return WT.UnitFrame._uiFrame_index[name] end
		-- Give up, it doesn't exist in any of our superclasses
		return nil
	end
}

local unitFrameCount = 0
local awaitingDetails = {}

-- Return a unique name for a frame. Used to ensure all frames are given unique names
function WT.UnitFrame.UniqueName()
	return WT.UniqueName("WT_FRAME")
end


function WT.UnitFrame:Template(templateName)
	local obj = {}
	obj.Template = templateName
	obj.Configuration = {}
	setmetatable(obj, { __index = self })
	WT.UnitFrame.Templates[templateName] = obj
	return obj
end

function WT.UnitFrame.CreateFromTemplate(templateName, unitSpec, options)
	WT.Log.Info("Creating unit frame from template " .. tostring(templateName) .. " for unit " .. tostring(unitSpec))
	local template = WT.UnitFrame.Templates[templateName]
	if not template then return nil end
	return template:Create(unitSpec, options)
end


function WT.UnitFrame:CreateElement(configuration, forceParent)

	if not configuration.type then
		WT.Log.Error("No type specified in element configuration")
		return nil
	end

	if not configuration.id then
		WT.Log.Error("No id specified in element configuration")
		return nil
	end

	if self.Elements[configuration.id] then
		WT.Log.Error("Duplicate element ID " .. tostring(configuration.id))
		return nil
	end

	local factory = WT.ElementFactories[configuration.type]
	if not factory then
		WT.Log.Error("No element factory for type " .. tostring(configuration.type))
		return nil
	end

	local element = factory:Create(self, configuration, forceParent)
	if not element then
		WT.Log.Error("Element factory for " .. tostring(configuration.type) .. " failed to create " .. tostring(configuration.id))
		return nil
	end

	self.Elements[configuration.id] = element
	
	-- Handle common configuration
	
	if configuration.attach then
		for idx, attachTo in ipairs(configuration.attach) do
			local attachToElement = self.Elements[attachTo.element]
			if attachToElement then
				local attachPoint = attachTo.point or "TOPLEFT"
				local attachTargetPoint = attachTo.targetPoint or "TOPLEFT"
				local attachOffsetX = attachTo.offsetX
				local attachOffsetY = attachTo.offsetY
				if attachOffsetX and attachOffsetY then
					element:SetPoint(attachPoint, attachToElement, attachTargetPoint, attachOffsetX, attachOffsetY)
				else
					element:SetPoint(attachPoint, attachToElement, attachTargetPoint)
				end
			else
				WT.Log.Error("Could not find attachTo element: " .. tostring(attachTo.element))
			end
		end	
	end
	
	if configuration.parent then
		local parentElement = self.Elements[configuration.parent]
		if parentElement then
			element:SetParent(parentElement)
		end
	end
		
	if configuration.layer then
		element:SetLayer(configuration.layer)
	end

	if configuration.alpha then
		element:SetAlpha(configuration.alpha)
	end
	
	if configuration.visibilityBinding then
		self:CreateBinding(configuration.visibilityBinding, element, element.SetVisible, false, WT.Utility.ToBoolean)
	end
	
	return element

end

--[[ 
local el = frame:CreateElement
{
	id = "buffPanel01",
	type = "BuffPanel",
	binding = "Buffs",
	anchorTo = { element = self, point = "TOPLEFT", targetPoint = "TOPLEFT", offsetX = 5, offsetY = 5 },
	rows=1, cols=5, iconSize=20, iconSpacing=1, borderThickness=1, 
	acceptLowPriorityBuffs=true, acceptMediumPriorityBuffs=true, acceptHighPriorityBuffs=true, acceptCriticalPriorityBuffs=true,
	acceptLowPriorityDebuffs=false, acceptMediumPriorityDebuffs=false, acceptHighPriorityDebuffs=false, acceptCriticalPriorityDebuffs=false,
	growthDirection = "left_up"
}
--]]

-- Creates a new instance of a UnitFrame, which inherits from UI.Frame
-- This uses a prototype based approach to inheritance. It inherits from a Frame instance so that
-- a UnitFrame has all of the Layout functionality of a Frame, but it also adds in all of the methods
-- from the UnitFrame class by adding in references
-- If an options table is included in this call, it will be passed to the Construct function to provide options
-- for use by the template.
function WT.UnitFrame:Create(unitSpec, options)

	local frameName = WT.UniqueName("WT_UNITFRAME", unitSpec)
	
	if not self.Configuration then self.Configuration = {} end
	
	local frame = UI.CreateFrame(self.Configuration.FrameType or "Frame", frameName, WT.Context)
	if self.Configuration.Width then frame:SetWidth(self.Configuration.Width) end
	if self.Configuration.Height then frame:SetHeight(self.Configuration.Height) end

	-- store a reference to the subclass that is actually being created
	frame._class = self
	
	if not WT.UnitFrame._uiFrame_index then
		WT.UnitFrame._uiFrame_index = getmetatable(frame).__index
	end
	
	setmetatable(frame, WT.UnitFrame_mt) 
	
	-- Manually add in the UnitFrame methods. This means that the metatable will be used to access the 
	-- base Frame, while also having UnitFrame functionality available. 
	--for k,v in pairs(WT.UnitFrame) do frame[k] = v end
	
	frame.UnitId = false
	frame.UnitSpec = unitSpec
	frame.Bindings = {}
	frame.Elements = {}	
		
	frame.Elements["frame"] = frame
		
	-- Store the UnitFrame in the global list of frames
	table.insert(WT.UnitFrames, frame)	
	
	if frame.Construct then frame:Construct(options) end
	
	frame:ApplyDefaultBindings()
	
	-- Track changes to the linked UnitId, and call into PopulateUnit
	table.insert(Library.LibUnitChange.Register(unitSpec), { function(unitId) frame:PopulateUnit(unitId) end,  AddonId, AddonId .. "_UnitFrame_OnUnitChange_" .. frameName })
	
	local unitId = Inspect.Unit.Lookup(unitSpec)
	if unitId then frame:PopulateUnit(unitId) end
	
	return frame
end


function WT.UnitFrame:PopulateUnit(unitId)
	self.UnitId = unitId
	if unitId then
		self.Unit = WT.UnitDatabase.GetUnit(unitId)
		if not self.Unit then
			awaitingDetails[self] = true
		else
			if self.OnUnitSet then
				self:OnUnitSet(unitId)
			end
			self:ApplyBindings()
			if self.OnBuffAdded then
				for buffId, buff in pairs(self.Unit.Buffs) do
					local buffPriority = self:GetBuffPriority(buff)
					if buffPriority > 0 then
						self:OnBuffAdded(buffId, buff, buffPriority) 
					end
				end
			end
		end
	else
		self.Unit = nil
		if self.OnUnitCleared then
			self:OnUnitCleared()
		end	
		self:ApplyDefaultBindings()
	end
end


-- Creates a binding from a property to an object method
function WT.UnitFrame:CreateBinding(property, bindToObject, bindToMethod, default, converter)
	WT.Log.Debug(self.UnitSpec .. ": Creating binding for " .. property)
	-- Create the binding object
	local binding = {}
	binding.property = property
	binding.object = bindToObject
	binding.method = bindToMethod
	binding.default = default
	binding.converter = converter
	-- Add the binding to the UnitFrame's bindings list
	if not self.Bindings[property] then self.Bindings[property] = {} end	
	table.insert(self.Bindings[property], binding)
end


-- Creates a binding from a token string
function WT.UnitFrame:CreateTokenBinding(tokenString, bindToObject, bindToMethod, default)

	local tokens = {}
	local tokenCount = 0
	for token in string.gmatch(tokenString, "{(%w+)}") do
		tokens[token] = true
		tokenCount = tokenCount + 1
	end
	
	if tokenCount == 0 then
		-- This is just a static text label, there are no tokens in it
		bindToObject:SetText(tokenString)
		return
	end
	
	local function fn(bindingObject, dummyValue)
		if not self.Unit then 
			bindToMethod(bindToObject, default)
			return 
		end
		local text = tokenString
		for token in pairs(tokens) do
			if not self.Unit[token] then 
				bindToMethod(bindToObject, default)
				return 
			end
			local tokenValue = self.Unit[token]
			if type(tokenValue) == "number" then 
				tokenValue = math.ceil(tokenValue)
				if (tokenValue >= 1000000) then 
					tokenValue = string.format("%.1f", tokenValue / 1000000) .. "M" 
				elseif tokenValue >= 10000 then
					tokenValue = string.format("%.1f", tokenValue / 1000) .. "K" 
				end 
			end
			text = text:gsub("{" .. token .. "}", tokenValue)
		end
		bindToMethod(bindToObject, text)
	end

	for dependency in pairs(tokens) do
		-- This is where we need to register the dependencies to trigger this binding
		-- Uses standard bindings to trigger the binding function above
		self:CreateBinding(dependency, bindToObject, fn, default)
	end

end

-- Applies the default values to all bindings on this unit frame
function WT.UnitFrame:ApplyDefaultBindings()
	if self.Bindings then
		for property, bindings in pairs(self.Bindings) do
			for idx, binding in pairs(bindings) do
				WT.Log.Debug("AppyDefaultBinding: " .. binding.property)
				binding.method(binding.object, binding.default)
			end
		end
	end
end


-- Applies the bindings on this unit frame
function WT.UnitFrame:ApplyBindings()
	if self.Unit and self.Bindings then
		for property, bindings in pairs(self.Bindings) do
			for idx, binding in pairs(bindings) do
				local value = self.Unit[property]
				if binding.converter then value = binding.converter(value) end
				binding.method(binding.object, value or binding.default)
			end
		end
	else
		self:ApplyDefaultBindings()
	end
end


-- This is the default implementation of the buff filter method. It will always respond with 2, meaning normal priority.
-- A buff filter takes buff details as a parameter, and returns a number between 0 and 4 as follows:
-- 0 - Ignore this buff
-- 1 - Low priority buff. First to drop off if no space
-- 2 - Medium priority buff. This is a normal buff/debuff. Will take priority over low if necessary.
-- 3 - High priority buff. This takes priority over normal buffs, and may be highlighted/larger if the template allows.
-- 4 - Critical buff. This would usually be a debuff, and the template should highlight it. This should be a debuff that
--     the player needs to respond to urgently. 
function WT.UnitFrame:GetBuffPriority(buff)
	return 2
end


-- Returns an iterator for up to maxBuffs buffs from the associated unit, in priority sequence
function WT.UnitFrame:GetBuffs(maxBuffs)

	local remaining = {}
	local returned = 0
	local currPriority = 4
	
	if self.Unit then
		for buffId, buff in pairs(self.Unit.Buffs) do
			remaining[buffId] = self:GetBuffPriority(buff)
		end
	end

	return function()
		if not self.Unit then return nil end
		if returned >= (maxBuffs or 9999) then return nil end
		while currPriority > 0 do
			for k,v in pairs(remaining) do
				if v == currPriority then
					remaining[k] = nil
					returned = returned + 1
					return k, self.Unit.Buffs[k]
				end
			end
			currPriority = currPriority - 1
		end
	end

end


-- Gadget Factory Function for single UnitFrame
function WT.UnitFrame.CreateFromConfiguration(configuration)
	local template = configuration.template
	local unitSpec = configuration.unitSpec
	
	if not template then print("Missing required configuration item: template") return end
	if not unitSpec then print("Missing required configuration item: unitSpec") return end
	
	WT.Log.Debug("Creating UnitFrame from configuration: template=" .. template .. " unitSpec=" .. unitSpec)
	return WT.UnitFrame.CreateFromTemplate(template, unitSpec, configuration)
end

-- Gadget Factory Function for grid of 20 UnitFrames
function WT.UnitFrame.CreateRaidFramesFromConfiguration(configuration)
	local template = configuration.template
	local layout = configuration.layout or "4 x 5"
	WT.Log.Debug("Creating RaidFrames from configuration: template=" .. template)
	
	local wrapper = UI.CreateFrame("Frame", WT.UniqueName("RaidFrames"), WT.Context)
	
	-- Unfortunately, if we want click targeting, we have to restrict things
	-- Will show a faded rectangle beneath the frames to give a hint as to why you can't click through invisible frames
	if configuration.clickToTarget then
		wrapper:SetBackgroundColor(0,0,0,0.2)
	end
	wrapper:SetSecureMode("restricted")
	-- Pass through our clickToTarget preference to the template to allow it to set itself up appropriately
	--if not configuration.templateOptions then configuration.templateOptions = {} end
	--configuration.templateOptions.clickToTarget = configuration.clickToTarget 
	
	local frames = {}
	frames[1] = WT.UnitFrame.CreateFromTemplate(template, "group01", configuration)
	frames[1]:SetPoint("TOPLEFT", wrapper, "TOPLEFT")
	frames[1]:SetParent(wrapper)
	
	for i = 2,20 do
		frames[i] = WT.UnitFrame.CreateFromTemplate(template, string.format("group%02d", i), configuration)
		frames[i]:SetParent(wrapper)
		if ((i-1) % 5) == 0 then
			frames[i]:SetPoint("TOPLEFT", frames[i-5], "TOPRIGHT", 1, 0)
		else
			frames[i]:SetPoint("TOPLEFT", frames[i-1], "BOTTOMLEFT", 0, 1)
		end
	end
	
	-- Layout the frames appropriately
	if layout == "5 x 4" then
		for i = 2,20 do
			if ((i-1) % 5) ~= 0 then 
				frames[i]:SetPoint("TOPLEFT", frames[i-1], "TOPRIGHT")
			else 
				frames[i]:SetPoint("TOPLEFT", frames[i-5], "BOTTOMLEFT") 
			end
		end
	elseif layout == "2 x 10" then
		for i = 2,20 do
			if ((i-1) % 10) ~= 0 then 
				frames[i]:SetPoint("TOPLEFT", frames[i-1], "BOTTOMLEFT")
			else 
				frames[i]:SetPoint("TOPLEFT", frames[i-10], "TOPRIGHT") 
			end
		end
	elseif layout == "10 x 2" then
		for i = 2,20 do
			if ((i-1) % 10) ~= 0 then 
				frames[i]:SetPoint("TOPLEFT", frames[i-1], "TOPRIGHT")
			else 
				frames[i]:SetPoint("TOPLEFT", frames[i-10], "BOTTOMLEFT") 
			end
		end
	elseif layout == "1 x 20" then
		for i = 2,20 do
			frames[i]:SetPoint("TOPLEFT", frames[i-1], "BOTTOMLEFT")
		end
	elseif layout == "20 x 1" then
		for i = 2,20 do
			frames[i]:SetPoint("TOPLEFT", frames[i-1], "TOPRIGHT")
		end
	else -- "4 x 5"
		for i = 2,20 do
			if ((i-1) % 5) ~= 0 then 
				frames[i]:SetPoint("TOPLEFT", frames[i-1], "BOTTOMLEFT")
			else 
				frames[i]:SetPoint("TOPLEFT", frames[i-5], "TOPRIGHT") 
			end
		end
	end
	
	local left = frames[1]:GetLeft()
	local top = frames[1]:GetTop()
	local right = frames[20]:GetRight()
	local bottom = frames[20]:GetBottom()
		
	wrapper:SetWidth(right - left + 1)	
	wrapper:SetHeight(bottom - top + 1)	
	return wrapper
end

-- Event Handlers --------------------------------------------------------------------------------

local function OnUnitAdded(unitId)
	for frame in pairs(awaitingDetails) do
		if frame.UnitId == unitId then
			frame:PopulateUnit(frame.UnitId)
			awaitingDetails[frame] = nil
		end
	end
	-- Need to rescan if a unit has become available again (e.g. after zoning)
	for idx, frame in ipairs(WT.UnitFrames) do
		if frame.UnitId == unitId then
			frame:PopulateUnit(unitId)
		end
	end
end


local function OnUnitPropertySet(unit, property, newValue, oldValue)
	WT.Log.Verbose("PropertySet binding search: " .. tostring(unit.id) .. ":" .. property)
	-- Execute the bindings for any UnitFrame that is currently linked to this unit
	for idx, unitFrame in ipairs(WT.UnitFrames) do
		if unitFrame.Unit and unitFrame.Unit.id == unit.id and unitFrame.Bindings[property] then
			for idx, binding in ipairs(unitFrame.Bindings[property]) do
				local value = newValue
				if binding.converter then value = binding.converter(value) end
				binding.method(binding.object, value or binding.default)
			end
		end
	end
end

local function OnBuffAdded(unitId, buffId, buff)
	for idx, unitFrame in ipairs(WT.UnitFrames) do
		local buffPriority = unitFrame:GetBuffPriority(buff)
		if buffPriority > 0 and unitFrame.Unit and unitFrame.UnitId == unitId and unitFrame.OnBuffAdded then
			unitFrame:OnBuffAdded(buffId, buff, buffPriority) 
		end
		-- Trigger any 'Buffs' bindings
		if buffPriority > 0 and unitFrame.Unit and unitFrame.Unit.id == unitId and unitFrame.Bindings["Buffs"] then
			for idx, binding in ipairs(unitFrame.Bindings["Buffs"]) do
				local value = unitFrame.Unit.Buffs
				if binding.converter then value = binding.converter(value) end
				binding.method(binding.object, value or binding.default)
			end
		end
	end
end

local function OnBuffChanged(unitId, buffId, buff)
	for idx, unitFrame in ipairs(WT.UnitFrames) do
		local buffPriority = unitFrame:GetBuffPriority(buff)
		if buffPriority > 0 and unitFrame.Unit and unitFrame.UnitId == unitId and unitFrame.OnBuffChanged then
			unitFrame:OnBuffChanged(buffId, buff, buffPriority)
		end
		-- Trigger any 'Buffs' bindings
		if buffPriority > 0 and unitFrame.Unit and unitFrame.Unit.id == unitId and unitFrame.Bindings["Buffs"] then
			for idx, binding in ipairs(unitFrame.Bindings["Buffs"]) do
				local value = unitFrame.Unit.Buffs
				if binding.converter then value = binding.converter(value) end
				binding.method(binding.object, value or binding.default)
			end
		end
	end
end

local function OnBuffRemoved(unitId, buffId, buff)
	for idx, unitFrame in ipairs(WT.UnitFrames) do
		local buffPriority = unitFrame:GetBuffPriority(buff)
		if buffPriority > 0 and unitFrame.Unit and unitFrame.UnitId == unitId and unitFrame.OnBuffRemoved then
			unitFrame:OnBuffRemoved(buffId, buff, buffPriority)
		end
		-- Trigger any 'Buffs' bindings
		if buffPriority > 0 and unitFrame.Unit and unitFrame.Unit.id == unitId and unitFrame.Bindings["Buffs"] then
			for idx, binding in ipairs(unitFrame.Bindings["Buffs"]) do
				local value = unitFrame.Unit.Buffs
				if binding.converter then value = binding.converter(value) end
				binding.method(binding.object, value or binding.default)
			end
		end
	end
end

local function OnCastbarShow(unitId, castbar)
	for idx, unitFrame in ipairs(WT.UnitFrames) do
		if unitFrame.Unit and unitFrame.UnitId == unitId and unitFrame.OnCastBegin then
			unitFrame:OnCastBegin(castbar)
		end
	end
end

local function OnCastbarHide(unitId)
	for idx, unitFrame in ipairs(WT.UnitFrames) do
		if unitFrame.Unit and unitFrame.UnitId == unitId and unitFrame.OnCastEnd then
			unitFrame:OnCastEnd()
		end
	end
end


-- Register for change events from the UnitDatabase
table.insert(WT.Event.UnitAdded, { OnUnitAdded, AddonId, AddonId .. "_UnitFrame_UnitAdded" })
table.insert(WT.Event.UnitPropertySet, { OnUnitPropertySet, AddonId, AddonId .. "_UnitFrame_UnitPropertySet" })
table.insert(WT.Event.BuffAdded, { OnBuffAdded, AddonId, AddonId .. "_UnitFrame_BuffAdded" })
table.insert(WT.Event.BuffChanged, { OnBuffChanged, AddonId, AddonId .. "_UnitFrame_BuffChanged" })
table.insert(WT.Event.BuffRemoved, { OnBuffRemoved, AddonId, AddonId .. "_UnitFrame_BuffRemoved" })
table.insert(WT.Event.CastbarShow, { OnCastbarShow, AddonId, AddonId .. "_UnitFrame_CastbarShow" })
table.insert(WT.Event.CastbarHide, { OnCastbarHide, AddonId, AddonId .. "_UnitFrame_CastbarHide" })

-- Set up standard virtual properties

WT.Unit.CreateVirtualProperty("resource", { "mana", "power", "energy" }, 
	function(unit) 
		return unit.mana or unit.energy or unit.power 
	end)
	
WT.Unit.CreateVirtualProperty("resourceMax", { "manaMax", "power", "energyMax" }, 
	function(unit)
		if unit.power then
			return 100
		else 
			return unit.manaMax or unit.energyMax
		end 
	end)

WT.Unit.CreateVirtualProperty("healthPercent", { "health", "healthMax" }, 
	function(unit)
		if unit.health and unit.healthMax and unit.healthMax > 0 then
			return (unit.health / unit.healthMax) * 100 
		else 
			return nil
		end 
	end)

WT.Unit.CreateVirtualProperty("chargePercent", { "charge", "chargeMax" }, 
	function(unit)
		if unit.charge then
			return (unit.charge / (unit.chargeMax or 100)) * 100 
		else 
			return nil
		end 
	end)

WT.Unit.CreateVirtualProperty("resourcePercent", { "mana", "power", "energy", "manaMax", "energyMax" }, 
	function(unit)
		if unit.mana and unit.manaMax and unit.manaMax > 0 then
			return (unit.mana / unit.manaMax) * 100 
		elseif unit.energy and unit.energyMax and unit.energyMax > 0 then
			return (unit.energy / unit.energyMax) * 100 
		elseif unit.power then
			return unit.power 
		else 
			return nil
		end 
	end)
	
--[[
WT.Unit.CreateVirtualProperty("resourcePercentText", { "mana", "power", "energy", "manaMax", "energyMax" }, 
	function(unit)
		if unit.mana and unit.manaMax and unit.manaMax > 0 then
			return math.ceil((unit.mana / unit.manaMax) * 100) .. "%" 
		elseif unit.energy and unit.energyMax and unit.energyMax > 0 then
			return math.ceil((unit.energy / unit.energyMax) * 100) .. "%"
		elseif unit.power then
			return unit.power .. "%" 
		else 
			return nil
		end 
	end)
--]]
WT.Unit.CreateVirtualProperty("readyStatus", { "ready" }, 
	function(unit)
		if unit.ready == true then 
			return "ready"
		elseif unit.ready == false then
			return "notready"
		else
			return nil
		end
	end)
	
WT.Unit.CreateVirtualProperty("aggroColor", { "aggro", "combat" },
	function(unit)
		if unit.aggro then
			return { r = 0.8, g=0, b = 0, a=1 }
		--elseif unit.combat then
			--return { r = 0.8, g=0.8, b = 0, a=0.6 }
		else
			return { r = 0, g=0, b = 0, a=0.8 }
		end
	end)

WT.Unit.CreateVirtualProperty("dead", { "health", "combat" },
	function(unit)
		if unit.health and unit.health == 0 then
			return "Dead"
		else
			return nil
		end
	end)

WT.Unit.CreateVirtualProperty("rank", { "relation", "tier" },
	function(unit)
		local rel = unit.relation or "neutral"
		local tier = unit.tier or "normal"
		return rel .. tier
	end)
	