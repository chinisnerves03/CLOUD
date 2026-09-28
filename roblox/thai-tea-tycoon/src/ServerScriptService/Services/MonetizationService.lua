-- MonetizationService: Game Pass 3 อัน + Developer Product 2 อัน
-- สถานะ Pass เก็บเป็น Attribute บนตัวผู้เล่น: Pass_DoubleCash, Pass_AutoCollect, Pass_OfflinePlus
-- ปุ่มขายในเกมยังไม่ได้ทำ: เรียก MarketplaceService:PromptGamePassPurchase จาก UI ได้เลย ระบบนี้รับต่อให้

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Config"))

local MonetizationService = {}

local DataService
local PlotService
local warnedMissingIds = false

local function attrName(passKey: string): string
	return "Pass_" .. passKey
end

local function passKeyFromId(passId: number): string?
	for passKey, pass in Config.PASSES do
		if pass.Id ~= 0 and pass.Id == passId then
			return passKey
		end
	end
	return nil
end

local function productKeyFromId(productId: number): string?
	for productKey, product in Config.PRODUCTS do
		if product.Id ~= 0 and product.Id == productId then
			return productKey
		end
	end
	return nil
end

function MonetizationService.HasPass(player: Player, passKey: string): boolean
	return player:GetAttribute(attrName(passKey)) == true
end

-- ตัวคูณรายได้รวมจาก Pass
function MonetizationService.IncomeMultiplier(player: Player): number
	return if MonetizationService.HasPass(player, "DoubleCash") then 2 else 1
end

function MonetizationService.LoadPasses(player: Player)
	local grantAll = RunService:IsStudio() and Config.STUDIO_GRANT_ALL_PASSES
	for passKey, pass in Config.PASSES do
		local owned = grantAll
		if not owned and pass.Id ~= 0 then
			local ok, result = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(player.UserId, pass.Id)
			end)
			if ok then
				owned = result
			else
				warn("[Monetization] เช็ก Pass " .. passKey .. " ไม่ได้: " .. tostring(result))
			end
		elseif pass.Id == 0 and not grantAll and not warnedMissingIds then
			warnedMissingIds = true
			warn("[Monetization] ยังไม่ได้ใส่ ID ของ Game Pass บางอันใน Config.PASSES")
		end
		player:SetAttribute(attrName(passKey), owned)
	end
end

function MonetizationService.Init(dataService, plotService)
	DataService = dataService
	PlotService = plotService

	-- ซื้อ Game Pass ระหว่างเล่น
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
		if not purchased then
			return
		end
		local passKey = passKeyFromId(passId)
		if passKey then
			player:SetAttribute(attrName(passKey), true)
			PlotService.Notify(player, "Buy", "ได้รับ " .. Config.PASSES[passKey].Name .. " แล้ว!")
		end
	end)

	-- Developer Product (ซื้อซ้ำได้)
	MarketplaceService.ProcessReceipt = function(receipt)
		local player = Players:GetPlayerByUserId(receipt.PlayerId)
		if not player or not DataService.Get(player) then
			-- ผู้เล่นยังโหลดไม่เสร็จหรือออกไปแล้ว Roblox จะส่งมาใหม่ภายหลัง
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local purchaseId = tostring(receipt.PurchaseId)
		if DataService.HasReceipt(player, purchaseId) then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

		local productKey = productKeyFromId(receipt.ProductId)
		if not productKey then
			warn("[Monetization] ไม่รู้จัก Product ID " .. tostring(receipt.ProductId))
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local product = Config.PRODUCTS[productKey]
		local amount = math.max(product.Min, PlotService.GetIncomePerSecond(player) * product.Seconds)
		PlotService.AddCash(player, amount)
		DataService.AddReceipt(player, purchaseId)
		PlotService.Notify(player, "Buy", product.Name .. ": ได้ " .. Config.FormatMoney(amount))

		-- ต้องเซฟสำเร็จก่อนบอก Roblox ว่าให้ของแล้ว
		-- ถ้าเซฟไม่ได้ ใบเสร็จอยู่ในหน่วยความจำแล้ว รอบหน้าจะไม่ให้ซ้ำ
		if DataService.Save(player) then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

return MonetizationService
