local map = true -- yay map

-- [[ FreeUI functions ]]

local classcolours = {
	["HUNTER"] = { r = 0.58, g = 0.86, b = 0.49 },
	["WARLOCK"] = { r = 0.6, g = 0.47, b = 0.85 },
	["PALADIN"] = { r = 1, g = 0.22, b = 0.52 },
	["PRIEST"] = { r = 0.8, g = 0.87, b = .9 },
	["MAGE"] = { r = 0, g = 0.76, b = 1 },
	["ROGUE"] = { r = 1, g = 0.91, b = 0.2 },
	["DRUID"] = { r = 1, g = 0.49, b = 0.04 },
	["SHAMAN"] = { r = 0, g = 0.6, b = 0.6 };
	["WARRIOR"] = { r = 0.9, g = 0.65, b = 0.45 },
	["DEATHKNIGHT"] = { r = 0.77, g = 0.12 , b = 0.23 },
}

Aurora = {
	["backdrop"] = "Interface\\ChatFrame\\ChatFrameBackground",
	["checked"] = "Interface\\AddOns\\Aurora\\CheckButtonHilight",
	["glow"] = "Interface\\AddOns\\Aurora\\glow",
}

Aurora.dummy = function() end

Aurora.CreateBD = function(f, a)
	f:SetBackdrop({
		bgFile = Aurora.backdrop, 
		edgeFile = Aurora.backdrop, 
		edgeSize = 1, 
	})
	f:SetBackdropColor(0, 0, 0, a or .5)
	f:SetBackdropBorderColor(0, 0, 0)
end

Aurora.CreateBG = function(frame)
	local f = frame
	if frame:GetObjectType() == "Texture" then f = frame:GetParent() end

	local bg = f:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", frame, -1, 1)
	bg:SetPoint("BOTTOMRIGHT", frame, 1, -1)
	bg:SetTexture(Aurora.backdrop)
	bg:SetVertexColor(0, 0, 0)
end

Aurora.CreateSD = function(parent, size, r, g, b, alpha, offset)
	local sd = CreateFrame("Frame", nil, parent)
	sd.size = size or 5
	sd.offset = offset or 0
	sd:SetBackdrop({
		edgeFile = Aurora.glow,
		edgeSize = sd.size,
	})
	sd:SetPoint("TOPLEFT", parent, -sd.size - 1 - sd.offset, sd.size + 1 + sd.offset)
	sd:SetPoint("BOTTOMRIGHT", parent, sd.size + 1 + sd.offset, -sd.size - 1 - sd.offset)
	sd:SetBackdropBorderColor(r or 0, g or 0, b or 0)
	sd:SetAlpha(alpha or 1)
end

Aurora.CreatePulse = function(frame, speed, mult, alpha)
	frame.speed = speed or .05
	frame.mult = mult or 1
	frame.alpha = alpha or 1
	frame.tslu = 0
	frame:SetScript("OnUpdate", function(self, elapsed)
		self.tslu = self.tslu + elapsed
		if self.tslu > self.speed then
			self.tslu = 0
			self:SetAlpha(self.alpha)
		end
		self.alpha = self.alpha - elapsed*self.mult
		if self.alpha < 0 and self.mult > 0 then
			self.mult = self.mult*-1
			self.alpha = 0
		elseif self.alpha > 1 and self.mult < 0 then
			self.mult = self.mult*-1
		end
	end)
end

-- [[ Addon core ]]

local _, class = UnitClass("player")
local r, g, b
if CUSTOM_CLASS_COLORS then 
	r, g, b = CUSTOM_CLASS_COLORS[class].r, CUSTOM_CLASS_COLORS[class].g, CUSTOM_CLASS_COLORS[class].b
else
	r, g, b = classcolours[class].r, classcolours[class].g, classcolours[class].b
end

local function StartGlow(f)
	f:SetBackdropColor(r, g, b, .1)
	f:SetBackdropBorderColor(r, g, b)
	Aurora.CreatePulse(f.glow)
end

local function StopGlow(f)
	f:SetBackdropColor(0, 0, 0, 0)
	f:SetBackdropBorderColor(0, 0, 0)
	f.glow:SetScript("OnUpdate", nil)
	f.glow:SetAlpha(0)
end

Aurora.Reskin = function(f)
	f:SetNormalTexture("")
	f:SetHighlightTexture("")
	f:SetPushedTexture("")
	f:SetDisabledTexture("")

	if f:GetName() then
		local left = _G[f:GetName().."Left"]
		local middle = _G[f:GetName().."Middle"]
		local right = _G[f:GetName().."Right"]

		if left then left:SetAlpha(0) end
		if middle then middle:SetAlpha(0) end
		if right then right:SetAlpha(0) end
	end

	Aurora.CreateBD(f, .0)

	local tex = f:CreateTexture(nil, "BACKGROUND")
	tex:SetPoint("TOPLEFT")
	tex:SetPoint("BOTTOMRIGHT")
	tex:SetTexture(Aurora.backdrop)
	tex:SetGradientAlpha("VERTICAL", 0, 0, 0, .3, .35, .35, .35, .35)

	f.glow = CreateFrame("Frame", nil, f)
	f.glow:SetBackdrop({
		edgeFile = Aurora.glow,
		edgeSize = 5,
	})
	f.glow:SetPoint("TOPLEFT", -6, 6)
	f.glow:SetPoint("BOTTOMRIGHT", 6, -6)
	f.glow:SetBackdropBorderColor(r, g, b)
	f.glow:SetAlpha(0)

	f:HookScript("OnEnter", StartGlow)
 	f:HookScript("OnLeave", StopGlow)
end

Aurora.CreateTab = function(f)
	f:DisableDrawLayer("BACKGROUND")

	local bg = CreateFrame("Frame", nil, f)
	bg:SetPoint("TOPLEFT", 8, -3)
	bg:SetPoint("BOTTOMRIGHT", -8, 0)
	bg:SetFrameLevel(f:GetFrameLevel()-1)
	Aurora.CreateBD(bg)

	f:SetHighlightTexture(Aurora.backdrop)
	local hl = f:GetHighlightTexture()
	hl:SetPoint("TOPLEFT", 9, -4)
	hl:SetPoint("BOTTOMRIGHT", -9, 1)
	hl:SetVertexColor(r, g, b, .25)
end

Aurora.ReskinScroll = function(f)
	local frame = f:GetName()

	if _G[frame.."Track"] then _G[frame.."Track"]:Hide() end
	if _G[frame.."BG"] then _G[frame.."BG"]:Hide() end
	if _G[frame.."Top"] then _G[frame.."Top"]:Hide() end
	if _G[frame.."Middle"] then _G[frame.."Middle"]:Hide() end
	if _G[frame.."Bottom"] then _G[frame.."Bottom"]:Hide() end

	local bu = _G[frame.."ThumbTexture"]
	bu:SetAlpha(0)
	bu:SetWidth(17)

	bu.bg = CreateFrame("Frame", nil, f)
	bu.bg:SetPoint("TOPLEFT", bu, 0, -2)
	bu.bg:SetPoint("BOTTOMRIGHT", bu, 0, 4)
	Aurora.CreateBD(bu.bg, 0)

	local tex = f:CreateTexture(nil, "BACKGROUND")
	tex:SetPoint("TOPLEFT", bu.bg)
	tex:SetPoint("BOTTOMRIGHT", bu.bg)
	tex:SetTexture(Aurora.backdrop)
	tex:SetGradientAlpha("VERTICAL", 0, 0, 0, .3, .35, .35, .35, .35)

	local up = _G[frame.."ScrollUpButton"]
	local down = _G[frame.."ScrollDownButton"]

	up:SetWidth(17)
	down:SetWidth(17)
	
	Aurora.Reskin(up)
	Aurora.Reskin(down)
	
	up:SetDisabledTexture(Aurora.backdrop)
	local dis1 = up:GetDisabledTexture()
	dis1:SetVertexColor(0, 0, 0, .3)
	dis1:SetDrawLayer("OVERLAY")
	
	down:SetDisabledTexture(Aurora.backdrop)
	local dis2 = down:GetDisabledTexture()
	dis2:SetVertexColor(0, 0, 0, .3)
	dis2:SetDrawLayer("OVERLAY")

	local uptex = up:CreateTexture(nil, "ARTWORK")
	uptex:SetTexture("Interface\\AddOns\\Aurora\\arrow-up-active")
	uptex:SetSize(8, 8)
	uptex:SetPoint("CENTER")
	uptex:SetVertexColor(1, 1, 1)

	local downtex = down:CreateTexture(nil, "ARTWORK")
	downtex:SetTexture("Interface\\AddOns\\Aurora\\arrow-down-active")
	downtex:SetSize(8, 8)
	downtex:SetPoint("CENTER")
	downtex:SetVertexColor(1, 1, 1)
end

Aurora.ReskinDropDown = function(f)
	local frame = f:GetName()

	local left = _G[frame.."Left"]
	local middle = _G[frame.."Middle"]
	local right = _G[frame.."Right"]

	if left then left:SetAlpha(0) end
	if middle then middle:SetAlpha(0) end
	if right then right:SetAlpha(0) end

	local down = _G[frame.."Button"]

	down:SetSize(20, 20)
	down:ClearAllPoints()
	down:SetPoint("RIGHT", -18, 2)

	Aurora.Reskin(down)
	
	down:SetDisabledTexture(Aurora.backdrop)
	local dis = down:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .3)
	dis:SetDrawLayer("OVERLAY")

	local downtex = down:CreateTexture(nil, "ARTWORK")
	downtex:SetTexture("Interface\\AddOns\\Aurora\\arrow-down-active")
	downtex:SetSize(8, 8)
	downtex:SetPoint("CENTER")
	downtex:SetVertexColor(1, 1, 1)

	local bg = CreateFrame("Frame", nil, f)
	bg:SetPoint("TOPLEFT", 16, -4)
	bg:SetPoint("BOTTOMRIGHT", -18, 8)
	bg:SetFrameLevel(f:GetFrameLevel()-1)
	Aurora.CreateBD(bg, 0)

	local tex = bg:CreateTexture(nil, "BACKGROUND")
	tex:SetPoint("TOPLEFT")
	tex:SetPoint("BOTTOMRIGHT")
	tex:SetTexture(Aurora.backdrop)
	tex:SetGradientAlpha("VERTICAL", 0, 0, 0, .3, .35, .35, .35, .35)
end

Aurora.ReskinClose = function(f, a1, p, a2, x, y)
	f:SetSize(17, 17)

	if not a1 then
		f:SetPoint("TOPRIGHT", -4, -4)
	else
		f:ClearAllPoints()
		f:SetPoint(a1, p, a2, x, y)
	end

	f:SetNormalTexture("")
	f:SetHighlightTexture("")
	f:SetPushedTexture("")
	f:SetDisabledTexture("")

	Aurora.CreateBD(f, 0)

	local tex = f:CreateTexture(nil, "BACKGROUND")
	tex:SetPoint("TOPLEFT")
	tex:SetPoint("BOTTOMRIGHT")
	tex:SetTexture(Aurora.backdrop)
	tex:SetGradientAlpha("VERTICAL", 0, 0, 0, .3, .35, .35, .35, .35)

	local text = f:CreateFontString(nil, "OVERLAY")
	text:SetFont("Fonts\\ARIALN.TTF", 14, "THINOUTLINE")
	text:SetPoint("CENTER", 1, 1)
	text:SetText("x")

	f:HookScript("OnEnter", function(self) text:SetTextColor(1, .1, .1) end)
 	f:HookScript("OnLeave", function(self) text:SetTextColor(1, 1, 1) end)
end

Aurora.ReskinInput = function(f, height, width)
	local frame = f:GetName()
	_G[frame.."Left"]:Hide()
	if _G[frame.."Middle"] then _G[frame.."Middle"]:Hide() end
	if _G[frame.."Mid"] then _G[frame.."Mid"]:Hide() end
	_G[frame.."Right"]:Hide()
	Aurora.CreateBD(f, 0)

	local tex = f:CreateTexture(nil, "BACKGROUND")
	tex:SetPoint("TOPLEFT")
	tex:SetPoint("BOTTOMRIGHT")
	tex:SetTexture(Aurora.backdrop)
	tex:SetGradientAlpha("VERTICAL", 0, 0, 0, .3, .35, .35, .35, .35)

	if height then f:SetHeight(height) end
	if width then f:SetWidth(width) end
end

Aurora.ReskinArrow = function(f, direction)
	f:SetSize(18, 18)
	Aurora.Reskin(f)
	
	f:SetDisabledTexture(Aurora.backdrop)
	local dis = f:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .3)
	dis:SetDrawLayer("OVERLAY")

	local tex = f:CreateTexture(nil, "ARTWORK")
	tex:SetSize(8, 8)
	tex:SetPoint("CENTER")
	
	if direction == 1 then
		tex:SetTexture("Interface\\AddOns\\Aurora\\arrow-left-active")
	elseif direction == 2 then
		tex:SetTexture("Interface\\AddOns\\Aurora\\arrow-right-active")
	end
end

Aurora.ReskinCheck = function(f)
	f:SetNormalTexture("")
	f:SetPushedTexture("")
	f:SetHighlightTexture(Aurora.backdrop)
	local hl = f:GetHighlightTexture()
	hl:SetPoint("TOPLEFT", 5, -5)
	hl:SetPoint("BOTTOMRIGHT", -5, 5)
	hl:SetVertexColor(r, g, b, .2)

	local bd = CreateFrame("Frame", nil, f)
	bd:SetPoint("TOPLEFT", 4, -4)
	bd:SetPoint("BOTTOMRIGHT", -4, 4)
	bd:SetFrameLevel(f:GetFrameLevel()-1)
	Aurora.CreateBD(bd, 0)

	local tex = f:CreateTexture(nil, "BACKGROUND")
	tex:SetPoint("TOPLEFT", 5, -5)
	tex:SetPoint("BOTTOMRIGHT", -5, 5)
	tex:SetTexture(Aurora.backdrop)
	tex:SetGradientAlpha("VERTICAL", 0, 0, 0, .3, .35, .35, .35, .35)
end

Aurora.SetBD = function(f, x, y, x2, y2)
	local bg = CreateFrame("Frame", nil, f)
	if not x then
		bg:SetPoint("TOPLEFT")
		bg:SetPoint("BOTTOMRIGHT")
	else
		bg:SetPoint("TOPLEFT", x, y)
		bg:SetPoint("BOTTOMRIGHT", x2, y2)
	end
	bg:SetFrameLevel(f:GetFrameLevel()-1)
	Aurora.CreateBD(bg)
	Aurora.CreateSD(bg)
end

