
//  TBIRTMP
//
//  Created by Macbook on 12/22/12.
//  Copyright (c) 2012 Grigori Jlavyan. All rights reserved.
//
#include "socketwrapper.h"
#include "TBI_thread.h"
#include "TBI_timer.h"
#include "TBIRTMP.h"

#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <errno.h>
#include <libkern/OSAtomic.h>

#define INCOMING_MESSAGE_BUFFER_SIZE    16*1024
#define OUTGOING_MESSAGE_BUFFER_SIZE    16*1024

#define CFReadStreamOpenCompleted       1
#define CFWriteStreamOpenCompleted      2
#define CFBothStreamOpenCompleted       (CFReadStreamOpenCompleted | CFWriteStreamOpenCompleted)

//int cfsocket(Socket_t* sock, int af, int type, int protocol)
//{
//    if(!sock)
//        return -1;
//
//    sock->sb_socket = socket(af, type, protocol);
//
//    return sock->sb_socket;
//}
//
//int cfconnect(Socket_t* sock, const struct sockaddr *name, int namelen)
//{
//    if(!sock)
//        return -1;
//
//    return connect(sock->sb_socket, name, namelen);
//}
//
//int cfsend(Socket_t* sock, const char *buf, int len,  int flags)
//{
//    if(!sock)
//        return -1;
//
//    return send(sock->sb_socket, buf, len, flags);
//}
//
//int cfrecv(Socket_t* sock, char *buf, int len,  int flags)
//{
//    if(!sock)
//        return -1;
//
//    return recv(sock->sb_socket, buf, len, flags);
//}
//
//int cfclose(Socket_t* sock)
//{
//    if(!sock)
//        return -1;
//
//    return close(sock->sb_socket);
//}

//bool isConnectedSocket(Socket_t *sock){
//
//    if(iphoneNetwork)
//        return [iphoneNetwork isConnected];
//
//    return false;
//}

in_port_t get_in_port(struct sockaddr *sa)
{
    if (sa->sa_family == AF_INET) {
        return (((struct sockaddr_in*)sa)->sin_port);
    }
    
    return (((struct sockaddr_in6*)sa)->sin6_port);
}

void *get_in_addr(struct sockaddr *sa)
{
    if (sa->sa_family == AF_INET) {
        return &(((struct sockaddr_in*)sa)->sin_addr);
    }
    
    return &(((struct sockaddr_in6*)sa)->sin6_addr);
}

#include "log.h"
void onStreamHasBytesAvailable(Socket_t* sock)
{
    //    NSLog(@"onStreamHasBytesAvailable !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    //    if(sock->bIsWait)
    //    {
    //        sock->bIsWait = tbi_false;
    //        TBI_semaphore_increment(sock->semRecvData);
    //    }
}

//void onStreamHasBytesAvailable2(Socket_t* sock)
//{
//    const int size = 2048;
//    uint8_t message[2048];
//
//    int nBytes = 0;
//    do
//    {
//        nBytes = CFReadStreamRead(sock->readStream, message, size);
//        if(nBytes > 0)
//        {
//            TBI_mutex_lock(sock->mutexIncomingBuffer);
//            int avel = speex_buffer_get_available(sock->incomingBuffer);
//            fprintf(stderr, "################# @@@@@@@@@@@@@@@@@@ %d @@@@@@@@@@@@@@@@ ######################\n", avel);
//
//
//            RTMP_LogHexString(RTMP_LOGERROR, message, nBytes);
//            speex_buffer_write(sock->incomingBuffer, message, nBytes);
//            if(sock->bIsWait)
//            {
//                sock->bIsWait = tbi_false;
//                TBI_semaphore_increment(sock->semRecvData);
//            }
//            TBI_mutex_unlock(sock->mutexIncomingBuffer);
//        }
//    } while (nBytes == size);
//}

