
#include "P2PClient.h"
#include "UdtStream.h"
#include "TcpStream.h"
#include <json/json.h>

enum MEDIA_TYPE
{
	QVGA = 0,
	VAG = 1,
	HD720P = 2,
	PALYBACK = 3,
	DVRSPEAK = 5,
};

CSipParams CP2PClient::m_sip_params;
unsigned long CP2PClient::m_reqid = 0;
CP2PClient::CP2PClient()
{
	m_pEvents = NULL;
	m_pUserData = NULL;
	StartBasicThread();
}

CP2PClient::~CP2PClient()
{
	StopBasicThread();
	//DelAllRequst(); 	// 临时方案 解决上层对象已经释放后，回调才回来导致的异常崩溃问题，这样处理会有内存泄露
}

z_bool_t CP2PClient::msg_cb(zsip_method_e method_id, const char* method_name, void* data, int data_len, void* /*msg_handler*/)
{
	if (method_id == ZSIP_OTHER_METHOD && strcmp(method_name, "MESSAGE") == 0)
	{
		if (m_sip_params.m_zisp_msg_cb)
			m_sip_params.m_zisp_msg_cb(stSIP, sipsMessage, (char*)data, data_len);
	}
	return Z_TRUE;
}

int CP2PClient::worker_thread(void* /*user_data*/)
{
	z_time_val timeout = {0, 100};
	while (!m_sip_params.m_bTerminated) 
	{
		zsip_endpt_handle_events(&timeout);
	}
	m_sip_params.m_bThreadStatus = false;
	return 0;
}

bool CP2PClient::InitStaticParams(const std::string & slParams, zsip_msg_cb cb)
{
	Json::Reader reader;
	Json::Value root;
	if (!reader.parse(slParams, root, false))
		return false;

	m_sip_params.m_strTokenId = root["TokenId"].asString();
	m_sip_params.m_strUsrId = root["UsrId"].asString();

	m_sip_params.addr.client_ip = root["ClientIP"].asString();
	m_sip_params.addr.client_port = root["ClientPort"].asString();
	m_sip_params.addr.stun_ip = root["StunIP"].asString();
	m_sip_params.addr.stun_port = root["StunPort"].asString();
	m_sip_params.addr.server_ip = root["ServerIP"].asString();
	m_sip_params.addr.server_port = root["ServerPort"].asString();

	m_sip_params.m_strCmuId = "1001000000";			// 默认cumid=1001000000指向固定服务器，后续考虑别的方案

#ifdef _WIN32
	#define Z_ATOI  _atoi64
#else
	#define Z_ATOI  atoll
#endif

	m_sip_params.m_SipKeepAlive = Z_ATOI(root["SipKeepAlive"].asString().c_str());
  m_sip_params.m_SipKeepAliveData = Z_ATOI(root["SipKeepAlvieData"].asString().c_str());
	m_sip_params.m_SipReqTimeout = Z_ATOI(root["SipReqTimeout"].asString().c_str());
	m_sip_params.m_P2PReqTimeout = Z_ATOI(root["P2PReqTimeout"].asString().c_str());
	m_sip_params.m_RegisterTimeout = Z_ATOI(root["RegisterTimeout"].asString().c_str());
	m_sip_params.m_LoginTimeout = Z_ATOI(root["LoginTimeout"].asString().c_str());
	m_sip_params.m_StreamKeepAlive = Z_ATOI(root["StreamKeepAlive"].asString().c_str());
	m_sip_params.m_StreamTimeout = Z_ATOI(root["StreamTimeout"].asString().c_str());

	if (m_sip_params.m_SipKeepAlive == 0) m_sip_params.m_SipKeepAlive = DEFAULT_SIP_KEEP_ALIVE;
  if (m_sip_params.m_SipKeepAliveData == 0) m_sip_params.m_SipKeepAliveData = DEFAULT_SIP_KEEP_ALIVE_DATA;
	if (m_sip_params.m_SipReqTimeout == 0) m_sip_params.m_SipReqTimeout = DEFAULT_SIP_REQ_TIMEOUT;
	if (m_sip_params.m_P2PReqTimeout == 0) m_sip_params.m_P2PReqTimeout = DEFAULT_P2P_REQ_TIMEOUT;
	if (m_sip_params.m_RegisterTimeout == 0) m_sip_params.m_RegisterTimeout = DEFAULT_REGISTER_TIMEOUT;
	if (m_sip_params.m_LoginTimeout == 0) m_sip_params.m_LoginTimeout = DEFAULT_LOGIN_TIMEOUT;
	if (m_sip_params.m_StreamKeepAlive == 0) m_sip_params.m_StreamKeepAlive = DEFAULT_STREAM_KEEPALIVE;
	if (m_sip_params.m_StreamTimeout == 0) m_sip_params.m_StreamTimeout = DEFAULT_STREAM_TIMEOUT;

	m_sip_params.UserType = atoi(root["UsrType"].asString().c_str());
	m_sip_params.ClientType = atoi(root["ClientType"].asString().c_str());
	if (!(m_sip_params.ClientType == 0 || m_sip_params.ClientType == 1))
		return false;
	m_sip_params.m_SipKeepAlive /= 1000;
	m_sip_params.m_keepAliveDelay.sec = m_sip_params.m_SipKeepAlive / 1000;
	m_sip_params.m_keepAliveDelay.msec = m_sip_params.m_SipKeepAlive % 1000;

  m_sip_params.m_SipKeepAliveData /= 1000000;

	m_sip_params.m_zisp_msg_cb = cb;
	return true;
}

