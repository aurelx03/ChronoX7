-- ------------------------------------------------
-- Chronométreur - v 5.0 - 30/06/2017
-- - - - - - - - -- - - - - - - - - - - - - - - - - 
-- Aurel Firmware - Nore Fpv - Dom Wilk
-- - - - - - - - -- - - - - - - - - - - - - - - - - 
-- -----------------------------------------
assert(loadScript("/SCRIPTS/CHRONO/config.lua"))()




-- -----------------------------------------




-- Tableau paramètres  ------------------------------------------------------------------------------------------------------------------------------------
local t_Params = { 	["delay"]			= 15 ; 
					["seuil"] 			= 80 ;

					["sw_Arm"]  		="sb"  ; ["sw_Arm_Off"]=-1024 ; 
					["sw_Lap"]  		="sh"  ;
					["sw_Reset"] 		="sh"  ; ["sw_Reset_On"]=1024 ; 
					["sw_Test"] 		="sc"  ; ["sw_Test_On"]=0 ; 
					["sw_Lap_ls_num"]  	= 2    ;	
					["sl_Seuil"] 		="s1"  ;
					
					["start_mode"] 		= 0    ;
					["start_throttle"] 	= -500 ;
					["nb_tours"] 		= 4    ;
					["annonce_temps"] 	= 1    ;
					["snd_start"] 		= "/SOUNDS/fr/Cstart.wav";
					["snd_best"] 		= "/SOUNDS/fr/Cbest.wav";
				 	["snd_fin"] 		= "/SOUNDS/fr/Cfin.wav";
				 }


-- Inters -----------------------------------------------------------------------------------------------------------------------------------------------
local sw_Arm 	 = getFieldInfo(t_Params.sw_Arm).id  	-- Inter d'Armement  
local sw_Arm_Off = tonumber(t_Params.sw_Arm_Off)		-- Position Inter Armement Off 

local sw_Lap 	 = getFieldInfo(t_Params.sw_Lap).id  	-- Inter de RAZ et validation tour  
local sw_Reset 	 = getFieldInfo(t_Params.sw_Reset).id  	-- RAZ du chrono
local sw_Reset_On= tonumber(t_Params.sw_Reset_On)		-- Position Inter Reset On 
local sw_Test 	 = getFieldInfo(t_Params.sw_Test).id  	-- Test et Réglage, on ne compte pas les tours, on sonne quand le rssi est dans la plage  
local sw_Test_On = tonumber(t_Params.sw_Test_On)		-- Position Inter Test On 

-- Option de départ -------------------------------------------------------------------------------------------------------------------------------------
local v_start_throttle	= tonumber(t_Params.start_throttle)	-- valeur des gazs à laquelle le départ est validé (nécessaire aux deux modes "v_start_mode")
local v_nb_tours 		= tonumber(t_Params.nb_tours)		-- nombre de tours à faire
local v_start_mode 		= 0									--  0 = départ arrété, -1 = départ lancé
local v_currentLap 		= 0									-- tour en cours

-- Gestion Temps -----------------------------------------------------------------------------------------------------------------------------------------
local tab_times 	= {0, 0, 0, 0}							-- tableua des temps
local start 		= getTime()*10							-- début du tour en millisecondes
local delay 		= getTime()/100							-- delai écoulé depuis la dernière validation en secondes
local v_delai_tour 	= tonumber(t_Params.delay)				-- temps minimum entre 2 validations (évite des validations intermédiaires accidentelles)

-- inter logique seuil RSSI  -----------------------------------------------------------------------------------------------------------------------------
local id_rssi_ls = tonumber(t_Params.sw_Lap_ls_num)						-- N° de l'inter logique (LS1 = 0, LS2 = 1, LS3 = 2 ... LSN=N-1)
local id_rssi_ok = getFieldInfo("ls"..tostring(id_rssi_ls+1)).id 		-- idetifiant de l'inter logique
local id_seuil = getFieldInfo("s1").id  					-- Potar pour régler le Seuil de prise en compte du RSSI
local id_thr   = getFieldInfo("thr").id 					-- Identifiant du manche des gaz
local id_rssi  = getFieldInfo("RSSI").id 					-- Identifiant du sensor rssi
local v_seuil  = 100										-- Seuil à partir duquel le RSSI valide le tour (potar S1)
local v_rssi   = 100										-- Relevé RSSI (pour affichage uniquement)
local v_ls_rssi= {["func"]=4 ; v1=1 ; v2=-99 ; v3=0 ; ["and"]=0; delay=0; duration=0}

