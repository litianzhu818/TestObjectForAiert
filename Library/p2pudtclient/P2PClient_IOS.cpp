#include "P2PClient_IOS.h"

void CP2PClientWarp::OnStatusReport(int iType, int iStatus, const char* pText, void* pCookie)
{
	if (m_pCBReport)
		m_pCBReport(iType, iStatus, pText, pCookie);
}

void CP2PClientWarp::OnFrameData(int iType, char* pData, int iSize, void* pCookie)
{
	if (m_pCBFrameData)
		m_pCBFrameData(iType, pData, iSize, pCookie);
}

bool CP2PClientWarp::Init(fpReport pCBReport, fpFrameData pCBFrameData)
{
	m_pCBReport = pCBReport;
	m_pCBFrameData = pCBFrameData;
	return m_p2pclient.Init(*this);
}

bool CP2PClientWarp::IsUPNPSupport(const std::string& strDeviceId, void* pCookie)
{
	return m_p2pclient.IsUPNPSupport(strDeviceId, pCookie);
}

bool CP2PClientWarp::RealPlay(const std::string& strDeviceId, int iChannel, int iMediaType, int iMode, void* pCookie)
{
	return m_p2pclient.RealPlay(strDeviceId, iChannel, iMediaType, iMode, pCookie);
}

void CP2PClientWarp::StopRealPlay()
{
	m_p2pclient.StopRealPlay();
}

bool CP2PClientWarp::ChangeStream(int iChannel, int iNewMediaType, int operation)
{
	return m_p2pclient.ChangeStream(iChannel, iNewMediaType, operation);
}

bool CP2PClientWarp::EnableSound(bool bOpen)
{
	return m_p2pclient.EnableSound(bOpen);
}

bool CP2PClientWarp::EnableTalk(bool bTalk)
{
	return m_p2pclient.EnableTalk(bTalk);
}

bool CP2PClientWarp::SendTalkData(char* data, unsigned size /*= 164*/)
{
	return m_p2pclient.SendTalkData(data, size);
}

bool CP2PClientWarp::EnableDVRTalk(bool bOpen)
{
	return m_p2pclient.EnableDVRTalk(bOpen);
}

bool CP2PClientWarp::SendDVRTalkData(char* data, unsigned size /*= 164*/)
{
	return m_p2pclient.SendDVRTalkData(data, size);
}

bool CP2PClientWarp::SendData(char* data, unsigned size)
{
	return m_p2pclient.SendData(data, size);
}

bool CP2PClientWarp::PlayBack(const std::string& strDeviceId, int iChannel, int iMode, std::string& strDateTime, void* pCookie)
{
	return m_p2pclient.PlayBack(strDeviceId, iChannel, iMode, strDateTime, pCookie);
}

bool CP2PClientWarp::LoginUPNP(const std::string& userName, const std::string& passWord)
{
	return m_p2pclient.LoginUPNP(userName, passWord);
}

bool CP2PClientWarp::ChangePwdUPNP(const std::string& userName, const std::string& passWord)
{
	return m_p2pclient.ChangePwdUPNP(userName, passWord);
}

bool CP2PClientWarp::PTZConfig(PTZ_CMD_E ptz_cmd, unsigned short para0, unsigned short para1)
{
	return m_p2pclient.PTZConfig(ptz_cmd, para0, para1);
}

bool CP2PClientWarp::GetPTZPreset()
{
	return m_p2pclient.GetPTZPreset();
}