bool CP2PClient::InitZSip(const std::string & slParams, zsip_msg_cb cb)
{
#ifdef ANDROID
	LOGI("CP2PClient::Init begin");
#endif
 
	if (!InitStaticParams(slParams, cb))
		return false;

	if (!m_sip_params.m_bInit)
	{
		do 
		{
			zsip_endptc endptc;
			pj_memset(&endptc, 0, sizeof(endptc));
			endptc.tp_type = ZSIP_TRANSPORT_UDP;
			endptc.inet_type = Z_AF_INET();
			endptc.local_addr = m_sip_params.addr.client_ip.c_str();
			endptc.local_port = atoi(m_sip_params.addr.client_port.c_str());
			endptc.published_addr = NULL;
			endptc.published_port = 0;
			endptc.on_rx_msg_request = msg_cb;
			endptc.on_rx_invite_request = NULL;
			endptc.stun_addr = m_sip_params.addr.stun_ip.c_str();
			endptc.stun_port = atoi(m_sip_params.addr.stun_port.c_str());
			endptc.srv_addr = m_sip_params.addr.server_ip.c_str();
			endptc.srv_port = atoi(m_sip_params.addr.server_port.c_str());
			endptc.req_timeout = (int)(m_sip_params.m_SipReqTimeout/1000);
			endptc.is_log = Z_FALSE;  // ZSIP日志开关

			if (PJ_SUCCESS != zsip_init(&endptc))
				break;

			if ((m_sip_params.m_Pool = z_pool_create(1024, 1024)) == NULL) 
				break;

			m_sip_params.m_bTerminated = false;
			if (PJ_SUCCESS != z_thread_create(m_sip_params.m_Pool, &worker_thread, NULL, &m_sip_params.m_ThreadID))
				break;
			m_sip_params.m_bThreadStatus = true;

      if (Z_SUCCESS != zsip_start_ka(m_sip_params.m_SipKeepAliveData))
        break;

			m_sip_params.m_bInit = true;

		} while(0);
	}

	if (!m_sip_params.m_bInit)
	{
		// 初始化失败释放资源
		ReleaseZSip();
	}
	else
	{
		return KeepAlive();
	}

	return false;
}

void CP2PClient::ReleaseZSip()
{	
#ifdef ANDROID
	LOGI("CP2PClient::Release begin");
#endif
	if (!m_sip_params.m_bInit)
		return;

	z_thread_register();
	if (m_sip_params.m_bTerminated) 
		return;
	m_sip_params.m_bTerminated = true;
	while (m_sip_params.m_bThreadStatus)
	{
		pj_thread_sleep(1);
	}

	pj_thread_destroy(m_sip_params.m_ThreadID);
	if (m_sip_params.m_Pool)
	{
		pj_pool_release(m_sip_params.m_Pool);
		m_sip_params.m_Pool = NULL;
	}

	zsip_release();
	m_sip_params.m_bInit = false;

#ifdef ANDROID
	LOGI("CP2PClient::Release end");
#endif
}

bool CP2PClient::Init(IEvents& Events)
{
	m_pEvents = &Events;
	return true;
}

void CP2PClient::keep_alive_cb(z_status_t /*status*/, int code, void* response, int len, void* user_data)
{
  printf("keep_alive_cb() code = %d, response = %s \n", code, response);
	bool bRebuild = false;
	if (200 == code)
	{
		Json::Reader reader;
		Json::Value root;
		if (!reader.parse(std::string((char*)response, len), root, false))
		{
			bRebuild = true;
		}
		else
		{
			int iResultCode = root["ResultCode"].asInt(); //0-成功, -1-协议格式错误, -2-json串内容不对, -3-未注册
			if (iResultCode == 0)
			{
				if (m_sip_params.m_strCmuId.empty() || atoi(m_sip_params.m_strCmuId.c_str()) != root["CmuId"].asInt())
				{
					char szCmuId[64] = {0};
					sprintf(szCmuId, "%d", root["CmuId"].asInt());
					m_sip_params.m_strCmuId = szCmuId;
				}
				zsip_endpt_schedule_timer(1, &m_sip_params.m_keepAliveDelay, keep_alive_timer_cb, user_data);
			}
			else if (iResultCode == -3)
			{
				if (m_sip_params.m_zisp_msg_cb)
					m_sip_params.m_zisp_msg_cb(stSIP, sipsSessionTimeout, NULL, 0);
			}
			else
				bRebuild = true;				
		}
	}
	else
	{
		if (code == 503)
		{
			if (m_sip_params.m_zisp_msg_cb)
				m_sip_params.m_zisp_msg_cb(stSIP, sipsUpdateDNS, "server is unavailable", strlen("server is unavailable"));
		}		
		bRebuild = true;
	}

	// 重建心跳
	if (bRebuild)
	{
		ReBuildKeepAlive();
	}
}

bool CP2PClient::KeepAlive()
{
	Json::Value root;
	Json::FastWriter writer;

	root["TokenId"] = m_sip_params.m_strTokenId;
	root["UsrId"] = m_sip_params.m_strUsrId;
	root["UserType"] = m_sip_params.UserType; // 0-客户端，1-设备，2-upnp设备，3-upnp客户端
	root["ClientType"] = m_sip_params.ClientType;
	root["MethodName"] = "Option.update";
	std::string strRequest = writer.write(root);

	zsip_request reqc;
	pj_memset(&reqc, 0, sizeof(reqc));
	reqc.method.id = ZSIP_OPTIONS_METHOD;
	reqc.method.name = "OPTIONS";
	reqc.contact_cnt = 1;
	reqc.caller = (char*)m_sip_params.m_strTokenId.c_str();
	reqc.callee = (char*)m_sip_params.m_strTokenId.c_str();
	reqc.user_data = NULL;
	reqc.content = (char*)strRequest.c_str();
	reqc.content_type = "text";
	reqc.content_subtype = "json";

	z_status_t status = zsip_req(&reqc, keep_alive_cb);
	return status == Z_SUCCESS;
}

