//define global variable
@initialize:python@
count << virtual.count;
@@
#-----------------------------Post Matching Process------------------------------
def print_and_log(filename,first,second,count):
	

	print "No. ", count, " file: ", filename
	print "--first fetch: line ",first
	print "--second fetch: line ",second
	print "------------------------------------\n"

	logfile = open('result.txt','a')
	logfile.write("No." + count + " File: \n" + str(filename) + "\n")
	logfile.write("--first fetch: line " + str(first) + "\n")
	logfile.write("--second fetch: line " + str(second) + "\n")
	logfile.write("-------------------------------\n")
	
	logfile.close()

def post_match_process(p1,p2,src,ptr,count):

	filename = p1[0].file
	first = p1[0].line
	second = p2[0].line

	src_str = str(src)
	ptr_str = str(ptr)
	#print "src1:", src_str
	#print "src2:", ptr_str
	#print "first:", first
	#print "second:", second

	# remove loop case, first and second fetch are not supposed to be in the same line.
	if first == second: 
		return
	# remove reverse loop case, where first fetch behand second fetch but in last loop .
	if int(first) > int(second):
		return
	# remove case of get_user(a, src++) or get_user(a, src + 4)
	if src_str.find("+") != -1 or ptr_str.find("+") != -1:
		return
	# remove case of get_user(a, src[i]) 
	if src_str.find("[") != -1 or ptr_str.find("[") != -1:
		return 
	# remove case of get_user(a, src--) or get_user(a, src - 4)
	if src_str.find("-") != -1 and src_str.find("->") == -1:
		return
	if ptr_str.find("-") != -1 and ptr_str.find("->") == -1:
		return
	# remove false matching of src ===> (int*)src , but leave function call like u64_to_uptr(ctl_sccb.sccb)
	if src_str.find("(") == 0 or ptr_str.find("(") == 0:
		return

	if count:
		count = str(int(count) + 1)
	else:
		count = "1"

	print_and_log(filename, first, second, count)

	return count


//---------------------Pattern Matching Rules-----------------------------------
//----------------------------------- case 1: normal case without src assignment
@ rule1 disable drop_cast exists @
expression addr,exp1,exp2,src,size1,size2,offset;
position p1,p2;
identifier func;
type T1,T2;
@@
	func(...){
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
	copyin_nofault((T1)src, exp1, size1)@p1
|
	copyin_nofault(src, exp1, size1)@p1
|
	copyin((T1)src, exp1, size1)@p1
|
	copyin(src, exp1, size1)@p1

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
	get_user(exp2, (T2)src)@p2
|
	get_user(exp2, src)@p2
|
	__get_user(exp2,(T2)src)@p2
|
	__get_user(exp2, src)@p2
|
	copyin((T2)src, exp2,size2)@p2
|
	copyin(src, exp2, size2)@p2
|
	copyin_nofault((T2)src, exp2, size2)@p2
|
	copyin_nofault(src, exp2, size2)@p2
)	
	...
	}

@script:python@
p11 << rule1.p1;
p12 << rule1.p2;
s1 << rule1.src;
@@

print "src1:", str(s1)
if p11 and p12:
	coccilib.report.print_report(p11[0],"rule1 First fetch")
	coccilib.report.print_report(p12[0],"rule1 Second fetch")
	
	ret = post_match_process(p11, p12, s1, s1, count)
	if ret: 
		count = ret



//--------------------------------------- case 2: ptr = src at beginning, ptr first
@ rule2 disable drop_cast exists @
identifier func;
expression addr,exp1,exp2,src,ptr,size1,size2,offset;
position p0,p1,p2;
type T0,T1,T2;
@@


	func(...){
	...	
(
	ptr = (T0)src@p0 // potential assignment case
|
	ptr = src@p0
)
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
	copyin_nofault((T1)ptr, exp1, size1)@p1
|
	copyin_nofault(ptr, exp1, size1)@p1
|
	copyin((T1)ptr, exp1, size1)@p1
|
	copyin(ptr, exp1, size1)@p1
)
	...	
	when != src += offset
	when != src = src + offset
	when != src++
	when != src -=offset
	when != src = src - offset
	when != src--
	when != src = addr
