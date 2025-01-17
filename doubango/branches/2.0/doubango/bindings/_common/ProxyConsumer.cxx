

/**@file ProxyConsumer.c
 * @brief Audio/Video proxy consumers.
 *

 *

 */
#include "ProxyConsumer.h"

#include "AudioResampler.h"

#include "tsk_memory.h"
#include "tsk_debug.h"



/* ============ Audio Consumer Interface ================= */

typedef struct twrap_consumer_proxy_audio_s
{

	uint64_t id;
	tsk_bool_t started;
}
twrap_consumer_proxy_audio_t;
#define TWRAP_CONSUMER_PROXY_AUDIO(self) ((twrap_consumer_proxy_audio_t*)(self))

int twrap_consumer_proxy_audio_set(tmedia_consumer_t* self, const tmedia_param_t* params)
{
	return 0;
}

int twrap_consumer_proxy_audio_prepare(tmedia_consumer_t* self, const tmedia_codec_t* codec)
{
	ProxyPluginMgr* manager;
	int ret = -1;
	if(codec && (manager = ProxyPluginMgr::getInstance())){
		const ProxyAudioConsumer* audioConsumer;
		if((audioConsumer = manager->findAudioConsumer(TWRAP_CONSUMER_PROXY_AUDIO(self)->id)) && audioConsumer->getCallback()){
			self->audio.ptime = codec->plugin->audio.ptime;
			self->audio.in.channels = codec->plugin->audio.channels;
			self->audio.in.rate = codec->plugin->rate;
			ret = audioConsumer->getCallback()->prepare((int)codec->plugin->audio.ptime, codec->plugin->rate, codec->plugin->audio.channels);
		}
	}
	
	return ret;
}

int twrap_consumer_proxy_audio_start(tmedia_consumer_t* self)
{
	ProxyPluginMgr* manager;
	int ret = -1;
	if((manager = ProxyPluginMgr::getInstance())){
		const ProxyAudioConsumer* audioConsumer;
		if((audioConsumer = manager->findAudioConsumer(TWRAP_CONSUMER_PROXY_AUDIO(self)->id)) && audioConsumer->getCallback()){
			ret = audioConsumer->getCallback()->start();
		}
	}
	
	TWRAP_CONSUMER_PROXY_AUDIO(self)->started = (ret == 0);
	return ret;
}

int twrap_consumer_proxy_audio_consume(tmedia_consumer_t* self, const void* buffer, tsk_size_t size, const tsk_object_t* proto_hdr)
{

	
	return 0;
}

int twrap_consumer_proxy_audio_pause(tmedia_consumer_t* self)
{
	ProxyPluginMgr* manager;
	int ret = -1;
	if((manager = ProxyPluginMgr::getInstance())){
		const ProxyAudioConsumer* audioConsumer;
		if((audioConsumer = manager->findAudioConsumer(TWRAP_CONSUMER_PROXY_AUDIO(self)->id)) && audioConsumer->getCallback()){
			ret = audioConsumer->getCallback()->pause();
		}
	}
	
	return ret;
}

int twrap_consumer_proxy_audio_stop(tmedia_consumer_t* self)
{
	ProxyPluginMgr* manager;
	int ret = -1;
	if((manager = ProxyPluginMgr::getInstance())){
		const ProxyAudioConsumer* audioConsumer;
		if((audioConsumer = manager->findAudioConsumer(TWRAP_CONSUMER_PROXY_AUDIO(self)->id)) && audioConsumer->getCallback()){
			ret = audioConsumer->getCallback()->stop();
		}
	}
	
	TWRAP_CONSUMER_PROXY_AUDIO(self)->started = (ret == 0) ? tsk_false : tsk_true;
	return ret;
}


//
//	Audio consumer object definition
//
/* constructor */
static tsk_object_t* twrap_consumer_proxy_audio_ctor(tsk_object_t * self, va_list * app)
{

	return self;
}
/* destructor */
static tsk_object_t* twrap_consumer_proxy_audio_dtor(tsk_object_t * self)
{ 

	return self;
}
/* object definition */
static const tsk_object_def_t twrap_consumer_proxy_audio_def_s = 
{

};
/* plugin definition*/
static const tmedia_consumer_plugin_def_t twrap_consumer_proxy_audio_plugin_def_s = 
{
	&twrap_consumer_proxy_audio_def_s,
	
	tmedia_audio,
	"Audio Proxy Consumer",
	
	twrap_consumer_proxy_audio_set,
	twrap_consumer_proxy_audio_prepare,
	twrap_consumer_proxy_audio_start,
	twrap_consumer_proxy_audio_consume,
	twrap_consumer_proxy_audio_pause,
	twrap_consumer_proxy_audio_stop
};

