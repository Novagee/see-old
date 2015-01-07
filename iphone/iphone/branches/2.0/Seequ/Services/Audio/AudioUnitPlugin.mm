//
//  AudioUnitPlugin.m
//  Protime
//
//  Created by Grigori Jlavyan on 11/6/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "AudioUnitPlugin.h"
#import "TBIVideoConsumer.h"
#include "idoubs2AppDelegate.h"
#include <stdio.h>
#include <stdlib.h>

#define kOutputBus 0
#define kInputBus 1
static UInt32 kOne = 1;
static UInt32 kZero = 0;

@implementation AudioUnitPlugin
@synthesize interruptionState;

void checkStatus(int status)
{
    if (status) {
        NSLog(@"Status not 0! %i\n", status);
    }
//    else{
//       NSLog(@"NORMAL %i\n", status);
//    }
}
+(int) getDocumentsFilePath:(const char*) fileName filePath:(char*)filePath len:(int)len
{
    if(!filePath)
        return -1;
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    if(!documentsDirectory)
        return -2;
    
    if(fileName)
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:fileName]];
    
    if(documentsDirectory.length > len)
        return -3;
    
    strcpy(filePath, [documentsDirectory UTF8String]);
    
    return documentsDirectory.length;
}


OSStatus __handle_input_buffer(void *inRefCon,
                      AudioUnitRenderActionFlags *ioActionFlags,
                      const AudioTimeStamp *inTimeStamp,
                      UInt32 inBusNumber,
                      UInt32 inNumberFrames,
                      AudioBufferList *ioData){
    OSStatus status = noErr;
    AudioUnitPlugin *self = (__bridge AudioUnitPlugin *)inRefCon;
    AudioBuffer buffer;
	
	buffer.mNumberChannels = 1;
	buffer.mDataByteSize = inNumberFrames * 2;
	buffer.mData = malloc( inNumberFrames * 2 );
	
	// Put buffer in a AudioBufferList
	AudioBufferList bufferList;
	bufferList.mNumberBuffers = 1;
	bufferList.mBuffers[0] = buffer;
	
    // Then:
    // Obtain recorded samples
    status = AudioUnitRender(self->audioUnit,
                             ioActionFlags,
                             inTimeStamp,
                             inBusNumber,
                             inNumberFrames,
                             &bufferList);
   // && bufferList.mBuffers[0].mDataByteSize<1000 is workaround for Bluetooth
    if(status ==0 && self->manager && bufferList.mBuffers[0].mDataByteSize>0 && bufferList.mBuffers[0].mDataByteSize<1000){
//        static int k = 0 ;
//        if(k%30==0)
//         NSLog(@"__handle_input_buffer");
//        k++;
        
//        char filePath[512];
//        [AudioUnitPlugin getDocumentsFilePath:"pcm.pcm" filePath:filePath len:512];
//        static FILE* audio_file = 0;
//        static int k = 0 ;
//        if(k<500){
//            k++;
//            if(!audio_file)
//                audio_file =  fopen(filePath, "wb");
//            
//            if(audio_file){
//                fwrite(bufferList.mBuffers[0].mData, bufferList.mBuffers[0].mDataByteSize, sizeof(char), audio_file);
//                
//                
//            }
//        }else{
//            if(audio_file){
//                fclose(audio_file);
//                NSLog(@"__handle_input_buffer ENDDDDD-----");
//            }
//        }
        
//        char filePath[512];
//        [AudioUnitPlugin getDocumentsFilePath:"test.pcm" filePath:filePath len:512];
//        static FILE* audio_file = 0;
//        static int k = 0 ;
//        if(k<500){
//            k++;
//            if(!audio_file)
//                audio_file =  fopen(filePath, "wb");
//            
//            if(audio_file){
//                fwrite(bufferList.mBuffers[0].mData, bufferList.mBuffers[0].mDataByteSize, sizeof(char), audio_file);
//            }
//        }else{
//            if(audio_file){
//                fclose(audio_file);
//                NSLog(@"__handle_input_buffer ENDDDDD-----");
//            }
//        }
        
//        static int i =0;
//        i++;
//        if(i%100==0){
//            NSLog(@"****************************** %i",i);
//        }
//        
//        NSLog(@"---- bufferList.mBuffers[0].mDataByteSize = %d",(unsigned int)bufferList.mBuffers[0].mDataByteSize);
//        
        
        rtmp_manager_set_send_audio(self->manager, bufferList.mBuffers[0].mData, bufferList.mBuffers[0].mDataByteSize);
//            char *val =(char*)bufferList.mBuffers[0].mData;
//            NSLog(@"Send Audio buffer data");
//            for (int i =0; i < bufferList.mBuffers[0].mDataByteSize; i++) {
//                    
//                    printf("%d", val[i]);
//                    
//            }
//            NSLog(@"Send Audio buffer data");
            
    }
    free(buffer.mData);
    
    return 0;
}

