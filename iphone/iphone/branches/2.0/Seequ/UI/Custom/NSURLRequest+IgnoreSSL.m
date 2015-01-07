

#import "NSURLRequest+IgnoreSSL.h"

@implementation NSURLRequest (IgnoreSSL)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host
{
    return YES;
    
}

//+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host
//{
//}
@end
