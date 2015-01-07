/*
 *  Created by Grigori Jlavyan .
 *  Copyright 2011 BeInteractive. All rights reserved.
 *
 */

#include "media_codec_vp8.h"
#include "TBIRTMP.h"

#if HAVE_LIBVPX


//#include "tinyrtp/rtp/trtp_rtp_packet.h"

#include "TBI_memory.h"
#include "TBI_time.h"
#include "TBI_debug.h"
#include "TBI_object.h"

#include <memory.h>


#define TDAV_VP8_PAY_DESC_SIZE				1 /* |X|R|N|S|PartID| */
#define TDAV_SYSTEM_CORES_COUNT				1
#define TDAV_VP8_GOP_SIZE_IN_SECONDS		1
#define TDAV_VP8_RTP_PAYLOAD_MAX_SIZE		1050
#if !defined(TDAV_VP8_MAX_BANDWIDTH_KB)
#	define TDAV_VP8_MAX_BANDWIDTH_KB			6000
#endif
#if !defined(TDAV_VP8_MIN_BANDWIDTH_KB)
#	define TDAV_VP8_MIN_BANDWIDTH_KB			100
#endif

#define vp8_interface_enc (vpx_codec_vp8_cx())
#define vp8_interface_dec (vpx_codec_vp8_dx())

static void media_codec_vp8_encap(media_codec_t* self, const vpx_codec_cx_pkt_t *pkt);
static void media_codec_vp8_rtp_callback(media_codec_t *self, const void *data, tbi_size_t size, uint32_t partID, tbi_bool_t part_start, tbi_bool_t non_ref, tbi_bool_t last);
static int media_codec_vp8_instance_restart(vp8_encoder_instance_t* self, int w, int h);
static vp8_encoder_instance_t* media_codec_vp8_encoder_instance_new(int w, int h, int bitrate);
static int media_codec_vp8_encoder_instance_open(vp8_encoder_instance_t* vp8,tbi_bool_t isLandscape);
static int media_codec_vp8_encoder_instance_close(vp8_encoder_instance_t* self);
static int media_codec_vp8_decoder_instance_close(vp8_decoder_instance_t* self);
static tbi_size_t media_codec_vp8_instance_encode(media_codec_t* self, const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size,tbi_bool_t isLandscape);
static tbi_size_t media_codec_vp8_instance_decode(media_codec_t* self, const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size);
static tbi_size_t media_codec_vp8_bitrate_change(media_codec_t* self, tbi_bool_t isDown,double bitrate);
static int media_codec_vp8_decoder_instance_open(vp8_decoder_instance_t* vp8 ,int width, int height);
/* ============ VP8 Plugin interface ================= */

static int media_codec_vp8_open(media_codec_t* self)
{
    //TBI_DEBUG_INFO("media_codec_vp8_open start");
    
    if(!self){
    	TBI_DEBUG_ERROR("Invalid parameter");
    	return -1;
    }
    int bitrate1,bitrate2, bitrate3;
    
//    2G and earlier	 115 kb/s
//    3g	 220 kb/s
//    4g	 300 kb/s
//    LTE	 440 kb/s
//    WiFi	 700 kb/s
    // 0 = No wifi or cellular
    // 1 = 2G and earlier? (not confirmed)
    // 2 = 3G? (not yet confirmed)
    // 3 = 4G
    // 4 = LTE
    // 5 = Wifi
    
//    switch (self->networkType) {
//        case 1:{ //     2G
//            bitrate1 = 100 ;
//            bitrate2 = 120 ;
//            bitrate3 = 140 ;
//        }
//        break;
//        case 2:{ //     3G
//            bitrate1 = 200 ;
//            bitrate2 = 220 ;
//            bitrate3 = 240 ;
//        }
//            break;
//        case 3:{ //     4G
//            bitrate1 = 280 ;
//            bitrate2 = 300 ;
//            bitrate3 = 320 ;
//        }
//            break;
//        case 4:{ //     LTE
//            bitrate1 = 420 ;
//            bitrate2 = 440 ;
//            bitrate3 = 460 ;
//        }
//            break;
//        case 5:{ //     Wifi
//            bitrate1 = 680 ;
//            bitrate2 = 700 ;
//            bitrate3 = 720 ;
//        }
//            break;
//        default:{ //    not detected
//            bitrate1 = 180 ;
//            bitrate2 = 200 ;
//            bitrate3 = 220 ;
//        }
//    }
    
    bitrate1 = MIN_BITRATE ;
    bitrate2 = MIN_BITRATE ;
    bitrate3 = MIN_BITRATE ;

    // RTMP_CALL_EVENT_TYPE_REQUEST_TERMINATE

    media_codec_vp8_t* vp8 =  (media_codec_vp8_t*)calloc(1, sizeof(media_codec_vp8_t));
    vp8->isClosed = tbi_true;
    vp8->changeForNext = TBI_false;
    
    vp8->instance1 = media_codec_vp8_encoder_instance_new(self->video.width, self->video.height, bitrate1);// (vp8_instance_t*)calloc(1, sizeof(vp8_instance_t));
    vp8->instance2 = media_codec_vp8_encoder_instance_new(self->video.width, self->video.height, bitrate2);
    vp8->instance3 = media_codec_vp8_encoder_instance_new(self->video.width, self->video.height, bitrate3);
    vp8->decoderInstance = (vp8_decoder_instance_t*)calloc(1, sizeof(vp8_decoder_instance_t));
    
    self->codec = vp8;
    vp8->chage = TBI_mutex_create();
    
    vp8->instance1->intanse = INSTANCE_1;
    vp8->instance2->intanse = INSTANCE_2;
    vp8->instance3->intanse = INSTANCE_3;
    
    TBI_bool_t bIsLandscape = (self->video.width > self->video.height);

    media_codec_vp8_encoder_instance_open(vp8->instance1, bIsLandscape);
    media_codec_vp8_encoder_instance_open(vp8->instance2, bIsLandscape);
    media_codec_vp8_encoder_instance_open(vp8->instance3, bIsLandscape);
    
    vp8->currentInstance = vp8->instance2;
    media_codec_vp8_decoder_instance_open(vp8->decoderInstance , vp8->currentInstance->out.width, vp8->currentInstance->out.height);
    
    vp8->isClosed = tbi_false;
     //TBI_DEBUG_INFO("media_codec_vp8_open end");
	return 0;
}

