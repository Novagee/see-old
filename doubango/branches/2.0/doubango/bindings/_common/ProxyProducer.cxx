

/**@file ProxyProducer.c
 * @brief Audio/Video proxy producers.
 *

 *

 */
#include "ProxyProducer.h"

#include "tsk_memory.h"
#include "tsk_debug.h"



/* ============ Audio Media Producer Interface ================= */
typedef struct twrap_producer_proxy_audio_s
{
		
	uint64_t id;
	tsk_bool_t started;
}
twrap_producer_proxy_audio_t;
#define TWRAP_PRODUCER_PROXY_AUDIO(self) ((twrap_producer_proxy_audio_t*)(self))

int twrap_producer_proxy_audio_set(tmedia_producer_t* self, const tmedia_param_t* params)
{
	return 0;
}

int twrap_producer_proxy_audio_prepare(tmedia_producer_t* self, const tmedia_codec_t* codec)
{
	ProxyPluginMgr* manager;
	int ret = -1;
	if(codec && (manager = ProxyPluginMgr::getInstance())){
		const ProxyAudioProducer* audioProducer;
		if((audioProducer = manager->findAudioProducer(TWRAP_PRODUCER_PROXY_AUDIO(self)->id)) && audioProducer->getCallback()){
			self->audio.channels = codec->plugin->audio.channels;
			self->audio.rate = codec->plugin->rate;
			self->audio.ptime = codec->plugin->audio.ptime;
			ret = audioProducer->getCallback()->prepare((int)codec->plugin->audio.ptime, codec->plugin->rate, codec->plugin->audio.channels);
		}
	}
	return ret;
}

int twrap_producer_proxy_audio_start(tmedia_producer_t* self)
{
	ProxyPluginMgr* manager;
	int ret = -1;
	if((manager = ProxyPluginMgr::getInstance())){
		const ProxyAudioProducer* audioProducer;
		if((audioProducer = manager->findAudioProducer(TWRAP_PRODUCER_PROXY_AUDIO(self)->id)) && audioProducer->getCallback()){
			ret = audioProducer->getCallback()->start();
		}
	}
	
	TWRAP_PRODUCER_PROXY_AUDIO(self)->started = (ret == 0);
	return ret;
}

int twrap_producer_proxy_audio_pause(tmedia_producer_t* self)
{
	ProxyPluginMgr* manager;
	int ret = -1;
	if((manager = ProxyPluginMgr::getInstance())){
		const ProxyAudioProducer* audioProducer;
		if((audioProducer = manager->findAudioProducer(TWRAP_PRODUCER_PROXY_AUDIO(self)->id)) && audioProducer->getCallback()){
			ret = audioProducer->getCallback()->pause();
		}
	}
	return ret;
}

int twrap_producer_proxy_audio_stop(tmedia_producer_t* self)
{
	ProxyPluginMgr* manager;
	int ret = -1;
	if((manager = ProxyPluginMgr::getInstance())){
		const ProxyAudioProducer* audioProducer;
		if((audioProducer = manager->findAudioProducer(TWRAP_PRODUCER_PROXY_AUDIO(self)->id)) && audioProducer->getCallback()){
			ret = audioProducer->getCallback()->stop();
		}
	}
	TWRAP_PRODUCER_PROXY_AUDIO(self)->started = (ret == 0) ? tsk_false : tsk_true;
	return ret;
}