-- Autres options  -------------------------------------------------------------------------------------------------------------------------------------
local v_annonce_temps = tonumber(t_Params.annonce_temps)				-- annonce du temps à chaque validation (à voir)

-- Sons  -------------------------------------------------------------------------------------------------------------------------------------
local snd_start	= t_Params.snd_start
local snd_best  = t_Params.snd_best
local snd_fin   = t_Params.snd_fin


-- Flags -------------------------------------------------------------------------------------------------------------------------------------
local v_TestMode = false								-- le mode test est engagé (v5)	
local v_Armed    = false								-- le quad est censé être Armé
local v_Reset	 = false								-- true si inter reset activé
local v_Runed	 = false								-- le temps sont encore consultable

local v_best_lap = 1

-- type de radio
i_IsX9D = LCD_W > 200 -- permet d'ajuster l'affichage sur Taranis X9D ou QX7
--local i_IsX9D = false 		-- pour tester affichage sur QX7

v_currentScreen = SCREEN_SETUP					   


-- ------------------------------------
-- Formatage de milliscones en mm:ss:dd
-- ------------------------------------
local function getTimeMsAsString(aTimeMs)
  v_ss = aTimeMs/1000
  v_mm = math.floor(v_ss/60) -- minutes
  v_ss = v_ss % 60 			 -- secondes Modulo 60 > secondes et dixièmes restants
  
  if v_ss == 0
  	then v_time = "--:--.-- "
    else v_time = string.format("%02d:%05.2f", v_mm, v_ss)
  end
  return v_time
end

-- ------------------------------------
-- Condition RSSi Valide
-- ------------------------------------
local function getRssiValide()
	-- finalement via un inter logique plus réactif qu'un "getvalue("rssi")"
	v_valid =  	getValue(id_rssi_ok) == 1024
	return v_valid
end

-- ------------------------------------
-- Affichage des temps au tour 
-- ------------------------------------
-- une fois à la fin de chaque tour
local function DrawChrono(aIdx) 

	-- Affichage glissant des temps par rapport au tour en cours 
	-- quand plus de 4 tours, affichage de 1 à 4, puis 2 à 5 au 5° tour, 3 à 6 au 6° ... )
	if aIdx==0 then
		aIdx = v_currentLap-5
		if aIdx<0 then aIdx = 0 end
	end
	
	-- X9D
  	if i_IsX9D then 

		lcd.drawText(  3, 29,tostring(aIdx+1), SMLSIZE+INVERS)
		lcd.drawText( 18, 29,getTimeMsAsString(tab_times[aIdx+1]), MIDSIZE)
		
		lcd.drawText(  3, 47,tostring(aIdx+2), SMLSIZE+INVERS)
		lcd.drawText( 18, 47,getTimeMsAsString(tab_times[aIdx+2]), MIDSIZE)
		
		lcd.drawText(75, 29,tostring(aIdx+3), SMLSIZE+INVERS)
		lcd.drawText(90, 29,getTimeMsAsString(tab_times[aIdx+3]), MIDSIZE)
		
		lcd.drawText(75, 47,tostring(aIdx+4), SMLSIZE+INVERS)
		lcd.drawText(90, 47,getTimeMsAsString(tab_times[aIdx+4]), MIDSIZE)
	
	-- QX7
  	else
		lcd.drawText( 1, 21,tostring(aIdx+1), SMLSIZE+INVERS)
		lcd.drawText(12, 22,getTimeMsAsString(tab_times[aIdx+1]), MIDSIZE)
		
		lcd.drawText( 1, 37,tostring(aIdx+2), SMLSIZE+INVERS)
		lcd.drawText(12, 37,getTimeMsAsString(tab_times[aIdx+2]), MIDSIZE)
		
		lcd.drawText(65, 21,tostring(aIdx+3), SMLSIZE+INVERS)
		lcd.drawText(76, 22,getTimeMsAsString(tab_times[aIdx+3]), MIDSIZE)
		
		lcd.drawText(65, 37,tostring(aIdx+4), SMLSIZE+INVERS)
		lcd.drawText(76, 37,getTimeMsAsString(tab_times[aIdx+4]), MIDSIZE)
	end

	--if getValue(sw_Arm) ~= sw_Arm_Off then lcd.drawText(1, 1,"*", SMLSIZE+INVERS+BLINK) end -- DBG
		
