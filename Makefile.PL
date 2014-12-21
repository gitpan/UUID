use strict;
use warnings;
use Config;
use Devel::CheckLib;
use ExtUtils::MakeMaker;

check_lib_or_exit(
    lib      => 'uuid',
    header   => 'uuid/uuid.h',
    function => qq/
        uuid_t u;
        uuid_generate(u);
        return 0;
    /,
);

check_lib_or_exit(
    lib      => 'uuid',
    header   => 'uuid/uuid.h',
    function => qq/
        uuid_t u;
        char s[37];
        uuid_generate(u);
        uuid_unparse(u,s);
        return 0;
    /,
);

check_lib_or_exit(
    lib      => 'uuid',
    header   => 'uuid/uuid.h',
    function => qq/
        uuid_t u;
        char s[37] = "00000000-0000-0000-0000-000000000000";
        uuid_parse(s,u);
        return 0;
    /,
);

WriteMakefile1(
    'NAME'             => 'UUID',
    'AUTHOR'           => 'Rick Myers <jrm@cpan.org>',
    'VERSION_FROM'     => 'UUID.pm',
    'ABSTRACT_FROM'    => 'UUID.pm',
    'LICENSE'          => 'artistic_2',
    'MIN_PERL_VERSION' => '5.005',
    'PREREQ_PM'        => {}, # e.g., Module::Name => 1.1
    'LIBS'             => [ '-luuid' ],
    'DEFINE'           => '', # e.g., '-DHAVE_SOMETHING'
    'INC'              => '', # e.g., '-I/usr/include/other'
    'CONFIGURE_REQUIRES' => {
        'Devel::CheckLib' => 0,
    },
    #'META_MERGE'       => {
    #    'resources' => {
    #        #repository => 'URL to repository here',
    #    },
    #},
    #BUILD_REQUIRES => {
    #},
);

sub WriteMakefile1 {  #Written by Alexandr Ciornii, version 0.21. Added by eumm-upgrade.
    my %params=@_;
    my $eumm_version=$ExtUtils::MakeMaker::VERSION;
    $eumm_version=eval $eumm_version;
    die "EXTRA_META is deprecated" if exists $params{EXTRA_META};
    die "License not specified" if not exists $params{LICENSE};
    if ($params{BUILD_REQUIRES} and $eumm_version < 6.5503) {
        #EUMM 6.5502 has problems with BUILD_REQUIRES
        $params{PREREQ_PM}={ %{$params{PREREQ_PM} || {}} , %{$params{BUILD_REQUIRES}} };
        delete $params{BUILD_REQUIRES};
    }
    delete $params{CONFIGURE_REQUIRES} if $eumm_version < 6.52;
    delete $params{MIN_PERL_VERSION} if $eumm_version < 6.48;
    delete $params{META_MERGE} if $eumm_version < 6.46;
    delete $params{META_ADD} if $eumm_version < 6.46;
    delete $params{LICENSE} if $eumm_version < 6.31;
    delete $params{AUTHOR} if $] < 5.005;
    delete $params{ABSTRACT_FROM} if $] < 5.005;
    delete $params{BINARY_LOCATION} if $] < 5.005;

    WriteMakefile(%params);
}

