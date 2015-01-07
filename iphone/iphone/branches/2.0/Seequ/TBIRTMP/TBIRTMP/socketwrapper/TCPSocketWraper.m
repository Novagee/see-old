//
//  TCPSocketWraper.m
//  TBIRTMP
//
//  Created by Grigori Jlavyan on 1/21/13.
//  Copyright (c) 2013 Grigori Jlavyan. All rights reserved.
//

#import "TCPSocketWraper.h"
#include <errno.h>
#include <stdint.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <errno.h>

#define INVALID_SOCKET -1
//
//@interface TCPSocketWraper()
//
//@property (nonatomic, retain)   NSInputStream *   networkInStream;
//@property (nonatomic, retain)   NSOutputStream *  networkOutStream;
//
//@end


@implementation TCPSocketWraper
//
//@synthesize networkInStream = _networkInStream;
//@synthesize networkOutStream = _networkOutStream;
//typedef struct AVal
//{
//    char *av_val;
//    int av_len;
//} AVal;
//
//static int add_addr_info(struct sockaddr_in *service, AVal *host, int port)
//{
//
//        static struct hostent *host = 0;
//        if(host==0)
//            host = gethostbyname(hostname);
//
//    return host;
//}
- (id)init{
    bIsErrorOccurred = false;
    bIsZeroReturned = false;
    return [super init];
}

