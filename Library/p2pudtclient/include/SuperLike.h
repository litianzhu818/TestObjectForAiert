/******************************************************************************************

CLikeBase is a string matching class that can compare a string "like" a pattern or not. But,
CLikeBase is abstract class, CBinaryLike and CStringLike is derived from CLikeBase to implement
binary string matching and normal C string matching.

Before to compare a string with a pattern, we must call Prepare() parse pattern and to speed up
matching steps later. Once Prepare() done, we can call Compare() in any time. IsLike() function
can do preceding steps in only one function, but speed is poor. We also can save matched string
in a string object by provide Values and use '&' in matching pattern.

CBinaryLike support following pattern format:
FFFFFFF*(&1-4)*(-5!1,00-7F,90,F0)00*FF*(-4,~0-1000)EEEE

CStringLike support following pattern format:
My name is *(&4-8,a-zA-Z~X), age is *(&-3,0-9), sex is [&`~male,female].

Char '*' is wildcard, following '*' is a couple of "()", "[]" or "{}" that any limited matching
conditions is inside it. Char '&' means that save matched string in given string object. Enclosed
by "[]" means that filter condition is a list of words that seperated by char ','. Char '`' means
to ignore case, and char '~' means reversed condition (or is black list rule). Char '!' is only
used by CBinaryLike class, that specify matching string is array and the size of element is given
by following number. Enclose by "{}" means that filter condition is sub condition.

for example:
// to get a file's extended name
// if b is true, then the file's extended name is saved in strFileExtName
string strFileExtName;
bool b = IsLike<CStringLike<>>("filename.ext.ext", "*.*(&1-,~.)", &strFileExtName);

// to get IP address and port
WString strIPAddress, strPort;
bool b = IsLike<CStringLike<WString>>(L"192.168.0.1:8080", L"*{&*(1~3,0-9).*(1~3,0-9).*(1~3,0-9).*(1~3,0-9)}{&:*(2-5,0-9)}", &strIPAddress, &strPort);

******************************************************************************************/

#ifndef SuperLikeH
#define SuperLikeH

#include <vector>

#include "StrTools.h"
#include "BitsOperation.h"

#ifndef ESCAPE_CHAR
#define ESCAPE_CHAR		'\\'
#endif

#define IsStrLike	IsLike< CStringLike<std::string> >
#define IsWStrLike	IsLike< CStringLike<WString> >
#define IsDefStrLike IsLike< CStringLike<DefString> >
#define IsBinLike	IsLike< CBinaryLike<> >

#define PATTERN_MAXSIZE		0xfffff
#define MAX_PATTERN_COUNT	100
#define MAX_RANGE_COUNT		50

template<class _RangeT, class _PatternStrT, class  _CompareDataT, class ThisType>
class CLikeBaseT
{
public:
	typedef _RangeT RangeT;
	typedef _PatternStrT PatternStrT;
	typedef _CompareDataT CompareDataT;
	typedef typename PatternStrT::pointer PPatternCharT;
	typedef typename CompareDataT::pointer PCompareData;
public:
	class ResultValues
	{
	public:
		ResultValues(CompareDataT** ppValues) { m_ppValues = ppValues; }
		ResultValues(va_list vaValues) { m_ppValues = NULL; m_vaValues = vaValues; }
		CompareDataT* operator++(int) { return (m_ppValues ? *(m_ppValues++) : va_arg(m_vaValues, CompareDataT*)); }
	private:
		CompareDataT** m_ppValues;
		va_list m_vaValues;
	};
public:
	enum EPatternType { ptNormal = 0, ptWildcard = 1, ptSubLike = 3 };
	struct SPattern
	{
		PCompareData pLastData;
		int iMinSize, iMaxSize, iStart, iSize;
		EPatternType Type;

		SPattern() : iMinSize(0), iMaxSize(PATTERN_MAXSIZE), iStart(0), iSize(0), Type(ptNormal) {}
		virtual ~SPattern() {}

