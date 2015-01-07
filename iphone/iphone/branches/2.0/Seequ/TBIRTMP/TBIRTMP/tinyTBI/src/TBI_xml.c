 

/**@file TBI_xml.c
 * @brief Useful functions to manipulate xml documents.
 *

 *

 */
#include "TBI_xml.h"

#if HAVE_LIBXML2_H

#include "TBI_string.h"
#include "TBI_memory.h"
#include "TBI_macros.h"

#include <string.h>

/**@defgroup TBI_xml_group XML
*/

/**@page TBI_xml_page XML Tutorial
*/


/**@ingroup TBI_xml_group
* Initialize an XML namespace
* @param namespace The XML namespace to initialize.
*/
/*void TBI_xml_namespace_init(TBI_xml_namespace_t* namespace)
{
}*/

/**@ingroup TBI_xml_group
* Free an XML namespace
* @param namespace The namespace to free
*/
/*void TBI_xml_namespace_free(TBI_xml_namespace_t** namespace)
{
	TBI_FREE((*namespace)->prefix);
	TBI_FREE((*namespace)->value);
	TBI_FREE(namespace);
}*/

/**@ingroup TBI_xml_group
* Initialize an XML element
* @param element The XML element to initialize
*/
/*void TBI_xml_element_init(TBI_xml_element_t* element)
{
}*/

/**@ingroup TBI_xml_group
* Initialize an XML element and set values
* @param element The XML element to initialize
* @param name The element name
* @param value The element value
* @param type The element type
*/
void TBI_xml_element_init_set(TBI_xml_element_t** element, const char* name, const char* value, TBI_xml_type_t type)
{
	TBI_XML_ELEMENT_CREATE((*element));
	(*element)->elements = TBI_LIST_CREATE();
	(*element)->attributes = TBI_LIST_CREATE();
	(*element)->namespaces = TBI_LIST_CREATE();
	(*element)->name = TBI_strdup(name);
	(*element)->value = TBI_strdup(value);
	(*element)->type = type;
}

/**@ingroup TBI_xml_group
* Free an XML element
* @param _element The XML element to free
*/
/*void TBI_xml_element_free(void** _element)
{
	TBI_xml_element_t** element = (TBI_xml_element_t**)_element;

	TBI_FREE((*element)->name);
	TBI_FREE((*element)->value);
	TBI_OBJECT_SAFE_FREE((*element)->elements);
	TBI_OBJECT_SAFE_FREE((*element)->attributes);
	TBI_OBJECT_SAFE_FREE((*element)->namespaces);

	TBI_FREE(element);
}*/

/**@ingroup TBI_xml_group
* Initialize an XML attribute
* @param attribute The XML attribute to initialize
*/
/*void TBI_xml_attribute_init(TBI_xml_attribute_t* attribute)
{
}*/

/**@ingroup TBI_xml_group
* Free an XML attribute
* @param attribute The XML attribute to free
*/
/*void TBI_xml_attribute_free(TBI_xml_attribute_t** attribute)
{
	TBI_FREE((*attribute)->name);
	TBI_FREE((*attribute)->value);

	TBI_FREE(attribute);
}*/

/**@ingroup TBI_xml_group
* Get an XML namespace from an XML document
* @param docPtr A pointer to the XML document
* @param node The XML node from which to extract the namespace
* @param href The namespace href
* @retval The Namespace value matching our criteria (href)
*/
xmlNsPtr TBI_xml_get_namespace(xmlDocPtr docPtr, xmlNodePtr node, const char *href)
{
	xmlNs *ns = *xmlGetNsList(docPtr, node);
	while (ns)
	{
		if (TBI_striequals(ns->href, href)) return ns;
		else ns = ns->next;
	}

	return 0;
}

