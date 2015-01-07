#include "SipStack.h"

#include "SipSession.h"
#include "SipEvent.h"

#include "DDebug.h"

#include "Common.h"

bool SipStack::g_bInitialized = false;




/* === default values === */
#ifndef DEFAULT_LOCAL_IP
//#	ifdef ANDROID /* On the emulator */
//#		define DEFAULT_LOCAL_IP	"10.0.2.15"
//#	else
#		define DEFAULT_LOCAL_IP	TNET_SOCKET_HOST_ANY
//#	endif
#endif

SipStack::SipStack(SipCallback* pCallback, const char* realm_uri, const char* impi_uri, const char* impu_uri)
:SafeObject()
{
	
}

SipStack::~SipStack()
{

	/* Destroy stack handle */
}

bool SipStack::start()
{
	return 0;
}

bool SipStack::setDebugCallback(DDebugCallback* pCallback)
{

	return true;
}

bool SipStack::setRealm(const char* realm_uri)
{
	return 0;

}

bool SipStack::setIMPI(const char* impi)
{
	return 0;

}

bool SipStack::setIMPU(const char* impu_uri)
{
	return 0;

}

bool SipStack::setPassword(const char* password)
{
	return 0;

}

bool SipStack::setAMF(const char* amf)
{
	return 0;

}

bool SipStack::setOperatorId(const char* opid)
{
	return 0;

}

bool SipStack::setProxyCSCF(const char* fqdn, unsigned short port, const char* transport, const char* ipversion)
{
	return 0;

}

bool SipStack::setLocalIP(const char* ip)
{
	return 0;

}

bool SipStack::setLocalPort(unsigned short port)
{
	return 0;

}

bool SipStack::setEarlyIMS(bool enabled){
	return 0;

}

bool SipStack::addHeader(const char* name, const char* value)
{
	return 0;

}

bool SipStack::removeHeader(const char* name)
{
	return 0;

}

bool SipStack::addDnsServer(const char* ip)
{
	return 0;

}

bool SipStack::setDnsDiscovery(bool enabled)
{
	tsk_bool_t _enabled = enabled;// 32bit/64bit workaround
	return 0;

}

bool SipStack::setAoR(const char* ip, int port)
{
	return 0;

}

bool SipStack::setModeServer()
{
	return 0;

}

bool SipStack::setSigCompParams(unsigned dms, unsigned sms, unsigned cpb, bool enablePresDict)
{
	return 0;
}

bool SipStack::addSigCompCompartment(const char* compId)
{
	return 0;
}

bool SipStack::removeSigCompCompartment(const char* compId)
{
	return 0;
}

bool SipStack::setSTUNServer(const char* ip, unsigned short port)
{
	return 0;
}

bool SipStack::setSTUNCred(const char* login, const char* password)
{
	return 0;
}

bool SipStack::setTLSSecAgree(bool enabled)
{

	return 0;
}

bool SipStack::setSSLCretificates(const char* privKey, const char* pubKey, const char* caKey)
{
	return 0;
}

bool SipStack::setIPSecSecAgree(bool enabled)
{
	return 0;
}

bool SipStack::setIPSecParameters(const char* algo, const char* ealgo, const char* mode, const char* proto)
{
	return 0;
}

char* SipStack::dnsENUM(const char* service, const char* e164num, const char* domain)
{

}

char* SipStack::dnsNaptrSrv(const char* domain, const char* service, unsigned short *OUTPUT)
{
//	tnet_dns_ctx_t* dnsctx = tsip_stack_get_dnsctx(m_pHandle);
//	char* ip = tsk_null;
//	tnet_port_t port;
//	*OUTPUT = 0;
//	
//
//	if(dnsctx){
//		if(!tnet_dns_query_naptr_srv(dnsctx, domain, service, &ip, &port)){
//			*OUTPUT = port;
//		}
//		tsk_object_unref(dnsctx);
//		return ip;
//	}
//	else{
//		TSK_DEBUG_ERROR("No DNS Context could be found");
//		return tsk_null;
//	}
}

char* SipStack::dnsSrv(const char* service, unsigned short* OUTPUT)
{
//	tnet_dns_ctx_t* dnsctx = tsip_stack_get_dnsctx(m_pHandle);
//	char* ip = tsk_null;
//	tnet_port_t port = 0;
//	*OUTPUT = 0;
//
//	if(dnsctx){
//		if(!tnet_dns_query_srv(dnsctx, service, &ip, &port)){
//			*OUTPUT = port;
//		}
//		tsk_object_unref(dnsctx);
//		return ip;
//	}
//	else{
//		TSK_DEBUG_ERROR("No DNS Context could be found");
//		return tsk_null;
//	}
}

char* SipStack::getLocalIPnPort(const char* protocol, unsigned short* OUTPUT)
{

	return 0; // See Swig %newobject
}

char* SipStack::getPreferredIdentity()
{
	return 0;
}

bool SipStack::isValid()
{
	return 0;
}

bool SipStack::stop()
{
	return 0;
}

bool SipStack::initialize()
{

	return true;
}

bool SipStack::deInitialize()
{
	return false;
}





