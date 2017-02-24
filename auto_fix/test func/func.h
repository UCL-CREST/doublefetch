#include <stdio.h>
//#include <string.h>
void func4(){
	printf("func4\n");
}
void func3(){
	func4();
	printf("func3\n");
}
void func2(){
	func3();
	printf("func2\n");
}
#include <string.h>
void func1(){
	func2();
	char src[] = "hello";
	char dst[6];
	memcpy(dst, src,strlen(src));
	printf("func1: %s\n",dst);
}