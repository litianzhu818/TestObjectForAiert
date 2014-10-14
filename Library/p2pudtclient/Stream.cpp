#include "Stream.h"
int32_t Stream::m_iMsgNo = 0;

Stream::Stream(int connect_type)
: m_pHandle(NULL)
, m_pEvents(NULL)
, m_FrameLen(0)
, m_last_recv_data_time(0)
, m_stream_create_time(0)
, m_stream_change_time(0)
, m_stream_login_time(0)
, m_streamTimeout(DEFAULT_STREAM_TIMEOUT)
, m_streamKeepAlive(DEFAULT_STREAM_KEEPALIVE)
, m_sLoginTimeout(DEFAULT_LOGIN_TIMEOUT)
, m_bClosing(false)
, m_StopLock()
, m_StopCond()
, m_Thread()
, m_bStatus(false)
, m_bSoundOpen(false)
, m_bTalkOpen(false)
, m_connect_type(connect_type)
{
}

Stream::~Stream(void)
{
}

bool Stream::Init(IEvents* pEvents, CUserData * pHandle, const char * tokenid, 
				  uint64_t streamTimeout, uint64_t streamKeepAlive, uint64_t sLoginTimeout)
{
	m_pEvents = pEvents;
	m_pHandle = pHandle;
	memset(m_sTokenid, 0, 64);
	strncpy(m_sTokenid, tokenid, sizeof(m_sTokenid));
	m_sTokenid[sizeof(m_sTokenid)-1] = '\0';
	m_streamTimeout = streamTimeout;
	m_streamKeepAlive = streamKeepAlive;
	m_sLoginTimeout = sLoginTimeout;
	return true;
}

void Stream::NotifyStreamTimeout()
{
	if (m_last_recv_data_time == m_stream_create_time)
	{
		if (m_pEvents)
		{
			if (GetConnectMode() == UPNP_MODE)
        m_pEvents->OnStatusReport(stStream, ssUPNPConnectFailed, "upnp recv first data timeout", m_pHandle->pUserCookie);
			else if (GetConnectMode() == P2P_MODE)
				m_pEvents->OnStatusReport(stStream, ssP2PConnectFailed, "p2p recv first data timeout", m_pHandle->pUserCookie);
			else if (GetConnectMode() == TRANSIT_MODE)
				m_pEvents->OnStatusReport(stStream, ssDeliverConnectFailed, "transit recv first data timeout", m_pHandle->pUserCookie);
		}
	}
	else
	{
		if (m_pEvents)
		{
			if (GetConnectMode() == UPNP_MODE)
				m_pEvents->OnStatusReport(stStream, ssUPNPConnectFailed, "upnp recv data timeout", m_pHandle->pUserCookie);
			else if (GetConnectMode() == P2P_MODE)
				m_pEvents->OnStatusReport(stStream, ssP2PRecvFailed, "p2p recv data timeout", m_pHandle->pUserCookie);
			else if (GetConnectMode() == TRANSIT_MODE)
				m_pEvents->OnStatusReport(stStream, ssDeliverRecvFailed, "transit recv data timeout", m_pHandle->pUserCookie);
		}
	}
}

// 声音开关请求
struct trans_msg_req_sound
{
	char status;
	char reserve[3];
	char link_id[32];
};

// 声音开关响应
struct trans_msg_resp_sound
{
	char status;
	char reserve[3];
};

bool Stream::ReqSound(int channel, bool bOpen)
{
	char szCmd[128] = {0};
	char *pCmd = szCmd;
	trans_msg_s *req_stream = (trans_msg_s*)pCmd;
	req_stream->magic = htonl(0xFFFF559F);
	req_stream->channel = channel;
	req_stream->cmd_type = 0;
	req_stream->cmd = htonl(PC_IPC_VOICE_STATUS_SYN);
	req_stream->seqnum = GetMsgNo();
	req_stream->length = htonl(sizeof(trans_msg_req_sound));

	trans_msg_req_sound *pBody = (trans_msg_req_sound*)(szCmd+sizeof(trans_msg_s));
	if (bOpen)
		pBody->status = 1;
	else
		pBody->status = 0;
	m_bSoundOpen = bOpen;

	return SendBuf((char*)&szCmd, sizeof(trans_msg_s)+sizeof(trans_msg_req_sound));
}

