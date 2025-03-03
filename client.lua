local QBCore = exports['qb-core']:GetCoreObject()

-- qb-hud
local config = Config
local speedMultiplier = config.UseMPH and 2.23694 or 3.6
local seatbeltOn = false
local cruiseOn = false
local showAltitude = false
local showSeatbelt = false
local voice = 0
local nos = 0
local stress = 0
local hunger = 100
local thirst = 100
local cashAmount = 0
local bankAmount = 0
local nitroActive = 0
local harness = 0
local hp = 100
local armed = 0
local parachute = -1
local oxygen = 100
local engine = 0
local dev = false
local playerDead = false
local showMenu = false
local showCircleB = false
local showSquareB = false

-- qb-menu 
local Menu = config.Menu
DisplayRadar(false)

local loadSettings = function(settings)
    for k,v in pairs(settings) do
        if k == 'isToggleMapShapeChecked' then
            Menu.isToggleMapShapeChecked = v
            SendNUIMessage({ test = true, event = k, toggle = v})
        elseif k == 'isCineamticModeChecked' then
            Menu.isCineamticModeChecked = v
            CinematicShow(v)
            SendNUIMessage({ test = true, event = k, toggle = v})
        elseif k == 'isChangeFPSChecked' then 
            Menu[k] = v
            local val = v == true and 'Optimized' or 'Synced'
            SendNUIMessage({ test = true, event = k, toggle = val})
        else
            Menu[k] = v
            SendNUIMessage({ test = true, event = k, toggle = v})
        end
    end
    QBCore.Functions.Notify(Lang:t("notify.hud_settings_loaded"), "success")
    TriggerEvent("hud:client:LoadMap")
end

local saveSettings = function()
    SetResourceKvp('hudSettings', json.encode(Menu))
end

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    Wait(2000)
    local hudSettings = GetResourceKvpString('hudSettings') 
    if hudSettings then loadSettings(json.decode(hudSettings)) end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        Wait(2000)
        local hudSettings = GetResourceKvpString('hudSettings') 
        if hudSettings then loadSettings(json.decode(hudSettings)) end
    end
end)

-- qb-menu Callbacks & Events
RegisterCommand('menu', function()
    Wait(50)
    if not showMenu then
        TriggerEvent("hud:client:playOpenMenuSounds")
        SetNuiFocus(true, true)
        SendNUIMessage({ action = "open"}) 
        showMenu = true
    end
end)

RegisterNUICallback('closeMenu', function()
    Wait(50)
    showMenu = false
    SetNuiFocus(false, false)
end) 

RegisterKeyMapping('menu', 'Open Menu', 'keyboard', Config.OpenMenu)

-- reset hud
local restartHud = function()
    TriggerEvent("hud:client:playResetHudSounds")
    TriggerEvent('QBCore:Notify', Lang:t("notify.hud_restart"), "error")
    if IsPedInAnyVehicle(PlayerPedId()) then
        Wait(2600)
        SendNUIMessage({ action = 'car', show = false })
        SendNUIMessage({ action = 'car', show = true })
    end
    Wait(2600)
    SendNUIMessage({ action = 'hudtick', show = false })
    SendNUIMessage({ action = 'hudtick', show = true })
    Wait(2600)
    TriggerEvent('QBCore:Notify', Lang:t("notify.hud_start"), "success")
end

RegisterNUICallback('restartHud', function()
    Wait(50)
    restartHud()
end) 

RegisterCommand('resethud', function()
    Wait(50)
    restartHud()
end)

RegisterNUICallback('resetStorage', function()
    Wait(50)
    TriggerEvent("hud:client:resetStorage")
end) 

RegisterNetEvent("hud:client:resetStorage", function()
    Wait(50)
    if Menu.isResetSoundsChecked == true then
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "airwrench", 0.1)
    end
    QBCore.Functions.TriggerCallback('hud:server:getMenu', function(menu) loadSettings(menu); SetResourceKvp('hudSettings', json.encode(menu)) end)
end)

-- notifications
RegisterNUICallback('openMenuSounds', function()
    Wait(50)
    Menu.isOpenMenuSoundsChecked = not Menu.isOpenMenuSoundsChecked
    TriggerEvent("hud:client:playHudChecklistSound")
    saveSettings()
end) 