end

-- -----------------------------------------
-- Affichage RSSI et Seuil de déclenchement
-- -----------------------------------------
-- continuel
local function DrawRSSI()

	-- Affichage RSSI et Seuil seulement si potar S1 tourné au-dessus du quart gauche (environ)
	if v_seuil > 25 then 

		v_rssi   = getValue(id_rssi)

		-- X9D
		if i_IsX9D then 
			lcd.drawFilledRectangle(153, 33, 212, 63,ERASE)
	  		lcd.drawText(156,30,"RSSI")
	  		lcd.drawNumber(185, 27, v_rssi, MIDSIZE)
	  		lcd.drawText(156,43,"Seuil") 
			lcd.drawNumber(185, 40, v_seuil, MIDSIZE)
		-- QX7
		else
			lcd.drawText(2,55,"RSSI",SMLSIZE+INVERS)
			lcd.drawNumber(24, 54, v_rssi )
			lcd.drawText(49,55,"Seuil",SMLSIZE+INVERS) 
			lcd.drawNumber(74, 54, v_seuil)

		end
	end

	-- Mode test
	if v_TestMode then
		if getRssiValide() then playTone( 900, 300 , 0, PLAY_NOW ) end

		if i_IsX9D then 
			lcd.drawFilledRectangle(152, 53, 55, 10,SOLID)
	  		lcd.drawText(158,55,"Mode Test",SMLSIZE+INVERS+BLINK) 
	  	else 
			lcd.drawFilledRectangle(90, 53, 28, 10,SOLID)
	  		lcd.drawText(95,54,"Test",SMLSIZE+INVERS+BLINK) 
	  	end

	end
end


-- -----------------------------------------
-- Dessin Structure écran
-- -----------------------------------------
-- une fois à la fin de chaque tour
local function DrawScreen()
  	lcd.clear()
  	lcd.drawFilledRectangle(0, 0, LCD_W, 63,ERASE)
  	
  	lcd.drawFilledRectangle(0, 0, LCD_W, 9,SOLID)
  	--lcd.drawText(LCD_W/2-26,1,"Chronometre",SMLSIZE+INVERS)
  	if v_start_mode == -1 
  		then v_titre = "Chronometre - Depart lance"
  		else v_titre = "Chronometre - Depart arrete"
  	end
  	lcd.drawText(LCD_W/2-67,1,v_titre,SMLSIZE+INVERS)

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

  	if v_currentLap==v_start_mode then 
  		lcd.drawText(5,11,"Attente Depart ...",v_attr+BLINK)

 	elseif v_currentLap == 0 and v_start_mode == -1 then 
  		lcd.drawText(5,11,"Attente passage ...",v_attr+BLINK)
  	
  	elseif v_currentLap==v_nb_tours+1 then 
  		lcd.drawText(2,11,"Terminee !",v_attr)
  
 	else
		lcd.drawText(2,11,"Tour n.",v_attr)
		lcd.drawText(v_xNbTour,11,v_currentLap,INVERS)
		lcd.drawText(lcd.getLastPos()+1,11,"/"..tostring(v_nb_tours))
 	end
 	DrawChrono(0)
end

-- -----------------------------------------
-- RAZ chrono et tours
-- -----------------------------------------
-- continuel
local function Reset() 

	for i=1, v_nb_tours do tab_times[i] = 0 end

	v_currentLap = v_start_mode
	delay  		 = getTime()/100
	v_Runed      = false
	v_best_lap   = 1

	DrawScreen()

	lcd.drawFilledRectangle(1, 10, LCD_W, LCD_H,ERASE)
	lcd.drawText((LCD_W-50)/2,25,"RESET",DBLSIZE) 
end

