#include "zsip.h"

#define THIS_FILE   "zsip.cpp"


/***additional information about encrypt sip and stun msg*******************
*1.sip send: pjisp_msg_print in sip_msg.c
*2.sip recv:pjsip_tpmgr_receive_packet in sip_transport.c
*3.stun send:pj_stun_msg_encode in stun_msg.c
*4.stun recv:on_data_recvfrom in stun_sock.c
*5.stun timeout:tsx_transmit_msg in stun_transaction.c
*6.pj_gethostip  slow:replace line 789 : status = pj_getaddrinfo(af, pj_gethostname(),
   &count, &ai); by : status = PJ_ERESOLVE;
***************************************************************************/

typedef struct zsip_endpoint
{
    pjsip_endpoint *endpt;
    pj_pool_t *pool; //pool for keeping zsip_endpoint object
    pjsip_tpselector sel;//endpoint lis transport
    z_status_t (*on_rx_msg_request)( zsip_method_e method_id, const char* method_name,
            void* data, int data_len, void* msg_handler);
    z_status_t (*on_rx_invite_request)(void* data, int data_len, void* call_handler);
}zsip_endpoint;


typedef struct zsip_app
{
    pj_caching_pool  cp;
    pj_pool_t       *pool;
    zsip_endpoint   *endpt;

    pj_timer_entry ka_entry;
    pj_time_val ka_tv;

    int inet_type;
    zsip_transport_type_e tp_type;
    pj_sockaddr default_addr;
    pj_sockaddr srv_addr;

    pjsip_route_hdr route_set;


    pj_ice_strans_cfg	ice_cfg;
    pj_ice_strans	*icest;

}zsip_app;

#if 0
typedef struct resolver_cb_data
{
    zsip_endpoint *endpt;
    z_pool_t *pool;
    void *user_data;
    zsip_resolver_callback *cb;
    zsip_resolve_addr resolve_addr;
}resolver_cb_data;
#endif

typedef struct regc_cb_data
{
    z_pool_t *pool;
    void *user_data;
    zsip_regc_cb* cb;
}regc_cb_data;

typedef struct reqc_cb_data
{
    z_pool_t *pool;
    void *user_data;
    zsip_reqc_cb* cb;
}reqc_cb_data;


typedef struct ice_cb_data
{
    z_pool_t *pool;
    void *user_data;
    zsip_stun_cb* stun_cb;
    zsip_neg_cb* neg_cb;
    z_ice_sess_role role;
    zsip_addr_pair addr_pair[PJ_ICE_MAX_COMP];
    int pair_cnt;
}ice_cb_data;


typedef struct sdp_info
{
    char		 ufrag[80];
    char		 pwd[80];
    char         param[200];
    unsigned	 comp_cnt;
    pj_sockaddr	 def_addr[PJ_ICE_MAX_COMP];
    unsigned	 cand_cnt;
    pj_ice_sess_cand cand[PJ_ICE_ST_MAX_CAND];
    char         foundation[200];
} sdp_info;


static zsip_app g_zsip_app;


static pj_bool_t zsip_on_rx_request(pjsip_rx_data *rdata);

static void zsip_set_route_set(pjsip_tx_data *tdata, const char* dest_addr=NULL, int dest_port=0);

static z_status_t zsip_endpt_resolve(zsip_endptc *endptc);


/*style for every mod alloc from endpt pool*/
static pjsip_module zsip_mod_style =
{
    NULL, NULL,             /* prev, next.      */
    { "mod-zsip", 8 }, /* Name.            */
    -1,                 /* Id           */
    PJSIP_MOD_PRIORITY_APPLICATION, /* Priority         */
    NULL,               /* load()           */
    NULL,               /* start()          */
    NULL,               /* stop()           */
    NULL,               /* unload()         */
    &zsip_on_rx_request,   /* on_rx_request()      */
    NULL,               /* on_rx_response()     */
    NULL,               /* on_tx_request.       */
    NULL,               /* on_tx_response()     */
    NULL,               /* on_tsx_state()       */
};

typedef struct msg_handle_st
{
    pj_pool_t *pool;
    pjsip_transaction *tsx;
    pjsip_tx_data *tdata;
    char *remote_sdp;
}msg_handle_st;

static void err(const char *op, pj_status_t status)
{
    char errmsg[Z_ERR_MSG_SIZE];
    pj_strerror(status, errmsg, sizeof(errmsg));
    PJ_LOG(3,(THIS_FILE, "%s error: %s", op, errmsg));
}


static pj_bool_t zsip_on_rx_request(pjsip_rx_data *rdata)
{
    zsip_method_e method_id;
    char method_name[MAX_METHOD_NAME];
    void *data;
    int data_len;


    /* ignore ACK requests. */
    if (rdata->msg_info.msg->line.req.method.id == PJSIP_ACK_METHOD)
    {
	    return PJ_TRUE;
    }

    method_id = (zsip_method_e)rdata->msg_info.msg->line.req.method.id;
    pj_memcpy(method_name, rdata->msg_info.msg->line.req.method.name.ptr, rdata->msg_info.msg->line.req.method.name.slen);
    method_name[rdata->msg_info.msg->line.req.method.name.slen]='\0';
    if(rdata->msg_info.msg->body)
    {
        data = rdata->msg_info.msg->body->data;
        data_len = rdata->msg_info.msg->body->len;
    }
    else
    {
        data = NULL;
        data_len = 0;
    }



    /*TODO:Add more request processing*/
    int ret;
    pj_str_t ret_text;
    pjsip_rx_data *msg_handler;

    pjsip_transaction *tsx;
    pjsip_tx_data *tdata;
    pj_status_t status;

    if (rdata->msg_info.msg->line.req.method.id != PJSIP_INVITE_METHOD)
    {
        if(g_zsip_app.endpt->on_rx_msg_request)
        {
            //create tsx uas
	        status = pjsip_tsx_create_uas(&zsip_mod_style, rdata, &tsx);
	        if(status != PJ_SUCCESS)
            {
                err("pjsip_tsx_create_uas", status);
                return PJ_TRUE;
            }
	        pjsip_tsx_recv_msg(tsx, rdata);

            status = pjsip_endpt_create_response(g_zsip_app.endpt->endpt, rdata, 200, NULL,  &tdata);
            if(status != PJ_SUCCESS)
            {
                err("pjsip_endpt_create_response", status);
                return PJ_TRUE;//leak:tsx?
            }

            pj_pool_t* pool = z_pool_create(1000, 1000);
            msg_handle_st* handle =  (msg_handle_st*)z_pool_alloc(pool, sizeof(msg_handle_st));
            handle->pool = pool;
            handle->tsx = tsx;
            handle->tdata = tdata;
            handle->remote_sdp = (char*)z_pool_alloc(pool, data_len+1);
            pj_memcpy(handle->remote_sdp, data, data_len);
            handle->remote_sdp[data_len]='\0';

            //pjsip_rx_data_clone(rdata, 0, &msg_handler);
            ret = g_zsip_app.endpt->on_rx_msg_request(method_id, method_name, data, data_len, handle);
        }
        else
        {
            /*not define msg request cb, return 500 error*/
            pjsip_endpt_respond_stateless(g_zsip_app.endpt->endpt, rdata, 500, pj_cstr(&ret_text, "Unsupported request"), NULL, NULL);
            return PJ_TRUE;
        }
	    return ret;
    }
    else
    {
        if(g_zsip_app.endpt->on_rx_invite_request)
        {
        }
        else
        {
            /*not define msg request cb, return 500 error*/
            pjsip_endpt_respond_stateless(g_zsip_app.endpt->endpt, rdata, 500, pj_cstr(&ret_text, "Unsupported invite request"), NULL, NULL);
        }
    }

    return PJ_TRUE;
}




/**
 * create endpoint object and start transport, then init sip stack layer support
 *
 * @param endptc      struct for creating endpt
 * @param inet_type   inet type,  value:Z_AF_INET(), Z_AF_INET6()
 * @param local_addr  local address, NULL means endpt will listen at any address in local host.
 * @param local_port  local port, 0 means endpt will listen at any port in local host
 * @return      The size of the printed message, or -1 if there is not
 *          sufficient space in the buffer to print the message.
 */
static z_status_t zsip_endpt_create(zsip_endptc* endptc, zsip_endpoint **endpt);


#define PRINT(fmt, arg0, arg1, arg2, arg3, arg4, arg5)	    \
	printed = pj_ansi_snprintf(p, maxlen - (p-buffer),  \
				   fmt, arg0, arg1, arg2, arg3, arg4, arg5); \
	if (printed <= 0) return -PJ_ETOOSMALL; \
	p += printed


/* Utility to create a=candidate SDP attribute */
static int print_cand(char buffer[], unsigned maxlen,
              const pj_ice_sess_cand *cand)
{
    char ipaddr[PJ_INET6_ADDRSTRLEN];
    char *p = buffer;
    int printed;

    PRINT("a=candidate:%.*s %u UDP %u %s %u typ ",
      (int)cand->foundation.slen,
      cand->foundation.ptr,
      (unsigned)cand->comp_id,
      cand->prio,
      pj_sockaddr_print(&cand->addr, ipaddr,
                sizeof(ipaddr), 0),
      (unsigned)pj_sockaddr_get_port(&cand->addr));

    PRINT("%s\n",
      pj_ice_get_cand_type_name(cand->type),
      0, 0, 0, 0, 0);

    if (p == buffer+maxlen)
    return -PJ_ETOOSMALL;

    *p = '\0';

    return (int)(p-buffer);
}

static int get_line(char *line, char **str)
{
	char *p=NULL;
    char *line_start = line;
	p=*str;
	while(*p==' '||*p=='\t'||*p=='\n'){
		p++;
	}
	if(*p=='\0'){
		return -1;
	}
	while(((*p)!='\0')&&((*p)!='\n')&&((*p)!='\r')){
		*line++=*p++;
	}
	*line='\0';
	*str=p;
	return line-line_start;
}

/*
 * Encode ICE information in SDP.
 */
int encode_sdp(z_ice_strans *icest, char* param, char buffer[], unsigned maxlen)
{
    char *p = buffer;
    unsigned comp;
    int printed;
    pj_str_t local_ufrag, local_pwd;
    pj_status_t status;

    /* Write "dummy" SDP v=, o=, s=, and t= lines */
    PRINT("v=0\no=- 3414953978 3414953978 IN IP4 localhost\ns=ice\nt=0 0\n",
      0, 0, 0, 0, 0, 0);

    /* Get ufrag and pwd from current session */
    pj_ice_strans_get_ufrag_pwd(icest, &local_ufrag, &local_pwd,
                NULL, NULL);

    /* Write the a=ice-ufrag and a=ice-pwd attributes */
    PRINT("a=ice-ufrag:%.*s\na=ice-pwd:%.*s\n",
       (int)local_ufrag.slen,
       local_ufrag.ptr,
       (int)local_pwd.slen,
       local_pwd.ptr,
       0, 0);

    /* Write the a=param attributes */
    if(param)
    {
        pj_str_t param_str;
        pj_cstr(&param_str, param);
        PRINT("a=param:%.*s\n",
           (int)param_str.slen,
           param_str.ptr,
           0, 0, 0, 0);
    }

    /* Write each component */
    int comp_cnt = pj_ice_strans_get_running_comp_cnt(icest);
    for (comp=0; comp<comp_cnt; ++comp)
    {
        unsigned j, cand_cnt;
        pj_ice_sess_cand cand[PJ_ICE_ST_MAX_CAND];
        char ipaddr[PJ_INET6_ADDRSTRLEN];

        /* Get default candidate for the component */
        status = pj_ice_strans_get_def_cand(icest, comp+1, &cand[0]);
        if (status != PJ_SUCCESS)
            return -status;

        /* Write the default address */
        if (comp==0) {
            /* For component 1, default address is in m= and c= lines */
            PRINT("m=audio %d RTP/AVP 0\n"
              "c=IN IP4 %s\n",
              (int)pj_sockaddr_get_port(&cand[0].addr),
              pj_sockaddr_print(&cand[0].addr, ipaddr,
                        sizeof(ipaddr), 0),
              0, 0, 0, 0);
        } else if (comp==1) {
            /* For component 2, default address is in a=rtcp line */
            PRINT("a=rtcp:%d IN IP4 %s\n",
              (int)pj_sockaddr_get_port(&cand[0].addr),
              pj_sockaddr_print(&cand[0].addr, ipaddr,
                        sizeof(ipaddr), 0),
              0, 0, 0, 0);
        } else {
            /* For other components, we'll just invent this.. */
            PRINT("a=Xice-defcand:%d IN IP4 %s\n",
              (int)pj_sockaddr_get_port(&cand[0].addr),
              pj_sockaddr_print(&cand[0].addr, ipaddr,
                        sizeof(ipaddr), 0),
              0, 0, 0, 0);
        }

        /* Enumerate all candidates for this component */
        cand_cnt = PJ_ARRAY_SIZE(cand);
        status = pj_ice_strans_enum_cands(icest, comp+1,
                          &cand_cnt, cand);
        if(status != PJ_SUCCESS)
        {
            err("pj_ice_strans_enum_cands", status);
            return status;
        }

        /* And encode the candidates as SDP */
        for (j=0; j<cand_cnt; ++j)
        {
            printed = print_cand(p, maxlen - (unsigned)(p-buffer), &cand[j]);
            if (printed < 0)
                return -PJ_ETOOSMALL;
            p += printed;
        }
    }

    if (p == buffer+maxlen)
    return -PJ_ETOOSMALL;

    *p = '\0';
    return (int)(p - buffer);
}


