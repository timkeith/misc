#!/usr/bin/env perl

use strict;
use warnings;
use File::Spec::Functions qw(canonpath);
use File::Basename qw(basename);
use File::Find ();
use FindBin ();
use lib "$FindBin::Bin";
use Misc qw(warning fatal);
sub grepdir($);
sub trygrep($);
sub grepfile($);

# source file extension
my %IS_SRC = map { $_ => 1 } qw(c h cc cpp jav java groovy idl pl pm vim xml rc);
# directories of eclipse project that might contain source
my @SRC_DIRS = qw(src srcant commonSrc os-src);

# ignore these files in dirs:
my $IGNORE = '(^|\\\\)(ID|tags|tagspath\.vim)$|\.(contrib|keep)(\.\d+)?$';

my $OPT = Misc::getopt(
    # noslash in case pattern starts with /
    {
        args => '0-',
        noslash => 1,
        exclusive => ['fpat,ext,java,properties,src'],
    },
    '[pattern] file...
Search for pattern in specified files',
    'pat=s<pat>'   => 'specify pattern (e.g. if it start with "-")',
    'fixed'        => 'pat is fixed string, not regex',
    'string'       => 'only find the pattern inside a string ("...")',
    'i|ignorecase' => 'ignore case',
    'case'         => 'match case even if all lower case',
    'w|word'       => 'search for pattern as word',
    'r|recurse'    => 'grep recursively',
    'v'            => 'verbose',
    'vi'           => 'view results in vim',
    'line|n'       => 'show line numbers',
    'col'          => 'show line & column numbers (called from vim)',
    'list|l'       => 'only list files with match',
    'count'        => 'show count of matches for each file',
    'files=s<file>' => 'get list of files to search from <file>',
    'src'          => 'source files only',
    'fpat=s<re>'   => 'include from dirs only files that match this perl re',
    'ext=s<ext>'   => 'search only in files with extension <ext> (implies -r)',
    'java'         => 'search only java and properties files (implies -r)',
    'groovy'       => 'search only groovy, java, and properties files (implies -r)',
    'properties'   => 'search only properties files (implies -r)',
    'wholefile'    => 'treat files as single strings instead of line-by-line',
#NYI    'bin|binary'   => 'search binary files too',
);
if(defined(my $ext = $OPT->ext)) {
    $ext =~ s/^\.//;
    $OPT->fpat('\.' . quotemeta($ext) . '$');
    $OPT->r(1);
}
$OPT->java and $OPT->fpat('\.(properties|java)$') and $OPT->r(1);
$OPT->groovy and $OPT->fpat('\.(properties|java|groovy)$') and $OPT->r(1);
$OPT->properties and $OPT->fpat('\.(properties)$') and $OPT->r(1);
my $pat = do {
    if($OPT->pat) {
        $OPT->pat;
    } else {
        @ARGV > 0 or fatal "must specify a pattern";
        my $p = shift(@ARGV);
        $p eq '-' and $p = Misc::get_clipboard();
        $p;
    }
};

my $vi_tmp = undef;
my $vi_fh = undef;
if($OPT->vi) {
    $OPT->line(1);
    $vi_tmp = Misc::gettemp();
    $vi_fh = select(Misc::do_open('>', $vi_tmp));
}

if($OPT->fixed) {
    #$pat = '\Q' . $pat . '\E';
    $pat = quotemeta($pat);
}
if($OPT->w) {
    # add word boundaries if start/end with word char
    $pat =~ s/^(?=\w)/\\b/;   # zero-width positive look-ahead
    $pat =~ s/(?<=\w)$/\\b/;  # zero-width positive look-behind assertion
}
if($OPT->string) {
    # pat must be followed by an odd number of quotes
    # NOTE: this can be confused by comments with quotes in them
    $pat .= '[^"\n]*"[^"\n]*(?:"[^"\n]*"[^"\n]*)*(?:\n|$)';
}
$pat = '(?i)' . $pat if $OPT->i || (!$OPT->case && $pat !~ /[A-Z]/);
#print STDOUT "pat=$pat\n";
if(my $files = $OPT->files) {
    my $file_list = Misc::get($files);
    exit 1 unless defined $file_list;
    my @files = split(/\s+/, $file_list);
    push(@ARGV, @files);
}
if(@ARGV == 0) {
    @ARGV = qw(.);
    $OPT->r(1);
}
my @args = Misc::glob_args(@ARGV);

$OPT->col and $OPT->line(1);

