local MogIt, mog = ...
local L = mog.L

local TEXTURE = [[Interface\RaidFrame\ReadyCheck-Ready]]

--epsi func

local itemSlots = {
	["HEAD"] = 1,
	["SHOULDER"] = 3,
	["SHIRT"] = 4,
	["CHEST"] = 5,
	["WAIST"] = 6,
	["LEGS"] = 7,
	["FEET"] = 8,
	["WRIST"] = 9,
	["HANDS"] = 10,
	["BACK"] = 15,
	["MAINHAND"] = 16,
	["OFFHAND"] = 17,
	["RANGED"] = 18,
	["TABARD"] = 19,
};




function mog:GetItemLabel(itemID, callback, includeIcon, iconSize)
	local item = mog:GetItemInfo(itemID, callback)
	local name
	if item then
		name = format("|c%s%s|r", select(4, GetItemQualityColor(item.quality)), item.name)
	else
		name = RED_FONT_COLOR_CODE..RETRIEVING_ITEM_INFO..FONT_COLOR_CODE_CLOSE
	end
	if includeIcon then
		return format("|T%s:%d|t %s", GetItemIcon(itemID), iconSize, name)
	else
		return name
	end
end

local function addItemTooltipLine(itemID, slot, selected, wishlist, isSetItem)
	local texture = format("|T%s:0|t ", (selected and [[Interface\ChatFrame\ChatFrameExpandArrow]]) or (wishlist and [[Interface\TargetingFrame\UI-RaidTargetingIcon_1]]) or (mog:HasItem(itemID, isSetItem) and TEXTURE) or "")
	GameTooltip:AddDoubleLine(texture..(type(slot) == "string" and _G[strupper(slot)]..": " or "")..mog:GetItemLabel(itemID, "ModelOnEnter"), mog.GetItemSourceShort(itemID), nil, nil, nil, 1, 1, 1)
end

function mog.GetItemSourceInfo(itemID)
	local source, info;
	local sourceType = mog:GetData("item", itemID, "source");
	local sourceID = mog:GetData("item", itemID, "sourceid");
	local sourceInfo = mog:GetData("item", itemID, "sourceinfo");

	if sourceType == 1 and sourceID then -- Drop
		source = mog:GetData("npc", sourceID, "name");
	elseif sourceType == 3 and sourceID then -- Quest
		info = IsQuestFlaggedCompleted(sourceID) or false;
	elseif sourceType == 5 and sourceInfo then -- Crafted
		source = L.professions[sourceInfo];
	elseif sourceType == 6 and sourceID then -- Achievement
		local _, name, _, complete = GetAchievementInfo(sourceID);
		source = name;
		info = complete;
	end

	local zone = mog:GetData("item", itemID, "zone");
	if zone then
		zone = GetMapNameByID(zone);
		if zone then
			local diff = L.diffs[sourceInfo];
			if sourceType == 1 and diff then
				zone = format("%s (%s)", zone, diff);
			end
		end
	end

	return L.source[sourceType], source, zone, info;
end

function mog.GetItemSourceShort(itemID)
	local sourceType, source, zone, info = mog.GetItemSourceInfo(itemID);
	if zone then
		if source then
			sourceType = source;
		end
		source = zone;
		if sourceType == L.source[3] then
			source = format("%s (%s)", source, sourceType)
		end
	end
	return source or sourceType
end

-- create a new set and add the item to it
local function previewOnClick(self, previewFrame)
	mog:AddToPreview(self.value, mog:GetPreview(previewFrame))
	CloseDropDownMenus()
end

-- create a new set and add the item to it
local function newSetOnClick(self)
	StaticPopup_Show("MOGIT_WISHLIST_CREATE_SET", nil, nil, {items = {self.value}})
	CloseDropDownMenus()
end

local previewItem = {
	text = L["Preview"],
	menuList = function(self, level)
		local info = UIDropDownMenu_CreateInfo()
		info.text = L["Active preview"]
		info.value = UIDROPDOWNMENU_MENU_VALUE
		info.func = previewOnClick
		info.disabled = not mog.activePreview
		info.notCheckable = true
		info.arg1 = mog.activePreview
		UIDropDownMenu_AddButton(info, level)

		for i, preview in ipairs(mog.previews) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = format("%s %d", L["Preview"], preview:GetID())
			info.value = UIDROPDOWNMENU_MENU_VALUE
			info.func = previewOnClick
			info.notCheckable = true
			info.arg1 = preview
			UIDropDownMenu_AddButton(info, level)
		end

		local info = UIDropDownMenu_CreateInfo()
		info.text = L["New preview"]
		info.value = UIDROPDOWNMENU_MENU_VALUE
		info.func = previewOnClick
		info.notCheckable = true
		UIDropDownMenu_AddButton(info, level)
	end,
}

