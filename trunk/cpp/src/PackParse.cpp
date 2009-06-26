#include "PackParse.h"

int PackParse::parse()
{
	/*
	 * �������:С��(����),����(����),���(�Ͽ�)
	 * �����ֽڲ����ڻ�������С
	 * ���ճ���:�������׵�ַ + �ӽ��յİ� + �ϴεİ�
	 */

	// ���ý������׵�ַ
	if(pEndPoint == NULL){
		pStartPoint = szBuf;
	}
	else{
		pStartPoint = pEndPoint + 1;
	}

	if(*pLastOffset){
		PRINTLN("�Ͻ��������:" << pStartPoint);
	}

	// �������
	if(pStartPoint >= szBuf + nBufLen + *pLastOffset){
		goto _FINISH;
	}

	// ������������
	pEndPoint = strchr(pStartPoint,C_ED_);

	if(pEndPoint != NULL && pEndPoint < szBuf + nBufLen + *pLastOffset){
		goto _SUCCESS;
	}

	goto _WAIT;

// �ɹ�
_SUCCESS:
	bParseFinish = true;
	return 1;

// �������
_FINISH:
	bParseFinish = true;
	return 2;
	
// �ȴ���һ������
_WAIT:
	PRINTLN("δ�����������:" << pEndPoint);
	bParseFinish = false;
	// δ������ֽڳ���
	if(pEndPoint){
		*pLastOffset = pEndPoint - pStartPoint;
	}
	else{
		*pLastOffset = nBufLen;
	}
	return 3;

}

void PackParse::clear()
{
	// �������
	if(bParseFinish == true)
	{
		// ����ѽ�������
		memset(szBuf,0,nParsedLen);
		// ���ñ���
		*pLastOffset = 0;
	}
	else
	{
		// ��δ������һ�ο�����ǰͷ
		memcpy(szBuf,pStartPoint,*pLastOffset);
		// ����ѽ�������
		memset(szBuf + *pLastOffset,0,NET_MAX_RECV_SIZE - *pLastOffset);
	}
}
