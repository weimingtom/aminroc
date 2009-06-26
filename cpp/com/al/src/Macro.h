#ifndef MACRO_H
#define MACRO_H

// C��׼������
#include <string.h>
#include <stdlib.h>

// C++��׼������
#include <iostream>
#include <fstream>
#include <sstream>
#include <string>
#include <memory>
#include <vector>
#include <map>
#include <stack>
#include <list>
#include <queue>

// �����ռ�����
using std::cin;
using std::cout;
using std::endl;
using std::ifstream;
using std::ofstream;
using std::istringstream;
using std::ostringstream;
using std::ios;
using std::string;
using std::vector;
using std::map;
using std::stack;
using std::list;
using std::queue;

// �궨��
//-----------------------------------------------
/** �����־ */
#ifndef OUT
#define OUT
#endif

/** �����־ */
#ifndef IN
#define IN
#endif

/** ���һ������������̨*/
#define PRINT(word)				cout<<word
/** ���һ������������̨ */
#define PRINTLN(word)			cout<<word<<endl

/** ���һ����ʼ����Ϣ */
#define PRINT_INIT(word)		PRINTLN("+ "<<word)
/** ���һ����Ŀ��Ϣ */
#define PRINT_ITEM(word,var)	PRINTLN("|- "<<word<<":"<<var)
/** ���һ��ϵͳ��Ϣ */
#define PRINT_SYS_INFO(word)	PRINTLN(">> "<<word)
/** ���һ����ͨ��Ϣ */
#define PRINT_INFO(word)		PRINTLN(">> "<<word)
/** ���һ���ɹ���Ϣ */
#define PRINT_OK(word)			PRINTLN("|= "<<word)
/** ���һ������ */
#define PRINT_ERROR(word)		PRINTLN("!= "<<word)
/** ���һ��������Ϣ */
#define DEBUG_INFO(word)		PRINTLN(" >$ "<<word)

/** ��ʼ���ɹ� */
#define INIT_OK					PRINT_OK("okay"<<endl);
/** ��ʼ��ʧ�� */
#define INIT_FAIL				PRINT_ERROR("Fail");cin.get();return false;

/** �����ʼ�� */
#define LOAD_LIB(word,expression,flag) PRINT_INIT(word);if(expression!=flag){INIT_FAIL}INIT_OK

#endif