RegisterNetEvent("hud:client:playOpenMenuSounds", function()
    Wait(50)
    if Menu.isOpenMenuSoundsChecked == true then
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.5)
    end
end)

RegisterNUICallback('resetHudSounds', function()
    Wait(50)
    Menu.isResetSoundsChecked = not Menu.isResetSoundsChecked
    TriggerEvent("hud:client:playHudChecklistSound")
    saveSettings()
end) 

RegisterNetEvent("hud:client:playResetHudSounds", function()
    Wait(50)
    if Menu.isResetSoundsChecked == true then
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "airwrench", 0.1)
    end
end)

RegisterNUICallback('checklistSounds', function()
    Wait(50)
    TriggerEvent("hud:client:checklistSounds")
end) 

RegisterNetEvent("hud:client:checklistSounds", function()
    Wait(50)
    Menu.isListSoundsChecked = not Menu.isListSoundsChecked
    TriggerEvent("hud:client:playHudChecklistSound")
    saveSettings()
end)

RegisterNetEvent("hud:client:playHudChecklistSound", function()
    Wait(50)
    if Menu.isListSoundsChecked == true then
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "lock", 0.5)
    end
end)

RegisterNUICallback('showOutMap', function()
    Wait(50)
    Menu.isOutMapChecked = not Menu.isOutMapChecked
    TriggerEvent("hud:client:playHudChecklistSound")
    saveSettings()
end) 

RegisterNUICallback('showMapNotif', function()
    Wait(50)
    Menu.isMapNotifChecked = not Menu.isMapNotifChecked
    TriggerEvent("hud:client:playHudChecklistSound")
    saveSettings()
end) 

RegisterNUICallback('showFuelAlert', function()
    Wait(50)
    Menu.isLowFuelChecked = not Menu.isLowFuelChecked
    TriggerEvent("hud:client:playHudChecklistSound")
    saveSettings()
end) 

RegisterNUICallback('showCinematicNotif', function()
    Wait(50)
    Menu.isCinematicNotifChecked = not Menu.isCinematicNotifChecked
    TriggerEvent("hud:client:playHudChecklistSound")
    saveSettings()
end) 

-- status
RegisterNUICallback('dynamicHealth', function()
    Wait(50)
    TriggerEvent("hud:client:ToggleHealth")
end) 

RegisterNetEvent("hud:client:ToggleHealth", function()
    Wait(50)
    Menu.isDynamicHealthChecked = not Menu.isDynamicHealthChecked
    TriggerEvent("hud:client:playHudChecklistSound")
    saveSettings()
end)
  

RegisterNUICallback('dynamicArmor', function()
    Wait(50)
    Menu.isDynamicArmorChecked = not Menu.isDynamicArmorChecked
    TriggerEvent("hud:client:playHudChecklistSound")
    saveSettings()
end) 

RegisterNUICallback('dynamicHunger', function()
    Wait(50)
    Menu.isDynamicHungerChecked = not Menu.isDynamicHungerChecked
    TriggerEvent("hud:client:playHudChecklistSound")
    saveSettings()
end) 

RegisterNUICallback('dynamicThirst', function()
    Wait(50)
    Menu.isDynamicThirstChecked = not Menu.isDynamicThirstChecked
    TriggerEvent("hud:client:playHudChecklistSound")
    saveSettings()
end) 


RegisterNUICallback('dynamicStress', function()
    Wait(50)
    Menu.isDynamicStressChecked = not Menu.isDynamicStressChecked
    TriggerEvent("hud:client:playHudChecklistSound")
    saveSettings()
end) 

RegisterNUICallback('dynamicOxygen', function()
    Wait(50)
    Menu.isDynamicOxygenChecked = not Menu.isDynamicOxygenChecked
    TriggerEvent("hud:client:playHudChecklistSound")
    saveSettings()
end)   

-- vehicle
RegisterNUICallback('changeFPS', function()
    Wait(50)
    Menu.isChangeFPSChecked = not Menu.isChangeFPSChecked
    TriggerEvent("hud:client:playHudChecklistSound")
    saveSettings()
end)   


