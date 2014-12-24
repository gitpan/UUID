#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifdef PERL__UUID__UUID_UUID_H
#include <uuid/uuid.h>
#elif PERL__UUID__UUID_H
#include <uuid.h>
#elif PERL__UUID__RPC_H
#include <Rpc.h>
#endif

#ifndef SvPV_nolen
# define SvPV_nolen(sv) SvPV(sv, na)
#endif

#ifdef PERL__UUID__UUID_UUID_H
#define UUID_T uuid_t
#define SV2UUID(s) ((unsigned char*)SvPV_nolen(s))
#define UUID2SV(u) ((char*)u)
#elif PERL__UUID__UUID_H
#define UUID_T uuid_t
#define SV2UUID(s) ((unsigned char*)SvPV_nolen(s))
#define UUID2SV(u) ((char*)u)
#elif PERL__UUID__RPC_H
#define UUID_T UUID
#define SV2UUID(s) ((unsigned char*)SvPV_nolen(s))
#define UUID2SV(u) ((char*)&u)
#endif


void do_generate(SV *str) {
    UUID_T uuid;
#ifdef PERL__UUID__UUID_UUID_H
    uuid_generate( uuid );
#elif PERL__UUID__UUID_H
    int32_t s;
    uuid_create(&uuid, &s);
#elif PERL__UUID__RPC_H
    RPC_STATUS st;
    st = UuidCreate(&uuid);
#endif
    sv_setpvn(str, UUID2SV(uuid), sizeof(UUID_T));
}


void do_generate_random(SV *str) {
    UUID_T uuid;
#ifdef PERL__UUID__UUID_UUID_H
    uuid_generate_random( uuid );
#elif PERL__UUID__UUID_H
    int32_t s;
    uuid_create(&uuid, &s);
#elif PERL__UUID__RPC_H
    RPC_STATUS st;
    st = UuidCreate(&uuid);
#endif
    sv_setpvn(str, UUID2SV(uuid), sizeof(UUID_T));
}


void do_generate_time(SV *str) {
    UUID_T uuid;
#ifdef PERL__UUID__UUID_UUID_H
    uuid_generate_time( uuid );
#elif PERL__UUID__UUID_H
    int32_t s;
    uuid_create(&uuid, &s);
#elif PERL__UUID__RPC_H
    RPC_STATUS st;
    st = UuidCreateSequential(&uuid);
#endif
    sv_setpvn(str, UUID2SV(uuid), sizeof(UUID_T));
}


void do_unparse(SV *in, SV * out) {
#ifdef PERL__UUID__UUID_UUID_H
    char str[37];
    uuid_unparse(SV2UUID(in), str);
    sv_setpvn(out, str, 36);
#elif PERL__UUID__UUID_H
    char str[37];
    int32_t s;
    /* this mallocs */
    uuid_to_string(SV2UUID(in), &str, &s);
    sv_setpvn(out, str, 36);
    free(str);
#elif PERL__UUID__RPC_H
    char *str;
    RPC_STATUS st;
    st = UuidToString((UUID*)SvPV_nolen(in), (RPC_CSTR)&str);
    if(st != RPC_S_OK)
        croak("Out of memory");
    sv_setpvn(out, str, 36);
#endif
}


void do_unparse_lower(SV *in, SV * out) {
#ifdef PERL__UUID__UUID_UUID_H
    char str[37];
    uuid_unparse_lower(SV2UUID(in), str);
    sv_setpvn(out, str, 36);
#elif PERL__UUID__UUID_H
    char *p, str[37];
    int32_t s;
    /* this mallocs */
    uuid_to_string(SV2UUID(in),&str,&s);
    for(p=str; *p; ++p) *p = tolower(*p);
    sv_setpvn(out, str, 36);
    free(str);
#elif PERL__UUID__RPC_H
    char *p, *str;
    RPC_STATUS st;
    st = UuidToString((UUID*)SvPV_nolen(in), (RPC_CSTR)&str);
    if(st != RPC_S_OK)
        croak("Out of memory");
    for(p=str; *p; ++p) *p = tolower(*p);
    sv_setpvn(out, str, 36);
#endif
}


void do_unparse_upper(SV *in, SV * out) {
#ifdef PERL__UUID__UUID_UUID_H
    char str[37];
    uuid_unparse_upper(SV2UUID(in), str);
    sv_setpvn(out, str, 36);
#elif PERL__UUID__UUID_H
    char *p, str[37];
    int32_t s;
    /* this mallocs */
    uuid_to_string(SV2UUID(in),&str,&s);
    for(p=str; *p; ++p) *p = toupper(*p);
    sv_setpvn(out, str, 36);
    free(str);
#elif PERL__UUID__RPC_H
    char *p, *str;
    RPC_STATUS st;
    st = UuidToString((UUID*)SvPV_nolen(in), (RPC_CSTR)&str);
    if(st != RPC_S_OK)
        croak("Out of memory");
    for(p=str; *p; ++p) *p = toupper(*p);
    sv_setpvn(out, str, 36);
#endif
}


int do_parse(SV *in, SV * out) {
    UUID_T uuid;
#ifdef PERL__UUID__UUID_UUID_H
    int rc;
    rc = uuid_parse(SvPV_nolen(in), uuid);
#elif PERL__UUID__UUID_H
    int rc;
    uuid_from_string(str,&uuid,&rc);
#elif PERL__UUID__RPC_H
    RPC_STATUS rc;
    rc = UuidFromString(SvPV_nolen(in), &uuid);
#endif
    if( !rc )
        sv_setpvn(out, UUID2SV(uuid), sizeof(UUID_T));
    return rc;
}


void do_clear(SV *in) {
    UUID_T uuid;
#ifdef PERL__UUID__UUID_UUID_H
    uuid_clear(uuid);
#elif PERL__UUID__UUID_H
    int32_t s;
    uuid_create_nil(&uuid,&s);
#elif PERL__UUID__RPC_H
    UuidCreateNil(&uuid);
#endif
    sv_setpvn(in, UUID2SV(uuid), sizeof(UUID_T));
}


int do_is_null(SV *in) {
#ifdef PERL__UUID__UUID_UUID_H
    if( SvCUR(in) != sizeof(uuid_t) )
        return 0;
    return uuid_is_null(SV2UUID(in));
#elif PERL__UUID__UUID_H
    int32_t s;
    return uuid_is_nil(SV2UUID(in),&s);
#elif PERL__UUID__RPC_H
    int rc;
    RPC_STATUS st;
    rc = UuidIsNil((UUID*)SvPV_nolen(in), &st);
    return rc == TRUE ? 1 : 0;
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
#elif PERL__UUID__RPC_H
#endif
    return sv_cmp(uu1, uu2);
}


void do_copy(SV *dst, SV *src) {
    UUID_T uuid;
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
#elif PERL__UUID__RPC_H
    if( SvCUR(src) != sizeof(uuid_t) )
        UuidCreateNil(&uuid);
    else
        memcpy(&uuid, SvPV_nolen(src), sizeof(UUID));
#endif
    sv_setpvn(dst, UUID2SV(uuid), sizeof(UUID_T));
}


SV* do_uuid() {
    char str[37];
    UUID_T uuid;
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
#elif PERL__UUID__RPC_H
    char str[37];
    PRC_STATUS st;
    UuidCreateSequential(&uuid);
    st = UuidToString(&uuid, (RPC_CSTR*)&str);
    if( st != RPC_S_OK )
        croak("Out of memory");
    return newSVpv(str, 36);
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

