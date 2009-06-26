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
	 * ���ú���
	 * @param [OUT] {int&} return_value ���շ���ֵ
	 * @param {const char*} func_name ���еĽű�������
	 * @param {const char*} params_format ������ʽ(�¸�������ʽ)
	 *	-	%c	�ַ���
	 *	-	%d	������
	 *	-	%f	������
	 *	-	%s	�ַ�����
	 * @param {...} ��Ӧ�����б�Ĳ���ֵ
	 * @return {int} ���ش���������
	 *	-	0	û�д���
	 *	-	-1	�޴˵��ú���
	 *	-	-2	lua����ʱ����
	 *	-	-3	lua�����ڴ����
	 *	-	-4	luaִ�д���������
	 */
	int call(OUT int& return_value,const char* func_name,const char* params_format = "",...);
public:
	lua_State *pLs;  // vm's point
};

#endif
