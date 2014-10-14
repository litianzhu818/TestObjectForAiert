#ifndef _ZSIP_H
#define _ZSIP_H

#include <pjsip.h>
#include <pjmedia.h>
#include <pjmedia-codec.h>
#include <pjsip_ua.h>
#include <pjsip_simple.h>
#include <pjlib-util.h>
#include <pjlib.h>
#include <pjnath.h>

#define ZSIP_RESOLVE 0
#define ZSIP_REGISTER 0
#define ZSIP_OPTION 1
#define ZSIP_STUN_CONTROLLER 1
#define ZSIP_NAT_DETECT 0
#define ZSIP_COMPOSITE_ICE 1
#define ZSIP_PORTPRE 0




/*P2P err code*/
#define ZSIP_ERROR_CODE 500
#define P2P_CALLER_INIT_ICE_FAILED (ZSIP_ERROR_CODE+10)
#define P2P_CALLEE_INIT_ICE_FAILED (ZSIP_ERROR_CODE+11)
#define P2P_CALLER_START_STUN_FAILED (ZSIP_ERROR_CODE+12)
#define P2P_CALLEE_START_STUN_FAILED (ZSIP_ERROR_CODE+13)
#define P2P_CALLER_START_NEGO_FAILED (ZSIP_ERROR_CODE+14)
#define P2P_CALLEE_START_NEGO_FAILED (ZSIP_ERROR_CODE+15)
#define P2P_CALLER_STUN_CB_FAILED (ZSIP_ERROR_CODE+16)
#define P2P_CALLEE_STUN_CB_FAILED (ZSIP_ERROR_CODE+17)
#define P2P_CALLER_NEGO_CB_FAILED (ZSIP_ERROR_CODE+18)
#define P2P_CALLEE_NEGO_CB_FAILED (ZSIP_ERROR_CODE+19)
#define P2P_SEND_REQ_FAILED (ZSIP_ERROR_CODE+20)

#define TIMER_KEEP_ALIVE 101



/*network definition*/
//---------------------------------------------
#define Z_AF_INET() pj_AF_INET()
#define Z_AF_INET6() pj_AF_INET6()

/**
 * Transport types.
 */
typedef enum zsip_transport_type_e
{

    ZSIP_TRANSPORT_UNSPECIFIED,/**< Unspecified*/

    ZSIP_TRANSPORT_UDP,/**< UDP*/

    ZSIP_TRANSPORT_TCP,/**< TCP. */

    ZSIP_TRANSPORT_TLS,/**< TLS. */

    ZSIP_TRANSPORT_SCTP,/**< SCTP. */

    ZSIP_TRANSPORT_LOOP,/**< Loopback (stream, reliable) */

    ZSIP_TRANSPORT_LOOP_DGRAM,/**< Loopback (datagram, unreliable) */

    ZSIP_TRANSPORT_START_OTHER,/**< Start of user defined transport */

    ZSIP_TRANSPORT_IPV6    = 128,/**< Start of IPv6 transports */

    ZSIP_TRANSPORT_UDP6 = ZSIP_TRANSPORT_UDP + ZSIP_TRANSPORT_IPV6,/**< UDP over IPv6 */

    ZSIP_TRANSPORT_TCP6 = ZSIP_TRANSPORT_TCP + ZSIP_TRANSPORT_IPV6/**< TCP over IPv6 */

} zsip_transport_type_e;


#define ZSIP_MAX_RESOLVED_ADDRESSES 8
#define ZSIP_MAX_ADDR_LEN  46

#define STUN_KA_INTERVAL 15
#define MAX_P2P_CONTENT_LEN 1000
#define MAX_PARAM_LEN 80
#define MAX_TYPE_LEN 20
#define MAX_METHOD_NAME 20
#define MAX_SESSION_LEN	512

#define MIN_OPTION_INTVAL 10
#define MAX_OPTION_INTVAL 300

/**
 * This structure describes an address's ip, port and transport type.
 */
