# option processing
package Options;

use strict;
use warnings;
use File::Spec::Functions qw(catfile catdir);
use File::Basename qw(basename dirname);
use Getopt::Long ();
use lib dirname __FILE__;
use Misc qw(private assert note warning error fatal internal);

use Exporter;
use vars qw(@ISA @EXPORT @EXPORT_OK);
@ISA = qw(Exporter);
@EXPORT = ();
@EXPORT_OK = ();

sub new($@);
sub show($);
sub get($$);
sub set($$;$);
sub valid($$);
sub image($;@);
sub do_getopt($$$;$);  # private
sub check($);  # private
sub get_and_check($$);  # private
sub make_help($$$);  # private
sub option_error($$);  # private
sub dummy_internal($);

# Usage:
# For a script:
#   my $opt = new Options([options], <cmd-descr>, <opt-name> => <opt-descr>);
# For a sub:
#   my $opt = new Options([options], \@_, <opt-name> => <opt-descr>);
# <opt-name> is like those passed to Getopt::Long
# <opt-descr> is a human-readable description of the option
# [options] are options the control the behaviour of class Options, as opposed
# to the sub or script that creates it:
#   args=s    - required number of non-option arguments of form:
#               \d+|\d+-|-\d+|\d+-\d+
#   noslash   - don't allow options to start with /
#   order     - force options to be before args (default in second case)
#   required  - list of options, at least one of which must be present
#   exclusive - list of options, at most one of which must be present
#   one       - list of options, exactly one of which must be present
#       Each of "required", "exclusive", and "one" may be a comma-separated list
#       of option names, or a ref to an array of same.
# When called from a sub (i.e. the second example above), -noslash and -order
# are implied, there is no generated -help option, and an error results in an
# internal error rather than a usage message.
sub new($@) {
    my($class, @args) = @_;
    my $this = { help => '' };
    bless $this, ref($class) || $class;
    # parse my options
    my $opt = $this->do_getopt(
        1, # order
        [ qw(script args=s argv=s noslash order required=s exclusive=s one=s) ],
        \@args,
    );
    for my $key (keys %$opt) {
        $this->{$key} = $opt->{$key};
    }
    if(!defined $this->{script} && !defined Misc::get_out_of_package_caller()) {
        $this->{script} = 1;
    }
    assert(@args % 2 == 1, "wrong number of args to Option::new");
    my($desc, @desc) = @args;
    my %desc = @desc;
    my $n = 0;
    my @keys = grep($n++ % 2 == 0, @desc);  # get keys in order, not keys(%desc)
    if(ref($desc) eq 'ARRAY') {
        $this->{argv} = $desc;
        $desc = undef;
        $this->{order} = 1;
    } else {
        $this->{script} = 1;
    }
    if($this->{script}) {
        $this->{help} = make_help($desc, \@keys, \%desc);
        push(@keys, 'help|?');
    }
    $this->{has_value} = {};  # set of options that require a value
    map {  # fix up for do_getopt; fill in has_value
        s/([=:])f/$1s/;
        s/([=:].+?)<.+?>/$1/;
        /(.+?)[=:]/ and $this->{has_value}->{$1} = 1;
    } @keys;
    $this->{options} = $this->do_getopt($this->{order}, \@keys, $this->{argv});
    $this->{argv} = \@ARGV if !defined($this->{argv});
    if($this->{options}->{help}) {
        print $this->{help};
        exit(0);
    }
    $this->check();
    return $this;
}

sub show($) {
    my($this) = @_;
    print "contents of $this\n";
    for my $key (sort keys %$this) {
        my $value = $this->{$key};
        next if !defined($value);
        if(ref($value)) {
            $value = Misc::image($this->{$key});
            $value =~ s/\s*\n\s*/ /g;
        } elsif($value =~ /\n/) {
            $value =~ s/^/    /gm;
            $value = "\n" . $value;
        }
        print "  $key = $value\n";
    }
}

sub get($$) {
    my($this, $name) = @_;
    $name =~ s/^-+//;
    if(!$this->valid($name)) {
        dummy_internal "undefined option: $name";
    }
    return $this->{options}->{$name};
}

sub set($$;$) {
    my($this, $name, $value) = @_;
    $name =~ s/^-+//;
    if(!$this->valid($name)) {
        dummy_internal "undefined option: $name";
    }
    my $result = $this->{options}->{$name};
    $this->{options}->{$name} = defined $value ? $value : 1;
    return $result;
}

# Is $name a valid option name?
sub valid($$) {
    my($this, $name) = @_;
    return exists($this->{options}->{$name});
}

sub image($;@) {
    my($this, @opts) = @_;
    my $image;
    if(@opts) {
        $image = [];
        for my $opt (@opts) {
            $opt =~ s/^-//;
            if(defined(my $value = $this->get($opt))) {
                #??? figure out if value is required!
                $value = $this->{has_value}->{$opt} ? "=$value" : '';
                push(@$image, "-$opt$value");
            }
        }
    } else {
        $image = $this->{image};
    }
    if(wantarray) {
        return @$image;
    } else {
        return join(' ', @$image);
    }
}

