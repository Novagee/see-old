
#ifndef TINYWRAP_SIPSTACK_H
#define TINYWRAP_SIPSTACK_H

#include "SipCallback.h"
#include "SafeObject.h"



class DDebugCallback;

class SipStack: public SafeObject
{
public: /* ctor() and dtor() */
	SipStack(SipCallback* pCallback, const char* realm_uri, const char* impi_uri, const char* impu_uri);
    ~SipStack();

public: /* API functions */
	bool start();
	bool setDebugCallback(DDebugCallback* pCallback);
	bool setRealm(const char* realm_uri);
	bool setIMPI(const char* impi);
	bool setIMPU(const char* impu_uri);
	bool setPassword(const char* password);
	bool setAMF(const char* amf);
	bool setOperatorId(const char* opid);
	bool setProxyCSCF(const char* fqdn, unsigned short port, const char* transport, const char* ipversion);
	bool setLocalIP(const char* ip);
	bool setLocalPort(unsigned short port);
	bool setEarlyIMS(bool enabled);
	bool addHeader(const char* name, const char* value);
	bool removeHeader(const char* name);
	bool addDnsServer(const char* ip);
	bool setDnsDiscovery(bool enabled);
	bool setAoR(const char* ip, int port);
#if !defined(SWIG)
	bool setModeServer();
#endif

	bool setSigCompParams(unsigned dms, unsigned sms, unsigned cpb, bool enablePresDict);
	bool addSigCompCompartment(const char* compId);
	bool removeSigCompCompartment(const char* compId);
	
	bool setSTUNServer(const char* ip, unsigned short port);
	bool setSTUNCred(const char* login, const char* password);

	bool setTLSSecAgree(bool enabled);
	bool setSSLCretificates(const char* privKey, const char* pubKey, const char* caKey);
	bool setIPSecSecAgree(bool enabled);
	bool setIPSecParameters(const char* algo, const char* ealgo, const char* mode, const char* proto);
	
	char* dnsENUM(const char* service, const char* e164num, const char* domain);
	char* dnsNaptrSrv(const char* domain, const char* service, unsigned short *OUTPUT);
	char* dnsSrv(const char* service, unsigned short* OUTPUT);

	char* getLocalIPnPort(const char* protocol, unsigned short* OUTPUT);

	char* getPreferredIdentity();
	bool isAOR ;
	bool isValid();
	bool stop();
	
	static bool initialize();
	static bool deInitialize();

public: /* Public helper function */
#if !defined(SWIG)

	inline SipCallback* getCallback()const{
		return m_pCallback;
	}
	inline DDebugCallback* getDebugCallback() const{
		return m_pDebugCallback;
	}
#endif

private:
	SipCallback* m_pCallback;
	DDebugCallback* m_pDebugCallback;

	static bool g_bInitialized;
};

#endif /* TINYWRAP_SIPSTACK_H */
