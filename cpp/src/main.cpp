/**
 * Developed by AminLab
 * ------------------------------------
 * date:2009-06-02
 * site:http://www.aminLab.cn
 * ------------------------------------
 */
// 外部引用
#include "../com/al/src/Log.h"
#include "../com/al/src/Config.h"
// 内部引用
#include "NCA.h"
#include "PolicyLicence.h"
#include "PackParse.h"
#include "EventTrigger.h"

/* 全局变量
---------------------------------------*/
Config g_config;
Log g_log;
EventTrigger g_eventTrigger;
PolicyLicence g_policyLicence;
NCA g_nca;
PackParse g_pp;

/* 函数声明
---------------------------------------*/
DECLARE_RECV_FUNC(cope);

/* 主函数
---------------------------------------*/
int main(int argc,char* argv[])
{
	// 初始化网络环境
	__INIT_NET_ENVIR__

	// 加载配置
	LOAD_LIB("Loading Config",
				g_config.load("config.xml"),
				true);

	// 加载日志
	LOAD_LIB("Loading Log",
				g_log.open(g_config.getStringByName("LogFile"),g_config.getUintByName("LogLevel")),
				true);

	// 加载事件触发器
	LOAD_LIB("Loading Event Trigger",
				g_eventTrigger.open(g_config.getStringByName("LuaFile")),
				true);

	// 加载过滤器
	LOAD_LIB("Loading Policy Licence",
				g_policyLicence.open(g_config.getStringByName("PolicyFile"),g_config.getUintByName("PolicyPort")),
				true);

	// 加载网络交互适配器
	LOAD_LIB("Loading Network Communication Adapter",
				g_nca.init(g_config.getUintByName("GamePort")),
				true);

	// 输出环境
	PRINT_SYS_INFO("Developed by AminLab");
	PRINT_SYS_INFO("date:2009-06-02");
	PRINT_SYS_INFO("site:http://www.aminLab.cn");

	// 启动游戏服务器
	g_nca.pCope = cope;
	g_nca.startup();

	return 0;
}
/**
 * 处理数据
 * @param {const uint} recvSize 接收长度
 * @param {const char*} netBuf 数据缓冲区
 * @param {ANet*} client 套接字扩展类
 * @return {bool}
 *	- true:继续接收
 *	- false:关闭socket
 */
DECLARE_RECV_FUNC(cope)
{
	int result = 0;

	// 连接断开
	if(recvSize <= 0){
_CLOSE:
		// 处理断开事件
		if(result != -1){
			g_eventTrigger.touchCloseEvent(client);
		}
		return false;
	}

	// 加载数据
	g_pp.reset();
	g_pp.load(client.szBuffer,recvSize,&client.nLastOffset);

	// 解析数据
	for(;;){
		result = g_pp.parse();
		// 成功
		if(result == 1){
			if(!g_eventTrigger.touch(client,g_pp.getPackage())){
				goto _CLOSE;
			}
		}
		// 完成
		else if(result == 2) { break;	}
		// 等待
		else if(result == 3) { break;	}
	}

	// 清空加载数据
	g_pp.clear();
	return true;
}
