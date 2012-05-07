--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier

local chargeFontSize = 18

-- Displays current Planar Charge count

local function Create(configuration)

	local chargeMeter = WT.UnitFrame:Create("player")
	chargeMeter:SetWidth(48)
	chargeMeter:SetHeight(48)
	chargeMeter:SetLayer(100)

	chargeMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="imgCharge", type="Image", parent="frame", layer=0, alpha=0.8,
		attach = {
			{ point="TOPLEFT", element="frame", targetPoint="TOPLEFT" },
			{ point="BOTTOMRIGHT", element="frame", targetPoint="BOTTOMRIGHT" },
		},
		texAddon=AddonId, texFile="img/wtPlanarCharge.png",
		backgroundColor={r=0, g=0, b=0, a=0.4}
	});
	chargeMeter.txt01 = chargeMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="chargeShadow", type="Label", parent="frame", layer=19,
		attach = {{ point="CENTER", element="imgCharge", targetPoint="CENTER", offsetX=1, offsetY=1 }},
		text="{planar}", fontSize=chargeFontSize, color={r=0,g=0,b=0,a=1}, alpha=0.8,
	});
	chargeMeter.txt02 = chargeMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="chargeShadow2", type="Label", parent="frame", layer=19,
		attach = {{ point="CENTER", element="imgCharge", targetPoint="CENTER", offsetX=-1, offsetY=-1 }},
		text="{planar}", fontSize=chargeFontSize, color={r=0,g=0,b=0,a=1}, alpha=0.8,
	});
	chargeMeter.txt03 = chargeMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="chargeLabel", type="Label", parent="frame", layer=20,
		attach = {{ point="CENTER", element="imgCharge", targetPoint="CENTER", offsetX=0, offsetY=0 }},
		text="{planar}", fontSize=chargeFontSize,
	});

	chargeMeter.txtHover = chargeMeter:CreateElement(
	{
		-- Generic Element Configuration
		id="chargeHover", type="Label", parent="frame", layer=20,
		attach = {{ point="TOPCENTER", element="frame", targetPoint="BOTTOMCENTER", offsetX=0, offsetY=-3 }},
		text="{planar}/{planarMax}", fontSize=12,
	});
	chargeMeter.txtHover:SetVisible(false)

	chargeMeter.Event.MouseIn = function() chargeMeter.txtHover:SetVisible(true) end
	chargeMeter.Event.MouseOut = function() chargeMeter.txtHover:SetVisible(false) end

	chargeMeter.OnResize = function(frame, width,height)
		chargeMeter.txt01:SetFontSize(height*0.66)
		chargeMeter.txt02:SetFontSize(height*0.66)
		chargeMeter.txt03:SetFontSize(height*0.66)
		chargeMeter.txtHover:SetFontSize(height*0.50)
	end

	return chargeMeter, { resizable = { 24,24, 64,64 } }
end


WT.Gadget.RegisterFactory("PlanarCharge",
	{
		name="Planar Charge",
		description="Display Planar Charge",
		author="Wildtide",
		version="1.0.0",
		iconTexAddon=AddonId,
		iconTexFile="img/wtPlanarCharge.png",
		["Create"] = Create,
	})

