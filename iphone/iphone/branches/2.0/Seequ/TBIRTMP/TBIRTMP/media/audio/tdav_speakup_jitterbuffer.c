

/**@file tdav_speakup_jitterbuffer.c
 * @brief Speakup Audio jitterbuffer Plugin
 *
 
 
 */
#include "tdav_speakup_jitterbuffer.h"
//#include "tinyrtp/rtp/trtp_rtp_header.h"
#include "media_codec.h"
#include <string.h>

#if TSK_UNDER_WINDOWS
#       include <Winsock2.h> // timeval
#elif defined(__SYMBIAN32__)
#       include <_timeval.h> 
#else
#       include <sys/time.h>
#endif

#define TDAV_SPEAKUP_10MS						10
#define TDAV_SPEAKUP_10MS_FRAME_SIZE(self)		(((self)->rate * TDAV_SPEAKUP_10MS)/1000)
#define TDAV_SPEAKUP_PTIME_FRAME_SIZE(self)		(((self)->rate * (self)->framesize)/1000)

static int tdav_speakup_jitterbuffer_set(tdav_speakup_jitterbuffer_t *self)
{
	//TSK_DEBUG_ERROR("Not implemented");
	return -2;
}

TBI_size_t tdav_speakup_jitterbuffer_open(tdav_speakup_jitterbuffer_t* self, uint32_t frame_duration, uint32_t rate)
{
	tdav_speakup_jitterbuffer_t *jitterbuffer = (tdav_speakup_jitterbuffer_t *)self;
	if(!jitterbuffer->jbuffer){
		if(!(jitterbuffer->jbuffer = jb_new())){
			//TSK_DEBUG_ERROR("Failed to create new buffer");
			return -1;
		}
		jitterbuffer->jcodec = JB_CODEC_OTHER;
	}
    jitterbuffer->jbuffer = malloc(sizeof(jitterbuffer));
    memset(jitterbuffer->jbuffer, 0, sizeof(jitterbuffer));
    
    jitterbuffer->jbuffer->settings.min_jb = JB_MIN_SIZE;
    jitterbuffer->jbuffer->settings.max_jb = JB_MAX_SIZE;
    jitterbuffer->jbuffer->settings.max_successive_interp = JB_MAX_SUCCESSIVE_INTERP;
    jitterbuffer->jbuffer->settings.extra_delay = JB_ALLOW_EXTRA_DELAY;
    jitterbuffer->jbuffer->settings.wait_grow = JB_WAIT_GROW;
    jitterbuffer->jbuffer->settings.wait_shrink = JB_WAIT_SHRINK;
    jitterbuffer->jbuffer->settings.max_diff = JB_MAX_DIFF;
    jitterbuffer->jbuffer->controlframes = 0;
    jitterbuffer->jbuffer->voiceframes = 0;
    jitterbuffer->jbuffer->hist_pointer = 0; //start over
    jitterbuffer->jbuffer->silence_begin_ts = 0; //no begin_ts defined
    jitterbuffer->jbuffer->info.silence =1; //we always start in silence
    
	jitterbuffer->ref_timestamp = 0;
	jitterbuffer->frame_duration = frame_duration;
	jitterbuffer->rate = rate;
	jitterbuffer->_10ms_size_bytes = 160 * (rate/8000);
    jitterbuffer->jcodec = JB_CODEC_OTHER;
    
	return 0;
}

static int tdav_speakup_jitterbuffer_tick(tdav_speakup_jitterbuffer_t* self)
{
	return 0;
}