void CP2PClient::keep_alive_timer_cb(int /*id*/, void* /*user_data*/)
{
	KeepAlive();	
}

bool CP2PClient::ReBuildKeepAlive()
{
	z_thread_register();
	z_status_t status = zsip_endpt_schedule_timer(1, &m_sip_params.m_keepAliveDelay, keep_alive_timer_cb, NULL);
	return PJ_SUCCESS == status;
}

void CP2PClient::upnp_cb(z_status_t /*status*/, int code, void* response, int len, void* user_data)
{
  CUserData *pUserData = (CUserData*)user_data;
  if (!pUserData) return;

  if (pUserData->reqid != CP2PClient::GetReqId()) {
    pUserData->status = req_status_invalid;
    return;
  }
  ZAutoCSLocker lock(&pUserData->m_lock_req);
  if (pUserData->status != req_status_requesting) {
    pUserData->status = req_status_process_complete;
    return;
  }

  if (code != 200) {
    if (pUserData->type == proto_upnp_query) {
      if (pUserData->m_pEvents)
        pUserData->m_pEvents->OnStatusReport(stUpnp, upnpQueryUpnpFailed, (char*)response, pUserData->pUserCookie);
    } else if (pUserData->type == proto_upnp_play) {
      if (pUserData->m_pEvents)
        pUserData->m_pEvents->OnStatusReport(stStream, ssUPNPConnectFailed, (char*)response, pUserData->pUserCookie);
    } else if (pUserData->type == proto_upnp_playback) {
      if (pUserData->m_pEvents)
        pUserData->m_pEvents->OnStatusReport(stStream, ssPlayBackReqFailed, (char*)response, pUserData->pUserCookie);
    }
    pUserData->status = req_status_process_complete;
    return;
  }  

  pUserData->status = req_status_process_complete;
  if (pUserData->type == proto_upnp_play || pUserData->type == proto_upnp_playback) {
    int iSuccStatus = pUserData->type == proto_upnp_play? ssUPNPConnectSucc : ssPlayBackReqSucc;
    int iFailedStatus = pUserData->type == proto_upnp_play? ssUPNPConnectFailed : ssPlayBackReqFailed;

    Json::Reader reader;
    Json::Value root;
    if (reader.parse(std::string((char*)response, len), root, false) && !root["QueryRes"].isNull()) {
      int iVideoPort = root["QueryRes"]["UpnpVideoPort"].asInt();
      std::string r_addr = root["QueryRes"]["InternetIp"].asString();
      if (iVideoPort != 0) {
        pUserData->m_Stream = new UdtStream(UPNP_MODE);
        pUserData->m_Stream->Init(pUserData->m_pEvents, pUserData, m_sip_params.m_strTokenId.c_str(), 
          m_sip_params.m_StreamTimeout, m_sip_params.m_StreamKeepAlive, m_sip_params.m_LoginTimeout);
        if (pUserData->m_Stream->OpenStream(r_addr.c_str(), iVideoPort, NULL, 0)) {
          if (pUserData->type == proto_upnp_play) {
            if (!pUserData->m_Stream->ReqStream(pUserData->m_iChannel, pUserData->m_iMediaType, 1)) {
              if (pUserData->m_pEvents)
                pUserData->m_pEvents->OnStatusReport(stStream, iFailedStatus, "req stream failed", pUserData->pUserCookie);
            } else {
              if (pUserData->m_pEvents)
                pUserData->m_pEvents->OnStatusReport(stStream, iSuccStatus, "upnp connect success", pUserData->pUserCookie);
            }
          } else if (pUserData->type == proto_upnp_playback) {
            if (!pUserData->m_Stream->ReqPlayback(pUserData->m_strDateTime.c_str(), pUserData->m_iChannel)) {
              if (pUserData->m_pEvents)
                pUserData->m_pEvents->OnStatusReport(stStream, ssPlayBackReqFailed, "upnp playback failed", pUserData->pUserCookie);
            }
          }
          pUserData->status = req_status_connected;
        } else {
          if (pUserData->m_pEvents)
            pUserData->m_pEvents->OnStatusReport(stStream, iFailedStatus, "upnp connect failed", pUserData->pUserCookie);
        }
      } else {
        if (pUserData->m_pEvents)
          pUserData->m_pEvents->OnStatusReport(stStream, iFailedStatus, "not sport upnp", pUserData->pUserCookie);
      }
    } else {
      if (pUserData->m_pEvents)
        pUserData->m_pEvents->OnStatusReport(stStream, iFailedStatus, "upnp query failed", pUserData->pUserCookie);
    }
  } else if (pUserData->type == proto_upnp_query) {
    if (pUserData->m_pEvents)
      pUserData->m_pEvents->OnStatusReport(stUpnp, upnpQueryUpnpSucc, (char*)response, pUserData->pUserCookie);
  }
}

