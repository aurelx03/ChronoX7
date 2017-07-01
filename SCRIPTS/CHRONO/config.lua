local f_config = '/SCRIPTS/CHRONO/chrono.cfg'

-- Ecrans 
SCREEN_RACE 		= 0
SCREEN_SETUP 		= 1
SCREEN_SETUPBACK 	= 2

local SETUP_RACE	= 3
local SETUP_INTERS	= 4

local v_SetupScreen = SETUP_RACE
local v_edit = false


local	t_fields_race  = { [1] = {field ="nb_tours", 		lx= 2, ly=12, text="Nb tours", 	dx= 50, dy=12, type="n+", 		stop=20, 	hint = "..."},
					 	   [2] = {field ="delay",			lx=70, ly=12, text="Delai", 	dx= 95, dy=12, type="n+", 		stop=60, 	hint = "delai entre 2 validations"},
						   [3] = {field ="seuil",			lx= 2, ly=22, text="Seuil RSSI",dx= 50, dy=22, type="n+", 		stop=100, 	hint = "seuil validation"},
						   [4] = {field ="start_throttle", 	lx= 2, ly=32, text="Seuil gaz", dx= 50, dy=32, type="sw_pos", 	stop="thr",	hint = "decollage du quad"},
						   [5] = {field ="start_mode",		lx= 2, ly=42, text="Depart", 	dx= 50, dy=42, type="n-", 		stop=-1, 	hint = "au decollage / 1er passage"}
						 }

local	t_fields_inters = { [1] = {field ="sw_Arm", 		lx= 2, ly=12, text="Armement", 	 dx= 55, dy=12, type="sw_name", stop=0, 			hint = "inter Armement"},
					 	    [2] = {field ="sw_Arm_Off",		lx=80, ly=12, text="Off", 		 dx=105, dy=12, type="sw_pos",  stop="fieldprec", 	hint = "Position Desarmee"},
						    [3] = {field ="sw_Lap" ,		lx= 2, ly=22, text="Valid tour", dx= 55, dy=22, type="sw_name", stop=0, 			hint = "Valid tour manuel"},
						    [4] = {field ="sw_Lap_ls_num", 	lx=80, ly=22, text="RSSI",  	 dx=105, dy=22, type="n+", 		stop=10, 			hint = "inter logique RSSI "},
						    [5] = {field ="sw_Reset",		lx= 2, ly=32, text="Reset", 	 dx= 55, dy=32, type="sw_name", stop=0, 			hint = "inter de R.A.Z du chrono"},
						    [6] = {field ="sw_Reset_On",	lx=80, ly=32, text="On", 	 	 dx=105, dy=32, type="sw_pos", 	stop="fieldprec", 	hint = "Position RAZ"},
						    [7] = {field ="sw_Test",		lx= 2, ly=42, text="Test", 		 dx= 55, dy=42, type="sw_name", stop=0, 			hint = "Tester le seuil RSSI"},
						    [8] = {field ="sw_Test_On",		lx=80, ly=42, text="On", 		 dx=105, dy=42, type="sw_pos",  stop="fieldprec", 	hint = "Position TEST"}
						  }

local t_switches = { ["sa"] = 0,
 					 ["sb"] = 0,
 					 ["sc"] = 0,
 					 ["sd"] = 0,
 					 ["se"] = 0,
 					 ["sf"] = 0,
 					 ["sg"] = 0,
 					 ["sh"] = 0
 				  }

local v_current_fields = t_fields_race	-- tabelau des champs à afficher
local v_focused_field = 0				-- n° du champ ayant le focus

-- -----------------------------------------------------------------------------
-- Selon la radio, les commandes "+" et "-" ne sont pas identiques
-- renvoi l'incrément
-- -----------------------------------------------------------------------------
function Button_GetMove(aEvent)
	v_Move = 0
	if (aEvent == EVT_PLUS_BREAK  and i_IsX9D) or (aEvent == EVT_ROT_RIGHT  and not i_IsX9D) 	then v_Move =  1 	end
	if (aEvent == EVT_MINUS_BREAK and i_IsX9D) or (aEvent == EVT_ROT_LEFT and not i_IsX9D) 	then v_Move = -1	end	
	return v_Move
end

