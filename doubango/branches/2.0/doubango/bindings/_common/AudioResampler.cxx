

/**@file AudioResampler.cxx
 * @brief Audio resampler
 *

 */
#include "AudioResampler.h"

#include "tinymedia/tmedia_resampler.h"

#include "tsk_debug.h"

AudioResampler::AudioResampler(uint32_t nInFreq, uint32_t nOutFreq, uint32_t nFrameDuration, uint32_t nChannels, uint32_t nQuality):
m_nOutFreq(nOutFreq), 
m_nInFreq(nInFreq), 
m_nFrameDuration(nFrameDuration), 
m_nChannels(nChannels),
m_nQuality(nQuality)
{
	if((m_pWrappedResampler = tmedia_resampler_create())){
		int ret;
		if((ret = tmedia_resampler_open(m_pWrappedResampler, nInFreq, nOutFreq, nFrameDuration, nChannels, m_nQuality))){
			TSK_DEBUG_ERROR("Failed to open audio resampler (%d)", ret);
			TSK_OBJECT_SAFE_FREE(m_pWrappedResampler);
		}
	}
	else{
		TSK_DEBUG_ERROR("No audio resampler could be found. Did you forget to call tdav_init()?");
	}
}

AudioResampler::~AudioResampler()
{
	TSK_OBJECT_SAFE_FREE(m_pWrappedResampler);
}

uint32_t AudioResampler::process(const void* pInData, uint32_t nInSizeInBytes, void* pOutData, uint32_t nOutSizeInBytes)
{
	if(!m_pWrappedResampler){
		TSK_DEBUG_ERROR("Embedded resampler is invalid");
		return 0;
	}
	if(nInSizeInBytes < getInputRequiredSizeInShort()/2){
		TSK_DEBUG_ERROR("Input buffer is too short");
		return 0;
	}
	if(nOutSizeInBytes < getOutputRequiredSizeInShort()/2){
		TSK_DEBUG_ERROR("Output buffer is too short");
		return 0;
	}
	return 2*tmedia_resampler_process(m_pWrappedResampler, (uint16_t*)pInData, nInSizeInBytes/2, (uint16_t*)pOutData, nOutSizeInBytes/2);
}
