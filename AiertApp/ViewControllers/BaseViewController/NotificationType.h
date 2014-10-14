//
//  NotificationType.h
//  工具类
//
//  Created by 李天柱 on 14-4-22.
//  Copyright (c) 2014年 Peter Lee. All rights reserved.
//
//  消息通知全部类型
//

/*
 涉及的消息类型
 NEW_MESSAGE                    //新信息
 SEND_MESSAGE                   //发送信息
 FIREND_ONLINE                  //好友下线
 FIREND_OFFLINE                 //好友上线
 RECEIVE_ADD_FIREND_REQUEST     //收到被添加好友的请求
 
 DISCONNECT_NET                 //断开网络连接
 CONNECT_NET                    //重新获得网络连接
 */


#ifndef XMPPTestDemo_NotificationType_h
#define XMPPTestDemo_NotificationType_h

#define NEW_MESSAGE             @"NewMessage"                                   //通知各个显示界面
#define DATABASE_MESSAGE        @"DatabaseMessage"                              //先向数据库处理类发送消息到达通知，数据库存储后在通知界面
#define SEND_MESSAGE            @"SendMessage"
#define SIGNALING_MESSAGE       @"SignalingMessage"
#define REQUEST_MESSAGE         @"RequestMessage"
#define CONTROL_MESSAGE         @"ControlMessage"
#define FIREND_ONLINE           @"Firend_Online"
#define FIREND_OFFLINE          @"Firend_Offline"
#define RECEIVE_ADD_FIREND_REQUEST @"Receive_Add_Firend_Request"

#define DISCONNECT_NET          @"Disconnect_Network"
#define CONNECT_NET             @"Connect_Network"
#define NO_NETWORK              @"NO_Network"

#define CONNECT_FAILED          @"connect_failed"
#define LOGIN_SUCCEED           @"login_succeed"
#define LOGIN_FAILED            @"login_failed"

#define REGISTER_SUCCEED        @"register_succeed"
#define REGISTER_FAILED         @"register_failed"

#endif
