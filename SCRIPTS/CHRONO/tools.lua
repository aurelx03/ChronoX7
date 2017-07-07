local tPage={}

local f_config = '/SCRIPTS/CHRONO/chrono.cfg'

-- Dessin du logo
local i_img  = nil
local i_line = nil
local i_x, i_y


tPage.config_read = function(aFields,aFile)

	local f = io.open(aFile, 'a')
	if f ~= nil then io.close(f) end

	f = io.open(aFile, 'r') 	
	if f == nil then return false end
	
	local v_params = io.read(f, 512)
	io.close(f)
	
	if v_params == '' then return false end

	local v_key = ""
	local v_val = ""
	local v_pair

	for v_pair in string.gmatch(v_params, '([^\n]+)') do
		v_key = string.sub(v_pair,1,string.find(v_pair, ":")-1)
		v_val = string.sub(v_pair,string.find(v_pair, ":")+1)
		aFields[v_key] = v_val
	end
	return true
end


tPage.config_write = function(aFields,aFile)

	local f = io.open(aFile~="" and aFile or f_config , 'w')
	local k, v

	for k, v in pairs(aFields) do
		io.write(f, string.format("%s:%s\n", k, v) )
	end
	io.close(f)
end


tPage.Button_GetMove = function(aEvent)
	if ((aEvent == EVT_PLUS_BREAK  or aEvent == EVT_PLUS_REPT)  and i_IsX9D) or (aEvent == EVT_ROT_RIGHT  and not i_IsX9D)	then return  1 	end
	if ((aEvent == EVT_MINUS_BREAK or aEvent == EVT_MINUS_REPT) and i_IsX9D) or (aEvent == EVT_ROT_LEFT   and not i_IsX9D)	then return -1	end
	return 0
end

tPage.Params_Load = function()

	t_Params = {
	["delay"]			= 15 ;
	["seuil"]			= 80 ;
	["sw_Arm"]			="sb"; ["sw_Arm_Off"]=-1024; 
	["sw_Lap"]			="sh";
	["sw_Reset"]		="sh"; ["sw_Reset_On"]=1024; 
	["sw_Test"]			="sc"; ["sw_Test_On"]=0; 
	["sw_Lap_ls_num"]	= 2;	
	["start_mode"] 		= 0;
	["start_top"] 		= 0;
	["start_throttle"] 	= -500;
	["nb_tours"] 		= 4;
	["snd_topDepart"] 	= "/SOUNDS/fr/CtopCD.wav";
	["snd_start"] 		= "/SOUNDS/fr/Cstart.wav";
	["snd_best"] 		= "/SOUNDS/fr/Cbest.wav";
	["snd_fin"] 		= "/SOUNDS/fr/Cfin.wav";
	}

	tPage.config_read(t_Params,f_config)

end

-- --------------------------------------------------------------------------------------------
tPage.drawFile010 = function (aFile,aX,aY)

	local f = io.open(aFile, 'a')
	if f ~= nil then io.close(f) end

	f = io.open(aFile, 'r')
	if f == nil then return "" end
	
	local v_img = io.read(f, 300)
	io.close(f)

	i_img = {}
	local v_line
	for v_line in string.gmatch(v_img, '([^\n]+)') do
		i_img[#i_img + 1] = v_line 
	end

	i_x = aX -1
	i_y = aY -1
	
	return tPage.drawImg
end

-- --------------------------------------------------------------------------------------------
tPage.drawImg = function ()
-- on dessine le fichier non pas en une seule fois mais à une ligne à chaque itération du "run"

	-- à chaque passage on dessine une ligne, mais en commençant par la fin, on par du bas et on monte
	for i=1, #i_img[#i_img] do
		if string.byte(i_img[#i_img],i)==49 then 	-- si le caractère est "1"
			lcd.drawPoint((i_x)+i,i_y+#i_img) 		-- allume le pixel
		end
	end

	i_img[#i_img] = nil 							-- libère la denière ligne

	-- dessin terminé
	if #i_img == 0 then
		i_img = nil									-- prêt pour charge le prochain fichier
		return 0									-- le dessin est terminé
	end

	return 1 										-- le dessin n'est pas terminé
end


return tPage