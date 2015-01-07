/*
 *  CompatQueue.h
 *  libnice-darwin
 *
 *  Created by Vadim Tsyganok on 8/19/10.
 *  Copyright 2010 tsyganok.com. All rights reserved.
 *
 */

// Double-ended queue.
#ifndef COMPAT_QUEUE
#define COMPAT_QUEUE

#include "CompatList.h"

typedef struct 
{
	CompatList *head;
	CompatList *tail;
	unsigned int  length;
} CompatQueue;

//Adds a new element at the tail of the queue.
void compat_queue_push_tail (CompatQueue *queue, void* data);
void* compat_queue_pop_head(CompatQueue *queue);
void compat_queue_remove(CompatQueue* queue, const void* data);
// Removes all the elements in queue. If queue elements contain dynamically-allocated memory, they should be freed first.
void compat_queue_clear(CompatQueue* queue);

void compat_queue_foreach(CompatQueue *queue, CompatFunc func, void* user_data);

#define compat_queue_new() ((CompatQueue*)calloc(1, sizeof(CompatQueue)))
#define compat_queue_free(q) free(q)

// First link (head container)
CompatList* compat_queue_peek_head_link(CompatQueue* queue);

#define GQueue CompatQueue
#define g_queue_new() compat_queue_new()
#define g_queue_free(q) compat_queue_free(q)
#define g_queue_push_tail(q,d) compat_queue_push_tail(q,d)
#define g_queue_pop_head(q) compat_queue_pop_head(q)
#define g_queue_remove(q,d) compat_queue_remove(q,d)
#define g_queue_clear(q) compat_queue_clear(q)
#define g_queue_foreach(q,f,ud) compat_queue_foreach(q,f,ud)
#define g_queue_peek_head_link(q) compat_queue_peek_head_link(q)
#endif