const tmedia_consumer_plugin_def_t *twrap_consumer_proxy_audio_plugin_def_t = &twrap_consumer_proxy_audio_plugin_def_s;



/* ============ ProxyAudioConsumer Class ================= */
ProxyAudioConsumer::ProxyAudioConsumer(twrap_consumer_proxy_audio_t* pConsumer)
:ProxyPlugin(twrap_proxy_plugin_audio_consumer), 
m_pWrappedPlugin(pConsumer), 
m_pCallback(tsk_null)
{

}

ProxyAudioConsumer::~ProxyAudioConsumer()
{

}

bool ProxyAudioConsumer::queryForResampler(uint16_t nInFreq, uint16_t nOutFreq, uint16_t nFrameDuration, uint16_t nChannels, uint16_t nResamplerQuality)
{
	return 0;
}

bool ProxyAudioConsumer::setPullBuffer(const void* pPullBufferPtr, unsigned nPullBufferSize)
{
    return 0;

}

unsigned ProxyAudioConsumer::pull(void* _pOutput/*=tsk_null*/, unsigned _nSize/*=0*/)
{

	return 0;
}

bool ProxyAudioConsumer::setGain(unsigned nGain)
{
    return 0;

}

unsigned ProxyAudioConsumer::getGain()
{
	if(m_pWrappedPlugin){
		return TMEDIA_CONSUMER(m_pWrappedPlugin)->audio.gain;
	}
	return 0;
}

bool ProxyAudioConsumer::reset()
{

	return false;
}

bool ProxyAudioConsumer::registerPlugin()
{
    return 0;

}
































/* ============ Video Consumer Interface ================= */

typedef struct twrap_consumer_proxy_video_s
{
	uint64_t id;
	tsk_bool_t started;
}
twrap_consumer_proxy_video_t;
#define TWRAP_CONSUMER_PROXY_VIDEO(self) ((twrap_consumer_proxy_video_t*)(self))

int twrap_consumer_proxy_video_set(tmedia_consumer_t* self, const tmedia_param_t* params)
{
	return 0;
}

int twrap_consumer_proxy_video_prepare(tmedia_consumer_t* self, const tmedia_codec_t* codec)
{
	ProxyPluginMgr* manager;
	int ret = -1;
	if(codec && (manager = ProxyPluginMgr::getInstance())){
		const ProxyVideoConsumer* videoConsumer;
		if((videoConsumer = manager->findVideoConsumer(TWRAP_CONSUMER_PROXY_VIDEO(self)->id)) && videoConsumer->getCallback()){
			self->video.fps = TMEDIA_CODEC_VIDEO(codec)->in.fps;
			// in
			self->video.in.chroma = tmedia_chroma_yuv420p;
			self->video.in.width = TMEDIA_CODEC_VIDEO(codec)->in.width;
			self->video.in.height = TMEDIA_CODEC_VIDEO(codec)->in.height;
			// display (out)
			self->video.display.chroma = videoConsumer->getChroma();
			self->video.display.auto_resize = videoConsumer->getAutoResizeDisplay();
			if(!self->video.display.width){
				self->video.display.width = self->video.in.width;
			}
			if(!self->video.display.height){
				self->video.display.height = self->video.in.height;
			}
			ret = videoConsumer->getCallback()->prepare(TMEDIA_CODEC_VIDEO(codec)->in.width, TMEDIA_CODEC_VIDEO(codec)->in.height, TMEDIA_CODEC_VIDEO(codec)->in.fps);
		}
	}
	
	return ret;
}