(
	get_user(exp2, (T2)src)@p2
|
	get_user(exp2, src)@p2
|
	__get_user(exp2,(T2)src)@p2
|
	__get_user(exp2, src)@p2
|
	copyin((T2)src, exp2, size2)@p2
|
	copyin(src, exp2, size2)@p2
|
	copyin_nofault((T2)src, exp2, size2)@p2
|
	copyin_nofault(src, exp2, size2)@p2
)
	... 
	}

@script:python@
p21 << rule2.p1;
p22 << rule2.p2;
p2 << rule2.ptr;
s2 << rule2.src;
@@
print "src2:", str(s2)
print "ptr2:", str(p2)
if p21 and p22:
	coccilib.report.print_report(p21[0],"rule2 First fetch")
	coccilib.report.print_report(p22[0],"rule2 Second fetch")
	ret = post_match_process(p21, p22, s2, p2, count)
	if ret: 
		count = ret

//--------------------------------------- case 3: ptr = src at beginning, src first
@ rule3 disable drop_cast exists @
identifier func;
expression addr,exp1,exp2,src,ptr,size1,size2,offset;
position p0,p1,p2;
type T0,T1,T2;
@@


	func(...){
	...	
(
	ptr = (T0)src@p0 // potential assignment case
|
	ptr = src@p0
)
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
	copyin_nofault((T1)src, exp1, size1)@p1
|
	copyin_nofault(src, exp1, size1)@p1
|
	copyin((T1)src, exp1, size1)@p1
|
	copyin(src, exp1, size1)@p1
)
	...	
	when != ptr += offset
	when != ptr = ptr + offset
	when != ptr++
	when != ptr -=offset
	when != ptr = ptr - offset
	when != ptr--
	when != ptr = addr
(
	get_user(exp2, (T2)ptr)@p2
|
	get_user(exp2, ptr)@p2
|
	__get_user(exp2,(T2)ptr)@p2
|
	__get_user(exp2, ptr)@p2
|
	copyin((T2)ptr, exp2, size2)@p2
|
	copyin( ptr, exp2, size2)@p2
|
	copyin_nofault((T2)ptr, exp2, size2)@p2
|
	copyin_nofault(ptr, exp2, size2)@p2
)
	... 
	}

@script:python@
p31 << rule3.p1;
p32 << rule3.p2;
p3 << rule3.ptr;
s3 << rule3.src;
@@
print "src3:", str(s3)
print "ptr3:", str(p3)
if p31 and p32:
	coccilib.report.print_report(p31[0],"rule3 First fetch")
	coccilib.report.print_report(p32[0],"rule3 Second fetch")
	ret = post_match_process(p31, p32, s3, p3, count)
	if ret: 
		count = ret

//----------------------------------- case 4: ptr = src at middle

@ rule4 disable drop_cast exists @
identifier func;
expression addr,exp1,exp2,src,ptr,size1,size2,offset;
position p0,p1,p2;
type T0,T1,T2;
@@


	func(...){
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
	copyin_nofault((T1)src, exp1, size1)@p1
|
	copyin_nofault(src, exp1, size1)@p1
|
	copyin((T1)src, exp1, size1)@p1
|
	copyin(src, exp1, size1)@p1
)
	...	
	when != src += offset
	when != src = src + offset
	when != src++
	when != src -=offset
	when != src = src - offset
	when != src--
	when != src = addr

(
	ptr = (T0)src@p0 // potential assignment case
|
	ptr = src@p0
)
	... 
	when != ptr += offset
	when != ptr = ptr + offset
	when != ptr++
	when != ptr -=offset
	when != ptr = ptr - offset
	when != ptr--
	when != ptr = addr

(
	get_user(exp2, (T2)ptr)@p2
|
	get_user(exp2, ptr)@p2
|
	__get_user(exp2,(T2)ptr)@p2
|
	__get_user(exp2, ptr)@p2
|
	copyin((T2)ptr, exp2,size2)@p2
|
	copyin(ptr, exp2, size2)@p2
|
	copyin_nofault((T2)ptr, exp2, size2)@p2
|
	copyin_nofault(ptr, exp2, size2)@p2
)
	... 
	}