local Skin = CreateFrame("Frame", nil, UIParent)
Skin:RegisterEvent("ADDON_LOADED")
Skin:SetScript("OnEvent", function(self, event, addon)
	if addon == "Aurora" then

		-- [[ Headers ]]

		local header = {"GameMenuFrame", "InterfaceOptionsFrame", "AudioOptionsFrame", "VideoOptionsFrame", "ChatConfigFrame", "ColorPickerFrame"}
		for i = 1, #header do
		local title = _G[header[i].."Header"]
			if title then
				title:SetTexture("")
				title:ClearAllPoints()
				if title == _G["GameMenuFrameHeader"] then
					title:SetPoint("TOP", GameMenuFrame, 0, 7)
				else
					title:SetPoint("TOP", header[i], 0, 0)
				end
			end
		end

		-- [[ Simple backdrops ]]

		local bds = {"AutoCompleteBox", "BNToastFrame", "TicketStatusFrameButton", "DropDownList1Backdrop", "DropDownList2Backdrop", "DropDownList1MenuBackdrop", "DropDownList2MenuBackdrop", "LFDSearchStatus", "FriendsTooltip", "DropDownList1MenuBackdrop", "DropDownList2MenuBackdrop", "DropDownList1Backdrop", "DropDownList2Backdrop", "GearManagerDialogPopup", "TokenFramePopup", "ReputationDetailFrame", "RaidInfoFrame"}

		for i = 1, #bds do
			Aurora.CreateBD(_G[bds[i]])
		end

		local lightbds = {"SpellBookCompanionModelFrame", "SecondaryProfession1", "SecondaryProfession2", "SecondaryProfession3", "SecondaryProfession4", "ChatConfigCategoryFrame", "ChatConfigBackgroundFrame", "ChatConfigChatSettingsLeft", "ChatConfigChatSettingsClassColorLegend", "ChatConfigChannelSettingsLeft", "ChatConfigChannelSettingsClassColorLegend", "FriendsFriendsList", "QuestLogCount", "HelpFrameTicketScrollFrame", "HelpFrameGM_ResponseScrollFrame1", "HelpFrameGM_ResponseScrollFrame2", "GuildRegistrarFrameEditBox", "FriendsFriendsNoteFrame", "AddFriendNoteFrame"}
		for i = 1, #lightbds do
			Aurora.CreateBD(_G[lightbds[i]], .25)
		end

		-- [[ Scroll bars ]]

		local scrollbars = {"FriendsFrameFriendsScrollFrameScrollBar", "QuestLogScrollFrameScrollBar", "QuestLogDetailScrollFrameScrollBar", "CharacterStatsPaneScrollBar", "PVPHonorFrameTypeScrollFrameScrollBar", "PVPHonorFrameInfoScrollFrameScrollBar", "LFDQueueFrameSpecificListScrollFrameScrollBar", "GossipGreetingScrollFrameScrollBar", "HelpFrameKnowledgebaseScrollFrameScrollBar", "HelpFrameTicketScrollFrameScrollBar", "PaperDollTitlesPaneScrollBar", "PaperDollEquipmentManagerPaneScrollBar", "SendMailScrollFrameScrollBar", "OpenMailScrollFrameScrollBar", "RaidInfoScrollFrameScrollBar", "ReputationListScrollFrameScrollBar", "FriendsFriendsScrollFrameScrollBar", "HelpFrameGM_ResponseScrollFrame1ScrollBar", "HelpFrameGM_ResponseScrollFrame2ScrollBar", "HelpFrameKnowledgebaseScrollFrame2ScrollBar", "WhoListScrollFrameScrollBar", "QuestProgressScrollFrameScrollBar", "QuestRewardScrollFrameScrollBar", "QuestDetailScrollFrameScrollBar", "QuestGreetingScrollFrameScrollBar", "QuestNPCModelTextScrollFrameScrollBar", "GearManagerDialogPopupScrollFrameScrollBar", "LFDQueueFrameRandomScrollFrameScrollBar", "WarGamesFrameScrollFrameScrollBar", "WarGamesFrameInfoScrollFrameScrollBar", "EncounterJournalInstanceSelectScrollFrameScrollBar"}
		for i = 1, #scrollbars do
			bar = _G[scrollbars[i]]
			Aurora.ReskinScroll(bar)
		end

		-- [[ Dropdowns ]]

		local dropdowns = {"FriendsFrameStatusDropDown", "LFDQueueFrameTypeDropDown", "LFRBrowseFrameRaidDropDown", "WhoFrameDropDown", "FriendsFriendsFrameDropDown", "WorldMapLevelDropDown"}
		for i = 1, #dropdowns do
			button = _G[dropdowns[i]]
			Aurora.ReskinDropDown(button)
		end

		-- [[ Input frames ]]

		local inputs = {"AddFriendNameEditBox", "PVPTeamManagementFrameWeeklyDisplay", "SendMailNameEditBox", "SendMailSubjectEditBox", "SendMailMoneyGold", "SendMailMoneySilver", "SendMailMoneyCopper", "StaticPopup1MoneyInputFrameGold", "StaticPopup1MoneyInputFrameSilver", "StaticPopup1MoneyInputFrameCopper", "StaticPopup2MoneyInputFrameGold", "StaticPopup2MoneyInputFrameSilver", "StaticPopup2MoneyInputFrameCopper", "GearManagerDialogPopupEditBox", "FriendsFrameBroadcastInput", "HelpFrameKnowledgebaseSearchBox", "ChannelFrameDaughterFrameChannelName", "ChannelFrameDaughterFrameChannelPassword", "EncounterJournalSearchBox"}
		for i = 1, #inputs do
			input = _G[inputs[i]]
			Aurora.ReskinInput(input)
		end

		Aurora.ReskinInput(StaticPopup1EditBox, 20)
		Aurora.ReskinInput(StaticPopup2EditBox, 20)
		Aurora.ReskinInput(PVPBannerFrameEditBox, 20)

		-- [[ Arrows ]]

		Aurora.ReskinArrow(SpellBookPrevPageButton, 1)
		Aurora.ReskinArrow(SpellBookNextPageButton, 2)
		Aurora.ReskinArrow(InboxPrevPageButton, 1)
		Aurora.ReskinArrow(InboxNextPageButton, 2)
		Aurora.ReskinArrow(MerchantPrevPageButton, 1)
		Aurora.ReskinArrow(MerchantNextPageButton, 2)
		Aurora.ReskinArrow(CharacterFrameExpandButton, 1)
		Aurora.ReskinArrow(PVPTeamManagementFrameWeeklyToggleLeft, 1)
		Aurora.ReskinArrow(PVPTeamManagementFrameWeeklyToggleRight, 2)
		Aurora.ReskinArrow(PVPBannerFrameCustomization1LeftButton, 1)
		Aurora.ReskinArrow(PVPBannerFrameCustomization1RightButton, 2)
		Aurora.ReskinArrow(PVPBannerFrameCustomization2LeftButton, 1)
		Aurora.ReskinArrow(PVPBannerFrameCustomization2RightButton, 2)
		Aurora.ReskinArrow(ItemTextPrevPageButton, 1)
		Aurora.ReskinArrow(ItemTextNextPageButton, 2)
		Aurora.ReskinArrow(TabardCharacterModelRotateLeftButton, 1)
		Aurora.ReskinArrow(TabardCharacterModelRotateRightButton, 2)
		for i = 1, 5 do
			Aurora.ReskinArrow(_G["TabardFrameCustomization"..i.."LeftButton"], 1)
			Aurora.ReskinArrow(_G["TabardFrameCustomization"..i.."RightButton"], 2)
		end

		hooksecurefunc("CharacterFrame_Expand", function()
			select(15, CharacterFrameExpandButton:GetRegions()):SetTexture("Interface\\AddOns\\Aurora\\arrow-left-active")
		end)

		hooksecurefunc("CharacterFrame_Collapse", function()
			select(15, CharacterFrameExpandButton:GetRegions()):SetTexture("Interface\\AddOns\\Aurora\\arrow-right-active")
		end)

		-- [[ Check boxes ]]

		local checkboxes = {"WorldMapShowDigSites", "WorldMapQuestShowObjectives", "WorldMapTrackQuest", "TokenFramePopupInactiveCheckBox", "TokenFramePopupBackpackCheckBox", "ReputationDetailAtWarCheckBox", "ReputationDetailInactiveCheckBox", "ReputationDetailMainScreenCheckBox"}
		for i = 1, #checkboxes do
			local checkbox = _G[checkboxes[i]]
			Aurora.ReskinCheck(checkbox)
		end

		Aurora.ReskinCheck(LFDQueueFrameRoleButtonTank:GetChildren())
		Aurora.ReskinCheck(LFDQueueFrameRoleButtonHealer:GetChildren())
		Aurora.ReskinCheck(LFDQueueFrameRoleButtonDPS:GetChildren())
		Aurora.ReskinCheck(LFDQueueFrameRoleButtonLeader:GetChildren())
		Aurora.ReskinCheck(LFRQueueFrameRoleButtonTank:GetChildren())
		Aurora.ReskinCheck(LFRQueueFrameRoleButtonHealer:GetChildren())
		Aurora.ReskinCheck(LFRQueueFrameRoleButtonDPS:GetChildren())
		Aurora.ReskinCheck(LFDRoleCheckPopupRoleButtonTank:GetChildren())
		Aurora.ReskinCheck(LFDRoleCheckPopupRoleButtonHealer:GetChildren())
		Aurora.ReskinCheck(LFDRoleCheckPopupRoleButtonDPS:GetChildren())
		
		-- [[ Backdrop frames ]]
			
		Aurora.SetBD(FriendsFrame, 10, -30, -34, 76)
		Aurora.SetBD(QuestLogFrame, 6, -9, -2, 6)
		Aurora.SetBD(QuestFrame, 6, -15, -26, 64)
		Aurora.SetBD(QuestLogDetailFrame, 6, -9, 0, 0)
		Aurora.SetBD(GossipFrame, 6, -15, -26, 64)
		Aurora.SetBD(LFRParentFrame, 10, -10, 0, 4)
		Aurora.SetBD(MerchantFrame, 10, -10, -34, 61)
		Aurora.SetBD(MailFrame, 10, -12, -34, 74)
		Aurora.SetBD(OpenMailFrame, 10, -12, -34, 74)
		Aurora.SetBD(DressUpFrame, 10, -12, -34, 74)
		Aurora.SetBD(TaxiFrame, 3, -23, -5, 3)
		Aurora.SetBD(TradeFrame, 10, -12, -30, 52)
		Aurora.SetBD(ItemTextFrame, 16, -8, -28, 62)
		Aurora.SetBD(TabardFrame, 10, -12, -34, 74)
		Aurora.SetBD(HelpFrame)
		Aurora.SetBD(GuildRegistrarFrame, 6, -15, -26, 64)
		Aurora.SetBD(PetitionFrame, 6, -15, -26, 64)
		Aurora.SetBD(SpellBookFrame)
		Aurora.SetBD(LFDParentFrame)
		Aurora.SetBD(CharacterFrame)
		Aurora.SetBD(PVPFrame)
		Aurora.SetBD(PVPBannerFrame)
		Aurora.SetBD(PetStableFrame)
		Aurora.SetBD(EncounterJournal)
		Aurora.SetBD(WorldStateScoreFrame)

		local FrameBDs = {"StaticPopup1", "StaticPopup2", "GameMenuFrame", "InterfaceOptionsFrame", "VideoOptionsFrame", "AudioOptionsFrame", "LFDDungeonReadyStatus", "ChatConfigFrame", "StackSplitFrame", "AddFriendFrame", "FriendsFriendsFrame", "ColorPickerFrame", "ReadyCheckFrame", "LFDDungeonReadyDialog", "LFDRoleCheckPopup", "RolePollPopup", "GuildInviteFrame", "ChannelFrameDaughterFrame"}
		for i = 1, #FrameBDs do
			FrameBD = _G[FrameBDs[i]]
			Aurora.CreateBD(FrameBD)
			Aurora.CreateSD(FrameBD)
		end

		NPCBD = CreateFrame("Frame", nil, QuestNPCModel)
		NPCBD:SetPoint("TOPLEFT", 0, 1)
		NPCBD:SetPoint("RIGHT", 1, 0)
		NPCBD:SetPoint("BOTTOM", QuestNPCModelTextScrollFrame)
		NPCBD:SetFrameLevel(QuestNPCModel:GetFrameLevel()-1)
		Aurora.CreateBD(NPCBD)

		local line = CreateFrame("Frame", nil, QuestNPCModel)
		line:SetPoint("BOTTOMLEFT", 0, -1)
		line:SetPoint("BOTTOMRIGHT", 0, -1)
		line:SetHeight(1)
		line:SetFrameLevel(QuestNPCModel:GetFrameLevel()-1)
		Aurora.CreateBD(line, 0)

		-- Pet stuff

		if class == "HUNTER" or class == "MAGE" or class == "DEATHKNIGHT" or class == "WARLOCK" then
			if class == "HUNTER" then
				PetStableFrame:DisableDrawLayer("BACKGROUND")
				PetStableFrame:DisableDrawLayer("BORDER")
				PetStableFrameInset:DisableDrawLayer("BACKGROUND")
				PetStableFrameInset:DisableDrawLayer("BORDER")
				PetStableBottomInset:DisableDrawLayer("BACKGROUND")
				PetStableBottomInset:DisableDrawLayer("BORDER")
				PetStableLeftInset:DisableDrawLayer("BACKGROUND")
				PetStableLeftInset:DisableDrawLayer("BORDER")
				PetStableFramePortrait:Hide()
				PetStableModelShadow:Hide()
				PetStableFramePortraitFrame:Hide()
				PetStableFrameTopBorder:Hide()
				PetStableFrameTopRightCorner:Hide()
				PetStableModelRotateLeftButton:Hide()
				PetStableModelRotateRightButton:Hide()

				Aurora.ReskinClose(PetStableFrameCloseButton)
				Aurora.ReskinArrow(PetStablePrevPageButton, 1)
				Aurora.ReskinArrow(PetStableNextPageButton, 2)

				for i = 1, 10 do
					local bu = _G["PetStableStabledPet"..i]
					local bd = CreateFrame("Frame", nil, bu)
					bd:SetPoint("TOPLEFT", -1, 1)
					bd:SetPoint("BOTTOMRIGHT", 1, -1)
					Aurora.CreateBD(bd, .25)
					bu:SetNormalTexture("")
					bu:DisableDrawLayer("BACKGROUND")
					_G["PetStableStabledPet"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
				end
			end

			CharacterFrameTab3.SetPoint = Aurora.dummy

			PetModelFrameRotateLeftButton:Hide()
			PetModelFrameRotateRightButton:Hide()
			PetModelFrameShadowOverlay:Hide()
			PetPaperDollXPBar1:Hide()
			select(2, PetPaperDollFrameExpBar:GetRegions()):Hide()
			PetPaperDollPetModelBg:SetAlpha(0)

			local bbg = CreateFrame("Frame", nil, PetPaperDollFrameExpBar)
			bbg:SetPoint("TOPLEFT", -1, 1)
			bbg:SetPoint("BOTTOMRIGHT", 1, -1)
			bbg:SetFrameLevel(PetPaperDollFrameExpBar:GetFrameLevel()-1)
			Aurora.CreateBD(bbg, .25)
		end

		-- Ghost frame

		GhostFrameContentsFrameIcon:SetTexCoord(.08, .92, .08, .92)

		local GhostBD = CreateFrame("Frame", nil, GhostFrameContentsFrame)
		GhostBD:SetPoint("TOPLEFT", GhostFrameContentsFrameIcon, -1, 1)
		GhostBD:SetPoint("BOTTOMRIGHT", GhostFrameContentsFrameIcon, 1, -1)
		Aurora.CreateBD(GhostBD, 0)

		-- Mail frame

		OpenMailLetterButton:SetNormalTexture("")
		OpenMailLetterButton:SetPushedTexture("")
		OpenMailLetterButtonIconTexture:SetTexCoord(.08, .92, .08, .92)

		local bg = CreateFrame("Frame", nil, OpenMailLetterButton)
		bg:SetPoint("TOPLEFT", -1, 1)
		bg:SetPoint("BOTTOMRIGHT", 1, -1)
		bg:SetFrameLevel(OpenMailLetterButton:GetFrameLevel()-1)
		Aurora.CreateBD(bg)

		for i = 1, INBOXITEMS_TO_DISPLAY do
			local it = _G["MailItem"..i]
			local bu = _G["MailItem"..i.."Button"]
			local st = _G["MailItem"..i.."ButtonSlot"]
			local ic = _G["MailItem"..i.."Button".."Icon"]
			local line = select(3, _G["MailItem"..i]:GetRegions())

			local a, b = it:GetRegions()
			a:Hide()
			b:Hide()

			bu:SetCheckedTexture(Aurora.checked)

			st:Hide()
			line:Hide()
			ic:SetTexCoord(.08, .92, .08, .92)

			local bg = CreateFrame("Frame", nil, bu)
			bg:SetPoint("TOPLEFT", -1, 1)
			bg:SetPoint("BOTTOMRIGHT", 1, -1)
			bg:SetFrameLevel(bu:GetFrameLevel()-1)
			Aurora.CreateBD(bg, 0)
		end

		for i = 1, ATTACHMENTS_MAX_SEND do
			local button = _G["SendMailAttachment"..i]
			button:GetRegions():Hide()

			local bg = CreateFrame("Frame", nil, button)
			bg:SetPoint("TOPLEFT", -1, 1)
			bg:SetPoint("BOTTOMRIGHT", 1, -1)
			bg:SetFrameLevel(0)
			Aurora.CreateBD(bg, .25)
		end

		for i = 1, ATTACHMENTS_MAX_RECEIVE do
			local bu = _G["OpenMailAttachmentButton"..i]
			local ic = _G["OpenMailAttachmentButton"..i.."IconTexture"]

			bu:SetNormalTexture("")
			bu:SetPushedTexture("")
			ic:SetTexCoord(.08, .92, .08, .92)

			local bg = CreateFrame("Frame", nil, bu)
			bg:SetPoint("TOPLEFT", -1, 1)
			bg:SetPoint("BOTTOMRIGHT", 1, -1)
			bg:SetFrameLevel(0)
			Aurora.CreateBD(bg, .25)
		end

		hooksecurefunc("SendMailFrame_Update", function()
			for i = 1, ATTACHMENTS_MAX_SEND do
				local button = _G["SendMailAttachment"..i]
				if button:GetNormalTexture() then
					button:GetNormalTexture():SetTexCoord(.08, .92, .08, .92)
				end
			end
		end)

		-- Currency frame

		TokenFrame:HookScript("OnShow", function()
			for i=1, GetCurrencyListSize() do
				local button = _G["TokenFrameContainerButton"..i]

				if button and not button.reskinned then
					button.highlight:SetPoint("TOPLEFT", 1, 0)
					button.highlight:SetPoint("BOTTOMRIGHT", -1, 0)
					button.highlight.SetPoint = Aurora.dummy
					button.highlight:SetTexture(r, g, b, .2)
					button.highlight.SetTexture = Aurora.dummy
					button.categoryMiddle:SetAlpha(0)	
					button.categoryLeft:SetAlpha(0)	
					button.categoryRight:SetAlpha(0)

					if button.icon and button.icon:GetTexture() then
						button.icon:SetTexCoord(.08, .92, .08, .92)
						Aurora.CreateBG(button.icon)
					end
					button.reskinned = true
				end
			end
		end)

		-- Reputation frame

		local function UpdateFactionSkins()
			for i = 1, GetNumFactions() do
				local statusbar = _G["ReputationBar"..i.."ReputationBar"]

				if statusbar then
					statusbar:SetStatusBarTexture(Aurora.backdrop)

					if not statusbar.reskinned then
						Aurora.CreateBD(statusbar, .25)
						statusbar.reskinned = true
					end

					_G["ReputationBar"..i.."Background"]:SetTexture(nil)
					_G["ReputationBar"..i.."LeftLine"]:SetAlpha(0)
					_G["ReputationBar"..i.."BottomLine"]:SetAlpha(0)
					_G["ReputationBar"..i.."ReputationBarHighlight1"]:SetTexture(nil)
					_G["ReputationBar"..i.."ReputationBarHighlight2"]:SetTexture(nil)	
					_G["ReputationBar"..i.."ReputationBarAtWarHighlight1"]:SetTexture(nil)
					_G["ReputationBar"..i.."ReputationBarAtWarHighlight2"]:SetTexture(nil)
					_G["ReputationBar"..i.."ReputationBarLeftTexture"]:SetTexture(nil)
					_G["ReputationBar"..i.."ReputationBarRightTexture"]:SetTexture(nil)
				end		
			end		
		end

		ReputationFrame:HookScript("OnShow", UpdateFactionSkins)
		hooksecurefunc("ReputationFrame_OnEvent", UpdateFactionSkins)

		-- LFD frame

		LFDQueueFrameCapBarProgress:SetTexture(Aurora.backdrop)
		LFDQueueFrameCapBarCap1:SetTexture(Aurora.backdrop)
		LFDQueueFrameCapBarCap2:SetTexture(Aurora.backdrop)

		LFDQueueFrameCapBarLeft:Hide()
		LFDQueueFrameCapBarMiddle:Hide()
		LFDQueueFrameCapBarRight:Hide()
		LFDQueueFrameCapBarBG:SetTexture(nil)

		LFDQueueFrameCapBar.backdrop = CreateFrame("Frame", nil, LFDQueueFrameCapBar)
		LFDQueueFrameCapBar.backdrop:SetPoint("TOPLEFT", LFDQueueFrameCapBar, "TOPLEFT", -1, -2)
		LFDQueueFrameCapBar.backdrop:SetPoint("BOTTOMRIGHT", LFDQueueFrameCapBar, "BOTTOMRIGHT", 1, 2)
		LFDQueueFrameCapBar.backdrop:SetFrameLevel(0)
		Aurora.CreateBD(LFDQueueFrameCapBar.backdrop)

		for i = 1, 2 do
			local bu = _G["LFDQueueFrameCapBarCap"..i.."Marker"]
			_G["LFDQueueFrameCapBarCap"..i.."MarkerTexture"]:Hide()

			local cap = bu:CreateTexture(nil, "OVERLAY")
			cap:SetSize(1, 14)
			cap:SetPoint("CENTER")
			cap:SetTexture(Aurora.backdrop)
			cap:SetVertexColor(0, 0, 0)
		end

		LFDQueueFrameRandomScrollFrame:SetWidth(304)

		LFDQueueFrameRandom:HookScript("OnShow", function()
			for i = 1, LFD_MAX_REWARDS do
				local button = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i]
				local cta = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."ShortageBorder"]
				local icon = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."IconTexture"]
				local count = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."Count"]
				local na = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."NameFrame"]
				local role1 = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."RoleIcon1"]
				local role2 = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."RoleIcon2"]
				local role3 = _G["LFDQueueFrameRandomScrollFrameChildFrameItem"..i.."RoleIcon3"]

				if button then
					icon:SetTexCoord(.08, .92, .08, .92)
					if cta then cta:SetAlpha(0) end
					if not button.reskinned then
						Aurora.CreateBG(icon)
						icon:SetDrawLayer("OVERLAY")
						count:SetDrawLayer("OVERLAY")
						na:SetTexture(0, 0, 0, .25)
						na:SetSize(118, 39)

						button.bg2 = CreateFrame("Frame", nil, button)
						button.bg2:SetPoint("TOPLEFT", na, "TOPLEFT", 10, 0)
						button.bg2:SetPoint("BOTTOMRIGHT", na, "BOTTOMRIGHT")
						Aurora.CreateBD(button.bg2, 0)

						button.reskinned = true
					end
				end
			end
		end)

		-- Spellbook

		for i = 1, SPELLS_PER_PAGE do
			local bu = _G["SpellButton"..i]
			local ic = _G["SpellButton"..i.."IconTexture"]
			_G["SpellButton"..i.."Background"]:SetAlpha(0)
			_G["SpellButton"..i.."TextBackground"]:Hide()
			_G["SpellButton"..i.."SlotFrame"]:SetAlpha(0)
			_G["SpellButton"..i.."UnlearnedSlotFrame"]:SetAlpha(0)
			_G["SpellButton"..i.."Highlight"]:SetAlpha(0)

			bu:SetCheckedTexture("")
			bu:SetPushedTexture("")

			ic:SetTexCoord(.08, .92, .08, .92)
			local bg = CreateFrame("Frame", nil, bu)
			bg:SetPoint("TOPLEFT", ic, -1, 1)
			bg:SetPoint("BOTTOMRIGHT", ic, 1, -1)
			bg:SetFrameLevel(0)
			Aurora.CreateBD(bg, .25)
		end

		hooksecurefunc("SpellButton_UpdateButton", function(self)
			local slot, slotType = SpellBook_GetSpellBookSlot(self);
			local name = self:GetName();
			local subSpellString = _G[name.."SubSpellName"]

			subSpellString:SetTextColor(1, 1, 1)
			if slotType == "FUTURESPELL" then
				local level = GetSpellAvailableLevel(slot, SpellBookFrame.bookType)
				if (level and level > UnitLevel("player")) then
					self.RequiredLevelString:SetTextColor(.7, .7, .7)
					self.SpellName:SetTextColor(.7, .7, .7)
					subSpellString:SetTextColor(.7, .7, .7)
				end
			end
		end)

		for i = 1, 5 do
			local tab = _G["SpellBookSkillLineTab"..i]
			tab:GetRegions():Hide()
			tab:SetCheckedTexture(Aurora.checked)
			local a1, p, a2, x, y = tab:GetPoint()
			tab:SetPoint(a1, p, a2, x + 11, y)
			Aurora.CreateBG(tab)
			Aurora.CreateSD(tab, 5, 0, 0, 0, 1, 1)
			_G["SpellBookSkillLineTab"..i.."TabardIconFrame"]:SetTexCoord(.08, .92, .08, .92)
			select(4, tab:GetRegions()):SetTexCoord(.08, .92, .08, .92)
		end

		-- Professions

		local professions = {"PrimaryProfession1", "PrimaryProfession2", "SecondaryProfession1", "SecondaryProfession2", "SecondaryProfession3", "SecondaryProfession4"}

		for _, button in pairs(professions) do
			local bu = _G[button]
			bu.professionName:SetTextColor(1, 1, 1)
			bu.missingHeader:SetTextColor(1, 1, 1)
			bu.missingText:SetTextColor(1, 1, 1)
		end

		local professionbuttons = {"PrimaryProfession1SpellButtonTop", "PrimaryProfession1SpellButtonBottom", "PrimaryProfession2SpellButtonTop", "PrimaryProfession2SpellButtonBottom", "SecondaryProfession1SpellButtonLeft", "SecondaryProfession1SpellButtonRight", "SecondaryProfession2SpellButtonLeft", "SecondaryProfession2SpellButtonRight", "SecondaryProfession3SpellButtonLeft", "SecondaryProfession3SpellButtonRight", "SecondaryProfession4SpellButtonLeft", "SecondaryProfession4SpellButtonRight"}

		for _, button in pairs(professionbuttons) do
			local icon = _G[button.."IconTexture"]
			local bu = _G[button]
			_G[button.."NameFrame"]:SetAlpha(0)

			bu:SetPushedTexture("")
			bu:SetCheckedTexture(Aurora.checked)
			bu:GetHighlightTexture():Hide()

			if icon then
				icon:SetTexCoord(.08, .92, .08, .92)
				icon:ClearAllPoints()
				icon:SetPoint("TOPLEFT", 2, -2)
				icon:SetPoint("BOTTOMRIGHT", -2, 2)
				Aurora.CreateBG(icon)
			end					
		end

		for i = 1, 2 do
			local bu = _G["PrimaryProfession"..i]
			local bg = CreateFrame("Frame", nil, bu)
			bg:SetPoint("TOPLEFT")
			bg:SetPoint("BOTTOMRIGHT", 0, -4)
			bg:SetFrameLevel(0)
			Aurora.CreateBD(bg, .25)
		end

		-- Mounts and pets

		for i = 1, NUM_COMPANIONS_PER_PAGE do
			_G["SpellBookCompanionButton"..i.."Background"]:Hide()
			_G["SpellBookCompanionButton"..i.."TextBackground"]:Hide()
			_G["SpellBookCompanionButton"..i.."ActiveTexture"]:SetTexture(Aurora.checked)

			local bu = _G["SpellBookCompanionButton"..i]
			local ic = _G["SpellBookCompanionButton"..i.."IconTexture"]

			if ic then
				ic:SetTexCoord(.08, .92, .08, .92)

				bu.bd = CreateFrame("Frame", nil, bu)
				bu.bd:SetPoint("TOPLEFT", ic, -1, 1)
				bu.bd:SetPoint("BOTTOMRIGHT", ic, 1, -1)
				Aurora.CreateBD(bu.bd, 0)

				bu:SetPushedTexture(nil)
				bu:SetCheckedTexture(nil)
			end
		end

		-- Merchant Frame

		for i = 1, 12 do
			local button = _G["MerchantItem"..i]
			local bu = _G["MerchantItem"..i.."ItemButton"]
			local ic = _G["MerchantItem"..i.."ItemButtonIconTexture"]
			local mo = _G["MerchantItem"..i.."MoneyFrame"]

			_G["MerchantItem"..i.."SlotTexture"]:Hide()
			_G["MerchantItem"..i.."NameFrame"]:Hide()
			_G["MerchantItem"..i.."Name"]:SetHeight(20)
			local a1, p, a2= bu:GetPoint()
			bu:SetPoint(a1, p, a2, -2, -2)
			bu:SetNormalTexture("")
			bu:SetPushedTexture("")
			bu:SetSize(40, 40)

			local a3, p2, a4, x, y = mo:GetPoint()
			mo:SetPoint(a3, p2, a4, x, y+2)

			Aurora.CreateBD(bu, 0)

			button.bd = CreateFrame("Frame", nil, button)
			button.bd:SetPoint("TOPLEFT", 39, 0)
			button.bd:SetPoint("BOTTOMRIGHT")
			button.bd:SetFrameLevel(0)
			Aurora.CreateBD(button.bd, .25)

			ic:SetTexCoord(.08, .92, .08, .92)
			ic:ClearAllPoints()
			ic:SetPoint("TOPLEFT", 1, -1)
			ic:SetPoint("BOTTOMRIGHT", -1, 1)
		end

		MerchantBuyBackItemSlotTexture:Hide()
		MerchantBuyBackItemNameFrame:Hide()
		MerchantBuyBackItemItemButton:SetNormalTexture("")
		MerchantBuyBackItemItemButton:SetPushedTexture("")

		Aurora.CreateBD(MerchantBuyBackItemItemButton, 0)
		Aurora.CreateBD(MerchantBuyBackItem, .25)

		MerchantBuyBackItemItemButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
		MerchantBuyBackItemItemButtonIconTexture:ClearAllPoints()
		MerchantBuyBackItemItemButtonIconTexture:SetPoint("TOPLEFT", 1, -1)
		MerchantBuyBackItemItemButtonIconTexture:SetPoint("BOTTOMRIGHT", -1, 1)

		MerchantGuildBankRepairButton:SetPushedTexture("")
		Aurora.CreateBG(MerchantGuildBankRepairButton)
		MerchantGuildBankRepairButtonIcon:SetTexCoord(0.61, 0.82, 0.1, 0.52)

		MerchantRepairAllButton:SetPushedTexture("")
		Aurora.CreateBG(MerchantRepairAllButton)
		MerchantRepairAllIcon:SetTexCoord(0.34, 0.1, 0.34, 0.535, 0.535, 0.1, 0.535, 0.535)

		MerchantRepairItemButton:SetPushedTexture("")
		Aurora.CreateBG(MerchantRepairItemButton)
		local ic = MerchantRepairItemButton:GetRegions():SetTexCoord(0.04, 0.24, 0.06, 0.5)

		hooksecurefunc("MerchantFrame_UpdateCurrencies", function()
			for i = 1, MAX_MERCHANT_CURRENCIES do
				local bu = _G["MerchantToken"..i]
				if bu and not bu.reskinned then
					local ic = _G["MerchantToken"..i.."Icon"]
					local co = _G["MerchantToken"..i.."Count"]

					ic:SetTexCoord(.08, .92, .08, .92)
					ic:SetDrawLayer("OVERLAY")
					ic:SetPoint("LEFT", co, "RIGHT", 2, 0)
					co:SetPoint("TOPLEFT", bu, "TOPLEFT", -2, 0)

					Aurora.CreateBG(ic)
					bu.reskinned = true
				end
			end
		end)

		-- Friends Frame

		for i = 1, FRIENDS_TO_DISPLAY do
			local bu = _G["FriendsFrameFriendsScrollFrameButton"..i]
			local ic = _G["FriendsFrameFriendsScrollFrameButton"..i.."GameIcon"]

			bu:SetHighlightTexture(Aurora.backdrop)
			bu:GetHighlightTexture():SetVertexColor(.24, .56, 1, .2)

			ic:SetSize(22, 22)
			ic:SetTexCoord(.15, .85, .15, .85)

			ic:ClearAllPoints()
			ic:SetPoint("RIGHT", bu, "RIGHT", -2, 0)
		end

		local function UpdateScroll()
			for i = 1, FRIENDS_TO_DISPLAY do
				local bu = _G["FriendsFrameFriendsScrollFrameButton"..i]
				local ic = _G["FriendsFrameFriendsScrollFrameButton"..i.."GameIcon"]
				if not bu.bg then
					bu.bg = CreateFrame("Frame", nil, bu)
					bu.bg:SetPoint("TOPLEFT", ic)
					bu.bg:SetPoint("BOTTOMRIGHT", ic)
					Aurora.CreateBD(bu.bg, 0)
				end
				if bu.buttonType == FRIENDS_BUTTON_TYPE_BNET and select(7, BNGetFriendInfo(bu.id)) == true then
					bu.bg:Show()
				else
					bu.bg:Hide()
				end
			end
		end

		local friendshandler = CreateFrame("Frame")
		friendshandler:RegisterEvent("FRIENDLIST_UPDATE")
		friendshandler:RegisterEvent("BN_FRIEND_TOON_ONLINE")
		friendshandler:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
		friendshandler:SetScript("OnEvent", UpdateScroll)
		FriendsFrameFriendsScrollFrame:HookScript("OnVerticalScroll", UpdateScroll)

		-- Nav Bar

		local function navButtonFrameLevel(self)
			for i=1, #self.navList do
				local navButton = self.navList[i]
				local lastNav = self.navList[i-1]
				if navButton and lastNav then
					navButton:SetFrameLevel(lastNav:GetFrameLevel() - 2)
					navButton:ClearAllPoints()
					navButton:SetPoint("LEFT", lastNav, "RIGHT", 1, 0)
				end
			end			
		end

		hooksecurefunc("NavBar_AddButton", function(self, buttonData)
			local navButton = self.navList[#self.navList]


			if not navButton.skinned then
				Aurora.Reskin(navButton)
				navButton:GetRegions():SetAlpha(0)
				select(2, navButton:GetRegions()):SetAlpha(0)
				select(3, navButton:GetRegions()):SetAlpha(0)

				navButton.skinned = true

				navButton:HookScript("OnClick", function()
					navButtonFrameLevel(self)
				end)
			end

			navButtonFrameLevel(self)
		end)

		-- Character frame

		local slots = {
			"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
			"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
			"SecondaryHand", "Ranged", "Tabard",
		}

		for i = 1, #slots do
			local slot = _G["Character"..slots[i].."Slot"]
			local ic = _G["Character"..slots[i].."SlotIconTexture"]
			_G["Character"..slots[i].."SlotFrame"]:Hide()

			slot:SetNormalTexture("")
			slot:SetPushedTexture("")
			ic:SetTexCoord(.08, .92, .08, .92)

			slot.bg = slot:CreateTexture(nil, "BACKGROUND")
			slot.bg:SetPoint("TOPLEFT", -1, 1)
			slot.bg:SetPoint("BOTTOMRIGHT", 1, -1)
			slot.bg:SetTexture(Aurora.backdrop)
			slot.bg:SetVertexColor(0, 0, 0)
		end

		select(9, CharacterMainHandSlot:GetRegions()):Hide()
		select(9, CharacterRangedSlot:GetRegions()):Hide()

		hooksecurefunc("PaperDollItemSlotButton_Update", function()
			for i = 1, #slots do
				local slot = _G["Character"..slots[i].."Slot"]
				local ic = _G["Character"..slots[i].."SlotIconTexture"]

				if GetInventoryItemLink("player", i) then
					ic:SetAlpha(1)
					slot.bg:SetAlpha(1)
				else
					ic:SetAlpha(0)
					slot.bg:SetAlpha(0)
				end
			end
		end)

		for i = 1, #PAPERDOLL_SIDEBARS do
			local tab = _G["PaperDollSidebarTab"..i]

			if i == 1 then
				for i = 1, 4 do
					local region = select(i, tab:GetRegions())
					region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
					region.SetTexCoord = Aurora.dummy
				end
			end

			tab.Highlight:SetTexture(r, g, b, .2)
			tab.Highlight:SetPoint("TOPLEFT", 3, -4)
			tab.Highlight:SetPoint("BOTTOMRIGHT", -1, 0)
			tab.Hider:SetTexture(.3, .3, .3, .4)
			tab.TabBg:SetAlpha(0)

			select(2, tab:GetRegions()):ClearAllPoints()
			if i == 1 then
				select(2, tab:GetRegions()):SetPoint("TOPLEFT", 3, -4)
				select(2, tab:GetRegions()):SetPoint("BOTTOMRIGHT", -1, 0)
			else
				select(2, tab:GetRegions()):SetPoint("TOPLEFT", 2, -4)
				select(2, tab:GetRegions()):SetPoint("BOTTOMRIGHT", -1, -1)
			end

			tab.bg = CreateFrame("Frame", nil, tab)
			tab.bg:SetPoint("TOPLEFT", 2, -3)
			tab.bg:SetPoint("BOTTOMRIGHT", 0, -1)
			tab.bg:SetFrameLevel(0)
			Aurora.CreateBD(tab.bg)

			tab.Hider:SetPoint("TOPLEFT", tab.bg, 1, -1)
			tab.Hider:SetPoint("BOTTOMRIGHT", tab.bg, -1, 1)
		end

		for i = 1, NUM_GEARSET_ICONS_SHOWN do
			local bu = _G["GearManagerDialogPopupButton"..i]
			local ic = _G["GearManagerDialogPopupButton"..i.."Icon"]

			bu:SetCheckedTexture(Aurora.checked)
			select(2, bu:GetRegions()):Hide()
			ic:SetPoint("TOPLEFT", 1, -1)
			ic:SetPoint("BOTTOMRIGHT", -1, 1)
			ic:SetTexCoord(.08, .92, .08, .92)

			Aurora.CreateBD(bu, .25)
		end

		local sets = false
		PaperDollSidebarTab3:HookScript("OnClick", function()
			if sets == false then
				for i = 1, 8 do
					local bu = _G["PaperDollEquipmentManagerPaneButton"..i]
					local bd = _G["PaperDollEquipmentManagerPaneButton"..i.."Stripe"]
					local ic = _G["PaperDollEquipmentManagerPaneButton"..i.."Icon"]
					_G["PaperDollEquipmentManagerPaneButton"..i.."BgTop"]:SetAlpha(0)
					_G["PaperDollEquipmentManagerPaneButton"..i.."BgMiddle"]:Hide()
					_G["PaperDollEquipmentManagerPaneButton"..i.."BgBottom"]:SetAlpha(0)

					bd:Hide()
					bd.Show = Aurora.dummy
					ic:SetTexCoord(.08, .92, .08, .92)

					Aurora.CreateBG(ic)
				end
				sets = true
			end
		end)

		PaperDollFrameItemFlyoutButtons:HookScript("OnShow", function(self)
			for i = 1, PDFITEMFLYOUT_MAXITEMS do
				local bu = _G["PaperDollFrameItemFlyoutButtons"..i]
				if bu and not bu.reskinned then
					bu:SetNormalTexture("")
					Aurora.CreateBG(bu)

					_G["PaperDollFrameItemFlyoutButtons"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)

					bu.reskinned = true
				end

			end
		end)

		-- Quest Frame

		QuestInfoSkillPointFrameIconTexture:SetSize(40, 40)
		QuestInfoSkillPointFrameIconTexture:SetTexCoord(.08, .92, .08, .92)

		local bg = CreateFrame("Frame", nil, QuestInfoSkillPointFrame)
		bg:SetPoint("TOPLEFT", -3, 0)
		bg:SetPoint("BOTTOMRIGHT", -3, 0)
		bg:Lower()
		Aurora.CreateBD(bg, .25)

		QuestInfoSkillPointFrameNameFrame:Hide()
		QuestInfoSkillPointFrameName:SetParent(bg)
		QuestInfoSkillPointFrameIconTexture:SetParent(bg)
		QuestInfoSkillPointFrameSkillPointBg:SetParent(bg)
		QuestInfoSkillPointFrameSkillPointBgGlow:SetParent(bg)
		QuestInfoSkillPointFramePoints:SetParent(bg)

		local line = QuestInfoSkillPointFrame:CreateTexture(nil, "BACKGROUND")
		line:SetSize(1, 40)
		line:SetPoint("RIGHT", QuestInfoSkillPointFrameIconTexture, 1, 0)
		line:SetTexture(Aurora.backdrop)
		line:SetVertexColor(0, 0, 0)

		QuestInfoItemHighlight:SetParent(QuestFrame)
		QuestInfoItemHighlight:SetBackdrop({
			bgFile = Aurora.backdrop,
		})
		QuestInfoItemHighlight:SetBackdropColor(r, g, b, .2)

		hooksecurefunc("QuestInfoItem_OnClick", function(self)
			QuestInfoItemHighlight:ClearAllPoints()
			QuestInfoItemHighlight:SetPoint("TOPLEFT", self, 41, -1)
			QuestInfoItemHighlight:SetPoint("BOTTOMRIGHT", self, -1, 1)
		end)

		for i = 1, MAX_REQUIRED_ITEMS do
			local bu = _G["QuestProgressItem"..i]
			local ic = _G["QuestProgressItem"..i.."IconTexture"]
			local na = _G["QuestProgressItem"..i.."NameFrame"]
			local co = _G["QuestProgressItem"..i.."Count"]

			ic:SetSize(40, 40)
			ic:SetTexCoord(.08, .92, .08, .92)

			Aurora.CreateBD(bu, .25)

			na:Hide()
			co:SetDrawLayer("OVERLAY")

			local line = CreateFrame("Frame", nil, bu)
			line:SetSize(1, 40)
			line:SetPoint("RIGHT", ic, 1, 0)
			Aurora.CreateBD(line)
		end

		for i = 1, MAX_NUM_ITEMS do
			local bu = _G["QuestInfoItem"..i]
			local ic = _G["QuestInfoItem"..i.."IconTexture"]
			local na = _G["QuestInfoItem"..i.."NameFrame"]
			local co = _G["QuestInfoItem"..i.."Count"]

			ic:SetPoint("TOPLEFT", 1, -1)
			ic:SetSize(39, 39)
			ic:SetTexCoord(.08, .92, .08, .92)
			ic:SetDrawLayer("OVERLAY")

			Aurora.CreateBD(bu, .25)

			na:Hide()
			co:SetDrawLayer("OVERLAY")

			local line = CreateFrame("Frame", nil, bu)
			line:SetSize(1, 40)
			line:SetPoint("RIGHT", ic, 1, 0)
			Aurora.CreateBD(line)
		end

		-- PVP Frame

		PVPTeamManagementFrameFlag2Header:SetAlpha(0)
		PVPTeamManagementFrameFlag3Header:SetAlpha(0)
		PVPTeamManagementFrameFlag5Header:SetAlpha(0)
		PVPTeamManagementFrameFlag2HeaderSelected:SetAlpha(0)
		PVPTeamManagementFrameFlag3HeaderSelected:SetAlpha(0)
		PVPTeamManagementFrameFlag5HeaderSelected:SetAlpha(0)
		PVPTeamManagementFrameFlag2Title:SetTextColor(1, 1, 1)
		PVPTeamManagementFrameFlag3Title:SetTextColor(1, 1, 1)
		PVPTeamManagementFrameFlag5Title:SetTextColor(1, 1, 1)
		PVPTeamManagementFrameFlag2Title.SetTextColor = Aurora.dummy
		PVPTeamManagementFrameFlag3Title.SetTextColor = Aurora.dummy
		PVPTeamManagementFrameFlag5Title.SetTextColor = Aurora.dummy

		local pvpbg = CreateFrame("Frame", nil, PVPTeamManagementFrame)
		pvpbg:SetPoint("TOPLEFT", PVPTeamManagementFrameFlag2)
		pvpbg:SetPoint("BOTTOMRIGHT", PVPTeamManagementFrameFlag5)
		Aurora.CreateBD(pvpbg, .25)

		PVPFrameConquestBarLeft:Hide()
		PVPFrameConquestBarMiddle:Hide()
		PVPFrameConquestBarRight:Hide()
		PVPFrameConquestBarBG:Hide()
		PVPFrameConquestBarShadow:Hide()
		PVPFrameConquestBarCap1:SetAlpha(0)
		PVPFrameConquestBarCap1MarkerTexture:Hide()

		for i = 1, 4 do
			_G["PVPFrameConquestBarDivider"..i]:Hide()
		end

		PVPFrameConquestBarProgress:SetTexture(Aurora.backdrop)
		PVPFrameConquestBarProgress:SetGradient("VERTICAL", .7, 0, 0, .8, 0, 0)

		local cap = PVPFrameConquestBarCap1Marker:CreateTexture(nil, "OVERLAY")
		cap:SetSize(1, 14)
		cap:SetPoint("CENTER")
		cap:SetTexture(Aurora.backdrop)
		cap:SetVertexColor(0, 0, 0)

		local qbg = CreateFrame("Frame", nil, PVPFrameConquestBar)
		qbg:SetPoint("TOPLEFT", -1, -2)
		qbg:SetPoint("BOTTOMRIGHT", 1, 2)
		qbg:SetFrameLevel(PVPFrameConquestBar:GetFrameLevel()-1)
		Aurora.CreateBD(qbg, .25)

		-- StaticPopup

		for i = 1, 2 do
			local bu = _G["StaticPopup"..i.."ItemFrame"]
			_G["StaticPopup"..i.."ItemFrameNameFrame"]:Hide()
			_G["StaticPopup"..i.."ItemFrameIconTexture"]:SetTexCoord(.08, .92, .08, .92)

			bu:SetNormalTexture("")
			Aurora.CreateBG(bu)
		end

		-- Encounter journal

		EncounterJournalEncounterFrameInfoBossTab:ClearAllPoints()
		EncounterJournalEncounterFrameInfoBossTab:SetPoint("LEFT", EncounterJournalEncounterFrameInfoEncounterTile, "RIGHT", -10, 4)
		EncounterJournalEncounterFrameInfoLootTab:ClearAllPoints()
		EncounterJournalEncounterFrameInfoLootTab:SetPoint("LEFT", EncounterJournalEncounterFrameInfoBossTab, "RIGHT", -24, 0)
					
		EncounterJournalEncounterFrameInfoBossTab:SetFrameStrata("HIGH")
		EncounterJournalEncounterFrameInfoLootTab:SetFrameStrata("HIGH")
					
		EncounterJournalEncounterFrameInfoBossTab:SetScale(0.75)
		EncounterJournalEncounterFrameInfoLootTab:SetScale(0.75)

		EncounterJournalEncounterFrameInfoBossTab:SetNormalTexture(nil)
		EncounterJournalEncounterFrameInfoBossTab:SetPushedTexture(nil)
		EncounterJournalEncounterFrameInfoBossTab:SetDisabledTexture(nil)
		EncounterJournalEncounterFrameInfoBossTab:SetHighlightTexture(nil)

		EncounterJournalEncounterFrameInfoLootTab:SetNormalTexture(nil)
		EncounterJournalEncounterFrameInfoLootTab:SetPushedTexture(nil)
		EncounterJournalEncounterFrameInfoLootTab:SetDisabledTexture(nil)
		EncounterJournalEncounterFrameInfoLootTab:SetHighlightTexture(nil)

		local encounterbd = CreateFrame("Frame", nil, EncounterJournalEncounterFrameInfo)
		encounterbd:SetPoint("TOPLEFT", -1, 1)
		encounterbd:SetPoint("BOTTOMRIGHT", 1, -1)
		Aurora.CreateBD(encounterbd, 0)

		-- PvP cap bar

		local function CaptureBar()
			if not NUM_EXTENDED_UI_FRAMES then return end
			for i = 1, NUM_EXTENDED_UI_FRAMES do
				local barname = "WorldStateCaptureBar"..i
				local bar = _G[barname]

				if bar and bar:IsVisible() then
					bar:ClearAllPoints()
					bar:SetPoint("TOP", UIParent, "TOP", 0, -120)
					if not bar.skinned then
						local left = _G[barname.."LeftBar"]
						local right = _G[barname.."RightBar"]
						local middle = _G[barname.."MiddleBar"]

						left:SetTexture(Aurora.backdrop)
						right:SetTexture(Aurora.backdrop)
						middle:SetTexture(Aurora.backdrop)
						left:SetDrawLayer("BORDER")
						middle:SetDrawLayer("ARTWORK")
						right:SetDrawLayer("BORDER")

						left:SetGradient("VERTICAL", .1, .4, .9, .2, .6, 1)
						right:SetGradient("VERTICAL", .7, .1, .1, .9, .2, .2)
						middle:SetGradient("VERTICAL", .8, .8, .8, 1, 1, 1)

						_G[barname.."RightLine"]:SetAlpha(0)
						_G[barname.."LeftLine"]:SetAlpha(0)
						select(4, bar:GetRegions()):Hide()
						_G[barname.."LeftIconHighlight"]:SetAlpha(0)
						_G[barname.."RightIconHighlight"]:SetAlpha(0)

						bar.bg = bar:CreateTexture(nil, "BACKGROUND")
						bar.bg:SetPoint("TOPLEFT", left, -1, 1)
						bar.bg:SetPoint("BOTTOMRIGHT", right, 1, -1)
						bar.bg:SetTexture(Aurora.backdrop)
						bar.bg:SetVertexColor(0, 0, 0)

						bar.bgmiddle = CreateFrame("Frame", nil, bar)
						bar.bgmiddle:SetPoint("TOPLEFT", middle, -1, 1)
						bar.bgmiddle:SetPoint("BOTTOMRIGHT", middle, 1, -1)
						Aurora.CreateBD(bar.bgmiddle, 0)

						bar.skinned = true
					end
				end
			end
		end

		hooksecurefunc("UIParent_ManageFramePositions", CaptureBar)

		-- [[ Hide regions ]]

		local bglayers = {"FriendsFrame", "SpellBookFrame", "LFDParentFrame", "LFDParentFrameInset", "WhoFrameColumnHeader1", "WhoFrameColumnHeader2", "WhoFrameColumnHeader3", "WhoFrameColumnHeader4", "RaidInfoInstanceLabel", "RaidInfoIDLabel", "CharacterFrame", "CharacterFrameInset", "CharacterFrameInsetRight", "GossipFrameGreetingPanel", "PVPFrame", "PVPFrameInset", "PVPFrameTopInset", "PVPTeamManagementFrame", "PVPTeamManagementFrameHeader1", "PVPTeamManagementFrameHeader2", "PVPTeamManagementFrameHeader3", "PVPTeamManagementFrameHeader4", "PVPBannerFrame", "PVPBannerFrameInset", "LFRQueueFrame", "LFRBrowseFrame", "HelpFrameMainInset", "CharacterModelFrame", "HelpFrame", "HelpFrameLeftInset", "QuestFrameDetailPanel", "QuestFrameProgressPanel", "QuestFrameRewardPanel", "WorldStateScoreFrame", "WorldStateScoreFrameInset", "QuestFrameGreetingPanel", "PaperDollFrameItemFlyoutButtons"}
		for i = 1, #bglayers do
			_G[bglayers[i]]:DisableDrawLayer("BACKGROUND")
		end
		local borderlayers = {"SpellBookFrame", "SpellBookFrameInset", "LFDParentFrame", "LFDParentFrameInset", "CharacterFrame", "CharacterFrameInset", "CharacterFrameInsetRight", "MerchantFrame", "PVPFrame", "PVPFrameInset", "PVPConquestFrameInfoButton", "PVPFrameTopInset", "PVPTeamManagementFrame", "PVPBannerFrame", "PVPBannerFrameInset", "TabardFrame", "QuestLogDetailFrame", "HelpFrame", "HelpFrameLeftInset", "HelpFrameMainInset", "TaxiFrame", "ItemTextFrame", "CharacterModelFrame", "OpenMailFrame", "EncounterJournal", "EncounterJournalInset", "EncounterJournalNavBar", "WorldStateScoreFrame", "WorldStateScoreFrameInset"}
		for i = 1, #borderlayers do
			_G[borderlayers[i]]:DisableDrawLayer("BORDER")
		end
		local overlayers = {"SpellBookFrame", "LFDParentFrame", "CharacterModelFrame", "MerchantFrame", "TaxiFrame", "EncounterJournal", "EncounterJournalInstanceSelectDungeonTab", "EncounterJournalInstanceSelectRaidTab"}
		for i = 1, #overlayers do
			_G[overlayers[i]]:DisableDrawLayer("OVERLAY")
		end
		local artlayers = {"GossipFrameGreetingPanel", "PVPConquestFrame", "TabardFrame", "GuildRegistrarFrame", "QuestLogDetailFrame", "PaperDollFrameItemFlyoutButtons"}
		for i = 1, #artlayers do
			_G[artlayers[i]]:DisableDrawLayer("ARTWORK")
		end
		CharacterFramePortrait:Hide()
		for i = 1, 3 do
			select(i, QuestLogFrame:GetRegions()):Hide()
			for j = 1, 2 do
				select(i, _G["PVPBannerFrameCustomization"..j]:GetRegions()):Hide()
			end
		end
		QuestLogDetailFrame:GetRegions():Hide()
		QuestFramePortrait:Hide()
		GossipFramePortrait:Hide()
		for i = 1, 6 do
			_G["HelpFrameButton"..i.."Selected"]:SetAlpha(0)
			for j = 1, 3 do
				select(i, _G["FriendsTabHeaderTab"..j]:GetRegions()):Hide()
				select(i, _G["FriendsTabHeaderTab"..j]:GetRegions()).Show = Aurora.dummy
			end
		end
		FriendsFrameTitleText:Hide()
		SpellBookCompanionModelFrameShadowOverlay:Hide()
		PVPFramePortrait:Hide()
		PVPHonorFrameBGTex:Hide()
		LFRParentFrameIcon:Hide()
		for i = 1, 5 do
			select(i, MailFrame:GetRegions()):Hide()
			_G["TabardFrameCustomization"..i.."Left"]:Hide()
			_G["TabardFrameCustomization"..i.."Middle"]:Hide()
			_G["TabardFrameCustomization"..i.."Right"]:Hide()
		end
		OpenMailFrameIcon:Hide()
		OpenMailHorizontalBarLeft:Hide()
		select(13, OpenMailFrame:GetRegions()):Hide()
		OpenStationeryBackgroundLeft:Hide()
		OpenStationeryBackgroundRight:Hide()
		for i = 4, 7 do
			select(i, SendMailFrame:GetRegions()):Hide()
		end
		SendStationeryBackgroundLeft:Hide()
		SendStationeryBackgroundRight:Hide()
		MerchantFramePortrait:Hide()
		DressUpFramePortrait:Hide()
		DressUpBackgroundTopLeft:Hide()
		DressUpBackgroundTopRight:Hide()
		DressUpBackgroundBotLeft:Hide()
		DressUpBackgroundBotRight:Hide()
		TradeFrameRecipientPortrait:Hide()
		TradeFramePlayerPortrait:Hide()
		for i = 1, 4 do
			select(i, GearManagerDialogPopup:GetRegions()):Hide()
			_G["LFDQueueFrameCapBarDivider"..i]:Hide()
		end
		StackSplitFrame:GetRegions():Hide()
		ItemTextFrame:GetRegions():Hide()
		ItemTextScrollFrameMiddle:Hide()
		ReputationDetailCorner:Hide()
		ReputationDetailDivider:Hide()
		QuestNPCModelShadowOverlay:Hide()
		QuestNPCModelBg:Hide()
		QuestNPCModel:DisableDrawLayer("OVERLAY")
		QuestNPCModelNameText:SetDrawLayer("ARTWORK")
		QuestNPCModelTextFrameBg:Hide()
		QuestNPCModelTextFrame:DisableDrawLayer("OVERLAY")
		TabardFramePortrait:Hide()
		LFDParentFrameEyeFrame:Hide()
		RaidInfoDetailFooter:Hide()
		RaidInfoDetailHeader:Hide()
		RaidInfoDetailCorner:Hide()
		RaidInfoFrameHeader:Hide()
		for i = 1, 9 do
			select(i, QuestLogCount:GetRegions()):Hide()
			select(i, FriendsFriendsNoteFrame:GetRegions()):Hide()
			select(i, AddFriendNoteFrame:GetRegions()):Hide()
		end
		PVPBannerFramePortrait:Hide()
		HelpFrameHeader:Hide()
		ReadyCheckPortrait:SetAlpha(0)
		select(2, ReadyCheckListenerFrame:GetRegions()):Hide()
		HelpFrameLeftInsetBg:Hide()
		LFDQueueFrameCapBarShadow:Hide()
		LFDQueueFrameBackground:Hide()
		select(4, HelpFrameTicket:GetChildren()):Hide()
		HelpFrameKnowledgebaseStoneTex:Hide()
		HelpFrameKnowledgebaseNavBarOverlay:Hide()
		GhostFrameLeft:Hide()
		GhostFrameRight:Hide()
		GhostFrameMiddle:Hide()
		for i = 3, 6 do
			select(i, GhostFrame:GetRegions()):Hide()
			select(i, TradeFrame:GetRegions()):Hide()
		end
		PaperDollSidebarTabs:GetRegions():Hide()
		select(2, PaperDollSidebarTabs:GetRegions()):Hide()
		select(6, PaperDollEquipmentManagerPaneEquipSet:GetRegions()):Hide()
		select(5, HelpFrameGM_Response:GetChildren()):Hide()
		select(6, HelpFrameGM_Response:GetChildren()):Hide()

		select(2, PVPHonorFrameInfoScrollFrameScrollBar:GetRegions()):Hide()
		select(3, PVPHonorFrameInfoScrollFrameScrollBar:GetRegions()):Hide()
		select(4, PVPHonorFrameInfoScrollFrameScrollBar:GetRegions()):Hide()
		PVPHonorFrameTypeScrollFrame:GetRegions():Hide()
		select(2, PVPHonorFrameTypeScrollFrame:GetRegions()):Hide()
		LFDQueueFrameCooldownFrameBlackFilter:SetAlpha(.6)
		HelpFrameKnowledgebaseNavBarHomeButtonLeft:Hide()
		TokenFramePopupCorner:Hide()
		QuestNPCModelTextScrollFrameScrollBarThumbTexture.bg:Hide()
		GearManagerDialogPopupScrollFrame:GetRegions():Hide()
		select(2, GearManagerDialogPopupScrollFrame:GetRegions()):Hide()
		for i = 1, 10 do
			select(i, GuildInviteFrame:GetRegions()):Hide()
		end
		CharacterFrameExpandButton:GetNormalTexture():SetAlpha(0)
		CharacterFrameExpandButton:GetPushedTexture():SetAlpha(0)
		InboxPrevPageButton:GetRegions():Hide()
		InboxNextPageButton:GetRegions():Hide()
		MerchantPrevPageButton:GetRegions():Hide()
		MerchantNextPageButton:GetRegions():Hide()
		select(2, MerchantPrevPageButton:GetRegions()):Hide()
		select(2, MerchantNextPageButton:GetRegions()):Hide()
		BNToastFrameCloseButton:SetAlpha(0)
		CharacterModelFrameRotateLeftButton:Hide()
		CharacterModelFrameRotateRightButton:Hide()
		DressUpModelRotateLeftButton:Hide()
		DressUpModelRotateRightButton:Hide()
		SpellBookCompanionModelFrameRotateLeftButton:Hide()
		SpellBookCompanionModelFrameRotateRightButton:Hide()
		ItemTextPrevPageButton:GetRegions():Hide()
		ItemTextNextPageButton:GetRegions():Hide()
		GuildRegistrarFramePortrait:Hide()
		LFDQueueFrameRandomScrollFrameScrollBackground:Hide()
		QuestLogFrameShowMapButton:Hide()
		QuestLogFrameShowMapButton.Show = Aurora.dummy
		select(6, GuildRegistrarFrameEditBox:GetRegions()):Hide()
		select(7, GuildRegistrarFrameEditBox:GetRegions()):Hide()
		LFDQueueFramePartyBackfill:SetAlpha(.6)
		ChannelFrameDaughterFrameCorner:Hide()
		PetitionFramePortrait:Hide()
		FriendsFrame:DisableDrawLayer("LOW")
		LFDQueueFrameCancelButton_LeftSeparator:Hide()
		LFDQueueFrameFindGroupButton_RightSeparator:Hide()
		LFDQueueFrameSpecificListScrollFrameScrollBackgroundTopLeft:Hide()
		LFDQueueFrameSpecificListScrollFrameScrollBackgroundBottomRight:Hide()
		for i = 1, MAX_DISPLAY_CHANNEL_BUTTONS do
			_G["ChannelButton"..i]:SetNormalTexture("")
		end
		ChannelFrameVerticalBar:Hide()
		CharacterStatsPaneTop:Hide()
		CharacterStatsPaneBottom:Hide()
		hooksecurefunc("PaperDollFrame_CollapseStatCategory", function(categoryFrame)
			categoryFrame.BgMinimized:Hide()
		end)
		hooksecurefunc("PaperDollFrame_ExpandStatCategory", function(categoryFrame)
			categoryFrame.BgTop:Hide()
			categoryFrame.BgMiddle:Hide()
			categoryFrame.BgBottom:Hide()
		end)
		CharacterFramePortraitFrame:Hide()
		CharacterFrameTopRightCorner:Hide()
		CharacterFrameTopBorder:Hide()
		local titles = false
		hooksecurefunc("PaperDollTitlesPane_Update", function()
			if titles == false then
				for i = 1, 17 do
					_G["PaperDollTitlesPaneButton"..i]:DisableDrawLayer("BACKGROUND")
				end
				titles = true
			end
		end)
		ReputationListScrollFrame:GetRegions():Hide()
		select(2, ReputationListScrollFrame:GetRegions()):Hide()
		select(3, ReputationDetailFrame:GetRegions()):Hide()
		MerchantNameText:SetDrawLayer("ARTWORK")
		BuybackFrameTopLeft:SetAlpha(0)
		BuybackFrameTopRight:SetAlpha(0)
		BuybackFrameBotLeft:SetAlpha(0)
		BuybackFrameBotRight:SetAlpha(0)
		SendScrollBarBackgroundTop:Hide()
		select(4, SendMailScrollFrame:GetRegions()):Hide()
		PVPFramePortraitFrame:Hide()
		PVPFrameTopBorder:Hide()
		PVPFrameTopRightCorner:Hide()
		PVPFrameLeftButton_RightSeparator:Hide()
		PVPFrameRightButton_LeftSeparator:Hide()
		PVPBannerFrameCustomizationBorder:Hide()
		PVPBannerFramePortraitFrame:Hide()
		PVPBannerFrameTopBorder:Hide()
		PVPBannerFrameTopRightCorner:Hide()
		PVPBannerFrameAcceptButton_RightSeparator:Hide()
		PVPBannerFrameCancelButton_LeftSeparator:Hide()
		for i = 7, 16 do
			select(i, TabardFrame:GetRegions()):Hide()
		end
		TabardFrameCustomizationBorder:Hide()
		select(2, GuildRegistrarGreetingFrame:GetRegions()):Hide()
		QuestLogDetailTitleText:SetDrawLayer("OVERLAY")
		SpellBookCompanionsModelFrame:Hide()
		for i = 1, 7 do
			_G["LFRBrowseFrameColumnHeader"..i]:DisableDrawLayer("BACKGROUND")
		end
		HelpFrameKnowledgebaseTopTileStreaks:Hide()
		TaxiFrameBg:Hide()
		TaxiFrameTitleBg:Hide()
		for i = 2, 5 do
			select(i, DressUpFrame:GetRegions()):Hide()
			select(i, PetitionFrame:GetRegions()):Hide()
		end
		ItemTextScrollFrameTop:Hide()
		ItemTextScrollFrameBottom:Hide()
		ChannelFrameDaughterFrameTitlebar:Hide()
		OpenScrollBarBackgroundTop:Hide()
		select(2, OpenMailScrollFrame:GetRegions()):Hide()
		QuestLogDetailScrollFrameScrollBackgroundTopLeft:SetAlpha(0)
		QuestLogDetailScrollFrameScrollBackgroundBottomRight:SetAlpha(0)
		select(2, WarGamesFrameInfoScrollFrameScrollBar:GetRegions()):Hide()
		select(3, WarGamesFrameInfoScrollFrameScrollBar:GetRegions()):Hide()
		select(4, WarGamesFrameInfoScrollFrameScrollBar:GetRegions()):Hide()
		EncounterJournalPortrait:Hide()
		EncounterJournalInstanceSelectBG:Hide()
		EncounterJournalNavBar:GetRegions():Hide()
		EncounterJournalNavBarOverlay:Hide()
		HelpFrameKnowledgebaseNavBar:GetRegions():Hide()
		EncounterJournalNavBarHomeButtonLeft:Hide()
		MerchantFrameExtraCurrencyTex:Hide()
		EncounterJournalBg:Hide()
		EncounterJournalInsetBg:Hide()
		EncounterJournalTitleBg:Hide()
		EncounterJournalInstanceSelectDungeonTabMid:Hide()
		EncounterJournalInstanceSelectRaidTabMid:Hide()
		for i = 8, 10 do
			select(i, EncounterJournalInstanceSelectDungeonTab:GetRegions()):SetAlpha(0)
			select(i, EncounterJournalInstanceSelectRaidTab:GetRegions()):SetAlpha(0)
		end
		WarGamesFrameBGTex:Hide()
		WarGamesFrameBarLeft:Hide()
		select(3, WarGamesFrame:GetRegions()):Hide()
		WarGameStartButton_RightSeparator:Hide()
		QuestLogFrameCompleteButton_LeftSeparator:Hide()
		QuestLogFrameCompleteButton_RightSeparator:Hide()
		WhoListScrollFrame:GetRegions():Hide()
		select(2, WhoListScrollFrame:GetRegions()):Hide()
		WorldStateScoreFrameTopLeftCorner:Hide()
		WorldStateScoreFrameTopBorder:Hide()
		WorldStateScoreFrameTopRightCorner:Hide()
		select(9, QuestFrameGreetingPanel:GetRegions()):Hide()
		QuestInfoItemHighlight:GetRegions():Hide()
		QuestInfoSpellObjectiveFrameNameFrame:Hide()

		ReadyCheckFrame:HookScript("OnShow", function(self) if UnitIsUnit("player", self.initiator) then self:Hide() end end)

		-- [[ Loot ]]

		if not IsAddOnLoaded("Butsu") and not IsAddOnLoaded("XLoot") then
			LootFramePortraitOverlay:Hide()
			select(3, LootFrame:GetRegions()):Hide()
			LootCloseButton:Hide()

			-- LootFrame:SetWidth(190)
			LootFrame:SetHeight(.001)
			LootFrame:SetHeight(.001)

			local reskinned = 1

			LootFrame:HookScript("OnShow", function()
				for i = reskinned, GetNumLootItems() do
					local bu = _G["LootButton"..i]
					local ic = _G["LootButton"..i.."IconTexture"]
					local qu = _G["LootButton"..i.."IconQuestTexture"]
					if not bu then return end
					local _, _, _, _, _, _, _, bg, na = bu:GetRegions()

					-- LootFrame:SetHeight(100 + 37 * i)

					local LootBD = CreateFrame("Frame", nil, bu)
					LootBD:SetFrameLevel(LootFrame:GetFrameLevel()-1)
					LootBD:SetPoint("TOPLEFT", 38, -1)
					LootBD:SetPoint("BOTTOMRIGHT", bu, 170, 1)

					Aurora.CreateBD(LootBD)
					Aurora.CreateBD(bu)

					bu:SetNormalTexture("")
					bu:SetPushedTexture("")
					ic:SetTexCoord(.08, .92, .08, .92)
					ic:SetPoint("TOPLEFT", 1, -1)
					ic:SetPoint("BOTTOMRIGHT", -1, 1)
					bg:Hide()
					qu:SetTexture("Interface\\AddOns\\Aurora\\quest")
					qu:SetVertexColor(1, 0, 0)
					qu:SetTexCoord(.03, .97, .03, .995)
					qu.SetTexture = Aurora.dummy
					na:SetWidth(174)

					reskinned = i + 1
				end
			end)
		end

		-- [[ Bags ]]

		if not IsAddOnLoaded("Baggins") and not IsAddOnLoaded("Stuffing") and not IsAddOnLoaded("Combuctor") and not IsAddOnLoaded("cargBags") and not IsAddOnLoaded("famBags") and not IsAddOnLoaded("ArkInventory") then
			for i = 1, 5 do
				local con = _G["ContainerFrame"..i]
				for j = 1, 7 do
					select(j, con:GetRegions()):Hide()
					select(j, con:GetRegions()).Show = Aurora.dummy
				end
				for k = 1, MAX_CONTAINER_ITEMS do
					_G["ContainerFrame"..i.."Item"..k]:SetNormalTexture("")
					_G["ContainerFrame"..i.."Item"..k.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
					_G["ContainerFrame"..i.."Item"..k.."IconQuestTexture"]:SetTexture("Interface\\AddOns\\FreeBags\\border")
					_G["ContainerFrame"..i.."Item"..k.."IconQuestTexture"]:SetVertexColor(1, 0, 0)
					_G["ContainerFrame"..i.."Item"..k.."IconQuestTexture"]:SetTexCoord(0.05, .955, 0.05, .965)
					_G["ContainerFrame"..i.."Item"..k.."IconQuestTexture"].SetTexture = Aurora.dummy
					local bd = CreateFrame("Frame", nil, _G["ContainerFrame"..i.."Item"..k])
					bd:SetPoint("TOPLEFT", -1, 1)
					bd:SetPoint("BOTTOMRIGHT", 1, -1)
					bd:SetFrameLevel(0)
					Aurora.CreateBD(bd, 0)
				end

				local f = CreateFrame("Frame", nil, con)
				f:SetPoint("TOPLEFT", 8, -4)
				f:SetPoint("BOTTOMRIGHT", -4, 3)
				f:SetFrameLevel(con:GetFrameLevel()-1)
				Aurora.CreateBD(f, .6)
			end

			BackpackTokenFrame:GetRegions():Hide()

			for i = 1, 3 do
				local ic = _G["BackpackTokenFrameToken"..i.."Icon"]
				ic:SetTexCoord(.08, .92, .08, .92)
				local bg = CreateFrame("Frame", nil, _G["BackpackTokenFrameToken"..i])
				bg:SetPoint("TOPLEFT", ic)
				bg:SetPoint("BOTTOMRIGHT", ic)
				Aurora.CreateBD(bg, 0)
			end
		end

		-- [[ Tooltips ]]

		if not IsAddOnLoaded("CowTip") and not IsAddOnLoaded("TipTac") and not IsAddOnLoaded("FreebTip") and not IsAddOnLoaded("lolTip") and not IsAddOnLoaded("StarTip") then
			do
				local tooltips = {
					"GameTooltip",
					"ItemRefTooltip",
					"ShoppingTooltip1",
					"ShoppingTooltip2",
					"ShoppingTooltip3",
					"WorldMapTooltip",
					"ChatMenu",
					"EmoteMenu",
					"LanguageMenu",
					"VoiceMacroMenu",
				}

				for i = 1, #tooltips do
					local t = _G[tooltips[i]]
					t:SetBackdrop(nil)
					local bg = CreateFrame("Frame", nil, t)
					bg:SetBackdrop({ 
						bgFile = Aurora.backdrop, 
						edgeFile = Aurora.backdrop,
						edgeSize = 1,
					})
					bg:SetBackdropColor(0, 0, 0, .6)
					bg:SetBackdropBorderColor(0, 0, 0)
					bg:SetWidth(t:GetWidth())
					bg:SetHeight(t:GetHeight())
					bg:SetPoint("TOPLEFT")
					bg:SetPoint("BOTTOMRIGHT")
					bg:SetFrameStrata("DIALOG")
				end
			end

			local sb = _G["GameTooltipStatusBar"]
			sb:SetHeight(3)
			sb:ClearAllPoints()
			sb:SetPoint("BOTTOMLEFT", GameTooltip, "BOTTOMLEFT", 1, 1)
			sb:SetPoint("BOTTOMRIGHT", GameTooltip, "BOTTOMRIGHT", -1, 1)

			local sep = GameTooltipStatusBar:CreateTexture(nil, "ARTWORK")
			sep:SetHeight(1)
			sep:SetPoint("BOTTOMLEFT", 0, 3)
			sep:SetPoint("BOTTOMRIGHT", 0, 3)
			sep:SetTexture(Aurora.backdrop)
			sep:SetVertexColor(0, 0, 0)
		end

		-- [[ Map ]]

		if map == true and not IsAddOnLoaded("MetaMap") and not IsAddOnLoaded("m_Map") and not IsAddOnLoaded("Mapster") then
			WorldMapFrameMiniBorderLeft:SetAlpha(0)
			WorldMapFrameMiniBorderRight:SetAlpha(0)

			local scale = WORLDMAP_WINDOWED_SIZE
			local mapbg = CreateFrame("Frame", nil, WorldMapDetailFrame)
			mapbg:SetPoint("TOPLEFT", -1 / scale, 1 / scale)
			mapbg:SetPoint("BOTTOMRIGHT", 1 / scale, -1 / scale)
			mapbg:SetFrameLevel(0)
			mapbg:SetBackdrop({ 
				bgFile = Aurora.backdrop, 
			})
			mapbg:SetBackdropColor(0, 0, 0)

			local frame = CreateFrame("Frame",nil,WorldMapButton)
			frame:SetFrameStrata("HIGH")

			hooksecurefunc("WorldMap_ToggleSizeDown", function()
				WorldMapFrameMiniBorderLeft:SetAlpha(0)
				WorldMapFrameMiniBorderRight:SetAlpha(0)
				WorldMapFrameCloseButton:ClearAllPoints()
				WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapButton, "TOPRIGHT", 3, 3)
				WorldMapFrameCloseButton:SetFrameStrata("HIGH")
				WorldMapFrameSizeUpButton:ClearAllPoints()
				WorldMapFrameSizeUpButton:SetPoint("TOPRIGHT", WorldMapButton, "TOPRIGHT", 3, -18)
				WorldMapFrameSizeUpButton:SetFrameStrata("HIGH")
				WorldMapFrameTitle:ClearAllPoints()
				WorldMapFrameTitle:SetPoint("BOTTOMLEFT", WorldMapDetailFrame, 9, 5)
				WorldMapFrameTitle:SetParent(frame)
				WorldMapFrameTitle:SetFont("fonts\\FRIZQT__.TTF", 18)
				WorldMapFrameTitle:SetTextColor(1, 1, 1)
				WorldMapQuestShowObjectives:SetParent(frame)
				WorldMapQuestShowObjectives:ClearAllPoints()
				WorldMapQuestShowObjectives:SetPoint("BOTTOMRIGHT", WorldMapButton, "BOTTOMRIGHT")
				WorldMapQuestShowObjectivesText:ClearAllPoints()
				WorldMapQuestShowObjectivesText:SetPoint("RIGHT", WorldMapQuestShowObjectives, "LEFT", -4, 1)
				WorldMapQuestShowObjectivesText:SetFont("fonts\\FRIZQT__.TTF", 18)
				WorldMapQuestShowObjectivesText:SetTextColor(1, 1, 1)
				WorldMapTrackQuest:SetParent(frame)
				WorldMapTrackQuest:ClearAllPoints()
				WorldMapTrackQuest:SetPoint("TOPLEFT", WorldMapDetailFrame, 9, -5)
				WorldMapTrackQuestText:SetFont("fonts\\FRIZQT__.TTF", 18)
				WorldMapTrackQuestText:SetTextColor(1, 1, 1)
				WorldMapShowDigSites:SetParent(frame)
				WorldMapShowDigSites:ClearAllPoints()
				WorldMapShowDigSites:SetPoint("BOTTOMRIGHT", WorldMapButton, "BOTTOMRIGHT", 0, 19)
				WorldMapShowDigSitesText:SetFont("fonts\\FRIZQT__.TTF", 18)
				WorldMapShowDigSitesText:ClearAllPoints()
				WorldMapShowDigSitesText:SetPoint("RIGHT",WorldMapShowDigSites,"LEFT",-4,1)
				WorldMapShowDigSitesText:SetTextColor(1, 1, 1)
			end)
		end

		-- [[ Text colour functions ]]

		NORMAL_QUEST_DISPLAY = "|cffffffff%s|r"
		TRIVIAL_QUEST_DISPLAY = "|cffffffff%s (low level)|r"

		GameFontBlackMedium:SetTextColor(1, 1, 1)
		QuestFont:SetTextColor(1, 1, 1)
		MailTextFontNormal:SetTextColor(1, 1, 1)
		InvoiceTextFontNormal:SetTextColor(1, 1, 1)
		InvoiceTextFontSmall:SetTextColor(1, 1, 1)
		SpellBookPageText:SetTextColor(.8, .8, .8)
		QuestProgressRequiredItemsText:SetTextColor(1, 1, 1)
		QuestProgressRequiredItemsText:SetShadowColor(0, 0, 0)
		QuestInfoRewardsHeader:SetShadowColor(0, 0, 0)
		QuestProgressTitleText:SetShadowColor(0, 0, 0)
		QuestInfoTitleHeader:SetShadowColor(0, 0, 0)
		AvailableServicesText:SetTextColor(1, 1, 1)
		AvailableServicesText:SetShadowColor(0, 0, 0)
		PetitionFrameCharterTitle:SetTextColor(1, 1, 1)
		PetitionFrameCharterTitle:SetShadowColor(0, 0, 0)
		PetitionFrameMasterTitle:SetTextColor(1, 1, 1)
		PetitionFrameMasterTitle:SetShadowColor(0, 0, 0)
		PetitionFrameMemberTitle:SetTextColor(1, 1, 1)
		PetitionFrameMemberTitle:SetShadowColor(0, 0, 0)
		QuestInfoTitleHeader:SetTextColor(1, 1, 1)
		QuestInfoTitleHeader.SetTextColor = Aurora.dummy
		QuestInfoDescriptionHeader:SetTextColor(1, 1, 1)
		QuestInfoDescriptionHeader.SetTextColor = Aurora.dummy
		QuestInfoDescriptionHeader:SetShadowColor(0, 0, 0)
		QuestInfoObjectivesHeader:SetTextColor(1, 1, 1)
		QuestInfoObjectivesHeader.SetTextColor = Aurora.dummy
		QuestInfoObjectivesHeader:SetShadowColor(0, 0, 0)
		QuestInfoRewardsHeader:SetTextColor(1, 1, 1)
		QuestInfoRewardsHeader.SetTextColor = Aurora.dummy
		QuestInfoDescriptionText:SetTextColor(1, 1, 1)
		QuestInfoDescriptionText.SetTextColor = Aurora.dummy
		QuestInfoObjectivesText:SetTextColor(1, 1, 1)
		QuestInfoObjectivesText.SetTextColor = Aurora.dummy
		QuestInfoGroupSize:SetTextColor(1, 1, 1)
		QuestInfoGroupSize.SetTextColor = Aurora.dummy
		QuestInfoRewardText:SetTextColor(1, 1, 1)
		QuestInfoRewardText.SetTextColor = Aurora.dummy
		QuestInfoItemChooseText:SetTextColor(1, 1, 1)
		QuestInfoItemChooseText.SetTextColor = Aurora.dummy
		QuestInfoItemReceiveText:SetTextColor(1, 1, 1)
		QuestInfoItemReceiveText.SetTextColor = Aurora.dummy
		QuestInfoSpellLearnText:SetTextColor(1, 1, 1)
		QuestInfoSpellLearnText.SetTextColor = Aurora.dummy
		QuestInfoXPFrameReceiveText:SetTextColor(1, 1, 1)
		QuestInfoXPFrameReceiveText.SetTextColor = Aurora.dummy
		GossipGreetingText:SetTextColor(1, 1, 1)
		QuestProgressTitleText:SetTextColor(1, 1, 1)
		QuestProgressTitleText.SetTextColor = Aurora.dummy
		QuestProgressText:SetTextColor(1, 1, 1)
		QuestProgressText.SetTextColor = Aurora.dummy
		ItemTextPageText:SetTextColor(1, 1, 1)
		ItemTextPageText.SetTextColor = Aurora.dummy
		GreetingText:SetTextColor(1, 1, 1)
		GreetingText.SetTextColor = Aurora.dummy
		AvailableQuestsText:SetTextColor(1, 1, 1)
		AvailableQuestsText.SetTextColor = Aurora.dummy
		AvailableQuestsText:SetShadowColor(0, 0, 0)
		QuestInfoSpellObjectiveLearnLabel:SetTextColor(1, 1, 1)
		QuestInfoSpellObjectiveLearnLabel.SetTextColor = Aurora.dummy
		CurrentQuestsText:SetTextColor(1, 1, 1)
		CurrentQuestsText.SetTextColor = Aurora.dummy
		CurrentQuestsText:SetShadowColor(0, 0, 0)

		for i = 1, MAX_OBJECTIVES do
			local objective = _G["QuestInfoObjective"..i]
			objective:SetTextColor(1, 1, 1)
			objective.SetTextColor = Aurora.dummy
		end

		hooksecurefunc("UpdateProfessionButton", function(self)
			self.spellString:SetTextColor(1, 1, 1);	
			self.subSpellString:SetTextColor(1, 1, 1)
		end)

		function PaperDollFrame_SetLevel()
			local primaryTalentTree = GetPrimaryTalentTree()
			local classDisplayName, class = UnitClass("player")
			local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or classcolours[class]
			local classColorString = format("ff%.2x%.2x%.2x", classColor.r * 255, classColor.g * 255, classColor.b * 255)
			local specName

			if (primaryTalentTree) then
				_, specName = GetTalentTabInfo(primaryTalentTree);
			end

			if (specName and specName ~= "") then
				CharacterLevelText:SetFormattedText(PLAYER_LEVEL, UnitLevel("player"), classColorString, specName, classDisplayName);
			else
				CharacterLevelText:SetFormattedText(PLAYER_LEVEL_NO_SPEC, UnitLevel("player"), classColorString, classDisplayName);
			end
		end

		-- [[ Change positions ]]

		ChatConfigFrameDefaultButton:SetWidth(125)
		ChatConfigFrameDefaultButton:SetPoint("TOPLEFT", ChatConfigCategoryFrame, "BOTTOMLEFT", 0, -4)
		ChatConfigFrameOkayButton:SetPoint("TOPRIGHT", ChatConfigBackgroundFrame, "BOTTOMRIGHT", 0, -4)
		QuestLogFramePushQuestButton:ClearAllPoints()
		QuestLogFramePushQuestButton:SetPoint("LEFT", QuestLogFrameAbandonButton, "RIGHT", 1, 0)
		QuestLogFramePushQuestButton:SetWidth(100)
		QuestLogFrameTrackButton:ClearAllPoints()
		QuestLogFrameTrackButton:SetPoint("LEFT", QuestLogFramePushQuestButton, "RIGHT", 1, 0)
		FriendsFrameStatusDropDown:ClearAllPoints()
		FriendsFrameStatusDropDown:SetPoint("TOPLEFT", FriendsFrame, "TOPLEFT", 10, -40)
		RaidFrameConvertToRaidButton:ClearAllPoints()
		RaidFrameConvertToRaidButton:SetPoint("TOPLEFT", FriendsFrame, "TOPLEFT", 30, -44)
		ReputationDetailFrame:SetPoint("TOPLEFT", ReputationFrame, "TOPRIGHT", 1, -28)
		PaperDollEquipmentManagerPaneEquipSet:SetWidth(PaperDollEquipmentManagerPaneEquipSet:GetWidth()-1)
		PaperDollEquipmentManagerPaneSaveSet:SetPoint("LEFT", PaperDollEquipmentManagerPaneEquipSet, "RIGHT", 1, 0)
		GearManagerDialogPopup:SetPoint("LEFT", PaperDollFrame, "RIGHT", 1, 0)
		DressUpFrameResetButton:SetPoint("RIGHT", DressUpFrameCancelButton, "LEFT", -1, 0)
		SendMailMailButton:SetPoint("RIGHT", SendMailCancelButton, "LEFT", -1, 0)
		OpenMailDeleteButton:SetPoint("RIGHT", OpenMailCancelButton, "LEFT", -1, 0)
		OpenMailReplyButton:SetPoint("RIGHT", OpenMailDeleteButton, "LEFT", -1, 0)
		HelpFrameTicketScrollFrameScrollBar:SetPoint("TOPLEFT", HelpFrameTicketScrollFrame, "TOPRIGHT", 1, -16)
		HelpFrameGM_ResponseScrollFrame1ScrollBar:SetPoint("TOPLEFT", HelpFrameGM_ResponseScrollFrame1, "TOPRIGHT", 1, -16)
		HelpFrameGM_ResponseScrollFrame2ScrollBar:SetPoint("TOPLEFT", HelpFrameGM_ResponseScrollFrame2, "TOPRIGHT", 1, -16)
		RaidInfoFrame:SetPoint("TOPLEFT", FriendsFrame, "TOPRIGHT", -33, -60)
		RaidInfoFrame.SetPoint = Aurora.dummy
		TokenFramePopup:SetPoint("TOPLEFT", TokenFrame, "TOPRIGHT", 1, -28)
		CharacterFrameExpandButton:SetPoint("BOTTOMRIGHT", CharacterFrameInset, "BOTTOMRIGHT", -14, 6)
		PVPTeamManagementFrameWeeklyDisplay:SetPoint("RIGHT", PVPTeamManagementFrameWeeklyToggleRight, "LEFT", -2, 0)
		TabardCharacterModelRotateRightButton:SetPoint("TOPLEFT", TabardCharacterModelRotateLeftButton, "TOPRIGHT", 1, 0)
		LFDQueueFrameSpecificListScrollFrameScrollBarScrollDownButton:SetPoint("TOP", LFDQueueFrameSpecificListScrollFrameScrollBar, "BOTTOM", 0, 2)
		LFDQueueFrameRandomScrollFrameScrollBarScrollDownButton:SetPoint("TOP", LFDQueueFrameRandomScrollFrameScrollBar, "BOTTOM", 0, 2)
		MerchantFrameTab2:SetPoint("LEFT", MerchantFrameTab1, "RIGHT", -15, 0)
		GuildRegistrarFrameEditBox:SetHeight(20)
		SendMailMoneySilver:SetPoint("LEFT", SendMailMoneyGold, "RIGHT", 1, 0)
		SendMailMoneyCopper:SetPoint("LEFT", SendMailMoneySilver, "RIGHT", 1, 0)
		StaticPopup1MoneyInputFrameSilver:SetPoint("LEFT", StaticPopup1MoneyInputFrameGold, "RIGHT", 1, 0)
		StaticPopup1MoneyInputFrameCopper:SetPoint("LEFT", StaticPopup1MoneyInputFrameSilver, "RIGHT", 1, 0)
		StaticPopup2MoneyInputFrameSilver:SetPoint("LEFT", StaticPopup2MoneyInputFrameGold, "RIGHT", 1, 0)
		StaticPopup2MoneyInputFrameCopper:SetPoint("LEFT", StaticPopup2MoneyInputFrameSilver, "RIGHT", 1, 0)
		WorldStateScoreFrameTab2:SetPoint("LEFT", WorldStateScoreFrameTab1, "RIGHT", -15, 0)
		WorldStateScoreFrameTab3:SetPoint("LEFT", WorldStateScoreFrameTab2, "RIGHT", -15, 0)
		WhoFrameWhoButton:SetPoint("RIGHT", WhoFrameAddFriendButton, "LEFT", -1, 0)
		WhoFrameAddFriendButton:SetPoint("RIGHT", WhoFrameGroupInviteButton, "LEFT", -1, 0)

		hooksecurefunc("QuestFrame_ShowQuestPortrait", function(parentFrame, portrait, text, name, x, y)
			local parent = parentFrame:GetName()
			if parent == "QuestLogFrame" or parent == "QuestLogDetailFrame" then
				QuestNPCModel:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", x+4, y)
			else
				QuestNPCModel:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", x+8, y)
			end
		end)

		local questlogcontrolpanel = function()
			local parent
			if QuestLogFrame:IsShown() then
				parent = QuestLogFrame
				QuestLogControlPanel:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 9, 6)
			elseif QuestLogDetailFrame:IsShown() then
				parent = QuestLogDetailFrame
				QuestLogControlPanel:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 9, 0)
			end
		end
		hooksecurefunc("QuestLogControlPanel_UpdatePosition", questlogcontrolpanel)

		-- [[ Tabs ]]

		for i = 1, 5 do
			Aurora.CreateTab(_G["SpellBookFrameTabButton"..i])
		end

		for i = 1, 4 do
			Aurora.CreateTab(_G["FriendsFrameTab"..i])
			Aurora.CreateTab(_G["PVPFrameTab"..i])
			if _G["CharacterFrameTab"..i] then
				Aurora.CreateTab(_G["CharacterFrameTab"..i])
			end
		end

		for i = 1, 3 do
			Aurora.CreateTab(_G["WorldStateScoreFrameTab"..i])
		end

		for i = 1, 2 do
			Aurora.CreateTab(_G["LFRParentFrameTab"..i])
			Aurora.CreateTab(_G["MerchantFrameTab"..i])
			Aurora.CreateTab(_G["MailFrameTab"..i])
		end

		-- [[ Buttons ]]

		for i = 1, 2 do
			for j = 1, 3 do
				Aurora.Reskin(_G["StaticPopup"..i.."Button"..j])
			end
		end

		local buttons = {"VideoOptionsFrameOkay", "VideoOptionsFrameCancel", "VideoOptionsFrameDefaults", "VideoOptionsFrameApply", "AudioOptionsFrameOkay", "AudioOptionsFrameCancel", "AudioOptionsFrameDefaults", "InterfaceOptionsFrameDefaults", "InterfaceOptionsFrameOkay", "InterfaceOptionsFrameCancel", "ChatConfigFrameOkayButton", "ChatConfigFrameDefaultButton", "DressUpFrameCancelButton", "DressUpFrameResetButton", "WhoFrameWhoButton", "WhoFrameAddFriendButton", "WhoFrameGroupInviteButton", "SendMailMailButton", "SendMailCancelButton", "OpenMailReplyButton", "OpenMailDeleteButton", "OpenMailCancelButton", "OpenMailReportSpamButton", "QuestLogFrameAbandonButton", "QuestLogFramePushQuestButton", "QuestLogFrameTrackButton", "QuestLogFrameCancelButton", "QuestFrameAcceptButton", "QuestFrameDeclineButton", "QuestFrameCompleteQuestButton", "QuestFrameCompleteButton", "QuestFrameGoodbyeButton", "GossipFrameGreetingGoodbyeButton", "QuestFrameGreetingGoodbyeButton", "ChannelFrameNewButton", "RaidFrameRaidInfoButton", "RaidFrameConvertToRaidButton", "TradeFrameTradeButton", "TradeFrameCancelButton", "GearManagerDialogPopupOkay", "GearManagerDialogPopupCancel", "StackSplitOkayButton", "StackSplitCancelButton", "TabardFrameAcceptButton", "TabardFrameCancelButton", "GameMenuButtonHelp", "GameMenuButtonOptions", "GameMenuButtonUIOptions", "GameMenuButtonKeybindings", "GameMenuButtonMacros", "GameMenuButtonLogout", "GameMenuButtonQuit", "GameMenuButtonContinue", "GameMenuButtonMacOptions", "FriendsFrameAddFriendButton", "FriendsFrameSendMessageButton", "LFDQueueFrameFindGroupButton", "LFDQueueFrameCancelButton", "LFRQueueFrameFindGroupButton", "LFRQueueFrameAcceptCommentButton", "PVPFrameLeftButton", "PVPFrameRightButton", "RaidFrameNotInRaidRaidBrowserButton", "WorldStateScoreFrameLeaveButton", "SpellBookCompanionSummonButton", "AddFriendEntryFrameAcceptButton", "AddFriendEntryFrameCancelButton", "FriendsFriendsSendRequestButton", "FriendsFriendsCloseButton", "ColorPickerOkayButton", "ColorPickerCancelButton", "FriendsFrameIgnorePlayerButton", "FriendsFrameUnsquelchButton", "LFDDungeonReadyDialogEnterDungeonButton", "LFDDungeonReadyDialogLeaveQueueButton", "LFRBrowseFrameSendMessageButton", "LFRBrowseFrameInviteButton", "LFRBrowseFrameRefreshButton", "LFDRoleCheckPopupAcceptButton", "LFDRoleCheckPopupDeclineButton", "GuildInviteFrameJoinButton", "GuildInviteFrameDeclineButton", "FriendsFramePendingButton1AcceptButton", "FriendsFramePendingButton1DeclineButton", "RaidInfoExtendButton", "RaidInfoCancelButton", "PaperDollEquipmentManagerPaneEquipSet", "PaperDollEquipmentManagerPaneSaveSet", "PVPBannerFrameAcceptButton", "PVPColorPickerButton1", "PVPColorPickerButton2", "PVPColorPickerButton3", "HelpFrameButton1", "HelpFrameButton2", "HelpFrameButton3", "HelpFrameButton4", "HelpFrameButton5", "HelpFrameButton6", "HelpFrameAccountSecurityOpenTicket", "HelpFrameCharacterStuckStuck", "HelpFrameReportLagLoot", "HelpFrameReportLagAuctionHouse", "HelpFrameReportLagMail", "HelpFrameReportLagChat", "HelpFrameReportLagMovement", "HelpFrameReportLagSpell", "HelpFrameReportAbuseOpenTicket", "HelpFrameOpenTicketHelpTopIssues", "HelpFrameOpenTicketHelpOpenTicket", "ReadyCheckFrameYesButton", "ReadyCheckFrameNoButton", "RolePollPopupAcceptButton", "HelpFrameTicketSubmit", "HelpFrameTicketCancel", "HelpFrameKnowledgebaseSearchButton", "GhostFrame", "HelpFrameGM_ResponseNeedMoreHelp", "HelpFrameGM_ResponseCancel", "GMChatOpenLog", "HelpFrameKnowledgebaseNavBarHomeButton", "AddFriendInfoFrameContinueButton", "GuildRegistrarFrameGoodbyeButton", "GuildRegistrarFramePurchaseButton", "GuildRegistrarFrameCancelButton", "LFDQueueFramePartyBackfillBackfillButton", "LFDQueueFramePartyBackfillNoBackfillButton", "ChannelFrameDaughterFrameOkayButton", "ChannelFrameDaughterFrameCancelButton", "PetitionFrameSignButton", "PetitionFrameRequestButton", "PetitionFrameRenameButton", "PetitionFrameCancelButton", "QuestLogFrameCompleteButton", "WarGameStartButton", "EncounterJournalNavBarHomeButton", "EncounterJournalInstanceSelectDungeonTab", "EncounterJournalInstanceSelectRaidTab"}
		for i = 1, #buttons do
		local reskinbutton = _G[buttons[i]]
			if reskinbutton then
				Aurora.Reskin(reskinbutton)
			else
				print("Button "..i.." was not found.")
			end
		end

		Aurora.Reskin(select(6, PVPBannerFrame:GetChildren()))

		if IsAddOnLoaded("ACP") then Aurora.Reskin(GameMenuButtonAddOns) end

		local closebuttons = {"LFDParentFrameCloseButton", "CharacterFrameCloseButton", "PVPFrameCloseButton", "SpellBookFrameCloseButton", "HelpFrameCloseButton", "PVPBannerFrameCloseButton", "RaidInfoCloseButton", "ContainerFrame1CloseButton", "ContainerFrame2CloseButton", "ContainerFrame3CloseButton", "ContainerFrame4CloseButton", "ContainerFrame5CloseButton", "RolePollPopupCloseButton", "ItemRefCloseButton", "TokenFramePopupCloseButton", "ReputationDetailCloseButton", "ChannelFrameDaughterFrameDetailCloseButton", "EncounterJournalCloseButton", "WorldStateScoreFrameCloseButton", "LFDDungeonReadyStatusCloseButton"}
		for i = 1, #closebuttons do
			local closebutton = _G[closebuttons[i]]
			Aurora.ReskinClose(closebutton)
		end

		Aurora.ReskinClose(FriendsFrameCloseButton, "LEFT", FriendsFrameBroadcastInput, "RIGHT", 20, 0)
		Aurora.ReskinClose(QuestLogFrameCloseButton, "TOPRIGHT", QuestLogFrame, "TOPRIGHT", -5, -12)
		Aurora.ReskinClose(QuestLogDetailFrameCloseButton, "TOPRIGHT", QuestLogDetailFrame, "TOPRIGHT", -5, -11)
		Aurora.ReskinClose(TaxiFrameCloseButton, "TOPRIGHT", TaxiRouteMap, "TOPRIGHT", -1, -1)
		Aurora.ReskinClose(InboxCloseButton, "TOPRIGHT", MailFrame, "TOPRIGHT", -38, -16)
		Aurora.ReskinClose(OpenMailCloseButton, "TOPRIGHT", OpenMailFrame, "TOPRIGHT", -38, -16)
		Aurora.ReskinClose(GossipFrameCloseButton, "TOPRIGHT", GossipFrame, "TOPRIGHT", -30, -20)
		Aurora.ReskinClose(MerchantFrameCloseButton, "TOPRIGHT", MerchantFrame, "TOPRIGHT", -38, -14)
		Aurora.ReskinClose(QuestFrameCloseButton, "TOPRIGHT", QuestFrame, "TOPRIGHT", -30, -20)
		Aurora.ReskinClose(DressUpFrameCloseButton, "TOPRIGHT", DressUpFrame, "TOPRIGHT", -38, -16)
		Aurora.ReskinClose(ItemTextCloseButton, "TOPRIGHT", ItemTextFrame, "TOPRIGHT", -32, -12)
		Aurora.ReskinClose(GuildRegistrarFrameCloseButton, "TOPRIGHT", GuildRegistrarFrame, "TOPRIGHT", -30, -20)
		Aurora.ReskinClose(TabardFrameCloseButton, "TOPRIGHT", TabardFrame, "TOPRIGHT", -38, -16)
		Aurora.ReskinClose(PetitionFrameCloseButton, "TOPRIGHT", PetitionFrame, "TOPRIGHT", -30, -20)
		Aurora.ReskinClose(TradeFrameCloseButton, "TOPRIGHT", TradeFrame, "TOPRIGHT", -34, -16)

		local LFRClose = LFRParentFrame:GetChildren()
		Aurora.ReskinClose(LFRClose, "TOPRIGHT", LFRParentFrame, "TOPRIGHT", -4, -14)

	-- [[ Load on Demand Addons ]]

	elseif addon == "Blizzard_ArchaeologyUI" then
		Aurora.SetBD(ArchaeologyFrame)
		Aurora.Reskin(ArchaeologyFrameArtifactPageSolveFrameSolveButton)
		Aurora.Reskin(ArchaeologyFrameArtifactPageBackButton)
		ArchaeologyFramePortrait:Hide()
		ArchaeologyFrame:DisableDrawLayer("BACKGROUND")
		ArchaeologyFrame:DisableDrawLayer("BORDER")
		ArchaeologyFrame:DisableDrawLayer("OVERLAY")
		ArchaeologyFrameInset:DisableDrawLayer("BACKGROUND")
		ArchaeologyFrameInset:DisableDrawLayer("BORDER")
		ArchaeologyFrameSummaryPageTitle:SetTextColor(1, 1, 1)
		ArchaeologyFrameArtifactPageHistoryTitle:SetTextColor(1, 1, 1)
		ArchaeologyFrameArtifactPageHistoryScrollChildText:SetTextColor(1, 1, 1)
		ArchaeologyFrameHelpPageTitle:SetTextColor(1, 1, 1)
		ArchaeologyFrameHelpPageDigTitle:SetTextColor(1, 1, 1)
		ArchaeologyFrameHelpPageHelpScrollHelpText:SetTextColor(1, 1, 1)
		ArchaeologyFrameCompletedPage:GetRegions():SetTextColor(1, 1, 1)
		ArchaeologyFrameCompletedPageTitle:SetTextColor(1, 1, 1)
		ArchaeologyFrameCompletedPageTitleTop:SetTextColor(1, 1, 1)
		ArchaeologyFrameCompletedPageTitleMid:SetTextColor(1, 1, 1)
		ArchaeologyFrameCompletedPagePageText:SetTextColor(1, 1, 1)

		for i = 1, 10 do
			_G["ArchaeologyFrameSummaryPageRace"..i]:GetRegions():SetTextColor(1, 1, 1)
		end
		for i = 1, ARCHAEOLOGY_MAX_COMPLETED_SHOWN do
			local bu = _G["ArchaeologyFrameCompletedPageArtifact"..i]
			bu:GetRegions():Hide()
			select(2, bu:GetRegions()):Hide()
			select(3, bu:GetRegions()):SetTexCoord(.08, .92, .08, .92)
			select(4, bu:GetRegions()):SetTextColor(1, 1, 1)
			select(5, bu:GetRegions()):SetTextColor(1, 1, 1)
			local bg = CreateFrame("Frame", nil, bu)
			bg:SetPoint("TOPLEFT", -1, 1)
			bg:SetPoint("BOTTOMRIGHT", 1, -1)
			bg:SetFrameLevel(bu:GetFrameLevel()-1)
			Aurora.CreateBD(bg, .25)
			local vline = CreateFrame("Frame", nil, bu)
			vline:SetPoint("LEFT", 44, 0)
			vline:SetSize(1, 44)
			Aurora.CreateBD(vline)
		end

		ArchaeologyFrameInfoButton:SetPoint("TOPLEFT", 3, -3)

		Aurora.ReskinDropDown(ArchaeologyFrameRaceFilter)
		Aurora.ReskinClose(ArchaeologyFrameCloseButton)
		Aurora.ReskinArrow(ArchaeologyFrameCompletedPagePrevPageButton, 1)
		Aurora.ReskinArrow(ArchaeologyFrameCompletedPageNextPageButton, 2)
		ArchaeologyFrameCompletedPagePrevPageButtonIcon:Hide()
		ArchaeologyFrameCompletedPageNextPageButtonIcon:Hide()

		ArchaeologyFrameRankBarBorder:Hide()
		ArchaeologyFrameRankBarBackground:Hide()
		ArchaeologyFrameRankBarBar:SetTexture(Aurora.backdrop)
		ArchaeologyFrameRankBarBar:SetGradient("VERTICAL", 0, .65, 0, 0, .75, 0)
		ArchaeologyFrameRankBar:SetHeight(14)
		Aurora.CreateBD(ArchaeologyFrameRankBar, .25)

		ArchaeologyFrameArtifactPageSolveFrameStatusBarBarBG:Hide()
		local bar = select(3, ArchaeologyFrameArtifactPageSolveFrameStatusBar:GetRegions())
		bar:SetTexture(Aurora.backdrop)
		bar:SetGradient("VERTICAL", .65, .25, 0, .75, .35, .1)

		local bg = CreateFrame("Frame", nil, ArchaeologyFrameArtifactPageSolveFrameStatusBar)
		bg:SetPoint("TOPLEFT", -1, 1)
		bg:SetPoint("BOTTOMRIGHT", 1, -1)
		bg:SetFrameLevel(0)
		Aurora.CreateBD(bg, .25)
	elseif addon == "Blizzard_AuctionUI" then
		Aurora.SetBD(AuctionFrame, 2, -10, 0, 10)
		Aurora.CreateBD(AuctionProgressFrame)
		AuctionDressUpFrame:ClearAllPoints()
		AuctionDressUpFrame:SetPoint("LEFT", AuctionFrame, "RIGHT", -3, 0)
		Aurora.CreateBD(AuctionDressUpModel)

		AuctionProgressBar:SetStatusBarTexture(Aurora.backdrop)
		local ABBD = CreateFrame("Frame", nil, AuctionProgressBar)
		ABBD:SetPoint("TOPLEFT", -1, 1)
		ABBD:SetPoint("BOTTOMRIGHT", 1, -1)
		ABBD:SetFrameLevel(AuctionProgressBar:GetFrameLevel()-1)
		Aurora.CreateBD(ABBD, .25)

		AuctionProgressBarIcon:SetTexCoord(.08, .92, .08, .92)
		local bg = CreateFrame("Frame", nil, AuctionProgressBar)
		bg:SetPoint("TOPLEFT", AuctionProgressBarIcon, -1, 1)
		bg:SetPoint("BOTTOMRIGHT", AuctionProgressBarIcon, 1, -1)
		Aurora.CreateBD(bg, 0)

		AuctionProgressBarText:SetPoint("CENTER")

		Aurora.ReskinClose(AuctionProgressFrameCancelButton, "LEFT", AuctionProgressBar, "RIGHT", 4, 0)
		select(15, AuctionProgressFrameCancelButton:GetRegions()):SetPoint("CENTER", 0, 2)

		AuctionFrame:DisableDrawLayer("ARTWORK")
		AuctionPortraitTexture:Hide()
		for i = 1, 4 do
			select(i, AuctionProgressFrame:GetRegions()):Hide()
		end
		AuctionProgressBarBorder:Hide()
		for i = 1, 4 do
			select(i, AuctionDressUpFrame:GetRegions()):Hide()
		end
		BrowseFilterScrollFrame:GetRegions():Hide()
		select(2, BrowseFilterScrollFrame:GetRegions()):Hide()
		BrowseScrollFrame:GetRegions():Hide()
		select(2, BrowseScrollFrame:GetRegions()):Hide()
		BidScrollFrame:GetRegions():Hide()
		select(2, BidScrollFrame:GetRegions()):Hide()
		AuctionsScrollFrame:GetRegions():Hide()
		select(2, AuctionsScrollFrame:GetRegions()):Hide()
		select(5, AuctionDressUpFrameCloseButton:GetRegions()):Hide()
		AuctionDressUpModelRotateLeftButton:Hide()
		AuctionDressUpModelRotateRightButton:Hide()
		BrowseQualitySort:DisableDrawLayer("BACKGROUND")
		BrowseLevelSort:DisableDrawLayer("BACKGROUND")
		BrowseDurationSort:DisableDrawLayer("BACKGROUND")
		BrowseHighBidderSort:DisableDrawLayer("BACKGROUND")
		BrowseCurrentBidSort:DisableDrawLayer("BACKGROUND")
		BidQualitySort:DisableDrawLayer("BACKGROUND")
		BidLevelSort:DisableDrawLayer("BACKGROUND")
		BidDurationSort:DisableDrawLayer("BACKGROUND")
		BidBuyoutSort:DisableDrawLayer("BACKGROUND")
		BidStatusSort:DisableDrawLayer("BACKGROUND")
		BidBidSort:DisableDrawLayer("BACKGROUND")
		AuctionsQualitySort:DisableDrawLayer("BACKGROUND")
		AuctionsDurationSort:DisableDrawLayer("BACKGROUND")
		AuctionsHighBidderSort:DisableDrawLayer("BACKGROUND")
		AuctionsBidSort:DisableDrawLayer("BACKGROUND")

		for i = 1, NUM_FILTERS_TO_DISPLAY do
			_G["AuctionFilterButton"..i]:SetNormalTexture("")
		end

		for i = 1, 3 do
			Aurora.CreateTab(_G["AuctionFrameTab"..i])
		end

		local abuttons = {"BrowseBidButton", "BrowseBuyoutButton", "BrowseCloseButton", "BrowseSearchButton", "BrowseResetButton", "BidBidButton", "BidBuyoutButton", "BidCloseButton", "AuctionsCloseButton", "AuctionDressUpFrameResetButton", "AuctionsCancelAuctionButton", "AuctionsCreateAuctionButton", "AuctionsNumStacksMaxButton", "AuctionsStackSizeMaxButton"}
		for i = 1, #abuttons do
			local reskinbutton = _G[abuttons[i]]
			if reskinbutton then
				Aurora.Reskin(reskinbutton)
			end
		end

		BrowseCloseButton:ClearAllPoints()
		BrowseCloseButton:SetPoint("BOTTOMRIGHT", AuctionFrameBrowse, "BOTTOMRIGHT", 66, 13)
		BrowseBuyoutButton:ClearAllPoints()
		BrowseBuyoutButton:SetPoint("RIGHT", BrowseCloseButton, "LEFT", -1, 0)
		BrowseBidButton:ClearAllPoints()
		BrowseBidButton:SetPoint("RIGHT", BrowseBuyoutButton, "LEFT", -1, 0)
		BidBuyoutButton:ClearAllPoints()
		BidBuyoutButton:SetPoint("RIGHT", BidCloseButton, "LEFT", -1, 0)
		BidBidButton:ClearAllPoints()
		BidBidButton:SetPoint("RIGHT", BidBuyoutButton, "LEFT", -1, 0)
		AuctionsCancelAuctionButton:ClearAllPoints()
		AuctionsCancelAuctionButton:SetPoint("RIGHT", AuctionsCloseButton, "LEFT", -1, 0)

		-- Blizz needs to be more consistent

		BrowseBidPriceSilver:SetPoint("LEFT", BrowseBidPriceGold, "RIGHT", 1, 0)
		BrowseBidPriceCopper:SetPoint("LEFT", BrowseBidPriceSilver, "RIGHT", 1, 0)
		BidBidPriceSilver:SetPoint("LEFT", BidBidPriceGold, "RIGHT", 1, 0)
		BidBidPriceCopper:SetPoint("LEFT", BidBidPriceSilver, "RIGHT", 1, 0)
		StartPriceSilver:SetPoint("LEFT", StartPriceGold, "RIGHT", 1, 0)
		StartPriceCopper:SetPoint("LEFT", StartPriceSilver, "RIGHT", 1, 0)
		BuyoutPriceSilver:SetPoint("LEFT", BuyoutPriceGold, "RIGHT", 1, 0)
		BuyoutPriceCopper:SetPoint("LEFT", BuyoutPriceSilver, "RIGHT", 1, 0)

		for i = 1, NUM_BROWSE_TO_DISPLAY do
			local bu = _G["BrowseButton"..i]
			local it = _G["BrowseButton"..i.."Item"]
			local ic = _G["BrowseButton"..i.."ItemIconTexture"]

			it:SetNormalTexture("")
			ic:SetTexCoord(.08, .92, .08, .92)

			local bg = CreateFrame("Frame", nil, it)
			bg:SetPoint("TOPLEFT", -1, 1)
			bg:SetPoint("BOTTOMRIGHT", 1, -1)
			bg:SetFrameLevel(it:GetFrameLevel()-1)
			Aurora.CreateBD(bg, 0)

			_G["BrowseButton"..i.."Left"]:Hide()
			select(6, _G["BrowseButton"..i]:GetRegions()):Hide()
			_G["BrowseButton"..i.."Right"]:Hide()

			local bd = CreateFrame("Frame", nil, bu)
			bd:SetPoint("TOPLEFT")
			bd:SetPoint("BOTTOMRIGHT", 0, 5)
			bd:SetFrameLevel(bu:GetFrameLevel()-1)
			Aurora.CreateBD(bd, .25)

			bu:SetHighlightTexture(Aurora.backdrop)
			local hl = bu:GetHighlightTexture()
			hl:SetVertexColor(r, g, b, .2)
			hl:ClearAllPoints()
			hl:SetPoint("TOPLEFT", 0, -1)
			hl:SetPoint("BOTTOMRIGHT", -1, 6)
		end

		for i = 1, NUM_BIDS_TO_DISPLAY do
			local bu = _G["BidButton"..i]
			local it = _G["BidButton"..i.."Item"]
			local ic = _G["BidButton"..i.."ItemIconTexture"]

			it:SetNormalTexture("")
			ic:SetTexCoord(.08, .92, .08, .92)

			local bg = CreateFrame("Frame", nil, it)
			bg:SetPoint("TOPLEFT", -1, 1)
			bg:SetPoint("BOTTOMRIGHT", 1, -1)
			bg:SetFrameLevel(it:GetFrameLevel()-1)
			Aurora.CreateBD(bg, 0)

			_G["BidButton"..i.."Left"]:Hide()
			select(6, _G["BidButton"..i]:GetRegions()):Hide()
			_G["BidButton"..i.."Right"]:Hide()

			local bd = CreateFrame("Frame", nil, bu)
			bd:SetPoint("TOPLEFT")
			bd:SetPoint("BOTTOMRIGHT", 0, 5)
			bd:SetFrameLevel(bu:GetFrameLevel()-1)
			Aurora.CreateBD(bd, .25)

			bu:SetHighlightTexture(Aurora.backdrop)
			local hl = bu:GetHighlightTexture()
			hl:SetVertexColor(r, g, b, .2)
			hl:ClearAllPoints()
			hl:SetPoint("TOPLEFT", 0, -1)
			hl:SetPoint("BOTTOMRIGHT", -1, 6)
		end

		for i = 1, NUM_AUCTIONS_TO_DISPLAY do
			local bu = _G["AuctionsButton"..i]
			local it = _G["AuctionsButton"..i.."Item"]
			local ic = _G["AuctionsButton"..i.."ItemIconTexture"]

			it:SetNormalTexture("")
			ic:SetTexCoord(.08, .92, .08, .92)

			local bg = CreateFrame("Frame", nil, it)
			bg:SetPoint("TOPLEFT", -1, 1)
			bg:SetPoint("BOTTOMRIGHT", 1, -1)
			bg:SetFrameLevel(it:GetFrameLevel()-1)
			Aurora.CreateBD(bg, 0)

			_G["AuctionsButton"..i.."Left"]:Hide()
			select(5, _G["AuctionsButton"..i]:GetRegions()):Hide()
			_G["AuctionsButton"..i.."Right"]:Hide()

			local bd = CreateFrame("Frame", nil, bu)
			bd:SetPoint("TOPLEFT")
			bd:SetPoint("BOTTOMRIGHT", 0, 5)
			bd:SetFrameLevel(bu:GetFrameLevel()-1)
			Aurora.CreateBD(bd, .25)

			bu:SetHighlightTexture(Aurora.backdrop)
			local hl = bu:GetHighlightTexture()
			hl:SetVertexColor(r, g, b, .2)
			hl:ClearAllPoints()
			hl:SetPoint("TOPLEFT", 0, -1)
			hl:SetPoint("BOTTOMRIGHT", -1, 6)
		end

		local auctionhandler = CreateFrame("Frame")
		auctionhandler:RegisterEvent("NEW_AUCTION_UPDATE")
		auctionhandler:SetScript("OnEvent", function()
			local _, _, _, _, _, _, _, _, _, _, _, _, _, AuctionsItemButtonIconTexture = AuctionsItemButton:GetRegions() -- blizzard, please name your textures
			if AuctionsItemButtonIconTexture then
				AuctionsItemButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
				AuctionsItemButtonIconTexture:SetPoint("TOPLEFT", 1, -1)
				AuctionsItemButtonIconTexture:SetPoint("BOTTOMRIGHT", -1, 1)
			end
		end)

		Aurora.CreateBD(AuctionsItemButton, .25)
		local _, AuctionsItemButtonNameFrame = AuctionsItemButton:GetRegions()
		AuctionsItemButtonNameFrame:Hide()

		Aurora.ReskinClose(AuctionFrameCloseButton, "TOPRIGHT", AuctionFrame, "TOPRIGHT", -4, -14)
		Aurora.ReskinClose(AuctionDressUpFrameCloseButton, "TOPRIGHT", AuctionDressUpModel, "TOPRIGHT", -4, -4)
		Aurora.ReskinScroll(BrowseScrollFrameScrollBar)
		Aurora.ReskinScroll(AuctionsScrollFrameScrollBar)
		Aurora.ReskinScroll(BrowseFilterScrollFrameScrollBar)
		Aurora.ReskinDropDown(PriceDropDown)
		Aurora.ReskinDropDown(DurationDropDown)
		Aurora.ReskinInput(BrowseName)
		Aurora.ReskinArrow(BrowsePrevPageButton, 1)
		Aurora.ReskinArrow(BrowseNextPageButton, 2)
		Aurora.ReskinCheck(IsUsableCheckButton)
		Aurora.ReskinCheck(ShowOnPlayerCheckButton)
		
		BrowsePrevPageButton:GetRegions():SetPoint("LEFT", BrowsePrevPageButton, "RIGHT", 2, 0)

		-- seriously, consistency
		BrowseDropDownLeft:SetAlpha(0)
		BrowseDropDownMiddle:SetAlpha(0)
		BrowseDropDownRight:SetAlpha(0)

		local a1, p, a2, x, y = BrowseDropDownButton:GetPoint()
		BrowseDropDownButton:SetPoint(a1, p, a2, x, y-4)
		BrowseDropDownButton:SetSize(16, 16)
		Aurora.Reskin(BrowseDropDownButton)

		local downtex = BrowseDropDownButton:CreateTexture(nil, "OVERLAY")
		downtex:SetTexture("Interface\\AddOns\\FreeUI\\media\\arrow-down-active")
		downtex:SetSize(8, 8)
		downtex:SetPoint("CENTER")
		downtex:SetVertexColor(1, 1, 1)

		local bg = CreateFrame("Frame", nil, BrowseDropDown)
		bg:SetPoint("TOPLEFT", 16, -5)
		bg:SetPoint("BOTTOMRIGHT", 109, 11)
		bg:SetFrameLevel(BrowseDropDown:GetFrameLevel(-1))
		Aurora.CreateBD(bg, 0)

		local tex = bg:CreateTexture(nil, "BACKGROUND")
		tex:SetPoint("TOPLEFT")
		tex:SetPoint("BOTTOMRIGHT")
		tex:SetTexture(Aurora.backdrop)
		tex:SetGradientAlpha("VERTICAL", 0, 0, 0, .3, .35, .35, .35, .35)

		local inputs = {"BrowseMinLevel", "BrowseMaxLevel", "BrowseBidPriceGold", "BrowseBidPriceSilver", "BrowseBidPriceCopper", "BidBidPriceGold", "BidBidPriceSilver", "BidBidPriceCopper", "StartPriceGold", "StartPriceSilver", "StartPriceCopper", "BuyoutPriceGold", "BuyoutPriceSilver", "BuyoutPriceCopper", "AuctionsStackSizeEntry", "AuctionsNumStacksEntry"}
		for i = 1, #inputs do
			Aurora.ReskinInput(_G[inputs[i]])
		end
	elseif addon == "Blizzard_AchievementUI" then
		Aurora.CreateBD(AchievementFrame)
		Aurora.CreateSD(AchievementFrame)
		AchievementFrameCategories:SetBackdrop(nil)
		AchievementFrameSummary:SetBackdrop(nil)
		for i = 1, 17 do
			select(i, AchievementFrame:GetRegions()):Hide()
		end
		AchievementFrameSummaryBackground:Hide()
		AchievementFrameSummary:GetChildren():Hide()
		AchievementFrameCategoriesContainerScrollBarBG:SetAlpha(0)
		for i = 1, 4 do
			select(i, AchievementFrameHeader:GetRegions()):Hide()
		end
		AchievementFrameHeaderRightDDLInset:SetAlpha(0)
		select(2, AchievementFrameAchievements:GetChildren()):Hide()
		AchievementFrameAchievementsBackground:Hide()
		select(3, AchievementFrameAchievements:GetRegions()):Hide()
		AchievementFrameStatsBG:Hide()
		AchievementFrameSummaryAchievementsHeaderHeader:Hide()
		AchievementFrameSummaryCategoriesHeaderTexture:Hide()
		select(3, AchievementFrameStats:GetChildren()):Hide()

		local first = 1
		hooksecurefunc("AchievementFrameCategories_Update", function()
			if first == 1 then
				for i = 1, 19 do
					_G["AchievementFrameCategoriesContainerButton"..i.."Background"]:Hide()
				end
				first = 0
			end
		end)

		AchievementFrameHeader:ClearAllPoints()
		AchievementFrameHeader:SetPoint("TOP", AchievementFrame, "TOP", 0, 36)
		AchievementFrameFilterDropDown:ClearAllPoints()
		AchievementFrameFilterDropDown:SetPoint("RIGHT", AchievementFrameHeader, "RIGHT", -120, 2)
		AchievementFrameFilterDropDownText:ClearAllPoints()
		AchievementFrameFilterDropDownText:SetPoint("CENTER", -10, 1)

		AchievementFrameSummaryCategoriesStatusBar:SetStatusBarTexture(Aurora.backdrop)

		for i = 1, 3 do
			local tab = _G["AchievementFrameTab"..i]
			if tab then
				Aurora.CreateTab(tab)
			end
		end

		AchievementFrameSummaryCategoriesStatusBar:SetStatusBarTexture(Aurora.backdrop)
		AchievementFrameSummaryCategoriesStatusBar:GetStatusBarTexture():SetGradient("VERTICAL", 0, .4, 0, 0, .6, 0)
		AchievementFrameSummaryCategoriesStatusBarLeft:Hide()
		AchievementFrameSummaryCategoriesStatusBarMiddle:Hide()
		AchievementFrameSummaryCategoriesStatusBarRight:Hide()
		AchievementFrameSummaryCategoriesStatusBarFillBar:Hide()
		AchievementFrameSummaryCategoriesStatusBarTitle:SetTextColor(1, 1, 1)
		AchievementFrameSummaryCategoriesStatusBarTitle:SetPoint("LEFT", AchievementFrameSummaryCategoriesStatusBar, "LEFT", 6, 0)
		AchievementFrameSummaryCategoriesStatusBarText:SetPoint("RIGHT", AchievementFrameSummaryCategoriesStatusBar, "RIGHT", -5, 0)

		local bg = CreateFrame("Frame", nil, AchievementFrameSummaryCategoriesStatusBar)
		bg:SetPoint("TOPLEFT", -1, 1)
		bg:SetPoint("BOTTOMRIGHT", 1, -1)
		bg:SetFrameLevel(AchievementFrameSummaryCategoriesStatusBar:GetFrameLevel()-1)
		Aurora.CreateBD(bg, .25)

		for i = 1, 7 do
			local bu = _G["AchievementFrameAchievementsContainerButton"..i]
			bu:DisableDrawLayer("BORDER")

			local bd = _G["AchievementFrameAchievementsContainerButton"..i.."Background"]

			bd:SetTexture(Aurora.backdrop)
			bd:SetVertexColor(0, 0, 0, .25)

			local text = _G["AchievementFrameAchievementsContainerButton"..i.."Description"]
			text:SetTextColor(.9, .9, .9)
			text.SetTextColor = Aurora.dummy
			text:SetShadowOffset(1, -1)
			text.SetShadowOffset = Aurora.dummy

			_G["AchievementFrameAchievementsContainerButton"..i.."TitleBackground"]:Hide()
			_G["AchievementFrameAchievementsContainerButton"..i.."Glow"]:Hide()
			_G["AchievementFrameAchievementsContainerButton"..i.."RewardBackground"]:SetAlpha(0)
			_G["AchievementFrameAchievementsContainerButton"..i.."PlusMinus"]:SetAlpha(0)
			_G["AchievementFrameAchievementsContainerButton"..i.."Highlight"]:SetAlpha(0)
			_G["AchievementFrameAchievementsContainerButton"..i.."IconOverlay"]:Hide()

			local bg = CreateFrame("Frame", nil, bu)
			bg:SetPoint("TOPLEFT", 2, -2)
			bg:SetPoint("BOTTOMRIGHT", -2, 2)
			Aurora.CreateBD(bg, 0)

			local ic = _G["AchievementFrameAchievementsContainerButton"..i.."IconTexture"]
			ic:SetTexCoord(.08, .92, .08, .92)
			Aurora.CreateBG(ic)
		end

		hooksecurefunc("AchievementObjectives_DisplayCriteria", function()
			for i = 1, 16 do
				local name = _G["AchievementFrameCriteria"..i.."Name"]
				if name and select(2, name:GetTextColor()) == 0 then
					name:SetTextColor(1, 1, 1)
				end
			end
		end)

		hooksecurefunc("AchievementButton_GetProgressBar", function(index)
			local bar = _G["AchievementFrameProgressBar"..index]
			if not bar.reskinned then
				bar:SetStatusBarTexture(Aurora.backdrop)
				bar.reskinned = true
			end
		end)

		hooksecurefunc("AchievementFrameSummary_UpdateAchievements", function()
			for i = 1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
				local bu = _G["AchievementFrameSummaryAchievement"..i]
				if not bu.reskinned then
					bu:DisableDrawLayer("BORDER")

					local bd = _G["AchievementFrameSummaryAchievement"..i.."Background"]

					bd:SetTexture(Aurora.backdrop)
					bd:SetVertexColor(0, 0, 0, .25)

					_G["AchievementFrameSummaryAchievement"..i.."TitleBackground"]:Hide()
					_G["AchievementFrameSummaryAchievement"..i.."Glow"]:Hide()
					_G["AchievementFrameSummaryAchievement"..i.."Highlight"]:SetAlpha(0)
					_G["AchievementFrameSummaryAchievement"..i.."IconOverlay"]:Hide()

					local text = _G["AchievementFrameSummaryAchievement"..i.."Description"]
					text:SetTextColor(.9, .9, .9)
					text.SetTextColor = Aurora.dummy
					text:SetShadowOffset(1, -1)
					text.SetShadowOffset = Aurora.dummy

					local bg = CreateFrame("Frame", nil, bu)
					bg:SetPoint("TOPLEFT", 2, -2)
					bg:SetPoint("BOTTOMRIGHT", -2, 2)
					Aurora.CreateBD(bg, 0)

					local ic = _G["AchievementFrameSummaryAchievement"..i.."IconTexture"]
					ic:SetTexCoord(.08, .92, .08, .92)
					Aurora.CreateBG(ic)

					bu.reskinned = true
				end
			end
		end)

		for i = 1, 8 do
			local bu = _G["AchievementFrameSummaryCategoriesCategory"..i]
			local bar = bu:GetStatusBarTexture()
			local label = _G["AchievementFrameSummaryCategoriesCategory"..i.."Label"]

			bu:SetStatusBarTexture(Aurora.backdrop)
			bar:SetGradient("VERTICAL", 0, .4, 0, 0, .6, 0)
			label:SetTextColor(1, 1, 1)
			label:SetPoint("LEFT", bu, "LEFT", 6, 0)

			local bg = CreateFrame("Frame", nil, bu)
			bg:SetPoint("TOPLEFT", -1, 1)
			bg:SetPoint("BOTTOMRIGHT", 1, -1)
			bg:SetFrameLevel(bu:GetFrameLevel()-1)
			Aurora.CreateBD(bg, .25)
			
			_G["AchievementFrameSummaryCategoriesCategory"..i.."Left"]:Hide()
			_G["AchievementFrameSummaryCategoriesCategory"..i.."Middle"]:Hide()
			_G["AchievementFrameSummaryCategoriesCategory"..i.."Right"]:Hide()
			_G["AchievementFrameSummaryCategoriesCategory"..i.."FillBar"]:Hide()
			_G["AchievementFrameSummaryCategoriesCategory"..i.."ButtonHighlight"]:SetAlpha(0)
			_G["AchievementFrameSummaryCategoriesCategory"..i.."Text"]:SetPoint("RIGHT", bu, "RIGHT", -5, 0)
		end

		for i = 1, 20 do
			_G["AchievementFrameStatsContainerButton"..i.."BG"]:Hide()
			_G["AchievementFrameStatsContainerButton"..i.."BG"].Show = Aurora.dummy
			_G["AchievementFrameStatsContainerButton"..i.."HeaderLeft"]:SetAlpha(0)
			_G["AchievementFrameStatsContainerButton"..i.."HeaderMiddle"]:SetAlpha(0)
			_G["AchievementFrameStatsContainerButton"..i.."HeaderRight"]:SetAlpha(0)
		end

		Aurora.ReskinClose(AchievementFrameCloseButton)
		Aurora.ReskinScroll(AchievementFrameAchievementsContainerScrollBar)
		Aurora.ReskinScroll(AchievementFrameStatsContainerScrollBar)
		Aurora.ReskinScroll(AchievementFrameCategoriesContainerScrollBar)
		Aurora.ReskinDropDown(AchievementFrameFilterDropDown)
	elseif addon == "Blizzard_BarbershopUI" then
		Aurora.SetBD(BarberShopFrame, 44, -75, -40, 44)
		BarberShopFrameBackground:Hide()
		BarberShopFrameMoneyFrame:GetRegions():Hide()
		Aurora.Reskin(BarberShopFrameOkayButton)
		Aurora.Reskin(BarberShopFrameCancelButton)
		Aurora.Reskin(BarberShopFrameResetButton)
		Aurora.ReskinArrow(BarberShopFrameSelector1Prev, 1)
		Aurora.ReskinArrow(BarberShopFrameSelector1Next, 2)
		Aurora.ReskinArrow(BarberShopFrameSelector2Prev, 1)
		Aurora.ReskinArrow(BarberShopFrameSelector2Next, 2)
		Aurora.ReskinArrow(BarberShopFrameSelector3Prev, 1)
		Aurora.ReskinArrow(BarberShopFrameSelector3Next, 2)
	elseif addon == "Blizzard_BattlefieldMinimap" then
		Aurora.SetBD(BattlefieldMinimap, -1, 1, -5, 3)
		BattlefieldMinimapCorner:Hide()
		BattlefieldMinimapBackground:Hide()
		BattlefieldMinimapCloseButton:Hide()
	elseif addon == "Blizzard_BindingUI" then
		Aurora.SetBD(KeyBindingFrame, 2, 0, -38, 10)
		KeyBindingFrame:DisableDrawLayer("BACKGROUND")
		KeyBindingFrameHeader:SetTexture("")
		Aurora.Reskin(KeyBindingFrameDefaultButton)
		Aurora.Reskin(KeyBindingFrameUnbindButton)
		Aurora.Reskin(KeyBindingFrameOkayButton)
		Aurora.Reskin(KeyBindingFrameCancelButton)
		KeyBindingFrameOkayButton:ClearAllPoints()
		KeyBindingFrameOkayButton:SetPoint("RIGHT", KeyBindingFrameCancelButton, "LEFT", -1, 0)
		KeyBindingFrameUnbindButton:ClearAllPoints()
		KeyBindingFrameUnbindButton:SetPoint("RIGHT", KeyBindingFrameOkayButton, "LEFT", -1, 0)

		for i = 1, KEY_BINDINGS_DISPLAYED do
			local button1 = _G["KeyBindingFrameBinding"..i.."Key1Button"]
			local button2 = _G["KeyBindingFrameBinding"..i.."Key2Button"]

			button2:SetPoint("LEFT", button1, "RIGHT", 1, 0)
			Aurora.Reskin(button1)
			Aurora.Reskin(button2)
		end

		Aurora.ReskinScroll(KeyBindingFrameScrollFrameScrollBar)
		Aurora.ReskinCheck(KeyBindingFrameCharacterButton)
	elseif addon == "Blizzard_Calendar" then
		CalendarFrame:DisableDrawLayer("BORDER")
		for i = 1, 15 do
			if i ~= 10 and i ~= 11 and i ~= 12 and i ~= 13 and i ~= 14 then select(i, CalendarViewEventFrame:GetRegions()):Hide() end
		end
		for i = 1, 9 do
			select(i, CalendarViewHolidayFrame:GetRegions()):Hide()
			select(i, CalendarViewRaidFrame:GetRegions()):Hide()
		end
		for i = 1, 3 do
			select(i, CalendarCreateEventTitleFrame:GetRegions()):Hide()
			select(i, CalendarViewEventTitleFrame:GetRegions()):Hide()
			select(i, CalendarViewHolidayTitleFrame:GetRegions()):Hide()
			select(i, CalendarViewRaidTitleFrame:GetRegions()):Hide()
		end
		for i = 1, 42 do
			_G["CalendarDayButton"..i]:DisableDrawLayer("BACKGROUND")
			_G["CalendarDayButton"..i.."DarkFrame"]:SetAlpha(.5)
		end
		CalendarViewEventDivider:Hide()
		CalendarCreateEventDivider:Hide()
		CalendarViewEventInviteList:GetRegions():Hide()
		CalendarViewEventDescriptionContainer:GetRegions():Hide()
		select(5, CalendarCreateEventCloseButton:GetRegions()):Hide()
		select(5, CalendarViewEventCloseButton:GetRegions()):Hide()
		select(5, CalendarViewHolidayCloseButton:GetRegions()):Hide()
		select(5, CalendarViewRaidCloseButton:GetRegions()):Hide()
		CalendarCreateEventBackground:Hide()
		CalendarCreateEventFrameButtonBackground:Hide()
		CalendarCreateEventMassInviteButtonBorder:Hide()
		CalendarCreateEventCreateButtonBorder:Hide()
		CalendarEventPickerTitleFrameBackgroundLeft:Hide()
		CalendarEventPickerTitleFrameBackgroundMiddle:Hide()
		CalendarEventPickerTitleFrameBackgroundRight:Hide()
		CalendarEventPickerFrameButtonBackground:Hide()
		CalendarEventPickerCloseButtonBorder:Hide()
		CalendarFrameModalOverlay:SetAlpha(.25)

		Aurora.SetBD(CalendarFrame, 12, 0, -10, 4)
		Aurora.CreateBD(CalendarViewEventFrame)
		Aurora.CreateSD(CalendarViewEventFrame)
		Aurora.CreateBD(CalendarViewHolidayFrame)
		Aurora.CreateSD(CalendarViewHolidayFrame)
		Aurora.CreateBD(CalendarViewRaidFrame)
		Aurora.CreateSD(CalendarViewRaidFrame)
		Aurora.CreateBD(CalendarCreateEventFrame)
		Aurora.CreateSD(CalendarCreateEventFrame)
		Aurora.CreateBD(CalendarViewEventInviteList, .25)
		Aurora.CreateBD(CalendarViewEventDescriptionContainer, .25)
		Aurora.CreateBD(CalendarCreateEventInviteList, .25)
		Aurora.CreateBD(CalendarCreateEventDescriptionContainer, .25)
		Aurora.CreateBD(CalendarEventPickerFrame, .25)
		-- No, I don't have a better way to do this
		for i = 1, 6 do
			local vline = CreateFrame("Frame", nil, _G["CalendarDayButton"..i])
			vline:SetHeight(546)
			vline:SetWidth(1)
			vline:SetPoint("TOP", _G["CalendarDayButton"..i], "TOPRIGHT")
			Aurora.CreateBD(vline)
		end
		for i = 1, 36, 7 do
			local hline = CreateFrame("Frame", nil, _G["CalendarDayButton"..i])
			hline:SetWidth(637)
			hline:SetHeight(1)
			hline:SetPoint("LEFT", _G["CalendarDayButton"..i], "TOPLEFT")
			Aurora.CreateBD(hline)
		end

		CalendarCreateEventInviteButton:SetPoint("TOPLEFT", CalendarCreateEventInviteEdit, "TOPRIGHT", 1, 1)

		local cbuttons = {"CalendarViewEventAcceptButton", "CalendarViewEventTentativeButton", "CalendarViewEventDeclineButton", "CalendarViewEventRemoveButton", "CalendarCreateEventMassInviteButton", "CalendarCreateEventCreateButton", "CalendarCreateEventInviteButton", "CalendarEventPickerCloseButton"}
		for i = 1, #cbuttons do
			local cbutton = _G[cbuttons[i]]
			Aurora.Reskin(cbutton)
		end

		Aurora.ReskinClose(CalendarCloseButton, "TOPRIGHT", CalendarFrame, "TOPRIGHT", -14, -4)
		Aurora.ReskinClose(CalendarCreateEventCloseButton)
		Aurora.ReskinClose(CalendarViewEventCloseButton)
		Aurora.ReskinClose(CalendarViewHolidayCloseButton)
		Aurora.ReskinClose(CalendarViewRaidCloseButton)
		Aurora.ReskinDropDown(CalendarCreateEventTypeDropDown)
		Aurora.ReskinDropDown(CalendarCreateEventHourDropDown)
		Aurora.ReskinDropDown(CalendarCreateEventMinuteDropDown)
		Aurora.ReskinInput(CalendarCreateEventTitleEdit)
		Aurora.ReskinInput(CalendarCreateEventInviteEdit)
		Aurora.ReskinArrow(CalendarPrevMonthButton, 1)
		Aurora.ReskinArrow(CalendarNextMonthButton, 2)
		CalendarPrevMonthButton:SetSize(19, 19)
		CalendarNextMonthButton:SetSize(19, 19)
		Aurora.ReskinCheck(CalendarCreateEventLockEventCheck)
	elseif addon == "Blizzard_DebugTools" then
		ScriptErrorsFrame:SetScale(UIParent:GetScale())
		ScriptErrorsFrame:SetSize(386, 274)
		ScriptErrorsFrame:DisableDrawLayer("OVERLAY")
		ScriptErrorsFrameTitleBG:Hide()
		ScriptErrorsFrameDialogBG:Hide()
		Aurora.CreateBD(ScriptErrorsFrame)
		Aurora.CreateSD(ScriptErrorsFrame)

		FrameStackTooltip:SetScale(UIParent:GetScale())
		FrameStackTooltip:SetBackdrop(nil)

		local bg = CreateFrame("Frame", nil, FrameStackTooltip)
		bg:SetPoint("TOPLEFT")
		bg:SetPoint("BOTTOMRIGHT")
		bg:SetFrameLevel(FrameStackTooltip:GetFrameLevel()-1)
		Aurora.CreateBD(bg, .6)

		Aurora.ReskinClose(ScriptErrorsFrameClose)
		Aurora.ReskinScroll(ScriptErrorsFrameScrollFrameScrollBar)
		Aurora.Reskin(select(4, ScriptErrorsFrame:GetChildren()))
		Aurora.Reskin(select(5, ScriptErrorsFrame:GetChildren()))
		Aurora.Reskin(select(6, ScriptErrorsFrame:GetChildren()))
	elseif addon == "Blizzard_GlyphUI" then
		GlyphFrameBackground:Hide()
		GlyphFrameSideInset:DisableDrawLayer("BACKGROUND")
		GlyphFrameSideInset:DisableDrawLayer("BORDER")
		GlyphFrameHeader1Left:Hide()
		GlyphFrameHeader1Middle:Hide()
		GlyphFrameHeader1Right:Hide()
		GlyphFrameClearInfoFrameIcon:SetPoint("TOPLEFT", 1, -1)
		GlyphFrameClearInfoFrameIcon:SetPoint("BOTTOMRIGHT", -1, 1)
		Aurora.CreateBD(GlyphFrameClearInfoFrame)
		GlyphFrameClearInfoFrameIcon:SetTexCoord(.08, .92, .08, .92)

		for i = 1, 12 do
			local bu = _G["GlyphFrameScrollFrameButton"..i]
			local ic = _G["GlyphFrameScrollFrameButton"..i.."Icon"]

			local bg = CreateFrame("Frame", nil, bu)
			bg:SetPoint("TOPLEFT", 38, -2)
			bg:SetPoint("BOTTOMRIGHT", 0, 2)
			bg:SetFrameLevel(bu:GetFrameLevel()-1)
			Aurora.CreateBD(bg, .25)

			_G["GlyphFrameScrollFrameButton"..i.."Name"]:SetParent(bg)
			_G["GlyphFrameScrollFrameButton"..i.."TypeName"]:SetParent(bg)
			bu:SetHighlightTexture(nil)
			select(3, bu:GetRegions()):SetAlpha(0)
			select(4, bu:GetRegions()):SetAlpha(0)

			local check = select(2, bu:GetRegions())
			check:SetPoint("TOPLEFT", 39, -3)
			check:SetPoint("BOTTOMRIGHT", -1, 3)
			check:SetTexture(Aurora.backdrop)
			check:SetVertexColor(r, g, b, .2)

			local icbg = CreateFrame("Frame", nil, bu)
			icbg:SetPoint("TOPLEFT", ic, -1, 1)
			icbg:SetPoint("BOTTOMRIGHT", ic, 1, -1)
			Aurora.CreateBD(icbg, 0)

			ic:SetTexCoord(.08, .92, .08, .92)
		end

		Aurora.ReskinInput(GlyphFrameSearchBox)
		Aurora.ReskinScroll(GlyphFrameScrollFrameScrollBar)
		Aurora.ReskinDropDown(GlyphFrameFilterDropDown)
	elseif addon == "Blizzard_GMSurveyUI" then
		Aurora.SetBD(GMSurveyFrame, 0, 0, -32, 4)
		Aurora.CreateBD(GMSurveyCommentFrame, .25)
		for i = 1, 11 do
			Aurora.CreateBD(_G["GMSurveyQuestion"..i], .25)
		end

		for i = 1, 11 do
			select(i, GMSurveyFrame:GetRegions()):Hide()
		end
		GMSurveyHeaderLeft:Hide()
		GMSurveyHeaderRight:Hide()
		GMSurveyHeaderCenter:Hide()
		GMSurveyScrollFrameTop:SetAlpha(0)
		GMSurveyScrollFrameMiddle:SetAlpha(0)
		GMSurveyScrollFrameBottom:SetAlpha(0)
		Aurora.Reskin(GMSurveySubmitButton)
		Aurora.Reskin(GMSurveyCancelButton)
		Aurora.ReskinClose(GMSurveyCloseButton, "TOPRIGHT", GMSurveyFrame, "TOPRIGHT", -36, -4)
		Aurora.ReskinScroll(GMSurveyScrollFrameScrollBar)
	elseif addon == "Blizzard_GuildBankUI" then
		local bg = CreateFrame("Frame", nil, GuildBankFrame)
		bg:SetPoint("TOPLEFT", 10, -8)
		bg:SetPoint("BOTTOMRIGHT", 0, 6)
		bg:SetFrameLevel(GuildBankFrame:GetFrameLevel()-1)
		Aurora.CreateBD(bg)
		Aurora.CreateSD(bg)

		GuildBankPopupFrame:SetPoint("TOPLEFT", GuildBankFrame, "TOPRIGHT", 2, -30)

		local bd = CreateFrame("Frame", nil, GuildBankPopupFrame)
		bd:SetPoint("TOPLEFT")
		bd:SetPoint("BOTTOMRIGHT", -28, 26)
		bd:SetFrameLevel(GuildBankPopupFrame:GetFrameLevel()-1)
		Aurora.CreateBD(bd)
		Aurora.CreateBD(GuildBankPopupEditBox, .25)

		GuildBankEmblemFrame:Hide()
		GuildBankPopupFrameTopLeft:Hide()
		GuildBankPopupFrameBottomLeft:Hide()
		select(2, GuildBankPopupFrame:GetRegions()):Hide()
		select(4, GuildBankPopupFrame:GetRegions()):Hide()
		GuildBankPopupNameLeft:Hide()
		GuildBankPopupNameMiddle:Hide()
		GuildBankPopupNameRight:Hide()
		GuildBankPopupScrollFrame:GetRegions():Hide()
		select(2, GuildBankPopupScrollFrame:GetRegions()):Hide()
		GuildBankTabTitleBackground:SetAlpha(0)
		GuildBankTabTitleBackgroundLeft:SetAlpha(0)
		GuildBankTabTitleBackgroundRight:SetAlpha(0)
		GuildBankTabLimitBackground:SetAlpha(0)
		GuildBankTabLimitBackgroundLeft:SetAlpha(0)
		GuildBankTabLimitBackgroundRight:SetAlpha(0)
		GuildBankFrameLeft:Hide()
		GuildBankFrameRight:Hide()
		local a, b = GuildBankTransactionsScrollFrame:GetRegions()
		a:Hide()
		b:Hide()

		for i = 1, 4 do
			Aurora.CreateTab(_G["GuildBankFrameTab"..i])
		end

		Aurora.Reskin(GuildBankFrameWithdrawButton)
		Aurora.Reskin(GuildBankFrameDepositButton)
		Aurora.Reskin(GuildBankFramePurchaseButton)
		Aurora.Reskin(GuildBankPopupOkayButton)
		Aurora.Reskin(GuildBankPopupCancelButton)
		Aurora.Reskin(GuildBankInfoSaveButton)

		GuildBankFrameWithdrawButton:ClearAllPoints()
		GuildBankFrameWithdrawButton:SetPoint("RIGHT", GuildBankFrameDepositButton, "LEFT", -1, 0)

		for i = 1, 7 do
			for j = 1, 14 do
				local co = _G["GuildBankColumn"..i]
				local bu = _G["GuildBankColumn"..i.."Button"..j]
				local ic = _G["GuildBankColumn"..i.."Button"..j.."IconTexture"]
				local nt = _G["GuildBankColumn"..i.."Button"..j.."NormalTexture"]

				co:GetRegions():Hide()
				ic:SetTexCoord(.08, .92, .08, .92)
				nt:SetAlpha(0)

				local bg = CreateFrame("Frame", nil, bu)
				bg:SetPoint("TOPLEFT", -1, 1)
				bg:SetPoint("BOTTOMRIGHT", 1, -1)
				bg:SetFrameLevel(bu:GetFrameLevel()-1)
				Aurora.CreateBD(bg, 0)
			end
		end

		for i = 1, 8 do
			local tb = _G["GuildBankTab"..i]
			local bu = _G["GuildBankTab"..i.."Button"]
			local ic = _G["GuildBankTab"..i.."ButtonIconTexture"]
			local nt = _G["GuildBankTab"..i.."ButtonNormalTexture"]

			bu:SetCheckedTexture(Aurora.checked)
			local bg = CreateFrame("Frame", nil, bu)
			bg:SetPoint("TOPLEFT", -1, 1)
			bg:SetPoint("BOTTOMRIGHT", 1, -1)
			bg:SetFrameLevel(bu:GetFrameLevel()-1)
			Aurora.CreateBD(bg, 1)
			Aurora.CreateSD(bu, 5, 0, 0, 0, 1, 1)

			local a1, p, a2, x, y = bu:GetPoint()
			bu:SetPoint(a1, p, a2, x + 11, y)

			ic:SetTexCoord(.08, .92, .08, .92)
			tb:GetRegions():Hide()
			nt:SetAlpha(0)
		end

		local GuildBankClose = select(14, GuildBankFrame:GetChildren())
		Aurora.ReskinClose(GuildBankClose, "TOPRIGHT", GuildBankFrame, "TOPRIGHT", -4, -12)
		Aurora.ReskinScroll(GuildBankTransactionsScrollFrameScrollBar)
		Aurora.ReskinScroll(GuildBankInfoScrollFrameScrollBar)
		Aurora.ReskinScroll(GuildBankPopupScrollFrameScrollBar)
	elseif addon == "Blizzard_GuildControlUI" then
		Aurora.CreateBD(GuildControlUI)
		Aurora.CreateSD(GuildControlUI)
		Aurora.CreateBD(GuildControlUIRankBankFrameInset, .25)

		for i = 1, 9 do
			select(i, GuildControlUI:GetRegions()):Hide()
		end

		for i = 1, 8 do
			select(i, GuildControlUIRankBankFrameInset:GetRegions()):Hide()
		end

		GuildControlUIRankSettingsFrameChatBg:SetAlpha(0)
		GuildControlUIRankSettingsFrameRosterBg:SetAlpha(0)
		GuildControlUIRankSettingsFrameInfoBg:SetAlpha(0)
		GuildControlUIRankSettingsFrameBankBg:SetAlpha(0)
		GuildControlUITopBg:Hide()
		GuildControlUIHbar:Hide()
		GuildControlUIRankBankFrameInsetScrollFrameTop:SetAlpha(0)
		GuildControlUIRankBankFrameInsetScrollFrameBottom:SetAlpha(0)

		hooksecurefunc("GuildControlUI_RankOrder_Update", function()
			if not reskinnedranks then
				for i = 1, GuildControlGetNumRanks() do
					Aurora.ReskinInput(_G["GuildControlUIRankOrderFrameRank"..i.."NameEditBox"], 20)
				end
				reskinnedranks = true
			end
		end)

		hooksecurefunc("GuildControlUI_BankTabPermissions_Update", function()
			for i = 1, GetNumGuildBankTabs()+1 do
				local tab = "GuildControlBankTab"..i
				local bu = _G[tab]
				if bu and not bu.reskinned then
					_G[tab.."Bg"]:Hide()
					Aurora.CreateBD(bu, .12)
					Aurora.Reskin(_G[tab.."BuyPurchaseButton"])
					Aurora.ReskinInput(_G[tab.."OwnedStackBox"])

					bu.reskinned = true
				end
			end
		end)

		Aurora.Reskin(GuildControlUIRankOrderFrameNewButton)

		Aurora.ReskinClose(GuildControlUICloseButton)
		Aurora.ReskinScroll(GuildControlUIRankBankFrameInsetScrollFrameScrollBar)
		Aurora.ReskinDropDown(GuildControlUINavigationDropDown)
		Aurora.ReskinDropDown(GuildControlUIRankSettingsFrameRankDropDown)
		Aurora.ReskinDropDown(GuildControlUIRankBankFrameRankDropDown)
		Aurora.ReskinInput(GuildControlUIRankSettingsFrameGoldBox, 20)
	elseif addon == "Blizzard_GuildUI" then
		local bg = CreateFrame("Frame", nil, GuildFrame)
		bg:SetPoint("TOPLEFT")
		bg:SetPoint("BOTTOMRIGHT")
		bg:SetFrameLevel(GuildFrame:GetFrameLevel()-1)
		Aurora.CreateBD(bg)
		Aurora.CreateSD(bg)
		Aurora.CreateBD(GuildMemberDetailFrame)
		Aurora.CreateBD(GuildMemberNoteBackground, .25)
		Aurora.CreateBD(GuildMemberOfficerNoteBackground, .25)
		Aurora.CreateBD(GuildLogFrame)
		Aurora.CreateBD(GuildLogContainer, .25)
		Aurora.CreateBD(GuildNewsFiltersFrame)
		Aurora.CreateBD(GuildTextEditFrame)
		Aurora.CreateSD(GuildTextEditFrame)
		Aurora.CreateBD(GuildTextEditContainer, .25)
		Aurora.CreateBD(GuildRecruitmentInterestFrame, .25)
		Aurora.CreateBD(GuildRecruitmentAvailabilityFrame, .25)
		Aurora.CreateBD(GuildRecruitmentRolesFrame, .25)
		Aurora.CreateBD(GuildRecruitmentLevelFrame, .25)
		for i = 1, 5 do
			Aurora.CreateTab(_G["GuildFrameTab"..i])
		end
		GuildFrameTabardBackground:Hide()
		GuildFrameTabardEmblem:Hide()
		GuildFrameTabardBorder:Hide()
		select(5, GuildInfoFrameInfo:GetRegions()):Hide()
		select(11, GuildMemberDetailFrame:GetRegions()):Hide()
		GuildMemberDetailCorner:Hide()
		for i = 1, 9 do
			select(i, GuildLogFrame:GetRegions()):Hide()
			select(i, GuildNewsFiltersFrame:GetRegions()):Hide()
			select(i, GuildTextEditFrame:GetRegions()):Hide()
		end
		select(2, GuildNewPerksFrame:GetRegions()):Hide()
		select(3, GuildNewPerksFrame:GetRegions()):Hide()
		GuildAllPerksFrame:GetRegions():Hide()
		GuildNewsFrame:GetRegions():Hide()
		GuildRewardsFrame:GetRegions():Hide()
		GuildNewsBossModelShadowOverlay:Hide()
		GuildPerksToggleButtonLeft:Hide()
		GuildPerksToggleButtonMiddle:Hide()
		GuildPerksToggleButtonRight:Hide()
		GuildPerksToggleButtonHighlightLeft:Hide()
		GuildPerksToggleButtonHighlightMiddle:Hide()
		GuildPerksToggleButtonHighlightRight:Hide()
		GuildPerksContainerScrollBarTrack:Hide()
		GuildNewPerksFrameHeader1:Hide()
		GuildNewsContainerScrollBarTrack:Hide()
		GuildInfoDetailsFrameScrollBarTrack:Hide()
		GuildInfoFrameInfoHeader1:SetAlpha(0)
		GuildInfoFrameInfoHeader2:SetAlpha(0)
		GuildInfoFrameInfoHeader3:SetAlpha(0)
		GuildInfoChallengesDungeonTexture:SetAlpha(0)
		GuildInfoChallengesRaidTexture:SetAlpha(0)
		GuildInfoChallengesRatedBGTexture:SetAlpha(0)
		GuildRecruitmentCommentInputFrameTop:Hide()
		GuildRecruitmentCommentInputFrameTopLeft:Hide()
		GuildRecruitmentCommentInputFrameTopRight:Hide()
		GuildRecruitmentCommentInputFrameBottom:Hide()
		GuildRecruitmentCommentInputFrameBottomLeft:Hide()
		GuildRecruitmentCommentInputFrameBottomRight:Hide()
		GuildRecruitmentInterestFrameBg:Hide()
		GuildRecruitmentAvailabilityFrameBg:Hide()
		GuildRecruitmentRolesFrameBg:Hide()
		GuildRecruitmentLevelFrameBg:Hide()
		GuildRecruitmentCommentFrameBg:Hide()

		GuildFrame:DisableDrawLayer("BACKGROUND")
		GuildFrame:DisableDrawLayer("BORDER")
		GuildFrameInset:DisableDrawLayer("BACKGROUND")
		GuildFrameInset:DisableDrawLayer("BORDER")
		GuildFrameBottomInset:DisableDrawLayer("BACKGROUND")
		GuildFrameBottomInset:DisableDrawLayer("BORDER")
		GuildInfoFrameInfoBar1Left:SetAlpha(0)
		GuildInfoFrameInfoBar2Left:SetAlpha(0)
		select(2, GuildInfoFrameInfo:GetRegions()):SetAlpha(0)
		select(4, GuildInfoFrameInfo:GetRegions()):SetAlpha(0)
		GuildFramePortraitFrame:Hide()
		GuildFrameTopRightCorner:Hide()
		GuildFrameTopBorder:Hide()
		GuildRosterColumnButton1:DisableDrawLayer("BACKGROUND")
		GuildRosterColumnButton2:DisableDrawLayer("BACKGROUND")
		GuildRosterColumnButton3:DisableDrawLayer("BACKGROUND")
		GuildRosterColumnButton4:DisableDrawLayer("BACKGROUND")
		GuildAddMemberButton_RightSeparator:Hide()
		GuildControlButton_LeftSeparator:Hide()
		GuildNewsBossModel:DisableDrawLayer("BACKGROUND")
		GuildNewsBossModel:DisableDrawLayer("OVERLAY")
		GuildNewsBossNameText:SetDrawLayer("ARTWORK")
		GuildNewsBossModelTextFrame:DisableDrawLayer("BACKGROUND")
		for i = 2, 6 do
			select(i, GuildNewsBossModelTextFrame:GetRegions()):Hide()
		end

		GuildMemberRankDropdown:HookScript("OnShow", function()
			GuildMemberDetailRankText:Hide()
		end)
		GuildMemberRankDropdown:HookScript("OnHide", function()
			GuildMemberDetailRankText:Show()
		end)

		Aurora.ReskinClose(GuildFrameCloseButton)
		Aurora.ReskinClose(GuildNewsFiltersFrameCloseButton)
		Aurora.ReskinClose(GuildLogFrameCloseButton)
		Aurora.ReskinClose(GuildMemberDetailCloseButton)
		Aurora.ReskinClose(GuildTextEditFrameCloseButton)
		Aurora.ReskinScroll(GuildPerksContainerScrollBar)
		Aurora.ReskinScroll(GuildRosterContainerScrollBar)
		Aurora.ReskinScroll(GuildNewsContainerScrollBar)
		Aurora.ReskinScroll(GuildRewardsContainerScrollBar)
		Aurora.ReskinScroll(GuildInfoDetailsFrameScrollBar)
		Aurora.ReskinScroll(GuildLogScrollFrameScrollBar)
		Aurora.ReskinScroll(GuildTextEditScrollFrameScrollBar)
		Aurora.ReskinDropDown(GuildRosterViewDropdown)
		Aurora.ReskinDropDown(GuildMemberRankDropdown)
		Aurora.ReskinInput(GuildRecruitmentCommentInputFrame)
		GuildRecruitmentCommentInputFrame:SetWidth(312)
		GuildRecruitmentCommentEditBox:SetWidth(284)
		GuildRecruitmentCommentFrame:ClearAllPoints()
		GuildRecruitmentCommentFrame:SetPoint("TOPLEFT", GuildRecruitmentLevelFrame, "BOTTOMLEFT", 0, 1)
		Aurora.ReskinCheck(GuildRosterShowOfflineButton)
		for i = 1, 7 do
			Aurora.ReskinCheck(_G["GuildNewsFilterButton"..i])
		end

		local a1, p, a2, x, y = GuildNewsBossModel:GetPoint()
		GuildNewsBossModel:ClearAllPoints()
		GuildNewsBossModel:SetPoint(a1, p, a2, x+5, y)

		local f = CreateFrame("Frame", nil, GuildNewsBossModel)
		f:SetPoint("TOPLEFT", 0, 1)
		f:SetPoint("BOTTOMRIGHT", 1, -52)
		f:SetFrameLevel(GuildNewsBossModel:GetFrameLevel()-1)
		Aurora.CreateBD(f)

		local line = CreateFrame("Frame", nil, GuildNewsBossModel)
		line:SetPoint("BOTTOMLEFT", 0, -1)
		line:SetPoint("BOTTOMRIGHT", 0, -1)
		line:SetHeight(1)
		line:SetFrameLevel(GuildNewsBossModel:GetFrameLevel()-1)
		Aurora.CreateBD(line, 0)

		GuildNewsFiltersFrame:SetWidth(224)
		GuildNewsFiltersFrame:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 1, -20)
		GuildMemberDetailFrame:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 1, -28)
		GuildLogFrame:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 1, 0)

		for i = 1, 5 do
			local bu = _G["GuildInfoFrameApplicantsContainerButton"..i]
			Aurora.CreateBD(bu, .25)
			bu:SetHighlightTexture("")
			bu:GetRegions():SetTexture(Aurora.backdrop)
			bu:GetRegions():SetVertexColor(r, g, b, .2)
		end

		GuildFactionBarProgress:SetTexture(Aurora.backdrop)
		GuildFactionBarLeft:Hide()
		GuildFactionBarMiddle:Hide()
		GuildFactionBarRight:Hide()
		GuildFactionBarShadow:Hide()
		GuildFactionBarBG:Hide()
		GuildFactionBarCap:SetAlpha(0)
		GuildFactionBar.bg = CreateFrame("Frame", nil, GuildFactionFrame)
		GuildFactionBar.bg:SetPoint("TOPLEFT", GuildFactionFrame, -1, -1)
		GuildFactionBar.bg:SetPoint("BOTTOMRIGHT", GuildFactionFrame, -3, 0)
		GuildFactionBar.bg:SetFrameLevel(0)
		Aurora.CreateBD(GuildFactionBar.bg, .25)

		GuildXPFrame:ClearAllPoints()
		GuildXPFrame:SetPoint("TOP", GuildFrame, "TOP", 0, -40)
		GuildXPBarProgress:SetTexture(Aurora.backdrop)
		GuildXPBarLeft:Hide()
		GuildXPBarRight:Hide()
		GuildXPBarMiddle:Hide()
		GuildXPBarBG:Hide()
		GuildXPBarShadow:SetAlpha(0)
		GuildXPBarCap:SetAlpha(0)
		GuildXPBarDivider1:Hide()
		GuildXPBarDivider2:Hide()
		GuildXPBarDivider3:Hide()
		GuildXPBarDivider4:Hide()
		GuildXPBar.bg = CreateFrame("Frame", nil, GuildXPBar)
		GuildXPBar.bg:SetPoint("TOPLEFT", GuildXPFrame)
		GuildXPBar.bg:SetPoint("BOTTOMRIGHT", GuildXPFrame, 0, 4)
		GuildXPBar.bg:SetFrameLevel(0)
		Aurora.CreateBD(GuildXPBar.bg, .25)

		local perkbuttons = {"GuildLatestPerkButton", "GuildNextPerkButton"}
		for _, button in pairs(perkbuttons) do
			local bu = _G[button]
			local ic = _G[button.."IconTexture"]
			local na = _G[button.."NameFrame"]

			na:Hide()
			ic:SetTexCoord(.08, .92, .08, .92)

			ic.bg = CreateFrame("Frame", nil, bu)
			ic.bg:SetPoint("TOPLEFT", ic, -1, 1)
			ic.bg:SetPoint("BOTTOMRIGHT", ic, 1, -1)
			ic.bg:SetFrameLevel(0)
			Aurora.CreateBD(ic.bg, .25)

			bu.bg = CreateFrame("Frame", nil, bu)
			bu.bg:SetPoint("TOPLEFT", na, 14, -24)
			bu.bg:SetPoint("BOTTOMRIGHT", na, -60, 24)
			bu.bg:SetFrameLevel(0)
			Aurora.CreateBD(bu.bg, .25)
		end

		select(5, GuildLatestPerkButton:GetRegions()):Hide()
		select(6, GuildLatestPerkButton:GetRegions()):Hide()

		local reskinnedperks = false
		GuildPerksToggleButton:HookScript("OnClick", function()
			if not reskinnedperks == true then
				for i = 1, 8 do
					local button = "GuildPerksContainerButton"..i
					local bu = _G[button]
					local ic = _G[button.."IconTexture"]

					bu:DisableDrawLayer("BACKGROUND")
					bu:DisableDrawLayer("BORDER")
					bu.EnableDrawLayer = Aurora.dummy
					ic:SetTexCoord(.08, .92, .08, .92)

					ic.bg = CreateFrame("Frame", nil, bu)
					ic.bg:SetPoint("TOPLEFT", ic, -1, 1)
					ic.bg:SetPoint("BOTTOMRIGHT", ic, 1, -1)
					Aurora.CreateBD(ic.bg, 0)
				end
				reskinnedperks = true
			end
		end)

		local reskinnedrewards = false
		GuildFrameTab4:HookScript("OnClick", function()
			if not reskinnedrewards == true then
				for i = 1, 8 do
					local button = "GuildRewardsContainerButton"..i
					local bu = _G[button]
					local ic = _G[button.."Icon"]

					local bg = CreateFrame("Frame", nil, bu)
					bg:SetPoint("TOPLEFT", 0, -1)
					bg:SetPoint("BOTTOMRIGHT")
					Aurora.CreateBD(bg, 0)

					bu:SetHighlightTexture(Aurora.backdrop)
					local hl = bu:GetHighlightTexture()
					hl:SetVertexColor(r, g, b, .2)
					hl:SetPoint("TOPLEFT", 0, -1)
					hl:SetPoint("BOTTOMRIGHT")

					ic:SetTexCoord(.08, .92, .08, .92)

					select(6, bu:GetRegions()):SetAlpha(0)
					select(7, bu:GetRegions()):SetTexture(Aurora.backdrop)
					select(7, bu:GetRegions()):SetVertexColor(0, 0, 0, .25)
					select(7, bu:GetRegions()):SetPoint("TOPLEFT", 0, -1)
					select(7, bu:GetRegions()):SetPoint("BOTTOMRIGHT", 0, 1)

					ic.bg = CreateFrame("Frame", nil, bu)
					ic.bg:SetPoint("TOPLEFT", ic, -1, 1)
					ic.bg:SetPoint("BOTTOMRIGHT", ic, 1, -1)
					Aurora.CreateBD(ic.bg, 0)
				end
				reskinnedrewards = true
			end
		end)

		for i = 1, 16 do
			local bu = _G["GuildRosterContainerButton"..i]
			local ic = _G["GuildRosterContainerButton"..i.."Icon"]

			bu:SetHighlightTexture(Aurora.backdrop)
			bu:GetHighlightTexture():SetVertexColor(r, g, b, .2)

			bu.bg = bu:CreateTexture(nil, "BACKGROUND")
			bu.bg:SetPoint("TOPLEFT", ic, -1, 1)
			bu.bg:SetPoint("BOTTOMRIGHT", ic, 1, -1)
			bu.bg:SetTexture(Aurora.backdrop)
			bu.bg:SetVertexColor(0, 0, 0)
		end

		local tcoords = {
			["WARRIOR"]     = {0.02, 0.23, 0.02, 0.23},
			["MAGE"]        = {0.27, 0.47609375, 0.02, 0.23},
			["ROGUE"]       = {0.51609375, 0.7221875, 0.02, 0.23},
			["DRUID"]       = {0.7621875, 0.96828125, 0.02, 0.23},
			["HUNTER"]      = {0.02, 0.23, 0.27, 0.48},
			["SHAMAN"]      = {0.27, 0.47609375, 0.27, 0.48},
			["PRIEST"]      = {0.51609375, 0.7221875, 0.27, 0.48},
			["WARLOCK"]     = {0.7621875, 0.96828125, 0.27, 0.48},
			["PALADIN"]     = {0.02, 0.23, 0.52, 0.73},
			["DEATHKNIGHT"] = {0.27, .48, 0.52, .73},
		}

		local UpdateIcons = function()
			local index
			local offset = HybridScrollFrame_GetOffset(GuildRosterContainer)
			local totalMembers, onlineMembers = GetNumGuildMembers()
			local visibleMembers = onlineMembers
			local numbuttons = #GuildRosterContainer.buttons
			if GetGuildRosterShowOffline() then
				visibleMembers = totalMembers
			end

			for i = 1, numbuttons do
				local button = GuildRosterContainer.buttons[i]
				index = offset + i
				local name, _, _, _, _, _, _, _, _, _, classFileName  = GetGuildRosterInfo(index)
				if name and index <= visibleMembers then
					if button.icon:IsShown() then
						button.icon:SetTexCoord(unpack(tcoords[classFileName]))
						button.bg:Show()
					else
						button.bg:Hide()
					end
				end
			end
		end

		hooksecurefunc("GuildRoster_Update", UpdateIcons)
		GuildRosterContainer:HookScript("OnMouseWheel", UpdateIcons)
		GuildRosterContainer:HookScript("OnVerticalScroll", UpdateIcons)

		GuildLevelFrame:SetAlpha(0)
		local closebutton = select(4, GuildTextEditFrame:GetChildren())
		Aurora.Reskin(closebutton)
		local logbutton = select(3, GuildLogFrame:GetChildren())
		Aurora.Reskin(logbutton)
		local gbuttons = {"GuildAddMemberButton", "GuildViewLogButton", "GuildControlButton", "GuildTextEditFrameAcceptButton", "GuildMemberGroupInviteButton", "GuildMemberRemoveButton", "GuildRecruitmentInviteButton", "GuildRecruitmentMessageButton", "GuildRecruitmentDeclineButton", "GuildPerksToggleButton", "GuildRecruitmentListGuildButton"}
		for i = 1, #gbuttons do
		local gbutton = _G[gbuttons[i]]
			if gbutton then
				Aurora.Reskin(gbutton)
			end
		end

		for i = 1, 3 do
			for j = 1, 6 do
				select(j, _G["GuildInfoFrameTab"..i]:GetRegions()):Hide()
				select(j, _G["GuildInfoFrameTab"..i]:GetRegions()).Show = Aurora.dummy
			end
		end
	elseif addon == "Blizzard_InspectUI" then
		Aurora.SetBD(InspectFrame)
		InspectFrame:DisableDrawLayer("BACKGROUND")
		InspectFrame:DisableDrawLayer("BORDER")
		InspectFrameInset:DisableDrawLayer("BACKGROUND")
		InspectFrameInset:DisableDrawLayer("BORDER")
		InspectModelFrame:DisableDrawLayer("OVERLAY")

		InspectPVPTeam1:DisableDrawLayer("BACKGROUND")
		InspectPVPTeam2:DisableDrawLayer("BACKGROUND")
		InspectPVPTeam3:DisableDrawLayer("BACKGROUND")
		InspectFramePortrait:Hide()
		InspectGuildFrameBG:Hide()
		for i = 1, 5 do
			select(i, InspectModelFrame:GetRegions()):Hide()
		end
		for i = 1, 4 do
			select(i, InspectTalentFrame:GetRegions()):Hide()
			Aurora.CreateTab(_G["InspectFrameTab"..i])
		end
		for i = 1, 3 do
			for j = 1, 6 do
				select(j, _G["InspectTalentFrameTab"..i]:GetRegions()):Hide()
				select(j, _G["InspectTalentFrameTab"..i]:GetRegions()).Show = Aurora.dummy
			end
		end
		InspectModelFrameRotateLeftButton:Hide()
		InspectModelFrameRotateRightButton:Hide()
		InspectFramePortraitFrame:Hide()
		InspectFrameTopBorder:Hide()
		InspectFrameTopRightCorner:Hide()
		InspectPVPFrameBG:SetAlpha(0)
		InspectPVPFrameBottom:SetAlpha(0)
		InspectTalentFramePointsBarBorderLeft:Hide()
		InspectTalentFramePointsBarBorderMiddle:Hide()
		InspectTalentFramePointsBarBorderRight:Hide()

		local slots = {
			"Head", "Neck", "Shoulder", "Shirt", "Chest", "Waist", "Legs", "Feet", "Wrist",
			"Hands", "Finger0", "Finger1", "Trinket0", "Trinket1", "Back", "MainHand",
			"SecondaryHand", "Ranged", "Tabard",
		}

		for i = 1, #slots do
			local slot = _G["Inspect"..slots[i].."Slot"]
			slot:DisableDrawLayer("BACKGROUND")
			slot:SetNormalTexture("")
			slot:SetPushedTexture("")
			slot.bd = CreateFrame("Frame", nil, slot)
			slot.bd:SetPoint("TOPLEFT", -1, 1)
			slot.bd:SetPoint("BOTTOMRIGHT", 1, -1)
			slot.bd:SetFrameLevel(0)
			Aurora.CreateBD(slot.bd, .25)
			_G["Inspect"..slots[i].."SlotIconTexture"]:SetTexCoord(.08, .92, .08, .92)
		end

		Aurora.ReskinClose(InspectFrameCloseButton)
	elseif addon == "Blizzard_ItemSocketingUI" then
		Aurora.SetBD(ItemSocketingFrame, 12, -8, -2, 24)
		select(2, ItemSocketingFrame:GetRegions()):Hide()
		ItemSocketingFramePortrait:Hide()
		ItemSocketingScrollFrameTop:SetAlpha(0)
		ItemSocketingScrollFrameBottom:SetAlpha(0)
		ItemSocketingSocket1Left:SetAlpha(0)
		ItemSocketingSocket1Right:SetAlpha(0)
		ItemSocketingSocket2Left:SetAlpha(0)
		ItemSocketingSocket2Right:SetAlpha(0)
		Aurora.Reskin(ItemSocketingSocketButton)
		ItemSocketingSocketButton:ClearAllPoints()
		ItemSocketingSocketButton:SetPoint("BOTTOMRIGHT", ItemSocketingFrame, "BOTTOMRIGHT", -10, 28)
		Aurora.ReskinClose(ItemSocketingCloseButton, "TOPRIGHT", ItemSocketingFrame, "TOPRIGHT", -6, -12)
		Aurora.ReskinScroll(ItemSocketingScrollFrameScrollBar)
	elseif addon == "Blizzard_LookingForGuildUI" then
		Aurora.SetBD(LookingForGuildFrame)
		Aurora.CreateBD(LookingForGuildInterestFrame, .25)
		LookingForGuildInterestFrameBg:Hide()
		Aurora.CreateBD(LookingForGuildAvailabilityFrame, .25)
		LookingForGuildAvailabilityFrameBg:Hide()
		Aurora.CreateBD(LookingForGuildRolesFrame, .25)
		LookingForGuildRolesFrameBg:Hide()
		Aurora.CreateBD(LookingForGuildCommentFrame, .25)
		LookingForGuildCommentFrameBg:Hide()
		Aurora.CreateBD(LookingForGuildCommentInputFrame, .12)
		LookingForGuildFrame:DisableDrawLayer("BACKGROUND")
		LookingForGuildFrame:DisableDrawLayer("BORDER")
		LookingForGuildFrameInset:DisableDrawLayer("BACKGROUND")
		LookingForGuildFrameInset:DisableDrawLayer("BORDER")
		for i = 1, 5 do
			local bu = _G["LookingForGuildBrowseFrameContainerButton"..i]
			Aurora.CreateBD(bu, .25)
			bu:SetHighlightTexture("")
			bu:GetRegions():SetTexture(Aurora.backdrop)
			bu:GetRegions():SetVertexColor(r, g, b, .2)
		end
		for i = 1, 9 do
			select(i, LookingForGuildCommentInputFrame:GetRegions()):Hide()
		end
		for i = 1, 3 do
			for j = 1, 6 do
				select(j, _G["LookingForGuildFrameTab"..i]:GetRegions()):Hide()
				select(j, _G["LookingForGuildFrameTab"..i]:GetRegions()).Show = Aurora.dummy
			end
		end
		LookingForGuildFrameTabardBackground:Hide()
		LookingForGuildFrameTabardEmblem:Hide()
		LookingForGuildFrameTabardBorder:Hide()
		LookingForGuildFramePortraitFrame:Hide()
		LookingForGuildFrameTopBorder:Hide()
		LookingForGuildFrameTopRightCorner:Hide()
		LookingForGuildBrowseButton_LeftSeparator:Hide()
		LookingForGuildRequestButton_RightSeparator:Hide()

		Aurora.Reskin(LookingForGuildBrowseButton)
		Aurora.Reskin(LookingForGuildRequestButton)

		Aurora.ReskinScroll(LookingForGuildBrowseFrameContainerScrollBar)
		Aurora.ReskinClose(LookingForGuildFrameCloseButton)
		Aurora.ReskinCheck(LookingForGuildQuestButton)
		Aurora.ReskinCheck(LookingForGuildDungeonButton)
		Aurora.ReskinCheck(LookingForGuildRaidButton)
		Aurora.ReskinCheck(LookingForGuildPvPButton)
		Aurora.ReskinCheck(LookingForGuildRPButton)
		Aurora.ReskinCheck(LookingForGuildWeekdaysButton)
		Aurora.ReskinCheck(LookingForGuildWeekendsButton)
		Aurora.ReskinCheck(LookingForGuildTankButton:GetChildren())
		Aurora.ReskinCheck(LookingForGuildHealerButton:GetChildren())
		Aurora.ReskinCheck(LookingForGuildDamagerButton:GetChildren())
	elseif addon == "Blizzard_MacroUI" then
		Aurora.SetBD(MacroFrame, 12, -10, -33, 68)
		Aurora.CreateBD(MacroFrameScrollFrame, .25)
		Aurora.CreateBD(MacroPopupFrame)
		Aurora.CreateBD(MacroPopupEditBox, .25)
		for i = 1, 6 do
			select(i, MacroFrameTab1:GetRegions()):Hide()
			select(i, MacroFrameTab2:GetRegions()):Hide()
			select(i, MacroFrameTab1:GetRegions()).Show = Aurora.dummy
			select(i, MacroFrameTab2:GetRegions()).Show = Aurora.dummy
		end
		for i = 1, 8 do
			if i ~= 6 then select(i, MacroFrame:GetRegions()):Hide() end
		end
		for i = 1, 5 do
			select(i, MacroPopupFrame:GetRegions()):Hide()
		end
		MacroPopupScrollFrame:GetRegions():Hide()
		select(2, MacroPopupScrollFrame:GetRegions()):Hide()
		MacroPopupNameLeft:Hide()
		MacroPopupNameMiddle:Hide()
		MacroPopupNameRight:Hide()
		MacroFrameTextBackground:SetBackdrop(nil)
		select(2, MacroFrameSelectedMacroButton:GetRegions()):Hide()
		MacroFrameSelectedMacroBackground:SetAlpha(0)
		MacroButtonScrollFrameTop:Hide()
		MacroButtonScrollFrameBottom:Hide()

		for i = 1, MAX_ACCOUNT_MACROS do
			local bu = _G["MacroButton"..i]
			local ic = _G["MacroButton"..i.."Icon"]

			bu:SetCheckedTexture(Aurora.checked)
			select(2, bu:GetRegions()):Hide()

			ic:SetPoint("TOPLEFT", 1, -1)
			ic:SetPoint("BOTTOMRIGHT", -1, 1)
			ic:SetTexCoord(.08, .92, .08, .92)

			Aurora.CreateBD(bu, .25)
		end

		for i = 1, NUM_MACRO_ICONS_SHOWN do
			local bu = _G["MacroPopupButton"..i]
			local ic = _G["MacroPopupButton"..i.."Icon"]

			bu:SetCheckedTexture(Aurora.checked)
			select(2, bu:GetRegions()):Hide()

			ic:SetPoint("TOPLEFT", 1, -1)
			ic:SetPoint("BOTTOMRIGHT", -1, 1)
			ic:SetTexCoord(.08, .92, .08, .92)

			Aurora.CreateBD(bu, .25)
		end

		MacroFrameSelectedMacroButton:SetPoint("TOPLEFT", MacroFrameSelectedMacroBackground, "TOPLEFT", 12, -16)
		MacroFrameSelectedMacroButtonIcon:SetPoint("TOPLEFT", 1, -1)
		MacroFrameSelectedMacroButtonIcon:SetPoint("BOTTOMRIGHT", -1, 1)
		MacroFrameSelectedMacroButtonIcon:SetTexCoord(.08, .92, .08, .92)

		Aurora.CreateBD(MacroFrameSelectedMacroButton, .25)

		Aurora.Reskin(MacroDeleteButton)
		Aurora.Reskin(MacroNewButton)
		Aurora.Reskin(MacroExitButton)
		Aurora.Reskin(MacroEditButton)
		Aurora.Reskin(MacroPopupOkayButton)
		Aurora.Reskin(MacroPopupCancelButton)
		Aurora.Reskin(MacroSaveButton)
		Aurora.Reskin(MacroCancelButton)
		MacroPopupFrame:ClearAllPoints()
		MacroPopupFrame:SetPoint("TOPLEFT", MacroFrame, "TOPRIGHT", -32, -40)

		Aurora.ReskinClose(MacroFrameCloseButton, "TOPRIGHT", MacroFrame, "TOPRIGHT", -38, -14)
		Aurora.ReskinScroll(MacroButtonScrollFrameScrollBar)
		Aurora.ReskinScroll(MacroFrameScrollFrameScrollBar)
		Aurora.ReskinScroll(MacroPopupScrollFrameScrollBar)
	elseif addon == "Blizzard_ReforgingUI" then
		Aurora.SetBD(ReforgingFrame)
		ReforgingFrame:DisableDrawLayer("BORDER")
		ReforgingFrameInset:DisableDrawLayer("BORDER")
		ReforgingFrameBottomInset:DisableDrawLayer("BORDER")
		ReforgingFrameTopInset:DisableDrawLayer("BACKGROUND")
		ReforgingFrameTopInset:DisableDrawLayer("BORDER")
		ReforgingFramePortrait:Hide()
		ReforgingFrameBg:Hide()
		ReforgingFrameTitleBg:Hide()
		ReforgingFrameInsetBg:Hide()
		ReforgingFrameBottomInsetBg:Hide()
		ReforgingFramePortraitFrame:Hide()
		ReforgingFrameTopBorder:Hide()
		ReforgingFrameTopRightCorner:Hide()
		ReforgingFrameRestoreButton_LeftSeparator:Hide()
		ReforgingFrameReforgeButton_LeftSeparator:Hide()
		Aurora.Reskin(ReforgingFrameRestoreButton)
		Aurora.Reskin(ReforgingFrameReforgeButton)
		Aurora.ReskinDropDown(ReforgingFrameFilterOldStat)
		Aurora.ReskinDropDown(ReforgingFrameFilterNewStat)
		Aurora.ReskinClose(ReforgingFrameCloseButton)
	elseif addon == "Blizzard_TalentUI" then
		Aurora.SetBD(PlayerTalentFrame)
		Aurora.Reskin(PlayerTalentFrameToggleSummariesButton)
		Aurora.Reskin(PlayerTalentFrameLearnButton)
		Aurora.Reskin(PlayerTalentFrameResetButton)
		Aurora.Reskin(PlayerTalentFrameActivateButton)
		PlayerTalentFrame:DisableDrawLayer("BACKGROUND")
		PlayerTalentFrame:DisableDrawLayer("BORDER")
		PlayerTalentFrameInset:DisableDrawLayer("BACKGROUND")
		PlayerTalentFrameInset:DisableDrawLayer("BORDER")
		PlayerTalentFramePortrait:Hide()
		PlayerTalentFramePortraitFrame:Hide()
		PlayerTalentFrameTopBorder:Hide()
		PlayerTalentFrameTopRightCorner:Hide()
		PlayerTalentFrameToggleSummariesButton_LeftSeparator:Hide()
		PlayerTalentFrameToggleSummariesButton_RightSeparator:Hide()
		PlayerTalentFrameLearnButton_LeftSeparator:Hide()
		PlayerTalentFrameResetButton_LeftSeparator:Hide()
		--PlayerTalentFrameTitleGlowLeft:SetAlpha(0)
		--PlayerTalentFrameTitleGlowRight:SetAlpha(0)
		--PlayerTalentFrameTitleGlowCenter:SetAlpha(0)

		if class == "HUNTER" then
			PlayerTalentFramePetPanel:DisableDrawLayer("BORDER")
			PlayerTalentFramePetModelBg:Hide()
			PlayerTalentFramePetShadowOverlay:Hide()
			PlayerTalentFramePetModelRotateLeftButton:Hide()
			PlayerTalentFramePetModelRotateRightButton:Hide()
			PlayerTalentFramePetIconBorder:Hide()
			PlayerTalentFramePetPanelHeaderIconBorder:Hide()
			PlayerTalentFramePetPanelHeaderBackground:Hide()
			PlayerTalentFramePetPanelHeaderBorder:Hide()

			PlayerTalentFramePetIcon:SetTexCoord(.08, .92, .08, .92)
			Aurora.CreateBG(PlayerTalentFramePetIcon)

			PlayerTalentFramePetPanelHeaderIconIcon:SetTexCoord(.08, .92, .08, .92)
			Aurora.CreateBG(PlayerTalentFramePetPanelHeaderIcon)

			PlayerTalentFramePetPanelHeaderIcon:SetPoint("TOPLEFT", PlayerTalentFramePetPanelHeaderBackground, "TOPLEFT", -2, 3)
			PlayerTalentFramePetPanelName:SetPoint("LEFT", PlayerTalentFramePetPanelHeaderBackground, "LEFT", 62, 8)

			local bg = CreateFrame("Frame", nil, PlayerTalentFramePetPanel)
			bg:SetPoint("TOPLEFT", 4, -6)
			bg:SetPoint("BOTTOMRIGHT", -4, 4)
			bg:SetFrameLevel(0)
			Aurora.CreateBD(bg, .25)

			local line = PlayerTalentFramePetPanel:CreateTexture(nil, "BACKGROUND")
			line:SetHeight(1)
			line:SetPoint("TOPLEFT", 4, -52)
			line:SetPoint("TOPRIGHT", -4, -52)
			line:SetTexture(Aurora.backdrop)
			line:SetVertexColor(0, 0, 0)
		end

		for i = 1, 3 do
			local tab = _G["PlayerTalentFrameTab"..i]
			if tab then
				Aurora.CreateTab(tab)
			end

			local panel = _G["PlayerTalentFramePanel"..i]
			local icon = _G["PlayerTalentFramePanel"..i.."HeaderIcon"]
			local num = _G["PlayerTalentFramePanel"..i.."HeaderIconPointsSpent"]
			local icontexture = _G["PlayerTalentFramePanel"..i.."HeaderIconIcon"]

			for j = 1, 8 do
				select(j, panel:GetRegions()):Hide()
			end
			for j = 14, 21 do
				select(j, panel:GetRegions()):SetAlpha(0)
			end

			_G["PlayerTalentFramePanel"..i.."HeaderBackground"]:SetAlpha(0)
			_G["PlayerTalentFramePanel"..i.."HeaderBorder"]:Hide()
			_G["PlayerTalentFramePanel"..i.."BgHighlight"]:Hide()
			_G["PlayerTalentFramePanel"..i.."HeaderIconPrimaryBorder"]:SetAlpha(0)
			_G["PlayerTalentFramePanel"..i.."HeaderIconSecondaryBorder"]:SetAlpha(0)
			_G["PlayerTalentFramePanel"..i.."HeaderIconPointsSpentBgGold"]:SetAlpha(0)
			_G["PlayerTalentFramePanel"..i.."HeaderIconPointsSpentBgSilver"]:SetAlpha(0)

			icontexture:SetTexCoord(.08, .92, .08, .92)
			icontexture:SetPoint("TOPLEFT", 1, -1)
			icontexture:SetPoint("BOTTOMRIGHT", -1, 1)

			Aurora.CreateBD(icon)

			icon:SetPoint("TOPLEFT", panel, "TOPLEFT", 4, -1)

			num:ClearAllPoints()
			num:SetPoint("RIGHT", _G["PlayerTalentFramePanel"..i.."HeaderBackground"], "RIGHT", -40, 0)
			num:SetFont("FONTS\\FRIZQT__.TTF", 12)
			num:SetJustifyH("RIGHT")

			panel.bg = CreateFrame("Frame", nil, panel)
			panel.bg:SetPoint("TOPLEFT", 4, -39)
			panel.bg:SetPoint("BOTTOMRIGHT", -4, 4)
			panel.bg:SetFrameLevel(0)
			Aurora.CreateBD(panel.bg)

			panel.bg2 = CreateFrame("Frame", nil, panel)
			panel.bg2:SetSize(200, 36)
			panel.bg2:SetPoint("TOPLEFT", 4, -1)
			panel.bg2:SetFrameLevel(0)
			Aurora.CreateBD(panel.bg2, .25)

			Aurora.Reskin(_G["PlayerTalentFramePanel"..i.."SelectTreeButton"])

			for j = 1, 28 do
				local bu = _G["PlayerTalentFramePanel"..i.."Talent"..j]
				local ic = _G["PlayerTalentFramePanel"..i.."Talent"..j.."IconTexture"]

				_G["PlayerTalentFramePanel"..i.."Talent"..j.."Slot"]:SetAlpha(0)
				_G["PlayerTalentFramePanel"..i.."Talent"..j.."SlotShadow"]:SetAlpha(0)
				_G["PlayerTalentFramePanel"..i.."Talent"..j.."GoldBorder"]:SetAlpha(0)

				bu:SetPushedTexture("")
				bu.SetPushedTexture = Aurora.dummy
				ic:SetTexCoord(.08, .92, .08, .92)
				ic:SetPoint("TOPLEFT", 1, -1)
				ic:SetPoint("BOTTOMRIGHT", -1, 1)

				Aurora.CreateBD(bu)
			end
		end
		for i = 1, 2 do
			_G["PlayerSpecTab"..i.."Background"]:Hide()
			local tab = _G["PlayerSpecTab"..i]
			tab:SetCheckedTexture(Aurora.checked)
			local a1, p, a2, x, y = PlayerSpecTab1:GetPoint()
			local bg = CreateFrame("Frame", nil, tab)
			bg:SetPoint("TOPLEFT", -1, 1)
			bg:SetPoint("BOTTOMRIGHT", 1, -1)
			bg:SetFrameLevel(tab:GetFrameLevel()-1)
			hooksecurefunc("PlayerTalentFrame_UpdateTabs", function()
				PlayerSpecTab1:SetPoint(a1, p, a2, x + 11, y + 10)
				PlayerSpecTab2:SetPoint("TOP", PlayerSpecTab1, "BOTTOM")
			end)
			Aurora.CreateSD(tab, 5, 0, 0, 0, 1, 1)
			Aurora.CreateBD(bg, 1)
			select(2, tab:GetRegions()):SetTexCoord(.08, .92, .08, .92)
		end

		Aurora.ReskinClose(PlayerTalentFrameCloseButton)
	elseif addon == "Blizzard_TradeSkillUI" then
		Aurora.CreateBD(TradeSkillFrame)
		Aurora.CreateSD(TradeSkillFrame)
		Aurora.CreateBD(TradeSkillGuildFrame)
		Aurora.CreateSD(TradeSkillGuildFrame)
		Aurora.CreateBD(TradeSkillGuildFrameContainer, .25)

		TradeSkillFrame:DisableDrawLayer("BORDER")
		TradeSkillFrameInset:DisableDrawLayer("BORDER")
		TradeSkillFramePortrait:Hide()
		TradeSkillFramePortrait.Show = Aurora.dummy
		for i = 18, 20 do
			select(i, TradeSkillFrame:GetRegions()):Hide()
			select(i, TradeSkillFrame:GetRegions()).Show = Aurora.dummy
		end
		TradeSkillHorizontalBarLeft:Hide()
		select(22, TradeSkillFrame:GetRegions()):Hide()
		for i = 1, 3 do
			select(i, TradeSkillExpandButtonFrame:GetRegions()):Hide()
			select(i, TradeSkillFilterButton:GetRegions()):Hide()
		end
		for i = 1, 9 do
			select(i, TradeSkillGuildFrame:GetRegions()):Hide()
		end
		TradeSkillListScrollFrame:GetRegions():Hide()
		select(2, TradeSkillListScrollFrame:GetRegions()):Hide()
		TradeSkillDetailHeaderLeft:Hide()
		TradeSkillDetailScrollFrameTop:SetAlpha(0)
		TradeSkillDetailScrollFrameBottom:SetAlpha(0)
		TradeSkillFrameBg:Hide()
		TradeSkillFrameInsetBg:Hide()
		TradeSkillFrameTitleBg:Hide()
		TradeSkillFramePortraitFrame:Hide()
		TradeSkillFrameTopBorder:Hide()
		TradeSkillFrameTopRightCorner:Hide()
		TradeSkillCreateAllButton_RightSeparator:Hide()
		TradeSkillCreateButton_LeftSeparator:Hide()
		TradeSkillCancelButton_LeftSeparator:Hide()
		TradeSkillViewGuildCraftersButton_RightSeparator:Hide()
		TradeSkillGuildCraftersFrameTrack:Hide()
		TradeSkillRankFrameBorder:Hide()
		TradeSkillRankFrameBackground:Hide()

		TradeSkillDetailScrollFrame:SetHeight(176)

		local a1, p, a2, x, y = TradeSkillGuildFrame:GetPoint()
		TradeSkillGuildFrame:ClearAllPoints()
		TradeSkillGuildFrame:SetPoint(a1, p, a2, x + 16, y)

		TradeSkillLinkButton:SetPoint("LEFT", 0, -1)

		Aurora.Reskin(TradeSkillCreateButton)
		Aurora.Reskin(TradeSkillCreateAllButton)
		Aurora.Reskin(TradeSkillCancelButton)
		Aurora.Reskin(TradeSkillViewGuildCraftersButton)
		Aurora.Reskin(TradeSkillFilterButton)

		TradeSkillRankFrame:SetStatusBarTexture(Aurora.backdrop)

		local bg = CreateFrame("Frame", nil, TradeSkillRankFrame)
		bg:SetPoint("TOPLEFT", -1, 1)
		bg:SetPoint("BOTTOMRIGHT", 1, -1)
		bg:SetFrameLevel(TradeSkillRankFrame:GetFrameLevel()-1)
		Aurora.CreateBD(bg, .25)

		for i = 1, MAX_TRADE_SKILL_REAGENTS do
			local bu = _G["TradeSkillReagent"..i]
			local na = _G["TradeSkillReagent"..i.."NameFrame"]
			local ic = _G["TradeSkillReagent"..i.."IconTexture"]

			na:Hide()

			ic:SetTexCoord(.08, .92, .08, .92)

			local bg = CreateFrame("Frame", nil, bu)
			bg:SetPoint("TOPLEFT", ic, -1, 1)
			bg:SetPoint("BOTTOMRIGHT", ic, 1, -1)
			Aurora.CreateBD(bg, 0)

			local bd = CreateFrame("Frame", nil, bu)
			bd:SetPoint("TOPLEFT", na, 14, -24)
			bd:SetPoint("BOTTOMRIGHT", na, -53, 25)
			bd:SetFrameLevel(0)
			Aurora.CreateBD(bd, .25)

			_G["TradeSkillReagent"..i.."Name"]:SetParent(bd)
		end

		local reskinned = false
		hooksecurefunc("TradeSkillFrame_SetSelection", function()
			if not reskinned == true then
				local ic = select(2, TradeSkillSkillIcon:GetRegions())
				if ic then
					ic:SetTexCoord(.08, .92, .08, .92)
					ic:SetPoint("TOPLEFT", 1, -1)
					ic:SetPoint("BOTTOMRIGHT", -1, 1)
					Aurora.CreateBD(TradeSkillSkillIcon)
					reskinned = true
				end
			end
		end)

		TradeSkillIncrementButton:SetPoint("RIGHT", TradeSkillCreateButton, "LEFT", -9, 0)

		Aurora.ReskinClose(TradeSkillFrameCloseButton)
		Aurora.ReskinClose(TradeSkillGuildFrameCloseButton)
		Aurora.ReskinScroll(TradeSkillDetailScrollFrameScrollBar)
		Aurora.ReskinScroll(TradeSkillListScrollFrameScrollBar)
		Aurora.ReskinScroll(TradeSkillGuildCraftersFrameScrollBar)
		Aurora.ReskinInput(TradeSkillInputBox)
		Aurora.ReskinInput(TradeSkillFrameSearchBox)
		Aurora.ReskinArrow(TradeSkillDecrementButton, 1)
		Aurora.ReskinArrow(TradeSkillIncrementButton, 2)
		Aurora.ReskinArrow(TradeSkillLinkButton, 2)
	elseif addon == "Blizzard_TrainerUI" then
		Aurora.SetBD(ClassTrainerFrame)
		ClassTrainerFrame:DisableDrawLayer("BACKGROUND")
		ClassTrainerFrame:DisableDrawLayer("BORDER")
		ClassTrainerFrameInset:DisableDrawLayer("BORDER")
		ClassTrainerFrameBottomInset:DisableDrawLayer("BORDER")
		ClassTrainerFrameInsetBg:Hide()
		ClassTrainerFramePortrait:Hide()
		ClassTrainerFramePortraitFrame:Hide()
		ClassTrainerFrameTopBorder:Hide()
		ClassTrainerFrameTopRightCorner:Hide()
		ClassTrainerFrameBottomInsetBg:Hide()
		ClassTrainerTrainButton_LeftSeparator:Hide()

		ClassTrainerStatusBarSkillRank:ClearAllPoints()
		ClassTrainerStatusBarSkillRank:SetPoint("CENTER", ClassTrainerStatusBar, "CENTER", 0, 0)

		local bg = CreateFrame("Frame", nil, ClassTrainerFrameSkillStepButton)
		bg:SetPoint("TOPLEFT", 42, -2)
		bg:SetPoint("BOTTOMRIGHT", 0, 2)
		bg:SetFrameLevel(ClassTrainerFrameSkillStepButton:GetFrameLevel()-1)
		Aurora.CreateBD(bg, .25)

		ClassTrainerFrameSkillStepButton:SetHighlightTexture(nil)
		select(7, ClassTrainerFrameSkillStepButton:GetRegions()):SetAlpha(0)

		local check = select(4, ClassTrainerFrameSkillStepButton:GetRegions())
		check:SetPoint("TOPLEFT", 43, -3)
		check:SetPoint("BOTTOMRIGHT", -1, 3)
		check:SetTexture(Aurora.backdrop)
		check:SetVertexColor(r, g, b, .2)

		local icbg = CreateFrame("Frame", nil, ClassTrainerFrameSkillStepButton)
		icbg:SetPoint("TOPLEFT", ClassTrainerFrameSkillStepButtonIcon, -1, 1)
		icbg:SetPoint("BOTTOMRIGHT", ClassTrainerFrameSkillStepButtonIcon, 1, -1)
		Aurora.CreateBD(icbg, 0)

		ClassTrainerFrameSkillStepButtonIcon:SetTexCoord(.08, .92, .08, .92)

		for i = 1, CLASS_TRAINER_SKILLS_DISPLAYED do
			local bu = _G["ClassTrainerScrollFrameButton"..i]
			local ic = _G["ClassTrainerScrollFrameButton"..i.."Icon"]

			local bg = CreateFrame("Frame", nil, bu)
			bg:SetPoint("TOPLEFT", 42, -5)
			bg:SetPoint("BOTTOMRIGHT", 0, 6)
			bg:SetFrameLevel(bu:GetFrameLevel()-1)
			Aurora.CreateBD(bg, .25)

			_G["ClassTrainerScrollFrameButton"..i.."Name"]:SetParent(bg)
			_G["ClassTrainerScrollFrameButton"..i.."SubText"]:SetParent(bg)
			_G["ClassTrainerScrollFrameButton"..i.."MoneyFrame"]:SetParent(bg)
			bu:SetHighlightTexture(nil)
			select(4, bu:GetRegions()):SetAlpha(0)
			select(5, bu:GetRegions()):SetAlpha(0)

			local check = select(2, bu:GetRegions())
			check:SetPoint("TOPLEFT", 43, -6)
			check:SetPoint("BOTTOMRIGHT", -1, 7)
			check:SetTexture(Aurora.backdrop)
			check:SetVertexColor(r, g, b, .2)

			local icbg = CreateFrame("Frame", nil, bu)
			icbg:SetPoint("TOPLEFT", ic, -1, 1)
			icbg:SetPoint("BOTTOMRIGHT", ic, 1, -1)
			Aurora.CreateBD(icbg, 0)

			ic:SetTexCoord(.08, .92, .08, .92)
		end

		Aurora.Reskin(ClassTrainerTrainButton)

		Aurora.ReskinClose(ClassTrainerFrameCloseButton)
		Aurora.ReskinScroll(ClassTrainerScrollFrameScrollBar)
		Aurora.ReskinDropDown(ClassTrainerFrameFilterDropDown)
	elseif addon == "DBM-Core" then
		local first = true
		hooksecurefunc(DBM.RangeCheck, "Show", function()
			if first == true then
				DBMRangeCheck:SetBackdrop(nil)
				local bd = CreateFrame("Frame", nil, DBMRangeCheck)
				bd:SetPoint("TOPLEFT")
				bd:SetPoint("BOTTOMRIGHT")
				bd:SetFrameLevel(DBMRangeCheck:GetFrameLevel()-1)
				Aurora.CreateBD(bd)
				first = false
			end
		end)
	end
