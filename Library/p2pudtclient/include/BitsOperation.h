#ifndef BitsOperationH
#define BitsOperationH

#define COUNT(Array)	(sizeof(Array) / sizeof(Array[0]))

#define GetBits32	GetBits<unsigned long, 32>
#define GetBits64	GetBits<unsigned long long, 64>
#define SetBits32	SetBits<unsigned long, 32>
#define SetBits64	SetBits<unsigned long long, 64>

template<class T> inline T Min(T X, T Y)
{
	return X < Y ? X : Y;
}

template<class T> inline T Max(T X, T Y)
{
	return X < Y ? Y : X;
}

template<class T> inline void Exchange(T& X, T& Y)
{
	T Z = X; X = Y; Y = Z;
}

template<class T> inline bool Between(T X, T MinX, T MaxX)
{
	return ((X >= MinX) && (X <= MaxX));
}

inline unsigned long ReverseBytesOrder(unsigned long iValue)
{
#ifdef __GNUC__
	return ((iValue >> 24) | ((iValue >> 8) & 0xff00) | ((iValue << 8) & 0xff0000) | (iValue << 24));
#else
	__asm 
	{
		mov eax, iValue
		xchg ah, al
		ror eax, 16
		xchg ah, al
	}
#endif
}

inline unsigned short ReverseBytesOrder(unsigned short iValue)
{
#ifdef __GNUC__
	return ((iValue << 8) | (iValue >> 8));
#else
	__asm 
	{
		mov ax, iValue
		xchg ah, al
	}
#endif
}

inline void ReverseBytesOrder(char* pBuffer, int iSize)
{
	for (char* pEnd = pBuffer + iSize - 1; pBuffer < pEnd;) Exchange(*pBuffer++, *pEnd--);
}

inline unsigned long long ReverseBytesOrder(unsigned long long iValue)
{
	ReverseBytesOrder((char*)&iValue, sizeof(iValue));
	return iValue; 
}

template<class ResultT, int MaxBits>
inline ResultT GetBits(const void* pBuffer, int iBitPos, int iBitCount)
{
	ResultT iResult = ReverseBytesOrder(*(ResultT*)((char*)pBuffer + (iBitPos >> 3))); 
	ResultT iMask = ((ResultT)-1 >> (MaxBits - iBitCount));
	return (iResult >> (MaxBits - iBitCount - (iBitPos & 7))) & iMask;
}

template<class ValueT, int MaxBits>
inline void SetBits(const void* pBuffer, int iBitPos, int iBitCount, ValueT Value)
{
	int iBytePos = iBitPos >> 3, iShiftBits = MaxBits - (iBitPos & 7) - iBitCount;
	ValueT iMask = ReverseBytesOrder(((ValueT)-1 >> (MaxBits - iBitCount)) << iShiftBits);
	ValueT &Data = *(ValueT*)((char*)pBuffer + iBytePos);
	Data = (Data & ~iMask) | (ReverseBytesOrder(Value << iShiftBits) & iMask);
}

inline long GetBitsInc(const void* pBuffer, int& iBitPos, int iBitCount)
{ 
	iBitPos += iBitCount;
	return GetBits32(pBuffer, iBitPos - iBitCount, iBitCount); 
}

inline void SetBitsInc(const void* pBuffer, int& iBitPos, int iBitCount, long Value) 
{ 
	SetBits32(pBuffer, iBitPos, iBitCount, Value); 
	iBitPos += iBitCount; 
}

template<class T> T ReadBytes(const void* pData, int iLen = -1, bool bReverseBytesOrder = false)
{
	T iResult = 0;
	if (iLen > (int)sizeof(T)) iLen = (int)sizeof(T);
	for (int i = 0; i < iLen; ++i) 
		*((char*)(&iResult) + i) = *((char*)pData + i);
	if (bReverseBytesOrder) 
		ReverseBytesOrder((char*)(&iResult), iLen);
	return iResult;
}

template<class T> void WriteBytes(T Value, const void* pData, int iLen = -1, bool bReverseBytesOrder = false)
{
	if (iLen > (int)sizeof(T)) iLen = (int)sizeof(T);
	for (int i = 0; i < iLen; ++i) 
		*((char*)pData + i) = *((char*)(&Value) + i);
	if (bReverseBytesOrder) 
		ReverseBytesOrder((char*)pData, iLen);
}

#endif // for BitsOperationH