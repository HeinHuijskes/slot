#!/bin/bash

cd "$HOME/slot/"

function="None"
explanation="TUI for slot machine
OPTIONS:

    -h
        Show this explanation

    -d [arg]
     
         initui (mini)
             Initializes the ui and returns it as a string. Use option mini for the smaller ui.
     
         draw [arg]
             Clears the screen and draws the ui provided as an argument to the screen. 
            'initui' can be piped into this directly.
     
         crank (mini)
             Draws the crank animation on the screen. 
             Presumes that a ui is already drawn to the screen, although this is not required.
       
         reversecrank (!mini)
             Same as crank, but in the opposite direction. Not yet functional for small ui"

while getopts "hd:" opt ; do
    case $opt in 
        h) # Display help
            # TODO: Expand help text to show different options
            echo "$explanation";
            exit
            ;;
        d)  # Determine what function to call
            function="$OPTARG"
            ;;
    esac
done

initui () {
    local ui=''
    local fileloc="./slot.txt"
    if [ "$1" = "mini" ] ; then
        fileloc="./minislot.txt"
    fi

    IFS=''
    local index=0
    while read -r line; do
        ui[$index]="$line"
        index=$((index+1))
    done < $fileloc
    IFS=$'\n'; ui="${ui[*]}"
    echo "${ui}"
}

drawer () {
    clear
    readarray -t ui <<< "${1}"
    for string in "${ui[@]}" ; do
        printf "${string}\n"
    done
}

symbolarray() {
    if [ "$1" = "mini" ] ; then
        symbols="7 BAR $ <3 U 0 # @ (?)"
    else
        symbols=""
    fi
    echo "$symbols"
}

minicrank() {    
    local speed=0.01
    #if [ -n $1 ] ; then
    #    speed=$1
    #fi

    scrlen=24
    tput cup 1 $scrlen
    for i in {2..10} ; do
        tput cup $(($i-1)) $scrlen
        if [ $i -le 7 ] ; then
            if [ $i -eq 7 ] ; then
                printf ' - '
            else
                printf '   '
            fi
        else
            printf ' | '
        fi
        tput cup $i $scrlen
        printf '( )'
        
        sleep $speed;
    done
    for i in {3..10} ; do
        tput cup $((13-$i)) $scrlen
        if [ $i -le 7 ] ; then
            if [ $i -eq 7 ] ; then
                printf ' - '
            else
                printf '   '
            fi
        else
            printf ' | '
        fi
        tput cup $((12-$i)) $scrlen
        printf '( )'
        
        sleep $speed;
    done
    return;
}

crank() {
    if [ "$1" = "mini" ] ; then
        minicrank $2
        return;
    fi
    
    local speed=0.02
    #if [ -n $1 ] ; then
    #    speed=$1
    #fi
    
    local crankstart=9
    local scrlen=80
    local head="(  )"
    local shaft=" __ "
    local clear="    "

    for i in {2..19} ; do
        if [ $i -eq 10 ] ; then
            shaft="\\__ "
            head="(__)"
        fi
        if [ $i -eq 11 ] ; then
            shaft=" \\  "
            clear="\\   "
        fi
        if [ $i -eq 12 ] ; then
            shaft="/|\\ "
        fi
        if [ $i -eq 13 ] ; then
            shaft=" || "
        fi

        tput cup $((crankstart+i-1)) $scrlen
        printf "$shaft"
        tput cup $((crankstart+i)) $scrlen
        printf "$head"
        
        if [ $i -le 11 ] ; then
            tput cup $((crankstart+i-2)) $scrlen
            printf "$clear"
        fi
        
        sleep $speed
    done
}

reversecrank() {    
    local speed=0.02
    #if [ -n $1 ] ; then
    #    speed=$1
    #fi

    # TODO: perhaps merge crank and reversecrank using the array method `shafts` uses below
    local shafts=("    " "/   " " /  " "\\|/ " " || ")
    local crankstart=9
    local scrlen=80

    local head="(__)"
    local shaft=${shafts[0]}
    local clear="    "

    for i in {2..19} ; do
        if [ $i -eq 10 ] ; then
            shaft="${shafts[1]}"
            clear="\\__ "
        fi
        if [ $i -eq 11 ] ; then
            head="(  )"
            shaft="${shafts[2]}"
            clear=" __ "
        fi
        if [ $i -eq 12 ] ; then
            shaft="${shafts[3]}"
        fi
        if [ $i -eq 13 ] ; then
            shaft="${shafts[4]}"
        fi

        tput cup $((crankstart+20-i+1)) $scrlen
        printf "$shaft"
        tput cup $((crankstart+20-i)) $scrlen
        printf "$head"
        
        if [ $i -ge 10 ] ; then
            tput cup $((crankstart+20-i-1)) $scrlen
            printf "$clear"
        fi
        
        sleep $speed
    done
}

# Pad a string equally on both sides to a desired length
# Expects $1 [string]: the string to be padded, and $2 [number]: desired string length, where ${#1} <= $2
padstring() {
    # Check preconditions
    # Fail if there are less than 2 arguments set or when the desired string length is smaller than the current length
    if [ -z $2 ] || [ ${#1} -gt ${2} ]; then return 1 ; fi;

    local offset padding back;
    # Calculate needed total padding and offsets
    local padding=$(($2 - ${#1}));
    local offset=$(($padding / 2));
    local back=$(($2-$offset));
    # Add offset to the string and return it
    echo "$(printf "%${2}s" "$(printf "%-${back}s" "$1")")"
}

replacestring () {
    local string="$1"
    local locator="$2"
    local body="$3"
    local string=$(padstring "$string" "${#locator}")
    local body="${body/"$locator"/"$string"}";
    echo "$body"
}

graph () {
    local hist=("$@")
    local scrnln=30
    local height=10

    max=${hist[0]}
    min=${hist[0]}
    for x in ${hist[@]} ; do
        if [ $x -gt $max ] ; then max=$x; fi
        if [ $x -lt $min ] ; then min=$x; fi
    done

    x=$scrnln
    for value in ${hist[@]} ; do
        y=$(($value-$min))
        y=$(($height-$y*$height/$max))
        tput cup $y $x
        printf "___"
        x=$(($x+3))
    done;
}


if [ "$function" = "None" ] ; then
    return 0
fi

functions=("initui" "drawer" "crank" "reversecrank" "replacestring" "graph")
for fun in ${functions[@]}; do
    if [ "$function" = "$fun" ] ; then
        $function "${@:3}"
    fi 
done

