//
//  TBISoundService.m
//  Zangi
//
//  Created by Norayr Harutyunyan on 10/24/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "TBISoundService.h"

@implementation TBISoundService


- (id) init {
    self = [super init];
    
    if (self) {
    }
    
    return self;
}


+(AVAudioPlayer*) initPlayerWithPath:(NSString*)path {
	NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], path]];
    
	NSError *error;
	AVAudioPlayer *player_path ;
    try {
//        if(player_path && [player_path isPlaying])
//            [player_path stop];
    } catch (NSException *ex) {
        
    }
    
    player_path = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
	if (player_path == nil){
		NSLog(@"Failed to create audio player(%@): %@", path, error);
	}
	
	return player_path;
}

-(BOOL) setSpeakerEnabled:(int)speaker {
#if TARGET_OS_IPHONE
    
//  JSC  AudioSessionSetActive(true);
    
    //error handling
    BOOL success;
    NSError* error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 80000
    [audioSession setActive:NO error:&error];
#endif
    
// JSC    UInt32 route;
    switch (speaker) {
        case 0: // Microphone
        {
//            UInt32 category = kAudioSessionCategory_PlayAndRecord;
//  JSC          AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:&error];
// JSC
//            UInt32 allowBluetoothInput = 0;
//            
//            AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryEnableBluetoothInput,
//                                     sizeof (allowBluetoothInput),
//                                     &allowBluetoothInput);

            //set the audioSession override
            success = [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone
                                                      error:&error];
            if (!success)  NSLog(@"AVAudioSession error overrideOutputAudioPort:%@",error);
            
// JSC
//            route = kAudioSessionOverrideAudioRoute_None;
//            
//            OSStatus osStatus = AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
//                                                         sizeof(route), &route);
//            
//            if (osStatus != kAudioSessionNoError)
//                NSLog(@"MIC AudioSessionSetProperty: ERROR osStatus %c%c%c%c", (char)(osStatus >> 24), (char)((osStatus >> 16)&0xFF), (char)((osStatus >> 8)&0xFF), (char)(osStatus&0xFF));
            
            //activate the audio session
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 80000
            success = [audioSession setActive:YES error:&error];
            if (!success)
                NSLog(@"AVAudioSession error activating: %@",error);
            else
                NSLog(@"audioSession active");
#endif
        }
            break;
        case 1: // Speaker Phone
        {
//            route = kAudioSessionOverrideAudioRoute_Speaker;
//            OSStatus osStatus = AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
//                                                         sizeof(route), &route);
//            if (osStatus != kAudioSessionNoError)
//                NSLog(@"SPK AudioSessionSetProperty: ERROR osStatus %c%c%c%c", (char)(osStatus >> 24), (char)((osStatus >> 16)&0xFF), (char)((osStatus >> 8)&0xFF), (char)(osStatus&0xFF));
//            

            
            //set the audioSession category.
            //Needs to be Record or PlayAndRecord to use audioRouteOverride:
            
            success = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                                     error:&error];
            
            if (!success)  NSLog(@"AVAudioSession error setting category:%@",error);
            
            //set the audioSession override
            success = [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                                 error:&error];
            if (!success)  NSLog(@"AVAudioSession error overrideOutputAudioPort:%@",error);
            
            //activate the audio session
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 80000
            success = [audioSession setActive:YES error:&error];
            if (!success) NSLog(@"AVAudioSession error activating: %@",error);
            else NSLog(@"audioSession active");
#endif
        }
            break;
        case 2: // Bluetooth
        {
            UInt32 allowBluetoothInput = 1;
            
            OSStatus osStatus;
            osStatus= AudioSessionSetProperty (kAudioSessionProperty_OverrideCategoryEnableBluetoothInput,
                                                         sizeof (allowBluetoothInput), &allowBluetoothInput);
            
            NSError *err;
            
            [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeVoiceChat error:&err];
            // set preferred buffer size
            Float32 preferredBufferSize = .02; // in seconds
            osStatus = AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(preferredBufferSize), &preferredBufferSize);
            
            if (osStatus != kAudioSessionNoError)
                NSLog(@"BT AudioSessionSetProperty: ERROR osStatus %c%c%c%c", (char)(osStatus >> 24), (char)((osStatus >> 16)&0xFF), (char)((osStatus >> 8)&0xFF), (char)(osStatus&0xFF));
        }
            break;
        default:
            break;
    }
    
	return YES;
