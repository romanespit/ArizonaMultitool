script_author("romanespit")
script_name("{3B66C5}romanespit")
script_url("https://github.com/romanespit/ArizonaMultitool")
script_version("2.00")
------------------------ J-CFG Minified
local a,b=pcall(require,'json')local c=getWorkingDirectory and getWorkingDirectory()or''local d={encode=encodeJson or(a and b.encode or nil),decode=decodeJson or(a and b.decode or nil)}assert(d.encode and d.decode,'error, cannot use json encode/decode functions. Install JSON cfg: https://github.com/rxi/json.lua')local function e(f)local g=io.open(f,'r')if g~=nil then io.close(g)end;return g~=nil end;function Json(h,i)if not h:find('(.+)%.json$')then h=h..'.json'end;local j,k,l={},false,'UNKNOWN_ERROR'local function m(n,o)local function p(q)local r=type(q)if r~='string'then q=tostring(q)end;local s=q:find('^(%d+)')or q:find('(%p)')or q:find('\\')or q:find('%-')return s==nil and q or('[%s]'):format(r=='string'and"'"..q.."'"or q)end;local t={'{'}local o=o or 0;for q,u in pairs(n)do table.insert(t,('%s%s = %s,'):format(string.rep("    ",o+1),p(q),type(u)=="table"and m(u,o+1)or(type(u)=='string'and"'"..u.."'"or tostring(u))))end;table.insert(t,string.rep('    ',o)..'}')return table.concat(t,'\n')end;local function v(i,w)local x=0;for y,z in pairs(i)do if w[y]==nil then if type(z)=='table'then w[y]={}_,subFilledCount=v(z,w[y])x=x+subFilledCount else w[y]=z;x=x+1 end elseif type(z)=='table'and type(w[y])=='table'then _,subFilledCount=v(z,w[y])x=x+subFilledCount end end;return w,x end;local function A(B)local C=io.open(h,'w')if C then local D,E=pcall(d.encode,B)if D and E then C:write(E)end;C:close()end end;local function F()local C=io.open(h,'r')if C then local G=C:read('*a')C:close()local H,I=pcall(d.decode,G)if H and I then j=I;k=true;local J,x=v(i,j)if x>0 then A(J)return J end;return I else l='JSON_DECODE_FAILED_'..I end else l='JSON_FILE_OPEN_FAILED'end;return{}end;if not e(h)then A(i)end;j=F()return k,setmetatable({},{__call=function(self,K)if type(K)=='table'then j=K;A(j)end end,__index=function(self,y)return y and j[y]or j end,__newindex=function(self,y,L)j[y]=L;A(j)end,__tostring=function(self)return m(j)end,__pairs=function()local y,z=next(j)return function()y,z=next(j,y)return y,z end end,__concat=function()return d.encode(j)end}),k and'ok'or l end

------------------------
local scr = thisScript()
local hook = require 'lib.samp.events'
local encoding = require('encoding')
local dlstatus = require("moonloader").download_status
local imgui = require 'mimgui'
local ffi = require 'ffi'
encoding.default = 'CP1251'
u8 = encoding.UTF8
local dirml = getWorkingDirectory() -- Директория moonloader
local effil_check, effil = pcall(require, 'effil')
local inicfg = require 'inicfg'
local faicons = require('fAwesome6')
if not doesDirectoryExist(dirml.."/rmnsptScripts/") then
    createDirectory(dirml.."/rmnsptScripts/")
    print("Директория rmnsptScripts не была найдена. Успешное создание")
end
local cfgstatus, settings = Json(dirml..'\\rmnsptScripts\\Multitool-settings.json', { 
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
	VCab = false,
	HotelBoxes = false,
	autoeat = false,
	bankPin = "12",
	TimeValue = 12,
	TimeLock = false,
	WeatherValue = 1,
	WeatherLock = false,
	isTurned = false,
	Default = -1,
	Platinum = -1,
	Elon = -1,
	isDisabled = false,
	InCinema = false,
	InHomeCinema = false,
	AutoCleaner = false
});
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
RadiusLavki = false
zeksText = 'Пусто'
zeki = {}
myid = -1
newversion = ""
newdate = ""
caseTimers = {settings.Default,settings.Platinum,settings.Elon}
caseName = {"рулетки","платиновой рулетки","Илона Маска"}
-- time/weather
local memory = require "memory"
local actual = {
	time = memory.getint8(0xB70153),
	weather = memory.getint16(0xC81320)
}
--- mimgui
local new, str = imgui.new, ffi.string
local WinState = new.bool()
local imQuestBots = new.bool(settings.qb)
local imQuestBomj = new.bool(settings.bomj)
local imLavka = new.bool(settings.lavka)
local imVCab = new.bool(settings.VCab)
local imHotelBoxes = new.bool(settings.HotelBoxes)
local imRLavka = new.bool(RadiusLavki)
local imKirka = new.bool(settings.kirka)
local imAutoClean = new.bool(settings.AutoCleaner)
local imAutoeat = new.bool(settings.autoeat)
local imCaseAlert = new.bool(settings.isTurned)