/*
 * Input and parse SDP from the remote (containing remote's ICE information)
 * and save it to global variables.
 */
static z_bool_t decode_sdp(char *buffer, sdp_info *sdpst)
{
    char linebuf[80];
    unsigned media_cnt = 0;
    unsigned comp0_port = 0;
    char     comp0_addr[80];

    if(buffer == NULL)
        return PJ_FALSE;

    pj_bzero(sdpst, sizeof(sdp_info));

    comp0_addr[0] = '\0';

    char *temp_buffer;
    temp_buffer = buffer;
    while (1)
    {
    	int len;
    	char *line;

        /*get a line from buffer*/
        len=get_line(linebuf, &temp_buffer);
        if(len<0)
            break;


        /*parse linebuf*/
    	line = linebuf;

    	/* Ignore subsequent media descriptors */
    	if (media_cnt > 1)
    	    continue;

    	switch (line[0])
        {
        	case 'm':
    	    {
        		int cnt;
        		char media[32], portstr[32];

        		++media_cnt;
        		if (media_cnt > 1)
                {
        		    break;
    		    }

        		cnt = sscanf(line+2, "%s %s RTP/", media, portstr);
        		if (cnt != 2)
                {
        		    PJ_LOG(3,("decode_sdp", "Error parsing media line"));
        		    goto on_error;
        		}

        		comp0_port = atoi(portstr);

                break;

        	}

        	case 'c':
    	    {
        		int cnt;
        		char c[32], net[32], ip[80];

        		cnt = sscanf(line+2, "%s %s %s", c, net, ip);
        		if (cnt != 3)
                {
        		    PJ_LOG(3,("decode_sdp", "Error parsing connection line"));
        		    goto on_error;
        		}

        		strcpy(comp0_addr, ip);

                break;
    	    }

        	case 'a':
    	    {
        		char *attr = strtok(line+2, ": \t\r\n");
        		if (strcmp(attr, "ice-ufrag")==0)
                {
        		    strcpy(sdpst->ufrag, attr+strlen(attr)+1);
        		}
                else if (strcmp(attr, "ice-pwd")==0)
                {
        		    strcpy(sdpst->pwd, attr+strlen(attr)+1);
        		}
                else if (strcmp(attr, "param")==0)
                {
        		    strcpy(sdpst->param, attr+strlen(attr)+1);
        		}
                else if (strcmp(attr, "rtcp")==0)
        		{
        		    char *val = attr+strlen(attr)+1;
        		    int af, cnt;
        		    int port;
        		    char net[32], ip[64];
        		    pj_str_t tmp_addr;
        		    pj_status_t status;

        		    cnt = sscanf(val, "%d IN %s %s", &port, net, ip);
        		    if (cnt != 3)
                    {
            			PJ_LOG(3,("decode_sdp", "Error parsing rtcp attribute"));
            			goto on_error;
        		    }

        		    if (strchr(ip, ':'))
        			    af = pj_AF_INET6();
        		    else
        			    af = pj_AF_INET();

        		    pj_sockaddr_init(af, &sdpst->def_addr[1], NULL, 0);
        		    tmp_addr = pj_str(ip);
        		    status = pj_sockaddr_set_str_addr(af, &sdpst->def_addr[1], &tmp_addr);
        		    if (status != PJ_SUCCESS)
                    {
            			PJ_LOG(3,("decode_sdp", "Invalid IP address"));
            			goto on_error;
        		    }
        		    pj_sockaddr_set_port(&sdpst->def_addr[1], (pj_uint16_t)port);

        		}
                else if (strcmp(attr, "candidate")==0)
                {
        		    char *sdpcand = attr+strlen(attr)+1;
        		    int af, cnt;
        		    char foundation[32], transport[12], ipaddr[80], type[32];
        		    pj_str_t tmpaddr;
        		    int comp_id, prio, port;
        		    pj_ice_sess_cand *cand;
        		    pj_status_t status;

        		    cnt = sscanf(sdpcand, "%s %d %s %d %s %d typ %s",
        				 foundation,
        				 &comp_id,
        				 transport,
        				 &prio,
        				 ipaddr,
        				 &port,
        				 type);
        		    if (cnt != 7)
                    {
            			PJ_LOG(3, ("decode sdp", "error: Invalid ICE candidate line"));
            			goto on_error;
        		    }

        		    cand = &sdpst->cand[sdpst->cand_cnt];
        		    pj_bzero(cand, sizeof(*cand));

        		    if (strcmp(type, "host")==0)
        			    cand->type = PJ_ICE_CAND_TYPE_HOST;
        		    else if (strcmp(type, "srflx")==0)
        			    cand->type = PJ_ICE_CAND_TYPE_SRFLX;
        		    else if (strcmp(type, "relay")==0)
        			    cand->type = PJ_ICE_CAND_TYPE_RELAYED;
        		    else
                    {
            			PJ_LOG(3, ("decode sdp", "Error: invalid candidate type '%s'", type));
            			goto on_error;
        		    }

        		    cand->comp_id = (pj_uint8_t)comp_id;
        		    //pj_strdup2(sdpst->pool, &cand->foundation, foundation);
        		    strcpy(sdpst->foundation, foundation);
        		    pj_cstr(&cand->foundation, sdpst->foundation);
        		    cand->prio = prio;

        		    if (strchr(ipaddr, ':'))
        			    af = pj_AF_INET6();
        		    else
        			    af = pj_AF_INET();

        		    tmpaddr = pj_str(ipaddr);
        		    pj_sockaddr_init(af, &cand->addr, NULL, 0);
        		    status = pj_sockaddr_set_str_addr(af, &cand->addr, &tmpaddr);
        		    if (status != PJ_SUCCESS)
                    {
            			PJ_LOG(1,("decode sdp", "Error: invalid IP address '%s'", ipaddr));
            			goto on_error;
        		    }

        		    pj_sockaddr_set_port(&cand->addr, (pj_uint16_t)port);

        		    ++sdpst->cand_cnt;

        		    if (cand->comp_id > sdpst->comp_cnt)
        			    sdpst->comp_cnt = cand->comp_id;
                    break;
        		}
    	    }
    	}
    }

    if (sdpst->cand_cnt==0 ||
	sdpst->ufrag[0]==0 ||
	sdpst->pwd[0]==0 ||
	sdpst->comp_cnt == 0)
    {
    	PJ_LOG(3, ("decode sdp", "Error: not enough info"));
    	goto on_error;
    }

    if (comp0_port==0 || comp0_addr[0]=='\0')
    {
    	PJ_LOG(3, ("decode sdp", "Error: default address for component 0 not found"));
    	goto on_error;
    }
    else
    {
    	int af;
    	pj_str_t tmp_addr;
    	pj_status_t status;

    	if (strchr(comp0_addr, ':'))
    	    af = pj_AF_INET6();
    	else
    	    af = pj_AF_INET();

    	pj_sockaddr_init(af, &sdpst->def_addr[0], NULL, 0);
    	tmp_addr = pj_str(comp0_addr);
    	status = pj_sockaddr_set_str_addr(af, &sdpst->def_addr[0], &tmp_addr);
    	if (status != PJ_SUCCESS)
        {
    	    PJ_LOG(3,("decode sdp", "Invalid IP address in c= line"));
    	    goto on_error;
	    }
	    pj_sockaddr_set_port(&sdpst->def_addr[0], (pj_uint16_t)comp0_port);
    }

    return PJ_TRUE;

on_error:
    pj_bzero(sdpst, sizeof(sdp_info));
    return PJ_FALSE;
}

/*
 * Input and parse SDP from the remote (containing remote's ICE information)
 * and save it to global variables.
 */
static char* decode_sdp2(char *buffer, sdp_info *sdpst)
{
    char* param = NULL;
    char linebuf[80];
    unsigned media_cnt = 0;
    unsigned comp0_port = 0;
    char     comp0_addr[80];

    if(buffer == NULL)
        return NULL;

    pj_bzero(sdpst, sizeof(sdp_info));

    comp0_addr[0] = '\0';

    char *temp_buffer;
    temp_buffer = buffer;
    while (1)
    {
    	int len;
    	char *line;

        /*get a line from buffer*/
        len=get_line(linebuf, &temp_buffer);
        if(len<0)
            break;


        /*parse linebuf*/
    	line = linebuf;

    	/* Ignore subsequent media descriptors */
    	if (media_cnt > 1)
    	    continue;

    	switch (line[0])
        {
        	case 'm':
    	    {
        		int cnt;
        		char media[32], portstr[32];

        		++media_cnt;
        		if (media_cnt > 1)
                {
        		    break;
    		    }

        		cnt = sscanf(line+2, "%s %s RTP/", media, portstr);
        		if (cnt != 2)
                {
        		    PJ_LOG(3,("decode_sdp", "Error parsing media line"));
        		    goto on_error;
        		}

        		comp0_port = atoi(portstr);

                break;

        	}

        	case 'c':
    	    {
        		int cnt;
        		char c[32], net[32], ip[80];

        		cnt = sscanf(line+2, "%s %s %s", c, net, ip);
        		if (cnt != 3)
                {
        		    PJ_LOG(3,("decode_sdp", "Error parsing connection line"));
        		    goto on_error;
        		}

        		strcpy(comp0_addr, ip);

                break;
    	    }

        	case 'a':
    	    {
        		char *attr = strtok(line+2, ": \t\r\n");
        		if (strcmp(attr, "ice-ufrag")==0)
                {
        		    strcpy(sdpst->ufrag, attr+strlen(attr)+1);
        		}
                else if (strcmp(attr, "ice-pwd")==0)
                {
        		    strcpy(sdpst->pwd, attr+strlen(attr)+1);
        		}
                else if (strcmp(attr, "param")==0)
                {
        		    strcpy(sdpst->param, attr+strlen(attr)+1);
                    param = sdpst->param;
        		}
                else if (strcmp(attr, "rtcp")==0)
        		{
        		    char *val = attr+strlen(attr)+1;
        		    int af, cnt;
        		    int port;
        		    char net[32], ip[64];
        		    pj_str_t tmp_addr;
        		    pj_status_t status;

        		    cnt = sscanf(val, "%d IN %s %s", &port, net, ip);
        		    if (cnt != 3)
                    {
            			PJ_LOG(3,("decode_sdp", "Error parsing rtcp attribute"));
            			goto on_error;
        		    }

        		    if (strchr(ip, ':'))
        			    af = pj_AF_INET6();
        		    else
        			    af = pj_AF_INET();

        		    pj_sockaddr_init(af, &sdpst->def_addr[1], NULL, 0);
        		    tmp_addr = pj_str(ip);
        		    status = pj_sockaddr_set_str_addr(af, &sdpst->def_addr[1], &tmp_addr);
        		    if (status != PJ_SUCCESS)
                    {
            			PJ_LOG(3,("decode_sdp", "Invalid IP address"));
            			goto on_error;
        		    }
        		    pj_sockaddr_set_port(&sdpst->def_addr[1], (pj_uint16_t)port);

        		}
                else if (strcmp(attr, "candidate")==0)
                {
        		    char *sdpcand = attr+strlen(attr)+1;
        		    int af, cnt;
        		    char foundation[32], transport[12], ipaddr[80], type[32];
        		    pj_str_t tmpaddr;
        		    int comp_id, prio, port;
        		    pj_ice_sess_cand *cand;
        		    pj_status_t status;

        		    cnt = sscanf(sdpcand, "%s %d %s %d %s %d typ %s",
        				 foundation,
        				 &comp_id,
        				 transport,
        				 &prio,
        				 ipaddr,
        				 &port,
        				 type);
        		    if (cnt != 7)
                    {
            			PJ_LOG(3, ("decode sdp", "error: Invalid ICE candidate line"));
            			goto on_error;
        		    }

        		    cand = &sdpst->cand[sdpst->cand_cnt];
        		    pj_bzero(cand, sizeof(*cand));

        		    if (strcmp(type, "host")==0)
        			    cand->type = PJ_ICE_CAND_TYPE_HOST;
        		    else if (strcmp(type, "srflx")==0)
        			    cand->type = PJ_ICE_CAND_TYPE_SRFLX;
        		    else if (strcmp(type, "relay")==0)
        			    cand->type = PJ_ICE_CAND_TYPE_RELAYED;
        		    else
                    {
            			PJ_LOG(3, ("decode sdp", "Error: invalid candidate type '%s'", type));
            			goto on_error;
        		    }

        		    cand->comp_id = (pj_uint8_t)comp_id;
        		    //pj_strdup2(sdpst->pool, &cand->foundation, foundation);
        		    strcpy(sdpst->foundation, foundation);
        		    pj_cstr(&cand->foundation, sdpst->foundation);
        		    cand->prio = prio;

        		    if (strchr(ipaddr, ':'))
        			    af = pj_AF_INET6();
        		    else
        			    af = pj_AF_INET();

        		    tmpaddr = pj_str(ipaddr);
        		    pj_sockaddr_init(af, &cand->addr, NULL, 0);
        		    status = pj_sockaddr_set_str_addr(af, &cand->addr, &tmpaddr);
        		    if (status != PJ_SUCCESS)
                    {
            			PJ_LOG(1,("decode sdp", "Error: invalid IP address '%s'", ipaddr));
            			goto on_error;
        		    }

        		    pj_sockaddr_set_port(&cand->addr, (pj_uint16_t)port);

        		    ++sdpst->cand_cnt;

        		    if (cand->comp_id > sdpst->comp_cnt)
        			    sdpst->comp_cnt = cand->comp_id;
                    break;
        		}
    	    }
    	}
    }

    if (sdpst->cand_cnt==0 ||
	sdpst->ufrag[0]==0 ||
	sdpst->pwd[0]==0 ||
	sdpst->comp_cnt == 0)
    {
    	PJ_LOG(3, ("decode sdp", "Error: not enough info"));
    	goto on_error;
    }

    if (comp0_port==0 || comp0_addr[0]=='\0')
    {
    	PJ_LOG(3, ("decode sdp", "Error: default address for component 0 not found"));
    	goto on_error;
    }
    else
    {
    	int af;
    	pj_str_t tmp_addr;
    	pj_status_t status;

    	if (strchr(comp0_addr, ':'))
    	    af = pj_AF_INET6();
    	else
    	    af = pj_AF_INET();

    	pj_sockaddr_init(af, &sdpst->def_addr[0], NULL, 0);
    	tmp_addr = pj_str(comp0_addr);
    	status = pj_sockaddr_set_str_addr(af, &sdpst->def_addr[0], &tmp_addr);
    	if (status != PJ_SUCCESS)
        {
    	    PJ_LOG(3,("decode sdp", "Invalid IP address in c= line"));
    	    goto on_error;
	    }
	    pj_sockaddr_set_port(&sdpst->def_addr[0], (pj_uint16_t)comp0_port);
    }

    return param;

on_error:
    pj_bzero(sdpst, sizeof(sdp_info));
    return NULL;
}