my $TOTAL_COUNT = 0;
my $MANY = $OPT->line || @args > 1 || -d $args[0];
for my $arg (@args) {
    if(-d $arg) {
        grepdir($arg);
    } else {
        grepfile($arg);
    }
}

if ($OPT->count) {
    print "TOTAL : $TOTAL_COUNT\n";
}

if($OPT->vi) {
    select($vi_fh);
    #TODO fix special chars in $pat
    $pat =~ s/^\(\?i\)//;
    $pat =~ s/\\b(?=\(*\w)/\\</g;
    $pat =~ s/(?<=\w)\\b/\\>/g;
    $pat =~ s/(?<=\))\\b/\\>/g;
    $pat =~ s/(?<!\\)([()|])/\\$1/g;
    $pat =~ s/'/''/g;  # double single quotes
    1 while $pat =~ s/(\[[^\]]*)"/$1\\x22/;  # " inside [...]
    1 while $pat =~ s/(\[[^\]]*)\\n/$1\\x0a/;  # \n inside [...]
    $pat =~ s/"/[\\x22]/g;  # " outside [...]
    $pat =~ s/\\n/[\\x0a]/g;  # \n outside [...]
    my @options = (
        "cfile $vi_tmp",
        "call ErrorMaps()",
        "call DeleteOnExit('$vi_tmp')",
        "let @/ = '$pat'",
        "set nohls",
        "set hls",  # this forces highlighting
    );
    $OPT->list and unshift(@options, 'set errorformat+=%f');
    Misc::run_vim(\@options, []);
}
exit;

sub grepdir($) {
    my($dir) = @_;
    if($OPT->r) {
        my @dirs = ($dir);
        if(($OPT->java || $OPT->properties)
        && -f "$dir/.project" && -d "$dir/src") {
            # dir is project: only search src subdir(s)
            @dirs = grep { -d $_ } map { "$dir/$_" } @SRC_DIRS
        }
        for my $d (@dirs) {
            File::Find::find({
                wanted   => sub {trygrep(canonpath($File::Find::name))},
                no_chdir => 1,
            }, $d);
        }
    } else {
        for my $file (Misc::get_dir($dir)) {
            my $full = $dir eq '.' ? $file : "$dir/$file";
            trygrep($full);
        }
    }
}

# Grep this file if appropriate.
sub trygrep($) {
    my($file) = @_;
    if(($OPT->groovy || $OPT->java || $OPT->properties || $OPT->src)
    && $file =~ m{[/\\](bin|CVS|\.git)$} && -d $file) {
        # do not go into bin, CVS, .git when -groovy or -java or -src
        $File::Find::prune = 1;
        return;
    }
    return unless -T $file;
    return if $file =~ /$IGNORE/oi;
    if($OPT->src) {
        $file =~ /\.([^\\]+)$/ or return;  # no ext
        $IS_SRC{$1} or return;  # not a src extension
        print "src: $file\n" if $OPT->v;
    } elsif(defined(my $fpat = $OPT->fpat)) {
        $file =~ /$fpat/ or return;
        print "fpat: $file\n" if $OPT->v;
    } else {
        print "file: $file\n" if $OPT->v;
    }
    grepfile($file);
}

sub grepfile($) {
    my $file = shift;
    if ($OPT->wholefile) {
        local $_ = Misc::get($file);
        while(/(.*?$pat.*)/go) {
            my $match = $1;
            if($MANY || $OPT->vi) {
                print $file;
                print " : ";
            }
            print $match, "\n";
        }
        return;
    }

    my $line = 0;
    my $count = 0;
    my $in = Misc::do_open({warn => 1}, '<', $file) or return;
    while(<$in>) {
        $line += 1;
        chomp;  # so \s doesn't match the \n
        if($OPT->properties) {
            while(s/\s*\\\s*$//) { # join continued lines
                my $next = <$in>;
                $line += 1;
                chomp($next);
                $next =~ s/^\s*/ /;
                $_ .= $next;
            }
        }
        while(/$pat/go) {
            if($OPT->list) {
                print $file, "\n";
                return;
            }
            if($OPT->count) {
                $count += 1;
                last;
            }
            if($MANY || $OPT->vi) {
                print $file;
                if($OPT->col) {
                    my $col = 1 + length($`);
                    print "($line,$col)";
                } elsif($OPT->line) {
                    print "($line)";
                }
                print " : ";
            }
            print $_, "\n";
            last unless $OPT->col;  # may have multiple matches per line
        }
    }
    $count > 0 and print "$file : $count\n";
    $TOTAL_COUNT += $count;
}