-- -----------------------------------------
-- Affichage meilleur tour
-- -----------------------------------------
-- une fois à la fin de chaque tour
local function BestLap()

	local v_best_time = 9999999

	-- Cherche le temps le plus faible parmi les tours réalisés
	for i=v_best_lap, v_nb_tours do
		if tab_times[i]>0 and tab_times[i] < v_best_time then 
			v_best_time = tab_times[i] 
			if v_best_lap < i then
				v_best_lap  = i 
				playFile(snd_best)
			end
		end
	end

	-- si un temps trouvé, on l'affiche
	if v_best_time ~= 9999999 then 
		if i_IsX9D then 
			lcd.drawText(156, 11,getTimeMsAsString(v_best_time), MIDSIZE+INVERS+BLINK)
			lcd.drawNumber(206, 12,v_best_lap, SMLSIZE+INVERS+BLINK)
		else
			lcd.drawText(91, 11,getTimeMsAsString(v_best_time), INVERS+BLINK)
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

	if aLap>0 then 
		tab_times[aLap] = vTime -- temps du tour
		--playNumber(vTime/100, 26, PREC1)	
		--playNumber(vTime/10, 27	, PREC2)	
		playTone( 300*aLap, 300 , 300, PLAY_NOW )
		if aLap == v_nb_tours
		  then playFile(snd_fin)
		  else playNumber(aLap, 0)
		end 
	else 
		playFile(snd_start)
	end 

	v_currentLap = aLap + 1		-- tour suivant
	start = vNow				-- horodate le début du tour
	delay = vNow/1000			-- delai minimum entre deux comptage

	
	DrawScreen()
	BestLap()
end

-- -----------------------------------------
-- Surveillance passage tour
-- -----------------------------------------
-- continuel
local function Chrono()

	-- si pas armé, on sort
	if not v_Armed then return end

	-- Start quand Throttle Up à 25%
	if v_currentLap==v_start_mode and getValue(id_thr)>v_start_throttle then
		start = getTime()*10
		v_currentLap=v_start_mode+1
		if v_currentLap == 0 then 
			delay=v_delai_tour-1
		else 
			delay=getTime()/100
			playFile(snd_start)
		end
		DrawScreen()
	end

	-- Départ lancé : Attente passage départ
	if v_currentLap == 0 and v_start_mode==-1 then playTone( 300, 300 , 300, PLAY_NOW ) end

	-- pas la peine d'aller plus loin si delay minimum entre validation pas écoulé
	if (getTime()/100)-delay < v_delai_tour then return end

	-- Validation du tour
	if v_currentLap>v_start_mode then 
		if  v_currentLap<v_nb_tours+1 then
			if  (getValue(sw_Lap) == 1024 
				or getRssiValide() ) 
			then
 				NewLap(v_currentLap)
 			end
 		end
 	end	

end





