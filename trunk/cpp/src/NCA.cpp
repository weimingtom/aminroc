#include "NCA.h"

bool NCA::init(const unsigned int game_port)
{
	nGamePort = game_port;

	PRINT_ITEM("port",game_port);

	// 创建超级socket
	netServer.super_socket();

	// 绑定端口
	if(!netServer.bind(nGamePort)){
		PRINT_ERROR("Fail to bind game port!Please check it that if have other server runing now");
		return false;
	}

	// 监听端口
	if(!netServer.listen()){
		PRINT_ERROR("Fail to listen game port!Please check it that if have other server runing now");
		return false;
	}

	return true;
}
#if defined(WIN32)
	bool NCA::startup()
	{
		// 创建I/O完成端口
		hCompletionPort = CreateIoCompletionPort(INVALID_HANDLE_VALUE,NULL,0,0);

		// 创建工作线程
		Thread t;
		t.create(nca_work_thread,(void*)this);

		// 接收的字节数
		DWORD recvSize;
		// 接收标识
		DWORD flags = 0;
		// 客户端
		ANet* ptrClient;

		for(;;){
			// 创建对象
			ptrClient = new ANet;

			// 接入连接
			*ptrClient = WSAAccept(netServer,ptrClient->address,&NET_ADDR_LEN,NULL,0);
			
			// 关联新接入来的socket和与创建好的完成端口,并传递一个套接字信息结构
			CreateIoCompletionPort((HANDLE)ptrClient->nSocket,hCompletionPort,(ULONG_PTR)ptrClient,0);

			// 创建重叠I/O信息结构
			memset(&ptrClient->overlapped,0,sizeof(ptrClient->overlapped));
			ptrClient->wsaBuf.len = NET_MAX_RECV_SIZE;
			ptrClient->wsaBuf.buf = ptrClient->szBuffer;

			// 接收数据
			WSARecv(*ptrClient,&(ptrClient->wsaBuf),1,&recvSize,&flags,&ptrClient->overlapped,NULL);
		}
		return false;
	}

	DECLARE_THREAD_FUNC(nca_work_thread)
	{
		// 网络处理器指针
		NCA* _this = (NCA*)param;

		// 接收标识
		DWORD flags = 0;

		// 数据缓冲区
		LPOVERLAPPED ptrOverlapped;
		// 接收的字节数
		DWORD recvSize = 0;
		// 客户端
		ANet* ptrClient;

		for(;;)
		{
			// 等待I/O完成
			GetQueuedCompletionStatus(_this->hCompletionPort,&recvSize,(PULONG_PTR)&ptrClient,&ptrOverlapped,INFINITE);

			if(_this->pCope(recvSize,*ptrClient) == false){
				// 关闭连接
				ptrClient->close();
				// 清空数据
				delete ptrClient;
				continue;
			}

			// 重新接收数据
			WSARecv(*ptrClient,&(ptrClient->wsaBuf),1,&recvSize,&flags,ptrOverlapped,NULL);
		}

		PRINT_ERROR("work Thread waw exit!");

		return 0;
	}