z_bool_t get_param(char *buffer, char *param)
{
    sdp_info info;
    if(decode_sdp2(buffer, &info) == NULL)
        return Z_FALSE;
    strcpy(param, info.param);
    return Z_TRUE;
}


/*
 * This is the callback that is registered to the ICE stream transport to
 * receive notification about incoming data. By "data" it means application
 * data such as RTP/RTCP, and not packets that belong to ICE signaling (such
 * as STUN connectivity checks or TURN signaling).
 */
static void cb_on_rx_data(pj_ice_strans *icest,
			  unsigned comp_id,
			  void *pkt, pj_size_t size,
			  const pj_sockaddr_t *src_addr,
			  unsigned src_addr_len)
{
    PJ_UNUSED_ARG(icest);
    PJ_UNUSED_ARG(src_addr_len);
    PJ_UNUSED_ARG(pkt);
}


/*
 * This is the callback that is registered to the ICE stream transport to
 * receive notification about ICE state progression.
 */
static void cb_on_ice_complete(pj_ice_strans *icest,
			       pj_ice_strans_op op,
			       pj_status_t status)
{
    ice_cb_data* data = (ice_cb_data*)pj_ice_strans_get_user_data(icest);
    if (status == PJ_SUCCESS)
    {
        if(op == PJ_ICE_STRANS_OP_INIT)
        {
            /* create session */
            status = pj_ice_strans_init_ice(icest, (pj_ice_sess_role)data->role, NULL, NULL);
            if (status != PJ_SUCCESS)
            {
                pj_ice_strans_destroy(icest);
                err("pj_ice_strans_init_ice", status);
                if(data->stun_cb)
                    data->stun_cb(status, NULL, data->user_data);
                z_pool_release(data->pool);
                return;
            }
            if(data->stun_cb)
                data->stun_cb(0, icest, data->user_data);
            return;
        }
        else if(op == PJ_ICE_STRANS_OP_NEGOTIATION)
        {
            const pj_ice_sess_check *c;
            int comp_cnt;
            comp_cnt = pj_ice_strans_get_running_comp_cnt(icest);
            int pair_cnt;
            pair_cnt = 0;
            for(int i=0; i<comp_cnt; i++)
            {
                c = pj_ice_strans_get_valid_pair(icest, i+1);
                if(c==NULL)
                    continue;
                pj_sockaddr_print(&c->lcand->addr, data->addr_pair[pair_cnt].l_addr, ZSIP_MAX_ADDR_LEN, 0);
                data->addr_pair[pair_cnt].l_port= pj_sockaddr_get_port(&c->lcand->addr);
                pj_sockaddr_print(&c->rcand->addr, data->addr_pair[pair_cnt].r_addr, ZSIP_MAX_ADDR_LEN, 0);
                data->addr_pair[pair_cnt].r_port = pj_sockaddr_get_port(&c->rcand->addr);
                pair_cnt++;
            }
            if(data->neg_cb)
                data->neg_cb(0, icest, data->addr_pair, pair_cnt, data->user_data);
            return;
        }
        else
        {
            //what is this?
        }
    }
    else
    {
        if(op == PJ_ICE_STRANS_OP_INIT)
        {
            pj_ice_strans_destroy(icest);
            err("PJ_ICE_STRANS_OP_INIT", status);
            if(data->stun_cb)
                data->stun_cb(status, NULL, data->user_data);
            z_pool_release(data->pool);
        }
        else if(op == PJ_ICE_STRANS_OP_NEGOTIATION)
        {
            pj_ice_strans_destroy(icest);
            err("PJ_ICE_STRANS_OP_NEGOTIATION", status);
            if(data->neg_cb)
                data->neg_cb(status, NULL, NULL, 0, data->user_data);
            z_pool_release(data->pool);
        }
        else
        {
            pj_ice_strans_destroy(icest);
            err("Unkown PROGRESS", status);
            z_pool_release(data->pool);
        }
	}
}


static pj_status_t zsip_ice_init(zsip_endptc* endptc)
{
    pj_status_t status;

    /* Initialize nath*/
    status = pjnath_init();
    if(status != PJ_SUCCESS)
    {
        err("pjnath_init", status);
        return status;
    }

    /* Init our ICE settings with null values */
    pj_ice_strans_cfg_default(&g_zsip_app.ice_cfg);

    g_zsip_app.ice_cfg.stun_cfg.pf = &g_zsip_app.cp.factory;

    /* Create timer heap for timer stuff */
    g_zsip_app.ice_cfg.stun_cfg.timer_heap = pjsip_endpt_get_timer_heap(g_zsip_app.endpt->endpt);
    //pj_timer_heap_create(g_zsip_app.pool, 100, &g_zsip_app.ice_cfg.stun_cfg.timer_heap);

    /* create ioqueue for network I/O stuff */
    g_zsip_app.ice_cfg.stun_cfg.ioqueue = pjsip_endpt_get_ioqueue(g_zsip_app.endpt->endpt);
    //pj_ioqueue_create(g_zsip_app.pool, 16, &g_zsip_app.ice_cfg.stun_cfg.ioqueue);

    g_zsip_app.ice_cfg.af = endptc->inet_type;

    /* -= Start initializing ICE stream transport config =- */
    /* Maximum number of host candidates */
	g_zsip_app.ice_cfg.stun.max_host_cands = PJ_ICE_ST_MAX_CAND;

    /* Nomination strategy */
	g_zsip_app.ice_cfg.opt.aggressive = PJ_FALSE;

    //stun check timer opt
    //g_zsip_app.ice_cfg.opt.controlled_agent_want_nom_timeout = -1;

    /*set stun bound addr*/
    if(endptc->bound_addr)
    {
        pj_str_t addr_str = pj_str((char*)endptc->bound_addr);
        pj_sockaddr_init(g_zsip_app.inet_type, &g_zsip_app.ice_cfg.stun.cfg.bound_addr,
            &addr_str, endptc->bound_port);
    }
    else
    {
        pj_sockaddr_init(g_zsip_app.inet_type, &g_zsip_app.ice_cfg.stun.cfg.bound_addr,
            NULL, endptc->bound_port);
        char addr[46];
        pj_sockaddr_print(&g_zsip_app.ice_cfg.stun.cfg.bound_addr, addr, sizeof(addr), 1);
    }

    /* Configure STUN/srflx candidate resolution */
    if(endptc->stun_addr)
    {
	    pj_cstr(&g_zsip_app.ice_cfg.stun.server, endptc->stun_addr);
	    g_zsip_app.ice_cfg.stun.port = endptc->stun_port;

    	/* For this demo app, configure longer STUN keep-alive time
    	 * so that it does't clutter the screen output.
    	 */
    	g_zsip_app.ice_cfg.stun.cfg.ka_interval = STUN_KA_INTERVAL;
    }

    /*set ice resolver*/
    g_zsip_app.ice_cfg.resolver = pjsip_endpt_get_resolver(g_zsip_app.endpt->endpt);


    return PJ_SUCCESS;

}

static bool zsip_init_flag = false;
z_status_t zsip_init(zsip_endptc* endptc)
{
    pj_status_t status;

	if (zsip_init_flag)
		return PJ_SUCCESS;

    if(g_zsip_app.endpt)
        return Z_INSTANCE_EXIST;

    status=pj_init();
    if(status != PJ_SUCCESS)
    {
        err("lib init", status);
        return status;
    }

    /* init PJLIB-UTIL: */
    status=pjlib_util_init();
    if(status != PJ_SUCCESS)
    {
        err("lib util init", status);
        return status;
    }

    /*set log level*/
    if(endptc->is_log == Z_TRUE)
        pj_log_set_level(6);
    else
        pj_log_set_level(1);

    /* Must create a pool factory before we can allocate any memory. */
    pj_caching_pool_init(&g_zsip_app.cp, &pj_pool_factory_default_policy, CACHING_POOL_SIZE);

    /* Create application pool for misc. */
    g_zsip_app.pool = pj_pool_create(&g_zsip_app.cp.factory, "zsip_app", 4096, 4096, NULL);

    status=zsip_endpt_create(endptc, &g_zsip_app.endpt);
    if(status != PJ_SUCCESS)
    {
        pj_pool_release(g_zsip_app.pool);
        g_zsip_app.endpt = NULL;
        return status;
    }


    status=zsip_ice_init(endptc);
    if(status != PJ_SUCCESS)
    {
        pj_pool_release(g_zsip_app.pool);
        pjsip_endpt_destroy(g_zsip_app.endpt->endpt);
        pj_pool_release(g_zsip_app.endpt->pool);
        g_zsip_app.endpt = NULL;
        return status;
    }

	zsip_init_flag = true;
    return PJ_SUCCESS;
}

void zsip_release()
{
	if (zsip_init_flag)
	{
		pj_pool_release(g_zsip_app.pool);
		pjsip_endpt_destroy(g_zsip_app.endpt->endpt);
		pj_pool_release(g_zsip_app.endpt->pool);
		g_zsip_app.endpt = NULL;
		pj_caching_pool_destroy(&g_zsip_app.cp);
		zsip_init_flag = false;
	}
}

z_pool_t* z_pool_create(int init, int inc)
{
   return (z_pool_t*)pj_pool_create(&g_zsip_app.cp.factory, NULL, init, inc, NULL);
}

z_status_t z_thread_create(z_pool_t *pool, z_thread_proc *proc, void *arg, z_thread_t **thread )
{
    return pj_thread_create(pool, NULL, proc, arg, 0, 0, thread);
}

static pj_bool_t thread_registered = PJ_FALSE;
pj_status_t z_thread_register(void)
{
	pj_thread_desc	desc;
	pj_thread_t*	thread = 0;

	if (!pj_thread_is_registered())
	{
		if (PJ_SUCCESS == pj_thread_register(NULL, desc, &thread))
		{
			thread_registered = PJ_TRUE;
		}
	}

	return PJ_SUCCESS;
}

/**
 * create endpoint object and start transport, then init sip stack layer support
 *
 * @param endptc      struct for creating endpt
 * @param inet_type   inet type,  value:Z_AF_INET(), Z_AF_INET6()
 * @param local_addr  local address, NULL means endpt will listen at any address in local host.
 * @param local_port  local port, 0 means endpt will listen at any port in local host
 * @return      The size of the printed message, or -1 if there is not
 *          sufficient space in the buffer to print the message.
 */
