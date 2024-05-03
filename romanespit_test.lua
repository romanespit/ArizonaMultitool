script_author("romanespit")
script_name("{3B66C5}romanespit")
script_version("1.32")
------------------------
local scr = thisScript()
local hook = require 'lib.samp.events'
local encoding = require('encoding')
local dlstatus = require("moonloader").download_status
local imgui = require 'mimgui'
local ffi = require 'ffi'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local effil_check, effil = pcall(require, 'effil')
local inicfg = require 'inicfg'
local faicons = require('fAwesome6')
local settings = inicfg.load({
    main = {
        TelegramToken = "",
		TelegramChat = "",
		PhNumber = "",
		PhNumberVice = "",
		TelegramNotifications = false,
		logging = 0,
		qb = false,
		kirka = false,
		bomj = false,
		lavka = false,
		autoeat = false,
		bankPin = ""
    },
	AdvokatHelper = {
		adhSendOriginalMessage = true,
		adhAutoUpdate = false,
		adhTurnedOn = false,
		adhUpdateTime = 30
	},
	climate = {
		TimeValue = 12,
		TimeLock = false,
		WeatherValue = 1,
		WeatherLock = false
	},
	cases = {
		isTurned = true,
		Default = -1,
		Platinum = -1,
		Elon = -1
	},
	clearMem = {
		AutoCleaner = false
	}
}, 'rmnspt\\settings')
------------------------

CR_AREA = {
	1095, -1472, -- [A]
	1165, -1424  -- [B]
	-- Vice
}
MARKERS = {}

COLOR_MAIN = '{3B66C5}'
SCRIPT_COLOR = 0xFF3B66C5
COLOR_YES = '{36c500}'
COLOR_NO = '{FF6A57}'
COLOR_WHITE = '{ffffff}'
SCRIPT_PREFIX = '[ romanespit ]{FFFFFF}: '
font = renderCreateFont("Trebuchet MS", 12, 5)
timer = -1
zeksText = 'Пусто'
zeki = {}
myid = -1
newversion = ""
caseTimers = {settings.cases.Default,settings.cases.Platinum,settings.cases.Elon}
caseName = {"рулетки","платиновой рулетки","Илона Маска"}
myNick = ""
-- time/weather
local memory = require "memory"
local actual = {
	time = memory.getint8(0xB70153),
	weather = memory.getint16(0xC81320)
}
--- mimgui
local new, str = imgui.new, ffi.string
local WinState = new.bool()
local WinUpdState = new.bool()
local imQuestBots = new.bool(settings.main.qb)
local imQuestBomj = new.bool(settings.main.bomj)
local imLavka = new.bool(settings.main.lavka)
local imKirka = new.bool(settings.main.kirka)
local imAutoClean = new.bool(settings.clearMem.AutoCleaner)
local imAutoeat = new.bool(settings.main.autoeat)
local imCaseAlert = new.bool(settings.cases.isTurned)
local imAdhAutoUpdate = new.bool(settings.AdvokatHelper.adhAutoUpdate)
local imAdhSendOriginalMessage = new.bool(settings.AdvokatHelper.adhSendOriginalMessage)
local imAdhTurnedOn = new.bool(settings.AdvokatHelper.adhTurnedOn)
local imAdhUpdateTime = new.int(settings.AdvokatHelper.adhUpdateTime)

local imClTimeLock = new.bool(settings.climate.TimeLock)
local imClTimeValue = new.int(settings.climate.TimeValue)
local imClWeatherLock = new.bool(settings.climate.WeatherLock)
local imClWeatherValue = new.int(settings.climate.WeatherValue)
local imWeatherNameList = {
	u8'EXTRASUNNY_LA',
	u8'SUNNY_LA',
	u8'EXTRASUNNY_SMOG_LA',
	u8'SUNNY_SMOG_LA',
	u8'CLOUDY_LA',
	u8'SUNNY_SF',
	u8'EXTRASUNNY_SF',
	u8'CLOUDY_SF',
	u8'RAINY_SF',
	u8'FOGGY_SF',
	u8'SUNNY_VEGAS',
	u8'EXTRASUNNY_VEGAS (heat waves)',
	u8'CLOUDY_VEGAS',
	u8'EXTRASUNNY_COUNTRYSIDE',
	u8'SUNNY_COUNTRYSIDE',
	u8'CLOUDY_COUNTRYSIDE',
	u8'RAINY_COUNTRYSIDE',
	u8'EXTRASUNNY_DESERT',
	u8'SUNNY_DESERT',
	u8'SANDSTORM_DESERT',
	u8'UNDERWATER (greenish, foggy)',
	u8'Unnamed Weather'
}
local imWeatherName = imWeatherNameList[1]