end)

-- [[ Mac Options ]]

if IsMacClient() then
	Aurora.CreateBD(MacOptionsFrame)
	MacOptionsFrameHeader:SetTexture("")
	MacOptionsFrameHeader:ClearAllPoints()
	MacOptionsFrameHeader:SetPoint("TOP", MacOptionsFrame, 0, 0)
 
	Aurora.CreateBD(MacOptionsFrameMovieRecording, .25)
	Aurora.CreateBD(MacOptionsITunesRemote, .25)

	Aurora.Reskin(MacOptionsButtonKeybindings)
	Aurora.Reskin(MacOptionsButtonCompress)
	Aurora.Reskin(MacOptionsFrameCancel)
	Aurora.Reskin(MacOptionsFrameOkay)
	Aurora.Reskin(MacOptionsFrameDefaults)

	Aurora.ReskinDropDown(MacOptionsFrameResolutionDropDown)
	Aurora.ReskinDropDown(MacOptionsFrameFramerateDropDown)
	Aurora.ReskinDropDown(MacOptionsFrameCodecDropDown)
	Aurora.ReskinCheck(MacOptionsFrameCheckButton1)
	Aurora.ReskinCheck(MacOptionsFrameCheckButton2)
	Aurora.ReskinCheck(MacOptionsFrameCheckButton3)
	Aurora.ReskinCheck(MacOptionsFrameCheckButton4)
	Aurora.ReskinCheck(MacOptionsFrameCheckButton5)
	Aurora.ReskinCheck(MacOptionsFrameCheckButton6)
	Aurora.ReskinCheck(MacOptionsFrameCheckButton7)
	Aurora.ReskinCheck(MacOptionsFrameCheckButton8)
 
	_G["MacOptionsButtonCompress"]:SetWidth(136)
 
	_G["MacOptionsFrameCancel"]:SetWidth(96)
	_G["MacOptionsFrameCancel"]:SetHeight(22)
	_G["MacOptionsFrameCancel"]:ClearAllPoints()
	_G["MacOptionsFrameCancel"]:SetPoint("LEFT", _G["MacOptionsButtonKeybindings"], "RIGHT", 107, 0)
 
	_G["MacOptionsFrameOkay"]:SetWidth(96)
	_G["MacOptionsFrameOkay"]:SetHeight(22)
	_G["MacOptionsFrameOkay"]:ClearAllPoints()
	_G["MacOptionsFrameOkay"]:SetPoint("LEFT", _G["MacOptionsButtonKeybindings"], "RIGHT", 5, 0)
 
	_G["MacOptionsButtonKeybindings"]:SetWidth(96)
	_G["MacOptionsButtonKeybindings"]:SetHeight(22)
	_G["MacOptionsButtonKeybindings"]:ClearAllPoints()
	_G["MacOptionsButtonKeybindings"]:SetPoint("LEFT", _G["MacOptionsFrameDefaults"], "RIGHT", 5, 0)
 
	_G["MacOptionsFrameDefaults"]:SetWidth(96)
	_G["MacOptionsFrameDefaults"]:SetHeight(22)
end