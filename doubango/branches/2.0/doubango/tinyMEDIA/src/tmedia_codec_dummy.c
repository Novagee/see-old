

/**@file tmedia_codec_dummy.c
 * @brief Dummy codecs used for test only.
 *

 *

 */
#include "tinymedia/tmedia_codec_dummy.h"

#include "tsk_debug.h"

//=================================================================================================
//	Dummy G.711u object definition
//

#define tmedia_codec_dpcmu_fmtp_get tsk_null
#define tmedia_codec_dpcmu_fmtp_set tsk_null
#define tmedia_codec_dpcmu_fmtp_encode tsk_null
#define tmedia_codec_dpcmu_fmtp_decode tsk_null

tsk_bool_t tmedia_codec_dpcmu_fmtp_match(const tmedia_codec_t* codec, const char* fmtp)
{	/* always match */
	return tsk_true;
}

/* constructor */
static tsk_object_t* tmedia_codec_dpcmu_ctor(tsk_object_t * self, va_list * app)
{
	tmedia_codec_dpcmu_t *dpcmu = self;
	if(dpcmu){
		/* init base: called by tmedia_codec_create() */
		/* init self */
	}
	return self;
}
/* destructor */
static tsk_object_t* tmedia_codec_dpcmu_dtor(tsk_object_t * self)
{ 
	tmedia_codec_dpcmu_t *dpcmu = self;
	if(dpcmu){
		/* deinit base */
		tmedia_codec_audio_deinit(dpcmu);
		/* deinit self */
	}

	return self;
}
/* object definition */
static const tsk_object_def_t tmedia_codec_dpcmu_def_s = 
{
	sizeof(tmedia_codec_dpcmu_t),
	tmedia_codec_dpcmu_ctor, 
	tmedia_codec_dpcmu_dtor,
	tmedia_codec_cmp, 
};
/* plugin definition*/
static const tmedia_codec_plugin_def_t tmedia_codec_dpcmu_plugin_def_s = 
{
	&tmedia_codec_dpcmu_def_s,

	tmedia_audio,
	"G.711u",
	"Dummy G.711u codec",
	TMEDIA_CODEC_FORMAT_G711u,
	tsk_false,
	8000, // rate
	
	{ /* audio */
		1, // channels
		20 // ptime
	},

	/* video */
	{0},

	tsk_null, // open
	tsk_null, // close
	tmedia_codec_dpcmu_fmtp_encode,
	tmedia_codec_dpcmu_fmtp_decode,
	tmedia_codec_dpcmu_fmtp_match,
	tmedia_codec_dpcmu_fmtp_get,
	tmedia_codec_dpcmu_fmtp_set
};
const tmedia_codec_plugin_def_t *tmedia_codec_dpcmu_plugin_def_t = &tmedia_codec_dpcmu_plugin_def_s;

//=================================================================================================
//	Dummy G.711a object definition
//

#define tmedia_codec_dpcma_fmtp_get tsk_null
#define tmedia_codec_dpcma_fmtp_set tsk_null
#define tmedia_codec_dpcma_fmtp_encode tsk_null
#define tmedia_codec_dpcma_fmtp_decode tsk_null

tsk_bool_t tmedia_codec_dpcma_fmtp_match(const tmedia_codec_t* codec, const char* fmtp)
{	/* always match */
	return tsk_true;
}

/* constructor */
static tsk_object_t* tmedia_codec_dpcma_ctor(tsk_object_t * self, va_list * app)
{
	tmedia_codec_dpcma_t *dpcma = self;
	if(dpcma){
		/* init base: called by tmedia_codec_create() */
		/* init self */
	}
	return self;
}
/* destructor */
static tsk_object_t* tmedia_codec_dpcma_dtor(tsk_object_t * self)
{ 
	tmedia_codec_dpcma_t *dpcma = self;
	if(dpcma){
		/* deinit base */
		tmedia_codec_audio_deinit(dpcma);
		/* deinit self */
	}

	return self;
}
/* object definition */
static const tsk_object_def_t tmedia_codec_dpcma_def_s = 
{
	sizeof(tmedia_codec_dpcma_t),
	tmedia_codec_dpcma_ctor, 
	tmedia_codec_dpcma_dtor,
	tmedia_codec_cmp, 
};
/* plugin definition*/
static const tmedia_codec_plugin_def_t tmedia_codec_dpcma_plugin_def_s = 
{
	&tmedia_codec_dpcma_def_s,

	tmedia_audio,
	"G.711a",
	"Dummy G.711a codec",
	TMEDIA_CODEC_FORMAT_G711a,
	tsk_false,
	8000, // rate
	
	{ /* audio */
		1, // channels
		20 // ptime
	},

	/* video */
	{0},

	tsk_null, // open
	tsk_null, // close
	tmedia_codec_dpcma_fmtp_encode,
	tmedia_codec_dpcma_fmtp_decode,
	tmedia_codec_dpcma_fmtp_match,
	tmedia_codec_dpcma_fmtp_get,
	tmedia_codec_dpcma_fmtp_set
};
const tmedia_codec_plugin_def_t *tmedia_codec_dpcma_plugin_def_t = &tmedia_codec_dpcma_plugin_def_s;



//=================================================================================================
//	Dummy H.263 object definition
//

tsk_size_t tmedia_codec_dh263_fmtp_encode(tmedia_codec_t* self, const void* in_data, tsk_size_t in_size, void** out_data, tsk_size_t* out_max_size)
{
	return 0;
}

tsk_size_t tmedia_codec_dh263_fmtp_decode(tmedia_codec_t* self, const void* in_data, tsk_size_t in_size, void** out_data, tsk_size_t* out_max_size, const tsk_object_t* proto_hdr)
{
	return 0;
}

