/*
 *  CompatCallback.h
 *  libnice-darwin
 *
 *  Created by Dmitri Svetlanov on 8/20/10.
 *  Copyright 2010 tsyganok.com. All rights reserved.
 *
 */
#ifndef COMPAT_CALLBACK
#define COMPAT_CALLBACK
#include "libnice/compat/gnu-compat.h"

#include "../agent.h"

typedef void (*T_cb_candidate_gathering_done)(NiceAgent *agent, void* context, guint stream_id);

typedef void (*T_cb_component_state_changed)(NiceAgent *agent, void* context, guint stream_id, guint component_id, guint state);

typedef void (*T_cb_initial_binding_request_received)(NiceAgent *agent, void* context, guint stream_id);

typedef void (*T_cb_new_selected_pair)(NiceAgent *agent, void* context, guint stream_id, guint component_id, gchar *lfoundation, gchar* rfoundation);

typedef void (*T_cb_new_candidate)(NiceAgent *agent, void* context, guint stream_id, guint component_id, gchar *foundation);

typedef void (*T_cb_new_remote_candidate)(NiceAgent *agent, void* context, guint stream_id, guint component_id, gchar *foundation);

typedef void (*T_cb_reliable_transport_writable)(NiceAgent *agent, void* context, guint stream_id, guint component_id);


// Almost a must for proper thread synchronization.
typedef void (*T_mutex)(NiceAgent *agent, void* context);




typedef struct 
{
	void* context;
	
	T_cb_candidate_gathering_done cb_candidate_gathering_done;
	T_cb_component_state_changed cb_component_state_changed;
	T_cb_new_selected_pair cb_new_selected_pair;
	T_cb_new_candidate cb_new_candidate;
	T_cb_initial_binding_request_received cb_initial_binding_request_received;
	T_cb_new_remote_candidate cb_new_remote_candidate;
	T_cb_reliable_transport_writable cb_reliable_transport_writable;
	// Define 2 methods to use specific lock/unlock operations.
	T_mutex lock;
	T_mutex unlock;
	
} CompatCallback;



#endif