		virtual void InitCompare() { pLastData = NULL; }
		virtual void SaveValue(SPattern** ppPattern) {}
		virtual CompareDataT ToString() { return CompareDataT(); }
		virtual void Parse(PPatternCharT& pszPattern, ResultValues& Values) = 0;
		virtual PCompareData Search(PCompareData pStart, PCompareData pEnd)
		{
			for (PCompareData pSearchEnd = pEnd - SPattern::iMinSize; pStart <= pSearchEnd; ++pStart)
				if (Compare(pStart, pStart + SPattern::iMinSize)) { SPattern::pLastData = pStart; return pStart; }
			return NULL;
		}
		virtual bool Compare(PCompareData pData, PCompareData pEnd) = 0;
	};
	struct SPatternGroup
	{
		SPattern* Patterns[MAX_PATTERN_COUNT + 2];
		int SearchablePatterns[MAX_PATTERN_COUNT + 2];
		int SearchablePatternMaxSize[MAX_PATTERN_COUNT + 2];
		int iPatternCount, iSearchablePatternCount;
	};

	struct SRange
	{
		SRange(RangeT L = 0, RangeT H = 0, bool R = false) { Low = L; High = H; bIsBlack = R; }
		RangeT Low, High;
		bool bIsBlack; // if true, Value is out of [Low, High] range is good.
	};

	struct SPatternEnd : public SPattern
	{
		virtual void Parse(PPatternCharT& pszPattern, ResultValues& Values) {}

		virtual PCompareData Search(PCompareData pStart, PCompareData pEnd)
		{
			SPattern::iSize = 0;
			return (SPattern::pLastData = pEnd);
		}

		virtual bool Compare(PCompareData pData, PCompareData pEnd)
		{
			return (pData == pEnd);
		}
	};

	struct SPatternSubStr : public SPattern
	{
		CompareDataT SubStr;

		virtual CompareDataT ToString() { return SubStr; }

		virtual void Parse(PPatternCharT& pszPattern, ResultValues& Values)
		{
			while (*pszPattern && !SPatternWildcard::IsWildcard(pszPattern))
				SubStr.push_back((typename CompareDataT::value_type)ThisType::ReadPatternChar(pszPattern));
			SPattern::iMinSize = SPattern::iMaxSize = SPattern::iSize = (int)SubStr.size();
		}

		virtual bool Compare(PCompareData pData, PCompareData pEnd)
		{
			if (((pEnd - pData) >= SPattern::iMinSize) && (SubStr.compare(0, SPattern::iMinSize, pData, SPattern::iMinSize) == 0))
				return true;
			return false;
		}
	};

	struct SPatternWildcard : public SPattern
	{
		CompareDataT* pValue;

		SPatternWildcard() : pValue(NULL) { SPattern::Type = ptWildcard; }

		virtual void SaveValue(SPattern** ppPattern)
		{
			if (pValue && SPattern::pLastData)
			{
				int iSize = (*(ppPattern + 1))->pLastData - SPattern::pLastData;
				pValue->assign(SPattern::pLastData, iSize);
			}
		}

		virtual CompareDataT ToString() { return pValue ? *pValue : CompareDataT(); }

		void ReadMinMax(PPatternCharT& pszPattern)
		{
			SPattern::iMinSize = (int)ReadInt<typename PatternStrT::value_type>(pszPattern);
			if (*pszPattern == '-')
				SPattern::iMaxSize = (int)ReadInt<typename PatternStrT::value_type>(++pszPattern);
			else
				SPattern::iMaxSize = SPattern::iMinSize;
			if (SPattern::iMaxSize == 0) SPattern::iMaxSize = PATTERN_MAXSIZE;
		}

		static bool IsWildcard(PPatternCharT pPattern) { return (*pPattern == '*'); }
	};

	struct SWildcardRange : public SPatternWildcard
	{
		SRange Ranges[MAX_RANGE_COUNT + 1];
		bool bIsReverseBytesOrder;
		char BitMap[32];
		int iArrayElementSize, iRangeCount;

		SWildcardRange() : SPatternWildcard()
		{
			memset(Ranges, 0, sizeof(Ranges));
			memset(BitMap, 0, sizeof(BitMap));
			bIsReverseBytesOrder = false;
			iRangeCount = 0;
			iArrayElementSize = sizeof(typename CompareDataT::value_type);
		}

