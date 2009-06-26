#ifndef DATAPARSE_H
#define DATAPARSE_H

// �ڲ�����
#include "../def/ANet.h"

/// ���ݽ���
class PackParse
{
public:
	/**
	 * ����
	 */
	inline void reset(){
		pStartPoint = NULL;
		pEndPoint = NULL;

		pSplit = NULL;
		nParsedLen = 0;
	}
	/**
	 * ��������
	 * @param {char*} buf ����
	 * @param {const uint} buf_len ���ݳ���
	 * @param [OUT] [IN] {uint*} last_offset �ϴ�ƫ������ַ
	 */
	inline void load(char* buf,const unsigned int buf_len,OUT IN unsigned int* last_offset){
		szBuf = buf;
		nBufLen = buf_len;
		pLastOffset = last_offset;
	}
	/**
	 * ��������
	 * @return {int} �������
	 */
	int parse();
	/**
	 * ��ȡ���ݰ�
	 * @return {const char*} ���ݰ�
	 */
	inline const char* getPackage(){
		return pStartPoint;
	}
	/**
	 * ��ս�������
	 */
	void clear();
private:
	char* szBuf; 					// ����
	unsigned int nBufLen; 			// ����
	unsigned int* pLastOffset; 		// ƫ����

	bool bParseFinish;				// �������
	
	const char* pStartPoint;		// ��ǰ��ʼ����
	const char* pEndPoint;			// �ϴ����������λ��
	
	const char* pSplit;				// �¼��ָ���λ��
	unsigned int nParsedLen;		// �ѽ������ĳ���
};

#endif
