//
//  g711C.cpp
//  MyAiert
//
//  Created by AndyPan on 13-10-23.
//  Copyright (c) 2013年 爱尔特电子有限公司. All rights reserved.
//


#import "g711C.h"
#include "string.h"
//把标准的g711a数据打包成hisi格式的音频帧流
int PacketG711A_HISI(unsigned char* hisiBuf,int hisiBufLen,const unsigned char* g711Buf,int g711BufLen,int blflag)
{
    int afFormat=0,afSize=0,afNum=0;
    //    int standBufLen = g711BufLen;
    //    unsigned char* fStandBuf = 0x0L;
    unsigned char* tmpHiSiBuf = 0X0L;
    unsigned char* tmpStandBuf= 0X0L;
    unsigned char hisiHead[4]={0};
    int i=0;
    int rlen=0;
    
    afFormat =0x01;
    afSize = FIX_HISI_AUDIO_FRAME_SIZE;
    afNum = (g711BufLen)/FIX_HISI_AUDIO_FRAME_SIZE;
    
    //生成海思的g711数据头
    if (G711_BIG_ENDIAN==blflag)
    {
        hisiHead[1]=afFormat;
        hisiHead[2]=afSize;
    }
    else
    {
        hisiHead[0]=afFormat;
        hisiHead[3]=afSize;
    }
    
    //拆分标准g711数据成海思音频帧格式
    tmpHiSiBuf = hisiBuf;
    tmpStandBuf = (unsigned char*)g711Buf;
    
    for (i=0;i<afNum;i++)
    {
        //copy 头部信息
        memcpy(tmpHiSiBuf,&hisiHead[0],4);
        //copy 音频帧信息
        memcpy(&tmpHiSiBuf[4],&tmpStandBuf,afSize*2);
        tmpHiSiBuf  += (afSize*2+4);
        tmpStandBuf += afSize*2;
    }
    
    rlen = afNum*(afSize*2+4);
    
    return rlen;
}

//把海思格式的音频帧流解包成标准的g711a流
int UnPacketG711A_HISI(unsigned char* g711Buf,int g711BufLen,const unsigned char* hisiBuf,int hisiBufLen,int blflag)
{
    int afFormat=0,afSize=0,afNum=0;
    //    unsigned char* fStandBuf = 0X0L;
    unsigned char* tmpHiSiBuf = 0X0L;
    unsigned char* tmpStandBuf= 0X0L;
    int standBufLen =0;
    int i=0;
    //    int rlen=0;
    //分析HISIbuffer的头信息
    GetHISIAudioFrameInfo((const unsigned char*)hisiBuf,hisiBufLen,&afFormat,&afSize,&afNum,blflag);
    
    //转换成正常的g711数据流
    standBufLen = afSize*afNum;
    
    tmpHiSiBuf = (unsigned char*)hisiBuf;
    tmpStandBuf = g711Buf;
    for ( i=0;i<afNum;i++)
    {
        memcpy(tmpStandBuf,&tmpHiSiBuf[4],afSize);
        tmpHiSiBuf  += (afSize+4);
        tmpStandBuf += afSize;
    }
    return standBufLen;
}


//获取海思音频数据中的音频帧信息（字节单位）
//参考海思的文档《hi3510客户端音频编解码库API参考》 P10
//afFormat pcm压缩格式 01 pcmalaw,
//afsize   除4字节头外的一帧音频流的大小(字节单位)
//afNum    该缓冲区中包含多少帧音频流
void GetHISIAudioFrameInfo(const unsigned char* fbuf,int bufLen,int *afFormat,int *afSize,int *afNum,int blflag)
{
    unsigned char* buf = (unsigned char*)fbuf;
    if (G711_BIG_ENDIAN==blflag)
    {
        *afFormat = (int)buf[1];
        *afSize  =  2*(int)buf[2];
        *afNum   =  (bufLen/(*afSize+4));
    }
    else
    {
        *afFormat = (int)buf[0];;
        *afSize  =  2*(int)buf[3];;
        *afNum   =  (bufLen/(*afSize+4));
    }
}

