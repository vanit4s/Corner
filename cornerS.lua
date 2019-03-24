corners = {}
dealing = {}

texts = {
	"wyskakuje zza krzaków wysuszony ćpun z łamiącym się angielskim. Nerwowo rozgląda się, wyciąga z majtek banknoty zwinięte w rulon i pyta o narkotyki. Po chwili dokonuje zakupu i ucieka.",
	"podszedł elegancki, ubrany w markowy garnitur staruszek. Po krótkiej pogawędce kupuje narkotyki.",
	"podszedł facet w obcisłym, skórzanym stroju. Początkowo insynuuje kontakt seksualny, jednak po chwili decyduje się kupić narkotyki.",
	"zbliża się facet w czarnej sukmanie - to ksiądz. Dyskretnie pyta się o narkotyki oraz najbliższą klinikę leczenia chorób wenerycznych. Kupuje narkotyki i odchodzi.",
	"podbija niewidomy facet z psem przewodnikiem. Pyta o drogę na najbliższą stację benzynową i przy okazji kupuje pakiet narkotyków.",
	"podchodzi stara murzynka. Grozi wszystkim dookoła, że albo sprzedadzą jej narkotyki albo rzuci na nich zły urok. W końcu kupuje konkretne dragi i odchodzi mrucząc coś pod nosem.",
	"podjeżdża stary motocyklista na Freewayu. Po krótkiej wymianie zdań kupuje towar.",
	"podchodzi budowlaniec z pobliskiej budowy. Po zorientowaniu się w sytuacji - kupuje dragi i upycha pod kaskiem ochronnym.",
	"toczy się gruba niska kobieta. Po chwili podaje mokre od potu pieniądze i odbiera narkotyki.",
	"podbija kobieta z dwoma małymi pieskami rasy York. Wyciąga swoją wielką, różową, pomponiastą portmonetkę i kupuje narkotyki.",
	"podchodzi wychudzona narkomanka, która panicznie rozgląda się dookoła. Odbiera narkotyk i szybko odchodzi.",
	"na rowerze podjeżdża młody murzyn, po krótkiej gadce chłopak wymienia pieniądze na towar.",
	"podbija gruby latynos, facet oklepuje się po kieszeniach, po czym wyciąga z jednej z nich kilka banknotów, za które kupuję narkotyki.",
	"podchodzi czarnoskóry crackhead, mężczyzna cały czas się drapie i jąka. Drżącymi dłońmi wręcza dilerowi pieniądze, po czym odbiera towar.",
	"podchodzi biały nastolatek z wygoloną głową i w koszulce radia V-Rock. Chłopak kupuje narkotyki dyskretnie wręczając pieniądze dilerowi.",
	"podbija roznegliżowana, lekko pijana azjatka. Kobieta wyciąga z torebki pieniądze, płaci nimi za narkotyk.",
	"podbija zmarnowana murzynka pchająca wózek z dzieckiem. Kobieta kupuję towar, po czym chowa go w wózku.",
	"podchodzi wysoki mężczyna ubrany w ortalionową bluzę, słychać u niego rosyjski akcent. Klient dyskretnie kupuje towar.",
	"na skuterze podjeżdża facet ubrany w strój pizzaboya The Well Stacked Pizza. Chłopak rozgląda się dookoła, po czym kupuję narkotyk i odjeżdża.",
	"podchodzi starszy trucker w ubrudzonej koszulce Logger Beer. Po krótkiej wymianie zdań dochodzi do sprzedaży narkotyku.",
}

local function updateCorner(id)
	local corner = exports.gtarp_db:query("SELECT * FROM `gtarp_corners` WHERE `id`=?", id)[1]
	local x, y, z = unpack(fromJSON(corner.position))

	destroyElement(corners[id])
	dealing[id] = nil

	if corner.visible == 1 then
		corners[id] = createMarker(x, y, z-1, "cylinder", 1, 255, 0, 0, 50)
		setElementData(corners[id], "markerDealing", true)
		setElementData(corners[id], "markerID", id)
	else
		for i, v in ipairs(getElementsByType("player")) do
			if exports.gtarp_admin:hasRight("corners.restart", v) then
				corners[id] = createMarker(x, y, z-1, "cylinder", 1, 66, 173, 244, 50, v)
				setElementData(corners[id], "markerDealing", true)
				setElementData(corners[id], "markerID", id)
			end
		end
	end
end

