 

/**@file TBI_condwait.c
 * @brief Pthread/Windows functions for waiting an signaling on condition variables.
 *

 *

 */

#include "TBI_condwait.h"
#include "TBI_memory.h"
#include "TBI_debug.h"
#include "TBI_time.h"
#include <time.h>

#if TBI_UNDER_WINDOWS
#	include <windows.h>
#	include "TBI_errno.h"
#	define CONDWAIT_S void
	typedef HANDLE	CONDWAIT_T;
#	define TIMED_OUT	WAIT_TIMEOUT
#else
#	include <sys/time.h>
#	include <pthread.h>
#	define CONDWAIT_S pthread_cond_t
	typedef CONDWAIT_S* CONDWAIT_T;
#	define TIMED_OUT	ETIMEDOUT
#endif

#if defined(__GNUC__) || defined (__SYMBIAN32__)
#	include <errno.h>
#endif

/**@defgroup TBI_condwait_group Pthread/Windows functions for waiting and signaling on condition variables (conwait).
* @code
* TBI_condwait_handle_t *condwait = TBI_condwait_create();
* @endcode
*
* In thread-1:
* @code
* // Bock the current thread until the condition is opened or until 1000ms have passed.
* int ret = TBI_condwait_timedwait(condwait, 1000);
* @endcode
*
* In thread-2:
* @code
* // Wakes up
* int ret = TBI_condwait_signal(condwait);
* // or TBI_condwait_broadcast(condwait)
* @endcode
*
* To free the condwait object:
* @code
* TBI_condwait_destroy(&condwait);
* @endcode
*/

/**@ingroup TBI_condwait_group
* Represents both PThread an Windows condwait object.
*/
typedef struct TBI_condwait_s
{
	CONDWAIT_T pcond; /**< Pthread handle pointing to the internal condwait object. */
#if !TBI_UNDER_WINDOWS
	TBI_mutex_handle_t* mutex;  /**< Locker. */
#endif
}
TBI_condwait_t;

/**@ingroup TBI_condwait_group
* Creates new conwait handle. You MUST call @ref TBI_condwait_destroy to free the handle.
* @retval New condwait handle.
* @sa @ref TBI_condwait_destroy.
*/
TBI_condwait_handle_t* TBI_condwait_create()
{
	TBI_condwait_t *condwait = TBI_calloc(1, sizeof(TBI_condwait_t));

	if(condwait)
	{
#if TBI_UNDER_WINDOWS
		condwait->pcond = CreateEvent(NULL, TRUE, FALSE, NULL);
		if(!condwait->pcond)
		{
			TBI_FREE(condwait);
		}
#else
		condwait->pcond = (CONDWAIT_T)TBI_calloc(1, sizeof(CONDWAIT_S));
		if(pthread_cond_init(condwait->pcond, 0))
		{
			TBI_DEBUG_ERROR("Failed to initialize the new conwait.");
		}

		if(!(condwait->mutex = TBI_mutex_create()))
		{
			pthread_cond_destroy(condwait->pcond);

			TBI_FREE(condwait);
			TBI_DEBUG_ERROR("Failed to initialize the internal mutex.");
		}
#endif
	}

	if(!condwait)
	{
		TBI_DEBUG_ERROR("Failed to create new conwait.");
	}
	return condwait;
}

/**@ingroup TBI_condwait_group
* Block the current thread until the condition is opened. 
* @param handle CondWait handle created using @ref TBI_condwait_create.
* @retval Zero if succeed and non-zero otherwise.
* @sa @ref TBI_condwait_timedwait.
*/
int TBI_condwait_wait(TBI_condwait_handle_t* handle)
{
	int ret = EINVAL;
	TBI_condwait_t *condwait = (TBI_condwait_t*)handle;

#if TBI_UNDER_WINDOWS
	if((ret = (WaitForSingleObject(condwait->pcond, INFINITE) == WAIT_FAILED) ? -1 : 0)){
		TBI_DEBUG_ERROR("WaitForSingleObject function failed: %d", ret);
	}
#else
	if(condwait && condwait->mutex){
		TBI_mutex_lock(condwait->mutex);
		if((ret = pthread_cond_wait(condwait->pcond, (pthread_mutex_t*)condwait->mutex)))
		{
			TBI_DEBUG_ERROR("pthread_cond_wait function failed: %d", ret);
		}
		TBI_mutex_unlock(condwait->mutex);
	}
#endif
	return ret;
}

