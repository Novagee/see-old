//
//  TCPSocketWraper.h
//  TBIRTMP
//
//  Created by Grigori Jlavyan on 1/21/13.
//  Copyright (c) 2013 Grigori Jlavyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <speex/speex_buffer.h>
#include "TBI_mutex.h"
#include "TBI_semaphore.h"

#define INCOMING_MESSAGE_BUFFER_SIZE 3072*4
#define OUTGOING_MESSAGE_BUFFER_SIZE 3072*4

@interface TCPSocketWraper : NSObject <NSStreamDelegate>
{
    NSInputStream *             networkInStream;
    NSOutputStream *            networkOutStream;
    
    bool bIsInStreamOpened;
    bool bIsOutStreamOpened;
    
    //    int m_s;
    SpeexBuffer *incomingBuffer;
    SpeexBuffer *outgoungBuffer;
    TBI_mutex_handle_t* mutexIncomingBuffer;
    
    bool bIsZeroReturned;
    bool bIsErrorOccurred;
}

- (bool) connect2server:(int) s;
//- (bool) connect2server:(int) u_port ip:(const char*)ip;
- (void) disconnect;
//- (bool) isConnected;
-(int) WriteData:(const UInt8*)buf size:(int)size;
-(int) ReadData:(const UInt8*)buf size:(int)size;
@end