-- -----------------------------------------------------------------------------
-- Lecture du fichier de config 
-- renvoi 
--	* le tableau des valeurs enregistrées dans le fichier de config
--  * "nil" si fichier vide ou impossibilité 
-- -----------------------------------------------------------------------------
function config_read(aFields)

	-- ouverture en "append" > création si inexistant
	local f = io.open(f_config, 'a')
	if f ~= nil then
		io.close(f)
	end

	-- echec ouverture fichier
	f = io.open(f_config, 'r')
	if f == nil then
		return false
	end
	
	local v_params = io.read(f, 1024)
	io.close(f)
	
	-- fichier vide
	if v_params == '' then
		return false
	end

	for v_pair in string.gmatch(v_params, '([^\n]+)') do
		v_key = string.sub(v_pair,1,string.find(v_pair, ":")-1)
		v_val = string.sub(v_pair,string.find(v_pair, ":")+1)
		aFields[v_key] = v_val
	end
	return true
end


-- -----------------------------------------------------------------------------
-- Ecriture des params de config
-- -----------------------------------------------------------------------------
function config_write(aFields)

	local f = io.open(f_config, 'w')

	for k, v in pairs(aFields) do
		s = k .. ":" .. tostring(v) .. "\n"
		io.write(f, s)
	end
	io.close(f)
end

-- -----------------------------------------------------------------------------
-- scan_switches
-- -----------------------------------------------------------------------------
-- lit la valuer de tous les inters 
-- si "aStop" = true, renvoit l'inter dont la valeur a changée
-- -----------------------------------------------------------------------------
local function scan_switches(aStop)
	for key, val in pairs(t_switches) do
		i = getValue(key)
		if val~=i then 
			t_switches[key] = i 
			if aStop then return key end	
		end
	end
	return nil
end

-- -----------------------------------------------------------------------------
-- field_draw
-- -----------------------------------------------------------------------------
local function fields_draw(aFieldsCoord, aFieldsList)

	lcd.drawFilledRectangle(1, 10, LCD_W, 63,ERASE)
			
	for key, tab in pairs(aFieldsCoord) do
		
		v_attr_text = SMLSIZE
		v_attr_data = SMLSIZE
		
		-- Le champ actif
		if tab.field == aFieldsCoord[v_focused_field].field then 

			-- en édtion ?
		  	if v_edit then 
		  		v_attr_data = v_attr_data + BLINK
		  		v_attr_text = v_attr_text + INVERS
		  		lcd.drawFilledRectangle(tab.lx, tab.ly-2, tab.dx-tab.lx-2, 11,SOLID)
			else 
				v_attr_data = v_attr_data + INVERS
		  	end

		  	-- dessin de l'aide
		  	lcd.drawFilledRectangle(1, 53, LCD_W, 63,SOLID)
			lcd.drawText(1, 54,  tab.hint, SMLSIZE + INVERS) 
		end 	

		-- Mise en forme ou Exceptions
		v_text = tab.text
		v_data = aFieldsList[tab.field]
		
		if tab.field =="delay" 		 	then v_data = tostring(v_data) .. "sec"	end
		if tab.field =="start_mode" 	then 
			if v_data == 0 
				then v_data = "arrete"
				else v_data = "lance"
			end	
		end
		
		if tab.field =="sw_Lap_ls_num" then 
			if i_IsX9D 	then v_data = "LS"..tostring(v_data+1) 	
						else v_data = "LO"..tostring(v_data+1) 		
			end
		elseif 
			tab.type =="sw_name"  then v_data = string.upper(v_data)
		end		
		-- affichage
		lcd.drawText(tab.lx, tab.ly, v_text, 	v_attr_text) 		
		lcd.drawText(tab.dx, tab.dy, v_data,	v_attr_data) 

	end
end

-- -----------------------------------------
-- Attente manip utilisateur
-- -----------------------------------------
local function field_draw_wait(aL1,aL2)

	xh = (LCD_W/2)-50
	yh = 15
	xb = 87
	yb = 30
	
	lcd.drawFilledRectangle  (xh, yh, xb+1, yb+1,ERASE)
	lcd.drawRectangle        (xh, yh, xb, yb, GREY_DEFAULT)
	
	lcd.drawText(xh +  5, 21, aL1, SMLSIZE+BLINK)
	lcd.drawText(xh + 18, 30, aL2, SMLSIZE+BLINK)
end


