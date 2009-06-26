#include "PolicyLicence.h"

bool PolicyLicence::open(const char* file,const unsigned int port)
{
	nPort = port;

	PRINT_ITEM("file",file);
	PRINT_ITEM("port",nPort);

	// ��������ļ�
	ifstream input;
	input.open(file);
	if(!input.is_open()){ PRINT_ERROR("invalid file:" << file); return false; }
	ostringstream output;
	output << input.rdbuf();
	strFile = output.str();
	input.close();

	// ���Ӳ��Զ˿�
	if(netServer.createServer(nPort) == false){
		PRINT_ERROR("Fail to listen policy port!Please check it that if have other server runing now or purview is enough.");
		return false;
	}

	// ���������߳�
	Thread s;
	s.create(filter_work_thread,(void*)this);

	return true;
}
DECLARE_THREAD_FUNC(filter_work_thread)
{
	// ���紦����ָ��
	PolicyLicence* _this = (PolicyLicence*)param;

	char szRecvBuf[128] = "";
	timeval tv;
	tv.tv_sec = 1;

	Net request;

	for(;;){
		_this->netServer.accept(request);

		// ���ý���socket
		//::setsockopt(request.nSocket,SOL_SOCKET,SO_RCVTIMEO,(char*)&tv, sizeof(tv));
		//::setsockopt(request.GetSocket(),SOL_SOCKET,SO_RCVBUF,szRecvBuf,sizeof(128));

		// �շ�����
		request.recv(szRecvBuf,sizeof(szRecvBuf));
		request.send(_this->strFile.c_str());
		request.close();
	}

	PRINT_ERROR("Policy thread was exit!");

	return 0;
}