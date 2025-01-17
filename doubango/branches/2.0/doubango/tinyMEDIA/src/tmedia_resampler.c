  

/**@file tmedia_resampler.c
 * @brief Audio Resample plugin
 *

 */
#include "tinymedia/tmedia_resampler.h"

#include "tsk_debug.h"

static const tmedia_resampler_plugin_def_t* __tmedia_resampler_plugin = tsk_null;

int tmedia_resampler_init(tmedia_resampler_t* self)
{
	if(!self){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	return 0;
}

int tmedia_resampler_open(tmedia_resampler_t* self, uint32_t in_freq, uint32_t out_freq, uint32_t frame_duration, uint32_t channels, uint32_t quality)
{
	int ret;

	if(!self || !self->plugin || !self->plugin->open){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	if(self->opened){
		TSK_DEBUG_WARN("Resampler already opened");
		return 0;
	}
	
	if((ret = self->plugin->open(self, in_freq, out_freq, frame_duration, channels, quality))){
		TSK_DEBUG_ERROR("Failed to open [%s] resamplerr", self->plugin->desc);
		return ret;
	}
	else{
		self->opened = tsk_true;
		return 0;
	}
}

tsk_size_t tmedia_resampler_process(tmedia_resampler_t* self, const uint16_t* in_data, tsk_size_t in_size, uint16_t* out_data, tsk_size_t out_size)
{
	if(!self || !in_data || !in_size || !self->plugin || !self->plugin->process){
		TSK_DEBUG_ERROR("Invalid parameter");
		return 0;
	}

	if(!self->opened){
		TSK_DEBUG_ERROR("Resampler not opened");
		return 0;
	}

	return self->plugin->process(self, in_data, in_size, out_data, out_size);
}

int tmedia_resampler_close(tmedia_resampler_t* self)
{
	if(!self || !self->plugin){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	if(!self->opened){
		TSK_DEBUG_WARN("Resampler not opened");
		return 0;
	}

	if(self->plugin->close){
		int ret;

		if((ret = self->plugin->close(self))){
			TSK_DEBUG_ERROR("Failed to close [%s] resamplerr", self->plugin->desc);
			return ret;
		}
		else{
			self->opened = tsk_false;
			return 0;
		}
	}
	else{
		self->opened = tsk_false;
		return 0;
	}
}

int tmedia_resampler_deinit(tmedia_resampler_t* self)
{
	if(!self){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}

	if(self->opened){
		tmedia_resampler_close(self);
	}

	return 0;
}

int tmedia_resampler_plugin_register(const tmedia_resampler_plugin_def_t* plugin)
{
	if(!plugin){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	__tmedia_resampler_plugin = plugin;
	return 0;
}

int tmedia_resampler_plugin_unregister()
{
	__tmedia_resampler_plugin = tsk_null;
	return 0;
}

tmedia_resampler_t* tmedia_resampler_create()
{
	tmedia_resampler_t* resampler = tsk_null;

	if(__tmedia_resampler_plugin){
		if((resampler = tsk_object_new(__tmedia_resampler_plugin->objdef))){
			resampler->plugin = __tmedia_resampler_plugin;
		}
	}
	return resampler;
}
