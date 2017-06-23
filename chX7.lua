--By Nore FPV et aurelx03
-- -----------------------------------------
-- Chronométreur sur 4 tours
-- - - - - - - - -- - - - - - - - - - - - - 
-- Décompte des tours soit avec "SH" soit par détection du RSSI
-- Réglagle du seuil RSSI de comptage par potar S1
-- Le Chrono démarre sur levé du manche des gaz (si armé)
-- - - - - - - - -- - - - - - - - - - - - - 
-- à déposer dans "SCRIPTS\TELEMETRY"
-- à lier à un écran de télémesure
-- -----------------------------------------

local tableau = {0, 0, 0, 0}
local start = getTime()*10
local nbtour = 0
local delay = 0
local delay_min = 100 -- delai minimum entre deux validations de tour
					  -- 100 = 5 secondes environ, 150 = 7.6 secondes	
-- type de radio
local i_IsX9D = LCD_W > 200 -- permet d'ajuster l'affichage sur Taranis X9D ou QX7
local i_IsX9D = false 		-- pour tester affichage sur QX7

-- Inters 
local id_thr = getFieldInfo("thr").id -- Throttle
local sw_Arm = getFieldInfo("sf").id  -- Arm Switch 
local sw_Lap = getFieldInfo("sh").id  -- Lap Switch

-- RSSI & Seuil
--local id_rssi = getFieldInfo("RSSI").id
--local v_rssi = getValue(id_rssi)
--local id_s1 = getFieldInfo("s1").id  -- Potar Seuil
--local v_s1 = getValue(id_s1)/10

-- test simu : on peut simuler les variations de RSSI avec le potar S2 (à désactiver avant de transférer sur la radio)
--local id_s2 = getFieldInfo("s2").id


-- ------------------------------------
-- Formatage de milliscones en mm:ss:dd
-- ------------------------------------
local function getTimeMsAsString(aTimeMs)
  v_ss = aTimeMs/1000
  v_mm = math.floor(v_ss/60) -- minutes
  v_ss = v_ss % 60 			 -- secondes Modulo 60 > secondes et dixièmes restants
  return string.format("%02d:%05.2f", v_mm, v_ss)
end

-- ------------------------------------
-- Affichage des temps au tour 
-- ------------------------------------
-- une fois à la fin de chaque tour
local function DrawChrono() 
	
	-- X9D
  	if i_IsX9D then 

		lcd.drawText(  3, 29,"1", SMLSIZE+INVERS)
		lcd.drawText( 18, 29,getTimeMsAsString(tableau[1]), MIDSIZE)
		
		lcd.drawText(  3, 47,"2", SMLSIZE+INVERS)
		lcd.drawText( 18, 47,getTimeMsAsString(tableau[2]), MIDSIZE)
		
		lcd.drawText(75, 29,"3", SMLSIZE+INVERS)
		lcd.drawText(90, 29,getTimeMsAsString(tableau[3]), MIDSIZE)
		
		lcd.drawText(75, 47,"4", SMLSIZE+INVERS)
		lcd.drawText(90, 47,getTimeMsAsString(tableau[4]), MIDSIZE)
	
	-- QX7
  	else
		lcd.drawText( 1, 21,"1", SMLSIZE+INVERS)
		lcd.drawText(12, 22,getTimeMsAsString(tableau[1]), MIDSIZE)
		
		lcd.drawText( 1, 37,"2", SMLSIZE+INVERS)
		lcd.drawText(12, 37,getTimeMsAsString(tableau[2]), MIDSIZE)
		
		lcd.drawText(65, 21,"3", SMLSIZE+INVERS)
		lcd.drawText(76, 22,getTimeMsAsString(tableau[3]), MIDSIZE)
		
		lcd.drawText(65, 37,"4", SMLSIZE+INVERS)
		lcd.drawText(76, 37,getTimeMsAsString(tableau[4]), MIDSIZE)
	end
end

-- -----------------------------------------
-- Affichage RSSI et Seuil de déclenchement
-- -----------------------------------------
-- continuel
local function DrawRSSI()

	-- Seuil RSSI définit par Potar S1
	-- pour plus de finesse, on prend toute la course du potar de -1024 à + 1024
 	--v_s1 = ((1024+getValue(id_s1))/2)/10
	-- vS1 varie entre 0 & 102
	--if v_s1>100 then v_s1 = 100 end

	-- Force du RSSI
	--v_rssi = getValue(id_rssi)
	
	-- test / s2 simule RSSI 				/!\ /!\ à inhiber avant d'envoyer sur la radio /!\ /!\
	--v_rssi = getValue(id_s2)/10
	--if v_rssi>100 then v_rssi = 100 end
	--if v_rssi<0   then v_rssi = 0 end

	-- Affichage RSSI et Seuil seulement si potar S1 tourné au-dessus du quart gauche (environ)
	--if v_s1 > 25 then 

		-- X9D
		--if i_IsX9D then 
			--lcd.drawFilledRectangle(153, 33, 212, 63,ERASE)
	  		--lcd.drawText(156,35,"RSSI")
	  		--lcd.drawNumber(185, 32, v_rssi, MIDSIZE)
	  		--lcd.drawText(156,50,"Seuil") 
			--lcd.drawNumber(185, 47, v_s1, MIDSIZE)
		
		-- QX7
		--else
			--lcd.drawText(2,55,"RSSI",SMLSIZE+INVERS)
			--lcd.drawNumber(24, 54, v_rssi )
			--lcd.drawText(60,55,"Seuil",SMLSIZE+INVERS) 
			--lcd.drawNumber(85, 54, v_s1)
		--end
	--end
end