@script:python@
p41 << rule4.p1;
p42 << rule4.p2;
p4 << rule4.ptr;
s4 << rule4.src;
@@
print "src4:", str(s4)
print "ptr4:", str(p4)
if p41 and p42:
	coccilib.report.print_report(p41[0],"rule4 First fetch")
	coccilib.report.print_report(p42[0],"rule4 Second fetch")
	ret = post_match_process(p41, p42, s4, p4, count)
	if ret: 
		count = ret

//----------------------------------- case 5: first element, then ptr, copy from structure
@ rule5 disable drop_cast exists @
identifier func, e1;
expression addr,exp1,exp2,src,size1,size2,offset;
position p1,p2;
type T1,T2;
@@


	func(...){
	...	
(
	get_user(exp1, (T1)src->e1)@p1
|
	get_user(exp1, src->e1)@p1
|
	get_user(exp1, &(src->e1))@p1
|
	__get_user(exp1, (T1)src->e1)@p1
|
	__get_user(exp1, src->e1)@p1
|
	__get_user(exp1, &(src->e1))@p1
|
	copyin_nofault((T1)src->e1, exp1, size1)@p1
|
	copyin_nofault(src->e1, exp1, size1)@p1
|
	copyin_nofault(&(src->e1), exp1, size1)@p1
|
	copyin((T1)src->e1, exp1, size1)@p1
|
	copyin(src->e1, exp1, size1)@p1
|
	copyin(&(src->e1), exp1, size1)@p1
)
	...	
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
	get_user(exp2,src)@p2
|
	__get_user(exp2,(T2)src)@p2
|
	__get_user(exp2,src)@p2
|
	copyin((T2)src, exp2, size2)@p2
|
	copyin(src, exp2, size2)@p2
|
	copyin_nofault((T2)src, exp2, size2)@p2
|
	copyin_nofault(src, exp2, size2)@p2
)
	... 
	}

@script:python@
p51 << rule5.p1;
p52 << rule5.p2;
s5 << rule5.src;
e5 << rule5.e1;
@@
print "src5:", str(s5)
print "e5:", str(e5)
if p51 and p52:
	coccilib.report.print_report(p51[0],"rule5 First fetch")
	coccilib.report.print_report(p52[0],"rule5 Second fetch")
	ret = post_match_process(p51, p52, s5, e5, count)
	if ret: 
		count = ret


//----------------------------------- case 6: first element, then ptr, copy from pointer
@ rule6 disable drop_cast exists @
identifier func, e1;
expression addr,exp1,exp2,src,size1,size2,offset;
position p1,p2;
type T1,T2;
@@
	func(...){
	...	
(
	get_user(exp1, (T1)src.e1)@p1
|
	get_user(exp1, src.e1)@p1
|
	get_user(exp1, &(src.e1))@p1
|
	__get_user(exp1, (T1)src.e1)@p1
|
	__get_user(exp1, src.e1)@p1
|
	__get_user(exp1, &(src.e1))@p1
|
	copyin_nofault((T1)src.e1, exp1, size1)@p1
|
	copyin_nofault(src.e1, exp1, size1)@p1
|
	copyin_nofault(&(src.e1), exp1, size1)@p1
|
	copyin((T1)src.e1, exp1, size1)@p1
|
	copyin(src.e1, exp1, size1)@p1
|
	copyin(&(src.e1), exp1, size1)@p1
)
	...	
	when != &src += offset
	when != &src = &src + offset
	when != &src++
	when != &src -=offset
	when != &src = &src - offset
	when != &src--
	when != &src = &addr
(
	get_user(exp2,(T2)&src)@p2
|
	get_user(exp2,&src)@p2
|
	__get_user(exp2,(T2)&src)@p2
|
	__get_user(exp2,&src)@p2
|
	copyin((T2)&src, exp2, size2)@p2
|
	copyin(&src, exp2, size2)@p2
|
	copyin_nofault((T2)&src, exp2, size2)@p2
|
	copyin_nofault(&src, exp2, size2)@p2
)
	... 
	}

@script:python@
p61 << rule6.p1;
p62 << rule6.p2;
s6 << rule6.src;
e6 << rule6.e1;
@@
print "src6:", str(s6)
print "e6:", str(e6)
if p61 and p62:
	coccilib.report.print_report(p61[0],"rule6 First fetch")
	coccilib.report.print_report(p62[0],"rule6 Second fetch")
	ret = post_match_process(p61, p62, s6, e6, count)
	if ret: 
		count = ret












