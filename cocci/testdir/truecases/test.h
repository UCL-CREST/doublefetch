int case1(int p){

	int x,y;
	q = (char*)p;
	x =x +1;

	get_user(x, q);


	y = y + 1;
	
	get_user(x, p);

	//get_user(x, (unsigned int *)e);
}
int case2(int p){

	int x,y;
	q = p;
	x =x +1;

	get_user(x, p);

	y = y + 1;
	
	get_user(x, q);

}
int case3(int p){

	int x,y;
	
	x =x +1;

	get_user(x, p);

	q = p;
	y = y + 1;
	
	get_user(x, q);

}
int case4(int p){

	int x,y;
	
	x =x +1;

	get_user(x, &p);

	y = y + 1;
	
	get_user(x, &p);

}
int case5(int p){

	int x,y;
	
	x =x +1;

	get_user(x, &p->size);

	y = y + 1;
	
	
	copy_from_user(buf, p, x);

}
