//
//  utlis.h
//  TBIRTMP
//
//  Created by Grigori Jlavyan on 11/2/12.
//  Copyright (c) 2012 Grigori Jlavyan. All rights reserved.
//

#ifndef TBIRTMP_utlis_h
#define TBIRTMP_utlis_h

#include <stdint.h>

#define VIDEO_FPS 12

enum iPhoneModels{
    iPhoneModel_unknown,
    iPod4,
    iPhone4v5,
    iPhone4v6,
    iPad2,
    iPhone4Sv5,
    iPhone4Sv6,
    iPad3,
    iPod5,
    iPhone5v6,
};

char* createUnicId();
void stringItoa(uint64_t i, char *result);
void randomString(char *result);
void generaterandomkey(unsigned char* key, int size);
#endif
