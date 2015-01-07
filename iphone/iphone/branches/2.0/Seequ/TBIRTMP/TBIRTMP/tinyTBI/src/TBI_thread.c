 

/**@file TBI_thread.c
 * @brief Utility functions for threading.
 *

 *

 */
#include "TBI_thread.h"
#include "TBI_debug.h"
#include "TBI_memory.h"

#if TBI_UNDER_WINDOWS
#	include <windows.h>
#else
#	include <pthread.h>
#endif

#include <string.h>

/**@defgroup TBI_thread_group Utility functions for threading.
*/

/**@ingroup TBI_thread_group
*/
void TBI_thread_sleep(uint64_t ms)
{
#if TBI_UNDER_WINDOWS
	Sleep((DWORD)ms);
#else
	struct timespec interval; 

	interval.tv_sec = (long)(ms/1000); 
	interval.tv_nsec = (long)(ms%1000) * 1000000; 
	nanosleep(&interval, 0);
#endif	
}

/**@ingroup TBI_thread_group
* Creates a new thread.
* @param tid Handle id of the newly created thread. The returned handle should be destroyed using @ref TBI_thread_join()
* @param start The function to be run as the new thread's start routine 
* @param arg An address for the argument for the thread's start routine 
* @retval If successful, returns zero. Otherwise, an error number is returned to indicate the error
*/
int TBI_thread_create(void** tid, void *(*start) (void *), void *arg)
{
#if TBI_UNDER_WINDOWS
	DWORD ThreadId;
	*((HANDLE*)tid) = CreateThread(NULL, 0, (LPTHREAD_START_ROUTINE)start, arg, 0, &ThreadId);
	return *((HANDLE*)tid) ? 0 : -1;
#else
	*tid = TBI_calloc(1, sizeof(pthread_t));
	return pthread_create((pthread_t*)*tid, 0, start, arg);
#endif
}

/**@ingroup TBI_thread_group
 */
int TBI_thread_set_priority(void* tid, int32_t priority)
{
#if TBI_UNDER_WINDOWS
	// SetPriorityClass()
	TBI_DEBUG_ERROR("Not implemented");
	return -1;
#else
	struct sched_param sp;
	int ret;
	if(!tid){
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
    memset(&sp, 0, sizeof(struct sched_param));
    sp.sched_priority = priority;
    if ((ret = pthread_setschedparam(*((pthread_t*)tid), SCHED_RR, &sp))) {
        TBI_DEBUG_ERROR("Failed to change priority to %d with error code=%d", priority, ret);
        return ret;
    }
    return 0;
#endif
}

/**@ingroup TBI_thread_group
 */
int TBI_thread_set_priority_2(int32_t priority)
{
#if TBI_UNDER_WINDOWS
	TBI_DEBUG_ERROR("Not implemented");
	return -1;
#else
	pthread_t thread = pthread_self();
	return TBI_thread_set_priority(&thread, priority);
#endif
}

/**@ingroup TBI_thread_group
* Join a thread.
* @param tid Pthread handle to the target thread.
* @retval If successful, returns zero. Otherwise, an error number is returned to indicate the error. 
*/
int TBI_thread_join(void** tid)
{
	int ret;

	if(!tid){
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	if(!*tid){
		TBI_DEBUG_WARN("Cannot join NULL tid");
		return 0;
	}
    
#if TBI_UNDER_WINDOWS
	ret = (WaitForSingleObject(*((HANDLE*)tid), INFINITE) == WAIT_FAILED) ? -1 : 0;
	if(ret == 0){
		CloseHandle(*((HANDLE*)tid));
		*tid = TBI_null;
	}
#else
	if((ret = pthread_join(*((pthread_t*)*tid), 0)) == 0){
		TBI_free(tid);
	}
#endif

	return ret;
}

