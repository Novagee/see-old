//
//  SoundTouchWraper.cpp
//  soundtest
//
//  Created by Grigori Jlavyan on 11/5/12.
//  Copyright (c) 2012 Administrator. All rights reserved.
//

#include "SoundTouchWraper.h"
#include "SoundTouch.h"
#include "TDStretch.h"

#include <string.h>

using namespace soundtouch;

SoundEffect_t* open_SoundTouchWraper(uint32_t srate, uint32_t channels)
{
    SoundTouch* pSoundTouch = new SoundTouch();
    
    pSoundTouch->setSampleRate(srate);
    pSoundTouch->setChannels(channels);
    
    pSoundTouch->setTempoChange(0);
    pSoundTouch->setPitchSemiTones(0);
    pSoundTouch->setRateChange(0);
    
    pSoundTouch->setSetting(SETTING_USE_QUICKSEEK, 0);
    pSoundTouch->setSetting(SETTING_USE_AA_FILTER, 0);
    
    if (/*params->speech*/ 1 )
    {
        // use settings for speech processing
        pSoundTouch->setSetting(SETTING_SEQUENCE_MS, 20);
        pSoundTouch->setSetting(SETTING_SEEKWINDOW_MS, 15);
        pSoundTouch->setSetting(SETTING_OVERLAP_MS, 8);
    }
    
    SoundEffect_t* soundEffect = (SoundEffect_t*)malloc(sizeof(SoundEffect_t));
    soundEffect->soundTouch = (void*)pSoundTouch;
    soundEffect->tempo = 0;
    soundEffect->nChannels = channels;
    
    TDStretch* ptdStretch = TDStretch::newInstance();
    ptdStretch->setParameters(8000, 20, 15, 8);
    ptdStretch->setChannels(1);
    
    soundEffect->pTDStretch = ptdStretch;
    
    return soundEffect;
}

void close_SoundTouchWraper(SoundEffect_t** soundEffect)
{
    if(!(*soundEffect))
        return;
    
    delete (SoundTouch*)((*soundEffect)->soundTouch);
    (*soundEffect)->soundTouch = 0;
    
    delete (TDStretch*)((*soundEffect)->pTDStretch);
    (*soundEffect)->pTDStretch = 0;
    
    free(*soundEffect);
    *soundEffect = 0;
}

int process_SoundTouchWraper(SoundEffect_t* soundEffect, uint8_t *inBuffer, int inLen, uint8_t **outBuffer, int* maxOutBufSize, float tempo)
{
    int sampelsCnt = 0;
    int nInSamples;
    int nOutSamples;
    
    if (soundEffect == NULL || soundEffect->soundTouch == NULL || inBuffer == NULL || outBuffer == NULL)
        return -1;
    
    SoundTouch* pSoundTouch = (SoundTouch*)soundEffect->soundTouch;
    SAMPLETYPE* sampleBuffer = (SAMPLETYPE*)inBuffer;
    nInSamples = inLen / (sizeof(SAMPLETYPE) * soundEffect->nChannels);
    
    pSoundTouch->setTempoChange(tempo);
    
    // Feed the samples into SoundTouch processor
    pSoundTouch->putSamples(sampleBuffer, nInSamples);
    
    // Read ready samples from SoundTouch processor & write them output file.
    // NOTES:
    // - 'receiveSamples' doesn't necessarily return any samples at all
    //   during some rounds!
    // - On the other hand, during some round 'receiveSamples' may have more
    //   ready samples than would fit into 'sampleBuffer', and for this reason
    //   the 'receiveSamples' call is iterated for as many times as it
    //   outputs samples.

    sampelsCnt = pSoundTouch->numSamples();
    if(!(*outBuffer) || (*maxOutBufSize < (sampelsCnt * sizeof(SAMPLETYPE))))
    {
        *maxOutBufSize = sampelsCnt * sizeof(SAMPLETYPE);
        *outBuffer = (uint8_t*)realloc(*outBuffer, *maxOutBufSize);
    }
    nOutSamples = pSoundTouch->receiveSamples((SAMPLETYPE*)(*outBuffer), sampelsCnt);

    // Now the input file is processed, yet 'flush' few last samples that are
    // hiding in the SoundTouch's internal processing pipeline.
//    pSoundTouch->flush();
//    do
//    {
//        nOutSamples = pSoundTouch->receiveSamples(outSampleBuffer, 1024);
//        if(nOutSamples > 0)
//        {
//            len = nOutSamples * sizeof(SAMPLETYPE) * soundEffect->nChannels;
//            *outBuffer = (uint8_t*)realloc(*outBuffer, size + len);
//            memcpy((*outBuffer) + size, outSampleBuffer, len);
//            size += len;
//        }
//    } while (nOutSamples != 0);
    
    return nOutSamples * sizeof(SAMPLETYPE);
}