local itemOptions = {
	previewItem,
	{
		text = L["Add to wishlist"],
		func = function(self)
			mog.wishlist:AddItem(self.value)
			mog:BuildList()
			CloseDropDownMenus()
		end,
	},
	{
		text = L["Add to set"],
		hasArrow = true,
		menuList = function(self, level)
			local info = UIDropDownMenu_CreateInfo()
			info.text = L["New set..."]
			info.value = UIDROPDOWNMENU_MENU_VALUE
			info.func = newSetOnClick
			info.colorCode = GREEN_FONT_COLOR_CODE
			info.notCheckable = true
			UIDropDownMenu_AddButton(info, level)

			mog.wishlist:AddSetMenuItems(level, "addItem", UIDROPDOWNMENU_MENU_VALUE)
		end,
	},
	{
		wishlist = true,
		text = L["Delete"],
		func = function(self, set)
			if set.name then
				local slot = mog.wishlist:DeleteItem(self.value, set.name)
				if slot then
					set.frame.model:UndressSlot(GetInventorySlotInfo(slot))
				end
			else
				mog.wishlist:DeleteItem(self.value)
				mog:BuildList(nil, "Wishlist")
			end
			CloseDropDownMenus()
		end,
	},
	{
		text = L["|cff00ccffAdd to inventory|r"], --epsi edit
		func = function(self)
		--print("add "..self.value:gsub("item:", ""):gsub(":0", ""))
		local itemID = self.value:match("item:(%d*)");
		bonusID = self.value:match(":1:(%d*)")
		if itemID:match(":1:%d*") then
			
						--has bonus still
						--bonusID = itemID:gsub("%d*:", "")
					end
					if bonusID ~= nil then
						if not mog.db.profile.toggleMessages then
							print("|cff00ccff[MogIt]|r adding item: "..itemID.." with bonus: "..bonusID)
						end
						SendChatMessage(".additem "..itemID.." 1 "..bonusID, "GUILD")
					--SendChatMessage(".add "..itemID)
					else
						if not mog.db.profile.toggleMessages then
							print("|cff00ccff[MogIt]|r adding item: "..itemID)
						end
						SendChatMessage(".add "..itemID, "GUILD")
					end

		end,
	},
	{
		text = L["|cff00ccffLookup item|r"], --epsi edit
		func = function(self)
		--print("add "..self.value:gsub("item:", ""):gsub(":0", ""))
		local item = mog:GetItemInfo(self.value, callback)
		itemID = self.value:match("item:(%d*)");
		--print(self.value)
		if not mog.db.profile.toggleMessages then
			print("|cff00ccff[MogIt]|r looking up item: |cff00ccff|Hitem:"..itemID.."|h["..item.name.."]|r");
		end
		SendChatMessage(".lookup item "..item.name, "GUILD")

		end,
	},
}


function mog:AddItemOption(info)
	tinsert(itemOptions, info)
end

function mog:SetPreviewMenu(isSinglePreview)
	if isSinglePreview then
		previewItem.func = previewOnClick
		previewItem.hasArrow = nil
	else
		previewItem.func = nil
		previewItem.hasArrow = true
	end
end

local function addItemList(dropdown, data, func)
	local items = data.items
	local isArray = #items > 0

	for i, v in ipairs(isArray and items or mog.slots) do
		local item = isArray and v or items[v]
		if item then
			local info = UIDropDownMenu_CreateInfo()
			info.text = mog:GetItemLabel(item, func and "ItemMenu" or "SetMenu")
			info.value = item
			info.func = func
			info.checked = (i == data.cycle)
			info.hasArrow = true
			info.notCheckable = data.isSaved or data.name
			info.arg1 = data
			info.arg2 = i
			info.menuList = itemOptions
			dropdown:AddButton(info)
		end
	end
end

