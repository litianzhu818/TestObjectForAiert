#include "UdtStream.h"
#include "zsip.h"

UdtStream::UdtStream(int connect_type)
: Stream(connect_type)
, m_Socket(UDT::INVALID_SOCK)
{
  	UDT::startup();
}

UdtStream::~UdtStream(void)
{
	CloseStream();
  UDT::cleanup();
}

static z_status_t z_getdefaultipinterfaceIPv4(char * l_addr, unsigned maxlen)
{
	pj_status_t status;
	pj_sockaddr addr;

	status = pj_getdefaultipinterface(PJ_AF_INET, &addr);
	if (PJ_SUCCESS == status)
	{
		strncpy(l_addr, pj_inet_ntoa(addr.ipv4.sin_addr), maxlen);
	}
	return status;
}

bool UdtStream::OpenStream(const char* r_IP, int r_port, const char* base_ip, int base_port)
{
	m_Socket = UDT::socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (INVALID_SOCKET == m_Socket)
	{
		printf("socket: %s \n", UDT::getlasterror().getErrorMessage());
		return false;
	}

	struct sockaddr_in baseAddr, servAddr;
	memset(&baseAddr, 0, sizeof(sockaddr_in));
	memset(&servAddr, 0, sizeof(sockaddr_in));
	baseAddr.sin_family = AF_INET;  
	//baseAddr.sin_addr.S_un.S_addr = inet_addr(base_ip);
	//baseAddr.sin_port = htons(base_port);

	servAddr.sin_family = AF_INET;
#ifdef _WIN32
	servAddr.sin_addr.S_un.S_addr = inet_addr(r_IP);
#else
	servAddr.sin_addr.s_addr = inet_addr(r_IP);
#endif
	servAddr.sin_port = htons(r_port);

	int snd_buf = 800000;
	int rcv_buf = 800000;
	UDT::setsockopt(m_Socket, 0, UDT_SNDBUF, &snd_buf, sizeof(int));
	UDT::setsockopt(m_Socket, 0, UDT_RCVBUF, &rcv_buf, sizeof(int));
	snd_buf = 80000;
	rcv_buf = 80000;
	UDT::setsockopt(m_Socket, 0, UDP_SNDBUF, &snd_buf, sizeof(int));
	UDT::setsockopt(m_Socket, 0, UDP_RCVBUF, &rcv_buf, sizeof(int));
	int mss = 1052;
	UDT::setsockopt(m_Socket, 0, UDT_MSS, &mss, sizeof(int));
	
	struct linger l = {1, 0};
	UDT::setsockopt(m_Socket, 0, UDT_LINGER, &l, sizeof(l)); // 设置Linger time on close().

	if (base_port == 0)
	{
		char l_addr[ZSIP_MAX_ADDR_LEN] = {0};
		if (PJ_SUCCESS == z_getdefaultipinterfaceIPv4(l_addr, ZSIP_MAX_ADDR_LEN))
		{
#ifdef _WIN32
			baseAddr.sin_addr.S_un.S_addr = inet_addr(l_addr);
#else
			baseAddr.sin_addr.s_addr = inet_addr(l_addr);
#endif

      baseAddr.sin_port = 0;
      if (UDT::ERROR == UDT::bind(m_Socket, (sockaddr*)&baseAddr, sizeof(sockaddr_in)))
        return false;
		}
	}
	else
	{
#ifdef _WIN32
		baseAddr.sin_addr.S_un.S_addr = inet_addr(base_ip);
#else
		baseAddr.sin_addr.s_addr = inet_addr(base_ip);
#endif

		baseAddr.sin_port = htons(base_port);
		if (UDT::ERROR == UDT::bind(m_Socket, (sockaddr*)&baseAddr, sizeof(sockaddr_in)))
		{
			printf("bind: %s \n", UDT::getlasterror().getErrorMessage());
			return false;
		}
	}

	if (SOCKET_ERROR == UDT::connect(m_Socket, (sockaddr *)&servAddr, sizeof(sockaddr_in)))
	{
		printf("connect: %s \n", UDT::getlasterror().getErrorMessage());
		return false;
	}

#ifndef WIN32
	pthread_mutex_init(&m_StopLock, NULL);
	pthread_cond_init(&m_StopCond, NULL);
	if (0 != pthread_create(&m_Thread, NULL, ThreadRecvStream, this))
	{
		m_bClosing = true;
		return false;
	}
#else
	m_StopLock = CreateMutex(NULL, false, NULL);
	m_StopCond = CreateEvent(NULL, false, false, NULL);
	DWORD ThreadID;
	m_Thread = CreateThread(NULL, 0, ThreadRecvStream, this, 0, &ThreadID);
	if (!m_Thread)
	{
		m_bClosing = true;
		return false;
	}
#endif

	m_bStatus = true;
	m_bStop = false;
	m_last_recv_data_time = m_stream_create_time = ZUtility::getTime();
	return StartBasicThread();
}


struct trans_msg_req_stream
{
	char mediaType;			// 0:qvga 1:vga 2:720p
	char channel;			// 
	char operation;			// 0:关闭通道, 1:打开通道
	char reserve;
	char link_id[32];
};

