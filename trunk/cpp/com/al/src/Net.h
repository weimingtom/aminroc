#ifndef NET_H
#define NET_H

// platform macro
#if defined(WIN32)
	#include <winsock2.h>
	#pragma comment(lib,"ws2_32.lib")	// 库链接
	typedef int socklen_t;
	#define __INIT_NET_ENVIR__ int nError;WSADATA wsaData;if((nError=WSAStartup(MAKEWORD(2,2),&wsaData))!=0){cout<<"启动WinSocket失败!"<<endl;return false;}
#elif defined(__linux__)
	#include <sys/socket.h>
	#include <sys/types.h>
	#include <sys/epoll.h>
	#include <arpa/inet.h>
	#include <netinet/in.h>
	#include <errno.h>
	#include <fcntl.h>
	#include <unistd.h>
	typedef int SOCKET;
	#define INVALID_SOCKET -1
	#define SOCKET_ERROR -1
	#define __INIT_NET_ENVIR__
#elif defined(__FreeBSD__)
	#include <sys/socket.h>
	#include <sys/types.h>
	#include <errno.h>
	#include <arpa/inet.h>
	#include <netinet/in.h>
	#include <sys/event.h>
	typedef int SOCKET;
	#define INVALID_SOCKET -1
	#define SOCKET_ERROR -1
	#define __INIT_NET_ENVIR__
#endif
// macro
#define MAX_CONNECTIONS 1024
static socklen_t NET_ADDR_LEN = sizeof(sockaddr);

// inner includes
#include "Macro.h"

/// net address
class NetAddress : public sockaddr_in
{
public:
	/**
	 * constructor
	 */
	NetAddress(){
		sin_family = AF_INET;
	}
	/**
	 * overloading constructor
	 */
	NetAddress(const unsigned short port)
	{
		sin_family = AF_INET;
		set(port);
	}
	/**
	 * overloading constructor
	 */
	NetAddress(const char* ip,const unsigned short port)
	{
		sin_family = AF_INET;
		set(ip,port);
	}
	/**
	 * set
	 */
	inline void set(const unsigned short port)
	{
		sin_addr.s_addr = htonl(INADDR_ANY); 
		sin_port = htons(port);
	}
	/**
	 * overloading set
	 */
	inline void set(const char* ip,const unsigned short port)
	{
		sin_addr.s_addr = inet_addr(ip);
		sin_port = htons(port);
	}
	/**
	 * overloading operator
	 */
	operator sockaddr*()
	{		return (sockaddr*)this;		}
	/** 
	 * overloading operator
	 */
	operator const sockaddr*()
	{		return (const sockaddr*)this;		}
};

/// net
class Net
{
public:
	SOCKET nSocket;
	NetAddress address;
public:
	/**
	 * constructor
	 */
	Net():nSocket(0){}
	/**
	 * destructor
	 */
	~Net(){}
	/**
	 * type conversion
	 */
	inline operator SOCKET() const{
		return nSocket;
	}
	/**
	 * overloading operator
	 */
	inline Net operator =(SOCKET s){
		nSocket = s;	
		return *this;
	};
	/**
	 * get ip
	 */
	inline const char* get_ip(){
		return inet_ntoa(address.sin_addr);
	}
	/**
	 * get int ip
	 */
	inline unsigned int get_int_ip(){
		return address.sin_addr.s_addr;
	}
	/** 
	 * create
	 * @param {const int} type 套接节类型
	 *	- TCP流:SOCK_STREAM
	 *	- UDP流:SOCK_DGRAM
	 * @return {bool} 
	 */
	bool socket(const int type = SOCK_STREAM);
	/** 
	 * bind
	 */
	bool bind(const unsigned short port);
	/** 
	 * listen
	 */
	bool listen(const unsigned int max_connections = MAX_CONNECTIONS);
	/** 
	 * accept a client
	 */
	bool accept(OUT Net& net);
	/** 
	 * send data
	 */
	int send(const char* data);
	/** 
	 * recv data
	 */
	int recv(OUT char* data,const unsigned int recv_size);
	/** 
	 * close
	 */
	bool close();
	/** 
	 * get error
	 */
	int getError();
	/** 
	 * create server
	 * @param {const ushort} port 监听端口
	 * @param {const uint} max_connections 最大连接数
	 * @param {const int} type 套接节类型
	 *	- TCP流:SOCK_STREAM
	 *	- UDP流:SOCK_DGRAM
	 * @return {bool} 处理结果 
	 */
	bool createServer(const unsigned short port,const unsigned int max_connections = MAX_CONNECTIONS,const int type = SOCK_STREAM);
	/**
	 * 各系统中的超级Socket
	 */
	bool super_socket();
};

#endif
