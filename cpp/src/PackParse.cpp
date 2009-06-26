#include "PackParse.h"

int PackParse::parse()
{
	/*
	 * 解决问题:小包(处理),整包(处理),大包(断开)
	 * 接收字节不等于缓冲区大小
	 * 接收长度:缓冲区首地址 + 加接收的包 + 上次的包
	 */

	// 设置解析的首地址
	if(pEndPoint == NULL){
		pStartPoint = szBuf;
	}
	else{
		pStartPoint = pEndPoint + 1;
	}

	if(*pLastOffset){
		PRINTLN("上接完成数据:" << pStartPoint);
	}

	// 解析完成
	if(pStartPoint >= szBuf + nBufLen + *pLastOffset){
		goto _FINISH;
	}

	// 搜索包结束符
	pEndPoint = strchr(pStartPoint,C_ED_);

	if(pEndPoint != NULL && pEndPoint < szBuf + nBufLen + *pLastOffset){
		goto _SUCCESS;
	}

	goto _WAIT;

// 成功
_SUCCESS:
	bParseFinish = true;
	return 1;

// 解析完成
_FINISH:
	bParseFinish = true;
	return 2;
	
// 等待下一次数据
_WAIT:
	PRINTLN("未接收完成数据:" << pEndPoint);
	bParseFinish = false;
	// 未处理的字节长度
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
	// 解析完成
	if(bParseFinish == true)
	{
		// 清掉已解析内容
		memset(szBuf,0,nParsedLen);
		// 重置变量
		*pLastOffset = 0;
	}
	else
	{
		// 将未解析的一段拷贝到前头
		memcpy(szBuf,pStartPoint,*pLastOffset);
		// 清掉已解析内容
		memset(szBuf + *pLastOffset,0,NET_MAX_RECV_SIZE - *pLastOffset);
	}
}
