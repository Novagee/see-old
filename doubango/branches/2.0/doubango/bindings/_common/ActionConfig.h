
#ifndef TINYWRAP_ACTIONCONFIG_H
#define TINYWRAP_ACTIONCONFIG_H

#include "Common.h"

class ActionConfig
{
public:
	ActionConfig();
	virtual ~ActionConfig();
	
	bool addHeader(const char* name, const char* value);
	
	ActionConfig* setResponseLine(short code, const char* phrase);
	ActionConfig* setMediaString(twrap_media_type_t type, const char* key, const char* value);
	ActionConfig* setMediaInt(twrap_media_type_t type, const char* key, int value);
	
private:

#if !defined(SWIG)
public:

#endif
};


#endif /* TINYWRAP_ACTIONCONFIG_H */