typedef struct addr_entry
{
    /**
     * Transport types.
     */
    zsip_transport_type_e type;
    /**
     * ip dot string.
     */
    char ip[ZSIP_MAX_ADDR_LEN];
    /**
     * port number.
     */
    int port;
} addr_entry;


/**
 * The server addresses returned by the resolver.
 */
typedef struct zsip_resolve_addr
{
    /**
     * Number of address records.
     */
    unsigned    count;
    /**
     * address records.
     */
    addr_entry entry[ZSIP_MAX_RESOLVED_ADDRESSES];
} zsip_resolve_addr;






/*general definition*/
//---------------------------------------------
/** error message size in log. */
#define Z_ERR_MSG_SIZE  PJ_ERR_MSG_SIZE

/** memeory pool size. */
#define CACHING_POOL_SIZE   (256*1024*1024)

/** Boolean. */
typedef int		z_bool_t;

/** True value. */
#define Z_TRUE	    1

/** False value. */
#define Z_FALSE    0


/** Status.  Z_SUCCESS means no error.*/
typedef pj_status_t  z_status_t;

/** thread object. */
typedef pj_thread_t z_thread_t;

/** thread execute function. */
typedef int z_thread_proc(void*);


/** status is OK. */
#define Z_SUCCESS 0
#define Z_INSTANCE_EXIST 1

/**
 * time interval struct.
 */
typedef struct z_time_val
{
    /** The seconds part of the time. */
    long    sec;

    /** The miliseconds fraction of the time. */
    long    msec;

} z_time_val;

/**
 * The type of callback function to be called by timer scheduler when a timer
 * has expired.
 *
 * @param id                The timer id.
 * @param user_data         user data specified in timer scheduler.
 */
typedef void z_timer_heap_callback(int id, void* user_data);

/**
 * Schedule timer to endpoint's timer heap. Application must poll the endpoint
 * periodically (by calling #zsip_endpt_handle_events) to ensure that the
 * timer events are handled in timely manner. When the timeout for the timer
 * has elapsed, the callback specified in the entry argument will be called.
 * This function, like all other endpoint functions, is thread safe.
 *
 * @param id                The timer id.
 * @param delay                the timerheap will call cb after tv.
 * @param cb                callback func
 * @param user_data         user data specified in timer scheduler.
 * @return	    Z_SUCCESS (zero) if successfull.
 */
 z_status_t zsip_endpt_schedule_timer(int id, z_time_val* delay, z_timer_heap_callback* cb, void* user_data);


/**
 * Send keep alive data to sip server. The data is raw data used to keep nat port aliving.
 * It is not a sip message and has very few bytes.
 * @param sec   timer inverval.
 * @return	    Z_SUCCESS (zero) if successfull.
 */
z_status_t zsip_start_ka(int sec);


/** memory pool. */
typedef pj_pool_t z_pool_t;

/**
 * This enumeration declares SIP methods.
 */
typedef enum zsip_method_e
{
    ZSIP_INVITE_METHOD,    /**< INVITE method, for establishing dialogs.   */
    ZSIP_CANCEL_METHOD,    /**< CANCEL method, for cancelling request.      */
    ZSIP_ACK_METHOD,        /**< ACK method.                    */
    ZSIP_BYE_METHOD,        /**< BYE method, for terminating dialog.        */
    ZSIP_REGISTER_METHOD,  /**< REGISTER method.                */
    ZSIP_OPTIONS_METHOD,   /**< OPTIONS method.             */

    ZSIP_OTHER_METHOD       /**< Other method.                  */

} zsip_method_e;

/**
 * This enumeration describes the role of the ICE agent.
 */
typedef enum z_ice_sess_role
{
    /**
     * The role is unknown.
     */
    Z_ICE_SESS_ROLE_UNKNOWN,

    /**
     * The ICE agent is in controlled role.
     */
    Z_ICE_SESS_ROLE_CONTROLLED,

    /**
     * The ICE agent is in controlling role.
     */
    Z_ICE_SESS_ROLE_CONTROLLING

} z_ice_sess_role;


/**
 * This structure represents a SIP method.
 */
