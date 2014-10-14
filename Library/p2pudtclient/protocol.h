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
	/* 客户端与中转服务器通信协议 */
	PC_TRANS_LOGIN_SYN = 11000,
	PC_TRANS_LOGIN_ACK = 11100,

	PC_GET_IPCSTATE_SYN	= 11002,
	PC_GET_IPCSTATE_ACK	= 11102,

	PC_TRANS_HEART_SYN = 11001,
	PC_TRANS_HEART_ACK = 11101,

	/* 设备与中转服务器通信协议 */
	IPC_TRANS_LOGIN_SYN = 21000,
	IPC_TRANS_LOGIN_ACK = 21100,
	IPC_TRANS_HEART_SYN = 21001,
	IPC_TRANS_HEART_ACK = 21101,
	IPC_TRANS_STOP_SYN = 21002,
	IPC_TRANS_STOP_ACK = 21102,

	/* 客户端与设备通信协议 */
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

	/* UPNP通信协议 */
	PC_IPC_UPNP_LOGIN_SYN = 31009,
	PC_IPC_UPNP_LOGIN_ACK = 31109,
	PC_IPC_UPNP_CHANGE_PWD_SYN = 31010,
	PC_IPC_UPNP_CHANGE_PWD_ACK = 31110,

	/* PTZ */
	PC_IPC_PTZ_SYN = 31011,
	PC_IPC_PTZ_ACK = 31111,
	PC_IPC_GET_PRESETPOINT_SYN = 31012,
	PC_IPC_GET_PRESETPOINT_ACK = 31112,

	/* TCP转发与SIP服务器通信协议 */
	SIP_TRANS_LOGIN_SYN = 41000,
	SIP_TRANS_LOGIN_ACK = 41100,
	SIP_TRANS_TCPCONN_SYN = 41001,
	SIP_TRANS_TCPCONN_ACK = 41101,
	SIP_TRANS_HEART_SYN = 41002,
	SIP_TRANS_HEART_ACK = 41102,

};

struct trans_msg_s{
	unsigned int	magic;		 /* 特殊头 */
	unsigned char	channel;	 /* 通道id。0xff表示DVR */
	unsigned char	flag;		 /* 丢包标志 */
	short			cmd_type;	 /* 指令类型 */
	unsigned int	cmd;		 /* 指令字*/
	unsigned int	seqnum;		 /* 流水号 */
	unsigned int	length;		 /* 包体长度 */
};

/* 用户或设备登录 */
struct tf_login_syn_s{
	char register_code[32];
	char username_or_sn[32];
};

// SIP MSG 回调 进程内唯一
typedef void (* zsip_msg_cb)(int iType, int iStatus, char* buffer, int len);

struct IEvents
{
	virtual void OnStatusReport(int iType, int iStatus, const char* pText, void * pCookie = NULL) = 0;
	virtual void OnFrameData(int iType, char* pData, int iSize, void * pCookie = NULL) = 0;
	//virtual void OnCloseThread()= 0;
};

enum EStatusType 
{ 
	stSIP,							// SIP服务器消息, 对应ESIPStatus
	stStream,						// 流状态消息, 对应EStreamStatus
	stNatType,						// 打洞类型消息 
	stUpnp,							// UPNP设备消息, 对应EUPNPStatus
};

enum ESIPStatus 
{ 
	sipsMessage,					// 通知SIP服务器推送消息 
	sipsSessionTimeout,				// 通知Session超时, 需重新登陆
	sipsUpdateDNS,
};

enum EStreamStatus 
{
	ssUnknownError = -1,			// 通知未知错误

	ssUPNPConnectSucc = 1,			// 通知UPNP连接成功
	ssUPNPConnectFailed,			// 通知UPNP连接失败
	ssUPNPDisconnect,				// 通知UPNP断开连接
	ssUPNPRecvFailed,				// 通知UPNP接收错误

	ssP2PConnectSucc = 100,			// 通知P2P连接成功
	ssP2PConnectFailed,				// 通知P2P连接失败
	ssP2PDisconnect,				// 通知P2P断开连接
	ssP2PRecvFailed,				// 通知P2P接收错误
	ssP2PSendFailed,				// 通知P2P发送错误

	ssDeliverConnectSucc = 200,		// 通知中转连接成功
	ssDeliverConnectFailed,			// 通知中转连接失败
	ssDeliverDisconnect,			// 通知中转断开连接
	ssDeliverRecvFailed,			// 通知中转接收错误
	ssDeliverSendFailed,			// 通知中转发送错误

	ssPlayBackReqSucc = 300,		// 通知回放请求成功
	ssPlayBackReqFailed,			// 通知回放请求失败
	ssPlayBackStop,					// 通知当前回放结束

	ssOpenSoundSucc = 500,			// 通知打开音频成功
	ssOpenSoundFailed,				// 通知打开音频失败
	ssCloseSoundSucc,				// 通知关闭音频成功
	ssCloseSoundFailed,				// 通知关闭音频失败
	ssOpenTalkSucc,					// 通知打开对讲成功
	ssOpenTalkFailed,				// 通知打开对讲失败
	ssCloseTalkSucc,				// 通知关闭对讲成功
	ssCloseTalkFailed,				// 通知关闭对讲失败

	ssChangeToQVGA = 600,			// 通知需要切换码流为QVGA
	ssChangeToVGA,					// 通知需要切换码流为VGA

	ssChangeStreamSucc,				// 切换码流通道成功
	ssChangeStreamFailed,			// 切换码流通到失败

	ssPTZCfgSucc,					// PTZ设置成功
	ssPTZCfgFailed,					// PTZ设置失败

	ssPTZGetPresetSucc,				// 获取PTZ预置点信息成功
	ssPTZGetPresetFailed,			// 获取PTZ预置点信息失败
};

enum EUPNPStatus
{
	upnpLoginSuper_0,				// login OK, permit:super
	upnpLoginNormal_0,				// login OK, permit:normal
	upnpLoginfalied,				// login falied,

	upnpChangePwdSucc,				// 修改密码成功
	upnpChangePwdFailed,			// 修改密码失败
	upnpQueryUpnpSucc,				// 通知查询设备信息成功
	upnpQueryUpnpFailed,			// 通知查询设备信息失败
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
	CMD_LEFT,//左
	CMD_RIGHT,//右
	CMD_UP,//上
	CMD_DOWN,//下
	CMD_CALL_CRIUSE = 0x12, // 呼叫巡航
	CMD_AUTOSCAN = 0x13,
	CMD_CALLPRESET = 0x15,
	CMD_CALL_KINDSCAN = 0x16,  //呼叫花样扫描
	CMD_FOCUSFAR = 0x23,
	CMD_FOCUSNAER = 0x24,
	CMD_IRISOPEN = 0x25,
	CMD_IRISCLOSE = 0x26,
	CMD_ZOOMTELE = 0x27,
	CMD_ZOOMWIDE  = 0x28,
	CMD_SET_CRIUSE_P = 0x32, //设置巡航点
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