TBI_size_t tdav_speakup_jitterbuffer_put(tdav_speakup_jitterbuffer_t* self, void* data, TBI_size_t data_size,void* proto_hdr)
{
//	tdav_speakup_jitterbuffer_t *jitterbuffer = (tdav_speakup_jitterbuffer_t *)self;
//	const void* rtp_hdr = 0;
//    int i;
//    long now, ts;
//    void* _10ms_buf;
//	uint8_t* pdata;
//    
//    
//	if(!self || !data || !data_size || !jitterbuffer->jbuffer){
//		TBI_DEBUG_ERROR("Invalid parameter");
//		return -1;
//	}
//    
//	/* synchronize the reference timestamp */
//	if(!jitterbuffer->ref_timestamp){
//		uint64_t now = TBI_time_now();
//		struct timeval tv;
//		long ts = (rtp_hdr->timestamp/(jitterbuffer->rate/1000));
//		//=> Do not use (see clock_gettime() on linux): tsk_gettimeofday(&tv, tsk_null);
//		tv.tv_sec = (long)(now)/1000;
//		tv.tv_usec = (long)(now - (tv.tv_sec*1000))*1000;
//        
//		tv.tv_sec -= (ts / jitterbuffer->rate);
//		tv.tv_usec -= (ts % jitterbuffer->rate) * 125;
//		if((tv.tv_usec -= (tv.tv_usec % (TDAV_SPEAKUP_10MS * 10000))) <0){
//			tv.tv_usec += 1000000;
//			tv.tv_sec -= 1;
//            
//		}
//		jitterbuffer->ref_timestamp = TBI_time_get_ms(&tv);
//        
//		switch(rtp_hdr->payload_type){
//			case 8: /*TMEDIA_CODEC_FORMAT_G711a*/
//			case 0: /* TMEDIA_CODEC_FORMAT_G711u */
//				jitterbuffer->jcodec = JB_CODEC_G711x;
//				break;
//			case 18: /* TMEDIA_CODEC_FORMAT_G729 */
//				jitterbuffer->jcodec = JB_CODEC_G729A;
//				break;
//			case 3: /* TMEDIA_CODEC_FORMAT_GSM */
//				jitterbuffer->jcodec = JB_CODEC_GSM_EFR;
//				break;
//			default:
//				jitterbuffer->jcodec = JB_CODEC_OTHER;
//				break;
//		}
//	}
//    
//	// split as several 10ms frames
//	now = (long) (TBI_time_now()-jitterbuffer->ref_timestamp);
//	ts = (long)(rtp_hdr->timestamp/(jitterbuffer->rate/1000));
//	pdata = (uint8_t*)data;
//	for(i=0; i<(int)(data_size/jitterbuffer->_10ms_size_bytes);i++){
//		if((_10ms_buf = TBI_calloc(jitterbuffer->_10ms_size_bytes, 1))){
//			memcpy(_10ms_buf, &pdata[i*jitterbuffer->_10ms_size_bytes], jitterbuffer->_10ms_size_bytes);
//            if((int*)(jitterbuffer->jbuffer) != 0){
//			jb_put(jitterbuffer->jbuffer, _10ms_buf, JB_TYPE_VOICE, TDAV_SPEAKUP_10MS, ts, now, jitterbuffer->jcodec);
//            }
//			_10ms_buf = TBI_null;
//		}
//		ts += TDAV_SPEAKUP_10MS;
//	}
//    
//#ifdef TDAV_HAVE_NETWORK_STATIC
//    if(jitterbuffer->__jitterbuffer__.callBack_function)
//    {
//        jb_info test;
//        jb_get_info(jitterbuffer->jbuffer,&test);
//        if(test.frames_received%40==0)
//            jitterbuffer->__jitterbuffer__.callBack_function(&test);
//    }
//#endif 
    
	return 0;
}


TBI_size_t tdav_speakup_jitterbuffer_get(tdav_speakup_jitterbuffer_t* self, void* out_data, TBI_size_t out_size,void* proto_hdr)
{
	tdav_speakup_jitterbuffer_t *jitterbuffer = (tdav_speakup_jitterbuffer_t *)self;
	int jret;
    
	int i, _10ms_count;
	long now;
	short* _10ms_buf = TBI_null;
	uint8_t* pout_data = (uint8_t*)out_data;
    
	if(!out_data || (out_size % jitterbuffer->_10ms_size_bytes)){
		TBI_DEBUG_ERROR("Invalid parameter");
		return 0;
	}

	_10ms_count = (out_size/jitterbuffer->_10ms_size_bytes);
	now = (long) (TBI_time_now() - jitterbuffer->ref_timestamp);
	for(i=0; i<_10ms_count; i++){
        
		jret = jb_get(jitterbuffer->jbuffer, (void**)&_10ms_buf, now, TDAV_SPEAKUP_10MS);
		switch(jret){
			case JB_INTERP:
				TBI_DEBUG_INFO("JB_INTERP");
				jb_reset_all(jitterbuffer->jbuffer);
				//memset(&pout_data[i*jitterbuffer->_10ms_size_bytes], 0, (_10ms_count*jitterbuffer->_10ms_size_bytes)-(i*jitterbuffer->_10ms_size_bytes));
                memset(&pout_data[i*jitterbuffer->_10ms_size_bytes], 0, (_10ms_count*jitterbuffer->_10ms_size_bytes)-(i*jitterbuffer->_10ms_size_bytes));
                //                if(i>0){
                //                    memset(&pout_data[i*jitterbuffer->_10ms_size_bytes], pout_data[(i-1)*jitterbuffer->_10ms_size_bytes], (_10ms_count*jitterbuffer->_10ms_size_bytes)-(i*jitterbuffer->_10ms_size_bytes));
                //                }
                //                else{
                //                    memset(&pout_data[i*jitterbuffer->_10ms_size_bytes], 0x00, (_10ms_count*jitterbuffer->_10ms_size_bytes)-(i*jitterbuffer->_10ms_size_bytes));
                //                }
				i = _10ms_count; // for exit
				break;
			case JB_OK:
			case JB_EMPTY:
			case JB_NOFRAME:
			case JB_NOJB:
            {
                if(_10ms_buf && (jret == JB_OK)){
                    /* copy data */
                    memcpy(&pout_data[i*jitterbuffer->_10ms_size_bytes], _10ms_buf, jitterbuffer->_10ms_size_bytes);
                }
                else{
                    /* copy silence */
                    memset(&pout_data[i*jitterbuffer->_10ms_size_bytes], 0, jitterbuffer->_10ms_size_bytes);
                    //                    if(i>0){
                    //                        memset(&pout_data[i*jitterbuffer->_10ms_size_bytes], pout_data[(i-1)*jitterbuffer->_10ms_size_bytes], jitterbuffer->_10ms_size_bytes);
                    //                    }else{
                    //                        memset(&pout_data[i*jitterbuffer->_10ms_size_bytes], 0x00, jitterbuffer->_10ms_size_bytes);
                    //                    }
                }
            }
			default:
				break;
		}
		TBI_FREE(_10ms_buf);
	}
    
	return (_10ms_count * jitterbuffer->_10ms_size_bytes);
}

