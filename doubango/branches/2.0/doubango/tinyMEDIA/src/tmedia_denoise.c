

/**@file tmedia_denoise.c
* @brief Denoiser (Noise suppression, AGC, AEC, VAD) Plugin
*
*
*

*/
#include "tinymedia/tmedia_denoise.h"
#include "tinymedia/tmedia_defaults.h"

#include "tsk_debug.h"

static const tmedia_denoise_plugin_def_t* __tmedia_denoise_plugin = tsk_null;

int tmedia_denoise_init(tmedia_denoise_t* self)
{
	if(!self){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}

	self->echo_tail = tmedia_defaults_get_echo_tail();
	self->echo_skew = tmedia_defaults_get_echo_skew();
	self->echo_supp_enabled = tmedia_defaults_get_echo_supp_enabled();
	self->agc_enabled = tmedia_defaults_get_agc_enabled();
	self->agc_level = tmedia_defaults_get_agc_level();
	self->vad_enabled = tmedia_defaults_get_vad_enabled();
	self->noise_supp_enabled = tmedia_defaults_get_noise_supp_enabled();
	self->noise_supp_level = tmedia_defaults_get_noise_supp_level();

	return 0;
}

int tmedia_denoise_set(tmedia_denoise_t* self, const tmedia_param_t* param)
{
	if(!self || !self->plugin){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}

	if(self->plugin->set){

		// FIXME: to be implemnted
		TSK_DEBUG_ERROR("Not implemented");

		return self->plugin->set(self, param);
	}
	return 0;
}

int tmedia_denoise_open(tmedia_denoise_t* self, uint32_t frame_size, uint32_t sampling_rate)
{
}

int tmedia_denoise_echo_playback(tmedia_denoise_t* self, const void* echo_frame)
{
	if(!self || !self->plugin){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}

	if(!self->opened){
		TSK_DEBUG_ERROR("Denoiser not opened");
		return -2;
	}

	if(self->plugin->echo_playback){
		return self->plugin->echo_playback(self, echo_frame);
	}
	else{
		return 0;
	}
}

int tmedia_denoise_process_record(tmedia_denoise_t* self, void* audio_frame, tsk_bool_t* silence_or_noise)
{
	if(!self || !self->plugin || !silence_or_noise){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}

	if(!self->opened){
		TSK_DEBUG_ERROR("Denoiser not opened");
		return -2;
	}

	if(self->plugin->process_record){
		return self->plugin->process_record(self, audio_frame, silence_or_noise);
	}
	else{
		*silence_or_noise = tsk_false;
		return 0;
	}
}

int tmedia_denoise_process_playback(tmedia_denoise_t* self, void* audio_frame)
{
	if(!self || !self->plugin){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}

	if(!self->opened){
		TSK_DEBUG_ERROR("Denoiser not opened");
		return -2;
	}

	if(self->plugin->process_playback){
		return self->plugin->process_playback(self, audio_frame);
	}
	return 0;
}

int tmedia_denoise_close(tmedia_denoise_t* self)
{
	if(!self || !self->plugin){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	if(!self->opened){
		TSK_DEBUG_WARN("Denoiser not opened");
		return 0;
	}

	if(self->plugin->close){
		int ret;

		if((ret = self->plugin->close(self))){
			TSK_DEBUG_ERROR("Failed to close [%s] denoiser", self->plugin->desc);
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

int tmedia_denoise_deinit(tmedia_denoise_t* self)
{


	return 0;
}

int tmedia_denoise_plugin_register(const tmedia_denoise_plugin_def_t* plugin)
{
	if(!plugin){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	__tmedia_denoise_plugin = plugin;
	return 0;
}

int tmedia_denoise_plugin_unregister()
{
	__tmedia_denoise_plugin = tsk_null;
	return 0;
}

tmedia_denoise_t* tmedia_denoise_create()
{
	tmedia_denoise_t* denoise = tsk_null;

	if(__tmedia_denoise_plugin){
		if((denoise = tsk_object_new(__tmedia_denoise_plugin->objdef))){
			denoise->plugin = __tmedia_denoise_plugin;
		}
	}
	return denoise;
}
