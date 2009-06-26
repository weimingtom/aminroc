#include "NCA.h"

bool NCA::init(const unsigned int game_port)
{
	nGamePort = game_port;

	PRINT_ITEM("port",game_port);

	// ��������socket
	netServer.super_socket();

	// �󶨶˿�
	if(!netServer.bind(nGamePort)){
		PRINT_ERROR("Fail to bind game port!Please check it that if have other server runing now");
		return false;
	}

	// �����˿�
	if(!netServer.listen()){
		PRINT_ERROR("Fail to listen game port!Please check it that if have other server runing now");
		return false;
	}

	return true;
}
#if defined(WIN32)
	bool NCA::startup()
	{
		// ����I/O��ɶ˿�
		hCompletionPort = CreateIoCompletionPort(INVALID_HANDLE_VALUE,NULL,0,0);

		// ���������߳�
		Thread t;
		t.create(nca_work_thread,(void*)this);

		// ���յ��ֽ���
		DWORD recvSize;
		// ���ձ�ʶ
		DWORD flags = 0;
		// �ͻ���
		ANet* ptrClient;

		for(;;){
			// ��������
			ptrClient = new ANet;

			// ��������
			*ptrClient = WSAAccept(netServer,ptrClient->address,&NET_ADDR_LEN,NULL,0);
			
			// �����½�������socket���봴���õ���ɶ˿�,������һ���׽�����Ϣ�ṹ
			CreateIoCompletionPort((HANDLE)ptrClient->nSocket,hCompletionPort,(ULONG_PTR)ptrClient,0);

			// �����ص�I/O��Ϣ�ṹ
			memset(&ptrClient->overlapped,0,sizeof(ptrClient->overlapped));
			ptrClient->wsaBuf.len = NET_MAX_RECV_SIZE;
			ptrClient->wsaBuf.buf = ptrClient->szBuffer;

			// ��������
			WSARecv(*ptrClient,&(ptrClient->wsaBuf),1,&recvSize,&flags,&ptrClient->overlapped,NULL);
		}
		return false;
	}

	DECLARE_THREAD_FUNC(nca_work_thread)
	{
		// ���紦����ָ��
		NCA* _this = (NCA*)param;

		// ���ձ�ʶ
		DWORD flags = 0;

		// ���ݻ�����
		LPOVERLAPPED ptrOverlapped;
		// ���յ��ֽ���
		DWORD recvSize = 0;
		// �ͻ���
		ANet* ptrClient;

		for(;;)
		{
			// �ȴ�I/O���
			GetQueuedCompletionStatus(_this->hCompletionPort,&recvSize,(PULONG_PTR)&ptrClient,&ptrOverlapped,INFINITE);

			if(_this->pCope(recvSize,*ptrClient) == false){
				// �ر�����
				ptrClient->close();
				// �������
				delete ptrClient;
				continue;
			}

			// ���½�������
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
		
		// ����������
		listenEvent.data.ptr = (void*)&netServer;
		listenEvent.events = EPOLLIN | EPOLLRDHUP | EPOLLHUP | EPOLLERR;
		epoll_ctl(listenEvents,EPOLL_CTL_ADD,netServer,&listenEvent);

		for(;;){
			// �ȴ��¼�����(����ģʽ)
			touchAmount = epoll_wait(listenEvents,touchEvents,MAX_TOUCH_EVENTS,-1);
			
			for(int i = 0;i < touchAmount;++i)
			{
				epoll_event& touchEvent = touchEvents[i];

				// �����������¼�
				//--------------------
				if(touchEvent.data.ptr == &netServer)
				{
					// ��������
					ANet* ptrClient = new ANet;
					ptrClient->super_socket();
					// ��������
					netServer.accept(*ptrClient);
					// ע���¼�
					listenEvent.data.ptr = (void*)ptrClient;
					epoll_ctl(listenEvents,EPOLL_CTL_ADD,*ptrClient,&listenEvent);
					continue;
				}
				// �ͻ��˽����¼�
				//--------------------
				int recvSize = 0;
				ANet* ptrClient = (ANet*)touchEvent.data.ptr;
				// ��������
				recvSize = ptrClient->recv(ptrClient->szBuffer,NET_BUFFER_SIZE);
				// �����¼�
				if(pCope(recvSize,*ptrClient) == false){
					// ɾ���¼�
					epoll_ctl(listenEvents,EPOLL_CTL_DEL,*ptrClient,NULL);
					// �ر�����
					ptrClient->close();
					// �������
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

		// ����kqueue
		int kq = kqueue();
		if(kq == -1){
			PRINTLN("Fail to create kqueue");
			return false;
		}
		
		// ��ʼ���¼���
		for(int i = 0;i < MAX_LISTEN_EVENTS;++i){
			EV_SET(&listenEvents[i],0,EVFILT_READ,EV_ENABLE | EV_ADD | EV_ERROR,0,0,0);
			// ����������������
			if(i){ freeIndex.push(MAX_LISTEN_EVENTS - i); }
		}
		// ����������
		listenEvents[0].ident = netServer;

		for (;;) {
			touchAmount = kevent(kq,listenEvents,MAX_LISTEN_EVENTS,touchEvents,MAX_TOUCH_EVENTS,NULL);

			for(int i = 0;i < touchAmount;++i) 
			{
				struct kevent& touchEvent = touchEvents[i];

				// �����������¼�
				//--------------------
				if(touchEvent.ident == netServer)
				{
					// ��������
					ANet* ptrClient = new ANet;
					ptrClient->super_socket();
					// ��������
					netServer.accept(*ptrClient);
					// ע���¼�
					int index = freeIndex.top();
					struct kevent& listenEvent = listenEvents[index];
					ptrClient->nIndex = index;
					listenEvent.ident = *ptrClient;
					listenEvent.udata = (void*)ptrClient;
					// ��������
					freeIndex.pop();
					continue;
				}
				// �ͻ��˽����¼�
				//--------------------
				int recvSize = 0;
				ANet* ptrClient = (ANet*)touchEvent.udata;
				// ��������
				if(touchEvent.data){
					recvSize = ptrClient->recv(ptrClient->szBuffer,NET_BUFFER_SIZE);
				}
				// �����¼�
				if(pCope(recvSize,*ptrClient) == false){
					int index = ptrClient->nIndex;
					// ɾ���¼�
					listenEvents[index].ident = 0;
					// �ر�����
					ptrClient->close();
					// �������
					delete ptrClient;
					// �黹����
					freeIndex.push(index);
					continue;
				}
			}
		}
		return false;
	}
#endif