static int tdav_speakup_jitterbuffer_reset(tdav_speakup_jitterbuffer_t* self)
{
	tdav_speakup_jitterbuffer_t *jitterbuffer = (tdav_speakup_jitterbuffer_t *)self;
	if(jitterbuffer->jbuffer){
		jb_reset_all(jitterbuffer->jbuffer);
		return 0;
	}
	else{
		TBI_DEBUG_ERROR("invalid parameter");
		return -1;
	}
}

static int tdav_speakup_jitterbuffer_close(tdav_speakup_jitterbuffer_t* self)
{
	tdav_speakup_jitterbuffer_t *jitterbuffer = (tdav_speakup_jitterbuffer_t *)self;
	if(jitterbuffer->jbuffer){
		jb_destroy(jitterbuffer->jbuffer);
		jitterbuffer->jbuffer = TBI_null;
	}
	return 0;
}



//
//	Speakup jitterbufferr Plugin definition
//

/* constructor */
static tdav_speakup_jitterbuffer_t* tdav_speakup_jitterbuffer_ctor(tdav_speakup_jitterbuffer_t * self, va_list * app)
{
	tdav_speakup_jitterbuffer_t *jitterbuffer = self;
	if(jitterbuffer){
		/* init base */
		tmedia_jitterbuffer_init(jitterbuffer);
		/* init self */
	}
	return self;
}
/* destructor */
static tdav_speakup_jitterbuffer_t* tdav_speakup_jitterbuffer_dtor(tdav_speakup_jitterbuffer_t * self)
{ 
	tdav_speakup_jitterbuffer_t *jitterbuffer = self;
	if(jitterbuffer){
		/* deinit base */
		tmedia_jitterbuffer_deinit(TMEDIA_JITTER_BUFFER(jitterbuffer));
		/* deinit self */
		if(jitterbuffer->jbuffer){
			jb_destroy(jitterbuffer->jbuffer);
			jitterbuffer->jbuffer = TBI_null;
		}
	}
    
	return self;
}
///* object definition */
//static const TBI_object_def_t tdav_speakup_jitterbuffer_def_s =
//{
//	sizeof(tdav_speakup_jitterbuffer_t),
//	tdav_speakup_jitterbuffer_ctor, 
//	tdav_speakup_jitterbuffer_dtor,
//	TBI_null,
//};
///* plugin definition*/
//static const tmedia_jitterbuffer_plugin_def_t tdav_speakup_jitterbuffer_plugin_def_s = 
//{
//	&tdav_speakup_jitterbuffer_def_s,
//	tmedia_audio,
//	"Audio/video JitterBuffer based on Speex",
//	
//	tdav_speakup_jitterbuffer_set,
//	tdav_speakup_jitterbuffer_open,
//	tdav_speakup_jitterbuffer_tick,
//	tdav_speakup_jitterbuffer_put,
//	tdav_speakup_jitterbuffer_get,
//	tdav_speakup_jitterbuffer_reset,
//	tdav_speakup_jitterbuffer_close,
//};
//const tmedia_jitterbuffer_plugin_def_t *tdav_speakup_jitterbuffer_plugin_def_t = &tdav_speakup_jitterbuffer_plugin_def_s;

