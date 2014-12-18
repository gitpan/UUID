#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <uuid/uuid.h>

#ifndef SvPV_nolen
# define SvPV_nolen(sv) SvPV(sv, na)
#endif

void do_generate(SV *str)
{
    uuid_t uuid;
    uuid_generate( uuid );
    sv_setpvn(str, uuid, sizeof(uuid));
}

void do_unparse(SV *in, SV * out) 
{
    uuid_t uuid;
    char str[37];

    uuid_unparse(SvPV_nolen(in), str);
    sv_setpvn(out, str, 36);
}

int do_parse(SV *in, SV * out) 
{
    uuid_t uuid;
    char str[37];
    int rc;

    rc = uuid_parse(SvPV_nolen(in), uuid);
    if (!rc) { 
        sv_setpvn(out, uuid, sizeof(uuid));
    }
    return rc;
}

SV* do_uuid()
{
    uuid_t uuid;
    char str[37];

    uuid_generate(uuid);
    uuid_unparse(uuid, str);
    return newSVpv(str, 36);
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

SV*
uuid()
    PROTOTYPE:
    CODE:
    RETVAL = do_uuid();
    OUTPUT:
    RETVAL

