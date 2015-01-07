 

/**@file tsk_thread.c
 * @brief Utility functions for threading.
 *

 *

 */
#include "tsk_thread.h"
#include "tsk_debug.h"
#include "tsk_memory.h"

#if TSK_UNDER_WINDOWS
#	include <windows.h>
#else
#	include <pthread.h>
#endif

#include <string.h>

/**@defgroup tsk_thread_group Utility functions for threading.
*/

/**@ingroup tsk_thread_group
*/
void tsk_thread_sleep(uint64_t ms)
{
#if TSK_UNDER_WINDOWS
	Sleep((DWORD)ms);
#else
	struct timespec interval; 

	interval.tv_sec = (long)(ms/1000); 
	interval.tv_nsec = (long)(ms%1000) * 1000000; 
	nanosleep(&interval, 0);
#endif	
}

/**@ingroup tsk_thread_group
* Creates a new thread.
* @param tid Handle id of the newly created thread. The returned handle should be destroyed using @ref tsk_thread_join()
* @param start The function to be run as the new thread's start routine 
* @param arg An address for the argument for the thread's start routine 
* @retval If successful, returns zero. Otherwise, an error number is returned to indicate the error
*/
int tsk_thread_create(void** tid, void *(*start) (void *), void *arg)
{
#if TSK_UNDER_WINDOWS
	DWORD ThreadId;
	*((HANDLE*)tid) = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)start, arg, 0, &ThreadId);
	return *((HANDLE*)tid) ? 0 : -1;
#else
	*tid = tsk_calloc(1, sizeof(pthread_t));
	return pthread_create((pthread_t*)*tid, 0, start, arg);
#endif
}

/**@ingroup tsk_thread_group
 */
int tsk_thread_set_priority(void* tid, int32_t priority)
{
#if TSK_UNDER_WINDOWS
	// SetPriorityClass()
	TSK_DEBUG_ERROR("Not implemented");
	return -1;
#else
	struct sched_param sp;
	int ret;
	if(!tid){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
    memset(&sp, 0, sizeof(struct sched_param));
    sp.sched_priority = priority;
    if ((ret = pthread_setschedparam(*((pthread_t*)tid), SCHED_RR, &sp))) {
        TSK_DEBUG_ERROR("Failed to change priority to %d with error code=%d", priority, ret);
        return ret;
    }
    return 0;
#endif
}

/**@ingroup tsk_thread_group
 */
int tsk_thread_set_priority_2(int32_t priority)
{
#if TSK_UNDER_WINDOWS
	TSK_DEBUG_ERROR("Not implemented");
	return -1;
#else
	pthread_t thread = pthread_self();
	return tsk_thread_set_priority(&thread, priority);
#endif
}

/**@ingroup tsk_thread_group
* Join a thread.
* @param tid Pthread handle to the target thread.
* @retval If successful, returns zero. Otherwise, an error number is returned to indicate the error. 
*/
int tsk_thread_join(void** tid)
{
	int ret;

	if(!tid){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	if(!*tid){
		TSK_DEBUG_WARN("Cannot join NULL tid");
		return 0;
	}
    
#if TSK_UNDER_WINDOWS
	ret = (WaitForSingleObject(*((HANDLE*)tid), INFINITE) == WAIT_FAILED) ? -1 : 0;
	if(ret == 0){
		CloseHandle(*((HANDLE*)tid));
		*tid = tsk_null;
	}
#else
	if((ret = pthread_join(*((pthread_t*)*tid), 0)) == 0){
		tsk_free(tid);
	}
#endif

	return ret;
}

