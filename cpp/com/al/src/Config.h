#ifndef CONFIG_H
#define CONFIG_H

// outer includes
#include "../../tinyxml2.5.3/src/tinyxml.h"
// inner includes
#include "Macro.h"

/// config
class Config
{
public:
	/** 
	 * load file of config
	 */
	bool load(const char* file_name);
	/** 
	 * get integral value by node name
	 */
	inline int getIntByName(const char* node_name){
		return atoi(mapTree[node_name].c_str());
	}
	/** 
	 * get unsigned integral value by node name
	 */
	inline unsigned int getUintByName(const char* name){
		return (unsigned int)atoi(mapTree[name].c_str());
	}
	/** 
	 * get string value by node name
	 */
	inline const char* getStringByName(const char* node_name){
		return mapTree[node_name].c_str();
	}
private:
	map<string,string> mapTree; // dom
};

#endif
