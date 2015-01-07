
#import "GalleryCell.h"
#import "MessageBalloonView.h"
#import "MessageItem.h"
#import "Common.h"
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>



@implementation UIImageView (additions)
- (CGSize)imageScale {
    CGFloat sx = self.frame.size.width / self.image.size.width;
    CGFloat sy = self.frame.size.height / self.image.size.height;
    CGFloat s = 1.0;
    switch (self.contentMode) {
        case UIViewContentModeScaleAspectFit:
            s = fminf(sx, sy);
            return CGSizeMake(s, s);
            
        case UIViewContentModeScaleAspectFill:
            s = fmaxf(sx, sy);
            return CGSizeMake(s, s);
            
        case UIViewContentModeScaleToFill:
            return CGSizeMake(sx, sy);
            
        default:
            return CGSizeMake(s, s);
    }
}
@end

@interface GalleryCell() {
    UITapGestureRecognizer* tapRecognizer;
}
@property ( nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic,retain) MessageBalloonView* balloon;
@property (nonatomic, assign) CGFloat currentZoomScale;

@end
#define BALLOON_TAG 2013
#define ACTIVITY_TAG 2014

@implementation GalleryCell
@synthesize  isSuspended = _isSuspended;
@synthesize  data = _data;
@synthesize balloon = _balloon;
@synthesize currentZoomScale = _currentZoomScale;
@synthesize goToOriGinalScale = _goToOriGinalScale;
@synthesize originalScale;
@synthesize isCalledFromTakes = _isCalledFromTakes;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _goToOriGinalScale = NO;
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"GalleryCell" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[UICollectionViewCell class]]) {
            return nil;
        }
        
        // TODO: JSC - This is odd start
// SUNDAY        self = [arrayOfViews objectAtIndex:0];
        // TODO: JSC - This is odd stop
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClicked)];
        [self.imageView addGestureRecognizer:tapRecognizer];
        
        UITapGestureRecognizer *DoubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture)];
        DoubleTapGesture.numberOfTapsRequired = 2;
        [self.contentView addGestureRecognizer:DoubleTapGesture];
        [tapRecognizer requireGestureRecognizerToFail:DoubleTapGesture];
    }
    return self;
}


-(void) imageClicked {
    [self.cellDelegate cellClicked];
}

-(void) setData:(GalleryCellInfo *)data {
    _data = data;
    _data.delegate = self;
    [self.loadingIndicator stopAnimating];
}