// 对讲开关请求
struct trans_msg_req_talk
{
	char status;
	char reserve[3];
	char tokenid[64];
};

// 对讲开关响应
struct trans_msg_resp_talk
{
	char status;
	char reserve[3];
	char tokenid[64];
};

bool Stream::ReqTalk(int channel, bool bOpen)
{
	char szCmd[128] = {0};
	char *pCmd = szCmd;
	trans_msg_s *req_stream = (trans_msg_s*)pCmd;
	req_stream->magic = htonl(0xFFFF559F);
	req_stream->channel = channel;
	req_stream->cmd_type = 0;
	req_stream->cmd = htonl(PC_IPC_TALK_STATUS_SYN);
	req_stream->seqnum = GetMsgNo();
	req_stream->length = htonl(sizeof(trans_msg_req_talk));

	trans_msg_req_talk *pBody = (trans_msg_req_talk*)(szCmd+sizeof(trans_msg_s));
	if (bOpen)
		pBody->status = 1;
	else
		pBody->status = 0;
	memcpy(pBody->tokenid, m_sTokenid, 64);
	m_bTalkOpen = bOpen;

	return SendBuf((char*)&szCmd, sizeof(trans_msg_s)+sizeof(trans_msg_req_talk));
}

struct trans_msg_req_playback
{
	char date[24];
	char link_id[32];
	int channel;
};

bool Stream::ReqPlayback(const char* strDate, int channel)
{
	char szCmd[128] = {0};
	char *pCmd = szCmd;
	trans_msg_s *req_stream = (trans_msg_s*)pCmd;
	req_stream->magic = htonl(0xFFFF559F);
	req_stream->cmd_type = 0;
	req_stream->cmd = htonl(PC_IPC_PLAYBACK_SYN);
	req_stream->seqnum = GetMsgNo();
	req_stream->length = htonl(sizeof(trans_msg_req_playback));

	trans_msg_req_playback *pBody = (trans_msg_req_playback*)(szCmd+sizeof(trans_msg_s));
	strcpy(pBody->date, strDate);
	pBody->channel = channel;
	return SendBuf((char*)&szCmd, sizeof(trans_msg_s)+sizeof(trans_msg_req_playback));
}

struct trans_msg_req_ptz_ctrl
{
	char channel;
	char reserve[2];
	char ptz_cmd;
	short para0;
	short para1;
	char tokenid[64];
};

struct trans_msg_resp_ptz_ctrl
{
	char result;
	char reserve[3];
	char tokenid[64];
};

bool Stream::ReqPTZConfig(PTZ_CMD_E ptz_cmd, unsigned short para0, unsigned short para1)
{
	char szCmd[128] = {0};
	char *pCmd = szCmd;
	trans_msg_s *req_stream = (trans_msg_s*)pCmd;
	req_stream->magic = htonl(0xFFFF559F);
	req_stream->cmd_type = 0;
	req_stream->cmd = htonl(PC_IPC_PTZ_SYN);
	req_stream->seqnum = GetMsgNo();
	req_stream->length = htonl(sizeof(trans_msg_req_ptz_ctrl));

	trans_msg_req_ptz_ctrl *pBody = (trans_msg_req_ptz_ctrl*)(szCmd+sizeof(trans_msg_s));
	pBody->ptz_cmd = ptz_cmd;
	pBody->para0 = para0;
	pBody->para1 = para1;
	memcpy(pBody->tokenid, m_sTokenid, strlen(m_sTokenid));

	return SendBuf((char*)&szCmd, sizeof(trans_msg_s)+sizeof(trans_msg_req_ptz_ctrl));
}

struct trans_msg_resp_ptz_preset
{
	char result;
	char reserve;
	char residence;
	char speed;
	char tokenid[64];
	int preset_point_num;
	//char * preset_point_info; // preset_point_num * 1 
};