local imDisabledVideo = new.bool(settings.isDisabled)
local imDisabledVideoInCinema = new.bool(settings.InCinema)
local imDisabledVideoInHomeCinema = new.bool(settings.InHomeCinema)

local imClTimeLock = new.bool(settings.TimeLock)
local imClTimeValue = new.int(settings.TimeValue)
local imClWeatherLock = new.bool(settings.WeatherLock)
local imClWeatherValue = new.int(settings.WeatherValue)
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

local imLoggingCombo = new.int(settings.logging)
local imLoggingList = {u8'Выключено', u8'В консоль SAMPFUNCS', u8'В игровой чат', u8'И в консоль, и в чат'}
local imLoggingItems = imgui.new['const char*'][#imLoggingList](imLoggingList)
local imPhNumber = new.char[256](u8(settings.PhNumber))
local imPhNumberVice = new.char[256](u8(settings.PhNumberVice))
local imTelegramChat = new.char[256](u8(settings.TelegramChat))
local imTelegramToken = new.char[256](u8(settings.TelegramToken))
local imBankPin = new.char[256](u8(settings.bankPin))
local imTelegramNotifications = new.bool(settings.TelegramNotifications)

function onScriptTerminate(scr, is_quit)
	if scr == thisScript() then
		settings.Default = caseTimers[1]
		settings.Platinum = caseTimers[2]
		settings.Elon = caseTimers[3]		
		settings();
		for handle, _ in pairs(MARKERS) do
			removeUser3dMarker(handle)
			MARKERS[handle] = nil
		end
	end
end


imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    iconRanges = imgui.new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85('solid'), 14, config, iconRanges)
	MimStyle()