-- -----------------------------------------
-- Ecran de config
-- -----------------------------------------
function config_screen(aEvent,aFields) 

	-- Sauvegarde et Retour à l'écran "Race"
	if aEvent == EVT_EXIT_BREAK then 
		v_edit = false
		config_write(aFields)
		v_currentScreen = SCREEN_SETUPBACK 
		return
	end

	-- Arrivée sur ecran de config
	if v_currentScreen ~= SCREEN_SETUP then
		
		v_currentScreen = SCREEN_SETUP
		v_focused_field = 0

	-- ou faire défiler les menus
	elseif aEvent == EVT_MENU_BREAK then 
		 v_SetupScreen =  v_SetupScreen + 1
		 if v_SetupScreen > SETUP_INTERS then  v_SetupScreen = 0 end 
		 v_focused_field = 0
	end

	-- Config Course
	if v_SetupScreen == SETUP_RACE then
  		v_titre = "Chronometre - CONFIG RACE"
		v_current_fields = t_fields_race
	end

	-- Config Inters
	if v_SetupScreen == SETUP_INTERS then
  		v_titre = "Chronometre - CONFIG INTERS"
		v_current_fields = t_fields_inters
	end


	-- Titre et champs actif sur arrivée page Race ou Inters
	if v_focused_field ==0 then 
		
		-- Dessin Titre
		lcd.drawFilledRectangle(0, 0, LCD_W, 63,ERASE)
		lcd.drawFilledRectangle(0, 0, LCD_W, 9,SOLID)
		lcd.drawText(1,1,v_titre,SMLSIZE+INVERS)

		-- champ actif
		v_focused_field = 1 
	end

	-- Validation saisie ou entrée en saisie
	if aEvent == EVT_ENTER_BREAK then 
		
		v_edit = not v_edit 
		
		if v_edit and v_current_fields[v_focused_field].type == "sw_name" 
		then 
			scan_switches(false) 
			field_draw_wait("manipulez l'inter","a affecter") 
		end	

		-- Capture de la position 
		if v_current_fields[v_focused_field].type == "sw_pos" 
		then 
			if v_edit then 
				field_draw_wait("inter en position","puis [ENT]") 
			else
				if v_current_fields[v_focused_field].stop == "fieldprec"
					then i = getValue(aFields[v_current_fields[v_focused_field-1].field])
					else i = getValue(v_current_fields[v_focused_field].stop)
				end
				aFields[v_current_fields[v_focused_field].field] = i
			end
		end	
		
		return
	end

	-- cas particulier détection  de switch
	if v_edit then  
		if v_current_fields[v_focused_field].type == "sw_name" then 
			sw_name = scan_switches(true)
			if sw_name ~= nil then
				aFields[v_current_fields[v_focused_field].field] = sw_name
				v_edit = false
			else 
				field_draw_wait("manipulez l'inter","a affecter") 
				return
			end
		elseif v_current_fields[v_focused_field].type == "sw_pos" then 
			field_draw_wait("inter en position","puis [ENT]") 
			return
		end
	end

	

	v_Move = Button_GetMove(aEvent)
 		
	if v_Move ~= 0 then

		-- déplacement de champ à champ
		if not v_edit then 
			v_focused_field = v_focused_field + v_Move																				-- bouge de 1 vers le haut ou le bas 
			if  v_focused_field == 0 then for key, tab in pairs(v_current_fields) do v_focused_field = v_focused_field +1 end end	-- début atteint, on passe au dernier
			if v_current_fields[v_focused_field] == nil then v_focused_field = 1 end										    	-- fin atteinte, on passe au premier
		
		-- incrémente décrménente valeur
		else
			i =aFields[v_current_fields[v_focused_field].field] + v_Move
			-- surveillance des bornes
			if v_current_fields[v_focused_field].type == "n+"  and i<0 													then i=v_current_fields[v_focused_field].stop 	end
			if v_current_fields[v_focused_field].type == "n+"  and i>v_current_fields[v_focused_field].stop 			then i=0										end
			if v_current_fields[v_focused_field].type == "n-"  and i>0													then i=v_current_fields[v_focused_field].stop	end
			if v_current_fields[v_focused_field].type == "n-"  and i<v_current_fields[v_focused_field].stop 			then i=0										end
			if v_current_fields[v_focused_field].type == "num" and math.abs(i)>v_current_fields[v_focused_field].stop 	then i=(i*-1)									end

			aFields[v_current_fields[v_focused_field].field] = i
		end

	end
	-- Dessin titre des champs
	fields_draw(v_current_fields,aFields)

	
end
