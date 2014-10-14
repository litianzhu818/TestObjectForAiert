#include "P2PClient_IOS.h"
#include "test.h"

#include <json/json.h>

bool InitZSipLib()
{
	Json::Value root;
	Json::FastWriter writer;

	root["TokenId"] = "S7wqMTq5tD1654500";
	root["UsrId"] = "1654500";

	root["ClientIP"] = "0.0.0.0";
	root["ClientPort"] = "0";
#if FOR_TEST_SERVER
	//root["StunIP"] = "106.120.243.22";
	//root["StunPort"] = "8089";
	//root["ServerIP"] = "106.120.243.22";
	//root["ServerPort"] = "8089";

	root["StunIP"] = "172.18.32.19";
	root["StunPort"] = "8088";
	root["ServerIP"] = "172.18.32.19";
	root["ServerPort"] = "8088";
#endif

#if FOR_DEV_SERVER
	root["StunIP"] = "172.18.35.6";
	root["StunPort"] = "8088";
	root["ServerIP"] = "172.18.35.6";
	root["ServerPort"] = "8088";
#endif

#if FOR_USA_SERVER
	//root["StunIP"] = "register.zmodo.com";  //"192.241.57.101";
	//root["StunPort"] = "8088";
	//root["ServerIP"] =  "register.zmodo.com";  //"192.241.57.101";
	//root["ServerPort"] = "8088";

	root["StunIP"] = "192.241.57.101";  //"192.241.57.101";
	root["StunPort"] = "8088";
	root["ServerIP"] =  "192.241.57.101";  //"192.241.57.101";
	root["ServerPort"] = "8088";
#endif
	root["UsrType"] = "3";					// 0-�ͻ��ˣ�3-upnp�ͻ���
	root["ClientType"] = "0";				// 0-android��1-ios

	// ��ʱ����
	root["SipKeepAlive"] = "4000000";		// SIP����������ʱ���� Ĭ��4s
	root["SipReqTimeout"] = "5000000";		// SIP����ʱʱ�䣬Ĭ��5s

	root["P2PReqTimeout"] = "8000000";		// P2P����ʱʱ�� Ĭ��8s
	root["RegisterTimeout"] = "2000000";	// ��תע�ᳬʱʱ�� Ĭ��2s
	root["LoginTimeout"] = "4000000";		// ��½��ʱʱ�� Ĭ��2s

	root["StreamKeepAlive"] = "2000000";		// ֱ��������� Ĭ��2s
	root["StreamTimeout"] = "5000000";		// �������ݳ�ʱ Ĭ��5s

	std::string slParams = writer.write(root);

	return CP2PClient::InitZSip(slParams, ZSIP_MSG);
}

void ZSIP_MSG(int iType, int iStatus, char* data, int data_len)
{
	switch (iStatus)
	{
	case sipsMessage:
		printf("SIP������������Ϣ: \n %s \n", data);	// pText ����Ϊjson�ַ��� ��Ҫ�ϲ����
		break;
	case sipsSessionTimeout:
		printf("sip������֪ͨSession��ʱ, �����µ�½\n");
		break;
	case sipsUpdateDNS:
		printf("�����������ã�UpdateDNS!\n");
		break;
	}
}

