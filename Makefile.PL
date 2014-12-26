use strict;
use warnings;
use Config;
use Devel::CheckLib;
use ExtUtils::MakeMaker;


# ARRRRR!.. there are _at_least_ 3 different UUID interfaces:
# Free/NetBSD/MacOSX, Windows, and e2fsprogs.
# ... this is gonna suck!
print "#\n";


# if the compiler can't find it,
# no sense wasting our time...
print "# ===> Checking for -luuid\n";
check_lib_or_exit(
    lib   => 'uuid',
    debug => 1,
);
print "#\n";


my @hfiles;
for my $try (qw{ uuid/uuid.h uuid.h Rpc.h }) {
    print "# ===> Checking for $try\n";
    eval { assert_lib(
        lib      => 'uuid',
        header   => $try,
        debug    => 1,
    )};
    unless ( $@ ) {
        push @hfiles, $try;
        print "# ===> Found!\n";
    }
    print "#\n";
}

die "No header file found. Can't continue.\n" unless @hfiles;


my $header;
my $defs = [];
my $libs = [];

while ( $header = shift @hfiles ) {
    try_rpc(  $header ) and last;
    try_e2fs( $header ) and last;
    try_win(  $header ) and last;
}

die "No interface found. Can't continue.\n" unless $header;


sub try_rpc {
    my $hdr = shift;
    print "# ===> Checking for RPC interface in $hdr\n";
    eval { assert_lib(
        lib      => 'uuid',
        header   => $hdr,
        debug    => 1,
        function => qq/
            char str[37];
            uuid_t u1,u2;
            int32_t r,s;
            uuid_create(&u1,&s);
            uuid_create_nil(&u2,&s);
            uuid_from_string(str,&u1,&s);
            uuid_to_string(&u1,&str,&s);
            r = uuid_compare(&u1,&u2,&s);
            r = uuid_equal(&u1,&u2,&s);
            r = uuid_is_nil(&u1,&s);
            return 0;
        /,
    )};
    if ($@) { my $L = length $@; print "# ===> Err($L): \"$@\"\n"; return 0 }
    push @$defs, '-DPERL__UUID__RPC_INT';
    push @$libs, '-luuid';
    print "# ===> Found!\n";
    print "#\n";
    return 1;
}

sub try_e2fs {
    my $hdr = shift;
    print "# ===> Checking for e2fs interface in $hdr\n";
    eval { assert_lib(
        lib      => 'uuid',
        header   => $header,
        debug    => 1,
        function => qq/
            int i;
            char s[37];
            uuid_t u,uu;
            uuid_generate(u);
            uuid_generate_random(u);
            uuid_generate_time(u);
            uuid_unparse(u,s);
            uuid_unparse_lower(u,s);
            uuid_unparse_upper(u,s);
            uuid_parse(s,u);
            uuid_clear(u);
            uuid_copy(uu,u);
            i = uuid_compare(u,uu);
            i = uuid_is_null(u);
            return 0;
        /,
    )};
    if ($@) { my $L = length $@; print "# ===> Err($L): \"$@\"\n"; return 0 }
    push @$defs, '-DPERL__UUID__E2FS_INT';
    push @$libs, '-luuid';
    print "# ===> Found!\n";
    print "#\n";
    return 1;
}

sub try_win {
    my $hdr = shift;
    print "# ===> Checking for Win interface in $hdr\n";
    eval { assert_lib(
        lib      => 'rpcrt4',
        header   => $header,
        debug    => 1,
        function => qq/
            int i;
            UUID u,uu;
            RPC_CSTR cs;
            RPC_STATUS st;
            unsigned char s[37];
            i  = UuidCompare(&u,&uu,&st);
            st = UuidCreate(&u);
            st = UuidCreateNil(&uu);
            st = UuidCreateSequential(&uu);
            i  = UuidEqual(&u,&uu,&st);
            st = UuidFromString(cs,&u);
            i  = UuidIsNil(&u,&st);
            st = UuidToString(&u,&s);
            return 0;
        /,
    )};
    if ($@) { my $L = length $@; print "# ===> Err($L): \"$@\"\n"; return 0 }
    push @$defs, '-DPERL__UUID__WIN_INT';
    push @$libs, '-lrpcrt4';
    print "# ===> Found!\n";
    print "#\n";
    return 1;
}

sub get_size {
    my ( $hdrs, $libs ) = @_;
    print "# ===> Checking binary size\n";
    ( my $lib = $libs->[0] ) =~ s/-l//;
    check_lib(
        lib      => $lib,
        header   => $hdrs,
        debug    => 1,
        function => qq/
            return sizeof(uuid_t);
        /,
    );
    my $rv = $? >> 8;
    print "# ===> $rv\n";
    print "#\n";
    return $rv;
}


my $size = get_size( $header, $libs );
push @$defs, "-DPERL__UUID__UUID_BUF_SZ=$size";

($header = '-DPERL__UUID__'. uc $header ) =~ y{/.}{__};
push @$defs, $header;


print "# ===> Writing Makefile\n";

WriteMakefile1(
    'NAME'               => 'UUID',
    'AUTHOR'             => 'Rick Myers <jrm@cpan.org>',
    'VERSION_FROM'       => 'UUID.pm',
    'ABSTRACT_FROM'      => 'UUID.pm',
    'LICENSE'            => 'artistic_2',
    'MIN_PERL_VERSION'   => '5.005',
    'LIBS'               => $libs,
    'DEFINE'             => join(' ', @$defs), #$header,
    'INC'                => '',
    'PREREQ_PM'          => {},
    'CONFIGURE_REQUIRES' => {
        'Devel::CheckLib' => '1.02',
    },
    'TEST_REQUIRES' => {
        'Test' => 0,
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

# stay calm. don't blink.
# this is just for me :-)
sub MY::postamble {
    return <<EOP;
readme:
	pod2text UUID.pm README
	perl -i -pe's{\\*(\\S+)\\*}{\\1}g' README
EOP
}

