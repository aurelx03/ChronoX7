-- ----------------------------------------------------
-- Chronométreur - v 6.6 - 07/07/2017
-- Aurel Firmware - Nore Fpv - Dom Wilk
-- ----------------------------------------------------
local tPage={}

-- Inters
local sw_Arm 	 
local sw_Arm_Off 

local sw_Lap 	 
local sw_Reset 	 
local sw_Reset_On
local sw_Test 	 
local sw_Test_On 

-- Option de départ
local v_start_throttle	
local v_nb_tours 		
local v_start_mode 		
local v_start_top		
local v_currentLap 		

-- Gestion Temps
local tab_times	={}
local start		=getTime()*10
local delay		=getTime()/100
local v_delai_tour 	

-- inter logique seuil RSSI
local id_rssi_ls
local id_rssi_ok
local id_thr
local id_rssi
local v_seuil
local v_ls_rssi

-- Sons
local snd_start
local snd_topDepart
local v_topDepart
local snd_best
local snd_fin

-- Flags
local v_TestMode	=false
local v_TestMode_chg=false
local v_Armed		=false
local v_Reset		=false
local v_ResetSleep	=0
local v_Finish		=false

local v_best_lap 	=0

local DrawImage

-- ----------------------------------------------------------------------------------------------------------
tPage.getTimeStr = function(aTimeMs)
	
	local v_ss = aTimeMs/1000
	local v_mm = math.floor(v_ss/60)

	v_ss = v_ss % 60

	if v_ss == 0
		then return "--:--.-- "
		else return string.format("%02d:%05.2f", v_mm, v_ss)
	end
end

-- ----------------------------------------------------------------------------------------------------------
tPage.DrawChrono = function() 

	local t_chronos ={}

	if i_IsX9D then 
		t_chronos={ 	
		[1]={xn= 3,y=29,xt=18},
		[2]={xn= 3,y=47,xt=18},
		[3]={xn=75,y=29,xt=90},
		[4]={xn=75,y=47,xt=90}
		}
	else
		t_chronos={ 	
		[1]={xn= 1,y=23,xt=12},
		[2]={xn= 1,y=38,xt=12},
		[3]={xn=65,y=23,xt=76},
		[4]={xn=65,y=38,xt=76}
		}
	end

	local v_Idx = v_currentLap-5 > 0 and v_currentLap-5 or 0
	
	local i, v_time

	for i=1,4 do

		-- si on charche à afficher un temps au-delà du nb de temps enregistrés, alors "0" secondes (v_time = <test> and <valeur si vrai> or <valeur si faux>)
		v_time = #tab_times >= v_Idx+i and tab_times[v_Idx+i] or 0

		lcd.drawText( t_chronos[i].xn, t_chronos[i].y, tostring(v_Idx+i), SMLSIZE+INVERS)
		lcd.drawText( t_chronos[i].xt, t_chronos[i].y, tPage.getTimeStr(v_time), MIDSIZE)
	end

	t_chronos = clearTable(t_chronos) -- fait gagner + ou - 7Ko de pic

end

-- ----------------------------------------------------------------------------------------------------------
tPage.DrawRSSI = function()

	if i_IsX9D then
		lcd.drawFilledRectangle(153, 33, 212, 63,ERASE)
		lcd.drawText(156,30,"RSSI")
		lcd.drawText(185, 27, id_rssi ~=0 and tostring(getValue(id_rssi)) or "Off" , MIDSIZE)
		lcd.drawText(156,43,"Seuil") 
		lcd.drawText(185, 40, v_seuil<100 and (id_rssi ~=0 and v_seuil or "Off") or "Off", MIDSIZE)
	else
		lcd.drawText(2,55,"RSSI",SMLSIZE+INVERS)
		lcd.drawText(24, 54, id_rssi ~=0 and tostring(getValue(id_rssi)) or "Off"  )
		lcd.drawText(85,55,"Seuil",SMLSIZE+INVERS)
		lcd.drawFilledRectangle(110, 54, 18, 9,ERASE)
		lcd.drawText(110, 54, v_seuil<100 and (id_rssi ~=0 and v_seuil or "Off") or "Off")
	end

	if v_TestMode then
		if getValue(id_rssi_ok) == 1024 then playTone( 900, 300 , 0, PLAY_NOW ) end

		if i_IsX9D then
			lcd.drawFilledRectangle(152, 53, 55, 10,SOLID)
			lcd.drawText(158,55,"Mode Test",SMLSIZE+INVERS+BLINK)
		else
			lcd.drawFilledRectangle(50, 53, 28, 10,SOLID)
			lcd.drawText(55,55,"Test",SMLSIZE+INVERS+BLINK)
		end
	elseif v_TestMode ~= v_TestMode_chg then
		if i_IsX9D 
		then lcd.drawFilledRectangle(152, 53, 55, 10,ERASE)
		else lcd.drawFilledRectangle( 50, 53, 28, 10,ERASE)
		end
	end

	return 0

