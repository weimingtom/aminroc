#ifndef DATAPARSE_H
#define DATAPARSE_H

// 内部引用
#include "../def/ANet.h"

/// 数据解析
class PackParse
{
public:
	/**
	 * 重置
	 */
	inline void reset(){
		pStartPoint = NULL;
		pEndPoint = NULL;

		pSplit = NULL;
		nParsedLen = 0;
	}
	/**
	 * 加载数据
	 * @param {char*} buf 数据
	 * @param {const uint} buf_len 数据长度
	 * @param [OUT] [IN] {uint*} last_offset 上次偏移量地址
	 */
	inline void load(char* buf,const unsigned int buf_len,OUT IN unsigned int* last_offset){
		szBuf = buf;
		nBufLen = buf_len;
		pLastOffset = last_offset;
	}
	/**
	 * 解析数据
	 * @return {int} 解析结果
	 */
	int parse();
	/**
	 * 获取数据包
	 * @return {const char*} 数据包
	 */
	inline const char* getPackage(){
		return pStartPoint;
	}
	/**
	 * 清空解析数据
	 */
	void clear();
private:
	char* szBuf; 					// 数据
	unsigned int nBufLen; 			// 长度
	unsigned int* pLastOffset; 		// 偏移量

	bool bParseFinish;				// 解析完成
	
	const char* pStartPoint;		// 当前开始搜索
	const char* pEndPoint;			// 上次搜索的最后位置
	
	const char* pSplit;				// 事件分隔符位置
	unsigned int nParsedLen;		// 已解析过的长度
};

#endif