typedef struct zsip_method
{
    zsip_method_e id;       /**< Method ID, from \a zsip_method_e. */
    char*      name;    /**< Method name . */
}zsip_method;


/**
 * create memory pool.
 *@param init      init pool size.
 *@param inc       pool auto increase size
 *@return          pointer to pool.
 */
z_pool_t* z_pool_create(int init, int inc);

/**
 * alloc mem from pool.
 *@param pool      memroy pool.
 *@param sz        mem size
 *@return          pointer to mem.
 */
#define z_pool_alloc(pool, sz)           \
     pj_pool_alloc(pool, sz)

/**
 * release pool.
 *@param pool      memroy pool.
 */
#define z_pool_release(pool)           \
     pj_pool_release(pool)



/**
 * Create a new thread.
 *
 *@param pool          The memory pool from which the thread record
 *                      will be allocated from.
 *@param proc          Thread entry function.
 *@param arg           Argument to be passed to the thread entry function.
 *@param thread        Pointer to hold the newly created thread.
 *
 *@return	        PJ_SUCCESS on success, or the error code.
 */
z_status_t z_thread_create(z_pool_t *pool,
                        z_thread_proc *proc,
                        void *arg,
				        z_thread_t **thread );

pj_status_t z_thread_register(void);

/**
 * This structure for creating an endpoint.
 */
typedef struct zsip_endptc
{
    /**
     * transport type.
     */
    zsip_transport_type_e tp_type;
    /**
     * the type define in \a Z_AF_INET() and \a Z_AF_INET6().
     */
    int inet_type;
    /**
     * address dot string in host.NULL means any ip.
     */
    const char* local_addr;
    /**
     * port in host for receiving SIP message.
     * 0 means any port.
     */
    int local_port;
    /**
     * address dot string in host. It is usaully same with local_addr.
     * NULL means not needed.
     */
    const char* published_addr;
    /**
     * published port.
     */
    int published_port;

    /*SIP Server info*/
    /**
     * address dot string in sip server.
     */
    const char* srv_addr;
    /**
     * sip server port.
     */
    int srv_port;

    /*stun info*/
    /**
     * address dot string in stun server.
     */
    const char* stun_addr;
    /**
     * stun server port.
     */
    int stun_port;

    /**
     * the addr in host which is used to hole punching.
     */
    const char* bound_addr;
    /**
     * the port in host which is used to hole punching.
     * 0 means any port.
     */
    int bound_port;

    /**
     * the addr of name server.
     */
    const char* ns_addr;
    /**
     * the port of name server.
     * 0 means any port.
     */
    int ns_port;

    /**
     * pjsip log on or off
     */
    z_bool_t is_log;


    /**
     * pjsip log on or off
     */
    int req_timeout;



    /**
     * role define in \a z_ice_sess_role, controller or controlled.
     */
    z_ice_sess_role role;
    /**
     * incoming non-INVITE requst process callback.
     *
     *@param method_id          incoming request id.
     *@param method_name        incoming request name for \a ZSIP_OTHER_METHOD.
     *@param data               request msg body data.
     *@param data_len           request msg body data len.
     *@param msg_handler        handler for send response.
     *@return                   Z_TRUE or Z_FALSE.
     */
    z_bool_t (*on_rx_msg_request)( zsip_method_e method_id, const char* method_name,
            void* data, int data_len, void* msg_handler);



    /**
     * incoming INVITE requst process callback.
     *
     *@param data               msg body data.
     *@param data_len           msg body data len.
     *@param call_handler       handler for send response.
     *@return                   msg ret code. 200,300,500....
     */
    z_bool_t (*on_rx_invite_request)(void* data, int data_len, void* call_handler);

}zsip_endptc;

/**
 * init zsip, create pool factory and pool for app, init zsip environment.
 *@param endptc      endpt struct.
 *@return      init result.
 */
z_status_t zsip_init(zsip_endptc* endptc);


/**
 * update dns server.
 *@param count      nameserver counts.
 *@param servers    nameserver address.
 *@param ports      nameserver ports, defaltly set with 53
 *@return      update result.
 */
