function box()
{
   blue=1
   green=2
   cyan=3
   red=4
   purple=5
   yellow=6
   gray=7
   light_blue=8
   light_green=9
   light_cyan=10
   light_red=11
   light_purple=12
   light_yellow=13
   light_gray=14
   color[blue]=34
   color[green]=32
   color[cyan]=36
   color[red]=31
   color[purple]=35
   color[yellow]=33
   color[gray]=37
   color[light_blue]=34
   color[light_green]=32
   color[light_cyan]=36
   color[light_red]=31
   color[light_purple]=35
   color[light_yellow]=33
   color[light_gray]=30
   local codef=0
   local codet=0
   local str=("$1")
   local cot=("$2")
   local cof=("$3")
   local len=${#str}
   local cul='┌'
   local cur='┐'
   local cbl='└'
   local cbr='┘'
   local ver='│'
   if  [[ $cof == light* ]] ;
   then
      codef=1
   fi
   if  [[ $cot == light* ]] ;
   then
      codet=1
   fi
   printf -v line '%*s' "$((len+2))"
   printf -v line '%s' "${line// /─}"
   echo -en "\033[${codef};${color[${cof}]}m$cul$line$cur\033[m\n"
   echo -en "\033[${codef};${color[${cof}]}m$ver\033[${codet};${color[${cot}]}m $str \033[m\033[${codef};${color[${cof}]}m$ver\n"
   echo -en "\033[${codef};${color[${cof}]}m$cbl$line$cbr\033[m\n"
}
