#ifndef POLICYLICENCE_H
#define POLICYLICENCE_H

// �ⲿ����
#include "../com/al/src/Net.h"
#include "../com/al/src/Thread.h"

/// �������
class PolicyLicence
{
public:
	/**
	 * ��ʼ��
	 * @param {const uint} port ���Զ˿�
	 * @param {const char*} policy_file �����ļ�
	 * @return {bool} ������
	 */
	bool open(const char* policy_file,const unsigned int port);
	/** 
	 * ��Ԫ����
	 */
	friend DECLARE_THREAD_FUNC(filter_work_thread);
private:
	unsigned int nPort;
	string strFile;
	Net netServer;
};

#endif
