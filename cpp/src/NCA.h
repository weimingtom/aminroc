#ifndef NCA_H
#define NCA_H

// 外部引用
#include "../com/al/src/Thread.h"
// 内部引用
#include "../def/ANet.h"

// 宏定义
typedef bool (*recvHandle)(const int,ANet&);
#define DECLARE_RECV_FUNC(name) bool name(const int recvSize,ANet& client)

/// 网络处理(单件模式)
class NCA
{
public:
	/**
	 * 初始化
	 * @param {const uint} game_port 游戏端口
	 * @return {bool} 处理结果
	 */
	bool init(const unsigned int game_port);
	/**
	 * 启动服务器
	 * @return {bool} 处理结果
	 */
	bool startup();

	/**iocp
	---------------------------*/
	#if defined(WIN32)
		friend DECLARE_THREAD_FUNC(nca_work_thread);
		HANDLE hCompletionPort;
	#endif
public:
	recvHandle pCope;
private:
	unsigned int nGamePort;
	Net netServer;
};

#endif
