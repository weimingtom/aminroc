#ifndef LOG_H
#define LOG_H

// inner includes
#include "Macro.h"

/// log
class Log
{
public:
	/** 
	 * open file of log
	 */
	bool open(const char* file_name,const unsigned int level);
	/**
	 * set log level
	 */
	inline void setLevel(unsigned int level){
		nLevel = level;
	}
	/**
	 * note a message
	 */
	inline void note(const char* msg,const unsigned int level){
		if(nLevel <= level){ fs << msg << endl; }
	}
	/**
	 * destructor
	 */
	~Log(){
		fs.close();
	}
private:
	ofstream fs;			// file handle
	unsigned int nLevel;	// log level
};
#endif
