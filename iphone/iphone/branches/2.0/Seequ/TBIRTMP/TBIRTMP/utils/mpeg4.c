//
//  TBI_mpeg4.c
//  ios-ngn-stack
//
//  Created by Administrator on 10/6/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#include "mpeg4.h"
#include "TBI_debug.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/sysctl.h>

#ifdef WIN32
#include <winsock2.h>
#endif //WIN32

char System_Versio[256];

#define BOX_SIZE		8
#define BUFFER_MAX_SIZE	1024

int isBaseLine = 0;

#ifdef __cplusplus
extern "C" {
#endif //__cplusplus
    uint8_t *spsUniversal176x144;
    uint32_t spsUniversalSize176x144;
    uint8_t *ppsUniversal176x144;
    uint32_t ppsUniversalSize176x144;
    
    uint8_t *spsUniversal352x288;
    uint32_t spsUniversalSize352x288;
    uint8_t *ppsUniversal352x288;
    uint32_t ppsUniversalSize352x288;
    
    uint8_t *spsUniversal640x480;
    uint32_t spsUniversalSize640x480;
    uint8_t *ppsUniversal640x480;
    uint32_t ppsUniversalSize640x480;
    
    tbi_bool_t get_sps_pps_nal_unit(const uint8_t** sps, int* spslen, const uint8_t** pps, int* ppslen, int type )
    {
        if(type==SIZE_176_X_144){
            
            *sps = spsUniversal176x144;
            *spslen = sizeof(spsUniversal176x144);
            *pps = ppsUniversal176x144;
            *ppslen = sizeof(ppsUniversal176x144);
            
        }else if(type==SIZE_352_X_288) {
            
            *sps = spsUniversal352x288;
            *spslen = sizeof(spsUniversal352x288);
            *pps = ppsUniversal352x288;
            *ppslen = sizeof(ppsUniversal352x288);
            
        } else if(type==SIZE_640_X_480 ){
            
            *sps = spsUniversal640x480;
            *spslen = sizeof(spsUniversal640x480);
            *pps = ppsUniversal640x480;
            *ppslen = sizeof(ppsUniversal640x480);
            
        }
        
        return tbi_true;
    }
    
    tbi_bool_t rtmp_get_sps_pps_nal_unit(uint8_t* spspps, int* spsppslen,int type )
    {
        if((type==SIZE_176_X_144 && (!spsUniversal176x144 || !ppsUniversal176x144)) || !spsUniversal352x288 || !ppsUniversal352x288){
            return tbi_false;
        }
        const uint8_t *sps;
        
        const uint8_t *pps;
        
        int spslen;
        
        int ppslen;
        
        
        if(type == SIZE_176_X_144)
        {
            sps = spsUniversal176x144;
            pps =  ppsUniversal176x144;
            spslen = spsUniversalSize176x144;
            ppslen = ppsUniversalSize176x144;
        }
        else if(type == SIZE_352_X_288)
        {
            sps = spsUniversal352x288;
            pps =  ppsUniversal352x288;
            spslen = spsUniversalSize352x288;
            ppslen = ppsUniversalSize352x288;
        }
        else {//if(type == SIZE_640_X_480){
            sps = spsUniversal640x480;
            pps =  ppsUniversal640x480;
            spslen = spsUniversalSize640x480;
            ppslen = ppsUniversalSize640x480;
        }
        const uint8_t videoTagHdrStart[] = { 0x17, 0x00, 0x00, 0x00, 0x00, 0x01 };
        const uint8_t videoTagHdrEnd[] = { 0xFF, 0xE1 };
        
        
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
        
        return tbi_true;
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
        if(mp4->buf_read_pos<0)
            mp4->buf_read_pos = 0;
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
    
    tbi_bool_t parseftyp( mpeg4_t* mp4, uint32_t offset )
    {
        int comp_brands_cnt;
        int i;
        
        mp4->file_type_box.major_brand = (brand_t)getulong(mp4);
        mp4->file_type_box.major_brand_version = (uint32_t)getulong(mp4);
        comp_brands_cnt = (offset - sizeof(mp4->file_type_box.major_brand) - sizeof(mp4->file_type_box.major_brand_version))/sizeof(uint32_t);
        
        if(comp_brands_cnt > 0)
        {
            mp4->file_type_box.compatible_brands = (brand_t*)calloc(comp_brands_cnt, sizeof(uint32_t));
            for(i = 0; i < comp_brands_cnt; i++)
            {
                mp4->file_type_box.compatible_brands[i] = (brand_t)getulong(mp4);
            }
        }
        
        return tbi_true;
    }
    
    tbi_bool_t parsemdat( mpeg4_t* mp4, uint32_t offset )
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
        
        return tbi_true;
    }
    
    tbi_bool_t parsesubatom( mpeg4_t* mp4, uint32_t offset )
    {
        int size = offset;
        mp4->depth++;
        while(size > 0)
        {
            //            for(i = 0; i < mp4->depth; i++)
            //                printf("\t");
            
            size -= parseatom(mp4);
        }
        mp4->depth--;
        
        return tbi_true;
    }
    
    tbi_bool_t parsestsd( mpeg4_t* mp4, uint32_t offset )
    {
        uint32_t desc_format, desc_length, count, i, ver_flags, descs_num;
        
        ver_flags = getulong(mp4);
        descs_num = getulong(mp4);
        
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
        
        return tbi_true;
    }
    
    tbi_bool_t parseavcc( mpeg4_t* mp4, uint32_t offset )
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
        
        return tbi_true;
    }
    
    uint32_t parseatom( mpeg4_t* mp4 )
    {
        atom_t atom;
        
        atom.offset = getulong(mp4);
        atom.name = (atomname_t)getulong(mp4);
        
        if(atom.offset == 0)
            return 0;
        
        //        printf("Atom: %c%c%c%c\n", atom.name >> 24 & 0xFF, atom.name >> 16 & 0xFF, atom.name >> 8 & 0xFF, atom.name & 0xFF);
        
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
        while(!feof(mp4->pfile) || mp4->buf_read_pos < mp4->buf_read_size)
        {
            if(parseatom(mp4) == 0)
                return -1;
        }
        
        return 0;
    }
    
    tbi_bool_t mpeg4_get_sps_pps_nal_unit(const char* file_name, uint8_t** sps, uint32_t* sps_len, uint8_t** pps, uint32_t* pps_len, int* mdat_offset)
    {
        tbi_bool_t bRet = tbi_false;
        mpeg4_t* mp4;
        int i;
        if(!sps_len || !pps_len)
            return tbi_false;
        
        TBI_DEBUG_INFO("mpeg4: Start file parsing...");
        TBI_DEBUG_INFO("mpeg4: openning file");
        
        mp4 = openmpeg4file(file_name);
        if(!mp4)
            return tbi_false;
        
        TBI_DEBUG_INFO("mpeg4: file sucsessfully opened");
        if(parsefile(mp4) >= 0)
        {
            TBI_DEBUG_INFO("mpeg4: parsing complite");
            
            *sps = malloc(mp4->avcc_box.sps_length);
            memcpy(*sps, mp4->avcc_box.sps_nal_unit, mp4->avcc_box.sps_length);
            *sps_len = mp4->avcc_box.sps_length;
            
            TBI_DEBUG_INFO("mpeg4: SPS Len: %d", *sps_len);
            TBI_DEBUG_INFO_WOE("mpeg4: SPS: ");
            for(i = 0; i < *sps_len; i++){
                TBI_DEBUG_INFO_WOE("%.2X ", (*sps)[i]);
            }
            TBI_DEBUG_INFO_WOE("\n");
            
            int pps_size = mp4->avcc_box.pps_length;
            *pps = malloc(pps_size);
            memcpy(*pps, mp4->avcc_box.pps_nal_unit, mp4->avcc_box.pps_length);
            *pps_len = mp4->avcc_box.pps_length;
            
            TBI_DEBUG_INFO("mpeg4: PPS Len: %d", *pps_len);
            TBI_DEBUG_INFO_WOE("mpeg4: PPS: ");
            for(i = 0; i < *pps_len; i++){
                TBI_DEBUG_INFO_WOE("%.2X ", (*pps)[i]);
            }
            TBI_DEBUG_INFO_WOE("\n");
            
            *mdat_offset = mp4->media_data_offset;
            TBI_DEBUG_INFO("mpeg4: mdat offset: %d", *mdat_offset);
            
            bRet = tbi_true;
        }
        
        closempeg4file(mp4);
        
        return bRet;
    }
    
#ifdef __cplusplus
};
#endif //__cplusplus