//unsigned char standBuffer[800];
//把海思的G711音频数据解码成标准的PCM数据
//转换后pcm数据至少是原始g711数据的2倍
int G711ABuf2PCMBuf_HISI(unsigned char* pcmBuf,int pcmBufLen,const unsigned char* g711Buf,int g711BufLen,int blflag)
{
    //    int afFormat=0,afSize=0,afNum=0;
    //    unsigned char* tmpHiSiBuf = 0X0L;
    //    unsigned char* tmpStandBuf= 0X0L;
    //    int standBufLen =0;
    //    int i=0;
    //    int rlen=0;
    //
    //    //分析HISIbuffer的头信息
    //    GetHISIAudioFrameInfo((const unsigned char*)g711Buf,g711BufLen,&afFormat,&afSize,&afNum,blflag);
    //
    //    //转换成正常的g711数据流
    //    standBufLen = afSize*afNum;
    //
    //    tmpHiSiBuf = (unsigned char*)g711Buf;
    //    tmpStandBuf = standBuffer;
    //    for ( i=0;i<afNum;i++)
    //    {
    //        memcpy(tmpStandBuf,&tmpHiSiBuf[4],afSize);
    //        tmpHiSiBuf  += (afSize+4);
    //        tmpStandBuf += afSize;
    //    }
    //
    //    //将标准g711数据解码成PCM数据
    //    rlen=G7112LinnerPCM((unsigned char*)pcmBuf,pcmBufLen,(const unsigned char*)standBuffer,standBufLen);
    
    int rlen=G7112LinnerPCM((unsigned char*)pcmBuf,pcmBufLen,g711Buf+4,g711BufLen-4);
    
    return rlen;
}

//把PCM数据编码成海思标准格式的G711数据
//转换后g711数据数据至少是原始g711数据的1/2
int PCMBuf2G711ABuf_HISI(unsigned char* g711Buf,int g711BufLen,const unsigned char* pcmBuf,int pcmBufLen,int blflag)
{
    //编码pcm成标准的g711数据
    int standG711Len = LinnerPCM2G711(g711Buf+4,g711BufLen,(const unsigned char*)pcmBuf,pcmBufLen);
    
    //生成海思的g711数据头
    if (G711_BIG_ENDIAN==blflag)
    {
        g711Buf[1] = 0x01;
        g711Buf[2] = standG711Len*0.5;
    }
    
    return standG711Len+4;
}

/*
 * This source code is a product of Sun Microsystems, Inc. and is provided
 * for unrestricted use.  Users may copy or modify this source code without
 * charge.
 *
 * SUN SOURCE CODE IS PROVIDED AS IS WITH NO WARRANTIES OF ANY KIND INCLUDING
 * THE WARRANTIES OF DESIGN, MERCHANTIBILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE, OR ARISING FROM A COURSE OF DEALING, USAGE OR TRADE PRACTICE.
 *
 * Sun source code is provided with no support and without any obligation on
 * the part of Sun Microsystems, Inc. to assist in its use, correction,
 * modification or enhancement.
 *
 * SUN MICROSYSTEMS, INC. SHALL HAVE NO LIABILITY WITH RESPECT TO THE
 * INFRINGEMENT OF COPYRIGHTS, TRADE SECRETS OR ANY PATENTS BY THIS SOFTWARE
 * OR ANY PART THEREOF.
 *
 * In no event will Sun Microsystems, Inc. be liable for any lost revenue
 * or profits or other special, indirect and consequential damages, even if
 * Sun has been advised of the possibility of such damages.
 *
 * Sun Microsystems, Inc.
 * 2550 Garcia Avenue
 * Mountain View, California  94043
 */

/*
 * g711.c
 *
 * u-law, A-law and linear PCM conversions.
 */


#define	SIGN_BIT	(0x80)		/* Sign bit for a A-law byte. */
#define	QUANT_MASK	(0xf)		/* Quantization field mask. */
#define	NSEGS		(8)		/* Number of A-law segments. */
#define	SEG_SHIFT	(4)		/* Left shift for segment number. */
#define	SEG_MASK	(0x70)		/* Segment field mask. */
#define	BIAS		(0x84)		/* Bias for linear code. */

static short seg_end[8] = {0xFF, 0x1FF, 0x3FF, 0x7FF,0xFFF, 0x1FFF, 0x3FFF, 0x7FFF};

/* copy from CCITT G.711 specifications */
unsigned char _u2a[128] = {			/* u- to A-law conversions */
    1,	1,	2,	2,	3,	3,	4,	4,
    5,	5,	6,	6,	7,	7,	8,	8,
    9,	10,	11,	12,	13,	14,	15,	16,
    17,	18,	19,	20,	21,	22,	23,	24,
    25,	27,	29,	31,	33,	34,	35,	36,
    37,	38,	39,	40,	41,	42,	43,	44,
    46,	48,	49,	50,	51,	52,	53,	54,
    55,	56,	57,	58,	59,	60,	61,	62,
    64,	65,	66,	67,	68,	69,	70,	71,
    72,	73,	74,	75,	76,	77,	78,	79,
    81,	82,	83,	84,	85,	86,	87,	88,
    89,	90,	91,	92,	93,	94,	95,	96,
    97,	98,	99,	100,	101,	102,	103,	104,
    105,	106,	107,	108,	109,	110,	111,	112,
    113,	114,	115,	116,	117,	118,	119,	120,
    121,	122,	123,	124,	125,	126,	127,	128};