//
//	Audio producer object definition
//
/* constructor */
static tsk_object_t* twrap_producer_proxy_audio_ctor(tsk_object_t * self, va_list * app)
{

	return self;
}
/* destructor */
static tsk_object_t* twrap_producer_proxy_audio_dtor(tsk_object_t * self)
{ 
	twrap_producer_proxy_audio_t *producer = (twrap_producer_proxy_audio_t *)self;
	if(producer){

		/* stop */
		if(producer->started){
			twrap_producer_proxy_audio_stop(TMEDIA_PRODUCER(producer));
		}

		/* deinit base */

		/* deinit self */
		
		/* Remove plugin from the manager */
		ProxyPluginMgr* manager = ProxyPluginMgr::getInstance();
		if(manager){
			manager->getCallback()->OnPluginDestroyed(producer->id, twrap_proxy_plugin_audio_producer);
			manager->removePlugin(producer->id);
		}
	}

	return self;
}
/* object definition */
static const tsk_object_def_t twrap_producer_proxy_audio_def_s = 
{
	sizeof(twrap_producer_proxy_audio_t),
	twrap_producer_proxy_audio_ctor, 
	twrap_producer_proxy_audio_dtor,
};
/* plugin definition*/
static const tmedia_producer_plugin_def_t twrap_producer_proxy_audio_plugin_def_s = 
{
	&twrap_producer_proxy_audio_def_s,
	
	tmedia_audio,
	"Audio Proxy Producer",
	
	twrap_producer_proxy_audio_set,
	twrap_producer_proxy_audio_prepare,
	twrap_producer_proxy_audio_start,
	twrap_producer_proxy_audio_pause,
	twrap_producer_proxy_audio_stop
};

const tmedia_producer_plugin_def_t *twrap_producer_proxy_audio_plugin_def_t = &twrap_producer_proxy_audio_plugin_def_s;



/* ============ ProxyAudioProducer Class ================= */
ProxyAudioProducer::ProxyAudioProducer(twrap_producer_proxy_audio_t* pProducer)
:m_pCallback(tsk_null), m_pWrappedPlugin(pProducer), ProxyPlugin(twrap_proxy_plugin_audio_producer)
{
	m_pWrappedPlugin->id = this->getId();
	m_PushBuffer.pPushBufferPtr = tsk_null;
	m_PushBuffer.nPushBufferSize = 0;
}

ProxyAudioProducer::~ProxyAudioProducer()
{
}

bool ProxyAudioProducer::setPushBuffer(const void* pPushBufferPtr, unsigned nPushBufferSize)
{
	m_PushBuffer.pPushBufferPtr = pPushBufferPtr;
	m_PushBuffer.nPushBufferSize = nPushBufferSize;
	return true;
}

int ProxyAudioProducer::push(const void* _pBuffer/*=tsk_null*/, unsigned _nSize/*=0*/)
{
	if(m_pWrappedPlugin && TMEDIA_PRODUCER(m_pWrappedPlugin)->enc_cb.callback){
		const void* pBuffer;
		unsigned nSize;
		if(_pBuffer && _nSize){
			pBuffer = _pBuffer, nSize = _nSize;
		}
		else{
			pBuffer = m_PushBuffer.pPushBufferPtr, nSize = m_PushBuffer.nPushBufferSize;
		}
		return TMEDIA_PRODUCER(m_pWrappedPlugin)->enc_cb.callback(TMEDIA_PRODUCER(m_pWrappedPlugin)->enc_cb.callback_data, pBuffer, nSize);
	}
	return 0;
}

bool ProxyAudioProducer::setGain(unsigned nGain)
{
	if(m_pWrappedPlugin){
		// see also: MediaSessionMgr.producerSetInt32(org.doubango.tinyWRAP.twrap_media_type_t.twrap_media_audio, "gain", nGain);
		TMEDIA_PRODUCER(m_pWrappedPlugin)->audio.gain = TSK_MIN(nGain,14);
		return true;
	}
	return false;
}

unsigned ProxyAudioProducer::getGain()
{
	if(m_pWrappedPlugin){
		return TMEDIA_PRODUCER(m_pWrappedPlugin)->audio.gain;
	}
	return 0;
}

bool ProxyAudioProducer::registerPlugin()
{
	/* HACK: Unregister all other audio plugins */
	tmedia_producer_plugin_unregister_by_type(tmedia_audio);
	/* Register our proxy plugin */
	return (tmedia_producer_plugin_register(twrap_producer_proxy_audio_plugin_def_t) == 0);
}


























