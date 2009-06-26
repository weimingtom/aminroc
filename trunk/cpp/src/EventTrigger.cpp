#include "EventTrigger.h"

// C接口 - 网络发送
int CNetSend(lua_State *ls)
{
	// 获得socket
	int socket = lua_tointeger(ls,1);
	// 获得发送字符串
	const char* data = lua_tostring(ls,2);

	int totalSendSize = 0;
	int thisSendSize = 0;

	// 如果包结束符是0,即lua调用CNetSend时不用带结束符,因为字符串的结束符就是0,否之则要
	#if C_ED_ == '\x00'
		const int dataLen = strlen(data) + 1;
	#else
		const int dataLen = strlen(data);
	#endif

	const char* buf = data;

	do {
		if((thisSendSize = ::send(socket,buf,dataLen - totalSendSize,0)) == SOCKET_ERROR)
		{
			PRINT_ERROR("Send Failed:"<< data);
			break;
		}

		totalSendSize += thisSendSize;	//累加发送数据
		buf += thisSendSize;			//移动指针发送末发送的内容	
	} while(totalSendSize < dataLen);

	// 返回发送出去的字符串
	lua_pushinteger(ls,totalSendSize);

	return 1;
}

// C接口 - 根据1970年来返回的毫秒数
int CGetTime(lua_State *ls)
{
#if defined(WIN32)
	struct _timeb t;
	_ftime(&t);
	lua_pushnumber(ls,t.time * 1000 + t.millitm);
#else
	struct timeb t;
	ftime(&t);
	lua_pushnumber(ls,t.time * 1000 + t.millitm);
#endif
	return 1;
}

bool EventTrigger::open(const char* file)
{
	// 加载主文件
	PRINT_ITEM("file",file);

	// 扩展全局变量
	lua_pushstring(lcScript.pLs,_CB_);
	lua_setglobal(lcScript.pLs,"_CB_");
	lua_pushstring(lcScript.pLs,_EN_);
	lua_setglobal(lcScript.pLs,"_EN_");
	lua_pushstring(lcScript.pLs,_1_);
	lua_setglobal(lcScript.pLs,"_1_");
	lua_pushstring(lcScript.pLs,_2_);
	lua_setglobal(lcScript.pLs,"_2_");
	// 扩展接口
	lua_pushcfunction(lcScript.pLs,CNetSend);
	lua_setglobal(lcScript.pLs,"CNetSend");
	lua_pushcfunction(lcScript.pLs,CGetTime);
	lua_setglobal(lcScript.pLs,"CGetTime");

	// 加载脚本
	if(!lcScript.load(file))
		return false;

	// 调用初始化函数
	int err_no;
	if(lcScript.call(err_no,"OnInit"))
		return false;

	if(err_no)
		return false;

	return true;
}

bool EventTrigger::touch(ANet& client,const char* package)
{
	// 调用函数
	int err_no;
	if(lcScript.call(err_no,"OnAEvent","%d%s",client.nSocket,package))
		return false;

	if(err_no){
		PRINTLN("IP:" << client.get_ip());
		return false;
	}

	return true;
}

void EventTrigger::touchCloseEvent(const ANet& client)
{
	int result;
	lcScript.call(result,"OnClose_Socket","%d",client.nSocket);
}