bool Stream::ReqPTZPreset()
{
	char szCmd[128] = {0};
	char *pCmd = szCmd;
	trans_msg_s *req_stream = (trans_msg_s*)pCmd;
	req_stream->magic = htonl(0xFFFF559F);
	req_stream->cmd_type = 0;
	req_stream->cmd = htonl(PC_IPC_GET_PRESETPOINT_SYN);
	req_stream->seqnum = GetMsgNo();
	req_stream->length = htonl(sizeof(m_sTokenid));

	memcpy(szCmd+sizeof(trans_msg_s), m_sTokenid, strlen(m_sTokenid));
	return SendBuf(szCmd, sizeof(trans_msg_s)+sizeof(m_sTokenid));
}

const char crypt_mask[16] = "adce3ddfei833";
const char xor_mask[16] = ",,33df389df=3df";
bool Stream::ZmdEnCrypt(char* src, char* key)
{
	int srclen = strlen(src);
	int masklen = strlen(crypt_mask);
	int keylen = strlen(key);
	int xorlen = strlen(xor_mask);

	int i; 
	for( i=0; i<srclen; ++i ){
		src[i] = src[i] + crypt_mask[i%masklen];
	}

	for( i=0; i<srclen; ++i){
		src[i] = src[i] ^ xor_mask[i%xorlen];
	}

	for( i=0; i<srclen; ++i){
		src[i] = src[i] ^ key[i%keylen];
	}
	return true;
}

bool Stream::ZmdDeCrypt(char* crypt, char* key)
{
	int cryptlen = strlen(crypt);
	int masklen = strlen(crypt_mask);
	int keylen = strlen(key);
	int xorlen = strlen(xor_mask);

	int i;
	for( i=0; i<cryptlen; ++i ){
		crypt[i] = crypt[i] ^ key[i%keylen];
	}

	for( i=0; i<cryptlen; ++i ){
		crypt[i] = crypt[i] ^ xor_mask[i%xorlen];
	}

	for( i=0; i<cryptlen; ++i ){
		crypt[i] = crypt[i] - crypt_mask[i%masklen];
	}

	return true;
}

// UPNP 登陆、修改密码结构体
struct trans_msg_upnp_login_req_s
{
	char userName[16];
	char passWord[16];
	char tokenid[64];
};

// UPNP登录请求响应
struct trans_msg_upnp_login_resp_s
{
	int permit;
	int echo_code;
	char tokenid[64];
};

bool Stream::LoginUPNP(const char* userName, const char* passWord)
{
	char szCmd[128] = {0};
	char *pCmd = szCmd;
	trans_msg_s *req_stream = (trans_msg_s*)pCmd;
	req_stream->magic = htonl(0xFFFF559F);
	req_stream->cmd_type = 0;
	req_stream->cmd = htonl(PC_IPC_UPNP_LOGIN_SYN);
	req_stream->seqnum = GetMsgNo();
	req_stream->length = htonl(sizeof(trans_msg_upnp_login_req_s));

	trans_msg_upnp_login_req_s *pBody = (trans_msg_upnp_login_req_s*)(szCmd+sizeof(trans_msg_s));
	strcpy(pBody->userName, userName);
	strcpy(pBody->passWord, passWord);
	ZmdEnCrypt(pBody->userName);
	ZmdEnCrypt(pBody->passWord);

	memcpy(pBody->tokenid, m_sTokenid, 64);

	bool bLogining = false;
	{
		ZAutoCSLocker lock(&m_stream_login_status);
		if (m_stream_login_time == 0)
			m_stream_login_time = ZUtility::getTime();
		else
			bLogining = true;
	}

	if (!bLogining)
		return SendBuf((char*)&szCmd, sizeof(trans_msg_s)+sizeof(trans_msg_upnp_login_req_s));
	else
		return true;
}

// UPNP修改密码请求响应
struct trans_msg_upnp_change_pwd_resp_s
{
	int echo_code;
	char tokenid[64];
};

bool Stream::ChangePwdUPNP(const char* userName, const char* passWord)
{
	char szCmd[128] = {0};
	char *pCmd = szCmd;
	trans_msg_s *req_stream = (trans_msg_s*)pCmd;
	req_stream->magic = htonl(0xFFFF559F);
	req_stream->cmd_type = 0;
	req_stream->cmd = htonl(PC_IPC_UPNP_CHANGE_PWD_SYN);
	req_stream->seqnum = GetMsgNo();
	req_stream->length = htonl(sizeof(trans_msg_upnp_login_req_s));

	trans_msg_upnp_login_req_s *pBody = (trans_msg_upnp_login_req_s*)(szCmd+sizeof(trans_msg_s));
	strcpy(pBody->userName, userName);
	strcpy(pBody->passWord, passWord);

	ZmdEnCrypt(pBody->userName);
	ZmdEnCrypt(pBody->passWord);

	memcpy(pBody->tokenid, m_sTokenid, 64);
	return SendBuf((char*)&szCmd, sizeof(trans_msg_s)+sizeof(trans_msg_upnp_login_req_s));
}

