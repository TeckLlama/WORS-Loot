-- Create the main frame
local WORS_Loot = CreateFrame("Frame", "WORS_Loot", UIParent)



WORS_Loot:SetSize(550, 450)
WORS_Loot:SetPoint("CENTER")
WORS_Loot:SetBackdrop({	
	bgFile = "Interface\\WORS\\OldSchoolBackground2",
    edgeFile = "Interface\\WORS\\OldSchool-Dialog-Border",
    tile = false, tileSize = 32, edgeSize = 32,
    insets = { left = 5, right = 6, top = 6, bottom = 5 }
})
--WORS_Loot:SetBackdropColor(0, 0, 0, 1)

WORS_Loot:Hide()
print("WORS Loot main frame created.")

-- Title
local title = WORS_Loot:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -10)
title:SetText("WORS Loot")

-- Dropdowns
local moduleDropdown = CreateFrame("Frame", "WORS_Loot_ModuleDropdown", WORS_Loot, "UIDropDownMenuTemplate")
moduleDropdown:SetPoint("TOPLEFT", WORS_Loot, "TOPLEFT", 20, -30)
UIDropDownMenu_SetWidth(moduleDropdown, 130)
print("Module dropdown created.")

local subcategoryDropdown = CreateFrame("Frame", "WORS_Loot_SubcategoryDropdown", WORS_Loot, "UIDropDownMenuTemplate")
subcategoryDropdown:SetPoint("TOPLEFT", moduleDropdown, "TOPLEFT", 160, 0)
UIDropDownMenu_SetWidth(subcategoryDropdown, 130)
print("Subcategory dropdown created.")

local thirdDropdown = CreateFrame("Frame", "WORS_Loot_ThirdDropdown", WORS_Loot, "UIDropDownMenuTemplate")
thirdDropdown:SetPoint("TOPLEFT", subcategoryDropdown, "TOPLEFT", 160, 0)
UIDropDownMenu_SetWidth(thirdDropdown, 130)
print("Third dropdown created.")


-- Loot Table Frame
local lootTableFrame = CreateFrame("ScrollFrame", "WORS_Loot_LootTable", WORS_Loot, "UIPanelScrollFrameTemplate")
lootTableFrame:SetSize(440, 350)
lootTableFrame:SetPoint("TOPLEFT", moduleDropdown, "BOTTOMLEFT", 20, -20)
lootTableFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
lootTableFrame:SetBackdropColor(0, 0, 0, 0)
lootTableFrame:SetBackdropBorderColor(0, 0, 0, 0)
local lootContent = CreateFrame("Frame", nil, lootTableFrame)
lootContent:SetSize(225, 1)
lootTableFrame:SetScrollChild(lootContent)
local lootItems = {}
local buttonHeight = 40
local buttonSpacing = 5

