/* --------------------------------------------------------------------*
 *                                                                     *  
 *  AES-256-CBC file crypter/ cpu CORE i5/i7 support                   * 
 *                                                                     *
 *  (c) Ostrovsky Alexey, 2013                                         * 
 *                                                                     *  
 * --------------------------------------------------------------------*/
 
// see also: https://github.com/jabberd/xor-crypter/ + 
//           https://github.com/sbuggay/xorcrypt
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "iaesni.h"
#include "sha256.h"
#include "aes_sft.h"

#define BUFSIZE 16384*4
typedef unsigned char byte;

// unsigned char test_key_256[32] = {0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a,0x0b,0x0c,0x0d,0x0e,0x0f,0x10,0x11,
// 0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f};
// unsigned char test_iv[16] = {0x00,0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88,0x99,0xaa,0xbb,0xcc,0xdd,0xee,0xff};

size_t file_size(FILE * f)
{
    fseek(f, 0, SEEK_END);
    size_t result = ftell(f);
    fseek(f, 0, SEEK_SET);
    return result;
}

void my_exit(FILE * x, FILE * y, char msg [])
{
    if (x != NULL) fclose(x);
    if (y != NULL) fclose(y);
    
    puts(msg);
    
    exit(EXIT_FAILURE);
}

void crypt_file (char * in, char * out, char * act, char * key1_, char * key2_) 
{

    unsigned char key1[32];
    unsigned char key2[32];
    unsigned char key2w[16];

    sha256(key1_, strlen(key1_), key1);
    sha256(key2_, strlen(key2_), key2);

    memcpy(key2w, key2, 16);

    FILE *ifp;
    FILE *ofp;

    ifp = fopen(in, "rb");
    if (ifp == NULL) my_exit(ifp, ofp, "Can't open input file.");
    
    ofp = fopen(out, "wb");
    if (ofp == NULL) my_exit(ifp, ofp, "Can't open output file.");
    
    int hard_ = check_for_aes_instructions();
    if (hard_) printf("++ AES cpu instruction found.\n");
    else       printf("-- AES cpu instruction NOT found.\n");
  
    byte buffer[BUFSIZE];
    byte res[BUFSIZE];

    int flag = 0;
    
    int temp = !strncmp(act, "x", 1);
    if ( !strncmp(act, "a", 1) || temp ) hard_ = 0;
    if ( !strncmp(act, "d", 1) || temp ) {
        flag = 1;
        printf("DECRYPT {ver. %d} ...\n", hard_); 
    } 
    else printf("ENCRYPT {ver. %d} ...\n", hard_); 
   
    size_t nread;
    size_t fz = file_size(ifp);
    size_t se = 0;

    if (flag == 1) se = sizeof(size_t); //decrypt
  
    if (fz <= ( se + 1)) my_exit(ifp, ofp, "Input file is empty!");
  
    fseek(ifp, 0, SEEK_SET);
    fseek(ofp, 0, SEEK_SET);

    int ee = 0;
    if (flag == 1) { // decrypt
        size_t nr = fread(&ee, sizeof(int), 1, ifp);
        if (ee > 15) my_exit(ifp, ofp, "Corrupt input file!");
    }
    else fwrite(&ee, sizeof(int), 1, ofp);
 
    int w = 0;
    
    AesCtx ctx;
    AesCtxIni(&ctx, key2w, key1, KEY256, CBC);       

    for (;;) {
        nread = fread(buffer, sizeof(byte), BUFSIZE, ifp);
        if (nread == 0) break;

        size_t numBlocks = nread >> 4;
        size_t a = nread - (numBlocks << 4);
        size_t aa = 16 - a;

        if (a > 0) numBlocks++;
      
        if (flag == 0) { 
            if (hard_) intel_AES_enc256_CBC(buffer, res, key1, numBlocks, key2w);
            else AesEncrypt(&ctx, buffer, res, numBlocks << 4);
        }
        else {
            if (hard_) intel_AES_dec256_CBC(buffer, res, key1, numBlocks, key2w);
            else AesDecrypt(&ctx, buffer, res, numBlocks << 4);
        }
        
        w = 0;
        if ( (flag == 0) && (a > 0) ) w = aa;
        else { 
            if ( (flag == 1) && (feof(ifp)) ) w = -ee;
        }

        fwrite(res, sizeof(byte), (size_t)(nread + w), ofp);

        memset(buffer, 0, BUFSIZE);
        memset(res, 0, BUFSIZE);
            
    }

    if (flag == 0) { // crypt
        fseek(ofp, 0, SEEK_SET);
        fwrite(&w, sizeof(int), 1, ofp);
        fseek(ofp, 0, SEEK_END);
    } 

    if (feof(ifp)) printf("ok.\n");
    else my_exit(ifp, ofp, "Error occured while reading input file!");
   
    fclose(ifp);
    fclose(ofp);

}
 
int main(int argc, char *argv[]) 
{

    if(argc == 6) {
        crypt_file (argv[1], argv[2], argv[3], argv[4], argv[5]);
    }
    else {
        printf("use --> aes64 in.file out.file d{e} key1 key2\n");
    }
    
    return 0;
}

