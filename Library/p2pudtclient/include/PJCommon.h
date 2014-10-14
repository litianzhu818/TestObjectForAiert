#ifndef PJCommon_h
#define PJCommon_h

#include <exception>
#include <pjlib.h>
#include <pjlib-util.h>
#include <StrTools.h>

#define IsPJStrLike		IsLike< CStringLike<PJString> >

extern pj_caching_pool g_PJMemFactory;
extern pj_pool_t* g_PJMemPool;

const int C_PJMemFactorySize = (2 * 1024 * 1024);
const int C_PJMemPoolSize = 4096;

#ifdef _WIN32

class PJException : public std::exception
{
public:
	PJException(const char* what, int err_num = -1) : std::exception(what), m_iErrNum(err_num) {}
	int err_num() { return m_iErrNum; }
private:
	int m_iErrNum;
};

#else

class PJException : public std::exception
{
public:
	PJException(const char* what, int err_num = -1) : m_strWhat(what), m_iErrNum(err_num) {}
    virtual ~PJException() throw() {}
    virtual const char* what() const throw()
    {
        return m_strWhat.c_str();
    }
	int err_num() { return m_iErrNum; }
private:
    std::string m_strWhat;
	int m_iErrNum;
};

#endif

class PJString : public std::string
{
public:
	PJString(pj_str_t Str) : std::string((const value_type*)Str.ptr, Str.slen) {}
	inline PJString& operator=(pj_str_t Str)
	{
		assign((const value_type*)Str.ptr, (size_type)Str.slen);
		return *this;
	}
	inline operator const pj_str_t&() const { return PJStr(); }
	inline operator const pj_str_t*() const { return &PJStr(); }
	inline const pj_str_t& PJStr() const
	{
		pj_str_t *p = (pj_str_t*)(&m_pjstr);
		p->ptr = const_cast<char*>(c_str());
		p->slen = (int)size();
		return *p;
	}
public:
	PJString(const std::string& Str) : std::string(Str) {}
	PJString(const value_type* pStr = NULL) { if (pStr) assign(pStr); }
	PJString(const value_type* pStr, std::string::size_type _Count) { if (pStr) assign(pStr, _Count); }

	inline PJString& operator=(const PJString& Str) { assign(Str.c_str(), Str.size()); return *this; }
	inline PJString& operator+=(const PJString& Str) { append(Str); return *this; }
	inline PJString& operator+=(value_type Char) { push_back(Char); return *this; }
	inline const std::string& str() const { return *this; }
private:
	pj_str_t m_pjstr;
};

struct PJTime : public pj_time_val
{
	PJTime(pj_time_val& Value)
	{
		*this = Value;
	}
	PJTime(int iMilliseconds = 0)
	{
		set(iMilliseconds);
	}
	inline void set(int iMilliseconds = 0)
	{
		sec = iMilliseconds / 1000;
		msec = iMilliseconds % 1000;
	}
	inline PJTime& now()
	{
		pj_gettickcount(this);
		return *this;
	}
	inline PJTime& operator+=(const PJTime& Value)
	{
		PJ_TIME_VAL_ADD(*this, Value);
		return *this;
	}
	inline PJTime& operator-=(const PJTime& Value)
	{
		PJ_TIME_VAL_SUB(*this, Value);
		return *this;
	}
	inline PJTime operator+(const PJTime& Value)
	{
		PJTime NewValue = *this;
		PJ_TIME_VAL_ADD(NewValue, Value);
		return NewValue;
	}
	inline PJTime operator-(const PJTime& Value)
	{
		PJTime NewValue = *this;
		PJ_TIME_VAL_SUB(NewValue, Value);
		return NewValue;
	}
	inline bool operator>(const PJTime& Value)
	{
		return PJ_TIME_VAL_GT(*this, Value);
	}
	inline bool operator<(const PJTime& Value)
	{
		return PJ_TIME_VAL_LT(*this, Value);
	}
	inline bool operator==(const PJTime& Value)
	{
		return PJ_TIME_VAL_EQ(*this, Value);
	}
};

typedef CStringListBasic< std::vector<PJString> > PJStringList;

inline void PJCheckError(pj_status_t status, const PJString& strErrInfo)
{
    if (status != PJ_SUCCESS)
		throw PJException(strErrInfo.c_str());
}

class CPJAtomic
{
public:
	CPJAtomic(pj_atomic_value_t initial = 0, pj_pool_t *pool = NULL)
	{
		if (pool == NULL) pool = g_PJMemPool;
		PJCheckError(pj_atomic_create(pool, initial, &m_pValue),
			"PJAtomic::PJAtomic() pj_atomic_create() error!");
	}
	~CPJAtomic()
	{
		pj_atomic_destroy(m_pValue);
	}

	inline pj_atomic_value_t Get()
	{
		return pj_atomic_get(m_pValue);
	}
	inline void Set(pj_atomic_value_t Value)
	{
		pj_atomic_set(m_pValue, Value);
	}
	inline pj_atomic_value_t Inc()
	{
		return pj_atomic_inc_and_get(m_pValue);
	}
	inline pj_atomic_value_t Dec()
	{
		return pj_atomic_dec_and_get(m_pValue);
	}
private:
	pj_atomic_t* m_pValue;
};

int InitPJLib(const PJString& strLogFileName = PJString());
void UninitPJLib();
pj_sockaddr_in PJStrToAddr(const PJString& strAddress);
void PJRegisterThread();

#endif // for PJCommon_h
