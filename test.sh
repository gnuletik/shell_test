#!/bin/bash

RCol='\e[0m'
BBla='\e[1;32m';
BRed='\e[1;31m';

SHELL=./42sh
TCSH=tcsh

trap 'echo -en "${BRed}SEGFAULT ${RCol}" && rm core.*' SIGSEGV

LS_BEGIN=`ls`

if [ ! -x ./42sh ]; then
    if [ ! -x ./mysh ]; then
	echo "Can't open your mysh/42sh"
	exit
    else
	echo "Exécution en mode minishell2"
	SHELL=./mysh
    fi
else
    echo "Exécution en mode 42sh"
fi

############### Mettez des tests !! ###############

if [ $SHELL = "./42sh" ]; then

    declare -a tests=(

	"ls;ls"
	"ls ; ls"
	"|"
	""
	"&"
	"&&"
	"||"
	";"
	";;"
	"cat Makefile"
	"CEBINAIRENEXISTEPAS"
	"pwd && cd .. && cd - && pwd"
	"ls | grep include"
	"ls|grep include"
	"ls | grep include && echo ok || echo ko"
	"ls | grep e | grep a > toto ; cat toto ; rm toto"
	"ls > testfile | ls < EOF"
	"ls | > testfile"
	"cat toto"
	"cat -e Makefile | grep 'CC'"
	"ls /root || ls"
	"cat << EOF | less"
	"who"
	"cat << EOF\ncoucou\nsalut\nEOF"
	"echo echo echo ls | $SHELL | $SHELL | $SHELL "
	"touch toto ; touch test ; cat < toto | wc -l < test ; rm toto ; rm test"
	"mkdir lol && touch lol/test && ls > ls_out lol ; cat ls_out ; rm -Rf lol ; rm -f ls_out"
	"echo /*/*/"
	"touch respect; rm respect; ls respect || echo le respect a disparu"
	"ls | > file_test echo test1 ; cat file_test ; rm -f file_test"
	"ls ;; ls"
	"ls ; | ls"
	"cat /dev/urandom | ./42sh"
	"./42sh < /dev/urandom"
    )
else
    declare -a tests=(

	"|"
	""
	";"
	";;"
	"ls;ls"
	"ls ; ls"
	"cd; pwd;"
	"cd ..; pwd;"
	"cd ././././././; pwd;"
	"cd -; pwd;"
	"cat Makefile"
	"CEBINAIRENEXISTEPAS"
	"ls | grep include"
	"ls|grep include"
	"ls | grep e | grep a > toto ; cat toto ; rm toto ; cat toto;"
	"ls > testfile | ls < EOF"
	"ls | > testfile"
	"cat toto"
	"cat -e Makefile | grep 'CC'"
	"cat << EOF | less"
	"who"
	"cat << EOF\ncoucou\nsalut\nEOF"
	"touch toto ; touch test ; cat < toto | wc -l < test ; rm toto ; rm test"
	"ls ;; ls"
	"ls ; | ls"
	"cat /dev/urandom | ./mysh"
	"./mysh < /dev/urandom"
    )
fi

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
  echo -e "${BRed}Certains fichiers n'ont pas été supprimé, la raison la plus probable étant que certains tests ont planté :)${RCol}"
fi
