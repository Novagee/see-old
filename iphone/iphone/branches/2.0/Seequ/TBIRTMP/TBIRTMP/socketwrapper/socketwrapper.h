//
//  socketwrapper.h
//  TBIRTMP
//
//  Created by Macbook on 12/22/12.
//  Copyright (c) 2012 Grigori Jlavyan. All rights reserved.
//

#ifndef __CF_SOCKET_H__
#define __CF_SOCKET_H__

#include "TBI_mutex.h"
#include "TBI_semaphore.h"
#include "TBI_timer.h"
#include "types.h"

#include <speex/speex_buffer.h>

#include <CoreFoundation/CFSocket.h>
#include <CoreFoundation/CFStream.h>

#include <sys/socket.h>

#define RTMP_BUFFER_CACHE_SIZE (16*1024)

#if RTMP_ENCODING_ON
struct tbi_rsa_t;
struct tbi_rc4_t;
#endif //RTMP_ENCODING_ON

typedef struct Socket_s
{
    int sb_socket;
    int sb_size;                            /* number of unprocessed bytes in buffer */
    char *sb_start;                         /* pointer into sb_pBuffer of next byte to process */
    char sb_buf[RTMP_BUFFER_CACHE_SIZE];	/* data read from socket */
    int sb_timedout;
    void *sb_ssl;
    int sb_noconnection;
    
//    SpeexBuffer *incomingBuffer;
    
    volatile uint32_t    bIsLocked;
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
    CFRunLoopRef        runLoopRef;
    
    int nIsStreamsOpened;
    tbi_bool_t sb_isvoipsock;
    tbi_bool_t sb_interupt;
    tbi_bool_t bIsReadZeroReturned;
    tbi_bool_t bIsReadErrorOccurred;
    tbi_bool_t bIsWriteZeroReturned;
    tbi_bool_t bIsWriteErrorOccurred;
    
    void* tid;
    
    tbi_bool_t bIsTimerOut;
//    TBI_timer_id_t recvTimerId;
//    tbi_bool_t bIsWait;
    
//    TBI_mutex_handle_t* mutexIncomingBuffer;
//    TBI_semaphore_handle_t* semRecvData;
    
    TBI_mutex_handle_t* mutex;

#if RTMP_ENCODING_ON
    struct tbi_rsa_t* rsa;
    struct tbi_rc4_t* rc4;
    
    char* encData;
    int encSize;
    
    char decData[2048];
    
    tbi_bool_t bIsFirstSend;
#endif //RTMP_ENCODING_ON
} Socket_t;

int cfsocket(Socket_t* sock, int af, int type, int protocol);
int cfconnect(Socket_t* sock, const struct sockaddr *name, int namelen);
int cfsend(Socket_t* sock, const char *buf, int len,  int flags);
int cfrecv(Socket_t* sock, char *buf, int len,  int flags);
int cfclose(Socket_t* sock);
tbi_bool_t cfisvalidsocket(const Socket_t* sock);

#endif //__CF_SOCKET_H__
