
#include "SipMessage.h"



SdpMessage::~SdpMessage()
{

}

char* SdpMessage::getSdpHeaderValue(const char* media, char name, unsigned index /*= 0*/)
{

	return 0;
}

char* SdpMessage::getSdpHeaderAValue(const char* media, const char* attributeName)
{
	
	return 0;
}




SipMessage::~SipMessage()
{
}

bool SipMessage::isResponse()
{
    return 0;}

short SipMessage::getResponseCode()
{
    return 0;
}


// e.g. getHeaderParamValue("content-type");
char* SipMessage::getSipHeaderValue(const char* name, unsigned index /* = 0*/)
{
	    return 0;
}

// e.g. getHeaderParamValue("content-type", "charset");
char* SipMessage::getSipHeaderParamValue(const char* name, const char* param, unsigned index /*=0*/)
{
	    return 0;
}

/** Returns the content length.
*/
unsigned SipMessage::getSipContentLength()
{
    return 0;}

/** Gets the message content
* @param output A pointer to the output buffer where to copy the data. MUST
* be allocated by the caller.
* @param maxsize The maximum number of octets to copy. Should be less than the size of the
* @a output buffer. You can use @a getSipContentLength() to get the right value to use.
* @retval The number of octet copied in the @a output buffer.
*/
unsigned SipMessage::getSipContent(void* output, unsigned maxsize)
{
	    return 0;
}

const void* SipMessage::getSipContentPtr()
{
	    return 0;
}

const SdpMessage* SipMessage::getSdpMessage()
{
	
	return 0;
}
