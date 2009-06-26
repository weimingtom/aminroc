#ifndef ANET_H
#define ANET_H

// 引用
#include "../com/al/src/Net.h"

// 宏定义
#define _ED_	"\x00"		// 包分隔符
#define _CB_	"\x01"		// 连包分隔符
#define _EN_	"\x03"		// 事件分隔符
#define _1_		"\x16"		// 内容分隔符
#define _2_		"\x1E"		// 小内容分隔符

#define C_ED_	'\x00'		// 包分隔符(字符版)
#define C_EN_	'\x03'		// 包分隔符(字符版)

#define NET_BUFFER_SIZE		1024	// 接收缓冲区大小
#define NET_MAX_RECV_SIZE	1023	// 接收字节数大小

/// 网络扩展
class ANet : public Net
{
public:
	ANet(){
		nLastOffset = 0;
		memset(szBuffer,0,NET_BUFFER_SIZE);
	}
	/**
	 * 重载赋值运算符
	 * @param {SOCKET} nSocket 套接字
	 * @return {SOCKET} 套接字
	 */
	inline ANet operator =(SOCKET s){
		Net::operator =(s);
		return *this;
	};
	/**
	 * 平台扩展
	 */
	#if defined(WIN32)
		OVERLAPPED overlapped;
		WSABUF wsaBuf;
	#elif defined(__FreeBSD__)
		int nIndex;
	#endif
public:
	unsigned int nLastOffset;			// 偏移地址
	char szBuffer[NET_BUFFER_SIZE];		// 接收缓冲区
};

#endif