static z_status_t zsip_endpt_create(zsip_endptc* endptc, zsip_endpoint **endpt)
{
    z_pool_t* pool;
    pool = z_pool_create(1000, 1000);
    *endpt = (zsip_endpoint*)z_pool_alloc(pool, sizeof(zsip_endpoint));
    (*endpt)->pool = pool;

    /*create endpt*/
    pj_status_t status;
    status = pjsip_endpt_create(&g_zsip_app.cp.factory, NULL, &(*endpt)->endpt);
    if(status != PJ_SUCCESS)
    {
        err("create endpt", status);
        z_pool_release(pool);
        return status;
    }

    /*create resolver*/
    status = zsip_endpt_resolve(endptc);
    if(status != PJ_SUCCESS)
    {
        z_pool_release(pool);
        return status;
    }

    /*back up the cb*/
    (*endpt)->on_rx_invite_request = endptc->on_rx_invite_request;
    (*endpt)->on_rx_msg_request = endptc->on_rx_msg_request;

    /*start transport*/
    pjsip_tcp_transport_cfg tcp_cfg;
    pjsip_tpfactory *tpfactory;
    pjsip_transport *tp;

    pj_sockaddr addr;
    pj_str_t local_addr_str;
    g_zsip_app.inet_type = endptc->inet_type;
    g_zsip_app.tp_type = endptc->tp_type;
    status = pj_gethostip(endptc->inet_type, &g_zsip_app.default_addr);
    if(status != PJ_SUCCESS)
    {
        err("pj_gethostip", status);
        z_pool_release(pool);
        return status;
    }
    pj_sockaddr_init((pj_uint16_t)(endptc->inet_type), &addr, NULL, (pj_uint16_t)endptc->local_port);
    /*
    if(endptc->local_addr)
    {
        pj_cstr(&local_addr_str, endptc->local_addr);
        pj_sockaddr_init((pj_uint16_t)(endptc->inet_type), &addr, &local_addr_str, (pj_uint16_t)endptc->local_port);
    }
    else
    {
        pj_sockaddr_cp(&addr, &g_zsip_app.default_addr);
        pj_sockaddr_set_port(&addr, (pj_uint16_t)endptc->local_port);
    }
    */
    if (endptc->inet_type == pj_AF_INET())
    {
    	if (endptc->tp_type == ZSIP_TRANSPORT_TCP)
        {
            pjsip_tcp_transport_cfg_default(&tcp_cfg, pj_AF_INET());

            pj_sockaddr_cp(&tcp_cfg.bind_addr, &addr);

            if(endptc->published_addr)
            {
                pjsip_host_port a_name;
                pj_cstr(&a_name.host, endptc->published_addr);
                a_name.port = endptc->published_port;
                pj_memcpy(&tcp_cfg.addr_name, &a_name, sizeof(a_name));
            }
            tcp_cfg.async_cnt = 1;
            tcp_cfg.reuse_addr = 1;//default value for Windows family is 0

            //we can set more detail with pjsip_tcp_transport_start3
    	    status = pjsip_tcp_transport_start3((*endpt)->endpt, &tcp_cfg, &tpfactory);
            if(status != PJ_SUCCESS)
            {
                err("pjsip_tcp_transport_start3", status);
                z_pool_release(pool);
                return status;
            }
            //(*endpt)->sel.type = PJSIP_TPSELECTOR_LISTENER;
            //(*endpt)->sel.u.listener = tpfactory;
    	}
        else
        {
    	    status = pjsip_udp_transport_start((*endpt)->endpt, &addr.ipv4, NULL, 1, &tp);
            if(status != PJ_SUCCESS)
            {
                err("pjsip_udp_transport_start", status);
                z_pool_release(pool);
                return status;
            }
            //(*endpt)->sel.type = PJSIP_TPSELECTOR_TRANSPORT;
            //(*endpt)->sel.u.transport = tp;
    	}
    }
    else if (endptc->inet_type == pj_AF_INET6())
    {
        status = pjsip_udp_transport_start6((*endpt)->endpt, &addr.ipv6, NULL, 1, &tp);
        if(status != PJ_SUCCESS)
        {
            err("pjsip_udp_transport_start6", status);
            z_pool_release(pool);
            return status;
        }
        //(*endpt)->sel.type = PJSIP_TPSELECTOR_TRANSPORT;
        //(*endpt)->sel.u.transport = tp;
    }
    else
    {
    	status = PJ_EAFNOTSUP;
    }
    if(status != PJ_SUCCESS)
    {
        err("start transport", status);
        z_pool_release(pool);
        pjsip_endpt_destroy((*endpt)->endpt);
        return status;
    }

    //create transport for send request
    pj_str_t srv_addr_str;
    pj_cstr(&srv_addr_str, endptc->srv_addr);
    pj_sockaddr_init((pj_uint16_t)(endptc->inet_type), &g_zsip_app.srv_addr, &srv_addr_str, (pj_uint16_t)endptc->srv_port);
    if (endptc->inet_type == pj_AF_INET())
    {
        status = pjsip_endpt_acquire_transport((*endpt)->endpt,
    						  (pjsip_transport_type_e)endptc->tp_type,
    						  &g_zsip_app.srv_addr,
    						  sizeof(g_zsip_app.srv_addr.ipv4),
    						  NULL,
    						  &tp);
    }
    else
    {
        status = pjsip_endpt_acquire_transport((*endpt)->endpt,
    						  (pjsip_transport_type_e)endptc->tp_type,
    						  &g_zsip_app.srv_addr,
    						  sizeof(g_zsip_app.srv_addr.ipv6),
    						  NULL,
    						  &tp);
    }
    if(status != PJ_SUCCESS)
    {
        err("pjsip_endpt_acquire_transport", status);
        z_pool_release(pool);
        pjsip_endpt_destroy((*endpt)->endpt);
        return status;
    }
    (*endpt)->sel.type = PJSIP_TPSELECTOR_TRANSPORT;
    (*endpt)->sel.u.transport = tp;

    /*
     * Init transaction layer.
     * This will create/initialize transaction hash tables etc.
     */
    //FIXME:注释部分代码，需要修改的地方
    /*
    status=pjsip_tsx_layer_init_module_timeout((*endpt)->endpt, endptc->req_timeout);
    if(status!=PJ_SUCCESS)
    {
        err("init tsx layer", status);
        z_pool_release(pool);
        pjsip_endpt_destroy((*endpt)->endpt);
        return status;
    }*/

    /*  Initialize UA layer. */
    status=pjsip_ua_init_module((*endpt)->endpt, NULL);
    if(status!=PJ_SUCCESS)
    {
        err("init ua layer", status);
        z_pool_release(pool);
        pjsip_endpt_destroy((*endpt)->endpt);
        return status;
    }

    /* Initialize 100rel support */
    status=pjsip_100rel_init_module((*endpt)->endpt);
    if(status!=PJ_SUCCESS)
    {
        err("init 100rel support", status);
        z_pool_release(pool);
        pjsip_endpt_destroy((*endpt)->endpt);
        return status;
    }

    /* Register our module to receive incoming requests. */
    pjsip_module* mod = (pjsip_module*)pj_pool_alloc(pool, sizeof(pjsip_module));
    pj_memcpy(mod, &zsip_mod_style, sizeof(pjsip_module));
    status = pjsip_endpt_register_module((*endpt)->endpt, mod);
    if(status!=PJ_SUCCESS)
    {
        err("register endpt module", status);
        z_pool_release(pool);
        pjsip_endpt_destroy((*endpt)->endpt);
        return status;
    }

    /*create route_set*/
   	pjsip_route_hdr *route;
	const pj_str_t hname = { "Route", 5 };
    char *route_uri = (char *)pj_pool_zalloc(g_zsip_app.pool, 80);
    if(endptc->tp_type == ZSIP_TRANSPORT_TCP)
	   sprintf(route_uri, "<sip:%s:%d;lr;transport=tcp;hide>", endptc->srv_addr, endptc->srv_port); //uri = "sip:192.168.1.13;lr;hide";
    else
        sprintf(route_uri, "<sip:%s:%d;lr;transport=udp;hide>", endptc->srv_addr, endptc->srv_port);//uri = "sip:192.168.1.13;lr;transport=tcp;hide";

	pj_list_init(&g_zsip_app.route_set);
	route = (pjsip_route_hdr*)pjsip_parse_hdr(g_zsip_app.pool, &hname, route_uri, strlen(route_uri), NULL);
	PJ_ASSERT_RETURN(route != NULL, 1);
	pj_list_push_back(&g_zsip_app.route_set, route);


    return PJ_SUCCESS;
}

z_pool_t* zsip_endpt_create_pool(const char *pool_name, int initial, int increment )
{
    return pjsip_endpt_create_pool(g_zsip_app.endpt->endpt, pool_name, initial, increment);
}

z_status_t zsip_endpt_handle_events(const z_time_val *max_timeout)
{
    return pjsip_endpt_handle_events(g_zsip_app.endpt->endpt, (const pj_time_val*)max_timeout);
}

#if 0
static void resolver_callback(pj_status_t status, void *token, const struct pjsip_server_addresses *addr)
{
    const pj_addr_hdr *h;
    resolver_cb_data* data = (resolver_cb_data*)token;

    if(status==PJ_SUCCESS)
    {
        data->resolve_addr.count = addr->count;
        for(int i=0; i<data->resolve_addr.count; i++)
        {
            data->resolve_addr.entry[i].type = (zsip_transport_type_e)addr->entry[i].type;
            h = (const pj_addr_hdr*)&addr->entry[i].addr;
            pj_inet_ntop(h->sa_family, pj_sockaddr_get_addr(&addr->entry[i].addr),
    			  data->resolve_addr.entry[i].ip, sizeof(data->resolve_addr.entry[i].ip));
            data->resolve_addr.entry[i].port = pj_sockaddr_get_port(&addr->entry[i].addr);
        }
    }

    //user callback
    data->cb(status, data->user_data, &data->resolve_addr);

    //release resolve pool
    pjsip_endpt_release_pool(data->endpt->endpt, data->pool);
}


z_status_t zsip_endpt_resolve(const char *addr,  int port,
    void *user_data,  zsip_resolver_callback *cb)
{
    pj_status_t status;

    pjsip_transport_type_e tp_type;
    tp_type = (pjsip_transport_type_e)g_zsip_app.tp_type;

    pjsip_host_info dest;
    dest.type = (pjsip_transport_type_e)tp_type;
    dest.flag = pjsip_transport_get_flag_from_type((pjsip_transport_type_e)tp_type);
    dest.addr.host = pj_str((char*)addr);
    dest.addr.port = port;

    pj_dns_resolver *resv;
    pj_str_t nameserver;
    status = pjsip_endpt_create_resolver(g_zsip_app.endpt->endpt, &resv);
    if(status!=PJ_SUCCESS)
    {
        err("endpt create resolver", status);
        return status;
    }
    nameserver = pj_str((char*)addr);
    status = pj_dns_resolver_set_ns(resv, 1, &nameserver, (const pj_uint16_t*)&port);
    if(status!=PJ_SUCCESS)
    {
        err("resolver set nameserver", status);
        return status;
    }
    status = pjsip_endpt_set_resolver(g_zsip_app.endpt->endpt, resv);
    if(status!=PJ_SUCCESS)
    {
        err("endpt set resolver", status);
        return status;
    }

    z_pool_t *pool = zsip_endpt_create_pool(NULL, 1000, 1000);
    resolver_cb_data* data = (resolver_cb_data*)z_pool_alloc(pool, sizeof(resolver_cb_data));
    data->endpt = g_zsip_app.endpt;
    data->pool = pool;
    data->user_data = user_data;
    data->cb = cb;
    pjsip_endpt_resolve(g_zsip_app.endpt->endpt, data->pool, &dest, data, resolver_callback);

    return PJ_SUCCESS;
}
#endif

static z_status_t zsip_endpt_resolve(zsip_endptc *endptc)
{
    pj_status_t status;

    pj_str_t nameserver;
    int nameport;
    pj_dns_resolver *resv;
    status = pjsip_endpt_create_resolver(g_zsip_app.endpt->endpt, &resv);
    if(status!=PJ_SUCCESS)
    {
        err("endpt create resolver", status);
        return status;
    }
    if(endptc->ns_addr)
    {
        nameserver = pj_str((char*)endptc->ns_addr);
        if(endptc->ns_port)
            nameport = endptc->ns_port;
        else
            nameport = 53;
    }
    else
    {
        nameserver = pj_str("8.8.8.8");
        nameport = 53;
    }
    status = pj_dns_resolver_set_ns(resv, 1, &nameserver, (const pj_uint16_t*)&nameport);
    if(status!=PJ_SUCCESS)
    {
        err("resolver set nameserver", status);
        return status;
    }
    status = pjsip_endpt_set_resolver(g_zsip_app.endpt->endpt, resv);
    if(status!=PJ_SUCCESS)
    {
        err("endpt set resolver", status);
        return status;
    }

    return PJ_SUCCESS;
}

z_status_t zsip_update_dns(unsigned count, char* servers[], int ports[])
{
    pj_status_t status;

    pj_dns_resolver *resv = NULL;
    resv = pjsip_endpt_get_resolver(g_zsip_app.endpt->endpt);

    int i;
    pj_str_t nameserver[PJ_DNS_RESOLVER_MAX_NS];
    pj_uint16_t nameport[PJ_DNS_RESOLVER_MAX_NS];
    for(i=0; i<count; i++)
    {
        nameserver[i] = pj_str(servers[i]);
        nameport[i] = ports[i];
    }


    status = pj_dns_resolver_set_ns(resv, count, nameserver, nameport);
    if(status!=PJ_SUCCESS)
    {
        err("resolver update nameserver", status);
        return status;
    }
    return Z_SUCCESS;
}



