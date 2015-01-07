
#import <UIKit/UIKit.h>
#import "GalleryCellInfo.h"


@protocol GalleryCellDelegate;

@interface GalleryCell : UICollectionViewCell<GalleryCellInfoDelegate,UIScrollViewDelegate>


@property (nonatomic,assign) BOOL isSuspended;
@property (nonatomic,retain) GalleryCellInfo*  data;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic,assign) BOOL goToOriGinalScale;
@property(nonatomic, assign) int originalScale;
@property (nonatomic, assign) BOOL isCalledFromTakes;
@property (nonatomic,assign) id<GalleryCellDelegate> cellDelegate;
-(void)updateCell:(BOOL) flag;
-(void) handleDoubleTapGesture;
- (void)killScroll;
@end


@protocol GalleryCellDelegate <NSObject>

-(void) needToReload;
-(void) cellClicked;
@end