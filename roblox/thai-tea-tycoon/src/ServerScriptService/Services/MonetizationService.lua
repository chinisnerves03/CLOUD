-- MonetizationService: 3 Game Passes + 2 Developer Products
-- Pass ownership is stored as player Attributes: Pass_DoubleCash, Pass_AutoBrew, Pass_OfflinePlus
-- No in-game shop buttons yet: call MarketplaceService:PromptGamePassPurchase from UI and this service handles the rest

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

-- total income multiplier from passes
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
				warn("[Monetization] Could not check pass " .. passKey .. ": " .. tostring(result))
			end
		elseif pass.Id == 0 and not grantAll and not warnedMissingIds then
			warnedMissingIds = true
			warn("[Monetization] Some Game Pass IDs in Config.PASSES are not set yet")
		end
		player:SetAttribute(attrName(passKey), owned)
	end
end

function MonetizationService.Init(dataService, plotService)
	DataService = dataService
	PlotService = plotService

	-- Game Pass bought during play
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
		if not purchased then
			return
		end
		local passKey = passKeyFromId(passId)
		if passKey then
			player:SetAttribute(attrName(passKey), true)
			PlotService.Notify(player, "Buy", "Unlocked " .. Config.PASSES[passKey].Name .. "!")
		end
	end)

	-- Developer Products (repeatable)
	MarketplaceService.ProcessReceipt = function(receipt)
		local player = Players:GetPlayerByUserId(receipt.PlayerId)
		if not player or not DataService.Get(player) then
			-- player not loaded yet or already gone; Roblox retries later
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local purchaseId = tostring(receipt.PurchaseId)
		if DataService.HasReceipt(player, purchaseId) then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end

		local productKey = productKeyFromId(receipt.ProductId)
		if not productKey then
			warn("[Monetization] Unknown Product ID " .. tostring(receipt.ProductId))
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end

		local product = Config.PRODUCTS[productKey]
		local amount = math.max(product.Min, PlotService.GetBaseIncome(player) * product.Seconds)
		PlotService.AddCash(player, amount)
		DataService.AddReceipt(player, purchaseId)
		PlotService.Notify(player, "Buy", product.Name .. ": +" .. Config.FormatMoney(amount))

		-- only confirm the grant to Roblox after a successful save
		-- if saving fails the receipt is already in memory, so a retry will not double-grant
		if DataService.Save(player) then
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

return MonetizationService