		void BuildRanges()
		{
			// if has no range, allow all is default
			if (iRangeCount == 0)
			{
				memset(BitMap, 0xff, sizeof(BitMap));
				Ranges[iRangeCount++].High = (RangeT)-1;
				return;
			}

			// convert all black ranges to white ranges
			std::vector<SRange> WhiteRanges;
			SRange WhiteRange;
			int i, j;
			for (i = 0; i < iRangeCount; ++i)
				if (!Ranges[i].bIsBlack) WhiteRanges.push_back(Ranges[i]);
			if (WhiteRanges.empty()) WhiteRanges.push_back(SRange(0, (RangeT)-1));
			for (i = 0; i < iRangeCount; ++i)
			{
				if (!Ranges[i].bIsBlack) continue;
				for (j = 0; j < (int)WhiteRanges.size(); ++j)
				{
					WhiteRange = WhiteRanges[j];
					if ((Ranges[i].Low <= WhiteRange.Low) && (Ranges[i].High >= WhiteRange.High))
						WhiteRanges.erase(WhiteRanges.begin() + j--);
					else if (Between(Ranges[i].Low, WhiteRange.Low, WhiteRange.High))
					{
						WhiteRanges[j].High = Ranges[i].Low - 1;
						if (Ranges[i].High < WhiteRange.High)
							WhiteRanges.push_back(SRange(Ranges[i].High + 1, WhiteRange.High));
					}
					else if (Between(Ranges[i].High, WhiteRange.Low, WhiteRange.High))
					{
						WhiteRanges[j].Low = Ranges[i].High + 1;
						if (Ranges[i].Low > WhiteRange.Low)
							WhiteRanges.push_back(SRange(WhiteRange.Low, Ranges[i].Low - 1));
					}
				}
			}

			// fill up BitMap and Rangs[]
			for (i = 0; i < (int)WhiteRanges.size(); ++i)
			{
				if ( WhiteRanges[i].Low > WhiteRanges[i].High)
					WhiteRanges.erase(WhiteRanges.begin() + i);
				WhiteRange = WhiteRanges[i];
				if (WhiteRange.Low <= 0xff)
				{
					if (WhiteRange.High <= 0xff)
						WhiteRanges.erase(WhiteRanges.begin() + i--);
					else
						WhiteRanges[i].Low = (RangeT)0x100, WhiteRange.High = 0xff;
					for (j = WhiteRange.Low; j <= (int)WhiteRange.High; j += 24)
						SetBits32(BitMap, j, Min<RangeT>(24, WhiteRange.High - j + 1), 0xffffffff);
				}
			}
			iRangeCount = (int)WhiteRanges.size();
			for (i = 0; i < iRangeCount; ++i)
				Ranges[i] = WhiteRanges[i];
			//memcpy(Ranges, WhiteRanges.data(), iRangeCount * sizeof(SRange));
			Ranges[iRangeCount].High = 0;
		}

		bool inline IsValueInRange(RangeT Value)
		{
			for (SRange* pRange = Ranges; pRange->High; ++pRange)
				if (Value >= pRange->Low && Value <= pRange->High)
					return true;
			return false;
		}

		virtual bool Compare(PCompareData pData, PCompareData pEnd)
		{
			if ((pEnd - pData) < SPattern::iMinSize) return false;
			PCompareData pStart = pData;
			SPattern::iSize = SPattern::iSize - (pStart - SPattern::pLastData);
			if (SPattern::iSize < 0) SPattern::iSize = 0; else pStart += SPattern::iSize;
			while (pStart < pEnd)
			{
				if (iArrayElementSize == sizeof(typename CompareDataT::value_type))
				{
					if ((((RangeT)*pStart <= 0xff) && !(BitMap[(RangeT)*pStart >> 3] & (0x80 >> ((RangeT)*pStart & 7))))
						|| (((RangeT)*pStart > 0xff) && !IsValueInRange(*pStart)))
					{
						if ((SPattern::iSize = pStart - pData) < SPattern::iMinSize) return false; else break;
					}
					++pStart;
				}
				else if (!IsValueInRange(ReadBytes<RangeT>(pStart, iArrayElementSize, bIsReverseBytesOrder)))
				{
					if ((SPattern::iSize = pStart - pData) < SPattern::iMinSize) return false; else break;
					pStart += iArrayElementSize;
				}
			}
			SPattern::iSize = pStart - pData;
			return true;
		}
	};

	struct SPatternSubLike : public SPatternWildcard
	{
		ThisType SubLike;

		SPatternSubLike() { SPattern::Type = ptSubLike; }

		virtual void InitCompare()
		{
			SubLike.InitCompare();
		}

		virtual void SaveValue(SPattern** ppPattern)
		{
			SPatternWildcard::SaveValue(ppPattern);
			SubLike.SaveValues();
		}