bool UdtStream::ReqStream(int iChannel, int iMediaType, int operation)
{
	char szCmd[128] = {0};
	char *pCmd = szCmd;
	trans_msg_s *req_stream = (trans_msg_s*)pCmd;
	req_stream->magic = htonl(0xFFFF559F);
	req_stream->cmd_type = 0;
	req_stream->cmd = htonl(PC_IPC_MEDIA_TYPE_SYN);
	req_stream->seqnum = htonl(GetMsgNo());
	req_stream->length = htonl(sizeof(trans_msg_req_stream));

	trans_msg_req_stream *pBody = (trans_msg_req_stream *)(szCmd+sizeof(trans_msg_s));
	pBody->mediaType = iMediaType;
	pBody->channel = iChannel;
	pBody->operation = operation;

	bool bChangeing = false;
	{
		ZAutoCSLocker lock(&m_stream_change_status);
		if (m_stream_change_time == 0)
			m_stream_change_time = ZUtility::getTime();
		else
			bChangeing = true;
	}

	if (!bChangeing)
		return SendBuf((char*)&szCmd, sizeof(trans_msg_s)+sizeof(trans_msg_req_stream));
	else
		return false;
}

bool UdtStream::ReqStopStream()
{
	char szCmd[128] = {0};
	char *pCmd = szCmd;
	trans_msg_s *req_stop_stream = (trans_msg_s*)pCmd;

	req_stop_stream->magic = htonl(0xFFFF559F);
	req_stop_stream->cmd_type = 0;
	req_stop_stream->cmd = htonl(PC_IPC_STOP_MEDIA_SYN);
	req_stop_stream->seqnum = GetMsgNo();
	req_stop_stream->length = htonl(32);

	char szLinkId[32] = {0};
	memcpy(szCmd+sizeof(trans_msg_s), szLinkId, sizeof(szLinkId));
	return SendBuf(szCmd, sizeof(trans_msg_s)+sizeof(szLinkId));
}

void UdtStream::CloseStream()
{
	if (!m_bStatus)
		return;

	m_bStop = true;
	// 停止线程 结束心跳和统计
	StopBasicThread();

	
	UDT::close(m_Socket);

	m_bClosing = true;
#ifndef WIN32
	pthread_cond_signal(&m_StopCond);
	pthread_join(m_Thread, NULL);
	pthread_mutex_destroy(&m_StopLock);
	pthread_cond_destroy(&m_StopCond);
#else
	SetEvent(m_StopCond);
	WaitForSingleObject(m_Thread, INFINITE);
	CloseHandle(m_Thread);
	CloseHandle(m_StopLock);
	CloseHandle(m_StopCond);
#endif

	m_bStatus = false;
}

void UdtStream::OnRecv()
{
	int max_size = 1024*40;
	char* buffer = new char[max_size];
	if (!buffer)
		return;

	unsigned buffer_size = 0;

	int flag = 0;

	while (!m_bClosing)
	{
		flag = ParseStreamUnit(buffer, buffer_size);
		if (flag == 0)
		{
			int rsize = UDT::recv(m_Socket, buffer+buffer_size, max_size-buffer_size, 0);
			if (rsize <= 0)
			{
				if (m_pEvents && !m_bStop)
				{
          if (GetConnectMode() == UPNP_MODE)
            m_pEvents->OnStatusReport(stStream, ssUPNPRecvFailed, "upnp recv failed", m_pHandle->pUserCookie);
          else if (GetConnectMode() == P2P_MODE)
            m_pEvents->OnStatusReport(stStream, ssP2PRecvFailed, "p2p recv failed", m_pHandle->pUserCookie);
				}

				break;
			}
			buffer_size += rsize;		
		}

#ifndef WIN32
		timeval now;
		timespec timeout;
		gettimeofday(&now, 0);
		timeout.tv_sec = now.tv_sec;
		timeout.tv_nsec = now.tv_usec * 1000;

		pthread_cond_timedwait(&m_StopCond, &m_StopLock, &timeout);
#else
		WaitForSingleObject(m_StopCond, 0);
#endif
	}
	delete [] buffer;
	buffer = NULL;
}

bool UdtStream::SendBuf(char * data, unsigned size)
{
	unsigned ssize = 0;
	int ss;
	
	while (ssize < size)
	{
		ss = UDT::send(m_Socket, data + ssize, size - ssize, 0);
		if (ss <= 0)
		{
			break;
		}

		ssize += ss;
	}
	printf("-$");
	return ssize == size;
}

int UdtStream::OnKeepalive()
{
	trans_msg_s keepalive;
	memset(&keepalive, 0, sizeof(trans_msg_s));
	keepalive.magic = htonl(0xFFFF559F);
	keepalive.cmd_type = htons(0);
	keepalive.cmd = htonl(PC_IPC_HEART_SYN);

	// 发送心跳包
	keepalive.seqnum = htonl(GetMsgNo());
	if (!SendBuf((char*)&keepalive, sizeof(trans_msg_s)))
	{
		return -1;
	}
	return 0;
}
