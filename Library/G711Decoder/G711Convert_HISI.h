#ifndef _G711_CONVERT_HISI_H
#define _G711_CONVERT_HISI_H



#define G711_BIG_ENDIAN    1
#define G711_LITTLE_ENDIAN 0
//海思一帧音频数据的大小;单位是short，换算成字节时需*2
#define FIX_HISI_AUDIO_FRAME_SIZE 0xA0

/**获取海思音频数据中的音频帧信息（字节单位）
 *参考海思的文档《hi3510客户端音频编解码库API参考》 P10
 *afFormat pcm压缩格式 01 pcmalaw,
 *afsize   除4字节头外的一帧音频流的大小(字节单位)
 *afNum    该缓冲区中包含多少帧音频流
 */
void GetHISIAudioFrameInfo(const unsigned char* fbuf,int bufLen,int *afFormat,int *afSize,int *afNum,int blflag);

//把标准的g711a数据打包成hisi格式的音频帧流
int PacketG711A_HISI(unsigned char* hisiBuf,int hisiBufLen,const unsigned char* g711Buf,int g711BufLen,int blflag);

//把海思格式的音频帧流解包成标准的g711a流
int UnPacketG711A_HISI(unsigned char* g711Buf,int g711BufLen,const unsigned char* hisiBuf,int hisiBufLen,int blflag);

/**
 *把海思的G711音频数据解码成标准的PCM数据
 *转换后pcm数据至少是原始g711数据的2倍
 *返回解码后的数据长度
 *blflag :大端、小端标示，默认取BIG_ENDIAN
 */
int G711ABuf2PCMBuf_HISI(unsigned char* pcmBuf,int pcmBufLen,const unsigned char* g711Buf,int g711BufLen,int blflag);

/**把PCM数据编码成海思标准格式的G711数据
 *转换后g711数据数据至少是原始g711数据的1/2
 *返回编码后的数据长度
 *blflag :大端、小端标示，默认取BIG_ENDIAN
 */
int PCMBuf2G711ABuf_HISI(unsigned char* g711Buf,int g711BufLen,const unsigned char* pcmBuf,int pcmBufLen,int blflag);
#endif