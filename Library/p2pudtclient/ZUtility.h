#ifndef __ZMD_UTILITY_H__
#define __ZMD_UTILITY_H__

#ifdef _WIN32
	#define WIN32_LEAN_AND_MEAN
	#include <windows.h>
	#include <winsock2.h>
	#include <ws2tcpip.h>
	#pragma comment(lib, "ws2_32.lib")
#else
	#include <unistd.h>
	#include <pthread.h>
	#include <cstring>
	#include <sys/socket.h>
	#include <sys/time.h>
	#include <arpa/inet.h>
	#include <sys/types.h>
	#include <fcntl.h>
	#include <errno.h>
	#include <netdb.h>
#endif

#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <list>
#include <map>
using namespace std;

#ifdef ANDROID
	#include <android/log.h>
	#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, "p2pclient", __VA_ARGS__))
	#define LOGW(...) ((void)__android_log_print(ANDROID_LOG_WARN, "p2pclient", __VA_ARGS__))
	#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, "p2pclient", __VA_ARGS__))
#endif

#include "zsip.h"
#include "protocol.h"

#define MAX_FRAME_SIZE 1024*512  // 包缓冲

#ifdef _WIN32
class WSAInitializer
{
public:
	WSAInitializer(BYTE minorVer = 2, BYTE majorVer = 2)
	{
		WSADATA wsaData;
		if (::WSAStartup(MAKEWORD(minorVer, majorVer), &wsaData) != 0)
		{
			exit(0);
		}
	}
	~WSAInitializer()
	{
		::WSACleanup();
	}
};
#endif


#ifdef _WIN32
	#define Errno WSAGetLastError()

	typedef HANDLE pthread_t;
	typedef HANDLE pthread_mutex_t;
	typedef HANDLE pthread_cond_t;
	typedef DWORD pthread_key_t;

	typedef __int32 int32_t;
	typedef __int64 int64_t;
	#ifndef LEGACY_WIN32
		typedef unsigned __int64 uint64_t;
	#else
		typedef __int64 uint64_t;
	#endif

	typedef	CRITICAL_SECTION ZMD_CRITICAL_SECTION;
#else
	typedef int SOCKET;
	#define Errno errno
	#ifndef INVALID_HANDLE_VALUE
		#define INVALID_HANDLE_VALUE	(-1)
	#endif
	#ifndef INVALID_SOCKET
		#define INVALID_SOCKET			(-1)
	#endif
	#ifndef SOCKET_ERROR
		#define SOCKET_ERROR            (-1)
	#endif

	typedef	pthread_mutex_t ZMD_CRITICAL_SECTION;
#endif

#ifndef DISALLOW_COPY_AND_ASSIGN
#define DISALLOW_COPY_AND_ASSIGN(TypeName) \
	TypeName(const TypeName&);               \
	void operator=(const TypeName&)
#endif

class BasicThread
{
public:
	BasicThread(void)
	{
		m_bBasicClosing = false;
		m_bThreadStatus = false;
	}
	~BasicThread(void)
	{
	}

	// 工作函数
	virtual void DoWork() = 0;

protected:
#ifndef WIN32
	static void * WorkThread(void* param)
#else
	static DWORD WINAPI WorkThread(LPVOID param)
#endif 
	{
		BasicThread *p = (BasicThread*)param;
		p->DoWork();
		return 0;
	}

