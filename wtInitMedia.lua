--[[
                                G A D G E T S
      -----------------------------------------------------------------
                            wildtide@wildtide.net
                           DoomSprout: Rift Forums 
      -----------------------------------------------------------------
      Gadgets Framework   : @project-version@
      Project Date (UTC)  : @project-date-iso@
      File Modified (UTC) : @file-date-iso@ (@file-author@)
      -----------------------------------------------------------------     
--]]

local toc, data = ...
local AddonId = toc.identifier
local TXT = Library.Translate


Library.Media.AddTexture("wtCastInterruptable", AddonId, "img/wtCastInterruptable.png", {"bar"})
Library.Media.AddTexture("wtCastUninterruptable", AddonId, "img/wtCastUninterruptable.png", {"bar"})
Library.Media.AddTexture("wtComboBlue", AddonId, "img/wtComboBlue.png", {"combo"})
Library.Media.AddTexture("wtComboBlueSmall", AddonId, "img/wtComboBlueSmall.png", {"combo"})
Library.Media.AddTexture("wtComboRed", AddonId, "img/wtComboRed.png", {"combo"})
Library.Media.AddTexture("wtVitality", AddonId, "img/wtVitality.png", {"vitality"})
Library.Media.AddTexture("wtPlanarCharge", AddonId, "img/wtPlanarCharge.png", {"planar"})
Library.Media.AddTexture("wtOrbBrightRed", AddonId, "img/wtOrbBrightRed.png", {"orb"})
Library.Media.AddTexture("wtOrbBrightGreen", AddonId, "img/wtOrbBrightGreen.png", {"orb"})
Library.Media.AddTexture("wtOrbBrightBlue", AddonId, "img/wtOrbBrightBlue.png", {"orb"})
Library.Media.AddTexture("wtOrbDarkRed", AddonId, "img/wtOrbDarkRed.png", {"orb"})
Library.Media.AddTexture("wtOrbDarkGreen", AddonId, "img/wtOrbDarkGreen.png", {"orb"})
Library.Media.AddTexture("wtOrbDarkBlue", AddonId, "img/wtOrbDarkBlue.png", {"orb"})

Library.Media.AddTexture("gradientD2L", AddonId, "img/gradientD2L.png", {"bar"})
Library.Media.AddTexture("gradientL2D", AddonId, "img/gradientL2D.png", {"bar"})

Library.Media.AddTexture("HealerBackdrop01", "Rift", "mtx_window_medium_bg_(blue).png.dds", {"backdrop"})
Library.Media.AddTexture("RaidFrameBackdrop01", "Rift", "window_conquest_dominion.png.dds", {"backdrop"})

Library.Media.AddTexture("CP Biohazard", AddonId, "img/combo/combo_Biohazard.png", {"combo"})
Library.Media.AddTexture("CP Bullet Holes", AddonId, "img/combo/combo_BulletHole.png", {"combo"})
Library.Media.AddTexture("CP Cupcakes", AddonId, "img/combo/combo_Cupcake.png", {"combo"})
Library.Media.AddTexture("CP Lips", AddonId, "img/combo/combo_Lips.png", {"combo"})
Library.Media.AddTexture("CP Pink Skulls", AddonId, "img/combo/combo_PinkSkull.png", {"combo"})
Library.Media.AddTexture("CP Target", AddonId, "img/combo/combo_Target.png", {"combo"})

Library.Media.AddTexture("CP Rogue", "Rift", "target_portrait_roguepoints_on.png.dds", {"combo", "combo_single"})
Library.Media.AddTexture("CP Warrior", "Rift", "target_portrait_warrior_hp.png.dds", {"combo", "combo_single"})
Library.Media.AddTexture("CP Skull", "Rift", "vfx_ui_mob_tag_skull.png.dds", {"combo", "combo_single"})
Library.Media.AddTexture("CP Twitter", "Rift", "twitter.png.dds", {"combo", "combo_single"})
Library.Media.AddTexture("CP Red Sword", "Rift", "vfx_ui_mob_tag_damage.png.dds", {"combo", "combo_single"})
Library.Media.AddTexture("CP Squirrel", "Rift", "vfx_ui_mob_tag_squirrel.png.dds", {"combo", "combo_single"})

Library.Media.AddTexture("Vitality_Gray", "Rift", "death_icon_(grey).png.dds", {"vitality"})
Library.Media.AddTexture("Vitality_Red", "Rift", "death_icon_(red).png.dds", {"vitality"})
Library.Media.AddTexture("Vitality_Zero", "Rift", "death_icon_(glow).png.dds", {"vitality"})
-----------------------------------Life-------------------------------------------------------------
Library.Media.AddTexture("1bar", "Rift", "Bank_110.dds", {"bar"})
Library.Media.AddTexture("CharacterSheet", "Rift", "CharacterSheet_I2B.dds", {"bar"})
Library.Media.AddTexture("Merchant", "Rift", "Merchant_I257.dds", {"bar"})
----------------------------------Life----------------------------------------------------------
Library.Media.AddTexture("BantoBar", AddonId, "img/BantoBar.png", {"bar", "colorize"})
Library.Media.AddTexture("Bumps", AddonId, "img/Bumps.png", {"bar", "colorize"})
Library.Media.AddTexture("Diagonal", AddonId, "img/Diagonal.png", {"bar", "colorize"})
Library.Media.AddTexture("Frost", AddonId, "img/Frost.png", {"bar", "colorize"})
Library.Media.AddTexture("Glamour", AddonId, "img/Glamour.png", {"bar", "colorize"})
Library.Media.AddTexture("Grid", AddonId, "img/Grid.tga", {"bar", "colorize"})
Library.Media.AddTexture("Healbot", AddonId, "img/Healbot.png", {"bar", "colorize"})
Library.Media.AddTexture("Ruben", AddonId, "img/Ruben.png", {"bar", "colorize"})
Library.Media.AddTexture("Runes", AddonId, "img/Runes.png", {"bar", "colorize"})
Library.Media.AddTexture("Steel", AddonId, "img/Steel.png", {"bar", "colorize"})
Library.Media.AddTexture("shadow", AddonId, "img/shadow.tga", {"bar"})
Library.Media.AddTexture("wtGlaze", AddonId, "img/wtGlaze.png", {"bar"})