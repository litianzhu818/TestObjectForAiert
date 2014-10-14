#ifndef __ZMD_PROTOCOL_H__
#define __ZMD_PROTOCOL_H__

#define DEFAULT_SIP_KEEP_ALIVE		180000000
#define DEFAULT_SIP_KEEP_ALIVE_DATA 15000000
#define DEFAULT_SIP_REQ_TIMEOUT		5000000
#define DEFAULT_P2P_REQ_TIMEOUT		8000000
#define DEFAULT_REGISTER_TIMEOUT	2000000
#define DEFAULT_LOGIN_TIMEOUT		2000000
#define DEFAULT_STREAM_KEEPALIVE	2000000
#define DEFAULT_STREAM_TIMEOUT		5000000

enum AIERT_CMD
{
	/* �ͻ�������ת������ͨ��Э�� */
	PC_TRANS_LOGIN_SYN = 11000,
	PC_TRANS_LOGIN_ACK = 11100,

	PC_GET_IPCSTATE_SYN	= 11002,
	PC_GET_IPCSTATE_ACK	= 11102,

	PC_TRANS_HEART_SYN = 11001,
	PC_TRANS_HEART_ACK = 11101,

	/* �豸����ת������ͨ��Э�� */
	IPC_TRANS_LOGIN_SYN = 21000,
	IPC_TRANS_LOGIN_ACK = 21100,
	IPC_TRANS_HEART_SYN = 21001,
	IPC_TRANS_HEART_ACK = 21101,
	IPC_TRANS_STOP_SYN = 21002,
	IPC_TRANS_STOP_ACK = 21102,

	/* �ͻ������豸ͨ��Э�� */
	PC_IPC_TRANSFER_DATA = 31000,
	PC_IPC_MEDIA_TYPE_SYN = 31001,
	PC_IPC_MEDIA_TYPE_ACK = 31101,
	PC_IPC_STOP_MEDIA_SYN = 31002,
	PC_IPC_STOP_MEDIA_ACK = 31102,
	PC_IPC_VOICE_STATUS_SYN = 31003,
	PC_IPC_VOICE_STATUS_ACK = 31103,
	PC_IPC_TALK_STATUS_SYN = 31004,
	PC_IPC_TALK_STATUS_ACK = 31104,
	PC_IPC_REPORT_STATUS_SYN = 31005,
	PC_IPC_REPORT_STATUS_ACK = 31105,
	PC_IPC_HEART_SYN = 31006,
	PC_IPC_HEART_ACK = 31106,
	PC_IPC_PLAYBACK_SYN = 31007,
	PC_IPC_PLAYBACK_ACK = 31107,
	PC_IPC_PLAYBACK_STOP_SYN = 31008,
	PC_IPC_PLAYBACK_STOP_ACK = 31108,

	/* UPNPͨ��Э�� */
	PC_IPC_UPNP_LOGIN_SYN = 31009,
	PC_IPC_UPNP_LOGIN_ACK = 31109,
	PC_IPC_UPNP_CHANGE_PWD_SYN = 31010,
	PC_IPC_UPNP_CHANGE_PWD_ACK = 31110,

	/* PTZ */
	PC_IPC_PTZ_SYN = 31011,
	PC_IPC_PTZ_ACK = 31111,
	PC_IPC_GET_PRESETPOINT_SYN = 31012,
	PC_IPC_GET_PRESETPOINT_ACK = 31112,

	/* TCPת����SIP������ͨ��Э�� */
	SIP_TRANS_LOGIN_SYN = 41000,
	SIP_TRANS_LOGIN_ACK = 41100,
	SIP_TRANS_TCPCONN_SYN = 41001,
	SIP_TRANS_TCPCONN_ACK = 41101,
	SIP_TRANS_HEART_SYN = 41002,
	SIP_TRANS_HEART_ACK = 41102,

};

struct trans_msg_s{
	unsigned int	magic;		 /* ����ͷ */
	unsigned char	channel;	 /* ͨ��id��0xff��ʾDVR */
	unsigned char	flag;		 /* ������־ */
	short			cmd_type;	 /* ָ������ */
	unsigned int	cmd;		 /* ָ����*/
	unsigned int	seqnum;		 /* ��ˮ�� */
	unsigned int	length;		 /* ���峤�� */
};

/* �û����豸��¼ */
struct tf_login_syn_s{
	char register_code[32];
	char username_or_sn[32];
};

// SIP MSG �ص� ������Ψһ
typedef void (* zsip_msg_cb)(int iType, int iStatus, char* buffer, int len);

struct IEvents
{
	virtual void OnStatusReport(int iType, int iStatus, const char* pText, void * pCookie = NULL) = 0;
	virtual void OnFrameData(int iType, char* pData, int iSize, void * pCookie = NULL) = 0;
	//virtual void OnCloseThread()= 0;
};

enum EStatusType 
{ 
	stSIP,							// SIP��������Ϣ, ��ӦESIPStatus
	stStream,						// ��״̬��Ϣ, ��ӦEStreamStatus
	stNatType,						// ��������Ϣ 
	stUpnp,							// UPNP�豸��Ϣ, ��ӦEUPNPStatus
};

enum ESIPStatus 
{ 
	sipsMessage,					// ֪ͨSIP������������Ϣ 
	sipsSessionTimeout,				// ֪ͨSession��ʱ, �����µ�½
	sipsUpdateDNS,
};

