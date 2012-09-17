--[[
	This file is part of Wildtide's WT Addon Framework
	Wildtide @ Blightweald (EU) / DoomSprout @ forums.riftgame.com
--]]

local toc, data = ...
local AddonId = toc.identifier

-- Load all of the built in media -----------------------------------------------------------------
Library.Media.AddTexture("wtBantoBar", AddonId, "img/BantoBar.png", {"bar", "colorize"})
Library.Media.AddTexture("wtDiagonal", AddonId, "img/Diagonal.png", {"bar", "colorize"})
Library.Media.AddTexture("wtGlaze2", AddonId, "img/Glaze2.png", {"bar", "colorize"})
Library.Media.AddTexture("wtHealbot", AddonId, "img/Healbot.png", {"bar", "colorize"})
Library.Media.AddTexture("wtOrbGreen", AddonId, "img/orb_green.tga", {"orb"})
Library.Media.AddTexture("wtOrbBlue", AddonId, "img/orb_blue.tga", {"orb"})
Library.Media.AddTexture("wtReadyCheck", AddonId, "img/wtReady.png", {"imgset", "readycheck"})
Library.Media.AddTexture("wtRankPips", AddonId, "img/wtRankPips.png", {"imgset", "elitestatus"})
Library.Media.AddTexture("wtRanks24", AddonId, "img/wtRanks24.png", {"imgset", "elitestatus"})
Library.Media.AddTexture("wtRanks38", AddonId, "img/wtRanks38.png", {"imgset", "elitestatus"})
Library.Media.AddTexture("wtSweep", AddonId, "img/Sweep.png", {"imgset", "sweep"})

Library.Media.AddTexture("octanusHeal", AddonId, "img/octanusHeal.png", {"roleHeal"})
Library.Media.AddTexture("octanusDPS", AddonId, "img/octanusDPS.png", {"roleDPS"})
Library.Media.AddTexture("octanusTank", AddonId, "img/octanusTank.png", {"roleTank"})
Library.Media.AddTexture("octanusSupport", AddonId, "img/octanusSupport.png", {"roleSupport"})

Library.Media.AddTexture("octanusHP", AddonId, "img/octanusHP.png", {"bar", "healthBar"})
Library.Media.AddTexture("octanusMana", AddonId, "img/octanusMana.png", {"bar", "manaBar"})
Library.Media.AddTexture("octanusEnergy", AddonId, "img/octanusEnergy.png", {"bar", "energyBar"})

Library.Media.AddTexture("riftMark01", "Rift", "vfx_ui_mob_tag_01.png.dds", {})
Library.Media.AddTexture("riftMark02", "Rift", "vfx_ui_mob_tag_02.png.dds", {})
Library.Media.AddTexture("riftMark03", "Rift", "vfx_ui_mob_tag_03.png.dds", {})
Library.Media.AddTexture("riftMark04", "Rift", "vfx_ui_mob_tag_04.png.dds", {})
Library.Media.AddTexture("riftMark05", "Rift", "vfx_ui_mob_tag_05.png.dds", {})
Library.Media.AddTexture("riftMark06", "Rift", "vfx_ui_mob_tag_06.png.dds", {})
Library.Media.AddTexture("riftMark07", "Rift", "vfx_ui_mob_tag_07.png.dds", {})
Library.Media.AddTexture("riftMark08", "Rift", "vfx_ui_mob_tag_08.png.dds", {})
Library.Media.AddTexture("riftMark09", "Rift", "vfx_ui_mob_tag_tank.png.dds", {})
Library.Media.AddTexture("riftMark10", "Rift", "vfx_ui_mob_tag_heal.png.dds", {})
Library.Media.AddTexture("riftMark11", "Rift", "vfx_ui_mob_tag_damage.png.dds", {})
Library.Media.AddTexture("riftMark12", "Rift", "vfx_ui_mob_tag_support.png.dds", {})
Library.Media.AddTexture("riftMark13", "Rift", "vfx_ui_mob_tag_arrow.png.dds", {})
Library.Media.AddTexture("riftMark14", "Rift", "vfx_ui_mob_tag_skull.png.dds", {})
Library.Media.AddTexture("riftMark15", "Rift", "vfx_ui_mob_tag_no.png.dds", {})
Library.Media.AddTexture("riftMark16", "Rift", "vfx_ui_mob_tag_smile.png.dds", {})
Library.Media.AddTexture("riftMark17", "Rift", "vfx_ui_mob_tag_squirrel.png.dds", {})

Library.Media.AddTexture("riftMark01_mini", "Rift", "vfx_ui_mob_tag_01_mini.png.dds", {})
Library.Media.AddTexture("riftMark02_mini", "Rift", "vfx_ui_mob_tag_02_mini.png.dds", {})
Library.Media.AddTexture("riftMark03_mini", "Rift", "vfx_ui_mob_tag_03_mini.png.dds", {})
Library.Media.AddTexture("riftMark04_mini", "Rift", "vfx_ui_mob_tag_04_mini.png.dds", {})
Library.Media.AddTexture("riftMark05_mini", "Rift", "vfx_ui_mob_tag_05_mini.png.dds", {})
Library.Media.AddTexture("riftMark06_mini", "Rift", "vfx_ui_mob_tag_06_mini.png.dds", {})
Library.Media.AddTexture("riftMark07_mini", "Rift", "vfx_ui_mob_tag_07_mini.png.dds", {})
Library.Media.AddTexture("riftMark08_mini", "Rift", "vfx_ui_mob_tag_08_mini.png.dds", {})
Library.Media.AddTexture("riftMark09_mini", "Rift", "vfx_ui_mob_tag_tank_mini.png.dds", {})
Library.Media.AddTexture("riftMark10_mini", "Rift", "vfx_ui_mob_tag_heal_mini.png.dds", {})
Library.Media.AddTexture("riftMark11_mini", "Rift", "vfx_ui_mob_tag_damage_mini.png.dds", {})
Library.Media.AddTexture("riftMark12_mini", "Rift", "vfx_ui_mob_tag_support_mini.png.dds", {})
Library.Media.AddTexture("riftMark13_mini", "Rift", "vfx_ui_mob_tag_arrow_mini.png.dds", {})
Library.Media.AddTexture("riftMark14_mini", "Rift", "vfx_ui_mob_tag_skull_mini.png.dds", {})
Library.Media.AddTexture("riftMark15_mini", "Rift", "vfx_ui_mob_tag_no_mini.png.dds", {})
Library.Media.AddTexture("riftMark16_mini", "Rift", "vfx_ui_mob_tag_smile_mini.png.dds", {})
Library.Media.AddTexture("riftMark17_mini", "Rift", "vfx_ui_mob_tag_squirrel_mini.png.dds", {})

Library.Media.AddFont("ArmWrestler", AddonId, "font/ArmWrestler.ttf")
Library.Media.AddFont("Bazooka", AddonId, "font/Bazooka.ttf")
Library.Media.AddFont("BlackChancery", AddonId, "font/BlackChancery.ttf")
Library.Media.AddFont("Collegia", AddonId, "font/Collegia.ttf")
Library.Media.AddFont("Disko", AddonId, "font/Disko.ttf")
Library.Media.AddFont("DorisPP", AddonId, "font/DorisPP.ttf")
Library.Media.AddFont("Enigma", AddonId, "font/Enigma.ttf")
Library.Media.AddFont("LiberationSans", AddonId, "font/LiberationSans.ttf")
Library.Media.AddFont("SFAtarianSystem", AddonId, "font/SFAtarianSystem.ttf")


---------------------------------------------------------------------------------------------------
