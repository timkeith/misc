# to use:
<<'END';
use strict;
use warnings;
use File::Spec::Functions qw(catfile catdir);
use File::Basename qw(basename);
use lib File::Basename::dirname __FILE__;
use lib catfile($ENV{ROOT}, 'bin');
use Misc qw(dirname assert note warning error fatal internal);
$| = 1;
my $OPT = Misc::getopt(
    {args => 1},
    '<file>
... description ...',
    'opt'        => 'description of -opt',
    'opt=s<str>'   => 'description of -opt=<str>',
);
END
#other versions
# C:\Misc\bom\Misc.pm
# C:\Misc\copy-installs\Misc.pm

package Misc;

use strict;
use warnings;
require 5.006_001;  # it works with this; don't know about earlier

# to turn off a warning:  no warnings qw(once);
use Carp qw(croak);
use Class::Struct qw(struct);
use Cwd ();
use Data::Dumper ();
use File::Spec::Functions qw(canonpath catfile catdir);
use File::Basename qw(basename);
use File::stat ();
use File::Find ();
use File::Path ();
use File::Copy ();
use FindBin ();
use Getopt::Long ();
use Digest::MD5 ();
use Time::Local ();
use Time::localtime ();
#use Term::ReadKey ();

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);
@ISA = qw(Exporter);
@EXPORT = qw(&true &false);
@EXPORT_OK = qw(get_view_and_vob ct run
    get_current_stream mon2num num2mon norm_date norm_date_time set_clipboard
    get_clipboard slurp put get_dir pushd cd save_log do_open Dump gettemp
    pvob unpvob get_project_info nsort private trace tracei
    fatal internal nyi error warning note assert try catch max min
    dirname);

sub true();
sub false();
sub getopt_old(@);
sub getopt(@);
sub _option_error($$);
sub get_out_of_package_caller();
sub get_out_of_package_caller_old(;$);
sub make_getopt_help($$$);
sub delete_opt($$);
sub getopt_help(;$);
sub get_array($);
sub opt_exc_req($@);
sub opt_exc($@);
sub opt_req($@);
sub uniq(@);
sub same(@);
sub sum(@);
sub max(@);
sub min(@);
sub mtime($);
sub ctime($);
sub mkdirs($;$);
sub rmdir($);
sub cd($);
sub pushd($);
sub move($$);
sub copy($$);
sub copy_dir($$);
sub cc_check_path($);
sub cc_parse_info($);
sub cc_parse_describe(@);
sub get_view_and_vob(;$);
sub ct(@);
sub run(@);
sub exit_status_msg($);
sub run_async($;$);
sub cvs(@);
sub get_cvs_root_opt($);
sub ct_new(@);
sub ct2(@);
sub run2(@);
sub run_old(@);
sub quoteargs(@);
sub get_build_id($);
sub num2mon($);
sub mon2num($);
sub num2day($);
sub day2num($);
sub date(;$);
sub date2(;$);
sub cc_date();
sub time(;$);
sub date_time(;$);
sub to_24hr($);
sub norm_date($);
sub norm_date_time($);
sub get_year_month();
sub set_clipboard($);
sub get_clipboard();
sub get_clipboard_files();
sub get_clipboard_bitmap();
sub get_clipboard_full();
sub get_clipboard_formats();
sub get_clipboard_format($);
sub get_clipboard_html();
sub slurp($;$);
sub simple_get($);
sub simple_put($$);
sub put($$;$);
sub append($$;$);
sub get_dir($);
sub get_dir2($);
sub is_empty_dir($);
sub match_case($);
sub save_log($);
sub do_open_old($;$);
sub do_open($;$$);
sub replacedir($$$);
sub stripdir($$);
sub abs2rel($$);
sub relpath($;$);
sub Dump($;$$);
sub dirname($);
sub root($);
sub suffix($);
sub tempdir();
sub is_temp($);
sub gettempdir(;$$);
sub gettempdir2($);
sub backup($;$);
sub gettemp(;$$);
sub mktemp(;$$$);
sub puttemp($;$$);
sub getargs($@);
sub subopts($$@);
sub options($@);
sub set_diff($$);
sub set_and($$);
sub member($@);
sub list_to_set(@);
sub add_to_list($$);
sub add_to_list2($$);
sub add_all_to_list($@);
sub diff_list($$);
sub get_project(;$);
sub get_cwd_workspace();
sub get_workspace();
sub pvob(;$$);
sub unpvob($);
sub get_current_stream(;$);
sub get_current_project(;$);
sub get_project_info(;$);
sub _match($);
sub _match_array($);
sub find_checkedout($);
sub find_hijacked($);
sub check_in_view($);
sub mount($);
sub get_labels($);
sub diff_map($$);
sub diffstr($$);
sub diff($$);
sub fix_diff($);
sub fix_gmt($);
sub same_file($$);
sub find_files($@);
sub dir_size($);
sub clean($$);
sub nsort(%);
sub isort(@);
sub sort_by_date(@);
sub trim($);
sub subst($@);
sub get_pat_in_file2($$);
sub get_pat_in_file($$);
sub win_slash($);
sub unix_slash($);
sub to_url($);
sub expand_links(@);
sub expand_link($);
sub my_glob($;$);
sub bsd_glob(@);
sub glob_args(@);
sub expand_args(@);
sub glob_one_dir($);
sub glob_one($);
sub glob_one_or_more($);
sub columnate($);
sub html_table($;$);
sub quote_html($);
sub unquote_html($);
sub indent($$);
sub private();
sub stack_trace();
sub trace(@);
sub tracei(@);
sub _trace(@);  # private
sub set_trace($);
sub nyi($@);
sub fatal($@);
sub error($@);
sub warning($@);
sub note($@);
sub internal($@);
sub assert($;$);
sub set_logger($);
sub check_file($);
sub check_dir($);
sub check_dirs(@);
sub try(&$);
sub catch(&);
sub serialize($$;$);
sub deserialize($);
sub image_old(@);
sub image(@);
sub hash_array_image(@);
sub hash_image(@);
sub fixundef($);
sub crypt($;$);
sub get_pw();
sub prompt($);
sub checksum($);
sub checksum16($);
sub checksum32($);
sub shorten($$);
sub shorten_line($$);
sub format_xml($;$);
sub sort_xml($);
sub get_xml_attribute($$$);
sub mail($$$@);
sub getcwd();
sub is_fullpath($);
sub fullpath($);
sub get_xde_install_info();
sub get_xde_install_info_unzipped($);
sub _get_xde_install_info($$$);
sub get_registry($);
sub set_registry($$;$);
sub toggle_service($;$);
sub get_from_url($);
sub get_dir_from_url($);
sub get_dir_from_url2($);
sub get_file_from_url($;$);
sub get_eclipse_project($);
sub find_java_exe($);
sub find_vim_exe();
sub run_vim2($;$);
sub run_vim($;$);
sub run_vim_wait($;$);
sub _run_vim_args($;$);
sub format_size($);
sub is_win32();
sub is_linux();
sub get_latest_imcl();
sub create_keyring($$);
sub tlist(@);
sub _wget($);
sub wget_unchecked($$);
sub wget_dir($);
sub wget_to_file($;$);
sub wget($);
sub get_password();

# Paths:
my $TLIST = 'C:\Install\bin\tlist.exe';
my $VIM = 'C:\Install\Vim\vim73\gvim.exe';
my $IMCL_GLOB = 'C:\Test\IM\*\install\eclipse\tools\imcl.exe';
use constant JAVA => 'C:\Program Files\Java';

$| = 1;

# returned by get_project_info
struct Project => [
    name       => '$',
    title      => '$',
    comment    => '$',
    master     => '$',
    date       => '$',
    creator    => '$',
    intstream  => '$',
    devstreams => '@',
    comps      => '@',
    recbls     => '%',
];

my $DEBUG = 0;  # 1 => stack trace for each error/warning message
my $TRACE = 0;  # 0 => no output from trace or tracei

my @last_keys = ();
my %last_desc = ();
1;

sub true() {
    return 1;
}

sub false() {
    return '';
}

# %desc maps option to description.  Options are standard Getopt::Long
# descriptors, except that =s, =i, etc. may be followed by <...> with a
# descriptive name of the option.  E.g. 'o|output=s<output-file>'.
# '=f' is short for '=s<file>'.
# Description of command can be provided as first arg or in $desc{''}.
# If it's a ref, it points to an array containing the lines of the description.
sub getopt_old(@) {
    my(@desc) = @_;
    my $desc = @desc % 2 == 1 && shift(@desc);
    my %desc = @desc;
    my $n = 0;
    my @keys = grep($n++ % 2 == 0, @desc);  # get keys in order, not keys(%desc)
    if($desc) {
        defined $desc{''}
            and Carp::croak("*** getopt_old: description was provide in first arg"
                . " and with '' => ...\n");
        $desc{''} = $desc;
    }
    @last_keys = @keys;
    %last_desc = %desc;
    my %opt = ();
    grep(s/([=:])f/$1s/, @keys);
    grep(s/([=:].+?)<.+?>/$1/, @keys);
    # allow users to configure?
#    Getopt::Long::Configure(qw(require_order no_auto_abbrev));
    Getopt::Long::Configure(qw(permute no_auto_abbrev));
    my $ok = Getopt::Long::GetOptions(\%opt, 'help', @keys);
    if(!$ok || $opt{'help'}) {
        getopt_help();
        exit(!$ok);
    }
    return %opt;
}