static int media_codec_vp8_decoder_instance_open(vp8_decoder_instance_t* vp8 ,int width, int height){
    //TBI_DEBUG_INFO("media_codec_vp8_encoder_instance_open start");
    
    vpx_codec_err_t vpx_ret;
    vpx_codec_flags_t dec_flags = 0;
	vpx_codec_caps_t dec_caps;
	vpx_codec_dec_cfg_t dec_cfg;
    
    static vp8_postproc_cfg_t __pp = { VP8_DEBLOCK | VP8_DEMACROBLOCK, 4, 0};
    
    //
	// Decoder
	//
	dec_cfg.w =width;
	dec_cfg.h = height;
	dec_cfg.threads = TDAV_SYSTEM_CORES_COUNT;
    
	dec_caps = vpx_codec_get_caps(&vpx_codec_vp8_dx_algo);
	if(dec_caps & VPX_CODEC_CAP_POSTPROC){
		dec_flags |= VPX_CODEC_USE_POSTPROC;
	}
	if(dec_caps & VPX_CODEC_CAP_ERROR_CONCEALMENT){
		dec_flags |= VPX_CODEC_USE_ERROR_CONCEALMENT;
	}
    
    
    if(vp8->decoder.initialized){
        if((vpx_ret = vpx_codec_destroy(&vp8->decoder.context)) != VPX_CODEC_OK){
            TBI_DEBUG_ERROR("vpx_codec_destroy decoder failed with error =%s", vpx_codec_err_to_string(vpx_ret));
        }
    }
    
    if((vpx_ret = vpx_codec_dec_init(&vp8->decoder.context, vp8_interface_dec, &dec_cfg, dec_flags)) != VPX_CODEC_OK){
        TBI_DEBUG_ERROR("vpx_codec_dec_init failed with error =%s", vpx_codec_err_to_string(vpx_ret));
        return -4;
    }
    
    if((vpx_ret = vpx_codec_control(&vp8->decoder.context, VP8_SET_POSTPROC, &__pp))){
        //        TBI_DEBUG_WARN("vpx_codec_control failed with error =%s", vpx_codec_err_to_string(vpx_ret));
    }
    vp8->decoder.initialized = tbi_true;
    //TBI_DEBUG_INFO("media_codec_vp8_encoder_instance_open end");
    return 0;
}
static int media_codec_vp8_encoder_instance_open(vp8_encoder_instance_t* vp8 , tbi_bool_t isLandscape){

    
    //TBI_DEBUG_INFO("media_codec_vp8_encoder_instance_open start");
//    if(vp8->isLandscape != isLandscape)
//    {
//        int nTmp = vp8->out.width;
//        vp8->out.width = vp8->out.height;
//        vp8->out.height = nTmp;
//        vp8->isLandscape = isLandscape;
//    }
    
    media_codec_vp8_instance_restart(vp8, vp8->out.width, vp8->out.height);
    
    vp8->forceKeyFrame = tbi_true;
    
    //TBI_DEBUG_INFO("media_codec_vp8_encoder_instance_open end");
    return 0;
}

