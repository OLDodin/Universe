Global("g_texIcons", {})
Global("g_texCheckState", {})
Global("g_texParty", {})
Global("g_texColorBack", {})
Global("g_classColors", {})
Global("g_relationColors", {})
Global("g_needClearColor", { r = 0; g = 0.03; b = 0.2; a = 1 })
Global("g_selectionColor", { r = 1; g = 0; b = 0.6; a = 1 })
Global("g_farColor", { r = 0.3; g = 0.3; b = 0.3; a = 0.7 })
Global("g_shieldContainerNormalColor", { r = 0, g = 0, b = 0, a = 1 })
Global("g_shieldContainerCleanableColor", { r = 0.39, g = 0.19, b = 0, a = 1 })

Global("FRIEND_PANEL", 1)
Global("NEITRAL_PANEL", 2)
Global("ENEMY_PANEL", 3)

function InitClassIconsTexture()
	g_texIcons["DRUID"] = common.GetAddonRelatedTextureGroup("common"):GetTexture("DruidIcon")
	g_texIcons["MAGE"] = common.GetAddonRelatedTextureGroup("common"):GetTexture("MageIcon")
	g_texIcons["PALADIN"] = common.GetAddonRelatedTextureGroup("common"):GetTexture("PaladinIcon")
	g_texIcons["PRIEST"] = common.GetAddonRelatedTextureGroup("common"):GetTexture("PriestIcon")
	g_texIcons["PSIONIC"] = common.GetAddonRelatedTextureGroup("common"):GetTexture("PsionicIcon")
	g_texIcons["STALKER"] = common.GetAddonRelatedTextureGroup("common"):GetTexture("StalkerIcon")
	g_texIcons["WARRIOR"] = common.GetAddonRelatedTextureGroup("common"):GetTexture("WarriorIcon")
	g_texIcons["NECROMANCER"] = common.GetAddonRelatedTextureGroup("common"):GetTexture("NecromancerIcon")
	g_texIcons["ENGINEER"] = common.GetAddonRelatedTextureGroup("common"):GetTexture("EngineerIcon")
	g_texIcons["BARD"] = common.GetAddonRelatedTextureGroup("common"):GetTexture("BardIcon")
	g_texIcons["WARLOCK"] = common.GetAddonRelatedTextureGroup("common"):GetTexture("WarlockIcon")
	g_texIcons["UNKNOWN"] = common.GetAddonRelatedTextureGroup("common"):GetTexture("UnknownIcon")
end

function InitButtonTextures()
	g_texParty[1] = common.GetAddonRelatedTextureGroup("common"):GetTexture("Party1")
	g_texParty[2] = common.GetAddonRelatedTextureGroup("common"):GetTexture("Party2")
	g_texParty[3] = common.GetAddonRelatedTextureGroup("common"):GetTexture("Party3")
	g_texParty[4] = common.GetAddonRelatedTextureGroup("common"):GetTexture("Party4")
end

function InitCheckTextures()
	g_texCheckState[READY_CHECK_READY_STATE_UNKNOWN] = common.GetAddonRelatedTextureGroup("common"):GetTexture("Unknown")
	g_texCheckState[READY_CHECK_READY_STATE_READY] = common.GetAddonRelatedTextureGroup("common"):GetTexture("True")
	g_texCheckState[READY_CHECK_READY_STATE_NOT_READY] = common.GetAddonRelatedTextureGroup("common"):GetTexture("False")
end

function InitBackgroundsTextures()
	g_texColorBack = common.GetAddonRelatedTextureGroup("common"):GetTexture("colorBack")
end

g_classColors={
	["WARRIOR"]		= { r = 143/255; g = 119/255; b = 075/255; a = 1 },
	["PALADIN"]		= { r = 207/255; g = 220/255; b = 155/255; a = 1 },
	["MAGE"]		= { r = 126/255; g = 159/255; b = 255/255; a = 1 },
	["DRUID"]		= { r = 255/255; g = 118/255; b = 060/255; a = 1 },
	["PSIONIC"]		= { r = 221/255; g = 123/255; b = 245/255; a = 1 },
	["STALKER"]		= { r = 150/255; g = 204/255; b = 086/255; a = 1 },
	["PRIEST"]		= { r = 255/255; g = 207/255; b = 123/255; a = 1 },
	["NECROMANCER"]	= { r = 208/255; g = 069/255; b = 075/255; a = 1 },
	["ENGINEER"]    = { r = 127/255; g = 128/255; b = 178/255; a = 1 },
	["BARD"]		= { r = 51/255;  g = 230/255; b = 230/255; a = 1 },
	["WARLOCK"] 	= { r = 125/255; g = 101/255; b = 219/255; a = 1 }, 
	["UNKNOWN"]		= { r = 127/255; g = 127/255; b = 127/255; a = 0 }
}

g_relationColors={
	[FRIEND_PANEL]		= { r = 0.1; g = 0.8; b = 0; a = 1.0 },
	[ENEMY_PANEL]		= { r = 1; g = 0; b = 0; a = 1 },
	[NEITRAL_PANEL]		= { r = 0.8; g = 0.8; b = 0.1; a = 1 },
}

