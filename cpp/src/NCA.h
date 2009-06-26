#ifndef NCA_H
#define NCA_H

// �ⲿ����
#include "../com/al/src/Thread.h"
// �ڲ�����
#include "../def/ANet.h"

// �궨��
typedef bool (*recvHandle)(const int,ANet&);
#define DECLARE_RECV_FUNC(name) bool name(const int recvSize,ANet& client)

/// ���紦��(����ģʽ)
class NCA
{
public:
	/**
	 * ��ʼ��
	 * @param {const uint} game_port ��Ϸ�˿�
	 * @return {bool} ������
	 */
	bool init(const unsigned int game_port);
	/**
	 * ����������
	 * @return {bool} ������
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
