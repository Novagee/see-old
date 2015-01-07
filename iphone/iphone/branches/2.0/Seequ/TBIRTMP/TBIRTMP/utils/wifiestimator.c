//
//  wifiestimator.c
//  TBIRTMP
//
//  Created by Grigori Jlavyan on 5/22/13.
//  Copyright (c) 2013 Grigori Jlavyan. All rights reserved.
//


#include "wifiestimator.h"
#include "rtmpmanager.h"
#define INITIAL_COUNT 15
double allCE = 0., allAT = 0., allAB =0.;
int i_PktSize     = 900;                    // packet size in bytes
int i_PktNumbPP   = 16;                      // number of packet pair
int i_PktNumbPT   = 16;                      // length of packet train
int timer_resolution = 0;                    // local host select timer resolution
int gettimeofday_resolution = 0;             // local host gettimeofday resolution
int tcpSocket, udpSocket;                    // TCP/UDP socket
int i_rate = 0;                              // For debug, if given in commandline, it overwrite the PP estimated capacity to send PT


// Function prototype
void SendPP(void* manager,char *to,int i_PktNumb);                                     // Send PP over UDP
void SendPT(void* manager,char *to,int i_PktNumb, double f_Rate);                        // Send PT over UDP
void tbi_wifiestimator_probetimer();                                              // Perform timer tests
void CleanUpSender(int arg1);                                   // Clean up
void sort_int_arr (int *arr, int num_elems);                    // bubble sorting for int
void tbi_wifiestimator_perform_est_send(rtmp_manager_t* manager,char *to,enum Options option, int num, double Rate);   // Perform PP/PT test
double ProcessPT (rtmp_wifiestimator_t*esrimator,int i_PktNumb);
double ProcessPP (rtmp_wifiestimator_t*esrimator,int i_PktNumb);
void InitStorage(rtmp_wifiestimator_t*esrimator);

int tbi_wifiestimator_bw_estimator(void *manager,char*to)
{
    rtmp_manager_t *rtmpmanager = manager;
    rtmpmanager->wifiestimator.sender.ce=0.0;
    rtmpmanager->wifiestimator.sender.ab=0.0;
    rtmpmanager->wifiestimator.sender.totalTime=0;
    rtmpmanager->wifiestimator.sender.totalTime = 0;
    
    tbi_wifiestimator_probetimer();
    
    // Measure proformance.
    gettimeofday(&rtmpmanager->wifiestimator.sender.start, NULL);
    tbi_wifiestimator_perform_est_send(rtmpmanager,to,PacketPair, i_PktNumbPP, 0);
    return 0;
} // end main()

/////////////////////////////////////////////////////////////////
void tbi_wifiestimator_perform_est_send(rtmp_manager_t* manager,char *to, enum Options option, int i_num, double f_Rate)
{
    Ctl_Pkt_t control_pkt;
    control_pkt.value = i_num;
    control_pkt.option = option;
    control_pkt.type = EstimationTypeSender;
    manager->wifiestimator.sender.f_Rate = f_Rate;
    manager->wifiestimator.sender.i_num = i_num;
    memset(control_pkt.pack.padding, 0, sizeof(unsigned char));
    control_pkt.pack.seq=0;
    control_pkt.pack.tstamp = 0;
    
    
    if (rtmp_manager_send_BW(manager,to,(char*)(&control_pkt),sizeof(Ctl_Pkt_t)))
    {
        perror("Send TCP control packet error");
    }
}