const int HEAD_SIZE = sizeof(trans_msg_s);
int Stream::ParseStreamUnit(char* ppBuf, unsigned & buff_len)
{
	int ret = 0;

	char * buffer = ppBuf;
	bool bFind = false;
	bool bComplete = false;
	unsigned pos = 0;

	u_long flag = ntohl(0xFFFF559F);
	trans_msg_s * pHdr = NULL;

	while (1) // 循环解析
	{
		if (buff_len < HEAD_SIZE)
			break;
		for (pos=0; pos<buff_len-4; ++pos)
		{
			if (memcmp(buffer+pos, &flag, 4) == 0)
			{
				bFind = true;
				pHdr = (trans_msg_s*)(buffer+pos);
				if (buff_len-pos < ntohl(pHdr->length) + HEAD_SIZE) // 完整帧大小 = 数据大小 + 帧头大小
				{
					// 非完整帧
					bComplete = false;
					break;
				}
				else
				{
					bComplete = true;

					if (ntohl(pHdr->length) + HEAD_SIZE + m_FrameLen > MAX_FRAME_SIZE)
						memcpy(m_Framebuf, buffer+pos, ntohl(pHdr->length) + HEAD_SIZE);
					else
					{
						if (pHdr->cmd == ntohl(PC_IPC_TRANSFER_DATA))
						{
							m_lock_recv_status.Lock();
							m_last_recv_data_time = ZUtility::getTime();
							m_lock_recv_status.UnLock();

							printf("%d", pHdr->channel);

							ZAutoCSLocker lock(&m_stream_change_status);
							if (m_stream_change_time != 0)
							{
								m_FrameLen = 0;
							}
							else
							{
//								pHdr->channel = 1;
								memcpy(m_Framebuf+m_FrameLen,  buffer+pos+20, ntohl(pHdr->length));
								m_FrameLen += ntohl(pHdr->length);
                                
								//printf("%d \t", ntohl(pHdr->length));
                                
								int seqnum = ntohl(pHdr->seqnum);
								short slic_cnt = seqnum &0xffff;
								short slic_num = (seqnum &0xffff0000)>>16;
								if (slic_num+1 == slic_cnt)
								{
									if (m_pEvents)
									{
                                        m_pEvents->OnFrameData(0, m_Framebuf, m_FrameLen, m_pHandle->pUserCookie);
									}
									m_FrameLen = 0;
								}
							}
						}
						else
						{
							if (0 != ParseCmd(buffer+pos, ntohl(pHdr->length) + HEAD_SIZE))
							{
								return -1;
							}
						}
					}

					// 移动到下一帧帧头
					buff_len = buff_len - pos - (ntohl(pHdr->length) + HEAD_SIZE); 
					memmove(buffer, buffer+pos+ntohl(pHdr->length) + HEAD_SIZE, buff_len);
					break;
				}
			}
		}

		if (!bFind)
		{
			memmove(buffer, buffer+buff_len-sizeof(int), sizeof(int));
			buff_len = sizeof(int); // 丢弃旧数据，仅保留Flag大小
			break;
		}
		else
		{
			// 找到了帧头但是帧的数据不完整，等待新的数据到来再做解析
			if (!bComplete)
			{
				if (pos > 0)
				{
					buff_len = buff_len - pos; 
					memmove(buffer, buffer+pos, buff_len);
				}
				break;
			}
		}
	}

	return ret;	
}