//void onStreamHasBytesAvailable1(Socket_t* sock)
//{
//    int size = 2048;
//    uint8_t message[2048];
////    native_debug_function("onStreamHasBytesAvailable =========================== \n");
//    int nBytes = CFReadStreamRead(sock->readStream, message, size);
//    if(nBytes > 0)
//    {
//        TBI_mutex_lock(sock->mutexIncomingBuffer);
//        speex_buffer_write(sock->incomingBuffer, message, nBytes);
//        if(sock->bIsWait)
//        {
//            sock->bIsWait = tbi_false;
//            TBI_semaphore_increment(sock->semRecvData);
//        }
//        TBI_mutex_unlock(sock->mutexIncomingBuffer);
//    }
//}

static void ReadStreamClientCallBack(CFReadStreamRef stream, CFStreamEventType type, void *clientCallBackInfo)
{
    Socket_t* sock = (Socket_t*)clientCallBackInfo;
    switch (type)
    {
        case kCFStreamEventOpenCompleted:
            //            NSLog(@"ReadStreamClientCallBack::kCFStreamEventOpenCompleted");
            sock->nIsStreamsOpened |= CFReadStreamOpenCompleted;
            break;
            
        case kCFStreamEventHasBytesAvailable:
            //            NSLog(@"ReadStreamClientCallBack::kCFStreamEventHasBytesAvailable");
            onStreamHasBytesAvailable(sock);
            break;
            
        case kCFStreamEventErrorOccurred:
            NSLog(@"ReadStreamClientCallBack::kCFStreamEventErrorOccurred");
            sock->bIsReadErrorOccurred = tbi_true;
            break;
            
        case kCFStreamEventEndEncountered:
        {
            NSLog(@"ReadStreamClientCallBack::kCFStreamEventEndEncountered");
            sock->bIsReadZeroReturned = tbi_true;
        }
            break;
            
        default:
            NSLog(@"ReadStreamClientCallBack::default");
            break; // do nothing
    }
}

static void WriteStreamClientCallBack(CFWriteStreamRef stream, CFStreamEventType type, void *clientCallBackInfo)
{
    Socket_t* sock = (Socket_t*)clientCallBackInfo;
    switch (type)
    {
        case kCFStreamEventOpenCompleted:
            //            NSLog(@"WriteStreamClientCallBack::kCFStreamEventOpenCompleted");
            sock->nIsStreamsOpened |= CFWriteStreamOpenCompleted;
            break;
            
        case kCFStreamEventCanAcceptBytes:
            //            NSLog(@"WriteStreamClientCallBack::kCFStreamEventCanAcceptBytes");
            break;
            
        case kCFStreamEventErrorOccurred:
            NSLog(@"WriteStreamClientCallBack::kCFStreamEventErrorOccurred");
            sock->bIsReadErrorOccurred = tbi_true;
            break;
            
        case kCFStreamEventEndEncountered:
            NSLog(@"WriteStreamClientCallBack::kCFStreamEventEndEncountered");
            sock->bIsReadZeroReturned = tbi_true;
            break;
            
        default:
            NSLog(@"WriteStreamClientCallBack::default");
            break; // do nothing
    }
}

int cfsocket(Socket_t* sock, int af, int type, int protocol)
{
    if(!sock)
        return -1;
    
    sock->readStream = NULL;
    sock->writeStream = NULL;
    sock->runLoopRef = NULL;
    sock->bIsLocked = 0;
    sock->mutex = NULL;
    
    sock->bIsReadZeroReturned = tbi_false;
    sock->bIsReadErrorOccurred = tbi_false;
    sock->bIsWriteZeroReturned = tbi_false;
    sock->bIsWriteErrorOccurred = tbi_false;
    
    //    sock->incomingBuffer = NULL;
    //    sock->mutexIncomingBuffer = TBI_mutex_create();
    if ((sock->sb_socket = socket(af, type, protocol)) == -1)
        return -1;
    
    if(sock->sb_isvoipsock)
    {
        sock->mutex = TBI_mutex_create();
        
        //        sock->semRecvData = TBI_semaphore_create();
        //        TBI_timer_mgr_global_ref();
        //        TBI_timer_mgr_global_start();
        //        sock->bIsWait = tbi_false;
    }
    
    return sock->sb_socket;
}

void zero(void)
{
    NSLog(@"0");
}

