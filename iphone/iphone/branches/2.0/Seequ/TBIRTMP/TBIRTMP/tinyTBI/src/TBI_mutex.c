 

/**@file TBI_mutex.c
 * @brief Pthread/Windows Mutex utility functions.
 *

 *

 */
#include "TBI_mutex.h"
#include "TBI_memory.h"
#include "TBI_debug.h"

#if TBI_UNDER_WINDOWS
#	include <windows.h>
#	include "TBI_errno.h"
	typedef HANDLE	MUTEX_T;
#	define MUTEX_S void
#	define TBI_ERROR_NOT_OWNER ERROR_NOT_OWNER
#else
#	include <pthread.h>
#	define MUTEX_S pthread_mutex_t
	typedef MUTEX_S* MUTEX_T;
#	define TBI_ERROR_NOT_OWNER EPERM
#endif

#if defined(__GNUC__) || defined(__SYMBIAN32__)
#	include <errno.h>
#endif

// FIXME: Momory leaks in mutex

/**@defgroup TBI_mutex_group Pthread/Windows Mutex utility functions.
*/

/**@ingroup TBI_mutex_group
* Creates new recursive mutex handle.
* @retval New mutex handle. It is up to you free the returned handle using  @ref TBI_mutex_destroy.
* @sa @ref TBI_mutex_destroy() @ref TBI_mutex_create_2()
*/
TBI_mutex_handle_t* TBI_mutex_create()
{	
	return TBI_mutex_create_2(TBI_true);
}

/**@ingroup TBI_mutex_group
 * Creates new recursive mutex handle.
 * @param recursive whether we want a recursive mutex or not
 * @retval New mutex handle. It is up to you free the returned handle using  @ref TBI_mutex_destroy.
 * @sa @ref TBI_mutex_destroy.
 */
TBI_mutex_handle_t* TBI_mutex_create_2(TBI_bool_t recursive)
{
	MUTEX_T handle = TBI_null;
	
#if TBI_UNDER_WINDOWS
	handle = CreateMutex(NULL, FALSE, NULL);
#else
	int ret;
	pthread_mutexattr_t   mta;
	
	if((ret = pthread_mutexattr_init(&mta))){
		TBI_DEBUG_ERROR("pthread_mutexattr_init failed with error code %d", ret);
		return TBI_null;
	}
	if(recursive && (ret = pthread_mutexattr_settype(&mta, PTHREAD_MUTEX_RECURSIVE))){
		TBI_DEBUG_ERROR("pthread_mutexattr_settype failed with error code %d", ret);
		pthread_mutexattr_destroy(&mta);
		return TBI_null;
	}
	
	/* if we are here: all is ok */
	handle = TBI_calloc(1, sizeof(MUTEX_S));
	if(pthread_mutex_init((MUTEX_T)handle, &mta)){
		TBI_FREE(handle);
	}
	pthread_mutexattr_destroy(&mta);
#endif
	
	if(!handle){
		TBI_DEBUG_ERROR("Failed to create new mutex.");
	}
	return handle;
}

/**@ingroup TBI_mutex_group
* Lock a mutex. You must use @ref TBI_mutex_unlock to unlock the mutex.
* @param handle The handle of the mutex to lock.
* @retval Zero if succeed and non-zero error code otherwise.
* @sa @ref TBI_mutex_unlock.
*/
int TBI_mutex_lock(TBI_mutex_handle_t* handle)
{
	int ret = EINVAL;
	if(handle)
	{
#if TBI_UNDER_WINDOWS
		if((ret = WaitForSingleObject((MUTEX_T)handle , INFINITE)) == WAIT_FAILED)
#else
		if((ret = pthread_mutex_lock((MUTEX_T)handle)))
#endif
		{
			TBI_DEBUG_ERROR("Failed to lock the mutex: %d", ret);
		}
	}
	return ret;
}

/**@ingroup TBI_mutex_group
* Unlock a mutex previously locked using @ref TBI_mutex_lock.
* @param handle The handle of the mutex to unlock.
* @retval Zero if succeed and non-zero otherwise.
* @sa @ref TBI_mutex_lock.
*/
int TBI_mutex_unlock(TBI_mutex_handle_t* handle)
{
	int ret = EINVAL;
	if(handle)
	{
#if TBI_UNDER_WINDOWS
		if((ret = ReleaseMutex((MUTEX_T)handle) ? 0 : -1)){
			ret = GetLastError();
#else
		if((ret = pthread_mutex_unlock((MUTEX_T)handle)))
		{
#endif
			if(ret == TBI_ERROR_NOT_OWNER){
				TBI_DEBUG_WARN("The calling thread does not own the mutex: %d", ret);
			}
			else{
				TBI_DEBUG_ERROR("Failed to unlock the mutex: %d", ret);
			}
		}
	}
	return ret;
}

/**@ingroup TBI_mutex_group
* Free/destroy a mutex.
* @param handle The mutex to free.
* @sa @ref TBI_mutex_create.
*/
void TBI_mutex_destroy(TBI_mutex_handle_t** handle)
{
	if(handle && *handle){
#if TBI_UNDER_WINDOWS
		CloseHandle((MUTEX_T)*handle);
		*handle = 0;
#else
		pthread_mutex_destroy((MUTEX_T)*handle);
		TBI_free(handle);
#endif
	}
	else{
		TBI_DEBUG_WARN("Cannot free an uninitialized mutex");
	}
}