z_status_t zsip_update_dns(unsigned count, char* servers[], int ports[]);


void zsip_release();

/**
 * Create pool from the endpoint.
 *
 *@param pool_name Name to be assigned to the pool.
 *@param initial   The initial size of the pool.
 *@param increment The resize size.
 *@return      Memory pool, or NULL on failure.
 *
 */
z_pool_t* zsip_endpt_create_pool(const char *pool_name, int initial, int increment );


/**
 * Poll for events.
 * Application must call this function periodically to ensure
 * that all events from both transports and timer heap are handled in timely
 * manner.  This function, like all other endpoint functions, is thread safe,
 * and application may have more than one thread concurrently calling this function.
 *
 *@param max_timeout   Maximum time to wait for events, or NULL to wait forever
 *          until event is received.
 *
 *@return      PJ_SUCCESS on success.
 */
z_status_t zsip_endpt_handle_events(const z_time_val *max_timeout);

#if 0
/**
 * The type of callback function to be called when resolver finishes the job.
 *
 *@param status        The status of the operation, which is zero on success.
 *@param user_data     The token that was associated with the job when application
 *                      call the resolve function.
 *@param addr          The addresses resolved by the operation.
 */
typedef void zsip_resolver_callback(z_status_t status,
                     void *user_data,
                     const struct zsip_resolve_addr *addr);


/**
 * Asynchronously resolve a SIP target host or domain.
 *
 *@param addr      The target ip string to be resolved.
 *@param port      The target port to be resolved.
 *@param user_data A user defined token to be passed back to callback function.
 *@param cb        The callback function, user should save the addr by himself in tis function.
 */
z_status_t zsip_endpt_resolve(const char *addr,  int port,
    void *user_data,  zsip_resolver_callback *cb);

#endif



#define MAX_CONTACT_CNT 8

/**
 *@ This structure for regist.
 */
typedef struct zsip_regc
{
    char* contact[MAX_CONTACT_CNT];
    int port[MAX_CONTACT_CNT];
    unsigned contact_cnt;
    char* caller;
    char* callee;
    char* user;
    char* passwd;
    int expired;
    void *user_data;
    char *content_type;
    char *content_subtype;
    char *content;
}zsip_regc;

/**
 * Type declaration for callback to receive registration result.
 *
 *@param status    register status.
 *@param code      sip register response code
 *@param response  sip register response body, user should save the buffer by himself
 *@param len       sip register response body
 *@param user_data user defined data to be passed back to callback function.
 */
typedef void zsip_regc_cb(z_status_t status, int code, void* response, int len, void* user_data);

/**
 * register to SIP server .
 *@param reqc  regist info structure
 *@param cb    regist callback
 */
z_status_t zsip_reg(zsip_regc *regc, zsip_regc_cb *cb);

/**
 * This structure for creating a request.
 */
typedef struct zsip_request
{
    zsip_method method;
    char* contact[MAX_CONTACT_CNT];
    int port[MAX_CONTACT_CNT];
    unsigned contact_cnt;
    char *callee;
    char *caller;
    void *user_data;
    char *content_type;
    char *content_subtype;
    char *content;
}zsip_request;

/**
* This structure for creating a p2p request.
*/
typedef struct zsip_p2p_request
{
    zsip_method method;
    char* contact[MAX_CONTACT_CNT];
    int port[MAX_CONTACT_CNT];
    unsigned contact_cnt;
    char *callee;
    char *caller;
    void *user_data;
    char *content_type;
    char *content_subtype;
    char *param;
}zsip_p2p_request;


 /**
 * Type of callback to be specified in #zsip_req().
 *
 *@param status    send status.
 *@param code      request response code
 *@param response  request response body, user should save the buffer by himself
 *@param len       request response body len
 *@param user_data user defined data to be passed back to callback function.
 */
typedef void zsip_reqc_cb(z_status_t status, int code, void* response, int len, void* user_data);

