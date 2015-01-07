 
#import <UIKit/UIKit.h>

static void sig_handler(int signum);

int main(int argc, char *argv[]) {
    @try {
        @autoreleasepool {

            signal(SIGSEGV, sig_handler);

            int retVal = UIApplicationMain(argc, argv, @"MyApplication", @"idoubs2AppDelegate");
            return retVal;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"main exception %@", exception.description);
    }
    @finally {
        exit(0);
    }
}

static void sig_handler(int signum)
{
    printf("Received signal %d\n", signum);
}