void OnStatusReport(int iType, int iStatus, const char* pText, void * pCookie)
{
	printf("OnStatusReport : %d   %d\t", iType, iStatus);
	switch (iType)
	{
	case stSIP:
		switch (iStatus)
		{

		}
		break;
	case stStream:
		{
			switch (iStatus)
			{
			case ssUPNPConnectSucc:
				{
					printf("UPNP���ӳɹ�\n");
					set_connect_status(upnp_status_connect_succ);
					char g_test[1024] = {0};
					sprintf(g_test, "[%s] (%0.0f) {%s} : %s \n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(upnp_status_connect_succ));
					write_to_log(g_test);
				}
				break;
			case ssUPNPConnectFailed:
				{
					printf("UPNP����ʧ�� %s\n", pText);
					set_connect_status(upnp_status_connect_failed);
					set_wait_first_data_error();
					char g_test[1024] = {0};
					sprintf(g_test, "[%s] (%0.0f) {%s} : %s %s\n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(upnp_status_connect_failed), pText);
					write_to_log(g_test);
				}
				break;
			case ssUPNPRecvFailed:
				{
					printf("UPNP���մ��� %s\n", pText);
					set_same_error();
					set_connect_status(upnp_status_connect_failed);
					set_wait_first_data_error();
					char g_test[1024] = {0};
					sprintf(g_test, "[%s] (%0.0f) {%s} : %s %s\n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(upnp_status_connect_failed), pText);
					write_to_log(g_test);
				}				
				break;

			case ssP2PConnectSucc:
				{
					printf("P2P���ӳɹ�\n");
					set_connect_status(p2p_status_connect_succ);
					char g_test[1024] = {0};
					sprintf(g_test, "[%s] (%0.0f) {%s} : %s \n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(p2p_status_connect_succ));
					write_to_log(g_test);
				}
				break;
			case ssP2PConnectFailed:
				{
					printf("P2P����ʧ�� %s\n", pText);
					set_connect_status(p2p_status_connect_failed);
					set_wait_first_data_error();
					char g_test[1024] = {0};
					sprintf(g_test, "[%s] (%0.0f) {%s} : %s %s\n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(p2p_status_connect_failed), pText);
					write_to_log(g_test);
				}
				break;
			case ssP2PRecvFailed:
				{
					printf("P2P���մ��� %s\n", pText);
					set_same_error();
					set_connect_status(p2p_status_connect_failed);
					set_wait_first_data_error();
					char g_test[1024] = {0};
					sprintf(g_test, "[%s] (%0.0f) {%s} : %s %s\n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(p2p_status_connect_failed), pText);
					write_to_log(g_test);
				}				
				break;

			case ssDeliverConnectSucc:
				{
					printf("��ת���ӳɹ�\n");
					set_connect_status(transit_status_connect_succ);
					char g_test[1024] = {0};
					sprintf(g_test, "[%s] (%0.0f) {%s} : %s %s\n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(transit_status_connect_succ), pText);
					write_to_log(g_test);
				}
				break;
			case ssDeliverConnectFailed:
				{
					printf("��ת����ʧ�� %s\n", pText);
					set_connect_status(transit_status_connect_failed);
					set_wait_first_data_error();
					char g_test[1024] = {0};
					sprintf(g_test, "[%s] (%0.0f) {%s} : %s %s\n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(transit_status_connect_failed), pText);
					write_to_log(g_test);
				}
				break;
			case ssDeliverRecvFailed:
				{
					printf("��ת���մ��� %s\n", pText);
					set_connect_status(transit_status_connect_failed);
					set_wait_first_data_error();
					char g_test[1024] = {0};

					if (strcmp("login timeout", pText) == 0)
						set_login_status(login_status_falied);
					sprintf(g_test, "[%s] (%0.0f) {%s} : %s %s\n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(transit_status_connect_failed), pText);
					write_to_log(g_test);
				}
				break;

			case ssPlayBackReqSucc:
				printf("�ط�����ɹ�\n");
				break;
			case ssPlayBackReqFailed:
				printf("�ط�����ʧ��\n");
				break;
			case ssPlayBackStop:
				printf("��ǰ�طŽ���\n");
				break;

			case ssChangeToQVGA:
				printf("��Ҫ�л�����ΪQVGA\n");
				break;
			case ssChangeToVGA:
				printf("��Ҫ�л�����ΪVGA\n");
				break;
			case ssOpenSoundSucc:
				printf("����Ƶ�ɹ�\n");
				break;
			case ssOpenSoundFailed :
				printf("����Ƶʧ��\n");
				break;
			case ssCloseSoundSucc:
				printf("�ر���Ƶ�ɹ�\n");
				break;
			case ssCloseSoundFailed:
				printf("�ر���Ƶʧ��\n");
				break;

			case ssOpenTalkSucc:
				printf("�򿪶Խ��ɹ�\n");
				set_talk_status(talk_status_succ);
				break;
			case ssOpenTalkFailed:
				printf("�򿪶Խ�ʧ��\n");
				set_talk_status(talk_status_failed);
				break;
			case ssCloseTalkSucc:
				printf("�رնԽ��ɹ�\n");
				set_talk_status(talk_status_succ);
				break;
			case ssCloseTalkFailed:
				printf("�رնԽ�ʧ��\n");
				set_talk_status(talk_status_failed);
				break;

			case ssChangeStreamSucc:
				printf("���������ɹ�\n");
				set_change_stream_status(change_stream_status_succ);
				break;
			case ssChangeStreamFailed:
				printf("��������ʧ��\n");
				set_change_stream_status(change_stream_status_failed);
				break;

			case ssPTZCfgSucc:
				printf("PTZ���óɹ�\n");
				break;
			case ssPTZCfgFailed:
				printf("PTZ����ʧ��\n");
				break;
			case ssPTZGetPresetSucc:
				printf("PTZԤ�õ��ȡ�ɹ�\n");
				break;
			case ssPTZGetPresetFailed:
				printf("PTZԤ�õ��ȡʧ��\n");
				break;

			case ssUnknownError:
			default:
				printf("δ֪����\n");
				break;
			}
		}
		break;
	case stNatType :
		{
			printf("������Ϣ����֪�ϲ������\n");
		}
		break;
	case stUpnp:
		{
			switch (iStatus)
			{
			case upnpLoginSuper_0:
				{
					set_login_status(login_status_super_succ);
					printf("login super ok \n");

					char g_test[1024] = {0};
					if (is_p2p_mode())
						sprintf(g_test, "[%s] (%0.0f) {%s} : Super %s %s\n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(p2p_status_login_succ), pText);
					else if (is_transit_mode())
						sprintf(g_test, "[%s] (%0.0f) {%s} : Super %s %s\n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(transit_status_login_succ), pText);
					write_to_log(g_test);
				}
				break;
			case upnpLoginNormal_0:
				{
					set_login_status(login_status_normal_succ);
					printf("login normal ok \n");

					char g_test[1024] = {0};
					if (is_p2p_mode())
						sprintf(g_test, "[%s] (%0.0f) {%s} : Normal %s %s\n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(p2p_status_login_succ), pText);
					else if (is_transit_mode())
						sprintf(g_test, "[%s] (%0.0f) {%s} : Normal %s %s\n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(transit_status_login_succ), pText);
					write_to_log(g_test);
				}
				break;
			case upnpLoginfalied:
				{
					set_login_status(login_status_falied);
					printf("login failed \n");

					char g_test[1024] = {0};
					if (is_p2p_mode())
						sprintf(g_test, "[%s] (%0.0f) {%s} : %s %s\n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(p2p_status_login_failed), pText);
					else if (is_transit_mode())
						sprintf(g_test, "[%s] (%0.0f) {%s} : %s %s\n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(transit_status_login_failed), pText);
					write_to_log(g_test);
				}
				break;
			case upnpChangePwdSucc:
				{
					printf("change pwd succ \n");

					set_change_pwd_status(change_pwd_status_succ);
					char g_test[1024] = {0};
					if (is_p2p_mode())
						sprintf(g_test, "[%s] (%0.0f) {%s} : %s %s\n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(p2p_status_change_pwd_succ), pText);
					else if (is_transit_mode())
						sprintf(g_test, "[%s] (%0.0f) {%s} : %s %s\n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(transit_status_login_succ), pText);
					write_to_log(g_test);
				}
				break;
			case upnpChangePwdFailed:
				{
					printf("change pwd failed \n");

					set_change_pwd_status(change_pwd_status_failed);
					char g_test[1024] = {0};
					if (is_p2p_mode())
						sprintf(g_test, "[%s] (%0.0f) {%s} : %s %s\n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(p2p_status_change_pwd_failed), pText);
					else if (is_transit_mode())
						sprintf(g_test, "[%s] (%0.0f) {%s} : %s %s\n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(transit_status_login_failed), pText);
					write_to_log(g_test);
				}
				break;
			case upnpQueryUpnpSucc:
				{
					if (pText == NULL)
					{
						printf("response null ");
					}
					printf("UPNP ��ѯ�ɹ� %s \n", pText);

					char g_test[1024] = {0};
					if (is_p2p_mode())
						sprintf(g_test, "[%s] (%0.0f) {%s} : %s \n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(p2p_upnp_query_succ));
					else if (is_transit_mode())
						sprintf(g_test, "[%s] (%0.0f) {%s} : %s \n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(transit_upnp_query_succ));
					write_to_log(g_test);

					set_upnp_query_status(upnp_query_status_succ);
				}
				break;
			case upnpQueryUpnpFailed:
				{
					if (pText == NULL)
					{
						printf("response null ");
					}
					printf("UPNP ��ѯʧ�� \n");
					char g_test[1024] = {0};
					if (is_p2p_mode())
						sprintf(g_test, "[%s] (%0.0f) {%s} : %s \n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(p2p_upnp_query_failed));
					else if (is_transit_mode())
						sprintf(g_test, "[%s] (%0.0f) {%s} : %s \n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(transit_upnp_query_failed));
					write_to_log(g_test);

					set_upnp_query_status(upnp_query_status_failed);
				}
				break;
			}
		}
		break;
	}
}

void OnFrameData(int iType, char* pData, int iSize, void * pCookie)
{
	// ���ش��� �õ����� ����->����
	if (!is_recv_first_data())
	{
		set_recv_first_data(true);
		char g_test[1024] = {0};
		if (is_p2p_mode())
			sprintf(g_test, "[%s] (%0.0f) {%s} : %s \n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(p2p_status_first_data));
		else if (is_transit_mode())
			sprintf(g_test, "[%s] (%0.0f) {%s} : %s \n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(transit_status_first_data));
		else if (is_upnp_mode())
			sprintf(g_test, "[%s] (%0.0f) {%s} : %s \n", GetCurTime(), GetWorkTime(), deviceList[g_device_index]._name, CONN_STATUS_STR(upnp_status_first_data));

		write_to_log(g_test);
	}
	printf("*");

#if TEST_RECORD_FRAME_DATA
	//write_data_to_file(pData, iSize);
#endif
}

int main(int argc, char* argv[])
{
	////
	set_never_stop(true);
	set_connect_mode(P2P_MODE);

	if (!InitZSipLib())
	{
		printf("init zsip lib failed\n");
	}

	//getchar();
	
	if (!create_test_log())
	{
		printf("create test log failed\n");
	}

	//getchar();

	//test_p2p_transit_all();
	//return 0;
	//create_data_file();
	test_connect_device("1308001424", CHANNEL_0, 0, P2P_MODE);

	//test_connect_device("1308000803", CHANNEL_0, 0, UPNP_MODE);

	//create_data_file();
	//test_connect_device("1308001028", CHANNEL_0, 0, UPNP_MODE);
	return 0;

#if 0
	test_dvr_talk("1308000312", CHANNEL_0, 0, TRANSIT_MODE);
	return 0;
#endif

//
//#if 1
//	test_ptz("1207001011", TRANSIT_MODE);
//	return 0;
//#endif

#if TEST_PLAYBACK
	std::string strDateTime = "2014-03-03 03:27:43";
	test_play_back("1308001259", CHANNEL_1, P2P_MODE, strDateTime);
	return 0;
#endif

//#if TEST_UPDATE_DNS
//	test_update_dns();
//	return 0;
//#endif
//
#if TEST_SEND_TALK_DATA
	test_talk("1308001060", UPNP_MODE);
	return 0;
#endif 

//#if TEST_CHANAGE_STREAM
//	test_change_stream("1308000906", P2P_MODE);
//	return 0;
//#endif

//#if  TEST_UPNP_CHANGE_PWD
//	test_change_pwd("1308000906", P2P_MODE);
//	return 0;
//#endif

	//test_connect_device("9999999970", CHANNEL_3, 0, P2P_MODE);
	//test_connect_device("1308000916", CHANNEL_0, 0, P2P_MODE);

	test_p2p_transit_all();

	close_test_log();
	CP2PClient::ReleaseZSip();

	printf("\n\n\nPress any key to quit... \n");
	getchar();
	return 0;
}