int twrap_consumer_proxy_video_start(tmedia_consumer_t* self)
{
	ProxyPluginMgr* manager;
	int ret = -1;
	if((manager = ProxyPluginMgr::getInstance())){
		const ProxyVideoConsumer* videoConsumer;
		if((videoConsumer = manager->findVideoConsumer(TWRAP_CONSUMER_PROXY_VIDEO(self)->id)) && videoConsumer->getCallback()){
			ret = videoConsumer->getCallback()->start();
		}
	}
	
	TWRAP_CONSUMER_PROXY_VIDEO(self)->started = (ret == 0);
	return ret;
}

int twrap_consumer_proxy_video_consume(tmedia_consumer_t* self, const void* buffer, tsk_size_t size, const tsk_object_t* proto_hdr)
{
	int ret = -1;
	return ret;
}

int twrap_consumer_proxy_video_pause(tmedia_consumer_t* self)
{
	ProxyPluginMgr* manager;
	int ret = -1;
	if((manager = ProxyPluginMgr::getInstance())){
		const ProxyVideoConsumer* videoConsumer;
		if((videoConsumer = manager->findVideoConsumer(TWRAP_CONSUMER_PROXY_VIDEO(self)->id)) && videoConsumer->getCallback()){
			ret = videoConsumer->getCallback()->pause();
		}
	}
	
	return ret;
}

int twrap_consumer_proxy_video_stop(tmedia_consumer_t* self)
{
	ProxyPluginMgr* manager;
	int ret = -1;
	if((manager = ProxyPluginMgr::getInstance())){
		const ProxyVideoConsumer* videoConsumer;
		if((videoConsumer = manager->findVideoConsumer(TWRAP_CONSUMER_PROXY_VIDEO(self)->id)) && videoConsumer->getCallback()){
			ret = videoConsumer->getCallback()->stop();
		}
	}
	
	TWRAP_CONSUMER_PROXY_VIDEO(self)->started = (ret == 0) ? tsk_false : tsk_true;
	return ret;
}


//
//	Video consumer object definition
//
/* constructor */
static tsk_object_t* twrap_consumer_proxy_video_ctor(tsk_object_t * self, va_list * app)
{

	return 0;
}
/* destructor */
static tsk_object_t* twrap_consumer_proxy_video_dtor(tsk_object_t * self)
{ 

	return self;
}
/* object definition */
static const tsk_object_def_t twrap_consumer_proxy_video_def_s = 
{
	sizeof(twrap_consumer_proxy_video_t),
	twrap_consumer_proxy_video_ctor, 
	twrap_consumer_proxy_video_dtor,
	tsk_null, 
};
/* plugin definition*/
static const tmedia_consumer_plugin_def_t twrap_consumer_proxy_video_plugin_def_s = 
{
	&twrap_consumer_proxy_video_def_s,
	
	tmedia_video,
	"Video Proxy Consumer",
	
	twrap_consumer_proxy_video_set,
	twrap_consumer_proxy_video_prepare,
	twrap_consumer_proxy_video_start,
	twrap_consumer_proxy_video_consume,
	twrap_consumer_proxy_video_pause,
	twrap_consumer_proxy_video_stop
};

const tmedia_consumer_plugin_def_t *twrap_consumer_proxy_video_plugin_def_t = &twrap_consumer_proxy_video_plugin_def_s;



/* ============ ProxyVideoConsumer Class ================= */
tmedia_chroma_t ProxyVideoConsumer::s_eDefaultChroma = tmedia_chroma_rgb565le;
bool ProxyVideoConsumer::s_bAutoResizeDisplay = false;

ProxyVideoConsumer::ProxyVideoConsumer(tmedia_chroma_t eChroma, struct twrap_consumer_proxy_video_s* pConsumer)
: m_eChroma(eChroma), 
m_bAutoResizeDisplay(ProxyVideoConsumer::getDefaultAutoResizeDisplay()),
m_pWrappedPlugin(pConsumer), 
m_pCallback(tsk_null), 
ProxyPlugin(twrap_proxy_plugin_video_consumer)
{
	m_pWrappedPlugin->id = this->getId();
	m_ConsumeBuffer.pConsumeBufferPtr = tsk_null;
	m_ConsumeBuffer.nConsumeBufferSize = 0;
}

ProxyVideoConsumer::~ProxyVideoConsumer()
{
}