static tbi_size_t media_codec_vp8_bitrate_change(media_codec_t* self, tbi_bool_t isDown,double bitrate){
    //TBI_DEBUG_INFO("media_codec_vp8_bitrate_change");

    media_codec_vp8_t *vp8 = (media_codec_vp8_t*)self->codec;
    int step = bitrate;
    int minimumStep = 10;
    
    native_debug_function("[vp8]{media_codec_vp8_bitrate_change} START | current:%d, change:%f, new:%d", vp8->currentInstance->bitrate, bitrate, vp8->currentInstance->bitrate + step);
    
    if(abs(step)<minimumStep) {
        native_debug_function("[vp8]{media_codec_vp8_bitrate_change} END | CHANGE MINIMUM NOT MEET (%d !> %d)", step, minimumStep);
        return 0;
    }
    
    if((vp8->currentInstance->bitrate == MIN_BITRATE && bitrate<0)  || (vp8->currentInstance->bitrate == MAX_BITRATE && bitrate>0)){
        native_debug_function("[vp8]{media_codec_vp8_bitrate_change} END | NO CHANGES - LIMIT REACHED (%d < 20 OR %d > 720)", vp8->currentInstance->bitrate + step);
        return 0;
    }
    

       
//    //fprintf(stderr, "****************** current bit-rate == %d\n", vp8->currentInstance->bitrate + step );
//    
//    vp8_encoder_instance_t *newInstance = (vp8_encoder_instance_t*)calloc(1, sizeof(vp8_encoder_instance_t));
//    newInstance->bitrate = vp8->currentInstance->bitrate + step;
//    newInstance->out.width = vp8->currentInstance->out.width;
//    newInstance->out.height = vp8->currentInstance->out.height;
//    newInstance->isResChanged=vp8->currentInstance->isResChanged;
//        
//    native_debug_function("[vp8]{media_codec_vp8_out.width- %d} END media_codec_vp8_current_out.width -%d", newInstance->out.width, vp8->currentInstance->out.width);
//    native_debug_function("[vp8]{media_codec_vp8_out.height- %d} END media_codec_vp8_current_out.heght -%d", newInstance->out.height, vp8->currentInstance->out.height);
//
//    if((vp8->currentInstance->bitrate + step) < MIN_BITRATE)
//    {
//        newInstance->bitrate = MIN_BITRATE ;
//    }
//    if((vp8->currentInstance->bitrate + step) > MAX_BITRATE)
//    {
//        newInstance->bitrate = MAX_BITRATE ;
//    }
//    
//    media_codec_vp8_encoder_instance_open(newInstance, (newInstance->out.width > newInstance->out.height));
//    newInstance->forceKeyFrame = tbi_true;
//    
//    vp8->currentInstance->forceKeyFrame = tbi_true;
//
//    if(vp8->instance1)
//        TBI_FREE(vp8->instance1);
//    
//    vp8->instance1 = newInstance;
    vp8->currentInstance->bitrate += step;
    vp8->changeForNext = tbi_true;
    
    
//    if(isDown){
//        if( vp8->currentInstance->bitrate - step < 20 ){
//            native_debug_function("media_codec_vp8_bitrate_change end limmit");
//            return 0;
//        }
//        
//        vp8->currentInstance = vp8->instance2;
//        vp8->instance2 = vp8->instance1;
//        media_codec_vp8_encoder_instance_close(vp8->instance3);
//        free(vp8->instance3);
//        vp8->instance3 = vp8->currentInstance;
//        vp8->instance1 = (vp8_instance_t*)calloc(1, sizeof(vp8_instance_t));
//        vp8->instance1->bitrate = vp8->instance2->bitrate - step;
//        media_codec_vp8_instance_open(vp8->instance1,vp8->instance2->isLandscape);
//        vp8->currentInstance->forceKeyFrame = tbi_true;
//    }else{
//        if(vp8->currentInstance->bitrate + step > 720){
//            native_debug_function("media_codec_vp8_bitrate_change end limmit");
//            return 0;
//        }
//        vp8->currentInstance = vp8->instance2;
//        vp8->instance2 = vp8->instance3;
//        media_codec_vp8_encoder_instance_close(vp8->instance1);
//        free(vp8->instance1);
//        vp8->instance1 = vp8->currentInstance;
//        vp8->instance3 = (vp8_instance_t*)calloc(1, sizeof(vp8_instance_t));
//        vp8->instance3->bitrate = vp8->instance2->bitrate + step;
//        media_codec_vp8_instance_open(vp8->instance3,vp8->instance2->isLandscape);
//        vp8->currentInstance->forceKeyFrame = tbi_true;
//        
//    }
    
//    vp8->currentInstance = vp8->instance2;
    
    native_debug_function("[vp8]{media_codec_vp8_bitrate_change} END | CHANGES APPLIED");
    
    
    
    /// Old version
//    media_codec_vp8_t *vp8 = (media_codec_vp8_t*)self->codec;
//    int step = 40;
//    
//    //fprintf(stderr, "****************** current bit-rate == %d\n", vp8->currentInstance->bitrate + step );
//    native_debug_function("################################ media_codec_vp8_bitrate_change start    %f",bitrate);
//    
//    
//    
//    if(isDown){
//        if( vp8->currentInstance->bitrate - step < 20 ){
//            native_debug_function("media_codec_vp8_bitrate_change end limmit");
//            return 0;
//        }
//        
//        vp8->currentInstance = vp8->instance2;
//        vp8->instance2 = vp8->instance1;
//        media_codec_vp8_encoder_instance_close(vp8->instance3);
//        free(vp8->instance3);
//        vp8->instance3 = vp8->currentInstance;
//        vp8->instance1 = (vp8_instance_t*)calloc(1, sizeof(vp8_instance_t));
//        vp8->instance1->bitrate = vp8->instance2->bitrate - step;
//        media_codec_vp8_instance_open(vp8->instance1,vp8->instance2->isLandscape);
//        vp8->currentInstance->forceKeyFrame = tbi_true;
//    }else{
//        if(vp8->currentInstance->bitrate + step > 720){
//            native_debug_function("media_codec_vp8_bitrate_change end limmit");
//            return 0;
//        }
//        vp8->currentInstance = vp8->instance2;
//        vp8->instance2 = vp8->instance3;
//        media_codec_vp8_encoder_instance_close(vp8->instance1);
//        free(vp8->instance1);
//        vp8->instance1 = vp8->currentInstance;
//        vp8->instance3 = (vp8_instance_t*)calloc(1, sizeof(vp8_instance_t));
//        vp8->instance3->bitrate = vp8->instance2->bitrate + step;
//        media_codec_vp8_instance_open(vp8->instance3,vp8->instance2->isLandscape);
//        vp8->currentInstance->forceKeyFrame = tbi_true;
//
//    }
//    
//        vp8->currentInstance = vp8->instance2;
//    
//    native_debug_function("media_codec_vp8_bitrate_change end %i",vp8->currentInstance->bitrate);
    
    return 0;
}

