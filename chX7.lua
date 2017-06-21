local horizontalCharSpacing = 6
local verticalCharSpacing   = 10
local x = 0
local y = 0
local chrono = 0
local tableau = {0, 0, 0, 0}
local nbtour = 1
local buffer = 0
local score = 0
local timer = {}

local function InitUi() --initTimerRACE
	timer.start = 0
	timer.value = 0
	timer.countdownBeep = 0
	timer.persistent = 0
	timer.mode = 5 --SFup
	model.setTimer(0, timer)
end

local function DrawScreen()
  lcd.clear()
  lcd.drawFilledRectangle(0, 0, LCD_W, verticalCharSpacing)
end

local function DrawChrono() --DrawChonoValue
			lcd.drawTimer(x+20, y+30, tableau[1], MIDSIZE)
 			lcd.drawTimer(x+20, y+45, tableau[2], MIDSIZE)
 			lcd.drawTimer(x+70, y+30, tableau[3], MIDSIZE)
 			lcd.drawTimer(x+70, y+45, tableau[4], MIDSIZE)
 			lcd.drawText(5,10,nbtour)
 			lcd.drawText(10,10,getValue(89))
end

local function Chrono()
local race = model.getTimer(0)
	if  getValue(94) == 1024 and nbtour == 1  and race.value > 5 then -- tour.value < 1 and race.value > 10 
		tableau[1] = race.value
		nbtour = 2
		buffer = 0
	end
	if getValue(94) == 1024 and race.value > 5 and nbtour == 2 and buffer > 150 then
		tableau[2] = race.value - math.abs(tableau[1])
		nbtour = 3
		buffer = 0
	end
	if getValue(94) == 1024 and race.value > 5 and nbtour == 3 and buffer > 150 then
		tableau[3] = race.value - math.abs((tableau[1]+tableau[2]))
		nbtour = 4
		buffer = 0
	end
	if getValue(94) == 1024 and race.value > 5 and nbtour == 4 and buffer > 150 then
		tableau[4] = race.value - math.abs((tableau[1]+tableau[2]+tableau[3]))
		nbtour = 5
		buffer = 0
	end
buffer = buffer + 1
end

local function BestLap()
	if tableau[1] < tableau[2] and tableau[1] < tableau[3] and tableau[1] < tableau[4] then
		score = 1
	end
	if tableau[2] < tableau[1] and tableau[2] < tableau[3] and tableau[2] < tableau[4] then 
		score = 2
	end
	if tableau[3] < tableau[1] and tableau[3] < tableau[2] and tableau[3] < tableau[4] then
		score = 3
	end
	if tableau[4] < tableau[1] and tableau[4] < tableau[2] and tableau[4] < tableau[3] then
		score = 4
	end
	if nbtour == 5 then
		lcd.drawTimer(47,15,tableau[score], MIDSIZE+INVERS+BLINK)
	end

	if getValue(94) == 1024 and getValue(89) > -1024 then
			model.resetTimer(0)
			tableau[1] = 0
			tableau[2] = 0
			tableau[3] = 0
			tableau[4] = 0
			score = 0
			nbtour = 1
			buffer = 0
	end
end


local function Run(event)
Chrono()
DrawScreen()
DrawChrono()
BestLap()	
  return 0
end





return {init=InitUi, run=Run}
