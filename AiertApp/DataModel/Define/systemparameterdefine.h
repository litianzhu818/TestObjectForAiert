
#ifndef __SYSTEM_PARAMETER_STRUCT_H__
#define __SYSTEM_PARAMETER_STRUCT_H__
#include "common.h"
#define	CHANNEL     			16
#define	ALARMOUTPORTNUM			8
#define LOGDISPLAYMAX					12
#define DISPLAY_MAX_NUM			  10   /*每次搜索文件的个数*/
#define MAX_ALARM_ZONE				16

#if 1

typedef struct
{
	unsigned int		    m_magic; // 魔数　固定为0x12345678
	unsigned int		    m_size;  // 结构体大小
}VIDEO_STHDR;

typedef struct
{
	//	unsigned char 		m_chlCount;
	unsigned char 			m_bitswidth;  // 音频采样的位宽
	unsigned char 			m_reserved1[3];
	unsigned int			m_bitRate;// 码率
	unsigned int			m_sampleRate;// 采样率
}ENCAUDIO_PARA;

typedef struct
{
	unsigned char				chlIndex;   // 通道号
	unsigned char				frameRate; // 帧率
	unsigned char				resolution; // 清晰度
	unsigned char				reserved1;
	char						chlName[16]; // 通道名称
}ENC_CH_PARA;

typedef struct
{
	VIDEO_STHDR                 m_Hdr;
	char						m_VerDev[28];  //设备名称
	char						m_VerFile;	// 文件版本
	unsigned char				m_BegYear;
	unsigned char				m_BegMonth;
	unsigned char				m_BegDay;
	unsigned char				m_BegHour;
	unsigned char				m_BegMinute;
	unsigned char				m_BegSecond;  // 开始的年月日时分秒
	unsigned char				m_EndYear;
	unsigned char				m_EndMonth;
	unsigned char				m_EndDay;
	unsigned char				m_EndHour;
	unsigned char				m_EndMinute;
	unsigned char				m_EndSecond;// 结束的年月日时分秒
	unsigned char				m_ChlCount;  // t通道数目
	unsigned char				m_RecType;	// 录像类型
	unsigned char				m_FileProtected;//录像是否保护
	unsigned char				m_pad0;//保留
	unsigned char				m_VideoType; // 视频制式
	unsigned short				m_DevNo; // 设备编号
	ENCAUDIO_PARA				m_Audio;  // 音频编码参数
	unsigned int				m_IndexTblOffset;//视频I帧索引表相对文件头部的偏移
	unsigned int				m_MovieOffset; //真实的录像数据位置 即第一个I帧的位置，（相对文件的偏移是m_movieoffset+512）
	unsigned short			    m_nDevType; //设备类型数字编号
	char						m_Reserved3;
	char						m_DateShowFmt;// 日期显示的格式暂时保留
	char						m_cDevType[12];// 设备类型字符串编码
	ENC_CH_PARA				    m_ChInfo; //通道的视频编码参数
}VideoFileInfo;

typedef struct
{
	VideoFileInfo		     	m_FileInfo; // 文件信息
}VIDEOFILE_HEADER;


/**********************************************************************
 copy from Net_ConnectionList.h
 目前type字段仅在CMD_ALARM_UPDATE 0x9010, CMD_PING 0x9001命令下生效。
 其中在0x9001命令中0表示获取版本信息及其本地IP信息。
 其中在0x9010命令中0表示不接收报警信息，1表示建立报警信息接收长连接。
 **********************************************************************/
typedef struct
{
	int									head; 		//0xaaaa5555					4字节
	int									length;		//data total length		4字节
	unsigned char						type;			//0or1  							1字节
	unsigned char						channel;	//video&audio channel	1字节
	unsigned short					    commd;		//control cmd					2字节
}Header;

typedef struct
{
	unsigned int 			m_u8Exist;  // 0: 不存在 ， 1 存在但是没有加载上，2，存在并加载上文件系统
	unsigned long			m_u32Capacity;  // 以M为单位
	unsigned long			m_u32FreeSpace; // 以M 为单位
	unsigned char			m_cDevName[16];
}BlockDevInfo_S;

/**********************************************************************
 copy from netserver.cpp
 **********************************************************************/
typedef struct
{
	char										ipaddr[20];
	char										geteway[20];
	char										submask[20];
	char										mac[20];
    //char									newmac[20];//20120411 jack 禁止探索工具修改IPC MAC地址
}ipaddr_tmp;

typedef struct
{
	unsigned short					webPort;//用于给搜索工具返回web监听端口
	unsigned short					videoPort;//用于给搜索工具返回video监听端口
	unsigned short					phonePort;//用于给搜索工具返回phone监听端口
	unsigned short					recver;
}devTypeInfo;//20120411 add by jack

/**********************************************************************
 copy from Common.h
 **********************************************************************/
typedef struct
{
	unsigned char 					year;
	unsigned char 					month;
	unsigned char 					day;
	unsigned char 					hour;
	unsigned char 					minute;
	unsigned char 					second;
	unsigned char 					week;
	unsigned char 					reserved;
} datetime_setting;


/**********************************************************************
 copy from arvin
 **********************************************************************/
typedef struct
{
	unsigned int		m_nVHeaderFlag; // 帧标识，x0dc(I帧), x1dc（p帧）
	unsigned int 		m_nVFrameLen;  // 帧的长度
	unsigned char		m_u8Hour;
	unsigned char		m_u8Minute;
	unsigned char		m_u8Sec;
    unsigned char		m_u8Pad0;// 代表附加消息的类型，根据这个类型决定其信息结构0 代表没有1.2.3 各代表其信息
    unsigned int		m_nILastOffset;// 此帧相对上一个I FRAME 的偏移只对Iframe 有用
	long long			m_lVPts;		// 时间戳
	unsigned int		m_nAlarmInfo;
	unsigned int		m_nReserved;
}VideoFrameHeader;

// 音频帧头　(音频压缩格式为ADPCM)8K采样率，8（bitwidth）
typedef struct
{
	unsigned int		m_nAHeaderFlag; // 帧标识， x1wb x（’0’, ‘1’, ‘2’, ‘3’…）
	unsigned int 		m_nAFrameLen;  // 帧的长度
	long long			m_lAPts;		// 时间戳
}AudioFrameHeader;

/**********************************************************************
 copy from logmanage.h
 **********************************************************************/
typedef struct
{
	unsigned char		m_u8AlarmType; // 1 : 移动侦测 ，2   防区报警   3   防区报告
	unsigned char   m_u8AFlag;	//开始事件：m_aflag＝00；//结束事件：m_aflag=0xff
	unsigned char  	m_u8AlarmNum;  //报警代号
	unsigned char	 	m_u8FangNum;   // 防区号
	unsigned char  	m_u8AStatus[8];  //  警情
	unsigned char  	m_u8AZoneNum;  //分区号
	unsigned char		m_u8Reserved[27];
}UserAlarmEvent;

typedef struct
{
	int			  			m_u32OperCode;	// 操作码
	unsigned char		m_u8Reseved[36];
}UserOperEvent;

typedef struct
{
    int			  		m_u32FaultCode; // 错误码
    unsigned char	m_u8Reseved[36];
}UserFaultEvent;

typedef struct
{
    int			  		m_u32SystemCode; // 系统码
    unsigned char	m_u8Reseved[36];
}UserSystemEvent;