void tbi_wifiestimator_reseiver(void* manager,char *from,struct Ctl_Pkt *control_rcv){
    rtmp_manager_t *rtmpManager = (rtmp_manager_t*)manager;
    static int counter= 0 ;
    printf("reseive package\n");
    if(!rtmpManager || !control_rcv ){
        printf("invalid package\n");
        return;
    }
    
    int i_PktNumb=30;
    i_PktNumb = control_rcv->value;
    if(control_rcv->type==EstimationPing){
        
        printf("ping %d %lld %d \n",control_rcv->pack.seq,control_rcv->pack.tstamp,counter);
        
        
        
        gettimeofday(&rtmpManager->wifiestimator.resiver.arrival[counter], NULL);
        rtmpManager->wifiestimator.resiver.seq[counter] = control_rcv->pack.seq;
        rtmpManager->wifiestimator.resiver.sendtime[counter] = control_rcv->pack.tstamp;
        rtmpManager->wifiestimator.resiver.psize[counter] = sizeof(Ctl_Pkt_t);
        counter++;
        
        if(control_rcv->pack.seq==INITIAL_COUNT-1){
            printf("ping end\n");
            counter = 0;
            Ctl_Pkt_t control_pkt;
            control_pkt.option = PacketTrain;
            control_pkt.type = EstimationTypeReseiver;
            memset(control_pkt.pack.padding, 0, sizeof(unsigned char));
            control_pkt.pack.seq=0;
            control_pkt.pack.tstamp = 0;
            allCE = ProcessPP(&rtmpManager->wifiestimator,INITIAL_COUNT);
            control_pkt.value = (unsigned int) (allCE * 1000000);
            rtmp_manager_send_BW(rtmpManager,from,(char *)&control_pkt,sizeof(Ctl_Pkt_t));
        }
        return;
    }
    
    
    if(control_rcv->type != EstimationTypeSender)
    {
        printf("invalid package\n");
        return;
    }
    
    
    
    switch (control_rcv->option){
        case PacketPair:{
            printf("PacketPair \n");
            counter = 0;
            struct Ctl_Pkt control_ready;
            control_ready.type = EstimationTypeReseiver;
            control_ready.option = Ready;
            control_ready.value = control_rcv->value;
            memset(control_ready.pack.padding, 0, sizeof(unsigned char));
            control_ready.pack.seq=0;
            control_ready.pack.tstamp = 0;
            InitStorage(&rtmpManager->wifiestimator);
            rtmp_manager_send_BW(rtmpManager,from,(char *)&control_ready,sizeof(Ctl_Pkt_t));
            //62865237
        }
            break;
            //        case PacketTrain:{
            //            struct Ctl_Pkt control_ready;
            //            control_ready.type = EstimationTypeReseiver;
            //            control_ready.option = Ready;
            //            control_ready.value = control_rcv->value;
            //            rtmp_manager_send_BW(rtmpManager,from,(char *)&control_ready,sizeof(Ctl_Pkt_t));
            //
            //            struct Ctl_Pkt control_pkt;
            //            control_pkt.option = PacketTrain;
            //            control_pkt.type = EstimationTypeReseiver;
            //            //allAB = ProcessPT(&rtmpManager->wifiestimator,i_PktNumb);
            //            control_pkt.value = (unsigned int)(allAB * 1000000);
            //            rtmp_manager_send_BW(rtmpManager,from,(char *)&control_pkt,sizeof(Ctl_Pkt_t));
            //        }
            break;
        default:
            break;
    }
}



void PerformEstRcv(void* manager,char*from,struct Ctl_Pkt *control_rcv){
    rtmp_manager_t *rtmpManager = (rtmp_manager_t*)manager;
    
    if(!manager || !control_rcv )
    {
        printf("estimator is not ready\n");
        return;
    }
    if(!(control_rcv->type==EstimationTypeReseiver)){
        return;
    }
    
    int nRet=0;
    double f_Rate = rtmpManager->wifiestimator.sender.f_Rate;
    struct Ctl_Pkt control_pkt = *control_rcv;
    nRet = sizeof(control_pkt);
    if (nRet==sizeof(control_pkt) && control_pkt.option == Ready)
    {
        
        SendPP(rtmpManager,from,rtmpManager->wifiestimator.sender.i_num); // perform PP estimation
        
    }else if(control_pkt.option == PacketTrain) {
        printf("Receive Ready message %d, with size %d\n", control_pkt.option, nRet);
        rtmpManager->wifiestimator.sender.ce = (double)control_pkt.value/1000000.;
        printf("Right message %d, with size %d ce = %f \n", control_pkt.option, nRet,rtmpManager->wifiestimator.sender.ce);
        // Measure performance
        gettimeofday(&rtmpManager->wifiestimator.sender.stop, NULL);
        rtmpManager->wifiestimator.sender.totalTime = (rtmpManager->wifiestimator.sender.stop.tv_sec - rtmpManager->wifiestimator.sender.start.tv_sec) * 1000000 +
        (rtmpManager->wifiestimator.sender.stop.tv_usec - rtmpManager->wifiestimator.sender.start.tv_usec);
        printf("Total estimation time: %d usec.\n", rtmpManager->wifiestimator.sender.totalTime);
        
    }else{
        printf("Receive unknow message %d, with size %d\n", control_pkt.option, nRet);
    }
}

