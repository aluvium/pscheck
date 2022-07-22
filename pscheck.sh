#!/bin/bash

##################### VARS
## Predefine -c count time, -t time deley, -u current user
C=9999999999
T=1
U=any

##################### Functions
## Main function
f_main() {
    echo "Pinging '$EXE_NAME' for '$U' user"
    while [ $C -gt 0  ]
    do
        C=$(( $C - 1 ))
        ps_check
        sleep $T
    done  	
}

# Check if usr exist
usr_check() {
U_VA="$(cat /etc/passwd | grep ^$U > /dev/null || echo false)"
if [ "$U_VA" = false ] ; then  
    echo "User doesn't exist. Please provide valid user."
    exit 1
fi
}

## Pgrep function, i assume we want all live processes but without childs
ps_check() {
    if [ $U == any ] ; then
        NR=$(pgrep -x $EXE_NAME --count)
        echo "$EXE_NAME: There is $NR live process"
else
        NR=$(pgrep --uid $U -x $EXE_NAME --count)
        #NR=$(ps -eF | awk '{print $11}'| grep $EXE_NAME | wc -l) <-- this would be with childs
        echo "$EXE_NAME: There is $NR live process"
    fi
}

## Taking last cmd as a exec
name() {
    EXE_NAME=$(echo "$*" | cut -f $# -d ' ')
}

##################### START 
## Check if user add argument after cmd && banner
if [ $# -eq 0 ] ; then
    echo ""	
    echo "*** This is pscheck *** ****************"
    echo "For ping you need to provide name of executable process"
    echo "Syntax : pscheck [-c <count>] [-t <time>] [-u <username>] exec-name"  
    exit 1
fi

##################### Cases
## Defining flags if exist
i=0
for c in $@
do
    i=$(( i+1 ))
    if [ $c == -c ] ; then 
        let i=$i+1	
    	C=$(echo $@ | cut -d ' ' -f $i)
    fi
done
i=0

for t in $@
do 
    i=$(( i+1 ))
    if [ $t == -t ] ; then
	let i=$i+1
	T=$(echo $@ | cut -d ' ' -f $i)
    fi
done
i=0

for u in $@
do
    i=$(( i+1 ))
    if [ $u == -u ] ; then
        let i=$i+1
        U=$(echo $@ | cut -d ' ' -f $i)		
        usr_check 
    fi
done 
	
name $@
f_main
