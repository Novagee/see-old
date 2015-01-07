//
//  TBI_rsa.c
//  TBIRTMP
//
//  Created by Macbook on 2/11/13.
//  Copyright (c) 2013 Grigori Jlavyan. All rights reserved.
//

#include "TBI_rsa.h"
#include "TBI_memory.h"
#include <openssl/pem.h>
#include <openssl/err.h>

tbi_rsa_t* rsaOpen(const char* keyFilePath)
{
    tbi_rsa_t* self = calloc(1, sizeof(tbi_rsa_t));
    
    FILE * keyFile = fopen(keyFilePath, "rb");
    if(keyFile)
    {
        PEM_read_RSA_PUBKEY(keyFile, &self->rsa, NULL, NULL);
        fclose(keyFile);

        if(self->rsa)
            return self;
    }
    free(self);
    return 0;
}

tbi_rsa_t* rsaOpenPrivate(const char* keyFilePath) {
    tbi_rsa_t* self = calloc(1, sizeof(tbi_rsa_t));
    
    FILE * keyFile = fopen(keyFilePath, "rb");
    if(keyFile)
    {
        PEM_read_RSAPrivateKey(keyFile, &self->rsa, NULL, NULL);
        fclose(keyFile);
        
        if(self->rsa)
            return self;
    }
    free(self);
    return 0;
}

void rsaClose(tbi_rsa_t** self)
{
    if(*self)
    {
        RSA_free((*self)->rsa);
        free(*self);
        (*self) = 0;
    }
}

int rsaEncode(tbi_rsa_t* self, const char* sourceBytes, int len, char** encodedBytes, int* encodedMaxSize)
{
    int encLen = RSA_size(self->rsa);
    if(!(*encodedBytes) || encLen > (*encodedMaxSize))
    {
        *encodedBytes = (char*)TBI_realloc(*encodedBytes, encLen);
        *encodedMaxSize = encLen;
    }
    return RSA_public_encrypt(len, (const unsigned char*)sourceBytes, (unsigned char*)(*encodedBytes), self->rsa, RSA_PKCS1_PADDING);
}

int rsaDecode(tbi_rsa_t* self, char* encodedBytes, int len, char** decodedBytes)
{
    return -1;
}

int rsaSign(tbi_rsa_t* self, const char* sourceBytes, int len, char** encodedBytes)
{
    int encLen = RSA_size(self->rsa);
    *encodedBytes = calloc(1, encLen);
    unsigned int length = 0;
//    unsigned char buffer[256];
//    
    // hashing the message
    unsigned char digest[SHA256_DIGEST_LENGTH];
    SHA256_CTX sha256_ctx = { 0 };
    SHA256_Init(&sha256_ctx);
    SHA256_Update(&sha256_ctx, sourceBytes, len);
    SHA256_Final(digest, &sha256_ctx);
        
    if (RSA_sign(NID_sha256, (const unsigned char*)digest, SHA256_DIGEST_LENGTH, (unsigned char*)(*encodedBytes), &length, self->rsa)) {
        return length;
    }
    
    return 0;
}

//RC4 encrypt / decrypt
tbi_rc4_t* rc4Open(const unsigned char* key)
{
    tbi_rc4_t* self = (tbi_rc4_t*)TBI_malloc(sizeof(tbi_rc4_t));
    if(self)
    {
        const EVP_CIPHER* cipher = EVP_rc4();
        self->encrCtx = ( EVP_CIPHER_CTX * )TBI_malloc( sizeof(EVP_CIPHER_CTX ));
        EVP_CIPHER_CTX_init( self->encrCtx );
        EVP_EncryptInit_ex( self->encrCtx, cipher, NULL, key, TBI_null );
        
        self->decrCtx = ( EVP_CIPHER_CTX * )TBI_malloc( sizeof(EVP_CIPHER_CTX ));
        EVP_CIPHER_CTX_init( self->decrCtx );
        EVP_DecryptInit_ex( self->decrCtx, cipher, NULL, key, TBI_null );
    }
    return self;
}

void rc4Close(tbi_rc4_t** self)
{
    if(self && *self)
    {
        EVP_CIPHER_CTX_cleanup( (*self)->encrCtx );
        EVP_CIPHER_CTX_cleanup( (*self)->decrCtx );
        
        TBI_FREE( (*self)->encrCtx );
        TBI_FREE( (*self)->decrCtx );
        
        TBI_free((void**)self);
    }
}

int rc4Encrypt(tbi_rc4_t* self, const char* sourceBytes, int len, char** encodedBytes, int* encodedMaxSize)
{
    if(!(*encodedBytes) || *encodedMaxSize < len)
    {
        *encodedBytes = (char*)TBI_realloc(*encodedBytes, len);
        *encodedMaxSize = len;
    }
    
    int outLen = 0, outLen1 = 0;
    
    
    EVP_EncryptUpdate( self->encrCtx, (unsigned char*)(*encodedBytes), &outLen, (unsigned char*)sourceBytes, len );
    //    EVP_EncryptFinal( self->encrCtx, (unsigned char*)(&(*encodedBytes)[outLen]), &outLen1 );
    
    return outLen + outLen1;
}

int rc4Decrypt(tbi_rc4_t* self, char* decryptedBytes, int len, char* sourceBytes, int sourceMaxSize)
{
    int outLen = 0, outLen1 = 0;
    
    EVP_DecryptUpdate( self->decrCtx, (unsigned char*)sourceBytes, &outLen, (unsigned char*)(decryptedBytes), len );
    //    EVP_DecryptFinal( self->decrCtx, (unsigned char*)(&sourceBytes[outLen]), &outLen1 );
    
    return outLen + outLen1;
}

