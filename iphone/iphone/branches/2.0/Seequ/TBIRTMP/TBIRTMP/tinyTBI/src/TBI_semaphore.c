 

/**@file TBI_semaphore.c
* @brief Pthread/Windows Semaphore utility functions.
*
*
*
* @date Created: Sat Nov 8 16:54:58 2009 mdiop
*/
#include "TBI_semaphore.h"
#include "TBI_memory.h"
#include "TBI_debug.h"
#include "TBI_string.h"

/* Apple claims that they fully support POSIX semaphore but ...
 */
#if defined(__APPLE__) /* Mac OSX/Darwin/Iphone/Ipod Touch */
#	define TBI_USE_NAMED_SEM	1
#else 
#	define TBI_USE_NAMED_SEM	0
#endif

#if TBI_UNDER_WINDOWS /* Windows XP/Vista/7/CE */

#	include <windows.h>
#	include "TBI_errno.h"
#	define SEMAPHORE_S void
	typedef HANDLE	SEMAPHORE_T;
//#else if define(__APPLE__) /* Mac OSX/Darwin/Iphone/Ipod Touch */
//#	include <march/semaphore.h>
//#	include <march/task.h>
#else /* All *nix */

#	include <pthread.h>
#	include <semaphore.h>
#	if TBI_USE_NAMED_SEM
#	include <fcntl.h> /* O_CREAT */
#	include <sys/stat.h> /* S_IRUSR, S_IWUSR*/

		static int sem_count = 0;
		typedef struct named_sem_s
		{
			sem_t* sem;
			char* name;
		} named_sem_t;
#		define SEMAPHORE_S named_sem_t
#		define GET_SEM(PSEM) (((named_sem_t*)(PSEM))->sem)
#	else
#		define SEMAPHORE_S sem_t
#		define GET_SEM(PSEM) ((PSEM))
#	endif /* TBI_USE_NAMED_SEM */
	typedef sem_t* SEMAPHORE_T;

#endif

#if defined(__GNUC__) || defined(__SYMBIAN32__)
#	include <errno.h>
#endif



/**@defgroup TBI_semaphore_group Pthread/Windows Semaphore functions.
*/

/**@ingroup TBI_semaphore_group
* Creates new semaphore handle.
* @retval A New semaphore handle.
* You MUST call @ref TBI_semaphore_destroy to free the semaphore.
* @sa @ref TBI_semaphore_destroy
*/
TBI_semaphore_handle_t* TBI_semaphore_create()
{
	SEMAPHORE_T handle = 0;
	
#if TBI_UNDER_WINDOWS
	handle = CreateSemaphore(NULL, 0, 0x7FFFFFFF, NULL);
#else
	handle = TBI_calloc(1, sizeof(SEMAPHORE_S));
	
#if TBI_USE_NAMED_SEM
	named_sem_t * nsem = (named_sem_t*)handle;
	TBI_sprintf(&(nsem->name), "/sem-%d", sem_count++);
    TBI_DEBUG_INFO(" nsem->name = %s",nsem->name);
    
	if((nsem->sem = sem_open(nsem->name, O_CREAT /*| O_EXCL*/, S_IRUSR | S_IWUSR, 0)) == SEM_FAILED)
	{
		TBI_FREE(nsem->name);
#else
	if(sem_init((SEMAPHORE_T)handle, 0, 0))
	{
#endif
		TBI_FREE(handle);
		TBI_DEBUG_ERROR("Failed to initialize the new semaphore (errno=%d).", errno);
	}
#endif
	
	if(!handle){
		TBI_DEBUG_ERROR("Failed to create new mutex.");
	}
	return handle;
}

/**@ingroup TBI_semaphore_group
* Increments a semaphore.
* @param handle The semaphore to increment.
* @retval Zero if succeed and otherwise the function returns -1 and sets errno to indicate the error.
* @sa @ref TBI_semaphore_decrement.
*/
int TBI_semaphore_increment(TBI_semaphore_handle_t* handle)
{
	int ret = EINVAL;
	if(handle)
	{
#if TBI_UNDER_WINDOWS
		if((ret = ReleaseSemaphore((SEMAPHORE_T)handle, 1L, 0L) ? 0 : -1))
#else
		if((ret = sem_post((SEMAPHORE_T)GET_SEM(handle))))
#endif
		{
			TBI_DEBUG_ERROR("sem_post function failed: %d", ret);
		}
	}
	return ret;
}

/**@ingroup TBI_semaphore_group
* Decrements a semaphore.
* @param handle The semaphore to decrement.
* @retval Zero if succeed and otherwise the function returns -1 and sets errno to indicate the error.
* @sa @ref TBI_semaphore_increment.
*/
int TBI_semaphore_decrement(TBI_semaphore_handle_t* handle)
{
	int ret = EINVAL;
	if(handle)
	{
#if TBI_UNDER_WINDOWS
		ret = (WaitForSingleObject((SEMAPHORE_T)handle, INFINITE) == WAIT_OBJECT_0 ? 0 : -1);
		if(ret)	TBI_DEBUG_ERROR("sem_wait function failed: %d", ret);
#else
		do 
		{ 
			ret = sem_wait((SEMAPHORE_T)GET_SEM(handle)); 
		} 
		while ( errno == EINTR );
		if(ret)	{ TBI_DEBUG_ERROR("sem_wait function failed: %d", errno); }
#endif
	}

	return ret;
}

/**@ingroup TBI_semaphore_group
* Destroy a semaphore previously created using @ref TBI_semaphore_create.
* @param handle The semaphore to free.
* @sa @ref TBI_semaphore_create
*/
void TBI_semaphore_destroy(TBI_semaphore_handle_t** handle)
{
	if(handle && *handle)
	{
#if TBI_UNDER_WINDOWS
		CloseHandle((SEMAPHORE_T)*handle);
		*handle = 0;
#else
#	if TBI_USE_NAMED_SEM
		named_sem_t * nsem = ((named_sem_t*)*handle);
		sem_close(nsem->sem);
		TBI_FREE(nsem->name);
#else
		sem_destroy((SEMAPHORE_T)GET_SEM(*handle));
#endif /* TBI_USE_NAMED_SEM */
	TBI_free(handle);
#endif
	}
	else{
		TBI_DEBUG_WARN("Cannot free an uninitialized semaphore object");
	}
}

