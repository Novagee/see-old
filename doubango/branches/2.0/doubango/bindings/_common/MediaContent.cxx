
#include "MediaContent.h"



MediaContent::MediaContent(tmedia_content_t* pContent)
: m_pData(tsk_null)
{
	m_pContent = (tmedia_content_t*)tsk_object_ref(pContent);
}

MediaContent::~MediaContent()
{
	TSK_OBJECT_SAFE_FREE(m_pContent);
	TSK_OBJECT_SAFE_FREE(m_pData);
}

const char* MediaContent::getType()
{
	if(m_pContent){
		return m_pContent->type;
	}
	return tsk_null;
}

unsigned MediaContent::getDataLength()
{

	return 0;
}

unsigned MediaContent::getData(void* pOutput, unsigned nMaxsize)
{
	unsigned nRetsize = 0;

	return nRetsize;
}

MediaContent* MediaContent::parse(const void* pData, unsigned nSize, const char* pType)
{
	MediaContent* pMediaContent = tsk_null;

	tmedia_content_t* pContent = tmedia_content_parse(pData, (tsk_size_t)nSize, pType);
	if(pContent){
		if(TMEDIA_CONTENT_IS_CPIM(pContent)){
			pMediaContent = new MediaContentCPIM(pContent);
		}
		else if(TMEDIA_CONTENT_IS_DUMMY(pContent)){
			// Todo
		}
		TSK_OBJECT_SAFE_FREE(pContent);
	}

	return pMediaContent;
}

MediaContentCPIM* MediaContent::parse(const void* pData, unsigned nSize)
{
	MediaContent* pMediaContent;
	if((pMediaContent = MediaContent::parse(pData, nSize, TMEDIA_CONTENT_CPIM_TYPE))){
		return dyn_cast<MediaContentCPIM*>(pMediaContent);
	}
	return tsk_null;
}

/* ============ message/CPIM ================= */

MediaContentCPIM::MediaContentCPIM(tmedia_content_t* pContent)
: MediaContent(pContent)
{
}

MediaContentCPIM::~MediaContentCPIM()
{
}

unsigned MediaContentCPIM::getPayloadLength()
{

	return 0;
}

unsigned MediaContentCPIM::getPayload(void* pOutput, unsigned nMaxsize)
{

	return 0;
}

const void* MediaContentCPIM::getPayloadPtr(){
	
	return TMEDIA_CONTENT_CPIM(m_pContent)->e ? TMEDIA_CONTENT_CPIM(m_pContent)->e->data : tsk_null;
}

const char* MediaContentCPIM::getHeaderValue(const char* name)
{

	return tsk_null;
}