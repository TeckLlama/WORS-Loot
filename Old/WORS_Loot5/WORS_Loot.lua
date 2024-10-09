-- Create the main frame
local WORS_Loot = CreateFrame("Frame", "WORS_Loot", UIParent)
WORS_Loot:SetSize(550, 450)
WORS_Loot:SetPoint("CENTER")
WORS_Loot:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
WORS_Loot:SetBackdropColor(0, 0, 0, 1)
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
lootTableFrame:SetSize(225, 300)  -- Set a fixed size for the scroll frame
lootTableFrame:SetPoint("TOPLEFT", moduleDropdown, "BOTTOMLEFT", 20, -20)

lootTableFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
-- Set the background color to opaque and border color to transparent
lootTableFrame:SetBackdropColor(0, 0, 0, 0)  -- Opaque background
lootTableFrame:SetBackdropBorderColor(0, 0, 0, 0)  -- Fully transparent border

local lootContent = CreateFrame("Frame", nil, lootTableFrame)
lootContent:SetSize(225, 1)  -- Start with a height of 1 to avoid initial clipping
lootTableFrame:SetScrollChild(lootContent)

local lootItems = {}

-- Clear Loot Content
local function ClearLootContent()
    print("Clearing loot content...")
    for _, item in ipairs(lootItems) do
        item:Hide()
        item:ClearAllPoints()  -- Clear position to reset
    end
    wipe(lootItems)
end

local buttonHeight = 40  -- Adjusted button height
local buttonSpacing = 5   -- Space between buttons

-- Create clickable item link with icon using item ID
local function CreateLootButton(itemId, index)
    print("Creating loot button for item ID:", itemId)
    if not itemId or not GetItemIcon or not GetItemInfo then
        print("Error: Missing item ID or required functions.")
        return nil
    end

    local lootButton = CreateFrame("Button", nil, lootContent)
    lootButton:SetSize(200, buttonHeight)

    -- Adjusted position calculation
    lootButton:SetPoint("TOPLEFT", lootContent, "TOPLEFT", 10, -(index - 1) * (buttonHeight + buttonSpacing))

    local itemIcon = lootButton:CreateTexture(nil, "ARTWORK")
    itemIcon:SetSize(40, 40)
    itemIcon:SetPoint("LEFT", lootButton, "LEFT", 5, 0)

    -- Set the item icon or use the question mark icon if not found
    local iconTexture = GetItemIcon(itemId) or "Interface/Icons/INV_Misc_QuestionMark"
    itemIcon:SetTexture(iconTexture)

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
    itemName:SetText(GetItemInfo(itemId) or tostring(itemId))  -- Use itemId as fallback

    lootButton:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight", "ADD")
    lootButton:SetNormalFontObject("GameFontNormal")
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
                ChatFrame_OpenChat(itemLink, SELECTED_CHAT_FRAME)
            end
        else
            print("Error: Item link not found for item ID " .. itemId)
        end
    end)

    -- Dynamically adjust the height of the lootContent based on the number of buttons
    local contentHeight = index * (buttonHeight + buttonSpacing)  -- Height based on number of items
    lootContent:SetHeight(contentHeight)  -- Set content height

    lootButton:Show()
    return lootButton
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
    UIDropDownMenu_SetText(thirdDropdown, "Select Task")

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

    if selectedModule == "Bosses" then
        UIDropDownMenu_SetText(subcategoryDropdown, "Select Boss")
        local bosses = {"King Black Dragon", "Kalphite Queen"}
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
    elseif selectedModule == "Slayer" then
        UIDropDownMenu_SetText(subcategoryDropdown, "Select Master")
        local masters = {"Turael", "Mazchna"}
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
    end
end

-- Module Dropdown Initialization
UIDropDownMenu_Initialize(moduleDropdown, function(self, level)
    local modules = {"Bosses", "Slayer"}
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

-- Show/Hide Frame Command
SLASH_WORSLOOT1 = "/worsloot"
SlashCmdList["WORSLOOT"] = function()
    if WORS_Loot:IsShown() then
        WORS_Loot:Hide()
    else
        WORS_Loot:Show()
    end
end

print("WORS Loot addon loaded.")