#ifndef __TCP_STREAM_H__
#define __TCP_STREAM_H__

#include "Stream.h"

class TcpStream : public Stream
{
public:
	TcpStream(int connect_type);
	~TcpStream(void);

	bool OpenStream(const char* r_IP, int r_port, const char* base_ip = NULL, int base_port = 0);
	void CloseStream();

	bool SendBuf(char * data, unsigned size);
	void OnRecv();

	// ��ת����ָ��
	bool ReqLogin(const char * register_code, const char * username_or_sn);
	// P2P ��Ҫ֧�ֵ�����
	bool ReqStream(int /*iChannel*/, int /*iMediaType*/, int /*operation*/) {return false;}

	int OnKeepalive();

protected:
	// ��������������ģʽ
	bool SetNonblocking(bool bNb = true);

private:
#ifdef _WIN32
	static WSAInitializer _Initializer_;
#endif
	SOCKET m_Socket;
};

#endif /*__TCP_STREAM_H__*/