-(void) imageLoaded:(UIImage *)image item:(MessageItem *)item {
    if (item == _data.item) {
        NSLog(@"image size %@", NSStringFromCGSize(image.size));
        self.originalScale = self.scrollView.zoomScale;
        [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
        [self.loadingIndicator stopAnimating];
        [_data.loadingIndicator stopAnimating];
        [self.cellDelegate needToReload];
        NSLog(@"ZoomScale is %f",self.scrollView.zoomScale);
     }
  
}

-(CGSize) calculateContentSize{
    
    CGSize result = CGSizeZero;
    
    CGSize tempSize  = [self.imageView imageScale];
    result.width = tempSize.width*self.imageView.image.size.width > self.frame.size.width?tempSize.width*self.imageView.image.size.width:self.frame.size.width;
    result.height = tempSize.width*self.imageView.image.size.height > self.frame.size.height?tempSize.width*self.imageView.image.size.height:self.frame.size.height;

    NSLog(@"the scaled factor %@", NSStringFromCGSize(result));
    
    return  result;
}

-(void) resetCell{
    UIView* v = [self viewWithTag:BALLOON_TAG];
    _currentZoomScale = 1.0;
    if (v) {
        [v removeFromSuperview];
    }
    NSArray*  subviews = self.subviews;
    for (UIView* vv in subviews) {
        if ([vv isKindOfClass:[UIActivityIndicatorView class]]) {
            [vv removeFromSuperview];
        }
    }
    self.imageView.image = nil;
////    self.scrollView.contentSize = self.bounds.size;
//    self.scrollView.contentOffset = CGPointMake(0, 0);
////    self.imageView.frame =self.scrollView.bounds;
////    self.scrollView.minimumZoomScale = 1;
////    self.scrollView.maximumZoomScale = 2;

    [self.scrollView zoomToRect:self.bounds animated:NO];
    NSLog(@"the self.imageView.contentScaleFactor %f", self.imageView.contentScaleFactor);

}

-(void)updateCell:(BOOL) flag {
    if (!flag) {
        [self resetCell];
        NSString*  str = _data.item.stringMessageText;
        if (str) {
            str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
        if ( str&& str.length != 0) {
            _balloon = [[MessageBalloonView alloc] initWithText:_data.item.stringMessageText];
            _balloon.tag = BALLOON_TAG;
            [self addSubview:_balloon];
            _balloon.hidden = [UIApplication sharedApplication].statusBarHidden;

        }
    }
    if (!_data.actualImage) {
        [self.loadingIndicator stopAnimating];
        UIActivityIndicatorView* v = [[UIActivityIndicatorView alloc] initWithFrame:self.bounds];
        v.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        v.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        v.tag = ACTIVITY_TAG;
        [v startAnimating];
        [self addSubview:v];
        _data.loadingIndicator =v;
        [self.data LoadImage];
    } else {
        
        [_data.loadingIndicator stopAnimating];
        self.imageView.image = _data.actualImage;
        [self.cellDelegate needToReload];
        if (!flag) {
            NSLog(@"the actual image size  is  %@", NSStringFromCGSize(_data.actualImage.size));
            self.scrollView.contentSize = CGSizeZero;
            
            self.scrollView.contentSize = self.bounds.size;
            self.scrollView.contentOffset = CGPointMake(0, 0);
            self.scrollView.minimumZoomScale = 1.0;
            self.scrollView.maximumZoomScale = 2.0;
        }
       
    }
 

    


    
}
-(void) updateContent {
    CGSize s = [self calculateContentSize];
//    self.imageView.frame = CGRectMake(0, 0, s.width, s.height);
    self.scrollView.contentSize = s;
    
    NSLog(@"scrollview contentSize %@ imageView  size %@", NSStringFromCGSize(_scrollView.contentSize),NSStringFromCGSize(self.imageView.frame.size));
    
    UIView *subView = [_scrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = (_scrollView.bounds.size.width > _scrollView.contentSize.width)?
    (_scrollView.bounds.size.width - _scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (_scrollView.bounds.size.height > _scrollView.contentSize.height)?
    (_scrollView.bounds.size.height - _scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(_scrollView.contentSize.width * 0.5 + offsetX,
                                 _scrollView.contentSize.height * 0.5 + offsetY);
}


-(void) layoutSubviews {
    [super layoutSubviews];
    
    UIView* v = [self viewWithTag:ACTIVITY_TAG];
    if (v) {
        v.center = self.center;
    }
    self.loadingIndicator.center = self.center;
    self.balloon.frame = CGRectMake((self.frame.size.width - self.balloon.frame.size.width)/2,
                                    self.frame.size.height - self.balloon.frame.size.height - 10,
                                    self.balloon.frame.size.width, self.balloon.frame.size.height);
    
    [self updateContent];
    

//    if(_isCalledFromTakes){
 
//    }
}





- (void)scrollViewDidZoom:(UIScrollView *)scrollView NS_AVAILABLE_IOS(3_2) {
    _currentZoomScale = scrollView.zoomScale;
    [self updateContent];
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    NSLog(@"Layout subciews");
    UIView *subView = [scrollView.subviews objectAtIndex:0];
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    subView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
    
}

-(UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return  self.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view NS_AVAILABLE_IOS(3_2){

}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale{
    _currentZoomScale = scale;
    [self updateContent];
}

-(void) handleDoubleTapGesture{
    if(!_goToOriGinalScale){
        
        _goToOriGinalScale = YES;
        NSLog(@"%@", NSStringFromCGSize(_data.actualImage.size));
        NSLog(@"%@",NSStringFromCGRect(self.imageView.frame));
        NSLog(@"Zoom scale %f", self.scrollView.zoomScale);
//        CGFloat scaleForZoom = 2;//_data.actualImage.size.width/ self.imageView.image.size.width;
        self.scrollView.zoomScale = 2;//self.scrollView.zoomScale/tempSize.width;
    }else {
        
        _goToOriGinalScale = NO;
        self.scrollView.zoomScale = 1;
    }
}

- (void)killScroll
{
    CGPoint offset = self.scrollView.contentOffset;
    offset.x -= 1.0;
    offset.y -= 1.0;
    [self.scrollView setContentOffset:offset animated:NO];
    offset.x += 1.0;
    offset.y += 1.0;
    [self.scrollView setContentOffset:offset animated:NO];
}
@end
