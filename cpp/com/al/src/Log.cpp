#include "Log.h"

bool Log::open(const char* file_name,const unsigned int level){
	PRINT_ITEM("file",file_name);
	PRINT_ITEM("level",level);

	setLevel(level);
	fs.open(file_name,ios::app);
	return true;
}
