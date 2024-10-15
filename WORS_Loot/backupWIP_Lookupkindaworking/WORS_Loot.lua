-- Create the main frame
print("WORS Loot start..")
local WORS_Loot = CreateFrame("Frame", "WORS_Loot", UIParent)
WORS_Loot:SetSize(550, 450)
WORS_Loot:SetPoint("CENTER")
WORS_Loot:SetBackdrop({
    bgFile = "Interface\\WORS\\OldSchoolBackground2",
    edgeFile = "Interface\\WORS\\OldSchool-Dialog-Border",
    tile = false, tileSize = 32, edgeSize = 32,
    insets = { left = 5, right = 6, top = 6, bottom = 5 }
})

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

-- Data
local WORS_Loot_Slayer_Data = {
    Turael = {
        ["Aberrant Spectres"] = {90039},
        ["Abyssal Demons"] = {90039, 90979, 999999},
        ["Ankou"] = {90039, 999999},
    },
    Mazchna = {
        ["Giant Bats"] = {90039, 999899},
        ["Murlocs"] = {90039, 999899},
    },
    Vannaka = {
        ["Abyssal Demons"] = {90039, 90040},
        ["Black Demons"] = {90039},
    }
}

local WORS_Loot_Boss_Data = {
    ["Kalphite Queen"] = {90144, 2455, 90479, 90133, 90328, 90390, 90084, 90005, 90521, 90526, 90519, 90627, 90620, 90750},
    ["King Black Dragon"] = {90066, 90368, 90347, 90343, 91119},
}

