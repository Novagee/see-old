

/**@file tmedia_qos.c
 * @brief RFC 3312 (Preconditions) implementation.
 *

 *

 */
#include "tinymedia/tmedia_qos.h"

#include "tsk_memory.h"
#include "tsk_debug.h"

/* ========================= Internal ==================================*/

static const char* tmedia_qos_strength_tostring(tmedia_qos_strength_t strength)
{
	switch(strength){
		case tmedia_qos_strength_none:
			return "none";
		case tmedia_qos_strength_mandatory:
			return "mandatory";
		case tmedia_qos_strength_optional:
			return "optional";
		case tmedia_qos_strength_failure:
			return "failure";
		case tmedia_qos_strength_unknown:
		default:
			return "unknown";
	}
}

static tmedia_qos_strength_t tmedia_qos_strength_fromstring(const char* strength)
{
	if(tsk_strequals(strength, "none")){
		return tmedia_qos_strength_none;
	}
	else if(tsk_strequals(strength, "mandatory")){
		return tmedia_qos_strength_mandatory;
	}
	else if(tsk_strequals(strength, "optional")){
		return tmedia_qos_strength_optional;
	}
	else if(tsk_strequals(strength, "failure")){
		return tmedia_qos_strength_failure;
	}
	else{
		return tmedia_qos_strength_unknown;
	}
}

static tmedia_qos_direction_t tmedia_qos_direction_fromstring(const char* direction)
{
	if(tsk_strequals(direction, "send")){
		return tmedia_qos_direction_send;
	}
	else if(tsk_strequals(direction, "recv")){
		return tmedia_qos_direction_recv;
	}
	else if(tsk_strequals(direction, "sendrecv")){
		return tmedia_qos_direction_sendrecv;
	}
	else{
		return tmedia_qos_direction_none;
	}
}

/* ========================= Common ==================================*/

tmedia_qos_tline_t* tmedia_qos_tline_create(tmedia_qos_stype_t type, tmedia_qos_strength_t strength)
{
	switch(type){
		case tmedia_qos_stype_e2e:
			return (tmedia_qos_tline_t*)tmedia_qos_tline_e2e_create(strength);
		case tmedia_qos_stype_segmented:
			return (tmedia_qos_tline_t*)tmedia_qos_tline_segmented_create(strength);
        default:
            break;
	}
	return tsk_null;
}





int tmedia_qos_tline_set_ro(tmedia_qos_tline_t* self, const tmedia_qos_tline_t* ro)
{
	if(!self || !ro){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}

	switch(self->type){
		case tmedia_qos_stype_e2e:
			return tmedia_qos_tline_e2e_set_ro((tmedia_qos_tline_e2e_t*)self, (const tmedia_qos_tline_e2e_t*)ro);
		case tmedia_qos_stype_segmented:
			return tmedia_qos_tline_segmented_set_ro((tmedia_qos_tline_segmented_t*)self, (const tmedia_qos_tline_segmented_t*)ro);
		default:
			TSK_DEBUG_ERROR("Invalid type");
			return -2;
	}
}

tsk_bool_t tmedia_qos_tline_canresume(const tmedia_qos_tline_t* self)
{
	if(!self){
		TSK_DEBUG_ERROR("Invalid parameter");
		return tsk_true;
	}
	switch(self->type){
		case tmedia_qos_stype_segmented:
			return tmedia_qos_tline_segmented_canresume((const tmedia_qos_tline_segmented_t*)self); 
		case tmedia_qos_stype_e2e:
			return tmedia_qos_tline_e2e_canresume((const tmedia_qos_tline_e2e_t*)self);
		default:
			return tsk_true;
	}
}

/* ========================= E2E ==================================*/

tmedia_qos_tline_e2e_t* tmedia_qos_tline_e2e_create(tmedia_qos_strength_t strength)
{
	return tsk_object_new(tmedia_qos_tline_e2e_def_t, strength);
}


int tmedia_qos_tline_e2e_set_ro(tmedia_qos_tline_e2e_t* self, const tmedia_qos_tline_e2e_t* ro)
{
	if(!self || !ro){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}

	/* We were the offerer
	* Remote asked for confirmation in its "recv" direction? 
	* "recv" direction for remote is our "send" direction
	* As we don't support RSVP (under the way), confirm immediatly.
	* "send" direction should not requested for confirmation
	*/
	if(ro->recv.confirm){
		self->send.current = tsk_true;
		goto bail;
	}
	if(ro->send.current){
		self->recv.confirm = tsk_false; /* remote confirmed */
		self->recv.current = tsk_true; /* because ro confirmed */
		self->send.current = tsk_true; /* beacuse we don't support RSVP */
		goto bail;
	}

	/* We are the answerer
	* As we don't support RSVP (under the way):
	* ==> request confirmation for "recv" direction if equal to "none" (not reserved)
	* =>
	*/
	if(!self->recv.current){
		self->recv.confirm = tsk_true;
		goto bail;
	}

bail:
	/* all other cases: success */
	return 0;
}