static int media_codec_vp8_bitrate_get(media_codec_t* self)
{
    if(!self || !self->codec)
        return -1;
    
    media_codec_vp8_t *vp8 = (media_codec_vp8_t*)self->codec;
    return vp8->currentInstance->bitrate;
}

static vp8_encoder_instance_t* media_codec_vp8_encoder_instance_new(int w, int h, int bitrate)
{
    //TBI_DEBUG_INFO("media_codec_vp8_encoder_instance_new");
    vp8_encoder_instance_t* vp8 = (vp8_encoder_instance_t*)calloc(1, sizeof(vp8_encoder_instance_t));
    vp8->bitrate = bitrate;
    int fps = 12 ;
	vpx_codec_enc_cfg_t enc_cfg;
	vpx_enc_frame_flags_t enc_flags;
	vpx_codec_err_t vpx_ret;
	/* the caller (base class) already checked that the codec is not opened */
	//
	//	Encoder
	//
	if((vpx_ret = vpx_codec_enc_config_default(vp8_interface_enc, &enc_cfg, 0)) != VPX_CODEC_OK){
		TBI_DEBUG_ERROR("vpx_codec_enc_config_default failed with error =%s", vpx_codec_err_to_string(vpx_ret));
		return 0;
	}
    //TBI_DEBUG_INFO("out.fps === %d, out.width === %d, out.height === %d", 12,w, h);
	enc_cfg.g_timebase.num = 1;
	enc_cfg.g_timebase.den = fps;
    enc_cfg.rc_target_bitrate = bitrate;//TBI_CLAMP(TDAV_VP8_MIN_BANDWIDTH_KB, enc_cfg.rc_target_bitrate>>=0, TDAV_VP8_MAX_BANDWIDTH_KB);
    enc_cfg.rc_end_usage = VPX_CBR;
	enc_cfg.g_w = w; //TMEDIA_CODEC_VIDEO(vp8)->out.width;
	enc_cfg.g_h = h; //TMEDIA_CODEC_VIDEO(vp8)->out.height;
	enc_cfg.kf_mode = VPX_KF_AUTO;
	enc_cfg.g_error_resilient = VPX_ERROR_RESILIENT_DEFAULT;
	enc_cfg.g_lag_in_frames = 0;
#if TDAV_UNDER_WINDOWS
	{
		SYSTEM_INFO SystemInfo;
		GetSystemInfo(&SystemInfo);
		enc_cfg.g_threads = SystemInfo.dwNumberOfProcessors;
	}
#else
	enc_cfg.g_threads = TDAV_SYSTEM_CORES_COUNT;
#endif
	enc_cfg.g_pass = VPX_RC_ONE_PASS;
	enc_cfg.rc_min_quantizer = TBI_CLAMP(enc_cfg.rc_min_quantizer, 20, enc_cfg.rc_max_quantizer);
	enc_cfg.rc_max_quantizer = TBI_CLAMP(enc_cfg.rc_min_quantizer, 51, enc_cfg.rc_max_quantizer);
	enc_cfg.rc_resize_allowed = 0;
	//enc_cfg.g_profile = 1;
    
	enc_flags = 0; //VPX_EFLAG_XXX
    
	if((vpx_ret = vpx_codec_enc_init(&vp8->encoder.context, vp8_interface_enc, &enc_cfg, enc_flags)) != VPX_CODEC_OK){
		TBI_DEBUG_ERROR("vpx_codec_enc_init failed with error =%s", vpx_codec_err_to_string(vpx_ret));
		return 0;
	}
    
	vp8->encoder.pic_id = (rand() ^ rand()) % 0x7FFF;
	vp8->encoder.gop_size = TDAV_VP8_GOP_SIZE_IN_SECONDS * fps;
	vp8->encoder.initialized = tbi_true;
    vpx_codec_control(&vp8->encoder.context, VP8E_SET_CPUUSED, 6);
	//vpx_codec_control(&vp8->encoder.context, VP8E_SET_SHARPNESS, 7);
	//vpx_codec_control(&vp8->encoder.context, VP8E_SET_ENABLEAUTOALTREF, 1);
    
    vp8->out.width = w;
    vp8->out.height = h;
//    vp8->isResChanged = TBI_false;
    
    return vp8;
}