-- Create clickable item link with icon using item ID
local buttonHeight = 40
local buttonSpacing = 5
local function CreateLootButton(itemId, index)
    print("Creating loot button for item ID:", itemId)
    if not itemId then
        print("Error: Missing item ID.")
        return nil
    end
    local lootButton = CreateFrame("Button", nil, lootContent)
    lootButton:SetSize(220, buttonHeight)
    -- Calculate row and column based on the index
    local column = (index - 1) % 2  -- 0 for first column, 1 for second column
    local row = math.floor((index - 1) / 2)  -- Calculate the row number
    lootButton:SetPoint("TOPLEFT", lootContent, "TOPLEFT", 10 + column * (220 + 10), -(row * (buttonHeight + buttonSpacing)))
    local itemIcon = lootButton:CreateTexture(nil, "ARTWORK")
    itemIcon:SetSize(40, 40)
    itemIcon:SetPoint("LEFT", lootButton, "LEFT", 5, 0)
    itemIcon:SetTexture(GetItemIcon(itemId) or "Interface/Icons/INV_Misc_QuestionMark")
    lootButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        local itemLink = GetItemLink(itemId)
        if itemLink then
            GameTooltip:SetHyperlink(itemLink)
            GameTooltip:Show()
        else
            print("Error: Item link not found for item ID " .. itemId)
        end
    end)
    lootButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    local itemName = lootButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    itemName:SetPoint("LEFT", itemIcon, "RIGHT", 5, 0)
    itemName:SetFont("Fonts\\runescape.ttf", 20)  -- Set custom font and size
    -- Attempt to fetch the item name using the cached method
    local itemInfo = {GetItemInfo(itemId)}
    if itemInfo[1] then
        itemName:SetText(itemInfo[1])  -- Use the name if found
    else
        -- Fallback method: Use item ID to create a hyperlink format
        local itemLink = format("|cffff8000|Hitem:%d:0:0:0:0:0:0:0|h[%d]|h|r", itemId, itemId)        
        itemName:SetText(itemLink)  -- Display the raw hyperlink format
        itemName:SetTextColor(1, 1, 0)  -- Yellow color for unknown items
        -- Using GetTime for a simple timeout mechanism
        local loadingStartTime = GetTime()
        lootButton:SetScript("OnUpdate", function(self)
            if (GetTime() - loadingStartTime) > 120 then
                itemName:SetText("Unknown Item")  -- Change to a default state after timeout
                lootButton:SetScript("OnUpdate", nil)  -- Stop the update script
            else
                -- Try to fetch the item info again to see if it has been cached now
                itemInfo = {GetItemInfo(itemId)}
                if itemInfo[1] then
                    itemName:SetText(itemInfo[1])  -- Update the name if it has now been found
                    itemName:SetTextColor(1, 1, 1)  -- Reset color to white
                    lootButton:SetScript("OnUpdate", nil)  -- Stop the update script
                end
            end
        end)
    end
    lootButton:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight", "ADD")
    lootButton:SetPushedTextOffset(0, -1)
    lootButton:SetScript("OnClick", function(self, button)
        local itemLink = GetItemLink(itemId)
        if itemLink then
            if ChatFrame1.editBox:IsVisible() then
                local currentChatText = ChatFrame1.editBox:GetText()
                ChatFrame1.editBox:SetText(currentChatText .. " " .. itemLink)
                ChatFrame1.editBox:SetCursorPosition(#currentChatText + #itemLink + 1)
                ChatFrame1.editBox:SetFocus()
            else
                ItemRefTooltip:SetOwner(self, "ANCHOR_RIGHT")
                ItemRefTooltip:SetHyperlink(itemLink)
                ItemRefTooltip:Show()
            end
        else
            -- Also try to generate the link from the itemId if the itemLink isn't found
            local fallbackItemLink = format("|cffff8000|Hitem:%d:0:0:0:0:0:0:0|h[%d]|h|r", itemId, itemId)        
            -- Show the fallback item tooltip directly
            ItemRefTooltip:SetOwner(self, "ANCHOR_RIGHT")
            ItemRefTooltip:SetHyperlink(fallbackItemLink)
            ItemRefTooltip:Show()
        end
    end)
    lootButton:Show()
    return lootButton
end

-- Clear Loot Content
local function ClearLootContent()
    print("Clearing loot content...")
    for _, item in ipairs(lootItems) do
        -- Cancel the loading timeout if it exists
        if item.loadingTimeout then
            item.loadingTimeout:Cancel()
            item.loadingTimeout = nil  -- Clean up the reference
        end
        item:Hide()
        item:ClearAllPoints()
    end
    wipe(lootItems)
end

-- Update Loot Table based on selection
local function UpdateLootTable(selectedMaster, selectedTask)
    print("Updating loot table for Master:", selectedMaster, "Task:", selectedTask)
    ClearLootContent()
    local lootEntries
    if selectedMaster and selectedTask then
        lootEntries = WORS_Loot_Slayer_Data[selectedMaster][selectedTask]
    elseif selectedTask then
        lootEntries = WORS_Loot_Boss_Data[selectedTask]
    end
    if lootEntries then
        for i, itemId in ipairs(lootEntries) do
            local lootButton = CreateLootButton(itemId, i)
            if lootButton then
                lootButton:SetParent(lootContent)
                table.insert(lootItems, lootButton)
            end
        end
    else
        print("No loot entries found for selected master/task.")
    end
end

-- Update Subcategory for Slayer
local function UpdateSlayerTasks(selectedMaster)
    print("Updating Slayer tasks for Master:", selectedMaster)
    UIDropDownMenu_ClearAll(thirdDropdown)
    UIDropDownMenu_SetText(thirdDropdown, WORS_Loot_Slayer_Data.subcategoryTwoText)
    local tasks = WORS_Loot_Slayer_Data[selectedMaster]
    UIDropDownMenu_Initialize(thirdDropdown, function(self, level)
        for task, _ in pairs(tasks) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = task
            info.func = function()
                UIDropDownMenu_SetText(thirdDropdown, task)
                UpdateLootTable(selectedMaster, task)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
end



-- Update Subcategory Dropdown
local function UpdateSubcategoryDropdown(selectedModule)
    print("Updating subcategory dropdown for module:", selectedModule)
    UIDropDownMenu_ClearAll(subcategoryDropdown)
    UIDropDownMenu_ClearAll(thirdDropdown)
    UIDropDownMenu_SetText(thirdDropdown, "")
    
	--ClearLootContent() -- Clear previous loot items
	
	-- one SubCatogry
    if selectedModule == "Bosses" then
        UIDropDownMenu_SetText(subcategoryDropdown, WORS_Loot_Boss_Data.subcategoryOneText)
        -- Retrieve bosses from the data file
        local bosses = WORS_Loot_Boss_Data.bosses or {}
        UIDropDownMenu_Initialize(subcategoryDropdown, function(self, level)
            for _, boss in ipairs(bosses) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = boss
                info.func = function()
                    UIDropDownMenu_SetText(subcategoryDropdown, boss)
                    UpdateLootTable(nil, boss)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
		thirdDropdown:Hide()
	
	-- two SubCatogry
    elseif selectedModule == "Slayer" then
        UIDropDownMenu_SetText(subcategoryDropdown, WORS_Loot_Slayer_Data.subcategoryOneText)
        -- Retrieve masters from the data file
        local masters = WORS_Loot_Slayer_Data.masters or {}
        UIDropDownMenu_Initialize(subcategoryDropdown, function(self, level)
            for _, master in ipairs(masters) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = master
                info.func = function()
                    UIDropDownMenu_SetText(subcategoryDropdown, master)
                    UpdateSlayerTasks(master)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
		thirdDropdown:Show()
    
	
	-- two SubCatogry
    elseif selectedModule == "Skills" then
        UIDropDownMenu_SetText(subcategoryDropdown, WORS_Loot_Skill_Data.subcategoryOneText)
        -- Retrieve masters from the data file
        local masters = WORS_Loot_Skill_Data.masters or {}
        UIDropDownMenu_Initialize(subcategoryDropdown, function(self, level)
            for _, master in ipairs(masters) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = master
                info.func = function()
                    UIDropDownMenu_SetText(subcategoryDropdown, master)
                    UpdateSlayerTasks(master)
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
		thirdDropdown:Show()
    end
end
	

-- Module Dropdown Logic
UIDropDownMenu_Initialize(moduleDropdown, function(self, level)
    local modules = {"Bosses", "Slayer", "Skills"}
    for _, module in ipairs(modules) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = module
        info.func = function()
            UIDropDownMenu_SetText(moduleDropdown, module)
            UpdateSubcategoryDropdown(module)
        end
        UIDropDownMenu_AddButton(info)
    end
end)

-- Toggle Command for Frame Visibility
SLASH_WORS_LOOT1 = "/worsloot"
SlashCmdList["WORS_LOOT"] = function()
    if WORS_Loot:IsVisible() then
        WORS_Loot:Hide()
    else
        WORS_Loot:Show()
    end
end

-- Minimap Icon for WORS_Loot using LibDBIcon and Ace3
local addon = LibStub("AceAddon-3.0"):NewAddon("WORS_Loot")
WORSLootMinimapButton = LibStub("LibDBIcon-1.0", true)
local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("WORS_Loot", {
	type = "data source",
	text = "WORS Loot",
	icon = "Interface\\Icons\\INV_Misc_Bag_CoreFelclothBag",
	OnClick = function(self, btn)
        if btn == "LeftButton" then
            if WORS_Loot:IsShown() then
                WORS_Loot:Hide()
            else
                WORS_Loot:Show()
            end
        elseif btn == "RightButton" then
            --if settingsFrame and settingsFrame:IsShown() then
            --    settingsFrame:Hide()
            --elseif settingsFrame then
            --    settingsFrame:Show()
            --end
			if WORS_Loot:IsShown() then
                WORS_Loot:Hide()
            else
                WORS_Loot:Show()
            end
        end
	end,
	OnTooltipShow = function(tooltip)
		if not tooltip or not tooltip.AddLine then
			return
		end
		tooltip:AddLine("WORS Loot\n\nLeft-click: Toggle WORS Loot Window", nil, nil, nil, nil)
		tooltip:AddLine("Right-click: N/A Placeholder", nil, nil, nil, nil)
	end,
})
function addon:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("WORSLootMinimapDB", {
		profile = {
			minimap = {
				hide = false,
			},
		},
	})
	WORSLootMinimapButton:Register("WORS_Loot", miniButton, self.db.profile.minimap)
end
WORSLootMinimapButton:Show("WORS_Loot")
print("WORS Loot addon loaded.")