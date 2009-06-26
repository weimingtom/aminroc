#include "LuaClass.h"

LuaClass::LuaClass():pLs(0)
{
	pLs = lua_open();		// 打开lua
	luaL_openlibs(pLs);		// 载入lua基本库
}

LuaClass::~LuaClass()
{
	lua_close(pLs);			// 关闭lua
}

bool LuaClass::load(const char* file_name)
{
	if(!pLs)
		return false;

	// 加载文件
	if(luaL_dofile(pLs,file_name))
		return false;

	return true;
}

int LuaClass::call(OUT int& return_value,const char* func_name,const char* params_format,...)
{
	int err_no = 0;
	int paramNumber = 0;
	char* ptrString = NULL;
	int result = 0;
	const char* error = NULL;

	// 获取函数
	lua_getglobal(pLs,func_name);
	if(lua_type(pLs,1) != LUA_TFUNCTION)
	{
		// 无此函数
		err_no = -1;
		goto _End;
	}

	// 得到参数个数
	paramNumber = strlen(params_format) / 2;
	// 字符串指针
	ptrString = NULL;

	// 实参列表
	va_list params;
	// 开始获取参数
	va_start(params,params_format);

	while(*params_format)
	{
		switch(*params_format)
		{
			case 'c':
				lua_pushinteger(pLs,va_arg(params,int));
				break;
			case 'd':
				lua_pushinteger(pLs,va_arg(params,int));
				break;
			case 'f':
				lua_pushnumber(pLs,va_arg(params,double));
				break;
			case 's':
				ptrString = va_arg(params,char*);
				lua_pushlstring(pLs,ptrString,strlen(ptrString));
				break;
		}
		// 移动指针
		++params_format;
	}

	// 结束获取参数
	va_end(params);

	// 参数压栈后开始调用函数
	result = lua_pcall(pLs,paramNumber,1,0);

	// 如果错误则输出
	if(result)
	{
        error = lua_tostring(pLs,-1);
        switch(result)
        {
            case LUA_ERRRUN:
                cout << "-- lua运行时错误:" << error << endl;
                err_no = -2;
                goto _End;
            case LUA_ERRMEM:
                cout << "-- lua分配内存错误:" << error << endl;
                err_no = -3;
                goto _End;
            case LUA_ERRERR:
                cout << "-- lua执行错误句柄函数:" << error <<endl;
                err_no = -4;
                goto _End;
        }
	}

	// 得到结果
	return_value = lua_tointeger(pLs,-1);
	lua_pop(pLs,1);

_End:
	return err_no;
}
