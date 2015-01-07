
#include "TBI_debug.h"
#include <string.h>

/**@defgroup TBI_debug_group Utility functions for debugging purpose.
 */

#if TBI_HAVE_DEBUG_H
// Nothing to do --> all is up to the end-user application
#else
char LogFileName[256];
//char System_Versio[256];
FILE *log_file;

unsigned int paket_rec_time = 0;
int paket_number;

const void* TBI_debug_arg_data = TBI_null;
TBI_debug_f TBI_debug_info_cb = TBI_null;
TBI_debug_f TBI_debug_warn_cb = TBI_null;
TBI_debug_f TBI_debug_error_cb = TBI_null;
TBI_debug_f TBI_debug_fatal_cb = TBI_null;

void TBI_debug_set_arg_data(const void* arg_data){
	TBI_debug_arg_data = arg_data;
}
void TBI_debug_set_Log_File_Name(const char *filename){
    strcpy(LogFileName, filename);
    log_file = fopen(LogFileName, "wt");
}
const char* TBI_debug_get_Log_File_Name(){
	return LogFileName;
}

const void* TBI_debug_get_arg_data(){
	return TBI_debug_arg_data;
}
void TBI_debug_set_info_cb(TBI_debug_f cb){
	TBI_debug_info_cb = cb;
}
TBI_debug_f TBI_debug_get_info_cb(){
	return TBI_debug_info_cb;
}
void TBI_debug_set_warn_cb(TBI_debug_f cb){
	TBI_debug_warn_cb = cb;
}
TBI_debug_f TBI_debug_get_warn_cb(){
	return TBI_debug_warn_cb;
}
void TBI_debug_set_error_cb(TBI_debug_f cb){
	TBI_debug_error_cb = cb;
}
TBI_debug_f TBI_debug_get_error_cb(){
	return TBI_debug_error_cb;
}
void TBI_debug_set_fatal_cb(TBI_debug_f cb){
	TBI_debug_fatal_cb = cb;
}

TBI_debug_f TBI_debug_get_fatal_cb(){
	return TBI_debug_fatal_cb;
}

void TBI_debug_set_system_version(const char *sys_ver) {
    strcpy(System_Versio, sys_ver);
    TBI_DEBUG_INFO("System_Versio === %s", System_Versio);
}

#endif /* TBI_HAVE_DEBUG_H */