bool CP2PClient::IsUPNPSupport(const std::string& strDeviceId, void * pCookie)
{
	if (m_sip_params.m_strCmuId.empty()) {
		if (m_pEvents)
			m_pEvents->OnStatusReport(stUpnp, upnpQueryUpnpFailed, "sip server not response!!", pCookie);
		return false;
	}

	CUserData * pUserData = new CUserData;
	pUserData->type = proto_upnp_query;
	pUserData->reqid = GetReqId(true);
	pUserData->pCookie = this;
	pUserData->pUserCookie = pCookie;
	pUserData->msTimeStamp = ZUtility::getTime();
	pUserData->status = req_status_requesting;
	pUserData->m_Stream = NULL;
	pUserData->m_pEvents = m_pEvents;
	AddRequest(pUserData);

	Json::Value root;
	Json::FastWriter writer;
	root["MethodName"] = "dm.GetPuInfo";
	root["DevId"] = strDeviceId;
	std::string req_content = writer.write(root);

	zsip_request reqc;
	pj_memset(&reqc, 0, sizeof(reqc));
	reqc.method.id = ZSIP_OTHER_METHOD;
	reqc.method.name = "MESSAGE";
	reqc.contact[0] = (char*)m_sip_params.addr.server_ip.c_str();
	reqc.port[0] = 0;
	reqc.contact_cnt = 1;
	reqc.caller = "admin";
	reqc.callee = (char*)m_sip_params.m_strCmuId.c_str();
	reqc.user_data = pUserData;
	reqc.content = (char*)req_content.c_str();
	reqc.content_type = "text";
	reqc.content_subtype = "json";

    printf("---------------- > %s : 1",__FUNCTION__);
	z_thread_register();
    printf("---------------- > %s : 2",__FUNCTION__);
    z_status_t status = zsip_req(&reqc, upnp_cb);
    printf("---------------- > %s : 3",__FUNCTION__);
    
	if (PJ_SUCCESS != status)
		return false;
	return true;
}

void CP2PClient::p2p_cb(int code, z_ice_strans* /*icest*/, char* /*param*/, zsip_addr_pair* addr_pair, int pair_cnt, void* user_data)
{
#ifdef ANDROID
  LOGI("enter p2p_cb(): code=%d, base_addr=%s, base_port=%d, r_addr=%s, r_port=%d",
    code, addr_pair->base_addr, addr_pair->base_port, addr_pair->r_addr, addr_pair->r_port);
#else
  char szLog[256] = {0};
  sprintf(szLog, "enter p2p_cb(): code=%d, base_addr=%s, base_port=%d, r_addr=%s, r_port=%d",
    code, addr_pair->base_addr, addr_pair->base_port, addr_pair->r_addr, addr_pair->r_port);
  printf(szLog); printf("\n");
#ifdef _WIN32
  ::OutputDebugStringA(szLog);
#endif
#endif

  CUserData *pUserData = (CUserData*)user_data;
  if (!pUserData) return;

  if (pUserData->reqid != CP2PClient::GetReqId()) {
    pUserData->status = req_status_invalid;
    return;
  }

  ZAutoCSLocker lock(&pUserData->m_lock_req);
  if (pUserData->status != req_status_requesting) {
    pUserData->status = req_status_process_complete;
    return;
  }

  if (200 != code) {
    if (404 == code) {
      //设备不在线
      if (pUserData->m_pEvents)
        pUserData->m_pEvents->OnStatusReport(stStream, ssP2PConnectFailed, "Device Not Available", pUserData->pUserCookie);
    } else {
      if (pUserData->type == proto_p2p_playback) {
        if (pUserData->m_pEvents)
          pUserData->m_pEvents->OnStatusReport(stStream, ssPlayBackReqFailed, "playback failed", pUserData->pUserCookie);
      } else {
        if (pUserData->m_pEvents)
          pUserData->m_pEvents->OnStatusReport(stStream, ssP2PConnectFailed, "p2p failed", pUserData->pUserCookie);
      }
    }
    pUserData->status = req_status_process_complete;
    return ;
  }

  pUserData->m_Stream = new UdtStream(P2P_MODE);
  pUserData->m_Stream->Init(pUserData->m_pEvents, pUserData, m_sip_params.m_strTokenId.c_str(), 
    m_sip_params.m_StreamTimeout, m_sip_params.m_StreamKeepAlive, m_sip_params.m_LoginTimeout);
  if (pUserData->m_Stream->OpenStream(
    addr_pair->r_addr, addr_pair->r_port, addr_pair->base_addr, addr_pair->base_port)) {
    if (pUserData->type == proto_p2p_playback) {
      if (!pUserData->m_Stream->ReqPlayback(pUserData->m_strDateTime.c_str(), pUserData->m_iChannel)) {
        if (pUserData->m_pEvents)
          pUserData->m_pEvents->OnStatusReport(stStream, ssPlayBackReqFailed, "playback failed", pUserData->pUserCookie);
      }
    } else {
      if (pUserData->m_pEvents)
        pUserData->m_pEvents->OnStatusReport(stStream, ssP2PConnectSucc, "p2p connect success", pUserData->pUserCookie);
    }
    pUserData->status = req_status_connected;
  } else {
    if (pUserData->type == proto_p2p_playback) {
      if (pUserData->m_pEvents)
        pUserData->m_pEvents->OnStatusReport(stStream, ssPlayBackReqFailed, "playback failed", pUserData->pUserCookie);
    } else {
      if (pUserData->m_pEvents)
        pUserData->m_pEvents->OnStatusReport(stStream, ssP2PConnectFailed, "p2p connect failed", pUserData->pUserCookie);
    }
    pUserData->status = req_status_process_complete;
  }
}

