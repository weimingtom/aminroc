#ifndef EVENTTRIGGER_H
#define EVENTTRIGGER_H

// 外部引用
#include <time.h>
#include <sys/types.h>
#include <sys/timeb.h>
#include "../com/al/src/LuaClass.h"
// 内部引用
#include "../def/ANet.h"

/// 事件触发器
class EventTrigger
{
public:
	/**
	 * 打开文件
	 * @param {const char*} file 脚本文件
	 * @return {bool} 处理结果
	 */
	bool open(const char* file);
	/**
	 * 触发
	 * @param {const uint} eventType 事件类型
	 * @param {const char*} content 事件内容
	 * @param {ANet*} client 套接字扩展类
	 * @return {bool} 处理结果
	 */
	bool touch(ANet& client,const char* package);
	/**
	 * 触发关闭事件
	 * @param {ANet*} client 套接字扩展类
	 */
	void touchCloseEvent(const ANet& client);
private:
	LuaClass lcScript;
};

#endif
