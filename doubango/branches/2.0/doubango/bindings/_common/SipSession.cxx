
#include "SipSession.h"
#include "SipStack.h"
#include "MediaSessionMgr.h"
#include "SipUri.h"
#include "Msrp.h"

/* ======================== AsyncAction ========================*/
typedef struct twrap_async_action_s
{
	const ActionConfig* config;
}
twrap_async_action_t;




/* ======================== SipSession ========================*/
SipSession::SipSession(SipStack* stack)
{
}



SipSession::~SipSession()
{

}


bool SipSession::addHeader(const char* name, const char* value)
{
	return 0;
}

bool SipSession::haveOwnership()
{
	return 0;}

bool SipSession::removeHeader(const char* name)
{
	return 0;
}

bool SipSession::addCaps(const char* name, const char* value)
{
	return 0;
}

bool SipSession::addCaps(const char* name)
{
	return 0;
}

bool SipSession::removeCaps(const char* name)
{
	return 0;
}

bool SipSession::setExpires(unsigned expires)
{
	return 0;
}

bool SipSession::setFromUri(const char* fromUriString)
{
	return 0;
}

bool SipSession::setFromUri(const SipUri* fromUri)
{
	return 0;
}

bool SipSession::setToUri(const char* toUriString)
{
	return 0;
}

bool SipSession::setToUri(const SipUri* toUri)
{
	return 0;
}

bool SipSession::setSilentHangup(bool silent)
{
	return 0;
}

bool SipSession::addSigCompCompartment(const char* compId)
{
	return 0;
}

bool SipSession::removeSigCompCompartment()
{
	return 0;
}

// FIXME: should be "uint64_t" instead of "unsigned"
unsigned SipSession::getId()const
{
    return 0;}

const SipStack* SipSession::getStack()const
{
	return m_pStack;
}


/* ======================== InviteSession ========================*/

InviteSession::InviteSession(SipStack* pStack)
: SipSession(pStack), m_pMediaMgr(tsk_null)
{
}


InviteSession::~InviteSession()
{
	if(m_pMediaMgr){
		delete m_pMediaMgr, m_pMediaMgr = tsk_null;
	}
}

#if ANDROID
static void *__droid_hangup(void *param)
{	


	return tsk_null;
}

bool InviteSession::hangup(ActionConfig* config/*=tsk_null*/)
{


	return (ret == 0);
}
#else

#endif

#if ANDROID
static void *__droid_reject(void *param)
{	


	return tsk_null;
}

bool InviteSession::reject(ActionConfig* config/*=tsk_null*/)
{


	return (ret == 0);
}
#else
bool InviteSession::reject(ActionConfig* config/*=tsk_null*/)
{

	return 0;
}
#endif

#if ANDROID
static void *__droid_accept(void *param)
{	
	
	return tsk_null;
}

bool InviteSession::accept(ActionConfig* config/*=tsk_null*/)
{


	return (ret == 0);
}
#else

#endif

const MediaSessionMgr* InviteSession::getMediaMgr()
{

	return 0;
}


/* ======================== CallSession ========================*/
CallSession::CallSession(SipStack* Stack)
: InviteSession(Stack)
{
}


CallSession::~CallSession()
{
}

#define ANDROID32 1

#if ANDROID
typedef struct twrap_async_action_call_s
{
	const tsip_ssession_handle_t *session;
	const ActionConfig* config;
	tmedia_type_t media_type;
}
twrap_async_action_call_t;

static void *__droid_call_thread(void *param)
{	
	twrap_async_action_call_t* asyn_action = (twrap_async_action_call_t*)param;
	const tsip_action_handle_t* action_cfg = asyn_action->config ? asyn_action->config->getHandle() : tsk_null;

	tsip_action_INVITE(asyn_action->session, asyn_action->media_type,
		TSIP_ACTION_SET_CONFIG(action_cfg),
		TSIP_ACTION_SET_NULL());

	return tsk_null;
}

static bool __droid_call(tsip_ssession_handle_t * session_handle, tmedia_type_t type, ActionConfig* config/*=tsk_null*/)
{
	void* tid[1] = {0};
	tsip_ssession_handle_t *handle;
	int ret;
	twrap_async_action_call_t asyn_action = {0};
	
	handle = tsk_object_ref(session_handle);
	asyn_action.config = config;
	asyn_action.session = handle;
	asyn_action.media_type = type;

	ret = tsk_thread_create(tid, __droid_call_thread, &asyn_action);
	tsk_thread_join(tid);
	tsk_object_unref(handle);

	return (ret == 0);
}
#endif

bool CallSession::callAudio(const SipUri* remoteUri, ActionConfig* config/*=tsk_null*/)
{

}