RegisterNUICallback('HideMap', function()
    Wait(50) 
    Menu.isHideMapChecked = not Menu.isHideMapChecked
    if Menu.isHideMapChecked == true then
        DisplayRadar(false)
    else 
        DisplayRadar(true)
    end
    TriggerEvent("hud:client:playHudChecklistSound")
    saveSettings()
end) 

RegisterNetEvent("hud:client:LoadMap", function()
    Wait(50)
    -- Credit to Dalrae for the solve.
    local defaultAspectRatio = 1920/1080 -- Don't change this.
    local resolutionX, resolutionY = GetActiveScreenResolution()
    local aspectRatio = resolutionX/resolutionY
    local minimapOffset = 0
    if aspectRatio > defaultAspectRatio then
        minimapOffset = ((defaultAspectRatio-aspectRatio)/3.6)-0.008
    end

    if Menu.isToggleMapShapeChecked == "square" then 
        RequestStreamedTextureDict("squaremap", false)
        if not HasStreamedTextureDictLoaded("squaremap") then
            Wait(150)
        end
        if Menu.isMapNotifChecked == true then
            TriggerEvent('QBCore:Notify',  Lang:t("notify.load_square_map"))
        end
            SetMinimapClipType(0)
            AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "squaremap", "radarmasksm")
            AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "squaremap", "radarmasksm")
            -- 0.0 = nav symbol and icons left 
            -- 0.1638 = nav symbol and icons stretched
            -- 0.216 = nav symbol and icons raised up
            SetMinimapComponentPosition("minimap", "L", "B", 0.0+minimapOffset, -0.047, 0.1638, 0.183)
    
            -- icons within map
            SetMinimapComponentPosition("minimap_mask", "L", "B", 0.2+minimapOffset, 0.0, 0.065, 0.20)
    
            -- -0.01 = map pulled left
            -- 0.025 = map raised up
            -- 0.262 = map stretched
            -- 0.315 = map shorten
            SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.01+minimapOffset, 0.025, 0.262, 0.300)
            SetBlipAlpha(GetNorthRadarBlip(), 0)
            SetRadarBigmapEnabled(true, false)
            SetMinimapClipType(0)
            Wait(50)
            SetRadarBigmapEnabled(false, false)
        if Menu.isToggleMapBordersChecked == true then
            showCircleB = false
            showSquareB = true
        end
        Wait(1200)
        if Menu.isMapNotifChecked == true then
            TriggerEvent('QBCore:Notify', Lang:t("notify.loaded_square_map"))
        end
    elseif Menu.isToggleMapShapeChecked == "circle" then 
        RequestStreamedTextureDict("circlemap", false)
        if not HasStreamedTextureDictLoaded("circlemap") then
            Wait(150)
        end
        if Menu.isMapNotifChecked == true then
            TriggerEvent('QBCore:Notify', Lang:t("notify.load_circle_map"))
        end
            SetMinimapClipType(1)
            AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "circlemap", "radarmasksm")
            AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "circlemap", "radarmasksm")
            -- -0.0100 = nav symbol and icons left 
            -- 0.180 = nav symbol and icons stretched
            -- 0.258 = nav symbol and icons raised up
            SetMinimapComponentPosition("minimap", "L", "B", -0.0100+minimapOffset, -0.030, 0.180, 0.258)

            -- icons within map
            SetMinimapComponentPosition("minimap_mask", "L", "B", 0.200+minimapOffset, 0.0, 0.065, 0.20)

            -- -0.00 = map pulled left
            -- 0.015 = map raised up
            -- 0.252 = map stretched
            -- 0.338 = map shorten
            SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.00+minimapOffset, 0.015, 0.252, 0.338)
            SetBlipAlpha(GetNorthRadarBlip(), 0)
            SetMinimapClipType(1)
            SetRadarBigmapEnabled(true, false)
            Wait(50)
            SetRadarBigmapEnabled(false, false)
            if Menu.isToggleMapBordersChecked == true then
                showSquareB = false
                showCircleB = true
            end
            Wait(1200)
        if Menu.isMapNotifChecked == true then
            TriggerEvent('QBCore:Notify', Lang:t("notify.loaded_circle_map"))
        end
    end
end)

