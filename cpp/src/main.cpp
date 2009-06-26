/**
 * Developed by AminLab
 * ------------------------------------
 * date:2009-06-02
 * site:http://www.aminLab.cn
 * ------------------------------------
 */
// �ⲿ����
#include "../com/al/src/Log.h"
#include "../com/al/src/Config.h"
// �ڲ�����
#include "NCA.h"
#include "PolicyLicence.h"
#include "PackParse.h"
#include "EventTrigger.h"

/* ȫ�ֱ���
---------------------------------------*/
Config g_config;
Log g_log;
EventTrigger g_eventTrigger;
PolicyLicence g_policyLicence;
NCA g_nca;
PackParse g_pp;

/* ��������
---------------------------------------*/
DECLARE_RECV_FUNC(cope);

/* ������
---------------------------------------*/
int main(int argc,char* argv[])
{
	// ��ʼ�����绷��
	__INIT_NET_ENVIR__

	// ��������
	LOAD_LIB("Loading Config",
				g_config.load("config.xml"),
				true);

	// ������־
	LOAD_LIB("Loading Log",
				g_log.open(g_config.getStringByName("LogFile"),g_config.getUintByName("LogLevel")),
				true);

	// �����¼�������
	LOAD_LIB("Loading Event Trigger",
				g_eventTrigger.open(g_config.getStringByName("LuaFile")),
				true);

	// ���ع�����
	LOAD_LIB("Loading Policy Licence",
				g_policyLicence.open(g_config.getStringByName("PolicyFile"),g_config.getUintByName("PolicyPort")),
				true);

	// �������罻��������
	LOAD_LIB("Loading Network Communication Adapter",
				g_nca.init(g_config.getUintByName("GamePort")),
				true);

	// �������
	PRINT_SYS_INFO("Developed by AminLab");
	PRINT_SYS_INFO("date:2009-06-02");
	PRINT_SYS_INFO("site:http://www.aminLab.cn");

	// ������Ϸ������
	g_nca.pCope = cope;
	g_nca.startup();

	return 0;
}
/**
 * ��������
 * @param {const uint} recvSize ���ճ���
 * @param {const char*} netBuf ���ݻ�����
 * @param {ANet*} client �׽�����չ��
 * @return {bool}
 *	- true:��������
 *	- false:�ر�socket
 */
DECLARE_RECV_FUNC(cope)
{
	int result = 0;

	// ���ӶϿ�
	if(recvSize <= 0){
_CLOSE:
		// ����Ͽ��¼�
		if(result != -1){
			g_eventTrigger.touchCloseEvent(client);
		}
		return false;
	}

	// ��������
	g_pp.reset();
	g_pp.load(client.szBuffer,recvSize,&client.nLastOffset);

	// ��������
	for(;;){
		result = g_pp.parse();
		// �ɹ�
		if(result == 1){
			if(!g_eventTrigger.touch(client,g_pp.getPackage())){
				goto _CLOSE;
			}
		}
		// ���
		else if(result == 2) { break;	}
		// �ȴ�
		else if(result == 3) { break;	}
	}

	// ��ռ�������
	g_pp.clear();
	return true;
}
