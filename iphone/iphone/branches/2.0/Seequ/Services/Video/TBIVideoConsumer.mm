//
//  TBIVideoConsumer.m
//  Zangi
//
//  Created by Norayr Harutyunyan on 10/30/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//
#import "idoubs2AppDelegate.h"
#import "TBIVideoConsumer.h"
#import "Common.h"
#import "VideoConfig.h"
#import "media_codec.h"

//#include "rtmpmanager.h"
//

@implementation TBIVideoConsumer

static TBIVideoConsumer *sharedVideoConsumer;


static int test123(void* callbackData, const void* buffer, int size, int width, int height) {

    if(width<height)
    {
        decoderWidth =width;
        decoderHeight =height;
    }else{
        decoderWidth =height;
        decoderHeight =width;
    }
    
    [sharedVideoConsumer set_mBufferPtr:(uint8_t*)buffer frameSize:size width:width height:height];
    [sharedVideoConsumer performSelectorOnMainThread:@selector(drawVideoFrameOnMainThread:) withObject:nil waitUntilDone:YES];
    return 0;
}
static unsigned int w = 0;
static unsigned int h = 0;

-(void) stopVideoRender {
    mDisplay.hidden = YES;
}

- (void)drawVideoFrameOnMainThread:(id)arg {
    if(mDisplay && _mBufferPtr && [[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground && [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive){

        
        
        if([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager] && [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession && [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->codec ){

            mDisplay.hidden = NO;
            
            
                            if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
                                
                                static CGFloat width;
                                static CGFloat height;
                                
//                                if(mDisplay.bounds.size.width != width || mDisplay.bounds.size.height != height){
//                                    [mDisplay setFrame:mDisplay.superview.frame];
//                                }

                                
                                

                                

                                w = mWidth;     //[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->codec->rotate.width;
                                h = mHeight;    //[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->codec->rotate.height;
                                
                                            width = mDisplay.frame.size.width;
                                            height = mDisplay.frame.size.height;
                                
//                                NSLog(@"WIDTH:%f", width);
//                                NSLog(@"WIDTH:%f", height);
                                
                                            [mDisplay renderImage:_mBufferPtr rect:[self createScreenRect:width height:height texstureWidth:mWidth texstureHeight:mHeight]];
                            }
        }
        [Common postNotificationWithName:@"kNgnReceivVideoFrame_Name" object:[NSNumber numberWithBool:w > h ? YES : NO]];
    }
}

-(CGRect)createScreenRect:(CGFloat)_width height:(CGFloat)_height texstureWidth:(GLuint)texstureWidth texstureHeight:(GLuint)texstureHeight {
    
    mDisplay.frame = mDisplay.superview.bounds;

    int width =mDisplay.superview.bounds.size.width;
    
    if(width==480)
    {
       // width = 510;
    }
    
    int height =mDisplay.superview.bounds.size.height;
    
    if(height==480){
        
        //height = 510;
    
    }
    CGRect rect;
    int x =0;
    int y =0;
    
    if(((UIInterfaceOrientationIsPortrait(interfaceOrientation) && w==decoderHeight)|| (UIInterfaceOrientationIsLandscape(interfaceOrientation) && w==decoderWidth)) && (displayState==VideoViewState_NORMAL || displayState==VideoViewState_NORMAL_MENU)){

    if((UIInterfaceOrientationIsPortrait(interfaceOrientation) && w==decoderHeight)){
        width = 320;
        height = 261;
        
        if(!displaySplited)
            y = (480-height)/2;
        else
            y=0;
        
        x = 0;
        
    }else{
        width = 261;
        height = 320;
        
        if(!displaySplited)
            x = (480-width)/2;
        else{
            x = 0;
            width = 284;
        }
        
        y = 0;
        
    }
    
    
        rect =  CGRectMake(x, y,width, height) ;
        mDisplay.frame =CGRectMake(x, y,width, height) ;
    }else{
        rect =  CGRectMake(x, y,width, height) ;
        mDisplay.frame =CGRectMake(x, y,width, height) ;
    }


    interfaceOrientation = [idoubs2AppDelegate sharedInstance].videoService.showVideoView.interfaceOrientation;
    
    switch (displayState) {
        case VideoViewState_NONE:{
        }
            break;
        case VideoViewState_NORMAL_MENU:
        case VideoViewState_NORMAL:{
            if(!displaySplited){
                if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
                {
                    
                    if(w==decoderWidth)
                    {
                        rect = [mDisplay calculateAndCreateRectCriterionFit:_width height:_height texstureWidth:texstureWidth texstureHeight:texstureHeight isDisplayStateChange:isDisplayStateChange];
                    }else if(w==decoderHeight){
                        rect = [mDisplay calculateAndCreateRectFitByHeight:_width height:_height texstureWidth:texstureWidth texstureHeight:texstureHeight isDisplayStateChange:isDisplayStateChange];
                    }
                }else if(UIInterfaceOrientationIsLandscape(interfaceOrientation))
                {
                    if(w==decoderHeight)
                    {
                        rect = [mDisplay calculateAndCreateRectCriterionFit:_width height:_height texstureWidth:texstureWidth texstureHeight:texstureHeight isDisplayStateChange:isDisplayStateChange];
                    }
                    else if(w==decoderWidth)
                    {
                        
                        rect = [mDisplay calculateAndCreateRectFitByHeight:_width height:_height texstureWidth:texstureWidth texstureHeight:texstureHeight isDisplayStateChange:isDisplayStateChange];

                    }
                }
                 isDisplayStateChange = NO;
            }
            else
            {
                if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
                {
                    if(w==decoderWidth)
                    {
                        rect = [mDisplay calculateAndCreateRectFitByWidth:_width height:_height texstureWidth:texstureWidth texstureHeight:texstureHeight isDisplayStateChange:isDisplayStateChange];

                    }else if(w==decoderHeight)
                    {
                        rect = [mDisplay calculateAndCreateRectFitByHeight:_width height:_height texstureWidth:texstureWidth texstureHeight:texstureHeight isDisplayStateChange:isDisplayStateChange];
                    }
                }else if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
                {
                    if(w==decoderHeight)
                    {
                        rect = [mDisplay calculateAndCreateRectFitByHeight:_width height:_height texstureWidth:texstureWidth texstureHeight:texstureHeight isDisplayStateChange:isDisplayStateChange];
                    }
                    else if(w==decoderWidth)
                    {
                        rect = [mDisplay calculateAndCreateRectFitByHeight:_width height:_height texstureWidth:texstureWidth texstureHeight:texstureHeight isDisplayStateChange:isDisplayStateChange];
                    }
                }
                isDisplayStateChange = NO;
            }
        }
            
            break;
        case VideoViewState_TAB_MENU:
        case VideoViewState_TAB:{
            if(!displayIsLandscape){
                if(w==decoderWidth)
                {

                    //isDisplayStateChange = YES;
                     rect = [mDisplay calculateAndCreateRectFitByWidth:_width height:_height texstureWidth:texstureWidth texstureHeight:texstureHeight isDisplayStateChange:isDisplayStateChange];
                }else{
                     rect = [mDisplay calculateAndCreateRectFitByHeight:_width height:_height texstureWidth:texstureWidth texstureHeight:texstureHeight isDisplayStateChange:isDisplayStateChange];
                }
            }else{
                if(w==decoderWidth)
                {
                    rect = [mDisplay calculateAndCreateRectFitByHeight:_width height:_height texstureWidth:texstureWidth texstureHeight:texstureHeight isDisplayStateChange:isDisplayStateChange];

                }else{
                    rect = [mDisplay calculateAndCreateRectFitByHeight:_width height:_height texstureWidth:texstureWidth texstureHeight:texstureHeight isDisplayStateChange:isDisplayStateChange];
                    
                }
            }
            isDisplayStateChange = NO;
        }
            break;
        case VideoViewState_HIDE:{
            mDisplay.hidden = YES;
            
        }
            break;
        default:
            mDisplay.hidden = YES;
            break;
    }
    
    return rect;
}

-(CGRect)currentScreenBoundsDependOnOrientation
{
//    if(isFirstFrame){
//        return screenBounds;
//    }
    
    
    
    
    CGRect screenBounds = [UIScreen mainScreen].bounds ;
    mDisplay.frame = CGRectMake(0,0, mDisplay.superview.frame.size.width, mDisplay.superview.frame.size.height);
    

    
    CGFloat width = screenBounds.size.width  ;
    CGFloat height = screenBounds.size.height ;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if(UIInterfaceOrientationIsPortrait(orientation)){
        screenBounds.size = CGSizeMake(width, height);
    }else if(UIInterfaceOrientationIsLandscape(orientation)){
        screenBounds.size = CGSizeMake(height, width);
    }
    
    //isFirstFrame = YES;
    return screenBounds ;
    
}

-(void)setNumberOfFrame:(uint64_t)value{
    numberOfPackage = value;
}
-(uint64_t)getNumberOfFrame{
    return numberOfPackage;
}

- (void) set_mBufferPtr:(uint8_t*)frame frameSize:(int)frameSize width:(int)width height:(int)height
{
    if(!_mBufferPtr || _mBufferSize < frameSize)
    {
        _mBufferSize = frameSize;
        _mBufferPtr = (uint8_t*)realloc((void*)_mBufferPtr, _mBufferSize);
    }
    
    mWidth = width;
    mHeight = height;

    //    Width = width;
    //    Height = height;
    //    Width = 480;
    //    Height = 392;
    memcpy(_mBufferPtr, frame, frameSize);
}

+ (void) initVideoSession {
    _consume_video_callback test2 = test123;
    rtmp_manager_init_video_session([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager], test2, video_width, video_height, video_fps);
}

+ (TBIVideoConsumer *) sharedVideoConsumer {
	@synchronized([TBIVideoConsumer class])
	{
		if (!sharedVideoConsumer)
			sharedVideoConsumer = [[TBIVideoConsumer alloc] init];
		return sharedVideoConsumer;
	}
	// to avoid compiler warning
	return nil;
}

- (void) StartVideoConsume {
    isUpdateFrame = YES;
    isDisplayStateChange = YES;
    
}

+ (id) alloc
{
    //	@synchronized([TBIVideoConsumer class])
	{
		//NSAssert(sharedVideoConsumer == nil, @"Attempted to allocate a second instance of a singleton.");
        
		sharedVideoConsumer = [super alloc];
        return sharedVideoConsumer;
	}
	// to avoid compiler warning
	return nil;
}

- (id) initWithWidth:(int)width Height:(int)height {
    self = [super init];
    
    if (self) {
        // resize buffer
        if([self resizeBitmapContextWithWidth: width andHeight: height]){
            NSLog(@"resizeBitmapContextWithWidth:%i andHeight:%i has failed", width, height);
            return nil;
        }
        
        isUpdateFrame = NO;
        isFirstFrame = YES;
        
        Width = 480;
        Height = 392;
        isDisplayStateChange = YES;
        tmpWidth = 587;
        tmpHeight = 480;
        
        _mBufferPtr = nil;
    }
    return self;
}



+ (int) consumeFrame:(void*) _frame {
    //	if(!mValid || !_mBufferPtr || !_mBufferSize){
    //		TSK_DEBUG_ERROR("Invalid state");
    //		return -1;
    //	}
    
    //	if(_mBufferPtr){
    //        unsigned w = const_cast<ProxyVideoConsumer *>(_mConsumer)->getDisplayWidth();
    //        unsigned h = const_cast<ProxyVideoConsumer *>(_mConsumer)->getDisplayHeight();
    //        unsigned size = w * h * 1.5; // For YUV 1.5
    //        memcpy(_mBufferPtr, (uint8_t*)_frame, size);
    //        //        _mBufferPtr = (uint8_t*)_frame;
    //		//
    return [[TBIVideoConsumer sharedVideoConsumer] drawFrame];
    //	}
	return 0;
}

- (int) drawFrame {
	if (_mBufferPtr && mDisplay && !isFirstFrame) {
        [self performSelectorOnMainThread:@selector(drawVideoFrameOnMainThread:) withObject:nil waitUntilDone:YES];
	}
    
    isFirstFrame = NO;
	return 0;
}
-(OpenGlView*) getOpenGlViewmDisplay{
    isDisplayStateChange = YES;
    return mDisplay;
}


//- (void) drawVideoFrameOnMainThread:(id)arg {
//    if (mDisplay && _mBufferPtr) {
//
//        if (isUpdateFrame) {
//            [mDisplay updatesize:Width h:Height];
//            isUpdateFrame = NO;
//        }
//
//        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
//            [mDisplay renderImage:_mBufferPtr
//                            Width:Width
//                           Height:Height];
//        }
//
//        [Common postNotificationOnMainThreadWithName:kTBIReceivVideoFrame_Name object:nil];
//    }
//}

- (int) resizeBitmapContextWithWidth:(int)width andHeight: (int)height {
    
    //	if(!_mConsumer){
    //		TSK_DEBUG_ERROR("Invalid embedded consumer");
    //		return -1;
    //	}
	@synchronized(self) {
		// release context
        // [mDisplay setBitmapContext:];
        //		CGContextRelease(mBitmapContext), mBitmapContext = nil;
        
		// realloc the buffer
        
		unsigned newBufferSize = width * height * 4;
        
        //        if (_mBufferPtr) {
        //            if(!(_mBufferPtr = realloc((void*)_mBufferPtr, newBufferSize))){
        //                NSLog(@"Memory reallocation failed");
        //            }
        //        } else {
        //            if (!(_mBufferPtr = calloc((void*)newBufferSize, 1))) {
        //                NSLog(@"Memory allocation failed");
        //            }
        //        }
        
		if (!_mBufferPtr) {
			NSLog(@"Failed to realloc buffer with size=%u", newBufferSize);
			_mBufferSize = 0;
			return -1;
		}
		_mBufferSize = newBufferSize;
        //		// set buffer and request for "bufferCopied()" callback instead of "consume()"
        //		const_cast<ProxyVideoConsumer*>(_mConsumer)->setConsumeBuffer(_mBufferPtr, _mBufferSize);
        //		mWidth = width;
        //		mHeight = height;
        //		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        //		mBitmapContext = CGBitmapContextCreate(_mBufferPtr, width, height, 8, width * 4, colorSpace,
        //											   kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        //		CGColorSpaceRelease(colorSpace);
        
		return 0;
	}
}


- (void) setOrientation:(AVCaptureVideoOrientation)orientation {
    if (mDisplay && _mBufferPtr) {
        isDisplayStateChange = YES;
        if([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]&&[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession && [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession && [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->codec && [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->codec->format == MEDIA_CODEC_FORMAT_VP8){
        }
        
        switch (orientation) {
            case AVCaptureVideoOrientationPortrait:
            case AVCaptureVideoOrientationPortraitUpsideDown:
                Width = decoderWidth;
                Height = decoderHeight;
                tmpWidth = decoderWidth;
                tmpHeight = decoderHeight;
                break;
            case AVCaptureVideoOrientationLandscapeLeft:
            case AVCaptureVideoOrientationLandscapeRight:
                Width = decoderHeight;
                Height = decoderWidth;
                tmpWidth = decoderHeight;
                tmpHeight = decoderWidth;
                break;
            default:
                break;
        }
        
        isUpdateFrame = YES;
    }
}

- (void) setDisplay:(OpenGlView*)display {
    if(display){
        @synchronized(self)
        {
            isDisplayStateChange = YES;
            display.hidden = YES;
            isUpdateFrame = YES;
            oldDisplayState = -1;
            mDisplay = display;
            mDisplay.backgroundColor = [UIColor grayColor];
            
        }
    }
}

- (void) RemotVideoFrameChangedTo:(int)state Split:(BOOL)splited Orientation:(BOOL)isLandscape frame:(CGRect)frame {
    displayState = state;
    displaySplited = splited;
    displayIsLandscape = isLandscape;
    isDisplayStateChange = YES;
    
    
    switch (state) {
        case VideoViewState_NONE:{
            NSLog(@"[VIDEO]{RemotVideoFrameChangedTo}->VideoViewState_NONE");
        }
            break;
        case VideoViewState_NORMAL:{
            NSLog(@"[VIDEO]{RemotVideoFrameChangedTo}->VideoViewState_NORMAL");
        }
            break;
        case VideoViewState_NORMAL_MENU:{
            NSLog(@"[VIDEO]{RemotVideoFrameChangedTo}->VideoViewState_NORMAL_MENU");
        }
            break;
        case VideoViewState_TAB_MENU:{
            NSLog(@"[VIDEO]{RemotVideoFrameChangedTo}->VideoViewState_TAB_MENU");
        }
            break;
        case VideoViewState_TAB:{
            NSLog(@"[VIDEO]{RemotVideoFrameChangedTo}->VideoViewState_TAB");
        }
            break;
        case VideoViewState_HIDE:{
            NSLog(@"[VIDEO]{RemotVideoFrameChangedTo}->VideoViewState_HIDE");
        }
            break;
        default:
            break;
    }
    
    
}
- (CGRect) changeDisplayState:(int)state Split:(BOOL)splited Orientation:(BOOL)isLandscape {
    
//    interfaceOrientation = [idoubs2AppDelegate sharedInstance].videoService.showVideoView.interfaceOrientation;

//    switch (state) {
//        case VideoViewState_NONE:{
//            mDisplay.hidden = YES;
//            NSLog(@"RemotVideoFrameChangedTo *********************************************************************************************** VideoViewState_NONE");
//        }
//            break;
//        case VideoViewState_NORMAL_MENU:
//        case VideoViewState_NORMAL:{
//            if(!splited){
//                if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
//                {
//                    if(w==288)
//                    {
//                        //self.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
//                        mDisplay.frame = CGRectMake(0, 0, 320, 480);
//                    }else if(w==352){
//                        int we = 320;
//                        int he = 261;
//                        mDisplay.frame = CGRectMake(0,(mDisplay.superview.frame.size.height-he)/2, we, he);// -(mDisplay.superview.frame.size.width-he)/2, we, he);
//                    }
//                }else if(UIInterfaceOrientationIsLandscape(interfaceOrientation))
//                {
//                    if(w==352){
//                        int we = 480 ;
//                        int he = 320 ;
//                        mDisplay.frame = CGRectMake(0, 0, we, he);
//                    }else if(w==288){
//                        int we = 261 ;
//                        int he = 320 ;
//                        mDisplay.frame = CGRectMake((mDisplay.superview.frame.size.height-we)/2, (mDisplay.superview.frame.size.width-he)/2, we, he);
//                    }
//                }
//            }
//            else
//            {
//                if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
//                {
//                    if(w==288)
//                    {
//                        mDisplay.frame = CGRectMake(0, -79, 320, 480);
//                    }else if(w==352)
//                    {
//                        int we = 320;
//                        int he = 261;
//                        mDisplay.frame = CGRectMake(0,-10.5, we, he);
//                    }
//                }else if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
//                {
//                    if(w==352)
//                    {
//                        int we = 480 ;
//                        int he = 320 ;
//                        mDisplay.frame = CGRectMake(-43, 0, we, he);
//                    }
//                    else if(w==288)
//                    {
//                        int we = 284 ;
//                        int he = 320 ;
//                        mDisplay.frame = CGRectMake(0, (mDisplay.superview.frame.size.width-he)/2, we, he);
//                    }
//                }
//
//            }
//        }
//
//            break;
//        case VideoViewState_TAB_MENU:
//        case VideoViewState_TAB:{
//            if(!isLandscape){
//                if(w==288)
//                {
//                    mDisplay.frame = CGRectMake(0, 0, mDisplay.superview.frame.size.width*2, mDisplay.superview.frame.size.height);
//                }else{
//                    mDisplay.frame = CGRectMake(0, 0, mDisplay.superview.frame.size.width*2, mDisplay.superview.frame.size.height);
//                }
//            }else{
//                if(w==288)
//                {
//                    if(interfaceOrientation==UIInterfaceOrientationLandscapeRight){
//                        mDisplay.frame = CGRectMake(0, 0, mDisplay.superview.frame.size.height,mDisplay.superview.frame.size.width);
//                    }else{
//                        mDisplay.frame = CGRectMake(0, 0,mDisplay.superview.frame.size.height,mDisplay.superview.frame.size.width);
//                    }
//                }else{
//                    if(interfaceOrientation==UIInterfaceOrientationLandscapeRight){
//                        mDisplay.frame = CGRectMake(mDisplay.frame.origin.x, mDisplay.frame.origin.y,mDisplay.superview.frame.size.height,mDisplay.superview.frame.size.width);
//
//                    }else{
//                        mDisplay.frame = CGRectMake(mDisplay.frame.origin.x, mDisplay.frame.origin.y,mDisplay.superview.frame.size.height,mDisplay.superview.frame.size.width);
//                    }
//
//                }
//            }
//            NSLog(@"RemotVideoFrameChangedTo *********************************************************************************************** VideoViewState_TAB");
//        }
//            break;
//        case VideoViewState_HIDE:{
//            mDisplay.hidden = YES;
//            NSLog(@"RemotVideoFrameChangedTo *********************************************************************************************** VideoViewState_HIDE");
//        }
//            break;
//        default:
//            mDisplay.hidden = YES;
//            break;
//    }
//
//    NSLog(@"mDisplay.frame=%@",mDisplay);
    
    fitToRect = mDisplay.superview.frame;
    isDisplayStateChange = YES;

    return mDisplay.frame;
}


//- (BOOL) changeDisplayState:(int)state Split:(BOOL)splited Orientation:(BOOL)isLandscape{
//    
//    static unsigned int w = 0;
//    static unsigned int h = 0;
//    
//    
//    if([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->codec->rotate.width !=w || w ==0){
//        isUpdateFrame = YES;
//        
//    }
//    if(interfaceOrientation!=[idoubs2AppDelegate sharedInstance].videoService.showVideoView.interfaceOrientation)
//    {
//        isUpdateFrame = YES;
//    }
//    
//    w = [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->codec->rotate.width;
//    h = [[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]->videoSession->codec->rotate.height;
//    
//    [mDisplay initRender];
//    //    if(displayState==oldDisplayState && displayIsLandscape == oldDisplayIsLandscape)
//    //    {
//    //        isDisplayStateChange = NO;
//    //    }
//    //    oldDisplayState = displayState;
//    //    oldDisplayIsLandscape = displayIsLandscape;
//    
//    if(!isDisplayStateChange && !isUpdateFrame)
//        return NO;
//    
//    
//    
//    isDisplayStateChange = NO ;
//    isUpdateFrame = NO ;
//    interfaceOrientation = [idoubs2AppDelegate sharedInstance].videoService.showVideoView.interfaceOrientation;
//    
////    [UIView beginAnimations:nil context:nil];
////    [UIView setAnimationDuration:0.5];
////    [UIView setAnimationDelay:0];
////    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
////    
////    
////    mDisplay.autoresizesSubviews = YES;
////    mDisplay.clipsToBounds = YES;
//    
//    switch (state) {
//        case VideoViewState_NONE:{
//            mDisplay.hidden = YES;
//            NSLog(@"RemotVideoFrameChangedTo *********************************************************************************************** VideoViewState_NONE");
//        }
//            break;
//        case VideoViewState_NORMAL_MENU:
//        case VideoViewState_NORMAL:{
//            if(!splited){
//                if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
//                {
//                    if(w==288)
//                    {
//                        //self.view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
//                        mDisplay.frame = CGRectMake(0, 0, 320, 480);
//                        //mDisplay.center= mDisplay.superview.center;
//                        [mDisplay updatesizeVPX:w h:h realSizeW:w realSizeH:h value:Scale_rate_vpx type:10];
//                    }else if(w==352){
//                        int we = 320;
//                        int he = 261;
//                        //mDisplay.center= mDisplay.superview.center;
//                        mDisplay.frame = CGRectMake(0,(mDisplay.superview.frame.size.height-he)/2, we, he);// -(mDisplay.superview.frame.size.width-he)/2, we, he);
//                        [mDisplay updatesizeVPX:w h:h realSizeW:w realSizeH:h value:Scale_rate_vpx type:12];
//                    }
//                }else if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
//                {
//                    if(w==352){
//                        int we = 480 ;
//                        int he = 320 ;
//                        mDisplay.frame = CGRectMake(0, 0, we, he);
//                        [mDisplay updatesizeVPX:w h:h realSizeW:w realSizeH:h value:Scale_rate_vpx type:11];
//                    }else if(w==288){
//                        int we = 261 ;
//                        int he = 320 ;
//                        mDisplay.frame = CGRectMake((mDisplay.superview.frame.size.height-we)/2, (mDisplay.superview.frame.size.width-he)/2, we, he);
//                        [mDisplay updatesizeVPX:w h:h realSizeW:w realSizeH:h value:Scale_rate_vpx type:13];
//                    }
//                }
//            }
//            else
//            {
//                if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
//                {
//                    if(w==288)
//                    {
////                        int we = 320;
////                        int he = 280;
////                        mDisplay.frame = CGRectMake(0, 0, we, he);
////                        [mDisplay updatesizeVPX:w h:h realSizeW:w realSizeH:h value:Scale_rate_vpx type:19];
//                        mDisplay.frame = CGRectMake(0, -79, 320, 480);
//                        //mDisplay.center= mDisplay.superview.center;
//                        [mDisplay updatesizeVPX:w h:h realSizeW:w realSizeH:h value:Scale_rate_vpx type:19];
//                        
//                    }else if(w==352)
//                    {
//                        
//                        
//                        int we = 320;
//                        int he = 261;
//                        
//                        mDisplay.frame = CGRectMake(0,-10.5, we, he);// -(mDisplay.superview.frame.size.width-he)/2, we, he);
//                        [mDisplay updatesizeVPX:w h:h realSizeW:w realSizeH:h value:Scale_rate_vpx type:21];
//                    }
//                }else if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
//                {
//                    if(w==352)
//                    {
////                        int we = 320;
////                        int he = 290;
////                        mDisplay.frame = CGRectMake(0, 0, he,we);
////                        [mDisplay updatesizeVPX:w h:h realSizeW:w realSizeH:h value:Scale_rate_vpx type:20];
//                        int we = 480 ;
//                        int he = 320 ;
//                        mDisplay.frame = CGRectMake(-43, 0, we, he);
//                        [mDisplay updatesizeVPX:w h:h realSizeW:w realSizeH:h value:Scale_rate_vpx type:20];
//                    }
//                    else if(w==288)
//                    {
//                        int we = 284 ;
//                        int he = 320 ;
//                        mDisplay.frame = CGRectMake(0, (mDisplay.superview.frame.size.width-he)/2, we, he);
//                        [mDisplay updatesizeVPX:w h:h realSizeW:w realSizeH:h value:Scale_rate_vpx type:22];
//                    }
//                }
//                
//            }
//             //[mDisplay renderImageVPX:_mBufferPtr width:w height:h];
//        }
//            
//            break;
//            //        case VideoViewState_NORMAL_MENU:{
//            //            mDisplay.frame = CGRectMake(mDisplay.frame.origin.x, mDisplay.frame.origin.y, 320, 480);
//            //            [mDisplay updatesizeVPX:w h:h realSizeW:w realSizeH:h value:Scale_rate_vpx type:10];
//            //            mDisplay.hidden = NO;
//            //            NSLog(@"RemotVideoFrameChangedTo *********************************************************************************************** VideoViewState_NORMAL_MENU");
//            //        }
//            //            break;
//        case VideoViewState_TAB_MENU:
//        case VideoViewState_TAB:{
//            if(!isLandscape){
//                if(w==288)
//                {
//                    mDisplay.frame = CGRectMake(0, 0, mDisplay.superview.frame.size.width, mDisplay.superview.frame.size.height);
//                    [mDisplay updatesizeVPX:w h:h realSizeW:w realSizeH:h value:Scale_rate_vpx type:14];
//                }else{
//                    mDisplay.frame = CGRectMake(0, 0, mDisplay.superview.frame.size.width, mDisplay.superview.frame.size.height);
//                    [mDisplay updatesizeVPX:w h:h realSizeW:w realSizeH:h value:Scale_rate_vpx type:15];
//                }
//            }else{
//                if(w==288)
//                {
//                    if(interfaceOrientation==UIInterfaceOrientationLandscapeRight){
//                        mDisplay.frame = CGRectMake(0, 0, mDisplay.superview.frame.size.height,mDisplay.superview.frame.size.width);
//                        [mDisplay updatesizeVPX:w h:h realSizeW:w realSizeH:h value:Scale_rate_vpx type:18];
//                    }else{
//                        mDisplay.frame = CGRectMake(0, 0,mDisplay.superview.frame.size.height,mDisplay.superview.frame.size.width);
//                        [mDisplay updatesizeVPX:w h:h realSizeW:w realSizeH:h value:Scale_rate_vpx type:17];
//                    }
//                }else{
//                    if(interfaceOrientation==UIInterfaceOrientationLandscapeRight){
//                        mDisplay.frame = CGRectMake(mDisplay.frame.origin.x, mDisplay.frame.origin.y,mDisplay.superview.frame.size.height,mDisplay.superview.frame.size.width);
//                        [mDisplay updatesizeVPX:w h:h realSizeW:w realSizeH:h value:Scale_rate_vpx type:23];
//                        
//                    }else{
//                        mDisplay.frame = CGRectMake(mDisplay.frame.origin.x, mDisplay.frame.origin.y,mDisplay.superview.frame.size.height,mDisplay.superview.frame.size.width);
//                        [mDisplay updatesizeVPX:w h:h realSizeW:w realSizeH:h value:Scale_rate_vpx type:16];
//                    }
//                    
//                }
//            }
//            //[mDisplay renderImageVPX:_mBufferPtr width:w height:h];
//            NSLog(@"RemotVideoFrameChangedTo *********************************************************************************************** VideoViewState_TAB");
//        }
//            break;
//        case VideoViewState_HIDE:{
//            mDisplay.hidden = YES;
//            NSLog(@"RemotVideoFrameChangedTo *********************************************************************************************** VideoViewState_HIDE");
//        }
//            break;
//        default:
//            mDisplay.hidden = YES;
//            break;
//    }
//    
//    return YES;
//}

@end