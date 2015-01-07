

/**@file tmedia_common.c
 * @brief Common functions and definitions.
 *

 *

 */
#include "tinymedia/tmedia_common.h"

#include "tinymedia/tmedia_session.h"

#include "tsk_params.h"
#include "tsk_debug.h"

#include <stdlib.h> /* atoi() */



int tmedia_parse_rtpmap(const char* rtpmap, char** name, int32_t* rate, int32_t* channels)
{
}


int tmedia_parse_video_fmtp(const char* fmtp, tmedia_bandwidth_level_t bl, unsigned* width, unsigned* height, unsigned* fps)
{
	int ret = -2;
	tsk_params_L_t* params = tsk_null;
	const tsk_param_t* param = tsk_null;
	const tsk_list_item_t* item;
	int i;

	struct fmtp_size{
		const char* name;
		tmedia_bandwidth_level_t min_bl;
		unsigned width;
		unsigned height;
	};
	static const struct fmtp_size fmtp_sizes[] = 
	{
		// from best to worst
		{"CIF", tmedia_bl_medium, 320, 240},
		{"QCIF", tmedia_bl_low, 240, 160},
		{"SQCIF", tmedia_bl_low, 128, 96},		
	};

	if(!fmtp || !width || !height || !fps){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}

	// set default values
	*fps = 10;
	switch(bl){
		case tmedia_bl_low:
		default:
			{
				*width= 240; 
				*height = 160;
				break;
			}
		case tmedia_bl_medium:
		case tmedia_bl_hight:
		case tmedia_bl_unrestricted:
        {
            *width= 320;
            *height = 240;
				break;
        }
	}
	if((params = tsk_params_fromstring(fmtp, ";", tsk_true))){
		// set real values
		tsk_list_foreach(item, params){
			if(!(param = TSK_PARAM(item->data)) || !param->name || !param->value){
				continue;
			}
			for(i=0;i<sizeof(fmtp_sizes)/sizeof(struct fmtp_size);i++){
				if((int)bl >= (int)fmtp_sizes[i].min_bl && tsk_striequals(fmtp_sizes[i].name, param->name)){
					*width= fmtp_sizes[i].width; 
					*height = fmtp_sizes[i].height;
//					*fps = atoi(param->value);
//					*fps = *fps ? 30/(*fps) : 15;
					ret = 0;
					goto done;
				}
			}
		}
done:
		TSK_OBJECT_SAFE_FREE(params);
	}

	return ret;
}

static const tmedia_video_size_t tmedia_video_sizes[] = 
{

};

const tmedia_video_size_t* tmedia_get_video_size(tmedia_chroma_t chroma, tsk_size_t size)
{
	return 0;
}

// #retval: 1(best)-31(worst) */
int tmedia_get_video_quality(tmedia_bandwidth_level_t bl)
{
	switch(bl){
		case tmedia_bl_low:
		default: return 9;
		case tmedia_bl_medium: return 9;
		case tmedia_bl_hight: return 5;
		case tmedia_bl_unrestricted: return 1;
	}
}