static int media_codec_vp8_instance_restart(vp8_encoder_instance_t* self, int w, int h)
{
    //TBI_DEBUG_INFO("media_codec_vp8_instance_restart start");
    vp8_encoder_instance_t* vp8 = self;
    int fps = 12 ;
	vpx_codec_enc_cfg_t enc_cfg;
	vpx_enc_frame_flags_t enc_flags;
	vpx_codec_err_t vpx_ret;
	/* the caller (base class) already checked that the codec is not opened */
	//
	//	Encoder
	//
	if((vpx_ret = vpx_codec_enc_config_default(vp8_interface_enc, &enc_cfg, 0)) != VPX_CODEC_OK){
		TBI_DEBUG_ERROR("vpx_codec_enc_config_default failed with error =%s", vpx_codec_err_to_string(vpx_ret));
		return -2;
	}
    //TBI_DEBUG_INFO("out.fps === %d, out.width === %d, out.height === %d", 12,w, h);
	enc_cfg.g_timebase.num = 1;
	enc_cfg.g_timebase.den = fps;
    enc_cfg.rc_target_bitrate = self->bitrate;//TBI_CLAMP(TDAV_VP8_MIN_BANDWIDTH_KB, enc_cfg.rc_target_bitrate>>=0, TDAV_VP8_MAX_BANDWIDTH_KB);
    enc_cfg.rc_end_usage = VPX_CBR;
	enc_cfg.g_w = w; //TMEDIA_CODEC_VIDEO(vp8)->out.width;
	enc_cfg.g_h = h; //TMEDIA_CODEC_VIDEO(vp8)->out.height;
	enc_cfg.kf_mode = VPX_KF_AUTO;
	enc_cfg.g_error_resilient = VPX_ERROR_RESILIENT_DEFAULT;
	enc_cfg.g_lag_in_frames = 0;
#if TDAV_UNDER_WINDOWS
	{
		SYSTEM_INFO SystemInfo;
		GetSystemInfo(&SystemInfo);
		enc_cfg.g_threads = SystemInfo.dwNumberOfProcessors;
	}
#else
	enc_cfg.g_threads = TDAV_SYSTEM_CORES_COUNT;
#endif
	enc_cfg.g_pass = VPX_RC_ONE_PASS;
	enc_cfg.rc_min_quantizer = TBI_CLAMP(enc_cfg.rc_min_quantizer, 20, enc_cfg.rc_max_quantizer);
	enc_cfg.rc_max_quantizer = TBI_CLAMP(enc_cfg.rc_min_quantizer, 51, enc_cfg.rc_max_quantizer);
	enc_cfg.rc_resize_allowed = 0;
	//enc_cfg.g_profile = 1;
    
	enc_flags = 0; //VPX_EFLAG_XXX
    
    if(vp8->encoder.initialized){
        if((vpx_ret = vpx_codec_destroy(&vp8->encoder.context)) != VPX_CODEC_OK){
            TBI_DEBUG_ERROR("vpx_codec_destroy encoder failed with error =%s", vpx_codec_err_to_string(vpx_ret));
        }
        vp8->encoder.initialized = tbi_false;
    }
    
	if((vpx_ret = vpx_codec_enc_init(&vp8->encoder.context, vp8_interface_enc, &enc_cfg, enc_flags)) != VPX_CODEC_OK){
		TBI_DEBUG_ERROR("vpx_codec_enc_init failed with error =%s", vpx_codec_err_to_string(vpx_ret));
		return -3;
	}

    
	vp8->encoder.pic_id = (rand() ^ rand()) % 0x7FFF;
	vp8->encoder.gop_size = TDAV_VP8_GOP_SIZE_IN_SECONDS * fps;
	vp8->encoder.initialized = tbi_true;
    vpx_codec_control(&vp8->encoder.context, VP8E_SET_CPUUSED, 6);
	//vpx_codec_control(&vp8->encoder.context, VP8E_SET_SHARPNESS, 7);
	//vpx_codec_control(&vp8->encoder.context, VP8E_SET_ENABLEAUTOALTREF, 1);
    
    

        
    
    //TBI_DEBUG_INFO("media_codec_vp8_instance_restart end");
    return 0;
}



static int media_codec_vp8_close(media_codec_t* self)
{
    //TBI_DEBUG_INFO("media_codec_vp8_close");
    if(!self->codec)
        return 0;
    
	media_codec_vp8_t* vp8 = (media_codec_vp8_t*)self->codec;
    vp8->isClosed = tbi_true;
    
    media_codec_vp8_encoder_instance_close(vp8->instance1);
    media_codec_vp8_encoder_instance_close(vp8->instance2);
    media_codec_vp8_encoder_instance_close(vp8->instance3);
    media_codec_vp8_decoder_instance_close(vp8->decoderInstance);
    
    
	return 0;
}