		virtual void Parse(PPatternCharT& pszPattern, ResultValues& Values)
		{
			PatternStrT strSubPattern;

			if (*(++pszPattern) == '&') { ++pszPattern; SPatternWildcard::pValue = Values++; }
			SPatternWildcard::ReadMinMax(pszPattern);

			if (*pszPattern == ',') ++pszPattern;
			for (int iLevel = 1; *pszPattern;)
			{
				if (*pszPattern == '{') ++iLevel; else if (*pszPattern == '}') { if (--iLevel == 0) break; }
				strSubPattern.push_back(*pszPattern++);
				if (*(pszPattern - 1) == ESCAPE_CHAR)
					for (int i = ((*pszPattern & 0xdf) == 'X' ? 3 : 1); i > 0; --i) strSubPattern.push_back(*pszPattern++);
			}
			if (*pszPattern == '}') ++pszPattern;

			SubLike.Prepare(strSubPattern, Values);
			if (SPattern::iMinSize > 0) SPattern::iMinSize = SubLike.iMinMatchSize;
			SPattern::iMaxSize = SubLike.iMaxMatchSize;
		}

		virtual PCompareData Search(PCompareData pStart, PCompareData pEnd)
		{
			if ((SPattern::iMinSize == 0) || (pStart = SubLike.Search(pStart, pEnd, SPattern::iSize)))
				SPattern::pLastData = pStart;
			return pStart;
		}

		virtual bool Compare(PCompareData pData, PCompareData pEnd)
		{
			for (; (pEnd - pData) >= SubLike.iMinMatchSize; --pEnd)
				if (SubLike.Compare(pData, pEnd)) { SPattern::iSize = pEnd - pData; return true; }
			SPattern::iSize = 0;
			return (SPattern::iMinSize == 0);
		}
	};
public:
	CLikeBaseT() : bPrepared(false)
	{
		memset(&PatternGroup, 0, sizeof(PatternGroup));
	}
	~CLikeBaseT() { Clear(); }

	void inline Prepare(const PatternStrT& strPattern, CompareDataT** ppValues = NULL)
	{
		ResultValues Values(ppValues);
		Prepare(strPattern, Values);
	}

	void inline Prepare(const PatternStrT& strPattern, va_list vaValues)
	{
		ResultValues Values(vaValues);
		Prepare(strPattern, Values);
	}

	virtual void Prepare(const PatternStrT& strPattern, ResultValues& Values)
	{
		Clear();
		if (strPattern.empty()) return;
		int iPatternsMaxSize = 0;
		for (PPatternCharT pszPattern = const_cast<PPatternCharT>(strPattern.c_str()); *pszPattern;)
		{
			SPattern* pPattern = PreparePattern(pszPattern, Values);
			iMinMatchSize += pPattern->SPattern::iMinSize;
			if ((iMaxMatchSize += pPattern->SPattern::iMaxSize) > PATTERN_MAXSIZE)
				iMaxMatchSize = PATTERN_MAXSIZE;

			PatternGroup.Patterns[PatternGroup.iPatternCount++] = pPattern;
			if (PatternGroup.iPatternCount >= MAX_PATTERN_COUNT)
				throw DefException("CLikeBase::Prepare(): PatternCount exceeded MAX_PATTERN_COUNT!");

			if (PatternGroup.iPatternCount == 1 || pPattern->SPattern::iMinSize > 0)
			{
				PatternGroup.SearchablePatterns[PatternGroup.iSearchablePatternCount] = PatternGroup.iPatternCount - 1;
				iPatternsMaxSize += (pPattern->Type == ptSubLike ? pPattern->SPattern::iMaxSize : pPattern->SPattern::iMinSize);
				if (iPatternsMaxSize > PATTERN_MAXSIZE) iPatternsMaxSize = PATTERN_MAXSIZE;
				PatternGroup.SearchablePatternMaxSize[PatternGroup.iSearchablePatternCount++] = iPatternsMaxSize;
				iPatternsMaxSize = 0;
			}
			iPatternsMaxSize += pPattern->SPattern::iMaxSize;
		}
		if (PatternGroup.iPatternCount == 0)
			throw DefException("CLikeBase::Prepare(): Bad syntax format");

		PatternGroup.SearchablePatterns[PatternGroup.iSearchablePatternCount] = PatternGroup.iPatternCount;
		PatternGroup.Patterns[PatternGroup.iPatternCount++] = new SPatternEnd();
		PatternGroup.Patterns[PatternGroup.iPatternCount] = NULL;
		PatternGroup.SearchablePatternMaxSize[PatternGroup.iSearchablePatternCount++] = PATTERN_MAXSIZE;
		PatternGroup.SearchablePatterns[PatternGroup.iSearchablePatternCount] = 0;

		pFirstSearchablePattern = PatternGroup.Patterns[PatternGroup.SearchablePatterns[0]];
		if (pFirstSearchablePattern->iMinSize == 0)
			pFirstSearchablePattern = PatternGroup.Patterns[PatternGroup.SearchablePatterns[1]];
		pLastSearchablePattern = PatternGroup.Patterns[PatternGroup.SearchablePatterns[PatternGroup.iSearchablePatternCount - 2]];

		bPrepared = true;
	}