/**
 * send SIP request to server or other peer.
 *@param reqc  requst info structure
 *@param cb    requst callback
 */
z_status_t zsip_req(zsip_request *reqc, zsip_reqc_cb *cb, const char* dest_addr=NULL, int dest_port=0);


/**
 * send response for non-INVITE message. handler will be freed in this function.
 *
 *@param handler   The handler was got from the callback for request
 *                  and must be freed by calling this function.
 *@param ret_code  request response code
 *@param ret_text  request response text.
 *@param type      SIP hdr
 *@param subtype   SIP hdr
 *@param data      body content
 */
z_status_t zsip_endpt_respond_msg(void* handler, int ret_code, char* ret_text,
    char*type, char*subtype, char* data);


typedef pj_ice_strans z_ice_strans;


/**
* Type of callback to be specified in #zsip_ice.
*
*@param status    stun status.
*@param icest     ice handler
*@param user_data user defined data to be passed back to callback function.
*/
typedef void zsip_stun_cb(z_status_t status, z_ice_strans* icest, void* user_data);

/**
* struct used in \a zsip_p2p_req callback.
* It describes the address info after p2p hole punching.
*/
typedef struct zsip_addr_pair
{
    /** address used to send and recv in host.*/
    char base_addr[ZSIP_MAX_ADDR_LEN];
    /** port used to send and recv in host.*/
    int base_port;
    /** address used to send and recv in host or host side NAT.*/
    char l_addr[ZSIP_MAX_ADDR_LEN];
    /** port used to send and recv in host or host side NAT.*/
    int l_port;
    /** address used to send and recv in remote or remote side NAT.*/
    char r_addr[ZSIP_MAX_ADDR_LEN];
    /** port used to send and recv in remote or remote side NAT.*/
    int r_port;
}zsip_addr_pair;

/**
* Type of callback to be specified in #zsip_ice.
*
*@param status          neg status.
*@param icest           ice handler
*@param addr_pair       local and remote address pairs
*@param pair_cnt        address pairs count
*@param user_data user defined data to be passed back to callback function.
*/
typedef void zsip_neg_cb(z_status_t status, z_ice_strans* icest,
    zsip_addr_pair* addr_pair, int pair_cnt, void* user_data);

/**
 * struct for starting ice progress.
 *
 */
typedef struct zsip_ice
{
    z_ice_strans *icest;
    void *user_data;
    z_ice_sess_role role;
    zsip_stun_cb *stun_cb;
    zsip_neg_cb *neg_cb;
}zsip_ice;



/**
* start to send stun msg to stun srv for getting peer candidate
*
*@param stun      stun info strunt
*/
z_status_t zsip_start_stun(zsip_ice *stun);


/**
* get param from sdp buffer.
*
*@param buffer    sdp buffer.
*@param param     msg param.
*@return   Z_TRUE:has param
*/
z_bool_t get_param(char *buffer, char*param);

/**
* get stun info from stun handler and save the info into buffer.
*
*@param icest     ice handler.
*@param param     msg param if any. NULL means no param needed to inform remote peer
*@param buffer    buffer to store sdp string
*@param maxlen    max buffer size.
*/
int encode_sdp(z_ice_strans *icest, char* param, char buffer[], unsigned maxlen);


/**
* validate addr-pairs between p2p peers.
*
*@param icest     ice handler.
*@param rem_sdp   remote msg string which contains address info of remote peer.
*/
z_status_t zsip_start_neg(z_ice_strans *icest, char* rem_sdp);

/**
* Type of callback to be specified in #zsip_p2p_req and #zsip_p2p_response.
*
*@param code            P2P request reply code.
*@param icest           ice handler
*@param param           p2p msg param string
*@param addr_pair       local and remote address pairs
*@param pair_cnt        address pairs count
*@param user_data user defined data to be passed back to callback function.
*/
typedef void zsip_p2p_cb(int code, z_ice_strans* icest,
    char* param, zsip_addr_pair* addr_pair, int pair_cnt, void* user_data);


