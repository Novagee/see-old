//
//  media_codec.h
//  TBIRTMP
//
//  Created by Administrator on 11/9/12.
//  Copyright (c) 2012 Grigori Jlavyan. All rights reserved.
//

#ifndef TBIRTMP_media_codec_h
#define TBIRTMP_media_codec_h

#include "types.h"
#include "media.h"

#define MEDIA_CODEC_FORMAT_COUNT                        6
#define MEDIA_CODEC_FORMAT_G729                         18
#define MEDIA_CODEC_FORMAT_SPEEX_NB                     97
#define MEDIA_CODEC_FORMAT_SPEEX_UWB					99
#define MEDIA_CODEC_FORMAT_PCMA                         114
#define MEDIA_CODEC_FORMAT_PCMU                         130

#define MEDIA_CODEC_FORMAT_OPUS                         131
#define MEDIA_CODEC_FORMAT_OPUS8_8                      132
#define MEDIA_CODEC_FORMAT_OPUS8_16                     133
#define MEDIA_CODEC_FORMAT_OPUS8_32                     134
#define MEDIA_CODEC_FORMAT_OPUS16_32                    135
#define MEDIA_CODEC_FORMAT_OPUS16_16                    136
#define MEDIA_CODEC_FORMAT_LAST_OPUS                    MEDIA_CODEC_FORMAT_OPUS16_16

#define MEDIA_CODEC_FORMAT_GSM                          137

#define MEDIA_CODEC_FORMAT_SPEEX_WB                     178
#define MEDIA_CODEC_FORMAT_H264_176_X_144               190
#define MEDIA_CODEC_FORMAT_H264_352_X_288               192
#define MEDIA_CODEC_FORMAT_H264                         194
#define MEDIA_CODEC_FORMAT_VP8                          193

//Full list
//#define SUPPORTED_AUDIO_CODECS_LIST       "opus8_8;opus8_16;opus8_32;opus16_32;opus;gsm;pcma;pcmu"
//#define IPOD_SUPPORTED_AUDIO_CODECS_LIST  "opus8_8;opus8_16;opus8_32;opus16_32;gsm;pcma;pcmu"


#define MEDIA_AUDIO_CODEC_FORMAT_SEQ                    200

#define SUPPORTED_AUDIO_CODECS_LIST       "opus16_32;opus16_16;gsm;pcma;pcmu"
#define IPOD_SUPPORTED_AUDIO_CODECS_LIST  "gsm;pcma;pcmu"
//#define SUPPORTED_AUDIO_CODECS_LIST       "speex"
//#define IPOD_SUPPORTED_AUDIO_CODECS_LIST  "speex"

#define IPHONE5_WWAN_SUPPORTED_AUDIO_CODECS_LIST     "opus16_16;gsm;speex"
#define IPHONE4_WWAN_SUPPORTED_AUDIO_CODECS_LIST     "gsm;speex"

#define WWAN_SUPPORTED_AUDIO_FRAME_COUNT             3

#define IPHONE5_WIFI_SUPPORTED_AUDIO_CODECS_LIST     "opus16_32;opus16_16;gsm;speex;pcmu;pcma"
#define IPHONE4_WIFI_SUPPORTED_AUDIO_CODECS_LIST     "gsm;speex;pcmu;pcma"

#define WIFI_SUPPORTED_AUDIO_FRAME_COUNT             3

//#define SUPPORTED_VIDEO_CODECS_LIST       "vp8;h264"
//#define IPOD_SUPPORTED_VIDEO_CODECS_LIST  "h264"
#define SUPPORTED_VIDEO_CODECS_LIST       "vp8"
#define IPOD_SUPPORTED_VIDEO_CODECS_LIST  "vp8"

#define AUDIO_FRAMES_COUNT  3

#define MIN_BITRATE 60
#define MAX_BITRATE 720

typedef struct rtmp_video_stat_s{
    void* callbackData;
    void* callback;
    double realDeltaPlayTime;
    uint64_t lastPlayedFrameTime;
    double lastPlayed2TimeFrameTime;
    uint64_t lastPlayed2TimeFrameCount;
    double parsent;
    double realAllTime;
    tbi_bool_t isunlock;

    int packetCount;
    int maxPacketCount;
    uint64_t* packetCompletionTimes;
    uint64_t lastPacketRecvTime;
    
    int playedFrameCount;
    int checkTime;
    float adaptiveValue;
    
    int remoteBitrate;
}rtmp_video_stat_t;


typedef struct media_codec_s{
    
	//! the type of the codec
	media_type_t type;
	//! the name of the codec. e.g. "G.711U" or "G.711A" etc used in the sdp
	char* name;
	//! full description
	char* desc;
	//! the format. e.g. 0 for PCMU or 8 for PCMA.
	uint8_t format;
	//! bandwidth
	uint32_t rate;
	/* default values could be updated at any time */
	struct{
		int8_t channels;
		uint8_t pTime;
        int birate;
        int codec_frame_size;
        int pcm_frame_size;
		/* ...to be continued */
	} audio;
    
    /* default values could be updated at any time */
	struct{
		unsigned width;
		unsigned height;
		unsigned fps;
		/* ...to be continued */
        void (*change_resolution) (struct media_codec_s*, int width, int height);
	} video;
    
    struct{
        unsigned width;
        unsigned height;
		/* ...to be continued */
	} rotate;
    
    uint32_t networkType;
    uint32_t priority;
    
	//! functons used to create the codec
	// bits per sample
    uint16_t  bits_per_sample;
    //! open the codec
	int (*open) (struct media_codec_s*);
	//! close the codec
	int (*close) (struct media_codec_s*);
	//! encode data
	tbi_size_t (*encode) (struct media_codec_s*, const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size);
	//! decode data
	tbi_size_t (*decode) (struct media_codec_s*, const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size);
    
    //bitrate change
    tbi_size_t (*bitrate_change) (struct media_codec_s* , tbi_bool_t isDown,double bitrate);
    //get bitrate
    int (*get_bitrate)  (struct media_codec_s*);
    
    void* codec;
    
} media_codec_t;

#endif