//add route set to msg->tdata
static void zsip_set_route_set(pjsip_tx_data *tdata, const char* dest_addr, int dest_port)
{
    pjsip_hdr *route_pos;
	const pjsip_route_hdr *route;
    if(dest_addr==NULL && dest_port==0)
    {
        //default route set
        route_pos = (pjsip_hdr*)
		pjsip_msg_find_hdr(tdata->msg, PJSIP_H_VIA, NULL);
    	if (!route_pos)
    		route_pos = &tdata->msg->hdr;

    	route = g_zsip_app.route_set.next;
    	while (route != &g_zsip_app.route_set)
        {
    		pjsip_hdr *new_hdr = (pjsip_hdr*)
    			pjsip_hdr_shallow_clone(tdata->pool, route);
    		pj_list_insert_after(route_pos, new_hdr);
    		route_pos = new_hdr;
    		route = route->next;
    	}
    }
	else
	{
        route_pos = (pjsip_hdr*)
		pjsip_msg_find_hdr(tdata->msg, PJSIP_H_VIA, NULL);
    	if (!route_pos)
    		route_pos = &tdata->msg->hdr;

        const pj_str_t hname = { "Route", 5 };
        char *route_uri = (char *)pj_pool_zalloc(tdata->pool, 80);
        if(g_zsip_app.tp_type == ZSIP_TRANSPORT_TCP)
    	   sprintf(route_uri, "<sip:%s:%d;lr;transport=tcp;hide>", dest_addr, dest_port); //uri = "sip:192.168.1.13;lr;hide";
        else
            sprintf(route_uri, "<sip:%s:%d;lr;transport=udp;hide>", dest_addr, dest_port);//uri = "sip:192.168.1.13;lr;transport=tcp;hide";

    	route = (pjsip_route_hdr*)pjsip_parse_hdr(tdata->pool, &hname, route_uri, strlen(route_uri), NULL);
    	pj_list_insert_after(route_pos, (pjsip_hdr*)route);
	}


}

static void regc_cb(struct pjsip_regc_cbparam *param)
{
    regc_cb_data* data = (regc_cb_data*)param->token;
    if(param->status!=PJ_SUCCESS)
        err("regc callback", param->status);

    //user callback
    if(param->rdata && param->rdata->msg_info.msg && param->rdata->msg_info.msg->body)
    {
        data->cb(param->status, param->code,
            param->rdata->msg_info.msg->body->data, param->rdata->msg_info.msg->body->len,
            data->user_data);
    }
    else
    {
        data->cb(param->status, param->code,
            NULL, 0,
            data->user_data);
    }

    //finish regc
    pjsip_regc_destroy(param->regc);
    z_pool_release(data->pool);

    /*if reg failed, create new transport*/
    pj_status_t status;
    pjsip_transport *tp;
    pjsip_transport_type_e tp_type;
    tp_type = (pjsip_transport_type_e)g_zsip_app.tp_type;
    if(param->code/100!=2 && tp_type==PJSIP_TRANSPORT_TCP)
    {
        //gracefully shut down
        if((g_zsip_app.endpt)->sel.u.transport)
        {
            pjsip_transport_shutdown((g_zsip_app.endpt)->sel.u.transport);

            //dec ref
            if((g_zsip_app.endpt)->sel.u.transport)
            {
                pjsip_transport_dec_ref((g_zsip_app.endpt)->sel.u.transport);
                (g_zsip_app.endpt)->sel.u.transport = NULL;
            }
        }


        if (g_zsip_app.inet_type == pj_AF_INET())
        {
            status = pjsip_endpt_acquire_transport((g_zsip_app.endpt)->endpt,
        						  tp_type,
        						  &g_zsip_app.srv_addr,
        						  sizeof(g_zsip_app.srv_addr.ipv4),
        						  NULL,
        						  &tp);
        }
        else
        {
            status = pjsip_endpt_acquire_transport((g_zsip_app.endpt)->endpt,
        						  tp_type,
        						  &g_zsip_app.srv_addr,
        						  sizeof(g_zsip_app.srv_addr.ipv6),
        						  NULL,
        						  &tp);
        }
        if(status == PJ_SUCCESS)
        {

            (g_zsip_app.endpt)->sel.type = PJSIP_TPSELECTOR_TRANSPORT;
            (g_zsip_app.endpt)->sel.u.transport = tp;
        }
    }
}


z_status_t zsip_reg(zsip_regc *regc, zsip_regc_cb *cb)
{
    z_status_t status;

    pjsip_transport_type_e tp_type;
    tp_type = (pjsip_transport_type_e)g_zsip_app.tp_type;


    //get sip uri
    char reg_uri_buffer[MAX_SESSION_LEN], from_uri_buffer[MAX_SESSION_LEN], to_uri_buffer[MAX_SESSION_LEN];
    pj_str_t reg_uri, from_uri, to_uri;
    memset(reg_uri_buffer, 0, sizeof(reg_uri_buffer));
    memset(from_uri_buffer, 0, sizeof(from_uri_buffer));
    memset(to_uri_buffer, 0, sizeof(to_uri_buffer));

    if(tp_type == PJSIP_TRANSPORT_TCP)
    {
        sprintf(reg_uri_buffer, "<sip:%s;transport=tcp>", regc->callee);
        sprintf(from_uri_buffer, "<sip:%s;transport=tcp>", regc->caller);
        sprintf(to_uri_buffer, "<sip:%s;transport=tcp>", regc->callee);
        //sprintf(reg_uri_buffer, "<sip:%s;transport=tcp>", regc->srvaddr);
        //sprintf(uri_buffer, "<sip:%s@%s;transport=tcp>", regc->user, regc->srvaddr);
    }
    else
    {
        sprintf(reg_uri_buffer, "<sip:%s;transport=udp>", regc->callee);
        sprintf(from_uri_buffer, "<sip:%s;transport=udp>", regc->caller);
        sprintf(to_uri_buffer, "<sip:%s;transport=udp>", regc->callee);
        //sprintf(reg_uri_buffer, "<sip:%s;transport=udp>", regc->srvaddr);
        //sprintf(uri_buffer, "<sip:%s@%s;transport=udp>", regc->user, regc->srvaddr);
    }

    reg_uri=pj_str(reg_uri_buffer);
    from_uri=pj_str(from_uri_buffer);
    to_uri=pj_str(to_uri_buffer);

    //get contacts
    char default_contact_buffer[MAX_SESSION_LEN];
    pj_sockaddr_print(&g_zsip_app.default_addr, default_contact_buffer, sizeof(default_contact_buffer), 0);

    pj_str_t contact_str[MAX_CONTACT_CNT];
    char contact_buffer[MAX_CONTACT_CNT][MAX_SESSION_LEN];
    int cnt;
    cnt = regc->contact_cnt>MAX_CONTACT_CNT?MAX_CONTACT_CNT:regc->contact_cnt;
    for(int i=0; i<cnt; i++)
    {
        if(tp_type == ZSIP_TRANSPORT_TCP)
        {
            if(regc->port[i])
            {
                if(regc->contact[i]==NULL)
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s:%d;transport=tcp>",
                        regc->caller, default_contact_buffer, regc->port[i]);
                }
                else
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s:%d;transport=tcp>",
                        regc->caller, regc->contact[i], regc->port[i]);
                }
            }
            else
            {
                if(regc->contact[i]==NULL)
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s;transport=tcp>",
                        regc->caller, default_contact_buffer);
                }
                else
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s;transport=tcp>",
                        regc->caller, regc->contact[i]);
                }
            }
        }
        else /*tp_type == ZSIP_TRANSPORT_UDP*/
        {
            if(regc->port[i])
            {
                if(regc->contact[i]==NULL)
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s:%d;transport=udp>",
                        regc->caller, default_contact_buffer, regc->port[i]);
                }
                else
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s:%d;transport=udp>",
                        regc->caller, default_contact_buffer, regc->port[i]);
                }
            }
            else
            {
                if(regc->contact[i]==NULL)
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s;transport=udp>",
                        regc->caller, default_contact_buffer);
                }
                else
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s;transport=udp>",
                        regc->caller, regc->contact[i]);
                }
            }
        }
        contact_str[i]=pj_str(contact_buffer[i]);
    }

    //create regc
    pjsip_regc *sip_regc;
    z_pool_t *pool;
    regc_cb_data *data;
    pool = z_pool_create(1000, 1000);
    data = (regc_cb_data*)z_pool_alloc(pool, sizeof(regc_cb_data));
    data->pool = pool;
    data->cb = cb;
    data->user_data = regc->user_data;

    status = pjsip_regc_create(g_zsip_app.endpt->endpt, data, regc_cb, &sip_regc);
    if(status!=PJ_SUCCESS)
    {
        err("regc create", status);
        z_pool_release(pool);
        return status;
    }

    //init regc struct
    status = pjsip_regc_init(sip_regc, &reg_uri, &from_uri, &to_uri, cnt,
			     contact_str,  regc->expired? regc->expired:60);
    if(status!=PJ_SUCCESS)
    {
        err("regc create", status);
        pjsip_regc_destroy(sip_regc);
        z_pool_release(pool);
        return status;
    }

    //set transport
    pjsip_regc_set_transport(sip_regc, &g_zsip_app.endpt->sel);

    //set auth
    pjsip_cred_info cred;
	pj_bzero(&cred, sizeof(cred));
	cred.realm = pj_str("*");
	cred.scheme = pj_str("digest");
	cred.username = pj_str((char*)regc->user);
	cred.data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
    cred.data = pj_str((char*)regc->passwd);
	status = pjsip_regc_set_credentials(sip_regc, 1, &cred);
    if(status!=PJ_SUCCESS)
    {
        err("regc set credentials", status);
        pjsip_regc_destroy(sip_regc);
        z_pool_release(pool);
        return status;
    }

    /*add route set*/
    pjsip_regc_set_route_set(sip_regc, &g_zsip_app.route_set);

    //register msg body
    pj_str_t type=pj_str(regc->content_type);
    pj_str_t subtype=pj_str(regc->content_subtype);
    pj_str_t content=pj_str(regc->content);


    /* Register */
    pjsip_tx_data *tdata;
    status = pjsip_regc_register(sip_regc, PJ_FALSE, &tdata);
    if (status != PJ_SUCCESS)
    {
        err("regc set credentials", status);
        pjsip_regc_destroy(sip_regc);
        z_pool_release(pool);
        return status;
    }

    tdata->msg->body = pjsip_msg_body_create(tdata->pool, &type, &subtype, &content);
    status = pjsip_regc_send(sip_regc, tdata);
    if (status != PJ_SUCCESS)
    {
        err("regc send", status);
        //pjsip_regc_destroy(sip_regc);
        z_pool_release(pool);
        return status;
    }


    return PJ_SUCCESS;
}

static void reqc_cb(void *token, pjsip_event *e)
{
    reqc_cb_data* data = (reqc_cb_data*)token;
    pjsip_transaction *tsx = e->body.tsx_state.tsx;
    pjsip_rx_data *rdata;
    pj_status_t status;
    int code;
    void *response;
    int len;

    status = e->body.tsx_state.src.status;
    code = tsx->status_code;
    if(code/100 != 2)
    {
        response = NULL;
        len = 0;
    }
    else
    {
        rdata = e->body.tsx_state.src.rdata;
        if(rdata->msg_info.msg->body)
        {
            response = rdata->msg_info.msg->body->data;
            len = rdata->msg_info.msg->body->len;
        }
        else
        {
            response=NULL;
            len=0;
        }
    }

    //user callback
    data->cb(status, code, response, len, data->user_data);

    //finish reqc
    z_pool_release(data->pool);

    /*if option failed, create new transport*/
    pjsip_transport *tp;
    pjsip_transport_type_e tp_type;
    tp_type = (pjsip_transport_type_e)g_zsip_app.tp_type;
    if(tsx->method.id==PJSIP_OPTIONS_METHOD && code/100!=2 && tp_type==PJSIP_TRANSPORT_TCP)
    {
        //gracefully shut down
        if((g_zsip_app.endpt)->sel.u.transport)
        {
            pjsip_transport_shutdown((g_zsip_app.endpt)->sel.u.transport);

            //dec ref
            if((g_zsip_app.endpt)->sel.u.transport)
            {
                pjsip_transport_dec_ref((g_zsip_app.endpt)->sel.u.transport);
                (g_zsip_app.endpt)->sel.u.transport = NULL;
            }
        }


        if (g_zsip_app.inet_type == pj_AF_INET())
        {
            status = pjsip_endpt_acquire_transport((g_zsip_app.endpt)->endpt,
        						  tp_type,
        						  &g_zsip_app.srv_addr,
        						  sizeof(g_zsip_app.srv_addr.ipv4),
        						  NULL,
        						  &tp);
        }
        else
        {
            status = pjsip_endpt_acquire_transport((g_zsip_app.endpt)->endpt,
        						  tp_type,
        						  &g_zsip_app.srv_addr,
        						  sizeof(g_zsip_app.srv_addr.ipv6),
        						  NULL,
        						  &tp);
        }
        if(status == PJ_SUCCESS)
        {

            (g_zsip_app.endpt)->sel.type = PJSIP_TPSELECTOR_TRANSPORT;
            (g_zsip_app.endpt)->sel.u.transport = tp;
        }
    }
}

