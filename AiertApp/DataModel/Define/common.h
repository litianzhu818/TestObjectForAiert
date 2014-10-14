#ifndef __COMMON_H__
#define __COMMON_H__

#define	TCPLISTENPORT			8000	//tcp监听端口
#define	UDPLISTENPORT			8080	//udp监听端口

//相关命令标识：
#define CMD_S_MAC				0x9c00	//烧写设备MAC地址
#define CMD_PING				0x9001	//PING包，返回IPC版本信息及本地IP参数
#define CMD_START_VIDEO			0x9002	//请求视频
#define CMD_START_SUBVIDEO		0x90a2	//请求子码流
#define CMD_START_VGA			0x9002	//请求视频
#define CMD_START_QVGA			0x90a2	//请求子码流
#define CMD_START_720P			0x5000	//请求视频

#define CMD_STOP_VIDEO			0x9003	//关闭视频
#define CMD_AUDIO_ON			0x9004  //设备声音开启
#define CMD_AUDIO_OFF			0x9005  //设备声音关闭
#define CMD_TALK_ON				0x9006  //对讲开启
#define CMD_TALK_OFF			0x9007  //对讲关闭
#define CMD_TALK_DATA			0x9008	//对讲数据
#define CMD_DECIVE_TYPE			0x9009	//设备型号
#define CMD_ALARM_UPDATE		0x9010	//报警上传
#define CMD_SEND_SPEED			0x9020	//控制视频回放传输速度

#define CMD_S_DEV_PARA			0xa100	// 设置参数
#define CMD_S_PTZ				0xa300	// 云台命令
#define CMD_S_REBOOT			0xa400	// 重启命令，数据部分
#define CMD_S_REBOOT_OK			0xa4ff	// 重启完成命令
#define CMD_S_UPDATE			0xa500	// 升级命令
#define CMD_S_UPDATEMCU		    0xa501	//升级报警主机
#define CMD_S_UPDATE_OK			0xa5ff	// 升级完成命令
#define CMD_S_NTP				0xa600	// 与client对时
#define CMD_S_RESTORE			0xa700	// 恢复出厂设置
#define CMD_S_PANEL_RESTORE		0xa755	// 恢复报警主机出厂设置
#define CMD_S_PANEL_STAT		0xa800	// 报警主机布撤防
#define CMD_S_AUTOSWCTL			0xa900  // 电器开关控制
#define CMD_S_3GCTL				0xaa00	// 控制3G连接或断线
#define CMD_S_CHN_ANA			0xa10f	// 恢复单通道默认颜色
#define CMD_S_CHN_ANALOG		0xa110	//设置单通道模拟量

#define CMD_G_CHN_ANALOG		0xa111	//获取单通道模拟量
#define CMD_G_WIFI_AP			0xa112	//获取WIFI热点
#define CMD_S_WIFI_CONNECT		0xa113	//连接WIFI热点
#define CMD_G_WIFI_STATUS		0xa114	//获取连接状态
#define CMD_S_PIC_NORMAL		0xa115	//正常
#define CMD_S_PIC_FLIP			0xa116	//翻转ON
#define CMD_S_PIC_MIRRORON	    0xa117  //镜像
#define CMD_S_PIC_FLIPMIRROR	0xa118	//镜像翻转
#define CMD_S_PIC_COLORON		0xa119	//彩色
#define CMD_S_PIC_COLOROFF		0xa120	//黑白
#define CMD_S_SENSORFREQ_50	    0xa121	//snsor工作电压50HZ
#define CMD_S_SENSORFREQ_60	    0xa122	//snsor工作电压60HZ
#define CMD_G_CHN_PRESET		0xa123	//获取单通道预置位

#define CMD_R_DEV_PARA			0x9100	// 读参数
#define CMD_R_ALARMINFO			0x9600	// 查询报警信息
#define CMD_R_LOG				0x9700	// 查询日志
#define CMD_R_DEV_INFO			0x9800	// 读状态信息
#define CMD_R_PANEL_INFO		0x9810	// 读报警主机状态信息
#define CMD_R_SEARCH_PLAYLIST	0x9900  // 检索回放列表
#define CMD_PLAYBACK_PLAY		0x9903	// 回放开始命令
#define CMD_PLAYBACK_STOP		0x9905	// 回放停止命令
#define CMD_REQ_LOGIN			0x9a00	// 登陆请求命令
#define CMD_R_3G_INFO			0x9b00	// 读3G连接状态和型号

////////////////////////////////////////////////////////////
#define CMD_G_HISTORY_SNAPSHOOT   0x1001
#define CMD_G_HISTORY_SENSOR_DATA 0x1002
#define CMD_G_DEVICES             0x1003
#define CMD_R_ERROR               0x1004
#define CMD_G_SNAPSHOP			  0x9040
////////////////////////////////////////////////////////////
#define CMD_ID_PING	              0x9050
#define CMD_SET_AUDIOSWITCH       0x9066
#endif