#else
	return NO;
#endif
}

- (BOOL) playRingTone {
  
//    if (soundFileObjectRingTone) {
//        AudioServicesDisposeSystemSoundID(soundFileObjectRingTone);
//        soundFileObjectRingTone = nil;
//    }

    if (!soundFileObjectRingTone) {
        NSURL *tapSound   = [[NSBundle mainBundle] URLForResource: @"ringtone"
                                                    withExtension: @"mp3"];
        // Store the URL as a CFURLRef instance
        CFURLRef soundFileURLRef = (__bridge CFURLRef)tapSound;
        
        // Create a system sound object representing the sound file.
        AudioServicesCreateSystemSoundID (soundFileURLRef, &soundFileObjectRingTone);
    }

    if (soundFileObjectRingTone) {
        AudioServicesPlaySystemSound (soundFileObjectRingTone);

        AudioServicesAddSystemSoundCompletion(soundFileObjectRingTone, nil, nil, playSoundFinished, (__bridge void*) self);
        
        if (timerVibrate) {
            [timerVibrate invalidate];
            timerVibrate = nil;
        }
        
        timerVibrate = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                        target:self
                                                      selector:@selector(timerCallBackVibrate:)
                                                      userInfo:nil
                                                       repeats:YES];
        return YES;
    }
    
    
//	if(playerRingTone){
//        playerRingTone = nil;
//    }
//    
//	if(!playerRingTone){
//		playerRingTone = [TBISoundService initPlayerWithPath:@"ringtone.mp3"];
//	}
//    
//	if(playerRingTone){
//        if(playerRingTone.playing){
//            [playerRingTone stop];
//        }
//		playerRingTone.numberOfLoops = -1;
//		[playerRingTone play];
//		return YES;
//	}
	return NO;
}
-(SystemSoundID)ringronSound{
    if (!soundFileObjectRingTone) {
        NSURL *tapSound   = [[NSBundle mainBundle] URLForResource: @"ringtone"
                                                    withExtension: @"mp3"];
        // Store the URL as a CFURLRef instance
        CFURLRef soundFileURLRef = (__bridge CFURLRef)tapSound;
        
        // Create a system sound object representing the sound file.
        AudioServicesCreateSystemSoundID (soundFileURLRef, &soundFileObjectRingTone);
    }
    return soundFileObjectRingTone;
}


void playSoundFinished (SystemSoundID sound, void *data) {
    TBISoundService *service = (__bridge TBISoundService*)data;
    [service playRingTone];
}

-(BOOL) stopRingTone{
//	if(playerRingTone && playerRingTone.playing){
//		[playerRingTone stop];
//	}
    
    if (timerVibrate) {
        [timerVibrate invalidate];
        timerVibrate = nil;
    }

    if (soundFileObjectRingTone) {
        AudioServicesDisposeSystemSoundID(soundFileObjectRingTone);
        soundFileObjectRingTone = nil;
    }
    
	return YES;
}

-(BOOL) playRingBackTone{
	if(!playerRingBackTone){
		playerRingBackTone = [TBISoundService initPlayerWithPath:@"outgoing.wav"];
	}
	if(playerRingBackTone){
		playerRingBackTone.numberOfLoops = -1;
		[playerRingBackTone play];
		return YES;
	}
	return NO;
}

-(BOOL) stopRingBackTone{
	if(playerRingBackTone && playerRingBackTone.playing){
		[playerRingBackTone stop];
	}
	return YES;
}
-(BOOL) playCallDrop {
    if(!playCallDrop){
		playCallDrop = [TBISoundService initPlayerWithPath:@"call_drop.mp3"];
	}
	if(playCallDrop){
		playCallDrop.numberOfLoops = 0;
		[playCallDrop play];
		return YES;
	}
	return NO;
}
-(BOOL) playDecline {
    if(!playerDecline){
		playerDecline = [TBISoundService initPlayerWithPath:@"decline.mp3"];
	}
	if(playerDecline){
		playerDecline.numberOfLoops = 0;
		[playerDecline play];
		return YES;
	}
	return NO;
}