enum EStreamStatus 
{
	ssUnknownError = -1,			// ֪ͨδ֪����

	ssUPNPConnectSucc = 1,			// ֪ͨUPNP���ӳɹ�
	ssUPNPConnectFailed,			// ֪ͨUPNP����ʧ��
	ssUPNPDisconnect,				// ֪ͨUPNP�Ͽ�����
	ssUPNPRecvFailed,				// ֪ͨUPNP���մ���

	ssP2PConnectSucc = 100,			// ֪ͨP2P���ӳɹ�
	ssP2PConnectFailed,				// ֪ͨP2P����ʧ��
	ssP2PDisconnect,				// ֪ͨP2P�Ͽ�����
	ssP2PRecvFailed,				// ֪ͨP2P���մ���
	ssP2PSendFailed,				// ֪ͨP2P���ʹ���

	ssDeliverConnectSucc = 200,		// ֪ͨ��ת���ӳɹ�
	ssDeliverConnectFailed,			// ֪ͨ��ת����ʧ��
	ssDeliverDisconnect,			// ֪ͨ��ת�Ͽ�����
	ssDeliverRecvFailed,			// ֪ͨ��ת���մ���
	ssDeliverSendFailed,			// ֪ͨ��ת���ʹ���

	ssPlayBackReqSucc = 300,		// ֪ͨ�ط�����ɹ�
	ssPlayBackReqFailed,			// ֪ͨ�ط�����ʧ��
	ssPlayBackStop,					// ֪ͨ��ǰ�طŽ���

	ssOpenSoundSucc = 500,			// ֪ͨ����Ƶ�ɹ�
	ssOpenSoundFailed,				// ֪ͨ����Ƶʧ��
	ssCloseSoundSucc,				// ֪ͨ�ر���Ƶ�ɹ�
	ssCloseSoundFailed,				// ֪ͨ�ر���Ƶʧ��
	ssOpenTalkSucc,					// ֪ͨ�򿪶Խ��ɹ�
	ssOpenTalkFailed,				// ֪ͨ�򿪶Խ�ʧ��
	ssCloseTalkSucc,				// ֪ͨ�رնԽ��ɹ�
	ssCloseTalkFailed,				// ֪ͨ�رնԽ�ʧ��

	ssChangeToQVGA = 600,			// ֪ͨ��Ҫ�л�����ΪQVGA
	ssChangeToVGA,					// ֪ͨ��Ҫ�л�����ΪVGA

	ssChangeStreamSucc,				// �л�����ͨ���ɹ�
	ssChangeStreamFailed,			// �л�����ͨ��ʧ��

	ssPTZCfgSucc,					// PTZ���óɹ�
	ssPTZCfgFailed,					// PTZ����ʧ��

	ssPTZGetPresetSucc,				// ��ȡPTZԤ�õ���Ϣ�ɹ�
	ssPTZGetPresetFailed,			// ��ȡPTZԤ�õ���Ϣʧ��
};

enum EUPNPStatus
{
	upnpLoginSuper_0,				// login OK, permit:super
	upnpLoginNormal_0,				// login OK, permit:normal
	upnpLoginfalied,				// login falied,

	upnpChangePwdSucc,				// �޸�����ɹ�
	upnpChangePwdFailed,			// �޸�����ʧ��
	upnpQueryUpnpSucc,				// ֪ͨ��ѯ�豸��Ϣ�ɹ�
	upnpQueryUpnpFailed,			// ֪ͨ��ѯ�豸��Ϣʧ��
};

enum proto_req
{
	proto_transit_play = 100,
	proto_p2p_play,
	proto_upnp_play,
	proto_p2p_playback,
	proto_upnp_playback,
	proto_upnp_query,
};

enum asyn_req_status
{
	req_status_invalid,
	req_status_timeout,
	req_status_canceled,
	req_status_requesting,
	req_status_registering,
	req_status_connected,
	req_status_process_complete,
};

typedef enum 
{
	CMD_STOP = 0,
	CMD_LEFT,//��
	CMD_RIGHT,//��
	CMD_UP,//��
	CMD_DOWN,//��
	CMD_CALL_CRIUSE = 0x12, // ����Ѳ��
	CMD_AUTOSCAN = 0x13,
	CMD_CALLPRESET = 0x15,
	CMD_CALL_KINDSCAN = 0x16,  //���л���ɨ��
	CMD_FOCUSFAR = 0x23,
	CMD_FOCUSNAER = 0x24,
	CMD_IRISOPEN = 0x25,
	CMD_IRISCLOSE = 0x26,
	CMD_ZOOMTELE = 0x27,
	CMD_ZOOMWIDE  = 0x28,
	CMD_SET_CRIUSE_P = 0x32, //����Ѳ����
	CMD_SETPRESET = 0x35,
	CMD_CRIUSE,
	CMD_CLRPRESET,
	CMD_STOPSCAN,
	CMD_SET_DWELLTIME,
	CMD_KINDSCAN_START,
	CMD_KINDSCAN_END,
	CMD_CLRCRIUES_LINE,
	CMD_CLR_SCAN_LINE,
	CMD_CLR_KINDSCAN,
	
}PTZ_CMD_E;

#endif /*__ZMD_PROTOCOL_H__*/

