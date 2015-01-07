//
//  media_session.h
//  TBIRTMP
//
//  Created by Administrator on 10/31/12.
//  Copyright (c) 2012 Grigori Jlavyan. All rights reserved.
//

#ifndef TBIRTMP_media_session_h
#define TBIRTMP_media_session_h

#include "types.h"

typedef struct media_session_s {
    
    uint64_t sessionId;
    char* codecFormat;
    
} media_session_t;

#define MEDIA_DECLARE_SESSION media_session_t

#endif