z_status_t zsip_req(zsip_request *reqc, zsip_reqc_cb *cb, const char* dest_addr, int dest_port)
{
    z_status_t status;

    //get tp_type
    pjsip_transport_type_e tp_type;
    tp_type = (pjsip_transport_type_e)g_zsip_app.tp_type;

    //get sip uri
    char target_uri_buffer[MAX_SESSION_LEN], from_uri_buffer[MAX_SESSION_LEN], to_uri_buffer[MAX_SESSION_LEN];
    pj_str_t target_uri, from_uri, to_uri;

    if(tp_type == PJSIP_TRANSPORT_TCP)
    {
        sprintf(target_uri_buffer, "<sip:%s;transport=tcp>", reqc->callee);
        sprintf(from_uri_buffer, "<sip:%s;transport=tcp>", reqc->caller);
        sprintf(to_uri_buffer, "<sip:%s;transport=tcp>", reqc->callee);
    }
    else
    {
        sprintf(target_uri_buffer, "<sip:%s;transport=udp>", reqc->callee);
        sprintf(from_uri_buffer, "<sip:%s;transport=udp>", reqc->caller);
        sprintf(to_uri_buffer, "<sip:%s;transport=udp>", reqc->callee);
    }


    target_uri = pj_str(target_uri_buffer);
    from_uri = pj_str(from_uri_buffer);
    to_uri = pj_str(to_uri_buffer);

    //get contacts
    char default_contact_buffer[MAX_SESSION_LEN];
    pj_sockaddr_print(&g_zsip_app.default_addr, default_contact_buffer, sizeof(default_contact_buffer), 0);

    pj_str_t contact_str[MAX_CONTACT_CNT];
    char contact_buffer[MAX_CONTACT_CNT][MAX_SESSION_LEN];
    int cnt;
    cnt = reqc->contact_cnt>MAX_CONTACT_CNT?MAX_CONTACT_CNT:reqc->contact_cnt;
    for(int i=0; i<cnt; i++)
    {
        if(tp_type == ZSIP_TRANSPORT_TCP)
        {
            if(reqc->port[i])
            {
                if(reqc->contact[i]==NULL)
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s:%d;transport=tcp>",
                        reqc->caller, default_contact_buffer, reqc->port[i]);
                }
                else
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s:%d;transport=tcp>",
                        reqc->caller, reqc->contact[i], reqc->port[i]);
                }
            }
            else
            {
                if(reqc->contact[i]==NULL)
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s;transport=tcp>",
                        reqc->caller, default_contact_buffer);
                }
                else
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s;transport=tcp>",
                        reqc->caller, reqc->contact[i]);
                }
            }
        }
        else /*tp_type == ZSIP_TRANSPORT_UDP*/
        {
            if(reqc->port[i])
            {
                if(reqc->contact[i]==NULL)
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s:%d;transport=udp>",
                        reqc->caller, default_contact_buffer, reqc->port[i]);
                }
                else
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s:%d;transport=udp>",
                        reqc->caller, reqc->contact[i], reqc->port[i]);
                }
            }
            else
            {
                if(reqc->contact[i]==NULL)
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s;transport=udp>",
                        reqc->caller, default_contact_buffer);
                }
                else
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s;transport=udp>",
                        reqc->caller, reqc->contact[i]);
                }
            }
        }
        contact_str[i]=pj_str(contact_buffer[i]);
    }


    // create request tdata
    pjsip_method method;
    method.id = (pjsip_method_e)reqc->method.id;
    method.name = pj_str(reqc->method.name);
    pjsip_tx_data *tdata;
    status = pjsip_endpt_create_request(g_zsip_app.endpt->endpt, &method,
					&target_uri, &from_uri,
					&to_uri, contact_str,
					NULL, -1, NULL, &tdata);
    if(status!=PJ_SUCCESS)
    {
        err("request create", status);
        return status;
    }

    //add msg body to tdata
    pj_str_t type=pj_str(reqc->content_type);
    pj_str_t subtype=pj_str(reqc->content_subtype);
    pj_str_t content=pj_str(reqc->content);
    tdata->msg->body = pjsip_msg_body_create(tdata->pool, &type,
		&subtype,
		&content);


    //set transport
    pjsip_tx_data_set_transport(tdata, &g_zsip_app.endpt->sel);

    //internal user_data
    z_pool_t *pool;
    reqc_cb_data *data;
    pool = z_pool_create(1000, 1000);
    data = (reqc_cb_data*)z_pool_alloc(pool, sizeof(reqc_cb_data));
    data->pool = pool;
    data->cb = cb;
    data->user_data = reqc->user_data;

    //set route_set
    zsip_set_route_set(tdata, dest_addr, dest_port);

    //send request
    status = pjsip_endpt_send_request(g_zsip_app.endpt->endpt,
        tdata, -1, data, reqc_cb);
    if (status != PJ_SUCCESS)
    {
        err("request send", status);
        z_pool_release(data->pool);
        return status;
    }



    return PJ_SUCCESS;
}

z_status_t zsip_endpt_respond_msg(void* handler, int ret_code, char* ret_text,
    char*type, char*subtype, char* data)
{
    pj_status_t status;

    msg_handle_st* msg_handle=(msg_handle_st*)handler;
    const pj_str_t ret_text_str=pj_str(ret_text);
    const pj_str_t type_str=pj_str(type);
    const pj_str_t subtype_str=pj_str(subtype);
    const pj_str_t data_str=pj_str(data);

    //update response msg in tdata
    msg_handle->tdata->msg->line.status.code = ret_code;
    if (ret_text)
    {
        pj_strdup(msg_handle->tdata->pool, &msg_handle->tdata->msg->line.status.reason, &ret_text_str);
    }

    /* Add the message body, if any. */
    if (data)
    {
        msg_handle->tdata->msg->body = pjsip_msg_body_create(msg_handle->tdata->pool, &type_str, &subtype_str, &data_str);
	    if (msg_handle->tdata->msg->body == NULL)
        {
	        pjsip_tx_data_dec_ref(msg_handle->tdata);
            z_pool_release(msg_handle->pool);
	        return status;
	    }
    }

    //change to statefully respond
    status = pjsip_tsx_send_msg(msg_handle->tsx, msg_handle->tdata);
    if (status != PJ_SUCCESS)
    {
    	pjsip_tx_data_dec_ref(msg_handle->tdata);
        z_pool_release(msg_handle->pool);
    	return status;
    }
    z_pool_release(msg_handle->pool);
    return PJ_SUCCESS;
}


z_status_t zsip_start_stun(zsip_ice *ice)
{
    pj_ice_strans_cb icecb;
    pj_status_t status;

    //internal user_data
    z_pool_t *pool;
    ice_cb_data *data;
    pool = z_pool_create(1000, 1000);
    data = (ice_cb_data*)z_pool_alloc(pool, sizeof(ice_cb_data));
    data->pool = pool;
    data->stun_cb = ice->stun_cb;
    data->neg_cb = ice->neg_cb;
    data->role = ice->role;
    data->user_data = ice->user_data;

    /* init the callback */
    pj_bzero(&icecb, sizeof(icecb));
    icecb.on_rx_data = cb_on_rx_data;
    icecb.on_ice_complete = cb_on_ice_complete;

    /* create the instance */
    status = pj_ice_strans_create("ice",            /* object name  */
                &g_zsip_app.ice_cfg,        /* settings     */
                1,      /* comp_cnt     */
                data,        /* user data    */
                &icecb,             /* callback     */
                &ice->icest)           /* instance ptr */
                ;
    if (status != PJ_SUCCESS)
    {
        err("pj_ice_strans_create", status);
        z_pool_release(pool);
        return status;
    }


    return PJ_SUCCESS;
}

z_status_t zsip_start_neg(z_ice_strans *icest, char* rem_sdp)
{
    pj_str_t rufrag, rpwd;
    pj_status_t status;
    pj_bool_t ret;

    sdp_info rem_info;
    ret = decode_sdp(rem_sdp, &rem_info);
    if(ret != PJ_TRUE)
    {
        PJ_LOG(3,("zsip_start_neg", "Error: decode sdp error"));
    	return 20000;
    }

    if (icest == NULL)
    {
    	PJ_LOG(3,("zsip_start_neg", "Error: No ICE instance, create it first"));
    	return 20001;
    }

    if (!pj_ice_strans_has_sess(icest))
    {
    	PJ_LOG(3,("zsip_start_neg", "Error: No ICE session, initialize first"));
    	return 20002;
    }

    if (rem_info.cand_cnt == 0)
    {
    	PJ_LOG(3,("zsip_start_neg", "Error: No remote info, input remote info first"));
    	return 20003;
    }


    status = pj_ice_strans_start_ice(icest,
				     pj_cstr(&rufrag, rem_info.ufrag),
				     pj_cstr(&rpwd, rem_info.pwd),
				     rem_info.cand_cnt,
				     rem_info.cand);
    if (status != PJ_SUCCESS)
    {
        err("pj_ice_strans_start_ice", status);
        return status;
    }
    return PJ_SUCCESS;
}


static z_status_t zsip_start_neg2(z_ice_strans *icest, char* rem_sdp, sdp_info* rem_info)
{
    pj_str_t rufrag, rpwd;
    pj_status_t status;
    pj_bool_t ret;

    ret = decode_sdp(rem_sdp, rem_info);
    if(ret != PJ_TRUE)
    {
        PJ_LOG(3,("zsip_start_neg", "Error: decode sdp error"));
    	return 20000;
    }

    if (icest == NULL)
    {
    	PJ_LOG(3,("zsip_start_neg", "Error: No ICE instance, create it first"));
    	return 20001;
    }

    if (!pj_ice_strans_has_sess(icest))
    {
    	PJ_LOG(3,("zsip_start_neg", "Error: No ICE session, initialize first"));
    	return 20002;
    }

    if (rem_info->cand_cnt == 0)
    {
    	PJ_LOG(3,("zsip_start_neg", "Error: No remote info, input remote info first"));
    	return 20003;
    }


    status = pj_ice_strans_start_ice(icest,
				     pj_cstr(&rufrag, rem_info->ufrag),
				     pj_cstr(&rpwd, rem_info->pwd),
				     rem_info->cand_cnt,
				     rem_info->cand);
    if (status != PJ_SUCCESS)
    {
        err("pj_ice_strans_start_ice", status);
        return status;
    }
    return PJ_SUCCESS;
}


typedef struct timer_data
{
    z_pool_t* pool;
    pj_timer_entry entry;
    z_timer_heap_callback* user_timer_cb;
    void* user_data;
}timer_data;

static void timer_heap_callback(pj_timer_heap_t *timer_heap, struct pj_timer_entry *entry)
{
    timer_data* data = (timer_data*)entry->user_data;
    data->user_timer_cb(entry->id, data->user_data);
    z_pool_release(data->pool);
}

z_status_t zsip_endpt_schedule_timer(int id, z_time_val* delay, z_timer_heap_callback* cb, void* user_data)
{
    pj_status_t status;

    if(id == TIMER_KEEP_ALIVE)
    {
        PJ_LOG(3,("zsip_endpt_schedule_timer", "timer id canot be %d which is a internal id", id));
        return id;
    }

    //internal user_data
    z_pool_t *pool;
    timer_data *data;
    pool = z_pool_create(1000, 1000);
    data = (timer_data*)z_pool_alloc(pool, sizeof(timer_data));
    data->pool = pool;
    pj_timer_entry_init(&data->entry, id, data, timer_heap_callback);
    data->user_timer_cb = cb;
    data->user_data = user_data;

    status = pjsip_endpt_schedule_timer(g_zsip_app.endpt->endpt, &data->entry, (pj_time_val*)delay);
    if (status != PJ_SUCCESS)
    {
        err("pjsip_endpt_schedule_timer", status);
        z_pool_release(pool);
        return status;
    }
    return PJ_SUCCESS;
}

static void send_raw_callback(void *token, pjsip_tx_data *tdata, pj_ssize_t bytes_sent)
{
    if(bytes_sent<0)
    {
        PJ_LOG(3,("send_raw_callback", "send ka failed:status(%d)", -bytes_sent));
    }
}


static pj_status_t zsip_keep_alive()
{
    pj_status_t status;

    //ka data
    char ka_data[]={'\r', '\n', '\r', '\n'};

    //get tp_type
    pjsip_transport_type_e tp_type;
    tp_type = (pjsip_transport_type_e)g_zsip_app.tp_type;

    //get sip uri
    char srv_uri_buffer[MAX_SESSION_LEN];
    char addr_buff[MAX_SESSION_LEN];
    pj_str_t srv_uri;

    pj_sockaddr_print(&g_zsip_app.srv_addr, addr_buff, sizeof(addr_buff), 1);

    if(tp_type == PJSIP_TRANSPORT_TCP)
    {
        sprintf(srv_uri_buffer, "<sip:%s;transport=tcp>", addr_buff);
    }
    else
    {
        sprintf(srv_uri_buffer, "<sip:%s;transport=udp>", addr_buff);
    }
    srv_uri = pj_str(srv_uri_buffer);

    //send raw data
    status = pjsip_endpt_send_raw_to_uri(g_zsip_app.endpt->endpt, &srv_uri, &g_zsip_app.endpt->sel,
						ka_data, sizeof(ka_data), NULL, send_raw_callback);
    if(status != PJ_SUCCESS)
    {
        err("pjsip_endpt_send_raw_to_uri", status);
    }
    return status;
}