-- -----------------------------------------
-- Affichage RSSI et Seuil de déclenchement
-- -----------------------------------------
-- une fois à la fin de chaque tour
local function DrawScreen()
  	lcd.clear()
  	lcd.drawFilledRectangle(0, 0, LCD_W, 63,ERASE)
  	
  	lcd.drawFilledRectangle(0, 0, LCD_W, 9,SOLID)
  	lcd.drawText(LCD_W/2-22,1,"Chronometre",SMLSIZE+INVERS)
  	
  	local v_attr 	= SMLSIZE
  	local v_xNbTour	= 33 -- X7
  	
  	-- X9D
  	if i_IsX9D then 
	  	lcd.drawLine(0,25,LCD_W,25,SOLID,0) --FORCE)
		lcd.drawLine(0,43,146,43,SOLID,0) 	-- sépare lignes
  		lcd.drawLine(70,26,70,63,SOLID,0) 	-- sépare colonnes  	
  		lcd.drawLine(147,26,147,63,SOLID,0) -- case RSSI
  		v_attr    = 0
		v_xNbTour = 40 	


  	-- QX7
  	else
		lcd.drawLine(0,20,LCD_W,20,SOLID,0) -- Info : Tour n° et meilleur chrono
  		--lcd.drawLine(128,0,128,63,SOLID,0) 	-- limite écran X7 (pour simu)
  		lcd.drawLine(0,35,LCD_W,35,SOLID,0) -- séparation lignes
  		lcd.drawLine(64,21,64,50,SOLID,0) 	-- séparation colonnes  	
  		lcd.drawLine(0,50,LCD_W,50,SOLID,0) -- séparation RSSI et Seuil
  	end 

  	if nbtour==0 then 
  		lcd.drawText(5,11,"Attente Depart ...",v_attr+BLINK)
 	else 
 		if nbtour==5 then 
  			lcd.drawText(2,11,"Terminee !",v_attr)
 		else
 			lcd.drawText(2,11,"Tour n.",v_attr)
  			lcd.drawText(v_xNbTour,11,nbtour,INVERS)
  		end
 	end
 	DrawChrono()
end

-- -----------------------------------------
-- RAZ chrono et tours
-- -----------------------------------------
-- continuel
local function Reset() 

	-- Armement au neutre + SH
	if getValue(sw_Lap) == 1024 and getValue(sw_Arm) == 1024 then
		tableau[1] = 0
		tableau[2] = 0
		tableau[3] = 0
		tableau[4] = 0
		nbtour = 0
		delay  = 0
		DrawScreen()
	end
end

-- -----------------------------------------
-- Affichage meilleur tour
-- -----------------------------------------
-- une fois à la fin de chaque tour
local function BestLap()

	local v_best = 9999999

	-- Cherche le temps le plus faible parmi les tours réalisés
	for i=1, 4 do
		if tableau[i]>0 and tableau[i] < v_best then v_best = tableau[i] end
	end

	-- si un temps trouvé, on l'affiche
	if v_best ~= 9999999 then 
		if i_IsX9D then 
			lcd.drawText(161, 11,getTimeMsAsString(v_best), MIDSIZE+INVERS+BLINK)
		else
			lcd.drawText(91, 11,getTimeMsAsString(v_best), INVERS+BLINK)
		end
	end
end


-- -----------------------------------------
-- Passage nouveau tour
-- -----------------------------------------
-- une fois à la fin de chaque tour
local function NewLap(aLap)
	
	
	vNow  = getTime()*10  -- Heure au passage
	vTime = vNow - start  -- Temps du tour	(start = Heure au passage précédent)

	tableau[aLap] = vTime	-- temps du tour
	nbtour = aLap + 1		-- tour suivant
	start = vNow			-- horodate le début du tour
	delay = 0				-- delai minimum entre deux comptage

	if aLap > 0 then 
		playTone( 300*nbtour, 300 , 300, PLAY_NOW )
		playNumber(aLap, 0) 
	end

	DrawScreen()
	BestLap()
end

-- -----------------------------------------
-- Surveillance passage tour
-- -----------------------------------------
-- continuel
local function Chrono()

		-- Start quand Throttle Up à 25%+arm
	if nbtour==0 and getValue(id_thr)>-500 and getValue(sw_Arm)<0 then

		-- on ne devrait pas toucher le potar une fois la course démarrée 
		-- inutile de lire à chaque fois la valeur
		--v_s1 = ((1024+getValue(id_s1))/2)/10
		--if v_s1>100 then v_s1 = 100 end

		start = getTime()*10
		nbtour=1
		delay=0
		playFile("/SOUNDS/hstart.wav")
		DrawScreen()
	end

	-- pas la peine d'aller plus loin si delay minimum entre validation pas écoulé
	if delay < delay_min then 
		delay = delay + 1
		return
	end


	--local v_rssi = getValue(id_rssi)

	-- test simu : S2 simule le RSSI       /!\ /!\ à inhiber avant d'envoyer sur la radio /!\ /!\
	--v_rssi = getValue(id_s2)/10
	--if v_rssi>100 then v_rssi = 100 end

	-- NewLap : Si armé ET "SH" up OU "RSSI" au delà du seuil
 	if nbtour>0 and nbtour<5  and getValue(sw_Arm)<0 
 	and getValue(sw_Lap) == 1024 --or (v_s1>25 and v_rssi >= v_s1)) 
 	then
 		NewLap(nbtour)
 	end	
end

-- -----------------------------------------
-- Init
-- -----------------------------------------
local function InitUi() 
end


-- -----------------------------------------
-- Main
-- -----------------------------------------
local function Run(event)
	if nbtour==0 then DrawScreen() end
	Chrono()
	DrawRSSI()
  	Reset()
	return 0
end

return {init=InitUi, run=Run}
