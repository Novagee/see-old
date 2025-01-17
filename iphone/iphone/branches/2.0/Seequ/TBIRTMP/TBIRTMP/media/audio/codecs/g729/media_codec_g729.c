//
//
///**@file media_codec_g729.c
// * @brief G729ab codec.
// * Source from: http://www.itu.int/rec/T-REC-G.729-199610-S!AnnB/en
// *
// 
// *
// 
// */
//#include "media_codec_g729.h"
//
//#ifdef HAVE_G729
//#include <stdio.h>
//
//#include "g729/dtx.h"
//#include "g729/octet.h"
//
//#include "tbi_debug.h"
//
//#include <stdlib.h>
//#include <memory.h>
//
//#if defined(_MSC_VER)
//#	pragma comment(lib, "../thirdparties/win32/lib/g729b/g729b.a")
//#endif
//
//Word16 bad_lsf;        /* bad LSF indicator   */
//
////#ifndef G729_ENABLE_VAD
//#define G729_ENABLE_VAD 0
////#endif
//
//static Word16 bin2int(Word16 no_of_bits, const Word16 *bitstream);
//static void int2bin(Word16 value, Word16 no_of_bits, Word16 *bitstream);
//
//static void unpack_G729(const uint8_t bitstream[], Word16 bits[], int len);
//static void unpack_SID(const uint8_t bitstream[], Word16 bits[]);
//
//static void pack_G729(const Word16 ituBits[], uint8_t bitstream[]);
//static void pack_SID(const Word16 ituBits[], uint8_t bitstream[]);
//
///* ============ G.729ab Plugin interface ================= */
//
//static int media_codec_g729ab_open(media_codec_t* self)
//{
//    if(self->codec)
//        return 0;
//    
//	media_codec_g729ab_t* g729a = (media_codec_g729ab_t*)calloc(1, sizeof(media_codec_g729ab_t));
//    
//    g729a->encoder.vad_enable = G729_ENABLE_VAD; // AnnexB
//    
//	// Initialize the decoder
//	bad_lsf = 0;
//	g729a->decoder.synth = (g729a->decoder.synth_buf + M);
//    
//	Init_Decod_ld8a();
//	Init_Post_Filter();
//	Init_Post_Process();
//	/* for G.729B */
//	Init_Dec_cng();
//	
//	// Initialize the encoder
//	Init_Pre_Process();
//	Init_Coder_ld8a();
//	Set_zero(g729a->encoder.prm, PRM_SIZE + 1);
//	/* for G.729B */
//	Init_Cod_cng();
//	
//    self->codec = g729a;
//    
//	return 0;
//}
//
//static int media_codec_g729ab_close(media_codec_t* self)
//{
//    if(self)
//    {
//        media_codec_g729ab_t* g729a = (media_codec_g729ab_t*)self->codec;
//        if(g729a)
//        {
//            free(g729a);
//            self->codec = 0;
//        }
//    }
//	
//	return 0;
//}
//
//static tbi_size_t media_codec_g729ab_encode(media_codec_t* self, const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size)
//{
//	if(!self || !in_data || !in_size || !out_data || (in_size % 160)){
//		TBI_DEBUG_ERROR("Invalid parameter");
//		return 0;
//	}
//	
//	tbi_size_t ex_size, out_size = 0;
//	media_codec_g729ab_t* g729a = (media_codec_g729ab_t*)self->codec;
//	int i, frame_count = (in_size / 160);
//	
//	ex_size = (frame_count * 10);
//    
//	// allocate new buffer if needed
//	if(*out_max_size <ex_size){
//		if(!(*out_data = realloc(*out_data, ex_size))){
//			TBI_DEBUG_ERROR("Failed to allocate new buffer");
//			*out_max_size = 0;
//			return 0;
//		}
//		*out_max_size = ex_size;
//	}
//    
//	for(i=0; i<frame_count; i++){
//		extern Word16 *new_speech;
//		
//		if(g729a->encoder.frame == 32767){
//			g729a->encoder.frame = 256;
//		}
//		else{
//			g729a->encoder.frame++;
//		}
//		
//		memcpy(new_speech, &((uint8_t*)in_data)[i*L_FRAME*sizeof(Word16)], sizeof(Word16)*L_FRAME);
//		
//		Pre_Process(new_speech, L_FRAME);
//		Coder_ld8a(g729a->encoder.prm, g729a->encoder.frame, g729a->encoder.vad_enable);
//		prm2bits_ld8k(g729a->encoder.prm, g729a->encoder.serial);
//		
//		if(g729a->encoder.serial[1] == RATE_8000){
//			pack_G729(&g729a->encoder.serial[2], &((uint8_t*)(*out_data))[out_size]);
//			out_size += 10;
//		}
//		else if(g729a->encoder.serial[1] == RATE_SID_OCTET){
//			pack_SID(&g729a->encoder.serial[2], &((uint8_t*)(*out_data))[out_size]);
//			out_size += 2;
//		}
//		else{ // RATE_0
//			//TBI_DEBUG_INFO("G729_RATE_0 - Not transmitted");
//			return 0;
//		}
//	}
//    
//	return out_size;
//}
//
//static tbi_size_t media_codec_g729ab_decode(media_codec_t* self, const void* in_data, tbi_size_t in_size, void** out_data, tbi_size_t* out_max_size)
//{
//	if(!self || !in_data || !in_size || !out_data || ((in_size % 10) && (in_size % 10 != 2))){
//		TBI_DEBUG_ERROR("Invalid parameter");
//		return 0;
//	}
//    
//	tbi_size_t out_size = 0;
//	int i, frame_count;
//	const uint8_t* data_start = (const uint8_t*)in_data;
//	const uint8_t* data_end;
//	media_codec_g729ab_t* g729a = (media_codec_g729ab_t*)self->codec;
//    
//	data_end = (data_start + in_size);
//    
//	frame_count = (in_size/10) + ((in_size % 10) ? 1 : 0);
//    
//	out_size = 160*frame_count;
//    
//	/* allocate new buffer if needed */
//	if(*out_max_size <out_size){
//		if(!(*out_data = realloc(*out_data, out_size))){
//			TBI_DEBUG_ERROR("Failed to allocate new buffer");
//			*out_max_size = 0;
//			return 0;
//		}
//		*out_max_size = out_size;
//	}
//    
//	for(i=0; i<frame_count; i++){
//		memset(g729a->decoder.synth_buf, 0, M);
//		g729a->decoder.synth = g729a->decoder.synth_buf + M;
//        
//		if((data_end - data_start) == 2){
//			unpack_SID(data_start, g729a->decoder.serial);
//			data_start += 2;
//		}
//		else{
//			unpack_G729(data_start, g729a->decoder.serial, 10);
//			data_start += 10;
//		}
//        
//		bits2prm_ld8k(&g729a->decoder.serial[1], g729a->decoder.parm);
//        
//		/* This part was modified for version V1.3 */
//		/* for speech and SID frames, the hardware detects frame erasures
//         by checking if all bits are set to zero */
//		/* for untransmitted frames, the hardware detects frame erasures
//         by testing serial[0] */
//        
//		g729a->decoder.parm[0] = 0;           /* No frame erasure */
//		if(g729a->decoder.serial[1] != 0) {
//			int j;
//			for (j=0; j < g729a->decoder.serial[1]; j++){
//				if (g729a->decoder.serial[j+2] == 0){
//					g729a->decoder.parm[0] = 1;  /* frame erased     */
//					break;
//				}
//			}
//		}
//		else if(g729a->decoder.serial[0] != SYNC_WORD){
//			g729a->decoder.parm[0] = 1;
//		}
//		if(g729a->decoder.parm[1] == 1) {
//			/* check parity and put 1 in parm[5] if parity error */
//			g729a->decoder.parm[5] = Check_Parity_Pitch(g729a->decoder.parm[4], g729a->decoder.parm[5]);
//		}
//        
//		Decod_ld8a(g729a->decoder.parm, g729a->decoder.synth, g729a->decoder.Az_dec, g729a->decoder.T2, &g729a->decoder.Vad);
//		Post_Filter(g729a->decoder.synth, g729a->decoder.Az_dec, g729a->decoder.T2, g729a->decoder.Vad);        /* Post-filter */
//		Post_Process(g729a->decoder.synth, L_FRAME);
//        
//		memcpy(&((uint8_t*)*out_data)[160*i], g729a->decoder.synth, 160);
//	}
//    
//    
//	return out_size;
//}
//
///* ============ Internal functions ================= */
//
//
///**
// * Converts from bitstream (ITU bits) to word16 value
// * @param no_of_bits number of bits to read
// * @param bitstream array containing bits
// * @retval decimal value of bit pattern
// */
//static Word16 bin2int(Word16 no_of_bits, const Word16 *bitstream)
//{
//	Word16   value, i;
//	Word16 bit;
//	
//	value = 0;
//	for(i = 0; i < no_of_bits; i++){
//		value <<= 1;
//		bit = *bitstream++;
//		if (bit == BIT_1){
//			value += 1;
//		}
//	}
//	return(value);
//}
//
///*----------------------------------------------------------------------------
// * int2bin convert integer to binary and write the bits bitstream array
// *----------------------------------------------------------------------------
// */
//
///**
// * Writes Word16 value to bitstream
// * @param value decimal value to write
// * @param no_of_bits number of bits from value to write
// * @param bitstream pointer to the destination stream (ITU bits)
// */
//static void int2bin(Word16 value, Word16 no_of_bits, Word16 *bitstream)
//{
//	Word16 *pt_bitstream;
//	Word16   i, bit;
//    
//	pt_bitstream = bitstream + no_of_bits;
//    
//	for (i = 0; i < no_of_bits; i++){
//		bit = value & (Word16)0x0001;      /* get lsb */
//		if (bit == 0){
//			*--pt_bitstream = BIT_0;
//		}
//		else{
//			*--pt_bitstream = BIT_1;
//		}
//		value >>= 1;
//	}
//}
//
///**
// * UnPack RTP bitstream as unpacked ITU stream
// * @param bitstream RTP bitstream to unpack
// * @param bits ITU bitstream used as destination (0 - BIT_0, 1 - BIT_1)
// * @param len length of the RTP bitstream
// */
//static void unpack_G729(const uint8_t bitstream[], Word16 bits[], int len)
//{
//	Word16 i;
//	*bits++ = SYNC_WORD;     /* bit[0], at receiver this bits indicates BFI */
//	switch(len){
//		case 10:
//			*bits++ = SIZE_WORD;
//			break;
//		case 8: // RATE_6400
//		case 15: //RATE_11800
//		default:
//			TBI_DEBUG_ERROR("%d is an invalid lenght value", len);
//			return;
//	}
//    
//	for(i=0; i<len; i++){
//		int2bin(bitstream[i], 8, &bits[i*8]);
//	}
//}
//
///**
// * UnPack RTP bitstream containing SID frame as unpacked ITU stream
// * @param bitstream RTP bitstream to unpack
// * @param bits ITU bitstream used as destination (0 - BIT_0, 1 - BIT_1)
// */
//static void unpack_SID(const uint8_t bitstream[], Word16 bits[])
//{
//    *bits++ = SYNC_WORD;
//    *bits++ = RATE_SID_OCTET;
//    int2bin((Word16)bitstream[0], 8, &bits[0]);
//    int2bin((Word16)bitstream[1], 8, &bits[8]);
//}
//
///**
// * Pack ITU bits into RTP stream
// * @param ituBits ITU stream to pack (80 shorts)
// * @param bitstream RTP bitstream (80 bits, 5 shorts, 10 bytes)
// */
//static void pack_G729(const Word16 ituBits[], uint8_t bitstream[])
//{
//	Word16 word16, i;
//	for(i=0; i<5; i++){
//		word16 = bin2int(16, (Word16*)&ituBits[i*16]);
//		bitstream[i*2] = word16>>8, bitstream[(i*2)+1] = (word16 & 0xFF);
//	}
//}
//
///**
// * Pack ITU bits containing SID frame as RTP stream
// * @param ituBits ITU stream to pack
// * @param bitstream RTP bitstream (15 bits, 1 short, 2 bytes)
// */
//static void pack_SID(const Word16 ituBits[], uint8_t bitstream[])
//{
//	Word16 word16 = bin2int(16, ituBits);
//	bitstream[0] = word16>>8, bitstream[1] = (word16 & 0xFF);
//}
//
//
////
////	g729ab Plugin definition
////
//
//static media_codec_t media_codec_g729ab_s =
//{
//	media_audio,
//	"g729",
//	"g729ab Codec",
//	MEDIA_CODEC_FORMAT_G729,
//	8000, // rate
//    {0,20},
//    {352,288,12},
//    {0,352,288}, // rotate
//    0,
//    -1,
//    1, // bits per sample
//	media_codec_g729ab_open,
//	media_codec_g729ab_close,
//	media_codec_g729ab_encode,
//	media_codec_g729ab_decode,
//};
//
//media_codec_t *pmedia_codec_g729ab = &media_codec_g729ab_s;
//
//#endif /* HAVE_G729 */