void CP2PClient::transit_cb(z_status_t /*status*/, int code, void* response, int len, void* user_data)
{
#ifdef ANDROID
  LOGI("enter transit_cb(): code=%d, response=%s", code, (char*)response);
#else
  char szLog[256] = {0};
  sprintf(szLog, "enter transit_cb(): code=%d, response=%s", code, (char*)response);
  printf(szLog); printf("\n");
#ifdef _WIN32
  ::OutputDebugStringA(szLog);
#endif
#endif

  CUserData *pUserData = (CUserData*)user_data;
  if (!pUserData) return;

  if (pUserData->reqid != CP2PClient::GetReqId()) {
    pUserData->status = req_status_invalid;
    return;
  }

  ZAutoCSLocker lock(&pUserData->m_lock_req);
  if (pUserData->status != req_status_requesting) {
    pUserData->status = req_status_process_complete;
    return;
  }

  Json::Reader reader;
  Json::Value root;
  if ((200 != code) || !reader.parse(std::string((char*)response, len), root, false)) {
    if (404 == code) {
      //设备不在线
      if (pUserData->m_pEvents)
        pUserData->m_pEvents->OnStatusReport(stStream, ssDeliverConnectFailed, "Device Not Available", pUserData->pUserCookie);
    } else {
      if (pUserData->m_pEvents)
        pUserData->m_pEvents->OnStatusReport(stStream, ssDeliverConnectFailed, (char*)response, pUserData->pUserCookie);
    }
    pUserData->status = req_status_process_complete;
    return;
  } 

  if (root["ResultCode"].asInt() != 0) {
    if (pUserData->m_pEvents)
      pUserData->m_pEvents->OnStatusReport(stStream, ssDeliverConnectFailed, root["ResultReason"].asString().c_str(), pUserData->pUserCookie);
    pUserData->status = req_status_process_complete;
  } else {
    pUserData->m_Stream = new TcpStream(TRANSIT_MODE);
    pUserData->m_Stream->Init(pUserData->m_pEvents, pUserData, m_sip_params.m_strTokenId.c_str(), 
      m_sip_params.m_StreamTimeout, m_sip_params.m_StreamKeepAlive, m_sip_params.m_LoginTimeout);
    if (pUserData->m_Stream->OpenStream(root["Ip"].asString().c_str(), root["Port"].asInt())) {
      if (!pUserData->m_Stream->ReqLogin(root["register_code"].asString().c_str(), m_sip_params.m_strTokenId.c_str())) {
        if (pUserData->m_pEvents)
          pUserData->m_pEvents->OnStatusReport(stStream, ssDeliverConnectFailed, "deliver register request failed", pUserData->pUserCookie);
        pUserData->status = req_status_process_complete;
      } else {
        pUserData->msTimeStamp = ZUtility::getTime();
        pUserData->status = req_status_registering;
      }
    } else {
      if (pUserData->m_pEvents)
        pUserData->m_pEvents->OnStatusReport(stStream, ssDeliverConnectFailed, "transit connect failed", pUserData->pUserCookie);
      pUserData->status = req_status_process_complete;
    }
  }
}

unsigned long CP2PClient::GetReqId(bool bIncrease)
{
	if (bIncrease) {
		if (++m_reqid == 0xEFFFFFFF)
			m_reqid = 1;
	}
	return m_reqid;
}

bool CP2PClient::RealPlay(const std::string& strDeviceId, int iChannel, int iMediaType, int iMode, void * pCookie)
{
	if (iMode == TRANSIT_MODE || iMode == UPNP_MODE) {
		if (m_sip_params.m_strCmuId.empty()) {
			if (m_pEvents) {
				if (iMode == TRANSIT_MODE)
					m_pEvents->OnStatusReport(stStream, ssDeliverConnectFailed, "sip server not response!!", pCookie);
				else if (iMode == UPNP_MODE)
					m_pEvents->OnStatusReport(stStream, ssUPNPConnectFailed, "sip server not response!!", pCookie);
			}
			return false;
		}
	}

	CUserData * pUserData = new CUserData;
	pUserData->reqid = GetReqId(true);
	pUserData->pCookie = this;
	pUserData->pUserCookie = pCookie;
	if (iMode == TRANSIT_MODE)
		pUserData->type = proto_transit_play;
	else if (iMode == P2P_MODE)
		pUserData->type = proto_p2p_play;
	else if (iMode == UPNP_MODE)
		pUserData->type = proto_upnp_play;
	pUserData->msTimeStamp = ZUtility::getTime();
	pUserData->status = req_status_requesting;

	pUserData->m_strDeviceId = strDeviceId;
	pUserData->m_iChannel = iChannel;
	pUserData->m_iMediaType = iMediaType;
	pUserData->m_Stream = NULL;
	pUserData->m_strDateTime = "";
	pUserData->m_pEvents = m_pEvents;
	AddRequest(pUserData);

	if (iMode == P2P_MODE) {
		zsip_p2p_request reqc;
		pj_memset(&reqc, 0, sizeof(reqc));
		reqc.method.id = ZSIP_OTHER_METHOD;
		reqc.method.name = "P2PREQUEST";
		reqc.contact[0] = (char*)m_sip_params.addr.client_ip.c_str();
		reqc.port[0] = 0;
		reqc.contact_cnt = 1;
		reqc.caller = (char*)m_sip_params.m_strUsrId.c_str();
		reqc.callee = (char*)strDeviceId.c_str();
		reqc.user_data = pUserData;
		reqc.content_subtype = "sdp";
		reqc.content_type = "application";
		char param[32] = {0};
		sprintf(param, "%d|%d", iChannel, iMediaType);
		reqc.param = param;

		z_thread_register();
		if (PJ_SUCCESS != zsip_p2p_req(&reqc, p2p_cb))
			return false;
		return true;
	} else if (iMode == TRANSIT_MODE) {
		Json::Value root;
		Json::FastWriter writer;
		root["MethodName"] = "ex.video";
		root["UsrId"] = m_sip_params.m_strUsrId;
		root["DevId"] = strDeviceId;
		root["MediaType"] = iMediaType;
		root["ChannelNum"] = iChannel;
		std::string req_content = writer.write(root);

		zsip_request reqc;
		pj_memset(&reqc, 0, sizeof(reqc));
		reqc.method.id = ZSIP_OTHER_METHOD;
		reqc.method.name = "MESSAGE";
		reqc.contact[0] = (char*)m_sip_params.addr.server_ip.c_str();
		reqc.port[0] = 0;
		reqc.contact_cnt = 1;
		reqc.caller = (char*)m_sip_params.m_strTokenId.c_str();
		reqc.callee = (char*)m_sip_params.m_strCmuId.c_str();
		reqc.user_data = pUserData;
		reqc.content = (char*)req_content.c_str();
		reqc.content_type = "text";
		reqc.content_subtype = "json";

		z_thread_register();
		if (PJ_SUCCESS != zsip_req(&reqc, transit_cb))
			return false;
		return true;
	} else if (iMode == UPNP_MODE) {
		// 先UPNP查询，然后再查询回调中,处理连接
		Json::Value root;
		Json::FastWriter writer;
		root["MethodName"] = "dm.GetPuInfo";
		root["DevId"] = strDeviceId;
		std::string req_content = writer.write(root);

		zsip_request reqc;
		pj_memset(&reqc, 0, sizeof(reqc));
		reqc.method.id = ZSIP_OTHER_METHOD;
		reqc.method.name = "MESSAGE";
		reqc.contact[0] = (char*)m_sip_params.addr.server_ip.c_str();
		reqc.port[0] = 0;
		reqc.contact_cnt = 1;
		reqc.caller = "admin";
		reqc.callee = (char*)m_sip_params.m_strCmuId.c_str();
		reqc.user_data = pUserData;
		reqc.content = (char*)req_content.c_str();
		reqc.content_type = "text";
		reqc.content_subtype = "json";

		z_thread_register();
		if (PJ_SUCCESS != zsip_req(&reqc, upnp_cb))
			return false;
		return true;
	}

	return false;
}

