/*
int rule1(int p){  

	
	a = a + 1;
	
	get_user(cmd, src);
	src += sizeof(uint32_t);
	get_user(target, src);
}

int rule2(int p){  

	
	a = a + 1;
	ptr = src;

	__get_user(cmd, ptr);
	//src += sizeof(uint32_t);


	__get_user(target, src);
}

int rule3(int p){  

	
	a = a + 1;
	ptr = src;

	copy_from_user(cmd, (uint32_t)src, c1);
	//ptr -= sizeof(uint32_t);


	copy_from_user(target, (uint32_t)ptr, c2);
}

int rule4(int p){  

	
	a = a + 1;
	

	__copy_from_user(cmd, src, c1);

	//src -= sizeof(uint32_t);
	ptr = (uint32_t)src;
	//ptr -= sizeof(uint32_t);


	__copy_from_user(target, ptr, c2);
}

int rule5(int p){  

	
	a = a + 1;
	

	__copy_from_user(cmd, (int)src->ele, c1);

	//src -= sizeof(uint32_t);


	__copy_from_user(target, src, c2);
}


int rule6(int p){  

	
	a = a + 1;

	__copy_from_user(cmd, src.ele, c1);

	//&src -= sizeof(uint32_t);


	__copy_from_user(target, (int)&src, c2);
}

void binder(){
	if (copy_from_user(t->buffer->data, (const void __user *)(uintptr_t)
			   tr->data.ptr.buffer, tr->data_size)) {
		binder_user_error("%d:%d got transaction with invalid data ptr\n",
				proc->pid, thread->pid);
		return_error = BR_FAILED_REPLY;
		goto err_copy_data_failed;
	}
	if (copy_from_user(offp, (const void __user *)(uintptr_t)
			   tr->data.ptr.offsets, tr->offsets_size)) {
		binder_user_error("%d:%d got transaction with invalid offsets ptr\n",
				proc->pid, thread->pid);
		return_error = BR_FAILED_REPLY;
		goto err_copy_data_failed;
	}
}
*/
void sysctl(){

	while (left  && isspace(c)){
		 __get_user(c, p)
		p++;
	}

	if (left > sizeof(tmpbuf) - 1)
		return -EINVAL;
	if (copy_from_user(tmpbuf, p, left))
		return -EFAULT;
}