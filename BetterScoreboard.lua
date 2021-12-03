BetterScoreboard = {}
local bs = BetterScoreboard
-- Written by M0R_Gaming

--ZO_ShouldPreferUserId
bs.name = "BetterScoreboard"
--bs.last = {}
--bs.queue = {"Start"}

bs.scores = {}


local classIcons = {
	"esoui/art/icons/class/gamepad/gp_class_dragonknight.dds",
	"esoui/art/icons/class/gamepad/gp_class_sorcerer.dds",
	"esoui/art/icons/class/gamepad/gp_class_nightblade.dds",
	"esoui/art/icons/class/gamepad/gp_class_warden.dds",
	"esoui/art/icons/class/gamepad/gp_class_necromancer.dds",
	"esoui/art/icons/class/gamepad/gp_class_templar.dds"
}




SecurePostHook(Battleground_Scoreboard_Player_Row, "UpdateRow", function(row)
	--bs.last = row
	--bs.queue[#bs.queue+1] = row
	--BetterScoreboard.last[1].nameLabel:GetText()
	local charName = zo_strformat(SI_PLAYER_NAME, row.data.characterName)
	local displayName = zo_strformat(SI_PLAYER_NAME, row.data.displayName)
	local formattedName = ""
	
	if ZO_ShouldPreferUserId() then
		formattedName = string.format("%s (%s)", displayName, charName)
	else
		formattedName = string.format("%s (%s)", charName, displayName)
	end
	row.nameLabel:SetText(formattedName)


	local classId = GetScoreboardEntryClassId(row.data.entryIndex)
	row.classIcon:SetTexture(classIcons[classId])
end)

SecurePostHook(Battleground_Scoreboard_Player_Row, "Initialize", function(self, row)
	--d(row)
	local rowName = row:GetName()
	local metalScore = row:GetNamedChild("MedalScore")
	local nameLabel = row:GetNamedChild("NameLabel")

	local damage = CreateControl(rowName.."DamageScore",row,CT_LABEL)
	local heal = CreateControl(rowName.."HealScore",row,CT_LABEL)
	heal:SetAnchor(LEFT,metalScore,RIGHT,15,0,0)
	damage:SetAnchor(LEFT,metalScore,RIGHT,15,0,0)
	heal:SetTransformOffsetY(15)
	damage:SetTransformOffsetY(-5)
	heal:SetColor(1,0.85,0)
	damage:SetFont("ZoFontGame")
	heal:SetFont("ZoFontGame")

	local classIcon = CreateControl(rowName.."ClassIcon",row,CT_TEXTURE)
	classIcon:SetAnchor(RIGHT,nameLabel,LEFT,-15,0,0)
	classIcon:SetDimensions(32,32)
	classIcon:SetDrawLevel(6)


	self.damage = damage
	self.heal = heal
	self.classIcon = classIcon

	--bs.scores[self.key] = {damage,heal}
	--bs.queue[#bs.queue+1] = row
end)



local function updateScore(i)
	local damage = GetScoreboardEntryScoreByType(i,1)
	local heal = GetScoreboardEntryScoreByType(i,2)

	damage = string.format("%sk",math.floor(damage/1000))
	heal = string.format("%sk",math.floor(heal/1000))

	if damage and bs.scores[i] then
		bs.scores[i].damage:SetText(damage)
	end
	if heal and bs.scores[i] then
		bs.scores[i].heal:SetText(heal)
	end
end

SecurePostHook(Battleground_Scoreboard_Player_Row, "SetupOnAcquire", function(self, panel, poolKey, data)
	for i=1,GetNumScoreboardEntries() do
		local _, name = GetScoreboardEntryInfo(i)
		if name == data.displayName then
			bs.scores[i] = self
			updateScore(i)
		end
	end
end)


function bs.somethingChanged(code)
	for i=1,GetNumScoreboardEntries() do
		updateScore(i)
	end
end


--[[
function bs.playerActivated()

end
--]]

--EVENT_BATTLEGROUND_SCOREBOARD_UPDATED

-- local score = GetScoreboardEntryScoreByType(entryIndex, scoreType)
--[[
local primaryName = ZO_GetPrimaryPlayerName(data.displayName, data.characterName)
local formattedName = zo_strformat(SI_PLAYER_NAME, primaryName)
self.nameLabel:SetText(formattedName)
]]




-- The following was adapted from https://wiki.esoui.com/Circonians_Stamina_Bar_Tutorial#lua_Structure

-------------------------------------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------
function bs.OnAddOnLoaded(event, addonName)
	if addonName ~= bs.name then return end

	bs:Initialize()
end
 
-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
function bs:Initialize()
	-- Addon Settings Menu

	EVENT_MANAGER:UnregisterForEvent(bs.name, EVENT_ADD_ON_LOADED)

	EVENT_MANAGER:RegisterForEvent(bs.name, EVENT_BATTLEGROUND_SCOREBOARD_UPDATED, bs.somethingChanged)
	--EVENT_MANAGER:RegisterForEvent(bs.name, EVENT_BATTLEGROUND_LEADERBOARD_DATA_CHANGED, bs.somethingChanged)
end
 
-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(bs.name, EVENT_ADD_ON_LOADED, bs.OnAddOnLoaded)