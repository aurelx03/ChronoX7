# ChronoX7
Chrono 4 tours avec affichage meilleur tour


Script test.lua à deplacer dans SCRIPTS/TELEMETRY/


1 --- 
	PAGE 2
Timer1 (Inter Armement actif) 00:00
Name Race
Persist OFF
Minute
Countdown Silent

Timer2 SH(haut) 00:00
Name Loop
Persist OFF
Minute
Countdown Silent

2 ---
	PAGE 9
L01 AND SA-(Armement neutre) ---  SH(bas)

3 ---
	PAGE 10
L01 Reset Tmr1 (coché)
SH(bas) Reset Tmr2 (coché)

4 ---
	PAGE 13
Screen1 Script test

l'armement du quad lance le chrono race, si le chrono a ete lancé trop tot, possible de le reset en appuyant sur le switch poussoir SH + armement neutre. Drone armé et en vol.... (protection spam <10s) valider le tour avec le poussoir SH
de même pour les 3 autres.
4 temps validés, le meilleur temps s'affiche en surbrillance

pour reset le tout switch armement neutre + poussoir SH

