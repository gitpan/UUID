use warnings;
use Test;
BEGIN { plan tests => 33 }
use UUID;


UUID::generate( $bin );
ok length $bin, 16;

UUID::generate_random( $bin );
ok length $bin, 16;

UUID::generate_time( $bin );
ok length $bin, 16;

UUID::unparse( $bin, $str );
ok $str, qr{^[-0-9a-f]+$}i;
$rc = UUID::parse( $str, $bin2 );
ok $rc, 0;
ok $bin, $bin2;

UUID::unparse_lower( $bin, $str );
UUID::unparse_upper( $bin, $str2 );
ok length( $str ), 36;
ok $str, qr/^[-a-f0-9]+$/;
ok lc( $str ), lc( $str2 );
ok $str ne $str2;

# content of uuid is unchanged if parse fails
UUID::generate( $bin );
$bin2 = $bin;
$str = 'Peter is a moose';
$rc = UUID::parse( $str, $bin );
ok $rc, -1;
ok $bin, $bin2;

UUID::generate( $bin );
$rc = UUID::is_null( $bin );
ok $rc, 0;

UUID::clear( $bin );
ok length( $bin ), 16;
ok UUID::is_null( $bin ), 1;

$bin = 'bogus value';
ok UUID::is_null( $bin ), 0; # != the null uuid, right?

$bin = '1234567890123456';
ok UUID::is_null( $bin ), 0; # still not null

# make sure compare operands sane
UUID::generate( $bin1 );
$bin2 = 'x';
ok abs(UUID::compare( $bin1, $bin2 )), 1;
ok abs(UUID::compare( $bin2, $bin1 )), 1;
$bin2 = 'some silly ridulously long string that couldnt possibly be a uuid';
ok abs(UUID::compare( $bin1, $bin2 )), 1;
ok abs(UUID::compare( $bin2, $bin1 )), 1;

# sane compare
$uuid=1; #kill warning until we get osx sorted
UUID::generate( $uuid ); # this is wrong, but dont fix it until after we figure out the segfault in macos
ok 1;                                   # for mac/os
$bin2 = '1234567890123456';
ok 1;                                   # for mac/os (pass)
#die; # 5.18.4 gets here (and all others)
$tmp1 = UUID::compare( $bin1, $bin2 );  # for mac/ox (segfault)
ok 1;                                   # for mac/os
#die; # 5.20.1 gets here
$tmp2 = -UUID::compare( $bin2, $bin1 ); # for mac/ox
ok $tmp1, $tmp2;                        # for mac/ox
ok UUID::compare( $bin1, $bin2 ), -UUID::compare( $bin2, $bin1 );
$bin2 = $bin1;
ok UUID::compare( $bin1, $bin2 ), 0;

# make sure we get back a null if src isnt sane
$bin1 = 'x';
UUID::copy( $bin2, $bin1 );
ok UUID::is_null( $bin2 ), 1;
$bin1 = 'another really really really long sting';
UUID::copy( $bin2, $bin1 );
ok UUID::is_null( $bin2 );

# sane copy
UUID::generate( $bin1 );
$bin2 = '1234567890123456';
UUID::copy( $bin2, $bin1 );
ok UUID::compare( $bin1, $bin2 ), 0;

# make sure we get back the same scalar we passed in
$bin1 = '1234567890123456';
UUID::generate( $bin2 );
$save1 = \$bin2;
UUID::copy( $bin2, $bin1 );
$save2 = \$bin2;
ok $save1, $save2;
ok $$save1, $$save2;

$rc = UUID::uuid();
ok length($rc), 36;

exit 0;