static void keep_alive_cb(pj_timer_heap_t *timer_heap, struct pj_timer_entry *entry)
{
    zsip_keep_alive();

    //schedule next keep alive
    pjsip_endpt_schedule_timer(g_zsip_app.endpt->endpt, entry, &g_zsip_app.ka_tv);
}

z_status_t zsip_start_ka(int sec)
{
    z_status_t status;

    pj_timer_entry_init(&g_zsip_app.ka_entry, TIMER_KEEP_ALIVE, NULL, keep_alive_cb);

    g_zsip_app.ka_tv.sec = sec;
    g_zsip_app.ka_tv.msec = 0;

    status = pjsip_endpt_schedule_timer(g_zsip_app.endpt->endpt, &g_zsip_app.ka_entry, &g_zsip_app.ka_tv);
    return status;
}


typedef struct zsip_p2p_request_data
{
    void *user_data;
    char content_type[MAX_TYPE_LEN];
    char content_subtype[MAX_TYPE_LEN];
    char *param;
}zsip_p2p_request_data;

typedef struct zsip_p2p_response_data
{
    void *user_data;
    char content_type[MAX_TYPE_LEN];
    char content_subtype[MAX_TYPE_LEN];
    char *param;
}zsip_p2p_response_data;


typedef struct p2p_data
{
    z_pool_t *pool;
    z_ice_strans *icest;
    zsip_p2p_request_data reqc;
    zsip_p2p_cb* cb;
    pjsip_tx_data *tdata;//for req
    msg_handle_st* handle;//for response
    zsip_p2p_response_data response;
    int role;

    zsip_addr_pair addr_pair[PJ_ICE_MAX_COMP];
    int pair_cnt;
}p2p_data;

static void get_pair(pj_ice_strans *icest)
{
    unsigned int c = PJ_ICE_ST_MAX_CAND;
    p2p_data* data = (p2p_data*)pj_ice_strans_get_user_data(icest);
    memset(data->addr_pair, 0, sizeof(p2p_data)-((char*)data->addr_pair-(char*)data));
    if(pj_ice_strans_has_sess(icest) == PJ_FALSE)
        return;
    int comp_cnt = pj_ice_strans_get_running_comp_cnt(icest);
    pj_ice_sess_cand cand[PJ_ICE_ST_MAX_CAND];
    memset(data->addr_pair, 0, sizeof(p2p_data)-((char*)data->addr_pair-(char*)data));
    for(int i=0; i<comp_cnt; i++)
    {
        pj_ice_strans_enum_cands(icest, i+1, &c, cand);
        if(c==0)
            return;

        for(int j=0; j<c; j++)
        {
            switch(cand[j].type)
            {
                case PJ_ICE_CAND_TYPE_HOST:
                    pj_sockaddr_print(&cand[j].base_addr, data->addr_pair[data->pair_cnt].base_addr, ZSIP_MAX_ADDR_LEN, 0);
                    data->addr_pair[data->pair_cnt].base_port= pj_sockaddr_get_port(&cand[j].base_addr);
                    break;
                case PJ_ICE_CAND_TYPE_SRFLX:
                    pj_sockaddr_print(&cand[j].addr, data->addr_pair[data->pair_cnt].l_addr, ZSIP_MAX_ADDR_LEN, 0);
                    data->addr_pair[data->pair_cnt].l_port= pj_sockaddr_get_port(&cand[j].addr);
                    break;
                default:
                    break;
            }
        }
        data->pair_cnt++;
    }
}


static void p2p_req_cb(void *token, pjsip_event *e)
{
    p2p_data* data = (p2p_data*)token;
    pjsip_transaction *tsx = e->body.tsx_state.tsx;
    pjsip_rx_data *rdata;
    pj_status_t status;
    int code;
    void *response;
    int len;

    status = e->body.tsx_state.src.status;
    code = tsx->status_code;
    if(code/100 != 2)
    {
        get_pair(data->icest);
        data->cb(code, NULL, data->reqc.param, data->addr_pair, data->pair_cnt, data->reqc.user_data);
        pj_ice_strans_destroy(data->icest);
        z_pool_release(data->pool);
    }
    else
    {
        rdata = e->body.tsx_state.src.rdata;
        if(rdata->msg_info.msg->body)
            response = rdata->msg_info.msg->body->data;
        else
            response = NULL;
        if(response)
        {
            char param[MAX_PARAM_LEN];
            if(get_param((char*)response, param) == Z_FALSE)
            {
                data->reqc.param = NULL;
            }
            else
                strcpy(data->reqc.param, param);
        }
        else
        {
            data->reqc.param = NULL;
        }
        status = zsip_start_neg(data->icest, (char*)response);
        if (status != PJ_SUCCESS)
        {
            pj_ice_strans_destroy(data->icest);
            data->cb(P2P_CALLER_START_NEGO_FAILED, NULL, NULL, NULL, 0, data->reqc.user_data);
            z_pool_release(data->pool);
            return;
        }
    }

}


/*
 * This is the callback that is registered to the ICE stream transport to
 * receive notification about ICE state progression.
 */
static void cb_on_p2p_complete(pj_ice_strans *icest,
                   pj_ice_strans_op op,
                   pj_status_t status)
{
    #if 0
    pj_time_val t;
    #endif

    p2p_data* data = (p2p_data*)pj_ice_strans_get_user_data(icest);
    if (status == PJ_SUCCESS)
    {
        if(op == PJ_ICE_STRANS_OP_INIT)
        {
            /* create session */
            status = pj_ice_strans_init_ice(icest, (pj_ice_sess_role)data->role, NULL, NULL);
            #if 0
            pj_gettimeofday(&t);
            printf("zsip:%u|%s|start nego\n", t.sec*1000+t.msec/1000, (char*)data->response.user_data);
            #endif
            if(data->role==Z_ICE_SESS_ROLE_CONTROLLING)
            {
                /*caller side*/
                if (status != PJ_SUCCESS)
                {
                    get_pair(icest);
                    pj_ice_strans_destroy(icest);
                    err("pj_ice_strans_init_ice", status);
                    data->cb(P2P_CALLER_INIT_ICE_FAILED, NULL, NULL, data->addr_pair, data->pair_cnt, data->reqc.user_data);
                    pjsip_tx_data_dec_ref(data->tdata);
                    z_pool_release(data->pool);
                    return;
                }
                else
                {
                    //add msg body to tdata
                    char buffer[MAX_P2P_CONTENT_LEN];
                    pj_str_t type=pj_str(data->reqc.content_type);
                    pj_str_t subtype=pj_str(data->reqc.content_subtype);
                    encode_sdp(icest, data->reqc.param, buffer, MAX_P2P_CONTENT_LEN);
                    pj_str_t content=pj_str(buffer);
                    data->tdata->msg->body = pjsip_msg_body_create(data->tdata->pool, &type,
                        &subtype,
                        &content);

                    //set transport
                    pjsip_tx_data_set_transport(data->tdata, &g_zsip_app.endpt->sel);

                    //set route_set
                    zsip_set_route_set(data->tdata);

                    //send request
                    status = pjsip_endpt_send_request(g_zsip_app.endpt->endpt,
                        data->tdata, -1, data, p2p_req_cb);
                    if (status != PJ_SUCCESS)
                    {
                        get_pair(icest);
                        pj_ice_strans_destroy(icest);
                        err("pjsip_endpt_send_request", status);
                        data->cb(P2P_SEND_REQ_FAILED, NULL, NULL, data->addr_pair, data->pair_cnt, data->reqc.user_data);
                        pjsip_tx_data_dec_ref(data->tdata);
                        z_pool_release(data->pool);
                    }
                    return;
                }
            }
            else
            {
                /*callee side*/
                if (status != PJ_SUCCESS)
                {
                    #if 0
                    pj_gettimeofday(&t);
                    printf("zsip:%u|%s|end nego 1\n", t.sec*1000+t.msec/1000, (char*)data->response.user_data);
                    #endif
                    get_pair(icest);
                    pj_ice_strans_destroy(icest);
                    err("pj_ice_strans_init_ice", status);
                    data->cb(P2P_CALLEE_INIT_ICE_FAILED, NULL, NULL, data->addr_pair, data->pair_cnt, data->response.user_data);
                    zsip_endpt_respond_msg(data->handle, P2P_CALLEE_INIT_ICE_FAILED, NULL, "application", "sdp", NULL);
                    z_pool_release(data->pool);
                    return;
                }
                else
                {
                    //start negotiation with remote sdp
                    sdp_info rem_info;
                    status = zsip_start_neg2(icest, (char*)data->handle->remote_sdp, &rem_info);
                    if (status != PJ_SUCCESS)
                    {
                        #if 0
                        pj_gettimeofday(&t);
                        printf("zsip:%u|%s|end nego 2\n", t.sec*1000+t.msec/1000, (char*)data->response.user_data);
                        #endif
                        get_pair(icest);
                        pj_ice_strans_destroy(icest);
                        data->cb(P2P_CALLEE_START_NEGO_FAILED, NULL, NULL, data->addr_pair, data->pair_cnt, data->response.user_data);
                        zsip_endpt_respond_msg(data->handle, P2P_CALLEE_START_NEGO_FAILED, NULL, "application", "sdp", NULL);
                        z_pool_release(data->pool);
                        return;
                    }
                    //send response with callee's sdp string
                    char buffer[1000];
                    encode_sdp(icest, data->response.param, buffer, sizeof(buffer));
                    zsip_endpt_respond_msg(data->handle, 200, NULL, "application", "sdp", buffer);
                    return;
                }
            }
        }
        else if(op == PJ_ICE_STRANS_OP_NEGOTIATION)
        {
            const pj_ice_sess_check *c;
            int comp_cnt = pj_ice_strans_get_running_comp_cnt(icest);
            data->pair_cnt = 0;
            for(int i=0; i<comp_cnt; i++)
            {
                c = pj_ice_strans_get_valid_pair(icest, i+1);
                if(c==NULL)
                    continue;
                pj_sockaddr_print(&c->lcand->base_addr, data->addr_pair[data->pair_cnt].base_addr, ZSIP_MAX_ADDR_LEN, 0);
                data->addr_pair[data->pair_cnt].base_port= pj_sockaddr_get_port(&c->lcand->base_addr);
                pj_sockaddr_print(&c->lcand->addr, data->addr_pair[data->pair_cnt].l_addr, ZSIP_MAX_ADDR_LEN, 0);
                data->addr_pair[data->pair_cnt].l_port= pj_sockaddr_get_port(&c->lcand->addr);
                pj_sockaddr_print(&c->rcand->addr, data->addr_pair[data->pair_cnt].r_addr, ZSIP_MAX_ADDR_LEN, 0);
                data->addr_pair[data->pair_cnt].r_port = pj_sockaddr_get_port(&c->rcand->addr);
                data->pair_cnt++;
            }
            if(data->role==Z_ICE_SESS_ROLE_CONTROLLING)
            {
                /*caller side*/
                pj_ice_strans_destroy(icest);
                data->cb(200, icest, data->reqc.param, data->addr_pair, data->pair_cnt, data->reqc.user_data);
                z_pool_release(data->pool);
                return;
            }
            else
            {
                /*callee side*/
                #if 0
                pj_gettimeofday(&t);
                printf("zsip:%u|%s|end nego 3\n", t.sec*1000+t.msec/1000, (char*)data->response.user_data);
                #endif
                pj_ice_strans_destroy(icest);
                data->cb(200, icest, NULL, data->addr_pair, data->pair_cnt, data->response.user_data);
                z_pool_release(data->pool);
                return;
            }
        }
        else
        {
            //what is this?
            printf("unexpected way 1\n");
        }
    }
    else
    {
        if(op == PJ_ICE_STRANS_OP_INIT)
        {
            if(data->role==Z_ICE_SESS_ROLE_CONTROLLING)
            {
                /*caller side*/
                get_pair(icest);
                pj_ice_strans_destroy(icest);
                err("pj_ice_strans_stun_cb", status);
                data->cb(P2P_CALLER_STUN_CB_FAILED, NULL, NULL, data->addr_pair, data->pair_cnt, data->reqc.user_data);
                pjsip_tx_data_dec_ref(data->tdata);
                z_pool_release(data->pool);
                return;
            }
            else
            {
                /*callee side*/
                #if 0
                pj_gettimeofday(&t);
                printf("zsip:%u|%s|end nego 4\n", t.sec*1000+t.msec/1000, (char*)data->response.user_data);
                #endif
                get_pair(icest);
                pj_ice_strans_destroy(icest);
                err("pj_ice_strans_stun_cb", status);
                data->cb(P2P_CALLEE_STUN_CB_FAILED, NULL, NULL, data->addr_pair, data->pair_cnt, data->response.user_data);
                zsip_endpt_respond_msg(data->handle, P2P_CALLEE_STUN_CB_FAILED, NULL, "application", "sdp", NULL);
                z_pool_release(data->pool);
                return;
            }
        }
        else if(op == PJ_ICE_STRANS_OP_NEGOTIATION)
        {
            if(data->role==Z_ICE_SESS_ROLE_CONTROLLING)
            {
                /*caller side*/
                get_pair(icest);
                pj_ice_strans_destroy(icest);
                err("pj_ice_strans_nego_cb", status);
                data->cb(P2P_CALLER_NEGO_CB_FAILED, NULL, NULL, data->addr_pair, data->pair_cnt, data->reqc.user_data);
                z_pool_release(data->pool);
                return;
            }
            else
            {
                /*callee side*/
                #if 0
                pj_gettimeofday(&t);
                printf("zsip:%u|%s|end nego 5\n", t.sec*1000+t.msec/1000, (char*)data->response.user_data);
                #endif
                get_pair(icest);
                pj_ice_strans_destroy(icest);
                err("pj_ice_strans_nego_cb", status);
                data->cb(P2P_CALLEE_NEGO_CB_FAILED, NULL, NULL, data->addr_pair, data->pair_cnt, data->response.user_data);
                z_pool_release(data->pool);
                return;
            }
        }
        else
        {
            pj_ice_strans_destroy(icest);
            err("Unkown PROGRESS", status);
            printf("unexpected way 2\n");
            z_pool_release(data->pool);
        }
    }
}