typedef struct
{
    int			  		m_u32CH; // 移动报警通道
    unsigned char	m_u8Reseved[36];
}UserMotionEvent;

typedef struct
{
	unsigned char		m_u8EventType; // 事件类型'A'  ALARM ,'O' OPERATION  'F': FAULT . 'S' : system  'M' Motion
	unsigned char		m_u8EDay; // 天
	unsigned char		m_u8EHour;// 小时
	unsigned char		m_u8EMinute;// 分钟
	unsigned char		m_u8ESec;// 秒
	unsigned char		m_u8Reserved[3];
	union
	{
		UserAlarmEvent 		m_AlarmEvent;
		UserFaultEvent		m_FaultEvent;
		UserOperEvent			m_OperEvent;
		UserSystemEvent		m_SystemEvent;
		UserMotionEvent		m_MotionEvent;
	}t_user_event;
}EventLogItem;

typedef struct
{
	unsigned char  	m_u8Year; // 日志年
	unsigned char  	m_u8Month;//日志月
	unsigned char		m_u8Day; // 日志天
	unsigned char		m_u8LogType; //日志类型,报警，操作，故障，所有
	unsigned char		m_u8SearchType;
	unsigned char		m_u8Reserved;
}FindUserLogItem;//finduserlogterm;

typedef struct
{
	unsigned char 	m_u8ListNum;//文件个数
	unsigned char		m_u8StartNum; // 第一成员在数组中的编号
	EventLogItem 		m_Item[LOGDISPLAYMAX];
}FindLogItems;

/**********************************************************************
 copy from filemanage.h
 **********************************************************************/
typedef struct TagFindFileType
{
	//struct tm time;//查询录像的开始时间
	int      m_i8Reserved[2];
	int		 devType;//2/*设备类型0-HDD 1-MHDD 2-SD 暂时没有用到*/
	int 	 channel;//2/*通道1~16*/
	int		 RecordType;//2/*录像类型0-全部，1-定时，2-手动，3-报警*/
	int		 SearchType;/*查询方式 0 ，录像类型查询，1 司机名查询 2   车牌号查询 暂时没有用到*/
	char	 m_drivername[17];//暂时没有用到
	char	 m_vehiclenum[17];//暂时没有用到
}FindFileType;

/*存储文件名的结构体*/
typedef struct tag_rec_dirent
{
    
	unsigned short	d_ino; 		/*条目编号*/
	//unsigned short	d_reclen;	/*名称长度*/
	unsigned short	lock;
	unsigned int 		start_time;  /*文件开始时间*/
	unsigned int 		end_time;	/* 文件结束时间*/
	unsigned int    filesize;     /*文件大小以K为单位*/
	unsigned int	  channel; 	/* 通道号*/
	int							m_filetype;
	int							m_alarmtype;
	char						d_name[96]; 		/*文件名(有路径)*/
	
}rec_dirent;

typedef struct
{
	int						fileNb;//文件个数
	rec_dirent    namelist[DISPLAY_MAX_NUM];
}RecordFileName;

/**********************************************************************
 copy from netserver.h
 **********************************************************************/
typedef struct tag_playback_node
{
	unsigned int		p_mode; 		// 0-回放 1- 下载
	unsigned int		p_offset;		// 回放 - 时间偏移量  下载 - 大小偏移量(K)
	unsigned int 		start_time;		/*文件开始时间*/
	unsigned int 		end_time;		/* 文件结束时间*/
	unsigned int    filesize;		/*文件大小以K为单位*/
	int							m_filetype;		//0-手动，1-定时，2-报警
	char						d_name[96]; 	/*文件名(有路径)*/
}playback_node;

/**********************************************************************
 copy from ptz.h
 **********************************************************************/
