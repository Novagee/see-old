//
//  tsk_mpeg4.c
//  ios-ngn-stack
//
//  Created by Administrator on 10/6/12.
//  Copyright (c) 2012 Doubango Telecom. All rights reserved.
//

#include "tsk_mpeg4.h"
#include "tsk_debug.h"


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/sysctl.h>

#ifdef WIN32
#include <winsock2.h>
#endif //WIN32

#define BOX_SIZE		8
#define BUFFER_MAX_SIZE	1024

int isBaseLine = 0;

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus
    
    // 352x288
    const uint8_t spsBl352[14] = { 0x67, 0x42, 0x00, 0x1E, 0x8D, 0x68, 0x16, 0x09, 0x69, 0xA8, 0x30, 0x08, 0x30, 0x10 };
    const uint8_t ppsBl352[4]  = { 0x68, 0xCE, 0x09, 0xC8 };
    
    // 320x240
    const uint8_t spsBl320[14] = { 0x67, 0x42, 0x00, 0x1E, 0x8D, 0x68, 0x14, 0x1F, 0xA6, 0xA0, 0x20, 0x20, 0x20, 0x40 };
    const uint8_t ppsBl320[4]  = { 0x68, 0xCE, 0x09, 0xC8 };
    
    // 640x480
    const uint8_t spsBl640[14] = { 0x67, 0x42, 0x00, 0x1E, 0x8D, 0x68, 0x0A, 0x03, 0xDA, 0x6A, 0x02, 0x02, 0x02, 0x04 };
    const uint8_t ppsBl640[4]  = { 0x68, 0xCE, 0x09, 0xC8 };
    
    //
    //  iPad 2
    //
    
    // 352x288
    const uint8_t spsM352[14] = { 0x67, 0x4D, 0x00, 0x1E, 0xAB, 0x40, 0xB0, 0x4B, 0x4D, 0x40, 0x40, 0x41, 0x80, 0x80 };
    const uint8_t ppsM352[4]  = { 0x28, 0xCE, 0x3C, 0x80 };
    
    // 320x240
    const uint8_t spsM320[13] = { 0x67, 0x4D, 0x00, 0x0D, 0xAB, 0x40, 0xA0, 0xFD, 0x35, 0x01, 0x06, 0x06, 0x02};
    const uint8_t ppsM320[4]  = { 0x28, 0xCE, 0x3C, 0x80 };
    
    // 640x480
    const uint8_t spsM640[14] = { 0x67, 0x4D, 0x00, 0x1E, 0xAB, 0x40, 0x50, 0x1E, 0xD3, 0x50, 0x10, 0x10, 0x60, 0x20 };
    const uint8_t ppsM640[4]  = { 0x28, 0xCE, 0x3C, 0x80 };
    
    //
    //  iPad 3
    //
    
    // 352x288
    const uint8_t spsM352_iPad3[14] = { 0x67, 0x4D, 0x00, 0x0D, 0xAB, 0x40, 0xB0, 0x4B, 0x4D, 0x40, 0x40, 0x41, 0x80, 0x80 };
    const uint8_t ppsM352_iPad3[4]  = { 0x28, 0xEE, 0x3C, 0x30 };
    
    //
    //  iPhone 4S
    //
    
    // 352x288
    const uint8_t spsM352_iPhone_4S[14] = {0x67, 0x4D, 0x00, 0x0D, 0xAB, 0x40, 0xB0, 0x4B, 0x4D, 0x40, 0x40, 0x41, 0x80, 0x80};
    const uint8_t ppsM352_iPhone_4S[4]  = {0x28, 0xEE, 0x3C, 0x30};
    
    
    const uint8_t spsM352_iPhone_5[14] = {0x67, 0x4D, 0x00, 0x0D, 0xAB, 0x40, 0xB0, 0x4B, 0x4D, 0x40, 0x40, 0x41, 0x80, 0x80};
    const uint8_t ppsM352_iPhone_5[4]  = {0x28, 0xEE, 0x09, 0xC3};
    
    
    int get_phone_version()
    {
        int version = 0;
        size_t size;
        sysctlbyname("hw.machine", NULL, &size, NULL, 0);
        
        void *answer = malloc(size);
        sysctlbyname("hw.machine", answer, &size, NULL, 0);
        
        int m_v, d_v;
        int m_sv, d_sv;
        int m_ssv, d_ssv;
        
        sscanf(System_Versio, "%d.%d.%d", &d_v, &d_sv, &d_ssv);
        
        if (d_v > 5 && strcmp(answer, "iPhone4,1")==0) {
            version = 3;
        } else {
            if(strncasecmp(answer, "iPhone5,1", strlen("iPhone5,1"))==0){
                version = 4;
            }else if (strncasecmp(answer, "iPad3", strlen("iPad3"))==0) {
                version = 2;
            } else {
                if (strncasecmp(answer, "iPhone4", strlen("iPhone4"))==0 || strncasecmp(answer, "iPad2", strlen("iPad2"))==0) {
                    version = 0;
                } else {
                    version = 1;
                }
            }
        }
        
        free(answer);
        
        return version;
    }
    
    tsk_bool_t get_sps_pps_nal_unit(int version, int frm_width, const uint8_t** sps, int* spslen, const uint8_t** pps, int* ppslen )
    {
        if(isBaseLine == 1)
        {
            switch (frm_width) {
                case 352:
                    *sps = spsBl352;
                    *spslen = sizeof(spsBl352);
                    *pps = ppsBl352;
                    *ppslen = sizeof(ppsBl352);
                    break;
                case 320:
                    *sps = spsBl320;
                    *spslen = sizeof(spsBl320);
                    *pps = ppsBl320;
                    *ppslen = sizeof(ppsBl320);
                    break;
                case 640:
                    *sps = spsBl640;
                    *spslen = sizeof(spsBl640);
                    *pps = ppsBl640;
                    *ppslen = sizeof(ppsBl640);
                    break;
                default:
                    *sps = spsBl320;
                    *spslen = sizeof(spsBl320);
                    *pps = ppsBl320;
                    *ppslen = sizeof(ppsBl320);
                    break;
            }
        }
        else
        {
            if(isBaseLine == 0) {
                switch (frm_width) {
                    case 352:
                        *sps = spsM352;
                        *spslen = sizeof(spsM352);
                        *pps = ppsM352;
                        *ppslen = sizeof(ppsM352);
                        break;
                    case 320:
                        *sps = spsM320;
                        *spslen = sizeof(spsM320);
                        *pps = ppsM352;
                        *ppslen = sizeof(ppsM320);
                        break;
                    case 640:
                        *sps = spsM640;
                        *spslen = sizeof(spsM640);
                        *pps = ppsM640;
                        *ppslen = sizeof(ppsM640);
                        break;
                    default:
                        *sps = spsM320;
                        *spslen = sizeof(spsM320);
                        *pps = ppsM352;
                        *ppslen = sizeof(ppsM320);
                        break;
                }
            } else {
                if(isBaseLine == 2) {
                    switch (frm_width) {
                        case 352:
                            *sps = spsM352_iPad3;
                            *spslen = sizeof(spsM352_iPad3);
                            *pps = ppsM352_iPad3;
                            *ppslen = sizeof(ppsM352_iPad3);
                            break;
                        case 320:
                            *sps = spsM320;
                            *spslen = sizeof(spsM320);
                            *pps = ppsM352;
                            *ppslen = sizeof(ppsM320);
                            break;
                        case 640:
                            *sps = spsM640;
                            *spslen = sizeof(spsM640);
                            *pps = ppsM640;
                            *ppslen = sizeof(ppsM640);
                            break;
                        default:
                            *sps = spsM320;
                            *spslen = sizeof(spsM320);
                            *pps = ppsM352;
                            *ppslen = sizeof(ppsM320);
                            break;
                    }
                } else {
                    if(isBaseLine == 3) {
                        switch (frm_width) {
                            case 352:
                                *sps = spsM352_iPhone_4S;
                                *spslen = sizeof(spsM352_iPhone_4S);
                                *pps = ppsM352_iPhone_4S;
                                *ppslen = sizeof(ppsM352_iPhone_4S);
                                break;
                            case 320:
                                break;
                            case 640:
                                break;
                            default:
                                break;
                        }
                    }
                    if(isBaseLine == 4) {
                        switch (frm_width) {
                            case 352:
                                *sps = spsM352_iPhone_5;
                                *spslen = sizeof(spsM352_iPhone_5);
                                *pps = ppsM352_iPhone_5;
                                *ppslen = sizeof(ppsM352_iPhone_5);
                                break;
                            case 320:
                                break;
                            case 640:
                                break;
                            default:
                                break;
                        }
                    }
                    
                }
            }
        }
        return tsk_true;
    }
    
    tsk_bool_t rtmp_get_sps_pps_nal_unit(int version, int frm_width, uint8_t* spspps, int* spsppslen )
    {
        const uint8_t *sps, *pps;
        int spslen, ppslen;
        
        const uint8_t videoTagHdrStart[] = { 0x17, 0x00, 0x00, 0x00, 0x00, 0x01 };
        const uint8_t videoTagHdrEnd[] = { 0xFF, 0xE1 };
        
        if(!get_sps_pps_nal_unit(version, frm_width, &sps, &spslen, &pps, &ppslen))
            return tsk_false;
        
        uint8_t* p = spspps;
        
        memcpy(p, videoTagHdrStart, sizeof(videoTagHdrStart));
        p += sizeof(videoTagHdrStart);
        
        *p = sps[1]; p++;
        *p = sps[2]; p++;
        *p = sps[3]; p++;
        
        memcpy(p, videoTagHdrEnd, sizeof(videoTagHdrEnd));
        p += sizeof(videoTagHdrEnd);
        
        *((uint16_t*)p) = ntohs(spslen);
        p += sizeof(uint16_t);
        
        memcpy(p, sps, spslen);
        p += spslen;
        
        *p = 0x01;
        p++;

        *((uint16_t*)p) = ntohs(ppslen);
        p += sizeof(uint16_t);
        
        memcpy(p, pps, ppslen);
        
        *spsppslen = sizeof(videoTagHdrStart) + 3 + sizeof(videoTagHdrEnd) + sizeof(uint16_t) + spslen + 1 + sizeof(uint16_t) + ppslen;

        return tsk_true;
    }
    
    typedef enum AtomName_e
    {
        an_ftyp = 'ftyp',
        an_mdat = 'mdat',
        an_moov = 'moov',
        an_meta = 'meta',
        an_trak = 'trak',
        an_mdia = 'mdia',
        an_minf = 'minf',
        an_stbl = 'stbl',
        an_stsd = 'stsd',
        an_avcC = 'avcC'
    }atomname_t;
    
    typedef enum Brand_e
    {
        br_mp41 = 'mp41',
        br_mp42 = 'mp42',
        br_isom = 'isom',
        br_3gp4 = '3gp4'
    }brand_t;
    
    typedef enum DescvisualFormat_e
    {
        dvf_mp4v = 'mp4v',
        dvf_avc1 = 'avc1',
        dvf_encv = 'encv',
        dvf_s263 = 's263',
        
        dvf_mp4a = 'mp4a',
        dvf_enca = 'enca',
        dvf_samr = 'samr',
        dvf_sawb = 'sawb',
        
        dvf_mp4s = 'mp4s',
        dvf_encs = 'encs'
    }descvisualformat_t;
    
    typedef struct Atom
    {
        uint32_t offset;
        atomname_t name;
        
        void* data;
    }atom_t;
    
    typedef struct FileTypeBox
    {
        brand_t		major_brand;
        uint32_t	major_brand_version;
        brand_t*	compatible_brands;
    }filetypebox_t;
    
    typedef struct AvcCBox
    {
        uint8_t		version;
        uint8_t		profile;
        uint8_t		compatible_profiles;
        uint8_t		level;
        uint8_t		nal_length;
        uint8_t		sps_number;
        uint16_t	sps_length;
        uint8_t*	sps_nal_unit;
        uint8_t		pps_number;
        uint16_t	pps_length;
        uint8_t*	pps_nal_unit;
    }avccbox_t;
    
    typedef struct Mpeg4
    {
        FILE*	pfile;
        
        char*	buffer;
        int		buf_read_size;
        int		buf_read_pos;
        
        int		read_pos;
        
        int		depth;
        
        filetypebox_t	file_type_box;
        avccbox_t		avcc_box;
        
        int				media_data_offset;
    }mpeg4_t;
    
    uint32_t parseatom( mpeg4_t* mp4 );
    
    uint64_t ntoh64(uint64_t n)
    {
        uint32_t n1, n2;
        long t = ntohl(1);
        if(t == 1)
            return n;
        
        n1 = ntohl((uint32_t)(n & 0xFFFFFFFF));
        n2 = ntohl((uint32_t)((n >> 32) & 0xFFFFFFFF));
        
        n = n1;
        return (n << 32) | n2;
    }
    
    int updatebuffer(mpeg4_t* mp4, int unused_data_size)
    {
        if(unused_data_size > 0)
            memmove(mp4->buffer, mp4->buffer + mp4->buf_read_pos, unused_data_size);
        
        mp4->buf_read_size = fread(mp4->buffer + unused_data_size, sizeof(char), BUFFER_MAX_SIZE - unused_data_size, mp4->pfile);
        mp4->buf_read_size += unused_data_size;
        mp4->buf_read_pos = 0;
        
        return mp4->buf_read_size;
    }
    
    int movetopos(mpeg4_t* mp4, int pos)
    {
        int count = mp4->buf_read_size - mp4->buf_read_pos;
        if(count < pos)
        {
            fseek(mp4->pfile, pos - count, SEEK_CUR);
            mp4->buf_read_size = fread(mp4->buffer, sizeof(char), BUFFER_MAX_SIZE, mp4->pfile);
            mp4->buf_read_pos = 0;
        }
        else
        {
            mp4->buf_read_pos += pos;
        }
        
        mp4->read_pos += pos;
        
        return pos;
    }
    
    uint8_t getubyte(mpeg4_t* mp4)
    {
        uint8_t n;
        int count = mp4->buf_read_size - mp4->buf_read_pos;
        if(count < sizeof(uint8_t))
        {
            updatebuffer(mp4, count);
        }
        
        n = mp4->buffer[mp4->buf_read_pos];
        mp4->buf_read_pos += sizeof(uint8_t);
        mp4->read_pos += sizeof(uint8_t);
        return n;
    }
    
    uint16_t getushort(mpeg4_t* mp4)
    {
        uint16_t n;
        int count = mp4->buf_read_size - mp4->buf_read_pos;
        if(count < sizeof(uint16_t))
        {
            updatebuffer(mp4, count);
        }
        
        n = (uint16_t)ntohs(*((uint16_t*)(mp4->buffer + mp4->buf_read_pos)));
        mp4->buf_read_pos += sizeof(uint16_t);
        mp4->read_pos += sizeof(uint16_t);
        
        return n;
    }
    
    uint32_t getulong(mpeg4_t* mp4)
    {
        uint32_t n;
        int count = mp4->buf_read_size - mp4->buf_read_pos;
        if(count < sizeof(uint32_t))
        {
            updatebuffer(mp4, count);
        }
        
        n = (uint32_t)ntohl(*((uint32_t*)(mp4->buffer + mp4->buf_read_pos)));
        mp4->buf_read_pos += sizeof(uint32_t);
        mp4->read_pos += sizeof(uint32_t);
        
        return n;
    }
    
    uint64_t getuint64(mpeg4_t* mp4)
    {
        uint64_t n;
        int count = mp4->buf_read_size - mp4->buf_read_pos;
        if(count < sizeof(uint64_t))
        {
            updatebuffer(mp4, count);
        }
        
        n = (uint64_t)ntoh64(*((uint64_t*)(mp4->buffer + mp4->buf_read_pos)));
        mp4->buf_read_pos += sizeof(uint64_t);
        mp4->read_pos += sizeof(uint64_t);
        
        return n;
    }
    
    void* getbytearray(mpeg4_t* mp4, void* buf, int size)
    {
        int count;
        
        if(!buf || !size)
            return 0;
        
        count = mp4->buf_read_size - mp4->buf_read_pos;
        if(count < size)
        {
            updatebuffer(mp4, count);
        }
        
        memcpy(buf, mp4->buffer + mp4->buf_read_pos, size);
        mp4->buf_read_pos += size;
        mp4->read_pos += size;
        
        return buf;
    }
    
    int getcurrentpos(mpeg4_t* mp4)
    {
        return mp4->read_pos;
    }
    
    tsk_bool_t parseftyp( mpeg4_t* mp4, uint32_t offset )
    {
        int comp_brands_cnt;
        int i;
        
        mp4->file_type_box.major_brand = (brand_t)getulong(mp4);
        mp4->file_type_box.major_brand_version = (uint32_t)getulong(mp4);
        comp_brands_cnt = (offset - sizeof(mp4->file_type_box.major_brand) - sizeof(mp4->file_type_box.major_brand_version))/sizeof(uint32_t);
        
        if(comp_brands_cnt > 0)
        {
            mp4->file_type_box.compatible_brands = (brand_t*)calloc(comp_brands_cnt, sizeof(brand_t));
            for(i = 0; i < comp_brands_cnt; i++)
            {
                mp4->file_type_box.compatible_brands[i] = (brand_t)getulong(mp4);
            }
        }
        
        return tsk_true;
    }
    
    tsk_bool_t parsemdat( mpeg4_t* mp4, uint32_t offset )
    {
        uint64_t dataOffset;
        if(offset == 1)
        {
            dataOffset = getuint64(mp4);
            mp4->media_data_offset = getcurrentpos(mp4);
            movetopos(mp4, (int)dataOffset);
        }
        else
        {
            mp4->media_data_offset = getcurrentpos(mp4);
            movetopos(mp4, offset);
        }
        
        return tsk_true;
    }
    
    tsk_bool_t parsesubatom( mpeg4_t* mp4, uint32_t offset )
    {
        int size = offset;
        int i;
        
        mp4->depth++;
        while(size > 0)
        {
            for(i = 0; i < mp4->depth; i++)
                printf("\t");
            
            size -= parseatom(mp4);
        }
        mp4->depth--;
        
        return tsk_true;
    }
    
    tsk_bool_t parsestsd( mpeg4_t* mp4, uint32_t offset )
    {
        uint32_t desc_format, desc_length, count = 0, i;
//        uint32_t ver_flags = getulong(mp4);
        uint32_t descs_num = getulong(mp4);
        
        for(i = 0; i < descs_num; i++)
        {
            desc_length = getulong(mp4);
            desc_format = getulong(mp4);
            switch(desc_format)
            {
                case dvf_mp4v:
                case dvf_avc1:
                case dvf_encv:
                case dvf_s263:
                    movetopos(mp4, 78);
                    count = desc_length - 78;
                    break;
                case dvf_mp4a:
                case dvf_enca:
                case dvf_samr:
                case dvf_sawb:
                    movetopos(mp4, 28);
                    count = desc_length - 28;
                    break;
                case dvf_mp4s:
                case dvf_encs:
                    movetopos(mp4, 8);
                    count = desc_length - 8;
                    break;
            }
            parsesubatom(mp4, count - sizeof(desc_length) - sizeof(desc_format));
        }
        
        return tsk_true;
    }
    
    tsk_bool_t parseavcc( mpeg4_t* mp4, uint32_t offset )
    {
        mp4->avcc_box.version				= getubyte(mp4);
        mp4->avcc_box.profile				= getubyte(mp4);
        mp4->avcc_box.compatible_profiles = getubyte(mp4);
        mp4->avcc_box.level				= getubyte(mp4);
        mp4->avcc_box.nal_length			= (getubyte(mp4) & 0x03) + 1;
        
        mp4->avcc_box.sps_number			= getubyte(mp4);
        mp4->avcc_box.sps_length			= getushort(mp4);
        mp4->avcc_box.sps_nal_unit		= (uint8_t*)malloc(mp4->avcc_box.sps_length);
        getbytearray(mp4, mp4->avcc_box.sps_nal_unit, mp4->avcc_box.sps_length);
        
        mp4->avcc_box.pps_number			= getubyte(mp4);;
        mp4->avcc_box.pps_length			= getushort(mp4);
        mp4->avcc_box.pps_nal_unit		= (uint8_t*)malloc(mp4->avcc_box.sps_length);
        getbytearray(mp4, mp4->avcc_box.pps_nal_unit, mp4->avcc_box.pps_length);
        
        return tsk_true;
    }
    
    uint32_t parseatom( mpeg4_t* mp4 )
    {
        atom_t atom;
        
        atom.offset = getulong(mp4);
        atom.name = (atomname_t)getulong(mp4);
        
        printf("Atom: %c%c%c%c\n", atom.name >> 24 & 0xFF, atom.name >> 16 & 0xFF, atom.name >> 8 & 0xFF, atom.name & 0xFF);
        
        if(atom.offset - BOX_SIZE > 0)
        {
            switch(atom.name)
            {
                case an_ftyp:
                    atom.data = (void*)parseftyp(mp4, atom.offset - BOX_SIZE);
                    break;
                case an_mdat:
                    parsemdat(mp4, atom.offset);
                    break;
                case an_moov:
                case an_trak:
                case an_mdia:
                case an_minf:
                case an_stbl:
                    parsesubatom(mp4, atom.offset - BOX_SIZE);
                    break;
                case an_stsd:
                    parsestsd(mp4, atom.offset - BOX_SIZE);
                    break;
                case an_avcC:
                    parseavcc(mp4, atom.offset - BOX_SIZE);
                    break;
                default:
                    movetopos(mp4, atom.offset - BOX_SIZE);
                    break;
            }
        }
        
        return atom.offset;
    }
    
    
    mpeg4_t* openmpeg4file(const char* file_name)
    {
        mpeg4_t* mp4 = 0;
        if(!file_name || file_name[0] == '\0')
            return 0;
        
        mp4 = (mpeg4_t*)malloc(sizeof(mpeg4_t));
        if(!mp4)
            return 0;
        
        memset(mp4, 0, sizeof(mpeg4_t));
        mp4->pfile = fopen(file_name, "rb");
        if(!mp4->pfile)
        {
            free(mp4);
            return 0;
        }
        
        mp4->buffer = (char*)malloc(BUFFER_MAX_SIZE);
        if(!mp4->buffer)
        {
            fclose(mp4->pfile);
            free(mp4);
            return 0;
        }
        
        mp4->buf_read_size = 0;
        mp4->buf_read_pos = 0;
        
        mp4->read_pos = 0;
        
        mp4->depth = 0;
        
        return mp4;
    }
    
    void closempeg4file( mpeg4_t* mp4 )
    {
        if(mp4)
        {
            if(mp4->avcc_box.sps_nal_unit)
                free(mp4->avcc_box.sps_nal_unit);
            if(mp4->avcc_box.pps_nal_unit)
                free(mp4->avcc_box.pps_nal_unit);
            
            fclose(mp4->pfile);
            free(mp4->buffer);
            free(mp4);
        }
    }
    
    int parsefile( mpeg4_t* mp4 )
    {
        while(!feof(mp4->pfile))
        {
            parseatom(mp4);
        }
        
        return 0;
    }
    
    tsk_bool_t mpeg4_get_sps_pps_nal_unit(const char* file_name, uint8_t** sps, int* sps_len, uint8_t** pps, int* pps_len, int* mdat_offset)
    {
        mpeg4_t* mp4;
        int i;
        if(!sps_len || !pps_len)
            return tsk_false;
        
        TSK_DEBUG_INFO("mpeg4: Start file parsing...");
        
        TSK_DEBUG_INFO("mpeg4: openning file\n");
        mp4 = openmpeg4file(file_name);
        if(!mp4)
            return tsk_false;
        
        TSK_DEBUG_INFO("mpeg4: file sucsessfully opened\n");
        parsefile(mp4);
        
        TSK_DEBUG_INFO("mpeg4: parsing complite\n");
        
        *sps = malloc(mp4->avcc_box.sps_length);
        memcpy(*sps, mp4->avcc_box.sps_nal_unit, mp4->avcc_box.sps_length);
        *sps_len = mp4->avcc_box.sps_length;
        
        TSK_DEBUG_INFO("mpeg4: SPS Len: %d\n", *sps_len);
        TSK_DEBUG_INFO("mpeg4: SPS: ");
        for(i = 0; i < *sps_len; i++)
            TSK_DEBUG_INFO("%X ", (*sps)[i]);
        TSK_DEBUG_INFO("\n");
        
        
        *pps = malloc(mp4->avcc_box.pps_length);
        memcpy(*pps, mp4->avcc_box.pps_nal_unit, mp4->avcc_box.pps_length);
        *pps_len = mp4->avcc_box.pps_length;
        
        TSK_DEBUG_INFO("mpeg4: PPS Len: %d\n", *pps_len);
        TSK_DEBUG_INFO("mpeg4: PPS: ");
        for(i = 0; i < *pps_len; i++)
            TSK_DEBUG_INFO("%X ", (*pps)[i]);
        TSK_DEBUG_INFO("\n");
        
        *mdat_offset = mp4->media_data_offset;
        TSK_DEBUG_INFO("mpeg4: mdat offset: %d\n", *mdat_offset);
        
        closempeg4file(mp4);
        
        return tsk_true;
    }
    
#ifdef __cplusplus
};
#endif //__cplusplus