local function createMenu(self, level, menuList)
	local data = self.data
	if type(menuList) == "function" then
		menuList(self, level)
	else
		for i, info in ipairs(menuList) do
			if type(info) == "function" then
				info(self, level, data)
			elseif (info.wishlist == nil or info.wishlist == data.isSaved) and (not info.set or data.items) then
				info.value = UIDROPDOWNMENU_MENU_VALUE
				info.notCheckable = true
				info.arg1 = data
				self:AddButton(info, level)
			end
		end
	end
end

local function showMenu(menu, data, isSaved, isPreview)
	if menu:IsShown() and menu.data ~= data then
		HideDropDownMenu(1)
	end
	-- needs to be either true or false
	data.isSaved = (isSaved ~= nil)
	data.isPreview = isPreview
	menu.data = data
	menu:Toggle(data.item, "cursor")
end

do	-- item functions
	local slots = {
		[1] = "MainHandSlot",
		-- [2] = "mainhand",
		-- [3] = "offhand",
	}

	local sourceLabels = {
		[L.source[1]] = BOSS,
	}

	GameTooltip:RegisterEvent("MODIFIER_STATE_CHANGED")
	GameTooltip:HookScript("OnEvent", function(self, event, key, state)
		local owner = self:GetOwner()
		if owner and self[mog] then
			owner:OnEnter()
		end
	end)
	GameTooltip:HookScript("OnTooltipCleared", function(self)
		self[mog] = nil
	end)

	function mog.Item_FrameUpdate(self, data)
		local item = data.item
		self:ApplyDress()
		self:TryOn(format(gsub(item, "item:(%d+):0", "item:%1:%%d"), mog.weaponEnchant), slots[mog:GetData("item", item, "slot")])
		if not mog:GetItemInfo(item) then
			mog.doModelUpdate = true;
		end
	end

	function mog.Item_OnClick(self, button, data, isSaved, isPreview)
		local item = data.item
		if not (self and item) then return end

		if button == "LeftButton" then
			if not HandleModifiedItemClick(select(2, GetItemInfo(item))) and data.items then
				if IsAltKeyDown() then -- Handling Alt+Left Click to Additem to inventory (EPSILON)
					SendChatMessage(".additem " ..mog:ToNumberItem(item));
				else
					data.cycle = (data.cycle % #data.items) + 1
					data.item = data.items[data.cycle]
					self:OnEnter()
				end
			end
		end
		if button == "RightButton" then
			if IsControlKeyDown() then
				mog:AddToPreview(item)
			elseif IsShiftKeyDown() then
				mog:ShowURL(item, "item")
			elseif IsAltKeyDown() then -- Handling Alt+Right Click to Additem to inventory (EPSILON)
				SendChatMessage(".additem " ..mog:ToNumberItem(item));
			else
				showMenu(mog.Item_Menu, data, isSaved, isPreview)
			end
		end
	end

	function mog.ShowItemTooltip(self, item, items)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip[mog] = true

		if IsShiftKeyDown() then
			if type(item) == "number" then
				GameTooltip:SetItemByID(item)
			else
				GameTooltip:SetHyperlink(item)
			end
			for _, frame in pairs(GameTooltip.shoppingTooltips) do
				frame:Hide()
			end
			return
		end

		local itemInfo = mog:GetItemInfo(item, "ModelOnEnter")
		local itemLevel = itemInfo and itemInfo.itemLevel
		GameTooltip:AddLine(mog:GetItemLabel(item, "ModelOnEnter"))

		local sourceType, source, zone, info = mog.GetItemSourceInfo(item)
		if sourceType then
			GameTooltip:AddLine(L["Source"]..": |cffffffff"..sourceType)
			if source then
				GameTooltip:AddLine((sourceLabels[sourceType] or sourceType)..": |cffffffff"..source)
			end
			if info ~= nil then
				GameTooltip:AddLine(STATUS..": |cffffffff"..(info and COMPLETE or INCOMPLETE))
			end
		end
		if zone then
			GameTooltip:AddLine(ZONE..": |cffffffff"..zone)
		end

		GameTooltip:AddLine(" ")
		local bindType = mog:GetData("item", item, "bind")
		if bindType then
			GameTooltip:AddLine(L.bind[bindType], 1.0, 1.0, 1.0)
		end
		local requiredLevel = mog:GetData("item", item, "level")
		if requiredLevel then
			GameTooltip:AddLine(L["Required Level"]..": |cffffffff"..requiredLevel)
		end
		GameTooltip:AddLine(STAT_AVERAGE_ITEM_LEVEL..": |cffffffff"..(itemLevel or "??"))
		local faction = mog:GetData("item", item, "faction")
		if faction then
			GameTooltip:AddLine(FACTION..": |cffffffff"..(faction == 1 and FACTION_ALLIANCE or FACTION_HORDE))
		end
		local class = mog:GetData("item", item, "class")
		if class and class > 0 then
			local str
			for k, v in pairs(L.classBits) do
				if bit.band(class, v) > 0 then
					local color = RAID_CLASS_COLORS[k].colorStr
					if str then
						str = format("%s, |c%s%s|r", str, color, LOCALIZED_CLASS_NAMES_MALE[k])
					else
						str = format("|c%s%s|r", color, LOCALIZED_CLASS_NAMES_MALE[k])
					end
				end
			end
			GameTooltip:AddLine(CLASS..": "..str)
		end
		local slot = mog:GetData("item", item, "slot")
		if slot then
			GameTooltip:AddLine(L["Slot"]..": |cffffffff"..L.slots[slot])
		end

		if mog.db.profile.tooltipItemID then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["Item ID"]..": |cffffffff"..mog:ToNumberItem(item))
		end

		local hasItem, characters = mog:HasItem(item)
		if hasItem then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(format("|T%s:0|t ", TEXTURE)..L["You have this item."], 1, 1, 1)
			if mog.db.profile.tooltipOwnedDetail and characters then
				for i, character in ipairs(characters) do
					GameTooltip:AddLine("|T:0|t "..character)
				end
			end
		end

		local found, profiles = mog.wishlist:IsItemInWishlist(item)
		if (not mog.active or mog.active.name ~= "Wishlist") and found then
			if not hasItem then
				GameTooltip:AddLine(" ")
			end
			GameTooltip:AddLine("|TInterface\\PetBattles\\PetJournal:0:0:0:0:512:1024:62:78:26:42:255:255:255|t "..L["This item is on your wishlist."], 1, 1, 1)
			if mog.db.profile.tooltipWishlistDetail and profiles then
				for i, character in ipairs(profiles) do
					GameTooltip:AddLine("|T:0|t "..character)
				end
			end
		end

		if items and #items > 1 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["Items using this appearance:"])
			for i, v in ipairs(items) do
				addItemTooltipLine(v, nil, v == item, (mog.wishlist:IsItemInWishlist(v)))
			end
		end

		GameTooltip:Show()
	end

	local function itemOnClick(self, data, index)
		data.cycle = index
		data.item = data.items[index]
	end

	mog.Item_Menu = mog:CreateDropdown("Menu")
	mog.Item_Menu.initialize = function(self, level, menuList)
		local data = self.data

		local items = data.items
		-- not listing the items if there's only 1 and it's not a set
		if level == 1 and (items and not (data.item and #items == 1)) then
			addItemList(self, data, itemOnClick)
		else
			createMenu(self, level, menuList or itemOptions)
		end
	end
end

do	-- set functions
	function mog.Set_FrameUpdate(self, data)
		self:ShowIndicator("label")
		self:SetText(data.name)
		self:Undress()
		local hasSet = next(data.items)
		for slot, item in pairs(data.items) do
			self:TryOn(item, slot == "SecondaryHandSlot" and slot)
			if not mog:HasItem(item, true) then
				hasSet = false
			end
			if not mog:GetItemInfo(item) then
				mog.doModelUpdate = true;
			end
		end
		if hasSet then
			self:ShowIndicator("hasItem")
		end
	end

	function mog.Set_OnClick(self, button, data, isSaved)
		if button == "LeftButton" then
			if IsShiftKeyDown() then
				ChatEdit_InsertLink(mog:SetToLink(data.items))
			elseif IsControlKeyDown() then
				if mog.db.profile.dressupPreview then
					mog:AddToPreview(data.items, mog:GetPreview(), data.name)
				else
					if not DressUpFrame:IsShown() or DressUpFrame.mode ~= "player" then
						DressUpFrame.mode = "player"
						DressUpFrame.ResetButton:Show()

						local race, fileName = UnitRace("player")
						SetDressUpBackground(DressUpFrame, fileName)

						ShowUIPanel(DressUpFrame)
						DressUpModel:SetUnit("player")
					end
					DressUpModel:Undress()
					for k, v in pairs(data.items) do
						DressUpItemLink(v)
					end
				end
			end
		end
		if button == "RightButton" then
			if IsShiftKeyDown() then
				if data.set then
					mog:ShowURL(data.set, "set")
				else
					mog:ShowURL(data.items, "compare")
				end
			elseif IsControlKeyDown() then
				mog:AddToPreview(data.items, mog:GetPreview(), data.name)
			else
				showMenu(mog.Set_Menu, data, isSaved)
			end
		end
	end
	--EPSI EQUIP FUNCS

	local function getBagPos(itemID, bonusID)
		--CHECK SLOTS
		local matchItem = 0;
	
		for k,v in pairs(itemSlots) do
			if GetInventoryItemID("player", v) ~= nil then
			eItem = tostring(GetInventoryItemID("player", v));
	
	
				if eItem == itemID then
					matchItem = 1;
				else
				end
			end
		end

		for bag = 0, NUM_BAG_SLOTS do
	
			for slot = 1, GetContainerNumSlots(bag) do
				local invItem = GetContainerItemLink(bag,slot);
				if invItem ~= nil and itemID ~= 0 then
					
					if invItem:match(itemID) then
						
						--equip item and set item exist flag to 1
						
						matchItem = 1;
	
					end
					
				else
				
				
				end
			end
	
		end
		--print(matchItem)
		if matchItem == 0 and itemID ~= 0 then
			
			SendChatMessage(".additem "..itemID.." 1 "..bonusID, "GUILD");
			
		end
	
	end

	local function equipItem(itemID)
		if itemID ~= 0 then
			C_Timer.NewTicker(1.5, function(self)
				if not mog.db.profile.toggleMessages then
					print("|cff00ccff[MogIt]|r equipping item: "..itemID)
				end
				EquipItemByName(itemID);
				EquipPendingItem(0);
			end, 1)
		end
	end

	local function equipWishlistItems(set,items)
		--unequip everything first
		for k,v in pairs(itemSlots) do
			PickupInventoryItem(v);
			PutItemInBackpack();
		end

		--second check if items are in backpack
		for k,v in pairs(items) do
			local item = 0;
			local itemBonus = 0;
			if v ~= nil then
				item, itemBonus = v:match("item%:(%d*)%:(%d*)");
				--print(item,itemBonus)
			end
			if item ~= nil then
				getBagPos(item, itemBonus);
				equipItem(item);
				--getbagPosFunc
				--equipItemFunc
			end
		end
	end

	function mog.ShowSetTooltip(self, items, name)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip[mog] = true

		GameTooltip:AddLine(name)
		for i, slot in ipairs(mog.slots) do
			local item = items[slot] or items[i]
			if item then
				addItemTooltipLine(item, nil, nil, nil, true)
			end
		end
		GameTooltip:Show()
	end

	local setOptions = {
		{
			wishlist = false,
			text = L["Add set to wishlist"],
			func = function(self, set, items)
				if mog.wishlist:CreateSet(set) then
					for i, item in pairs(items) do
						mog.wishlist:AddItem(item, set)
					end
				end
			end,
		},
		{
			wishlist = true,
			text = L["|cff00ccffEquip Set|r"],
			func = function(self,set,items)

					equipWishlistItems(set,items);
				
				--print(items)
			end,
		},
		{
			wishlist = true,
			text = L["Rename set"],
			func = function(self, set)
				mog.wishlist:RenameSet(set)
			end,
		},
		{
			wishlist = true,
			text = L["Delete set"],
			func = function(self, set)
				mog.wishlist:DeleteSet(set)
			end,
		},
	}

	function mog:AddSetOption(info)
		tinsert(setOptions, info)
	end

	mog.Set_Menu = mog:CreateDropdown("Menu")
	mog.Set_Menu.initialize = function(self, level, menuList)
		if level == 1 then
			local data = self.data
			addItemList(self, data)
			for i, info in ipairs(setOptions) do
				if info.wishlist == nil or info.wishlist == data.isSaved then
					info.value = data.name
					info.notCheckable = true
					info.arg1 = data.name
					info.arg2 = data.items
					self:AddButton(info, level)
				end
			end
		else
			createMenu(self, level, menuList)
		end
	end
end


--epsi functions


