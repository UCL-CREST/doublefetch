resultfile='result.txt'
testdir='testdir'
outcome='outcome'

if test -d ${outcome}
then 
	rm -rf ${outcome}/
	mkdir ${outcome}
	echo Remove old outcome files...
else
	mkdir ${outcome}
	echo Make outcome dir...
fi

if test -d ${testdir}
then 
	pass
else
	mkdir ${testdir}
	echo Make  testdir...
fi

if test -f ${resultfile}
then 
	rm ${resultfile}
	touch ${resultfile}
	echo Remove old results...
else
	touch ${resultfile}
	echo Make results log file...
fi

echo Start analyzing...
spatch -cocci_file pattern_match_linux.cocci -D count=0 -dir ${testdir}
#--disable-worth-trying-opt
echo Finished analyzing.
python copy_files.py

echo Result log: ${resultfile}.
echo Source files copied to: ${outcome}\