end)
imgui.OnFrame(function() return WinState[0] end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(500, 600), imgui.Cond.Always)
        imgui.Begin(faicons('poo')..u8' romanespit Arizona Multitool v'..scr.version, WinState, imgui.WindowFlags.AlwaysAutoResize+imgui.WindowFlags.NoCollapse)
		if imgui.CollapsingHeader(faicons('gear')..u8" Основные") then
			if imgui.InputTextWithHint(u8'PIN', u8'Введите PIN от банка', imBankPin, 256) then
				settings.bankPin = u8:decode(ffi.string(imBankPin))
				settings();
			end

			if imgui.InputTextWithHint(u8'Номер телефона SA', u8'Введите телефон на основном сервере', imPhNumber, 256) then
				settings.PhNumber = u8:decode(ffi.string(imPhNumber))
				settings();
			end

			if imgui.InputTextWithHint(u8'Номер телефона VC', u8'Введите телефон на VC сервере', imPhNumberVice, 256) then
				settings.imPhNumberVice = u8:decode(ffi.string(imPhNumberVice))
				settings();
			end
				--
			if imgui.Checkbox(u8'Уведомления о кейсах '..faicons('gem'), imCaseAlert) then
				settings.isTurned = imCaseAlert[0]
				settings();
				Logger("Уведомления о кейсах "..(imCaseAlert[0] and COLOR_YES.."включены" or COLOR_NO.."выключены"))
			end
			if imgui.Checkbox(u8'Выключение видео на билбордах '..faicons('play'), imDisabledVideo) then
				settings.isDisabled = imDisabledVideo[0]
				settings();
				Logger("Видеобилборды "..(imDisabledVideo[0] and COLOR_YES.."выключены" or COLOR_NO.."включены"))
				
			end
			if imDisabledVideo[0] then
				if imgui.Checkbox(u8'Выключение в кинотеатре '..faicons('play'), imDisabledVideoInCinema) then
					settings.InCinema = imDisabledVideoInCinema[0]
					settings();
					Logger("Видео в кинотеатре "..(imDisabledVideoInCinema[0] and COLOR_YES.."выключено" or COLOR_NO.."включено"))
				end
				if imgui.Checkbox(u8'Выключение в домашнем кинотеатре '..faicons('play'), imDisabledVideoInHomeCinema) then
					settings.InHomeCinema = imDisabledVideoInHomeCinema[0]
					settings();
					Logger("Видео в домашнем кинотеатре "..(imDisabledVideoInHomeCinema[0] and COLOR_YES.."выключено" or COLOR_NO.."включено"))
				end
			end
			if imgui.Checkbox(u8'Авто /jmeat (поедание оленины)'..faicons('burger'), imAutoeat) then
				settings.autoeat = imAutoeat[0]
				settings();
				Logger("Авто /jmeat "..(imAutoeat[0] and COLOR_YES.."включен" or COLOR_NO.."выключен"))
			end
			if imgui.Checkbox(u8'Квестовые боты '..faicons('robot'), imQuestBots) then
				settings.qb = imQuestBots[0]
				settings();
				Logger("Квестовые боты "..(imQuestBots[0] and COLOR_YES.."показываются" or COLOR_NO.."не показываются"))
			end
			if imgui.Checkbox(u8'Квестовые бомжи '..faicons('robot'), imQuestBomj) then
				settings.bomj = imQuestBomj[0]
				settings();
				Logger("Квестовые бомжи "..(imQuestBomj[0] and COLOR_YES.."показываются" or COLOR_NO.."не показываются"))
			end
			if imgui.Checkbox(u8'Рендер руды '..faicons('gem'), imKirka) then
				settings.kirka = imKirka[0]
				settings();
				Logger("Рендер руды "..(imKirka[0] and COLOR_YES.."включен" or COLOR_NO.."выключен"))
			end
			if imgui.Checkbox(u8'Автоочистка памяти '..faicons('trash'), imAutoClean) then
				settings.AutoCleaner = imAutoClean[0]
				settings();
				Logger("Автоочистка памяти by Azller Lollison "..(imAutoClean[0] and COLOR_YES.."включена" or COLOR_NO.."выключена"))
			end
			if imgui.IsItemHovered() then
				imgui.BeginTooltip()
				imgui.Text(u8'Автор: Azller Lollison')
				imgui.EndTooltip()
			end
			if imgui.Checkbox(u8'Уведомления о свободных лавках '..faicons('store'), imLavka) then
				settings.lavka = imLavka[0]
				settings();
				Logger("Уведомления о лавках "..(imLavka[0] and COLOR_YES.."включены" or COLOR_NO.."выключены"))
			end
			if imgui.Checkbox(u8'Уведомления о свободных местах на АБ ViceCity '..faicons('store'), imVCab) then
				settings.VCab = imVCab[0]
				settings();				
				Logger("Уведомления о свободных местах на АБ ViceCity "..(imVCab[0] and COLOR_YES.."включены" or COLOR_NO.."выключены"))
			end
			if imgui.Checkbox(u8'Радиус переносных лавок '..faicons('store'), imRLavka) then
				RadiusLavki = not RadiusLavki			
				Logger("Радиус переносных лавок "..(RadiusLavki == true and COLOR_YES.."включен" or COLOR_NO.."выключен"))
			end
			if imgui.Checkbox(u8'Уведомления о ларцах в отеле '..faicons('store'), imHotelBoxes) then
				settings.HotelBoxes = imHotelBoxes[0]
				settings();
				Logger("Уведомления о ларцах в отеле "..(imHotelBoxes[0] and COLOR_YES.."включены" or COLOR_NO.."выключены"))
			end
			if imgui.Combo(u8'Логирование '..faicons('pen'),imLoggingCombo,imLoggingItems, #imLoggingList) then
				settings.logging = imLoggingCombo[0]
				settings();
				if settings.logging == 1 then
					sampAddChatMessage(SCRIPT_PREFIX .."Логирование скрипта ".. COLOR_YES .."включено в консоль", SCRIPT_COLOR)
				elseif settings.logging == 2 then
					sampAddChatMessage(SCRIPT_PREFIX .."Логирование скрипта ".. COLOR_YES .."включено в чат", SCRIPT_COLOR)
				elseif settings.logging == 3 then
					sampAddChatMessage(SCRIPT_PREFIX .."Логирование скрипта ".. COLOR_YES .."и в консоль, и в чат", SCRIPT_COLOR)
				elseif settings.logging == 0 then
					sampAddChatMessage(SCRIPT_PREFIX .."Логирование скрипта ".. COLOR_NO .."выключено", SCRIPT_COLOR)
				end
			end
		end
		imgui.Separator()
		if imgui.CollapsingHeader(faicons('clock')..faicons('cloud')..u8" Управление временем/погодой") then
			if imgui.Checkbox(u8'Блокировать изменение времени', imClTimeLock) then
				settings.TimeLock = imClTimeLock[0]
				settings();
				Logger("Изменение времени сервером "..(imClTimeLock[0] and COLOR_NO.."заблокировано" or COLOR_YES.."разблокировано"))
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
				settings.WeatherLock = imClWeatherLock[0]
				settings();
				Logger("Изменение погоды сервером "..(imClWeatherLock[0] and COLOR_NO.."заблокировано" or COLOR_YES.."разблокировано"))
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
		if imgui.CollapsingHeader(faicons('envelope')..u8" Настройки уведомлений Telegram") then
			if imgui.Checkbox(u8'Уведомления в Telegram', imTelegramNotifications) then
				settings.TelegramNotifications = imTelegramNotifications[0]
				settings(); 
				Logger("Уведомления в Telegram "..(settings.TelegramNotifications == true and COLOR_YES.."включены" or COLOR_NO.."выключены"))
			end
			if imTelegramNotifications[0] then
				if imgui.InputTextWithHint(u8'Токен бота', u8'Введите токен вашего бота', imTelegramToken, 256) then
					settings.TelegramToken = u8:decode(ffi.string(imTelegramToken))
					settings();
				end
				if imgui.InputTextWithHint(u8'ID чата в Telegram', u8'Введите ваш TG User ID', imTelegramChat, 256) then
					settings.TelegramChat = u8:decode(ffi.string(imTelegramChat))
					settings();
				end
			end
		end	
		imgui.Separator()
			if newversion ~= scr.version then
				if imgui.Button(faicons('rotate')..u8' Обновить до v'..newversion) then
					updateScript()
				end
			end
			imgui.SameLine()
			if imgui.Button(faicons('rotate')..u8' Перезагрузить скрипт') then
				sampAddChatMessage(SCRIPT_PREFIX .."Перезагрузка скрипта...", SCRIPT_COLOR)
				showCursor(false)
				scr:reload()
			end
			if doesFileExist(getWorkingDirectory().."/rmnsptScripts/Multitool-update.txt") then
				imgui.TextColoredRGB("{F8A436}Что было добавлено в v"..newversion..' от '..newdate)
				imgui.Spacing()
				imgui.BeginChild("Update Log", imgui.ImVec2(0, 0), true)
					
						for line in io.lines(getWorkingDirectory().."/rmnsptScripts/Multitool-update.txt") do
							imgui.TextColoredRGB(line:gsub("*n*", "\n"))
						end
				imgui.EndChild()
			end
        imgui.End()
    end
)
function onReceivePacket(id, bs)
	if (settings.isDisabled and getActiveInterior() == 0) or 
	(settings.InCinema and getActiveInterior() == 201) or 
	(settings.InHomeCinema and getActiveInterior() == 61) then 
		if id == 220 then
			raknetBitStreamIgnoreBits(bs, 8)
			if raknetBitStreamReadInt8(bs) == 12 then
				return false
			end
		end
	end
