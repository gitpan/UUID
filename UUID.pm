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

$VERSION = '0.07';

bootstrap UUID $VERSION;

# Preloaded methods go here.

1;
__END__

=head1 NAME

UUID - Perl extension for using UUID interfaces as defined in e2fsprogs.

=head1 SYNOPSIS

  use UUID;

  UUID::generate($uuid);             # generates a 128 bit uuid
  UUID::unparse($uuid, $string);     # change $uuid to 36 byte string

  $rc = UUID::parse($string, $uuid); # map string to UUID, return -1 on error

  $string = UUID::uuid();            # generate new UUID, return string only

=head1 DESCRIPTION

With these 4 routines UUID's can easily be generated and parsed/un-parsed.

=head2 Exports

The following functions are exported only by request.

    generate
    unparse
    parse
    uuid

All the functions may be imported using the ":all" tag.


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

  Lukas Zaplatel <lzap@cpan.org>

=head1 SEE ALSO

perl(1).

=cut