tsk_bool_t tmedia_qos_tline_e2e_canresume(const tmedia_qos_tline_e2e_t* self)
{
	if(!self){
		TSK_DEBUG_ERROR("Invalid parameter");
		return tsk_true;
	}

	/*  Example
		a=curr:qos e2e none
		a=des:qos mandatory e2e sendrecv

		Or

		a=curr:qos e2e send
		a=des:qos mandatory e2e recv
		a=des:qos optional e2e send
	*/

	/* only "mandatory" strength should force the application to continue nego. */
	if(self->recv.strength == tmedia_qos_strength_mandatory && !self->recv.current){
		return tsk_false;
	}
	/*else */if(self->send.strength == tmedia_qos_strength_mandatory && !self->send.current){
		return tsk_false;
	}
	
	/* "optinal" and "none" strengths */
	return tsk_true;
}

//
//	E2E QoS line object definition
//
static tsk_object_t* tmedia_qos_tline_e2e_ctor(tsk_object_t * self, va_list * app)
{
	tmedia_qos_tline_e2e_t *e2e = self;
	if(e2e){
		e2e->recv.strength = e2e->send.strength = va_arg(*app, tmedia_qos_strength_t);
		TMEDIA_QOS_TLINE(e2e)->type = tmedia_qos_stype_e2e;
	}
	return self;
}

static tsk_object_t* tmedia_qos_tline_e2e_dtor(tsk_object_t * self)
{ 
	tmedia_qos_tline_e2e_t *e2e = self;
	if(e2e){
	}

	return self;
}

static const tsk_object_def_t tmedia_qos_tline_e2e_def_s = 
{
	sizeof(tmedia_qos_tline_e2e_t),
	tmedia_qos_tline_e2e_ctor, 
	tmedia_qos_tline_e2e_dtor,
	tsk_null, 
};
const tsk_object_def_t *tmedia_qos_tline_e2e_def_t = &tmedia_qos_tline_e2e_def_s;










/* ========================= Segmented ==================================*/

tmedia_qos_tline_segmented_t* tmedia_qos_tline_segmented_create(tmedia_qos_strength_t strength)
{
	return tsk_object_new(tmedia_qos_tline_segmented_def_t, strength);
}


int tmedia_qos_tline_segmented_set_ro(tmedia_qos_tline_segmented_t* self, const tmedia_qos_tline_segmented_t* ro)
{
	if(!self || !ro){
		TSK_DEBUG_ERROR("Invalid parameter");
		return -1;
	}

	//////////////
	if(!ro->local_recv.current && !ro->remote_recv.confirm){
		/* request confirmation */
		self->remote_recv.confirm = tsk_true;
	}
	else{
		self->remote_recv.confirm = tsk_false;
		self->local_recv.current = tsk_true;
	}
	if(!ro->local_send.current && !ro->remote_send.confirm){
		/* request confirmation */
		self->remote_send.confirm = tsk_true;
	}
	else{
		self->remote_send.confirm = tsk_false;
		self->local_send.current = tsk_true;
	}

	//////////////
	if(ro->remote_recv.confirm){
		self->local_recv.current = tsk_true;
	}
	if(ro->remote_send.confirm){
		self->local_send.current = tsk_true;
	}

	//////////////
	if(ro->local_recv.current){
		self->remote_recv.current = tsk_true;
	}
	if(ro->local_send.current){
		self->remote_send.current = tsk_true;
	}

	return 0;
}

tsk_bool_t tmedia_qos_tline_segmented_canresume(const tmedia_qos_tline_segmented_t* self)
{
	if(!self){
		TSK_DEBUG_ERROR("Invalid parameter");
		return tsk_true;
	}

	/* == Strength is mandatory == */
	if(self->local_recv.strength == tmedia_qos_strength_mandatory && !self->local_recv.current){
		return tsk_false;
	}
	
	if(self->local_send.strength == tmedia_qos_strength_mandatory && !self->local_send.current){
		return tsk_false;
	}

	if(self->remote_recv.strength == tmedia_qos_strength_mandatory && !self->remote_recv.current){
		return tsk_false;
	}

	if(self->remote_send.strength == tmedia_qos_strength_mandatory && !self->remote_send.current){
		return tsk_false;
	}

	/* "optinal" and "none" strengths */
	return tsk_true;
}

//
//	Segmented QoS line object definition
//
static tsk_object_t* tmedia_qos_tline_segmented_ctor(tsk_object_t * self, va_list * app)
{
	tmedia_qos_tline_segmented_t *segmented = self;
	if(segmented){
		segmented->local_recv.strength = segmented->local_send.strength
			= segmented->remote_recv.strength = segmented->remote_send.strength = va_arg(*app, tmedia_qos_strength_t);
		TMEDIA_QOS_TLINE(segmented)->type = tmedia_qos_stype_segmented;
	}
	return self;
}

static tsk_object_t* tmedia_qos_tline_segmented_dtor(tsk_object_t * self)
{ 
	tmedia_qos_tline_segmented_t *segmented = self;
	if(segmented){
	}

	return self;
}

static const tsk_object_def_t tmedia_qos_tline_segmented_def_s = 
{
	sizeof(tmedia_qos_tline_segmented_t),
	tmedia_qos_tline_segmented_ctor, 
	tmedia_qos_tline_segmented_dtor,
	tsk_null, 
};
const tsk_object_def_t *tmedia_qos_tline_segmented_def_t = &tmedia_qos_tline_segmented_def_s;