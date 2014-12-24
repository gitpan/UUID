#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifdef PERL__UUID__UUID_UUID_H
#include <uuid/uuid.h>
#elif PERL__UUID__UUID_H
#include <uuid.h>
#endif

#ifndef SvPV_nolen
# define SvPV_nolen(sv) SvPV(sv, na)
#endif

/*
#define SV2UUID(s) ((unsigned char*)SvPV_nolen(s))
#define UUID2SV(u) ((char*)u)
*/


#ifdef PERL__UUID__UUID_UUID_H
#define SV2UUID(s) ((unsigned char*)SvPV_nolen(s))
#define UUID2SV(u) ((char*)u)
#elif PERL__UUID__UUID_H
#define SV2UUID(s) ((unsigned char*)SvPV_nolen(s))
#define UUID2SV(u) ((char*)u)
#endif


void do_generate(SV *str) {
    uuid_t uuid;
#ifdef PERL__UUID__UUID_UUID_H
    uuid_generate( uuid );
#elif PERL__UUID__UUID_H
    int32_t s;
    uuid_create(&uuid, &s);
#endif
    sv_setpvn(str, UUID2SV(uuid), sizeof(uuid_t));
}


void do_generate_random(SV *str) {
    uuid_t uuid;
#ifdef PERL__UUID__UUID_UUID_H
    uuid_generate_random( uuid );
#elif PERL__UUID__UUID_H
    int32_t s;
    uuid_create(&uuid, &s);
#endif
    sv_setpvn(str, UUID2SV(uuid), sizeof(uuid_t));
}


void do_generate_time(SV *str) {
    uuid_t uuid;
#ifdef PERL__UUID__UUID_UUID_H
    uuid_generate_time( uuid );
#elif PERL__UUID__UUID_H
    int32_t s;
    uuid_create(&uuid, &s);
#endif
    sv_setpvn(str, UUID2SV(uuid), sizeof(uuid_t));
}


void do_unparse(SV *in, SV * out) {
    char str[37];
#ifdef PERL__UUID__UUID_UUID_H
    uuid_unparse(SV2UUID(in), str);
    sv_setpvn(out, str, 36);
#elif PERL__UUID__UUID_H
    int32_t s;
    /* this mallocs */
    uuid_to_string(SV2UUID(in),&str,&s);
    sv_setpvn(out, str, 36);
    free(str);
#endif
}


void do_unparse_lower(SV *in, SV * out) {
    char str[37];
#ifdef PERL__UUID__UUID_UUID_H
    uuid_unparse_lower(SV2UUID(in), str);
    sv_setpvn(out, str, 36);
#elif PERL__UUID__UUID_H
    int32_t s;
    /* this mallocs */
    uuid_to_string(SV2UUID(in),&str,&s);
    for(; *p; ++p) *p = tolower(*p);
    sv_setpvn(out, str, 36);
    free(str);
#endif
}


void do_unparse_upper(SV *in, SV * out) {
    char str[37];
#ifdef PERL__UUID__UUID_UUID_H
    uuid_unparse_upper(SV2UUID(in), str);
    sv_setpvn(out, str, 36);
#elif PERL__UUID__UUID_H
    int32_t s;
    /* this mallocs */
    uuid_to_string(SV2UUID(in),&str,&s);
    for( ; *p; ++p) *p = toupper(*p);
    sv_setpvn(out, str, 36);
    free(str);
#endif
}


int do_parse(SV *in, SV * out) {
    uuid_t uuid;
    int rc;
#ifdef PERL__UUID__UUID_UUID_H
    rc = uuid_parse(SvPV_nolen(in), uuid);
#elif PERL__UUID__UUID_H
    uuid_from_string(str,&uuid,&rc);
#endif
    if (!rc) { 
        sv_setpvn(out, UUID2SV(uuid), sizeof(uuid_t));
    }
    return rc;
}


void do_clear(SV *in) {
    uuid_t uuid;
#ifdef PERL__UUID__UUID_UUID_H
    uuid_clear(uuid);
#elif PERL__UUID__UUID_H
    int32_t s;
    uuid_create_nil(&uuid,&s);
#endif
    sv_setpvn(in, UUID2SV(uuid), sizeof(uuid_t));
}


