--к сожалению в сейчас EditLine ограничен 4096 символами, нам это не достаточно поэтому экспорт/импорт в WString невозможен (нет иной возможности паристь WString по символам)



local sNumberTypeCharacter = "%"
local sStringTypeCharacter = "$"
local sTableOpenBracket = "{"
local sTableCloseBracket = "}"
local sEscapeCharacter = "\\"
local sTableEntrySeperator = ","
local sKeyValueSeperator = "="
local sNilTypeCharacter = "&"
local sBooleanFalseChracter = "f"
local sBooleanTrueCharacter = "t"
local sWStringTypeCharacter = "?"





local function EscapeSString(aStr)
	if not aStr or type(aStr) ~= "string" then
		return ""
	end
	
    local result = ""
    local length = aStr:len()
	
	for i = 1, length do
		local char = aStr:sub(i,i)
		if char == sTableCloseBracket or char == sEscapeCharacter or
		char == sTableEntrySeperator or char == sKeyValueSeperator then
			result = result..sEscapeCharacter
		end
		result = result..char
	end
	return result
end

local function AddSerializedValue(aValue, aResultArr)
	local valueType = type(aValue)
	if valueType == "nil" then
		table.insert(aResultArr, sNilTypeCharacter)
	elseif valueType == "boolean" then
		table.insert(aResultArr, aValue and sBooleanTrueCharacter or sBooleanFalseChracter)
	elseif valueType == "number" then
		table.insert(aResultArr, sNumberTypeCharacter .. tostring(aValue))
	elseif valueType == "string" then
		table.insert(aResultArr, EscapeSString(sStringTypeCharacter .. aValue))
	elseif valueType == "table" then
		Serialize(aValue, aResultArr)
	elseif valueType == "userdata" and common.IsWString(aValue) then
		table.insert(aResultArr, EscapeSString(sWStringTypeCharacter..userMods.FromWString(aValue)))
	end
end

function Serialize(aTable, aResultArr)
	if not aTable or type(aTable) ~= "table" then
		return ""
	end  

    table.insert(aResultArr, sTableOpenBracket)
    local first = true
    for k, v in pairs( aTable ) do
		if not first then
		  table.insert(aResultArr, sTableEntrySeperator)
		end
		first = false
		--LogInfo("[", k, "] = ", v)
		AddSerializedValue(k, aResultArr)
		table.insert(aResultArr, sKeyValueSeperator)
		AddSerializedValue(v, aResultArr)
    end
    table.insert(aResultArr, sTableCloseBracket)
end

function StartSerialize(aTable)
	local result = { }
	Serialize(aTable, result)
		
	return userMods.ToWString(table.concat(result))
end

local SeperatorPredicate = function(aCh) 
	return aCh == sTableEntrySeperator or aCh == sKeyValueSeperator or aCh == sTableCloseBracket
end

local function CreateSStringStream(aStr)
	local result = 
	{
		Str = aStr,
		LastRemovedChar = "",
		LastRemovedCharIsEscaped = false,
		CurrentPos = 1,
		ReadChar = function(self) 
			local char = self.Str:sub(self.CurrentPos, self.CurrentPos)
			self.LastRemovedChar = char
			self.CurrentPos = self.CurrentPos + 1
			return char
		end,
		ReadUntil = function(self, anUntilPredicate, anEscapeCharacter)
			local text = { }
			local char
			while self:CanReadChar() do
				char = self:ReadChar()
				self.LastRemovedCharIsEscaped = false
				if anEscapeCharacter and char == anEscapeCharacter then
					if not self:CanReadChar() then
						return nil
					end
					char = self:ReadChar()
					self.LastRemovedCharIsEscaped = true
				elseif anUntilPredicate and anUntilPredicate(char) then
					break		  
				end
				table.insert(text, char)
			end

			return table.concat(text)
		end,
		CanReadChar = function(self)
			return self.Str:len() - self.CurrentPos > 0
		end
  }

  return result
end
-- ={},
local function InternalDeserialize(aStream) 
	local type = aStream:ReadChar()
	if type == sTableOpenBracket then
		local result = { }
		while aStream:CanReadChar() do
			local key = InternalDeserialize(aStream)
			if not aStream.LastRemovedCharIsEscaped and aStream.LastRemovedChar == sTableCloseBracket then
				aStream:ReadChar()
				break
			end
			local value = InternalDeserialize(aStream)
			if key ~= nil then
				result[key] = value
			end
			if not aStream.LastRemovedCharIsEscaped and aStream.LastRemovedChar == sTableCloseBracket then
				aStream:ReadChar()
				break
			end
		end
		return result
	elseif type == sNilTypeCharacter then
		aStream:ReadChar()
		return nil
	elseif type == sBooleanFalseChracter then
		aStream:ReadChar()
		return false
	elseif type == sBooleanTrueCharacter then
		aStream:ReadChar()
		return true
	elseif type == sNumberTypeCharacter then
		local value = aStream:ReadUntil(SeperatorPredicate)
		return tonumber(value)
	elseif type == sStringTypeCharacter then
		return aStream:ReadUntil(SeperatorPredicate, sEscapeCharacter)
	elseif type == sWStringTypeCharacter then
		return userMods.ToWString(aStream:ReadUntil(SeperatorPredicate, sEscapeCharacter))
	end
end

-- Deserialize a wstring to a table
function StartDeserialize(aWStr)
	if not aWStr or type(aWStr) ~= "userdata" or not common.IsWString(aWStr) or common.IsEmptyWString(aWStr) then
		return nil
	end

	local str = userMods.FromWString(aWStr)
	
	local stream = CreateSStringStream(str)
	local table = InternalDeserialize(stream)
	if type(table) == "table" then
		return table
	end
	return nil
end