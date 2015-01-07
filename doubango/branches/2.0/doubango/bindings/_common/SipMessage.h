
#ifndef TINYWRAP_SIPMESSAGE_H
#define TINYWRAP_SIPMESSAGE_H


class SdpMessage
{
public:
	SdpMessage();
#if !defined(SWIG)

#endif
	virtual ~SdpMessage();

	char* getSdpHeaderValue(const char* media, char name, unsigned index = 0);
	char* getSdpHeaderAValue(const char* media, const char* attributeName);

private:
};

class SipMessage
{
public:
	SipMessage();
#if !defined(SWIG)
#endif
	virtual ~SipMessage();
	
	bool isResponse();
	short getResponseCode();
	char* getSipHeaderValue(const char* name, unsigned index = 0);
	char* getSipHeaderParamValue(const char* name, const char* param, unsigned index = 0);
	unsigned getSipContentLength();
	unsigned getSipContent(void* output, unsigned maxsize);
#if !defined(SWIG)
	const void* getSipContentPtr();
#endif
	const SdpMessage* getSdpMessage();

private:

private:
	SdpMessage *m_pSdpMessage;
};

#endif /* TINYWRAP_SIPMESSAGE_H */