-- Modular Functions
local function PopulateDropdown(dropdown, data)
    print("Location: PopulateDropdown start")
    if not data then
        print("Error: No data provided for dropdown.")
        return
    end
    UIDropDownMenu_ClearAll(dropdown)
    UIDropDownMenu_SetText(dropdown, "Select...")
    UIDropDownMenu_Initialize(dropdown, function(self, level)
        for _, item in ipairs(data) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = item
            info.func = function()
                UIDropDownMenu_SetText(dropdown, item)
                print("Selected item:", item)
                -- Add further handling here as needed
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    print("Location: PopulateDropdown end")
end

local function UpdateDropdownBasedOnSelection(dropdown, selectedValue, data)
    print("Location: UpdateDropdownBasedOnSelection start")
    if not data or not data[selectedValue] then
        print("No data found for selection:", selectedValue)
        return
    end
    UIDropDownMenu_ClearAll(dropdown)
    UIDropDownMenu_SetText(dropdown, "Select...")
    UIDropDownMenu_Initialize(dropdown, function(self, level)
        for subcategory, _ in pairs(data[selectedValue]) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = subcategory
            info.func = function()
                UIDropDownMenu_SetText(dropdown, subcategory)
                print("Third dropdown item selected:", subcategory)
                -- Call to update item buttons in the loot table
                UpdateThirdDropdown(subcategory)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
end

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
local function CreateLootButton(itemId, index)
    print("Location: CreateLootButton start")
    print("Creating loot button for item ID:", itemId)
    if not itemId then
        print("Error: Missing item ID.")
        return nil
    end
    local lootButton = CreateFrame("Button", nil, lootContent)
    lootButton:SetSize(220, buttonHeight)
    
    -- Calculate row and column based on the index
    local column = (index - 1) % 2  -- 0 for first column, 1 for second column
    local row = math.floor((index - 1) / 2) -- Calculate the row number
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
    itemName:SetFont("Fonts\\runescape.ttf", 20) -- Set custom font and size

    -- Attempt to fetch the item name using the cached method
    local itemInfo = {GetItemInfo(itemId)}
    if itemInfo[1] then
        itemName:SetText(itemInfo[1]) -- Use the name if found
    else
        -- Fallback method: Use item ID to create a hyperlink format
        local itemLink = format("|cffff8000|Hitem:%d:0:0:0:0:0:0:0|h[%d]|h|r", itemId, itemId)
        itemName:SetText(itemLink) -- Display the raw hyperlink format
        itemName:SetTextColor(1, 1, 0) -- Yellow color for unknown items

        -- Using GetTime for a simple timeout mechanism
        local loadingStartTime = GetTime()
        lootButton:SetScript("OnUpdate", function(self)
            if (GetTime() - loadingStartTime) > 120 then
                itemName:SetText("Unknown Item") -- Change to a default state after timeout
                lootButton:SetScript("OnUpdate", nil) -- Stop the update script
            else
                -- Try to fetch the item info again to see if it has been cached now
                itemInfo = {GetItemInfo(itemId)}
                if itemInfo[1] then
                    itemName:SetText(itemInfo[1]) -- Update with the found name
                    itemName:SetTextColor(1, 1, 1) -- Change color to white
                    lootButton:SetScript("OnUpdate", nil) -- Stop the update script
                end
            end
        end)
    end

    lootItems[itemId] = lootButton
    lootButton:Show()
    print("Loot button created for item ID:", itemId)
    return lootButton
end

-- Clear loot content
local function ClearLootContent()
    print("Location: ClearLootContent start")
    for _, button in pairs(lootItems) do
        button:Hide()
    end
    print("Loot content cleared.")
end

-- Update Subcategory Dropdown
local function UpdateSubcategoryDropdown(selectedModule)
    print("Location: UpdateSubcategoryDropdown start")
    print("Updating subcategory dropdown for module:", selectedModule)
    UIDropDownMenu_ClearAll(subcategoryDropdown)
    UIDropDownMenu_ClearAll(thirdDropdown)
    UIDropDownMenu_SetText(thirdDropdown, "")

    ClearLootContent() -- Clear previous loot items

    if selectedModule == "Bosses" then
        UIDropDownMenu_SetText(subcategoryDropdown, "Select Boss")
        local bossList = {}
        for boss, _ in pairs(WORS_Loot_Boss_Data) do
            table.insert(bossList, boss)
        end
        PopulateDropdown(subcategoryDropdown, bossList)

        thirdDropdown:Hide()
    elseif selectedModule == "Slayer" then
        UIDropDownMenu_SetText(subcategoryDropdown, "Select Master")
        local slayerList = {}
        for master, _ in pairs(WORS_Loot_Slayer_Data) do
            table.insert(slayerList, master)
        end
        PopulateDropdown(subcategoryDropdown, slayerList)
        thirdDropdown:Show()
    end
end

-- Update Third Dropdown based on Subcategory Selection
local function UpdateThirdDropdown(selectedBoss)
    print("Location: UpdateThirdDropdown start")
    if not WORS_Loot_Boss_Data[selectedBoss] then return end

    local itemIds = WORS_Loot_Boss_Data[selectedBoss]

    ClearLootContent() -- Clear previous loot items
    for index, itemId in ipairs(itemIds) do
        CreateLootButton(itemId, index)
    end
end

-- Initialize Module Dropdown
UIDropDownMenu_Initialize(moduleDropdown, function(self, level)
    local info = UIDropDownMenu_CreateInfo()
    info.text = "Bosses"
    info.func = function()
        UIDropDownMenu_SetText(moduleDropdown, "Bosses")
        UpdateSubcategoryDropdown("Bosses")
    end
    UIDropDownMenu_AddButton(info)

    info = UIDropDownMenu_CreateInfo()
    info.text = "Slayer"
    info.func = function()
        UIDropDownMenu_SetText(moduleDropdown, "Slayer")
        UpdateSubcategoryDropdown("Slayer")
    end
    UIDropDownMenu_AddButton(info)
end)

-- Initialize Subcategory Dropdown
UIDropDownMenu_Initialize(subcategoryDropdown, function(self, level)
    local selectedModule = UIDropDownMenu_GetText(moduleDropdown)
    UpdateDropdownBasedOnSelection(subcategoryDropdown, selectedModule, WORS_Loot_Slayer_Data)
end)

-- Initialize Third Dropdown
UIDropDownMenu_Initialize(thirdDropdown, function(self, level)
    local selectedValue = UIDropDownMenu_GetText(subcategoryDropdown)
    if selectedValue and WORS_Loot_Boss_Data[selectedValue] then
        UpdateThirdDropdown(selectedValue)
    end
end)

-- Show the frame for testing
WORS_Loot:Show()
