#ifndef __STREAM_H__
#define __STREAM_H__

#include "ZUtility.h"
#include "protocol.h"

class Stream;
class CUserData
{
public:
	CUserData() {}
	~CUserData() {}
	unsigned long reqid;
	void * pCookie;
	void * pUserCookie;
	proto_req type;
	uint64_t msTimeStamp;
	int status;
	ZCRIT m_lock_req;

	std::string m_strDeviceId;
	int m_iChannel;
	int m_iMediaType;
	Stream* m_Stream;
	std::string m_strDateTime;
	IEvents* m_pEvents;
};

class Stream : public BasicThread
{
public:
	explicit Stream(int connect_type);
	virtual ~Stream(void);

	bool Init(IEvents* pEvents, CUserData * pHandle, const char * tokenid, 
			uint64_t streamTimeout, uint64_t streamKeepAlive, uint64_t sLoginTimeout);

	virtual bool OpenStream(const char* r_IP, int r_port, const char* base_ip = NULL, int base_port = 0) = 0;
	virtual void CloseStream() = 0;
	virtual bool SendBuf(char * data, unsigned size) = 0;
	virtual int OnKeepalive() = 0;				// 心跳

	// 语音、对讲
	bool ReqSound(int channel, bool bOpen);
	bool ReqTalk(int channel, bool bOpen);

	// 中转请求指令
	virtual bool ReqLogin(const char * register_code, const char * username_or_sn) = 0;

	// P2P 需要支持的命令
	virtual bool ReqStream(int iChannel, int iMediaType, int operation) = 0;

	// 回放请求
	bool ReqPlayback(const char* strDate, int channel);

	// PTZ
	bool ReqPTZConfig(PTZ_CMD_E ptz_cmd, unsigned short para0, unsigned short para1);
	bool ReqPTZPreset();

	int GetConnectMode() const
	{
		return m_connect_type;
	}
protected:
	static int32_t GetMsgNo()
	{
		++m_iMsgNo;
		if (m_iMsgNo == 0xEFFFFFFF)
			m_iMsgNo = 1;
		return m_iMsgNo;
	}

	virtual void DoWork();

	CUserData* m_pHandle;
	IEvents* m_pEvents;
	char m_sTokenid[64];

	static int32_t m_iMsgNo;			// message number
	int m_connect_type;

protected:
	int ParseStreamUnit(char * ppBuf, unsigned & buff_len);		// 解析单元包
	int ParseCmd(char * pCmd, int len);
private:

	bool CheckRecvDataTimeout();
	bool CheckLoginTimeout();
	bool CheckChangeStreamTimeout();
	void NotifyStreamTimeout();

	char m_Framebuf[MAX_FRAME_SIZE];
	unsigned m_FrameLen;

protected:	// 收数据线程

	virtual void OnRecv() = 0;
	bool m_bStop;

	ZCRIT m_lock_recv_status;
	uint64_t m_last_recv_data_time;
	uint64_t m_stream_create_time;

	ZCRIT m_stream_change_status;
	uint64_t m_stream_change_time;

	ZCRIT m_stream_login_status;
	uint64_t m_stream_login_time;

	uint64_t m_streamTimeout;
	uint64_t m_streamKeepAlive;
	uint64_t m_sLoginTimeout;

#ifndef WIN32
	static void * ThreadRecvStream(void* param)
#else
	static DWORD WINAPI ThreadRecvStream(LPVOID param)
#endif 
	{
		Stream *p = (Stream*)param;
		p->OnRecv();
		return 0;
	}

	volatile bool m_bClosing;
	pthread_mutex_t m_StopLock;
	pthread_cond_t m_StopCond;
	pthread_t m_Thread;
	bool m_bStatus;

	bool m_bSoundOpen;
	bool m_bTalkOpen;

public:

	#define CRYPT_KEY		"PeterLee2014"
	static bool ZmdEnCrypt(char* src, char* key = CRYPT_KEY);
	static bool ZmdDeCrypt(char* crypt, char* key = CRYPT_KEY);
	bool LoginUPNP(const char* userName, const char* passWord);
	bool ChangePwdUPNP(const char* userName, const char* passWord);
};

#endif /*__STREAM_H__*/

