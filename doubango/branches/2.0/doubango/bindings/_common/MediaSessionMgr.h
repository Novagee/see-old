
#ifndef TINYWRAP_MEDIA_SESSIONMGR_H
#define TINYWRAP_MEDIA_SESSIONMGR_H

#include "tinymedia.h"
#include "Common.h"

class ProxyPlugin;

class MediaSessionMgr
{
public:
#if !defined(SWIG)
	MediaSessionMgr(tmedia_session_mgr_t* pWrappedMgr);
#endif
	virtual ~MediaSessionMgr();

public:
	bool sessionSetInt32(twrap_media_type_t media, const char* key, int32_t value);

	bool consumerSetInt32(twrap_media_type_t media, const char* key, int32_t value);
	bool consumerSetInt64(twrap_media_type_t media, const char* key, int64_t value);

	bool producerSetInt32(twrap_media_type_t media, const char* key, int32_t value);
	bool producerSetInt64(twrap_media_type_t media, const char* key, int64_t value);

#if !defined(SWIG)
	const ProxyPlugin* findProxyPlugin(twrap_media_type_t media, bool consumer)const;
#endif
    const void callBackFunctionInfo(void*);
    
	const ProxyPlugin* findProxyPluginConsumer(twrap_media_type_t media)const{
		return this->findProxyPlugin(media, true);
	}
	const ProxyPlugin* findProxyPluginProducer(twrap_media_type_t media)const{
		return this->findProxyPlugin(media, false);
	}

	uint64_t getSessionId(twrap_media_type_t media)const;
	
	// Defaults
	static bool defaultsSetBandwidthLevel(tmedia_bandwidth_level_t bl);
	static tmedia_bandwidth_level_t defaultsGetBandwidthLevel();
	static bool defaultsSetEchoTail(uint32_t echo_tail);
	static uint32_t defaultsGetEchoTail();
	static bool defaultsSetEchoSkew(uint32_t echo_skew);
	static bool defaultsSetEchoSuppEnabled(bool echo_supp_enabled);
	static bool defaultsGetEchoSuppEnabled();
	static bool defaultsSetAgcEnabled(bool agc_enabled);
	static bool defaultsGetAgcEnabled();
	static bool defaultsSetAgcLevel(float agc_level);
	static float defaultsGetAgcLevel();
	static bool defaultsSetVadEnabled(bool vad_enabled);
	static bool defaultsGetGetVadEnabled();
	static bool defaultsSetNoiseSuppEnabled(bool noise_supp_enabled);
	static bool defaultsGetNoiseSuppEnabled();
	static bool defaultsSetNoiseSuppLevel(int32_t noise_supp_level);
	static int32_t defaultsGetNoiseSuppLevel();
	static bool defaultsSet100relEnabled(bool _100rel_enabled);
	static bool defaultsGet100relEnabled();
	static bool defaultsSetScreenSize(int32_t sx, int32_t sy);
	static bool defaultsSetAudioGain(int32_t producer_gain, int32_t consumer_gain);
	static bool setMaxQueuePacketCount(int nMaxPktCount);
	static int getMaxQueuePacketCount();
	static void SetBackgroundState(tsk_bool_t background_state);

    
private:
	tmedia_session_mgr_t* m_pWrappedMgr;
};

#endif /* TINYWRAP_MEDIA_SESSIONMGR_H */