- (bool) connect2server:(int) s {
    
    //	// set socket to non-blocking mode
    //	int flag;
    //	flag = fcntl( m_s, F_GETFL, 0 );
    //	fcntl( m_s, F_SETFL, flag | O_NONBLOCK );
    incomingBuffer = speex_buffer_init(INCOMING_MESSAGE_BUFFER_SIZE);
    outgoungBuffer = speex_buffer_init(OUTGOING_MESSAGE_BUFFER_SIZE);
    mutexIncomingBuffer = TBI_mutex_create();
    
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
    
    CFStreamCreatePairWithSocket(NULL, s, &readStream, &writeStream);
    assert(readStream != NULL && writeStream != NULL);
    if (!CFReadStreamSetProperty(readStream, kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP))
        NSLog(@"Error - Failed to set VoIP type to CFReadStreamRef\n");
    
    self->networkInStream = (__bridge NSInputStream *) readStream;
    self->networkOutStream = (__bridge NSOutputStream *) writeStream;
    
    CFRelease(readStream);
    CFRelease(writeStream);
    
    [self->networkInStream setProperty:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
    
    self->bIsInStreamOpened = false;
    [self->networkInStream setDelegate:self];
    [self->networkInStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self->networkInStream open];
    
    self->bIsOutStreamOpened = false;
    [self->networkOutStream setDelegate:self];
    [self->networkOutStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self->networkOutStream open];
    
    int n = 600;
    while (--n)
    {
        if(self->bIsInStreamOpened && self->bIsOutStreamOpened)
        {
            NSLog(@"In & out streams are opened!!!");
            return true;
        }
        
        usleep(50000);
    }
    
    NSLog(@"In & out streams open failed!!!");
	return false;
}

//- (bool) connect2server:(int) u_port ip:(const char*)ip{
//
//    //	// set socket to non-blocking mode
//    //	int flag;
//    //	flag = fcntl( m_s, F_GETFL, 0 );
//    //	fcntl( m_s, F_SETFL, flag | O_NONBLOCK );
//    incomingBuffer = speex_buffer_init(INCOMING_MESSAGE_BUFFER_SIZE);
//    outgoungBuffer = speex_buffer_init(OUTGOING_MESSAGE_BUFFER_SIZE);
//
//	m_s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
//	if(m_s == INVALID_SOCKET)
//	{
//		NSLog(@"Error - socket creation error\n");
//		return false;
//	}
//
//	struct sockaddr_in peer;
//	memset(&peer, 0, sizeof(peer));
//	peer.sin_family = AF_INET;
//	peer.sin_port = htons(u_port);
//
//	unsigned long addr = inet_addr(ip);
//	peer.sin_addr.s_addr = addr;
//
//	if(connect(m_s, (struct sockaddr*)&peer, sizeof(peer)) == -1)
//	{
//		close(m_s);
//		m_s = INVALID_SOCKET;
//		NSLog(@"Error - connect error\n");
//		return false;
//	}
//
//    mutexIncomingBuffer = TBI_mutex_create();
//
//    CFReadStreamRef     readStream;
//    CFWriteStreamRef    writeStream;
//
//    CFStreamCreatePairWithSocket(NULL, m_s, &readStream, &writeStream);
//    assert(readStream != NULL && writeStream != NULL);
//    if (!CFReadStreamSetProperty(readStream, kCFStreamNetworkServiceType, kCFStreamNetworkServiceTypeVoIP))
//        NSLog(@"Error - Failed to set VoIP type to CFReadStreamRef\n");
//
//    self->networkInStream = (__bridge NSInputStream *) readStream;
//    self->networkOutStream = (__bridge NSOutputStream *) writeStream;
//
//    CFRelease(readStream);
//    CFRelease(writeStream);
//
//    [self->networkInStream setProperty:(id)kCFBooleanTrue forKey:(NSString *)kCFStreamPropertyShouldCloseNativeSocket];
//
//    [self->networkInStream setDelegate:self];
//    [self->networkInStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
//    [self->networkInStream open];
//
//    [self->networkOutStream setDelegate:self];
//    [self->networkOutStream scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
//    [self->networkOutStream open];
//
//	return true;
//}
//
- (void) disconnect
{
    NSLog(@"disconnecting");
    //TBI_mutex_destroy(mutexIncomingBuffer);
    [self->networkInStream setDelegate:nil];
    [self->networkInStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self->networkInStream close];
    
    [self->networkOutStream setDelegate:nil];
    [self->networkOutStream removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [self->networkOutStream close];
}

//- (bool) isConnected
//{
//    return m_s != INVALID_SOCKET;
//}
//
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode{
    
    //    NSLog(@"eventCode = %i",eventCode);
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
            char* p = "Unknown stream";
            if(aStream == self->networkInStream)
            {
                p = "In stream";
                self->bIsInStreamOpened = true;
            }
            if(aStream == self->networkOutStream)
            {
                p = "Out stream";
                self->bIsOutStreamOpened = true;
            }
            
            NSLog(@" ***************************** NSStreamEventOpenCompleted %s\n", p);
        } break;
        case NSStreamEventHasBytesAvailable: {
            
            if(aStream == self->networkInStream) {
                
                int size = 2048; //speex_buffer_get_available(incomingBuffer);
                uint8_t *message = malloc(size);
                int nBytes = [self->networkInStream read:(uint8_t*)message maxLength:size];
                if(nBytes > 0){
                    TBI_mutex_lock(mutexIncomingBuffer);
                    speex_buffer_write(self->incomingBuffer, message, nBytes);
                    TBI_mutex_unlock(mutexIncomingBuffer);
                }else{
                    if(nBytes == 0)
                    {
                        NSError *error = [aStream streamError];
                        NSLog(@"DISCONNECT %@", error);
                    }
                    else
                    {
                        NSError *error = [aStream streamError];
                        NSLog(@"Read failed %@", error);
                    }
                }
                free(message);
                
                //                NSLog(@" ***************************** nBytes = %i speex_buffer_get_available = %i", nBytes, speex_buffer_get_available(incomingBuffer));
            }
            //            NSLog(@" ***************************** NSStreamEventHasBytesAvailable\n");
        }break;
            
        case NSStreamEventHasSpaceAvailable: {
            if (aStream == self->networkOutStream) {
                //                //NSLog(@" ***************************** \n");
                //                int size = speex_buffer_get_available(outgoungBuffer);
                //                if(size>0){
                //                    uint8_t *message = malloc(size);
                //                    speex_buffer_read(outgoungBuffer, message, size);
                //                    int nBytes = [self->networkOutStream write:message maxLength:size];
                //                    speex_buffer_write(outgoungBuffer, message+nBytes, size-nBytes);
                //                    free(message);
                //                }
                //                NSLog(@" ***************************** NSStreamEventHasSpaceAvailable\n");
            }
        } break;
        case NSStreamEventErrorOccurred: {
            NSError *error = [aStream streamError];
            NSLog(@" ***************************** Error - Socket Stream has error (%@)\n", error);
            bIsErrorOccurred = true;
        } break;
        case NSStreamEventEndEncountered: {
            NSError *error = [aStream streamError];
            NSLog(@" ***************************** NSStreamEventEndEncountered %@\n", error);
            bIsZeroReturned = true;
        } break;
        default: {
            NSLog(@" ***************************** default - Socket Stream has default\n");
        } break;
    }
}
-(int) ReadData:(const UInt8*)buf size:(int)size{
    
    if(bIsErrorOccurred)
    {
        NSLog(@"ReadData: bIsErrorOccurred == true");
        return -1;
    }
    else if(bIsZeroReturned)
    {
        NSLog(@"ReadData: bIsZeroReturned == true");
        return 0;
    }
    
    TBI_mutex_lock(mutexIncomingBuffer);
    if(!incomingBuffer)
        incomingBuffer = speex_buffer_init(INCOMING_MESSAGE_BUFFER_SIZE);
    
    int available = speex_buffer_get_available(self->incomingBuffer);
    if(available == 0){
        TBI_mutex_unlock(mutexIncomingBuffer);
        return -2;
    }
    int len  = size > available ? available : size;
    speex_buffer_read(self->incomingBuffer, (void*)buf, len);
    TBI_mutex_unlock(mutexIncomingBuffer);
    
    //    NSLog(@"available = %i",available);
    return len;
}

-(int) WriteData:(const UInt8*)buf size:(int)size{
    
    if(bIsErrorOccurred)
    {
        NSLog(@"WriteData: bIsErrorOccurred == true");
        return -1;
    }
    
    int nBytes;
    //        speex_buffer_write(outgoungBuffer, (void*)buf,size);
    if ([self->networkOutStream hasSpaceAvailable]){
        nBytes = [self->networkOutStream write:buf maxLength:size];
        //        NSLog(@"nBytes = %i size = %i",nBytes,size);
        //        if(nBytes!=-1){
        //            char *message =malloc(nBytes);
        //            speex_buffer_read(outgoungBuffer, message, nBytes);
        //            free(message);
        //        }
        //        NSLog(@"WriteData: nBytes == %d", nBytes);
        return nBytes;
        //NSLog(@" WriteData - %i",nBytes);
    }
    else{
        NSLog(@"[self.networkOutStream hasSpaceAvailable] = NO");
    }
    return 0;
}
@end