RegisterNUICallback('ToggleMapShape', function()
    Wait(50)
    if Menu.isHideMapChecked == false then
        if Menu.isToggleMapShapeChecked == "circle" then 
            Menu.isToggleMapShapeChecked = "square"
        else 
            Menu.isToggleMapShapeChecked = "circle"
        end
        Wait(50)
        TriggerEvent("hud:client:LoadMap")   
    end 
    TriggerEvent("hud:client:playHudChecklistSound")
    saveSettings()
end)

RegisterNUICallback('ToggleMapBorders', function()
    Wait(50)
    Menu.isToggleMapBordersChecked = not Menu.isToggleMapBordersChecked
    if Menu.isToggleMapBordersChecked == false then
        showSquareB = false
        showCircleB = false
    elseif Menu.isToggleMapBordersChecked == true then 
        if Menu.isToggleMapShapeChecked == "square" then
            showSquareB = true
        else 
            showCircleB = true
        end
    end
    TriggerEvent("hud:client:playHudChecklistSound")
    saveSettings()
end)

RegisterNUICallback('dynamicEngine', function()
    Wait(50)
    Menu.isDynamicEngineChecked = not Menu.isDynamicEngineChecked
    TriggerEvent("hud:client:playHudChecklistSound")
    saveSettings()
end) 
 
RegisterNUICallback('dynamicNitro', function()
    Wait(50)
    Menu.isDynamicNitroChecked = not Menu.isDynamicNitroChecked
    TriggerEvent("hud:client:playHudChecklistSound")
    saveSettings()
end) 

RegisterNUICallback('cinematicMode', function()
    Wait(50)
    if Menu.isCineamticModeChecked == true then
        CinematicShow(false)
        Menu.isCineamticModeChecked = false
        if Menu.isCinematicNotifChecked == true then
            TriggerEvent('QBCore:Notify', Lang:t("notify.cinematic_off"), 'error')
        end
        DisplayRadar(1)
    elseif Menu.isCineamticModeChecked == false then
        CinematicShow(true)
        Menu.isCineamticModeChecked = true
        if Menu.isCinematicNotifChecked == true then
            TriggerEvent('QBCore:Notify', Lang:t("notify.cinematic_on"))
        end
    end
    TriggerEvent("hud:client:playHudChecklistSound")
    saveSettings()
end) 

RegisterNetEvent("hud:client:EngineHealth", function(newEngine)
    engine = newEngine
end)

RegisterNetEvent('hud:client:ToggleAirHud', function()
    showAltitude = not showAltitude
end)

RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst) -- Triggered in qb-core
    hunger = newHunger
    thirst = newThirst
end)

RegisterNetEvent('hud:client:UpdateStress', function(newStress) -- Add this event with adding stress elsewhere
    stress = newStress
end)

RegisterNetEvent('hud:client:ToggleShowSeatbelt', function()
    showSeatbelt = not showSeatbelt
end)

RegisterNetEvent('seatbelt:client:ToggleSeatbelt', function() -- Triggered in smallresources
    seatbeltOn = not seatbeltOn
end)

RegisterNetEvent('seatbelt:client:ToggleCruise', function() -- Triggered in smallresources
    cruiseOn = not cruiseOn
end)

RegisterNetEvent('hud:client:UpdateNitrous', function(hasNitro, nitroLevel, bool)
    nos = nitroLevel
    nitroActive = bool
end)

RegisterNetEvent('hud:client:UpdateHarness', function(harnessHp)
    hp = harnessHp
end)

RegisterNetEvent("qb-admin:client:ToggleDevmode", function()
    dev = not dev
end)

RegisterCommand('+engine', function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle ~= nil and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, 0) then
        if (GetIsVehicleEngineRunning(vehicle)) then
            QBCore.Functions.Notify(Lang:t("notify.engine_off"), "error")
        else
            QBCore.Functions.Notify(Lang:t("notify.engine_on"))
        end
        SetVehicleEngineOn(vehicle, (not GetIsVehicleEngineRunning(vehicle)), false, true)
    end
end)

RegisterKeyMapping('+engine', 'Toggle Engine', 'keyboard', 'G')

local function IsWhitelistedWeaponArmed(weapon)
    if weapon ~= nil then
        for _, v in pairs(config.WhitelistedWeaponArmed) do
            if weapon == GetHashKey(v) then
                return true
            end
        end
    end
    return false
