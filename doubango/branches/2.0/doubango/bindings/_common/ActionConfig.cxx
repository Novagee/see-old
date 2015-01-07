

#include "ActionConfig.h"



ActionConfig::ActionConfig()
{

}

ActionConfig::~ActionConfig()
{
}

bool ActionConfig::addHeader(const char* name, const char* value)
{
    return 0;
}

ActionConfig* ActionConfig::setResponseLine(short code, const char* phrase)
{
    return 0;}

ActionConfig* ActionConfig::setMediaString(twrap_media_type_t type, const char* key, const char* value)
{
    return 0;}

ActionConfig* ActionConfig::setMediaInt(twrap_media_type_t type, const char* key, int value)
{
    return 0;
}