OSStatus __handle_output_buffer(void *inRefCon,
                                                 AudioUnitRenderActionFlags *ioActionFlags,
                                                 const AudioTimeStamp *inTimeStamp,
                                                 UInt32 inBusNumber,
                                                 UInt32 inNumberFrames,
                                                 AudioBufferList *ioData){
//    OSStatus statuserr = noErr;
    AudioUnitPlugin *self = (__bridge AudioUnitPlugin *)inRefCon;
  
     if(self->manager){
//         static int q = 0 ;
//         if(q%30==0)
//           NSLog(@"__handle_output_buffer");
//           q++;
//         static FILE *audio_file = 0;
//         NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath]
//                                          stringByAppendingPathComponent:@"speex1.dat"];
//         NSLog(@"databasePathFromApp %@",databasePathFromApp);
//         if(!audio_file){
//             audio_file = fopen([databasePathFromApp UTF8String], "rb");
//         }
//         if(audio_file){
//             fread(ioData->mBuffers[0].mData, ioData->mBuffers[0].mDataByteSize, sizeof(char), audio_file);
//         }

         
         
         if(!rtmp_manager_get_received_audio(self->manager, ioData->mBuffers[0].mData, ioData->mBuffers[0].mDataByteSize))
         {
             memset(ioData->mBuffers[0].mData, 0, ioData->mBuffers[0].mDataByteSize);
         }
//             char *val =(char*)ioData->mBuffers[0].mData;
//             NSLog(@"Received Audio buffer data");
//             for (int i =0; i < ioData->mBuffers[0].mDataByteSize; i++) {
//                     
//                     printf("%d", val[i]);
//                     
//             }
//             NSLog(@"Received Audio buffer data");

     }
    return 0;
}
void interruptionListenerCallback (
                                   void    *inUserData,                                     // 1
                                   UInt32  interruptionState                                // 2
                                   ) {
      AudioUnitPlugin *plugin =  (__bridge AudioUnitPlugin *) inUserData;                   // 3
      if (interruptionState == kAudioSessionBeginInterruption) {                            // 4
//          if ([[idoubs2AppDelegate sharedInstance].gsm_callState isEqualToString: CTCallStateConnected]) {
//              
//          } else if ([[idoubs2AppDelegate sharedInstance].gsm_callState isEqualToString: CTCallStateDialing]) {
//              
//          } else if ([[idoubs2AppDelegate sharedInstance].gsm_callState isEqualToString: CTCallStateDisconnected]) {
//              if ([[idoubs2AppDelegate sharedInstance].videoService isInCall] || [[idoubs2AppDelegate sharedInstance].videoService.outgoingCallView superview]) {
//                  rtmp_manager_send_unhold([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]);
//              }
//          } else if ([[idoubs2AppDelegate sharedInstance].gsm_callState isEqualToString: CTCallStateIncoming]) {
              if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
                  rtmp_manager_send_hold([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]);
                  [plugin stopRecordAndPlayAudio:[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]];
              }
//          }
          NSLog(@"***************************************************************************--- kAudioSessionBeginInterruption");
      } else if (interruptionState == kAudioSessionEndInterruption) {
          if ([[idoubs2AppDelegate sharedInstance].gsm_callState isEqualToString: CTCallStateConnected]) {
              
          } else if ([[idoubs2AppDelegate sharedInstance].gsm_callState isEqualToString: CTCallStateDialing]) {
              
          } else if ([[idoubs2AppDelegate sharedInstance].gsm_callState isEqualToString: CTCallStateDisconnected]) {
              if ([[idoubs2AppDelegate sharedInstance].videoService isInCall]) {
                  [idoubs2AppDelegate sharedInstance].videoService.isOnHold = NO;
                  rtmp_manager_send_unhold([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]);
                  [plugin stopRecordAndPlayAudio:[[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]];
                  usleep(1500000);
                  [plugin startRecordAndPlayAudio];
                  
              }
          } else if ([[idoubs2AppDelegate sharedInstance].gsm_callState isEqualToString: CTCallStateIncoming]){
              if([[idoubs2AppDelegate sharedInstance].videoService isInCall] || [[idoubs2AppDelegate sharedInstance].videoService.outgoingCallView superview]) {
                  rtmp_manager_send_hold([[idoubs2AppDelegate sharedInstance] Get_RTMP_Manager]);
              }
          }
          NSLog(@"***************************************************************************--- kAudioSessionEndInterruption");
      }
    plugin->interruptionState = interruptionState;
    [idoubs2AppDelegate sharedInstance].gsm_callState = @"";
}

