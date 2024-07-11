Global("Locales", {})
Global("LocalesInited", false)

local localeGroup = common.GetAddonRelatedTextGroup(common.GetLocalization(), true) or common.GetAddonRelatedTextGroup("eng")

function getLocale()
	if LocalesInited then
		return Locales
	else
		LocalesInited = true
		return setmetatable(Locales, 
			{__index = function(t,k) 
				if localeGroup:HasText(k) then
					return localeGroup:GetText(k) 
				end
			end
			}
		)
	end
end