end

-- ----------------------------------------------------------------------------------------------------------
tPage.DrawScreen = function()

	lcd.clear()
	lcd.drawFilledRectangle(0, 0, LCD_W, 9,SOLID)

	local v_titre = v_start_mode == -1 and "Chronometre - Depart lance" or "Chronometre - Depart arrete"

	if not i_IsX9D then v_titre = string.gsub(v_titre, "Chronometre", "Chrono") end

	lcd.drawText(LCD_W/2- (i_IsX9D and 67 or 51) ,1,v_titre,SMLSIZE+INVERS)

	if i_IsX9D then 
		lcd.drawLine(0,25,LCD_W,25,SOLID,0)
		lcd.drawLine(0,43,146,43,SOLID,0)
		lcd.drawLine(70,26,70,63,SOLID,0)
		lcd.drawLine(147,26,147,63,SOLID,0)
		DrawImage = p_Tools.drawFile010('/SCRIPTS/CHRONO/logoCD.010', LCD_W-23,10)
	else
		lcd.drawLine(0,21,LCD_W,21,SOLID,0)
		lcd.drawLine(0,36,LCD_W,36,SOLID,0)
		lcd.drawLine(64,22,64,51,SOLID,0)
		lcd.drawLine(0,51,LCD_W,51,SOLID,0)
		--lcd.drawLine(128,0,128,63,SOLID,0) -- X7 (pour simu)
		DrawImage = p_Tools.drawFile010('/SCRIPTS/CHRONO/logoCD.QX7', (128-22)/2,53)
	end

	

end

-- ----------------------------------------------------------------------------------------------------------
tPage.DrawStatut = function()

	-- nettoyage de la zone
	if i_IsX9D 
		then lcd.drawFilledRectangle(2, 10, 153, 15,ERASE)
		else lcd.drawFilledRectangle(2, 11,  80, 10,ERASE)
	end

	-- Consulation des temps
	if v_Finish then
		lcd.drawText(2,12,string.format("Tours %i > %i", v_currentLap-4 > 0 and v_currentLap-4 or 1, v_currentLap-1 > 3 and  v_currentLap-1 or 4),SMLSIZE)
		return 0
	end

	local v_attr 	= i_IsX9D and  0 or SMLSIZE 
	local v_xNbTour	= i_IsX9D and 40 or 33 

	-- Attente Départ
	if v_currentLap==v_start_mode then
		lcd.drawText(5,12,v_topDepart and "Armez pour top depart..." or "Attente Depart ...",v_attr+INVERS+BLINK)
	-- Départ lancé, attente passage
	elseif v_currentLap == 0 and v_start_mode == -1 then 
		lcd.drawText(5,12,"Attente passage ...",v_attr+BLINK)

	-- Course terminée
	elseif v_currentLap==v_nb_tours+1 then 
		lcd.drawText(2,12,"Terminee !",v_attr)

	-- Affichage du tour encours		
	else
		if v_best_lap == 0 then 
			lcd.drawFilledRectangle(i_IsX9D and 154 or 80, 10, i_IsX9D and 58 or 48, i_IsX9D and 15 or 10,ERASE) 
			v_best_lap = 1
		end
		lcd.drawText(2,12,"Tour n.",v_attr)
		lcd.drawText(v_xNbTour,12,v_currentLap,INVERS)
		lcd.drawText(lcd.getLastPos()+1,12,string.format("/%i", v_nb_tours))
	end

	return 0
end

