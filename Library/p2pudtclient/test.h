#pragma once

#ifdef _WIN32
	#define WIN32_LEAN_AND_MEAN
	#include <windows.h>
	#include <winsock2.h>
	#include <ws2tcpip.h>
	#pragma comment(lib, "ws2_32.lib")
#else
	#include <unistd.h>
	#include <pthread.h>
	#include <cstring>
	#include <sys/socket.h>
	#include <sys/time.h>
	#include <arpa/inet.h>
	#include <sys/types.h>
	#include <fcntl.h>
	#include <errno.h>
	#include <netdb.h>
#endif

#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <list>
#include <map>
using namespace std;

// Test Switch
#define FOR_TEST_SERVER			0			// 测试服务器
#define FOR_DEV_SERVER			0			// 开发服务器
#define FOR_USA_SERVER			1			// 美国服务器

#define TEST_PLAYBACK			0			// 测试回放
#define TEST_REALPLAY			0			// 测试实时视频

#define TEST_MULTI_THREAD		0			// 测试多线程问题

#define TEST_ENABLE_SOUND		0			// 测试音频开关
#define TEST_ENABLE_TALK		1			// 测试对讲开关
#define TEST_SEND_TALK_DATA		0			// 测试发送对讲数据
#define TEST_CHANAGE_STREAM		0			// 测试通道和码流切换
#define TEST_UPDATE_DNS			1			// 测试更新DNS

#define TEST_RECORD_FRAME_DATA	0			// 测试Frame数据

#define TEST_UPNP_QUERY			1			// 测试UPNP设备信息查询
#define TEST_UPNP_CHANGE_PWD	0			// 测试UPNP，用户修改密码
#define TEST_UPNP_LOGIN			0			// 测试UPNP，用户登陆


#define P2P_STATUS_A(a) #a
enum P2P_status
{
	p2p_status_start,

	p2p_upnp_query_succ,
	p2p_upnp_query_failed,

	p2p_status_cb_start,
	p2p_status_cb_end,

	p2p_status_connect_succ,
	p2p_status_connect_failed,

	p2p_status_first_data,
	
	p2p_status_login_start,

	p2p_status_login_succ,
	p2p_status_login_failed,
	p2p_status_login_timeout,

	p2p_status_stop_begin,
	p2p_status_stop_end,

	p2p_status_end,
};

enum deliver_status
{
	deliver_status_start,

	deliver_upnp_query_succ,
	deliver_upnp_query_failed,

	deliver_status_cb_start,
	deliver_status_cb_end,

	deliver_status_connect_succ,
	deliver_status_connect_failed,
	deliver_status_connect_tcp_close,

	deliver_status_registering,

	deliver_status_first_data,

	deliver_status_login_start,

	deliver_status_login_succ,
	deliver_status_login_failed,
	deliver_status_login_timeout,

	deliver_status_stop_begin,
	deliver_status_stop_end,

	deliver_status_end,
};


struct DeviceName {	char _name[11]; };

// common
void _Sleep(int nMilliseconds);
std::string GetCurTime();
void reset_start_time();
double GetWorkTime();


// P2PClient callback
void ZSIP_MSG(int iType, int iStatus, char* data, int data_len);
void OnStatusReport(int iType, int iStatus, const char* pText);
void OnFrameData(int iType, char* pData, int iSize);


// set/get global status
enum t_error_e
{
	no_error = 0,
	same_error,
};
void set_same_error(t_error_e err = same_error);
bool is_same_error();

enum t_login_status_e
{
	login_status_ready = -1,
	login_status_super_succ,
	login_status_normal_succ,
	login_status_falied,
};
void set_login_status(t_login_status_e staus = login_status_ready);
void reset_login_status();
bool is_login_success();
bool is_login_failed();

void set_recv_first_data(bool bFlag = false);
bool is_recv_first_data();

void set_wait_first_data_error(t_error_e err = same_error);
bool is_wait_first_data_error();

enum t_talk_status_e
{
	talk_status_succ,
	talk_status_failed,
};
void set_talk_status(t_talk_status_e status);
t_talk_status_e get_talk_status();

enum t_upnp_query_status_e
{
	upnp_query_status_unkown,
	upnp_query_status_succ,
	upnp_query_status_failed,
};
void set_upnp_query_status(t_upnp_query_status_e status);
t_upnp_query_status_e get_upnp_query_status();

enum t_change_stream_status_e
{
	change_stream_status_ready,
	change_stream_status_succ,
	change_stream_status_failed,
};

void set_change_stream_status(t_change_stream_status_e status);
void set_change_stream_status_ready();
t_change_stream_status_e get_change_stream_status();

int get_device_list_max();

void set_p2p_mode(bool bFlag = true);
void switch_p2p_deliver_mode();
bool is_p2p_mode();

void set_never_stop(bool bFlag = true);
bool is_never_stop();

void set_connect_status(int status);
int get_connect_status();

bool create_test_log();
void write_to_log(char * log);
void close_test_log();

extern DeviceName deviceList[];
extern int g_device_index;

bool wait_first_data();
bool wait_p2p_connect_status();
bool wait_deliver_connect_status();
bool wait_login_ret(int msTimeout);
bool wait_upnp_query_response();
bool wait_talk_status();
bool wait_change_stream();


#ifdef _WIN32
typedef DWORD (WINAPI * thread_proc_ptr)(LPVOID param);
#else
typedef void* (* thread_proc_ptr)(void* param);
#endif
bool create_multi_thread(thread_proc_ptr pfun, void * param);

// test unit

bool InitZSipLib();

void test_change_stream(std::string strDeviceId, bool bP2P);

void test_mulit_stream();

bool test_update_dns();

void test_talk(std::string strDeviceId, bool bP2P = true);