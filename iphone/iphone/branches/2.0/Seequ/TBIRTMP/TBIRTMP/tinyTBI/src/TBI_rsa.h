//
//  TBI_rsa.h
//  TBIRTMP
//
//  Created by Macbook on 2/11/13.
//  Copyright (c) 2013 Grigori Jlavyan. All rights reserved.
//

#ifndef TBIRTMP_TBI_rsa_h
#define TBIRTMP_TBI_rsa_h

#include <openssl/rsa.h>

#if __cplusplus
extern "C" {
#endif

typedef struct tbi_rsa_s{
    
    RSA* rsa;
    
} tbi_rsa_t;

tbi_rsa_t* rsaOpen(const char* keyFilePath);
tbi_rsa_t* rsaOpenPrivate(const char* keyFilePath);

void rsaClose(tbi_rsa_t** self);
int rsaEncode(tbi_rsa_t* self, const char* sourceBytes, int len, char** encodedBytes, int* encodedMaxSize);
int rsaDecode(tbi_rsa_t* self, char* encodedBytes, int len, char** decodedBytes);
int rsaSign(tbi_rsa_t* self, const char* sourceBytes, int len, char** encodedBytes);

typedef struct tbi_rc4_s
{
    EVP_CIPHER_CTX *encrCtx;
    EVP_CIPHER_CTX *decrCtx;
}tbi_rc4_t;

tbi_rc4_t* rc4Open(const unsigned char* key);
void rc4Close(tbi_rc4_t** self);
int rc4Encrypt(tbi_rc4_t* self, const char* sourceBytes, int len, char** encodedBytes, int* encodedMaxSize);
int rc4Decrypt(tbi_rc4_t* self, char* decryptedBytes, int len, char* sourceBytes, int sourceMaxSize);

    
#if __cplusplus
}
#endif

#endif
