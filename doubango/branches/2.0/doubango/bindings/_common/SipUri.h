
#ifndef TINYWRAP_SIPURI_H
#define TINYWRAP_SIPURI_H



class SipUri
{
public:
	~SipUri();

public:
	static bool isValid(const char*);

	bool isValid();
	const char* getScheme();
	const char* getHost();
	unsigned short getPort();
	const char* getUserName();
	const char* getPassword();
	const char* getDisplayName();
	const char* getParamValue(const char* pname);
	void setDisplayName(const char* displayName);
#if !defined(SWIG)

#endif

private:
};

#endif /* TINYWRAP_SIPURI_H */