local imLoggingCombo = new.int(settings.main.logging)
local imLoggingList = {u8'Выключено', u8'В консоль SAMPFUNCS', u8'В игровой чат', u8'И в консоль, и в чат'}
local imLoggingItems = imgui.new['const char*'][#imLoggingList](imLoggingList)
local imPhNumber = new.char[256](u8(settings.main.PhNumber))
local imPhNumberVice = new.char[256](u8(settings.main.PhNumberVice))
local imTelegramChat = new.char[256](u8(settings.main.TelegramChat))
local imTelegramToken = new.char[256](u8(settings.main.TelegramToken))
local imBankPin = new.char[256](u8(settings.main.bankPin))
local imTelegramNotifications = new.bool(settings.main.TelegramNotifications)

function onScriptTerminate(scr, is_quit)
	if scr == thisScript() then
		settings.cases.Default = caseTimers[1]
		settings.cases.Platinum = caseTimers[2]
		settings.cases.Elon = caseTimers[3]
		inicfg.save(settings, 'rmnspt\\settings')
		for handle, _ in pairs(MARKERS) do
			removeUser3dMarker(handle)
			MARKERS[handle] = nil
		end
	end
end

function hook.onSendSpawn()
	_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	myNick = sampGetPlayerNickname(myid)
end
imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solid'), 14, config, iconRanges)
end)
imgui.OnFrame(function() return WinUpdState[0] end,
	function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(500, 320), imgui.Cond.Always)
		imgui.Begin(faicons('poo')..u8'Есть обновление до версии v'..newversion, WinUpdState, imgui.WindowFlags.AlwaysAutoResize+imgui.WindowFlags.NoCollapse)
		imgui.End()
    end
)
imgui.OnFrame(function() return WinState[0] end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(500, 320), imgui.Cond.Always)
        imgui.Begin(faicons('poo')..u8' romanespit Arizona Multitool v'..scr.version, WinState, imgui.WindowFlags.AlwaysAutoResize+imgui.WindowFlags.NoCollapse)
		if imgui.CollapsingHeader(faicons('gear')..u8" Основные") then
			imgui.Text(faicons('gear'))
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.Text(u8'Нажмите, чтобы скопировать команду в чат')
				imgui.EndTooltip()
			end 
			if imgui.IsItemClicked() then sampSetChatInputEnabled(true) sampSetChatInputText('/setpin ') end
			imgui.SameLine()
			imgui.Text(u8"PIN: ")
			imgui.SameLine()
			imgui.TextDisabled(u8(settings.main.bankPin))
			
			imgui.Text(faicons('gear'))
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.Text(u8'Нажмите, чтобы скопировать команду в чат')
				imgui.EndTooltip()
			end 
			if imgui.IsItemClicked() then sampSetChatInputEnabled(true) sampSetChatInputText('/setphone ') end
			imgui.SameLine()
			imgui.Text(u8"Номер телефона SA: ")
			imgui.SameLine()
			imgui.TextDisabled(u8(settings.main.PhNumber))	
			imgui.SameLine()
			imgui.Text(faicons('question'))
			if imgui.IsItemClicked() then
				sampAddChatMessage(SCRIPT_PREFIX .."Вы можете писать в чат "..COLOR_YES.."(alo)"..COLOR_WHITE.." или "..COLOR_YES.."(алло)"..COLOR_WHITE.." - текст будет заменен на указанный номер", SCRIPT_COLOR)
				sampAddChatMessage(SCRIPT_PREFIX .."Также вы можете написать "..COLOR_YES.."(id)"..COLOR_WHITE.." или "..COLOR_YES.."(ид)"..COLOR_WHITE.." - будет подставлен ваш ID", SCRIPT_COLOR)
			end

			imgui.Text(faicons('gear'))
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.Text(u8'Нажмите, чтобы скопировать команду в чат')
				imgui.EndTooltip()
			end 
			if imgui.IsItemClicked() then sampSetChatInputEnabled(true) sampSetChatInputText('/setphonevc ') end
			imgui.SameLine()
			imgui.Text(u8"Номер телефона VC: ")
			imgui.SameLine()
			imgui.TextDisabled(u8(settings.main.PhNumberVice))	
			imgui.SameLine()
			imgui.Text(faicons('question'))
			if imgui.IsItemClicked() then
				sampAddChatMessage(SCRIPT_PREFIX .."Вы можете писать в чат "..COLOR_YES.."(alo)"..COLOR_WHITE.." или "..COLOR_YES.."(алло)"..COLOR_WHITE.." - текст будет заменен на указанный номер", SCRIPT_COLOR)
				sampAddChatMessage(SCRIPT_PREFIX .."Также вы можете написать "..COLOR_YES.."(id)"..COLOR_WHITE.." или "..COLOR_YES.."(ид)"..COLOR_WHITE.." - будет подставлен ваш ID", SCRIPT_COLOR)
			end
				--
			if imgui.Checkbox(u8'Уведомления о кейсах '..faicons('gem'), imCaseAlert) then
				settings.cases.isTurned = not settings.cases.isTurned
				inicfg.save(settings, 'rmnspt\\settings')
				if settings.cases.isTurned then
					sampAddChatMessage(SCRIPT_PREFIX .."Уведомления о кейсах ".. COLOR_YES .."включены", SCRIPT_COLOR)
				else
					sampAddChatMessage(SCRIPT_PREFIX .."Уведомления о кейсах ".. COLOR_NO .."выключены", SCRIPT_COLOR)
				end
			end
			if imgui.Checkbox(u8'Авто /jmeat '..faicons('burger'), imAutoeat) then
				settings.main.autoeat = not settings.main.autoeat
				inicfg.save(settings, 'rmnspt\\settings')
				if settings.main.autoeat then
					sampAddChatMessage(SCRIPT_PREFIX .."Авто /jmeat ".. COLOR_YES .."включен", SCRIPT_COLOR)
				else
					sampAddChatMessage(SCRIPT_PREFIX .."Авто /jmeat ".. COLOR_NO .."выключен", SCRIPT_COLOR)
				end
			end
			if imgui.Checkbox(u8'Квестовые боты '..faicons('robot'), imQuestBots) then
				settings.main.qb = not settings.main.qb
				inicfg.save(settings, 'rmnspt\\settings')
				if settings.main.qb then
					sampAddChatMessage(SCRIPT_PREFIX .."Квестовые боты ".. COLOR_YES .."показываются", SCRIPT_COLOR)
				else
					sampAddChatMessage(SCRIPT_PREFIX .."Квестовые боты ".. COLOR_NO .."не показываются", SCRIPT_COLOR)
				end
			end
			if imgui.Checkbox(u8'Квестовые бомжи '..faicons('robot'), imQuestBomj) then
				settings.main.bomj = not settings.main.bomj
				inicfg.save(settings, 'rmnspt\\settings')
				if settings.main.bomj then
					sampAddChatMessage(SCRIPT_PREFIX .."Квестовые бомжи ".. COLOR_YES .."показываются", SCRIPT_COLOR)
				else
					sampAddChatMessage(SCRIPT_PREFIX .."Квестовые бомжи ".. COLOR_NO .."не показываются", SCRIPT_COLOR)
				end
			end
			if imgui.Checkbox(u8'Рендер руды '..faicons('gem'), imKirka) then
				settings.main.kirka = not settings.main.kirka
				inicfg.save(settings, 'rmnspt\\settings')
				if settings.main.kirka then
					sampAddChatMessage(SCRIPT_PREFIX .."Рендер руды ".. COLOR_YES .."включен", SCRIPT_COLOR)
				else
					sampAddChatMessage(SCRIPT_PREFIX .."Рендер руды ".. COLOR_NO .."выключен", SCRIPT_COLOR)
				end
			end
			if imgui.Checkbox(u8'Автоочистка памяти '..faicons('trash'), imAutoClean) then
				settings.clearMem.AutoCleaner = not settings.clearMem.AutoCleaner
				inicfg.save(settings, 'rmnspt\\settings')
				if settings.clearMem.AutoCleaner then
					sampAddChatMessage(SCRIPT_PREFIX .."Автоочистка памяти by Azller Lollison ".. COLOR_YES .."включена", SCRIPT_COLOR)
				else
					sampAddChatMessage(SCRIPT_PREFIX .."Автоочистка памяти by Azller Lollison ".. COLOR_NO .."выключена", SCRIPT_COLOR)
				end
			end
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.Text(u8'Автор: Azller Lollison')
				imgui.EndTooltip()
			end
			if imgui.Checkbox(u8'Уведомления о свободных лавках '..faicons('store'), imLavka) then
				settings.main.lavka = not settings.main.lavka
				inicfg.save(settings, 'rmnspt\\settings')
				if settings.main.lavka then
					sampAddChatMessage(SCRIPT_PREFIX .."Уведомления о лавках ".. COLOR_YES .."включены", SCRIPT_COLOR)
				else
					sampAddChatMessage(SCRIPT_PREFIX .."Уведомления о лавках ".. COLOR_NO .."выключены", SCRIPT_COLOR)
				end
			end
			if imgui.Combo(u8'Логирование '..faicons('pen'),imLoggingCombo,imLoggingItems, #imLoggingList) then
				settings.main.logging = imLoggingCombo[0]
				inicfg.save(settings, 'rmnspt\\settings')
				if settings.main.logging == 1 then
					sampAddChatMessage(SCRIPT_PREFIX .."Логирование скрипта ".. COLOR_YES .."включено в консоль", SCRIPT_COLOR)
				elseif settings.main.logging == 2 then
					sampAddChatMessage(SCRIPT_PREFIX .."Логирование скрипта ".. COLOR_YES .."включено в чат", SCRIPT_COLOR)
				elseif settings.main.logging == 3 then
					sampAddChatMessage(SCRIPT_PREFIX .."Логирование скрипта ".. COLOR_YES .."и в консоль, и в чат", SCRIPT_COLOR)
				elseif settings.main.logging == 0 then
					sampAddChatMessage(SCRIPT_PREFIX .."Логирование скрипта ".. COLOR_NO .."выключено", SCRIPT_COLOR)
				end
			end
		end
		imgui.Separator()
		if imgui.CollapsingHeader(faicons('clock')..faicons('cloud')..u8" Управление временем/погодой") then
			if imgui.Checkbox(u8'Блокировать изменение времени', imClTimeLock) then
				settings.climate.TimeLock = not settings.climate.TimeLock
				inicfg.save(settings, 'rmnspt\\settings')
				if settings.climate.TimeLock then
					sampAddChatMessage(SCRIPT_PREFIX .."Изменение времени сервером ".. COLOR_NO .."заблокировано", SCRIPT_COLOR)
				else
					sampAddChatMessage(SCRIPT_PREFIX .."Изменение времени сервером ".. COLOR_YES .."разблокировано", SCRIPT_COLOR)
				end
			end
			if imgui.SliderInt(u8'Установить время', imClTimeValue, 0, 23) then
				setWorldTime(imClTimeValue[0])
			end
			imgui.SameLine()
			imgui.Text(faicons('rotate'))
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.Text(u8'Изменить время на серверное: '..tostring(actual.time))
				imgui.EndTooltip()
			end
			if imgui.IsItemClicked() then 
				setWorldTime("off")
				imClTimeValue[0] = actual.time
				sampAddChatMessage(SCRIPT_PREFIX .."Время изменено на серверное: ".. COLOR_YES ..tostring(actual.time), SCRIPT_COLOR)
			end
			if imgui.Checkbox(u8'Блокировать изменение погоды', imClWeatherLock) then
				settings.climate.WeatherLock = not settings.climate.WeatherLock
				inicfg.save(settings, 'rmnspt\\settings')
				if settings.climate.WeatherLock then
					sampAddChatMessage(SCRIPT_PREFIX .."Изменение погоды сервером ".. COLOR_NO .."заблокировано", SCRIPT_COLOR)
				else
					sampAddChatMessage(SCRIPT_PREFIX .."Изменение погоды сервером ".. COLOR_YES .."разблокировано", SCRIPT_COLOR)
				end
			end
			if imgui.SliderInt(u8'Установить погоду', imClWeatherValue, 0, 45) then				
				setWorldWeather(imClWeatherValue[0])
			end
			imgui.SameLine()
			imgui.Text(faicons('rotate'))
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.Text(u8'Изменить погоду на серверную: ID '..tostring(actual.weather))
				imgui.EndTooltip()
			end
			if imgui.IsItemClicked() then 
				setWorldWeather("off")
				imClWeatherValue[0] = actual.weather
				sampAddChatMessage(SCRIPT_PREFIX .."Погода изменена на серверную: ID ".. COLOR_YES ..tostring(actual.weather), SCRIPT_COLOR)
			end
			imgui.TextDisabled(u8(imWeatherName))	
		end
		imgui.Separator()
		if imgui.CollapsingHeader(faicons('suitcase')..u8" Job Helper") then
			if imgui.BeginTabBar('Tabs') then --   
				if imgui.BeginTabItem(u8'Адвокат (не воркает)') then --  
					if imgui.Checkbox(u8'Включить', imAdhTurnedOn) then
						settings.AdvokatHelper.adhTurnedOn = not settings.AdvokatHelper.adhTurnedOn
						inicfg.save(settings, 'rmnspt\\settings')
						zeki = {}
						if settings.AdvokatHelper.adhTurnedOn then
							sampAddChatMessage(SCRIPT_PREFIX .."Advokat Helper ".. COLOR_YES .."включен", SCRIPT_COLOR)
							if settings.AdvokatHelper.adhAutoUpdate then
								local nowTime = os.time()
								timer = nowTime + 5
							else
								timer = -1
							end
						else
							sampAddChatMessage(SCRIPT_PREFIX .."Advokat Helper ".. COLOR_NO .."выключен", SCRIPT_COLOR)
							if settings.AdvokatHelper.adhAutoUpdate then
								local nowTime = os.time()
								timer = nowTime + 5
							else
								timer = -1
							end
						end
					end
					--
					if imAdhTurnedOn[0] then
						if imgui.Checkbox(u8'Автообновление КПЗ', imAdhAutoUpdate) then
							settings.AdvokatHelper.adhAutoUpdate = not settings.AdvokatHelper.adhAutoUpdate
							if settings.AdvokatHelper.adhAutoUpdate then
								sampAddChatMessage(SCRIPT_PREFIX .."Автообновление КПЗ ".. COLOR_YES .."включено", SCRIPT_COLOR)					
								local nowTime = os.time()
								timer = nowTime + 5
							else
								sampAddChatMessage(SCRIPT_PREFIX .."Автообновление КПЗ ".. COLOR_NO .."выключено", SCRIPT_COLOR)
								timer = -1
							end	
							inicfg.save(settings, 'rmnspt\\settings')			
						end
						if imAdhAutoUpdate[0] then
							if imgui.SliderInt(u8'Период автообновления (сек)', imAdhUpdateTime, 15, 120) then
								settings.AdvokatHelper.adhUpdateTime = imAdhUpdateTime[0]
								local nowTime = os.time()
								timer = nowTime + settings.AdvokatHelper.adhUpdateTime
								inicfg.save(settings, 'rmnspt\\settings')
							end
							imgui.SameLine()
							imgui.Text(faicons('rotate'))
							if imgui.IsItemHovered() then
								imgui.BeginTooltip()
								imgui.Text(u8'Нажмите, чтобы вернуть стандартное значение')
								imgui.EndTooltip()
							end
							if imgui.IsItemClicked() then 
								imAdhUpdateTime[0] = 30
								local nowTime = os.time()
								settings.AdvokatHelper.adhUpdateTime = imAdhUpdateTime[0]
								timer = nowTime + settings.AdvokatHelper.adhUpdateTime
								inicfg.save(settings, 'rmnspt\\settings')
							end
						end					
						if imgui.Checkbox(u8'Получение ответов на /zeks', imAdhSendOriginalMessage) then
							settings.AdvokatHelper.adhSendOriginalMessage = not settings.AdvokatHelper.adhSendOriginalMessage
							inicfg.save(settings, 'rmnspt\\settings')
							if settings.AdvokatHelper.adhSendOriginalMessage then
								sampAddChatMessage(SCRIPT_PREFIX .."Получение ответов на /zeks ".. COLOR_YES .."включены", SCRIPT_COLOR)
							else
								sampAddChatMessage(SCRIPT_PREFIX .."Получение ответов на /zeks ".. COLOR_NO .."выключены", SCRIPT_COLOR)
							end
						end
					end
					imgui.EndTabItem()
				end
				imgui.EndTabBar()
			end
		end
		imgui.Separator()
		if imgui.CollapsingHeader(faicons('envelope')..u8" Настройки уведомлений Telegram") then
			if imgui.Checkbox(u8'Уведомления в Telegram', imTelegramNotifications) then
				settings.main.TelegramNotifications = not settings.main.TelegramNotifications
				inicfg.save(settings, 'rmnspt\\settings')
				if settings.main.TelegramNotifications then
					sampAddChatMessage(SCRIPT_PREFIX .."Уведомления в Telegram ".. COLOR_YES .."включены", SCRIPT_COLOR)
				else
					sampAddChatMessage(SCRIPT_PREFIX .."Уведомления в Telegram ".. COLOR_NO .."выключены", SCRIPT_COLOR)
				end
			end
			if imTelegramNotifications[0] then
				imgui.Text(faicons('gear'))
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.Text(u8'Нажмите, чтобы скопировать команду в чат')
					imgui.EndTooltip()
				end 
				if imgui.IsItemClicked() then sampSetChatInputEnabled(true) sampSetChatInputText('/settgtoken') end
				imgui.SameLine()
				imgui.Text(u8"Токен бота: ")
				imgui.SameLine()
				imgui.TextDisabled(u8(settings.main.TelegramToken))			
				imgui.Text(faicons('gear')) 
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.Text(u8'Нажмите, чтобы скопировать команду в чат')
					imgui.EndTooltip()
				end 
				if imgui.IsItemClicked() then sampSetChatInputEnabled(true) sampSetChatInputText('/settgchat') end			
				imgui.SameLine()
				imgui.Text(u8"ID чата в Telegram: ")
				imgui.SameLine()
				imgui.TextDisabled(u8(settings.main.TelegramChat))
			end
		end	
		imgui.Separator()
		if imgui.CollapsingHeader(faicons('envelope')..u8" Обновление") then
			if newversion ~= scr.version then
				if imgui.Button(u8'Обновить до v'..newversion) then
					updateScript()
				end
			end
			imgui.TextColoredRGB("{F8A436}Что было добавлено в v"..newversion)
			imgui.Spacing()
			imgui.BeginChild("Update Log", imgui.ImVec2(0, 0), true)
				if doesFileExist(getWorkingDirectory().."/config/rmnspt/update.txt") then
					for line in io.lines(getWorkingDirectory().."/config/rmnspt/update.txt") do
						imgui.TextColoredRGB(line:gsub("*n*", "\n"))
					end
				end
			imgui.EndChild()
		end
        imgui.End()
    end
)
------------
function main()
	while not isSampAvailable() do wait(0) end
	if not doesDirectoryExist(getWorkingDirectory()..'/config/rmnspt') then createDirectory('moonloader\\config\\rmnspt') end
    if not doesFileExist('moonloader/config/rmnspt/settings.ini') then inicfg.save(settings, 'rmnspt\\settings') end
	thread = lua_thread.create(function() return end)
	secTimer = lua_thread.create(function() return end)
	userscreenX, userscreenY = getScreenResolution()
	if settings.AdvokatHelper.adhAutoUpdate then
		local nowTime = os.time()
		timer = nowTime + 30
	end
	wait(1000)
	sampAddChatMessage(SCRIPT_PREFIX .."Успешная загрузка скрипта. Используйте: ".. COLOR_MAIN .."/nespit{FFFFFF}. Автор: "..COLOR_MAIN.."romanespit", SCRIPT_COLOR)
	updateCheck()
	_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	sampRegisterChatCommand('nespit', function() WinState[0] = not WinState[0] end)
	sampRegisterChatCommand('bcl', cleanStreamMemoryBuffer)
	sampRegisterChatCommand("settgtoken", function(par)
		if par:find(".+") then
			local token = par:match(".+")
			settings.main.TelegramToken = token
			inicfg.save(settings, 'rmnspt\\settings')
			sampAddChatMessage(SCRIPT_PREFIX .."Новый токен: ".. COLOR_YES .. token, SCRIPT_COLOR)
		else
			sampAddChatMessage(SCRIPT_PREFIX .."Используйте: /settgtoken [token]", SCRIPT_COLOR)
		end
	end)
	
	sampRegisterChatCommand("settgchat", function(par)
		if par:find("([A-Za-z0-9%a%s]+)") then
			local chat = par:match("([A-Za-z0-9%a%s]+)")
			settings.main.TelegramChat = chat
			inicfg.save(settings, 'rmnspt\\settings')
			sampAddChatMessage(SCRIPT_PREFIX .."Новый чат: ".. COLOR_YES .. chat, SCRIPT_COLOR)
		else
			sampAddChatMessage(SCRIPT_PREFIX .."Используйте: /settgchat [chatid]", SCRIPT_COLOR)
		end
	end)
	sampRegisterChatCommand("setpin", function(par)
		if par:find("([A-Za-z0-9%a%s]+)") then
			local pin = par:match("([A-Za-z0-9%a%s]+)")
			settings.main.bankPin = pin
			inicfg.save(settings, 'rmnspt\\settings')
			sampAddChatMessage(SCRIPT_PREFIX .."Новый пин-код: ".. COLOR_YES .. pin, SCRIPT_COLOR)
		else
			settings.main.bankPin = ""
			inicfg.save(settings, 'rmnspt\\settings')
			sampAddChatMessage(SCRIPT_PREFIX .."Пин-код ".. COLOR_YES .. "сброшен", SCRIPT_COLOR)
		end
	end)
	sampRegisterChatCommand("setphone", function(par)
		if par:find("([A-Za-z0-9%a%s]+)") then
			local phone = par:match("([A-Za-z0-9%a%s]+)")
			settings.main.PhNumber = phone
			inicfg.save(settings, 'rmnspt\\settings')
			sampAddChatMessage(SCRIPT_PREFIX .."Новый номер SA: ".. COLOR_YES .. phone, SCRIPT_COLOR)
		else
			sampAddChatMessage(SCRIPT_PREFIX .."Используйте: /setphone [phone]", SCRIPT_COLOR)
		end
	end)
	sampRegisterChatCommand("setphonevc", function(par)
		if par:find("([A-Za-z0-9%a%s]+)") then
			local phone = par:match("([A-Za-z0-9%a%s]+)")
			settings.main.PhNumberVice = phone
			inicfg.save(settings, 'rmnspt\\settings')
			sampAddChatMessage(SCRIPT_PREFIX .."Новый номер VC: ".. COLOR_YES .. phone, SCRIPT_COLOR)
		else
			sampAddChatMessage(SCRIPT_PREFIX .."Используйте: /setphonevc [phone]", SCRIPT_COLOR)
		end
	end)
	sampRegisterChatCommand("nespit_dialog", function(par)		
		if par:find("([0-9%a%s]+)") then
			Logger("Par = "..par)
			if doesFileExist("moonloader/config/dialogs/"..par..".txt") then
				local f = io.open("moonloader/config/dialogs/"..par..".txt")
				local dialogText =  f:read("*a")
				f:close()
				sampShowDialog(par,"Test Dialog",dialogText,"button1","button2",0)
			end
		else
			sampAddChatMessage(SCRIPT_PREFIX .."Используйте: /nespit_dialog [id file]", SCRIPT_COLOR)
		end
	end)
	local audio = loadAudioStream('moonloader/config/rmnspt/alert.mp3')
	setAudioStreamVolume(audio, 0.1)
	while true do
		if secTimer:status() == "dead" then
			secTimer = lua_thread.create(function()
				wait(1000)			
				for i = 1, 3 do
					if caseTimers[i] ~= -1 then 
						caseTimers[i] = caseTimers[i]-1					
						if caseTimers[i] == -1 then
							if setting.cases.isTurned then
								sampAddChatMessage(SCRIPT_PREFIX .."Используй сундук "..caseName[i], SCRIPT_COLOR)
								caseTimers[i] = 300
								setAudioStreamState(audio, 1)
							end
						end
					end
				end
				if settings.clearMem.AutoCleaner then
					if memory.read(0x8E4CB4, 4, true) > 524288000 then
						cleanStreamMemoryBuffer()
					end
				end
			end)
		end
		QuestBots()
		QuestBomj()
		Kirka()
		kpztext = 'КПЗ'
		if settings.AdvokatHelper.adhTurnedOn then
			UpdateTD(zeki)
			if settings.AdvokatHelper.adhAutoUpdate then
				local nowTime = os.time()
				kpztext = 'КПЗ (до автообновления '..timer-nowTime..' сек.)'
				if nowTime >= timer then
					sampSendChat("/zeks")
				end
			end
			local l = #zeki-1
			if l == -1 then l = 0 end
			renderFontDrawText(font, kpztext, userscreenX/3 + 30, (userscreenY - 60) - l*15, 0xFFFFFFFF)
		end
		wait(0)
  end  
  wait(-1)
