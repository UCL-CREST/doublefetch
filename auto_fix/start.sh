
testdir='bug_files'
outcome='patched_files'

if test -d ${outcome}
then 
	rm -rf ${outcome}/
	mkdir ${outcome}
	echo Remove old outcome files...
else
	mkdir ${outcome}
	echo Make outcome dir...
fi

if ! test -d ${testdir}
then
	mkdir ${testdir}
	echo Make  testdir...
fi

file_dir=$(pwd)/${testdir}
patch_dir=$(pwd)/${outcome}
num=0

echo Start analyzing...

for curfile in $(ls ${file_dir})
do
	num=$[num+1]
	echo [${num}] Patching file: ${curfile}
	spatch --sp-file fix.cocci  ${file_dir}/${curfile}  -o ${patch_dir}/${num}-patched-${curfile}
done

echo ==============================================
echo Finished.
echo ${num} Patched files copied to: ${outcome}\