	virtual bool Compare(const CompareDataT& Data, bool bSaveValues = true)
	{
		if (!Compare(const_cast<PCompareData>(Data.c_str()), const_cast<PCompareData>(Data.c_str()) + Data.size()))
			return false;

		if (bSaveValues) SaveValues();

		return true;
	}

	virtual bool Compare(PCompareData pBufStart, PCompareData pEnd)
	{
		if (!bPrepared || !Between(pEnd - pBufStart, iMinMatchSize, iMaxMatchSize)) return false;

		InitCompare();

		PCompareData pData, pFound = pBufStart;
		SPattern **ppPatterns = PatternGroup.Patterns;
		SPattern **ppComparePattern, *pSearchPattern = NULL;
		int *pSearchablePatterns = PatternGroup.SearchablePatterns;
		int *pSearchablePatternMaxSize = PatternGroup.SearchablePatternMaxSize, iPatternSize;

		for (int iIndex = -1; ;)
		{
			if (iIndex > 0)
			{
				pData = pSearchPattern->pLastData;
				if ((pFound = pSearchPattern->Search(pData, (PCompareData)Min((int)pEnd, (int)pData + pSearchablePatternMaxSize[iIndex]))) == NULL)
				{
__BACK_TO_PRIOR_SEARCHABLE_PATTERN:
					if (--iIndex < 1) return false;
					pSearchPattern = ppPatterns[pSearchablePatterns[iIndex]];
__BACK_TO_CURRENT_SEARCHABLE_PATTERN:
					++pSearchPattern->pLastData;
					if ((pSearchPattern->iSize > 0) && (pSearchPattern->Type & ptWildcard))
						--pSearchPattern->iSize;
					continue;
				}
				ppComparePattern = (ppPatterns + pSearchablePatterns[iIndex - 1]);
				pData = (*ppComparePattern)->pLastData;
				for (; *ppComparePattern != pSearchPattern; ++ppComparePattern)
				{
					if (((*ppComparePattern)->iMinSize == 0) || (iIndex == 1) || ((*ppComparePattern)->iMinSize != (*ppComparePattern)->iMaxSize))
					{
						if (!(*ppComparePattern)->Compare(pData, pFound))
							goto __BACK_TO_PRIOR_SEARCHABLE_PATTERN;
						(*ppComparePattern)->pLastData = pData;
					}
					pData += (*ppComparePattern)->iSize;
				}
				if (pData < pFound)
				{
					ppComparePattern = (ppPatterns + pSearchablePatterns[iIndex - 1]);
					for (; *ppComparePattern != pSearchPattern; ++ppComparePattern)
						if (((*ppComparePattern)->Type & ptSubLike) && (pFound + pSearchPattern->iSize < pEnd))
							goto __BACK_TO_CURRENT_SEARCHABLE_PATTERN;
					goto __BACK_TO_PRIOR_SEARCHABLE_PATTERN;
				}
			}
			if (++iIndex >= PatternGroup.iSearchablePatternCount)
				break;
			else
			{
				iPatternSize = (pSearchPattern ? pSearchPattern->iSize : 0);
				pSearchPattern = ppPatterns[pSearchablePatterns[iIndex]];
				pSearchPattern->pLastData = pFound + iPatternSize;
				if (pSearchPattern->Type & ptWildcard)
					pSearchPattern->iSize = 0;
			}
		}

		return true;
	}