end
function updateScript()
	sampAddChatMessage(SCRIPT_PREFIX .."Производится скачивание новой версии скрипта...", SCRIPT_COLOR)
	local dir = getWorkingDirectory().."/romanespit_test.lua"
	local url = "https://github.com/romanespit/ArizonaMultitool/blob/main/romanespit_test.lua?raw=true"
	local updates = nil
	downloadUrlToFile(url, dir, function(id, status, p1, p2)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if updates == nil then 
				print("{FF0000}Ошибка при попытке обновиться.") 
				addOneOffSound(0, 0, 0, 1058)
				sampAddChatMessage(SCRIPT_PREFIX .."Произошла ошибка при скачивании обновления. Попробуйте позднее...", SCRIPT_COLOR)
			end
		end
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			updates = true
			print("Загрузка закончена")
			sampAddChatMessage(SCRIPT_PREFIX .."Скачивание завершено, перезагрузка скрипта...", SCRIPT_COLOR)
			scr:reload()
			showCursor(false)
		end
	end)
end
function updateCheck()
	sampAddChatMessage(SCRIPT_PREFIX .."Проверяем наличие обновлений...", SCRIPT_COLOR)
		local dir = getWorkingDirectory().."/config/rmnspt/info.upd"
		local url = "https://github.com/romanespit/ArizonaMultitool/raw/main/config/rmnspt/info.upd"
		downloadUrlToFile(url, dir, function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				lua_thread.create(function()
				wait(1000)
				if doesFileExist(getWorkingDirectory().."/config/rmnspt/info.upd") then
					local f = io.open(getWorkingDirectory().."/config/rmnspt/info.upd", "r")
					local upd = decodeJson(f:read("*a"))
					f:close()
					if type(upd) == "table" then
					newversion = upd.version
						if upd.version == scr.version then
							sampAddChatMessage(SCRIPT_PREFIX .."Вы используете актуальную версию скрипта - v"..scr.version, SCRIPT_COLOR)
						else
							sampAddChatMessage(SCRIPT_PREFIX .."Имеется обновление до версии v"..newversion.."! Открой меню скрипта и обнови его!", SCRIPT_COLOR)
						end
					end
				end

				end)
			end
		end)		
		dir = getWorkingDirectory().."/config/rmnspt/update.txt"
		url = "https://github.com/romanespit/ArizonaMultitool/raw/main/config/rmnspt/update.txt"
		downloadUrlToFile(url, dir, function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				lua_thread.create(function()
					wait(1000)
					if doesFileExist(getWorkingDirectory().."/config/rmnspt/update.txt") then
						local f = io.open(getWorkingDirectory().."/config/rmnspt/update.txt", "r")
						f:close()
					end
				end)
			end
		end)