tsk_bool_t tmedia_codec_dh263_fmtp_match(const tmedia_codec_t* codec, const char* fmtp)
{	
	/* check whether we can match this fmtp with our local
	* check size, maxbr, fps ...*/
	return tsk_true;
}

char* tmedia_codec_dh263_fmtp_get(const tmedia_codec_t* self)
{
	return tsk_strdup("CIF=2/MaxBR=3840;QCIF=2/MaxBR=1920");
}

int tmedia_codec_dh263_fmtp_set(tmedia_codec_t* self, const char* fmtp)
{
	TSK_DEBUG_INFO("remote fmtp=%s", fmtp);
	return 0;
}

/* constructor */
static tsk_object_t* tmedia_codec_dh263_ctor(tsk_object_t * self, va_list * app)
{
	tmedia_codec_dh263_t *dh263 = self;
	if(dh263){
		/* init base: called by tmedia_codec_create() */
		/* init self */
	}
	return self;
}
/* destructor */
static tsk_object_t* tmedia_codec_dh263_dtor(tsk_object_t * self)
{ 
	tmedia_codec_dh263_t *dh263 = self;
	if(dh263){
		/* deinit base */
		tmedia_codec_video_deinit(dh263);
		/* deinit self */
	}

	return self;
}
/* object definition */
static const tsk_object_def_t tmedia_codec_dh263_def_s = 
{
	sizeof(tmedia_codec_dh263_t),
	tmedia_codec_dh263_ctor, 
	tmedia_codec_dh263_dtor,
	tmedia_codec_cmp, 
};
/* plugin definition*/
static const tmedia_codec_plugin_def_t tmedia_codec_dh263_plugin_def_s = 
{
	&tmedia_codec_dh263_def_s,

	tmedia_video,
	"H263",
	"Dummy H.263-1996 codec",
	TMEDIA_CODEC_FORMAT_H263,
	tsk_false,
	90000, // rate
	
	/* audio */
	{ 0 },

	/* video */
	{0, 0},

	tsk_null, // open
	tsk_null, // close
	tmedia_codec_dh263_fmtp_encode,
	tmedia_codec_dh263_fmtp_decode,
	tmedia_codec_dh263_fmtp_match,
	tmedia_codec_dh263_fmtp_get,
	tmedia_codec_dh263_fmtp_set
};
const tmedia_codec_plugin_def_t *tmedia_codec_dh263_plugin_def_t = &tmedia_codec_dh263_plugin_def_s;




//=================================================================================================
//	Dummy H.264 (Base profile 10) object definition
//

tsk_size_t tmedia_codec_dh264_fmtp_encode(tmedia_codec_t* self, const void* in_data, tsk_size_t in_size, void** out_data, tsk_size_t* out_max_size)
{
	return 0;
}

tsk_size_t tmedia_codec_dh264_fmtp_decode(tmedia_codec_t* self, const void* in_data, tsk_size_t in_size, void** out_data, tsk_size_t* out_max_size, const tsk_object_t* proto_hdr)
{
	return 0;
}

tsk_bool_t tmedia_codec_dh264_fmtp_match(const tmedia_codec_t* codec, const char* fmtp)
{	
	/* check whether we can match this fmtp with our local
	* check size, maxbr, fps, profile-level-id, packetization-mode ...*/
	return tsk_true;
}

char* tmedia_codec_dh264_fmtp_get(const tmedia_codec_t* self)
{
	return tsk_strdup("profile-level-id=42A01E;sprop-parameter-sets=Z0IACpZTBYmI,aMljiA==");
}

int tmedia_codec_dh264_fmtp_set(tmedia_codec_t* self, const char* fmtp)
{
	TSK_DEBUG_INFO("remote fmtp=%s", fmtp);
	return 0;
}

/* constructor */
static tsk_object_t* tmedia_codec_dh264_ctor(tsk_object_t * self, va_list * app)
{
	tmedia_codec_dh264_t *dh264 = self;
	if(dh264){
		/* init base: called by tmedia_codec_create() */
		/* init self */
	}
	return self;
}
/* destructor */
static tsk_object_t* tmedia_codec_dh264_dtor(tsk_object_t * self)
{ 
	tmedia_codec_dh264_t *dh264 = self;
	if(dh264){
		/* deinit base */
		tmedia_codec_video_deinit(dh264);
		/* deinit self */
	}

	return self;
}
/* object definition */
static const tsk_object_def_t tmedia_codec_dh264_def_s = 
{
	sizeof(tmedia_codec_dh264_t),
	tmedia_codec_dh264_ctor, 
	tmedia_codec_dh264_dtor,
	tmedia_codec_cmp, 
};
/* plugin definition*/
static const tmedia_codec_plugin_def_t tmedia_codec_dh264_plugin_def_s = 
{
	&tmedia_codec_dh264_def_s,

	tmedia_video,
	"H264",
	"Dummy H.264 (base profile 10) codec",
	TMEDIA_CODEC_FORMAT_H264_BP10,
	tsk_true,
	90000, // rate
	
	/* audio */
	{ 0 },

	/* video */
	{176, 144},

	tsk_null, // open
	tsk_null, // close
	tmedia_codec_dh264_fmtp_encode,
	tmedia_codec_dh264_fmtp_decode,
	tmedia_codec_dh264_fmtp_match,
	tmedia_codec_dh264_fmtp_get,
	tmedia_codec_dh264_fmtp_set
};
const tmedia_codec_plugin_def_t *tmedia_codec_dh264_plugin_def_t = &tmedia_codec_dh264_plugin_def_s;
