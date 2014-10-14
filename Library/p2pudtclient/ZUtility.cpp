#include "ZUtility.h"

ZCriticalSection::ZCriticalSection()
{
#ifdef _WIN32
	InitializeCriticalSection(&m_cs);
#else
	pthread_mutex_init(&m_cs, NULL);
#endif
}

ZCriticalSection::~ZCriticalSection()
{
#ifdef _WIN32
	DeleteCriticalSection(&m_cs);
#else
	pthread_mutex_destroy(&m_cs);
#endif
}

int ZCriticalSection::Lock()
{
#ifdef _WIN32
	EnterCriticalSection(&m_cs);
	return 0;
#else
	return pthread_mutex_lock(&m_cs);
#endif
}

int ZCriticalSection::UnLock()
{
#ifdef _WIN32
	LeaveCriticalSection(&m_cs);
	return 0;
#else
	return pthread_mutex_unlock(&m_cs);
#endif
}

uint64_t ZUtility::getTime()
{
#ifndef WIN32
	timeval t;
	gettimeofday(&t, 0);
	return t.tv_sec * 1000000ULL + t.tv_usec;
#else
	LARGE_INTEGER ccf;
	HANDLE hCurThread = ::GetCurrentThread(); 
	DWORD_PTR dwOldMask = ::SetThreadAffinityMask(hCurThread, 1);
	if (QueryPerformanceFrequency(&ccf))
	{
		LARGE_INTEGER cc;
		if (QueryPerformanceCounter(&cc))
		{
			SetThreadAffinityMask(hCurThread, dwOldMask); 
			return (cc.QuadPart * 1000000ULL / ccf.QuadPart);
		}
	}

	SetThreadAffinityMask(hCurThread, dwOldMask); 
	return GetTickCount() * 1000ULL;
#endif
}