end


function cleanStreamMemoryBuffer()
	Logger("Буфер памяти был очищен ("..tostring(memory.read(0x8E4CB4, 4, true))..")")
	local huy = callFunction(0x53C500, 2, 2, true, true)
	local huy1 = callFunction(0x53C810, 1, 1, true)
	local huy2 = callFunction(0x40CF80, 0, 0)
	local huy3 = callFunction(0x4090A0, 0, 0)
	local huy4 = callFunction(0x5A18B0, 0, 0)
	local huy5 = callFunction(0x707770, 0, 0)
	local pX, pY, pZ = getCharCoordinates(PLAYER_PED)
	requestCollision(pX, pY)
	loadScene(pX, pY, pZ)
end
function UpdateTD(table)
	if #table == 0 then
		zeksText = '{919191}Пусто'
		renderFontDrawText(font, zeksText, userscreenX/3 + 30, userscreenY - 45, SCRIPT_COLOR)
	else
		for i = 1, #table do
			zeksText = table[i][5] ..table[i][1] .. " | " .. table[i][3] .. "зв. | " .. table[i][4] .. " (" .. table[i][2] .. ")\n"
			renderFontDrawText(font, zeksText, userscreenX/3 + 30, (userscreenY - 45) - (i-1)*15, SCRIPT_COLOR)
		end
	end
