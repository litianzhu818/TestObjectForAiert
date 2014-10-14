#include "TcpStream.h"

#ifdef _WIN32
WSAInitializer TcpStream::_Initializer_;
#endif
TcpStream::TcpStream(int connect_type)
: Stream(connect_type)
, m_Socket(INVALID_SOCKET)
{
}

TcpStream::~TcpStream(void)
{
	CloseStream();
}

bool TcpStream::OpenStream(const char* r_IP, int r_port, const char* /*base_ip*/, int /*base_port*/)
{
	m_Socket = ::socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	if (INVALID_SOCKET == m_Socket)
	{
#ifdef ANDROID
		LOGI("tcp socket: %d ", Errno);
#else
		printf("tcp socket: %d \n", Errno);
#endif
		return false;
	}

	struct sockaddr_in servAddr;
	memset(&servAddr, 0, sizeof(sockaddr_in));
	servAddr.sin_family = AF_INET;
#ifdef _WIN32
	servAddr.sin_addr.S_un.S_addr = inet_addr(r_IP);
#else
	servAddr.sin_addr.s_addr = inet_addr(r_IP);
#endif
	servAddr.sin_port = htons(r_port);

#ifndef _WIN32
	int snd_buf = 8000;
	int rcv_buf = 80000;
	setsockopt(m_Socket, 0, SO_SNDBUF, &snd_buf, sizeof(int));
	setsockopt(m_Socket, 0, SO_RCVBUF, &rcv_buf, sizeof(int));
#endif

	if (SOCKET_ERROR == connect(m_Socket, (sockaddr *)&servAddr, sizeof(sockaddr_in)))
	{
#ifdef ANDROID
		LOGI("tcp connect: %d ", Errno);
#else
		printf("tcp connect: %d \n", Errno);
#endif
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
	m_last_recv_data_time = m_stream_create_time = 0;
	return StartBasicThread();
}

void TcpStream::CloseStream()
{
	if (!m_bStatus)
		return;

	m_bStop = true;
	// 停止线程 结束心跳和统计
	StopBasicThread();

	shutdown(m_Socket, 2);	// RDWR

	if (m_Socket != INVALID_SOCKET)
	{
#ifdef _WIN32
		closesocket(m_Socket);
#else
		close(m_Socket);
#endif
		m_Socket = INVALID_SOCKET;
	}

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

void TcpStream::OnRecv()
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
		if (-1 == flag)
		{
			break;
		}
		
		if (flag == 0)
		{
			int rsize = ::recv(m_Socket, buffer+buffer_size, max_size-buffer_size, 0);
			if (rsize <= 0)
			{
#ifdef ANDROID
				LOGI("tcp recv: %d ", Errno);
#else
				printf("tcp recv: %d \n", Errno);
#endif
                ZAutoCSLocker lock(&m_lock_recv_status);
                if (m_last_recv_data_time != 0)
                {
				if (m_pEvents && !m_bStop)
            m_pEvents->OnStatusReport(stStream, ssDeliverRecvFailed, "transit recv failed", m_pHandle->pUserCookie);
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

bool TcpStream::SendBuf(char * data, unsigned size)
{
	unsigned ssize = 0;
	int ss;
	while (ssize < size)
	{
		ss = send(m_Socket, data + ssize, size - ssize, 0);
		if (ss <= 0)
		{
#ifdef ANDROID
			LOGI("tcp send: %d ", Errno);
#else
			printf("tcp send: %d \n", Errno);
#endif
			break;
		}
		ssize += ss;
	}
	printf("-$");
	return ssize == size;
}

bool TcpStream::ReqLogin(const char * register_code, const char * username_or_sn)
{
	char szCmd[128] = {0};
	char *pCmd = szCmd;
	trans_msg_s *req_stream = (trans_msg_s*)pCmd;
	req_stream->magic = htonl(0xFFFF559F);
	req_stream->cmd_type = htons(1);
	req_stream->cmd = htonl(PC_TRANS_LOGIN_SYN);
	req_stream->seqnum = GetMsgNo();
	req_stream->length = htonl(sizeof(tf_login_syn_s));

	tf_login_syn_s *pBody = (tf_login_syn_s*)(szCmd+sizeof(trans_msg_s));
	memcpy(pBody->register_code, register_code, strlen(register_code));
	memcpy(pBody->username_or_sn, username_or_sn, strlen(username_or_sn));

	return SendBuf((char*)&szCmd, sizeof(trans_msg_s)+sizeof(tf_login_syn_s));
}

bool TcpStream::SetNonblocking(bool bNb)
{
	bool bRet = true;
#ifdef _WIN32
	unsigned long l = bNb ? 1 : 0;
	int n = ioctlsocket(m_Socket, FIONBIO, &l);
	if (n != 0)
	{
		bRet = false;
	}
#else
	int flag = 0;
	flag = fcntl(m_Socket, F_GETFL, 0);
	if (bNb)
		flag |= O_NONBLOCK;
	else
		flag  = flag & (~O_NONBLOCK);
	if (fcntl(m_Socket, F_SETFL, flag) == -1)
	{
		bRet = false;
	}
#endif
	return bRet;
}

int TcpStream::OnKeepalive()
{
	// 心跳包
	trans_msg_s keepalive;
	memset(&keepalive, 0, sizeof(trans_msg_s));
	keepalive.magic = htonl(0xFFFF559F);
	keepalive.cmd_type = htons(1);
	keepalive.cmd = htonl(PC_TRANS_HEART_SYN);

	// 发送心跳包
	keepalive.seqnum = htonl(GetMsgNo());
	if (!SendBuf((char*)&keepalive, sizeof(trans_msg_s)))
	{
		return -1;
	}
	return 0;
}

