#include "Net.h"

bool Net::socket(const int type /* = SOCK_STREAM */)
{
	if((nSocket = ::socket(AF_INET,type,0)) == INVALID_SOCKET)
		return false;

	return true;
}

bool Net::bind(const unsigned short port)
{
	address.set(port);
	if(::bind(nSocket,address,sizeof(address)) == SOCKET_ERROR)
		return false;

	return true;
}

bool Net::listen(const unsigned int max_connections)
{
	if(::listen(nSocket,max_connections) == SOCKET_ERROR)
		return false;

	return true;
}

bool Net::accept(OUT Net& net)
{
	if((net = ::accept(nSocket,net.address,&NET_ADDR_LEN)) == INVALID_SOCKET)
		return false;

	return true;
}

int Net::send(const char* data)
{
	int totalSendSize = 0;
	int thisSendSize = 0;
	const int dataLen = strlen(data) + 1;
	const char* buf = data;

	do {
		if((thisSendSize = ::send(nSocket,buf,dataLen - totalSendSize,0)) == SOCKET_ERROR)
		{
			PRINT_ERROR("Send Failed:"<< data);
			return -1;
		}

		totalSendSize += thisSendSize;	//累加发送数据
		buf += thisSendSize;			//移动指针发送末发送的内容	
	} while(totalSendSize < dataLen);

	return totalSendSize;
}

int Net::recv(char* data,const unsigned int recv_size)
{
	int bytesThisTime;
	if((bytesThisTime = ::recv(nSocket, data, recv_size, 0)) == SOCKET_ERROR || bytesThisTime == 0){
		return -1;
	}

	return bytesThisTime;
}

bool Net::close()
{
#if defined(WIN32)
	if(::closesocket(nSocket) == SOCKET_ERROR){ return false; }
#else
	if(::close(nSocket) == SOCKET_ERROR){ return false;}
#endif
	nSocket = 0; 
	return true;
}

int Net::getError()
{
#if defined(WIN32)
	return WSAGetLastError();
#else
	return errno;
#endif
}

bool Net::createServer(const unsigned short port,const unsigned int max_connections,const int type)
{
	if(socket(type) == false)
		return false;

	if(bind(port) == false)
		return false;

	if(listen(max_connections) == false)
		return false;

	return true;
}


bool Net::super_socket()
{
#if defined(WIN32)
	nSocket = ::WSASocket(AF_INET,SOCK_STREAM,0,NULL,0,WSA_FLAG_OVERLAPPED);
	return true;
#elif defined(__linux__)
	socket();
	int opts = fcntl(nSocket,F_GETFL);
	if(opts<0){
		return false;
	}
	if(fcntl(nSocket,F_SETFL,opts|O_NONBLOCK)<0){
		return false;
	}
	return true;
#else
	socket();
	return true;
#endif
	
}
