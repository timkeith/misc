#!/usr/bin/env perl
use strict;
use warnings;
use File::stat ();
use File::Copy ();
use File::Spec::Functions qw(canonpath catfile catdir);
use File::Basename qw(basename dirname);
use lib dirname __FILE__;
use Misc qw(private assert note warning error fatal internal trace tracei);
sub diff($);
sub restore($);
sub get_orig($);
sub list_dir($);
sub backup($);
sub get_backup_file($);
sub get_backup_dir($);
sub list_all();

use constant BACKUP_DIR => catdir($ENV{HOME}, 'Save');

$| = 1;
my $opt = Misc::getopt(
    { args => '0-', },
    '<file>...
Make backup copy of each file under ' . BACKUP_DIR,
    'vi|vim'    => 'view listing of backups single named file',
    'restore|r' => 'restore backup file to original',
    'diff'      => 'show diff between backup file and original',
    'n|effort'  => 'effort only',
    'ls|l'      => 'list existing backups for each named file',
);

if($opt->vi) {
    @ARGV == 1 or fatal "one arguments required with -vi";
    my($dir) = @ARGV;
    my $root = dirname(get_backup_file($dir));
    chdir($root);
    unlink('list.txt');  # so it doesn't appear in ls output
    #local $_ = Misc::run('ls.pl', '-r', '-l');
    local $_ = Misc::run('ls', '-R', '-l');
    s#^\S.*:\n(.*/\n)*\n##gm;
    if(!/\S/) {
        $_ = "no backups found for $dir";
    } else {
        $_ = "# $dir\n\n" . $_;
    }
    Misc::put('list.txt', $_);
    Misc::run_vim2('call RestoreInit()', 'list.txt');
    #system 'vi -c "call RestoreInit()" list.txt';
    exit(0);
}
if($opt->ls && @ARGV == 0) {
    list_all();
    exit(0);
}

#if($opt->restore) {
#    for my $backup (@ARGV) {
#        Misc::check_file($backup) or next;
#        my $list = catfile(dirname($backup), 'list.txt');
#        -f $list or error('List file not found: %s', $list) and next;
#        my $orig = Misc::get($list) =~ /.*^# (.*?)$/ms ? $1 : undef;
#        defined $orig or error('Failed to find original in: %s', $list) and next;
#        print "copy $backup\n  to $orig\n";
#    }
#    exit;
#    #fatal "-restore must be followed by one arg" if @ARGV != 1;
#    #local $_ = shift;
#    #fatal "bad -restore path: $_"
#    #    unless /^([A-Za-z])(\\.+)\~\d+((\.[^\\]*)?)$/;
#    #print "$1:$2$3";
#}

for my $file (@ARGV) {
    if(-d $file) {
        $opt->ls or error "directory ignored: $file" and next;
        list_dir($file);
    } elsif ($opt->restore) {
        restore($file);
    } elsif ($opt->diff) {
        diff($file);
    } else {
        backup($file);
    }
}

exit;

sub diff($) {
    my($backup) = @_;
    my $orig = get_orig($backup) or return;
    Misc::run('page.pl', 'diff', '-w', $backup, $orig);
}

sub restore($) {
    my($backup) = @_;
    my $orig = get_orig($backup) or return;
    backup($orig);
    print "restore to $orig\n";
    Misc::copy($backup, $orig) unless $opt->n;
}

sub get_orig($) {
    my($backup) = @_;
    Misc::check_file($backup) or return undef;
    my $list = catfile(dirname($backup), 'list.txt');
    -f $list or error('List file not found: %s', $list) and return undef;
    my $orig = Misc::get($list) =~ /.*^# (.*?)$/ms ? $1 : undef;
    defined $orig or error('Failed to find original in: %s', $list) and return undef;
    return $orig;
}

sub list_dir($) {
    my($dir) = @_;
    print "$dir:\n";
    my $bak = get_backup_dir($dir)
        or error "can't determine backup dir for $dir" and return;
    my $prev = '';
    for my $file (Misc::find_files('.', $bak)) {
        -f $file or next;
        my $f = dirname($file);
        my $v = basename($file);
        if($f ne $prev) {
            printf "  %s:\n", Misc::relpath($f, $bak);
            $prev = $f;
        }
        printf "    %2d  %s\n",
            Misc::root($v), Misc::date_time(File::stat::stat($file)->mtime);
    }
}

sub backup($) {
    my($file) = @_;
    my $bak = get_backup_file($file) or return;  # error or -ls
    note "Saved in: $bak";
    Misc::copy($file, $bak) unless $opt->n;
}

sub get_backup_file($) {
    my($file) = @_;
#    my $bak = Misc::fullpath($file);
#    unless($bak =~ s/^([a-z]):/$1/i || $bak =~ s/^\\\\/\\/) {
#        error "can't get full path for $file: $bak";
#        return undef;
#    }
#    $bak = catdir(BACKUP_DIR, $bak);
    my $bak = catdir(get_backup_dir(dirname($file)), basename($file));
    $opt->n ? note "mkdir $bak" : Misc::mkdir($bak);
    my $suffix = Misc::suffix($file);
    for(my $i = 1; ; ++$i) {
        my $try = catfile($bak, "$i$suffix");
        if(!-e $try) {
            return $opt->ls ? undef : $try;
        }
        if($opt->ls) {
            $i == 1 and print "$file\n";
            printf "  %2d  %s\n",
                $i, Misc::date_time(File::stat::stat($try)->mtime);
        }
    }
}

sub get_backup_dir($) {
    my($file) = @_;
    my $bak = Misc::fullpath($file);
    unless($bak =~ m#^/# || $bak =~ s/^([a-z]):/$1/i || $bak =~ s/^\\\\/\\/) {
        error "can't get full path for $file: $bak";
        return undef;
    }
    $bak =~ s#\Q$ENV{HOME}/\E#/#;
    $bak = catdir(BACKUP_DIR, $bak);
    return $bak;
}

sub list_all() {
    my @roots = ();
    for my $root (Misc::get_dir(BACKUP_DIR)) {
        lc($root) eq 'auto' and next;
        push(@roots, catdir(BACKUP_DIR, $root));
    }
    my @files = ();
    File::Find::find({
        wanted => sub {
            -f $_ && $_ ne 'list.txt'
                and push(@files, canonpath $File::Find::name);
        },
    }, @roots);
    for my $file (@files) {
        my $version = basename($file);
        my $orig = Misc::relpath(dirname($file), BACKUP_DIR);
        #TODO fix shares
        $orig =~ s#^([A-Z])([/\\])#$1:$2#;
        print "$file -> $version $orig\n";
    }
}