int do_is_null(SV *in) {
#ifdef PERL__UUID__UUID_UUID_H
    if( SvCUR(in) != sizeof(uuid_t) )
        return 0;
    return uuid_is_null(SV2UUID(in));
#elif PERL__UUID__UUID_H
    int32_t s;
    return uuid_is_nil(SV2UUID(in),&s);
#endif
}


int do_compare(SV *uu1, SV *uu2) {
#ifdef PERL__UUID__UUID_UUID_H
    if( SvCUR(uu1) == sizeof(uuid_t) )
        if( SvCUR(uu2) == sizeof(uuid_t) )
            return uuid_compare(SV2UUID(uu1), SV2UUID(uu2));
#elif PERL__UUID__UUID_H
    int32_t s;
    if( SvCUR(uu1) == sizeof(uuid_t) )
        if( SvCUR(uu2) == sizeof(uuid_t) )
            return uuid_compare(SV2UUID(uu1), SV2UUID(uu2), &s);
#endif
    return sv_cmp(uu1, uu2);
}


void do_copy(SV *dst, SV *src) {
    uuid_t uuid;
#ifdef PERL__UUID__UUID_UUID_H
    if( SvCUR(src) != sizeof(uuid_t) )
        uuid_clear(uuid);
    else
        uuid_copy(uuid, SV2UUID(src));
#elif PERL__UUID__UUID_H
    int32_t s;
    if( SvCUR(src) != sizeof(uuid_t) )
        uuid_create_nil(uuid, &s);
    else
        uuid_copy(uuid, SV2UUID(src), &s);
#endif
    sv_setpvn(dst, UUID2SV(uuid), sizeof(uuid_t));
}


SV* do_uuid() {
    uuid_t uuid;
    char str[37];
#ifdef PERL__UUID__UUID_UUID_H
    uuid_generate(uuid);
    uuid_unparse(uuid, str);
    return newSVpv(str, 36);
#elif PERL__UUID__UUID_H
    int32_t s;
    SV *ss;
    uuid_create(&uuid, &s);
    /* this mallocs */
    uuid_to_string(&uuid, &str, &s);
    ss = newSVpv(str, 36);
    free(str);
    return ss;
#endif
}



MODULE = UUID		PACKAGE = UUID		

void
generate(str)
    SV * str
    PROTOTYPE: $
    CODE:
    do_generate(str); 

void
generate_random(str)
    SV * str
    PROTOTYPE: $
    CODE:
    do_generate_random(str); 

void
generate_time(str)
    SV * str
    PROTOTYPE: $
    CODE:
    do_generate_time(str); 

void
unparse(in, out)
    SV * in
    SV * out
    PROTOTYPE: $$
    CODE:
    do_unparse(in, out);

void
unparse_lower(in, out)
    SV * in
    SV * out
    PROTOTYPE: $$
    CODE:
    do_unparse_lower(in, out);

void
unparse_upper(in, out)
    SV * in
    SV * out
    PROTOTYPE: $$
    CODE:
    do_unparse_upper(in, out);

int
parse(in, out)
    SV * in
    SV * out
    PROTOTYPE: $$
    CODE: 
    RETVAL = do_parse(in, out);
    OUTPUT:
    RETVAL

void
clear(in)
    SV * in
    PROTOTYPE: $
    CODE:
    do_clear(in);

int
is_null(in)
    SV * in
    PROTOTYPE: $
    CODE:
    RETVAL = do_is_null(in);
    OUTPUT:
    RETVAL

void
copy(dst, src)
    SV * dst
    SV * src
    CODE:
    do_copy(dst, src);

int
compare(uu1, uu2)
    SV * uu1
    SV * uu2
    CODE:
    RETVAL = do_compare(uu1, uu2);
    OUTPUT:
    RETVAL

SV*
uuid()
    PROTOTYPE:
    CODE:
    RETVAL = do_uuid();
    OUTPUT:
    RETVAL

