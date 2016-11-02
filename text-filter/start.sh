#!/bin/sh

num=0 # total file number
non_num=0 #non .c or .h file number
function scandir() {
    local cur_dir parent_dir workdir logfile infile  inc #must be defined first
    workdir=$1
    
    #echo ${basedir}
    #echo ${filterdir}
    #echo ${filter2dir}
    #echo ${outputdir}
    #echo ${output2dir}
    #echo ${testdir}
    
    cd ${workdir}
    if [ ${workdir} = "/" ]
    then
        cur_dir=""
    else
        cur_dir=$(pwd)
    fi

    for curfile in $(ls ${cur_dir})
    do
        if test -d ${curfile}
        then
            cd ${curfile}
            scandir ${cur_dir}/${curfile} 
            cd ..
        else

            infile=${cur_dir}/${curfile}

            filename=${curfile%.*}
            extension=${curfile##*.} 
            #echo filename is ${filename}
            #echo extension is ${extension}

            curtime=$(date "+%H:%M:%S")
            num=$[num+1]
            echo [${curtime}][Phase 1]No.${num} :${infile}

            if test ${extension} = "c" -o ${extension} = "h"
            then
                touch ${basedir}/"temp2"

                #sed = ${infile} | sed 'N;s/\n/:/' >> ${outputdir}/"temp1"
                sed -n -e '/^[#]/d' -e '/^};.*/d' -e '/^asmlinkage.*/p' -e '/^inline.*/p' -e '/^const.*/p' -e '/^unsigned.*/p' -e '/^void.*/p' -e '/^static.*/p' -e '/^int.*/p' -e '/^[{}]/p' -e 's/^.*__get_user/get_user/p' -e 's/^.*[^_]get_user/get_user/p' -e 's/^.*copy_from_user/copy_from_user/p' -e 's/^.*case/case/p' -e 's/^.*default/default/p' ${infile} >> ${basedir}/"temp2"
                
                #all the output files sorted by numbers
                python ${filterdir} ${basedir}/"temp2" ${outputdir}/${num}-${curfile} ${infile}

                #copy candidate source files to specific location
                if test -e ${outputdir}/${num}-${curfile}
                then
                    cp ${infile} ${sourcedir}/s-${num}-${curfile}
                fi
                    

                rm ${basedir}/"temp2"
            else
                non_num=$[non_num+1]
                echo [${curtime}][Phase 1]No.${num} : non .h or .c file number: ${non_num}
            fi

            

        fi
    done
}

count=0
function check_indentical() { 
    
    for curfile in $(ls ${outputdir})
    do
        if test -f ${outputdir}/${curfile}
        then
            python ${filter2dir} ${outputdir}/${curfile} ${output2dir}/${curfile}
            curtime=$(date "+%H:%M:%S")
            count=$[count+1]
            echo [${curtime}][Phase 2]No.${count} :${outputdir}/${curfile}
        elif test -d ${outputdir}/${curfile}
        then
            echo ${curfile} is dir!

       
        fi
    done

}

if test -d $1  #$0: script name, $1 $2 ...  args
then
    basedir=$(pwd)
    filterdir=$(pwd)/'filter.py'
    filter2dir=$(pwd)/'filter2.py'
    outputdir=$(pwd)/'output'
    output2dir=$(pwd)/'output2'
    testdir=$(pwd)/'test'
    sourcedir=$(pwd)/'source'

    #phase 1
    scandir ${testdir} #$1 base dir of project
    #phase 2
    check_indentical 

elif test -f $1
then
    echo "you input a file but not a directory,pls reinput and try again"
    exit 1
else
    echo "the Directory isn't exist which you input,pls input a new one!!"
    exit 1
fi

#f ls *.c >/dev/null 2>&1;then，