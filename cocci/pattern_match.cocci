@ rule1  exists @
identifier e1,e2,sizefunc;
expression addr,exp1,exp2,src,ptr,size1,size2,offset,arg;
position p0,p1,p2,p3;
type T0,T1,T2;
@@

(
	fake; //fake statement for parsing
|   //--------------------------------------- case 1: ptr = src at beginning, ptr first
	ptr = (T0)src@p0 // potential assignment case
	...
(
	get_user(exp1, (T1)ptr)@p1
|
	get_user(exp1, ptr)@p1
|
	__get_user(exp1, (T1)ptr)@p1
|
	__get_user(exp1, ptr)@p1
|
	copy_from_user(exp1, (T1)ptr,size1)@p1
|
	copy_from_user(exp1, ptr,size1)@p1
|
	__copy_from_user(exp1, (T1)ptr,size1)@p1
|
	__copy_from_user(exp1, ptr,size1)@p1
)
	...	when any
		when != src += offset
		when != src = src + offset
		when != src++
		when != src -=offset
		when != src = src - offset
		when != src--
		when != src = addr
(
	get_user(exp2,(T2)src)@p2
|
	__get_user(exp2,(T2)src)@p2
|
	__copy_from_user(exp2,(T2)src,size2)@p2
|
	copy_from_user(exp2,(T2)src,size2)@p2
)	
	... when any

|	//----------------------------------- case 2: ptr = src at beginning, src first

	ptr = (T0)src@p0 
	...
(
	get_user(exp1, (T1)src)@p1
|
	get_user(exp1, src)@p1
|
	__get_user(exp1, (T1)src)@p1
|
	__get_user(exp1, src)@p1
|
	copy_from_user(exp1, (T1)src,size1)@p1
|
	copy_from_user(exp1, src,size1)@p1
|
	__copy_from_user(exp1, (T1)src,size1)@p1
|
	__copy_from_user(exp1, src,size1)@p1
)
	...	when any
		when != ptr += offset
		when != ptr = ptr + offset
		when != ptr++
		when != ptr -=offset
		when != ptr = ptr - offset
		when != ptr--
		when != ptr = addr
(	
	get_user(exp2,(T2)ptr)@p2
|
	__get_user(exp2,(T2)ptr)@p2
|
	__copy_from_user(exp2,(T2)ptr,size2)@p2
|
	copy_from_user(exp2,(T2)ptr,size2)@p2
)	
	... when any
|	//----------------------------------- case 3: ptr = src at middle

(
	get_user(exp1, (T1)src)@p1
|
	get_user(exp1, src)@p1
|
	__get_user(exp1, (T1)src)@p1
|
	__get_user(exp1, src)@p1
|
	copy_from_user(exp1, (T1)src,size1)@p1
|
	copy_from_user(exp1, src,size1)@p1
|
	__copy_from_user(exp1, (T1)src,size1)@p1
|
	__copy_from_user(exp1, src,size1)@p1
)
	...	when any
		when != src += offset
		when != src = src + offset
		when != src++
		when != src -=offset
		when != src = src - offset
		when != src--
		when != src = addr
	ptr = (T0)src@p0
	...	when any
		when != ptr += offset
		when != ptr = ptr + offset
		when != ptr++
		when != ptr -=offset
		when != ptr = ptr - offset
		when != ptr--
		when != ptr = addr
(	
	get_user(exp2,(T2)ptr)@p2
|
	__get_user(exp2,(T2)ptr)@p2
|
	__copy_from_user(exp2,(T2)ptr,size2)@p2
|
	copy_from_user(exp2,(T2)ptr,size2)@p2
)	
	... when any
|	//----------------------------------- case 4: normal case without src assignment
(
	get_user(exp1, (T1)src)@p1
|
	get_user(exp1, src)@p1	
|
	__get_user(exp1, (T1)src)@p1
|	
	__get_user(exp1, src)@p1
|
	copy_from_user(exp1, (T1)src, size1)@p1
|
	copy_from_user(exp1, src, size1)@p1
|
	__copy_from_user(exp1, (T1)src, size1)@p1
|
	__copy_from_user(exp1, src, size1)@p1

)
	...	when any
		when != src += offset	
		when != src = src + offset
		when != src++
		when != src -=offset
		when != src = src - offset
		when != src--
		when != src = addr
		


(	//binder.c
	get_user(exp2,(T1)src)@p2
|
	get_user(exp2,(T2)src)@p2

|
	__get_user(exp2,(T2)src)@p2
|
	__get_user(exp2,(T1)src)@p2
|
	__copy_from_user(exp2,(T2)src,size2)@p2
|
	copy_from_user(exp2,(T2)src,size2)@p2
)	
	... when any
|	//----------------------------------- case 5: first element, then ptr
(
	get_user(exp1, &src->e1)@p1
|
	get_user(exp1, (T1)src->e1)@p1
|
	__get_user(exp1, &src->e1)@p1
|
	__get_user(exp1, (T1)src->e1)@p1
|
	copy_from_user(exp1, &src->e1,size1)@p1
|
	copy_from_user(exp1, (T1)src->e1,size1)@p1
|
	__copy_from_user(exp1, &src->e1,size1)@p1
|
	__copy_from_user(exp1, (T1)src->e1,size1)@p1
)
	...	when any
		when != src += offset
		when != src = src + offset
		when != src++
		when != src -=offset
		when != src = src - offset
		when != src--
		when != src = addr
(	
	get_user(exp2,(T2)src)@p2
|
	__get_user(exp2,(T2)src)@p2
|
	__copy_from_user(exp2,(T2)src,size2)@p2
|
	copy_from_user(exp2,(T2)src,size2)@p2
)	
	... when any
)  

@initialize:python@
count << virtual.count;
@@

@script:python@
//p10 << rule1.p0;
p11 << rule1.p1;
p12 << rule1.p2;
s << rule1.src;
@@


//coccilib.report.print_report(p10[0],"Src Assignment")
coccilib.report.print_report(p11[0],"First fetch")
coccilib.report.print_report(p12[0],"Second fetch")

filename = p11[0].file
first = p11[0].line
second = p12[0].line
src_str = str(s)

print "src:",src_str

def print_log(filename,first,second,count):
	logfile = open('result.txt','a')

	print "No. ", count, " file: ", filename
	print "--first fetch: line ",first
	print "--second fetch: line ",second
	print "------------------------------------\n"

	logfile.write("No." + count + " File: \n" + str(filename) + "\n")
	logfile.write("--first fetch: line " + str(first) + "\n")
	logfile.write("--second fetch: line " + str(second) + "\n")
	logfile.write("-------------------------------\n")
	
	logfile.close()


# handle loop case, first and second fetch are not supposed to be in the same line.
if first != second: 
	if src_str.find("+") == -1 and src_str.find("[") == -1 :
		if src_str.find("-") == -1:
			count = str(int(count) + 1)
			print_log(filename, first, second, count)
		else:
			if src_str.find("->") != -1 :
				count = str(int(count) + 1)
				print_log(filename, first, second, count)