end

local prevPlayerStats = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }

local function updatePlayerHud(data)
    local shouldUpdate = false
    for k, v in pairs(data) do
        if prevPlayerStats[k] ~= v then
            shouldUpdate = true
            break
        end
    end
    prevPlayerStats = data
    if shouldUpdate then
        SendNUIMessage({
            action = 'hudtick',
            show = data[1],
            dynamicHealth = data[2],
            dynamicArmor = data[3],
            dynamicHunger = data[4],
            dynamicThirst = data[5],
            dynamicStress = data[6],
            dynamicOxygen = data[7],
            dynamicEngine = data[8],
            dynamicNitro = data[9],
            health = data[10],
            playerDead = data[11],
            armor = data[12],
            thirst = data[13],
            hunger = data[14],
            stress = data[15],
            voice = data[16],
            radio = data[17],
            talking = data[18],
            armed = data[19],
            oxygen = data[20],
            parachute = data[21],
            nos = data[22],
            cruise = data[23],
            nitroActive = data[24],
            harness = data[25],
            hp = data[26],
            speed = data[27],
            engine = data[28],
            cinematic = data[29],
            dev = data[30],
        })
    end
end

local prevVehicleStats = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil }

local function updateVehicleHud(data)
    local shouldUpdate = false
    for k, v in pairs(data) do
        if prevVehicleStats[k] ~= v then shouldUpdate = true break end
    end
    prevVehicleStats = data
    if shouldUpdate then
        SendNUIMessage({
            action = 'car',
            show = data[1],
            isPaused = data[2],
            seatbelt = data[3],
            speed = data[4],
            fuel = data[5],
            altitude = data[6],
            showAltitude = data[7],
            showSeatbelt = data[8],
            showSquareB = data[9],
            showCircleB = data[10],
        })
    end
end

local lastFuelUpdate = 0
local lastFuelCheck = {}

local function getFuelLevel(vehicle)
    local updateTick = GetGameTimer()
    if (updateTick - lastFuelUpdate) > 2000 then
        lastFuelUpdate = updateTick
        lastFuelCheck = math.floor(exports['LegacyFuel']:GetFuel(vehicle))
    end
    return lastFuelCheck
end

-- HUD Update loop

