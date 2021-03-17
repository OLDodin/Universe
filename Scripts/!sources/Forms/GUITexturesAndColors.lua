Global("g_texIcons", {})
Global("g_texCheckState", {})
Global("g_texParty", {})
Global("g_classColors", {})
Global("g_relationColors", {})

Global("FRIEND_PANEL", 1)
Global("NEITRAL_PANEL", 2)
Global("ENEMY_PANEL", 3)

function InitClassIconsTexture()
	g_texIcons["DRUID"] = common.GetAddonRelatedTexture("DruidIcon")
	g_texIcons["MAGE"] = common.GetAddonRelatedTexture("MageIcon")
	g_texIcons["PALADIN"] = common.GetAddonRelatedTexture("PaladinIcon")
	g_texIcons["PRIEST"] = common.GetAddonRelatedTexture("PriestIcon")
	g_texIcons["PSIONIC"] = common.GetAddonRelatedTexture("PsionicIcon")
	g_texIcons["STALKER"] = common.GetAddonRelatedTexture("StalkerIcon")
	g_texIcons["WARRIOR"] = common.GetAddonRelatedTexture("WarriorIcon")
	g_texIcons["NECROMANCER"] = common.GetAddonRelatedTexture("NecromancerIcon")
	g_texIcons["ENGINEER"] = common.GetAddonRelatedTexture("EngineerIcon")
	g_texIcons["BARD"] = common.GetAddonRelatedTexture("BardIcon")
	g_texIcons["WARLOCK"] = common.GetAddonRelatedTexture("WarlockIcon")
	g_texIcons["UNKNOWN"] = common.GetAddonRelatedTexture("UnknownIcon")
end

function InitButtonTextures()
	g_texParty[1] = common.GetAddonRelatedTexture("Party1")
	g_texParty[2] = common.GetAddonRelatedTexture("Party2")
	g_texParty[3] = common.GetAddonRelatedTexture("Party3")
	g_texParty[4] = common.GetAddonRelatedTexture("Party4")
end

function InitCheckTextures()
	g_texCheckState[READY_CHECK_READY_STATE_UNKNOWN] = common.GetAddonRelatedTexture("Unknown")
	g_texCheckState[READY_CHECK_READY_STATE_READY] = common.GetAddonRelatedTexture("True")
	g_texCheckState[READY_CHECK_READY_STATE_NOT_READY] = common.GetAddonRelatedTexture("False")
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