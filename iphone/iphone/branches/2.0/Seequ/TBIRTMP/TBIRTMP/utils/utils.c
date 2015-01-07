//
//  utils.c
//  TBIRTMP
//
//  Created by Grigori Jlavyan on 11/2/12.
//  Copyright (c) 2012 Grigori Jlavyan. All rights reserved.
//

#include "utlis.h"

#include <time.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <sys/sysctl.h>

char System_Versio[256];

char* createUnicId(){

    static long int __counter = 0 ;
    __counter++;
	time_t now_time = time(&now_time);
    srand ( time(&now_time));
	int rand_val = rand();
	char tmp[256];
	sprintf(tmp, "%ld-%d-%ld", now_time%10000000, rand_val%1000000,__counter%100);
    return strdup(tmp);
}

void stringItoa(uint64_t i, char *result)
{
	memset(result, 0, sizeof(*result));
    sprintf(result,"%lld",i);
}

void randomString(char *result)
{
	static uint64_t __counter = 1;
    time_t now_time = time(&now_time);
    uint64_t value = (now_time ^ (rand())) ^ ++__counter;
	stringItoa(value, result);
}

enum iPhoneModels get_phone_version()
{
    int version = iPhoneModel_unknown;
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    
    void *answer = malloc(size);
    sysctlbyname("hw.machine", answer, &size, NULL, 0);
    
    int d_v;
    int d_sv;
    int d_ssv;
    
    sscanf(System_Versio, "%d.%d.%d", &d_v, &d_sv, &d_ssv);
    
    if (d_v > 5)
    {
        if(strcmp(answer, "iPod4,1")==0)
            version = iPod4;
        if(strcmp(answer, "iPhone3,1")==0)
            version = iPhone4v6;
        if(strcmp(answer, "iPad2")==0)
            version = iPad2;
        else if(strcmp(answer, "iPhone4,1")==0)
            version = iPhone4Sv6;
        else if(strcmp(answer, "iPad3")==0)
            version = iPad3;
        else if(strcmp(answer, "iPhone5,1")==0)
            version = iPhone5v6;
        else if(strcmp(answer, "iPod5,1")==0)
            version = iPod5;
    }
    else
    {
        if(strcmp(answer, "iPod4,1")==0)
            version = iPod4;
        if(strcmp(answer, "iPhone3,1")==0)
            version = iPhone4v5;
        if(strcmp(answer, "iPad2")==0)
            version = iPad2;
        else if(strcmp(answer, "iPhone4,1")==0)
            version = iPhone4Sv5;
        else if(strcmp(answer, "iPad3")==0)
            version = iPad3;
        else if(strcmp(answer, "iPhone5,1")==0)
            version = iPhone5v6;
        else if(strcmp(answer, "iPod5,1")==0)
            version = iPod5;
    }
    free(answer);
    return version;
}

void generaterandomkey(unsigned char* key, int size)
{
    char c;
    int count = 'z' - '0' + 1;
    srand (time(NULL));
    for (int i = 0; i < size; i++)
    {
        c = (char)('0' + rand() % count);
        if((c > '9' && c < 'A') || (c > 'Z' && c < 'a'))
            key[i] = 'Z';
        else
            key[i] = c;
    }
}


