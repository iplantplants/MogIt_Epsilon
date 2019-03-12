--?

local MogIt_Epsilon_Cloth,mec = ...;
local mog = MogIt;

local module = mog:RegisterModule(MogIt_Epsilon_Cloth, tonumber(GetAddOnMetadata(MogIt_Epsilon_Cloth, "X-MogItModuleVersion")));


	function mec.AddSlot(itemID, bonusID, display, quality, lvl, faction, class, bind, slot, source, sourceid, zone, sourceinfo)
		local id = mog:ToStringItem(itemID, bonusID);
		tinsert(list, id);
		mog:AddData("item", id, "display", display);
		mog:AddData("item", id, "quality", quality);
		mog:AddData("item", id, "level", lvl);
		mog:AddData("item", id, "faction", faction);
		mog:AddData("item", id, "class", class);
		mog:AddData("item", id, "bind", bind);
		mog:AddData("item", id, "slot", slot);
		mog:AddData("item", id, "source", source);
		mog:AddData("item", id, "sourceid", sourceid);
		mog:AddData("item", id, "sourceinfo", sourceinfo);
		mog:AddData("item", id, "zone", zone);
		tinsert(mog:GetData("display", display, "items") or mog:AddData("display", display, "items", {}), id);
	end

-- function mec.AddSlot(slot, addon)
	-- local module = mog:GetModule(addon);
	-- if not module.slots[slot] then
		-- module.slots[slot] = {
			-- label = LBI[slot] or slot,
			-- list = {},
		-- };
		-- tinsert(module.slotList, slot);
	-- end
	-- local list = module.slots[slot].list;
	
	-- return function(itemID, bonusID, display, quality, lvl, faction, class, bind, slot, source, sourceid, zone, sourceinfo)
		-- local id = mog:ToStringItem(itemID, bonusID);
		-- tinsert(list, id);
		-- mog:AddData("item", id, "display", display);
		-- mog:AddData("item", id, "quality", quality);
		-- mog:AddData("item", id, "level", lvl);
		-- mog:AddData("item", id, "faction", faction);
		-- mog:AddData("item", id, "class", class);
		-- mog:AddData("item", id, "bind", bind);
		-- mog:AddData("item", id, "slot", slot);
		-- mog:AddData("item", id, "source", source);
		-- mog:AddData("item", id, "sourceid", sourceid);
		-- mog:AddData("item", id, "sourceinfo", sourceinfo);
		-- mog:AddData("item", id, "zone", zone);
		-- tinsert(mog:GetData("display", display, "items") or mog:AddData("display", display, "items", {}), id);
	-- end
-- end


-- function module.Dropdown(module,tier)
	-- local info;
	-- if tier == 1 then
		-- info = UIDropDownMenu_CreateInfo();
		-- info.text = module.label;
		-- info.value = module;
		-- info.colorCode = "\124cFF00FF00";
		-- info.hasArrow = true;
		-- info.keepShownOnClick = true;
		-- info.notCheckable = true;
		-- UIDropDownMenu_AddButton(info,tier);
	-- elseif tier == 2 then
		-- for k,v in ipairs(sets) do
			-- info = UIDropDownMenu_CreateInfo();
			-- info.text = v.label;
			-- info.value = v;
			-- info.notCheckable = true;
			-- info.func = DropdownTier2;
			-- info.arg1 = module;
			-- UIDropDownMenu_AddButton(info,tier);
		-- end
	-- end
-- end

function module.FrameUpdate(module,self,value)
	self.data.items = {};
	for k,v in ipairs(data.items[value]) do
		tinsert(self.data.items,v);
	end
	if extra and data.extras[value] then
		for k,v in ipairs(data.extras[value]) do
			tinsert(self.data.items,v);
		end
	end
	self.data.name = data.name[value];
	self.data.main = data.items[value];
	self.data.extras = data.extras[value];
	self.data.alts = data.alts[value];
	mog.Set_FrameUpdate(self,self.data);
end

function module.OnEnter(module,self,value)
	--mog.Set_OnEnter(self,self.data);
	if not (self and self.data and self.data.main) then return end;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip[mog] = true;
	
	GameTooltip:AddLine(self.data.name);
	for k,v in ipairs(self.data.main) do
		GameTooltip:AddDoubleLine(mog:GetItemLabel(v, "ModelOnEnter", true, 18),"ID: "..v,nil,nil,nil,1,1,1);
	end
	
	if self.data.extras then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine("Extra Items");
		for k,v in ipairs(self.data.extras) do
			local item = mog:GetItemInfo(v, "ModelOnEnter");
			GameTooltip:AddDoubleLine(mog:GetItemLabel(v, "ModelOnEnter", true, 18),"ID: "..v,nil,nil,nil,1,1,1);
		end
	end
	
	if self.data.alts then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine("Alternative Items");
		for k,v in ipairs(self.data.alts) do
			local item = mog:GetItemInfo(v, "ModelOnEnter");
			GameTooltip:AddDoubleLine(mog:GetItemLabel(v, "ModelOnEnter", true, 18),"ID: "..v,nil,nil,nil,1,1,1);
		end
	end
	
	if data.favs[self.data.name] then
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine("\124TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:16\124t One of Lull's favourites!",1,1,1);
	end
	
	GameTooltip:Show();
end

