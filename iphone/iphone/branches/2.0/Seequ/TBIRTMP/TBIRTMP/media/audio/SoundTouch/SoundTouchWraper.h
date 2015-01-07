//
//  SoundTouchWraper.h
//  soundtest
//
//  Created by Grigori Jlavyan on 11/5/12.
//  Copyright (c) 2012 Administrator. All rights reserved.
//

#ifndef __SoundTouchWraper_h
#define __SoundTouchWraper_h

#include <stdio.h>
#include <stdint.h>

# ifdef __cplusplus
extern "C"
{
#endif // __cplusplus
    
    typedef struct SoundEffect_s
    {
        void* soundTouch;
        void* pTDStretch;
        float tempo;
        int nChannels;
        
    } SoundEffect_t;
    
    SoundEffect_t* open_SoundTouchWraper(uint32_t srate, uint32_t channels);
    int process_SoundTouchWraper(SoundEffect_t* soundEffect, uint8_t *inBuffer, int inLen, uint8_t **outBuffer, int* maxOutBufSize, float tempo);
    int process_with_flush_SoundTouchWraper(SoundEffect_t* soundEffect, uint8_t **outBuffer, int* maxOutBufSize, float tempo);
    int process_with_flush_SoundTouchWraper1(SoundEffect_t* soundEffect, uint8_t *inBuffer, int inLen, uint8_t **outBuffer, int* maxOutBufSize, float tempo);
    void close_SoundTouchWraper(SoundEffect_t** soundEffect);

    int process_correct_SoundTouchWraper(uint8_t *inBuffer, int inLen, uint8_t *outBuffer, int outBufSize);
    int process_correct_revers_SoundTouchWraper(uint8_t *inBuffer, int inLen, uint8_t *outBuffer, int outBufSize);

# ifdef __cplusplus
}
#endif // __cplusplus
#endif // __SoundTouchWraper_h
