
#include "SipEvent.h"
#include "SipSession.h"
#include "SipMessage.h"

#include "SipStack.h"

/* ======================== SipEvent ========================*/


SipEvent::~SipEvent()
{

}

short SipEvent::getCode() const
{
	return 0;
}

const char* SipEvent::getPhrase() const
{
	return 0;
}

const SipSession* SipEvent::getBaseSession() const
{

	return tsk_null;
}

const SipMessage* SipEvent::getSipMessage() const
{
	return 0;
}

SipStack* SipEvent::getStack()const
{

	return tsk_null;
}


/* ======================== DialogEvent ========================*/

DialogEvent::~DialogEvent(){ }

StackEvent::~StackEvent(){ }


/* ======================== InviteEvent ========================*/

InviteEvent::~InviteEvent()
{
}


twrap_media_type_t InviteEvent::getMediaType() const
{
	
	return twrap_media_msrp;
}

const InviteSession* InviteEvent::getSession() const
{
	return 0;
}

CallSession* InviteEvent::takeCallSessionOwnership() const
{

	return tsk_null;
}

MsrpSession* InviteEvent::takeMsrpSessionOwnership() const
{

	return tsk_null;
}

/* ======================== MessagingEvent ========================*/


MessagingEvent::~MessagingEvent()
{
}



const MessagingSession* MessagingEvent::getSession() const
{
	return dyn_cast<const MessagingSession*>(this->getBaseSession());
}

MessagingSession* MessagingEvent::takeSessionOwnership() const
{

	return tsk_null;
}

/* ======================== OptionsEvent ========================*/

OptionsEvent::~OptionsEvent()
{
}


const OptionsSession* OptionsEvent::getSession() const
{
	return dyn_cast<const OptionsSession*>(this->getBaseSession());
}

OptionsSession* OptionsEvent::takeSessionOwnership() const
{

	return tsk_null;
}


/* ======================== PublicationEvent ========================*/

PublicationEvent::~PublicationEvent()
{
}

const PublicationSession* PublicationEvent::getSession() const
{
	return dyn_cast<const PublicationSession*>(this->getBaseSession());
}




RegistrationEvent::~RegistrationEvent()
{
}


const RegistrationSession* RegistrationEvent::getSession() const
{
	return dyn_cast<const RegistrationSession*>(this->getBaseSession());
}

RegistrationSession* RegistrationEvent::takeSessionOwnership() const
{
	return tsk_null;
}


/* ======================== SubscriptionEvent ========================*/

SubscriptionEvent::~SubscriptionEvent()
{
}


const SubscriptionSession* SubscriptionEvent::getSession() const
{
	return dyn_cast<const SubscriptionSession*>(this->getBaseSession());
}