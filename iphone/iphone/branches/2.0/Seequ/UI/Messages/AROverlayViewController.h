#import <UIKit/UIKit.h>
#import "CaptureSessionManager.h"
#import "MessageItem.h"

@interface AROverlayViewController : UIViewController {
    
}

@property (retain) CaptureSessionManager *captureManager;
@property (nonatomic,assign) id<CaptureSessionManagerDelegate> delegate;
@property (nonatomic,retain) MessageItem* messageItem;

-(void) startRecording;
-(void) stopRecording;

@end