#elif defined(__linux__)
	#define MAX_LISTEN_EVENTS	10000
	#define MAX_TOUCH_EVENTS	1000
	#ifndef EPOLLRDHUP
		#define EPOLLRDHUP 0x2000
	#endif

	bool NCA::startup(){
		int listenEvents = epoll_create(MAX_LISTEN_EVENTS);
		epoll_event touchEvents[MAX_TOUCH_EVENTS];
		epoll_event listenEvent;
		int touchAmount;
		
		// 监听服务器
		listenEvent.data.ptr = (void*)&netServer;
		listenEvent.events = EPOLLIN | EPOLLRDHUP | EPOLLHUP | EPOLLERR;
		epoll_ctl(listenEvents,EPOLL_CTL_ADD,netServer,&listenEvent);

		for(;;){
			// 等待事件触发(阻塞模式)
			touchAmount = epoll_wait(listenEvents,touchEvents,MAX_TOUCH_EVENTS,-1);
			
			for(int i = 0;i < touchAmount;++i)
			{
				epoll_event& touchEvent = touchEvents[i];

				// 服务器接入事件
				//--------------------
				if(touchEvent.data.ptr == &netServer)
				{
					// 创建对象
					ANet* ptrClient = new ANet;
					ptrClient->super_socket();
					// 接入连接
					netServer.accept(*ptrClient);
					// 注册事件
					listenEvent.data.ptr = (void*)ptrClient;
					epoll_ctl(listenEvents,EPOLL_CTL_ADD,*ptrClient,&listenEvent);
					continue;
				}
				// 客户端接收事件
				//--------------------
				int recvSize = 0;
				ANet* ptrClient = (ANet*)touchEvent.data.ptr;
				// 接收数据
				recvSize = ptrClient->recv(ptrClient->szBuffer,NET_BUFFER_SIZE);
				// 处理事件
				if(pCope(recvSize,*ptrClient) == false){
					// 删除事件
					epoll_ctl(listenEvents,EPOLL_CTL_DEL,*ptrClient,NULL);
					// 关闭连接
					ptrClient->close();
					// 清空数据
					delete ptrClient;
					continue;
				}
			}
		}
		return false;
	}
#elif defined(__FreeBSD__)
	#define MAX_LISTEN_EVENTS		10000
	#define MAX_TOUCH_EVENTS		1000

	bool NCA::startup(){
		struct kevent listenEvents[MAX_LISTEN_EVENTS];
		struct kevent touchEvents[MAX_TOUCH_EVENTS];
		int touchAmount;
		stack<int> freeIndex;

		// 创建kqueue
		int kq = kqueue();
		if(kq == -1){
			PRINTLN("Fail to create kqueue");
			return false;
		}
		
		// 初始化事件组
		for(int i = 0;i < MAX_LISTEN_EVENTS;++i){
			EV_SET(&listenEvents[i],0,EVFILT_READ,EV_ENABLE | EV_ADD | EV_ERROR,0,0,0);
			// 跳过服务器的索引
			if(i){ freeIndex.push(MAX_LISTEN_EVENTS - i); }
		}
		// 监听服务器
		listenEvents[0].ident = netServer;

		for (;;) {
			touchAmount = kevent(kq,listenEvents,MAX_LISTEN_EVENTS,touchEvents,MAX_TOUCH_EVENTS,NULL);

			for(int i = 0;i < touchAmount;++i) 
			{
				struct kevent& touchEvent = touchEvents[i];

				// 服务器接入事件
				//--------------------
				if(touchEvent.ident == netServer)
				{
					// 创建对象
					ANet* ptrClient = new ANet;
					ptrClient->super_socket();
					// 接入连接
					netServer.accept(*ptrClient);
					// 注册事件
					int index = freeIndex.top();
					struct kevent& listenEvent = listenEvents[index];
					ptrClient->nIndex = index;
					listenEvent.ident = *ptrClient;
					listenEvent.udata = (void*)ptrClient;
					// 弹出索引
					freeIndex.pop();
					continue;
				}
				// 客户端接收事件
				//--------------------
				int recvSize = 0;
				ANet* ptrClient = (ANet*)touchEvent.udata;
				// 接收数据
				if(touchEvent.data){
					recvSize = ptrClient->recv(ptrClient->szBuffer,NET_BUFFER_SIZE);
				}
				// 处理事件
				if(pCope(recvSize,*ptrClient) == false){
					int index = ptrClient->nIndex;
					// 删除事件
					listenEvents[index].ident = 0;
					// 关闭连接
					ptrClient->close();
					// 清空数据
					delete ptrClient;
					// 归还索引
					freeIndex.push(index);
					continue;
				}
			}
		}
		return false;
	}
#endif
