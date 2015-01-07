//
//  wifiestimator.h
//  TBIRTMP
//
//  Created by Grigori Jlavyan on 5/22/13.
//  Copyright (c) 2013 Grigori Jlavyan. All rights reserved.
//

#ifndef TBIRTMP_wifiestimator_h
#define TBIRTMP_wifiestimator_h

#define MAX_PKT_SIZE 640      // Max pp packet size
#define MAX_PKT_NUM 200        // Max number PP in a bursty
#define VERY_SMALL 1e-20       // Very small
#define NUM_TIMER_PROBING  31  // Number of timer probing, used in ProbeTimer()

#ifndef INADDR_NONE
#define INADDR_NONE 0xffffffff /* should be in <netinet/in.h> */
#endif
#include <sys/time.h>



typedef struct rtmp_wifiestimator_s {
    struct{
        double ce;
        double ab;
        struct timeval start;
        struct timeval stop;
        int totalTime;
        double f_Rate;
        int i_num;
    } sender;
    struct{
        double allCE ;
        double allAT ;
        double allAB ;
        struct timeval arrival[MAX_PKT_NUM];       // arrrival time
        int sendtime[MAX_PKT_NUM];                 // sending time
        int seq[MAX_PKT_NUM];                      // sequence number
        int psize[MAX_PKT_NUM];                    // packet size (bytes)
        int disperse[MAX_PKT_NUM];                 // dispersion(usec)
        double ce[MAX_PKT_NUM];                    // Effective capacity (Mbps)
        double sr[MAX_PKT_NUM];                    // Sending rate (Mbps)
        int ceflag[MAX_PKT_NUM];                   // valid packet pair
    } resiver;
} rtmp_wifiestimator_t;




enum Options {                  // Options used in control packet
      PacketPair = 0x0001
    , PacketTrain = 0x0002
    , Ready = 0x0004
    , Failed = 0x0008
};

enum EstimationType {                  // Options used in control packet
    EstimationTypeReseiver = 0x0001,
    EstimationTypeSender = 0x0002,
    EstimationPing = 0x0003,
    EstimationPingEnd = 0x0004,
};
typedef struct PP_Pkt{                 // PP/PT packet (over UDP)
    int seq;
    long long tstamp;
    unsigned char padding[MAX_PKT_SIZE];
} PP_Pkt_t;

typedef struct Ctl_Pkt{                // Control packet (over TCP)
    enum Options option;
    enum EstimationType type;
    unsigned int value;
    PP_Pkt_t pack;
}Ctl_Pkt_t;



int tbi_wifiestimator_bw_estimator(void* manager,char*to);
void PerformEstRcv(void* manager,char*from,struct Ctl_Pkt *control_rcv);
void tbi_wifiestimator_reseiver(void* manager,char *from,struct Ctl_Pkt *control_rcv);


#endif