end
------------
function main()
	while not isSampAvailable() do wait(0) end
	if not doesDirectoryExist(getWorkingDirectory()..'/config/rmnspt') then createDirectory('moonloader\\config\\rmnspt') end
    if not doesFileExist('moonloader/config/rmnspt/settings.ini') then settings(); end
	thread = lua_thread.create(function() return end)
	secTimer = lua_thread.create(function() return end)
	userscreenX, userscreenY = getScreenResolution()
	
	sampRegisterChatCommand('nespit_test', function()
		sampAddChatMessage(SCRIPT_PREFIX .."Здесь была секретная команда, которую я использовал для различных тестов", SCRIPT_COLOR)
		sampAddChatMessage(SCRIPT_PREFIX .."Но перед релизом я её выпилил", SCRIPT_COLOR)
	end)
	repeat wait(100) until sampIsLocalPlayerSpawned()
	sampAddChatMessage(SCRIPT_PREFIX .."Успешная загрузка скрипта. Используйте: ".. COLOR_MAIN .."/nespit{FFFFFF}. Автор: "..COLOR_MAIN.."romanespit", SCRIPT_COLOR)
	updateCheck()
	sampRegisterChatCommand('nespit_cmd', function() 
		sampAddChatMessage(SCRIPT_PREFIX .."Команды скрипта:", SCRIPT_COLOR)
		sampAddChatMessage(SCRIPT_PREFIX .. COLOR_MAIN .."/nespit{FFFFFF} - главное меню", SCRIPT_COLOR)
		sampAddChatMessage(SCRIPT_PREFIX .. COLOR_MAIN .."/bcl{FFFFFF} - очистить память игры", SCRIPT_COLOR)
		sampAddChatMessage(SCRIPT_PREFIX .. COLOR_MAIN .."/rlavka{FFFFFF} - включить рендер кругов вокруг переносных лавок", SCRIPT_COLOR)
		sampAddChatMessage(SCRIPT_PREFIX .. COLOR_MAIN .."/tg{FFFFFF} - отправить сообщение себе в тг", SCRIPT_COLOR)
	end)
	sampRegisterChatCommand('nespit', function() WinState[0] = not WinState[0] end)
	sampRegisterChatCommand('roma', function() WinState[0] = not WinState[0] end)	
	sampRegisterChatCommand('bcl', cleanStreamMemoryBuffer)
	
	sampRegisterChatCommand("tg", function(par)
		if par:find(".+") then
			local msg = par:match(".+")
			sendTelegram(true,msg)
			sampAddChatMessage(SCRIPT_PREFIX .."Сообщение в тг ".. COLOR_YES .."отправлено", SCRIPT_COLOR)
		else
			sampAddChatMessage(SCRIPT_PREFIX .."Используйте: /tg [сообщение]", SCRIPT_COLOR)
		end
	end)
	sampRegisterChatCommand('rlavka',function() 
		RadiusLavki = not RadiusLavki
		imRLavka[0] = not imRLavka[0]
		Logger("Радиус переносных лавок "..(RadiusLavki and COLOR_YES.."включен" or COLOR_NO.."выключен"))
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
	if doesFileExist('moonloader/rmnsptScripts/Multitool-alert.mp3') then
		audio = loadAudioStream('moonloader/rmnsptScripts/Multitool-alert.mp3')
		setAudioStreamVolume(audio, 0.1)
	end
	while true do
		if secTimer:status() == "dead" then
			secTimer = lua_thread.create(function()
				wait(1000)			
				for i = 1, 3 do
					if caseTimers[i] ~= -1 then 
						caseTimers[i] = caseTimers[i]-1					
						if caseTimers[i] == -1 then
							if settings.isTurned == true then
								sampAddChatMessage(SCRIPT_PREFIX .."Используй сундук "..caseName[i], SCRIPT_COLOR)
								caseTimers[i] = 300
								if doesFileExist('moonloader/rmnsptScripts/Multitool-alert.mp3') then setAudioStreamState(audio, 1) end
							end
						end
					end
				end
				if settings.AutoCleaner == true then
					if memory.read(0x8E4CB4, 4, true) > 524288000 then
						cleanStreamMemoryBuffer()
					end
				end
			end)
		end
		QuestBots()
		QuestBomj()
		Kirka()
		RadiusLavka()
		VCab()
		HotelBoxes()
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
			showCursor(false)
			scr:reload()
			showCursor(false)
		end
	end)