void CP2PClient::StopRealPlay()
{
	GetReqId(true);
	ZAutoCSLocker lock(&m_lock_rp);
	if (!m_pUserData)
    return;

	iter_rp it = m_rp.find(m_pUserData->reqid);
	if (it != m_rp.end()) {
		CUserData * pUserData = dynamic_cast<CUserData *>(it->second);
		if (pUserData) {
			ZAutoCSLocker lock(&pUserData->m_lock_req);
			if (pUserData->m_Stream) {
				delete pUserData->m_Stream;
				pUserData->m_Stream = NULL;
			}
			pUserData->status = req_status_canceled;
			m_pUserData = NULL;
		}
	}
}

void CP2PClient::p2p_nat_detect_cb(const z_nat_detect_result *res, void* user_data)
{
	CP2PClient* _this = (CP2PClient*)user_data;
	_this->m_pEvents->OnStatusReport(stNatType, res->nat_type, res->nat_desc);
}

bool CP2PClient::QueryNatType()
{
	if (PJ_SUCCESS != z_detect_nat_type(p2p_nat_detect_cb, this))
		return false;
	return true;
}

bool CP2PClient::UpdateZSipDNS(unsigned count, SIP_DNS * sip_dns)
{
	z_status_t status = -1;
	char ** ptr = new char* [count];
	ptr[0] = new char[count*PJ_DNS_RESOLVER_MAX_NS*sizeof(char)];
	int * ports = new int[count];

	if (ptr && ports)
	{
		for (int i=1; i<count; i++)
		{
			ptr[i] = ptr[i-1] + PJ_DNS_RESOLVER_MAX_NS;
		}

		for (int i=0; i<count; i++)
		{
			memset(ptr[i], 0, PJ_DNS_RESOLVER_MAX_NS);
			strcpy(ptr[i], sip_dns[i].server);
			ports[i] = sip_dns[i].port;
		}

		z_thread_register();
		status = zsip_update_dns(count, ptr, ports);
	}

	delete[] ptr[0];
	delete[] ptr;
	delete[] ports;

	return status == PJ_SUCCESS; 
}

bool CP2PClient::ChangeStream(int iChannel, int iNewMediaType, int operation)
{
	ZAutoCSLocker lock(&m_lock_rp);
	if (m_pUserData) {
		if (m_pUserData->m_Stream) {
			m_pUserData->m_iChannel = iChannel;
			m_pUserData->m_iMediaType = iNewMediaType;
			return m_pUserData->m_Stream->ReqStream(iChannel, iNewMediaType, operation);
		}
	}
	return false;
}

bool CP2PClient::EnableSound(bool bOpen)
{
	ZAutoCSLocker lock(&m_lock_rp);
	if (m_pUserData) {
		if (m_pUserData->m_Stream)
			return m_pUserData->m_Stream->ReqSound(m_pUserData->m_iChannel, bOpen);
	}
	return false;
}

bool CP2PClient::EnableTalk(bool bTalk)
{
	ZAutoCSLocker lock(&m_lock_rp);
	if (m_pUserData) {
		if (m_pUserData->m_Stream)
			return m_pUserData->m_Stream->ReqTalk(m_pUserData->m_iChannel, bTalk);
	}
	return false;
}

bool CP2PClient::SendTalkData(char * data, unsigned size /*= 164*/)
{
	bool bRet = false;
	ZAutoCSLocker lock(&m_lock_rp);
	if (m_pUserData) {
		if (m_pUserData->m_Stream) {
			unsigned nTalkDataLen = size + sizeof(trans_msg_s);
			char * pTalkData = new char[nTalkDataLen];
			if (pTalkData) {
				trans_msg_s *req_stream = (trans_msg_s*)pTalkData;
				req_stream->magic = htonl(0xFFFF559F);
				req_stream->channel = m_pUserData->m_iChannel;
				req_stream->cmd_type = 0;
				req_stream->cmd = htonl(PC_IPC_TRANSFER_DATA);
				req_stream->seqnum = 0;
				req_stream->length = htonl(size);

				memcpy(pTalkData+sizeof(trans_msg_s), data, size);
				bRet = m_pUserData->m_Stream->SendBuf(pTalkData, nTalkDataLen);

				delete[] pTalkData;
				pTalkData = NULL;
			}
		}
	}
	return bRet;
}

bool CP2PClient::EnableDVRTalk(bool bOpen)
{
	ZAutoCSLocker lock(&m_lock_rp);
	if (m_pUserData) {
		if (m_pUserData->m_Stream)
			return m_pUserData->m_Stream->ReqTalk(0xff, bOpen);
	}
	return false;
}