	virtual PCompareData Search(PCompareData pStart, PCompareData pEnd, int& iSize)
	{
		if ((pEnd - pStart) < iMinMatchSize)
			return NULL;

		pFirstSearchablePattern->pLastData = pLastSearchablePattern->pLastData = NULL;
		if (pFirstSearchablePattern->Type & ptWildcard)
			pFirstSearchablePattern->iSize = 0;
		if (pLastSearchablePattern->Type & ptWildcard)
			pLastSearchablePattern->iSize = 0;

		SPatternSubLike* pFirstSubLike = (PatternGroup.Patterns[0]->Type & ptSubLike) ? static_cast<SPatternSubLike*>(PatternGroup.Patterns[0]) : NULL;
		while ((pFirstSubLike && (pStart = pFirstSubLike->Search(pStart, pEnd)))
			|| (!pFirstSubLike && (pStart = pFirstSearchablePattern->Search(pStart, pEnd))))
		{
			for (PCompareData pSearchEnd = pStart + iMinMatchSize - pLastSearchablePattern->iMinSize; pSearchEnd && (pSearchEnd < pEnd); ++pSearchEnd)
			{
				if ((pSearchEnd = pLastSearchablePattern->Search(pSearchEnd, pEnd)) == NULL)
					return NULL;
				else if (Compare(pStart, pSearchEnd + pLastSearchablePattern->iSize))
				{
					iSize = (pSearchEnd + pLastSearchablePattern->iSize - pStart);
					return pStart;
				}
			}
		}

		return NULL;
	}

	virtual void SaveValues()
	{
		for (SPattern** ppPattern = PatternGroup.Patterns; *ppPattern; ++ppPattern)
			(*ppPattern)->SaveValue(ppPattern);
	}

	virtual CompareDataT ToString()
	{
		CompareDataT Result;
		for (SPattern** ppPattern = PatternGroup.Patterns; *ppPattern; ++ppPattern)
			Result.append((*ppPattern)->ToString());
		return Result;
	}
public:
	int iMinMatchSize, iMaxMatchSize;
	bool bPrepared;
	SPatternGroup PatternGroup;
	SPattern *pFirstSearchablePattern, *pLastSearchablePattern;
protected:
	virtual SPattern* PreparePattern(PPatternCharT& pszPattern, ResultValues& Values) = 0;

	virtual void Clear()
	{
		for (SPattern** ppPattern = PatternGroup.Patterns; *ppPattern; ++ppPattern)
			delete (*ppPattern);
		memset(&PatternGroup, 0, sizeof(PatternGroup));
		bPrepared = false;
		iMinMatchSize = iMaxMatchSize = 0;
		pFirstSearchablePattern = pLastSearchablePattern = NULL;
	}

	virtual void InitCompare() 
	{
		for (SPattern** ppPattern = PatternGroup.Patterns; *ppPattern; ++ppPattern)
			(*ppPattern)->InitCompare();
	}
};

template<class _RangeT = unsigned, class _PatternStrT = DefString>
class CBinaryLike : public CLikeBaseT< _RangeT, _PatternStrT, DefString, CBinaryLike<_RangeT, _PatternStrT> >
{
public:
	typedef CLikeBaseT< _RangeT, _PatternStrT, DefString, CBinaryLike<_RangeT, _PatternStrT> > CLikeBase;
	typedef typename _PatternStrT::value_type RangeT;
	typedef _PatternStrT PatternStrT;
	typedef DefString CompareDataT;
	typedef typename PatternStrT::pointer PPatternCharT;
	typedef typename PatternStrT::const_pointer ConstPPatternCharT;
	typedef typename CompareDataT::pointer PCompareData;
public:
	static RangeT ReadPatternChar(PPatternCharT& pszPattern)
	{
		if (!isxdigit(*pszPattern) || !isxdigit(*(pszPattern + 1)))
			throw DefException("CBinaryLike::PreparePattern(): Bad syntax format");
		return (RangeT)ReadInt(pszPattern, 2, 16);
	}