unsigned char _a2u[128] = {			/* A- to u-law conversions */
    1,	3,	5,	7,	9,	11,	13,	15,
    16,	17,	18,	19,	20,	21,	22,	23,
    24,	25,	26,	27,	28,	29,	30,	31,
    32,	32,	33,	33,	34,	34,	35,	35,
    36,	37,	38,	39,	40,	41,	42,	43,
    44,	45,	46,	47,	48,	48,	49,	49,
    50,	51,	52,	53,	54,	55,	56,	57,
    58,	59,	60,	61,	62,	63,	64,	64,
    65,	66,	67,	68,	69,	70,	71,	72,
    73,	74,	75,	76,	77,	78,	79,	79,
    80,	81,	82,	83,	84,	85,	86,	87,
    88,	89,	90,	91,	92,	93,	94,	95,
    96,	97,	98,	99,	100,	101,	102,	103,
    104,	105,	106,	107,	108,	109,	110,	111,
    112,	113,	114,	115,	116,	117,	118,	119,
    120,	121,	122,	123,	124,	125,	126,	127};

static int search( int val,  short *table, int size);

static int
search(
       int		val,
       short		*table,
       int		size)
{
	int		i;
    
	for (i = 0; i < size; i++) {
		if (val <= *table++)
			return (i);
	}
	return (size);
}

/*
 * linear2alaw() - Convert a 16-bit linear PCM value to 8-bit A-law
 *
 * linear2alaw() accepts an 16-bit integer and encodes it as A-law data.
 *
 *		Linear Input Code	Compressed Code
 *	------------------------	---------------
 *	0000000wxyza			000wxyz
 *	0000001wxyza			001wxyz
 *	000001wxyzab			010wxyz
 *	00001wxyzabc			011wxyz
 *	0001wxyzabcd			100wxyz
 *	001wxyzabcde			101wxyz
 *	01wxyzabcdef			110wxyz
 *	1wxyzabcdefg			111wxyz
 *
 * For further information see John C. Bellamy's Digital Telephony, 1982,
 * John Wiley & Sons, pps 98-111 and 472-476.
 */
unsigned char
linear2alaw(
            int		pcm_val)	/* 2's complement (16-bit range) */
{
	int		mask;
	int		seg;
	unsigned char	aval;
    
	if (pcm_val >= 0) {
		mask = 0xD5;		/* sign (7th) bit = 1 */
	} else {
		mask = 0x55;		/* sign bit = 0 */
		pcm_val = -pcm_val - 8;
	}
    
	/* Convert the scaled magnitude to segment number. */
	seg = search(pcm_val, seg_end, 8);
    
	/* Combine the sign, segment, and quantization bits. */
    
	if (seg >= 8)		/* out of range, return maximum value. */
		return (0x7F ^ mask);
	else {
		aval = seg << SEG_SHIFT;
		if (seg < 2)
			aval |= (pcm_val >> 4) & QUANT_MASK;
		else
			aval |= (pcm_val >> (seg + 3)) & QUANT_MASK;
		return (aval ^ mask);
	}
}

/*
 * alaw2linear() - Convert an A-law value to 16-bit linear PCM
 *
 */
int
alaw2linear(
            unsigned char	a_val)
{
	int		t;
	int		seg;
    
	a_val ^= 0x55;
    
	t = (a_val & QUANT_MASK) << 4;
	seg = ((unsigned)a_val & SEG_MASK) >> SEG_SHIFT;
	switch (seg) {
        case 0:
            t += 8;
            break;
        case 1:
            t += 0x108;
            break;
        default:
            t += 0x108;
            t <<= seg - 1;
	}
	return ((a_val & SIGN_BIT) ? t : -t);
}