static int media_codec_vp8_encoder_instance_close(vp8_encoder_instance_t* self)
{
    //TBI_DEBUG_INFO("media_codec_vp8_encoder_instance_close");
    vp8_encoder_instance_t* vp8 = (vp8_encoder_instance_t*)self;
    if(!vp8){
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	
    vpx_codec_err_t vpx_ret;
    
	if(vp8->encoder.initialized){
        if((vpx_ret = vpx_codec_destroy(&vp8->encoder.context)) != VPX_CODEC_OK){
            TBI_DEBUG_ERROR("vpx_codec_destroy encoder failed with error =%s", vpx_codec_err_to_string(vpx_ret));
        }
        
        //		vpx_codec_destroy(&vp8->encoder.context);
		vp8->encoder.initialized = tbi_false;
	}

    return 0;
}

static int media_codec_vp8_decoder_instance_close(vp8_decoder_instance_t* self){
    
    vp8_decoder_instance_t* vp8 = (vp8_decoder_instance_t*)self;
    
    if(!vp8){
		TBI_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	
    vpx_codec_err_t vpx_ret;

    
    if(vp8->decoder.initialized){
        if((vpx_ret = vpx_codec_destroy(&vp8->decoder.context)) != VPX_CODEC_OK){
            TBI_DEBUG_ERROR("vpx_codec_destroy decoder failed with error =%s", vpx_codec_err_to_string(vpx_ret));
        }
        
        //		vpx_codec_destroy(&vp8->decoder.context);
		vp8->decoder.initialized = tbi_false;
	}
    
	TBI_FREE(vp8->decoder.accumulator);
	vp8->decoder.accumulator_pos = 0;
    return 0;
}

static tbi_size_t media_codec_vp8_encode(media_codec_t* self, const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size)
{
    media_codec_vp8_t* vp8 = (media_codec_vp8_t*)self->codec;
    //    static int counter = 0 ;
    //    counter++;
    //    if(vp8->currentInstance->bitrate < 400 && counter > 100){
    //
    //        TBI_DEBUG_INFO("current bit rate %i",vp8->currentInstance->bitrate);
    //        media_codec_vp8_bitrate_change(self,0);
    //        counter = 0;
    //    }

    tbi_size_t val = 0 ;
    
    if(!vp8->isClosed)
    {
        if(vp8->changeForNext)
        {
            vp8->changeForNext = TBI_false;
            vp8->currentInstance->forceKeyFrame = TBI_true;
            media_codec_vp8_instance_restart(vp8->currentInstance, vp8->currentInstance->out.width, vp8->currentInstance->out.height);
        }

//        if(vp8->changeForNext){
//            
//            
//            vp8->changeForNext = TBI_false;
//            vp8_encoder_instance_t *oldInstance = vp8->currentInstance;
//            
//            vp8->currentInstance = vp8->instance1;
//            vp8->currentInstance->out.width = oldInstance->out.width;
//            vp8->currentInstance->out.height = oldInstance->out.height;
//            vp8->currentInstance->isResChanged = oldInstance->isResChanged;
//            vp8->instance2 = vp8->instance1;
//            
//            vp8->currentInstance->forceKeyFrame = tbi_true;
//            vp8->instance2->forceKeyFrame = tbi_true;
//            
//            
//            media_codec_vp8_encoder_instance_close(oldInstance);
//        }
        
        //TBI_mutex_lock(vp8->chage);
        val = media_codec_vp8_instance_encode(self,in_data,in_size,out_data,out_max_size, (vp8->currentInstance->out.width > vp8->currentInstance->out.height));
        //TBI_mutex_unlock(vp8->chage);
    }
    return val;
}

static tbi_size_t media_codec_vp8_instance_encode(media_codec_t* self, const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size,tbi_bool_t isLandscape)
{

	vp8_encoder_instance_t* vp8 = (vp8_encoder_instance_t*)((media_codec_vp8_t*)self->codec)->currentInstance;
	vpx_enc_frame_flags_t flags = 0;
	vpx_codec_err_t vpx_ret;
	const vpx_codec_cx_pkt_t *pkt;
	vpx_codec_iter_t iter = tbi_null;
	vpx_image_t image;
    
	if(!vp8 || !in_data || !in_size || !out_data){
		TBI_DEBUG_ERROR("Invalid parameter");
		return 0;
	}
        
        if(in_size!=vp8->out.width*vp8->out.height*3/2){
		TBI_DEBUG_INFO("Invalid width height");
                return 0;
        }
    
	if( vp8->encoder.context.config.enc && in_size != (vp8->encoder.context.config.enc->g_w * vp8->encoder.context.config.enc->g_h * 3)>>1){
		//TBI_DEBUG_INFO("Invalid size");
        //return 0;
	}

//    if(vp8->isResChanged)
//    {
//        vp8->isResChanged = TBI_false;
//        vp8->forceKeyFrame = TBI_true;
//        media_codec_vp8_instance_restart(vp8, vp8->out.width, vp8->out.height);
//    }
    
//    if(vp8->encoder.context.config.enc && (w!=vp8->encoder.context.config.enc->g_w || h!=vp8->encoder.context.config.enc->g_h)){
//        //        vp8->encoder.context.config.enc->g_w = h;
//        //        vp8->encoder.context.config.enc->g_h = w;
//        //TSK_DEBUG_INFO1("------ w = %i , h = %i",w,h);
//                media_codec_vp8_instance_restart(self,w,h);
//    }
    
	// wrap yuv420 buffer
	if(!vp8->encoder.context.config.enc || !vpx_img_wrap(&image, VPX_IMG_FMT_I420, vp8->encoder.context.config.enc->g_w, vp8->encoder.context.config.enc->g_h, 1, (unsigned char*)in_data)){
		//TBI_DEBUG_INFO("vpx_img_wrap failed");
		return 0;
	}
#if !HAVE_FFMPEG// convert flip use FFmpeg
	if(vp8->out.flip){
		vpx_img_flip(&image);
	}
#endif

    
	// encode data
	++vp8->encoder.pts;
	if(vp8->encoder.frame_count == 0 || (vp8->encoder.frame_count % vp8->encoder.gop_size) == 0 || vp8->forceKeyFrame){
		flags |= VPX_EFLAG_FORCE_KF;
        vp8->forceKeyFrame = tbi_false;
	}
	//flags = VPX_EFLAG_FORCE_KF;
	
	if((vpx_ret = vpx_codec_encode(&vp8->encoder.context, &image, vp8->encoder.pts, 1, flags, VPX_DL_REALTIME)) != VPX_CODEC_OK){
		TBI_DEBUG_ERROR("vpx_codec_encode failed with error =%s", vpx_codec_err_to_string(vpx_ret));
		vpx_img_free(&image);
		return 0;
	}

	++vp8->encoder.frame_count;
    static int all = 0;
    static int count = 0;
	while((pkt = vpx_codec_get_cx_data(&vp8->encoder.context, &iter))){
		switch(pkt->kind){
			case VPX_CODEC_CX_FRAME_PKT:
            {
                if(!*out_data || *out_max_size < pkt->data.frame.sz)
                {
                    *out_data = realloc(*out_data, pkt->data.frame.sz);
                    *out_max_size = pkt->data.frame.sz;
                }
                
                memcpy((uint8_t*)(*out_data), (const uint8_t*)pkt->data.frame.buf , (unsigned long)pkt->data.frame.sz);
                all+=pkt->data.frame.sz;
                count++;
                //                    TBI_DEBUG_INFO("pkt size =%i all= %i count = %i instance=%i", (int)pkt->data.frame.sz,all,count,vp8->intanse);
                return pkt->data.frame.sz;
                //media_codec_vp8_encap(self, pkt);
//                break;
            }
			default:
			case VPX_CODEC_STATS_PKT:       /**< Two-pass statistics for this frame */
			case VPX_CODEC_PSNR_PKT:        /**< PSNR statistics for this frame */
			case VPX_CODEC_CUSTOM_PKT: /**< Algorithm extensions  */
            {
                //TBI_DEBUG_INFO("pkt->kind=%d not supported", (int)pkt->kind);
                break;
            }
		}
	}
    
	vpx_img_free(&image);
    
	return 0;
}

static tbi_size_t media_codec_vp8_decode(media_codec_t* self, const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size)
{
    return media_codec_vp8_instance_decode(self,in_data,in_size,out_data,out_max_size);
//    return media_codec_vp8_instance_decode(vp8->instance1,in_data,in_size,out_data,out_max_size);
//    return media_codec_vp8_instance_decode(vp8->instance3,in_data,in_size,out_data,out_max_size);
}

static tbi_size_t media_codec_vp8_instance_decode(media_codec_t* self, const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size)
{
	vp8_decoder_instance_t* vp8 = (vp8_decoder_instance_t*)((media_codec_vp8_t*)self->codec)->decoderInstance;
	const uint8_t* pdata = (uint8_t*)in_data;
	tbi_size_t ret = 0;
	static tbi_size_t xmax_size = (1920 * 1080 * 3) >> 3;
	if(!self || !in_data || in_size<1 || !out_data || !vp8->decoder.initialized){
		TBI_DEBUG_ERROR("Invalid parameter");
		return 0;
	}
    
	// start-accumulator
	if(!vp8->decoder.accumulator){
		if(in_size > xmax_size){
			TBI_DEBUG_ERROR("%u too big to contain valid encoded data. xmax_size=%u", in_size, xmax_size);
			goto bail;
		}
		if(!(vp8->decoder.accumulator = TBI_calloc(in_size, sizeof(uint8_t)))){
			TBI_DEBUG_ERROR("Failed to allocated new buffer");
			goto bail;
		}
		vp8->decoder.accumulator_size = in_size;
        
	}
	if((vp8->decoder.accumulator_pos + in_size) >= xmax_size){
		TBI_DEBUG_ERROR("BufferOverflow");
		vp8->decoder.accumulator_pos = 0;
		goto bail;
	}
	if((vp8->decoder.accumulator_pos + in_size) > vp8->decoder.accumulator_size){
		if(!(vp8->decoder.accumulator = TBI_realloc(vp8->decoder.accumulator, (vp8->decoder.accumulator_pos + in_size)))){
			TBI_DEBUG_ERROR("Failed to reallocated new buffer");
			vp8->decoder.accumulator_pos = 0;
			vp8->decoder.accumulator_size = 0;
			goto bail;
		}
		vp8->decoder.accumulator_size = (vp8->decoder.accumulator_pos + in_size);
	}
    
	memcpy((void*)(&((uint8_t*)vp8->decoder.accumulator)[vp8->decoder.accumulator_pos]), (const void*)pdata, (unsigned int)in_size);
	vp8->decoder.accumulator_pos += in_size;
	// end-accumulator
    
	// FIXME: First partition is decodable
	// for better error handling we should decode it
	// (vp8->decoder.last_PartID == 0 && vp8->decoder.last_S && S) => previous was "first decodable" and current is new one
	//if(rtp_hdr /*|| (vp8->decoder.last_PartID == 0 && vp8->decoder.last_S)*/)
    {
		vpx_image_t *img;
		vpx_codec_iter_t iter = tbi_null;
		vpx_codec_err_t vpx_ret;
		tbi_size_t pay_size = vp8->decoder.accumulator_pos;
        
		// in all cases: reset accumulator
		vp8->decoder.accumulator_pos = 0;
        
		// libvpx will crash very ofen when the frame is corrupted => for now we decided not to decode such frame
		// according to the latest release there is a function to check if the frame
		// is corrupted or not => To be checked
		if(vp8->decoder.frame_corrupted){
			vp8->decoder.frame_corrupted = tbi_false;
			goto bail;
		}
		vpx_ret = vpx_codec_decode(&vp8->decoder.context, (const uint8_t*)vp8->decoder.accumulator, pay_size, tbi_null, VPX_DL_REALTIME);
		
		if(vpx_ret != VPX_CODEC_OK){
//			TBI_DEBUG_INFO("vpx_codec_decode failed with error =%s", vpx_codec_err_to_string(vpx_ret));
			goto bail;
		}
		
        
        
		// copy decoded data
		ret = 0;
		while((img = vpx_codec_get_frame(&vp8->decoder.context, &iter))){
            
            

			unsigned int plane, y;
            
			// update sizes
//			vp8->in.width = img->d_w;
//			vp8->in.height = img->d_h;
            self->rotate.width = img->d_w;
            self->rotate.height = img->d_h;
			xmax_size = (img->d_w * img->d_h * 3) >> 1;
			// allocate destination buffer
			if(*out_max_size <xmax_size){
				if(!(*out_data = TBI_realloc(*out_data, xmax_size))){
					TBI_DEBUG_ERROR("Failed to allocate new buffer");
					vp8->decoder.accumulator_pos = 0;
					*out_max_size = 0;
					goto bail;
				}
				*out_max_size = xmax_size;
			}
            
#if !HAVE_FFMPEG// convert flip use FFmpeg
//			if(vp8->in.flip)
            {
				//vpx_img_flip(img);
			}
#endif
            //TBI_DEBUG_INFO("img waith = %i , img height = %i",img->d_w,img->d_h);
			// layout picture
			for(plane=0; plane < 3; plane++) {
                unsigned char *buf =img->planes[plane];
                for(y=0; y<img->d_h >> (plane ? 1 : 0); y++) {
					unsigned int w_count = img->d_w >> (plane ? 1 : 0);
					if((ret + w_count) > *out_max_size){
						TBI_DEBUG_ERROR("BufferOverflow");
						ret = 0;
						goto bail;
					}
					memcpy(((uint8_t*)*out_data) + ret, buf, w_count);
					ret += w_count;
                    buf += img->stride[plane];
                }
            }
		}
	}
    
bail:
    
    
    
	return ret;
}

static void media_codec_vp8_change_resolution(media_codec_t* self, int width, int height)
{
    media_codec_vp8_t* vp8 = (media_codec_vp8_t*)self->codec;
	vp8_encoder_instance_t* vp8_inst = (vp8_encoder_instance_t*)vp8->currentInstance;
        if (!vp8_inst) {
                return;
        }
    if(vp8_inst->out.width != width || vp8_inst->out.height != height)
    {
        TBI_DEBUG_INFO("change_resolution: %d x %d to %d x %d", vp8_inst->out.width, vp8_inst->out.height, width, height);
        vp8_inst->out.width = width;
        vp8_inst->out.height = height;
        vp8->changeForNext = TBI_true;
    }
}

static tbi_bool_t tdav_codec_vp8_fmtp_match(const media_codec_vp8_t* codec, const char* fmtp)
{
    
	return tbi_true;
}

static char* media_codec_vp8_fmtp_get(const media_codec_vp8_t* self)
{
    char *vpx = "vp8";
    
    return vpx;
}
static int media_codec_vp8_fmtp_set(media_codec_vp8_t* self, const char* fmtp)
{
	//TBI_DEBUG_INFO("remote fmtp=%s", fmtp);
	return 0;
}

/* ============ VP8 object definition ================= */

static const media_codec_t media_codec_vp8_s =
{
	media_video,
	"vp8",
	"vp8 Codec",
	MEDIA_CODEC_FORMAT_VP8,
	8000, // rate
	{0,0},
    {
        352, 288, 12
        , media_codec_vp8_change_resolution
    },
    {0, 288, 352}, // rotate
    0,
    -1,
    2, // bits per sample
	media_codec_vp8_open,
	media_codec_vp8_close,
	media_codec_vp8_encode,
	media_codec_vp8_decode,
    media_codec_vp8_bitrate_change,
    media_codec_vp8_bitrate_get
};
const media_codec_t *pmedia_codec_vp8 = &media_codec_vp8_s;

#endif /* HAVE_LIBVPX */
