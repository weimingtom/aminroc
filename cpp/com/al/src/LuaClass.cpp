#include "LuaClass.h"

LuaClass::LuaClass():pLs(0)
{
	pLs = lua_open();		// ��lua
	luaL_openlibs(pLs);		// ����lua������
}

LuaClass::~LuaClass()
{
	lua_close(pLs);			// �ر�lua
}

bool LuaClass::load(const char* file_name)
{
	if(!pLs)
		return false;

	// �����ļ�
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

	// ��ȡ����
	lua_getglobal(pLs,func_name);
	if(lua_type(pLs,1) != LUA_TFUNCTION)
	{
		// �޴˺���
		err_no = -1;
		goto _End;
	}

	// �õ���������
	paramNumber = strlen(params_format) / 2;
	// �ַ���ָ��
	ptrString = NULL;

	// ʵ���б�
	va_list params;
	// ��ʼ��ȡ����
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
		// �ƶ�ָ��
		++params_format;
	}

	// ������ȡ����
	va_end(params);

	// ����ѹջ��ʼ���ú���
	result = lua_pcall(pLs,paramNumber,1,0);

	// ������������
	if(result)
	{
        error = lua_tostring(pLs,-1);
        switch(result)
        {
            case LUA_ERRRUN:
                cout << "-- lua����ʱ����:" << error << endl;
                err_no = -2;
                goto _End;
            case LUA_ERRMEM:
                cout << "-- lua�����ڴ����:" << error << endl;
                err_no = -3;
                goto _End;
            case LUA_ERRERR:
                cout << "-- luaִ�д���������:" << error <<endl;
                err_no = -4;
                goto _End;
        }
	}

	// �õ����
	return_value = lua_tointeger(pLs,-1);
	lua_pop(pLs,1);

_End:
	return err_no;
}
