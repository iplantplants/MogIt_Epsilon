local MogIt,mog = ...;
local L = mog.L;

local function dropdownTier1(self)
	mog:SortList("alphabetical");
end

local function nameSort(a, b)


    item1 = mog:GetItemInfo(a[1])
    item2 = mog:GetItemInfo(b[1])
    
    if item1 ~= nil and item2 ~= nil then
        return item1.name < item2.name;
    end



end

mog:CreateSort("alphabetical",{
	label = L["Alphabetical"],
	Dropdown = function(dropdown,module,tier)
		local info = UIDropDownMenu_CreateInfo();
		info.text = L["|cff00ccffAlphabetical|r"];
		info.value = "alphabetical";
		info.func = dropdownTier1;
		info.checked = mog.sorting.active == "alphabetical";
		dropdown:AddButton(info,tier);
	end,
	Sort = function(args)
		table.sort(mog.list, nameSort);
	end,
});