void one(void)
{
    NSLog(@"-1");
}

void two(void)
{
    NSLog(@"-2");
}

void three(void)
{
    NSLog(@"-3");
}

void four(void)
{
    NSLog(@"-4");
}

void five(void)
{
    NSLog(@"-5");
}

static void* initCFSocket(void* param)
{
    Socket_t* sock = (Socket_t*)param;
    
    CFStreamCreatePairWithSocket(NULL, sock->sb_socket, &sock->readStream, &sock->writeStream);
    if(sock->readStream == NULL || sock->writeStream == NULL)
        return one;
    
    if (!CFReadStreamSetProperty(sock->readStream, kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP))
        NSLog(@"Error - Failed to set VoIP type to CFReadStreamRef\n");
    
    if (!CFWriteStreamSetProperty(sock->writeStream, kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP))
        NSLog(@"Error - Failed to set VoIP type to CFWriteStreamRef\n");
    
    int nrFlags = kCFStreamEventOpenCompleted | kCFStreamEventHasBytesAvailable | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered;
    int nwFlags = kCFStreamEventOpenCompleted | kCFStreamEventCanAcceptBytes    | kCFStreamEventErrorOccurred | kCFStreamEventEndEncountered;
    
    CFStreamClientContext context = {0, (void*)sock, NULL, NULL, NULL};
    
    if (!CFReadStreamSetClient(sock->readStream, nrFlags, ReadStreamClientCallBack, &context) )
        return two;
    
    if ( !CFWriteStreamSetClient(sock->writeStream, nwFlags, WriteStreamClientCallBack, &context) )
        return three;
    
    sock->runLoopRef = CFRunLoopGetCurrent();
    CFReadStreamScheduleWithRunLoop(sock->readStream, sock->runLoopRef, kCFRunLoopCommonModes);
    CFWriteStreamScheduleWithRunLoop(sock->writeStream, sock->runLoopRef, kCFRunLoopCommonModes);
    
    if(!CFReadStreamOpen(sock->readStream))
    {
        NSLog(@"CFReadStreamOpen: Failed!!!");
        return four;
    }
    
    if(!CFWriteStreamOpen(sock->writeStream))
    {
        NSLog(@"CFWriteStreamOpen: Failed!!!");
        return five;
    }
    
    CFRunLoopRun();
    
    return zero;
}

int cfconnect(Socket_t* sock, const struct sockaddr *name, int namelen)
{
    int rv = -1;
    if(!sock)
        return -1;
    
    if((rv = connect(sock->sb_socket, name, namelen)) == -1)
        return -2;
    
    struct sockaddr_in local;
    int localLen = sizeof(local);
    getsockname(sock->sb_socket, (struct sockaddr*)&local, (socklen_t*)&localLen);
    
    NSLog(@"################## LOCAL IP %s PORT %d ##################", inet_ntoa(local.sin_addr), ntohs(local.sin_port));
    
    if(sock->sb_isvoipsock)
    {
        //        sock->incomingBuffer = speex_buffer_init(INCOMING_MESSAGE_BUFFER_SIZE);
        
        sock->nIsStreamsOpened = 0;
        TBI_thread_create(&sock->tid, initCFSocket, sock);
        
        int n = 600;
        while (--n)
        {
            if((sock->nIsStreamsOpened&CFBothStreamOpenCompleted) == CFBothStreamOpenCompleted)
            {
                NSLog(@"In & out streams are opened!!!");
                return rv;
            }
            
            usleep(50000);
        }
        NSLog(@"In (%s) / Out (%s) stream(s) open failed!", (sock->nIsStreamsOpened&CFReadStreamOpenCompleted ? "true" : "false"), (sock->nIsStreamsOpened&CFWriteStreamOpenCompleted ? "true" : "false"));
        return -3;
    }
    
    return rv;
}