/* ============ Video Media Producer Interface ================= */
typedef struct twrap_producer_proxy_video_s
{
	TMEDIA_DECLARE_PRODUCER;

	int rotation;
	uint64_t id;
	tsk_bool_t started;
}
twrap_producer_proxy_video_t;
#define TWRAP_PRODUCER_PROXY_VIDEO(self) ((twrap_producer_proxy_video_t*)(self))

int twrap_producer_proxy_video_set(tmedia_producer_t* self, const tmedia_param_t* params)
{
	return 0;
}

int twrap_producer_proxy_video_prepare(tmedia_producer_t* self, const tmedia_codec_t* codec)
{

	
	return 0;
}

int twrap_producer_proxy_video_start(tmedia_producer_t* self)
{
	ProxyPluginMgr* manager;
	int ret = -1;
	if((manager = ProxyPluginMgr::getInstance())){
		const ProxyVideoProducer* videoProducer;
		if((videoProducer = manager->findVideoProducer(TWRAP_PRODUCER_PROXY_VIDEO(self)->id)) && videoProducer->getCallback()){
			ret = videoProducer->getCallback()->start();
		}
	}
	
	TWRAP_PRODUCER_PROXY_VIDEO(self)->started = (ret == 0);
	return ret;
}

int twrap_producer_proxy_video_pause(tmedia_producer_t* self)
{
	ProxyPluginMgr* manager;
	int ret = -1;
	if((manager = ProxyPluginMgr::getInstance())){
		const ProxyVideoProducer* videoProducer;
		if((videoProducer = manager->findVideoProducer(TWRAP_PRODUCER_PROXY_VIDEO(self)->id)) && videoProducer->getCallback()){
			ret = videoProducer->getCallback()->pause();
		}
	}
	
	return ret;
}

int twrap_producer_proxy_video_stop(tmedia_producer_t* self)
{
	ProxyPluginMgr* manager;
	int ret = -1;
	if((manager = ProxyPluginMgr::getInstance())){
		const ProxyVideoProducer* videoProducer;
		if((videoProducer = manager->findVideoProducer(TWRAP_PRODUCER_PROXY_VIDEO(self)->id)) && videoProducer->getCallback()){
			ret = videoProducer->getCallback()->stop();
		}
	}
	
	TWRAP_PRODUCER_PROXY_VIDEO(self)->started = (ret == 0) ? tsk_false : tsk_true;
	return ret;
}


//
//	Video producer object definition
//
/* constructor */
static tsk_object_t* twrap_producer_proxy_video_ctor(tsk_object_t * self, va_list * app)
{
	twrap_producer_proxy_video_t *producer = (twrap_producer_proxy_video_t *)self;
	if(producer){
		/* init base */
		tmedia_producer_init(TMEDIA_PRODUCER(producer));
		/* init self */

		/* Add the plugin to the manager */
		ProxyPluginMgr* manager = ProxyPluginMgr::getInstance();
		if(manager){
			ProxyPlugin* proxyProducer = new ProxyVideoProducer(ProxyVideoProducer::getDefaultChroma(), producer);
			uint64_t id = proxyProducer->getId();
			manager->addPlugin(&proxyProducer);
			manager->getCallback()->OnPluginCreated(id, twrap_proxy_plugin_video_producer);
		}
	}
	return self;
}
/* destructor */
static tsk_object_t* twrap_producer_proxy_video_dtor(tsk_object_t * self)
{ 
	twrap_producer_proxy_video_t *producer = (twrap_producer_proxy_video_t *)self;
	if(producer){

		/* stop */
		if(producer->started){
			twrap_producer_proxy_video_stop(TMEDIA_PRODUCER(producer));
		}

		/* deinit base */
		tmedia_producer_deinit(TMEDIA_PRODUCER(producer));
		/* deinit self */
		
		/* Remove plugin from the manager */
		ProxyPluginMgr* manager = ProxyPluginMgr::getInstance();
		if(manager){
			manager->getCallback()->OnPluginDestroyed(producer->id, twrap_proxy_plugin_video_producer);
			manager->removePlugin(producer->id);
		}
	}

	return self;
}
/* object definition */
static const tsk_object_def_t twrap_producer_proxy_video_def_s = 
{
	sizeof(twrap_producer_proxy_video_t),
	twrap_producer_proxy_video_ctor, 
	twrap_producer_proxy_video_dtor,
	tsk_null, 
};
/* plugin definition*/
static const tmedia_producer_plugin_def_t twrap_producer_proxy_video_plugin_def_s = 
{
	&twrap_producer_proxy_video_def_s,
	
	tmedia_video,
	"Video Proxy Producer",
	
	twrap_producer_proxy_video_set,
	twrap_producer_proxy_video_prepare,
	twrap_producer_proxy_video_start,
	twrap_producer_proxy_video_pause,
	twrap_producer_proxy_video_stop
};