-- ----------------------------------------------------------------------------------------------------------
tPage.Reset = function(aSleep)

	if aSleep>0 and v_ResetSleep<1 then
		v_ResetSleep = aSleep
		DrawImage = p_Tools.drawFile010('/SCRIPTS/CHRONO/logoCD.010',(LCD_W-22)/2,8)
		-- dessin de pause
		lcd.clear()
		lcd.drawText((LCD_W-120)/2,25,"CHRONODRONE",DBLSIZE)
		lcd.drawText((LCD_W-120)/2,40,"remet vos compteurs a zero",SMLSIZE)
	else 
		v_ResetSleep=v_ResetSleep-1
	end

	if v_ResetSleep == aSleep then 
		
		clearTable(tab_times)

		v_currentLap = v_start_mode
		delay		 = getTime()/100
		v_Finish	 = false
		v_best_lap	 = 1
		
		v_topDepart  = v_start_top ~= 0
	end

	if (aSleep==0 or v_ResetSleep==0) and not v_Reset then 
		tPage.DrawScreen() 
		tPage.DrawChrono(0) 
	end

end

-- ----------------------------------------------------------------------------------------------------------
tPage.BestLap = function()

	-- nettoyage de la zone
	if i_IsX9D 
		then lcd.drawFilledRectangle(154, 10, 58, 15,ERASE)
		else lcd.drawFilledRectangle(80, 11,  48, 10,ERASE)
	end

	local v_best_time = 9999999, i

	for i=v_best_lap, #tab_times do
		if tab_times[i]>0 and tab_times[i] < v_best_time then
			v_best_time = tab_times[i]
			if v_best_lap<i then
				v_best_lap=i
				playFile(snd_best)
			end
		end
	end

	if v_best_time ~= 9999999 then
		if i_IsX9D then
			lcd.drawText(156, 11,tPage.getTimeStr(v_best_time), MIDSIZE+INVERS)
			lcd.drawNumber(206, 12,v_best_lap, SMLSIZE+INVERS)
		else
			lcd.drawText(83, 12,tPage.getTimeStr(v_best_time), INVERS)
			lcd.drawNumber(120, 11,v_best_lap, SMLSIZE+INVERS)
		end
	end
end