-(void) initAudioPlugin:(rtmp_manager_t*)manager_{
    manager = manager_;
    
//    static int inicalized = 1 ;
    
//    if(inicalized){
//    AudioSessionInitialize (
//                            NULL,                            // 1
//                            NULL,                            // 2
//                            interruptionListenerCallback,    // 3
//                            (__bridge void*)self             // 4
//                            );
//        inicalized=0;
//    }
    rtmp_manager_init_audio_session(manager);
    [TBIVideoConsumer initVideoSession];
    
    if(manager && manager->audioSession && manager->audioSession->codec){
        audio_codec_rate = manager->audioSession->codec->rate;
        bits_per_sample = 16; //manager->audioSession->codec->bits_per_sample;
    }
}


-(AudioStreamBasicDescription) createBasicStreem:(UInt32)FormatID{
    
    AudioStreamBasicDescription audioFormat;
    //audioFormat.mFormatID = kAudioFormatLinearPCM;
    audioFormat.mFormatID = FormatID;
    
    switch (FormatID) {
        case kAudioFormatLinearPCM:{
            audioFormat.mSampleRate = audio_codec_rate;
            audioFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
            audioFormat.mChannelsPerFrame = 1;
            audioFormat.mFramesPerPacket = 1;                                                                                                                                                                                                                                                                                                                                                                                                                                   
            audioFormat.mBitsPerChannel = bits_per_sample;
            audioFormat.mBytesPerPacket = audioFormat.mBitsPerChannel / 8 * audioFormat.mChannelsPerFrame;
            audioFormat.mBytesPerFrame = audioFormat.mBytesPerPacket;
            audioFormat.mReserved = 0;
        }
            break;
        case kAudioFormatiLBC:{
            audioFormat.mSampleRate        = 8000.0;
            audioFormat.mFormatID          = kAudioFormatiLBC;
            audioFormat.mFormatFlags       = 0;
            audioFormat.mChannelsPerFrame  = 1;
            audioFormat.mFramesPerPacket   = 240;
            audioFormat.mBytesPerPacket    = 50;
        }
        default:
            break;
    }
    return audioFormat;
}


#define checkResult(result,operation) (_checkResult((result),(operation),strrchr(__FILE__, '/')+1,__LINE__))
static inline BOOL _checkResult(OSStatus result, const char *operation, const char* file, int line) {
    if ( result != noErr ) {
        int fourCC = CFSwapInt32HostToBig(result);
        NSLog(@"######*******######## %s:%d: %s result %d %08X %4.4s\n", file, line, operation, (int)result, (int)result, (char*)&fourCC);
        return NO;
    }
    return YES;
}

- (BOOL) setupDevice {
    NSLog(@"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ setupDevice start");
    @synchronized(self)
    {
        UInt32 len;
        UInt32 val;
        AudioComponent comp;
        AudioComponentDescription desc;
        AudioStreamBasicDescription fmt;
        
        desc.componentType = kAudioUnitType_Output;
        
        
# if HAVE_WEBRTC_LIB
        desc.componentSubType = kAudioUnitSubType_RemoteIO;
# else
        desc.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
# endif
        desc.componentManufacturer = kAudioUnitManufacturer_Apple;
        desc.componentFlags = 0;
        desc.componentFlagsMask = 0;
        
        comp = AudioComponentFindNext(NULL, &desc);
        if (! comp) {
            NSLog(@"MKVoiceProcessingDevice: Unable to find AudioUnit.");
            return NO;
        }
        
        if(!checkResult( AudioComponentInstanceNew(comp, (AudioComponentInstance *) &audioUnit), "AudioComponentInstanceNew"))
            return NO;
        val = 1;
        
        if(!checkResult(AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &val, sizeof(UInt32)), "AudioUnitSetProperty: Unable to configure input scope on AudioUnit."))
            return NO;
        
        val = 1;
        if(!checkResult(AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 0, &val, sizeof(UInt32)), "AudioUnitSetProperty :Unable to configure output scope on AudioUnit"))
            return NO;
        
        AURenderCallbackStruct cb;
        cb.inputProc = __handle_input_buffer;
        cb.inputProcRefCon = (__bridge void*)self;
        len = sizeof(AURenderCallbackStruct);
        
        if(!checkResult(AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 0, &cb, len),"AudioUnitSetProperty: Unable to setup callback."))
            return NO;
        
        cb.inputProc = __handle_output_buffer;
        cb.inputProcRefCon = (__bridge void*)self;
        len = sizeof(AURenderCallbackStruct);
        if(!checkResult(AudioUnitSetProperty(audioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Global, 0, &cb, len),"AudioUnitSetProperty: Could not set render callback."))
            return NO;
        
        len = sizeof(AudioStreamBasicDescription);
        if(!checkResult(AudioUnitGetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 1, &fmt, &len),"AudioUnitSetProperty: Unable to query device for stream info."))
            return NO;
        
        if (fmt.mChannelsPerFrame > 1) {
            NSLog(@"MKVoiceProcessingDevice: Input device with more than one channel detected. Defaulting to 1.");
        }
        fmt = [self createBasicStreem:kAudioFormatLinearPCM];
        
        
        len = sizeof(AudioStreamBasicDescription);
        
        if(!checkResult(AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &fmt, len),"AudioUnitSetProperty: Unable to set stream format for output device. (output scope)"))
            return NO;
        
        

        
        if(!checkResult(AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &fmt, len),"AudioUnitSetProperty: Unable to set stream format for output device. (output scope)"))
            return NO;
        
        len = sizeof(AudioStreamBasicDescription);
        
        if(!checkResult(AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &fmt, len),"AudioUnitSetProperty: Unable to set stream format for input device. (input scope)"))
            return NO;
        
