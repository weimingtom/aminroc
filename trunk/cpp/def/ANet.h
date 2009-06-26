#ifndef ANET_H
#define ANET_H

// ����
#include "../com/al/src/Net.h"

// �궨��
#define _ED_	"\x00"		// ���ָ���
#define _CB_	"\x01"		// �����ָ���
#define _EN_	"\x03"		// �¼��ָ���
#define _1_		"\x16"		// ���ݷָ���
#define _2_		"\x1E"		// С���ݷָ���

#define C_ED_	'\x00'		// ���ָ���(�ַ���)
#define C_EN_	'\x03'		// ���ָ���(�ַ���)

#define NET_BUFFER_SIZE		1024	// ���ջ�������С
#define NET_MAX_RECV_SIZE	1023	// �����ֽ�����С

/// ������չ
class ANet : public Net
{
public:
	ANet(){
		nLastOffset = 0;
		memset(szBuffer,0,NET_BUFFER_SIZE);
	}
	/**
	 * ���ظ�ֵ�����
	 * @param {SOCKET} nSocket �׽���
	 * @return {SOCKET} �׽���
	 */
	inline ANet operator =(SOCKET s){
		Net::operator =(s);
		return *this;
	};
	/**
	 * ƽ̨��չ
	 */
	#if defined(WIN32)
		OVERLAPPED overlapped;
		WSABUF wsaBuf;
	#elif defined(__FreeBSD__)
		int nIndex;
	#endif
public:
	unsigned int nLastOffset;			// ƫ�Ƶ�ַ
	char szBuffer[NET_BUFFER_SIZE];		// ���ջ�����
};

#endif
