-- ----------------------------------------------------
-- Chronométreur - v 6.6 - 07/07/2017
-- Aurel Firmware - Nore Fpv - Dom Wilk
-- ----------------------------------------------------
-- Moteur de pages destiné à minimiser les Ko en mémoire
-- le pages sont déchargées de la mémoire lorsqu'elles ne
-- sont plus utiles, et quand on s'en va sur un autre scipt
-- ----------------------------------------------------
-- ce qui fait que l'on ne dépasse pas (environ)
-- 	   22ko en charge, en pic inf à 40 ?
--  moins de 7ko sur un autre script (6,4/6,7)
-- ----------------------------------------------------
	-- Radio
i_IsX9D = LCD_W > 200
--i_IsX9D = false

-- Ecrans 
local PG_MAIN 	=1
local PG_RACE 	=2
local PG_CONFIG =3
local PG_TOOLS	=4

local t_pages = {}

local page={}
local g_CurrPage = PG_MAIN
--local memMax = 0

t_Params = {}
p_Tools=nil 


-- ----------------------------------------------------
function clearTable(t) -- Thank You Mr Ishems !
	if type(t)=="table" then
		for i,v in pairs(t) do
			if type(v) == "table" then clearTable(v) end
			t[i] = nil
		end
	end
	collectgarbage()
end

-- ----------------------------------------------------
local function pageStop()
	page=clearTable(page)								-- décharge la page
	gCurrPage = PG_MAIN									-- retour sur la page principal 
end

-- ----------------------------------------------------
local function pageRun(aEvent,aPageIdx)

	if gCurrPage ~= aPageIdx then 						-- C'est une autre page

		if page then pageStop() end						-- Arrêt de la précédente

		page = loadScript(t_pages[aPageIdx].script)()	-- Chargement et récup du pointeur
		if page.init then 								-- Init prévue ?
			page.init() 								-- Init !
			page.init = nil								-- Init effectué, plus utile, on vire, on soulage
		end

		gCurrPage = aPageIdx
		return page
	end

	if page.run then return page.run(aEvent) end		-- ça roule !
	
	return page
end

-- ----------------------------------------------------
local function mainRun(aEvent)
	
	if p_Tools==nil then -- rien n'est encore chargé

		-- les modules
		t_pages = 
		{	[PG_RACE]	={script="/SCRIPTS/CHRONO/race.lua"		},
			[PG_CONFIG]	={script="/SCRIPTS/CHRONO/config.lua"	},
			[PG_TOOLS]	={script="/SCRIPTS/CHRONO/tools.lua"	}
		}
		
		p_Tools = pageRun(aEvent,PG_TOOLS)	-- charges les routines

		page = nil
		gCurrPage = PG_MAIN
	end
		
	-- Mode Config
	if aEvent==EVT_MENU_BREAK or gCurrPage==PG_CONFIG then
		if pageRun(aEvent,PG_CONFIG)==-1 then pageStop() end
		return 0 -- Pas besoin d'exe le reste et puis page config capture [ENT]
	end

	-- Mode Race
	if gCurrPage==PG_RACE or gCurrPage==PG_MAIN then
		if pageRun(aEvent,PG_RACE)==-1 then pageStop() end
	end

	-- Part sur une autre page
	if aEvent==EVT_PAGE_BREAK and t_pages then
		pageStop()	 			-- décharge la page courrante
		page=p_Tools 			-- décharge les tools
		p_Tools  = pageStop() 
		t_Params = clearTable(t_Params)
		t_pages  = clearTable(t_pages)
	end

	--[[
	if collectgarbage("count")*1024>memMax then 
		memMax = collectgarbage("count")*1024 
		print(string.format("memMax : %i",memMax))
		print("-------------------\n")
	end
	--]]
	
	if aEvent~=0 then 
		collectgarbage()
	--	print(string.format("mainRun Out : %i",collectgarbage("count")*1024))
	--	print(string.format("memMax : %i",memMax))
	--	print("-------------------\n")
	end

	--lcd.drawNumber(160, 52,collectgarbage("count"), SMLSIZE) --DBG
	
	return 0

end

return {run=mainRun}