//
//  AudioUnitPlugin.h
//  Protime
//
//  Created by Grigori Jlavyan on 11/6/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>
#include <Foundation/Foundation.h>
#include "rtmpmanager.h"


#define kAudioUnitSubType	kAudioUnitSubType_VoiceProcessingIO

@interface AudioUnitPlugin : NSObject{
    AudioComponentInstance audioUnit;
    rtmp_manager_t *manager;
    uint16_t audio_codec_rate;
    uint16_t bits_per_sample;
    bool isStarted;
    bool isMute;
    UInt32  interruptionState;
    uint32_t counter;
}
@property (nonatomic) UInt32  interruptionState;
void checkStatus(int status);

-(void) startRecordAndPlayAudio;
-(void) initAudioPlugin:(rtmp_manager_t*)manager_;
-(void) stopRecordAndPlayAudio:(rtmp_manager_t*)manager;
-(AudioStreamBasicDescription) createBasicStreem:(UInt32)FormatID;
-(int) AudioUnitPlugin_handle_mute:(bool) mute;
-(bool)isMuted;

@end
