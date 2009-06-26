#ifndef EVENTTRIGGER_H
#define EVENTTRIGGER_H

// �ⲿ����
#include <time.h>
#include <sys/types.h>
#include <sys/timeb.h>
#include "../com/al/src/LuaClass.h"
// �ڲ�����
#include "../def/ANet.h"

/// �¼�������
class EventTrigger
{
public:
	/**
	 * ���ļ�
	 * @param {const char*} file �ű��ļ�
	 * @return {bool} ������
	 */
	bool open(const char* file);
	/**
	 * ����
	 * @param {const uint} eventType �¼�����
	 * @param {const char*} content �¼�����
	 * @param {ANet*} client �׽�����չ��
	 * @return {bool} ������
	 */
	bool touch(ANet& client,const char* package);
	/**
	 * �����ر��¼�
	 * @param {ANet*} client �׽�����չ��
	 */
	void touchCloseEvent(const ANet& client);
private:
	LuaClass lcScript;
};

#endif
