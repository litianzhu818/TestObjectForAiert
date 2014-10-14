#ifndef __UDT_STREAM_H__
#define __UDT_STREAM_H__

#include "Stream.h"
#include "udt.h"

class UdtStream : public Stream
{
public:
	UdtStream(int connect_type);
	~UdtStream(void);

	bool OpenStream(const char* r_IP, int r_port, const char* base_ip = NULL, int base_port = 0);
	void CloseStream();

	bool SendBuf(char * data, unsigned size);

	void OnRecv();

	// P2P 需要支持的命令
	bool ReqStream(int iChannel, int iMediaType, int operation);
	bool ReqStopStream();

	bool ReqLogin(const char * /*register_code*/, const char * /*username_or_sn*/) { return false; }

	int OnKeepalive();

private:
	UDTSOCKET m_Socket;
	UDT::TRACEINFO m_perf;
};

#endif /*__UDT_STREAM_H__*/

