------------------------------------------------------------------------------------------------------------------------------------------------
CHRONOMETREUR - v 5.0 - 30/06/2017
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Ecrit et imaginé par : Aurel Firmware - Nore Fpv - Dom Wilk
------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------
INSTALLATION : 
------------------------------------------------------------------------------------------------------------------------------------------------
1. Sur la SD card de votre radio :
   a. "timer.lua" à déposer dans "\SCRIPTS\TELEMETRY\"
   b. "config.lua" à déposer dans "\SCRIPTS\CHRONO\"
   c. "Cstart.wav,Cfin.wav,Cbest.wav" à déposer dans "\SOUNDS\fr"
   
2. Script "timer" à lier à un écran de télémesure

3. configurer un inter logique, lequel inter devra être indiqué dans la configuration des inters
  * Fonction : a>x
  * V1       : RSSI
  * V2       : 74db (sera écrasé par le paramètre Seuil + et les ajustements dynamiques) 

4. Aller dans la config du chrono 
	- renseignez l'inter logique du RSSI
	- ajustez les autres paramètres si nécessaire (voyez leur description plus bas dans ce document)


------------------------------------------------------------------------------------------------------------------------------------------------
UTILISATION
------------------------------------------------------------------------------------------------------------------------------------------------
> LANCEMENT 
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Appui long sur "Page" pour appeler les écrans de télémétrie
Appui court sur "Page" pour faire défiler les écrans de télémétrie jusqu'à celui du chrono (si vous n'y êtes pa déjà)



- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
> PARAMETRAGE (L'ensemble des paramètres est décrit plus bas) 
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Depuis l'écran "Chronomètre ..."
Appui court sur "Menu" pour les paramètres propres à la course (Nb de tours, Délai entre 2 validations, Seuil de décollage, Mode de départ) 
Appui court sur "Menu" pour les paramètres propres à votre radio (Inters d'armement, de validation manuelle ou logique (RSSI)  ...)
Appui court sur "Exit" pour revenir à l'écran de chrono



- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
> TEST & REGLAGES 
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
En théorie, la validation du tour par RSSI, c'est beau !
Sur le terrain, ça l'est un peu moins, vous devrez étudier un peu l'aire de jeu avant et si vous pouvez choisir vos emplacements de pilotage et 
de validation ce sera encore mieux ! 

Il va vous falloir régler deux paramètres pour pouvoir en profiter : 
- le seuil RSSI de déclenchement 
- le délai de validation entre deux tours

Le mode test fait sonner la radio tant que la force du signal [RSSI] est au-dessus du seuil réglé.
Aidez vous de ce mode pour ajuster votre seuil (touches [+] ou [-] (X9D) ou la molette (QX7) ).
Si un point intermédiaire du circuit sonne, vous pourrez le "gommer" avec le "délai". Ce paramètre ne permet la validation d'un tour qu'une fois ce délai écoulé, et ce, à chaque tour. 
Plus vous serez régulier et plus le "délai" sera efficace, puisque en mettant le "délai" un peu en dessous de votre meilleur temps, la "fenêtre de validation RSSI" (sens figuré) n'agira qu'un peu avant la fin du tour jusqu'à sa validation.

- Le mode test est engagé par un inter configurabale dans les paramètres (choix de l'inter et position)
- Le délai est paramétrable dans l'écran de configuration "Race"
- Le seuil RSSI est réglable dans les paramètres ET en dynamique par [+] ou [-] (X9D) ou la molette (QX7) dans certeins conditions (mode TEST, Avant course)


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
> AVANT COURSE
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Le seuil RSSI reste réglable par [+] ou [-] (X9D) ou la molette (QX7)


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
> COURSE
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Armez, décollez, faites le circuit
Eventuellement revenez sur le délai de validation (cf DELAI dans les paramètres)
Le seuil RSSI reste réglable par [+] ou [-] (X9D) ou la molette (QX7)


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
> APRES COURSE
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Si vous avez paramétré un nombre de tours supérieur à 4, une fois désarmé, vous pouvez naviguer dans le tabelau des temps avec la molette (QX7) 
ou les touches "+" et "-" (X9D)
Le seuil RSSI n'est plus réglable par [+] ou [-] (X9D) ou la molette (QX7) tant que vous n'aurez pas RAZ le tableau des temps
Utilisez l'inter de Reset pour remettre le chrono et les temps à zéro



------------------------------------------------------------------------------------------------------------------------------------------------
PARAMETRES
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
D'une manière générale, vous vous déplacez sur les différents paramètres avec les touches "+" et "-" de la radio (ou de la molette pour la QX7)
Pour éditer le paramètre appuyez sur la touche [ENT]
Le script s'adapte en fonction de ce qu'il y a renseigner : 
- soit qu'il faille manipuler un inter pour le détecter ou pour lire sa valeur (et dans ce cas il vous le dit)
- soit qu'il faille user des "+" et "-" (ou la molette sur la QX7) pour ajuster vote choix (pas d'indication contrairement au cas précédent)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Les paramètres sont répartis sur 2 écrans, l'écran RACE est présenté en premier car une fois réglés les inters vous ne devriez plus à avoir à y 
revenir qu'occasionellement. 
------------------------------------------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------------------------------------------------------------------------------
PARAMETRES "RACE"
------------------------------------------------------------------------------------------------------------------------------------------------


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
NB tours                                        	[ENT] puis molette (QX7) ou touche +/- (X9D) puis [ENT]
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Il s'agit bien entendu du nombre de tours que vous souhaitez chronométrétiser. Oui je sais ce n'est pas français, mais faut bien meubler un peu,
car qui aurait imaginé qu'il puisse s'agir d'autre chose ?



- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
DELAI (de validation entre deux tours)	            [ENT] puis molette (QX7) ou touche +/- (X9D) puis [ENT]
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
En paramétrant un délai un peu en dessous du meilleur temps dont vous êtes capable, cela permet d'éviter d'avoir un déclenchement RSSI intempestif
à un point intermédiaire du circuit. En effet, comme la force du signal RSSi peut être au seuil à plusieurs endroits, selon votre altitude, 
l'humidité dans l'air, le sens du vent, ou encore la manière dont vous tenez votre radio ... et compte tenu qu'on a pas interêt à canaliser ce 
signal, fallait bien essayer qq chose ! Donc vous n'avez pas le choix, soyez régulier dans vos tours !!!  


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SEUIL RSSI 	            						     [ENT] puis molette (QX7) ou touche +/- (X9D) puis [ENT]
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Valeur au delà de laquelle l'inter logique du RSSI provoquera la validation du tour
Vous pouvez ajuster le seuil dans les écrans de config, mais aussi en Mode TEST ou avant et pendant la course, il n'y a que lorsqu'il y a des temps 
à consulter que le molette ou les touches [+] et [-] ne modifient pas le seuil. 


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
SEUIL GAZ (ou seuil de décollage)                     [ENT] puis levez le manche jusqu'à la position où le décollage est valide puis [ENT]
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Le Chrono a besoin de savoir quand vous décollez, soit pour être déclenché, soit pour attendre le premier passage au point de validation (voir 
les Modes de départ) 
"-500" paraît être une bonne valeur, dès que vous êtes au premier quart de la course du manche, on considère que vous avez décollé.


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
MODES de DEPART	                                    [ENT] puis molette (QX7) ou touche +/- (X9D) puis [ENT]
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Départ lancé ou arrêté, le chrono démarre 
	* arrêté = dès que le manche des gaz est levé 
	* lancé  = dès que vous franchissez une première fois le point de validation, des bips signal l'attente du point de passage


------------------------------------------------------------------------------------------------------------------------------------------------
PARAMETRES "INTERS"
------------------------------------------------------------------------------------------------------------------------------------------------


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ARMEMENT (inter d')                                 [ENT] puis actionnez l'inter d'armement, il est aussitôt pris en compte
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Il s'agit de l'inter avec lequel vous armez le quad. Selon les habitudes des uns et des autres, des radios, il était souhaitable que vous puissiez
le choisir.



- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
OFF (ARMEMENT) 									    [ENT] puis positionnez l'inter en mode désarmé puis [ENT]
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
La plupart du temps cette valeur est "-1024" mais selon la configuration de votre radio, si l'inter est à 3 ou 2 positions ... bref, le mieux est
d'éditer le paramètre de mettre l'inter dans sa position "Off" et de refaire [ENT] pour que le paramètre capture cette valeur 



- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
VALID TOUR (Inter de)                               [ENT] puis actionnez l'inter de validation manuelle du tour, il est aussitôt pris en compte 
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Généralement "SH" sur la X9D et la QX7 car c'est le seul inter à retour.
Si vous êtes assez doué et précis, vous pourrez valider vos temps grâce à lui.
Mais comme on est bpc à n'être pas bon à ce point, on a essayé de faire un truc avec le RSSI  


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
RSSI (Inter logique de détection du)                [ENT] puis molette (QX7) ou touche +/- (X9D) puis [ENT]
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Au point 3 de l'installation, nous vous présentions les paramètres de réglages d'un inter logique sur la force du signal RSSI
vous devez reporter le nom de cet inter logique dans ce paramètre


- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
RESET (Inter de RAZ des temps)                      [ENT] puis actionnez l'inter de RAZ des compteurs, il est aussitôt pris en compte 
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Beaucoup mettront le "SH" pour la remise à zéro avant une nouvelle course, il n'agira que lorsque vous êtes désarmé, donc pas de risque de 
RAZ pendant une course.
Mais, si comme moi, votre "SH" vous sert aussi à déclamer le voltage de votre lipo, alors vous apprécierez de pouvoir mettre le RAZ sur un autre inter. 



- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ON (RESET) position RAZ                             [ENT] puis positionnez l'inter en mode RAZ puis [ENT]
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Pour convenir à chaque cas, définissez ici à quelle valeur de cet inter la RAZ doit être effectuée 



- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
TEST (Inter de mise en route du mode TEST)          [ENT] puis actionnez l'inter de mode TEST, il est aussitôt pris en compte 
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Cet inter vous permet d'enclencher le mode test pour ajuster le seuil de détection du RSSI. Des fois que vous ayez un sbire à envoyer sur le 
terrain pour tester le quad en main ... ça marche aussi bien armé que non armé :P 
Vous pouvez même faire la course en mode Test (woua, ça c'était pas prévu, mais après tout ...)



- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
ON (TEST)  déclenchement du mode TEST               [ENT] puis positionnez l'inter en mode RAZ puis [ENT]
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Une fois choisi l'inter, définissez dans quelle position il doit déclencher le mode test. Bien entendu, le mode TEST s'arrêtera dès que l'inter 
ne sera plus dans cette position. 
On enfonce des portes ouvertes, mais au moins ça à le mérite d'être clair, du moins, je l'espère ;)



------------------------------------------------------------------------------------------------------------------------------------------------
PERSONNALISATION : 
------------------------------------------------------------------------------------------------------------------------------------------------
Certains paramètres ne sont pas dans les écrans de configuration
Vous pouvez toutefois les atteindre et les modifier dans "\SCRIPTS\CHRONO\chrono.cfg"
changez le nom des fichiers figurants sur les lignes commençant par
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
"snd_start" : le fichier son de départ de votre choix
"snd_best"  : le fichier son lorsque vous faites un temps meilleur que les précédents
"snd_fin"   : le fichier son à la fin des tours
- - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Pack Fr pour taranis : https://www.dropbox.com/s/5dvplq1i1fjwak8/Fr_sound_pack_2.1.x_160914-Heisenberg.zip?dl=1

------------------------------------------------------------------------------------------------------------------------------------------------
BUGS & AMELIORATIONS
------------------------------------------------------------------------------------------------------------------------------------------------
- - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Quand on lève un manche, faire afficher la valeur au fur et à mesure
- - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Message "Inter en position" pour le réglage du "Seuil Gaz" 
> "Montez le stick à la valeur de décollage"
------------------------------------------------------------------------------------------------------------------------------------------------
Historique : 
- - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
5.1 : Bug sur BetsLap : ne prenait que les 4 premiers tous
	  Affichage "RESET" en gros sur tout l'écran ... si pas "SH" trop béta de laisser l'inter en position "RESET"	
	  nommenclature des variables pour les fichiers sons revue "snd_xxxxxxx", "sfile" renommé en "snd_start" 
	  Son quand meilleur temps "snd_best"
	  pour éviter de reparamétrer les fichier sons à cahque nouvelle version, possibilité de les modifier dans "chrono.cfg" 
- - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
5.0 : Seuil RSSI : se règle désormais dans les paramètres "RACE"
				   MAIS s'ajuste aussi en dynamique 
				   - en mode TEST avec la molette (QX7) les touches "+" & "-" (X9D) + annonce vocale de la valeur de seuil
				   - avant la course, dans ce cas, ça fait juste bip plus ou moins aigu selon la valeur du seuil
				   - pendant la course, mais aller chercher les boutons vous fera certainement faire un temps minable, voire pas de temps du tout 
	  Affichage "Mode TEST" qaund l'inter est engagé
	  Consultation temps ([+][-] ou molette) : seulement quand 
	  	- désarmé
	  	- pas en mode test
	  	- qu'il y a au moins un temps dans le tableau
	  	le reste du temps, ces commandes sont dédièes au réglage du seuil

	BUG : Si on fait [EXIT] depuis un écran de config qui attend la manipuation d'un inter, alors on revient sur cet écran au retour sur la config
		 > sortir du mode Edit
		 Ok, comment je te l'ai mis kaput le bug !
- - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
4.8 : Paramétrage de la valeur de l'inter de Reset
	  info tours consultés
	  bip quand premier ou dernier tour atteint en consultation
	  mise en forme temps au tour non bouclés (mise en évidence des tours non courus)
	  reprise des infos paramètres (viré les accents)
	  bug affichage sur quitte écran télémétrie en cours de course 
	  bug affichage "Mode départ"
- - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
4.7 : rectif bug bornage "start_mode" ne peut plus prendre une valeur autre que 0 ou 1
- - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
4.6 : rectif bug reconaissance molette QX7 / + et - X9D
	  paramètre de config, position "On" de l'inter de Test	
- - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
4.5 : Naviguer dans le tableau des temps (après désarmement) avec touches + et - (ou molette sur QX7)
- - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
4.0 : Paramétrages persistents (fichier "/SCRIPTS/CHRONO/chrono.cfg" sur SDCard)
	  Ecrans de menu "Config Race" et "Config Inters"
	  Réglage du nombre de tours et défilement du tableau des temps durant la course
	  Délai de validations entre deux tours paramétrable en secondes
	  Cmmentaire sur les paramétrages dans le abse de l'écran
- - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
3.5 : Dessins d'écran adapté au type de radio (QX7/ X9D)
- - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
3.0 : Modes de départ, lancé ou arrêté
- - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
2.5 : Mode test = vérifier où le RSSI déclenche pour pouvoir ajuster le potar en vol
	  Amélioration RSSI (inter logique)
- - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
2.0 : Essais RSSI
	  Reglage de seuil RSSI
	  Plage de détection (abandonné par la suite)
- - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
1.0 : Premier jet, Table des chonos, chronos, délai ...
------------------------------------------------------------------------------------------------------------------------------------------------


VOILA VOUS SAVEZ TOUT MAINTENANT !!!!!!!