/*
 * linear2ulaw() - Convert a linear PCM value to u-law
 *
 * In order to simplify the encoding process, the original linear magnitude
 * is biased by adding 33 which shifts the encoding range from (0 - 8158) to
 * (33 - 8191). The result can be seen in the following encoding table:
 *
 *	Biased Linear Input Code	Compressed Code
 *	------------------------	---------------
 *	00000001wxyza			000wxyz
 *	0000001wxyzab			001wxyz
 *	000001wxyzabc			010wxyz
 *	00001wxyzabcd			011wxyz
 *	0001wxyzabcde			100wxyz
 *	001wxyzabcdef			101wxyz
 *	01wxyzabcdefg			110wxyz
 *	1wxyzabcdefgh			111wxyz
 *
 * Each biased linear code has a leading 1 which identifies the segment
 * number. The value of the segment number is equal to 7 minus the number
 * of leading 0's. The quantization interval is directly available as the
 * four bits wxyz.  * The trailing bits (a - h) are ignored.
 *
 * Ordinarily the complement of the resulting code word is used for
 * transmission, and so the code word is complemented before it is returned.
 *
 * For further information see John C. Bellamy's Digital Telephony, 1982,
 * John Wiley & Sons, pps 98-111 and 472-476.
 */
unsigned char
linear2ulaw(
            int		pcm_val)	/* 2's complement (16-bit range) */
{
	int		mask;
	int		seg;
	unsigned char	uval;
    
	/* Get the sign and the magnitude of the value. */
	if (pcm_val < 0) {
		pcm_val = BIAS - pcm_val;
		mask = 0x7F;
	} else {
		pcm_val += BIAS;
		mask = 0xFF;
	}
    
	/* Convert the scaled magnitude to segment number. */
	seg = search(pcm_val, seg_end, 8);
    
	/*
	 * Combine the sign, segment, quantization bits;
	 * and complement the code word.
	 */
	if (seg >= 8)		/* out of range, return maximum value. */
		return (0x7F ^ mask);
	else {
		uval = (seg << 4) | ((pcm_val >> (seg + 3)) & 0xF);
		return (uval ^ mask);
	}
    
}

/*
 * ulaw2linear() - Convert a u-law value to 16-bit linear PCM
 *
 * First, a biased linear code is derived from the code word. An unbiased
 * output can then be obtained by subtracting 33 from the biased code.
 *
 * Note that this function expects to be passed the complement of the
 * original code word. This is in keeping with ISDN conventions.
 */
int
ulaw2linear(
            unsigned char	u_val)
{
	int		t;
    
	/* Complement to obtain normal u-law value. */
	u_val = ~u_val;
    
	/*
	 * Extract and bias the quantization bits. Then
	 * shift up by the segment number and subtract out the bias.
	 */
	t = ((u_val & QUANT_MASK) << 3) + BIAS;
	t <<= ((unsigned)u_val & SEG_MASK) >> SEG_SHIFT;
    
	return ((u_val & SIGN_BIT) ? (BIAS - t) : (t - BIAS));
}

/* A-law to u-law conversion */
unsigned char
alaw2ulaw(
          unsigned char	aval)
{
	aval &= 0xff;
	return ((aval & 0x80) ? (0xFF ^ _a2u[aval ^ 0xD5]) :
            (0x7F ^ _a2u[aval ^ 0x55]));
}

/* u-law to A-law conversion */
unsigned char
ulaw2alaw(
          unsigned char	uval)
{
	uval &= 0xff;
	return ((uval & 0x80) ? (0xD5 ^ (_u2a[0xFF ^ uval] - 1)) :
            (0x55 ^ (_u2a[0x7F ^ uval] - 1)));
}

//转换后PCM buf的长度为g711buf的2倍,缓冲区由调用者负责分配和释放
int G7112LinnerPCM(unsigned char* pcmBuf,int pcmBufLen,const unsigned char* g711Buf,int g711BufLen)
{
    int i=0;
    short* pbuf =(short*)pcmBuf;
    
    if(pcmBuf==0x0L || g711Buf ==0x0L)return-1;
    if(pcmBufLen < 2*g711BufLen)return-1;
    
    for (i=0;i<g711BufLen;i++)
    {
        pbuf[i]=alaw2linear(g711Buf[i]);
    }
    return 2*g711BufLen;
}
//转换后g711buf的长度为PCM buf的1/2,缓冲区由调用者负责分配和释放
int LinnerPCM2G711(unsigned char* g711Buf,int g711BufLen,const unsigned char* pcmBuf,int pcmBufLen)
{
    int i=0;
    short* pbuf =(short*)pcmBuf;
    
    if(pcmBuf==0x0L || g711Buf ==0x0L)return-1;
    if(g711BufLen < pcmBufLen/2) return-1;
    
    for (i=0;i<pcmBufLen/2;i++)
    {
        g711Buf[i] = linear2alaw(pbuf[i]);
    }
    return pcmBufLen/2;
}