sub do_getopt($$$;$) { private;
    my($this, $order, $keys, $argv) = @_;
    if(defined($argv)) {
        # Getopt::Long always operates on @ARGV;
        my @save_ARGV = @ARGV;
        @ARGV = @$argv;
        my $result = $this->do_getopt($order, $keys);
        @$argv = @ARGV;
        @ARGV = @save_ARGV;
        return $result;
    }
#if(!$order) {
#    print "in do_getopt: ", Misc::stack_trace();
#}
#print "do_getopt(order=", $order||0, "\n";
#print "  keys=@$keys\n" if @$keys;
#print "  args=@ARGV\n";

    # allow /foo for -foo
    grep(s#^/#-#, @ARGV) if $this->{script} && !$this->{noslash};
    local $SIG{__DIE__} = sub { dummy_internal $_[0] . $this->{help} };
    local $SIG{__WARN__} = sub {
        $SIG{__DIE__} = 'DEFAULT';
        $this->option_error($_[0] . $this->{help});
    };
    Getopt::Long::Configure(
        'no_auto_abbrev', $order ? 'require_order' : 'permute');
#        $this->{order} || !$this->{script} ? 'require_order' : 'permute');
    my @temp_ARGV = @ARGV;
    my $result = { map { /^([^=]*)/; $1 => undef } @$keys };
    Getopt::Long::GetOptions($result, @$keys) or exit 1;
    $this->{image} = [ Misc::set_diff(\@temp_ARGV, \@ARGV) ];
    if($this->{script} && !$this->{noslash}) {
        grep(s#^-#/#, @ARGV);  # change -foo back to /foo
    }
    return $result;
}

# check requirements based on options to getopt
sub check($) { private;
    my($this) = @_;
    my $required = $this->get_and_check('required');
    my $exclusive = $this->get_and_check('exclusive');
    my $one = $this->get_and_check('one');
    push(@$required, @$one);
    push(@$exclusive, @$one);
    for my $req (@$required) {
        if(grep(defined($this->{options}->{$_}), @$req) == 0) {
            $this->option_error(@$req == 1
                ? "-@$req must be specified"
                : 'one of these options must be specified:'
                    . join(' -', '', @$req));
        }
    }
    for my $excl (@$exclusive) {
        if(grep(defined($this->{options}->{$_}), @$excl) > 1) {
            $this->option_error('only of these options may be specified:'
                . join(' -', '', @$excl));
        }
    }
    # check arg count
    if(defined(local $_ = $this->{args})) {
        my @argv = @{$this->{argv}};
        my($min, $max) = /^(\d+)$/ ? ($1, $1)
            : /^(\d+)-$/ ? ($1, 999999)
            : /^-(\d+)$/ ? (0, $1)
            : /^(\d+)-(\d+)$/ ? ($1, $2)
            : dummy_internal "bad args option to getopt_new: $_";
        if(my $msg = @argv < $min ? "At least $min arguments are required"
                : @argv > $max ? "No more than $max arguments are allowed"
                : '') {
            $min == $max and $msg = "Exactly $min arguments are required";
            $msg =~ s/ 1 arguments are / 1 argument is /;  # grammar!
            $msg =~ s/ more than 0 / /;
            $msg .= '; found: ';
            $msg .= @argv == 0 ? 'none' : join(', ', @argv);
            $msg .= "\n" . $this->{help};
            chomp($msg);
            $this->option_error($msg);
            return undef;
        }
    }
}


# get the value of an option that expects a comma-separated list or a ref
# to array of same.
# Return ref to array of refs to array or option names.
sub get_and_check($$) { private;
    my($this, $name) = @_;
    my $value = $this->{$name} or return [];
    if(!ref($value)) {
        $value = [ $value ];
    } elsif(ref($value) ne 'ARRAY') {
        dummy_internal "expected array ref or scalar for -$name, found: $value";
    }
    my $result = [];
    for my $v (@$value) {
        if(!ref($v)) {
            $v = [ split(/,/, $v) ];
        } elsif(ref($v) ne 'ARRAY') {
            dummy_internal "expected array ref or scalar for -$name, found: $v";
        }
        # check all names are legal
        for my $x (@$v) {
            if(!$this->valid($x)) {
                dummy_internal "unknown option name in -$name: $x";
            }
        }
        push(@$result, $v);
    }
    return $result;
}

sub make_help($$$) { private;
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
        $desc and $result .= ' ' . Misc::subst($desc, '\s*\n\s*' => "\n");
        $result .= "\n";
    }
    for(@k) {
        my $sp = ' ' x ($max + 9);
        my $v = Misc::subst(shift(@v), "\n *" => "\n$sp");
        $result .= sprintf("    -%-${max}s => %s\n", $_, $v);
    }
    return $result;
}

# issue fatal or internal errors for options errors depending on whether
# it is a script or not
sub option_error($$) { private;
    my($this, $msg) = @_;
    return $this->{script} ? fatal $msg : dummy_internal $msg;
}

sub dummy_internal($) {
    my($msg) = @_;
}

1;
