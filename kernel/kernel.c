#include "./kernel.h"
#include "../drivers/screen.h"

void main(){
   // Put X char in the first cell of vedio memory
   char* video_memory = (char*) 0xb8000;
   *video_memory = 'X';
   
   // start the kernel 
   entry_point();
}

void entry_point(){
   clear_screen(); // OK
   for(int i=0; i<MAX_ROWS-1; i++){
     print_at(">", 0, i);
   }
   print("Hello from the most basic kernel ...\n"); // OK
   print_char('X', 5, 7, WHITE_ON_BLACK); // OK
   print_at("Message hhsqqsddqsdqsdqssdqsdqsdsdsdq \n another line XXX", 8, 10); // OK
   print_at("Message hhsqqsddqsdqsdqssdqsdqsdsdsdq another line sqkkqsdqjdsqdlksqldkqslkdlqsdlqsdkk XXX", 15, 14); // OK
   
}