int Stream::ParseCmd(char * pCmd, int len)
{
	trans_msg_s *ptrCmd = (trans_msg_s*)pCmd;
	int respcmd = htonl(ptrCmd->cmd);
	int resplen = htonl(ptrCmd->length);

	switch (respcmd)
	{
	case PC_TRANS_LOGIN_ACK:
		{
			ptrCmd->length;
			char res = pCmd[sizeof(trans_msg_s)];
			printf("\n PC_TRANS_LOGIN_ACK : %d \n", res);
			switch (res)
			{
			case 0:		// 设备在线，登陆成功
				if (m_pEvents && m_pHandle)
				{
					m_pEvents->OnStatusReport(stStream, ssDeliverConnectSucc, "register success", m_pHandle->pUserCookie);
					{
						ZAutoCSLocker lock(&m_pHandle->m_lock_req);
						if (m_pHandle->status == req_status_registering)
							m_pHandle->status = req_status_connected;
					}
					ZAutoCSLocker lock_recv_status(&m_lock_recv_status);
					m_last_recv_data_time = m_stream_create_time = ZUtility::getTime();
				}
				break;
			case 1:		// 登陆成功，设备不在线
				if (m_pEvents && m_pHandle)
				{
					m_pEvents->OnStatusReport(stStream, ssDeliverConnectSucc, "register success, but device not ready", m_pHandle->pUserCookie);
					{
						ZAutoCSLocker lock(&m_pHandle->m_lock_req);
						if (m_pHandle->status == req_status_registering)
							m_pHandle->status = req_status_connected;
					}

					ZAutoCSLocker lock_recv_status(&m_lock_recv_status);
					m_last_recv_data_time = m_stream_create_time = ZUtility::getTime();
				}
				break;
			case 2:		// 登陆失败
				if (m_pEvents && m_pHandle)
				{
					m_pEvents->OnStatusReport(stStream, ssDeliverConnectFailed, "register failed", m_pHandle->pUserCookie);
					ZAutoCSLocker lock(&m_pHandle->m_lock_req);
					if (m_pHandle->status == req_status_registering)
						m_pHandle->status = req_status_process_complete;
				}
				break;
			}
		}
		break;
	case PC_GET_IPCSTATE_ACK: // 待用
		{
			ptrCmd->length;
			char res = pCmd[sizeof(trans_msg_s)];
			printf("\n PC_GET_IPCSTATE_ACK : %d \n", res);
		}
		break;
	case PC_IPC_MEDIA_TYPE_ACK:
		{
			ZAutoCSLocker lock(&m_stream_change_status);
			if (m_stream_change_time != 0)
			{
				m_stream_change_time = 0;
				char res = pCmd[sizeof(trans_msg_s)];
				if (res == 0)
				{
					if (m_pEvents)
					{
						m_pEvents->OnStatusReport(stStream, ssChangeStreamSucc, "channge stream success", m_pHandle->pUserCookie);
					}
				}
				else
				{
					if (m_pEvents)
					{
						m_pEvents->OnStatusReport(stStream, ssChangeStreamFailed, "channge stream failed", m_pHandle->pUserCookie);
					}
				}
			}
		}
		break;
	case PC_IPC_STOP_MEDIA_ACK:
		{

		}
		break;
	case PC_IPC_VOICE_STATUS_ACK:
		{
			trans_msg_resp_sound * resp = (trans_msg_resp_sound*)(pCmd + sizeof(trans_msg_s));
			if (resp && resp->status == 0)
			{
				if (m_pEvents)
				{
					m_pEvents->OnStatusReport(stStream, 
						m_bSoundOpen?ssOpenSoundSucc:ssCloseSoundSucc, 
						m_bSoundOpen?"Open sound success":"Close sound success", m_pHandle->pUserCookie);
				}
			}
			else
			{
				if (m_pEvents)
				{
					m_pEvents->OnStatusReport(stStream, 
						m_bSoundOpen?ssOpenSoundFailed:ssCloseSoundFailed, 
						m_bSoundOpen?"Open sound failed":"Close sound failed", m_pHandle->pUserCookie);
				}
			}
		}
		break;
	case PC_IPC_TALK_STATUS_ACK:
		{
			trans_msg_resp_talk * resp = (trans_msg_resp_talk*)(pCmd + sizeof(trans_msg_s));
			if (strncmp(resp->tokenid, m_sTokenid, strlen(m_sTokenid)) == 0)
			{
				if (resp->status == 0)
				{
					if (m_pEvents)
					{
						m_pEvents->OnStatusReport(stStream, 
							m_bTalkOpen?ssOpenTalkSucc:ssCloseTalkSucc,
							m_bTalkOpen?"Open talk success":"Close talk success", m_pHandle->pUserCookie);
					}
				}
				else
				{				
					if (m_pEvents)
					{
						m_pEvents->OnStatusReport(stStream, 
							m_bTalkOpen?ssOpenTalkFailed:ssCloseTalkFailed,
							m_bTalkOpen?"Open talk failed":"Close talk failed", m_pHandle->pUserCookie);
					}
				}
			}
		}
		break;
	case PC_IPC_REPORT_STATUS_ACK:
		break;
	case PC_IPC_HEART_ACK:
		{
			// do nothing
		}
		break;
	case IPC_TRANS_STOP_SYN://中转服务器下发停止视频指令处理
		{
			if (m_pEvents)
			{
				m_pEvents->OnStatusReport(stStream, ssDeliverConnectFailed, "transit server close connect", m_pHandle->pUserCookie);
				break;
			}
			return -1;//返回固定的错误值
		}
		break;
	case PC_TRANS_HEART_ACK:
		{
		}
		break;
	case PC_IPC_PLAYBACK_ACK:
		{
			char res = pCmd[sizeof(trans_msg_s)];
			if (res == 0)
			{
				if (m_pEvents)
				{
					m_pEvents->OnStatusReport(stStream, ssPlayBackReqSucc, "playback req success", m_pHandle->pUserCookie);
				}
			}
			else
			{
				if (m_pEvents)
				{
					m_pEvents->OnStatusReport(stStream, ssPlayBackReqFailed, "playback req failed", m_pHandle->pUserCookie);
				}
			}
		}
		break;
	case PC_IPC_UPNP_LOGIN_ACK:
		{
			ZAutoCSLocker lock(&m_stream_login_status);
			if (m_stream_login_time != 0)
			{
				m_stream_login_time = 0;
				trans_msg_upnp_login_resp_s * resp = (trans_msg_upnp_login_resp_s*)(pCmd + sizeof(trans_msg_s));
				if (strncmp(resp->tokenid, m_sTokenid, strlen(m_sTokenid)) == 0)
				{
					if (m_pEvents)
					{
						if (resp->echo_code == 0)
						{
							if (resp->permit == 0)
							{
								m_pEvents->OnStatusReport(stUpnp, upnpLoginSuper_0, resp->tokenid, m_pHandle->pUserCookie);
							}
							else
							{
								m_pEvents->OnStatusReport(stUpnp, upnpLoginNormal_0, resp->tokenid, m_pHandle->pUserCookie);
							}
						}
						else
						{
							m_pEvents->OnStatusReport(stUpnp, upnpLoginfalied, resp->tokenid, m_pHandle->pUserCookie);
						}
					}
				}
			}
		}
		break;
	case PC_IPC_UPNP_CHANGE_PWD_ACK:
		{
			trans_msg_upnp_change_pwd_resp_s * resp = (trans_msg_upnp_change_pwd_resp_s*)(pCmd + sizeof(trans_msg_s));
			if (strncmp(resp->tokenid, m_sTokenid, strlen(m_sTokenid)) == 0)
			{
				if (m_pEvents)
				{
					if (resp->echo_code == 0)
						m_pEvents->OnStatusReport(stUpnp, upnpChangePwdSucc, resp->tokenid, m_pHandle->pUserCookie);
					else
						m_pEvents->OnStatusReport(stUpnp, upnpChangePwdFailed, resp->tokenid, m_pHandle->pUserCookie);
				}
			}
		}
		break;
	case PC_IPC_PLAYBACK_STOP_SYN:
		{
			if (m_pEvents)
			{
				m_pEvents->OnStatusReport(stStream, ssPlayBackStop, "playback stop", m_pHandle->pUserCookie);
			}
		}
		break;
	case PC_IPC_PTZ_ACK:
		{
			trans_msg_resp_ptz_ctrl * resp = (trans_msg_resp_ptz_ctrl*)(pCmd + sizeof(trans_msg_s));
			if (strncmp(resp->tokenid, m_sTokenid, strlen(m_sTokenid)) == 0)
			{
				if (m_pEvents)
				{
					if (resp->result == 0)
						m_pEvents->OnStatusReport(stStream, ssPTZCfgSucc, resp->tokenid, m_pHandle->pUserCookie);
					else
						m_pEvents->OnStatusReport(stStream, ssPTZCfgFailed, resp->tokenid, m_pHandle->pUserCookie);
				}
			}
		}
		break;
	case PC_IPC_GET_PRESETPOINT_ACK:
		{
			trans_msg_resp_ptz_preset * resp = (trans_msg_resp_ptz_preset*)(pCmd + sizeof(trans_msg_s));
			if (strncmp(resp->tokenid, m_sTokenid, strlen(m_sTokenid)) == 0)
			{
				if (m_pEvents)
				{
					if (resp->result == 0)
						m_pEvents->OnStatusReport(stStream, ssPTZGetPresetSucc, (char*)resp, m_pHandle->pUserCookie);
					else
						m_pEvents->OnStatusReport(stStream, ssPTZGetPresetFailed, (char*)resp, m_pHandle->pUserCookie);
				}
			}
		}
		break;
	default:
		printf("response cmd : %d \n", respcmd);
		break;
	}

	return 0;
}