CreateThread(function()
    local wasInVehicle = false;
    while true do
        if Menu.isChangeFPSChecked == true then
            Wait(500)
        elseif Menu.isChangeFPSChecked == false then
            Wait(50)
        end
        if LocalPlayer.state.isLoggedIn then
            local show = true  
            local player = PlayerPedId()
            local weapon = GetSelectedPedWeapon(player)
            -- player hud
            if not IsWhitelistedWeaponArmed(weapon) then
                if weapon ~= `WEAPON_UNARMED` then
                    armed = true
                else
                    armed = false
                end
            end
            if IsPedDeadOrDying(player) or QBCore.Functions.GetPlayerData().metadata["inlaststand"] then
                playerDead=true
        
            else
                playerDead=false
            end    
            parachute = GetPedParachuteState(PlayerPedId())
            -- stamina
            if not IsEntityInWater(PlayerPedId()) then
                oxygen = 100 - GetPlayerSprintStaminaRemaining(PlayerId())  
            end
            -- oxygen
            if IsEntityInWater(PlayerPedId()) then
                oxygen = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10
            end
            -- player hud
            local talking = NetworkIsPlayerTalking(PlayerId())
            local voice = 0
            if LocalPlayer.state['proximity'] ~= nil then
                voice = LocalPlayer.state['proximity'].distance
            end
            if IsPauseMenuActive() then
                show = false
            end
            if not ( IsPedInAnyVehicle(player) and not IsThisModelABicycle(vehicle) ) then
            updatePlayerHud({
                show, 
                Menu.isDynamicHealthChecked,
                Menu.isDynamicArmorChecked,
                Menu.isDynamicHungerChecked,
                Menu.isDynamicThirstChecked,
                Menu.isDynamicStressChecked,
                Menu.isDynamicOxygenChecked,
                Menu.isDynamicEngineChecked,
                Menu.isDynamicNitroChecked,
                GetEntityHealth(player) - 100,
                playerDead,
                GetPedArmour(player),
                thirst,
                hunger,
                stress,
                voice,
                LocalPlayer.state['radioChannel'],
                talking,
                armed,
                oxygen,
                GetPedParachuteState(player),
                -1,
                cruiseOn,
                nitroActive,
                harness,
                hp,
                math.ceil(GetEntitySpeed(vehicle) * speedMultiplier),
                -1,
                Menu.isCineamticModeChecked,
                dev,
            }) 
            end
            -- vehcle hud
            local vehicle = GetVehiclePedIsIn(player)
            if IsPedInAnyHeli(player) or IsPedInAnyPlane(player) then
                showAltitude = true
                showSeatbelt = false
            end
            if IsPedInAnyVehicle(player) and not IsThisModelABicycle(vehicle) then
                if not wasInVehicle then
                    DisplayRadar(true)
                end
                wasInVehicle = true
                QBCore.Functions.TriggerCallback('hud:server:HasHarness', function(hasItem)
                    if hasItem then
                        harness = true
                    else
                        harness = false
                    end
                end, "harness")
                updatePlayerHud({
                    show, 
                    Menu.isDynamicHealthChecked,
                    Menu.isDynamicArmorChecked,
                    Menu.isDynamicHungerChecked,
                    Menu.isDynamicThirstChecked,
                    Menu.isDynamicStressChecked,
                    Menu.isDynamicOxygenChecked,
                    Menu.isDynamicEngineChecked,
                    Menu.isDynamicNitroChecked,
                    GetEntityHealth(player) - 100,
                    playerDead,
                    GetPedArmour(player),
                    thirst,
                    hunger,
                    stress,
                    voice,
                    LocalPlayer.state['radioChannel'],
                    talking,
                    armed,
                    oxygen,
                    GetPedParachuteState(player),
                    nos,
                    cruiseOn,
                    nitroActive,
                    harness,
                    hp,
                    math.ceil(GetEntitySpeed(vehicle) * speedMultiplier),
                    (GetVehicleEngineHealth(vehicle) /10),
                    Menu.isCineamticModeChecked,
                    dev,
                })
                updateVehicleHud({
                    show,
                    IsPauseMenuActive(),
                    seatbeltOn,
                    math.ceil(GetEntitySpeed(vehicle) * speedMultiplier),
                    getFuelLevel(vehicle),
                    math.ceil((GetEntityCoords(player).z *.5)),
                    showAltitude,
                    showSeatbelt,
                    showSquareB,
                    showCircleB,
                })
                showAltitude = false
                showSeatbelt = true
            else
                if wasInVehicle then
                    wasInVehicle = false
                    SendNUIMessage({
                        action = 'car',
                        show = false,
                        seatbelt = false,
                        cruise = false,
                    })
                    seatbeltOn = false
                    cruiseOn = false
                    harness = false
                end
                if Menu.isOutMapChecked == false then
                    DisplayRadar(false)
                else
                    DisplayRadar(true)
                end
            end
        else
            SendNUIMessage({
                action = 'hudtick',
                show = false
            })
        end
    end
end)

-- low fuel
CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                if exports['LegacyFuel']:GetFuel(GetVehiclePedIsIn(PlayerPedId(), false)) <= 20 then -- At 20% Fuel Left
                    if Menu.isLowFuelChecked == true then
                        TriggerServerEvent("InteractSound_SV:PlayOnSource", "pager", 0.10)
                        TriggerEvent('QBCore:Notify', Lang:t("notify.low_fuel"), "error")
                        Wait(60000) -- repeats every 1 min until empty
                    end
                end
            end
        end
        Wait(10000)
    end
end)

-- Money HUD

RegisterNetEvent('hud:client:ShowAccounts')
AddEventHandler('hud:client:ShowAccounts', function(type, amount)
    if type == 'cash' then
        SendNUIMessage({
            action = 'show',
            type = 'cash',
            cash = amount
        })
    else
        SendNUIMessage({
            action = 'show',
            type = 'bank',
            bank = amount
        })
    end
end)

RegisterNetEvent('hud:client:OnMoneyChange')
AddEventHandler('hud:client:OnMoneyChange', function(type, amount, isMinus)
    QBCore.Functions.GetPlayerData(function(PlayerData)
        cashAmount = PlayerData.money['cash']
        bankAmount = PlayerData.money['bank']
    end)
    SendNUIMessage({
        action = 'update',
        cash = cashAmount,
        bank = bankAmount,
        amount = amount,
        minus = isMinus,
        type = type
    })
end)