/////////////////////////////////////////////////////////////////
void SendPP(void* manager,char *to,int i_PktNumb)
{
    struct timeval init_stamp, time_stamp;
    Ctl_Pkt_t pp_pkt;
    pp_pkt.type = EstimationPing;
    int nRet=0;
    int i;
    
    pp_pkt.pack.seq = 0;
    gettimeofday(&init_stamp, NULL);
    
    // start here: packetpair have the same seq bumber
    for (i=0; i < i_PktNumb; i++) {
        // Generate 1 packet in the pair
        gettimeofday(&time_stamp, NULL);
        pp_pkt.pack.tstamp = (time_stamp.tv_sec - init_stamp.tv_sec) * 1000000 +
        (time_stamp.tv_usec - init_stamp.tv_usec);
        
        rtmp_manager_send_BW(manager,to,(char*)&pp_pkt,sizeof(Ctl_Pkt_t));
        usleep (10000);
        nRet = i_PktSize;
        // Generate 2nd packet in the pair
        gettimeofday(&time_stamp, NULL);
        pp_pkt.pack.tstamp = (time_stamp.tv_sec - init_stamp.tv_sec) * 1000000 +
        (time_stamp.tv_usec - init_stamp.tv_usec);
        rtmp_manager_send_BW(manager,to,(char*)&pp_pkt,sizeof(Ctl_Pkt_t));
        usleep (10000);
        pp_pkt.pack.seq++;
        
//        if(i==(i_PktNumb-1)){
//            Ctl_Pkt_t pp_pkt_end;
//            pp_pkt.option=0;
//            pp_pkt.value=0;
//            pp_pkt.type = EstimationPingEnd;
//            rtmp_manager_send_BW(manager,to,(char*)&pp_pkt_end,sizeof(Ctl_Pkt_t));
//        }
    }
    printf("ping end is sended *********************** \n");
    
    usleep (10000);
    
} // end SendPP()

void sort_int_arr (int *arr, int num_elems)
{
    int i,j;
    int temp;
    
    for (i=1; i<num_elems; i++) {
        for (j=i-1; j>=0; j--)
            if (arr[j+1] < arr[j])
            {
                temp = arr[j];
                arr[j] = arr[j+1];
                arr[j+1] = temp;
            }
            else break;
    }
} // end sort_int_arr()

/////////////////////////////////////////////////////////////////
void SendPT(void* manager,char *to,int i_PktNumb, double f_Rate)
{
    // All time values are in usec
    double totalTime = 0.;      // time to send i_PktNumb packets in total
    double avgPacketTime = 0.;  // computed average time for sending one packet
    double sleepTime = 0.;         // Select timeout value
    double initTime = 0., doneTime = 0.;   // Start and end time
    struct timeval initTV, doneTV;    // Start and end time
    double tempTime1 = 0., tempTime2 = 0.; // Used to control sending rate
    struct PP_Pkt pt_pkt;
    double avgSendRate = 0.;
    int nRet = 0, i=0;
    
    if (i_rate != 0) f_Rate = (double) i_rate; // for debug, overwrite the estimated effective capacity
    
    // time from the start of first packet to the start of the last packet
    totalTime = (double) ((i_PktNumb - 1)  * i_PktSize *8)/ (f_Rate); //usec
    avgPacketTime = totalTime / (double)(i_PktNumb - 1); // usec
    
    
    printf("PacketTrain: sending %d PT with %f us per packet, at %f Mbps\n", i_PktNumb, avgPacketTime, f_Rate);
    
    if (avgPacketTime < gettimeofday_resolution || f_Rate < VERY_SMALL || i_PktNumb <= 0) // have problems
    {
        printf("Can not send %d PT with %f us per packet at %f Mbps. \n", i_PktNumb, avgPacketTime, f_Rate);
        return;
    }
    
    pt_pkt.seq = 0;
    pt_pkt.tstamp = 0;
    gettimeofday(&initTV, NULL);
    initTime = tempTime1 = (double) initTV.tv_sec * 1000000. + (double)initTV.tv_usec;
    
    for (i=0; i < i_PktNumb; i++)
    {
        rtmp_manager_send_BW(manager,to,(char*)&pt_pkt,i_PktSize);
        nRet = i_PktSize;
        gettimeofday(&doneTV, NULL);
        tempTime2 = (double) (doneTV.tv_sec * 1000000.) +  (double) doneTV.tv_usec;
        sleepTime = avgPacketTime - (tempTime2 - tempTime1);
        // Use the select timer first
        if (sleepTime > 1.5 * timer_resolution )
        {
            doneTV.tv_sec = (int)sleepTime / 1000000;
            doneTV.tv_usec = ((int)sleepTime % 1000000)/timer_resolution*timer_resolution; // explain it
            select(0,NULL,NULL,NULL,&doneTV);   // Sleep
            gettimeofday(&doneTV, NULL);          // get the return time
            tempTime2 = (double)doneTV.tv_sec * 1000000. +  (double)doneTV.tv_usec;
            sleepTime = avgPacketTime - (tempTime2 - tempTime1);
        }
        // Let the busy waiting time handle the small ammount of sleep time
        while (sleepTime > gettimeofday_resolution)
        {
            gettimeofday(&doneTV, NULL);
            tempTime2 = (double)doneTV.tv_sec * 1000000. +  (double)doneTV.tv_usec;
            sleepTime = avgPacketTime - (tempTime2 - tempTime1);
        }
        
        pt_pkt.seq++;
        pt_pkt.tstamp = (doneTV.tv_sec - initTV.tv_sec) * 1000000 +  doneTV.tv_usec - initTV.tv_usec;
        tempTime1 = tempTime2;
    }
    doneTime = tempTime2;
    avgSendRate = ((i_PktNumb) * i_PktSize * 8)/(doneTime - initTime);
    printf("Real sending rate: %f Mbps, time spend: %f us, average packet time %f us\n",
           avgSendRate, doneTime - initTime, (doneTime - initTime)/i_PktNumb);
    
} // end SendPT

