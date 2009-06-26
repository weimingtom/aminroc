#ifndef POLICYLICENCE_H
#define POLICYLICENCE_H

// 外部引用
#include "../com/al/src/Net.h"
#include "../com/al/src/Thread.h"

/// 策略许可
class PolicyLicence
{
public:
	/**
	 * 初始化
	 * @param {const uint} port 策略端口
	 * @param {const char*} policy_file 策略文件
	 * @return {bool} 处理结果
	 */
	bool open(const char* policy_file,const unsigned int port);
	/** 
	 * 友元函数
	 */
	friend DECLARE_THREAD_FUNC(filter_work_thread);
private:
	unsigned int nPort;
	string strFile;
	Net netServer;
};

#endif