-- ----------------------------------------------------------------------------------------------------------
tPage.NewLap = function()
	
	local vNow =getTime()*10
	local vTime=vNow-start

	if v_currentLap>0 then
		tab_times[#tab_times + 1] = vTime
		playTone( 300*v_currentLap, 300 , 300, PLAY_NOW )
		if v_currentLap == v_nb_tours
			then playFile(snd_fin)
			else playNumber(v_currentLap, 0)
		end
	else
		if v_start_top ==0 then playFile(snd_start) end
	end

	v_currentLap = v_currentLap + 1
	start = vNow
	delay = vNow/1000

	tPage.DrawChrono(0)
	tPage.DrawStatut()
	tPage.BestLap()
end

-- ----------------------------------------------------------------------------------------------------------
tPage.Chrono = function()

	-- Faux Départ = aucun tour n'a été validé
	if not v_Armed then
		if not v_topDepart and v_start_top~=0 and tab_times[1]==0 then	-- faux départ
			v_topDepart = true
		end
		return
	end

	-- La radio joue la séquence sonore de départ
	if v_topDepart then
		playFile(snd_topDepart)
		v_topDepart = false
	end

	-- Décollage : Départ lancé ou Arrêté
	if v_currentLap==v_start_mode and getValue(id_thr)>v_start_throttle then
	
		start = getTime()*10
		v_currentLap=v_start_mode+1
	
		-- Départ lancé
		if v_currentLap == 0 then
			delay=v_delai_tour-1

		else
			delay=getTime()/100
			if v_start_top==0 then playFile(snd_start) end -- Départ arrêté
		end
	end

	-- Départ lancé, attente 1° validation
	if v_currentLap == 0 and v_start_mode==-1 then playTone( 300, 300 , 300, PLAY_NOW ) end

	-- délai non écoulé
	if (getTime()/100)-delay < v_delai_tour then return end

	-- veille validation
	if v_currentLap>v_start_mode then
		if v_currentLap<v_nb_tours+1 then
			if getValue(sw_Lap)==1024 or (v_seuil<100 and getValue(id_rssi_ok)==1024)	then tPage.NewLap() end
		end
	end
end

-- ----------------------------------------------------------------------------------------------------------
tPage.init = function()

	p_Tools.Params_Load()

	id_thr=getFieldInfo("thr").id
	id_rssi = getFieldInfo("RSSI")~=nil and getFieldInfo("RSSI").id or 0	

	--img_sponsor = loadFile010("/SCRIPTS/CHRONO/logo.010")

	v_start_throttle=tonumber(t_Params.start_throttle)
	v_start_mode	=tonumber(t_Params.start_mode)
	v_start_top		=tonumber(t_Params.start_top)
	v_nb_tours		=tonumber(t_Params.nb_tours)
	v_delai_tour 	=tonumber(t_Params.delay)

	v_topDepart = v_start_top ~= 0
	if v_topDepart
		then snd_topDepart=t_Params.snd_topDepart
		else snd_topDepart=nil
	end

	id_rssi_ls=tonumber(t_Params.sw_Lap_ls_num)
	id_rssi_ok=getFieldInfo(string.format("ls%i", id_rssi_ls+1)).id


	sw_Arm 	  =getFieldInfo(t_Params.sw_Arm).id
	sw_Arm_Off=tonumber(t_Params.sw_Arm_Off)

	sw_Lap		=getFieldInfo(t_Params.sw_Lap).id
	sw_Test		=getFieldInfo(t_Params.sw_Test).id
	sw_Test_On	=tonumber(t_Params.sw_Test_On)
	sw_Reset 	=getFieldInfo(t_Params.sw_Reset).id
	sw_Reset_On	=tonumber(t_Params.sw_Reset_On)

	v_currentLap = v_start_mode

	v_seuil = tonumber(t_Params.seuil)
	v_ls_rssi = model.getLogicalSwitch(id_rssi_ls)
	v_ls_rssi.v2 = v_seuil
	model.setLogicalSwitch(id_rssi_ls,v_ls_rssi)
	clearTable(v_ls_rssi)
	v_ls_rssi = nil

	snd_start=t_Params.snd_start
	snd_best =t_Params.snd_best
	snd_fin  =t_Params.snd_fin

	tPage.Reset(0)
	return(0)

end

-- ----------------------------------------------------------------------------------------------------------
tPage.run = function(aEvent)

	if t_Params~=nil then 
		clearTable(t_Params) 
		t_Params=nil
	end

	if aEvent==EVT_PAGE_BREAK or aEvent==191 or aEvent==EVT_EXIT_BREAK  or v_nb_tours<0 then --35
		tPage.DrawScreen()
		tPage.DrawChrono(0)
		if v_nb_tours<0 then v_nb_tours = v_nb_tours * -1 end
		if aEvent==EVT_PAGE_BREAK then v_nb_tours = v_nb_tours * -1 end -- subterfuge pour faire redessiner une 2° fois l'écran
	end

	v_TestMode = getValue(sw_Test)  == sw_Test_On
	v_Armed    = getValue(sw_Arm)   ~= sw_Arm_Off
	v_Reset    = getValue(sw_Reset) == sw_Reset_On
	v_Finish   = not v_Armed and not v_TesMode and #tab_times>0

	if v_TestMode or not v_Finish then
		local v_Move = p_Tools.Button_GetMove(aEvent)
		if v_Move ~=0 then
			if (v_seuil < 100 and v_Move == 1) or (v_seuil >0    and v_Move == -1) then 
				v_seuil = v_seuil + v_Move
				v_ls_rssi = model.getLogicalSwitch(id_rssi_ls) 
				v_ls_rssi.v2 = v_seuil
				model.setLogicalSwitch(id_rssi_ls,v_ls_rssi)
				p_Tools.Params_Load()
				t_Params.seuil = v_seuil
				p_Tools.config_write(t_Params,"")
				clearTable(t_Params)
				t_Params = nil
				clearTable(v_ls_rssi)
				v_ls_rssi = nil
				if v_TestMode 
					then playNumber(v_seuil,0) 
					else playTone( 9*v_seuil, 100 , 0, PLAY_NOW )
				end
			end
		end

	end

	if v_Finish then
		local v_Move = p_Tools.Button_GetMove(aEvent)

 		if v_Move ~=0 then
 			v_currentLap = v_currentLap + v_Move
			if v_currentLap < 5	 	 	    then v_currentLap = v_nb_tours+1 	playTone( 900, 300 , 0, PLAY_NOW ) end
			if v_currentLap > v_nb_tours+1 	then v_currentLap = 5			  	playTone( 900, 300 , 0, PLAY_NOW ) end
			tPage.DrawChrono()	
		end
	end

	--if v_currentLap==v_start_mode then tPage.DrawScreen() end
	
	-- Désarmé + SH
	if (v_Reset or v_ResetSleep>0) and not v_Armed then 
		tPage.Reset(30) 
	else
		tPage.DrawStatut()
		tPage.DrawRSSI()
		tPage.Chrono()
	end

	v_TestMode_chg = v_TestMode

	if DrawImage then DrawImage = DrawImage()==1 and DrawImage or nil end



	return 0

end

return tPage