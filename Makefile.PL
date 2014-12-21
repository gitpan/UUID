use strict;
use warnings;
use Config;

my $useold = exists $ENV{TEST_OLD_LIBLIST}
    and defined $ENV{TEST_OLD_LIBLIST}
    and $ENV{TEST_OLD_LIBLIST} ? 1 : 0
;

my $verbose = exists $ENV{TEST_VERBOSE}
    and defined $ENV{TEST_VERBOSE}
    and $ENV{TEST_VERBOSE} ? 1 : 0
;

my %funcs = (
    uuid => [qw(uuid_generate uuid_parse uuid_unparse)],
);

my $loadlibs;
my $trylibs = join ' ', map { "-l$_" } keys %funcs;

print "Checking for libraries...\n";

if ($] >= 5.008001 and !$useold) {
    require ExtUtils::Liblist;          # Buggy before this
    ($loadlibs) = ExtUtils::Liblist->ext( $trylibs, $verbose );
}
else {
    unshift @INC, 'inc';
    require FindLib;
    ($loadlibs) = FindLib::findlib( $trylibs, $verbose );
}

if (scalar( split /\s+/, $trylibs) != scalar( split /\s+/, $loadlibs )) {
    print "Can't continue: missing libraries\n";
    exit 0; # play nice with CPAN testers
}

print "...Found '$loadlibs'\n";

{
    my %libs;
    my $fail = 0;
    my (@libs) = ($loadlibs =~ /\B-l(\S*)/g);
    @libs{@libs} = @libs;

    for my $l (keys %funcs) {
        unless ( $libs{$l} ) {
            print "-l$l not found\n";
            next;
        }

        my @symb    = @{$funcs{$l}};
        my $header  = "inc/try${l}.h";
        my $header1 = "${l}.h";

        my $cppflags = $Config{cppflags};
        $cppflags =~ s/-Zmt\b// if $^O eq 'os2';

        # Use $Config{cpprun}, instead of $Config{cpp}, since
        # cpp is set to only 'cpp' after Configure has run.
        # We need the one that usually lives in /lib.
        my $cpp = $Config{cpprun} || $Config{cpp};
        my $cmd = "$cpp $cppflags $header";

        if (open IN, "$cmd |") {{
            local $/;
            my $in = <IN>;
            close IN or (warn("close pipe from `$cmd': $!"), last);
            for my $s (@symb) {
                if ( $in =~ /$s/ ) {
                    print "...Found $s\n";
                }
                else {
                    print "...NOT found: $s\n";
                    $fail++;
                }
            }
        }}
    }
    if ( $fail ) {
        print "Can't continue: missing functions\n";
        exit 0; # play nice with CPAN testers
    }
}
print "Looks good\n";

require ExtUtils::MakeMaker;
ExtUtils::MakeMaker->import( 'WriteMakefile' );

WriteMakefile1(
    'NAME'             => 'UUID',
    'AUTHOR'           => 'Rick Myers <jrm@cpan.org>',
    'VERSION_FROM'     => 'UUID.pm',
    'ABSTRACT_FROM'    => 'UUID.pm',
    'LICENSE'          => 'artistic_2',
    'MIN_PERL_VERSION' => '5.005',
    'PREREQ_PM'        => {}, # e.g., Module::Name => 1.1
    'LIBS'             => [ $loadlibs ],
    'DEFINE'           => '', # e.g., '-DHAVE_SOMETHING'
    'INC'              => '', # e.g., '-I/usr/include/other'
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

