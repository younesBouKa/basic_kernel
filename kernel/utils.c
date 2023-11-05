#include "./utils.h"

void memory_copy(char* src, char* dest, int size){
	int i=0;
	for(i=0; i<size; i++){
		*(dest+i) = *(src+i); 
	}
}
