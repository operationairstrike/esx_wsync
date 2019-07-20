CurrentWeather = 'EXTRASUNNY'
local lastWeather = CurrentWeather
local baseTime = 0
local timeOffset = 0
local timer = 0
local freezeTime = false
local blackout = false

RegisterNetEvent('es_wsync:updateWeather')
AddEventHandler('es_wsync:updateWeather', function(NewWeather, newblackout)
	CurrentWeather = NewWeather
	blackout = newblackout
end)

function changeWeather(weather)
	if lastWeather == weather then
		return
	end

	ClearWeatherTypePersist()
	ClearOverrideWeather()
	SetWeatherTypeOverTime(weather, 15.0)
	Citizen.Wait(14990)
	SetOverrideWeather(weather)

	if CurrentWeather == 'XMAS' then
		SetForceVehicleTrails(true)
		SetForcePedFootstepsTracks(true)
	else
		SetForceVehicleTrails(false)
		SetForcePedFootstepsTracks(false)
	end

	lastWeather = weather
end

Citizen.CreateThread(function()
	while true do
		changeWeather(CurrentWeather)
		Citizen.Wait(100)
	end
end)

RegisterNetEvent('es_wsync:updateTime')
AddEventHandler('es_wsync:updateTime', function(base, offset, freeze)
	freezeTime = freeze
	timeOffset = offset
	baseTime = base
end)

Citizen.CreateThread(function()
	local hour = 0
	local minute = 0
	while true do
		Citizen.Wait(0)
		local newBaseTime = baseTime
		if GetGameTimer() - 500  > timer then
			newBaseTime = newBaseTime + 0.25
			timer = GetGameTimer()
		end
		if freezeTime then
			timeOffset = timeOffset + baseTime - newBaseTime
		end
		baseTime = newBaseTime
		hour = math.floor(((baseTime+timeOffset)/60)%24)
		minute = math.floor((baseTime+timeOffset)%60)
		NetworkOverrideClockTime(hour, minute, 0)
	end
end)

AddEventHandler('playerSpawned', function()
	TriggerServerEvent('es_wsync:requestSync')
end)