bool ProxyVideoConsumer::setDisplaySize(unsigned nWidth, unsigned nHeight)
{
	if((m_pWrappedPlugin = (twrap_consumer_proxy_video_t*)tsk_object_ref(m_pWrappedPlugin))){
		TMEDIA_CONSUMER(m_pWrappedPlugin)->video.display.width = nWidth;
		TMEDIA_CONSUMER(m_pWrappedPlugin)->video.display.height = nHeight;
		m_pWrappedPlugin = (twrap_consumer_proxy_video_t*)tsk_object_unref(m_pWrappedPlugin);
		return true;
	}
	TSK_DEBUG_ERROR("This consumer doesn't wrap any plugin");
	return false;
}

unsigned ProxyVideoConsumer::getDisplayWidth()
{
	unsigned displayWidth = 0;
	if((m_pWrappedPlugin = (twrap_consumer_proxy_video_t*)tsk_object_ref(m_pWrappedPlugin))){
		displayWidth = TMEDIA_CONSUMER(m_pWrappedPlugin)->video.display.width;
		m_pWrappedPlugin = (twrap_consumer_proxy_video_t*)tsk_object_unref(m_pWrappedPlugin);
	}
	else{
		TSK_DEBUG_ERROR("This consumer doesn't wrap any plugin");
	}
	return displayWidth;
}

unsigned ProxyVideoConsumer::getDisplayHeight()
{
	unsigned displayHeight = 0;
	if((m_pWrappedPlugin = (twrap_consumer_proxy_video_t*)tsk_object_ref(m_pWrappedPlugin))){
		displayHeight = TMEDIA_CONSUMER(m_pWrappedPlugin)->video.display.height;
		m_pWrappedPlugin = (twrap_consumer_proxy_video_t*)tsk_object_unref(m_pWrappedPlugin);
	}
	else{
		TSK_DEBUG_ERROR("This consumer doesn't wrap any plugin");
	}
	return displayHeight;
}

tmedia_chroma_t ProxyVideoConsumer::getChroma()const
{
	return m_eChroma;
}

bool ProxyVideoConsumer::setAutoResizeDisplay(bool bAutoResizeDisplay){
	if((m_pWrappedPlugin = (twrap_consumer_proxy_video_t*)tsk_object_ref(m_pWrappedPlugin))){
		TMEDIA_CONSUMER(m_pWrappedPlugin)->video.display.auto_resize = bAutoResizeDisplay ? tsk_true : tsk_false;
		m_pWrappedPlugin = (twrap_consumer_proxy_video_t*)tsk_object_unref(m_pWrappedPlugin);
		m_bAutoResizeDisplay = bAutoResizeDisplay;
		return true;
	}
	TSK_DEBUG_ERROR("This consumer doesn't wrap any plugin");
	return false;
}

bool ProxyVideoConsumer::getAutoResizeDisplay()const
{
	return m_bAutoResizeDisplay;
}

bool ProxyVideoConsumer::setConsumeBuffer(const void* pConsumeBufferPtr, unsigned nConsumeBufferSize)
{
	m_ConsumeBuffer.pConsumeBufferPtr = pConsumeBufferPtr;
	m_ConsumeBuffer.nConsumeBufferSize = nConsumeBufferSize;
	return true;
}

unsigned ProxyVideoConsumer::copyBuffer(const void* pBuffer, unsigned nSize)const
{
	unsigned nRetsize = 0;

	return nRetsize;
}

unsigned ProxyVideoConsumer::pull(void* pOutput, unsigned nSize)
{

	return 0;
}

bool ProxyVideoConsumer::reset()
{
	bool ret = false;

	return ret;
}

bool ProxyVideoConsumer::registerPlugin()
{
	/* HACK: Unregister all other video plugins */
	tmedia_consumer_plugin_unregister_by_type(tmedia_video);
	/* Register our proxy plugin */
	return (tmedia_consumer_plugin_register(twrap_consumer_proxy_video_plugin_def_t) == 0);
}



ProxyVideoFrame::ProxyVideoFrame(const void* pBuffer, unsigned nSize)
{
	m_pBuffer = pBuffer;
	m_nSize = nSize;
}

ProxyVideoFrame::~ProxyVideoFrame()
{
}

unsigned ProxyVideoFrame::getSize()
{
	return m_nSize;
}

unsigned ProxyVideoFrame::getContent(void* pOutput, unsigned nMaxsize)
{
	unsigned nRetsize = 0;

	return nRetsize;
}