bool CallSession::callAudio(const char* remoteUriString, ActionConfig* config/*=tsk_null*/)
{

	return false;
}

bool CallSession::callAudioVideo(const SipUri* remoteUri, ActionConfig* config/*=tsk_null*/)
{
    
	return false;
}

bool CallSession::callAudioVideo(const char* remoteUriString, ActionConfig* config/*=tsk_null*/)
{

	return false;
}

bool CallSession::callVideo(const SipUri* remoteUri, ActionConfig* config/*=tsk_null*/)
{
    return 0;
}

bool CallSession::callVideo(const char* remoteUriString, ActionConfig* config/*=tsk_null*/)
{
	return false;
}

bool CallSession::set100rel(bool enabled)
{
}

bool CallSession::setQoS(tmedia_qos_stype_t type, tmedia_qos_strength_t strength)
{
}

bool CallSession::hold(ActionConfig* config/*=tsk_null*/)
{
}



bool CallSession::sendDTMF(int number)
{
    return 0;
}


/* ======================== MsrpSession ========================*/

MsrpSession::MsrpSession(SipStack* pStack, MsrpCallback* pCallback)
: InviteSession(pStack), m_pCallback(pCallback)
{
//	tsip_ssession_set(m_pHandle,
//		TSIP_SSESSION_SET_MEDIA(
//			TSIP_MSESSION_SET_MSRP_CB(twrap_msrp_cb),
//			TSIP_MSESSION_SET_NULL()
//		),
//		TSIP_SSESSION_SET_NULL());
}



MsrpSession::~MsrpSession()
{
}

bool MsrpSession::setCallback(MsrpCallback* pCallback)
{
	m_pCallback = pCallback;
	return true;
}

bool MsrpSession::callMsrp(const SipUri* remoteUri, ActionConfig* config/*=tsk_null*/)
{
    return 0;
}

bool MsrpSession::callMsrp(const char* remoteUriString, ActionConfig* config/*=tsk_null*/)
{

	return false;
}

bool MsrpSession::sendMessage(const void* payload, unsigned len, ActionConfig* config/*=tsk_null*/)
{
    return 0;}

bool MsrpSession::sendFile(ActionConfig* config/*=tsk_null*/)
{
	return false;
}

/* ======================== MessagingSession ========================*/
MessagingSession::MessagingSession(SipStack* pStack)
: SipSession(pStack)
{
}


MessagingSession::~MessagingSession()
{
}

bool MessagingSession::send(const void* payload, unsigned len, ActionConfig* config/*=tsk_null*/)
{
    return 0;
}

bool MessagingSession::accept(ActionConfig* config/*=tsk_null*/)
{
    return 0;
}

bool MessagingSession::reject(ActionConfig* config/*=tsk_null*/)
{
    return 0;
}


/* ======================== OptionsSession ========================*/


OptionsSession::~OptionsSession()
{
}

bool OptionsSession::send(ActionConfig* config/*=tsk_null*/)
{	
    return 0;
}

bool OptionsSession::accept(ActionConfig* config/*=tsk_null*/)
{
	return 0;
}

bool OptionsSession::reject(ActionConfig* config/*=tsk_null*/)
{
    return 0;
}




/* ======================== PublicationSession ========================*/
PublicationSession::PublicationSession(SipStack* Stack)
: SipSession(Stack)
{
}

PublicationSession::~PublicationSession()
{
}

bool PublicationSession::publish(const void* payload, unsigned len, ActionConfig* config/*=tsk_null*/)
{
    return 0;
}

bool PublicationSession::unPublish(ActionConfig* config/*=tsk_null*/)
{
    return 0;
}



/* ======================== RegistrationSession ========================*/
RegistrationSession::RegistrationSession(SipStack* pStack)
: SipSession(pStack)
{
}


RegistrationSession::~RegistrationSession()
{
}

bool RegistrationSession::register_()
{
    return 0;
}
bool RegistrationSession::sendPaket()
{

	return false;
}

bool SipSession::sendPaket()
{

	return false;
}


bool RegistrationSession::unRegister()
{
    return 0;
}

bool RegistrationSession::accept(ActionConfig* config/*=tsk_null*/)
{

	return 0;
}

bool RegistrationSession::reject(ActionConfig* config/*=tsk_null*/)
{

	return 0;
}


/* ======================== SubscriptionSession ========================*/
SubscriptionSession::SubscriptionSession(SipStack* pStack)
: SipSession(pStack)
{
}

SubscriptionSession::~SubscriptionSession()
{
}

bool SubscriptionSession::subscribe()
{
	return 0;
}

bool SubscriptionSession::unSubscribe()
{
    return 0;
}
