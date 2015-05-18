#!/bin/bash

# TO DO
# Rediriger vers un fichier la difference et le supprimer seulement si le test a succed ?

RCol='\e[0m'
BBla='\e[1;33m';
BRed='\e[1;31m';

SHELL=./42sh
TCSH=tcsh

trap 'echo -en "${BRed}SEGFAULT${RCol}" && rm core.*' SIGSEGV

LS_BEGIN=`ls`

if [ ! -x ./42sh ]; then
  echo "Can't open your shell $SHELL"
  exit
fi

############### Mettez des tests !! ############### 

declare -a tests=(

"cat Makefile" 
"Unexisting"
"ls | grep include"
"ls | grep e | grep a > toto ; cat toto ; rm toto"
"ls > cul | ls < EOF"
"cat toto"
"cat -e Makefile | grep 'CC'"
"ls /root || ls"
"ls;ls"
"ls ; ls"
"|"
""
"&"
"&&"
"||"
";"
";;"
"who"
"cat << EOF\ncoucou\nsalut\nEOF"
"/bin/kill -11 0"

# etc...
)

for i in "${tests[@]}"
do

echo "Test : $i"

#Compare stdout
echo -en "\tSTDOUT : "
diff <( echo "$i" | $SHELL 2>/dev/null )     <( echo "$i" | $TCSH 2>/dev/null )	   > /dev/null \
    && echo -e "${BBla}OK${RCol}" || echo -e "${BRed}KO${RCol}"

#Compare stderr
echo -en "\tSTDERR : "
diff <( echo "$i" | $SHELL 2>&1 1>/dev/null) <( echo "$i" | $TCSH 2>&1 1>/dev/null ) > /dev/null \
    && echo -e "${BBla}OK${RCol}" || echo -e "${BRed}KO${RCol}"

#Compare return value
(echo "$i" | $SHELL 2>&1) >/dev/null
res1=$?
(echo "$i" | $TCSH 2>&1) >/dev/null
res2=$?

echo -en "\tRETURN : "
[ $res1 == $res2 ] && echo -e "${BBla}OK${RCol}" || echo -e "${BRed}KO${RCol}"

done

LS_END=`ls`

#Know if files were created
if [[ $LS_BEGIN != $LS_END ]] ; then
  echo -e "${BRed}Some files were created${RCol}"
fi