-(BOOL) stopDecline {
	if(playerDecline && playerDecline.playing){
		[playerDecline stop];
        playerDecline = nil;
	}
	return YES;
}

-(BOOL) playLocating {
	if(!playerlocating){
		playerlocating = [TBISoundService initPlayerWithPath:@"locating.mp3"];
	}
	if(playerlocating){
		playerlocating.numberOfLoops = -1;
		[playerlocating play];
		return YES;
	}
	return NO;
}
-(BOOL)playDrop{
        if(!playerDrop){
		playerDrop = [TBISoundService initPlayerWithPath:@"DropSound.mp3"];
	}
	if(playerDrop){
		playerDrop.numberOfLoops = 0;
		[playerDrop play];
		return YES;
	}
	return NO;
}
-(BOOL) stopLocating {
	if(playerlocating && playerlocating.playing){
		[playerlocating stop];
        playerlocating = nil;
	}
	return YES;
}
-(BOOL)playHoldBeep{
        if(!playHoldBeep){
		playHoldBeep = [TBISoundService initPlayerWithPath:@"Hold_Beep.mp3"];
	}
	if(playHoldBeep){
		playHoldBeep.numberOfLoops =0;
		[playHoldBeep play];
		return YES;
	}
        return NO;
}
-(BOOL) playDtmf:(int)digit{
	NSString* code = nil;
	BOOL ok = NO;
	switch(digit){
		case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7: case 8: case 9: code = [NSString stringWithFormat:@"%i", digit]; break;
		case 10: code = @"pound"; break;
		case 11: code = @"star"; break;
		default: code = @"0";
	}
	CFURLRef soundUrlRef;
    if(digit == 13){
        soundUrlRef = (CFURLRef) CFBridgingRetain([[NSBundle mainBundle] URLForResource:@"Delete" withExtension:@"wav"]);
    }else{
        soundUrlRef = (CFURLRef) CFBridgingRetain([[NSBundle mainBundle] URLForResource:[@"dtmf-" stringByAppendingString:code] withExtension:@"wav"]);
    }
	
    if(dtmfLastSoundId){
		AudioServicesDisposeSystemSoundID(dtmfLastSoundId);
		dtmfLastSoundId = 0;
	}
	
    if(soundUrlRef && AudioServicesCreateSystemSoundID(soundUrlRef, &dtmfLastSoundId) == 0){
		AudioServicesPlaySystemSound(dtmfLastSoundId);
		ok = YES;
	}
	
	if(soundUrlRef){
		CFRelease(soundUrlRef);
	}
	
	return ok;
}

-(BOOL) vibrate {
	AudioServicesPlayAlertSound (kSystemSoundID_Vibrate);
	return YES;
}

-(BOOL) playIncomingMessage {
    if(!playerIncomingMessage) {
        playerIncomingMessage = [TBISoundService initPlayerWithPath:@"Delete.mp3"];
    }
    if(playerIncomingMessage) {
        playerIncomingMessage.numberOfLoops = 0;
        [playerIncomingMessage play];
        
        return YES;
    }
    
    return NO;
}
-(void)startVibrate{
        timerVibrate = [NSTimer scheduledTimerWithTimeInterval:1.5
                                                        target:self
                                                      selector:@selector(timerCallBackVibrate:)
                                                      userInfo:nil
                                                       repeats:YES];
}
-(void)stopVibrate{
        if([timerVibrate isValid]){
                [timerVibrate invalidate];
        }
}

-(void) timerCallBackVibrate:(NSTimer*)timer {
    [self vibrate];
}

-(void)dealloc{
    if(playerIncomingMessage){
		if(playerIncomingMessage.playing){
			[playerIncomingMessage stop];
		}
	}
}

@end