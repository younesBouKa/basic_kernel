#include "./screen.h"
#include "../kernel/low_level.h"
#include "../kernel/utils.h"

// print a char in col, row with attr_byte
void print_char(char character, int col, int row, char attr_byte){
	// create a byte (char) pointer to the start of video memery address
	unsigned char *video_mem = (char*) VIDEO_ADDRESS;
	
	// if attr_byte is zero, assume default style
	if(!attr_byte){
		attr_byte = WHITE_ON_BLACK;
	}
	
	// get the video memory offset for the screen location
	int offset;
	if(col >=0 && row >= 0){
		offset = get_screen_offset(col, row);
	// otherwise use the current cursor position
	}else{
		offset = get_cursor();
	}
	
	// if we see a newline character set offset to the end of current row
	// so it will be advanced to the first core of next row
	if(character == '\n'){// TODO to verify (will never work)
		int rows = offset / (2*MAX_COLS);
		offset = get_screen_offset(MAX_COLS-1, rows); 
		//offset = get_screen_offset(0, rows+1);
	// otherwise write the character and its attr byte to the video mem
	// at the calculated offset
	}
	else{
		video_mem[offset] = character;
		video_mem[offset+1] = attr_byte; 
	}
	
	// update the offset to the next character cell which is two byte
	// ahead of current cell
	offset += 2;
	// make scrolling adjustment for when we reach the bottom of screeen
	offset = handle_scrolling(offset);
	// update the cursor position on the screen device
	set_cursor(offset);
}

// Calculate screen offset of a given col and row
int get_screen_offset(int col, int row){
	return ((row * MAX_COLS) + col) * 2;
}

int get_cursor(){
	// the device uses its control register as an index to select its
	// internal registers, of which we are interested in:
	// 	reg 14: which is high byte of the cursor's offset
	// 	reg 15: which is the low byte of the cursor's offset
	// once the internal register has benn selected, we may read
	// write a byte on the data register
	port_byte_out(REG_SCREEN_CTRL, 14);
	int offset = port_byte_in(REG_SCREEN_DATA) << 8;
	port_byte_out(REG_SCREEN_CTRL, 15);
	offset += port_byte_in(REG_SCREEN_DATA);
	// since the cursor offset reported by the VGA hardware is
	// the number of characters, we multiply by two to convert it 
	// to a character cell offset
	return offset*2;
}

void set_cursor(int offset){
	// convert from cell offset to char offset
	offset /= 2; 
	// this is similar to get_cursor, only now we write bytes to those internal 
	// device registers.
	port_byte_out(REG_SCREEN_CTRL, 14);
	port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset >> 8));
	port_byte_out(REG_SCREEN_CTRL, 15);
	port_byte_out(REG_SCREEN_DATA, (unsigned char)(offset));
}

void print_at(char* message, int col, int row){
	// update cusror if col and row are not negative
	if(col >=0 && row >=0){
		set_cursor(get_screen_offset(col, row));
	}
	// loop through each character of the message and print it
	int i=0;
	while(message[i] != 0){
		if(message[i] == '\n'){
			row++;
			col=0;
		}
		print_char(message[i++], col++, row, WHITE_ON_BLACK);
	}
}

void print(char* message){
	print_at(message, -1, -1);
}

void clear_screen(){
	int row = 0;
	int col = 0;
	
	// loop through video memory and write blank characters
	for(row=0; row<MAX_ROWS; row++){
		for(col=0; col<MAX_COLS; col++){
			print_char(' ', col, row, WHITE_ON_BLACK);
		}
	}
	
	// move the cursor to the top left
	set_cursor(get_screen_offset(0, 0));
}

int handle_scrolling(int cursor_offset){
	// if the cursor is within the screen, return it unmodified
	if(cursor_offset < MAX_ROWS*MAX_COLS*2){
		return cursor_offset;
	}
	
	// shuffle the rows back one
	int i;
	char* src;
	char* dest;
	int line_size = MAX_COLS*2;
	for(i=1; i<MAX_ROWS; i++){
		src = (char*) (get_screen_offset(0, i) + VIDEO_ADDRESS);
		dest = (char*) (get_screen_offset(0, i-1) + VIDEO_ADDRESS);
		memory_copy(src, dest, line_size);
	}
	
	// blank the last line wy setting all bytes to 0
	char* last_line = (char*) (get_screen_offset(0, MAX_ROWS-1) + VIDEO_ADDRESS);
	for(i=0; i<line_size; i++){
		last_line[i] = 0;
	}
	
	// move the offset back one row, such that it is now on the last row
	// rather than off the edge of screen
	cursor_offset -= line_size;
	
	// return the updated cursor
	return cursor_offset;
}
