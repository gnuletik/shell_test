#!/bin/bash

RCol='\e[0m'
BBla='\e[1;32m'
BRed='\e[1;31m'

SHELL=./42sh
TCSH=tcsh
MORE_TEST=0
NO_ENV=0

LS_BEGIN=`ls`

while test $# -gt 0
do
    case "$1" in
	--full)
	    MORE_TEST=1
	    ;;
	--no-env)
	    NO_ENV=1
	    ;;
	*) echo "Usage ./test.sh [--full] [--no-env]"
	   exit
	   ;;
    esac
    shift
done

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

trap 'echo -en "${BRed}SEGFAULT ${RCol}" && rm core.*' SIGSEGV

############### Mettez des tests !! ###############

declare -a tests=(

    "|"
    "\"\"\"\\\"\"\"\""
    ""
    ";"
    ";;"
    ">>"
    "<<"
    ">"
    "<"
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
    "echo toto > test ; cat test ; echo toto >> test && cat test && rm test ;"
    "cat /dev/urandom | $SHELL"
    "$SHELL < /dev/urandom"
)

if [ $SHELL = "./42sh" ]; then

    tests+=(

	"&"
	"&&"
	"||"
	"pwd && cd .. && cd - && pwd"
	"ls | grep include && echo ok || echo ko"
	"ls /root || ls"
	"echo echo echo ls | $SHELL | $SHELL | $SHELL "
	"mkdir lol && touch lol/test && ls > ls_out lol ; cat ls_out ; rm -Rf lol ; rm -f ls_out"
	"echo /*/*/"
	"touch respect; rm respect; ls respect || echo le respect a disparu"
    )
fi

if [ $MORE_TEST = 1 ]; then
    tests+=(
	"ls *c*"
	"env env env env env env env -i env ls"
	"test || test && test && test || test ; ; ; ; ; ; ; testdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxungrosbuffertoustest || test && test && test || test ; ; ; ; ; ; ; testdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireuxtestdunsupergrosbufferpoureviterlesgetnextlinefoireux;"
	"setenv TRUC toto ; echo ${TRUC} ; echo ${truc}; setenv TRUC titi ; echo ${TRUC} ; echo ${sdse}"
	"cd ../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../../ ; pwd ; cd -"
	"ls /dev | grep tty | sort -r | rev > toto ; < toto cat | rev | wc -l > titi ; rm titi toto;"
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

if [ $NO_ENV = 1 ]; then

    for i in "${tests[@]}"
    do

	echo "Test [NO ENV] : $i"

	#Compare stdout
	echo -en "\tSTDOUT : "
	diff <( echo "$i" | env -i $SHELL 2>/dev/null )     <( echo "$i" | env -i $TCSH 2>/dev/null )	   > /dev/null \
	    && echo -e "${BBla}OK${RCol}" || echo -e "${BRed}KO${RCol}"

	#Compare stderr
	echo -en "\tSTDERR : "
	diff <( echo "$i" | env -i $SHELL 2>&1 1>/dev/null) <( echo "$i" | env -i $TCSH 2>&1 1>/dev/null ) > /dev/null \
	    && echo -e "${BBla}OK${RCol}" || echo -e "${BRed}KO${RCol}"

	#Compare return value
	(echo "$i" | env -i $SHELL 2>&1) >/dev/null
	res1=$?
	(echo "$i" | env -i $TCSH 2>&1) >/dev/null
	res2=$?

	echo -en "\tRETURN : "
	[ $res1 == $res2 ] && echo -e "${BBla}OK${RCol}" || echo -e "${BRed}KO${RCol}"

    done

fi

LS_END=`ls`

#Know if files were created
if [[ $LS_BEGIN != $LS_END ]] ; then
  echo -e "${BRed}Certains fichiers n'ont pas été supprimé, la raison la plus probable étant que certains tests ont planté :)${RCol}"
fi
