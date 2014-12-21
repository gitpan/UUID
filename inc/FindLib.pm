package FindLib;

use ExtUtils::Liblist;

# As ExtUtils::Liblist->ext(), but works even before 5.6.0
sub findlib {
    require ExtUtils::Liblist;

    local @ExtUtils::Liblist::ISA = @ExtUtils::Liblist::ISA, 'xxx';

    *xxx::lsdir = 'MY'->can('lsdir');
    *xxx::file_name_is_absolute = 'MY'->can('file_name_is_absolute');

    return ExtUtils::Liblist->ext( @_ );
}

1;