int process_with_flush_SoundTouchWraper(SoundEffect_t* soundEffect, uint8_t **outBuffer, int* maxOutBufSize, float tempo)
{
    int sampelsCnt = 0;
    int nOutSamples;
    
    if (soundEffect == NULL || soundEffect->soundTouch == NULL || outBuffer == NULL)
        return -1;
    
    SoundTouch* pSoundTouch = (SoundTouch*)soundEffect->soundTouch;
    pSoundTouch->setTempoChange(tempo);
    
    pSoundTouch->flush();
    sampelsCnt = pSoundTouch->numSamples();
    if(!(*outBuffer) || (*maxOutBufSize < (sampelsCnt * sizeof(SAMPLETYPE))))
    {
        *maxOutBufSize = sampelsCnt * sizeof(SAMPLETYPE);
        *outBuffer = (uint8_t*)realloc(*outBuffer, *maxOutBufSize);
    }
    nOutSamples = pSoundTouch->receiveSamples((SAMPLETYPE*)(*outBuffer), sampelsCnt);
    
    for (int i = nOutSamples - 1; i >= 0; i--)
    {
        if(((SAMPLETYPE*)*outBuffer)[i] != 0)
            break;
        
        nOutSamples--;
    }
    
    printf("process_with_flush_SoundTouchWraper before = %d after = %d\n", sampelsCnt, nOutSamples);

    return nOutSamples * sizeof(SAMPLETYPE);
}

int process_with_flush_SoundTouchWraper1(SoundEffect_t* soundEffect, uint8_t *inBuffer, int inLen, uint8_t **outBuffer, int* maxOutBufSize, float tempo)
{
    int sampelsCnt = 0;
    int nInSamples;
    int nOutSamples;
    
    if (soundEffect == NULL || soundEffect->soundTouch == NULL || inBuffer == NULL || outBuffer == NULL)
        return -1;
    
    SoundTouch* pSoundTouch = (SoundTouch*)soundEffect->soundTouch;
    SAMPLETYPE* sampleBuffer = (SAMPLETYPE*)inBuffer;
    nInSamples = inLen / (sizeof(SAMPLETYPE) * soundEffect->nChannels);
    
    pSoundTouch->setTempoChange(tempo);
    
    // Feed the samples into SoundTouch processor
    pSoundTouch->putSamples(sampleBuffer, nInSamples);
    
    // Read ready samples from SoundTouch processor & write them output file.
    // NOTES:
    // - 'receiveSamples' doesn't necessarily return any samples at all
    //   during some rounds!
    // - On the other hand, during some round 'receiveSamples' may have more
    //   ready samples than would fit into 'sampleBuffer', and for this reason
    //   the 'receiveSamples' call is iterated for as many times as it
    //   outputs samples.
    
    pSoundTouch->flush();
    sampelsCnt = pSoundTouch->numSamples();
    if(!(*outBuffer) || (*maxOutBufSize < (sampelsCnt * sizeof(SAMPLETYPE))))
    {
        *maxOutBufSize = sampelsCnt * sizeof(SAMPLETYPE);
        *outBuffer = (uint8_t*)realloc(*outBuffer, *maxOutBufSize);
    }
    nOutSamples = pSoundTouch->receiveSamples((SAMPLETYPE*)(*outBuffer), sampelsCnt);
    
    for (int i = nOutSamples - 1; i >= 0; i--)
    {
        if(((SAMPLETYPE*)*outBuffer)[i] != 0)
            break;
        
        nOutSamples--;
    }
//    printf("process_with_flush_SoundTouchWraper1 before = %d after = %d\n", sampelsCnt, nOutSamples);
    
    return nOutSamples * sizeof(SAMPLETYPE);
}

int process_correct_SoundTouchWraper(uint8_t *inBuffer, int inLen, uint8_t *outBuffer, int outBufSize)
{
    int i;
    int overlapLength = inLen/sizeof(SAMPLETYPE);
    
    SAMPLETYPE m1;
    
    m1 = (SAMPLETYPE)0;
    
    SAMPLETYPE* pIn = (SAMPLETYPE*)inBuffer;
    SAMPLETYPE* pOut = (SAMPLETYPE*)outBuffer;
    
    for (i = 0; i < overlapLength; i ++)
    {
        pOut[i] = (pIn[i] * m1) / overlapLength;
        m1 += 1;
    }

    return inLen;
}

int process_correct_revers_SoundTouchWraper(uint8_t *inBuffer, int inLen, uint8_t *outBuffer, int outBufSize)
{
    int i;
    int overlapLength = inLen/sizeof(SAMPLETYPE);
    
    SAMPLETYPE m1;
    
    m1 = (SAMPLETYPE)overlapLength;
    
    SAMPLETYPE* pIn = (SAMPLETYPE*)inBuffer;
    SAMPLETYPE* pOut = (SAMPLETYPE*)outBuffer;
    
    for (i = 0; i < overlapLength ; i ++)
    {
        pOut[i] = (pIn[i] * m1) / overlapLength;
        m1 -= 1;
    }

    return inLen;
}