addCommandHandler("corner", function(plrA, _, argA, ...)
	if argA == "create" then
		local name = tostring(...)

		if name then
			if exports.gtarp_admin:hasRight("corners.gm", plrA) then
				local x, y, z = getElementPosition(plrA)
				exports.gtarp_db:query("INSERT INTO `gtarp_corners` SET `position` = ?, `price`=?, `name` = ?", toJSON({x,y,z}, true), toJSON({100, 300, 200, 250, 290}, true), name)
				local cid = exports.gtarp_db:query("SELECT * FROM `gtarp_corners` ORDER BY id DESC LIMIT 1")[1]
				createCorner(cid.id, x, y, z-1)
				outputChatBox("Stworzyłeś corner.", plrA, 255, 0, 0)
			end
		end
	elseif argA == "delete" then
		if exports.gtarp_admin:hasRight("corners.gm", plrA) then
			local corner = tostring(...)

			if corner then
				local marker = exports.gtarp_db:query("SELECT * FROM `gtarp_corners` WHERE `id` = ?", tonumber(corner))
				outputChatBox("Usuwasz corner o ID: ".. tostring(corner) ..".", plrA, 255, 0, 0)
				deleteCorner(tonumber(corner))
			end
		end
	elseif argA == "restart" then
		if exports.gtarp_admin:hasRight("corners.gm", plrA) then

			for k in pairs(corners) do
    			destroyElement(corners[k])
    			corners[k] = nil
			end

			restartMarkers()
			outputChatBox("Restartujesz cornery.", plrA, 255, 0, 0)
		end
	elseif argA == "id" then
		if exports.gtarp_admin:hasRight("corners.restart", plrA) then
			local x, y, z = getElementPosition(plrA)
			local sphere = createColSphere(x, y, z, 2)
			local nearbyMarkers = getElementsWithinColShape(sphere, "marker")

			for i, v in ipairs(nearbyMarkers) do
				outputChatBox("ID cornera: ".. getElementData(v, "markerID") .. ".", plrA, 255, 0, 0)
			end
		end
	elseif argA == "r" then
		if exports.gtarp_admin:hasRight("corners.restart", plrA) then
			local x, y, z = getElementPosition(plrA)
			local sphere = createColSphere(x, y, z, 2)
			local nearbyMarkers = getElementsWithinColShape(sphere, "marker")

			for i, v in ipairs(nearbyMarkers) do
				updateCorner(getElementData(v, "markerID"))
				outputChatBox("Odświeżasz corner.", plrA, 255, 0, 0)
			end
		end
	elseif not argA then
		if exports.gtarp_admin:hasRight("corners.restart", plrA) then
			local x, y, z = getElementPosition(plrA)
			local sphere = createColSphere(x, y, z, 2)
			local nearbyMarkers = getElementsWithinColShape(sphere, "marker")

			for i, v in ipairs(nearbyMarkers) do
				local query = exports.gtarp_db:query("SELECT * FROM `gtarp_corners` WHERE `id`=?", getElementData(v, "markerID"))

				for x, y in ipairs(query) do
					local marihuana, kokaina, meta, hydro, lsd = unpack(fromJSON(y.price))
					triggerClientEvent(plrA, "editWindow", plrA, getElementData(v, "markerID"), marihuana, kokaina, meta, hydro, lsd, y.visible)
				end
			end
		end
	end
end)

function startDeal(plr)
	local x, y, z = getElementPosition(plr)

	for i, v in ipairs(getElementsByType("marker")) do
		local x2, y2, z2 = getElementPosition(v)

		if getDistanceBetweenPoints3D(x, y, z, x2, y2, z2) < 1.5 then
			if getElementData(plr, "isDealing") == false then
				if dealing[i] == nil then
					setElementData(plr, "isDealing", true)
					setElementData(plr, "cornerDealing", i)
					outputChatBox("Rozpoczynasz handel narkotykami.", plr, 214, 214, 214)
					dealing[i] = v
					local items = exports.gtarp_db:query("SELECT * FROM `gtarp_items` WHERE `ownervalue`=? AND `type`=?", getElementData(plr, "characters_id"), 2)
					triggerClientEvent(plr, "startDealing", plr, items, i)
					local cornerSphere = createColSphere(x, y, z, 1.5)

					addEventHandler("onColShapeLeave", cornerSphere, function()
						if getElementData(plr, "isDealing") == true then
							outputChatBox("Opuściłeś miejsce handlu narkotykami.", plr, 214, 214, 214)
							setElementData(plr, "isDealing", false)
							dealing[getElementData(plr, "cornerDealing")] = nil
							setElementData(plr, "cornerDealing", nil)
						end
					end)
				else
					setElementData(plr, "isDealing", false)
					outputChatBox("Ktoś aktualnie handluje na tym cornerze.", plr, 214, 214, 214)
				end
			else
				setElementData(plr, "isDealing", false)
				setElementData(plr, "cornerDealing", nil)
				dealing[i] = nil
				outputChatBox("Przestajesz handlować.", plr, 214, 214, 214)
			end
		end
	end
end
addCommandHandler("handel", startDeal)

addEvent("saveDrugPrices", true)
addEventHandler("saveDrugPrices", root, function(id, marihuana, kokaina, meta, hydro, lsd, visible)
	exports.gtarp_db:query("UPDATE `gtarp_corners` SET `price`=?, `visible`=? WHERE `id`=?", toJSON({marihuana, kokaina, meta, hydro, lsd}, true), visible, id)
	updateCorner(id)
	outputChatBox("Zmieniasz ceny sprzedaży narkotyków na cornerze o ID: ".. id ..".", source, 255, 0, 0)
end)

