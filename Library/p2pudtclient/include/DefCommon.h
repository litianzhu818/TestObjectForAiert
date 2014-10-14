#ifndef DefCommon_h
#define DefCommon_h

#ifdef __GNUC__

#include <tr1/functional>
#include <tr1/memory>

inline long atomic_add(volatile long *intp, long val)
{
	return __sync_fetch_and_add(intp, val);
}

#else

#include <functional>
#include <memory>
#include <Windows.h>

inline long atomic_add(volatile long *intp, long val)
{
	return InterlockedExchangeAdd(intp, val);
}

#endif // for __GNUC__

class CDefAtomic
{
public:

	CDefAtomic(long initial = 0)
	{
		Set(initial);
	}
	~CDefAtomic()
	{
	}

	inline long Get()
	{
		return m_Value;
	}
	inline void Set(long Value)
	{
		m_Value = Value;
	}
	inline long Inc()
	{
		return Add(1);
	}
	inline long Dec()
	{
		return Add(-1);
	}
	inline long Add(long Value)
	{
		return atomic_add(&m_Value, Value);
	}
private:
	volatile long m_Value;
};

template<class LockerT>
class CAutoLock
{
public:
	CAutoLock(LockerT& Locker) : m_Locker(Locker), m_bLocked(false)
	{
		m_Locker.lock();
		m_bLocked = true;
	}
	~CAutoLock()
	{
		unlock();
	}
	void unlock()
	{
		if (m_bLocked) m_Locker.unlock();
		m_bLocked = false;
	}
private:
	LockerT& m_Locker;
	bool m_bLocked;
};

class PJString;
class PJException;

class CLockerFree
{
public:
	void lock() {}
	void unlock() {}
	bool try_lock() { return true; }
};

enum ELogLevel { llFatal, llError, llWarning, llInfo, llDebug, llTrace, llDETRC };
/*#define llFatal		0
#define llError		1
#define llWarning	2
#define llInfo		3
#define llDebug		4
#define llTrace		5
#define llDETRC		6
*/
#define DefLog			PJ_LOG
#define DefAssert		assert
#define DefStringList	PJStringList
#define DefString		PJString
#define DefException	PJException
#define DefLocker		CPJLockerMutex
//
//#include <android/log.h>
//#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, "zsip", __VA_ARGS__))
//#define LOGW(...) ((void)__android_log_print(ANDROID_LOG_WARN, "zsip", __VA_ARGS__))
//#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, "zsip", __VA_ARGS__))

#define C_DefIntFormat		"%d"
#define C_DefSListDelimiter	";"
#define C_DefLinesDelimiter "\r\n"

#define DEF_CPP_TRY try {
#define DEF_CPP_CATCH(FuncName) \
	} catch (DefException& e) { LOGE("%s(): %s\n", FuncName, e.what()); \
	} catch (...) { LOGE("%s(): Unknown error!", FuncName); }

const int C_MaxStrBufSize = 10240;

#endif // for DefCommon_h