void sort_double (double arr[], int num_elems)
{
    int i,j;
    double temp;
    
    for (i=1; i<num_elems; i++) {
        for (j=i-1; j>=0; j--)
            if (arr[j+1] < arr[j])
            {
                temp = arr[j];
                arr[j] = arr[j+1];
                arr[j+1] = temp;
            }
            else break;
    }
} // end sort_double()

/////////////////////////////////////////////////////////////////////////////
double ProcessPP(rtmp_wifiestimator_t*esrimator,int i_PktNumb)
{
    // Show that we've received some data
    int processed = 0, count=0, i=0;
    double sum = 0., mean = 0., median=0.;
    
    for (i=0; i<i_PktNumb*2-1; i++)
    {
        if (esrimator->resiver.seq[i] == esrimator->resiver.seq[i+1] && esrimator->resiver.seq[i] >= 0 ) //packet pair not lost
        {
            if ( processed > esrimator->resiver.seq[i]) continue; // duplicated packet
            while (processed < esrimator->resiver.seq[i])        // we skip any pairs?
            {
                esrimator->resiver.ceflag[processed] = 0;                                 // this pair is not valid
                printf("[%2d]: Packet pair lost\n", processed);
                processed ++;
            }
            
            esrimator->resiver.ceflag[processed] = 1;                                     // this pair is valid
            
            esrimator->resiver.disperse[count] = (esrimator->resiver.arrival[i+1].tv_sec - esrimator->resiver.arrival[i].tv_sec) * 1000000 +
            (esrimator->resiver.arrival[i+1].tv_usec - esrimator->resiver.arrival[i].tv_usec);
            
            esrimator->resiver.ce[count] = (esrimator->resiver.psize[i+1]*8.0/esrimator->resiver.disperse[count]);              // compute effective capacity
            esrimator->resiver.sr[count] = esrimator->resiver.psize[i+1]*8.0/(esrimator->resiver.sendtime[i+1]-esrimator->resiver.sendtime[i]);    // compute sending rate
            
            if (esrimator->resiver.ce[count] > 0.)
            {
                sum += esrimator->resiver.ce[count];
                printf("[%2d]: %d recv in %d usec - Ce: %7.2f Mbps, sendRate: %7.2f Mbps\n",
                       esrimator->resiver.seq[i+1], esrimator->resiver.psize[i+1], esrimator->resiver.disperse[count], esrimator->resiver.ce[count], esrimator->resiver.sr[count]);
                
                count ++ ; // increase valid packet pair by 1
            }
            
            processed ++;  // Move to next pair
            
            if (processed >= i_PktNumb) break;
        }
    }
    
    mean = sum/count;
    
    sort_double(esrimator->resiver.ce, count);
    median = (esrimator->resiver.ce[count/2]+esrimator->resiver.ce[count/2+1])/2;
    
    printf("Summary of Ce test with %d valid tests out %d pairs:\n\tmedian: %f Mbps\n",
           count, i_PktNumb, median);
    if (median >= 0)
    {
        return median;
    }
    else
    {
        return 0.0;
    }
} // end ProcessPP()

