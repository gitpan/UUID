use ExtUtils::MakeMaker;
use Config;

my $libs;

$win32 = ($Config{osname} =~ /win32/i);
if ($win32) {
	print "Running on win32\n";
	$libs = "-lrpcrt4.lib";
} else {
	$libs = "-luuid";
}

WriteMakefile(
    'NAME'              => 'UUID',
    'VERSION_FROM'      => 'UUID.pm', # finds $VERSION
    'PREREQ_PM'         => {}, # e.g., Module::Name => 1.1
    'LIBS'              => $libs,
    'DEFINE'            => '', # e.g., '-DHAVE_SOMETHING'
    'INC'               => '', # e.g., '-I/usr/include/other'
);
