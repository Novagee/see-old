
#include "tsk_debug.h"
#include <string.h>

/**@defgroup tsk_debug_group Utility functions for debugging purpose.
 */

#if TSK_HAVE_DEBUG_H
// Nothing to do --> all is up to the end-user application
#else
char LogFileName[256];
char System_Versio[256];
FILE *log_file;

unsigned int paket_rec_time = 0;
int paket_number;

const void* tsk_debug_arg_data = tsk_null;
tsk_debug_f tsk_debug_info_cb = tsk_null;
tsk_debug_f tsk_debug_warn_cb = tsk_null;
tsk_debug_f tsk_debug_error_cb = tsk_null;
tsk_debug_f tsk_debug_fatal_cb = tsk_null;

void tsk_debug_set_arg_data(const void* arg_data){
	tsk_debug_arg_data = arg_data;
}
void tsk_debug_set_Log_File_Name(const char *filename){
    strcpy(LogFileName, filename);
    log_file = fopen(LogFileName, "wt");
}
const char* tsk_debug_get_Log_File_Name(){
	return LogFileName;
}

const void* tsk_debug_get_arg_data(){
	return tsk_debug_arg_data;
}
void tsk_debug_set_info_cb(tsk_debug_f cb){
	tsk_debug_info_cb = cb;
}
tsk_debug_f tsk_debug_get_info_cb(){
	return tsk_debug_info_cb;
}
void tsk_debug_set_warn_cb(tsk_debug_f cb){
	tsk_debug_warn_cb = cb;
}
tsk_debug_f tsk_debug_get_warn_cb(){
	return tsk_debug_warn_cb;
}
void tsk_debug_set_error_cb(tsk_debug_f cb){
	tsk_debug_error_cb = cb;
}
tsk_debug_f tsk_debug_get_error_cb(){
	return tsk_debug_error_cb;
}
void tsk_debug_set_fatal_cb(tsk_debug_f cb){
	tsk_debug_fatal_cb = cb;
}

tsk_debug_f tsk_debug_get_fatal_cb(){
	return tsk_debug_fatal_cb;
}

void tsk_debug_set_system_version(const char *sys_ver) {
    strcpy(System_Versio, sys_ver);
    TSK_DEBUG_INFO("System_Versio === %s", System_Versio);
}

#endif /* TSK_HAVE_DEBUG_H */