static z_status_t zsip_p2p_stun(p2p_data *data)
{
    pj_ice_strans_cb icecb;
    pj_status_t status;

    /* init the callback */
    pj_bzero(&icecb, sizeof(icecb));
    icecb.on_rx_data = cb_on_rx_data;
    icecb.on_ice_complete = cb_on_p2p_complete;

    /* create the instance */
    status = pj_ice_strans_create("ice",            /* object name  */
                &g_zsip_app.ice_cfg,        /* settings     */
                1,      /* comp_cnt     */
                data,        /* user data    */
                &icecb,             /* callback     */
                &data->icest)           /* instance ptr */
                ;
    if (status != PJ_SUCCESS)
    {
        err("pj_ice_strans_create", status);
        return status;
    }

    return PJ_SUCCESS;
}


z_status_t zsip_p2p_req(zsip_p2p_request *reqc, zsip_p2p_cb *cb)
{
    z_status_t status;

    //get tp_type
    pjsip_transport_type_e tp_type;
    tp_type = (pjsip_transport_type_e)g_zsip_app.tp_type;


    //get sip uri
    char target_uri_buffer[MAX_SESSION_LEN], from_uri_buffer[MAX_SESSION_LEN], to_uri_buffer[MAX_SESSION_LEN];
    pj_str_t target_uri, from_uri, to_uri;

    if(tp_type == PJSIP_TRANSPORT_TCP)
    {
        sprintf(target_uri_buffer, "<sip:%s;transport=tcp>", reqc->callee);
        sprintf(from_uri_buffer, "<sip:%s;transport=tcp>", reqc->caller);
        sprintf(to_uri_buffer, "<sip:%s;transport=tcp>", reqc->callee);
    }
    else
    {
        sprintf(target_uri_buffer, "<sip:%s;transport=udp>", reqc->callee);
        sprintf(from_uri_buffer, "<sip:%s;transport=udp>", reqc->caller);
        sprintf(to_uri_buffer, "<sip:%s;transport=udp>", reqc->callee);
    }
    #if 0
    if(reqc->remoteport==0)
    {
        if(tp_type == PJSIP_TRANSPORT_TCP)
        {
            sprintf(target_uri_buffer, "<sip:%s;transport=tcp>", reqc->callee);
            sprintf(from_uri_buffer, "<sip:%s;transport=tcp>", reqc->caller);
            sprintf(to_uri_buffer, "<sip:%s;transport=tcp>", reqc->callee);
            //sprintf(target_uri_buffer, "<sip:%s@%s;transport=tcp>", reqc->callee, reqc->remoteaddr);
            //sprintf(from_uri_buffer, "<sip:%s@%s;transport=tcp>", reqc->caller, reqc->remoteaddr);
            //sprintf(to_uri_buffer, "<sip:%s@%s;transport=tcp>", reqc->callee, reqc->remoteaddr);
        }
        else
        {
            sprintf(target_uri_buffer, "<sip:%s;transport=udp>", reqc->callee);
            sprintf(from_uri_buffer, "<sip:%s;transport=udp>", reqc->caller);
            sprintf(to_uri_buffer, "<sip:%s;transport=udp>", reqc->callee);
            //sprintf(target_uri_buffer, "<sip:%s@%s;transport=udp>", reqc->callee, reqc->remoteaddr);
            //sprintf(from_uri_buffer, "<sip:%s@%s;transport=udp>", reqc->caller, reqc->remoteaddr);
            //sprintf(to_uri_buffer, "<sip:%s@%s;transport=udp>", reqc->callee, reqc->remoteaddr);
        }

    }
    else
    {
        if(tp_type == PJSIP_TRANSPORT_TCP)
        {
            sprintf(target_uri_buffer, "<sip:%s;transport=tcp>", reqc->callee);
            sprintf(from_uri_buffer, "<sip:%s;transport=tcp>", reqc->caller);
            sprintf(to_uri_buffer, "<sip:%s;transport=tcp>", reqc->callee);
            //sprintf(target_uri_buffer, "<sip:%s@%s:%d;transport=tcp>", reqc->callee, reqc->remoteaddr, reqc->remoteport);
            //sprintf(from_uri_buffer, "<sip:%s@%s:%d;transport=tcp>", reqc->caller, reqc->remoteaddr, reqc->remoteport);
            //sprintf(to_uri_buffer, "<sip:%s@%s:%d;transport=tcp>", reqc->callee, reqc->remoteaddr, reqc->remoteport);
        }
        else
        {
            sprintf(target_uri_buffer, "<sip:%s;transport=udp>", reqc->callee);
            sprintf(from_uri_buffer, "<sip:%s;transport=udp>", reqc->caller);
            sprintf(to_uri_buffer, "<sip:%s;transport=udp>", reqc->callee);
            //sprintf(target_uri_buffer, "<sip:%s@%s:%d;transport=udp>", reqc->callee, reqc->remoteaddr, reqc->remoteport);
            //sprintf(from_uri_buffer, "<sip:%s@%s:%d;transport=udp>", reqc->caller, reqc->remoteaddr, reqc->remoteport);
            //sprintf(to_uri_buffer, "<sip:%s@%s:%d;transport=udp>", reqc->callee, reqc->remoteaddr, reqc->remoteport);
        }

    }
    #endif

    target_uri = pj_str(target_uri_buffer);
    from_uri = pj_str(from_uri_buffer);
    to_uri = pj_str(to_uri_buffer);

    //get contacts
    char default_contact_buffer[MAX_SESSION_LEN];
    pj_sockaddr_print(&g_zsip_app.default_addr, default_contact_buffer, sizeof(default_contact_buffer), 0);

    pj_str_t contact_str[MAX_CONTACT_CNT];
    char contact_buffer[MAX_CONTACT_CNT][MAX_SESSION_LEN];
    int cnt;
    cnt = reqc->contact_cnt>MAX_CONTACT_CNT?MAX_CONTACT_CNT:reqc->contact_cnt;
    for(int i=0; i<cnt; i++)
    {
        if(tp_type == ZSIP_TRANSPORT_TCP)
        {
            if(reqc->port[i])
            {
                if(reqc->contact[i]==NULL)
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s:%d;transport=tcp>",
                        reqc->caller, default_contact_buffer, reqc->port[i]);
                }
                else
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s:%d;transport=tcp>",
                        reqc->caller, reqc->contact[i], reqc->port[i]);
                }
            }
            else
            {
                if(reqc->contact[i]==NULL)
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s;transport=tcp>",
                        reqc->caller, default_contact_buffer);
                }
                else
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s;transport=tcp>",
                        reqc->caller, reqc->contact[i]);
                }
            }
        }
        else /*tp_type == ZSIP_TRANSPORT_UDP*/
        {
            if(reqc->port[i])
            {
                if(reqc->contact[i]==NULL)
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s:%d;transport=udp>",
                        reqc->caller, default_contact_buffer, reqc->port[i]);
                }
                else
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s:%d;transport=udp>",
                        reqc->caller, reqc->contact[i], reqc->port[i]);
                }
            }
            else
            {
                if(reqc->contact[i]==NULL)
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s;transport=udp>",
                        reqc->caller, default_contact_buffer);
                }
                else
                {
                    sprintf(contact_buffer[i], "<sip:%s@%s;transport=udp>",
                        reqc->caller, reqc->contact[i]);
                }
            }
        }
        contact_str[i]=pj_str(contact_buffer[i]);
    }


    // create request tdata
    pjsip_method method;
    method.id = (pjsip_method_e)reqc->method.id;
    method.name = pj_str(reqc->method.name);
    pjsip_tx_data *tdata;
    status = pjsip_endpt_create_request(g_zsip_app.endpt->endpt, &method,
                    &target_uri, &from_uri,
                    &to_uri, contact_str,
                    NULL, -1, NULL, &tdata);
    if(status!=PJ_SUCCESS)
    {
        err("request create", status);
        return status;
    }

    //internal user_data
    z_pool_t *pool;
    pool = z_pool_create(1000, 1000);

    p2p_data* req_data = (p2p_data*)z_pool_alloc(pool, sizeof(p2p_data));
    req_data->pool = pool;
    req_data->icest = NULL;
    req_data->reqc.user_data = reqc->user_data;
    if(reqc->param)
    {
        req_data->reqc.param = (char*)z_pool_alloc(pool, MAX_PARAM_LEN);
        strcpy(req_data->reqc.param, reqc->param);
    }
    else
        req_data->reqc.param = NULL;
    strcpy(req_data->reqc.content_type, reqc->content_type);
    strcpy(req_data->reqc.content_subtype, reqc->content_subtype);
    req_data->cb = cb;
    req_data->tdata = tdata;
    req_data->role = Z_ICE_SESS_ROLE_CONTROLLING;

    //start to stun!
    status = zsip_p2p_stun(req_data);
    if(status!=PJ_SUCCESS)
    {
        z_pool_release(pool);
        return status;
    }

    return PJ_SUCCESS;
}


z_status_t zsip_p2p_response(void *handle, const char* param, void* user_data, zsip_p2p_cb *cb)
{
    pj_status_t status;

    //internal user_data(reuse the msg_handle_st pool)
    msg_handle_st* msg_handle = (msg_handle_st*)handle;

    pj_pool_t* pool = z_pool_create(1000, 1000);
    p2p_data* response_data = (p2p_data*)z_pool_alloc(pool, sizeof(p2p_data));
    response_data->pool = pool;
    response_data->icest = NULL;
    response_data->cb = cb;
    response_data->response.user_data = user_data;

    if(param)
    {
        response_data->response.param = (char*)z_pool_alloc(pool, MAX_PARAM_LEN);
        strcpy(response_data->response.param, param);
    }
    else
        response_data->response.param = NULL;
    response_data->handle = msg_handle;
    response_data->role = Z_ICE_SESS_ROLE_CONTROLLED;


    //start to stun!
    status = zsip_p2p_stun(response_data);
    if(status!=PJ_SUCCESS)
    {
        zsip_endpt_respond_msg(handle, P2P_CALLEE_START_STUN_FAILED, NULL, "application", "sdp", NULL);
        z_pool_release(pool);
        return status;
    }

    #if 0
    pj_time_val t;
    pj_gettimeofday(&t);
    printf("zsip:%u|%s|start p2p\n", t.sec*1000+t.msec/1000, (char*)user_data);
    #endif

    return PJ_SUCCESS;
}

static char nat_type_desc[][30] =
{
    "NAT TYPE UNKNOW",
    "NAT TYPE ERR UNKNOWN",
    "NAT TYPE OPEN",
    "NAT TYPE BLOCKED",
    "NAT TYPE SYMMETRIC UDP",
    "NAT TYPE FULL CONE",
    "NAT TYPE SYMMETRIC",
    "NAT TYPE RESTRICTED",
    "NAT TYPE PORT RESTRICTED"
};

typedef struct nat_data
{
    z_pool_t *pool;
    z_nat_detect_cb *cb;
    void *user_data;
    pj_sockaddr_in server;
    z_nat_detect_result result;
}nat_data;

static void p2p_nat_detect_cb(void *user_data, const pj_stun_nat_detect_result *res)
{
    nat_data* data = (nat_data*)user_data;
    data->result.status = res->status;
    data->result.nat_type = (z_nat_type)res->nat_type;
    data->result.nat_desc = nat_type_desc[(int)data->result.nat_type];
    data->cb(&data->result, data->user_data);
    z_pool_release(data->pool);
}


z_status_t z_detect_nat_type(z_nat_detect_cb *cb, void *user_data)
{
    pj_status_t status;

    //internal user_data
    z_pool_t *pool;
    pool = z_pool_create(1000, 1000);

    nat_data* data = (nat_data*)z_pool_alloc(pool, sizeof(nat_data));
    data->pool = pool;
    data->cb = cb;
    data->user_data=user_data;
    pj_sockaddr_in_init(&data->server,
        &g_zsip_app.ice_cfg.stun.server, g_zsip_app.ice_cfg.stun.port);


    status = pj_stun_detect_nat_type(&data->server,
					    &g_zsip_app.ice_cfg.stun_cfg,
					    data,
					    p2p_nat_detect_cb);// only support ipv4?
    if(status!=PJ_SUCCESS)
    {
        z_pool_release(pool);
        return status;
    }
    return PJ_SUCCESS;
}
















