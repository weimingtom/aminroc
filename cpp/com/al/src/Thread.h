#ifndef THREAD_H
#define THREAD_H

// platform macro
#if defined(WIN32)
	#include <winsock2.h>
	#include <process.h>
	typedef unsigned int ThreadId;
	typedef unsigned int (__stdcall *ThreadFunc)(void *param);
	#define DECLARE_THREAD_FUNC(name) unsigned int __stdcall name(void *param)
	#define _CREATE_THREAD_FUNC CloseHandle((HANDLE)_beginthreadex(NULL,0,func_ptr,param,0,&nID)) == TRUE ? true : false;
#else
	#include <pthread.h>
	typedef pthread_t ThreadId;
	typedef void*(*ThreadFunc)(void *param);
	#define DECLARE_THREAD_FUNC(name) void* name(void *param)
	#define _CREATE_THREAD_FUNC (pthread_create(&nID,NULL,func_ptr,param) == 0 ? true : false)
#endif

// inner includes
#include "Macro.h"

/// thread
class Thread
{
public:
	/**
	 * create thread
	 */
	bool create(ThreadFunc func_ptr,void* param = NULL){
		return _CREATE_THREAD_FUNC;
	}
	/**
	 * return thread's id
	 */
	inline ThreadId getId() const{
		return nID;
	}
private:
	ThreadId nID;
};

#endif
