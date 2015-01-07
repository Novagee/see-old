//
//  TBISoundService.h
//  Zangi
//
//  Created by Norayr Harutyunyan on 10/24/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVFoundation.h>
#include <AudioToolbox/AudioToolbox.h>

@interface TBISoundService : NSObject {
	AVAudioPlayer  *playerRingBackTone;
	AVAudioPlayer  *playerRingTone;
	AVAudioPlayer  *playerEvent;
	AVAudioPlayer  *playerConn;
    AVAudioPlayer  *playerNotFound;
    AVAudioPlayer  *playerDecline;
    AVAudioPlayer  *playerlocating;
    AVAudioPlayer  *playerZangiSignal;
    AVAudioPlayer  *playCallDrop;
    AVAudioPlayer  *playHoldBeep;
    AVAudioPlayer  *playerDrop;
	SystemSoundID dtmfLastSoundId;
	AVAudioPlayer *playerKeepAwake;
	AVAudioPlayer *playerIncomingMessage;
    
    NSTimer *timerVibrate;
    SystemSoundID	soundFileObjectRingTone;
}


+(AVAudioPlayer*) initPlayerWithPath:(NSString*)path;


-(BOOL) setSpeakerEnabled:(int)speaker;
-(BOOL) playRingTone;
-(BOOL) stopRingTone;
-(BOOL) playRingBackTone;
-(BOOL) stopRingBackTone;
-(BOOL) playDecline;
-(BOOL) stopDecline;
-(BOOL) playLocating;
-(BOOL) stopLocating;
-(BOOL) playCallDrop;
-(BOOL) playHoldBeep;
-(BOOL) playDtmf:(int)digit;
-(BOOL) vibrate;
-(BOOL) playIncomingMessage;
-(BOOL) playDrop;
-(void) startVibrate;
-(void) stopVibrate;

-(void) timerCallBackVibrate:(NSTimer*)timer;
-(SystemSoundID)ringronSound;
@end