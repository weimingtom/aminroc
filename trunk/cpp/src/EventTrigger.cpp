#include "EventTrigger.h"

// C�ӿ� - ���緢��
int CNetSend(lua_State *ls)
{
	// ���socket
	int socket = lua_tointeger(ls,1);
	// ��÷����ַ���
	const char* data = lua_tostring(ls,2);

	int totalSendSize = 0;
	int thisSendSize = 0;

	// �������������0,��lua����CNetSendʱ���ô�������,��Ϊ�ַ����Ľ���������0,��֮��Ҫ
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

		totalSendSize += thisSendSize;	//�ۼӷ�������
		buf += thisSendSize;			//�ƶ�ָ�뷢��ĩ���͵�����	
	} while(totalSendSize < dataLen);

	// ���ط��ͳ�ȥ���ַ���
	lua_pushinteger(ls,totalSendSize);

	return 1;
}

// C�ӿ� - ����1970�������صĺ�����
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
	// �������ļ�
	PRINT_ITEM("file",file);

	// ��չȫ�ֱ���
	lua_pushstring(lcScript.pLs,_CB_);
	lua_setglobal(lcScript.pLs,"_CB_");
	lua_pushstring(lcScript.pLs,_EN_);
	lua_setglobal(lcScript.pLs,"_EN_");
	lua_pushstring(lcScript.pLs,_1_);
	lua_setglobal(lcScript.pLs,"_1_");
	lua_pushstring(lcScript.pLs,_2_);
	lua_setglobal(lcScript.pLs,"_2_");
	// ��չ�ӿ�
	lua_pushcfunction(lcScript.pLs,CNetSend);
	lua_setglobal(lcScript.pLs,"CNetSend");
	lua_pushcfunction(lcScript.pLs,CGetTime);
	lua_setglobal(lcScript.pLs,"CGetTime");

	// ���ؽű�
	if(!lcScript.load(file))
		return false;

	// ���ó�ʼ������
	int err_no;
	if(lcScript.call(err_no,"OnInit"))
		return false;

	if(err_no)
		return false;

	return true;
}

bool EventTrigger::touch(ANet& client,const char* package)
{
	// ���ú���
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