int cfsend(Socket_t* sock, const char *buf, int len,  int flags)
{
    if(!sock)
        return -1;
    int size = 0;
    TBI_mutex_lock(sock->mutex);
    
    if(sock->sb_isvoipsock)
    {
        if(sock->writeStream && CFWriteStreamCanAcceptBytes(sock->writeStream))
            size = CFWriteStreamWrite(sock->writeStream, (const UInt8*)buf, len);
    }
    else
    {
        size = send(sock->sb_socket, buf, len, flags);
    }
    TBI_mutex_unlock(sock->mutex);
    
    return size;
}

//int cfrecv_timer_callback(const void* arg, TBI_timer_id_t timer_id)
//{
//    Socket_t* sock = (Socket_t*)arg;
//    if(sock)
//    {
//        sock->bIsTimerOut = tbi_true;
//        TBI_mutex_lock(sock->mutexIncomingBuffer);
//        if(sock->bIsWait)
//        {
//            sock->bIsWait = tbi_false;
//            TBI_semaphore_increment(sock->semRecvData);
//        }
//        TBI_mutex_unlock(sock->mutexIncomingBuffer);
//        native_debug_function("Receive timed out!!!!!!!!!!!!!!!!!");
//    }
//
//    return 0;
//}

int cfrecv(Socket_t* sock, char *buf, int len,  int flags)
{
    int size = -2;
    if(sock->sb_isvoipsock)
    {
        OSAtomicOr32(0x01, &sock->bIsLocked);
        if(!sock->readStream && sock->bIsReadZeroReturned)
        {
            NSLog(@"ReadData: No connection!!!!");
            OSAtomicAnd32(0xFE, &sock->bIsLocked);
            return 0;
        }
        if(sock->bIsReadErrorOccurred)
        {
            NSLog(@"ReadData: bIsErrorOccurred == true");
            OSAtomicAnd32(0xFE, &sock->bIsLocked);
            return -1;
        }
        
        
        do
        {
            if(!cfisvalidsocket(sock) || !sock->readStream)
            {
                NSLog(@"ReadData: Not valid socket or no connection!!!!");
                OSAtomicAnd32(0xFE, &sock->bIsLocked);
                return -1;
            }
            
            if(CFReadStreamHasBytesAvailable(sock->readStream))
            {
                size = CFReadStreamRead(sock->readStream, (UInt8*)buf, (CFIndex)len);
                OSAtomicAnd32(0xFE, &sock->bIsLocked);
                return size;
            }
            
            //            sock->bIsWait = tbi_true;
            //            sock->bIsTimerOut = tbi_false;
            //            sock->recvTimerId = TBI_timer_mgr_global_schedule(30000, cfrecv_timer_callback, sock);
            //
            //            TBI_semaphore_decrement(sock->semRecvData);
            //            TBI_timer_mgr_global_cancel(sock->recvTimerId);
            
            sock->bIsTimerOut = tbi_false;
            
            struct timeval tv;
            tv.tv_sec = 30;
            tv.tv_usec = 0;
            
            fd_set rdSet;
            FD_ZERO(&rdSet);
            FD_SET(sock->sb_socket, &rdSet);
            
            if(select(sock->sb_socket + 1, &rdSet, 0, 0, &tv) == 0)
                sock->bIsTimerOut = tbi_true;
            
        } while (!(sock->bIsLocked&0x02) && !sock->bIsTimerOut);
        
        if((sock->bIsLocked&0x02))
        {
            if(sock->readStream)
            {
                fprintf(stderr, "cfclose: close read stream 2\n");
// SUNDAY - JSC                CFReadStreamUnscheduleFromRunLoop(sock->readStream, sock->runLoopRef, kCFRunLoopCommonModes);
                CFReadStreamClose(sock->readStream);
                CFRelease(sock->readStream);
                sock->readStream = NULL;
            }
        }
        
        OSAtomicAnd32(0xFE, &sock->bIsLocked);
    }
    else
    {
        size = recv(sock->sb_socket, buf, len, flags);
    }
    
    return size;
}