const tmedia_producer_plugin_def_t *twrap_producer_proxy_video_plugin_def_t = &twrap_producer_proxy_video_plugin_def_s;



/* ============ ProxyVideoProducer Class ================= */
tmedia_chroma_t ProxyVideoProducer::s_eDefaultChroma = tmedia_chroma_nv21;

ProxyVideoProducer::ProxyVideoProducer(tmedia_chroma_t eChroma, struct twrap_producer_proxy_video_s* pProducer)
:m_pCallback(tsk_null), m_eChroma(eChroma), m_nRotation(0), m_pWrappedPlugin(pProducer), ProxyPlugin(twrap_proxy_plugin_video_producer)
{
	if(m_pWrappedPlugin){
		m_pWrappedPlugin->id = this->getId();
	}
}

ProxyVideoProducer::~ProxyVideoProducer()
{
}

int ProxyVideoProducer::getRotation()const
{
	return m_nRotation;
}

bool ProxyVideoProducer::setRotation(int nRot)
{
	m_nRotation = nRot;
	if(m_pWrappedPlugin){
		TMEDIA_PRODUCER(m_pWrappedPlugin)->video.rotation = m_nRotation;
		return true;
	}
	return false;
}

// alert the encoder which size your camera is using because it's very hard to retrieve it from send(buffer, size) function
// this function is only needed if the actual size (output from your camera) is different than the negociated one
bool ProxyVideoProducer::setActualCameraOutputSize(unsigned nWidth, unsigned nHeight)
{
	if(m_pWrappedPlugin){
		TMEDIA_PRODUCER(m_pWrappedPlugin)->video.width = nWidth;
		TMEDIA_PRODUCER(m_pWrappedPlugin)->video.height = nHeight;
		return true;
	}
	return false;
}

// encode() then send()
int ProxyVideoProducer::push(const void* pBuffer, unsigned nSize)
{
	if(m_pWrappedPlugin && TMEDIA_PRODUCER(m_pWrappedPlugin)->enc_cb.callback){
		return TMEDIA_PRODUCER(m_pWrappedPlugin)->enc_cb.callback(TMEDIA_PRODUCER(m_pWrappedPlugin)->enc_cb.callback_data, pBuffer, nSize);
	}
	return 0;
}

// send() "as is"
int ProxyVideoProducer::send(const void* pBuffer, unsigned nSize, unsigned nDuration, bool bMarker)
{
	if(m_pWrappedPlugin && TMEDIA_PRODUCER(m_pWrappedPlugin)->raw_cb.callback){
		return TMEDIA_PRODUCER(m_pWrappedPlugin)->raw_cb.callback(TMEDIA_PRODUCER(m_pWrappedPlugin)->raw_cb.callback_data, pBuffer, nSize, nDuration, bMarker);
	}
	return 0;
}

tmedia_chroma_t ProxyVideoProducer::getChroma()const
{
	return m_eChroma;
}

bool ProxyVideoProducer::registerPlugin()
{
	/* HACK: Unregister all other video plugins */
	tmedia_producer_plugin_unregister_by_type(tmedia_video);
	/* Register our proxy plugin */
	return (tmedia_producer_plugin_register(twrap_producer_proxy_video_plugin_def_t) == 0);
}