bool Stream::CheckRecvDataTimeout()
{
	ZAutoCSLocker lock(&m_lock_recv_status);
	if (m_last_recv_data_time != 0)
	{
		uint64_t cur_time = ZUtility::getTime();
		if (cur_time>m_last_recv_data_time && (cur_time-m_last_recv_data_time>m_streamTimeout))
		{
            m_last_recv_data_time = 0;
			NotifyStreamTimeout();
			return true;
		}
	}
	return false;
}
bool Stream::CheckLoginTimeout()
{
	ZAutoCSLocker lock(&m_stream_login_status);
	if (m_stream_login_time != 0)
	{
		if (ZUtility::getTime()-m_stream_login_time>m_sLoginTimeout)
		{
			m_stream_login_time = 0;
			if (m_pEvents && m_pHandle) // 上报超时	
			{
				if (m_pHandle->type == proto_transit_play)
					m_pEvents->OnStatusReport(stStream, ssDeliverRecvFailed, "login timeout", m_pHandle->pUserCookie);
				else
					m_pEvents->OnStatusReport(stStream, ssP2PRecvFailed, "login timeout", m_pHandle->pUserCookie);
			}
			return true;
		}
	}
	return false;
}
bool Stream::CheckChangeStreamTimeout()
{
	ZAutoCSLocker lock(&m_stream_change_status);
	if (m_stream_change_time != 0)
	{
		if (ZUtility::getTime()-m_stream_change_time>DEFAULT_STREAM_TIMEOUT)
		{
			m_stream_change_time = 0;
			if (m_pEvents) // 上报超时	
			{
				m_pEvents->OnStatusReport(stStream, ssChangeStreamFailed, "change stream timeout", m_pHandle->pUserCookie);
			}
			return true;
		}
	}

	return false;
}

void Stream::DoWork()
{
	uint64_t last_keepalive_time = 0;
	while (!m_bBasicClosing)
	{
		// 发送心跳
		uint64_t cur_time = ZUtility::getTime();
		if (cur_time - last_keepalive_time > m_streamKeepAlive)
		{
			if (-1 == OnKeepalive())
			{
				break;
			}
			last_keepalive_time = cur_time;
		}

		if (CheckRecvDataTimeout())
			break;

		if (CheckLoginTimeout())
			break;

		if (CheckChangeStreamTimeout())
			break;

		// 统计是否需要切换码流
		//OnCheckStream(total_low_rate);

#ifndef WIN32
		timeval t;
		gettimeofday(&t, 0);
		uint64_t exptime = t.tv_sec * 1000000ULL + t.tv_usec + 10 *1000ULL;
		timespec timeout;
		timeout.tv_sec = exptime / 1000000;
		timeout.tv_nsec = (exptime % 1000000) * 1000;
		pthread_cond_timedwait(&m_BasicStopCond, &m_BasicStopLock, &timeout);
#else
		WaitForSingleObject(m_BasicStopCond, 10);	// 时间间隔10ms
#endif

	}
}