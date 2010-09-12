local addonName, addon = ...
local config = addon.config.inventory

if config.enabled then
	-- Bag slots
	addon:AddReminder("Bag space", "BAG_UPDATE", function(self)
		local slots = MainMenuBarBackpackButton.freeSlots

		if slots < 3 then
			if slots == 0 then
				self.title = "No bag-slots available"
				self.setColor(1, 0.1, 0.1)
			else
				self.title = "Less than 3 bag-slots available"
				self.setColor(1, 1, 1)
			end

			return true
		end
	end, nil, "inv_misc_bag_13", nil, nil, true)
	
	-- Repair
	local slots = {"Head", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "MainHand", "SecondaryHand", "Ranged"}
	local slotIds = {}

	for _, slot in pairs(slots) do 
		slotIds[slot] = GetInventorySlotInfo(slot .. "Slot")
	end
	
	-- From oUF, thanks haste!
	local infinity = math.huge
	
	function addon:ColorGradient(value, ...)
		if value ~= value or value == infinity then
			value = 0
		end
		
		if value >= 1 then
			local r, g, b = select(select('#', ...) - 2, ...)
			
			return r, g, b
		elseif value <= 0 then
			local r, g, b = ...
			
			return r, g, b
		end
		
		local segmentCount = select('#', ...) / 3
		local segment, relativePercent = math.modf(value * (segmentCount - 1))
		local r1, g1, b1, r2, g2, b2 = select((segment * 3)+1, ...)
		
		return r1 + (r2 - r1) * relativePercent, g1 + (g2 - g1) * relativePercent, b1 + (b2 - b1) * relativePercent
	end
	
	local getDurability

	local repairReminder = addon:AddReminder("Equipment damaged", {"UPDATE_INVENTORY_DURABILITY", "UNIT_INVENTORY_CHANGED"}, function(self)
		local minDurability = 1

		for _, id in pairs(slotIds) do
			local durability, maxDurability = GetInventoryItemDurability(id)

			if durability then
				minDurability = math.min(durability / maxDurability, minDurability)
			end
		end
		
		if minDurability < config.repairThreshold / 100 then
			local r, g, b = addon:ColorGradient(minDurability, 1, 0, 0, 1, 1, 0, 0, 1, 0)
			self.setColor(r, g, b)

			return true
		end
	end, nil, "ability_repair", nil, nil, true)
	
	local round = function(value) return floor(value + 0.5) end
	repairReminder:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetWidth(250)
		GameTooltip:AddLine(self.name)
		GameTooltip:AddLine(" ")

		for _, id in pairs(slotIds) do
			local durability, maxDurability = GetInventoryItemDurability(id)

			if durability then
				local percent = durability / maxDurability
				
				if percent < config.repairThreshold / 100 then
					local link = GetInventoryItemLink("player", id)
					local name, _, quality = GetItemInfo(link)
					local qualityColor = ITEM_QUALITY_COLORS[quality]
					local icon = GetItemIcon(link)
					local r, g, b = addon:ColorGradient(percent, 1, 0, 0, 1, 1, 0, 0, 1, 0)
				
					GameTooltip:AddDoubleLine(name, math.floor((percent * 100) + 0.5) .. "%", qualityColor.r, qualityColor.g, qualityColor.b, r, g, b)
					GameTooltip:AddTexture(icon)
				end
			end
		end

		GameTooltip:Show()
	end)
end