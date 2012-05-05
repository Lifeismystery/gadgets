--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier

-- wtCPUGadget creates a really simple "CPU" gadget for displaying Frames Per Second

local gadgetIndex = 0
local cpuGadgets = {}

local function Create(configuration)

	local wrapper = UI.CreateFrame("Frame", WT.UniqueName("wtCPU"), WT.Context)
	wrapper:SetWidth(150)
	wrapper:SetHeight(64)
	wrapper:SetBackgroundColor(0,0,0,0.4)

	local cpuHeading = UI.CreateFrame("Text", WT.UniqueName("wtCPU"), wrapper)
	cpuHeading:SetText("ADDON CPU USAGE")
	cpuHeading:SetFontSize(10)

	local cpuFrame = UI.CreateFrame("Text", WT.UniqueName("wtCPU"), wrapper)
	cpuFrame:SetText("")
	cpuFrame:SetFontSize(24)
	cpuFrame.currText = ""

	local txtDetail = UI.CreateFrame("Text", WT.UniqueName("wtCPU"), wrapper)
	txtDetail:SetText("")
	txtDetail:SetFontSize(10)
	cpuFrame.detail = txtDetail

	cpuHeading:SetPoint("TOPCENTER", wrapper, "TOPCENTER", 0, 5)
	cpuFrame:SetPoint("TOPCENTER", cpuHeading, "BOTTOMCENTER", 0, -5)
	txtDetail:SetPoint("TOPCENTER", cpuFrame, "BOTTOMCENTER", 0, -6)

	table.insert(cpuGadgets, cpuFrame)
	return wrapper
end


local dialog = false

local function ConfigDialog(container)	
	dialog = WT.Dialog(container)
		:Label("The CPU monitor displays the percentage of Rift's processing time used by all addons.")
		:Label("A future enhancement to this control is to allow the selection of which addons to monitor.")	
end

local function GetConfiguration()
	return dialog:GetValues()
end

local function SetConfiguration(config)
	dialog:SetValues(config)
end


WT.Gadget.RegisterFactory("CPU",
	{
		name="CPU Monitor",
		description="Display Frames Per Second",
		author="Wildtide",
		version="1.0.0",
		iconTexAddon=AddonId,
		iconTexFile="img/wtCPU.png",
		["Create"] = Create,
		["ConfigDialog"] = ConfigDialog,
		["GetConfiguration"] = GetConfiguration, 
		["SetConfiguration"] = SetConfiguration, 
	})

local function GetCPU()
	local cpuData = Inspect.Addon.Cpu()[AddonId]
	local total = 0
	local ctxrender = 0
	if cpuData then
		for k,v in pairs(cpuData) do
			total = total + v
			if string.find(k, "render time") then ctxrender = ctxrender + v end
			if string.find(k, "update time") then ctxrender = ctxrender + v end
		end
	end
	return total, ctxrender
end


local delta = 0
local function OnTick(frameDeltaTime, frameIndex)
	delta = delta + frameDeltaTime
	if (delta >= 1) then
		delta = 0
		local addons = {}
		local grandTotal = 0
		local renderTotal = 0
		for addonId, cpuData in pairs(Inspect.Addon.Cpu()) do
			if cpuData then
				local total = 0
				for k,v in pairs(cpuData) do
					total = total + v
					if string.find(k, "render time") then renderTotal = renderTotal + v end
					if string.find(k, "update time") then renderTotal = renderTotal + v end
				end
				grandTotal = grandTotal + total
				addons[addonId] = total
			end
		end

		local cpuText = string.format("%.02f%%", grandTotal * 100)
		local detailText = string.format("%.01f%% Process %.01f%% Render", (grandTotal-renderTotal)*100, renderTotal*100)

		for idx, gadget in ipairs(cpuGadgets) do
			gadget:SetText(cpuText)
			gadget.detail:SetText(detailText)
		end
	end
end

table.insert(WT.Event.Tick, { OnTick, AddonId, AddonId .. "_OnTick" })