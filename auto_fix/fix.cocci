// Size checking scenario automatic fix
// Be careful that msg is allocated dynamically, 
// therefore need to be cleaned up before return.
// Also pay attention that when two fetches use the same dst pointer,
// we copy the content out from the first fetch, then compare with the second fetch.
@rule1@
expression head,msg,dst,src,size1,size2,ret,ERROR;
position p1,p2;
type T;
identifier func,cleanup;
@@
+	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
+ #include <linux/string.h>
+	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	func(...){
	...
(
	
	if (copy_from_user((T)dst, src, size1)){@p1 //Has explicit type conversion
		... 
	}

+	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
+	char* hd;
+	unsigned int len = size1;
+	hd = kmalloc(len, GFP_KERNEL);
+	if(hd)	
+		memcpy(hd, dst, len);
+	else{
+		ret = ERROR;	
+		goto cleanup;
+	}
+	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	...
	if (copy_from_user(dst, src, size2)){@p2
		...
		ret = ERROR;
		...	
		goto cleanup;
	}

+	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
+	if(memcmp(hd, dst, len) != 0){
+		kfree(hd);
+		ret = ERROR;	
+		goto cleanup;
+	}
+	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

|

if (copy_from_user(dst, src, size1)){@p1 
		... 
	}

+	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
+	char* hd;
+	unsigned int len = size1;
+	hd = kmalloc(len, GFP_KERNEL);
+	if(hd)	
+		memcpy(hd, dst, len);
+	else{
+		ret = ERROR;	
+		goto cleanup;
+	}
+	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	...
	if (copy_from_user(dst, src, size2)){@p2
		...
		ret = ERROR;
		...	
		goto cleanup;
	}

+	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
+	if(memcmp(hd, dst, len) != 0){
+		kfree(hd);
+		ret = ERROR;	
+		goto cleanup;
+	}
+	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

|

	if (copy_from_user(head, src, size1)){@p1 
		... 
	}
	...
	if (copy_from_user(msg, src, size2)){@p2
		...
		ret = ERROR;
		...	
		goto cleanup;
	}

+	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
+	if(memcmp(head, msg, size1) != 0){
+		ret = ERROR;	
+		goto cleanup;
+	}
+	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

|

	copy_from_user(head, src, size1)@p1 
	...
	if (copy_from_user(msg, src, size2)){@p2
		...
		ret = ERROR;
		...	
		goto cleanup;
	}

+	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
+	if(memcmp(head, msg, size1) != 0){
+		ret = ERROR;	
+		goto cleanup;
+	}
+	//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
)
	...

	}

@script:python@
p11 << rule1.p1;
p12 << rule1.p2;
@@
if p11 and p12:
	coccilib.report.print_report(p11[0],"rule1 First fetch")
	coccilib.report.print_report(p12[0],"rule1 Second fetch")




