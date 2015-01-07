
#ifndef TINYWRAP_SIPEVENT_H
#define TINYWRAP_SIPEVENT_H


#include "Common.h"

class SipStack;

class SipSession;
class InviteSession;
class CallSession;
class MsrpSession;
class MessagingSession;
class OptionsSession;
class PublicationSession;
class RegistrationSession;
class SubscriptionSession;

class SipMessage;


/* ======================== SipEvent ========================*/
class SipEvent
{
public:
#if !defined(SWIG)
#endif
	virtual ~SipEvent();

public:
	short getCode() const;
	const char* getPhrase() const;
	const SipSession* getBaseSession() const;
	const SipMessage* getSipMessage() const;

protected:
#if !defined(SWIG)
	SipStack* getStack()const;
#endif

protected:
	SipMessage* sipmessage;
};


/* ======================== DialogEvent ========================*/
class DialogEvent: public SipEvent
{
public:
#if !defined(SWIG)
#endif
	virtual ~DialogEvent();

public: /* Public API functions */
};

/* ======================== StackEvent ========================*/
class StackEvent: public SipEvent
{
public:
#if !defined(SWIG)
#endif
	virtual ~StackEvent();

public: /* Public API functions */
};



/* ======================== InviteEvent ========================*/
class InviteEvent: public SipEvent
{
public:
#if !defined(SWIG)
#endif
	virtual ~InviteEvent();

public: /* Public API functions */
	twrap_media_type_t getMediaType() const;
	const InviteSession* getSession() const;
	CallSession* takeCallSessionOwnership() const;
	MsrpSession* takeMsrpSessionOwnership() const;
};



/* ======================== MessagingEvent ========================*/
class MessagingEvent: public SipEvent
{
public:
#if !defined(SWIG)
#endif
	virtual ~MessagingEvent();

public: /* Public API functions */
	const MessagingSession* getSession() const;
	MessagingSession* takeSessionOwnership() const;
};


/* ======================== OptionsEvent ========================*/
class OptionsEvent: public SipEvent
{
public:
#if !defined(SWIG)
#endif
	virtual ~OptionsEvent();

public: /* Public API functions */
	const OptionsSession* getSession() const;
	OptionsSession* takeSessionOwnership() const;
};



/* ======================== PublicationEvent ========================*/
class PublicationEvent: public SipEvent
{
public:
#if !defined(SWIG)
#endif
	virtual ~PublicationEvent();

public: /* Public API functions */
	const PublicationSession* getSession() const;
};



/* ======================== RegistrationEvent ========================*/
class RegistrationEvent: public SipEvent
{
public:
#if !defined(SWIG)
#endif
	virtual ~RegistrationEvent();

public: /* Public API functions */
	const RegistrationSession* getSession() const;
	RegistrationSession* takeSessionOwnership() const;
	
};


/* ======================== SubscriptionEvent ========================*/
class SubscriptionEvent: public SipEvent
{
public:
#if !defined(SWIG)
#endif
	virtual ~SubscriptionEvent();

public: /* Public API functions */
	const SubscriptionSession* getSession() const;
};

#endif /* TINYWRAP_SIPEVENT_H */
