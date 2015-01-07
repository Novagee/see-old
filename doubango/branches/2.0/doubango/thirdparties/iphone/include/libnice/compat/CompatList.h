
#ifndef COMPAT_LIST
#define COMPAT_LIST


typedef struct CompatList CompatList;

struct CompatList
{
	void* data;
	CompatList* next;
	CompatList* prev;
};
typedef CompatList* CompatListRef;
CompatList* compat_list_prepend(CompatList* list, void* data);
// Very inefficient
CompatList* compat_list_append(CompatList* list, void* data);

// Elements of "other" are used directly.
CompatList* compat_list_concat (CompatList* list, CompatList* other);

CompatList* compat_list_remove(CompatList *list, const void* data);

CompatList* compat_list_last(CompatList *list);

CompatList* compat_list_first(CompatList *list);

// Functional programming:
typedef void (*CompatFunc) (void* data, void* user_data);
typedef int (*CompatCompareFunc) (void* first, void* second);

void compat_list_foreach(CompatList *list, CompatFunc func, void* user_data);

void compat_list_free(CompatList *list);
#define compat_list_next(list) (list->next)

int compat_list_length(CompatList *list);

CompatList *compat_list_delete_link(CompatList *list, CompatList *link);

//Make it think we have GLib

#define GList CompatList
#define g_list_free(l) compat_list_free(l)
#define g_list_prepend(list,data) compat_list_prepend(list,data)
#define g_list_append(list,data) compat_list_append(list,data)
#define g_list_remove(l,d) compat_list_remove(l,d)
#define g_list_concat(list,other) compat_list_concat(list,other)
#define g_list_last(list) compat_list_last(list)
#define g_list_first(list) compat_list_first(list)
#define g_list_foreach(l,f,ud) compat_list_foreach(l,f,ud)
#define g_list_next(l) compat_list_next(l)
#define g_list_length(list) compat_list_length(list)
#define g_list_delete_link(list, link) compat_list_delete_link(list, link)
#define GFunc CompatFunc
#define GCompareFunc CompatCompareFunc

// Single Linked List stuff:

typedef struct CompatSList CompatSList;
struct CompatSList
{
	void* data;
	CompatSList* next;

};

void compat_slist_free(CompatSList *list);
CompatSList *compat_slist_append(CompatSList *list, void *data);
CompatSList *compat_slist_last(CompatSList *list);
void compat_slist_foreach(CompatSList *list, CompatFunc func, void* user_data);
int compat_slist_length(CompatSList *list);
CompatSList *compat_slist_next(CompatSList *l);
CompatSList *compat_slist_nth(CompatSList *list, int n);
CompatSList *compat_slist_remove(CompatSList *list, void *data);
CompatSList* compat_slist_insert_sorted(CompatSList* list, void* data, CompatCompareFunc f);
void compat_slist_free1(CompatSList *l);

#define GSList CompatSList

#define g_slist_free(list) compat_slist_free(list)
#define g_slist_append(list, data) compat_slist_append(list, data)
#define g_slist_last(list) compat_slist_last(list)
#define g_slist_nth(list, n) compat_slist_nth(list, n)
#define g_slist_foreach(l,f,ud) compat_slist_foreach(l,f,ud)
#define g_slist_next(l) compat_slist_next(l)
#define g_slist_length(list) compat_slist_length(list)
#define g_slist_remove(list, data) compat_slist_remove(list, data)
#define g_slist_insert_sorted(l,d,f) compat_slist_insert_sorted(l, d, f)


#endif // COMPAT_LIST