end
function IsZeksResponse(text)
	if text:find("В данный момент в КПЗ отсутствуют заключенные!") then -- Получили ответ на /zeks
		zeki = {} -- Очищаем таблицу зеков
		return true
	elseif (text:find("Время") and text:find("Залог") and text:find("КПЗ")) then -- Поймали сообщение - нужно добавить в таблицу
		nameid = string.sub(text, string.find(text, '.+%(%d+%)')) -- Ivan_Pupkin(123)
		id = math.floor(tonumber(nameid:match("%d+"))) -- 123
		time = string.sub(text, string.find(text, '%d+%sмин')) -- Сколько осталось сидеть
		zalog = string.sub(text, string.find(text, '%$[%d+%p]+')):gsub("%p", "") -- Сумма залога, если есть MoneySeparator, удаляем знаки пунктуации
		wanted = math.floor(tonumber(zalog/4000)) -- Звезды = Залог / 4000
		kpz = string.sub(text, string.find(text, 'КПЗ:%s.+')) -- В каком КПЗ
		if kpz then kpz = GetShortKPZName(kpz) else kpz = "???" end -- Сокращаем КПЗ
		if string.find(text, 'Адвокат:%s.+') then advokat = "{919191}[".. text:match("Адвокат:%s.+") .."] " color = 0xFF919191  -- Если находим, значит есть адвокат
		elseif string.find(text, 'В ожидании адвоката') then advokat = "{FFD700}[ЖДЁТ АДВОКАТА] " color = colormsg -- Если находим, значит адвоката нет
		end 
		table.insert(zeki, #zeki+1,{nameid,time,wanted,kpz,advokat}) -- Пуляем в таблицу	
		return true
	end
	
end
function GetShortKPZName(kpz)
	if kpz:match("Las Venturas PD") then kpz = "LVPD"
	elseif kpz:match("San Fierro PD") then kpz = "SFPD"
	elseif kpz:match("Los Santos PD") then kpz = "LSPD"
	elseif kpz:match("Red County PD") then kpz = "RCPD"
	elseif kpz:match("Неизвестно") then kpz = "???"
	end
	return kpz
end

function FuncStatus(status)
	local text = ""
	if status == 1 then text=COLOR_YES.."(В консоль)"
	elseif status == 2 then text=COLOR_YES.."(В чат)"
	elseif status == true then text=COLOR_YES.."(Оба)"
	else text=COLOR_NO.."(Откл)" end
	return text
end	
function Logger(text)
	if settings.main.logging == 1 then print("[".. os.date("%X") .."] "..text)		
	elseif settings.main.logging == 2 then sampAddChatMessage(SCRIPT_PREFIX..text, SCRIPT_COLOR)
	elseif settings.main.logging == 3 then 
		sampAddChatMessage(SCRIPT_PREFIX..text, SCRIPT_COLOR)
		print("[".. os.date("%X") .."] "..text)
	end
end
function Kirka()
	if settings.main.kirka then
		for a = 1, 2048 do
			if sampIs3dTextDefined(a) then
				local string, color, vposX, vposY, vposZ, distance, ignoreWalls, playerId, vehicleId = sampGet3dTextInfoById(a)
				local X, Y, Z = getCharCoordinates(PLAYER_PED)
				local distances = getDistanceBetweenCoords2d(vposX, vposY, X, Y)
				if isPointOnScreen(vposX, vposY, vposZ, 0.0) and string.find(string, "Месторождение") and distances > 4.0 then
					local wposX, wposY = convert3DCoordsToScreen(vposX, vposY, vposZ)
					renderFontDrawText(font, "Руда", wposX, wposY, color)
				end
			end
		end
	end
end
function QuestBomj() 
	if settings.main.bomj then
		for a = 1, 2048 do
			if sampIs3dTextDefined(a) then
				local string, color, vposX, vposY, vposZ, distance, ignoreWalls, playerId, vehicleId = sampGet3dTextInfoById(a)
				local X, Y, Z = getCharCoordinates(PLAYER_PED)
				local distances = getDistanceBetweenCoords2d(vposX, vposY, X, Y)
				if isPointOnScreen(vposX, vposY, vposZ, 0.0) and string.find(string, "Бомж") and distances > 4.0 then
					local wposX, wposY = convert3DCoordsToScreen(vposX, vposY, vposZ)
					renderFontDrawText(font, string, wposX, wposY, color)
				end
			end
		end
	end
end
function QuestBots() 
	if settings.main.qb then
		for a = 1, 2048 do
			if sampIs3dTextDefined(a) then
				local string, color, vposX, vposY, vposZ, distance, ignoreWalls, playerId, vehicleId = sampGet3dTextInfoById(a)
				local X, Y, Z = getCharCoordinates(PLAYER_PED)
				local distances = getDistanceBetweenCoords2d(vposX, vposY, X, Y)
				if isPointOnScreen(vposX, vposY, vposZ, 0.0) and string.find(string, "Квестовый") and distances > 4.0 then
					local wposX, wposY = convert3DCoordsToScreen(vposX, vposY, vposZ)
					renderFontDrawText(font, string, wposX, wposY, color)
				end
			end
		end
	end
end
function get_distance(Object)
	local result, posX, posY, posZ = getObjectCoordinates(Object)
	if result then
		if doesObjectExist(Object) then
			local pPosX, pPosY, pPosZ = getCharCoordinates(PLAYER_PED)
			local distance = (math.abs(posX - pPosX)^2 + math.abs(posY - pPosY)^2)^0.5
			local posX, posY = convert3DCoordsToScreen(posX, posY, posZ)
			if round(distance, 2) <= 0.9 then
				return true
			end
		end
	end
	return false
end
function isViceCity()
	local ip, port = sampGetCurrentServerAddress()
	local address = ("%s:%s"):format(ip, port)
	return (address == "80.66.82.147:7777")
end
function isPlayerInWorld(interior_id)
	local ip, port = sampGetCurrentServerAddress()
	local address = ("%s:%s"):format(ip, port)
	if address == "80.66.82.147:7777" then -- Vice City
		return (interior_id == 20)
	end
	return (interior_id == 0)
end
function hook.onSetWeather(id)
	actual.weather = id
	if settings.climate.WeatherLock then
		return false
	else
		imClWeatherValue[0] = id
		imWeatherName = imWeatherNameList[id+1]
		settings.climate.WeatherValue = id
		inicfg.save(settings, 'rmnspt\\settings')
	end
end

function hook.onSetPlayerTime(hour, min)
	actual.time = hour
	if settings.climate.TimeLock then
		return false
	else
		imClTimeValue[0] = hour
		settings.climate.TimeValue = hour
		inicfg.save(settings, 'rmnspt\\settings')
	end
end

function hook.onSetWorldTime(hour)
	actual.time = hour
	if settings.climate.TimeLock then
		return false
	else
		imClTimeValue[0] = hour
		settings.climate.TimeValue = hour
		inicfg.save(settings, 'rmnspt\\settings')
	end
end

function hook.onSetInterior(id)
	local result = isPlayerInWorld(id)
	if settings.climate.TimeLock then
		setWorldTime(result and settings.climate.TimeValue or actual.time, true) 
	end
	if settings.climate.WeatherLock then 
		setWorldWeather(result and settings.climate.WeatherValue or actual.weather, true)
	end
end
function hook.onSetObjectMaterialText(ev, data)
	local Object = sampGetObjectHandleBySampId(ev)
	if doesObjectExist(Object) and getObjectModel(Object) == 18663 and string.find(data.text, "(.-) {30A332}Свободная!") then
		if settings.main.lavka then
			local result, posX, posY, posZ = getObjectCoordinates(Object)
			if (isObjectInArea2d(Object, CR_AREA[1], CR_AREA[2], CR_AREA[3], CR_AREA[4], false) and not isViceCity()) then
				if posZ <= 20 then
					local marker = createUser3dMarker(posX, posY, posZ + 3, 0)
					MARKERS[marker] = true
					sampAddChatMessage(SCRIPT_PREFIX, SCRIPT_COLOR)
					sampAddChatMessage(SCRIPT_PREFIX .."Появилась свободная лавка", SCRIPT_COLOR)
					sampAddChatMessage(SCRIPT_PREFIX, SCRIPT_COLOR)
					printStyledString('~n~~g~LAVKA', 15000, 4)
					lua_thread.create(function()
						wait(15000)
						removeUser3dMarker(marker)
						MARKERS[marker] = nil
					end)
				end
			elseif isViceCity() then
				local marker = createUser3dMarker(posX, posY, posZ + 3, 0)
				MARKERS[marker] = true
				sampAddChatMessage(SCRIPT_PREFIX, SCRIPT_COLOR)
				sampAddChatMessage(SCRIPT_PREFIX .."Появилась свободная лавка", SCRIPT_COLOR)
				sampAddChatMessage(SCRIPT_PREFIX, SCRIPT_COLOR)
				printStyledString('~n~~g~LAVKA', 15000, 4)
				lua_thread.create(function()
					wait(15000)
					removeUser3dMarker(marker)
					MARKERS[marker] = nil
				end)
			end
		end
	end
end
function hook.onServerMessage(_,text)
	if text:find("Вы использовали сундук с рулетками") then caseTimers[1] = 3600 end
	if text:find("Вы использовали платиновый сундук с рулетками") then caseTimers[2] = 7200 end
	if text:find("Вы использовали тайник Илона Маска") then caseTimers[3] = 7200 end
	if text:find("испытал удачу") or text:find("Удача улыбнулась") or text:find("словил грядку") then
		sendTelegram(false,text)		
		print("{FF0000}выбивание: {FFFFFF}"..text)
	end
	if text:find("кикнул игрока "..myNick) then
		sendTelegram(true,text)
	end
	if IsZeksResponse(text) then
		if not settings.AdvokatHelper.adhSendOriginalMessage and settings.AdvokatHelper.adhTurnedOn then return false end
	elseif text:match("Вы не состоите в мэрии!") and settings.AdvokatHelper.adhTurnedOn == true then
		settings.AdvokatHelper.adhTurnedOn = false
		imAdhTurnedOn[0] = settings.AdvokatHelper.adhTurnedOn
		inicfg.save(settings, 'rmnspt\\settings')
		timer = -1
		sampAddChatMessage(SCRIPT_PREFIX .."Вы не адвокат! Advokat Helper ".. COLOR_NO .."выключен", SCRIPT_COLOR)
		return false
	end	
end
function setWorldTime(hour, no_save)
	if tostring(hour):lower() == "off" then
		hour = actual.time
	end
	hour = tonumber(hour)
	if hour ~= nil and (hour >= 0 and hour <= 23) then
		local bs = raknetNewBitStream()
		raknetBitStreamWriteInt8(bs, hour)
		raknetEmulRpcReceiveBitStream(94, bs)
		raknetDeleteBitStream(bs)
		if no_save == nil then
			settings.climate.TimeValue = hour
			inicfg.save(settings, 'rmnspt\\settings')
		end
		return nil
	end
end

function setWorldWeather(id, no_save)
	if tostring(id):lower() == "off" then
		id = actual.weather
		if actual.weather >= 21 then imWeatherName = imWeatherNameList[22] else imWeatherName = imWeatherNameList[actual.weather+1] end
	end
	id = tonumber(id)
	if id ~= nil and (id >= 0 and id <= 45) then
		local bs = raknetNewBitStream()
		raknetBitStreamWriteInt8(bs, id)
		raknetEmulRpcReceiveBitStream(152, bs)
		raknetDeleteBitStream(bs)
		if no_save == nil then
			settings.climate.WeatherValue = id
			if id >= 21 then imWeatherName = imWeatherNameList[22] else imWeatherName = imWeatherNameList[id+1] end
			inicfg.save(settings, 'rmnspt\\settings')
		end
		return nil
	end
end
-->> Telegram
function sendTelegram(notification,msg)
	if settings.main.TelegramNotifications then
		local msg = tostring(msg):gsub('{......}', '')
		msg = tostring(msg):gsub(' ', '%+')
		msg = tostring(msg):gsub('\n', '%%0A')
		local params = ""
		if not notification then params = params.."&disable_notification=true" end
		local url = 'https://api.telegram.org/bot'.. settings.main.TelegramToken ..'/sendMessage?chat_id='.. settings.main.TelegramChat .. params ..'&text=' .. u8(msg)
		asyncHttpRequest('POST', url, nil, function(result) end, function(err) print('Ошибка при отправке в тг!') end)
		
		
	end
end

function asyncHttpRequest(method, url, args, resolve, reject)
   local request_thread = effil.thread(function (method, url, args)
		 	local requests = require('requests')
      local result, response = pcall(requests.request, method, url, args)
      if result then
         response.json, response.xml = nil, nil
         return true, response
      else
         return false, response
      end
   end)(method, url, args)
   if not resolve then resolve = function() end end
   if not reject then reject = function() end end
   lua_thread.create(function()
      local runner = request_thread
      while true do
         local status, err = runner:status()
         if not err then
            if status == 'completed' then
               local result, response = runner:get()
               if result then
                  resolve(response)
               else
                  reject(response)
               end
               return
            elseif status == 'canceled' then
               return reject(status)
            end
         else
            return reject(err)
         end
         wait(0)
      end
   end)
end
function hook.onDisplayGameText(style,time,text)
	-- /jmeat
	if text:match("You are hungry") or text:match("You are very hungry") then
		if settings.main.autoeat then
			if thread:status() == "dead" then
				thread = lua_thread.create(function()
					math.randomseed(os.clock())
					local a = math.random(30,180)
					wait(a*1000)
					sampSetChatInputEnabled(true)
					sampSetChatInputText('/jmeat')
					wait(3750)
					sampSetChatInputText('')
					sampSetChatInputEnabled(false)
					sampSendChat("/jmeat")	
				end)
			end
		end
	end
end
function hook.onSendChat(message)
	if not isViceCity() then 
		message = message:gsub("%(алло%)", settings.main.PhNumber)
		message = message:gsub("%(alo%)", settings.main.PhNumber)
	else
		message = message:gsub("%(алло%)", settings.main.PhNumberVice)
		message = message:gsub("%(alo%)", settings.main.PhNumberVice)
	end
	message = message:gsub("%(id%)", tostring(myid))
	message = message:gsub("%(ид%)", tostring(myid))
	return {message}
end
function hook.onSendCommand(message)
	if message == "/zeks" then 
		zeki = {}
		if settings.AdvokatHelper.adhTurnedOn then
			if settings.AdvokatHelper.adhAutoUpdate then 
				local nowTime = os.time()
				timer = nowTime + settings.AdvokatHelper.adhUpdateTime
			else
				timer = -1
			end
		end
	end
	if not isViceCity() then 
		message = message:gsub("%(алло%)", settings.main.PhNumber)
		message = message:gsub("%(alo%)", settings.main.PhNumber)
	else
		message = message:gsub("%(алло%)", settings.main.PhNumberVice)
		message = message:gsub("%(alo%)", settings.main.PhNumberVice)
	end
	message = message:gsub("%(id%)", tostring(myid))
	message = message:gsub("%(ид%)", tostring(myid))
	return {message}
end

function hook.onCreate3DText(id,color,position,distance,testLOS,attachedPlayerId,attachedVehicleId,text)
	
end
function hook.onShowDialog(id, style, title, button1, button2, text)
	if(id == 991 or id == 26559) then -- PIN CODE
		if (settings.main.bankPin == "") then 
		else
			sampSendDialogResponse(id, 1, 0, settings.main.bankPin)
			sampCloseCurrentDialogWithButton(0)
			return false
		end
	end
	if id == 26558 then -- PIN CODE
		sampSendDialogResponse(id, 1, 0, nil)
		sampCloseCurrentDialogWithButton(0)
		return false
	end
	if id == 131 then -- Самохил
		if text:find(myNick) then 
			sampSendDialogResponse(id, 1, 0, nil)
			sampCloseCurrentDialogWithButton(0)
			return false
		end
	end
	if (id==15380) then -- Выдать медкарту
		sampSendDialogResponse(id, 1, 0, nil)
		sampCloseCurrentDialogWithButton(0)
		return false
	end
	title = title.." | ID: "..id
	return {id,style,title,button1,button2,text}
end
function imgui.TextColoredRGB(string, max_float)

	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local u8 = require 'encoding'.UTF8

	local function color_imvec4(color)
		if color:upper():sub(1, 6) == 'SSSSSS' then return imgui.ImVec4(colors[clr.Text].x, colors[clr.Text].y, colors[clr.Text].z, tonumber(color:sub(7, 8), 16) and tonumber(color:sub(7, 8), 16)/255 or colors[clr.Text].w) end
		local color = type(color) == 'number' and ('%X'):format(color):upper() or color:upper()
		local rgb = {}
		for i = 1, #color/2 do rgb[#rgb+1] = tonumber(color:sub(2*i-1, 2*i), 16) end
		return imgui.ImVec4(rgb[1]/255, rgb[2]/255, rgb[3]/255, rgb[4] and rgb[4]/255 or colors[clr.Text].w)
	end

	local function render_text(string)
		for w in string:gmatch('[^\r\n]+') do
			local text, color = {}, {}
			local render_text = 1
			local m = 1
			if w:sub(1, 8) == '[center]' then
				render_text = 2
				w = w:sub(9)
			elseif w:sub(1, 7) == '[right]' then
				render_text = 3
				w = w:sub(8)
			end
			w = w:gsub('{(......)}', '{%1FF}')
			while w:find('{........}') do
				local n, k = w:find('{........}')
				if tonumber(w:sub(n+1, k-1), 16) or (w:sub(n+1, k-3):upper() == 'SSSSSS' and tonumber(w:sub(k-2, k-1), 16) or w:sub(k-2, k-1):upper() == 'SS') then
					text[#text], text[#text+1] = w:sub(m, n-1), w:sub(k+1, #w)
					color[#color+1] = color_imvec4(w:sub(n+1, k-1))
					w = w:sub(1, n-1)..w:sub(k+1, #w)
					m = n
				else w = w:sub(1, n-1)..w:sub(n, k-3)..'}'..w:sub(k+1, #w) end
			end
			local length = imgui.CalcTextSize(u8(w))
			if render_text == 2 then
				imgui.NewLine()
				imgui.SameLine(max_float / 2 - ( length.x / 2 ))
			elseif render_text == 3 then
				imgui.NewLine()
				imgui.SameLine(max_float - length.x - 5 )
			end
			if text[0] then
				for i, k in pairs(text) do
					imgui.TextColored(color[i] or colors[clr.Text], u8(k))
					imgui.SameLine(nil, 0)
				end
				imgui.NewLine()
			else imgui.Text(u8(w)) end
		end
	end
	
	render_text(string)
end