//int cfrecv1(Socket_t* sock, char *buf, int len,  int flags)
//{
//    int size = 0, available;
//    if(sock->sb_isvoipsock)
//    {
//        if(sock->bIsReadErrorOccurred)
//        {
//            NSLog(@"ReadData: bIsErrorOccurred == true");
//            return -1;
//        }
//        else if(sock->bIsReadZeroReturned)
//        {
//            NSLog(@"ReadData: bIsZeroReturned == true");
//            return 0;
//        }
//
//        do
//        {
//            if(!cfisvalidsocket(sock))
//                return -1;
//
//            TBI_mutex_lock(sock->mutexIncomingBuffer);
//            available = speex_buffer_get_available(sock->incomingBuffer);
//            if(available > 0)
//            {
////                fprintf(stderr, "available ================ %d\n", available);
//                size = speex_buffer_read(sock->incomingBuffer, (void*)buf, len);
//                TBI_mutex_unlock(sock->mutexIncomingBuffer);
//                return size;
//            }
//            sock->bIsWait = tbi_true;
//            TBI_mutex_unlock(sock->mutexIncomingBuffer);
//
//            sock->bIsTimerOut = tbi_false;
//            sock->recvTimerId = TBI_timer_mgr_global_schedule(30000, cfrecv_timer_callback, sock);
//
//            TBI_semaphore_decrement(sock->semRecvData);
//            TBI_timer_mgr_global_cancel(sock->recvTimerId);
//
//        } while (!sock->bIsTimerOut);
//
//        size = -2;
//    }
//    else
//    {
//        size = recv(sock->sb_socket, buf, len, flags);
//    }
//    return size;
//}

int cfclose(Socket_t* sock)
{
    int rv = 0;
    
    if(sock->sb_isvoipsock)
    {
        TBI_mutex_lock(sock->mutex);
        
        if(sock->runLoopRef)
            CFRunLoopStop(sock->runLoopRef);
        
        int32_t b = sock->bIsLocked;
        OSAtomicOr32(0x02, &sock->bIsLocked);
        
        if((b & 0x01) == 0)
        {
            if(sock->readStream)
            {
                fprintf(stderr, "cfclose: close read stream 1\n");
                CFReadStreamUnscheduleFromRunLoop(sock->readStream, sock->runLoopRef, kCFRunLoopCommonModes);
                CFReadStreamClose(sock->readStream);
                CFRelease(sock->readStream);
                sock->readStream = NULL;
            }
        }
        
        if(sock->writeStream)
        {
            fprintf(stderr, "cfclose: close write stream\n");
            CFWriteStreamUnscheduleFromRunLoop(sock->writeStream, sock->runLoopRef, kCFRunLoopCommonModes);
            CFWriteStreamClose(sock->writeStream);
            CFRelease(sock->writeStream);
            sock->writeStream = NULL;
        }
        
        if(sock->tid)
            TBI_thread_join(&sock->tid);
        
        TBI_mutex_unlock(sock->mutex);
        
        if(sock->mutex)
            TBI_mutex_destroy(&sock->mutex);
    }
    
    if(sock->sb_socket != -1)
    {
        fprintf(stderr, "cfclose: close socket\n");
        rv = close(sock->sb_socket);
        sock->sb_socket = -1;
    }
    
    //    if(sock->sb_isvoipsock)
    //    {
    ////        if(sock->semRecvData)
    ////        {
    ////            if(sock->bIsWait)
    ////                TBI_semaphore_increment(sock->semRecvData);
    ////            TBI_semaphore_destroy(&sock->semRecvData);
    ////        }
    //
    ////        if(sock->incomingBuffer)
    ////        {
    ////            speex_buffer_destroy(sock->incomingBuffer);
    ////            sock->incomingBuffer = 0;
    ////        }
    //
    ////        TBI_timer_mgr_global_stop();
    ////        TBI_timer_mgr_global_unref();
    //    }
    
    return rv;
}

tbi_bool_t cfisvalidsocket(const Socket_t* sock)
{
    if(sock->sb_isvoipsock)
    {
        return  (sock->sb_socket != -1       &&
                 !sock->bIsReadZeroReturned  &&
                 !sock->bIsWriteZeroReturned &&
                 !sock->bIsReadErrorOccurred &&
                 !sock->bIsWriteErrorOccurred);
    }
    return sock->sb_socket != -1;
}
