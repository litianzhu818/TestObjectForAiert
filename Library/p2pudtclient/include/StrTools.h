#ifndef __StrTools_H_
#define __StrTools_H_

#include <stdio.h>
#include <vector>
#include <string>
#include <stdarg.h>

#include "DefCommon.h"

#ifdef USE_WSTRING

#ifndef DefString
#define DefString		WString
#endif

//#define ACE_HAS_ICONV 1
//#define USE_mbstowcs 1

#ifdef USE_nsAString
#include <nsStringAPI.h>
#endif

#ifdef XP_WIN
#include <windows.h>
#elif defined(USE_mbstowcs)
#include <stdlib.h>
#elif defined(ACE_HAS_ICONV)
#include <iconv.h>
#endif

template<class FromT, class ToT>
inline ToT& IConConvert(const FromT& FromStr, ToT& ToStr, bool bToWChar);

inline std::string WStrToMBS(const std::wstring& Value)
{
	std::string Str;
	return IConConvert(Value, Str, false);
}

inline std::wstring MBSToWStr(const std::string& Value)
{
	std::wstring WStr;
	return IConConvert(Value, WStr, true);
}

inline std::string ConvertStr(std::wstring& WStr)
{
	return WStrToMBS(WStr);
}
inline std::wstring ConvertStr(std::string& Str)
{
	return MBSToWStr(Str);
}

#define HAVE_CPP_2BYTE_WCHAR_T 1

#ifdef HAVE_CPP_2BYTE_WCHAR_T
typedef std::wstring WStringBase;
#else
#include <nsCharTraits.h>
typedef basic_string< PRUnichar, nsCharTraits<PRUnichar>, allocator<PRUnichar> > WStringBase;
#endif

#ifdef USE_nsAString
class WString : private nsStringContainer_base, public WStringBase
{
public:
	WString(const nsAString& Str) : WStringBase((const value_type*)Str.BeginReading(), (WStringBase::size_type)Str.Length()) {}
	inline WString& operator=(const nsAString& Str)
	{
		assign((const value_type*)Str.BeginReading(), (WStringBase::size_type)Str.Length());
		return *this;
	}
	inline operator const nsString&() const { return nsStr(); }
	inline const nsString& nsStr() const
	{
		nsStringContainer_base *p = (nsStringContainer_base*)(this);
		p->d1 = (void*)c_str();
		p->d2 = (PRUint32)size();
		p->d3 = 1;
		return *(nsString*)p;
	}
#else
class WString : public WStringBase
{
#endif
public:
	WString() {}
	WString(const WStringBase& Str) : WStringBase(Str) {}
	WString(const value_type* pStr) : WStringBase(pStr) {}
	WString(const value_type* pStr, WStringBase::size_type _Count) : WStringBase(pStr, _Count) {}

#ifdef HAVE_CPP_2BYTE_WCHAR_T
	WString(const char* pStr) { IConConvert(std::string(pStr), *this, true); }
	WString(const std::string& Str) { IConConvert(Str, *this, true); }
	inline operator std::string() const { std::string Str; return IConConvert(*this, Str, false); }
	inline std::string str() const { std::string Str; return IConConvert(*this, Str, false); }
	inline const std::wstring& wstr() const { return *this; }
#else
	WString(const char* pStr) { std::wstring WStr; convert(IConConvert(std::string(pStr), WStr, true), *this); }
	WString(const std::string& Str) { std::wstring WStr; convert(IConConvert(Str, WStr, true), *this); }
	inline WString& operator=(const std::string& Str) { std::wstring WStr; return convert(IConConvert(Str, WStr, true), *this); }
	inline operator std::string() const { return str(); }
	inline std::string str() const { std::string Str; return IConConvert(wstr(), Str, false); }

	inline WString(const wchar_t* pStr) { convert(std::wstring(pStr), *this); }
	inline WString(const std::wstring& Str) { convert(Str, *this); }
	inline operator const std::wstring() const { std::wstring strRet; return convert(*this, strRet); }
	inline std::wstring wstr() const { std::wstring strRet; return convert(*this, strRet); }
#endif
	inline operator const WStringBase::value_type*() { return c_str(); }
	inline WString& operator=(const WString& Str) { assign(Str); return *this; }
	inline WString operator+(const WString& Str) const { WString Ret(*this); Ret.append(Str); return Ret; }
	inline WString operator+(wchar_t Char) const { WString Ret(*this); Ret.push_back((value_type)Char); return Ret; }
	inline WString operator+(char Char) const { WString Ret(*this); Ret.push_back((value_type)Char); return Ret; }
	inline WString& operator+=(const WString& Str) { append(Str); return *this; }
	inline WString& operator+=(wchar_t Char) { push_back((value_type)Char); return *this; }
	inline WString& operator+=(char Char) { push_back((value_type)Char); return *this; }
	inline bool operator==(const WString& Str) const { return compare(Str) == 0; }
	inline bool operator!=(const WString& Str) const { return compare(Str) != 0; }