-- Stress Gain

CreateThread(function() -- Speeding
    while true do
        if LocalPlayer.state.isLoggedIn then
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                local speed = GetEntitySpeed(GetVehiclePedIsIn(ped, false)) * speedMultiplier
                local stressSpeed = seatbeltOn and config.MinimumSpeed or config.MinimumSpeedUnbuckled
                if speed >= stressSpeed then
                    TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                end
            end
        end
        Wait(10000)
    end
end)

local function IsWhitelistedWeaponStress(weapon)
    if weapon ~= nil then
        for _, v in pairs(config.WhitelistedWeaponStress) do
            if weapon == GetHashKey(v) then
                return true
            end
        end
    end
    return false
end

CreateThread(function() -- Shooting
    while true do
        if LocalPlayer.state.isLoggedIn then
            local ped = PlayerPedId()
            local weapon = GetSelectedPedWeapon(ped)
            if weapon ~= `WEAPON_UNARMED` then
                if IsPedShooting(ped) and not IsWhitelistedWeaponStress(weapon) then
                    if math.random() < config.StressChance then
                        TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                    end
                end
            else
                Wait(1000)
            end
        end
        Wait(8)
    end
end)

-- Stress Screen Effects

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if stress >= 100 then
            local ShakeIntensity = GetShakeIntensity(stress)
            local FallRepeat = math.random(2, 4)
            local RagdollTimeout = (FallRepeat * 1750)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
            SetFlash(0, 0, 500, 3000, 500)

            if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
                SetPedToRagdollWithFall(ped, RagdollTimeout, RagdollTimeout, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            end

            Wait(1000)
            for i=1, FallRepeat, 1 do
                Wait(750)
                DoScreenFadeOut(200)
                Wait(1000)
                DoScreenFadeIn(200)
                ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
                SetFlash(0, 0, 200, 750, 200)
            end
        elseif stress >= config.MinimumStress then
            local ShakeIntensity = GetShakeIntensity(stress)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', ShakeIntensity)
            SetFlash(0, 0, 500, 2500, 500)
        end
        Wait(GetEffectInterval(stress))
    end
end)

function GetShakeIntensity(stresslevel)
    local retval = 0.05
    for k, v in pairs(config.Intensity['shake']) do
        if stresslevel >= v.min and stresslevel <= v.max then
            retval = v.intensity
            break
        end
    end
    return retval
end

function GetEffectInterval(stresslevel)
    local retval = 60000
    for k, v in pairs(config.EffectInterval) do
        if stresslevel >= v.min and stresslevel <= v.max then
            retval = v.timeout
            break
        end
    end
    return retval
end

-- minimap update
Citizen.CreateThread(function()
    while true do
        Wait(500)
        local player = PlayerPedId()
        SetRadarZoom(1000)
        SetRadarBigmapEnabled(false, false)
    end
end)

-- cinematic mode
CinematicHeight = 0.2
CinematicModeOn = false
w = 0

function CinematicShow(bool)
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)
    if bool then
        for i = CinematicHeight, 0, -1.0 do
            Wait(10)
            w = i
        end 
    else
        for i = 0, CinematicHeight, 1.0 do 
            Wait(10)
            w = i
        end
    end
end

Citizen.CreateThread(function()
    minimap = RequestScaleformMovie("minimap")
    if not HasScaleformMovieLoaded(minimap) then
        RequestScaleformMovie(minimap)
        while not HasScaleformMovieLoaded(minimap) do 
            Wait(1)
        end
    end
    while true do
        Citizen.Wait(0)
        if w > 0 then
            BlackBars()
            DisplayRadar(0)
            SendNUIMessage({
                action = 'hudtick',
                show = false,
            })
            SendNUIMessage({
                action = 'car',
                show = false,
            })
        end
    end
end)

function BlackBars()
    DrawRect(0.0, 0.0, 2.0, w, 0, 0, 0, 255)
    DrawRect(0.0, 1.0, 2.0, w, 0, 0, 0, 255)
end