/**@ingroup TBI_condwait_group
* Block the current thread until the condition is opened or until @a ms milliseconds have passed. 
* @param handle condwait handle created using @ref TBI_condwait_create.
* @param ms The number of milliseconds to wait for a given condition.
* @retval Zero if succeed and non-zero error code otherwise.
* @sa @ref TBI_condwait_wait.
*/
int TBI_condwait_timedwait(TBI_condwait_handle_t* handle, uint64_t ms)
{
#if TBI_UNDER_WINDOWS
	DWORD ret = WAIT_FAILED;
#else
	int ret = EINVAL;
#endif
	TBI_condwait_t *condwait = (TBI_condwait_t*)handle;

#if TBI_UNDER_WINDOWS
	if((ret = WaitForSingleObject(condwait->pcond, (DWORD)ms)) != WAIT_OBJECT_0){
		if(ret == TIMED_OUT){
			/* TBI_DEBUG_INFO("WaitForSingleObject function timedout: %d", ret); */
		}
		else{
			TBI_DEBUG_ERROR("WaitForSingleObject function failed: %d", ret);
		}
		return ((ret == TIMED_OUT) ? 0 : ret);
	}
#else
	if(condwait && condwait->mutex){
		struct timespec   ts = {0, 0};
		struct timeval    tv = {0, 0};
		/*int rc =*/  TBI_gettimeofday(&tv, 0);

		ts.tv_sec  = ( tv.tv_sec + ((long)ms/1000) );
		ts.tv_nsec += ( (tv.tv_usec * 1000) + ((long)ms % 1000 * 1000000) );
		if(ts.tv_nsec > 999999999) ts.tv_sec+=1, ts.tv_nsec = ts.tv_nsec % 1000000000;
		
		TBI_mutex_lock(condwait->mutex);
		if((ret = pthread_cond_timedwait(condwait->pcond, (pthread_mutex_t*)condwait->mutex, &ts))){
			if(ret == TIMED_OUT){
				/* TBI_DEBUG_INFO("pthread_cond_timedwait function timedout: %d", ret); */
			}
			else{
				TBI_DEBUG_ERROR("pthread_cond_timedwait function failed: %d", ret);
			}
		}

		TBI_mutex_unlock(condwait->mutex);

		return ((ret == TIMED_OUT) ? 0 : ret);
	}
#endif

	return ret;
}

/**@ingroup TBI_condwait_group
* Wakes up at least one thread that is currently waiting.
* @param handle CondWait handle created using @ref TBI_condwait_create.
* @retval Zero if succeed and non-zero otherwise.
* @sa @ref TBI_condwait_broadcast.
*/
int TBI_condwait_signal(TBI_condwait_handle_t* handle)
{
	int ret = EINVAL;
	TBI_condwait_t *condwait = (TBI_condwait_t*)handle;

#if TBI_UNDER_WINDOWS
	if(ret = ((SetEvent(condwait->pcond) && ResetEvent(condwait->pcond)) ? 0 : -1)){
		ret = GetLastError();
		TBI_DEBUG_ERROR("SetEvent/ResetEvent function failed: %d", ret);
	}
#else
	if(condwait && condwait->mutex){
		TBI_mutex_lock(condwait->mutex);

		if((ret = pthread_cond_signal(condwait->pcond))){
			TBI_DEBUG_ERROR("pthread_cond_signal function failed: %d", ret);
		}
		TBI_mutex_unlock(condwait->mutex);
	}
#endif
	return ret;
}


/**@ingroup TBI_condwait_group
* Wakes up all threads that are currently waiting for the condition.
* @param handle CondWait handle created using @ref TBI_condwait_create.
* @retval Zero if succeed and non-zero otherwise.
* @sa @ref TBI_condwait_signal.
*/
int TBI_condwait_broadcast(TBI_condwait_handle_t* handle)
{
	int ret = EINVAL;
	TBI_condwait_t *condwait = (TBI_condwait_t*)handle;

#if TBI_UNDER_WINDOWS
	if(ret = ((SetEvent(condwait->pcond) && ResetEvent(condwait->pcond)) ? 0 : -1)){
		ret = GetLastError();
		TBI_DEBUG_ERROR("SetEvent function failed: %d", ret);
	}
#else
	if(condwait && condwait->mutex){
		TBI_mutex_lock(condwait->mutex);
		if((ret = pthread_cond_broadcast(condwait->pcond))){
			TBI_DEBUG_ERROR("pthread_cond_broadcast function failed: %d", ret);
		}
		TBI_mutex_unlock(condwait->mutex);
	}
#endif

	return ret;
}

/**@ingroup TBI_condwait_group
* Safely free a condwait variable previously created using @ref TBI_condwait_create.
* @param handle The condwait handle to free.
* @sa @ref TBI_condwait_create
*/
void TBI_condwait_destroy(TBI_condwait_handle_t** handle)
{
	TBI_condwait_t **condwait = (TBI_condwait_t**)handle;
	
	if(condwait && *condwait){
#if TBI_UNDER_WINDOWS
		CloseHandle((*condwait)->pcond);
#else
		TBI_mutex_destroy(&((*condwait)->mutex));
		pthread_cond_destroy((*condwait)->pcond);
		TBI_FREE((*condwait)->pcond);
#endif
		TBI_free((void**)condwait);
	}
	else{
		TBI_DEBUG_WARN("Cannot free an uninitialized condwait object");
	}
}

