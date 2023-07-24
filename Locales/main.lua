Global("Locales", {})

local localeGroup = common.GetAddonRelatedTextGroup(common.GetLocalization(), true) or common.GetAddonRelatedTextGroup("eng")

function getLocale()
	return setmetatable(Locales, 
		{__index = function(t,k) 
			if localeGroup:HasText(k) then
				return localeGroup:GetText(k) 
			end
		end
		}
	)
end