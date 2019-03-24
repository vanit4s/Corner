local drug = {
    button = {},
}

local editWindow = {
    checkbox = {},
    edit = {},
    button = {},
    window = {},
    label = {}
}

drug.window = guiCreateWindow(0.4, 0.3, 0.2, 0.4, "Wybierz narkotyk na sprzedaż", true)
    guiSetVisible(drug.window, false)
	guiWindowSetSizable(drug.window, false)
drug.button.zamknij = guiCreateButton(0.05, 0.8, 0.9, 0.15, "Anuluj", true, drug.window)
drug.grid = guiCreateGridList(0.05, 0.1, 0.9, 0.65, true, drug.window)
	guiGridListAddColumn(drug.grid, "ID", 0.15)
    guiGridListAddColumn(drug.grid, "Nazwa", 0.7)
    guiGridListSetSortingEnabled(drug.grid, false)

    local screenW, screenH = guiGetScreenSize()
        editWindow.window[1] = guiCreateWindow((screenW - 432) / 2, (screenH - 416) / 2, 432, 416, "Corners", false)
        guiWindowSetSizable(editWindow.window[1], false)
        guiSetVisible(editWindow.window[1], false)

        editWindow.button[1] = guiCreateButton(268, 338, 140, 58, "Zamknij", false, editWindow.window[1])
        editWindow.button[2] = guiCreateButton(35, 338, 140, 58, "Zapisz", false, editWindow.window[1])  
        editWindow.label[1] = guiCreateLabel(31, 38, 108, 27, "ID cornera:", false, editWindow.window[1])
        guiSetFont(editWindow.label[1], "default-bold-small")
        editWindow.label[2] = guiCreateLabel(59, 104, 65, 27, "Ceny", false, editWindow.window[1])
        guiSetFont(editWindow.label[2], "default-bold-small")
        guiSetProperty(editWindow.label[2], "Font", "default-bold-small")
        editWindow.edit[1] = guiCreateEdit(79, 131, 81, 30, "", false, editWindow.window[1])
        editWindow.edit[2] = guiCreateEdit(69, 171, 81, 30, "", false, editWindow.window[1])
        editWindow.edit[3] = guiCreateEdit(118, 211, 81, 30, "", false, editWindow.window[1])
        editWindow.edit[4] = guiCreateEdit(55, 251, 81, 30, "", false, editWindow.window[1])
        editWindow.edit[5] = guiCreateEdit(45, 291, 81, 30, "", false, editWindow.window[1])
        editWindow.label[3] = guiCreateLabel(17, 136, 62, 19, "Marihuana", false, editWindow.window[1])
        editWindow.label[4] = guiCreateLabel(17, 176, 62, 19, "Kokaina", false, editWindow.window[1])
        editWindow.label[5] = guiCreateLabel(17, 216, 95, 15, "Metaamfetamina", false, editWindow.window[1])
        editWindow.label[6] = guiCreateLabel(17, 257, 62, 19, "Hydro", false, editWindow.window[1])
        editWindow.label[7] = guiCreateLabel(17, 297, 62, 19, "LSD", false, editWindow.window[1])
        editWindow.label[8] = guiCreateLabel(268, 288, 105, 23, "Widoczny?", false, editWindow.window[1])
        guiSetFont(editWindow.label[8], "default-bold-small")
        editWindow.checkbox[1] = guiCreateCheckBox(348, 288, 15, 15, "", true, false, editWindow.window[1])

addEvent("editWindow", true)   
addEventHandler("editWindow", root, function(id, marihuana, kokaina, meta, hydro, lsd, visible)
	guiSetVisible(editWindow.window[1], true)
	showCursor(true)

	cornerid = id

	guiSetText(editWindow.label[1], "ID Cornera: ".. id ..".")
	guiSetText(editWindow.edit[1], tonumber(marihuana))
	guiSetText(editWindow.edit[2], kokaina)
	guiSetText(editWindow.edit[3], meta)
	guiSetText(editWindow.edit[4], hydro)
	guiSetText(editWindow.edit[5], lsd)

	if visible == 1 then
		guiCheckBoxGetSelected(editWindow.checkbox[1], true)
	else
		guiCheckBoxGetSelected(editWindow.checkbox[1], false)
	end
end)

function exitEdit()
	guiSetVisible(editWindow.window[1], false)
	showCursor(false)
end

addEventHandler("onClientGUIClick", editWindow.button[1], exitEdit)

function savePrices()
	if guiCheckBoxGetSelected(editWindow.checkbox[1]) then
		visible = 1
	else
		visible = 0
	end

	local marihuana = tonumber(guiGetText(editWindow.edit[1]))
	local kokaina = tonumber(guiGetText(editWindow.edit[2]))
	local metaamfetamina = tonumber(guiGetText(editWindow.edit[3]))
	local hydro = tonumber(guiGetText(editWindow.edit[4]))
	local lsd = tonumber(guiGetText(editWindow.edit[5]))

	triggerServerEvent("saveDrugPrices", localPlayer, cornerid, marihuana, kokaina, metaamfetamina, hydro, lsd, visible)
	guiSetVisible(editWindow.window[1], false)
	showCursor(false)
end

addEventHandler("onClientGUIClick", editWindow.button[2], savePrices)

addEvent("startDealing", true)
addEventHandler("startDealing", root, function(items, corner)
	marker = corner
	guiSetVisible(drug.window, true)
    showCursor(true)

    guiGridListClear(drug.grid)
    for i, v in ipairs(items) do
        local row = guiGridListAddRow(drug.grid)
        local count = v.type == 2 and " (" .. v.value2 .. ")" or ""
        guiGridListSetItemText(drug.grid, row, 1, v.id, false, false)
        guiGridListSetItemText(drug.grid, row, 2, v.name .. count, false, false)
        guiGridListSetItemData(drug.grid, row, 1, v)
        guiGridListSetItemData(drug.grid, row, 2, v)
    end
end)

function cancelDeal()
	guiSetVisible(drug.window, false)
	showCursor(false)
	triggerServerEvent("onCancelCorner", localPlayer, marker)
end

addEventHandler("onClientGUIClick", drug.button.zamknij, cancelDeal, false)

function exitMarker()
	triggerServerEvent("leftCorner", localPlayer, localPlayer)
end

addEventHandler("onClientGUIDoubleClick", drug.grid, function()
    local row = guiGridListGetSelectedItem(drug.grid)
    local item = guiGridListGetItemData(drug.grid, row, 1)
    if row >= 0 then
		guiSetVisible(drug.window, false)
		showCursor(false)

		setTimer(function()
            triggerServerEvent("onSelectDealDrug", localPlayer, item)
        end, math.random(1000, 5000), 1)
    end
end, false)