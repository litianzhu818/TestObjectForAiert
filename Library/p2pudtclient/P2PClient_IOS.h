#ifndef __P2PCLIENT_IOS_H__
#define __P2PCLIENT_IOS_H__

#include "P2PClient.h"
#include <string>

typedef void(* fpReport)(int iType, int iStatus, const char* pText, void* pCookie);
typedef void(* fpFrameData)(int iType, char* pData, int iSize, void* pCookie);

class CP2PClientWarp : public IEvents
{
public:
	CP2PClientWarp(void) {}
	~CP2PClientWarp(void) {}

	bool Init(fpReport pCBReport, fpFrameData pCBFrameData);

	bool IsUPNPSupport(const std::string& strDeviceId, void* pCookie = NULL);

	bool RealPlay(const std::string& strDeviceId, int iChannel, int iMediaType, int iMode, void* pCookie = NULL);
	void StopRealPlay();

	bool ChangeStream(int iChannel, int iNewMediaType, int operation);

	bool EnableSound(bool bOpen = false);
	bool EnableTalk(bool bTalk = false);
	bool SendTalkData(char* data, unsigned size = 164);
	bool EnableDVRTalk(bool bOpen = false);
	
	bool SendDVRTalkData(char* data, unsigned size = 164);
    
	bool SendData(char* data, unsigned size);
	bool PlayBack(const std::string& strDeviceId, int iChannel, int iMode, std::string& strDateTime, void* pCookie = NULL);

	bool LoginUPNP(const std::string& userName, const std::string& passWord);
	bool ChangePwdUPNP(const std::string& userName, const std::string& passWord);

	bool PTZConfig(PTZ_CMD_E ptz_cmd, unsigned short para0, unsigned short para1);
	bool GetPTZPreset();
	
private:
	void OnStatusReport(int iType, int iStatus, const char* pText, void* pCookie = NULL);
	void OnFrameData(int iType, char* pData, int iSize, void* pCookie = NULL);
	fpReport m_pCBReport;
	fpFrameData m_pCBFrameData;
	CP2PClient m_p2pclient;
};

#endif /*__P2PCLIENT_IOS_H__*/