	struct SWildcardBinRange : public CLikeBase::SWildcardRange
	{
		virtual void Parse(PPatternCharT& pszPattern, typename CLikeBase::ResultValues& Values)
		{
			if (*(++pszPattern) != '(')
			{
				CLikeBase::SWildcardRange::iMinSize = CLikeBase::SWildcardRange::iMaxSize = 0;
				CLikeBase::SWildcardRange::BuildRanges();
				return;
			}
			if (*(++pszPattern) == '&')
				{ ++pszPattern; CLikeBase::SWildcardRange::pValue = Values++; }
			ReadMinMax(pszPattern);
			if (*pszPattern == '!')
				CLikeBase::SWildcardRange::iArrayElementSize = (int)ReadInt(++pszPattern);
			if ((CLikeBase::SWildcardRange::iArrayElementSize <= 0) || (CLikeBase::SWildcardRange::iArrayElementSize > (int)sizeof(RangeT)))
				CLikeBase::SWildcardRange::iArrayElementSize = sizeof(RangeT);
			CLikeBase::SWildcardRange::bIsReverseBytesOrder = (int)(*pszPattern == '~');
			if (CLikeBase::SWildcardRange::bIsReverseBytesOrder)
				++pszPattern;
			while ((*pszPattern == ',') || ((*pszPattern != ')') && (*pszPattern != '\0')))
			{
				typename CLikeBase::SRange Range(0, 0, (*(++pszPattern) == '~') ? (++pszPattern, true) : false);
				Range.Low = (RangeT)ReadInt(pszPattern, sizeof(RangeT) << 1, 16);
				Range.High = (*pszPattern == '-') ? ((RangeT)ReadInt(++pszPattern, sizeof(RangeT) << 1, 16)) : Range.Low;
				if (Range.Low > Range.High) Exchange(Range.Low, Range.High);
				CLikeBase::SWildcardRange::Ranges[CLikeBase::SWildcardRange::iRangeCount++] = Range;
				if (CLikeBase::SWildcardRange::iRangeCount >= MAX_RANGE_COUNT)
					throw DefException("SWildcardBinRange::Parse(): iRangeCount exceeded MAX_RANGE_COUNT!");
			}
			if (*pszPattern == ')') ++pszPattern;
			CLikeBase::SWildcardRange::BuildRanges();
		}
	};
protected:
	virtual typename CLikeBase::SPattern* PreparePattern(PPatternCharT& pszPattern, typename CLikeBase::ResultValues& Values)
	{
		typename CLikeBase::SPattern* pPattern;
		if (!CLikeBase::SPatternWildcard::IsWildcard(pszPattern))
			pPattern = new typename CLikeBase::SPatternSubStr();
		else
		{
			if (*(pszPattern + 1) == '{')
				pPattern = new typename CLikeBase::SPatternSubLike();
			else
				pPattern = new SWildcardBinRange();
		}
		pPattern->Parse(pszPattern, Values);
		return pPattern;
	}
};

template<class _PatternStrT = DefString>
class CStringLike : public CLikeBaseT< unsigned short, _PatternStrT, _PatternStrT, CStringLike<_PatternStrT> >
{
public:
	typedef CLikeBaseT< unsigned short, _PatternStrT, _PatternStrT, CStringLike<_PatternStrT> > CLikeBase;
	typedef typename _PatternStrT::value_type RangeT;
	typedef _PatternStrT PatternStrT;
	typedef _PatternStrT CompareDataT;
	typedef typename PatternStrT::pointer PPatternCharT;
	typedef typename PatternStrT::const_pointer ConstPPatternCharT;
	typedef typename CompareDataT::pointer PCompareData;
public:
	static RangeT ReadPatternChar(PPatternCharT& pszPattern)
	{
		if (*pszPattern == ESCAPE_CHAR)
			if ((*(++pszPattern) & 0xdf) == 'X')
				return (RangeT)ReadInt<RangeT>(++pszPattern, sizeof(RangeT) << 1, 16);
		return *(pszPattern++);
	}

	struct SWildcardCharRange : public CLikeBase::SWildcardRange
	{
		virtual void Parse(PPatternCharT& pszPattern, typename CLikeBase::ResultValues& Values)
		{
			if (*pszPattern != '(') { CLikeBase::SWildcardRange::BuildRanges(); return; }
			if (*(++pszPattern) == '&')
				{ ++pszPattern; CLikeBase::SWildcardRange::pValue = Values++; }
			CLikeBase::SPatternWildcard::ReadMinMax(pszPattern);
			if (*pszPattern == ',')
				++pszPattern;
			while ((*pszPattern != ')') && (*pszPattern != '\0'))
			{
				typename CLikeBase::SRange Range(0, 0, (*pszPattern == '~') ? (++pszPattern, true) : false);
				Range.Low = ReadPatternChar(pszPattern);
				Range.High = (*pszPattern == '-') ? ReadPatternChar(++pszPattern) : Range.Low;
				if (Range.Low > Range.High) Exchange(Range.Low, Range.High);
				CLikeBase::SWildcardRange::Ranges[CLikeBase::SWildcardRange::iRangeCount++] = Range;
				if (CLikeBase::SWildcardRange::iRangeCount >= MAX_RANGE_COUNT)
					throw DefException("SWildcardCharRange::Parse(): iRangeCount exceeded MAX_RANGE_COUNT!");
			}
			if (*pszPattern == ')') ++pszPattern;
			CLikeBase::SWildcardRange::BuildRanges();
		}
	};

