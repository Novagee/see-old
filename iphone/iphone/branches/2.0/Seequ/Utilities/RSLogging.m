
// We need all the log functions visible so we set this to DEBUG
#ifdef RS_COMPILE_TIME_LOG_LEVEL
#undef RS_COMPILE_TIME_LOG_LEVEL
//#define RS_COMPILE_TIME_LOG_LEVEL ASL_LEVEL_DEBUG
#endif

#import "RSLogging.h"

// JSC static FILE* log_file = 0;

static void AddStderrOnce()
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		asl_add_log_file(NULL, STDERR_FILENO);
	});
}

#define __RS_MAKE_LOG_FUNCTION(LEVEL, NAME) \
void NAME (NSString *format, ...) \
{ \
	AddStderrOnce(); \
	va_list args; \
	va_start(args, format); \
	NSString *message = [[NSString alloc] initWithFormat:format arguments:args]; \
	asl_log(NULL, NULL, (LEVEL), "%s", [message UTF8String]); \
	va_end(args); \
}

#if RS_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_EMERG
    __RS_MAKE_LOG_FUNCTION(ASL_LEVEL_EMERG, RSLogEmergency)
#endif
#if RS_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_ALERT
    __RS_MAKE_LOG_FUNCTION(ASL_LEVEL_ALERT, RSLogAlert)
#endif
#if RS_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_CRIT
    __RS_MAKE_LOG_FUNCTION(ASL_LEVEL_CRIT, RSLogCritical)
#endif
#if RS_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_ERR
    __RS_MAKE_LOG_FUNCTION(ASL_LEVEL_ERR, RSLogError)
#endif
#if RS_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_WARNING
    __RS_MAKE_LOG_FUNCTION(ASL_LEVEL_WARNING, RSLogWarning)
#endif
#if RS_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_NOTICE
    __RS_MAKE_LOG_FUNCTION(ASL_LEVEL_NOTICE, RSLogNotice)
#endif
#if RS_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_INFO
    __RS_MAKE_LOG_FUNCTION(ASL_LEVEL_INFO, RSLogInfo)
#endif

//__RS_MAKE_LOG_FUNCTION(ASL_LEVEL_DEBUG, RSLogDebug)

#undef __RS_MAKE_LOG_FUNCTION

#if RS_COMPILE_TIME_LOG_LEVEL >= ASL_LEVEL_DEBUG
void RSLog (NSString *format, ...)
{
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1];
    // Example: 1   UIKit                               0x00540c89 -[UIApplication _callInitializationDelegatesForURL:payload:suspended:] + 1163
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]];
    [array removeObject:@""];
    
    //    NSLog(@"Stack = %@", [array objectAtIndex:0]);
    //    NSLog(@"Framework = %@", [array objectAtIndex:1]);
    //    NSLog(@"Memory address = %@", [array objectAtIndex:2]);
    //    NSLog(@"Class caller = %@", [array objectAtIndex:3]);
    //    NSLog(@"Function caller = %@", [array objectAtIndex:4]);
    //    NSLog(@"Line caller = %@", [array objectAtIndex:5]);
    
    AddStderrOnce();
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format
                                               arguments:args];
    //    asl_log(NULL, NULL, (ASL_LEVEL_DEBUG), "<%s:(%s)> %s", [[array objectAtIndex:3] UTF8String], [[array objectAtIndex:5] UTF8String], [message UTF8String]);
    NSLog(@"<%@:(%@)> %s", [array objectAtIndex:3], [array objectAtIndex:5], [message UTF8String]);
    write_to_log_file(message);
    va_end(args);
}

#if RS_COMPILE_TIME_LOG_DEBUG_TOFILE
void write_to_log_file (NSString* text) {
    if(!log_file)
    {
        NSString *filePath;
        NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        if(documentsDirectory) {
            filePath = [documentsDirectory stringByAppendingPathComponent:@"log.txt"];
        }
        
        log_file = fopen([filePath UTF8String], "a");
        NSLog(@" Log File created - %@", filePath);
    }
    
    if(log_file) {
        text = [text stringByAppendingString:@"\n"];
        //        NSLog(@"text: %@",text);
        fwrite([text UTF8String], text.length, sizeof(char), log_file);
        fflush(log_file);
    }
}
#endif

#define __RS_MAKE_LOG_DEBUG_FUNCTIONS(NAME) \
void NAME (NSString *format, ...) \
{ \
    NSString *sourceString = [[NSThread callStackSymbols] objectAtIndex:1]; \
    NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"]; \
    NSMutableArray *array = [NSMutableArray arrayWithArray:[sourceString  componentsSeparatedByCharactersInSet:separatorSet]]; \
    [array removeObject:@""]; \
    va_list args; \
    va_start(args, format); \
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args]; \
    NSLog(@"<%@:(%@)> [%@] %s", [array objectAtIndex:3], [array objectAtIndex:5], [[NSString stringWithUTF8String:__func__] substringFromIndex:5], [message UTF8String]); \
    write_to_log_file(message); \
    va_end(args); \
}


#if RS_COMPILE_TIME_LOG_DEBUG_ADV
    __RS_MAKE_LOG_DEBUG_FUNCTIONS(RSLogADV)
#endif
#if RS_COMPILE_TIME_LOG_DEBUG_HTTP
    __RS_MAKE_LOG_DEBUG_FUNCTIONS(RSLogHTTP)
#endif
#if RS_COMPILE_TIME_LOG_DEBUG_UI
    __RS_MAKE_LOG_DEBUG_FUNCTIONS(RSLogUI)
#endif
#if RS_COMPILE_TIME_LOG_DEBUG_RTMP
    __RS_MAKE_LOG_DEBUG_FUNCTIONS(RSLogRTMP)
#endif
#if RS_COMPILE_TIME_LOG_DEBUG_RTMP_XMPP
    __RS_MAKE_LOG_DEBUG_FUNCTIONS(RSLogRTMP_XMPP)
#endif
#if RS_COMPILE_TIME_LOG_DEBUG_SQL
__RS_MAKE_LOG_DEBUG_FUNCTIONS(RSLogSQL)
#endif
#if RS_COMPILE_TIME_LOG_DEBUG_LOOPS
__RS_MAKE_LOG_DEBUG_FUNCTIONS(RSLogLOOPS)
#endif

#undef __RS_MAKE_LOG_DEBUG_FUNCTIONS
#endif