# Usage:
#   getopt({<options>}, [<desciption>], <option> => <desc>, ...)
# getopt can be used for script options or optional args to subs.
# It returns a struct whose fields are the option names.
# It is assumed to be a script if: script is in the options; there is no
# caller; or no <description> is provided.
# Different behaviour for subs:
#   - options are introduced only by '-', not '/'
#   - there is no automatic -help option
#   - when an error occurs it results in an internal error, not usage message
# Options to getopt:
#   - argv: ref to array of args to operate on, rather than ARGV
#   - args: indicates how many args are allowed after option processing.
#     E.g. "1-3" means 1, 2, or 3; "1" means exactly 1; "-3" means up to three;
#     "1-" means at least 1.
#   - script: force it to be treated like script args
#   - noslash: don't allow /foo for -foo in scripts
#   - order: requires options before args
#   - required: lists a set of options, at least one of which must be present
#   - exclusive: lists a set of options, at most one of which may be present
#   - one: lists a set of options, exactly one of which must be present
#   each of "required", "exclusive", and "one" may be a comma-separated list
#   of option names, or a ref to an array of same
#TODO opts that take arrays
my %structs_defined = ();
sub getopt(@) {
    my %opt = subopts(
        \@_, [], qw(script args argv noslash order required exclusive one));
    $opt{noslash} = 1 unless is_win32();
    my(@desc) = @_;
    my $desc = @desc % 2 == 0 ? undef : shift(@desc);
    my %desc = @desc;
    assert(!defined $desc{''}, 'empty arg key in description for getopt');
    my $caller = get_out_of_package_caller();
    $opt{script} = 1 if !defined $opt{script} && !defined($caller);
    local $_;
    my $n = 0;
    my @keys = grep($n++ % 2 == 0, @desc);  # get keys in order, not keys(%desc)
    my $added_help = false;
    my $help = do {
        if($opt{script} && !member('help', @keys)) {
            $added_help = true;
            my $help = make_getopt_help($desc, \@keys, \%desc);
            push(@keys, 'help|?');
            $help;
        } else {
            '';
        }
    };
    # add default -trace option which causes set_trace(1)
    my $added_trace = false;
    if(!member('trace', @keys)) {
        $added_trace = true;
        push(@keys, 'trace');
    }
    grep(s/([=:])f/$1s/, @keys);
    grep(s/([=:].+?)<.+?>/$1/, @keys);
    my %options = ();
    my @image;  # args that were removed as part of option processing
    {
        my @save_ARGV = @ARGV;
        $opt{argv} and @ARGV = @{$opt{argv}};
        # allow /foo for -foo
        grep(s#^/#-#, @ARGV) if $opt{script} && !$opt{noslash};
        local $SIG{__DIE__} = sub { internal $_[0] . $help };
        local $SIG{__WARN__} = sub {
            $SIG{__DIE__} = 'DEFAULT';
            _option_error(\%opt, $_[0] . $help);
        };
        Getopt::Long::Configure('no_auto_abbrev',
            $opt{order} || !$opt{script} ? 'require_order' : 'permute');
        my @temp_ARGV = @ARGV;
        Getopt::Long::GetOptions(\%options, @keys) or exit 1;
        @image = set_diff(\@temp_ARGV, \@ARGV);
        if($opt{script} && !$opt{noslash}) {
            grep(s#^-#/#, @ARGV);  # change -foo back to /foo
        }
        if($opt{argv}) {
            @{$opt{argv}} = @ARGV;
            @ARGV = @save_ARGV;
        }
    }
    if($added_help && $options{help}) {
        print $help;
        exit(0);
    }
    if($added_trace && $options{trace}) {
        set_trace(1);
    }
    # check requirements based on options to getopt
    my $key_names = [ map {
        s/^-//;  # allow optional '-'
        /^(\w+)/ or _option_error(\%opt, "option doesn't start with \\w: $_");
        $1;
    } @keys ];
    my @required = get_array($opt{required});
    my @exclusive = get_array($opt{exclusive});
    my @one = get_array($opt{one});
    push(@required, @one);
    push(@exclusive, @one);
    for my $required (@required) {
        my @required = split(/\s*,\s*/, $required);
        if(my @bad = set_diff(\@required, $key_names)) {
            internal "invalid option name in required: @bad";
        }
        if(grep(defined($options{$_}), @required) == 0) {
            _option_error(\%opt, @required == 1
                ? "-@required must be specified"
                : 'one of these options must be specified: -'
                    . join(' -', @required));
        }
    }
    for my $exclusive (@exclusive) {
        my @exclusive = split(/\s*,\s*/, $exclusive);
        if(my @bad = set_diff(\@exclusive, $key_names)) {
            internal "invalid option name in exclusive: @bad";
        }
        if(grep(defined($options{$_}), @exclusive) > 1) {
            _option_error(\%opt, 'only one of these options may be specified:'
                . join(' -', '', @exclusive));
        }
    }
    # check arg count
    if(defined(local $_ = $opt{args})) {
        my @argv = $opt{argv} ? @{$opt{argv}} : @ARGV;
        my($min, $max) = /^(\d+)$/ ? ($1, $1)
            : /^(\d+)-$/ ? ($1, 999999)
            : /^-(\d+)$/ ? (0, $1)
            : /^(\d+)-(\d+)$/ ? ($1, $2)
            : internal "bad args option to getopt_new: $_";
        if(my $msg = @argv < $min ? "At least $min arguments are required"
                : @argv > $max ? "No more than $max arguments are allowed"
                : '') {
            $min == $max and $msg = "Exactly $min arguments are required";
            $msg =~ s/ 1 arguments are / 1 argument is /;  # grammar!
            $msg =~ s/ more than 0 / /;
            $msg .= '; found: ';
            $msg .= @argv == 0 ? 'none' : join(', ', @argv);
            $msg .= "\n" . $help;
            chomp($msg);
            _option_error(\%opt, $msg);
            return undef;
        }
    }
    # create struct -- should all fields be '$'?
    my $name = 'Options';
    if(defined(my $caller = get_out_of_package_caller())) {
        # make struct name unique by adding name of caller
        $name .= '_' . Misc::subst($caller, '\W' => '_');
    } else {
        $name .= '_';
    }
    # add _image field to return array of args processed as options
    $options{_image} = \@image;
    push(@$key_names, '_image');
    #my @fields = map { /^[_a-z]/i or $_ = "_$_"; $_ => '$' } @$key_names;
    my @fields = map { $_ => '$' } @$key_names;
    my $result = eval {
        if(!$structs_defined{$name}++) {
            use Class::Struct;
            struct($name => \@fields);
        }
        return new $name(help => $help, %options)
    };
    $@ and internal "error creating $name: $@";
    return $result;
}

# issue fatal or internal errors for options errors depending on whether
# it is a script or not
sub _option_error($$) {
    my($opt, $msg) = @_;
    return $opt->{script} ? fatal $msg : internal $msg;
}

# Return the name of the last caller not in my caller's package
sub get_out_of_package_caller() {
    my $sub = (caller(1))[3] or return undef;
    $sub =~ /(.+?)::.*/ or return undef;
    my $package = $1;
    for(my $n = 2; ; $n += 1) {
        my $sub = (caller($n))[3] or return undef;
        $sub =~ /^\Q$package\E::/ or return $sub;
    }
}

# Return the name of the last caller not in this package.
sub get_out_of_package_caller_old(;$) {
    my($package) = @_;
    defined $package or $package = __PACKAGE__;
    for(my $n = 0; ; $n += 1) {
        my $sub = (caller($n))[3];
        defined $sub or return undef;
        $sub =~ /^\Q$package\E::/ or return $sub;
    }
}

sub make_getopt_help($$$) {
    my($desc, $keysref, $descref) = @_;
    assert(ref $keysref eq 'ARRAY', '');
    assert(ref $descref eq 'HASH', '');
    my @keys = @$keysref;
    my $max = 0;
    my @k = ();
    my @v = ();
    for(@keys) {
        next if $_ eq '';
        push(@v, $descref->{$_});
        s/=.+?(<.+?>)/=$1/;
        s/=i/=<num>/;
        s/=s/=<string>/;
        s/=f/=<file>/;
        push(@k, $_);
        $max = length($_) if length($_) > $max;
    }
    my $result = '';
    if(defined $desc) {
        $result .= 'usage: ' . $FindBin::Script;
        @k > 0 and $result .= ' [options]';
#        $desc and $result .= ' ' . subst($desc, '\s*\n\s*' => "\n");
        # don't want to remove leading newline if no args!
#        $desc and $result .= ' ' . subst($desc, '^\n' => '', '\n$' => '');
        $desc and $result .= ' ' . subst($desc, '\n$' => '');
        $result .= "\n";
    }
    for(@k) {
        my $sp = ' ' x ($max + 9);
        my $v = Misc::subst(shift(@v), "\n *" => "\n$sp");
        $result .= sprintf("    -%-${max}s => %s\n", $_, $v);
    }
    return $result;
}

# Delete an option of given name from an option struct and return old value.
sub delete_opt($$) {
    my($opt, $name) = @_;
    assert(ref($opt) =~ /^Options($|_)/,
        'arg to delete_opt must be ref to Options class');
    my $result = $opt->$name;
    $opt->$name(undef);
    return $result;
}

sub getopt_help(;$) {
    my($exit) = @_;
    my %desc = %last_desc;
    my $desc = $desc{''};
    if(ref($desc)) {
        $desc = join("\n", @$desc);
    }
    chomp($desc);
    printf "usage: %s [options] %s\n", $FindBin::Script, $desc;
    my $max = 0;
    my @keys = ();
    my @values = ();
    for(@last_keys) {
        next if $_ eq '';
        push(@values, $desc{$_});
        s/=.+?(<.+?>)/ $1/;
        s/=i/ <num>/;
        s/=s/ <string>/;
        s/=f/ <file>/;
        push(@keys, $_);
        $max = length($_) if length($_) > $max;
    }
    for(@keys) {
        printf "    -%-${max}s => %s\n", $_, shift(@values);
    }
    defined($exit) and exit($exit);
    return 1;
}

# convert array ref or scalar to array
sub get_array($) {
    my($x) = @_;
    if(!defined $x) {
        return ();
    } elsif(ref $x eq 'ARRAY') {
        return @$x;
    } elsif(ref $x eq '') {
        return $x;
    } else {
        assert(0, 'arg to get_array must be array ref or scalar');
    }
}

# The options named in @opt are exclusive and one must be set.
sub opt_exc_req($@) {
    my($opt, @opt) = @_;
    opt_exc($opt, @opt);
    opt_req($opt, @opt);
}

# The options named in @opt are exclusive; only one may be set in %$opt.
sub opt_exc($@) {
    my($opt, @opt) = @_;
    if(grep($$opt{$_}, @opt) > 1) {
        die '*** only one of -', join(' or -', @opt), " may be specified\n";
    }
}

# At least one of the options named in @opt must be set in %$opt
sub opt_req($@) {
    my($opt, @opt) = @_;
    if(grep($$opt{$_}, @opt) == 0) {
        die '*** one of -', join(' or -', @opt), " must be specified\n";
    }
}

# return elements in same order, with dups removed
sub uniq(@) {
    my(@x) = @_;
    my %saw = ();
    my @result = ();
    for my $x (@x) {
        push(@result, $x) unless $saw{$x}++;
    }
    return @result;
}

# check all values of this array are the same
sub same(@) {
    my(@x) = @_;
    return @x < 2 || !grep($_ ne $x[0], @x);
}

sub sum(@) {
    my @x = @_;
    my $sum = 0;
    while(defined(my $x = shift @x)) {
        $sum += $x;
    }
    return $sum;
}

sub max(@) {
    my @x = @_;
    @x == 0 and return undef;
    my $max = shift @x;
    while(defined(my $x = shift @x)) {
        $x > $max and $max = $x;
    }
    return $max;
}

sub min(@) {
    my @x = @_;
    @x == 0 and return undef;
    my $min = shift @x;
    while(defined(my $x = shift @x)) {
        $x < $min and $min = $x;
    }
    return $min;
}

# Return the modification time of $file or 0.
sub mtime($) {
    my($file) = @_;
    my $st = File::stat::stat($file);
    return defined($st) ? $st->mtime : 0;
}

# Return the modification time of $file or 0.
sub ctime($) {
    my($file) = @_;
    my $st = File::stat::stat($file);
    return defined($st) ? $st->ctime : 0;
}

# Make directory including containing ones; error if we can't.
# Error is fatal if the fatal option is specified, or if warn is defined
# and false.  Neither defined => non-fatal, for backward compatibility.
sub mkdirs($;$) {
    my %opt = subopts(\@_, [1], qw(fatal));
    my $warn = !$opt{fatal} && !defined($opt{warn}) || $opt{warn};
    my($dir) = @_;
    if(-d $dir) {
        return 1;
    } elsif(-e $dir) {
        fatal({'warn' => $warn}, "file exists and is not a directory: $dir");
        return 0;
    } else {
        if(my $parent = dirname($dir)) {
            mkdirs($parent) or return 0;
        }
        CORE::mkdir($dir)
            or fatal({'warn' => $warn}, "failed to mkdir $dir: $!")
                and return 0;
        return 1;
    }
}

# Keep this for backward compat.
sub mkdir {
    return &mkdirs;
}

sub rmdir($) {
    my($dir) = @_;
    if(-e $dir) {
        local $SIG{__WARN__} = sub {
            local $_ = "@_";
            s/ at .*? line \d+$//gm;
            error $_;
        };
        File::Path::rmtree($dir);
    }
    return !-e $dir;
}

sub cd($) {
    my($dir) = @_;
    chdir($dir) or fatal "can't chdir to $dir: $!";
}

sub pushd($) {
    my($dir) = @_;
    my $old = Win32::GetCwd();
    cd($dir);
#    chdir($dir) or Carp::croak("*** can't chdir to $dir: $!\n");
    return $old;
}

sub move($$) {
    my($src, $dst) = @_;
    -e $src or error "can't move $src: not found" and return 0;
    -d $dst and $dst = catfile($dst, basename($src));
    rename($src, $dst) or error "can't move $src to $dst: $!" and return 0;
    return 1;
}

# copy src to dst; dst may be a dir
sub copy($$) {
    my($src, $dst) = @_;
    -e $src or fatal "can't copy $src: file not found";
    -f $src or fatal "can't copy $src: not a file";
    -d $dst and $dst = catfile($dst, basename($src));
    my $dir = dirname($dst);
    -d $dir or fatal "can't copy to $dir: directory not found";
    unlink($dst);
    File::Copy::copy($src, $dst) or fatal "Can't copy $src to $dst: $!";
    #Win32::CopyFile($src, $dst, 1);
    #if(Win32::GetLastError()) {
    #    fatal "can't copy %s to %s: %s",
    #        $src, $dst, Win32::FormatMessage(Win32::GetLastError());
    #}
}

# Copy dir $src to dir $dst.  $dst is actual name of copy and must not exist.
# Its parents are created as needed.
sub copy_dir($$) {
    my($src, $dst) = @_;
    check_dir($src) or return 0;
    -e $dst and error "dst of copy dir already exists: $dst" and return 0;
    mkdirs(dirname($dst));
    run('xcopy', '/e/i/q/k/y', win_slash($src), win_slash($dst));
    return 1;
}

# see if we need to start a view or mount a vob to make path accessible
sub cc_check_path($) {
    my($path) = @_;
    -e $path and return;
    $path =~ m#^m:[/\\]([^/\\]+)([/\\][^/\\]+)?#i or return;
    my($viewtag, $vob) = ($1, $2);
    if(!-d "m:\\$viewtag") {
        ct({nodie => 1, verbose => 1, stdout => 1}, 'startview', $viewtag);
    }
    if($vob && -d "m:\\$viewtag" && !-d "m:\\$viewtag$vob") {
        ct({nodie => 1, verbose => 1, stdout => 1}, 'mount', $vob);
    }
}

# Parse the output of ct desc and return as hash.
sub cc_parse_info($) {
    local($_) = @_;
    my @x = split(/^ *(.*):\s/m, "\n" . $_);
    map { s/^\s+//gm; s/\s+$//gm; } @x;
    unshift(@x, 'misc');
    push(@x, '') if @x % 2 == 1;  # split drops empty trailing values
    my %x = @x;
    return \%x;
}

# Run a ct describe command and parse output like cc_parse_info
sub cc_parse_describe(@) {
    my(@args) = @_;
    return cc_parse_info(ct('describe', @args));
}

# return 2-elem array representing view root & vob of cwd or named dir.
# or path to vob
sub get_view_and_vob(;$) {
    my($dir) = @_;
    $dir = dirname($dir) if defined($dir) && -f $dir;
    my $vob = undef;
    my $view = ct({indir => $dir, nodie => 1}, 'pwv', '-root');
    chomp($view);
    $? != 0 || $view eq '' and $view = undef;
    my $full = fullpath($dir || '.');
    if(!$view && $full =~ /^([a-z]:)/i) {
        my $drive = $1;
        local $_ = Misc::run({nodie => 1}, 'net', 'use', $drive);
        if(/\nRemote name\s+\\\\view\\/) {
            $view = "$drive";
        }
    }
    if($view) {
        $vob = $full =~ /^\Q$view\E\\([^\\]+)/i ? $1 : undef;
    }
    return wantarray ? ($view, $vob)
        : defined $view && defined $vob ? catdir($view, $vob)
        : undef;
}

# run a cleartool command & return output; die if it fails
sub ct(@) {
    my %opt = subopts(\@_, [], qw(indir stdout pipe nodie verbose effort));
    my(@args) = @_;
    return run(\%opt, 'cleartool', @args);
}

# Run a cmd and return output and one big string or list of lines, depending on context.
# First arg can be hash of options:
#   indir   => dir to run in
#   stdout  => print output to stdout instead of returning it
#   output  => print output to named file instead of returning it
#   pipe    => return a pipe to read output from
#   nodie   => don't die if command fails
#   verbose => print command before running it
#   effort  => print command but don't run it
sub run(@) {
    my %opt = subopts(\@_, [], qw(indir stdout output pipe nodie verbose effort));
    my(@args) = @_;
    my @cmd = quoteargs(@args);
    $opt{verbose} || $opt{effort}
        and note 'running' . ($opt{indir} ? " in $opt{indir}" : '') . ": @cmd";
    $opt{effort} and return '';
    defined($opt{output}) + defined($opt{'pipe'}) + defined($opt{stdout}) > 1
        and internal 'options output, pipe, and stdout are mutually exclusive';
    my $out_fh = undef;
    if (defined(my $output = $opt{output})) {
        #$out_fh = do_open({nodie => $opt{nodie}}, '>', $output)
        #    or $opt{nodie} or fatal "can't open $output: $!";

        $out_fh = do_open({nodie => $opt{nodie}}, '>', $output);
        if (!defined($out_fh)) {
            fatal "can't open $output: $!" unless $opt{nodie};
            return undef;
        }
#        select($out_fh);
#        $opt{stdout} = 1;
    } elsif ($opt{stdout}) {
        $out_fh = select(STDOUT);
    }
    my $cwd;
    if($opt{indir}) {
        $cwd = Win32::GetCwd();
        chdir($opt{indir})
            or $opt{nodie} or fatal "can't chdir to $opt{indir}: $!";
    }
    my $fh = do_open({nodie => $opt{nodie}}, '-|', "@cmd 2>&1");
    return undef unless defined $fh;
    $opt{indir} and chdir($cwd);
    return $fh if $opt{'pipe'};  # filehandle for pipe from cmd
    my $result = '';
    my @result = ();
    local $_;
    while (sysread($fh, $_, 1024) > 0) {
        s/\r\n/\n/g;
    #while(<$fh>) {
        if ($opt{stdout}) {
            print;
        } elsif (defined $out_fh) {
            #???TODO doesn't work for stdout case???
#        if (defined $out_fh) {
            print $out_fh $_;
        } elsif(wantarray) {
            push(@result, $_);
        } else {
            $result .= $_;
        }
    }
    close($fh);  # to get $?
    my $st = $?;
    if(!$opt{nodie} && $st != 0) {
        my $msg = exit_status_msg($st) . " from: @cmd\n";
        $msg .= "in $opt{indir}\n" if $opt{indir};
#        if($opt{stdout}) {
        if(defined $out_fh) {
            # have already seen output
        } elsif(@result) {
            $msg .= join('', @result);
        } else {
            $msg .= $result;
        }
        fatal $msg;
    }
    close($out_fh) if $opt{output};
    return wantarray ? @result : $result;
}

# Return the appropriate message for this exit status
sub exit_status_msg($) {
    my($st) = @_;
    my $msg = '';
    if($st == 0) {
        return '';
    } elsif(($st & 0xff) != 0) {
        return "signal $st";
    } else {
        $st = int($st / 256);
        $st >= 128 and $st -= 256;
        return "exit status $st";
    }
}

# Run a command asynchronously.
# $app is full path of executable to run
# $cmdline is the command line (including command)
sub run_async($;$) {
    my($app, $cmdline) = @_;
    defined $cmdline or $cmdline = $app;
    my $cwd = Win32::GetCwd();
    my $obj;
    require Win32::Process;
    Win32::Process::Create(
        $obj,
        $app,
        $cmdline,
        0,
        Win32::Process::NORMAL_PRIORITY_CLASS(),
        ".")
        or fatal "Running %s\n  %s",
            $app, Win32::FormatMessage(Win32::GetLastError());
}

# run a CVS command and return the output
sub cvs(@) {
    my %opt = subopts(\@_, [], qw(indir stdout pipe nodie verbose effort));
    my(@args) = @_;
    my $CYGWIN = catdir($ENV{ROOT}, 'Cygwin', 'bin');
    my $CVS = catfile($CYGWIN, 'cvs.exe');
    $ENV{CVS_RSH} = catfile($CYGWIN, 'ssh.exe');
    return Misc::run(\%opt, $CVS, get_cvs_root_opt($opt{indir} || '.'), @args);
}

use constant CVS_ROOT_FILE => 'CVS/Root';
sub get_cvs_root_opt($) {
    my($dir) = @_;
    my $root_file = catfile($dir, CVS_ROOT_FILE);
    if(-e $root_file) {
        # extssh doesn't seem to be support from command line
        # so switch to ext
        local $_ = get($root_file);
        if(s/:extssh:/:ext:/) {
            chomp;
            return ('-d', $_);
        }
    }
    return ();
}

my $ct;
sub ct_new(@) {
    require Win32::OLE;
    my $opt = new Options(\@_,
        'indir=s<dir>' => 'run in <dir> instead of cwd',
        'stdout'       => 'send output to stdout in addition to returning it',
        'nodie'        => "don't die on error from cmd",
        'verbose'      => 'show command being executed',
        'effort'       => "show command but don't execute",
    );
    my(@args) = @_;
    my $args = join(' ', quoteargs(@args));
    $opt->get(-verbose) || $opt->get(-effort)
        and note 'running%s: %s',
            $opt->get(-indir) ? " in $opt->get(-indir)" : '', "cleartool $args";
    $opt->get(-effort) and return '';
    my $cwd;
    if($opt->get(-indir)) {
        $cwd = Win32::GetCwd();
        chdir($opt->get(-indir))
            or $opt->get(-nodie)
            or fatal "can't chdir to %s: %s", $opt->get(-indir), $!;
    }

    if(!defined($ct)) {
        $ct = new Win32::OLE('ClearCase.ClearTool');
        if(!defined($ct)) {
            my $msg = "can't create ClearCase.Cleartool object";
            if($opt->get(-nodie)) {
                error $msg;
                return undef;
            } else {
                fatal $msg;
            }
        }
    }
    Win32::OLE->Option(Warn => 0);  # don't have OLE print errors
    my $result = $ct->Invoke('CmdExec', $args);
    $opt->get(-indir) and chdir($cwd);
    if(my $error = Win32::OLE::LastError()) {
        $error =~ s/\r/\n/g;
        $error =~ s/^OLE exception from .*\n+//;
        $error =~ /\n+Win32::OLE\(.*?\) error 0x/ and $error = $`;
        $error = "cleartool: $error";
        $opt->get(-nodie) or fatal $error;
        $result = $error . "\n";
        $? = 1;
    }

    $opt->get(-stdout) and print $result;
    if(wantarray) {
        return split(/\n/, $result);
    } else {
        return $result;
    }
}


# run a cleartool command & return output; die if it fails
sub ct2(@) {
    my $opt = new Options(\@_,
        'indir=s<dir>' => 'run in <dir> instead of cwd',
        'stdout'       => 'send output to stdout in addition to returning it',
        'pipe'         => 'open pipe from cmd and return file handle',
        'nodie'        => "don't die on error from cmd",
        'verbose'      => 'show command being executed',
        'effort'       => "show command but don't execute",
    );
    my(@args) = @_;
    return run2($opt->image, 'cleartool', @args);
}

# Run a cmd.  First arg can be hash of options: indir, nodie, verbose, effort
sub run2(@) {
    my $opt = new Options(\@_,
        'indir=s<dir>' => 'run in <dir> instead of cwd',
        'stdout'       => 'send output to stdout in addition to returning it',
        'pipe'         => 'open pipe from cmd and return file handle',
        'nodie'        => "don't die on error from cmd",
        'verbose'      => 'show command being executed',
        'effort'       => "show command but don't execute",
    );
    my(@args) = @_;
    my @cmd = quoteargs(@args);
    $opt->get(-verbose) || $opt->get(-effort)
        and note 'running%s: %s',
            $opt->get(-indir) ? " in $opt->get(-indir)" : '', "@cmd";
    $opt->get(-effort) and return '';
    my $cwd;
    if($opt->get(-indir)) {
        $cwd = Win32::GetCwd();
        chdir($opt->get(-indir))
            or $opt->get(-nodie)
            or fatal "can't chdir to %s: %s", $opt->get(-indir), $!;
    }
    my $fh = do_open('-|', "@cmd 2>&1");
    $opt->get(-indir) and chdir($cwd);
    return $fh if $opt->get('-pipe');  # filehandle for pipe from cmd
    my $result = '';
    my @result = ();
    local $_;
    while(<$fh>) {
        if(wantarray) {
            push(@result, $_);
        } else {
            $result .= $_;
        }
        print if $opt->get(-stdout);
    }
    close($fh);  # to get $?
    my $st = $?;
    if(!$opt->get(-nodie) && $st != 0) {
        my $msg = '';
        if(($st & 0xff) != 0) {
            $msg .= "signal $st";
        } else {
            $st = int($st / 256);
            $st >= 128 and $st -= 256;
            $msg .= "exit status $st";
        }
        $result = join('', @result) if @result;
        $msg .= " from: @cmd\n$result";
        fatal $msg;
    }
    return wantarray ? @result : $result;
}

sub run_old(@) {
    my(@args) = @_;
    my @cmd = quoteargs(@args);
    return `@cmd 2>&1`;
}

sub quoteargs(@) {
    my(@args) = @_;
    my @result = ();
    for(@args) {
        if(!/"/) { # don't do anything if there are already quotes
            if(/[\s\+\~\%\^\(\)\{\}\[\]\,\`\']/ || /^$/) {
                $_ = '"' . $_ . '"';
            }
        }
        push(@result, $_);
    }
    return @result;
}

# If this is a build id of form MMMM.NNNN or NNNN, return it as MMMM.NNNN.
# Otherwise undef.
sub get_build_id($) {
    my($id) = @_;
    if($id =~ /^\d{4}\.\d{4}$/) {
        return $id;
    } elsif($id =~ /^(\d\d)\d\d$/) {
        my $d = $1;
        my $now = Time::localtime::localtime;
        my($y, $m) = ($now->year % 100, $now->mon + 1);
        if($d > $now->mday) {
            $m -= 1;  # after today: assume last month
            $m == 0 and $m = 12 and $y -= 1;
        }
        return sprintf("%02d%02d.%s", $y, $m, $id);
    } else {
        return undef;
    }
}

use constant NUM2MON => [ qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec) ];
use constant MON2NUM => { map { lc(NUM2MON->[$_]) => $_+1 } (0..11) };

# 1..12 to month name
sub num2mon($) {
    my($num) = @_;
    my $mon = NUM2MON->[$num-1];
    defined $mon or fatal "bad month number: $num";
    return $mon;
}

# month name to 1..12
sub mon2num($) {
    my($mon) = @_;
    if($mon =~ /^\d+$/ && defined(num2mon($mon))) {
        return $mon;
    } elsif(defined(my $num = MON2NUM->{lc($mon)})) {
        return $num;
    } else {
        fatal "bad month: $mon";
    }
}

use constant NUM2DAY => [ qw(Sun Mon Tue Wed Thu Fri Sat) ];
use constant DAY2NUM => { map { lc(NUM2DAY->[$_]) => $_+1 } (0..6) };

# 1..7 to day name
sub num2day($) {
    my($num) = @_;
    $num >= 1 && $num <= 7 or fatal "bad day number: $num";
    return NUM2DAY->[$num-1];
}

# day name to 1..7
sub day2num($) {
    my($day) = @_;
    if($day =~ /^\d+$/ && defined(num2day($day))) {
        return $day;
    } elsif(defined(my $num = DAY2NUM->{lc($day)})) {
        return $num;
    } else {
        fatal "bad day: $day";
    }
}

# Date in form yyyy/mm/dd
sub date(;$) {
    my($time) = @_;
    my $l = Time::localtime::localtime(defined $time ? $time : CORE::time);
    return sprintf("%04d/%02d/%02d", $l->year + 1900, $l->mon + 1, $l->mday);
}

# Date in form yyyy-mm-dd
sub date2(;$) {
    my($time) = @_;
    my $l = Time::localtime::localtime(defined $time ? $time : CORE::time);
    return sprintf("%04d-%02d-%02d", $l->year + 1900, $l->mon + 1, $l->mday);
}

# Clearcase-style yymmdd date.
sub cc_date() {
    my $now = Time::localtime::localtime;
    return sprintf("%02d%02d%02d", $now->year % 100, $now->mon + 1, $now->mday);
}

sub time(;$) {
    my($time) = @_;
    my $l = Time::localtime::localtime(defined $time ? $time : CORE::time);
    return sprintf("%02d:%02d", $l->hour, $l->min);
}

sub date_time(;$) {
    my($time) = @_;
    return date($time) . ' ' . Misc::time($time);
}

# convert 12-hour time to 24-hour format, returning either
# (hr, min) or "hr:min".
sub to_24hr($) {
    my($time) = @_;
    $time =~ /^(\d\d?):(\d\d)\s*([ap])m?$/i
        or error "invalid 12-hour time: $time" and return undef;
    my($hr, $min, $ampm) = ($1, $2, $3);
    if($ampm =~ /p/i) {
        $hr += 12 if $hr != 12;  # 5 pm => 17
    } else {
        $hr -= 12 if $hr == 12;  # 12 am => 0
    }
    return wantarray ? ($hr, $min) : sprintf("%02d:%02d", $hr, $min);
}

# Convert date from dd-mmm-yy to a form that can be compared as string,
# namely: yyyy-mm-dd
sub norm_date($) {
    my $date = shift;
    my $result = norm_date_time($date);
    $result =~ s/\..*$//;
    return $result;
#    $date =~ /^(\d+)-(\w\w\w)(-(\d+))?(\..*)?$/ or die "*** bad date: $date\n";
#    my($mday, $mon, $year) = ($1, $2, $3 && $4);
#    if(!$year) {
#        $year = Time::localtime::localtime->year() + 1900;
#    } elsif($year < 100) {
#        $year += 2000;
#    }
#    return sprintf("%04d-%02d-%02d", $year, mon2num($mon), $mday);
}

sub norm_date_time($) {
    my $date = shift;
    $date =~ /^(\d+)-(\w\w\w)(-(\d+))?((\..*)?)$/
        or die "*** bad date: $date\n";
    my($mday, $mon, $year, $time) = ($1, $2, $3 && $4, $5 && $6);
    if(!$year) {
        $year = Time::localtime::localtime->year() + 1900;
    } elsif($year < 100) {
        $year += 2000;
    }
    return sprintf("%04d-%02d-%02d%s", $year, mon2num($mon), $mday, $time);
}

# Now as YYMM
sub get_year_month() {
    my $now = Time::localtime::localtime;
    return sprintf("%02d%02d", $now->year % 100, $now->mon + 1);
}

sub set_clipboard($) {
    my $x = shift;
    require Win32::Clipboard;
    Win32::Clipboard::Set($x);
}

sub get_clipboard() {
    require Win32::Clipboard;
    return Win32::Clipboard::GetText();
}

# List of files copied from Explorer (e.g.)
sub get_clipboard_files() {
    require Win32::Clipboard;
    return Win32::Clipboard::GetFiles();
}

sub get_clipboard_bitmap() {
    require Win32::Clipboard;
    return Win32::Clipboard::GetBitMap();
}

sub get_clipboard_full() {
    require Win32::Clipboard;
    # from perldoc:
    my %FORMAT_NAMES = qw(
        1  CF_TEXT
        2  CF_BITMAP
        3  CF_METAFILEPICT
        4  CF_SYLK
        5  CF_DIF
        6  CF_TIFF
        7  CF_OEMTEXT
        8  CF_DIB
        9  CF_PALETTE
        10 CF_PENDATA
        11 CF_RIFF
        12 CF_WAVE
        13 CF_UNICODETEXT
        14 CF_ENHMETAFILE
        15 CF_HDROP
        16 CF_LOCALE
    );
    print "FORMAT_NAMES{7} = $FORMAT_NAMES{7}\n";
    my $clip = Win32::Clipboard();
    my %result = ();
    for my $format ($clip->EnumFormats()) {
        my $name = $clip->GetFormatName($format);
        $name or $name = $FORMAT_NAMES{$format};
        $name or $name = $format;
        $result{$name} = $clip->GetAs($format);
    }
    return %result;
}

sub get_clipboard_formats() {
    require Win32::Clipboard;
    # from perldoc:
    my %FORMAT_NAMES = qw(
        1  CF_TEXT
        2  CF_BITMAP
        3  CF_METAFILEPICT
        4  CF_SYLK
        5  CF_DIF
        6  CF_TIFF
        7  CF_OEMTEXT
        8  CF_DIB
        9  CF_PALETTE
        10 CF_PENDATA
        11 CF_RIFF
        12 CF_WAVE
        13 CF_UNICODETEXT
        14 CF_ENHMETAFILE
        15 CF_HDROP
        16 CF_LOCALE
    );
    my $clip = Win32::Clipboard();
    my @result = ();
    for my $format ($clip->EnumFormats()) {
        my $name = $clip->GetFormatName($format);
        $name or $name = $FORMAT_NAMES{$format};
        push(@result, $name ? "$format: $name" : $format);
    }
    return @result;
}

# Get clipboard by format name.
sub get_clipboard_format($) {
    my($name) = @_;
    require Win32::Clipboard;
    my $clip = Win32::Clipboard();
    my @result = ();
    for my $format ($clip->EnumFormats()) {
        if($clip->GetFormatName($format) eq $name) {
print "??? format=$format\n";
            return $clip->GetAs($format);
        }
    }
    return undef;
}

sub get_clipboard_html() {
    my $START = '<!--StartFragment-->';
    my $END = '<!--EndFragment-->';
if(0) {
    require Win32::Clipboard;
    my $FORMAT = 49353;
    my $clip = Win32::Clipboard();
    $clip->IsFormatAvailable($FORMAT) or return undef;
    local $_ = $clip->GetAs($FORMAT);
}
    local $_ = get_clipboard_format('HTML Format');
    defined $_ or return undef;
    m#$START(.*)$END#s or return undef;
    $_ = $1;
    s#(</[^<>]*>)\s*#$1\n#g;
    return $_;
}

# chomp   => chomp each line in array context
# stripcr => remove cr's
# nodie   => just return undef if can't read
# warn    => warn & return undef if can't read
sub slurp($;$) {
    my %opt = subopts(\@_, [1], qw(chomp stripcr nodie warn binary));
    my($file) = @_;
    my $chomp = $opt{chomp} and delete $opt{chomp};
    my $stripcr = $opt{stripcr} and delete $opt{stripcr};
    my $in = do_open(\%opt, '<', $file);
    defined $in or return undef;
#    local $/ = wantarray ? $/ : undef;
#    return <$in>;
    if(wantarray) {
        my @result = <$in>;
        local $_;
        $chomp and grep(chomp, @result);
        $stripcr and grep(s/\r//g, @result);
        return @result;
    } else {
        local $/ = undef;
        my $result = <$in>;
        $stripcr and $result =~ s/\r//g; 
        return $result;
    }

#    if(!wantarray) {
#        local $/ = undef;
#        if($stripcr) {
#            return subst(scalar <$in>, "\r" => '');
#        } else {
#            return scalar <$in>;
#        }
#    } elsif($chomp) {
#        local $_;
#        return map { chomp; $stripcr && s/\r//g; $_; } <$in>;
#    } else {
#        return <$in>;
#    }
}

sub get {
    return &slurp;
}

sub simple_get($) {
    my($file) = @_;
    open(my $fh, '<', $file) or return undef;
    local $/ = undef;
    return <$fh>;
}

sub simple_put($$) {
    my($file, $contents) = @_;
    unlink($file);
    my $fh;
    open($fh, '>', $file) or return 0;
    print $fh $contents;
    return 1;
}

# put({options}, file, contents)
sub put($$;$) {
    my %opt = subopts(\@_, [2], qw(nodie warn mkdirs binary));
    my($file, $out) = @_;
    if($opt{mkdirs}) {
        mkdirs({'fatal' => !$opt{warn}}, dirname($file));
        delete $opt{mkdirs};
    }
    unlink($file);
    my $fh = do_open(\%opt, '>', $file);
    if(defined $fh) {
        print $fh $out;
        return 1;
    } else {
        return 0;
    }
}

# Append contents to file.
# append({options}, file, contents)
sub append($$;$) {
    my %opt = subopts(\@_, [2], qw(create nodie warn mkdirs));
    my($file, $out) = @_;
    if(delete $opt{mkdirs}) {
        mkdirs({'fatal' => !$opt{warn}}, dirname($file));
    }
    my $create = delete $opt{create};
    if(-e $file) {
        my $fh = do_open(\%opt, '>>', $file);
        if(defined $fh) {
            print $fh $out;
            return 1;
        } else {
            return 0;
        }
    } elsif($create) {
        return put(\%opt, $file, $out);
    } elsif($opt{warn}) {
        warning "can't append to $file: it does not exist";
        return 0;
    } else {
        fatal "can't append to $file: is does not exist";
    }
}

# Return array of files from a dir.
# Each is relative to dir.
sub get_dir($) {
    my $dir = shift;
    my $fh;
    opendir($fh, $dir) or error "can't readdir $dir: $!" and return ();
    return grep(!/^\.\.?$/, readdir($fh));
}

# Return array of files from a dir.
# Each is relative to cwd.
sub get_dir2($) {
    my $dir = shift;
    my $fh;
    opendir($fh, $dir) or error "can't readdir $dir: $!" and return ();
    return map { catfile($dir, $_) } grep(!/^\.\.?$/, readdir($fh));
}

# Is this dir empty?
sub is_empty_dir($) {
    my($dir) = @_;
    my $fh;
    opendir($fh, $dir) or return 0;
    for(readdir($fh)) {
        /^\.\.?$/ or return 0;
    }
    return 1;
}

# Change this path to one whose case matches the filesystem.
my %DIRS = ();  # cache of dir contents
sub match_case($) {
    my($path) = @_;
    $path = win_slash($path);
    $path eq '.' and return $path;
    $path =~ s/[a-z]:\\$/\U$&/i and return $path;
    my $dir = match_case(dirname($path));
    my $base = basename($path);
    if(!defined($DIRS{$dir})) {
        my %d = ();
        if(-d $dir) {
            for my $file (get_dir($dir)) {
                $d{lc($file)} = $file;
            }
        }
        $DIRS{$dir} = \%d;
    }
    my $d = $DIRS{$dir};
    if(defined(my $b = $d->{lc($base)})) {
        return $dir eq '.' ? $b : catfile($dir, $b);
    } else {
        return $path;
    }
}

# save 9 old copies of a log file
sub save_log($) {
    my($root) = @_;
    for(my $n = 9; $n > 1; $n -= 1) {
        unlink($root . '.' . $n);
        rename($root . '.' . ($n-1), $root . '.' . $n);
    }
    unlink($root . '.1');
    rename($root, $root . '.1');
    unlink($root);
}

# the valid modes for do_open and their meanings
use constant OPEN_MODES => {
    '<' => 'read', '>' => 'write', '>>' => 'append', '+<' => 'update',
    '-|' => 'read pipe from', '|-' => 'write pipe to',
};

# open a file & return filehandle; it is closed when fh goes out of scope
# default mode is '<'
sub do_open_old($;$) {
    my $mode = @_ == 1 ? '<' : shift;
    my $file = shift;
    my $op = OPEN_MODES->{$mode};
    defined($op)
        or Carp::croak("*** bad mode to do_open: '$mode'; legal modes are: '"
            . join("' '", sort keys %{OPEN_MODES()}) . "'\n");
    my $fh;
    open($fh, $mode, $file) or Carp::croak("*** can't $op $file: $!\n");
    return $fh;
}

# open a file & return filehandle; it is closed when fh goes out of scope
# default mode is '<'
sub do_open($;$$) {
    my %opt = subopts(\@_, [1,2], qw(nodie warn binary));
    my($mode, $file) = @_ == 2 ? @_ : @_ == 1 ? ('<', @_) : die;
    assert(defined $file);
    my $binary = delete $opt{binary};
    my $op = OPEN_MODES->{$mode};
    defined($op)
        or Carp::croak("*** bad mode to do_open: '$mode'; legal modes are: '"
            . join("' '", sort keys %{OPEN_MODES()}) . "'\n");
    # check for writable: otherwise we can accidentally hijack clearcase files
    -r $file && !-w $file && $mode =~ />/
        and fatal(\%opt, "can't $op $file: file is readonly");
    my $fh;
    open($fh, $mode, $file)
        or fatal(\%opt, "can't $op $file: $!") and return undef;
    $binary and binmode($fh);
    return $fh;
}

# replace leading dir $old with $new in $path
sub replacedir($$$) {
    my($old, $new, $path) = @_;
    return catdir($new, stripdir($old, $path));
}

# Strip leading directory from path.
sub stripdir($$) {
    my($dir, $path) = @_;
    local $_ = abs2rel($path, $dir);
#    s/^[A-Z]://;  # abs2rel leaves C: at front???
    s/^\\//; # confused by UNC names?
    return $_;
}

# Make $x relative to $y.
# Real abs2rel leaves C: at front???
sub abs2rel($$) {
    my($x, $y) = @_;
    return subst(File::Spec::Functions::abs2rel($x, $y), '^[a-zA-Z]:'=>'');
}

# Make $x relative to $y (default: cwd).
sub relpath($;$) {
    my($x, $y) = @_;
    return abs2rel(fullpath($x), fullpath($y || '.')) || '.';
}

# dump a complicated data structure
sub Dump($;$$) {
    my($x, $in, $label) = @_;
    my $indent = '  ' x $in;
    print $indent;
    print $label if defined($label);
    my $ref = ref($x);
    if(!$ref) {
        $x =~ s/\n/\\n/g;
        print "'$x'\n";
    } elsif($ref eq 'SCALAR') {
        Dump($$x, $in+1, '->');
    } elsif($ref eq 'ARRAY') {
        print "[\n";
        for my $i (0..$#$x) {
            Dump($x->[$i], $in+1, "$i: ");
        }
        print "$indent]\n";
    } elsif($ref eq 'HASH') {
        print "{\n";
        while(my($key, $value) = each %$x) {
            Dump($value, $in+1, "$key => ");
        }
        print "$indent}\n";
    } else {
        print "$x\n";
    }
}

# Like File::Basename::dirname except return undef if no parent,
# i.e. if dirname returns the same dir.
sub dirname($) {
    my($dir) = @_;
    # canon() is to handle dirname("foo/..") which returns "foo"
    my $canon = File::Spec::Functions::canonpath($dir);
    my $result = File::Basename::dirname($canon);
    if($result ne $canon) {
        return $result;
    } else {
        my $full = fullpath($canon);
        $result = File::Basename::dirname($full);
        if($result ne $full) {
            return $result;
        } else {
            return undef;
        }
    }
}

# The root of a path is the basename without the suffix.
sub root($) {
    my($path) = @_;
    return (File::Basename::fileparse($path, '\.[^\.]*'))[0];
}

# The suffix, including the '.'.
sub suffix($) {
    my($path) = @_;
    return (File::Basename::fileparse($path, '\.[^\.]*'))[2];
}

my $tempdir;
sub tempdir() {
    if(!defined $tempdir) {
        $tempdir = $ENV{TEMP};
        defined $tempdir && -d $tempdir
            or $tempdir = File::Spec::Functions::tmpdir();
    }
    return $tempdir;
}

sub is_temp($) {
    my($path) = @_;
    my $tempdir = tempdir();
    return $path =~ /^\Q$tempdir\E\\/;
}

# Like gettemp, but creates an empty dir
sub gettempdir(;$$) {
    my($prefix, $suffix) = @_;
    my $dir = gettemp($prefix, $suffix);
    unlink($dir);
    mkdirs($dir);
    return $dir;
}

# For semi-temp stuff.  If temp is ...temp\tmp move it up one level.
# OK to exist but create it if not
sub gettempdir2($) {
    my($dir) = @_;
    my $temp = tempdir();
    $temp =~ s#([/\\]temp)[/\\]tmp$#$1#i;
    my $result = catdir($temp, $dir);
    mkdirs($result);
    return $result;
}

# Backup file, e.g. for foo.txt use foo.1.txt, foo.2.txt, etc.
# Upon return, foo.txt and foo.1.txt should have same contents.
# If max_age is specfied, backups older than that (in days) are deleted.
# Return 0 if it failed.
sub backup($;$) {
    my($path, $max_age) = @_;
    my($root, $dir, $suffix) = File::Basename::fileparse($path, '\.[^\.]*');
    my @try = ();
    my $try = undef;
    for(my $i = 1; ; $i += 1) {
        $try = "$dir$root.$i$suffix";
        -e $try or last;
        if(defined($max_age) && -M $try > $max_age) {
            unlink($try);  # delete old ones
        } else {
            push(@try, $try);
        }
    }
    while(@try > 0) {
        my $prev = pop(@try);
        rename($prev, $try)
            or error "can't move $prev to $try: $!" and return 0;
        $try = $prev;
    }
    copy($path, $try);
    return -e $try ? 1 : 0;
#    my $i = 0;
#    my $try;
#    do {
#        $i += 1;
#        $try = "$dir$root.$i$suffix";
#    } while (-e $try);
#    for(my $i = 1; ; $i += 1) {
#        my $try = "$dir$root.$i$suffix";
#        #-e $try && -M $try > 7 and unlink($try);  # delete old ones
#        if(!-e $try) {
#            do_open('>', $try);  # create it immediately
#            return $try;
#            #return File::Spec::Functions::canonpath($try);
#        }
#    }
}

sub gettemp(;$$) {
    my($prefix, $suffix) = @_;
    if(defined $prefix) {
        $prefix =~ s/\.(.+)$// and !defined $suffix and $suffix = $1;
    } else {
#    if(!defined $prefix) {
        $prefix = subst($FindBin::Script, '\..*$' => '');
    }
    if(!defined $suffix) {
        $suffix = 'tmp';
    }
    my $path = $prefix;
    if (!is_fullpath($path)) {
        $path = catfile(tempdir(), $path);
    }
    if($path !~ m#[\\/]$#) {
        $path .= '.';
    }
    my $dir = File::Basename::dirname($path . 'X');
    mkdirs({fatal => 1}, $dir);
#    -d $dir or File::Path::mkpath($dir) or fatal "can't make dir $dir: $!";
    for(my $i = 1; ; $i += 1) {
        my $try = "$path$i.$suffix";
        -e $try && -M $try > 7 and unlink($try);  # delete old ones
        if(!-e $try) {
            do_open('>', $try);  # create it immediately
            return File::Spec::Functions::canonpath($try);
        }
    }
}

# Create a new empty temp file of the form $prefix<number>.$suffix.
# If $prefix ends with a slash the files will be <number>.$suffix; if it ends
# with "foo" they will be foo.<number>.$suffix
# If $prefix isn't a full path, interpret it relative to $TEMP
# Clean up old ones older than $max_age days.
sub mktemp(;$$$) {
    my($prefix, $suffix, $max_age) = @_;
    $prefix = '' unless defined $prefix;
    $suffix = 'tmp' unless defined $suffix;
    $max_age = 7 unless defined $max_age;
    if($prefix !~ m#^([A-Z]:|\\|/)#) {
        $prefix = catfile($ENV{TEMP}, $prefix);
    }
    if($prefix !~ m#[\\/]$#) {
        $prefix .= '.';
    }
    my $dir = File::Basename::dirname($prefix . 'X');
print "??? dir=$dir\n";
    mkdirs({fatal => 1}, $dir);
    for(my $i = 1; ; $i += 1) {
        my $try = "$prefix$i.$suffix";
        -e $try && -M $try > $max_age and unlink($try);  # delete old ones
        if(!-e $try) {
            do_open('>', $try);  # create it immediately
            return File::Spec::Functions::canonpath($try);
        }
    }
}

# $tempfile = puttemp($contents)
# $tempfile = puttemp($prefix, $contents)
# $tempfile = puttemp($prefix, $suffix, $contents)
sub puttemp($;$$) {
    my $contents = pop(@_);
    my($prefix, $suffix) = @_;
    my $tempfile = gettemp($prefix, $suffix);
    put($tempfile, $contents);
    return $tempfile;
}

#EXPERIMENTAL:
# Get named or positional args.  Arg names are passed in, hash of values
# is returned.  Non-named args are assumed to be in order of names.
# sub func(@) { my %args = getargs(\@_, qw(foo bar gorn)); }
# func(0, gorn => 1) => foo=0, bar=undef, gorn=1
sub getargs($@) {
    my($args, @names) = @_;
    my %names = map { $_ => 1 } @names;
    my @args = @$args;
    my %result = ();
    # get positional args
    while(@args) {
        my $arg = shift(@args);
        if($names{$arg}) {
            # first named arg
            unshift(@args, $arg);
            last;
        }
        my $name = shift(@names);
        $result{$name} = $arg;
    }
    # get named args
    while(@args) {
        my $name = shift(@args);
        $names{$name} or die "*** unexpected arg name: $name\n";
        defined(my $value = shift(@args))
            or die "*** missing value for arg $name\n";
        $result{$name} = $value;
    }
    return %result;
}

# Pass in ref to args, ref to count array, and list of valid options.
# If first arg is hash ref, it is options which are check against the
# valid list and returned as a hash.  The count arrays indicates how
# many args should be left: empty => any number; 1 elem => that number;
# 2 elem => in that range.
sub subopts($$@) {
    my($args, $count, @valid) = @_;
    my %opts = ();
    if(ref($args->[0]) =~ /^(ARRAY|HASH)$/) {
        %opts = $1 eq 'HASH' ? %{shift @$args} : list_to_set @{shift @$args};
        my %valid = list_to_set @valid;
        for my $key (keys %opts) {
            $valid{$key} or Carp::croak("*** invalid optional arg: $key\n"
                . "... valids ones are: @valid\n");
        }
    }
    # check number of remaining args
    my $nargs = @{$args};
    my @count = @{$count};
    if(@count == 0) { # any number 
    } elsif(@count == 1) {
        $nargs == $count[0]
            or Carp::croak("*** expected $count[0] args; found: @{$args}\n");
    } elsif(@count == 2) {
        $nargs >= $count[0] && $nargs <= $count[1]
            or Carp::croak("*** expected $count[0]-$count[1] args;"
                . " found: @{$args}\n");
    } else {
        Carp::croak("&&& bad count arg to subopts: @count\n");
    }
    return %opts;
}

# REPLACEMENT for subopts

# This sub provides support for options args to sub.  It is used like this:
#   sub foo(@) {
#       my $opt = options(\@_, <option descriptors>);
#       my(<args>) = @_;
# The option descriptors
sub options($@) {
    my($ref, @args) = @_;
    Misc::assert(ref $ref eq 'ARRAY',
        'first arg to options must be ref to arg array');
    my $opt = ref $args[0] eq 'HASH' ? shift(@args) : {};
    Misc::assert(@args % 2 == 0, 'options must have odd number of args');
    my $caller = (caller(1))[3];
    my @save_ARGV = @ARGV;
    @ARGV = @$ref;
    $opt->{'sub'} = $caller;
    my $result = Misc::getopt($opt, 'dummy', @args);
    Misc::assert(defined $result, "bad options to $caller");
    @$ref = @ARGV;
    @ARGV = @save_ARGV;
    return $result;
}

# return the difference of two sets, represented as lists
sub set_diff($$) {
    my($x, $y) = @_;
    assert(ref $x eq 'ARRAY', 'arg 1 of set_diff must be an array ref');
    assert(ref $y eq 'ARRAY', 'arg 2 of set_diff must be an array ref');
    my %y = list_to_set(@$y);
    my @result = ();
    for my $z (@$x) {
        defined $y{$z} or push(@result, $z);
    }
    return @result;
}

# return the intersection of two sets, represented as lists
sub set_and($$) {
    my($x, $y) = @_;
    assert(ref $x eq 'ARRAY', 'arg 1 of set_diff must be an array ref');
    assert(ref $y eq 'ARRAY', 'arg 2 of set_diff must be an array ref');
    my %y = list_to_set(@$y);
    my @result = ();
    for my $z (@$x) {
        defined $y{$z} and push(@result, $z);
    }
    return @result;
}

# Is $x one of the elements in @list?
sub member($@) {
    my($x, @list) = @_;
    return scalar grep($_ eq $x, @list);
}

# Convert a list to a set, represented as a hash with all values == 1.
sub list_to_set(@) {
    my(@list) = @_;
    local $_;
    return map { $_ => 1 } @list;
}

# Push $val on array ref'd by $ref.  Create if not there
# NOTE: $val IS NOT added if already there.
sub add_to_list($$) {
    my($ref, $val) = @_;
    if(!defined $$ref) {
        $$ref = [];
    } elsif(!member($val, @$$ref)) {
    } else {
        return;
    }
    push(@$$ref, $val);
}

# Push $val on array ref'd by $ref.  Create if not there
# NOTE: $val IS added if already there.
sub add_to_list2($$) {
    my($ref, $val) = @_;
    if(!defined $$ref) {
        $$ref = [];
    }
    push(@$$ref, $val);
}

sub add_all_to_list($@) {
    my($ref, @vals) = @_;
    if(!defined $$ref) {
        $$ref = [];
    }
    push(@$$ref, @vals);
}

# Diff two lists of text (ignoring case).
sub diff_list($$) {
    my($l1, $l2) = @_;
    assert(ref($l1) eq 'ARRAY', "expected array ref, got: $l1");
    assert(ref($l2) eq 'ARRAY', "expected array ref, got: $l2");
    my @s1 = isort @$l1;
    my @s2 = isort @$l2;
    push(@s1, "\377");  # mark end with string gt any normal one
    push(@s2, "\377");
    my $result = '';
    while(@s1 > 1 || @s2 > 1) {
        assert(@s1 > 0 && @s2 > 0, 'internal error');
        my $cmp = lc($s1[0]) cmp lc($s2[0]);
        if($cmp < 0) {
            $result .= '< ' . shift(@s1) . "\n";
        } elsif($cmp > 0) {
            $result .= '> ' . shift(@s2) . "\n";
        } else {
            shift(@s1);
            shift(@s2);
        }
    }
    return $result;
}

# Get the eclipse project containing $file (default: cwd)
# undef if not in eclipse project
sub get_project(;$) {
    my($file) = @_;
    $file = getcwd() unless defined $file;
    for (; defined($file); $file = dirname($file)) {
        -f "$file/.project" and return $file;
    }
    return undef;
}

# Get the workspace the current directory is contained in, or undef.
sub get_cwd_workspace() {
    for (my $dir = getcwd(); defined($dir); $dir = dirname($dir)) {
        -d catdir($dir, '.metadata') and return $dir;
    }
    return undef;
}

# Get the current workspace from the 'ws' abbreviation.
sub get_workspace() {
    my $abbrevs = catfile($ENV{USERPROFILE}, 'abbrev.txt');
    -f $abbrevs or return undef;
    local $_ = Misc::get($abbrevs);
    # get last line starting with 'ws '
    /.*^ws +(.+?)$/ms or return undef;
    return $1;
}

# Return the name of the pvob, or the arg with it appended.
sub pvob(;$$) {
    local $_ = join(':', @_);
    return /\@\\r_pvob$/ ? $_ : $_ . '@\r_pvob';
}

sub unpvob($) {
    local $_ = shift;
    s/\@\\r_pvob\b//g;
    return $_;
}

sub get_current_stream(;$) {
    my($dir) = @_;
    local $_ = ct({nodie => 1, indir => $dir}, 'lsstream', -short);
    $? != 0 and return undef;
    chomp;
    return $_;
#    s/^\S+ +(\S+) .*\n/$1/ or return undef;
#    return $1;
}

sub get_current_project(;$) {
    my($dir) = @_;
    local $_ = ct({nodie => 1, indir => $dir}, 'lsproject', '-cview');
    $? != 0 and return undef;
    /^\S+ +(\S+) +\S+( +"(.*)")?$/ or return undef;
    return $2 ? $3 : $1;
}

sub get_project_info(;$) {
    my($dir) = @_;
    local $_ = unpvob(ct({nodie => 1, indir => $dir},
        'lsproject', '-cview', '-long'));
    $_ eq '' and fatal('not in a UCM project');
    my($name, $date, $creator, $comment)
        = /^project "(.*)".*\n *(\S+) by +(.*)\n *(?:"(.*)")?/
        or die "*** bad output from lsproject:\n$_";
    my @recbls = @{_match_array('recommended baselines')};
    my %recbls = map { /(.*) \((.*)\)/ and ($2 => $1) } @recbls;
    my $title = eval { _match('title') };  # may not be there
    return Project->new(
        name       => $name,
        comment    => $comment,
        date       => $date,
        creator    => $creator,
        master     => _match('master replica'),
        title      => $title,
        intstream  => _match('integration stream'),
        comps      => _match_array('modifiable components'),
        recbls     => \%recbls,
    );
}

sub _match($) {
    my($pat) = @_;
    /^ *$pat: *(.*)/m
        or die "&&& internal error: failed to find '$pat:' in:\n$_";
    return $1;
}

sub _match_array($) {
    my($pat) = @_;
    /^ *$pat:\n */m or die "*** didn't find \"$pat:\" in:\n$_";
    my $x = $';
    $x =~ s/^ *[\w ]+:.*//ms;
    my @x = split(/\n */, $x);
    return \@x;
}

# Return list of checkedout files in given dir.
sub find_checkedout($) {
    my($dir) = @_;
    check_in_view($dir);
    my $in = Misc::do_open(
        '-|', "cleartool lsco -cview -r -short \"$dir\" 2>&1");
    my @result = ();
    while(<$in>) {
        chomp;
        push(@result, $_);
    }
    return @result;
}

# Return list of hijacked files in given dir.
sub find_hijacked($) {
    my($dir) = @_;
    check_in_view($dir);
    local $_ = ct('update', '-print', '-log', 'NUL', $dir);
    my @result = /^Keeping hijacked object "(.*?)"/gm;
    if(@result) {
        my($view, undef) = get_view_and_vob();
        @result = map { stripdir('.', catfile($view, $_)) } @result;
    }
    return @result;
}

sub check_in_view($) {
    my($dir) = @_;
    ct({indir => $dir, nodie => 1}, 'pwv', '-short');
    $? == 0 or fatal "not in a view: $dir";
}

sub mount($) {
    my($vob) = @_;
    local $_ = ct({nodie => 1}, 'mount', "\\$vob");
    if($? && !/ is already mounted/) {
        s/^cleartool: error: //gmi;
        fatal "mount: $_"
    }
}

# Return the list of labels found on this file.
sub get_labels($) {
    my($path) = @_;
    local $_ = ct('describe', '-fmt', '%l', $path);
    s/^\((.*)\)$/$1/;
    return split(/, /, $_);
}

# Diff two maps returning three lists of keys:
# my($only_in_1, $only_in_2, $different) = diff_map(\%map1, \%map2);
sub diff_map($$) {
    my($map1, $map2) = @_;
    my(@only_in_1, @only_in_2, @different) = ();
    for my $k (sort keys %$map1) {
        my $v2 = $map2->{$k};
        if (!defined $v2) {
            push(@only_in_1, $k);
        } elsif ($v2 ne $map1->{$k}) {
            push(@different, $k);
        } else {
            # same value in both
        }
    }
    for my $k (sort keys %$map2) {
        if (!defined $map1->{$k}) {
            push(@only_in_2, $k);
        }
    }
    return (\@only_in_1, \@only_in_2, \@different);
}

sub diffstr($$) {
    my($s1, $s2) = @_;
    my($t1, $t2) = (gettemp('diff'), gettemp('diff'));
    put($t1, subst($s1, "\n*\$" => "\n"));
    put($t2, subst($s2, "\n*\$" => "\n"));
    local $_ = diff($t1, $t2);
    unlink($t1);
    unlink($t2);
    s/^((===|---|\+\+\+) .*\n)+//;
    return $_;
}

# Return 1 if files $f1 and $f2 are different
sub diff($$) {
    my($f1, $f2) = @_;
    return run({nodie => 1}, 'diff', $f1, $f2);
#    return subst(
#        ct({nodie => 1}, 'diff', '-diff', $f1, $f2),
#    "exit status 1 from: .*\n" => '',
#    "cleartool: Warning: No type info, using text file type manager.*\n" => '',
#            "\r" => '');
}

# Fix up up diff output
sub fix_diff($) {
    local($_) = @_;
    s/^\? (.+)/=== added $1/gm;
    s/^cvs (diff|server): Diffing .*\n//gm;
    s/\n+(cvs diff:)/\n\n$1/g;
my $PAT = qq{\n=====+\nRCS file: .*\n(?:retrieving revision .*\n)+diff .*-r};
    s{^Index: (.+)$PAT(\S+).*}{\n=== diff $1 $2}gm;
    # new files:
    s{^Index: (.+)\n=====+\nRCS file: .*\ndiff -N .*}{=== diff $1}gm;
    
    s/^\n//;
    s/\n+$/\n\n/;

    # convert format of unidiff; c.f. diff.pl
#    s/^ /  /gm;
#    s/^---/>>>/gm;
#    s/^-/> /gm;
#    s/^\+\+\+/<<</gm;
#    s/^\+/< /gm;
#    s/^@@ -([\d,]+) \+([\d,]+) @@\n/\n@@ <$2 >$1 @@\n/gm;
#    # put < lines before > lines
#    s/^((?:>.*\n)+)((?:<.*\n)+)/$2$1/gm;

    #<<< and >>> lines have times in GMT: fix that
    s/^(<<<|>>>|---|\+\+\+)(.*?[ \t]{2,})(.+?)((?:\s+\d+\.\d+)?)$/"$1 $2".fix_gmt($3).$4/egm;
    return $_;
}

# Convert GMT to local time, if appropriate
sub fix_gmt($) {
    my($t) = @_;
#print "??? t = <$t>\n";
    $t =~ /^(\d+)\s+(\w+)\s+(\d{4})\s+(\d+):(\d+):(\d+)\s*-000+$/
        or return $t;
    my($mday, $mon, $year, $hr, $min, $sec) = ($1, $2, $3, $4, $5, $6);
#print "$mday, $mon, $year, $hr, $min, $sec\n";
    my $time = Time::Local::timegm(
        $sec, $min, $hr, $mday, Misc::mon2num($mon)-1, $year);
    return Misc::date_time($time);
}

# Determine if two files have the same contents.
# We don't product a diff, so we don't need an external program like diff or cc.
sub same_file($$) {
    my($f1, $f2) = @_;
    if(!-e $f1) {
        return !-e $f2;
    } elsif(!-e $f2) {
        return 0;
    } elsif(-s $f1 != -s $f2) {
        return 0;
    } else {
        my $h1 = Misc::do_open({binary => 1}, $f1);
        my $h2 = Misc::do_open({binary => 1}, $f2);
        my($b1, $b2);
        for(;;) {
            my $n1 = read($h1, $b1, 16*1024)
                or return 1;  # EOF: no difference found
            my $n2 = read($h2, $b2, 16*1024);
            $b1 ne $b2 and return 0;  # found a difference
        }
    }
}

# find files in @dirs whose simple name matches pat
sub find_files($@) {
    my($pat, @dirs) = @_;
    my @result = ();
    @dirs = ('.') if @dirs == 0;
    $File::Find::name = '';  # prevent warnings
    for my $dir (@dirs) {
        check_dir($dir) or next;
        File::Find::find({
            wanted => sub {
                basename($_) =~ /$pat/ and push(@result, canonpath $File::Find::name);
            },
            no_chdir => 1,
        }, $dir);
    }
    return @result;
}

sub dir_size($) {
    my($dir) = @_;
    check_dir($dir) or return undef;
    my $size = 0;
    File::Find::find({
        wanted => sub { -f $_ and $size += -s $_ },
        no_chdir => 1,
    }, $dir);
    return $size;
}

# Remove files under $dir that match $pat.
sub clean($$) {
    my($pat, $dir) = @_;
    my @clean = find_files($pat, $dir);
    for my $clean (@clean) {
        if(-d $clean) {
            Misc::rmdir($clean);
        } else {
            unlink($clean) or error "can't remove $clean: $!";
        }
    }
}

# Return keys of a hash, sorted by numeric values.
sub nsort(%) {
    my(%x) = @_;
    return sort { $x{$a} <=> $x{$b} } keys %x;
}

# case-insensitive sort
sub isort(@) {
    return sort { lc $a cmp lc $b } @_;
}

# Sort a list of files by date, increasing.
sub sort_by_date(@) {
    my(@files) = @_;
    return sort { -M $b <=> -M $a } @files;
}

# Trim whitespace off beginning and end.
sub trim($) {
    my($x) = @_;
    $x =~ s/^\s+//;
    $x =~ s/\s+$//;
    return $x;
}

# Apply some global substitutions to a value and return new value.
sub subst($@) {
    my %opt = subopts(\@_, [], qw(quote));
    my($x, @map) = @_;
    assert(defined $x, '');
    assert(@map % 2 == 0, 'subst requires an odd number of params');
    while(@map) {
        my $to = shift(@map);
        $opt{quote} and $to = "\\Q$to\\E";
        my $from = shift(@map);
        assert(defined $to && defined $from, '');
        $x =~ s/$to/$from/g;
    }
    return $x;
}

# Read $file and match $pat in it, returning $1.
# undef if not found
sub get_pat_in_file2($$) {
    my($file, $pat) = @_;
    assert($pat =~ /\(.*\)/, "pat must have parens: $pat");
    local $_ = Misc::get($file);
    /$pat/ or return undef;
    return $1;
}

# Read $file and match $pat in it, returning $1.
# fatal error if not found
sub get_pat_in_file($$) {
    my($file, $pat) = @_;
    my $result = get_pat_in_file2($file, $pat);
    defined $result or fatal "didn't find pattern \"$pat\" in $file";
    return $result;
}

# Convert slashes to Windows-style.
sub win_slash($) {
    my($path) = @_;
    $path =~ tr#/#\\#;
    return $path;
}

# Convert slashes to UNIX-style.
sub unix_slash($) {
    my($path) = @_;
    $path =~ tr#\\#/#;
    return $path;
}

sub to_url($) {
    my($path) = @_;
    return "file:///" . Misc::unix_slash(fullpath($path));
}

sub expand_links(@) {
    my(@args) = @_;
    return map { expand_link($_) } @args;
}

# If arg is a shortcut, return what it points to.
sub expand_link($) {
    my($arg) = @_;
    if(-f $arg && $arg =~ /\.lnk$/i) {
        require Win32::Shortcut;
        my $s = new Win32::Shortcut();
        $s->Load($arg) and $arg = $s->Path();
    }
    return $arg;
}

# my_glob($glob) does glob with back slashes
# my_glob($root, $glob) globs $glob relative to $root
# Both allow for spaces
sub my_glob($;$) {
    if(@_ == 2) {
        my($root, $glob) = @_;
        return map { stripdir($root, $_) } my_glob(catfile($root, $glob));
    } else {
        my($glob) = @_;
        if($glob =~ /'/) {
            return ($glob);
        } else {
            return glob(subst($glob, ' ' => '\\ '));
            # no longer necessary?
            #return map { win_slash($_) }
            #    glob(subst(unix_slash($glob), ' ' => '\\ '));
        }
    }
}

# Do globbing with {...} supported.
sub bsd_glob(@) {
    my(@path) = @_;
    return File::Glob::bsd_glob(catdir(@path), File::Glob::GLOB_BRACE);
}


# glob args if necessary
sub glob_args(@) {
    my(@args) = @_;
    my @result = ();
    for(@args) {
        if(/^-$/) {
            push(@result, Misc::get_clipboard());
        } elsif(-e $_ || /^".*"$/) {
            push(@result, $_);
        } else {
            my @glob = my_glob($_);
            push(@result, @glob == 0 ? $_ : @glob);
        }
    }
    return @result;
}

# glob args & expand dirs
# Possible options: don't glob, text, recurse, default = (.)
sub expand_args(@) {
    my(@args) = @_;
    @args == 0 and @args = '.';
    my @result = ();
    for my $file (glob_args(@args)) {
        if(-d $file) {
            for my $f (get_dir($file)) {
                my $full = "$file\\$f";
                -f $full and push(@result, $full);
            }
        } else {
            push(@result, $file);
        }
    }
    return @result;
}

# do a glob that expects one dir to match
sub glob_one_dir($) {
    my($glob) = @_;
    my @glob = grep(-d $_, my_glob($glob));
    @glob == 0 and fatal "no match for $glob";
    @glob > 1
        and fatal "more than one match for $glob:%s", join("\n  ", '', @glob);
    return $glob[0];
}

# do a glob that expects one match
sub glob_one($) {
    my($glob) = @_;
    my @glob = my_glob($glob);
    @glob == 0 and fatal "no match for $glob";
    @glob > 1
        and fatal "more than one match for $glob:%s", join("\n  ", '', @glob);
    return $glob[0];
}

# do a glob that expects at least one match
sub glob_one_or_more($) {
    my($glob) = @_;
    my @glob = my_glob($glob);
    @glob == 0 and fatal "no match for $glob";
    return @glob;
}

# Given $x a ref to an array of refs to arrays, format them in columns,
# one element of @$x per line.
sub columnate($) {
    my($x) = @_;
    assert(ref $x eq 'ARRAY', 'arg to columnate must be an array ref');
    my @w = ();  # widths
    for my $y (@$x) {
        assert(ref $y eq 'ARRAY', 'must be array ref');
        for(my $i = 0; $i < @$y; $i += 1) {
            my $z = $y->[$i];
            my $l = length($z);
            $w[$i] = $l if !defined($w[$i]) || $l > $w[$i];
        }
    }
    my $result = '';
    my $fmt = join('  ', map { "%-${_}s" } @w);
    for my $y (@$x) {
        my @z = @$y;
        while ($#z < $#w) {
            push(@z, '');
        }
        $result .= Misc::subst(sprintf($fmt, @z), ' +$' => '', '$' => "\n");
    }
    return $result;
}

# Given $x a ref to an array of refs to arrays, format them in columns,
# one element of @$x per line.
# Like columnate except that output is html for a table.
# Elements have < > & quoted unless {noquote => 1} is specified (in which
# case elements are assumed to be valid html.
sub html_table($;$) {
    my %opt = subopts(\@_, [1], qw(noquote));
    my($x) = @_;
    assert(ref $x eq 'ARRAY', 'arg to columnate must be an array ref');
    my $html = "<table>\n";
    for my $y (@$x) {
        assert(ref $y eq 'ARRAY', 'must be array ref');
        $html .= " <tr>\n";
        for(my $i = 0; $i < @$y; $i += 1) {
            my $z = $y->[$i];
            if(!$opt{noquote}) {
                $z = quote_html($z);
#                $z =~ s#\&#&amp;#g;
#                $z =~ s#<#&lt;#g;
#                $z =~ s#>#&gt;#g;
            }
            $html .= "  <td>$z</td>\n";
        }
        $html .= " </tr>\n";
    }
    $html .= "</table>\n";
    return $html;
}

# Quote special chars in xml or html.
sub quote_html($) {
    my($x) = @_;
    $x =~ s#\&#&amp;#g;
    $x =~ s#<#&lt;#g;
    $x =~ s#>#&gt;#g;
    $x =~ s#"#&quot;#g;
    return $x;
}

# Un-quote special chars in xml or html.
sub unquote_html($) {
    my($x) = @_;
    $x =~ s#&lt;#<#g;
    $x =~ s#&gt;#>#g;
    $x =~ s#&quot;#"#g;
    $x =~ s#&amp;#\&#g;
    return $x;
}

# Indent a string by a number of spaces.
sub indent($$) {
    my($spaces, $string) = @_;
    my $indent = ' ' x $spaces;
    $string =~ s/^/$indent/gm;
    return $string;
}

# this asserts that caller is private, i.e. can't be called from other packages
sub private() {
    my($package0, $filename0, $line0, $subroutine0, $hasargs0, $wantarray0,
        $evaltext0, $is_require0, $hints0, $bitmask0) = caller(0);
    my($package1, $filename1, $line1, $subroutine1, $hasargs1, $wantarray1,
        $evaltext1, $is_require1, $hints1, $bitmask1) = caller(1);
    assert($package0 eq $package1,
        "can't call private $subroutine1 from package $package1");
}

{   # error_count and diagnostic_callout are private to these subs
    my %error_count;
    my $diagnostic_callout = undef;

    sub get_error_count($) {
        my($kind) = @_;
        assert($kind eq 'error' || $kind eq 'warning', "bad kind: $kind");
        return $error_count{$kind};
    }

    # If defined, diagnostic_callout sub is call by diagnostic with two args:
    # the kind ('fatal', 'error', 'warning', or '') and the message.
    # This sub sets the diagnostic callout sub if an arg is provided and
    # returns the old one
    sub diagnostic_callout(;&) {
        my($arg) = @_;
        my $result = $diagnostic_callout;
        defined $arg and $diagnostic_callout = $arg;
        return $result;
    }

    sub diagnostic($$@) {
        my($kind, $msg, @rest) = @_;
        assert(defined($msg), "msg undefined");
        $error_count{$kind} += 1;
        if(@rest == 0) {
        } elsif($msg =~ /%/) {  # assume sprintf
            $msg = sprintf($msg, map { fixundef($_) } @rest);
        } else {  # join with spaces, except for args that end with \n
            $msg = join("\001", $msg, @rest);
            $msg =~ s/\n\001/\n/g;
            $msg =~ s/\001/ /g;
        }
#        @rest > 0 and $msg = sprintf($msg, map { fixundef($_) } @rest);
        $msg =~ s/\n*$/\n/;
        $DEBUG || $kind eq 'internal' and $msg .= stack_trace();
        if(defined $diagnostic_callout) {
            &$diagnostic_callout($kind, $msg);
        } else {
            # default handing of diagnostics; use die and warn so that
            # %SIG and try/catch work
            my $prefix = basename($0, '.pl') . ': ';
            if($kind eq 'fatal' || $kind eq 'internal') {
                die "$prefix$kind error: $msg";
            } elsif($kind eq 'error' || $kind eq 'warning') {
                warn "$prefix$kind: $msg";
            } else {
                print $prefix . ($kind && "$kind: ") . $msg;
            }
        }
        return 1;
    }
}

# return a current stack trace; skip frames for certain error handling
# functions, except that last one
sub stack_trace() {
    my $trace = Carp::longmess();
    $trace =~ s/^ *at .*\n//;
    my $cwd = Win32::GetCwd();
    $trace =~ s/ at (.+?) line /' at ' . stripdir($cwd, $1) . ' line '/ge;
    my $last = '';
    while($trace =~ s/^[ \t]*Misc::(diagnostic|internal|assert).*\n//) {
        $last = $&;
    }
    return $last . $trace;
#    return $trace;
}

# emit a trace message indicating where we are
sub trace(@) {
    my(@msg) = @_;
    $TRACE or return;
    _trace(map { fixundef($_) } @msg);
}

# emit a trace message indicating where we are; apply image() to ref args
sub tracei(@) {
    my(@msg) = @_;
    $TRACE or return;
    _trace(map { ref($_) ? image($_) : fixundef($_) } @msg);
}

sub _trace(@) { private;
    my(@msg) = @_;
    my $msg;
    if(@msg == 0) {
        $msg = '';
    } elsif(@msg == 1) {
        $msg = $msg[0];
    } elsif($msg[0] =~ /%/) {
        $msg = sprintf(shift(@msg), @msg);
    } else {
        $msg = join(' ', @msg);
    }
    my($package, $filename, $line) = caller(1);
    $filename = basename($filename);
    my $time = Misc::time();
    print "$time $filename:$line> $msg\n";
}

sub set_trace($) {
    my($value) = @_;
    $TRACE = $value;
}

# Report a "Not Yet Implemented" error
# Fatal by default; warn => don't make it fatal
sub nyi($@) {
    my %opt = subopts(\@_, [1,999999], qw(warn));
    my($msg, @rest) = @_;
    return diagnostic($opt{'warn'} ? 'error' : 'fatal', "NYI: $msg", @rest);
}

# nodie => suppress errors
# warn => don't make it fatal
# TODO: option to show caller or part of callstack?
sub fatal($@) {
    my %opt = subopts(\@_, [1,999999], qw(nodie warn));
    my($msg, @rest) = @_;
    $opt{nodie} and return 1;
    return diagnostic($opt{'warn'} ? 'error' : 'fatal', $msg, @rest);
}

sub error($@) {
    my($msg, @rest) = @_;
    return diagnostic('error', $msg, @rest);
}

sub warning($@) {
    my($msg, @rest) = @_;
    return diagnostic('warning', $msg, @rest);
}

sub note($@) {
    my($msg, @rest) = @_;
    return diagnostic('', $msg, @rest);
}

sub internal($@) {
    my($msg, @rest) = @_;
    return diagnostic('internal', $msg, @rest);
}

sub assert($;$) {
    my($cond, $msg) = @_;
    $cond or internal(defined $msg ? $msg : 'assertion failed');
}

# Force diagnostics to go through this logger.  It must have the log_print_*
# methods.
sub set_logger($) {
    my($logger) = @_;
    diagnostic_callout(sub {
        my($kind, $msg) = @_;
        chomp($msg);
        if($kind ne '') {
            my $caller = get_out_of_package_caller();
            $caller and $msg = "$caller: $msg";
        }
        if($kind eq 'internal') {
            $logger->log_print_error("internal: $msg");
        } elsif($kind eq 'error' || $kind eq 'fatal') {
            $logger->log_print_error($msg);
        } elsif($kind eq 'warning') {
            $logger->log_print_warning($msg);
        } elsif($kind eq '') {
            $logger->log_print_message($msg);
        } else {
            $logger->log_print_message("$kind: $msg");
        }
        $kind eq 'fatal' || $kind eq 'internal' and die "$kind error\n";
    });
}

sub check_file($) {
    my($file) = @_;
    -e $file or error "file not found: $file" and return 0;
    -d $file and error "expected file, got dir: $file" and return 0;
    -f $file or error "not a file: $file" and return 0;
    return 1;
}

sub check_dir($) {
    my($dir) = @_;
    -e $dir or error "dir not found: $dir" and return 0;
    -f $dir and error "expected dir, got file: $dir" and return 0;
    -d $dir or error "not a dir: $dir" and return 0;
    return 1;
}

sub check_dirs(@) {
    my(@dirs) = @_;
    for my $dir (@dirs) {
        check_dir($dir) or return 0;
    }
    return 1;
}

# Usage:
#   try {
#       ...
#   } catch {
#       ...
#       die;  # propagate failure
#   };  # note semi
sub try(&$) {
    my($try, $catch) = @_;
    eval { &$try };
    if($@) {
        local $_ = $@;
        &$catch;
    }
}

sub catch(&) {
    $_[0];
}

# Serialize data structure in $data to $file.  Optional comment at beginning.
sub serialize($$;$) {
    my($file, $data, $comment) = @_;
    ref($file) and fatal 'First arg to serialize must be a path';
    ref($data) or fatal 'Second arg to serialize must be a ref';
    my $dumper = new Data::Dumper([$data]);
    $dumper->Indent(1);
    $dumper->Terse(1);
    $dumper->Sortkeys(1);
    $dumper->Quotekeys(0);
    my $string = $dumper->Dump();
    if (defined $comment) {
        $comment =~ s/^(?=.*\S)/# /gm;
        $string = $comment . "\n" . $string;
    }
    unlink($file);
    my $fh;
    open($fh, '>', $file) or fatal "Cannot write $file: $!";
    print $fh $string;
}

# Read $file and deserialize.
sub deserialize($) {
    my($file) = @_;
    my $fh;
    open($fh, '<', $file) or return undef;
    local $/ = undef;
    local $_ = <$fh>;
    return eval $_;
}

# convert any scalar or refs to printable string
# short => all on one line; width=<n> => on one line if less than <n>
sub image_old(@) {
    my $opt = getopt({ argv => \@_ }, '',
        'short' => 'result all on one line',
        'width=i<n>' => 'result all on one line if less than <n> chars',
    );
    my(@args) = @_;
    $Data::Dumper::Terse = 1;
    my $result;
    if($opt->short || $opt->width) {
        $Data::Dumper::Indent = 0;
        $result = Data::Dumper::Dumper(@args);
    }
    if(!defined($result) || $opt->width && length($result) >= $opt->width) {
        $Data::Dumper::Indent = 1;
        $result = Data::Dumper::Dumper(@args);
    }
    return $result;
}

# convert any scalar or refs to printable string
# short => all on one line; width=<n> => on one line if less than <n>
sub image(@) {
    require Options;  # don't use "use Options" due to circularities
    my $opt = new Options(\@_,
        'short' => 'result all on one line',
        'width=i<n>' => 'result all on one line if less than <n> chars',
    );
    my(@args) = @_;
    $Data::Dumper::Terse = 1;
    $Data::Dumper::Sortkeys = 1;
    my $result;
    my $width = $opt->get(-width);
    if($opt->get(-short) || $width) {
        $Data::Dumper::Indent = 0;
        $result = Data::Dumper::Dumper(@args);
    }
    if(!defined($result) || $width && length($result) >= $width) {
        $Data::Dumper::Indent = 1;
        $result = Data::Dumper::Dumper(@args);
    }
    return $result;
}

# convert array or array ref containing hashes to printable string
sub hash_array_image(@) {
    my $array = @_ == 1 && ref($_[0]) eq 'ARRAY' ? $_[0] : \@_;
    return join("\n", map { hash_image($_) } @$array);
}

# convert hash or hashref to printable string
sub hash_image(@) {
    my $hash = do {
        if(@_ == 1 && ref $_[0]) {
            $_[0];
        } elsif(@_ % 2 == 0) {
            my %hash = @_;
            \%hash;
        } else {
            assert(0, 'arg to dump_hash must be a hash ref or a hash');
        }
    };
    my $max_key = 0;
    map { length > $max_key and $max_key = length } keys %$hash;
    my @lines = 
        map { sprintf("%-${max_key}s => %s", $_, fixundef($hash->{$_})) }
        sort keys %$hash;
    return join("\n", @lines, '');
}

sub fixundef($) {
    my($x) = @_;
    return defined $x ? $x : '<undef>';
}

# encrypt a string and return it (prompts for pw)
sub crypt($;$) {
    my($in, $pw) = @_;
require Crypt::RC4;
    defined $pw or $pw = get_pw();
    return RC4($pw, $in);
}

# Use ReadLine to get noecho
#sub get_pw() {
#    $| = 1;
#    print "Enter password: ";
#    Term::ReadKey::ReadMode('noecho');
#    my $pw = Term::ReadKey::ReadLine();
#    Term::ReadKey::ReadMode('restore');
#    chomp($pw);
#    print "\n";
#    return $pw;
#}
sub get_pw() {
    $| = 1;
    Term::ReadKey::ReadMode('noecho');
    my $pw = prompt('Enter password: ');
    Term::ReadKey::ReadMode('restore');
    print "\n";
    return $pw;
}

sub prompt($) {
    my($prompt) = @_;
    $| = 1;
    print $prompt;
    my $result = Term::ReadKey::ReadLine();
    chomp($result);
    return $result;
}

# checksum a string
sub checksum($) {
    my($x) = @_;
    return Digest::MD5::md5_hex($x);
}

# checksum a string
sub checksum16($) {
    my($x) = @_;
    return substr(Digest::MD5::md5_hex($x), 0, 4);
}

# checksum a string
sub checksum32($) {
    my($x) = @_;
    return substr(Digest::MD5::md5_hex($x), 0, 8);
}

# shorten long lines, preserving indent
sub shorten($$) {
    my($line, $max) = @_;
    1 while $line =~ s#^(.{$max})(.+)#shorten_line($1, $2)#em;
    return $line;
}

# shorten one long line
sub shorten_line($$) {
    my($pre, $post) = @_;
    $pre =~ /^(\s*)/;
    my $indent = $1;
    if($pre =~ /^\s*(\S.*)\s+(\S.*)$/) {
        return "$indent$1\n$indent$2$post";
    } else {
        # no spaces in pre -- just cut it off
        return "$pre\n$indent$post";
    }
}

# format some xml, splitting into lines and indenting
sub format_xml($;$) {
    my %opt = subopts(\@_, [], qw(indent width));
    local($_) = @_;
    s/\s*([-\w:.]+)\s*=\s*(['"])/ $1=$2/g;
    s/<\s+/</g;
    s#\s+(/?>)#$1#g;
    s/>\s*([^<>]*)\s*</>\n$1\n</g;
    s/\n\n/\n/g;
    my $result = '';
    my(@lines) = split(/\n/, $_);
    my $INDENT = !defined $opt{indent} ? 2 : $opt{indent};
    my $WIDTH = !defined $opt{width} ? 80 : $opt{width} || 999999;
    assert($INDENT =~ /^\d+$/, 'non-numeric indent option to format_xml');
    assert($WIDTH =~ /^\d+$/, 'non-numeric width option to format_xml');
    my $in = 0;
    for $_ (@lines) {
        next if /^ *$/;
        s/^\s+//;
        m#^</# and $in -= $INDENT;
        my $indent = ' ' x $in;
        m#^<([^/?!])(|.*([^/?!]))># and $in += $INDENT;
        if(length($_) + $in > $WIDTH) {
            my $indent2 = $indent . (' ' x $INDENT);
            s/(['"]) *([-\w:.]+=)/$1\n$indent2$2/g;
        }
        $result .= "$indent$_\n";
    }
    return $result;
}

# given xml properly indented, sort it
# assume no tabs for indent
sub sort_xml($) {
    my($xml) = @_;
    $xml =~ /^( *)/;
    my $in = $1;
    if(length($in) > 0) {
        my $in2 = ' ' x (length($in)-1);
        if($xml =~ m#^($in2\S)#m) {
            fatal "inconsistent indentation; line:\n${1}xml:\n$xml";
        }
    }
    # pieces: start at indent $in; end at same; </...> included in prev
    my @pieces = ();
#    while($xml =~ m#(^$in.*\n((?:$in .*\n)*)((?:$in</.*\n)?))#mg) {
    while($xml =~ s#^($in.*\n)((?:$in .*\n)*)((?:$in</.*\n)?)##) {
        my($a, $b, $c) = ($1, $2, $3);
        my $b2 = sort_xml($b);
        push(@pieces, $a . $b2 . $c);
    }
#    map { $_ = sort_xml($_) } @pieces;
    return join('', sort(@pieces));

#    my @pieces = $xml =~ m#(^$in.*\n(?:$in .*\n)*(?:$in</.*\n)?)#mg;
#    printf "%d pieces\n", int(@pieces);
#    for my $piece (@pieces) {
#        print $piece, "\n";
#    }
}
#
# <a>
#   <b>
#     <c/>
#   </b>
#   <b2>
#     <c2/>
#   </b2>
# </a>

# Return the first value of attribute $attr in element $elem in some xml.
# undef if not found
sub get_xml_attribute($$$) {
    my($xml, $elem, $attr) = @_;
    return $xml =~ /<\s*$elem\s[^<>]*\b$attr=(['"])(.*?)\1/ ? $2 : undef;
}


use Net::SMTP ();
use constant SMTP_SERVER => 'sus-or1it01.rational.com';

# mail a message to a single recipient
sub mail($$$@) {
    my($addr, $name, $subject, @lines) = @_;
    my $smtp = Net::SMTP->new(SMTP_SERVER)
        or warn "*** can't create Net::SMTP: $!\n" and return;
    $smtp->mail($addr);
    $smtp->to($addr);
    $smtp->data();
    $smtp->datasend("To: $name\n");
    $smtp->datasend("Subject: $subject\n");
    $smtp->datasend("\n");
    for(@lines) {
        chomp;
        $smtp->datasend("$_\n");
    }
    $smtp->dataend();
    $smtp->quit();
}

sub getcwd() {
    #return Win32::GetCwd();
    return File::Spec->curdir();
}

sub is_fullpath($) {
    my($file) = @_;
    #return File::Spec::Functions::file_name_is_absolute($file);
    return File::Spec->file_name_is_absolute($file);
}

sub fullpath($) {
    my($file) = @_;
    #return scalar Win32::GetFullPathName($file);
    if (-e $file) {
        # abs_path doesn't like non-existent files
        return Cwd::abs_path($file);
    } else {
        return catfile(fullpath(dirname($file)), basename($file));
    }
}


use constant RSSETUP_KEY =>
    'HKEY_LOCAL_MACHINE/SOFTWARE/Rational Software/RSSetup';
use constant INSTALLDIR_KEY =>
    'HKEY_LOCAL_MACHINE/SOFTWARE/Rational Software/XDE/InstallDir';
use constant MODELSERVER_PATH => 'XDE/XdePkg/ModelServer.dll';

# return: { root => $root, variant => $variant, id => $id }
sub get_xde_install_info() {
    require Win32::TieRegistry;
    my $reg = $Win32::TieRegistry::Registry;
    $reg->Delimiter('/');
    my $rssetup = $reg->{RSSETUP_KEY()};
#    my $root = $rssetup->{DataDir};
    my $root = $reg->{INSTALLDIR_KEY()};
    defined $root and $root = dirname($root);  # remove 'XDE'
    my $products = $rssetup->{Products};
    for my $subkey (keys %$products) {
        next unless $subkey =~ /^(pdg|rbu)/i;
        my $build = $products->{$subkey}->{Build};
        $subkey =~ s#/$##;
        my $displayname = $products->{$subkey}->{DisplayName};
        return _get_xde_install_info($root, $build, $displayname);
    }
    fatal 'no pdg or rbu products found: '
        . Misc::subst(join(' ', keys %$products), '/' => '');
}

# get install info from an unzipped xde install
sub get_xde_install_info_unzipped($) {
    my($dir) = @_;
    -d $dir or fatal "directory not found: $dir";
    my $bom = catfile($dir, 'setup', 'bom.xml');
    local $_ = get($bom);
    /<bom build=['"](.*?)['"]/ or fatal "no '<bom build=...> found in $bom";
    my $build = $1;
    my @names = /<product .*?<displayname .*?>(.*?)</gs
        or fatal "failed to find product display name in $bom";
    my $displayname = join('/', @names);
    return _get_xde_install_info($dir, $build, $displayname);
}

sub _get_xde_install_info($$$) {
    my($root, $build, $displayname) = @_;
    my $variant = do {  # determine variant: debug / release / ?
        local $_ = Misc::run({nodie => 1},
            'dumpbin', '/dependents',
            canonpath(catfile($root, MODELSERVER_PATH)));
        !/\n\s*msvcrt(d?)\.dll\n/i
            ? undef : lc $1 eq 'd' ? 'debug' : 'release';
    };
    $build =~ /^xde_(\d+\.\d+\w*)\.(\d{4}\.\d{4})$/i
        or warning "failed to parse build build string: $build";
    return {
        version => $1,
        build   => $2,
        root    => $root ? fullpath($root) : 'undef',
        name    => $displayname,
        variant => $variant || 'undef',
    };
    return undef;
}

# returns data & type in list context
sub get_registry($) {
    my($key) = @_;
    require Win32::TieRegistry;
    return $Win32::TieRegistry::Registry->{dirname($key)}
        ->GetValue(basename($key));
}

sub set_registry($$;$) {
    my($key, $data, $type) = @_;
    require Win32::TieRegistry;
    my $k = $Win32::TieRegistry::Registry->{dirname($key)};
    $k->SetValue(basename($key), $data, $type);
#    $Win32::TieRegistry::Registry->{$key} = $data;
}

# Turn a service on or off.  If state is defined it is a boolean to indicate
# whether the service should be on or off.  If not defined, toggle state
sub toggle_service($;$) {
    my($service, $state) = @_;
    my $action = defined($state) && !$state ? 'stop' : 'start';
    local $_ = run({nodie => 1}, 'net', $action, $service);
    s/\n\n+/\n/g;
    if(/The requested service has already been started/) {
        defined($state) or return toggle_service($service, 0);
        note qq{service "$service" is already running};
    } elsif(/service was (started|stopped) successfully/) {
        note qq{service "$service" was $1};
    } elsif(/service is not started/) {
        note qq{service "$service" is already stopped};
    } else {
        error qq{error from "net start $service": $_};
    }
}

# Generate a GUID
sub guidgen {
    # NOTE: Win32::API is not part of the standard Perl distribution, so we
    # don't "use" it.  guidgen is only implemented if it's available.
    eval 'require Win32::API';
    assert(!$@, "guidgen is not supported:\n$@");

	# defintion of GUID structure
	# typedef struct _GUID {
	#	DWORD	data1;
	#	WORD	data2;
	#	WORD	data3;
	#	BYTE	data4[8];
	# } GUID;
	my $P_GUID = pack("LIIC8", 0,0,0,0);
	my $CoCreateGuid = new Win32::API('ole32.dll', 'CoCreateGuid', ['P'], 'N');
    defined $CoCreateGuid
        or die "Could not create CoCreateGuid API call variable: $!\n";
	my $rc1 = $CoCreateGuid->Call($P_GUID);
    $rc1 == 0 or die "CoCreateGuid failed with status $rc1\n";
    my $P_GUIDSTR = pack("S39", 0);
    my $StringFromGuid = new Win32::API(
        'ole32.dll', 'StringFromGUID2', ['P', 'P', 'N'], 'N');
    defined $StringFromGuid
        or die "Could not create StringFromGUID2 API call variable: $!\n";
    my $rc2 = $StringFromGuid->Call($P_GUID, $P_GUIDSTR, 39);
    my @chars = unpack("S$rc2", $P_GUIDSTR);
    return join('', map { $_ != 0 && chr($_) } @chars);
}

{
    my $inet;
    sub get_inet() {
        if(!defined $inet) {
            require Win32::Internet;
            $inet = new Win32::Internet();
        }
        return $inet;
    }
}

# Read a url and return the string.
sub get_from_url($) {
    my($url) = @_;
    if ($url =~ m{^file:/+(.*)}) {
        return Misc::get({nodie => 1}, $1);
    } else {
        return get_inet()->FetchURL($url);
    }
}

#NOTE: not all servers return this format!
# return map path => { size | "<dir>" }
sub get_dir_from_url($) {
    my($url) = @_;
    my $root = $url =~ m#(http://.*?)/# ? $1 : $url;
    my $dir = get_from_url($url)
        or error "failed to fetch dir from url: $url";
    my %result = ();
    while($dir =~ /\s(\S+)\s+<a href="(.+?)"/gi) {
        $result{"$root/$2"} = $1;
    }
    return %result;
}

# Return list of files found in remote dir.
sub get_dir_from_url2($) {
    my($url) = @_;
    my $root = $url =~ m#(http://.*?)/# ? $1 : $url;
    my $dir = get_from_url($url)
        or error "failed to fetch dir from url: $url"
            and return ();
    $dir =~ s{<address>.*?</address>}{}g;
    $dir =~ s#"#'#g;  # normalize quotes
    $dir =~ s{<a href='/.*?</a>}{}gs;  # remove absolute URLs
    my @result = $dir =~ m#<a href='(?:[^?']*/)?([^/?']+)/?'>#gi;
    return @result;
}

# Read a url; if dst is specified, write to it and return size (or -1 on error);
# otherwise return contents (or undef on error)
sub get_file_from_url($;$) {
    my($url, $dst) = @_;
    if(!defined($dst)) {
        my $result = get_from_url($url);
        defined $result or error "failed to read from url: $url";
        return $result;
    }
    if ($url =~ m{^file:/+(.*)}) {
        copy($1, $dst);
        return -s $dst;
    }
    my $u;
    get_inet()->OpenURL($u, $url)
        or error "failed to OpenURL $url" and return -1;
    my $BUF_SIZE = 16 * 1024;
    my $tsize = 0;
    my $out = do_open({binary => 1}, '>', $dst);
    while((my $avail = $u->QueryDataAvailable()) > 0) {
        my $size = min($avail, $BUF_SIZE);
        $tsize += $size;
        my $buffer = $u->ReadFile($size);
        defined $buffer or error "problem reading from $url" and return -1;
        print $out $buffer;
    }
    $u->Close();
    return $tsize;
}

# Return the root directory of the eclipse project this dir is in.
sub get_eclipse_project($) {
    my($dir) = @_;
    for(my $d = fullpath($dir); ; $d = dirname($d)) {
        defined $d or return undef;
        -f catfile($d, '.project') and return $d;
    }
}

sub find_java_exe($) {
    my($exe) = @_;
    $exe =~ /\.exe$/i or $exe .= '.exe';
    my $age = 999999;
    my $file = undef;
    my $glob = catfile(JAVA, '*', 'bin', $exe);
    for my $x (my_glob($glob)) {
        -M $x < $age and $file = $x and $age = -M $x;
    }
    defined $file or fatal "no match found for $glob";
    return $file;
}

sub find_vim_exe() {
    if (!is_win32()) {
        return 'gvim';
    }
    # NOTE: change version in vi.pl too
    #my $VERSION = '73';
    my $root = $ENV{ROOT} || dirname(dirname(__FILE__));
    my $BIN = catdir($root, 'bin');
    #my $VIM = catdir($root, 'vim', "vim$VERSION");
    $ENV{VIMINIT} = "so " . catfile($BIN, 'vimrc.vim');
    #$ENV{VIMRUNTIME} = $VIM;
    return $VIM;
    #my $try1 = catfile($VIM, 'gvim.exe');
    #my $try2 = catfile($BIN, 'gvim.exe');
    #-e $try1 and return $try1;
    #-e $try2 and return $try2;
    #fatal "gvim.exe not found, tried: $try1 $try2"
}

# Run vim: if one param it is list of args.
# If two, the first is the -c options, the second is the args.
# Args may be ref to list or a single scalar.
# NOTE: returns immediate; doesn't wait for vim to exit
sub run_vim2($;$) {
    my $args = &_run_vim_args;
    my $vi = find_vim_exe();
    if (!is_win32()) {
        $vi = unix_slash($vi);
        #TODO: not getting right cwd in vim -- this stuff doesn't work
        #my $cwd = Cwd::getcwd();
        #$cwd =~ s{/([a-z])/}{$1:/};
        #chdir($cwd);
        #system("$vi -c \"cd $cwd\" $args &");
        #print "$vi $args &\n";
        system("$vi $args");
        return;
    }

    #my $vi;
    #if(is_win32()) {
    #    $vi = find_vim_exe();
    #} else {
    #    $vi = "$ENV{HOME}/bin/vi";
    #}
    run_async($vi, "$vi $args");
}

# Run vim: if one param it is list of args.
# If two, the first is the -c options, the second is the args.
# Args may be ref to list or a single scalar.
# NOTE: returns immediate; doesn't wait for vim to exit
sub run_vim($;$) {
    return &run_vim2;
    my $args = &_run_vim_args;
    my $vi = is_win32() ? 'vi.bat' : "$ENV{HOME}/bin/vi";
#    print "$vi $args\n";
    system qq{$vi $args};
}

# Like run_vim but wait for vim to exit.
sub run_vim_wait($;$) {
    my $args = &_run_vim_args;
    my $vi = is_win32() ? 'vi.bat -wait' : 'vim';
    #print "$vi $args\n";
    system qq{$vi $args};
}

sub _run_vim_args($;$) {
    @_ == 1 and unshift(@_, []);
    my($vimcmds, $args) = @_;
    my @args = !defined($args) ? () : ref($args) ? @$args : ($args);
    my @vimcmds = map { qq{ -c "$_"} } ref($vimcmds) ? @$vimcmds : ($vimcmds);
    @args = quoteargs(@args);
    return qq{@vimcmds @args};
}

sub format_size($) {
    my($size) = @_;
    if($size < 10000) {
        return sprintf('%4.0f ', $size);
    } else {
        $size /= 1024;
        if($size < 100) {
            return sprintf('%4.1fk', $size);
        } elsif($size < 1024) {
            return sprintf('%4.0fk', $size);
        } else {
            $size /= 1024;
            if($size < 100) {
                return sprintf('%4.1fM', $size);
            } else {
                return sprintf('%4.0fM', $size);
            }
        }
    }
}

my $is_win32;
sub is_win32() {
    if(!defined $is_win32) {
        eval { require Win32 };
        $is_win32 = !$@;
    }
    return $is_win32;
}

sub is_linux() {
    return !is_win32();
}

sub get_latest_imcl() {
    my @glob = glob($IMCL_GLOB);
    @glob == 0 and fatal "No files matched $IMCL_GLOB";
    return $glob[-1];
}

# Create (or update) a .keyring file in $dir for $repo
sub create_keyring($$) {
    my($dir, $repo) = @_;
    my $imutilsc = Misc::subst(get_latest_imcl(), 'imcl.exe' => 'imutilsc.exe');
    run({ indir => $dir, verbose => 1 }, $imutilsc, 'saveCredential',
        '-url' => $repo, '-userName' => 'tsk@us.ibm.com', '-userPassword' => get_password());
}

sub tlist(@) {
    my(@args) = @_;
    return Misc::run($TLIST, @args);
}

# Fetch a URL to a temp file and return it.
#sub wget_to_file($) {
#    my($url) = @_;
#    #print "Fetching $url\n";
#    my $base = basename($url);
#    my $temp = catfile($ENV{TEMP}, $base);
#    unlink($temp);
#    -e $temp and fatal "Failed to delete $temp";
#    my $WGET = 'C:\Install\wget.exe';
#    run({nodie => 1, indir => $ENV{TEMP}},
#        $WGET, '-q', '--no-check-certificate',
#        '--user=tsk@us.ibm.com', '--password=xxx',
#        $url);
#    if ($?) {
#        fatal "wget failed on url: $url";
#    }
#    return $temp;
#}

# Run wget in TEMP on $url
sub _wget($) {
    my($url) = @_;
    my $WGET = 'wget.exe';
    my $out = run({stdout => 0, verbose => 0, nodie => 1, indir => $ENV{TEMP}},
        $WGET, '-q', '--no-check-certificate',
        '--user=tsk@us.ibm.com', '--password=' . get_password(),
        $url);
    if ($?) {
        fatal "wget failed on url: $url\n$out";
    }
}

sub wget_unchecked($$) {
    my($url, $file) = @_;
    my $base = basename($url);
    my $temp = catfile($ENV{TEMP}, $base);
    unlink($temp);
    -e $temp and fatal "Failed to delete $temp";
    my $WGET = 'wget.exe';
    my $out = run({stdout => 0, verbose => 0, nodie => 1, indir => $ENV{TEMP}},
        $WGET, '--no-check-certificate',
        '--user=tsk@us.ibm.com', '--password=' . get_password(),
        $url);
    unlink($file);
    move($temp, $file);
    return $out;
}

# Try to get dir listing -- depends on the server whether it works.
sub wget_dir($) {
    my($url) = @_;
    _wget($url);
    my $temp = "$ENV{TEMP}/index.html";
    my $x = get($temp);
    # Expected format:
    #   <a href="(file)">.* (date)
    my @result = $x =~ m{<a href="([^"/]+/?)">.*\s\d+-\w+-\d+}g;
    unlink($temp);
    return @result;
}

# Fetch a URL to a file and return the file.
# If file is not specified, create temp.
sub wget_to_file($;$) {
    my($url, $file) = @_;
    #print "Fetching $url\n";
    my $base = basename($url);
    my $temp = catfile($ENV{TEMP}, $base);
    unlink($temp);
    -e $temp and fatal "Failed to delete $temp";
    _wget($url);
    #my $WGET = 'wget.exe';
    #run({verbose => 0, nodie => 1, indir => $ENV{TEMP}},
    #    $WGET, '-q', '--no-check-certificate',
    #    '--user=tsk@us.ibm.com', '--password=' . get_password(),
    #    $url);
    #if ($?) {
    #    fatal "wget failed on url: $url";
    #}
    if (defined $file) {
        unlink($file);
        move($temp, $file);
        return $file;
    } else {
        return $temp;
    }
}

# Fetch and return a URL.
sub wget($) {
    my($url) = @_;
    my $file = wget_to_file($url);
    my $result = get($file);
    unlink($file);
    return $result;
}

# PW password
sub get_password() {
    return 'qq777`qq';
}

1;