	template<class FromT, class ToT> static ToT& convert(const FromT& FromStr, ToT& ToStr)
	{
		ToStr.size(FromStr.size());
		typename FromT::const_pointer pFrom = FromStr.c_str();
		typename ToT::pointer pTo = (typename ToT::pointer)ToStr.c_str();
		for (int iCount = (int)FromStr.size() + 1; iCount > 0; --iCount, ++pFrom, ++pTo)
			*pTo = (typename ToT::value_type)(*pFrom);
		return ToStr;
	}
};

template<class FromT, class ToT>
inline ToT& IConConvert(const FromT& FromStr, ToT& ToStr, bool bToWChar)
{
	size_t iFromSize = FromStr.size() + 1;
	ToStr.resize(iFromSize * sizeof(wchar_t));
	char* pszFrom = (char*)(FromStr.data());
	char* pszTo = (char*)(ToStr.data());
	size_t iToSize = ToStr.capacity();

#ifdef XP_WIN
	UINT const cp = GetACP();  // Codepage
	if (bToWChar)
		iToSize = ::MultiByteToWideChar(cp, 0, (LPSTR)pszFrom, -1, (LPWSTR)pszTo, ToStr.capacity());
	else
		iToSize = ::WideCharToMultiByte(cp, 0, (LPWSTR)pszFrom, -1, (LPSTR)pszTo, ToStr.capacity(), 0, 0);
	if (iToSize != size_t(-1))
		ToStr.resize(iToSize - 1);
#elif defined(USE_mbstowcs)
	if (bToWChar)
		iToSize = ::mbstowcs((wchar_t*)pszTo, (char*)pszFrom, iFromSize);
	else
		iToSize = ::wcstombs((char*)pszTo, (wchar_t*)pszFrom, iFromSize);
	if (iToSize != size_t(-1))
		ToStr.resize(iToSize);
#elif defined(ACE_HAS_ICONV)
	iconv_t iconv_env = bToStrIsWChar ? iconv_open("WCHAR_T", "") : iconv_open("", "WCHAR_T");
	size_t hr = iconv(iconv_env, &pszFrom, &iFromSize, &pszTo, &iToSize);
	iconv_close(iconv_env);
	if ((hr == size_t(-1)) || (iToSize == ToStr.capacity()))
		return WString::convert<FromT, ToT>(FromStr, ToStr);
	iToSize = (ToStr.capacity() - iToSize) / sizeof(typename ToT::value_type) - 1;
	ToStr.resize(iToSize);
#else // ACE_HAS_ICONV
	return WString::convert(FromStr, ToStr);
#endif // _WIN32

	return ToStr;
}

inline WString PrintStr(const wchar_t* Format, ...)
{
	va_list pParams;
	va_start(pParams, Format);
	wchar_t szResult[C_MaxStrBufSize];

#if defined(_WIN32)
	wvsprintfW(szResult, Format, pParams);
#else
	vswprintf(szResult, C_MaxStrBufSize, Format, pParams);
#endif

	return szResult;
}

#else // for USE_WSTRING

#ifndef DefString
#define DefString		std::string
#endif

#endif // for USE_WSTRING

template<class StringT, class StringListT>
StringT SListToStr(const StringListT& StrList, const StringT& Delimiter)
{
	StringT strResult;

	for (typename StringListT::const_iterator i = StrList.begin(); i != StrList.end();)
	{
		strResult += *i;
		if (++i != StrList.end()) strResult += Delimiter;
	}
	return strResult;
}

template<class StringT, class StringListT>
StringListT& StrToSList(const StringT& Str, StringListT& StrList, const StringT& Delimiter)
{
	int iStart = 0, iSubstrSize;

	StrList.clear();
	while (iStart < (int)Str.size())
	{
		iSubstrSize = (int)Str.find(Delimiter, iStart) - iStart;
		if (iSubstrSize < 0) iSubstrSize = (int)Str.size() - iStart;
		if (iSubstrSize > 0) StrList.push_back(Str.substr(iStart, iSubstrSize));
		iStart += iSubstrSize + (int)Delimiter.size();
	}
	return StrList;
}

inline std::string PrintStr(const char* Format, ...)
{
	va_list pParams;
	char szResult[C_MaxStrBufSize];

	va_start(pParams, Format);
#ifdef _WINDOWS
	vsprintf_s(szResult, sizeof(szResult), Format, pParams);
#else
	vsprintf(szResult, Format, pParams);
#endif

	return szResult;
}

template <class ValueType, class StringT>
inline ValueType StrToNum(const StringT& Value, const ValueType Default = 0, const StringT& Format = StringT(C_DefIntFormat))
{
	if (Value.empty()) return Default;
	ValueType Result = Default;
    if (sizeof(typename StringT::value_type) == 1)
        sscanf((const char*)Value.c_str(), (const char*)Format.c_str(), &Result);
    else
        swscanf((const wchar_t*)Value.c_str(), (const wchar_t*)Format.c_str(), &Result);
	return Result;
}

template <class ValueType, class StringT>
inline StringT NumToStr(const ValueType Value, const StringT& Format = StringT(C_DefIntFormat))
{
	return PrintStr(Format.c_str(), Value);
}

template<class StringListT>
class CStringListBasic : public StringListT
{
public:
	typedef typename StringListT::value_type StringT;
public:
	CStringListBasic() : StringListT() {}
	CStringListBasic(const StringT& Str, const StringT& Delimiter = StringT(C_DefSListDelimiter)) : StringListT()
	{
		StrToSList(Str, *this, Delimiter);
	}
	StringT Name(unsigned _Pos) const
	{
		unsigned iPos = StringListT::at(_Pos).find('=');
		return (iPos != StringT::npos) ? StringListT::at(_Pos).substr(0, iPos) : StringListT::at(_Pos);
	}
	CStringListBasic<StringListT> Names() const
	{
		CStringListBasic<StringListT> slResult;
		for (typename StringListT::size_type iPos = 0; iPos < StringListT::size(); ++iPos)
			slResult.push_back(Name(iPos));
		return slResult;
	}
	StringT Value(unsigned _Pos) const
	{
		unsigned iPos = StringListT::at(_Pos).find('=');
		return (iPos != StringT::npos) ? StringListT::at(_Pos).substr(iPos + 1) : StringT();
	}
	StringT Value(const StringT &Name) const
	{
		int iPos = IndexOf(Name);
		return (iPos < 0) ? StringT() : StringListT::at(iPos).substr(Name.size() + 1);
	}
	int intValue(const StringT &Name, int iDefault = 0) const
	{
		return StrToNum<int, StringT>(Value(Name), iDefault);
	}
	double numValue(const StringT &Name, double fltDefault = 0) const
	{
		return StrToNum<double, StringT>(Value(Name), fltDefault, "%lf");
	}
	int IndexOf(const StringT &Name) const
	{
		for (typename StringListT::const_iterator p = StringListT::begin(); p != StringListT::end(); ++p)
			if ((p->compare(0, Name.size(), Name) == 0) && (Name.size() == p->size() || (*p)[Name.size()] == '='))
				return (int)(p - StringListT::begin());
		return -1;
	}
	const StringT operator[](const StringT &Name) const { return Value(Name); }
	const StringT& operator[](unsigned _Pos) const { return StringListT::at(_Pos); }
	void setValue(const StringT& Name, const StringT& Value)
	{
		int iPos = IndexOf(Name);
		if (iPos < 0)
		{
			if (!Value.empty())
			{
				StringT strName(Name);
				strName += '=';
				StringListT::push_back(strName + Value);
			}
		}
		else
		{
			if (Value.empty())
				StringListT::erase(StringListT::begin() + iPos);
			else
				StringListT::at(iPos).replace(Name.size() + 1, StringT::npos, Value);
		}
	}
	void setValue(const StringT &Name, int iValue)
	{
		setValue(NumToStr<int, StringT>(iValue));
	}
	void setValue(const StringT &Name, double fltValue)
	{
		setValue(NumToStr<double, StringT>(fltValue), "%lf");
	}
	StringT Text(const StringT& Delimiter = StringT(C_DefSListDelimiter)) const
	{
		return SListToStr<StringT, StringListT>(*this, Delimiter);
	}
	void setText(const StringT& Value, const StringT& Delimiter = StringT(C_DefSListDelimiter))
	{
		StrToSList<StringT, StringListT>(Value, *this, Delimiter);
	}
};

template<class StringT>
inline StringT GetConfigValue(const StringT& Config, const StringT& Name, const StringT& Delimiter)
{
	CStringListBasic< std::vector<StringT> > SList;
	StrToSList(Config, SList, Delimiter);
	return SList.Value(Name);
}

template<class StringT>
inline StringT SetConfigValue(const StringT& Config, const StringT& Name, const StringT& Value, const StringT& Delimiter)
{
	CStringListBasic< std::vector<StringT> > SList;
	StrToSList(Config, SList, Delimiter);
	SList.setValue(Name, Value);
	return SList.Text();
}

template<class StringT>
inline StringT extractFilePath(const StringT& strFilePath)
{
	typename StringT::size_type iPos = strFilePath.find_last_of(StringT(":\\/"));
	return (iPos != StringT::npos) ? strFilePath.substr(0, iPos + (strFilePath[iPos] == ':' ?  2 : 1)) : StringT("");
}

template<class StringT>
inline StringT extractFileName(const StringT& strFilePath)
{
	typename StringT::size_type iPos = strFilePath.find_last_of(StringT(":\\/"));
	return (iPos != StringT::npos) ? StringT(strFilePath.substr(iPos + 1)) : strFilePath;
}

template<class StringT>
inline StringT extractFileNameNoExt(const StringT& strFilePath)
{
	StringT strFileName = extractFileName<StringT>(strFilePath);
	typename StringT::size_type iPos = strFileName.find_last_of('.');
	return (iPos != StringT::npos) ? strFileName.substr(0, iPos) : strFileName;
}

template<class StringT>
inline StringT replaceFileExtName(const StringT& strFilePath, const StringT& strNewExtName)
{
	typename StringT::size_type iPos = strFilePath.find_last_of('.');
	return ((iPos != StringT::npos ? strFilePath.substr(0, iPos) : strFilePath) + '.' + strNewExtName);
}

enum ETrimType { ttAll, ttLeft, ttRight };

template<class StringT>
inline StringT Trim(const StringT& Str, ETrimType TrimType = ttAll)
{
	StringT strSpaceChars(" \t\r\n");
	typename StringT::size_type iLeftOffset = ((TrimType == ttAll) || (TrimType == ttLeft)) ? Str.find_first_not_of(strSpaceChars) : 0;
	typename StringT::size_type iRightOffset = ((TrimType == ttAll) || (TrimType == ttRight)) ? Str.find_last_not_of(strSpaceChars) : Str.size() - 1;
	return ((iLeftOffset == StringT::npos) ? StringT() : Str.substr(iLeftOffset, iRightOffset - iLeftOffset + 1));
}

template<class CharT, class StringT>
inline bool IsInRange(CharT Char, const StringT& strRange)
{
	for (int i = 0; i < (int)strRange.size();)
		if (strRange[i + 1] != '-')
			{ if (strRange[i] == '\\') ++i; if (strRange[i++] == Char) return true; }
		else
			{ if (Char >= strRange[i] && Char <= strRange[i + 2]) return true; i += 3; }
	return false;
}

template<class CharT> inline long long ReadInt(CharT*& pStr, int iLen = 32, int iDigit = 10)
{
	long long iResult = 0;
	switch (iDigit)
	{
	case 10 :
		for (; (iLen > 0) && isdigit(*pStr); --iLen, ++pStr)
			iResult = (iResult * 10) + (*pStr - '0');
		break;
	case 16 :
		for (; (iLen > 0) && isxdigit(*pStr); --iLen, ++pStr)
			iResult = (iResult << 4) | (((*pStr & 0xdf) >= 'A') ? ((*pStr & 0xdf) - 'A' + 10) : (*pStr - '0'));
		break;
	default :
		throw std::exception();//"ReadInt(): Bad iDigit");
	};
	return iResult;
}

template<class StringT> inline StringT& UpperCase(StringT& Str)
{
	for (typename StringT::pointer p = const_cast<typename StringT::pointer>(Str.c_str()); *p; ++p)
		if (*p >= 'a' && *p <= 'z') *p &= 0xdf;
	return Str;
}

template<class StringT> inline StringT& LowerCase(StringT& Str)
{
	for (typename StringT::pointer p = const_cast<typename StringT::pointer>(Str.c_str()); *p; ++p)
		if (*p >= 'A' && *p <= 'Z') *p |= 0x20;
	return Str;
}

template<class StringT> inline StringT& ReplaceStr(StringT& Str, const StringT& SubStr1, const StringT& SubStr2)
{
	int iPos = 0;
	while ((iPos = (int)Str.find_first_of(SubStr1, (unsigned)iPos)) >= 0)
	{
		Str.replace((unsigned)iPos, SubStr1.size(), SubStr2.c_str());
		iPos += (int)SubStr2.size();
	}
	return Str;
}

#endif //__StrTools_H_
