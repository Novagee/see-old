#ifndef __RTMP_H__
#define __RTMP_H__
/*
 *      Copyright (C) 2005-2008 Team XBMC
 *      http://www.xbmc.org
 *      Copyright (C) 2008-2009 Andrej Stepanchuk
 *      Copyright (C) 2009-2010 Howard Chu
 *
 *  This file is part of librtmp.
 *
 *  librtmp is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as
 *  published by the Free Software Foundation; either version 2.1,
 *  or (at your option) any later version.
 *
 *  librtmp is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with librtmp see the file COPYING.  If not, write to
 *  the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA  02110-1301, USA.
 *  http://www.gnu.org/copyleft/lgpl.html
 */

#if !defined(NO_CRYPTO) && !defined(CRYPTO)
//#define CRYPTO
#endif

#include <errno.h>
#include <stdint.h>
#include <stddef.h>
#include "amf.h"
#include "../socketwrapper/socketwrapper.h"
#include "rtmpevent.h"

#ifdef __cplusplus
extern "C"
{
#endif
    
#define RTMP_LIB_VERSION	0x020300	/* 2.3 */
    
#define RTMP_FEATURE_HTTP	0x01
#define RTMP_FEATURE_ENC	0x02
#define RTMP_FEATURE_SSL	0x04
#define RTMP_FEATURE_MFP	0x08	/* not yet supported */
#define RTMP_FEATURE_WRITE	0x10	/* publish, not play */
#define RTMP_FEATURE_HTTP2	0x20	/* server-side rtmpt */
    
#define RTMP_PROTOCOL_UNDEFINED	-1
#define RTMP_PROTOCOL_RTMP      0
#define RTMP_PROTOCOL_RTMPE     RTMP_FEATURE_ENC
#define RTMP_PROTOCOL_RTMPT     RTMP_FEATURE_HTTP
#define RTMP_PROTOCOL_RTMPS     RTMP_FEATURE_SSL
#define RTMP_PROTOCOL_RTMPTE    (RTMP_FEATURE_HTTP|RTMP_FEATURE_ENC)
#define RTMP_PROTOCOL_RTMPTS    (RTMP_FEATURE_HTTP|RTMP_FEATURE_SSL)
#define RTMP_PROTOCOL_RTMFP     RTMP_FEATURE_MFP
    
#define RTMP_DEFAULT_CHUNKSIZE	128
    
    /* needs to fit largest number of bytes recv() may return */
#define RTMP_BUFFER_CACHE_SIZE (16*1024)
    
#define	RTMP_CHANNELS	65600
    
    extern const char RTMPProtocolStringsLower[][7];
    extern const AVal RTMP_DefaultFlashVer;
    
    uint32_t RTMP_GetTime(void);
    
#define RTMP_PACKET_TYPE_AUDIO 0x08
#define RTMP_PACKET_TYPE_VIDEO 0x09
#define RTMP_PACKET_TYPE_INFO  0x12
    
#define RTMP_MAX_HEADER_SIZE 18
    
#define RTMP_PACKET_SIZE_LARGE    0
#define RTMP_PACKET_SIZE_MEDIUM   1
#define RTMP_PACKET_SIZE_SMALL    2
#define RTMP_PACKET_SIZE_MINIMUM  3
    
    
    typedef enum {
        param_type_number
        , param_type_boolean
        , param_type_string
    }param_type;
    
    typedef struct RTMPChunk
    {
        int c_headerSize;
        int c_chunkSize;
        char *c_chunk;
        char c_header[RTMP_MAX_HEADER_SIZE];
    } RTMPChunk;
    
    typedef struct RTMPPacket
    {
        TBI_DECLARE_OBJECT;
        
        uint8_t m_headerType;
        uint8_t m_packetType;
        uint8_t m_hasAbsTimestamp;	/* timestamp absolute or relative? */
        int m_nChannel;
        uint32_t m_nTimeStamp;	/* timestamp */
        int32_t m_nInfoField2;	/* last 4 bytes in a long header */
        uint32_t m_nBodySize;
        uint32_t m_nBytesRead;
        RTMPChunk *m_chunk;
        char *m_body;
        
        uint32_t partCount;
        uint64_t createTime;
        uint64_t completeTime;
        
    } RTMPPacket;

    extern const TBI_object_def_t* RTMPPacket_def_t;
    
    typedef struct RTMPSockBuf
    {
        int sb_socket;
        int sb_size;		/* number of unprocessed bytes in buffer */
        char *sb_start;		/* pointer into sb_pBuffer of next byte to process */
        char sb_buf[RTMP_BUFFER_CACHE_SIZE];	/* data read from socket */
        int sb_timedout;
        void *sb_ssl;
    } RTMPSockBuf;
    
    void RTMPPacket_Reset(RTMPPacket *p);
    void RTMPPacket_Dump(RTMPPacket *p);
    int RTMPPacket_Alloc(RTMPPacket *p, int nSize);
    void RTMPPacket_Free(RTMPPacket *p, const char* info);
    

    
#define RTMPPacket_IsReady(a)	((a)->m_nBytesRead == (a)->m_nBodySize)
    
    typedef struct RTMP_LNK
    {
        AVal hostname;
        AVal sockshost;
        
        AVal playpath0;	/* parsed from URL */
        AVal playpath;	/* passed in explicitly */
        AVal publishpath;	/* passed in explicitly */
        AVal tcUrl;
        AVal swfUrl;
        AVal pageUrl;
        AVal app;
        AVal auth;
        AVal flashVer;
        AVal subscribepath;
        AVal token;
        AMFObject extras;
        int edepth;
        
        int seekTime;
        int stopTime;
        
#define RTMP_LF_AUTH	0x0001	/* using auth param */
#define RTMP_LF_LIVE	0x0002	/* stream is live */
#define RTMP_LF_SWFV	0x0004	/* do SWF verification */
#define RTMP_LF_PLST	0x0008	/* send playlist before play */
#define RTMP_LF_BUFX	0x0010	/* toggle stream on BufferEmpty msg */
#define RTMP_LF_FTCU	0x0020	/* free tcUrl on close */
        int lFlags;
        
        int swfAge;
        
        int protocol;
        int timeout;		/* connection timeout in seconds */
        
        unsigned short socksport;
        unsigned short port;
        
#ifdef CRYPTO
#define RTMP_SWF_HASHLEN	32
        void *dh;			/* for encryption */
        void *rc4keyIn;
        void *rc4keyOut;
        
        uint32_t SWFSize;
        uint8_t SWFHash[RTMP_SWF_HASHLEN];
        char SWFVerificationResponse[RTMP_SWF_HASHLEN+10];
#endif
    } RTMP_LNK;
    
    /* state for read() wrapper */
    typedef struct RTMP_READ
    {
        char *buf;
        char *bufpos;
        unsigned int buflen;
        uint32_t timestamp;
        uint8_t dataType;
        uint8_t flags;
#define RTMP_READ_HEADER	0x01
#define RTMP_READ_RESUME	0x02
#define RTMP_READ_NO_IGNORE	0x04
#define RTMP_READ_GOTKF		0x08
#define RTMP_READ_GOTFLVK	0x10
#define RTMP_READ_SEEKING	0x20
        int8_t status;
#define RTMP_READ_COMPLETE	-3
#define RTMP_READ_ERROR	-2
#define RTMP_READ_EOF	-1
#define RTMP_READ_IGNORE	0
        
        /* if bResume == TRUE */
        uint8_t initialFrameType;
        uint32_t nResumeTS;
        char *metaHeader;
        char *initialFrame;
        uint32_t nMetaHeaderSize;
        uint32_t nInitialFrameSize;
        uint32_t nIgnoredFrameCounter;
        uint32_t nIgnoredFlvFrameCounter;
    } RTMP_READ;
    
    typedef struct RTMP_METHOD
    {
        AVal name;
        int num;
    } RTMP_METHOD;
    
    typedef RTMP_METHOD RTMP_RESULT_PARAM;
    typedef void (*receiveCallback)(void* self, rtmp_event_t* event);
    typedef struct RTMP
    {
        int m_inChunkSize;
        int m_outChunkSize;
        int m_nBWCheckCounter;
        int m_nBytesIn;
        int m_nBytesInSent;
        int m_nBufferMS;
        int m_playstream_id;		/* returned in _result from createStream */
        int m_publishstream_id;		/* returned in _result from createStream */
        int m_mediaChannel;
        uint32_t m_mediaStamp;
        uint32_t m_pauseStamp;
        int m_pausing;
        int m_nServerBW;
        int m_nClientBW;
        uint8_t m_nClientBW2;
        uint8_t m_bPlaying;
        uint8_t m_bPublishing;
        uint8_t m_bSendEncoding;
        uint8_t m_bSendCounter;
        
        int m_numInvokes;
        int m_numCalls;
        RTMP_METHOD *m_methodCalls;	/* remote method calls queue */

        int m_numResults;
        RTMP_RESULT_PARAM *m_resultParam;
        
        RTMPPacket *m_vecChannelsIn[RTMP_CHANNELS];
        RTMPPacket *m_vecChannelsOut[RTMP_CHANNELS];
        int m_channelTimestamp[RTMP_CHANNELS];	/* abs timestamp of last packet */
        
        double m_fAudioCodecs;	/* audioCodecs for the connect packet */
        double m_fVideoCodecs;	/* videoCodecs for the connect packet */
        double m_fEncoding;		/* AMF0 or AMF3 */
        
        double m_fDuration;		/* duration of stream in seconds */
        
        int m_msgCounter;		/* RTMPT stuff */
        int m_polling;
        int m_resplen;
        int m_unackd;
        AVal m_clientID;
        
        RTMP_READ m_read;
        RTMPPacket* m_Awrite;
//        RTMPPacket m_Vwrite;
//        RTMPSockBuf m_sb;
        Socket_t m_sb;
        RTMP_LNK Link;
        
        receiveCallback onStatusCallback;
        receiveCallback onAudioSettingsCallback;
        
        void* callbackData;
        
        uint8_t buf[4096];
        int rSize;
        int readBuffer;
        
        int serverUpTime;
        int recvTime;
        
        int RTMP_ctrlC;
        
        int nDataSize;
        
        char type[16];
        int bIsSecure;

    } RTMP;
    
    int RTMP_ParseURL(const char *url, int *protocol, AVal *host,
                      unsigned int *port, AVal *playpath, AVal *app);
    
    void RTMP_ParsePlaypath(AVal *in, AVal *out);
    void RTMP_SetBufferMS(RTMP *r, int size);
    void RTMP_UpdateBufferMS(RTMP *r);
    
    int RTMP_SetOpt(RTMP *r, const AVal *opt, AVal *arg);
    int RTMP_SetupURL(RTMP *r, char *url);
    void RTMP_SetupStream(RTMP *r, int protocol,
                          AVal *hostname,
                          unsigned int port,
                          AVal *sockshost,
                          AVal *playpath,
                          AVal *tcUrl,
                          AVal *swfUrl,
                          AVal *pageUrl,
                          AVal *app,
                          AVal *auth,
                          AVal *swfSHA256Hash,
                          uint32_t swfSize,
                          AVal *flashVer,
                          AVal *subscribepath,
                          int dStart,
                          int dStop, int bLiveStream, long int timeout);
    
    int RTMP_Connect(RTMP *r, RTMPPacket *cp);
    struct sockaddr;
    int RTMP_Connect0(RTMP *r, struct sockaddr *svc);
    int RTMP_Connect1(RTMP *r, RTMPPacket *cp);
    int RTMP_Serve(RTMP *r);
    
    int RTMP_ReadPacket(RTMP *r, RTMPPacket *packet);
    int RTMP_SendPacket(RTMP *r, RTMPPacket *packet, int queue);
    int RTMP_SendChunk(RTMP *r, RTMPChunk *chunk);
    int RTMP_IsConnected(RTMP *r);
    int RTMP_Socket(RTMP *r);
    int RTMP_IsTimedout(RTMP *r);
    double RTMP_GetDuration(RTMP *r);
    int RTMP_ToggleStream(RTMP *r);
    
    int RTMP_ConnectStream(RTMP *r, int seekTime);
    int RTMP_ReconnectStream(RTMP *r, int seekTime);
    void RTMP_DeleteStreams(RTMP *r);
    int RTMP_GetNextMediaPacket(RTMP *r, RTMPPacket *packet);
    int RTMP_ClientPacket(RTMP *r, RTMPPacket *packet);
    
    void RTMP_Init(RTMP *r, int isVoIP, int isSecure, char* type);
    void RTMP_Close(RTMP *r);
    void RTMP_Reset(RTMP *r);
    RTMP *RTMP_Alloc(void);
    void RTMP_Free(RTMP *r);
    void RTMP_EnableWrite(RTMP *r);
    
    int RTMP_LibVersion(void);
    void RTMP_UserInterrupt(RTMP* r);	/* user typed Ctrl-C */
    
    int RTMP_SendCtrl(RTMP *r, short nType, unsigned int nObject,
                      unsigned int nTime);
    
    /* caller probably doesn't know current timestamp, should
     * just use RTMP_Pause instead
     */
    
    int TBI_RTMP_SendTrying(RTMP *r, AVal* uid,AVal* callid);
    int RTMP_SendPause(RTMP *r, int DoPause, int dTime);
    int RTMP_Pause(RTMP *r, int DoPause);
    
    int RTMP_FindFirstMatchingProperty(AMFObject *obj, const AVal *name, AMFObjectProperty * p);
    
    int RTMPSockBuf_Fill(RTMP* r, /*RTMPSockBuf*/Socket_t *sb);
    int RTMPSockBuf_Send(/*RTMPSockBuf*/Socket_t *sb, const char *buf, int len);
    int RTMPSockBuf_Close(/*RTMPSockBuf*/Socket_t *sb);
    
    int RTMP_SendCreateStream(RTMP *r);
    int RTMP_SendSeek(RTMP *r, int dTime);
    int RTMP_SendServerBW(RTMP *r);
    int RTMP_SendClientBW(RTMP *r);
    void RTMP_DropRequest(RTMP *r, int i, int freeit);
    int RTMP_Read(RTMP *r, char *buf, int size);
    int RTMP_Write(RTMP *r, const char *buf, int size);
    
    /* hashswf.c */
    int RTMP_HashSWF(const char *url, unsigned int *size, unsigned char *hash,
                     int age);
    
    // signaling functions =============================================================
    int TBI_RTMP_SendRegister(RTMP *r, AVal* uid, AVal* sipServer, AVal* username, AVal* password, AVal* clientType, AVal *codecs, AVal *videoCodecs_list,int videoType);
    int TBI_RTMP_SendUnRegister(RTMP *r, AVal* uid);
    int TBI_RTMP_SendMakeCall(RTMP *r, int type, AVal* uid,AVal *callid,AVal* name, AVal* dialNumber, AVal* callType,AVal *codecs, int frameSize,AVal *videoCodecs_list, int videoType,int internet_type);
    int TBI_RTMP_SndBW(RTMP *r, AVal* uid,AVal* to,AVal* data);
    int TBI_RTMP_SendMakeUnHold(RTMP *r, AVal* uid, AVal *callid);
    int TBI_RTMP_SendMakeHold(RTMP *r, AVal* uid,AVal *callid);
  
    int TBI_RTMP_SendHangup(RTMP *r, AVal* uid,AVal* callid);
    int TBI_RTMP_SendAccept(RTMP *r, AVal* uid,AVal *callid, AVal* codecs, int frameSize, AVal *videoCodecs_list,int videotype,int internet_type);
    int TBI_RTMP_SendDecline(RTMP *r, AVal* uid,AVal* callid);
    int TBI_RTMP_SendHold(RTMP *r, AVal* uid);
    int TBI_RTMP_SendUnHold(RTMP *r, AVal* uid);
    int TBI_RTMP_SendDTMF(RTMP *r, AVal* uid,AVal *callId, AVal* dtmf);
    int TBI_RTMP_SendReConnect(RTMP *r, AVal* uid, AVal* dstNumber, AVal* data);
    int TBI_RTMP_SendIncrease(RTMP *r, AVal* uid, AVal* dstNumber, double bitrate,double increaseSize);
    int TBI_RTMP_SendDecrease(RTMP *r, AVal* uid, AVal* dstNumber, double bitrate,double decreaseSize);
    int TBI_RTMP_SendChangeState(RTMP *r, AVal* uid, int state);

    // chat functions
    int TBI_RTMP_SendChatTextMessage(RTMP *r, AVal* uid, const char* data, int size);
    int TBI_RTMP_SendTextDelivaryNotify(RTMP *r, AVal* uid, const char* data, int size);
    int TBI_RTMP_SendInstMsg(RTMP *r, AVal* uid, int type, const char* data, int size, int queue);

#if RTMP_WITHOUT_HANDSHAKE
    int TBI_RTMP_ConnectWoHandshak(RTMP *r, AVal* uid, AVal* sipServer, AVal* username, AVal* password, AVal* clientType, AVal *codecs, AVal *videocodec, int videoType, RTMPPacket* cp);
    int TBI_RTMP_ConnectWoHandshakNoReg(RTMP *r, RTMPPacket* cp);
#endif //RTMP_WITHOUT_HANDSHAKE
    
    int TBI_ChangeChunkSize(RTMP *r, int chunkSize);
    void TBI_RTMP_SetCallback(RTMP* r, receiveCallback callbackFunction, void* callbackData);
    int TBI_RTMP_SendChecknet(RTMP *r, AVal* uid);
    
#ifdef __cplusplus
};
#endif

#endif