addEvent("onCancelCorner", true)
addEventHandler("onCancelCorner", root, function(x)
	dealing[getElementData(source, "cornerDealing")] = nil
	setElementData(source, "cornerDealing", nil)
	setElementData(source, "isDealing", false)
	outputChatBox("Przestajesz handlować.", source, 214, 214, 214)
end)

addEvent("onSelectDealDrug", true)
addEventHandler("onSelectDealDrug", root, function(item)
	local id = item.id
	local count = item.value2

	if count > 0 then
		count = count - 1
		if count == 0 then
			exports.gtarp_db:query("DELETE FROM `gtarp_items` WHERE `id` = ?", id)
		end
	else
		exports.gtarp_db:query("DELETE FROM `gtarp_items` WHERE `id` = ?", id)
	end

	if getElementData(source, "isDealing") == true then
		local x, y, z = getElementPosition(source)
		local sphere = createColSphere(x, y, z, 15)
		local nearbyPlayers = getElementsWithinColShape(sphere, "player")

		for i, v in ipairs(nearbyPlayers) do
			local number = math.random(1, 10)
			outputChatBox("**Do ".. getElementData(source, "characters_name") .." ".. tostring(texts[number]), v, 152, 127, 249, false)
		end

		exports.gtarp_db:query("UPDATE `gtarp_items` SET `value2` = ? WHERE `id` = ?", count, id)

		local x2, y2, z2 = getElementPosition(source)
		local sphere2 = createColSphere(x2, y2, z2, 2)
		local nearbyMarkers = getElementsWithinColShape(sphere2, "marker")
		local a, b, c, d, e

		for i, v in ipairs(nearbyMarkers) do
			local query = exports.gtarp_db:query("SELECT * FROM `gtarp_corners` WHERE `id`=?", getElementData(v, "markerID"))

			for x, y in ipairs(query) do
				a, b, c, d, e = unpack(fromJSON(y.price))
			end
		end

		local drug = exports.gtarp_db:query("SELECT * FROM `gtarp_items` WHERE `id`=?", id)

		for i, v in ipairs(drug) do
			if v.value1 == 1 then
				outputChatBox("Sprzedajesz marihuanę za $".. a ..".", source, 214, 214, 214)
				givePlayerMoney(source, a)
			elseif v.value1 == 2 then
				outputChatBox("Sprzedajesz kokainę za $".. b ..".", source, 214, 214, 214)
				givePlayerMoney(source, b)
			elseif v.value1 == 3 then
				outputChatBox("Sprzedajesz metaamfetaminę za $".. c ..".", source, 214, 214, 214)
				givePlayerMoney(source, c)
			elseif v.value1 == 4 then
				outputChatBox("Sprzedajesz hydro za $".. d ..".", source, 214, 214, 214)
				givePlayerMoney(source, d)
			elseif v.value1 == 5 then
				outputChatBox("Sprzedajesz lsd za $".. e ..".", source, 214, 214, 214)
				givePlayerMoney(source, e)
			end
		end

		local items = exports.gtarp_db:query("SELECT * FROM `gtarp_items` WHERE `ownervalue`=? AND `type`=?", getElementData(source, "characters_id"), 2)
		triggerClientEvent(source, "startDealing", source, items)
	end
end)

function createCorner(id, x, y, z)
	corners[id] = createMarker(x, y, z, "cylinder", 1, 255, 0, 0, 50)
	setElementData(corners[id], "markerDealing", true)
	setElementData(corners[id], "markerID", id)
end

function deleteCorner(id)
	destroyElement(corners[id])
	dealing[id] = nil
	exports.gtarp_db:query("DELETE FROM `gtarp_corners` WHERE `id` = ?", id)
end

function restartMarkers()
	local results = exports.gtarp_db:query("SELECT * FROM `gtarp_corners`")

	for i, v in ipairs(getElementsByType("marker")) do
		if getElementData(v, "markerDealing") == true then
			destroyElement(v)
			corners[i] = nil
			dealing[i] = nil
		end
	end

	for i, v in ipairs(results) do
		local x, y, z = unpack(fromJSON(v.position))
		createCorner(v.id, x, y, z-1)
		updateCorner(v.id)
	end

	for i, v in ipairs(getElementsByType("player")) do
		setElementData(v, "isDealing", false)
		setElementData(v, "cornerDealing", nil)
	end
end

addEvent("onResourceStart", true)
addEventHandler("onResourceStart", root, function()
	restartMarkers()
end)

addEventHandler("onPlayerQuit", root, function()
	if getElementData(source, "isDealing") == true then
		setElementData(source, "isDealing", false)
		dealing[getElementData(source, "cornerDealing")] = nil
		setElementData(source, "cornerDealing", nil)
	end
end)