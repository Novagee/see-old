
#ifndef TINYWRAP_SIPSESSION_H
#define TINYWRAP_SIPSESSION_H


#include "tinymedia/tmedia_qos.h"
#include "ActionConfig.h"

class SipUri;
class SipStack;
class MsrpCallback;
class MediaSessionMgr;

/* ======================== SipSession ========================*/
class SipSession
{
public:
	SipSession(SipStack* stack);
#if !defined(SWIG)
#endif
	virtual ~SipSession();

public:
	bool haveOwnership();
	bool addHeader(const char* name, const char* value);
	bool removeHeader(const char* name);
	bool addCaps(const char* name, const char* value);
	bool addCaps(const char* name);
	bool removeCaps(const char* name);
	bool setExpires(unsigned expires);
	bool setFromUri(const char* fromUriString);
	bool setFromUri(const SipUri* fromUri);
	bool setToUri(const char* toUriString);
	bool setToUri(const SipUri* toUri);
	bool setSilentHangup(bool silent);
	bool addSigCompCompartment(const char* compId);
	bool removeSigCompCompartment();
	unsigned getId()const;
	bool sendPaket();
#if !defined(SWIG)
	const SipStack* getStack() const;
#endif
	
private:

protected:
	const SipStack* m_pStack;
};

/* ======================== InviteSession ========================*/
class InviteSession : public SipSession
{
public: /* ctor() and dtor() */
	InviteSession(SipStack* Stack);
#if !defined(SWIG)
#endif
	virtual ~InviteSession();

public: /* Public functions */
	bool accept(ActionConfig* config=tsk_null);
	bool hangup(ActionConfig* config=tsk_null);
	bool reject(ActionConfig* config=tsk_null);
	const MediaSessionMgr* getMediaMgr();

private:
	MediaSessionMgr* m_pMediaMgr;
};


/* ======================== CallSession ========================*/
class CallSession : public InviteSession
{
public: /* ctor() and dtor() */
	CallSession(SipStack* pStack);
#if !defined(SWIG)
#endif
	virtual ~CallSession();

public: /* Public functions */
	bool callAudio(const char* remoteUriString, ActionConfig* config=tsk_null);
	bool callAudio(const SipUri* remoteUri, ActionConfig* config=tsk_null);
	bool callAudioVideo(const char* remoteUriString, ActionConfig* config=tsk_null);
	bool callAudioVideo(const SipUri* remoteUri, ActionConfig* config=tsk_null);
	bool callVideo(const char* remoteUriString, ActionConfig* config=tsk_null);
	bool callVideo(const SipUri* remoteUri, ActionConfig* config=tsk_null);
	bool setSessionTimer(unsigned timeout, const char* refresher);
	bool set100rel(bool enabled);
	bool setQoS(tmedia_qos_stype_t type, tmedia_qos_strength_t strength);
	bool hold(ActionConfig* config=tsk_null);
    bool ect(ActionConfig* config, const char* remoteUri);
    
	bool resume(ActionConfig* config=tsk_null);
	bool sendDTMF(int number);
};

/* ======================== MsrpSession ========================*/
class MsrpSession : public InviteSession
{
public: /* ctor() and dtor() */
	MsrpSession(SipStack* pStack, MsrpCallback* pCallback);
#if !defined(SWIG)
#endif
	virtual ~MsrpSession();

public: /* Public functions */
	bool setCallback(MsrpCallback* pCallback);
	bool callMsrp(const char* remoteUriString, ActionConfig* config=tsk_null);
	bool callMsrp(const SipUri* remoteUri, ActionConfig* config=tsk_null);
	bool sendMessage(const void* payload, unsigned len, ActionConfig* config=tsk_null);
	bool sendFile(ActionConfig* config=tsk_null);

	public: /* Public helper function */
#if !defined(SWIG)
		inline MsrpCallback* getCallback()const{
			return m_pCallback;
		}
#endif

private:
	MsrpCallback* m_pCallback;
};



/* ======================== MessagingSession ========================*/
class MessagingSession : public SipSession
{
public: /* ctor() and dtor() */
	MessagingSession(SipStack* pStack);
#if !defined(SWIG)
#endif
	virtual ~MessagingSession();

public: /* Public functions */
	bool send(const void* payload, unsigned len, ActionConfig* config=tsk_null);
	bool accept(ActionConfig* config=tsk_null);
	bool reject(ActionConfig* config=tsk_null);
};

/* ======================== OptionsSession ========================*/
class OptionsSession : public SipSession
{
public: /* ctor() and dtor() */
	OptionsSession(SipStack* pStack);
#if !defined(SWIG)
#endif
	virtual ~OptionsSession();

public: /* Public functions */
	bool send(ActionConfig* config=tsk_null);
	bool accept(ActionConfig* config=tsk_null);
	bool reject(ActionConfig* config=tsk_null);
};



/* ======================== PublicationSession ========================*/
class PublicationSession : public SipSession
{
public: /* ctor() and dtor() */
	PublicationSession(SipStack* pStack);
	virtual ~PublicationSession();

public: /* Public functions */
	bool publish(const void* payload, unsigned len, ActionConfig* config=tsk_null);
	bool unPublish(ActionConfig* config=tsk_null);
};


/* ======================== RegistrationSession ========================*/
class RegistrationSession : public SipSession
{
public: /* ctor() and dtor() */
	RegistrationSession(SipStack* pStack);
#if !defined(SWIG)
#endif
	virtual ~RegistrationSession();

public: /* Public functions */
	bool register_();
	bool sendPaket();
	bool unRegister();
	bool accept(ActionConfig* config=tsk_null);
	bool reject(ActionConfig* config=tsk_null);
};


/* ======================== SubscriptionSession ========================*/
class SubscriptionSession : public SipSession
{
public: /* ctor() and dtor() */
	SubscriptionSession(SipStack* pStack);
	virtual ~SubscriptionSession();

public: /* Public functions */
	bool subscribe();
	bool unSubscribe();
};

#endif /* TINYWRAP_SIPSESSION_H */