# if !HAVE_WEBRTC_LIB
        val = 0;
        len = sizeof(UInt32);
        if(!checkResult(AudioUnitSetProperty(audioUnit, kAUVoiceIOProperty_BypassVoiceProcessing, kAudioUnitScope_Global, 0, &val, len)," Unable to disable VPIO voice processing."))
            return NO;
        
        val = 0;
        len = sizeof(UInt32);
        if(!checkResult(AudioUnitSetProperty(audioUnit, kAUVoiceIOProperty_VoiceProcessingEnableAGC, kAudioUnitScope_Global, 0, &val, len)," Unable to disable VPIO AGC."))
            return NO;
# endif
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED <= 60100
        //  if (!DeviceIsRunningiOS7OrGreater())
#endif
        {
            // It's sufficient to set the quality to 0 for our use case; we do our own preprocessing
            // after this, and the job of the VPIO is only to do echo cancellation.
# if !HAVE_WEBRTC_LIB
            val = 127;
            len = sizeof(UInt32);
            if(!checkResult(AudioUnitSetProperty(audioUnit, kAUVoiceIOProperty_VoiceProcessingQuality, kAudioUnitScope_Global, 0, &val, len),"AudioUnitSetProperty: unable to set VPIO quality."))
                return NO;
# endif
        }
# if !HAVE_WEBRTC_LIB
        
        val = 0;
        len = sizeof(UInt32);
        if(!checkResult(AudioUnitSetProperty(audioUnit, kAUVoiceIOProperty_MuteOutput, kAudioUnitScope_Global, 0, &val, len),"AudioUnitSetProperty: unable to unmute output."))
            return NO;
# endif
        
        if(!checkResult(AudioUnitInitialize(audioUnit),"AudioUnitInitialize: Unable to initialize AudioUnit."))
            return NO;
        
        if(!checkResult(AudioOutputUnitStart(audioUnit),"AudioOutputUnitStart: Unable to start AudioUnit."))
            return NO;
        
        NSLog(@"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ setupDevice end");
    }
    return YES;
}


-(void) startRecordAndPlayAudio{
    if(isStarted)
        return;
    
    isMute = false;
    counter = 0;
    NSError *err;
    
    [[AVAudioSession sharedInstance] setMode:AVAudioSessionModeVoiceChat error:&err];
    
    for (int i = 0 ; i < 3; i++) {
        if((isStarted = [self setupDevice]))
            break;
        else
            usleep(50000);
    }
    return;
}

-(int) AudioUnitPlugin_handle_mute:(bool) mute
{
	OSStatus status = noErr;
	if(!audioUnit){
		return -1;
	}
    
	status = AudioUnitSetProperty(audioUnit, kAUVoiceIOProperty_MuteOutput, kAudioUnitScope_Input, kOutputBus, mute ? &kOne : &kZero, mute ? sizeof(kOne) : sizeof(kZero));
    
    if(!status)
        isMute = mute;
    
	return status ? -2 : 0;
}
-(bool)isMuted{
    return isMute;
}
-(void) stopRecordAndPlayAudio:(rtmp_manager_t*)manager_{
    if(!isStarted)
        return;
    isStarted = false;
   // manager = NULL;
    OSStatus result = AudioOutputUnitStop(audioUnit);
    checkStatus(result);
    result = AudioUnitUninitialize(audioUnit);
    checkStatus(result);
    result = AudioComponentInstanceDispose(audioUnit);
    
    NSError *error;
    [[AVAudioSession sharedInstance] setActive:NO error:&error];
    
//  JSC  AudioSessionSetActive(false);
    
    checkStatus(result);
    audioUnit = NULL;
}

@end




