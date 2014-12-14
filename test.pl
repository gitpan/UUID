# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..6\n"; }
END {print "not ok 1\n" unless $loaded;}
use UUID;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):


UUID::generate($var);
print (length $var == 0 ? 'not ' : '', "ok 2\n");
UUID::unparse($var, $out);

# Try to parse the UUID we got.
$rc = UUID::parse($out, $var2);
print ($rc ? 'not ' : '', "ok 3\n");

# Check that the unparsed version matches the parsed version.
print ($var eq $var2 ? '' : 'not ', "ok 4\n");

$rc = UUID::parse("Peter is a moose", $var2);
print ($rc ? '' : 'not ', "ok 5\n");

$rc = UUID::uuid();
print (length($rc)==36 ? '' : 'not', "ok 6\n");

exit (0);
