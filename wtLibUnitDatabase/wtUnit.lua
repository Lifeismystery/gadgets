--[[ 
	This file is part of Wildtide's WT Addon Framework 
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com

	WT.Unit
	
		Represents a single unit within the Unit Database. There should only ever be one instance
		of a WT.Unit for each unit available in the game.
		
		A Unit implements a shadow copy of the unit table, and catches all property gets and sets. This allows
		it to raise an event every time a property is changed on the unit, filtering out property sets where
		the value doesn't actually change. 

		It also provides a mechanism for creating virtual (calculated) properties on a unit. These are triggered
		by a change in any dependent property, and should appear to be a standard property to clients. A virtual
		property should never have a value directly assigned to it, as this would be overwritten the next time the
		property changes.
		
		Virtual properties are global to the WT library. Recreating a virtual property will issue a warning to the
		WT warning log, and do nothing, which means the initial definition will not be overwritten.  

	API
	
		Class Methods
		
			WT.Unit:Create(unitId)
				Creates a Unit instance linked to the specified unitId
				This will not populate the unit's details automatically. The UnitDatabase handles the population
				as it also manages partial unit details and other special cases. A WT.Unit instance is not expected
				to be used outside of WT.UnitDatabase.
				
		Static Methods
		
			WT.Unit.CreateVirtualProperty(propertyName, dependencies, fn)
				Creates a virtual property called 'propertyName'. The dependencies is an array of built in
				property names. Any changes to these dependency properties will trigger the function fn, which
				is passed the Unit instance, and returns the value of the virtual property.	
			
		Events
		
			WT.Event.UnitPropertySet(unit, propertyName, value, previousValue)
				Event signals a property changing on the specified unit. The new and old values of the property are included.

--]]

local toc, data = ...
local AddonId = toc.identifier

WT.Unit = {}
WT.Unit.VirtualProperties = {}
WT.Unit.VirtualPropertyDependencies = {}

-- Events --------------------------------------------------------------------
WT.Event.Trigger.UnitPropertySet, WT.Event.UnitPropertySet = Utility.Event.Create(AddonId, "UnitPropertySet")

function WT.Unit:Create(unitId)
	local unit = {}
	unit._shadow = {}
	setmetatable(unit, self)
	unit.id = unitId
	return unit
end

function WT.Unit.__index(table, property)
	return table._shadow[property]
end

function WT.Unit.__newindex(table, property, value)
	local oldValue = table._shadow[property]
	if oldValue ~= value then
		WT.Log.Verbose("Unit Property Set " .. tostring(table.id) .. " " .. tostring(property) .. " = " .. tostring(value))
		table._shadow[property] = value
		WT.Event.Trigger.UnitPropertySet(table, property, value, oldValue)
		
		-- does this trigger a virtual property?
		local dependencies = WT.Unit.VirtualPropertyDependencies[property] 
		if dependencies then
			for idx, dependency in ipairs(dependencies) do
				local depValue = dependency.method(table)
				local oldDepValue = table._shadow[dependency.name]
				if depValue ~= oldDepValue then 
					table._shadow[dependency.name] = depValue
					WT.Event.Trigger.UnitPropertySet(table, dependency.name, depValue, oldDepValue)
				end
			end
		end 	
	end
end

function WT.Unit.CreateVirtualProperty(propertyName, dependencies, fn)
	if WT.Unit.VirtualProperties[propertyName] then
		WT.Log.Warning("Duplicate virtual property: " .. propertyName)
		return 
	end
	
	local calc = {}
	calc.name = propertyName
	calc.method = fn
	
	for idx, dependency in ipairs(dependencies) do
		if not WT.Unit.VirtualPropertyDependencies[dependency] then
 			WT.Unit.VirtualPropertyDependencies[dependency] = {}
		end	
		table.insert(WT.Unit.VirtualPropertyDependencies[dependency], calc)
	end
	
	WT.Unit.VirtualProperties[propertyName] = calc
end