bool CP2PClient::SendDVRTalkData(char * data, unsigned size)
{
	bool bRet = false;
	ZAutoCSLocker lock(&m_lock_rp);
	if (m_pUserData) {
		if (m_pUserData->m_Stream) {
			unsigned nTalkDataLen = size + sizeof(trans_msg_s);
			char * pTalkData = new char[nTalkDataLen];
			if (pTalkData) {
				trans_msg_s *req_stream = (trans_msg_s*)pTalkData;
				req_stream->magic = htonl(0xFFFF559F);
				req_stream->channel = 0xff;
				req_stream->cmd_type = 0;
				req_stream->cmd = htonl(PC_IPC_TRANSFER_DATA);
				req_stream->seqnum = 0;
				req_stream->length = htonl(size);
				memcpy(pTalkData+sizeof(trans_msg_s), data, size);
				bRet = m_pUserData->m_Stream->SendBuf(pTalkData, nTalkDataLen);
				delete[] pTalkData;
				pTalkData = NULL;
			}
		}
	}
	return bRet;
}

bool CP2PClient::SendData(char * data, unsigned size)
{
	ZAutoCSLocker lock(&m_lock_rp);
	if (m_pUserData) {
		if (m_pUserData->m_Stream)
			return m_pUserData->m_Stream->SendBuf(data, size);
	}
	return false;
}

bool CP2PClient::PlayBack(const std::string& strDeviceId, int iChannel, int iMode, const std::string& strDateTime, void* pCookie)
{
	if (iMode == TRANSIT_MODE || iMode == UPNP_MODE) {
		if (m_sip_params.m_strCmuId.empty()) {
			if (m_pEvents) {
				if (iMode == TRANSIT_MODE)
					m_pEvents->OnStatusReport(stStream, ssPlayBackReqFailed, "sip server not response!!", pCookie);
				else if (iMode == UPNP_MODE)
					m_pEvents->OnStatusReport(stStream, ssPlayBackReqFailed, "sip server not response!!", pCookie);
			}
			return false;
		}
	}

	CUserData * pUserData = new CUserData;
	pUserData->reqid = GetReqId(true);
	pUserData->pCookie = this;
	pUserData->pUserCookie = pCookie;
	if (iMode == TRANSIT_MODE)
		pUserData->type = proto_p2p_playback; // 后续考虑中转或云存储的回放
	else if (iMode == P2P_MODE)
		pUserData->type = proto_p2p_playback;
	else if (iMode == UPNP_MODE)
		pUserData->type = proto_upnp_playback;
	pUserData->msTimeStamp = ZUtility::getTime();
	pUserData->status = req_status_requesting;

	pUserData->m_strDeviceId = strDeviceId;
	pUserData->m_iChannel = iChannel;
	pUserData->m_iMediaType = 3;  // 录像回放
	pUserData->m_Stream = NULL;
	pUserData->m_strDateTime = strDateTime;
	pUserData->m_pEvents = m_pEvents;
	AddRequest(pUserData);

	if (iMode == TRANSIT_MODE) {

	} else if (iMode == P2P_MODE) {
		zsip_p2p_request reqc;
		pj_memset(&reqc, 0, sizeof(reqc));
		reqc.method.id = ZSIP_OTHER_METHOD;
		reqc.method.name = "P2PREQUEST";
		reqc.contact[0] = (char*)m_sip_params.addr.client_ip.c_str();
		reqc.port[0] = 0;
		reqc.contact_cnt = 1;
		reqc.caller = (char*)m_sip_params.m_strUsrId.c_str();
		reqc.callee = (char*)strDeviceId.c_str();
		reqc.user_data = pUserData;
		reqc.content_subtype = "sdp";
		reqc.content_type = "application";
		char param[32] = {0};
		sprintf(param, "%d|%d", iChannel, pUserData->m_iMediaType);
		reqc.param = param;

		z_thread_register();
		if (PJ_SUCCESS != zsip_p2p_req(&reqc, p2p_cb))
			return false;
		return true;
	} else if (iMode == UPNP_MODE) {
		// 先UPNP查询，然后再查询回调中,处理连接
		Json::Value root;
		Json::FastWriter writer;
		root["MethodName"] = "dm.GetPuInfo";
		root["DevId"] = strDeviceId;
		std::string req_content = writer.write(root);

		zsip_request reqc;
		pj_memset(&reqc, 0, sizeof(reqc));
		reqc.method.id = ZSIP_OTHER_METHOD;
		reqc.method.name = "MESSAGE";
		reqc.contact[0] = (char*)m_sip_params.addr.server_ip.c_str();
		reqc.port[0] = 0;
		reqc.contact_cnt = 1;
		reqc.caller = "admin";
		reqc.callee = (char*)m_sip_params.m_strCmuId.c_str();
		reqc.user_data = pUserData;
		reqc.content = (char*)req_content.c_str();
		reqc.content_type = "text";
		reqc.content_subtype = "json";

		z_thread_register();
		if (PJ_SUCCESS != zsip_req(&reqc, upnp_cb))
			return false;
		return true;
	}

	return false;
}

bool CP2PClient::LoginUPNP(const std::string& strUserName, const std::string& strPassWord)
{
	ZAutoCSLocker lock(&m_lock_rp);
	if (m_pUserData) {
		if (m_pUserData->m_Stream)
      return m_pUserData->m_Stream->LoginUPNP(strUserName.c_str(), strPassWord.c_str());
	}
	return false;
}

bool CP2PClient::ChangePwdUPNP(const std::string& strUserName, const std::string& strPassWord)
{
	ZAutoCSLocker lock(&m_lock_rp);
	if (m_pUserData) {
		if (m_pUserData->m_Stream)
			return m_pUserData->m_Stream->ChangePwdUPNP(strUserName.c_str(), strPassWord.c_str());
	}
	return false;
}