	bool StartBasicThread()
	{
		if (m_bThreadStatus)
			return true;

		m_bBasicClosing = false;
#ifndef WIN32
		pthread_mutex_init(&m_BasicStopLock, NULL);
		pthread_cond_init(&m_BasicStopCond, NULL);
		if (0 != pthread_create(&m_BasicThread, NULL, WorkThread, this))
			m_bBasicClosing = true;
#else
		m_BasicStopLock = CreateMutex(NULL, false, NULL);
		m_BasicStopCond = CreateEvent(NULL, false, false, NULL);
		DWORD ThreadID;
		m_BasicThread = CreateThread(NULL, 0, WorkThread, this, 0, &ThreadID);
		if (!m_BasicThread)
			m_bBasicClosing = true;
#endif
		m_bThreadStatus = true;

		return !m_bBasicClosing;
	}
	void StopBasicThread()
	{
		if (!m_bThreadStatus)
			return;

		m_bBasicClosing = true;
#ifndef WIN32
		pthread_cond_signal(&m_BasicStopCond);
		pthread_join(m_BasicThread, NULL);
		pthread_mutex_destroy(&m_BasicStopLock);
		pthread_cond_destroy(&m_BasicStopCond);
#else
		SetEvent(m_BasicStopCond);
		WaitForSingleObject(m_BasicThread, INFINITE);
		CloseHandle(m_BasicThread);
		CloseHandle(m_BasicStopLock);
		CloseHandle(m_BasicStopCond);
#endif
		m_bThreadStatus = false;
	}

protected:	
	volatile bool m_bBasicClosing;
	pthread_mutex_t m_BasicStopLock;
	pthread_cond_t m_BasicStopCond;
	pthread_t m_BasicThread;
	bool m_bThreadStatus;
};

class ZCriticalSection
{
public:
	ZCriticalSection();
	~ZCriticalSection();

	int Lock();
	int UnLock();

private:
	ZMD_CRITICAL_SECTION m_cs;
};

class ZAutoCSLocker
{
public:
	inline ZAutoCSLocker(ZCriticalSection* pcs)
		: m_pCS(pcs)
	{
		m_pCS->Lock();
	}
	~ZAutoCSLocker()
	{
		m_pCS->UnLock();
	}
private:
	ZAutoCSLocker(const ZAutoCSLocker&);
	ZAutoCSLocker& operator=(const ZAutoCSLocker&);

	ZCriticalSection* m_pCS;
};
typedef ZCriticalSection ZCRIT;

class ZUtility
{
public:
	static uint64_t getTime();
};

class CSipParams
{
public:
	struct P2P_ADDR
	{
		std::string client_ip;
		std::string stun_ip;
		std::string server_ip;
		std::string client_port;
		std::string stun_port;
		std::string server_port;
	};

	CSipParams() 
	{
		m_zisp_msg_cb = NULL;
		m_SipKeepAlive = 0;
		m_SipReqTimeout = 0;
		m_P2PReqTimeout = 0;
		m_RegisterTimeout = 0;
		m_LoginTimeout = 0;

		m_StreamKeepAlive = 0;
		m_StreamTimeout = 0;
		UserType= 0;
		ClientType = 0;

		m_Pool = NULL;
		m_ThreadID = NULL;
		m_bTerminated = false;
		m_bThreadStatus = false;
		m_bInit = false;
	}

	P2P_ADDR addr;
	zsip_msg_cb m_zisp_msg_cb;

	std::string m_strCmuId;
	std::string m_strTokenId;
	std::string m_strUsrId;

	uint64_t m_SipKeepAlive;
  uint64_t m_SipKeepAliveData;
	uint64_t m_SipReqTimeout;
	uint64_t m_P2PReqTimeout;
	uint64_t m_RegisterTimeout;
	uint64_t m_LoginTimeout;

	uint64_t m_StreamKeepAlive;
	uint64_t m_StreamTimeout;

	int UserType;
	int ClientType;
	z_time_val m_keepAliveDelay;

	z_pool_t* m_Pool;
	pj_thread_t* m_ThreadID;
	bool m_bTerminated;
	bool m_bThreadStatus;
	bool m_bInit;
};

struct SIP_DNS
{
	char server[20];
	int port;
};

enum CONNECT_MODE
{
	TRANSIT_MODE,
	P2P_MODE,
	UPNP_MODE,
};


#endif /*__ZMD_UTILITY_H__*/

