if select(2, UnitClass("player")) == "DEATHKNIGHT" and UnitLevel("player") >= 65 then
	evl_Reminders:AddReminder("Missing Horn of Winter", "UNIT_AURA", function() return not evl_Reminders:PlayerHasBuff("Horn of Winter") end, "INV_Misc_Horn_02", {type1 = "spell", spell1 = "Horn of Winter", unit1 = "player"})
end