package UUID;

require 5.005;
use strict;
#use warnings;

require Exporter;
require DynaLoader;

use vars qw(@ISA %EXPORT_TAGS @EXPORT_OK $VERSION);
@ISA = qw(Exporter DynaLoader);

# This allows declaration       use UUID ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.

%EXPORT_TAGS = ( 'all' => [qw(&generate &parse &unparse &uuid)] );

@EXPORT_OK = ( @{$EXPORT_TAGS{'all'}} );

$VERSION = '0.09';

bootstrap UUID $VERSION;

# Preloaded methods go here.

1;
__END__

=head1 NAME

UUID - DCE compatible Universally Unique Identifier library for Perl

=head1 SYNOPSIS

    use UUID ':all';

    generate($uuid);             # generates a 128 bit uuid

    unparse($uuid, $string);     # change $uuid to 36 byte string

    $rc = parse($string, $uuid); # map string to UUID, return -1 on error

    $string = uuid();            # generate new UUID, return string only

=head1 DESCRIPTION

The UUID library is used to generate unique identifiers for objects that
may be accessible beyond the local system. For instance, they could be
used to generate unique HTTP cookies across multiple web servers without
communication between the servers, and without fear of a name clash.

The generated UUIDs can be reasonably expected to be unique within a
system, and unique across all systems, and are compatible with those
created by the Open Software Foundation (OSF) Distributed Computing
Environment (DCE) utility uuidgen.

=head1 FUNCTIONS

Most of the UUID functions expose the underlying libuuid C interface
rather directly. That is, many return their values in their parameters
and nothing else.

Not very Perlish, is it? It's been like that for a long time though, so
not very likely to change any time soon.

All take or return UUIDs in either binary or string format. The string
format resembles the following:

    1b4e28ba-2fa1-11d2-883f-0016d3cca427

Or, in terms of printf(3) format:

    "%08x-%04x-%04x-%04x-%012x"

The binary format is simply a packed 16 byte binary value.

=head2 B<generate(> I<$uuid> B<)>

Creates a new binary UUID based on high quality randomness from
/dev/urandom, if available.

Alternately, the current time, the local ethernet MAC address (if
available), and random data generated using a pseudo-random generator
are used.

The previous content of I<$uuid>, if any, is lost.

=head2 B<unparse(> I<$uuid>B<,> I<$string> B<)>

Converts the binary UUID in I<$uuid> to string format and returns in
I<$string>. The previous content of I<$string>, if any, is lost.

The case of the hex digits returned may be upper or lower case, and is
dependent on the system-dependent local default.

=head2 B<$rc = parse(> I<$string>B<,> I<$uuid> B<)>

Converts the string format UUID in I<$string> to binary and returns in
I<$uuid>. The previous content of I<$uuid>, if any, is lost.

Returns 0 on success and -1 on failure. Additionally on failure, the
content of I<$uuid> is unchanged.

=head2 B<>I<$string> B<= uuid()>

Creates a new string format UUID and returns it in a more Perlish way.

Functionally the equivalent of calling B<generate> and then B<unparse>, but
throwing away the intermediate binary UUID.

=head1 EXPORTS

The following functions are exported only by request.

    generate
    unparse
    parse
    uuid

All the functions may be imported using the ":all" tag.

=head1 TODO

Expose the rest of libuuid.

    Status  Function
    ------  --------
    .       void uuid_clear(uuid_t uu);
    .       int uuid_compare(const uuid_t uu1, const uuid_t uu2);
    .       void uuid_copy(uuid_t dst, const uuid_t src);
    !       void uuid_generate(uuid_t out);
    .       void uuid_generate_random(uuid_t out);
    .       void uuid_generate_time(uuid_t out);
    .       int uuid_is_null(const uuid_t uu);
    !       int uuid_parse(const char *in, uuid_t uu);
    .       void uuid_unparse(const uuid_t uu, char *out);
    .       void uuid_unparse_lower(const uuid_t uu, char *out);
    .       void uuid_unparse_upper(const uuid_t uu, char *out);
    .       time_t uuid_time(const uuid_t uu, struct timeval *ret_tv);
    ?       int uuid_type(const uuid_t uu);
    ?       int uuid_variant(const uuid_t uu);

    Status  Constant
    ------  --------
    ?       UUID_VARIANT_NCS
    ?       UUID_VARIANT_DCE
    ?       UUID_VARIANT_MICROSOFT
    ?       UUID_VARIANT_OTHER
    ?       UUID_TYPE_DCE_TIME
    ?       UUID_TYPE_DCE_RANDOM

    . - todo.
    ! - done!
    ? - why?


=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2014 by Rick Myers.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

Details of this license can be found within the 'License' text file.

=head1 AUTHOR

Current maintainer:

  Rick Myers <jrm@cpan.org>.

Authors and/or previous maintainers:

  Joseph N. Hall <joseph.nathan.hall@gmail.com>

  Colin Faber <cfaber@clusterfs.com>

  Peter J. Braam <braam@mountainviewdata.com>

  Lukas Zapletal <lzap@cpan.org>

=head1 SEE ALSO

uuid_generate(3), uuid_parse(3), uuid_unparse(3), perl(1).

=cut

