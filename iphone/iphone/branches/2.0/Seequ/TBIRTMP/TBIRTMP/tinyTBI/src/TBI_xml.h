 

/**@file TBI_xml.h
 * @brief Useful functions to manipulate xml document.
 *

 *

 */
#ifndef _TINYTBI_XML_H_
#define _TINYTBI_XML_H_

#include "tinysak_config.h"
#include "TBI_list.h"

#if HAVE_LIBXML2_H
#include <libxml/tree.h>

#define TBI_XML_NODE_IS_TEXTVALUE(node)							(node && node->type==XML_TEXT_NODE)
#define TBI_XML_NODE_SAFE_GET_TEXTVALUE(node)					(const char*)(TBI_XML_NODE_IS_TEXTVALUE(node)?(node->content):0)
#define TBI_XML_NODE_SKIP_COMMENTS(node)						while(node && (node->type==XML_COMMENT_NODE)) node = TBI_xml_find_node(node, 0, nft_next);
		

#define TBI_XML_NODE_SELECT_BY_NAME(qname)						nst_by_name, qname
#define TBI_XML_NODE_SELECT_BY_ATT(qname, att_name, att_value)	nst_by_att, qname, att_name, att_value
#define TBI_XML_NODE_SELECT_ATT_VALUE(qname, att_name)			nst_att_value, qname, att_name
#define TBI_XML_NODE_SELECT_CONTENT()							nst_content
#define TBI_XML_NODE_SELECT_END()								nst_end

#define TBI_XML_NAMESPACE_CREATE()								TBI_object_new(TBI_xml_namespace_def_t)
#define TBI_XML_NAMESPACE_FREE(self)							TBI_object_unref(self), self = 0

#define TBI_XML_ELEMENT_CREATE(element)							TBI_object_new(TBI_xml_element_def_t)
#define TBI_XML_ELEMENT_FREE(self)								TBI_object_unref(self), self = 0

#define TBI_XML_ATTRIBUTE_CREATE(attribute)						TBI_object_new(TBI_xml_attribute_def_t)
#define TBI_XML_ATTRIBUTE_FREE(self)							TBI_object_unref(self), self = 0

#define TBI_XML_SERIALIZE(result, element, strValue)\
	if(strValue) TBI_sprintf(&result, "<"##element##">%s</"##element##">", strValue); \
	else TBI_strupdate(&result, "");

/** C and XML Schema mapping */
typedef enum TBI_xml_type_e
{
	xt_none,
	xt_string,			/* xsd:string */
	xt_byte,			/* xsd:byte */
	xt_unsignedByte,	/* xsd:unsignedByte */
	xt_short,			/* xsd:short */
	xt_unsignedShort,	/* xsd:unsignedShort */
	xt_int,				/* xsd:int */
	xt_unsignedInt,		/* xsd:unsignedInt */
	xt_long,			/* xsd:long */
	xt_boolean,			/* xsd:boolean */
	xt_float,			/* xsd:float */
	xt_double			/* xsd:double */
}
TBI_xml_type_t;

/** Node finding types */
typedef enum TBI_xml_node_find_type_s
{
	nft_none,
	nft_children,
	nft_parent,
	nft_next,
	nft_prev
}
TBI_xml_node_find_type_t;

/** Element selection types */
typedef enum TBI_xml_node_select_type_s
{
	nst_by_name,
	nst_by_att,
	nst_att_value,
	nst_content,
	nst_end
}
TBI_xml_node_select_type_t;

/** XML namespace */
typedef struct TBI_xml_namespace_s
{
	TBI_DECLARE_OBJECT;

	char* prefix;
	char* value;
}
TBI_xml_namespace_t;

/** XML attribute */
typedef struct TBI_xml_attribute_s
{
	TBI_DECLARE_OBJECT;

	char* name;
	void* value;
	TBI_xml_type_t type;
}
TBI_xml_attribute_t;

/** XML element */
typedef struct TBI_xml_element_s
{
	TBI_DECLARE_OBJECT;

	char* name;
	void* value;
	TBI_list_t* elements;
	TBI_list_t* attributes;
	TBI_list_t* namespaces;
	TBI_xml_type_t type;
}
TBI_xml_element_t;

typedef TBI_list_t TBI_xml_elements_t;
typedef TBI_list_t TBI_xml_attributes_t;
typedef TBI_list_t TBI_xml_namespaces_t;

#define TBI_xml_elements_init		TBI_list_init
#define TBI_xml_attributes_init		TBI_list_init
#define TBI_xml_namespaces_init		TBI_list_init

#define TBI_xml_elements_add		TBI_list_add_data
#define TBI_xml_attributes_add		TBI_list_add_data
#define TBI_xml_namespaces_add		TBI_list_add_data

#define TBI_xml_elements_free		TBI_list_free
#define TBI_xml_attributes_free		TBI_list_free
#define TBI_xml_namespaces_free		TBI_list_free

//TINYSAK_API void TBI_xml_namespace_init(TBI_xml_namespace_t* _namespace);
//TINYSAK_API void TBI_xml_namespace_free(TBI_xml_namespace_t** _namespace);

//TINYSAK_API void TBI_xml_element_init(TBI_xml_element_t* element);
TINYSAK_API void TBI_xml_element_init_set(TBI_xml_element_t** element, const char* name, const char* value, TBI_xml_type_t type);
//TINYSAK_API void TBI_xml_element_free(void** element);

//TINYSAK_API void TBI_xml_attribute_init(TBI_xml_attribute_t* attribute);
//TINYSAK_API void TBI_xml_attribute_free(TBI_xml_attribute_t** attribute);

TINYSAK_API xmlNsPtr TBI_xml_get_namespace(xmlDocPtr docPtr, xmlNodePtr node, const char *href);
TINYSAK_API xmlNodePtr TBI_xml_find_node(const xmlNodePtr curr, const char* name, TBI_xml_node_find_type_t ftype);
TINYSAK_API xmlNodePtr TBI_xml_select_node(const xmlNodePtr root, ...);

TINYSAK_GEXTERN const void *TBI_xml_namespace_def_t;
TINYSAK_GEXTERN const void *TBI_xml_attribute_def_t;
TINYSAK_GEXTERN const void *TBI_xml_element_def_t;

#endif /* HAVE_LIBXML2_H */

#endif /* _TINYTBI_XML_H_ */

