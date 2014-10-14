#ifndef __P2PCLIENT_H__
#define __P2PCLIENT_H__

#include "Stream.h"

class CP2PClient : public BasicThread
{
public:
	CP2PClient();
	~CP2PClient();

	static bool InitZSip(const std::string & slParams, zsip_msg_cb zsip_msg_cb);
	static void ReleaseZSip();

	bool Init(IEvents& Events);

	bool IsUPNPSupport(const std::string& strDeviceId, void * pCookie = NULL);

	bool RealPlay(const std::string& strDeviceId, int iChannel, int iMediaType, int iMode, void * pCookie = NULL);
	void StopRealPlay();

	bool ChangeStream(int iChannel, int iNewMediaType, int operation);

	bool EnableSound(bool bOpen = false);
	bool EnableTalk(bool bTalk = false);
	bool SendTalkData(char* data, unsigned size = 164);

	bool EnableDVRTalk(bool bOpen = false);

	bool SendDVRTalkData(char* data, unsigned size = 164);
	bool SendData(char* data, unsigned size);
	bool PlayBack(const std::string& strDeviceId, int iChannel, int iMode, const std::string& strDateTime, void* pCookie = NULL);

	bool LoginUPNP(const std::string& strUserName, const std::string& strPassWord);
	bool ChangePwdUPNP(const std::string& strUserName, const std::string& strPassWord);

	bool QueryNatType();	// For Test

	static bool UpdateZSipDNS(unsigned count, SIP_DNS* sip_dns);

	bool PTZConfig(PTZ_CMD_E ptz_cmd, unsigned short para0, unsigned short para1);
	bool GetPTZPreset();

protected:
	static bool KeepAlive();
	static bool ReBuildKeepAlive();
	void DoWork();

private:
	static int worker_thread(void* user_data);
	static z_bool_t msg_cb(zsip_method_e method_id, const char* method_name, void* data, int data_len, void* msg_handler);

	static void keep_alive_timer_cb(int id, void* user_data);
	static void keep_alive_cb(z_status_t status, int code, void* response, int len, void* user_data);

	static void p2p_cb(int code, z_ice_strans* icest, char* param, zsip_addr_pair* addr_pair, int pair_cnt, void* user_data);
	static void transit_cb(z_status_t status, int code, void* response, int len, void* user_data);
	static void upnp_cb(z_status_t status, int code, void* response, int len, void* user_data);

	static void p2p_nat_detect_cb(const z_nat_detect_result* res, void* user_data);

	static unsigned long GetReqId(bool bIncrease = false);
	static bool InitStaticParams(const std::string& slParams, zsip_msg_cb cb);
protected:
	static CSipParams m_sip_params;
	CUserData* m_pUserData;

	IEvents* m_pEvents;
	static unsigned long m_reqid;

	ZCRIT m_lock_rp;
	std::map<unsigned long, CUserData*> m_rp;
	std::list<unsigned long> m_rp_erase;
	typedef std::map<unsigned long, CUserData*>::iterator iter_rp;

	int AddRequest(CUserData* data);
	bool CheckRequest();
	bool ClearRequest();
	void DelAllRequst();
};

#endif //__P2PCLIENT_H__
