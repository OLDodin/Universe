Global( "SpellCondition", {} )

function SpellCondition:Init(aSettings)
	self.settings = aSettings
	self.avlCustomTree  = GetAVLWStrTree()
	for _, element in ipairs(self.settings.customSpells) do
		if element.name then
			self.avlCustomTree:add(element)
		end
	end

end

function SpellCondition:HasCondtion()
	return not self.avlCustomTree:isEmpty()
end

function SpellCondition:Check(aSpellInfo)
	local searchRes = self.avlCustomTree:find(aSpellInfo)

	if searchRes ~= nil then
		--LogInfo("search = ", aSpellInfo.name)
		--LogInfo("searchRes = ", searchRes)
		return true, searchRes
	end

	return false
end


local m_buffPlateConditionArr = {}

function InitSpellConditionMgr()
	local profile = GetCurrentProfile()

	for i, buffPlateSettings in ipairs(profile.buffFormSettings.buffGroups) do
		local buffGroup = {}
		buffGroup.customSpells = {}
		if profile.buffFormSettings.buffGroups[i].buffs then
			for ind, settingsBuffInfo in pairs(profile.buffFormSettings.buffGroups[i].buffs) do
				if settingsBuffInfo.isSpell then
					settingsBuffInfo.ind = ind
					table.insert(buffGroup.customSpells, settingsBuffInfo)
				end
			end
			m_buffPlateConditionArr[i] = copyTable(SpellCondition)
			m_buffPlateConditionArr[i]:Init(buffGroup)
		end
	end
end

function GetSpellConditionForBuffPlate(anPlateIndex)
	return m_buffPlateConditionArr[anPlateIndex]
end