void sort_int (int arr[], int num_elems)
{
    int i,j;
    int temp;
    
    for (i=1; i<num_elems; i++) {
        for (j=i-1; j>=0; j--)
            if (arr[j+1] < arr[j])
            {
                temp = arr[j];
                arr[j] = arr[j+1];
                arr[j+1] = temp;
            }
            else break;
    }
} // end sort_int()

/////////////////////////////////////////////////////////////////////////////
double ProcessPT (rtmp_wifiestimator_t*esrimator,int i_PktNumb)
{
    int i=0, count=0, expected = 0, loss=0;
    double at[MAX_PKT_NUM], invalidrate, lossrate;
    int sum = 0;
    double medianAt=0., meanAt=0.;
    double medianAb=0., meanAb=0.;
    
    for (i=0; i<i_PktNumb; i++)
    {
        if (esrimator->resiver.seq[i] != expected) // Sequence number is not the one we expected (out of order=loss)
        {
            printf ("[%2d](%2d-%2d): Dispersion invalid due to packet #%d lost (match 1)! \n",
                    expected, expected, expected+1, expected); // the expected packet is lost
            loss++;
            if (esrimator->resiver.seq[i] > expected) // Bursty loss
            {
                expected++;
                while (esrimator->resiver.seq[i] > expected && expected < i_PktNumb)
                {
                    printf ("[%2d](%2d-%2d): Dispersion invalid due to packet #%d lost (match 2)! \n",
                            expected, expected, expected+1, expected); // more losses after the first loss
                    loss++;
                    expected++;
                }
            }
        }
        
        if (esrimator->resiver.seq[i+1] == esrimator->resiver.seq[i] + 1 && esrimator->resiver.seq[i] == expected) // Good pkts, count the total good ones
        {
            esrimator->resiver.disperse[count] = (esrimator->resiver.arrival[i+1].tv_sec - esrimator->resiver.arrival[i].tv_sec) * 1000000 +
            (esrimator->resiver.arrival[i+1].tv_usec - esrimator->resiver.arrival[i].tv_usec);
            
            
            at[count] = (esrimator->resiver.psize[i+1]*8.0/esrimator->resiver.disperse[count]);              // compute achievable throughput
            esrimator->resiver.sr[count] = esrimator->resiver.psize[i+1]*8.0/(esrimator->resiver.sendtime[i+1]-esrimator->resiver.sendtime[i]);    // compute sending rate
            // dispersion rate should less than sending rate
            if (at[count] > esrimator->resiver.sr[count]) esrimator->resiver.disperse[count] = esrimator->resiver.psize[i+1]*8.0/esrimator->resiver.sr[count];
            
            sum += esrimator->resiver.disperse[count];
            
            // Todo: maybe we need to filter out these sending error -- if (sr < ce) => discard?
            
            printf("[%2d](%2d-%2d): %d recv in %d usec - At: %7.2f Mbps, sendRate: %7.2f Mbps\n",
                   expected, expected, expected+1, esrimator->resiver.psize[i+1], esrimator->resiver.disperse[count], at[count], esrimator->resiver.sr[count]);
            count++;
        }
        else // expected packet is good, however, the next one lost
        {
            printf ("[%2d](%2d-%2d): Dispersion invalid due to packet #%d lost (next 1)! \n",
                    expected, expected, expected+1, expected+1); // the next one packet is lost
            if (expected == i_PktNumb -2) loss++; // Last packet in the train is lost...
        }
        expected ++;
        if (expected >= i_PktNumb -1) break;
    }
    
    // in general, one packet loss = two dispersion loss
    // Todo: we can estimate the bursty loss be compare lossrate and invalidrate.
    //
    lossrate = (double)loss/(double)i_PktNumb;                            // loss rate of pkt
    invalidrate = (double)(i_PktNumb - 1 - count)/(double)(i_PktNumb-1);  // loss rate of dispersion
    
    printf("Summary of At test with %d valid tests out %d train (%d tests):\n",
           count, i_PktNumb, i_PktNumb - 1);
    printf("\tpacket loss: %d (%f%%) \n\tinvalid result: %d (%f%%)\n",
           loss, lossrate * 100, i_PktNumb - 1 - count, invalidrate * 100);
    
    sort_int(esrimator->resiver.disperse, count);
    
    meanAt = (double)esrimator->resiver.psize[0] * 8.0 / ((double)sum / (double)count);
    medianAt = (double)esrimator->resiver.psize[0] * 8.0 / (((double)esrimator->resiver.disperse[count/2] + (double)esrimator->resiver.disperse[count/2+1]) / 2.0);
    printf("\tmean At: %f Mbps\n\tmedian At: %f Mbps\n", meanAt, medianAt);
    printf("\tmean At: %f Mbps\n", meanAt);
    
    // Equations... need to play around to compare the performance.
    // And to return At if the At is less than half Ce
    if (meanAt >= allCE )
    {
        meanAb = meanAt;
    }
    else
    {
        meanAb = allCE * (2.0 - allCE/meanAt);
    }
    
    
    if (medianAt >= allCE )
    {
        medianAb = medianAt;
    }
    else
    {
        medianAb = allCE * (2.0 - allCE/medianAt);
    }
    /*
     printf("\tmean Ab: %f Mbps\n\tmedian Ab: %f Mbps\n", meanAb, medianAb);
     printf("\tmean Ab with loss: %f Mbps\n\tmedian Ab with loss: %f Mbps\n", meanAb*(1.0-lossrate), medianAb*(1.0-lossrate));
     */
    
    printf("\tmean Ab: %f Mbps\n", meanAb);
    printf("\tmean Ab with loss: %f Mbps\n", meanAb*(1.0-lossrate));
    
    if (meanAb < 0)
    {
        return 0;
    }
    else
    {
        return meanAb*(1.0-lossrate);
    }
    
} // end ProcessPT()




