#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifdef WIN32
#include <windows.h>
#include <memory.h>
#include <rpc.h>
#include <rpcdce.h>
#else
#include <uuid/uuid.h>
#endif

#ifndef SvPV_nolen
# define SvPV_nolen(sv) SvPV(sv, na)
#endif

/*
 * returns binary UUID
 */
void do_generate(SV *str)
{
#ifdef WIN32
	UUID wuuid;
	char uuid[16];
	char *pcopy = (char* ) &uuid;
#else
	uuid_t uuid;
#endif

#ifdef WIN32
	if (UuidCreate(&wuuid) != RPC_S_OK)
		croak("cannot create UUID");
	memcpy(pcopy, &wuuid.Data1, 4); pcopy += 4;
	memcpy(pcopy, &wuuid.Data2, 2); pcopy += 2;
	memcpy(pcopy, &wuuid.Data3, 2); pcopy += 2;
	memcpy(pcopy, &wuuid.Data4, 8); pcopy += 8;
#else
	uuid_generate(uuid);
#endif

	sv_setpvn(str, uuid, sizeof(uuid));
}

/*
 * converts binary UUID to string
 */
void do_unparse(SV *in, SV * out) 
{
#ifdef WIN32
	unsigned char *pstr = NULL;
	unsigned char *uuid;
	UUID wuuid;
#else
	uuid_t uuid;
#endif
	char str[37];
	
#ifdef WIN32
	uuid = SvPV_nolen(in);
	memcpy((char*) &wuuid, uuid, 16);
	if (UuidToString(&wuuid, &pstr) != RPC_S_OK)
		croak("cannot convert UUID to string");
	str[0] = NULL;
	strcpy(str, pstr);
	RpcStringFree(&pstr);
#else
	uuid_unparse(SvPV_nolen(in), str);
#endif
	sv_setpvn(out, str, 36);
}

/*
 * converts string to binary UUID
 */
int do_parse(SV *in, SV * out) 
{
#ifdef WIN32
	UUID wuuid;
	char uuid[16];
	char *pstr;
#else
	uuid_t uuid;
#endif
	int rc = 0;
	
#ifdef WIN32
	pstr = SvPV_nolen(in);
	if (UuidFromString(pstr, &wuuid) != RPC_S_OK) {
		rc = -1;
	} else {
		memcpy((char*) &uuid, (char*) &wuuid, 16);
	}
#else
	rc = uuid_parse(SvPV_nolen(in), uuid);
#endif
	
	if (rc != -1)
		sv_setpvn(out, uuid, sizeof(uuid));
	
	return rc;
}

MODULE = UUID		PACKAGE = UUID		

void
generate(str)
	SV * str
	PROTOTYPE: $
	CODE:
	do_generate(str); 

void
unparse(in, out)
	SV * in
	SV * out
	PROTOTYPE: $$
	CODE:
	do_unparse(in, out);

int
parse(in, out)
	SV * in
	SV * out
	PROTOTYPE: $$
	CODE: 
	RETVAL = do_parse(in, out);
	OUTPUT:
	RETVAL