end
function updateCheck()
	sampAddChatMessage(SCRIPT_PREFIX .."Проверяем наличие обновлений...", SCRIPT_COLOR)
		local dir = getWorkingDirectory().."/rmnsptScripts/Multitool-info.upd"
		local url = "https://github.com/romanespit/ArizonaMultitool/raw/main/rmnsptScripts/Multitool-info.upd"
		downloadUrlToFile(url, dir, function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				lua_thread.create(function()
					wait(1000)
					if doesFileExist(getWorkingDirectory().."/rmnsptScripts/Multitool-info.upd") then
						local f = io.open(getWorkingDirectory().."/rmnsptScripts/Multitool-info.upd", "r")
						local upd = decodeJson(f:read("*a"))
						f:close()
						if type(upd) == "table" then
							newversion = upd.version
							newdate = upd.release_date
							if upd.version == scr.version then
								sampAddChatMessage(SCRIPT_PREFIX .."Вы используете актуальную версию скрипта - v"..scr.version.." от "..newdate, SCRIPT_COLOR)
							else
								sampAddChatMessage(SCRIPT_PREFIX .."Имеется обновление до версии v"..newversion.." от "..newdate.."! Открой меню скрипта и обнови его!", SCRIPT_COLOR)
							end
						end
					end
				end)
			end
		end)		
		dir = getWorkingDirectory().."/rmnsptScripts/Multitool-update.txt"
		url = "https://github.com/romanespit/ArizonaMultitool/raw/main/rmnsptScripts/Multitool-update.txt"
		downloadUrlToFile(url, dir, function(id, status, p1, p2)
			if status == dlstatus.STATUS_ENDDOWNLOADDATA then
				lua_thread.create(function()
					wait(1000)
					if doesFileExist(getWorkingDirectory().."/rmnsptScripts/Multitool-update.txt") then
						local f = io.open(getWorkingDirectory().."/rmnsptScripts/Multitool-update.txt", "r")
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
	if settings.logging == 1 then print("[".. os.date("%X") .."] "..text)		
	elseif settings.logging == 2 then sampAddChatMessage(SCRIPT_PREFIX..text, SCRIPT_COLOR)
	elseif settings.logging == 3 then 
		sampAddChatMessage(SCRIPT_PREFIX..text, SCRIPT_COLOR)
		print("[".. os.date("%X") .."] "..text)
	end
end
function RadiusLavka()
	if RadiusLavki then
		local canPlaceMarket = true
		local circleColor = 0xFFFFFFFF
		local x, y, z = getCharCoordinates(PLAYER_PED)
		for IDTEXT = 0, 2048 do
			if sampIs3dTextDefined(IDTEXT) then
				local text, color, posX, posY, posZ, distance, ignoreWalls, player, vehicle = sampGet3dTextInfoById(IDTEXT)
				if getDistanceBetweenCoords3d(x,y,z,posX,posY,posZ) < 35 then
					if text == 'Управления товарами.' and not isCentralMarket(posX, posY) then
						circleColor = 0xFFFFFFFF
						if getDistanceBetweenCoords3d(x,y,z,posX,posY,posZ) < 5 then canPlaceMarket = false circleColor = 0xFFFF0000 end					
						drawCircleIn3d(posX,posY,posZ-1.3,5,36,1.5,circleColor)
					elseif text:find("Номер бизнеса") then
						circleColor = 0xFF0000FF		
						if getDistanceBetweenCoords3d(x,y,z,posX,posY,posZ) < 25 then canPlaceMarket = false circleColor = 0xFFFF0000 end
						drawCircleIn3d(posX,posY,posZ-1.3,25,36,1.5,circleColor)
					end
				end
			end
		end
		if isCentralMarket(x, y) then canPlaceMarket = false end
		if canPlaceMarket then renderFontDrawText(font, "Можно поставить лавку", userscreenX/3 + 30, (userscreenY - 60), 0xFF228B22)
		else renderFontDrawText(font, "Нельзя поставить лавку", userscreenX/3 + 30, (userscreenY - 60), 0xFFFF0000) end		
	end
end
function drawCircleIn3d(x, y, z, radius, polygons,width,color)
    local step = math.floor(360 / (polygons or 36))
    local sX_old, sY_old
    for angle = 0, 360, step do
        local lX = radius * math.cos(math.rad(angle)) + x
        local lY = radius * math.sin(math.rad(angle)) + y
        local lZ = z
        local _, sX, sY, sZ, _, _ = convert3DCoordsToScreenEx(lX, lY, lZ)
        if sZ > 1 then
            if sX_old and sY_old then
                renderDrawLine(sX, sY, sX_old, sY_old, width, color)
            end
            sX_old, sY_old = sX, sY
        end
    end
end
function isCentralMarket(x, y)
	return (x > 1044 and x < 1197 and y > -1565 and y < -1403)
end
function Kirka()
	if settings.kirka == true then
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
function VCab()
	if settings.VCab == true and isViceCity() then
		for a = 1, 2048 do
			if sampIs3dTextDefined(a) then
				local string, color, vposX, vposY, vposZ, distance, ignoreWalls, playerId, vehicleId = sampGet3dTextInfoById(a)
				local X, Y, Z = getCharCoordinates(PLAYER_PED)
				local distances = getDistanceBetweenCoords2d(vposX, vposY, X, Y)
				if isPointOnScreen(vposX, vposY, vposZ, 0.0) and string.find(string, "Место для легкового транспорта") and string.find(string, "Доступно") and distances > 4.0 then
					local wposX, wposY = convert3DCoordsToScreen(vposX, vposY, vposZ)
					renderFontDrawText(font, "Свободное место", wposX, wposY, 0xFF228B22)
				end
				if isPointOnScreen(vposX, vposY, vposZ, 0.0) and string.find(string, "Место для большого транспорта") and string.find(string, "Доступно") and distances > 4.0 then
					local wposX, wposY = convert3DCoordsToScreen(vposX, vposY, vposZ)
					renderFontDrawText(font, "Свободное место", wposX, wposY, 0xFFA5EF21)
				end
			end
		end
	end
end
function HotelBoxes()
	if settings.HotelBoxes == true then
		for a = 1, 2048 do
			if sampIs3dTextDefined(a) then
				local string, color, vposX, vposY, vposZ, distance, ignoreWalls, playerId, vehicleId = sampGet3dTextInfoById(a)
				local X, Y, Z = getCharCoordinates(PLAYER_PED)
				local distances = getDistanceBetweenCoords2d(vposX, vposY, X, Y)
				if string.find(string, "Бонусный Ларец") then
					renderFontDrawText(font, "Не забудь забрать ларец из номера!", userscreenX/3 + 30, (userscreenY - 60), 0xFF228B22)
				end
				if string.find(string, "Статус дверей") and string.find(string, "Открыты") then					
					renderFontDrawText(font, "Есть открытые номера", userscreenX/3 + 30, (userscreenY - 60), 0xFF228B22)
					if isPointOnScreen(vposX, vposY, vposZ, 0.0) and distances > 4.0 then
						local wposX, wposY = convert3DCoordsToScreen(vposX, vposY, vposZ)
						renderFontDrawText(font, "Open", wposX, wposY, 0xFF228B22)
					end
				end
			end
		end
	end
end
function QuestBomj() 
	if settings.bomj == true then
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
	if settings.qb == true then
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
	if settings.WeatherLock == true then
		return false
	else
		imClWeatherValue[0] = id
		imWeatherName = imWeatherNameList[id+1]
		settings.WeatherValue = id
		settings();
	end
end

function hook.onSetPlayerTime(hour, min)
	actual.time = hour
	if settings.TimeLock == true then
		return false
	else
		imClTimeValue[0] = hour
		settings.TimeValue = hour
		settings();
	end
end

function hook.onSetWorldTime(hour)
	actual.time = hour
	if settings.TimeLock == true then
		return false
	else
		imClTimeValue[0] = hour
		settings.TimeValue = hour
		settings();
	end
end

function hook.onSetInterior(id)
	local result = isPlayerInWorld(id)
	if settings.TimeLock == true then
		setWorldTime(result and settings.TimeValue or actual.time, true) 
	end
	if settings.WeatherLock == true then 
		setWorldWeather(result and settings.WeatherValue or actual.weather, true)
	end
end
function hook.onSetObjectMaterialText(ev, data)
	local Object = sampGetObjectHandleBySampId(ev)
	if doesObjectExist(Object) and (getObjectModel(Object) == 14210 or getObjectModel(Object) == 18663) and string.find(data.text, "(.-) {30A332}Свободная!") then
		if settings.lavka == true then
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
function GetNick()
	_, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	myNick = sampGetPlayerNickname(myid)
	return tostring(myNick):gsub("%[.*%]","")
end
function hook.onServerMessage(_,text)
	if text:find("Вы использовали сундук с рулетками") then caseTimers[1] = 3600 end
	if text:find("Вы использовали платиновый сундук с рулетками") then caseTimers[2] = 7200 end
	if text:find("Вы использовали тайник Илона Маска") then caseTimers[3] = 7200 end
	if text:find("словил грядку") then
		sendTelegram(false,text)		
		print("{FF0000}Выбивание: {FFFFFF}"..text)
	end
	if text:find("([A-Za-z0-9%a]+_[A-Za-z0-9%a]+) испытал удачу при открытии '([^']*)' и выиграл транспорт: (.+)") then
		local nick, larec, prize = text:match("([A-Za-z0-9%a]+_[A-Za-z0-9%a]+) испытал удачу при открытии '([^']*)' и выиграл транспорт: (.+)")
		local msg = string.format("[`".. os.date("%X") .."`] `%s` открыл *%s* и выбил `%s`",nick,larec,prize)
		sendTelegram(false,msg)
	end	
	if text:find("Удача улыбнулась игроку ([A-Za-z0-9%a]+_[A-Za-z0-9%a]+) при открытии '([^']*)' и он выиграл предмет: (.+)") then
		local nick, larec, prize = text:match("Удача улыбнулась игроку ([A-Za-z0-9%a]+_[A-Za-z0-9%a]+) при открытии '([^']*)' и он выиграл предмет: (.+)")
		local msg = string.format("[`".. os.date("%X") .."`] #доесть@ArzNespitBot `%s` открыл *%s* и выбил `%s`",nick,larec,prize)
		print("{FF0000}Выбивание: {FFFFFF}"..msg)
		sendTelegram(true,msg)
	end
	if text:find("кикнул игрока "..GetNick(true)) then
		sendTelegram(true,text)
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
			settings.TimeValue = hour
			settings();
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
			settings.WeatherValue = id
			if id >= 21 then imWeatherName = imWeatherNameList[22] else imWeatherName = imWeatherNameList[id+1] end
			settings();
		end
		return nil
	end
end
-->> Telegram
function sendTelegram(notification,msg)
	if settings.TelegramNotifications == true then
		local msg = tostring(msg):gsub('{......}', '')
		msg = tostring(msg):gsub(' ', '%+')
		msg = tostring(msg):gsub('\n', '%%0A')
		msg = tostring(msg):gsub('#',"\\%%23")
		msg = tostring(msg):gsub('%[',"\\%%5B")
		msg = tostring(msg):gsub('%]',"\\%%5D")
		msg = tostring(msg):gsub('@',"\\%%40")
		local params = "&parse_mode=MarkdownV2"
		if not notification then params = params.."&disable_notification=true" end
		local url = 'https://api.telegram.org/bot'.. settings.TelegramToken ..'/sendMessage?chat_id='.. settings.TelegramChat .. params ..'&text=' .. u8(msg)
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
		if settings.autoeat == true then
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
	if text:match("Style: ~g~Comfort!") then
	end
	if text:match("Style: ~r~Sport!") then
	end
	--Logger("S: "..style.." | T: ".. time.. " | Text: "..text)
end
function hook.onSendChat(message)
	if not isViceCity() then 
		message = message:gsub("%(алло%)", settings.PhNumber)
		message = message:gsub("%(alo%)", settings.PhNumber)
	else
		message = message:gsub("%(алло%)", settings.PhNumberVice)
		message = message:gsub("%(alo%)", settings.PhNumberVice)
	end
	message = message:gsub("%(id%)", tostring(myid))
	message = message:gsub("%(ид%)", tostring(myid))
	return {message}
end
function hook.onSendCommand(message)
	if not isViceCity() then 
		message = message:gsub("%(алло%)", settings.PhNumber)
		message = message:gsub("%(alo%)", settings.PhNumber)
	else
		message = message:gsub("%(алло%)", settings.PhNumberVice)
		message = message:gsub("%(alo%)", settings.PhNumberVice)
	end
	message = message:gsub("%(id%)", tostring(myid))
	message = message:gsub("%(ид%)", tostring(myid))
	return {message}
end

function hook.onCreate3DText(id,color,position,distance,testLOS,attachedPlayerId,attachedVehicleId,text)
	
end
function hook.onShowDialog(id, style, title, button1, button2, text)
	if(id == 991 or id == 26559) then -- PIN CODE
		if (settings.bankPin == "") then 
		else
			sampSendDialogResponse(id, 1, 0, settings.bankPin)
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
		if text:find(GetNick(false)) then 
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

function MimStyle()
    local style = imgui.GetStyle();
    local colors = style.Colors;
    style.Alpha = 1;
    style.WindowPadding = imgui.ImVec2(8.00, 8.00);
    style.WindowRounding = 12;
    style.WindowBorderSize = 0;
    style.WindowMinSize = imgui.ImVec2(32.00, 32.00);
    style.WindowTitleAlign = imgui.ImVec2(0.50, 0.50);
    style.ChildRounding = 6;
    style.ChildBorderSize = 0;
    style.PopupRounding = 12;
    style.PopupBorderSize = 0;
    style.FramePadding = imgui.ImVec2(10.00, 5.00);
    style.FrameRounding = 7;
    style.FrameBorderSize = 0;
    style.ItemSpacing = imgui.ImVec2(5.00, 4.00);
    style.ItemInnerSpacing = imgui.ImVec2(10.00, 4.00);
    style.IndentSpacing = 20;
    style.ScrollbarSize = 10;
    style.ScrollbarRounding = 12;
    style.GrabMinSize = 8;
    style.GrabRounding = 12;
    style.TabRounding = 7;
    style.ButtonTextAlign = imgui.ImVec2(0.50, 0.50);
    style.SelectableTextAlign = imgui.ImVec2(0.50, 0.50);
    colors[imgui.Col.Text] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00);
    colors[imgui.Col.TextDisabled] = imgui.ImVec4(0.50, 0.50, 0.50, 1.00);
    colors[imgui.Col.WindowBg] = imgui.ImVec4(0.20, 0.20, 0.20, 0.94);
    colors[imgui.Col.ChildBg] = imgui.ImVec4(0.20, 0.20, 0.20, 0.94);
    colors[imgui.Col.PopupBg] = imgui.ImVec4(0.20, 0.20, 0.20, 0.94);
    colors[imgui.Col.Border] = imgui.ImVec4(0.43, 0.43, 0.50, 0.50);
    colors[imgui.Col.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00);
    colors[imgui.Col.FrameBg] = imgui.ImVec4(0.00, 0.26, 0.64, 0.54);
    colors[imgui.Col.FrameBgHovered] = imgui.ImVec4(0.26, 0.59, 0.98, 0.40);
    colors[imgui.Col.FrameBgActive] = imgui.ImVec4(0.26, 0.59, 0.98, 0.67);
    colors[imgui.Col.TitleBg] = imgui.ImVec4(0.16, 0.29, 0.48, 0.79);
    colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.16, 0.29, 0.48, 1.00);
    colors[imgui.Col.TitleBgCollapsed] = imgui.ImVec4(0.16, 0.29, 0.48, 0.70);
    colors[imgui.Col.MenuBarBg] = imgui.ImVec4(0.16, 0.29, 0.48, 0.78);
    colors[imgui.Col.ScrollbarBg] = imgui.ImVec4(0.00, 0.00, 0.00, 0.59);
    colors[imgui.Col.ScrollbarGrab] = imgui.ImVec4(0.34, 0.34, 0.34, 1.00);
    colors[imgui.Col.ScrollbarGrabHovered] = imgui.ImVec4(0.41, 0.41, 0.41, 1.00);
    colors[imgui.Col.ScrollbarGrabActive] = imgui.ImVec4(0.51, 0.51, 0.51, 1.00);
    colors[imgui.Col.CheckMark] = imgui.ImVec4(0.23, 0.42, 0.70, 1.00);
    colors[imgui.Col.SliderGrab] = imgui.ImVec4(0.16, 0.29, 0.48, 1.00);
    colors[imgui.Col.SliderGrabActive] = imgui.ImVec4(0.22, 0.39, 0.64, 1.00);
    colors[imgui.Col.Button] = imgui.ImVec4(0.18, 0.35, 0.58, 0.86);
    colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.16, 0.29, 0.48, 1.00);
    colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.21, 0.38, 0.61, 1.00);
    colors[imgui.Col.Header] = imgui.ImVec4(0.72, 0.72, 0.72, 0.31);
    colors[imgui.Col.HeaderHovered] = imgui.ImVec4(0.18, 0.35, 0.58, 0.74);
    colors[imgui.Col.HeaderActive] = imgui.ImVec4(0.18, 0.35, 0.58, 0.86);
    colors[imgui.Col.Separator] = imgui.ImVec4(0.43, 0.43, 0.50, 0.50);
    colors[imgui.Col.SeparatorHovered] = imgui.ImVec4(0.10, 0.40, 0.75, 0.78);
    colors[imgui.Col.SeparatorActive] = imgui.ImVec4(0.10, 0.40, 0.75, 1.00);
    colors[imgui.Col.ResizeGrip] = imgui.ImVec4(0.66, 0.66, 0.66, 0.31);
    colors[imgui.Col.ResizeGripHovered] = imgui.ImVec4(0.77, 0.77, 0.77, 0.67);
    colors[imgui.Col.ResizeGripActive] = imgui.ImVec4(0.18, 0.35, 0.58, 0.86);
    colors[imgui.Col.Tab] = imgui.ImVec4(0.18, 0.35, 0.58, 0.51);
    colors[imgui.Col.TabHovered] = imgui.ImVec4(0.18, 0.35, 0.58, 1.00);
    colors[imgui.Col.TabActive] = imgui.ImVec4(0.24, 0.45, 0.75, 0.86);
    colors[imgui.Col.TabUnfocused] = imgui.ImVec4(0.07, 0.10, 0.15, 0.97);
    colors[imgui.Col.TabUnfocusedActive] = imgui.ImVec4(0.14, 0.26, 0.42, 1.00);
    colors[imgui.Col.PlotLines] = imgui.ImVec4(0.61, 0.61, 0.61, 1.00);
    colors[imgui.Col.PlotLinesHovered] = imgui.ImVec4(1.00, 0.43, 0.35, 1.00);
    colors[imgui.Col.PlotHistogram] = imgui.ImVec4(0.90, 0.70, 0.00, 1.00);
    colors[imgui.Col.PlotHistogramHovered] = imgui.ImVec4(1.00, 0.60, 0.00, 1.00);
    colors[imgui.Col.TextSelectedBg] = imgui.ImVec4(0.26, 0.59, 0.98, 0.35);
    colors[imgui.Col.DragDropTarget] = imgui.ImVec4(1.00, 1.00, 0.00, 0.90);
    colors[imgui.Col.NavHighlight] = imgui.ImVec4(0.18, 0.35, 0.58, 0.86);
    colors[imgui.Col.NavWindowingHighlight] = imgui.ImVec4(1.00, 1.00, 1.00, 0.70);
    colors[imgui.Col.NavWindowingDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.20);
    colors[imgui.Col.ModalWindowDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.35);
end