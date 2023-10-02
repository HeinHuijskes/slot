#!/bin/bash

clear

expected="Hello this is a   test   string"
actual=$(bash slotui.sh -d replacestring 'test' '<locate>' 'Hello this is a <locate> string')
bash test.sh "$expected" "$actual"

sleep 2

var=$(bash slotui.sh -d initui); 
bash slotui.sh -d drawer "${var[@]}"; 
bash slotui.sh -d crank; 
bash slotui.sh -d reversecrank

sleep 1

clear

bash slotui.sh -d initui mini;
bash slotui.sh -d crank mini;

sleep 1

clear

hist=(4 3 2 3 4 3 4 8 7 6 5 9 13 12 16 15 14 13 12 11 10)
bash slotui.sh -d graph "${hist[@]}"
