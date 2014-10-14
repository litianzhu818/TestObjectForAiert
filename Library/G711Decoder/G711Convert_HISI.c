//#include <stdio.h>
//#include <stdlib.h>
#include "string.h"
#include "g711.h"
#include "G711Convert_HISI.h"

////把标准的g711a数据打包成hisi格式的音频帧流
//int PacketG711A_HISI(unsigned char* hisiBuf,int hisiBufLen,const unsigned char* g711Buf,int g711BufLen,int blflag)
//{
//    int afFormat=0,afSize=0,afNum=0;
////    int standBufLen = g711BufLen;
////    unsigned char* fStandBuf = 0x0L;
//    unsigned char* tmpHiSiBuf = 0X0L;
//    unsigned char* tmpStandBuf= 0X0L;
//    unsigned char hisiHead[4]={0};
//    int i=0;
//    int rlen=0;
//    
//    afFormat =0x01;
//    afSize = FIX_HISI_AUDIO_FRAME_SIZE;
//    afNum = (g711BufLen)/FIX_HISI_AUDIO_FRAME_SIZE;
//    
//    //生成海思的g711数据头
//    if (G711_BIG_ENDIAN==blflag)
//    {
//        hisiHead[1]=afFormat;
//        hisiHead[2]=afSize;
//    }
//    else
//    {
//        hisiHead[0]=afFormat;
//        hisiHead[3]=afSize;
//    }
//    
//    //拆分标准g711数据成海思音频帧格式
//    tmpHiSiBuf = hisiBuf;
//    tmpStandBuf = (unsigned char*)g711Buf;
//    
//    for (i=0;i<afNum;i++)
//    {
//        //copy 头部信息
//        memcpy(tmpHiSiBuf,&hisiHead[0],4);
//        //copy 音频帧信息
//        memcpy(&tmpHiSiBuf[4],&tmpStandBuf,afSize*2);
//        tmpHiSiBuf  += (afSize*2+4);
//        tmpStandBuf += afSize*2;
//    }
//    
//    rlen = afNum*(afSize*2+4);
//    
//    return rlen;
//}
//
////把海思格式的音频帧流解包成标准的g711a流
//int UnPacketG711A_HISI(unsigned char* g711Buf,int g711BufLen,const unsigned char* hisiBuf,int hisiBufLen,int blflag)
//{
//    int afFormat=0,afSize=0,afNum=0;
////    unsigned char* fStandBuf = 0X0L;
//    unsigned char* tmpHiSiBuf = 0X0L;
//    unsigned char* tmpStandBuf= 0X0L;
//    int standBufLen =0;
//    int i=0;
////    int rlen=0;
//    //分析HISIbuffer的头信息
//    GetHISIAudioFrameInfo((const unsigned char*)hisiBuf,hisiBufLen,&afFormat,&afSize,&afNum,blflag);
//    
//    //转换成正常的g711数据流
//    standBufLen = afSize*afNum;
//    
//    tmpHiSiBuf = (unsigned char*)hisiBuf;
//    tmpStandBuf = g711Buf;
//    for ( i=0;i<afNum;i++)
//    {
//        memcpy(tmpStandBuf,&tmpHiSiBuf[4],afSize);
//        tmpHiSiBuf  += (afSize+4);
//        tmpStandBuf += afSize;
//    }
//    return standBufLen;
//}
//
//
////获取海思音频数据中的音频帧信息（字节单位）
////参考海思的文档《hi3510客户端音频编解码库API参考》 P10
////afFormat pcm压缩格式 01 pcmalaw,
////afsize   除4字节头外的一帧音频流的大小(字节单位)
////afNum    该缓冲区中包含多少帧音频流
//void GetHISIAudioFrameInfo(const unsigned char* fbuf,int bufLen,int *afFormat,int *afSize,int *afNum,int blflag)
//{
//    unsigned char* buf = (unsigned char*)fbuf;
//    if (G711_BIG_ENDIAN==blflag)
//    {
//        *afFormat = (int)buf[1];
//        *afSize  =  2*(int)buf[2];
//        *afNum   =  (bufLen/(*afSize+4));
//    }
//    else
//    {
//        *afFormat = (int)buf[0];;
//        *afSize  =  2*(int)buf[3];;
//        *afNum   =  (bufLen/(*afSize+4));
//    }
//}

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