int CP2PClient::AddRequest(CUserData * data)
{
	ZAutoCSLocker lock(&m_lock_rp);
	if (data->type == proto_p2p_play 
		|| data->type == proto_transit_play 
		|| data->type == proto_p2p_playback
		|| data->type == proto_upnp_play)
		m_pUserData = data;

	iter_rp it = m_rp.find(data->reqid);
	if (it != m_rp.end())
		delete it->second;
	m_rp[data->reqid] = data;
	return 0;
}

bool CP2PClient::CheckRequest()
{
	ZAutoCSLocker lock(&m_lock_rp);
	iter_rp it = m_rp.begin();
	while (it != m_rp.end())
	{
		ZAutoCSLocker lock(&it->second->m_lock_req);
		if (it->second->status == req_status_requesting)
		{
			uint64_t u_timeout = 10000000;
			if (it->second->type == proto_transit_play || it->second->type == proto_upnp_query)
				u_timeout = m_sip_params.m_SipReqTimeout;					// 中转和UPNP查询超时
			else if (it->second->type == proto_p2p_play || it->second->type == proto_p2p_playback || it->second->type == proto_upnp_play)
				u_timeout = m_sip_params.m_P2PReqTimeout;					// P2P和回放超时

			if (ZUtility::getTime() - it->second->msTimeStamp > u_timeout /*m_sip_params.m_msTimeoutReq*/)
			{
				if (it->second->reqid != CP2PClient::GetReqId())
				{
					it->second->status = req_status_canceled;
				}
				else
				{
					printf("-----------CP2PClient::CheckRequest() timeout-------------\n");
					it->second->status = req_status_timeout;
					if (m_pEvents) // 上报超时	
					{
						if (it->second->type == proto_p2p_play)
              m_pEvents->OnStatusReport(stStream, ssP2PConnectFailed, "p2p connect timeout", it->second->pUserCookie);
						else if (it->second->type == proto_transit_play)
							m_pEvents->OnStatusReport(stStream, ssDeliverConnectFailed, "transit connect timeout", it->second->pUserCookie);
						else if (it->second->type == proto_p2p_playback)
							m_pEvents->OnStatusReport(stStream, ssPlayBackReqFailed, "playback timeout", it->second->pUserCookie);
						else if (it->second->type == proto_upnp_query)
							m_pEvents->OnStatusReport(stUpnp, upnpQueryUpnpFailed, "upnp query timeout", it->second->pUserCookie);
					}
				}
			}
		}
		else if (it->second->status == req_status_registering)
		{
			if (ZUtility::getTime() - it->second->msTimeStamp > m_sip_params.m_RegisterTimeout)
			{
				it->second->status = req_status_canceled;		// req_status_canceled
				if (m_pEvents)
				{
					m_pEvents->OnStatusReport(stStream, ssDeliverConnectFailed, "deliver register timeout", it->second->pUserCookie);
				}
			}
		}
		else if (it->second->status == req_status_canceled)
		{
			if (it->second->m_Stream)
			{
				delete it->second->m_Stream;
				it->second->m_Stream = NULL;
			}
			it->second->status = req_status_process_complete;
		}

		if (it->second->status == req_status_process_complete)
		{
			m_rp_erase.push_back(static_cast<unsigned long>(it->first));
		}
		++it;
	}
	return true;
}

bool CP2PClient::ClearRequest()
{
	ZAutoCSLocker lock(&m_lock_rp);
	while (m_rp_erase.size())
	{
		std::list<unsigned long>::iterator it_e = m_rp_erase.begin();
		iter_rp it = m_rp.find(static_cast<unsigned long>(*it_e));
		if (it != m_rp.end())
		{
			if (!it->second)
			{
				if (it->second->m_Stream)
				{
					delete it->second->m_Stream;
					it->second->m_Stream = NULL; 
				}
				delete it->second;
				it->second = NULL;
			}
			m_rp.erase(it);
		}
		m_rp_erase.erase(it_e);
	}
	return true;
}

void CP2PClient::DelAllRequst()
{
	ZAutoCSLocker lock(&m_lock_rp);
	iter_rp it = m_rp.begin();
	while (m_rp.size())
	{
		if (it->second)
		{
			delete it->second;
			it->second = NULL;
		}
		
		m_rp.erase(it);
	}
}

void CP2PClient::DoWork()
{
	while (!m_bBasicClosing)
	{
		CheckRequest();
		ClearRequest();

#ifndef WIN32
		timeval t;
		gettimeofday(&t, 0);
		uint64_t exptime = t.tv_sec * 1000000ULL + t.tv_usec + 10 *1000ULL;
		timespec timeout;
		timeout.tv_sec = exptime / 1000000;
		timeout.tv_nsec = (exptime % 1000000) * 1000;
		pthread_cond_timedwait(&m_BasicStopCond, &m_BasicStopLock, &timeout);
#else
		WaitForSingleObject(m_BasicStopCond, 10);
#endif
	}
}

bool CP2PClient::PTZConfig(PTZ_CMD_E ptz_cmd, unsigned short para0, unsigned short para1)
{
	ZAutoCSLocker lock(&m_lock_rp);
	if (m_pUserData) {
		if (m_pUserData->m_Stream)
      return m_pUserData->m_Stream->ReqPTZConfig(ptz_cmd, para0, para1);
	}
	return false;
}

bool CP2PClient::GetPTZPreset()
{
	ZAutoCSLocker lock(&m_lock_rp);
	if (m_pUserData) {
		if (m_pUserData->m_Stream)
      return m_pUserData->m_Stream->ReqPTZPreset();
	}
	return false;
}