	struct SWildcardWordList : public CLikeBase::SPatternWildcard
	{
		typedef std::vector<CompareDataT> CWords;
		CWords FilterWords;
		bool bIgnoreCase, bIsBlack;

		SWildcardWordList() : bIgnoreCase(false), bIsBlack(false) {}

		virtual void Parse(PPatternCharT& pszPattern, typename CLikeBase::ResultValues& Values)
		{
			while (true)
				if (*(++pszPattern) == '&') CLikeBase::SPatternWildcard::pValue = Values++;
				else if (*pszPattern == '`') bIgnoreCase = true;
				else if ((*pszPattern == '~')) bIsBlack = true;
				else break;
			CompareDataT Word;
			Exchange(CLikeBase::SPatternWildcard::iMinSize, CLikeBase::SPatternWildcard::iMaxSize);
			while ((*pszPattern != ']') && (*pszPattern != '\0'))
			{
				Word.clear();
				if (*pszPattern == ',') ++pszPattern;
				while ((*pszPattern != ',') && (*pszPattern != ']') && (*pszPattern != '\0'))
					Word.push_back((*pszPattern == ESCAPE_CHAR) ? (*((++pszPattern)++)) : *(pszPattern++));
				if (!Word.empty())
					FilterWords.push_back(bIgnoreCase ? UpperCase(Word) : Word);
				if ((int)Word.size() < CLikeBase::SPatternWildcard::iMinSize)
					CLikeBase::SPatternWildcard::iMinSize = (int)Word.size();
				if ((int)Word.size() > CLikeBase::SPatternWildcard::iMaxSize)
					CLikeBase::SPatternWildcard::iMaxSize = (int)Word.size();
			}
			if (*pszPattern == ']') ++pszPattern;
		}

		virtual bool Compare(PCompareData pData, PCompareData pEnd)
		{
			if (pEnd - pData < CLikeBase::SPatternWildcard::iMinSize)
				return false;
			CompareDataT Word(pData, Min(CLikeBase::SPatternWildcard::iMaxSize, pEnd - pData));
			if (bIgnoreCase) UpperCase(Word);
			bool bFound = false;
			for (typename CWords::iterator p = FilterWords.begin(); p != FilterWords.end(); ++p)
			{
				int iStrSize = (int)(*p).size();
				if (iStrSize > (int)Word.size()) continue;
				if ((*p).compare(0, iStrSize, Word.c_str(), iStrSize) == 0)
					{ bFound = true; CLikeBase::SPattern::iSize = iStrSize; break; }
			}
			return (bFound ^ bIsBlack);
		}
	};
protected:
	virtual typename CLikeBase::SPattern* PreparePattern(PPatternCharT& pszPattern, typename CLikeBase::ResultValues& Values)
	{
		typename CLikeBase::SPattern* pPattern;
		if (!CLikeBase::SPatternWildcard::IsWildcard(pszPattern))
			pPattern = new typename CLikeBase::SPatternSubStr();
		else
			switch (*(++pszPattern))
			{
			case '[' : pPattern = new SWildcardWordList(); break;
			case '{' : pPattern = new typename CLikeBase::SPatternSubLike(); break;
			default  : pPattern = new SWildcardCharRange();
			}
		pPattern->Parse(pszPattern, Values);
		return pPattern;
	}
};

template<class LikeT>
bool IsLike(const typename LikeT::CompareDataT& Data, typename LikeT::ConstPPatternCharT Pattern, ...)
{
	LikeT Like;
	va_list Arguments;// = (va_list)&reinterpret_cast<const char &>(Pattern) + sizeof(typename LikeT::PatternStrT*);

	va_start(Arguments, Pattern);
	Like.Prepare(Pattern, Arguments);
	va_end(Arguments);

	return Like.Compare(Data);
}

#endif
