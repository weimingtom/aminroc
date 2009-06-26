#ifndef MACRO_H
#define MACRO_H

// C标准库引用
#include <string.h>
#include <stdlib.h>

// C++标准库引用
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

// 域名空间引用
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

// 宏定义
//-----------------------------------------------
/** 输出标志 */
#ifndef OUT
#define OUT
#endif

/** 输入标志 */
#ifndef IN
#define IN
#endif

/** 输出一段文字至控制台*/
#define PRINT(word)				cout<<word
/** 输出一段文字至控制台 */
#define PRINTLN(word)			cout<<word<<endl

/** 输出一个初始化信息 */
#define PRINT_INIT(word)		PRINTLN("+ "<<word)
/** 输出一个条目信息 */
#define PRINT_ITEM(word,var)	PRINTLN("|- "<<word<<":"<<var)
/** 输出一条系统信息 */
#define PRINT_SYS_INFO(word)	PRINTLN(">> "<<word)
/** 输出一条普通信息 */
#define PRINT_INFO(word)		PRINTLN(">> "<<word)
/** 输出一个成功消息 */
#define PRINT_OK(word)			PRINTLN("|= "<<word)
/** 输出一个错误 */
#define PRINT_ERROR(word)		PRINTLN("!= "<<word)
/** 输出一条调试信息 */
#define DEBUG_INFO(word)		PRINTLN(" >$ "<<word)

/** 初始化成功 */
#define INIT_OK					PRINT_OK("okay"<<endl);
/** 初始化失败 */
#define INIT_FAIL				PRINT_ERROR("Fail");cin.get();return false;

/** 组件初始化 */
#define LOAD_LIB(word,expression,flag) PRINT_INIT(word);if(expression!=flag){INIT_FAIL}INIT_OK

#endif