/**@ingroup TBI_xml_group
* Find an XML node by name
* @param curr The XML node from which to start
* @param name The name of the XML node to find
* @param ftype The find type
* @retval Returns the node which match our criteria. If none match, this method returns NULL.
*/
xmlNodePtr TBI_xml_find_node(const xmlNodePtr curr, const char* name, TBI_xml_node_find_type_t ftype)
{
	xmlNodePtr node = curr;
	
	while(node)
	{
		switch(ftype)
		{
		case nft_none:		return (TBI_striequals(node->name, name))? node : 0;
		case nft_children: node = node->children; break;
		case nft_parent:	node = node->parent; break;
		case nft_next:		node = node->next; break;
		case nft_prev:		node = node->prev; break;
		default: return 0;
		} /* switch */

		/* check and return value if match */
		if( node && (!name || TBI_striequals(node->name, name)) ) 
		//if( node && (name == 0 || !TBI_stricmp((const char*)node->name, name)) ) 
		{
			return node;
		}
	}

	return 0;
}

/**@ingroup TBI_xml_group
* Select an XML node
* @retval Returns the pointer to the node which match our criteria. If none match, this method returns NULL.
*/
xmlNodePtr TBI_xml_select_node(const xmlNodePtr root, ...)
{
	va_list list;
	int step;
	char* root_name = 0;
	xmlNodePtr node = root;

	if(!node || !(node->name)) return 0;

	/* initialize variable arguments */
	va_start(list, root);

	while( node && (step=va_arg(list, TBI_xml_node_select_type_t)) != nst_end)
	{
		switch(step)
		{
		case nst_by_name:
			{	/* name */
				const char* qname = va_arg(list, const char*);
				if(TBI_striequals(root->name, qname)){
					node = TBI_xml_find_node(node, 0, nft_children);
				}
				else{
					if(!TBI_striequals(node->name, qname))
					{	/* do not match */
						node = TBI_xml_find_node(node, qname, nft_next);
					}
					else
					{ /* already match */
						node = node->children;
					}
				}
				break;
			}

		case nst_content:
			{	/**/
				node = TBI_xml_find_node(node, 0, nft_children);
				break;
			}

		case nst_att_value:
			{	/* qname, att_name */
				xmlAttrPtr attrPtr = 0;
				int found = 0;
				const char* qname = va_arg(list, const char*);
				const char* att_name = va_arg(list, const char*);
				node = TBI_xml_find_node(node, qname, nft_none);
				while( node && !found )
				{
					attrPtr = node->properties;
					while(attrPtr)
					{
						if(attrPtr->type == XML_ATTRIBUTE_NODE && attrPtr->children)
						{
							if( TBI_striequals(attrPtr->name, att_name) ){
								node = attrPtr->children;
								found = 1;
							}
						}
						attrPtr = attrPtr->next;
					}
					if(!found) node = TBI_xml_find_node(node, 0, nft_next);
				}
				break;
			}

		case nst_by_att:
			{	/* qname att_name att_value */
				xmlAttrPtr attrPtr = 0;
				int found = 0;
				const char* qname = va_arg(list, const char*);
				const char* att_name = va_arg(list, const char*);
				const char* att_value = va_arg(list, const char*);
				node = TBI_xml_find_node(node, qname, nft_none);
				while( node && !found )
				{
					attrPtr = node->properties;
					while(attrPtr)
					{
						if(attrPtr->type == XML_ATTRIBUTE_NODE && attrPtr->children)
						{
							if( TBI_striequals(attrPtr->name, att_name)
								&& ( (attrPtr->children->content && TBI_striequals(attrPtr->children->content, att_value)) || !att_value )
								){
									found = 1;
							}
						}
						attrPtr = attrPtr->next;
					}
					if(!found) node = TBI_xml_find_node(node, 0, nft_next);
				}

				if(found && node) break;
				else return 0;

				break;
			}
		default: return 0;
		} /* switch */

		/* skip all comments */
		TBI_XML_NODE_SKIP_COMMENTS(node);

	} /* while*/

	return node;
}

#endif /* HAVE_LIBXML2_H */

