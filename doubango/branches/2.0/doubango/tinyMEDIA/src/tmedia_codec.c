

/**@file tmedia_codec.c
 * @brief Base codec object.
 *

 *

 */
#include "tinymedia/tmedia_codec.h"
#include "tinymedia/tmedia_defaults.h"

#include "tsk_string.h"
#include "tsk_memory.h"
#include "tsk_debug.h"

/**@defgroup tmedia_codec_group Codecs
*/

/* pointer to all registered codecs */
const tmedia_codec_plugin_def_t* __tmedia_codec_plugins[TMED_CODEC_MAX_PLUGINS] = {0};


/*== Predicate function to find a codec object by format */
static int __pred_find_codec_by_format(const tsk_list_item_t *item, const void *format)
{
	if(item && item->data){
		return tsk_strcmp(((tmedia_codec_t *)item->data)->format, format);
	}
	return -1;
}

/*== Predicate function to find a codec object by negociated format */
static int __pred_find_codec_by_neg_format(const tsk_list_item_t *item, const void *format)
{
	if(item && item->data){
		return tsk_strcmp(((tmedia_codec_t *)item->data)->neg_format, format);
	}
	return -1;
}

/**@ingroup tmedia_codec_group
* Initialize a Codec 
* @param self The codec to initialize. Could be any type of codec (e.g. @ref tmedia_codec_audio_t or @ref tmedia_codec_video_t).
* @param type
* @param name the name of the codec. e.g. "G.711u" or "G.711a" etc used in the sdp.
* @param desc full description.
* @param format the format. e.g. "0" for G.711.u or "8" for G.711a or "*" for MSRP.
* @retval Zero if succeed and non-zero error code otherwise.
*/
int tmedia_codec_init(tmedia_codec_t* self, tmedia_type_t type, const char* name, const char* desc, const char* format)
{
	if(!self || tsk_strnullORempty(name)){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	self->type = type;
	tsk_strupdate(&self->name, name);
	tsk_strupdate(&self->desc,desc);
	tsk_strupdate(&self->format, format);
	
	// Video flipping: For backward compatibility we have to initialize the default values
	// according to the CFLAGS: 'FLIP_ENCODED_PICT' and 'FLIP_DECODED_PICT'. At any time you
	// can update thse values (e.g. when the device switch from landscape to portrait) using video_session->set();
	if(type & tmedia_video){
#if FLIP_ENCODED_PICT
		TMEDIA_CODEC_VIDEO(self)->out.flip = tsk_true;
#endif
#if FLIP_DECODED_PICT
		TMEDIA_CODEC_VIDEO(self)->in.flip = tsk_true;
#endif
	}

	return 0;
}

/**@ingroup tmedia_codec_group
* Prepares a codec by opening it.
* @param self The codec to open.
* @retval Zero if succeed and non-zero error code otherwise.
* @sa @ref tmedia_codec_close()
*/
int tmedia_codec_open(tmedia_codec_t* self)
{
	if(!self || !self->plugin){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	if(self->opened){
		TSK_DEBUG_WARN("Codec already opened");
		return 0;
	}

	if(self->plugin->open){
		int ret;
		if((ret = self->plugin->open(self))){
			TSK_DEBUG_ERROR("Failed to open [%s] codec", self->plugin->desc);
			return ret;
		}
		else{
			self->opened = tsk_true;
			return 0;
		}
	}
	else{
		self->opened = tsk_true;
		return 0;
	}
}

/**@ingroup tmedia_codec_group
* UnPrepares a codec by closing it.
* @param self The codec to close.
* @retval Zero if succeed and non-zero error code otherwise.
* @sa @ref tmedia_codec_open()
*/
int tmedia_codec_close(tmedia_codec_t* self)
{
	if(!self || !self->plugin){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
	if(!self->opened){
		TSK_DEBUG_WARN("Codec not opened");
		return 0;
	}

	if(self->plugin->close){
		int ret;

		if((ret = self->plugin->close(self))){
			TSK_DEBUG_ERROR("Failed to close [%s] codec", self->plugin->desc);
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

/**@ingroup tmedia_codec_group
* Generic function to compare two codecs.
* @param codec1 The first codec to compare.
* @param codec2 The second codec to compare.
* @retval Returns an integral value indicating the relationship between the two codecs:
* <0 : @a codec1 less than @a codec2.<br>
* 0  : @a codec1 identical to @a codec2.<br>
* >0 : @a codec1 greater than @a codec2.<br>
*/
int tmedia_codec_cmp(const tsk_object_t* codec1, const tsk_object_t* codec2)
{
	const tmedia_codec_t* _c1 = codec1;
	const tmedia_codec_t* _c2 = codec2;

	if((_c1 && _c2) && (_c1->type == _c2->type)){
		/* Do not compare names. For example, H264 base profile 1.0 will have the 
		* same name than H264 base profile 3.0. */
		return tsk_stricmp(_c1->format, _c2->format);
	}
	else{
		return -1;
	}
}

/**@ingroup tmedia_codec_group
* Registers a codec plugin.
* @param plugin the definition of the plugin.
* @retval Zero if succeed and non-zero error code otherwise.
* @sa @ref tmedia_codec_create()
*/
int tmedia_codec_plugin_register(const tmedia_codec_plugin_def_t* plugin)
{
	tsk_size_t i;
	if(!plugin || tsk_strnullORempty(plugin->name) || tsk_strnullORempty(plugin->format)){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}

	/* add or replace the plugin */
	for(i = 0; i<TMED_CODEC_MAX_PLUGINS; i++){
		if(!__tmedia_codec_plugins[i] || (__tmedia_codec_plugins[i] == plugin)){
			__tmedia_codec_plugins[i] = plugin;
			return 0;
		}
	}
	
	TSK_DEBUG_ERROR("There are already %d plugins.", TMED_CODEC_MAX_PLUGINS);
	return -2;
}

/**@ingroup tmedia_codec_group
 * Checks whether a codec plugin is registered or not.
 * @param plugin the definition of the plugin to check for availability.
 * @retval 1 (tsk_true) if registered and 0 (tsk_false) otherwise.
 * @sa @ref tmedia_codec_plugin_register() and @ref tmedia_codec_plugin_unregister()
 */
tsk_bool_t tmedia_codec_plugin_is_registered(const tmedia_codec_plugin_def_t* plugin)
{
	if(plugin){
		tsk_size_t i;
		for(i = 0; i<TMED_CODEC_MAX_PLUGINS && __tmedia_codec_plugins[i]; i++){
			if(__tmedia_codec_plugins[i] == plugin){
				return tsk_true;
			}
		}
	}
	return tsk_false;
}

/**@ingroup tmedia_codec_group
* UnRegisters a codec plugin.
* @param plugin the definition of the plugin.
* @retval Zero if succeed and non-zero error code otherwise.
*/
int tmedia_codec_plugin_unregister(const tmedia_codec_plugin_def_t* plugin)
{
	tsk_size_t i;
	tsk_bool_t found = tsk_false;
	if(!plugin){
		TSK_DEBUG_ERROR("Invalid Parameter");
		return -1;
	}

	/* find the plugin to unregister */
	for(i = 0; i<TMED_CODEC_MAX_PLUGINS && __tmedia_codec_plugins[i]; i++){
		if(__tmedia_codec_plugins[i] == plugin){
			__tmedia_codec_plugins[i] = tsk_null;
			found = tsk_true;
			break;
		}
	}

	/* compact */
	if(found){
		for(; i<(TMED_CODEC_MAX_PLUGINS - 1); i++){
			if(__tmedia_codec_plugins[i+1]){
				__tmedia_codec_plugins[i] = __tmedia_codec_plugins[i+1];
			}
			else{
				break;
			}
		}
		__tmedia_codec_plugins[i] = tsk_null;
	}
	return (found ? 0 : -2);
}

/**@ingroup tmedia_codec_group
* Creates a new codec using an already registered plugin.
* @param format The format of the codec to create (e.g. "0" for PCMU or "8" for PCMA or "*" for MSRP)
* @sa @ref tmedia_codec_plugin_register()
*/
tmedia_codec_t* tmedia_codec_create(const char* format)
{
	tmedia_codec_t* codec = tsk_null;
	const tmedia_codec_plugin_def_t* plugin;
	tsk_size_t i = 0;

	while((i < TMED_CODEC_MAX_PLUGINS) && (plugin = __tmedia_codec_plugins[i++])){
		if(plugin->objdef && tsk_striequals(plugin->format, format)){
			if((codec = tsk_object_new(plugin->objdef))){
				/* initialize the newly created codec */
				codec->dyn = plugin->dyn;
				codec->plugin = plugin;
				codec->bl = tmedia_bl_medium;
				switch(plugin->type){
					case tmedia_audio:
						{	/* Audio codec */
							tmedia_codec_audio_t* audio = TMEDIA_CODEC_AUDIO(codec);
							tmedia_codec_audio_init(TMEDIA_CODEC(audio), plugin->name, plugin->desc, plugin->format);
							break;
						}
					case tmedia_video:
						{ /* Video codec */
							tmedia_codec_video_t* video = TMEDIA_CODEC_VIDEO(codec);
							tmedia_codec_video_init(TMEDIA_CODEC(video), plugin->name, plugin->desc, plugin->format);
							if(!video->in.width)video->in.width = video->out.width = plugin->video.width;
							if(!video->in.height)video->in.height = video->out.height = plugin->video.height;
							if(!video->in.fps)video->in.fps = video->out.fps = plugin->video.fps;
							if(video->in.chroma==tmedia_chroma_none)video->in.chroma = tmedia_chroma_yuv420p;
							if(video->out.chroma==tmedia_chroma_none)video->out.chroma = tmedia_chroma_yuv420p;
							break;
						}
					case tmedia_msrp:
						{	/* Msrp codec */
							tmedia_codec_msrp_init(codec, plugin->name, plugin->desc);
							break;
						}
					default:
						{	/* Any other codec */
							tmedia_codec_init(codec, plugin->type, plugin->name, plugin->desc, plugin->format);
							break;
						}
				}
				break;
			}
		}
	}

	return codec;
}

/**@ingroup tmedia_codec_group
* Gets the rtpmap attribute associated to this code.
* @param self the codec for which to get the rtpmap attribute. Should be created using @ref tmedia_codec_create().
* @retval rtpmap string (e.g. "AMR-WB/16000/2" or "H261/90000") if succeed and Null otherwise. It's up to the caller to free the
* returned string.
*/
char* tmedia_codec_get_rtpmap(const tmedia_codec_t* self)
{
	char* rtpmap = tsk_null;

	if(!self || !self->plugin){
		TSK_DEBUG_ERROR("invalid parameter");
		return tsk_null;
	}
	switch(self->type){
		case tmedia_audio:
			{	/* audio codecs */
				/* const tmedia_codec_audio_t* audioCodec = (const tmedia_codec_audio_t*)self; */

				// special case for G.722 which has fake rate
				if(tsk_strequals(self->plugin->format,TMEDIA_CODEC_FORMAT_G722)){
					tsk_sprintf(&rtpmap, "%s %s/8000/%d", self->neg_format? self->neg_format : self->format, self->name, self->plugin->audio.channels);
				}
				else{
					if(self->plugin->audio.channels > 0){
						tsk_sprintf(&rtpmap, "%s %s/%d/%d", self->neg_format? self->neg_format : self->format, self->name, self->plugin->rate, self->plugin->audio.channels);
					}
					else{
						tsk_sprintf(&rtpmap, "%s %s/%d", self->neg_format? self->neg_format : self->format, self->name, self->plugin->audio);
					}
				}
			}
			break;
		case tmedia_video:
			{	/* video codecs */
				/* const tmedia_codec_video_t* videoCodec = (const tmedia_codec_video_t*)self; */
				tsk_sprintf(&rtpmap, "%s %s/%d", self->neg_format? self->neg_format : self->format, self->name, self->plugin->rate);
				break;
			}
		/* all others */
		default:
			break;
	}

	return rtpmap;
}

/**@ingroup tmedia_codec_group
* Gets the codec's fmtp attribute value.
* @param self the codec for which to get the fmtp attribute. Should be created using @ref tmedia_codec_create().
* @retval fmtp attribute string (e.g. "mode-set=0,2,5,7; mode-change-period=2; mode-change-neighbor=1"). It's up to the caller to free the
* returned string.
*/
char* tmedia_codec_get_fmtp(const tmedia_codec_t* self)
{
	char* fmtp = tsk_null;

	if(!self || !self->plugin){
		TSK_DEBUG_ERROR("invalid parameter");
		return tsk_null;
	}

	if(self->plugin->fmtp_get){ /* some codecs, like G711, won't produce fmtp */
		fmtp = self->plugin->fmtp_get(self);
	}

	return fmtp;
}

/**@ingroup tmedia_codec_group
* Indicates whether the codec can handle this fmtp.
* @param self the codec to match aginst to.
* @param fmtp the fmtp to match
* @retval @a tsk_true if the codec can handle this fmtp and @a tsk_false otherwise
*/
tsk_bool_t tmedia_codec_match_fmtp(const tmedia_codec_t* self, const char* fmtp)
{
	/* checks */
	if(!self || !self->plugin || !self->plugin->fmtp_match){
		TSK_DEBUG_ERROR("invalid parameter");
		return tsk_false;
	}

	/* if fmtp is null or empty -> always match */
	if(tsk_strnullORempty(fmtp)){
		return tsk_true;
	}
	else{
		return self->plugin->fmtp_match(self, fmtp);
	}
}

/**@ingroup tmedia_codec_group
* Sets remote fmtp.
* @param self codec for which to set the remote fmtp.
* @param fmtp fmtp received from remote party (e.g. "mode-set=0,2,5,7; mode-change-period=2; mode-change-neighbor=1").
* @retval Zero if succeed and non-zero error code otherwise.
*/
int tmedia_codec_set_remote_fmtp(tmedia_codec_t* self, const char* fmtp)
{
	if(!self || !self->plugin){
		TSK_DEBUG_ERROR("invalid parameter");
		return -1;
	}

	if(self->plugin->fmtp_set){
		return self->plugin->fmtp_set(self, fmtp);
	}
	else{ /* some codecs, like G711, could ignore remote fmtp attribute */
		return 0;
	}
}

/**@ingroup tmedia_codec_group
* Remove all codecs except the specified ones.
* @param codecs the list of codecs from which to remove codecs.
* @param codecs2keep the codecs which shall not be removed.
* @retval zero if succeed (or nothing to do) and non-zero error code otherwise.
*/
int tmedia_codec_removeAll_exceptThese(tmedia_codecs_L_t* codecs, const tmedia_codecs_L_t * codecs2keep)
{
	tsk_list_item_t* item;
	if(!codecs || !codecs2keep){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}
again:
	tsk_list_foreach(item, codecs){
		if(!tsk_list_find_item_by_pred(codecs2keep, __pred_find_codec_by_format, ((tmedia_codec_t*)item->data)->format)){
			tsk_list_remove_item(codecs, item);
			goto again;
		}
	}
	return 0;
}

/**@ingroup tmedia_codec_group
* Serialize a list of codecs to sdp (m= line) message.<br>
* Will add: fmt, rtpmap and fmtp.
* @param codecs The list of codecs to convert
* @param m The destination
* @retval Zero if succeed and non-zero error code otherwise
*/


/**@ingroup tmedia_codec_group
* Finds a codec by format. If the codec has a dyn. payload type, then this function will also compare negociate formats.
* @param codecs List of codecs from which to retrieve the matching codec.
* @param format the format of the codec to find.
* @retval Zero if succeed and non-zero error code otherwise.
*/
tmedia_codec_t* tmedia_codec_find_by_format(tmedia_codecs_L_t* codecs, const char* format)
{
	const tmedia_codec_t* codec = tsk_null;

	if(!codecs || !format){
		TSK_DEBUG_ERROR("Inalid parameter");
		return tsk_null;
	}

	if((codec = tsk_list_find_object_by_pred(codecs, __pred_find_codec_by_format, format)) || 
		(codec = tsk_list_find_object_by_pred(codecs, __pred_find_codec_by_neg_format, format))){
		return tsk_object_ref((void*)codec);
	}
	else{
		return tsk_null;
	}
}

/**@ingroup tmedia_codec_group
*/
int tmedia_codec_parse_fmtp(const char* fmtp, unsigned* maxbr, unsigned* fps, unsigned *width, unsigned *height)
{
	char *copy, *pch;
	tsk_bool_t found = tsk_false;
	
	if(tsk_strnullORempty(fmtp)){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}

	copy = tsk_strdup(fmtp);
	pch = strtok(copy, "; /");

	while(pch){
		unsigned div = 0;
		
		if(sscanf(pch, "QCIF=%u", &div) == 1 && div){
			*fps = 30/div;

			found = tsk_true;
		}
		else if(sscanf(pch, "CIF=%u", &div) == 1 && div){
			*fps = 30/div;
			*width = 320;
			*height = 240;
			found = tsk_true;
		}
		else if(sscanf(pch, "SQCIF=%u", &div) == 1 && div){
			*fps = 30/div;
			*width = 128;
			*height = 96;
			found = tsk_true;
		}
		else if(sscanf(pch, "QVGA=%u", &div) == 1 && div){
			*fps = 30/div;
			*width = 320;
			*height = 240;
			found = tsk_true;
		}
		// to be continued

		if(found){
			//found = tsk_false;
			pch = strtok(tsk_null, "; ");
			while(pch){
				if(sscanf(pch, "MaxBR=%u", maxbr) == 1){
					//found = tsk_true;
					break;
				}
				pch = strtok(tsk_null, "; /");
			}
		}
		
		if(found){
			break;
		}

		pch = strtok(tsk_null, "; /");
	}

	TSK_FREE(copy);

	return found ? 0 : -2;
}

/**@ingroup tmedia_codec_group
* DeInitialize a Codec.
* @param self The codec to deinitialize. Could be any type of codec (e.g. @ref tmedia_codec_audio_t or @ref tmedia_codec_video_t).
* @retval Zero if succeed and non-zero error code otherwise.
*/
int tmedia_codec_deinit(tmedia_codec_t* self)
{
	if(!self){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}

	if(self->opened){
		tmedia_codec_close(self);
	}

	TSK_FREE(self->name);
	TSK_FREE(self->desc);
	TSK_FREE(self->format);
	TSK_FREE(self->neg_format);

	return 0;
}

int tmedia_codec_video_set_callback(tmedia_codec_video_t *self, tmedia_codec_video_rtpcb_f callback, const void* callback_data)
{
	if(!self){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}

	self->callback = callback;
	self->callback_data = callback_data;

	return 0;
}