typedef enum
{
	CMD_STOP = 0,
	CMD_LEFT,
	CMD_RIGHT,
	CMD_UP,
	CMD_DOWN,
    
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

struct PTZ_CTRL
{
	PTZ_CMD_E cmd;
	unsigned short para0;
	unsigned short para1;
};

#endif
typedef struct
{
    
	//*8-15 bits保留
	//#define		REL_SPECIAL_COM		0x00000000
	//*16-23 bits 代表设备类型00:IPC CMOS VGA 01:IPC CMOS 720P 02:IPC CMOS 1080P 03 IPC CCD 04:DVR 05:NVR
	//#define		REL_VERSION_COM		0x00000000
	//*24-31表示芯片类型
	//#define		CHIP_TYPE_HI3511	0x50000000	//3507/3511芯片
	//#define		CHIP_TYPE_HI3515	0x52000000
	//#define		CHIP_TYPE_HI3520	0x54000000
	//#define		DEV_TYPE_INFO		CHIP_TYPE_HI3511+REL_VERSION_COM+REL_SPECIAL_COM+MAX_REC_CHANNEL
    
	int		     	DeviceType;				//设备类型DEV_TYPE_INFO
	char			DeviceName[32];			//设备名称
	char			SerialNumber[32];		//MAC地址
	char			HardWareVersion[32];	//硬件版本
	char			SoftWareVersion[32];		//软件版本
	char			VideoNum;				//视频通道数
	char			AudioNum;				//音频通道数
	char			AlarmInNum;			//报警输入
	char			AlarmOutNum;			//报警输出
	char			SupportAudioTalk;		//是否支持对讲1:支持0:不支持
	char			SupportStore;			//是否支持本地储存1:支持0:不支持
	char			SupportWifi;			//是否支持WIFI 1:支持0:不支持
	char			resver;					//保留
	
}TYPE_DEVICE_INFO;

typedef struct
{
	unsigned char		       	m_uCenterIP[4];   	// 中心服务器IP
	unsigned char				m_Switch;			// 是否连接平台
	unsigned char				deviceid[15];		// 平台注册ID
	char						passwd[16];					// 平台用户密码
	unsigned int				m_heartbeat;				// 心跳间隔时间(s)
	unsigned short			m_uPhoneListenPt; 	// 手机监听端口
	unsigned short			m_uVideoListenPt; 	// 视频监听端口
	unsigned short			m_uHttpListenPt;  	// http 监听端口
	unsigned short			m_uEnrolPort;		// 注册服务器端口
	
}TYPE_CENTER_NETWORK;

typedef struct
{
	unsigned char				m_uLocalIp[4];		// 本机ip 地址
	unsigned char				m_uMask[4];			// 子网掩码
	unsigned char				m_uGateWay[4];		// 网关
	unsigned char				m_uMac[6];			// MAC地址
	unsigned char				m_dhcp;				// DHCP开关1:开0:关
	unsigned char				m_upnp;				// upnp开关1:开0:关
	unsigned short			m_v_port;			// 视频映射端口
	unsigned short			m_http_port;		// HTTP映射端口
	unsigned short			m_plat_port;		// 平台映射端口
	unsigned short			m_phone_port;		// 手机映射端口
}TYPE_NETWORK_DEVICE;


typedef struct
{
	unsigned char				m_umDNSIp[4]; 		// 主 DNS
	unsigned char				m_usDNSIp[4];		// 备用 DNS
}TYPE_NETWORK_DNS;

typedef struct
{
	unsigned char				m_ntp_switch;				// NTP对时开关
  	char						m_Reserved[3];
}TYPE_NETWORK_NTP;

typedef struct
{
	unsigned int         	m_uPppoeIP[4]; 	// 暂未使用
	char					m_s8UserName[32];
	char					m_s32Passwd[16];
	unsigned char			m_u8PppoeSelected;	//是否启用PPPOE 1:on 0:off
	unsigned char			m_u8Reserved[3];
    
}TYPE_PPPOEPARA;

typedef struct
{
	unsigned char 			m_u8NatIpAddr[4];
	unsigned char       	m_u8NatIpValid;
	unsigned char			m_u8Reserved[3];
}TYPE_NATSETPARA;

typedef struct
{
	char					m_s8Name[32];		// 域名
	char					m_s8UserName[16];
	char					m_s32Passwd[16];
	unsigned char			m_u8Selected;
	unsigned char			m_server;			// 1:表示3322.org, 2:表示dynDDNS.org 3:88ip 4:no-ip
	unsigned char			m_u8Reserved[6];
	
}TYPE_DYNAMICDOMAIN;

typedef struct
{
	char					m_server[32];		// 服务器地址
	char					m_account[32];		// 帐户
	char					m_password[16];		// 密码
	int					m_port;				//端口
}TYPE_FTP;

typedef struct
{
	char					m_title[64];			//标题
	char					m_server[32];		// 服务器地址
	char					m_addr[32];			// 接收邮箱地址
	char					m_account[32];		// 发送邮箱地址
	char					m_password[16];		// 密码
	int						m_mode;				// 认证模式
	int						m_u8Sslswitch;		//是否启用SSL 1:启用0: 不启用
	int						m_u16SslPort;		//端口
}TYPE_EMAIAL;

typedef struct
{
	unsigned char			m_u8Selected;		//WIFI是否启用1:on 0:off
	unsigned char			m_dhcp;			//dhcp是否启用1:on 0:off
	unsigned char			m_uLocalIp[4];		// ip 地址
	unsigned char			m_uMask[4];			// 子网掩码
	unsigned char			m_uGateWay[4];		// 网关
	unsigned char			m_uMac[6];			// MAC地址
	unsigned char			m_umDNSIp[4]; 		// 主 DNS
	unsigned char			m_usDNSIp[4];		// 备用 DNS
	
}TYPE_WIFI_ADDR;

typedef struct
{
    char				RouteDeviceName[32];	//热点名称
    char				Passwd[32];				//密码
	unsigned char				AuthenticationMode;		//认证模式
	unsigned char				EncryptionProtocol;		//加密协议
	unsigned char				Index;					//通道
	unsigned char				SignalLevel;				//热点强度(客户端需要除255得到百分比)1-255
	unsigned char				ConnectStatus;		//连接状态0:未连接1:已连接
	unsigned char				WepKeyMode;     //0:ASCII 1:Hex
    char               BackupFlag;
    char               m_Reserved;
}TYPE_WIFI_LOGIN;

typedef struct
{
	TYPE_WIFI_ADDR		WifiAddrMode;		//设备获取地址方式
	TYPE_WIFI_LOGIN		LoginWifiDev;		//登陆WIFI结构
	
}TYPE_WIFI_DEVICE;


typedef struct
{
	TYPE_CENTER_NETWORK			m_CenterNet;  	// 位0 平台及监听端口设置
	TYPE_NETWORK_DNS			m_DNS;    		// 位1 DNS 服务器设置
	TYPE_NETWORK_DEVICE			m_Eth0Config;  	// 位2 本机第一网口及映射端口设置
	TYPE_NETWORK_DEVICE			m_Eth1Config;  	// 位3 本机第二个网口的设置
	TYPE_PPPOEPARA				m_PppoeSet;		// 位4 PPPOE
	TYPE_NATSETPARA				m_NatConfig;	// 位5预留结构体
	TYPE_DYNAMICDOMAIN			m_DomainConfig;	// 位6   DDNS服务
	TYPE_FTP					m_ftp;			// 位7 FTP上传
	TYPE_EMAIAL					m_email;		// 位8 邮箱服务
	TYPE_NETWORK_NTP		m_NTP;	// NTP对时
	TYPE_WIFI_DEVICE		m_WifiConfig;	//wifi
	unsigned int				m_changeinfo;	// 更新指示 对应bit0-bit10 1:有更新0:没有更新
    
}NETWORK_PARA;

typedef struct
{
	unsigned int 		m_uAdminPassword;		// 管理员密码
	unsigned int 		m_uOperatePassword;		// 操作员密码
	unsigned int 		m_uCurrentPwd;			// 当前登录的密码
	unsigned char		m_uPwdEnable;			// 密码功能打开0: 没有密码，1: 有密码
	unsigned char		m_Reserved[19];			// 保留 23->19
	unsigned int		m_changeinfo;			// 更新指示 0无更新，1有更新
}PASSWORD_PARA;


typedef struct
{
	unsigned short 		m_u16StartTime;			// 时间任务片段的开始时间 60xh+m
  	unsigned short		m_u16EndTime;			// 时间任务片段的结束时间 60xh+m
   	unsigned char			m_u8Valid;				// 时间段是否有效
	unsigned char			m_u8Reserved;
	unsigned short		m_validChannel;			// 对应的定时器通道有效位
}TIMETBLSECTION;

typedef struct
{
	unsigned short		m_uTimeTbl[8];			// 时间表	4个时间段,单位:minute
	unsigned short		m_uMdTbl[8];			// 移动侦测
	unsigned short		m_uAlarmTbl[8];			// 外部报警
	unsigned char			m_uWeekDay;			// week date  (0--8):sun--every--*****
	unsigned char			m_uTrigeType;			// 录像触发类型:	0 TIMER , 1 SEN, 2 EVENT
	unsigned char			m_Reserved[6];
}RECTIMERS_PARA;

typedef struct
{
	RECTIMERS_PARA		m_TimerTask[8];			// 定时录像任务设置
	unsigned char			m_uTimerSwitch;			// 时间表录像是否开启
	unsigned char 		m_uPowerRecEnable;		// 是否有开机录像
	unsigned char			m_u8PreRecordTime;
	unsigned char			m_u8RecordDelay;
	unsigned char			m_Reserved[8];
}REC_TASK_PARA;

typedef struct
{
	TIMETBLSECTION		m_uTimeTbl[4];			// 时间表	4个时间段,单位:minute
	TIMETBLSECTION		m_uMdTbl[4];			// 移动侦测
	TIMETBLSECTION		m_uAlarmTbl[4];			// 外部报警
	TIMETBLSECTION		m_uAorMTbl[4];			// 外部报警或移动侦测
	unsigned char		m_uWeekDay;				// 对CS未使用 week date  (0--8):sun--every--*****
	unsigned char		m_uTrigeType;			// 对CS未使用 录像触发类型:	0 TIMER , 1 SEN, 2 EVENT
	unsigned char		m_Reserved[6];
}RECSCHEDULE_PARA;

typedef struct
{
	RECSCHEDULE_PARA	m_TimerTask[8];			// 定时录像任务设置: 周日-周六
	unsigned char		m_uTimerSwitch;			// 时间表录像是否开启
	unsigned char 		m_uPowerRecEnable;		// 是否有开机录像
	unsigned char		m_u8PreRecordTime;//未用
	unsigned char		m_u8RecordDelay;//未用
	unsigned char		m_u8PreRecordTimeValid; //预录标志
	unsigned char		m_u8RecordDelayValid;	//延时标志
	unsigned char		m_Reserved[6];
}RECORDTASK; // 每个通道的录像任务

typedef struct
{
	RECORDTASK			m_ChTask[CHANNEL];  		// 每个通道的录像任务
	unsigned int		m_changeinfo;		// 更新指示: 位0-31对应32个通道 0-无参数更新
	
}GROUPRECORDTASK;

typedef struct
{
	unsigned int 			m_uMachinId;		// 机器号码
	unsigned char 			m_uTvSystem;		// 系统制式:1 NTSC, 0  PAL
	unsigned char 			m_uHddOverWrite;	// 自动覆盖开关是否打开: 0 no, 1 yes
	unsigned char 			m_uHddorSD;			// 硬盘或者SD卡录像，若改变重启系统0:HDD 1:SD
	unsigned char			m_uCursorFb;		//未用
	unsigned char			m_uOutputMode;		// 0:VGA  1:HDMI
	unsigned char 			m_Reserved[7];
	unsigned int 			m_serialId;			// 机器序列号
	unsigned int			m_ChipType;			// 芯片类型:3520 3511 3512
	unsigned int			m_changeinfo;		// 更新指示 0无更新 1有更新
}MACHINE_PARA;

typedef struct
{
	unsigned char 			m_uChannelValid; 	// 主码流视频通道开关1:on  0:off
	unsigned char				m_uAudioSwitch;	// 主码流音频通道开关1:on  0:off
	unsigned char				m_uSubEncSwitch; // 子码流视频开关1:on 0:off
	unsigned char				m_uSubAudioEncSwitch; // 子码流音频开关1:on 0:off
	char 					m_Title[17];	 	 // 通道标题
	unsigned char 			m_uFrameRate;	 // 帧率	PAL(1-25) NTSC(1-30)
	unsigned char 			m_uResolution;	 // 清晰度  0:D1, 1: HD1, 2:CIF 3:QCIF 4:1080P 5:720P 6:VGA 7:QVGA
	unsigned char 			m_uQuality;		 // 画质quality	values:0--4 (最好)(很好)(好)(一般)(差)
	unsigned char 			m_uEncType;	// 1:CBR 0:VBR
	unsigned char			m_uSubRes;  	 // 子码流清晰度0:D1, 1: HD1, 2:CIF 3:QCIF 4:1080P 5:720P 6:VGA 7:QVGA
	unsigned char			m_uSubQuality; 	 // 子码流画质 values:0--4 (最好)(很好)(好)(一般)(差)
	unsigned char			m_uSubFrameRate; // 子码流帧率 PAL(1-25) NTSC(1-30)
	unsigned char 		m_uSubEncType;
	unsigned char			m_u16RecDelay;	 // 录像延时
	unsigned char			m_u8PreRecTime;  // 预录时间
	unsigned char			m_TltleSwitch;	 // 通道标题开关0:off 1:on
	unsigned char			m_TimeSwitch;	 // 时间标题开关0:off 1:on
	unsigned char			m_u8Reserved[3];
}CHANNEL_PARA;

typedef struct
{
	CHANNEL_PARA			m_ChannelPara[CHANNEL];  // 位0-31 通道编码参数
	unsigned int			m_changeinfo;		// 更新指示: 位0-31对应16路CHANNEL_PARA，
}CAMERA_PARA;

typedef struct
{
	unsigned short		m_u16X;/*X 开始坐标  0 - 720*/
	unsigned short		m_u16Y;/*y 开始坐标 0---480*/
	unsigned short		m_u16Width;/*叠加区域的宽度*/
	unsigned short		m_u16Height; /*叠加区域的高度*/
	unsigned char		m_u8OverValid; /*叠加是否有效1:on 0:0ff*/
	unsigned char		m_u8Reserved[7];
}OVERLAYSET;

typedef struct
{
	unsigned short		m_u16X;  /*X 坐标  0 - 720*/
	unsigned short		m_u16Y;  /*y 坐标 0---480*/
	unsigned char		m_u8OverValid; /*叠加是否开启*/
	unsigned char		m_u8Reserved[7];
}CHARINSERTSET;

typedef struct
{
	//注意:一个通道的四个区域开关一致
	OVERLAYSET			m_CoverLay[CHANNEL];  	/* 遮盖层1 */
	OVERLAYSET			m_CoverLay2[CHANNEL];  	/* 遮盖层 2*/
	OVERLAYSET			m_CoverLay3[CHANNEL];  	/* 遮盖层3 */
	OVERLAYSET			m_CoverLay4[CHANNEL];  	/* 遮盖层4 */
	unsigned int			m_changeinfo1;		// 更新指示: 对应0
	unsigned int			m_changeinfo2;		// 更新指示: 对应1
	unsigned int			m_changeinfo3;		// 更新指示: 对应2
	unsigned int			m_changeinfo4;		// 更新指示: 对应3
}VIDEOOSDINSERT;

typedef struct
{
	int 			m_nBrightness; 		// 前端摄像头亮度
	int 			m_nContrast;  		// 前端摄像头 对比度
	int				m_nSaturation;  	// 前端摄像头饱和度
	int 			m_nHue;  			// 前端摄像头色度
}ANALOG_CHANNEL;

typedef struct
{
	ANALOG_CHANNEL		m_Channels[CHANNEL]; 	// 各个通道前端模拟量设置
	unsigned int		m_changeinfo;		// 更新指示: 位0-31对应32个通道
}CAMERA_ANALOG;

typedef struct
{
	unsigned short 			m_nAlarmRecDelay; 	// 报警录像延时30 -100
    //	unsigned short 			m_nAlarmOutDelay;	// 报警输出延时30 -300
    //	unsigned short 			m_nBuzzeDelay; 		// 蜂鸣器响延时
	unsigned short 			m_nPreRecTime; 		//预录时间(0--20s)
	unsigned char 			m_Reserved[28];
}ALARM_PARA;

typedef struct
{
	char					m_cTitle[9];// IO  传感器名称
	char					m_Reserved[3];
}IO_SENSOR_TITLE;

typedef struct
{
	IO_SENSOR_TITLE		 	m_cTitle[9];// 传感器标题
	unsigned short  		m_uSwitch;	// 触发开关0 关闭 1开启
	unsigned short  		m_uInMode;	// 报警时外部输入的状态，0 常闭，1 常开
	unsigned short  		m_uAlarmSwitch;		// 是否报警
	unsigned short			m_uLogSwitch;		// 是否纪录日志0 不纪录 1 纪录
	unsigned short 			m_uLockSwitch;		// 报警录像是否加锁，0 不加，1加锁
	unsigned char			m_Reserved[10];
}SENSOR_IO;

typedef struct
{
	SENSOR_IO				m_SensorIO;   // IO 报警设置
}SENSOR_PARA;


typedef struct
{
	TIMETBLSECTION		m_TBLSection[4]; // 时间段
	unsigned char		m_u8WeekDay;	 // 星期几
	unsigned char		m_u8Reserved[3];
}ALARMINDATESET;

typedef struct
{
	ALARMINDATESET		m_TimeTblSet[8];    /* 每天一个处理按星期计算*/
	unsigned int			m_u32AlarmOutSel;	// 每一位代表一个输出有效0  无效  1  有效
	unsigned int			m_u32RecSel;		// 每一位代表一通道录像是否有效，0  无效 1 有效
	unsigned int			m_u32AlarmHandle;	// 每一位代表处理方式 bit0   声音报警     bit1     屏显           bit2  上传中心
	unsigned char 		m_u8TblValid;		// 是否启用时间表
	unsigned char			m_u8AlarmValid;	// 报警是否有效
	unsigned char			m_u8TrigeType;		/* 报警触发电瓶，0 常闭   1 常开*/
	unsigned char			m_u8Reserved;		// 保留5->1
}ALARMINSET;

typedef struct
{
	ALARMINSET			m_AlarmIn[4];
	unsigned int		m_changeinfo;		// 更新指示: 位0-7对应8路 ALARMINSET
}GROUPALARMINSET;

typedef struct
{
	unsigned char		m_uPowerOffSwitch; 	// 自动关机功能是否开启
	unsigned char 	m_uStartupMode;  	// 0: 关闭 1:定时开机，2:车钥匙开机即延时关机
	unsigned short	m_uShutDelay; 		// 关机的延时时间,以秒为单位。
	unsigned char		m_uStartupHour; 	// 开机时间小时
	unsigned char		m_uStartupMin; 		// 开机时间，分钟；
	unsigned char		m_uStartupSec;
	unsigned char		m_uShutDownHour; 	// 定时关机时间，小时
	unsigned char		m_uShutDownMin; 	// 定时关机，分钟
	unsigned char		m_uShutDownSec; 	// 定时关进秒
	unsigned char 	m_reserved[14];		// 兼容对齐 30 -> 14
	unsigned int		m_changeinfo;		// 更新指示: 0-无更新 1-有参数更新
}POWER_MANAGE;

typedef	 struct
{
	unsigned char 		m_uDateMode;		// 日期显示的方式	0 表示09/09/2004 ,1表示2004-09-09
	unsigned char		m_uTimeMode;		// 时间的格式:0 表示24 hours, 1 表示am/pm
	unsigned char		m_uFilePacketLen;	// 录像文件的打包时间: 0:15, 1:30, 2:45, 3:60(MIN)
	unsigned char		m_uWeekDayStart;	// 无功能 工作日开始: 0--6分别表示从sunday--saturday
	unsigned char 		m_uWeekDayEnd;		// 无功能 工作日的结束: 0--6分别表示从sunday--saturday
	unsigned char		m_uIdleTime;		// 无功能 system->date/time->idie time:0--9分别表示0.5, 1, 5, 10	MIN
	unsigned char		m_uTimeInSert;		// 无功能 时钟插入
	unsigned char		m_uTimeSyncMode;	// 无功能 时间同步模式
	unsigned long		m_uManualRecValid;	// 无功能 手动录像是否有效每一位代表一个通道0:无效 1 有效
	unsigned char		m_date_mode;		// 日期分隔符: - | / 三种
	unsigned char		m_self_start;		// 无功能 来电自启动
	unsigned char		m_screen_save;		// 无功能 屏幕保护
	unsigned char		m_language;			// 语言选择: 0-中文 1-英文
	unsigned char		m_uDiaphaneity;		// 透明度 1-7
	unsigned char 	m_uDecodeMode; 	//0:CIF 1:HD 2:D1
	unsigned char 	m_acceptAlarmMsg;  //0:不接收报警1:接收报警
	unsigned char 	m_Reserved[5]; 		// 未用 8->7->6->5
	unsigned int		m_changeinfo;		// 更新指示 0-无参数更新 1-有参数更新
}COMMON_PARA;
typedef struct
{	// 移动侦测设疑与处理
	ALARMINDATESET			m_TimeTblSet[8];    // 布撤防时间段
	unsigned int			m_uBlindSwitch;		// 视频遮挡开关 -- 1:开启,0:关闭
	unsigned int			m_uBlindSensitive;		// 视频遮挡灵敏度/*4个等级:0-高，1-较高，2-中，3:较低.4:低*/
	unsigned int  			m_uBlindAlarm;			// 报警输出每一位代表一个输出
	unsigned int 			m_uOutputDelay;		//输出延时
	unsigned int			m_uAalarmOutMode;  	// 每一位代表处理方式 bit0   声音报警   bit1  抓拍   bit2  FTP上传bit3 发送邮件bit4 屏幕提示bit5录像
}CNANNEL_SETUP;
typedef struct
{
	CNANNEL_SETUP	m_Channel[CHANNEL];	//
	unsigned int		m_changeinfo;		// 更新指示:位0-32对应32路灵敏度
}CAMERA_BLIND;  // 摄像头遮盖

typedef struct
{	// 移动侦测设疑与处理
	ALARMINDATESET		m_TimeTblSet[8];    /* 布撤防时间段*/
	unsigned int			m_uVideoLossSwitch;		// 视频丢失开关 -- 1:开启,0:关闭
	unsigned int  			m_uBlindAlarm;			// 报警输出每一位代表一个口输出
	unsigned int 			m_uOutputDelay;		//输出延时
	unsigned int			m_uAalarmOutMode;  	// 每一位代表处理方式 bit0   声音报警   bit1  抓拍   bit2  FTP上传bit3 发送邮件bit4 屏幕提示bit5录像
}CNANNEL_VideoLoss;
typedef struct
{
	CNANNEL_VideoLoss	m_Channel[CHANNEL];	//
	unsigned int			m_changeinfo;		// 更新指示:位0-32对应32路
}CAMERA_VideoLoss;  //视频丢失

typedef struct
{
	unsigned int	status;			//1:开启0:关闭
}AlarmPort;

typedef struct
{
	AlarmPort				m_uPort[ALARMOUTPORTNUM];
	unsigned int			m_changeinfo;		// 更新指示 0-无参数更新 1-有参数更新
}AlarmOutPort;

typedef struct
{   // 移动侦测区域设置
    //	unsigned short	 		m_uMDRaw[12]; 	// 移动侦测区域分成了16x12个的方格
	unsigned short			m_x;			// 区域左上的X坐标
	unsigned short			m_y;			// 区域左上Y坐标
	unsigned short			m_width;		// 区域的宽度
	unsigned short			m_height;		// 区域的高度
}MD_AREA;

typedef struct
{
	unsigned char			m_u8PresetEn;   	// 开启预置点 0 : 关闭  1  开启
	unsigned char			m_u8PresetId;  		// 预置点编号
	unsigned char			m_u8CruiseEn; 		// 开启巡航   0   关闭    1   开启
	unsigned char			m_u8TrackEn;  		// 启用轨迹关闭     1    开启
	unsigned char			m_u8TrackId;  		// 轨迹编号
	unsigned char			m_u8CruiseId;		// 巡航编号
	unsigned char			m_u8Reserved[2];
	
}PtzLinkAction;

typedef struct
{	// 移动侦测设疑与处理
	ALARMINDATESET		m_TimeTblSet[8];    /* 每天一个处理按星期计算*/
	unsigned char			m_MDMask[20*15];//设置移动区域
	unsigned char			resver;
	unsigned int			m_uMDSwitch;		// 移动侦测检查开关 -- 1:开启,0:关闭
	unsigned int			m_uMDSensitive;		// 移动侦测灵敏度/*4个等级:0-高，1-较高，2-中，3:低*/
	unsigned int  			m_uMDAlarm;			// 报警输出每一位代表一个输出
	unsigned int 			m_uOutputDelay;		//输出延时
	unsigned int			m_uAalarmOutMode;  	// 每一位代表处理方式 bit0   声音报警   bit1  抓拍   bit2  FTP上传bit3 发送邮件bit4 屏幕提示bit5录像 bit6录像
}MD_SETUP;
typedef struct
{
	MD_SETUP			m_Channel[CHANNEL];
	unsigned int		m_changeinfo;		// 更新指示: 位0-31对应32路通道
}CAMERA_MD;

typedef struct
{
	char				m_cVoltageDate[16];   	// 日期
	char				m_cVoltageTime[12];
 	// 时间
	unsigned char		m_uVoltageValues;   	//电压值
	char				m_Reserver[7];
	
}SystemVoltagesInfo;

typedef struct
{
	unsigned char 		m_uTempeatureValues; 	// 温度值
	char				m_uTempeatureDate[16];	// 日期
	char				m_uTempeatureTime[12];  // 时间
	char				m_Reserved[7];
	
}SystemTempeatures;


typedef struct
{
	SystemVoltagesInfo		High_VoltagesInfo;		// 高压信息
	SystemVoltagesInfo		Low_VoltagesInfo;		// 低压信息
	SystemTempeatures		HighTempeaturesInfo;	// 高温信息
	SystemTempeatures		Low_TempeaturesInfo;	// 低温信息
	unsigned long			TotalRecordTime;		// 录像的总时间
	unsigned short			HighSpeed;			    // 最高速度
	unsigned char			m_uFirstRec;
	char					m_Reserved[17];			//18
}SYSTEM_RUNINFO;

typedef struct
{
    char  				m_cCommName[16]; /*串口名称*/
    unsigned char    	m_u8Databit;     /*数据位*/
    unsigned char    	m_u8Stopbit;     /*停止位*/
    unsigned char    	m_u8Parity;      /*校验位*/
    unsigned char    	m_u8BaudRate;    /*波特率*/
    unsigned char		m_Reserved[4];
}PTZ_ComInfo_S;

typedef struct
{
    unsigned char   	 	m_s32Chn;        /*云台对应视频通道*/
    unsigned char    	m_u8Addr;        /*云台逻辑地址*/
    unsigned char  	 	m_u8Protocol;    /*云台协议0---pelco-d  1---pelco-p  */
    unsigned char	 	m_u8BautRate; 	 /* 波特率 0 ---1200  1--2400  2--4800  3---9600  4--19200 5--38400  6---57600  7--115200*/
    unsigned char	 	m_u8Speed;		 /*转动速度*/
    unsigned char    	m_u8Databit;     /*数据位默认为8 位*/
    unsigned char    	m_u8Stopbit;     /*停止位默认为1 位停止位*/
    unsigned char    	m_u8Parity;      /*校验位0 : 没有校验， 1 奇校验 2 偶校验*/
}PTZ_Info_S;

typedef struct
{
	PTZ_Info_S 		m_ptz_channel[CHANNEL];
	unsigned int		m_changeinfo;		// 更新指示: 位0-31对应32路通道
    
}PTZ_PARA;

typedef struct
{
	unsigned char		m_u8Alpha;			// 视频层的透明度 0，1，2
	unsigned char		m_u8VGAMode;		// VGA显示模式0 800x600    1:1024X768     2:1280*1024
	unsigned char		m_u8CruiseInterval;	// 监视轮询间隔
	unsigned char		m_u8AlarmCruiseInterval;  // 报警轮询 间隔
	unsigned char		m_u8CruiseMode;		// 轮询模式0 单通道  1 四通道  2 9 通道  3 16 通道
	unsigned char		m_pad0[3];			// 2->3
	unsigned int		m_u32SChValid; 		// 每位代表一组有效 0  无效   1    有效
	unsigned int		m_u32FourValid;		// 每位代表一组有效 0  无效   1    有效
	unsigned int		m_changeinfo;		// 更新指示: 0-无参数更新   1-有参数更新
}VIDEODISPLAYSET;

typedef struct
{
	char				m_pcSnapDir[96];
	char				m_pcRecDir[96];
	char				m_pcdLoadDir[96];
	unsigned char		m_u8Reserved[96];	// 保留
	unsigned int		m_changeinfo;		// 更新指示:位0-3对应
    
}PCDIR_PARA;

typedef struct
{
	unsigned char		pelcoP_enterMenu[CHANNEL][4];	// 菜单显示
	unsigned char		pelcoP_runpattern[CHANNEL][4];	// 花样扫描
	unsigned char		pelcoP_cruiseOn[CHANNEL][4];		// 自动巡航
	unsigned char		pelcoP_autoScan[CHANNEL][4];		// 自动扫描
	unsigned char		pelcoP_stopScan[CHANNEL][4];		// 自动扫描停止
	unsigned char		pelcoP_pRever1[CHANNEL][16];		// 保留4个命令
    
	unsigned char		pelcoP_default1[9][4];		// 默认值1
	unsigned char		pelcoP_default2[9][4];		// 默认值2
	unsigned char		pelcoP_default3[9][4];		// 用户自定义默认值3
    
	unsigned char		pelcoD_enterMenu[CHANNEL][4];	// 菜单显示
	unsigned char		pelcoD_runpattern[CHANNEL][4];	// 花样扫描
	unsigned char		pelcoD_cruiseOn[CHANNEL][4];		// 自动巡航
	unsigned char		pelcoD_autoScan[CHANNEL][4];		// 自动扫描
	unsigned char		pelcoD_stopScan[CHANNEL][4];		// 自动扫描停止
	unsigned char		pelcoD_pRever1[CHANNEL][16];		// 保留4个命令
    
	unsigned char		pelcoD_default1[9][4];		// 默认值1
	unsigned char		pelcoD_default2[9][4];		// 默认值2
	unsigned char		pelcoD_default3[9][4];		// 用户自定义默认值3
    
	unsigned int		m_changeinfo[16];			// 更新指示: 位0-11 and 16-27
    
}PELCO_CmdCfg;

typedef struct
{
	ANALOG_CHANNEL		m_picChn[3];  	  // 三组定时器对应的颜色值
	TIMETBLSECTION		m_picTmr[3];	  // 定时器
	ANALOG_CHANNEL		m_picChnDefault[3][3];  // 默认值
	TIMETBLSECTION		m_picTmrDefault[3][3];  // 默认值
    
	unsigned int		m_changeinfo;  	  // 更新指示: 位0-2对应3组颜色值，位3-5对应定时器，
    // 位6-8对应3组默认颜色, 位9-11对应三组定时器默认值
}PICTURE_TIMER;

typedef struct
{
	ANALOG_CHANNEL		m_SDPic; 		  // SD模拟量设置
	ANALOG_CHANNEL		m_HDPic;		  // HD模拟量设置
	unsigned int		m_changeinfo;	  // 更新指示: 位0-1对应SD,HD
}VODEV_ANALOG;


typedef struct
{
	char				m_cUserName[16];  // 用户名
	char				m_s32Passwd[16];  // 用户密码
	int					m_s32UserPermit;  // 0:超级权限 1:普通权限
	unsigned char		m_u8UserValid;	  // 暂未使用 此用户是否有效
	unsigned char		m_u8Reserved[3];
}SINGLEUSERSET;

typedef struct
{
	SINGLEUSERSET		m_UserSet[16];
	unsigned int		m_changeinfo;		// 更新指示: 位0-15对应16个用户
}USERGROUPSET;


typedef struct
{
	unsigned int		m_u16AlarmValid;	// 1:启用0:关闭
	unsigned int		m_u16AlarmMode;  	// 每一位代表处理方式 bit0   声音报警     bit1     屏显
}EXCEPTIONHANDLE;


typedef struct
{
	
	EXCEPTIONHANDLE     m_ExceptHandle[8]; 	// 0-7 异常处理  0 组: 无硬盘  1 : 硬盘出错 2 硬盘满
	unsigned int		m_changeinfo;		// 更新指示: 0-无更新，1-有参数更新
}GROUPEXCEPTHANDLE;

//系统维护
typedef struct
{
	unsigned char		m_u8Mode;			// 0-不进行维护 ，1-按周维护  2-按天数间隔维护
	unsigned char		m_u8WeekDayValid; 	// 天有效BIT0-BIT7 对应星期天-星期一
	unsigned char		m_u8DayInterval;  	// 天间隔
	unsigned char		m_u8WeekHour; 		// 小时
	unsigned char		m_u8WeekMinute;		// 分钟
	unsigned char		m_u8WeekSec;		// 秒
	unsigned char		m_u8DateModeHour; 	// 小时
	unsigned char		m_u8DateModeMinute;	// 分钟
	unsigned int		m_changeinfo;		// 更新指示: 0-无更新，1-有参数更新
}SYSTEMMAINETANCE;

typedef struct
{
    
	PtzLinkAction			m_Channel[CHANNEL];
    
}FangZonePtzLinkSet;

typedef struct
{
	FangZonePtzLinkSet  	m_Zone[MAX_ALARM_ZONE];
	unsigned int			m_changeinfo1;		// 0:没有更新1:有更新
}GroupZonePtzLinkSet;

typedef struct
{
	unsigned char 		m_u8StartHour;
	unsigned char		m_u8StartMin;
	unsigned char 		m_u8EndHour;
	unsigned char		m_u8EndMin;
	unsigned char		m_u8Valid;     	// 时间片段是否有效  0 无效  1 有效
	unsigned char		m_u8DefMode; 	// 1  为布防  0  为撤防
	unsigned char		m_u8Reserved[2];
	
}DefenceScheduleSliceSet;

typedef struct
{
	DefenceScheduleSliceSet		m_SingleSlice[4];
    
}DeScheduleGroup;

typedef struct
{
	unsigned short		    m_StartTim;
	unsigned short		    m_EndTim;
	unsigned char 		    m_u8StartH;
	unsigned char			m_u8StartM;
	unsigned char			m_u8StartS;
	unsigned char 		    m_u8EndH;
	unsigned char			m_u8EndM;
	unsigned char			m_u8EndS;
	unsigned char			m_u8Valid;
	unsigned char			m_u8DefMode;
	
}SchemeMega;

typedef struct
{
	char					m_uAccDomain[32];	// 注册服务器域名或IP
	char					m_deviceid[32];		// 平台注册ID
	unsigned short		    m_MsgPort;			// 消息端口
	unsigned char			m_IsSupportNAT;		// 是否支持 NAT 穿越
	unsigned char			m_PtzLockRet;		// 是否支持控制云台时返回云台锁定状态 1：支持，0：不支持
	char					m_devLinkType;		// 1是LAN，2为ADSL，3为其它类型
	char					m_DevMaxConnect;	// 指前端和网络带宽能够支持的最大视频路数
	char					m_reserved[10];		// 80 bytes
	
}NetWorkMegaEyes;

typedef struct
{
	char					m_videoId[32];		// 摄像头的业务 ID -< Camera
	char					m_channelId;		// ChannelId="1"
	char					m_hasPan;			// 是否有云台
	char					m_isIPCamera;		//
	char					m_IsLocalSaved;		// 是否本地存储
	char					m_lDiskFullOption;	// StopRecord/Overlay
	char					m_SchemeCycle;		// day/week/month
	char 					m_StoreCycle;		// 最大保存天数
	char					m_streamType;		// 被录像的码流类型
	char					m_ftpUsr[32];		// 访问存储使用的ftp帐号用户名
	char					m_ftpPwd[16];		// 访问存储使用的ftp帐号密码
	char					m_remoteIp[4];		// 中心存储服务器IP
	unsigned short			m_remotePort;		// 存储服务器侦听端口号
	SchemeMega				m_schemeItem[4];	// 计划表
	char					m_reserved[4];		// 96+4 +4= 148 bytes
	
}CamerMegaEyes;

typedef struct
{
	char					r_devId[32];		// 视频服务器业务ID -< Message
	char					r_Naming[64];		// 视频服务器全局标识Naming -< Message
	unsigned short			r_HeartCycle;		// 心跳周期秒
	unsigned short			r_SysRebootTime;	// 系统重起的时间
	unsigned short			r_SysRebootCycle; 	// 系统重起的周期天
	char					r_PlatformTel[14];	// 声讯网关号码
	char					r_ConfigServer[32];	// 配置服务器
	char					m_cpuUseRat;		// 网管告警阈值之 CPU使用率
	char					m_memUseRat;		// 网管告警阈值之 内存使用率
	char					m_diskSpaRat;		// 网管告警阈值之 硬盘利用率
	char					m_reserved1;		// 对齐
	int						m_diskSpaBalance;	// 网管告警阈值之 硬板剩余量(MB)
	char					r_reserved[76];		// 380-148 = 232 bytes
	CamerMegaEyes			r_magaCam;			// 互信互通目前项目只使用一路视频
    
}NetWorkMegaEcho;

typedef struct
{
	NetWorkMegaEyes			m_netWorkMegaEyes;	// 注册等网络配置使用
	NetWorkMegaEcho			m_netWorkMegaEcho;	// 注册返回信息
	
	unsigned int			m_changeinfo;		// 使用2位: 0-无参数更新 1-有参数更新 464 bytes
}MegaEyes_PARA;

typedef struct
{
	//1:启用0:不启用
	ALARMINDATESET		    m_TimeTblSet[8];    /* 每天一个处理按星期计算布撤防时间段*/
	unsigned char 		    m_u8ZoneEnable;  // 是否启用
	unsigned char			m_u8OSDEnable;   // 是否有屏幕显示
	unsigned char			m_u8RpCenter;    // 是否上报中心
	unsigned char			m_u8EmailEnable; //	是否发送e-mail
	unsigned int			m_u32UionChannel;  //云台关联0-31代表0-31通道
	unsigned int			m_u32RecEnable;	   // 报警使能通道录像， 每一位表示一个通道，每一位使能一个通道，为1的位使能录像
	unsigned int			m_u8ShotEnable;   // 报警使能通道抓拍， 每一位表示一个通道，每一位使能一个通道，为1的位使能录像
	unsigned int			m_OutPutPort;	//输出口每位代表一个输出口
	unsigned int			m_VoiceAlarm;//蜂鸣
	unsigned int			m_DetectTime;//多长时间检测一次此参数8个IO口要保持一致以最后保存的为准单位:秒
	unsigned int			m_OutputTime;//报警输出延时
	unsigned int			m_uFTP;//是否FTP上传
	unsigned int			m_Mode;//0:常闭1:常开
	
}AlarmZoneSet;

typedef struct
{
	AlarmZoneSet			m_AlarmZone[MAX_ALARM_ZONE];	//16个报警输入
	unsigned int			m_changeinfo1;		// 0:没有更新1:有更新
    
}ALARMZONEGROUPSET;

typedef struct
{
	DeScheduleGroup  		m_DefTime[8];
	unsigned int			m_changeinfo;		// 更新指示: 位0-7对应8个 DeScheduleGroup
}DefenceScheduleSet;

typedef struct
{
	unsigned char  			installerCode[7];
	unsigned char  			usrCode[5];
}PassWord_PARA;

typedef struct
{
	unsigned char 			remoteID[11];  // 遥控器ID码
	unsigned char 			remoteEnable;  // 0-禁止 1-使能
	
}RemoteCTL_PARA;

typedef struct
{
	unsigned char 			zoneID[10];		// 1-8为有线，无ID码
	unsigned char			zoneEnable;
	unsigned char 			BuzzAndType;	// 高三位代表鸣笛方式:  低五位代表防区属性:
    
}PanelZone_PARA;

typedef struct
{
	unsigned char  			entryDelay;  // 进入延时
	unsigned char  			exitDelay;	 // 退出延时
	unsigned char  			sirenTime;	 // 警号时间
	unsigned char  			ringCycle;   // 振铃次数
	unsigned char  			commTestTime; // 通讯检测时间
	unsigned char  			lossDetectTime;	// 丢失检测 0-表示不检测
	unsigned char  			armDis_tone;  // 布撤防提示音
	unsigned char  			armDis_report; // 布撤防报告
	
}SysOption_PARA;

typedef struct
{
	unsigned char  			cmsPhone[4][16]; // 中心电话号码
}CmsPhone_PARA;

typedef struct
{
	unsigned char  			voicePhone[4][16]; // 用户电话号码
	
}UserPhone_PARA;

typedef struct
{
	unsigned char			g3modenable;	// 3G 模块使能 0--不使能
	unsigned char			g3conmethd;  	// 连接控制方式 1:一直在线  0:手动控制连接状态
	char  					simcard[16];  	// 本机号码
	char					ctlpwd[16]; 	// 短信控制密码
	unsigned char			g3card;			// 无线modem型号选择
	char  					phonenum[16];  	// 短信/彩信报警号码
	unsigned char			g3TypeSelCtl;	// 无线modem型号选择方式 0:自动选择 1:手动选择
	char					m_reserved[4];	// 保留
	
	unsigned int			m_changeinfo;	// 更新指示: 位0-6
}G3G_CONFIG;

typedef struct
{
	unsigned char			g3mandialEnable; // 3G 手动配置拨号使能 0--不使能
	char					g3UserName[17];	 // 3G 拨号用户名
	char					g3Passwrd[17];	 // 3G 拨号密码
	char					g3CountryCode[17];// 3G 国家代码
	char					m_reserved[16];	 // 保留
    
	unsigned int			m_changeinfo;	 // 更新指示: 位0-3
}G3G_DIAL_CONFIG;

typedef struct
{
	unsigned char 			m_u8StartHour;
	unsigned char			m_u8StartMin;
	unsigned char 			m_u8EndHour;
	unsigned char			m_u8EndMin;
	unsigned char			m_u8Valid;     	// 时间片段是否有效  0 无效  1 有效
	unsigned char			m_reserved[3];	// 保留
	
}Switch_Timer ;

typedef struct
{
	Switch_Timer			m_switchTimer[4];// 定时时间
	
}Switch_Week;

typedef struct
{
	unsigned char			m_switchID[10];	 // 电器开关ID--3字节
	char 			    	m_switchName[17];// 电器开关自定义名称
	unsigned char			m_timerVal;		 // 定时总开关	开启: 1   关闭0
	unsigned char			m_switchMode;	 // 工作模式	循环: 1   正常0
	unsigned char			m_switchWork;	 // 开关选择	开启: 1   关闭0
	unsigned char			m_switchType;	 // 电器类型0:Light 1:Power  2:Motor  3:Electrovalve 4:Elderly Care 5:Meteo Station 6:Thermostat 7:Water Meter 8:Electricity Meter
	unsigned char			m_sceneVal;		 // 场景属性bit0  场景1  ；bit1  场景2；bit2  场景3；bit3  场景4
	Switch_Week				m_switchWeek[7];
	unsigned short			m_keepTime;		 // 持续时间 -- 保存以秒为单位
	unsigned short			m_cycTime;		 // 循环时间 -- 保存以秒为单位
	unsigned char			m_nNoAck;		 // 回应失败位，0 有回应 1 没有回应
	unsigned char			m_reserved[3];	 // 保留
	
}Switch_PARA ;

typedef struct
{
	char					m_deviceAliases[32];		//设备别名
	char					m_remoteDomain[32];	// 远端视频服务器域名或IP
	char					m_userName[16];
	char					m_passwd[16];
	unsigned int 			m_remotePort;		// 远端视频服务器端口号
	unsigned char 		    m_remoteCh;			// 远端视频服务器通道
	unsigned char 		    m_bindCh;			// 绑定到解码器通道
	unsigned char			isEnable;			// 1:转发0:停止转发
	unsigned char			m_isConnectToAlarmServer;	// 1:连接0:不连接
	unsigned char			m_forwardIsSuccess;		// 1:成功0:失败
	unsigned char			m_devChl;				//远端设备通道数
	char					m_reserv[14];		// 保留
	
}DecoderBind_PARA;

typedef struct
{
	DecoderBind_PARA		m_decBind[CHANNEL];		// 目前支持4路视频解码
    
	unsigned int			m_changeinfo;		// 更新指示: 位0-3 共180字节
    
}NETDECODER_PARA;

typedef struct
{
	int	m_colorMode;			// 1:彩色模式2:黑白模式
	int	m_picMode;				// 1:普通2:镜像+翻转
	int	m_picFlip;
	int	m_picMirrorn;
	int	m_PowerFreq;			// 1:50HZ 2:60HZ
    
}CAMERASENSOR_PARA;

typedef struct
{
	NETWORK_PARA			m_NetWork;			//网络设置
	MACHINE_PARA			m_Machine;			//机器设置
	CAMERA_PARA			    m_Camera;			//编码设置
	CAMERA_ANALOG			m_Analog;			//模拟量设置
	CAMERASENSOR_PARA		m_Sensor;			//sensor工作状态
	COMMON_PARA			    m_CommPara;			//基本设置
	CAMERA_BLIND			m_CamerBlind;		//视频遮挡检测
	AlarmOutPort			m_AlarmPort;		//报警输出口配置
	CAMERA_VideoLoss		m_CamerVideoLoss;	//视频丢失
	CAMERA_MD				m_CameraMd;			//移动侦测
	PTZ_PARA				m_PTZ;				//云台设置
	USERGROUPSET			m_Users;			//用户管理
	SYSTEMMAINETANCE		m_SysMainetance;	//系统维护
	VIDEODISPLAYSET			m_DisplaySet;		//视频输出
	GROUPEXCEPTHANDLE		m_SysExcept;		//异常处理
	PCDIR_PARA				m_PcDir;			//PC端储存配置
	PELCO_CmdCfg			m_pelcoCfg;			//摄像头控制(暂时未使用)
	PICTURE_TIMER			m_picTimer;			//图像颜色设置
	VODEV_ANALOG			m_picVo;			//输出
	G3G_DIAL_CONFIG		    m_3gDial;			//3G拨号
	NETDECODER_PARA		    m_Netdecoder;		//解码器设置
	VIDEOOSDINSERT			m_OsdInsert;		//视频遮挡
	GROUPRECORDTASK		    m_RecordSchedule; 	//录像任务
	ALARMZONEGROUPSET		m_ZoneGroup;		//报警输入设置及处理
	DefenceScheduleSet		m_DefSchedule;		//未用
	GroupZonePtzLinkSet		m_PtzLink;			//报警输入联动设置(预置点\花样扫描等)
	G3G_CONFIG				m_3g;				//3G配置
	
}SYSTEM_PARAMETER; 

#endif 



