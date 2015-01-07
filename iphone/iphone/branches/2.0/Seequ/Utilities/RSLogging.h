// Debud level options
#define RS_COMPILE_TIME_LOG_DEBUG_ADV   0
#define RS_COMPILE_TIME_LOG_DEBUG_UI    0
#define RS_COMPILE_TIME_LOG_DEBUG_SQL   0
#define RS_COMPILE_TIME_LOG_DEBUG_LOOPS 0
#define RS_COMPILE_TIME_LOG_DEBUG_HTTP  0
#define RS_COMPILE_TIME_LOG_DEBUG_RTMP  0
#define RS_COMPILE_TIME_LOG_DEBUG_RTMP_XMPP  0

#define RS_COMPILE_TIME_LOG_DEBUG_TOFILE 0

// If you want manually specify the log level, do it bellow
//#define RS_COMPILE_TIME_LOG_LEVEL ASL_LEVEL_NOTICE

/*
 RSLogging. Simple wrapper macros/functions around ASL (Apple System
 Log)

 We support a compile-time log level through
 RS_COMPILE_TIME_LOG_LEVEL. This will turn the associated log calls
 into NOPs.

 The log levels are the constants defined in asl.h:

 #define ASL_LEVEL_EMERG   0
 #define ASL_LEVEL_ALERT   1
 #define ASL_LEVEL_CRIT    2
 #define ASL_LEVEL_ERR     3
 #define ASL_LEVEL_WARNING 4
 #define ASL_LEVEL_NOTICE  5
 #define ASL_LEVEL_INFO    6
 #define ASL_LEVEL_DEBUG   7

 For a description of when to use each level, see here:

 http://developer.apple.com/library/mac/#documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/LoggingErrorsAndWarnings.html#//apple_ref/doc/uid/10000172i-SW8-SW1

 Emergency (level 0) - The highest priority, usually reserved for
                       catastrophic failures and reboot notices.

 Alert (level 1)     - A serious failure in a key system.

 Critical (level 2)  - A failure in a key system.

 Error (level 3)     - Something has failed.

 Warning (level 4)   - Something is amiss and might fail if not
                       corrected.

 Notice (level 5)    - Things of moderate interest to the user or
                       administrator.

 Info (level 6)      - The lowest priority that you would normally log, and
                       purely informational in nature.

 Debug (level 7)     - The lowest priority, and normally not logged except
                       for messages from the kernel.


 Note that by default the iOS syslog/console will only record items up
 to level ASL_LEVEL_NOTICE.

 */

/** @todo

 We want better multithread support. Default NULL client uses
 locking. Perhaps we can check for [NSThread mainThread] and associate
 an asl client object to that thread. Then we can specify
 ASL_OPT_STDERR and not need an extra call to add stderr.

 */

#import <Foundation/Foundation.h>

// By default, in non-debug mode we want to disable any logging
// statements except NOTICE and above.
#ifndef RS_COMPILE_TIME_LOG_LEVEL
	#ifdef RSDEBUG
//        #define RS_COMPILE_TIME_LOG_LEVEL ASL_LEVEL_DEBUG
        #define RS_COMPILE_TIME_LOG_LEVEL ASL_LEVEL_NOTICE
	#else
        #define RS_COMPILE_TIME_LOG_LEVEL ASL_LEVEL_NOTICE
	#endif
#endif

#include <asl.h>

#if RS_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_EMERG
//    #define RSLogEmergency(...)
    void RSLogEmergency(NSString *format, ...);
#else
    #define RSLogEmergency(...)
#endif

#if RS_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_ALERT
    void RSLogAlert(NSString *format, ...);
#else
    #define RSLogAlert(...)
#endif

#if RS_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_CRIT
    void RSLogCritical(NSString *format, ...);
#else
    #define RSLogCritical(...)
#endif

#if RS_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_ERR
    void RSLogError(NSString *format, ...);
#else
    #define RSLogError(...)
#endif

#if RS_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_WARNING
    void RSLogWarning(NSString *format, ...);
#else
    #define RSLogWarning(...)
#endif

#if RS_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_NOTICE
    void RSLogNotice(NSString *format, ...);
#else
    #define RSLogNotice(...)
#endif

#if RS_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_INFO
    void RSLogInfo(NSString *format, ...);
#else
    #define RSLogInfo(...)
#endif

#if RS_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_DEBUG
    void RSLog(NSString *format, ...);
    #if RS_COMPILE_TIME_LOG_DEBUG_ADV
        void RSLogADV(NSString *format, ...);
    #else
        #define RSLogADV(...)
    #endif
    #if RS_COMPILE_TIME_LOG_DEBUG_UI
        void RSLogUI(NSString *format, ...);
    #else
        #define RSLogUI(...)
    #endif
    #if RS_COMPILE_TIME_LOG_DEBUG_SQL
        void RSLogSQL(NSString *format, ...);
    #else
        #define RSLogSQL(...)
    #endif
    #if RS_COMPILE_TIME_LOG_DEBUG_LOOPS
        void RSLogLOOPS(NSString *format, ...);
    #else
        #define RSLogLOOPS(...)
    #endif
    #if RS_COMPILE_TIME_LOG_DEBUG_HTTP
        void RSLogHTTP(NSString *format, ...);
    #else
        #define RSLogHTTP(...)
    #endif
    #if RS_COMPILE_TIME_LOG_DEBUG_RTMP
        void RSLogRTMP(NSString *format, ...);
    #else
        #define RSLogRTMP(...)
    #endif
    #if RS_COMPILE_TIME_LOG_DEBUG_RTMP_XMPP
        void RSLogRTMP_XMPP(NSString *format, ...);
    #else
        #define RSLogRTMP_XMPP(...)
    #endif
    #if RS_COMPILE_TIME_LOG_DEBUG_TOFILE
        void write_to_log_file( NSString* text);
    #else
        #define write_to_log_file(...)
    #endif
#else
    #define RSLog(...)
    #define RSLogADV(...)
    #define RSLogUI(...)
    #define RSLogSQL(...)
    #define RSLogLOOPS(...)
    #define RSLogHTTP(...)
    #define RSLogRTMP(...)
    #define RSLogRTMP_XMPP(...)
    #define write_to_log_file(...)
#endif

/* Write to file settings
 FILE* log_file;
 
 -(NSString*) getDocumentsFilePath:(NSString*)fileName {
     NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
     if(documentsDirectory) {
         documentsDirectory = [documentsDirectory stringByAppendingPathComponent:fileName];
     }
     
     return documentsDirectory;
 }
 
 if (DEBUG && DEBUG_TO_FILE) {
 NSString *filePath = [self getDocumentsFilePath:@"log.txt"];
 log_file = 0;
 if(!log_file)
 log_file =  fopen([filePath UTF8String], "w");
 }
 
 - (void) write_to_log_file:(NSString*)text {
     if(log_file) {
         text = [text stringByAppendingString:@"\n"];
 //        NSLog(@"text: %@",text);
         fwrite([text UTF8String], text.length, sizeof(char), log_file);
         fflush(log_file);
     }
 }
 
 if (DEBUG && DEBUG_TO_FILE) {
 [self write_to_log_file:@"startTraking 1 start"];
 }
 
 
 */