/**
* composite request function which can get address pairs in callback directly.
*
*@param reqc            requst info structure.
*@param cb              result callback
*/
z_status_t zsip_p2p_req(zsip_p2p_request *reqc, zsip_p2p_cb *cb);

/**
* composite response function which can get address pairs in callback directly.
*
*@param handle          the call_handler got from #on_rx_msg_request.
*@param param           param returned from callee side.
*@param param           user data.
*@param cb              result callback
*/
z_status_t zsip_p2p_response(void *handle, const char* param, void* user_data, zsip_p2p_cb *cb);


/**
 * This enumeration describes the NAT types, as specified by RFC 3489
 * Section 5, NAT Variations.
 */
typedef enum z_nat_type
{
    /**
     * NAT type is unknown because the detection has not been performed.
     */
    Z_NAT_TYPE_UNKNOWN,

    /**
     * NAT type is unknown because there is failure in the detection
     * process, possibly because server does not support RFC 3489.
     */
    Z_NAT_TYPE_ERR_UNKNOWN,

    /**
     * This specifies that the client has open access to Internet (or
     * at least, its behind a firewall that behaves like a full-cone NAT,
     * but without the translation)
     */
    Z_NAT_TYPE_OPEN,

    /**
     * This specifies that communication with server has failed, probably
     * because UDP packets are blocked.
     */
    Z_NAT_TYPE_BLOCKED,

    /**
     * Firewall that allows UDP out, and responses have to come back to
     * the source of the request (like a symmetric NAT, but no
     * translation.
     */
    Z_NAT_TYPE_SYMMETRIC_UDP,

    /**
     * A full cone NAT is one where all requests from the same internal
     * IP address and port are mapped to the same external IP address and
     * port.  Furthermore, any external host can send a packet to the
     * internal host, by sending a packet to the mapped external address.
     */
    Z_NAT_TYPE_FULL_CONE,

    /**
     * A symmetric NAT is one where all requests from the same internal
     * IP address and port, to a specific destination IP address and port,
     * are mapped to the same external IP address and port.  If the same
     * host sends a packet with the same source address and port, but to
     * a different destination, a different mapping is used.  Furthermore,
     * only the external host that receives a packet can send a UDP packet
     * back to the internal host.
     */
    Z_NAT_TYPE_SYMMETRIC,

    /**
     * A restricted cone NAT is one where all requests from the same
     * internal IP address and port are mapped to the same external IP
     * address and port.  Unlike a full cone NAT, an external host (with
     * IP address X) can send a packet to the internal host only if the
     * internal host had previously sent a packet to IP address X.
     */
    Z_NAT_TYPE_RESTRICTED,

    /**
     * A port restricted cone NAT is like a restricted cone NAT, but the
     * restriction includes port numbers. Specifically, an external host
     * can send a packet, with source IP address X and source port P,
     * to the internal host only if the internal host had previously sent
     * a packet to IP address X and port P.
     */
    Z_NAT_TYPE_PORT_RESTRICTED

} z_nat_type;


/**
 * This structure contains the result of NAT classification function.
 */
typedef struct z_nat_detect_result
{
    /**
     * Status of the detection process. If this value is not Z_SUCCESS,
     * the detection has failed and \a nat_type field will contain
     * Z_NAT_TYPE_UNKNOWN.
     */
    z_status_t		 status;

    /**
     * This contains the NAT type as detected by the detection procedure.
     * This value is only valid when the \a status is Z_SUCCESS.
     */
    z_nat_type	 nat_type;

    /**
     * This contains the NAT type desc.
     */
    char *nat_desc;

} z_nat_detect_result;

/**
* detect nat type callback define in \a z_stun_detect_nat_type.
*
*@param res            detect result.
*@param user_data      user_data.
*/
typedef void z_nat_detect_cb(const z_nat_detect_result *res, void* user_data);

/**
* detect nat type.
*
*@param cb            call back function return detect result.
*@param user_data     user_data.
*/
z_status_t z_detect_nat_type(z_nat_detect_cb *cb, void *user_data);



















#endif /*_ZSIP_H*/

