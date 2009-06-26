#ifndef LUACLASS_H
#define LUACLASS_H

// outer includes
#include <stdarg.h>
extern "C" {
#include "../../lua5.1.4/src/lua.h"
#include "../../lua5.1.4/src/lualib.h"
#include "../../lua5.1.4/src/lauxlib.h"
}
// inner includes
#include "Macro.h"

/// lua class
class LuaClass
{
public:
	/**
	 * constructor
	 */
	LuaClass();
	/**
	 * load file of lua
	 */
	bool load(const char* file_name);
	/**
	 * destructor
	 */
	~LuaClass();
public:
	/**
	 * 调用函数
	 * @param [OUT] {int&} return_value 接收返回值
	 * @param {const char*} func_name 运行的脚本函数名
	 * @param {const char*} params_format 参数格式(下附参数格式)
	 *	-	%c	字符型
	 *	-	%d	整数型
	 *	-	%f	数字型
	 *	-	%s	字符串型
	 * @param {...} 对应参数列表的参数值
	 * @return {int} 返回处理结果代码
	 *	-	0	没有错误
	 *	-	-1	无此调用函数
	 *	-	-2	lua运行时错误
	 *	-	-3	lua分配内存错误
	 *	-	-4	lua执行错误句柄函数
	 */
	int call(OUT int& return_value,const char* func_name,const char* params_format = "",...);
public:
	lua_State *pLs;  // vm's point
};

#endif