/////////////////////////////////////////////////////////////////
void tbi_wifiestimator_probetimer() // Some ideas from pathload take the median as the timer resolution.
{
    int probe[NUM_TIMER_PROBING];
    int i;
    struct timeval sleep_time, time[NUM_TIMER_PROBING] ;
    
    // Probe the Select timer resolution
    gettimeofday(&time[0], NULL);
    for(i=1; i<NUM_TIMER_PROBING; i++) // Give a sleep time to see how fast we can get back
    {
        sleep_time.tv_sec = 0;
        sleep_time.tv_usec = 1;
        select(0,NULL,NULL,NULL,&sleep_time);  // Sleep for 1 usec
        gettimeofday(&time[i], NULL);          // get the return time
    }
    
    for(i=1; i<NUM_TIMER_PROBING; i++)
    {
        probe[i-1] = (time[i].tv_sec - time[i-1].tv_sec) * 1000000 +
        (time[i].tv_usec - time[i-1].tv_usec);
    }
    
    sort_int_arr(probe, NUM_TIMER_PROBING - 1);  // sort the timer probing
    
    timer_resolution = (probe[NUM_TIMER_PROBING/2]+probe[NUM_TIMER_PROBING/2+1])/2;
    
    printf("The timer resolution is %d usecs.\n", timer_resolution);
    
    // Probe the gettimeofday_resolution.
    gettimeofday(&time[0], NULL);
    for(i=1; i<NUM_TIMER_PROBING; i++) // Give a sleep time to see how fast we can get back
    {
        gettimeofday(&time[i], NULL);          // get the return time
        probe[i-1] = (time[i].tv_sec - time[i-1].tv_sec) * 1000000 +
        (time[i].tv_usec - time[i-1].tv_usec);
    }
    
    sort_int_arr(probe, NUM_TIMER_PROBING - 1);  // sort the timer probing
    gettimeofday_resolution = (probe[NUM_TIMER_PROBING/2]+probe[NUM_TIMER_PROBING/2+1])/2;
    //  gettimeofday_resolution = gettimeofday_resolution < 2 ? 2 : gettimeofday_resolution; // 1 make no sense
    
    printf("The gettimeofday resolution is %d usecs.\n", gettimeofday_resolution);
    
} // end tbi_wifiestimator_probetimer()

void InitStorage(rtmp_wifiestimator_t*esrimator)
{
    struct timeval notime;
    int i = 0;
    notime.tv_sec = 0;
    notime.tv_usec = 0;
    
    for (i=0; i<MAX_PKT_NUM; i++)
    {
        esrimator->resiver.seq[i] = -1;
        esrimator->resiver.sendtime[i] = -1;
        esrimator->resiver.psize[i]= -1;
        esrimator->resiver.arrival[i] = notime;
        esrimator->resiver.disperse[i] = -1;
        esrimator->resiver.ce[i] = -1;
        esrimator->resiver.ceflag[i] = -1;
    }
} // end InitStorage()
