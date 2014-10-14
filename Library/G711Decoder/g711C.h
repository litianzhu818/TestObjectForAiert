



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
//int G711ABuf2PCMBuf_HISI(unsigned char* pcmBuf,int pcmBufLen,const unsigned char* g711Buf,int g711BufLen,int blflag);

/**把PCM数据编码成海思标准格式的G711数据
 *转换后g711数据数据至少是原始g711数据的1/2
 *返回编码后的数据长度
 *blflag :大端、小端标示，默认取BIG_ENDIAN
 */
int PCMBuf2G711ABuf_HISI(unsigned char* g711Buf,int g711BufLen,const unsigned char* pcmBuf,int pcmBufLen,int blflag);
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
unsigned char linear2alaw(int pcm_val);

/*
 * alaw2linear() - Convert an A-law value to 16-bit linear PCM
 *
 */
int alaw2linear(unsigned char a_val);


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
unsigned char linear2ulaw(int pcm_val);

/*
 * ulaw2linear() - Convert a u-law value to 16-bit linear PCM
 *
 * First, a biased linear code is derived from the code word. An unbiased
 * output can then be obtained by subtracting 33 from the biased code.
 *
 * Note that this function expects to be passed the complement of the
 * original code word. This is in keeping with ISDN conventions.
 */
int ulaw2linear(unsigned char	u_val);

/* A-law to u-law conversion */
unsigned char alaw2ulaw(unsigned char aval);

/* u-law to A-law conversion */
unsigned char ulaw2alaw(unsigned char	uval);

//转换后PCM buf的长度为g711buf的2倍,缓冲区由调用者负责分配和释放
//返回转换成功的字节数
int G7112LinnerPCM(unsigned char* pcmBuf,int pcmBufLen,const unsigned char* g711Buf,int g711BufLen);
//转换后g711buf的长度为PCM buf的1/2,缓冲区由调用者负责分配和释放
//返回转换成功的字节数
int LinnerPCM2G711(unsigned char* g711Buf,int g711BufLen,const unsigned char* pcmBuf,int pcmBufLen);