-- -----------------------------------------
-- Init
-- -----------------------------------------
local function InitUi() 
	
	v_currentScreen = SCREEN_RACE

	config_read(t_Params)
	
	v_start_throttle 	= tonumber(t_Params.start_throttle)
	v_start_mode 		= tonumber(t_Params.start_mode)
	v_nb_tours 	 		= tonumber(t_Params.nb_tours)
	v_delai_tour 		= tonumber(t_Params.delay)

	
	id_rssi_ls 	= tonumber(t_Params.sw_Lap_ls_num)
	id_rssi_ok 	= getFieldInfo("ls"..tostring(id_rssi_ls+1)).id

	sw_Arm 	 	= getFieldInfo(t_Params.sw_Arm).id  
 	sw_Arm_Off 	= tonumber(t_Params.sw_Arm_Off)

 	sw_Lap 	 	= getFieldInfo(t_Params.sw_Lap).id  	-- Inter de RAZ et validation tour  
	sw_Test 	= getFieldInfo(t_Params.sw_Test).id  	-- Test et Réglage, on ne compte pas les tours, on sonne quand le rssi est dans la plage  
	sw_Test_On 	= tonumber(t_Params.sw_Test_On)  		
	sw_Reset 	= getFieldInfo(t_Params.sw_Reset).id  	-- RAZ du chrono
	sw_Reset_On	= tonumber(t_Params.sw_Reset_On)  		
	
	v_currentLap = v_start_mode

	v_seuil = tonumber(t_Params.seuil)
	v_ls_rssi = model.getLogicalSwitch(id_rssi_ls) 
	v_ls_rssi.v2 = v_seuil
	model.setLogicalSwitch(id_rssi_ls,v_ls_rssi)
	
	--[[
	v_seuil = math.floor(((1024+getValue(id_seuil))/2)/10)
	if v_seuil>100 then v_seuil = 100 end
	
	if v_seuil > 25 then 
		
	end
	--]]
	
	while #tab_times < v_nb_tours do
		tab_times[#tab_times + 1] = 0
	end

	Reset()

	return (0)
end


-- -----------------------------------------
-- Main
-- -----------------------------------------
local function Run(aEvent)
	
	
	-- Appel des ecrans de config
	if aEvent == EVT_MENU_BREAK or v_currentScreen == SCREEN_SETUP then 
		config_screen(aEvent,t_Params) 
		return 0
	end

	-- Retour sur la Race
	if  aEvent == EVT_PAGE_BREAK or v_currentScreen == SCREEN_SETUPBACK then
		v_currentScreen = SCREEN_RACE
		InitUi()
		Reset()
	end
	
	
	-- Lire l'état des inters une seule fois par boucle
	v_TestMode = getValue(sw_Test)  == sw_Test_On
	v_Armed    = getValue(sw_Arm)   ~= sw_Arm_Off
	v_Reset    = getValue(sw_Reset) == sw_Reset_On
	--v_Reset    = aEvent == EVT_ENTER_BREAK and  v_currentScreen == SCREEN_RACE 
	v_Runed	   = not v_Armed and not v_TesMode and tab_times[1]~=0 


	-- Mode Test
	if v_TestMode or not v_Runed then
		v_Move = Button_GetMove(aEvent)
 		if v_Move ~=0 then
 			if (v_seuil < 100 and v_Move == 1)
 			or (v_seuil >0    and v_Move == -1)
 			then 
 				v_seuil = v_seuil + v_Move
 				v_ls_rssi = model.getLogicalSwitch(id_rssi_ls) 
				v_ls_rssi.v2 = v_seuil
				model.setLogicalSwitch(id_rssi_ls,v_ls_rssi)
				t_Params.seuil = v_seuil
				config_write(t_Params)
				if v_TestMode 
					then playNumber(v_seuil,0) 
					else playTone( 9*v_seuil, 100 , 0, PLAY_NOW )
				end
			end
		end
	end

	-- consultation temps
	if v_Runed then 
		v_Move = Button_GetMove(aEvent)
 		if v_Move ~=0 then
			v_currentLap = v_currentLap + v_Move
			if v_currentLap < 5	 	 	    then v_currentLap = v_nb_tours+1 	playTone( 900, 300 , 0, PLAY_NOW ) end
			if v_currentLap > v_nb_tours+1 	then v_currentLap = 5			  	playTone( 900, 300 , 0, PLAY_NOW ) end
			lcd.drawText(2,11,"Tours ".. tostring(v_currentLap-4) .." > ".. tostring(v_currentLap-1),SMLSIZE)
			DrawChrono(0)	
		end
		if i_IsX9D then 
			lcd.drawFilledRectangle(2, 10, 60, 15,ERASE)
			lcd.drawText(2,12,"Tours ".. tostring(v_currentLap-4) .." > ".. tostring(v_currentLap-1),SMLSIZE)
		else 
			lcd.drawFilledRectangle(2, 10, 70, 10,ERASE)
			lcd.drawText(2,11,"Tours ".. tostring(v_currentLap-4) .." > ".. tostring(v_currentLap-1),SMLSIZE)
		end
	end

	if v_currentLap==v_start_mode then DrawScreen() end
	
	Chrono()
	DrawRSSI()
	-- Désarmé + SH
	if v_Reset and not v_Armed then Reset() end

  	--lcd.drawText(180, 52,"Scr"..tostring(v_currentScreen)) --DBG
	--lcd.drawText(100, 52,"Reset"..tostring(getValue(sw_Reset))) --DBG
	return 0
end

return {init=InitUi, run=Run}