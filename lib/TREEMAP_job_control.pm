package TREEMAP_job_control;

## - this code copied from the STRING project - some lines may not make sense for TREEMAP - ##

############################################################################################
## TREEMAP_job_control
##
## This module implements session-IDs, user-IDs, queuing systems, background jobs and 
## related flow-control items.
############################################################################################

use strict;
use warnings;
use Fcntl qw(:DEFAULT :flock);       # for file-locking.

use TREEMAP_globals;               # directories, global parameters, ...

## constructor:
##
## job_control's constructor 'new' can be called with or without 
## taskId/sessionIds/userIds. If it's called without, it makes itself new ones.

sub new {

    my ($that, $taskId, $sessionId, $userId) = @_;
    
    my $class = ref($that) || $that;    
    my $self = {};
    bless $self, $class;

    unless ((defined $taskId) and ($taskId =~ /\A\w+\z/)) {         ## no legal taskId provided ?  -> make a new one.    
	$taskId = $self->make_unique_id ();
    }

    unless ((defined $sessionId) and ($sessionId =~ /\A\w+\z/)) {   ## dito for the sessionId ...
	$sessionId = $self->make_unique_id ();
    }

    unless ((defined $userId) and ($userId =~ /\A\w+\z/)) {         ## ... and the userId.
	$userId = $self->make_unique_id ();
    }

    $self->{taskId} = $taskId;
    $self->{sessionId} = $sessionId;
    $self->{userId} = $userId;
    $self->{blast_finished} = undef;
    
    return $self;
}


sub has_finished_completely {

    my ($self) = @_;

    my $blast_status =$self->get_status("blast");
    my $string_status = $self->get_status ("string");

    unless ($blast_status =~ m/done|failure/) { return 0; }
    unless ($string_status =~ m/done|failure/) { return 0; }

    return 1;
}


sub create_status_file {   # CVM : all the methods below need more 
                           #       verbose error handling !!!

    my ($self, $file_suffix, $timeout_value) = @_;

    my $filename = "$TREEMAP_globals::userdata_dir/$self->{taskId}.$file_suffix.status";
    if (-e $filename) { return 0; }

    my $start_time = time;
    if (not defined $timeout_value or $timeout_value < 0) { $timeout_value = 0; }
    umask 0111;
    sysopen (FH, "$filename", O_WRONLY | O_CREAT, 0777);
    flock (FH, LOCK_EX);
    print FH "\n";                # current 'ticks' of this job (ticks simply
                                  # increase to show that time is passing). now empty.
    print FH "\n";                # status. now empty. can be 'done', 'queued', 'running', 'failure' ...
    print FH "$start_time\n";     # timestamp of creation of this job.
                                  # in seconds since 1.1.1970
    print FH "$timeout_value\n";  # maximum time allowed for this job (in seconds).
                                  # zero: may run indefinitely.
    print FH "\n";                # message. now empty.
    close FH;
}

sub check_for_timeout {

    my ($self, $file_suffix) = @_;

    my $filename = "$TREEMAP_globals::userdata_dir/$self->{taskId}.$file_suffix.status";
    if (not -e $filename) { return 0; }

    sysopen (FH, "$filename", O_RDWR);
    flock (FH, LOCK_EX);
    my $ticks = <FH>;
    my $status = <FH>;
    my $start_time = <FH>;
    my $timeout_value = <FH>;
    my $message = <FH>;
    close FH;

    if ($timeout_value <= 0) { return 0; }

    my $current_time = time;
    if (($current_time - $start_time) < $timeout_value) { return 0; }

    ## if this point is reached, a timeout has occured.

    my $errortext = "your job has taken too long (timeout is ";
    $errortext .= "$timeout_value seconds)";

    $self->declare_failure ($file_suffix, $errortext);

    return 1;
}

sub increment_status_tick {

    my ($self, $file_suffix) = @_;

    my $filename = "$TREEMAP_globals::userdata_dir/$self->{taskId}.$file_suffix.status";
    if (not -e $filename) { return 0; }

    sysopen (FH, "$filename", O_RDWR);
    flock (FH, LOCK_EX);
    my $ticks = <FH>;
    my $status = <FH>;
    my $start_time = <FH>;
    my $timeout_value = <FH>;
    my $message = <FH>;

    # do not increment ticks for a status-file where the status has
    # already been decided conclusively.

    unless ($status =~ /done|failure/) {
	if (length ($ticks) < 40) {
	    chomp ($ticks);
	    $ticks .= "-\n"; 
	}
    }

    truncate (FH, 0);
    seek (FH, 0, 0);        # necessary when changing from read- to write-access
    print FH $ticks;
    print FH $status;
    print FH $start_time;
    print FH $timeout_value;
    print FH $message;
    close FH;
}


sub declare_success {
   
    my ($self, $file_suffix, $message) = @_;
    $self->set_status_and_message ($file_suffix, "done.", $message);
}


sub declare_failure {

    my ($self, $file_suffix, $error) = @_;
    $self->set_status_and_message ($file_suffix, "failure.", $error);
}

#######################################################################################################
## subroutine: get_overall_status ()
##
##
#######################################################################################################

sub get_overall_status {
    my ($self,$task_id) = @_;

    my %finished_runs = ();            
    my $status = "running";
    
    
    ## Check if queued:
    
    #my $commands_filename ="$TREEMAP_globals::process_starter_file";
    #my $sequence_filename = "$TREEMAP_globals::mltreemap_perl_dir/$self->{taskId}"."_report.txt";
    #my $command_common_part1 = "$TREEMAP_globals::mltreemap_perl_dir/mltreemap.pl -i $sequence_filename -b ";
    #my $command_common_part2 .= "-o $TREEMAP_globals::userdata_dir/$input->{taskId}/ > $TREEMAP_globals::userdata_dir/$input->{taskId}"."_report.txt";
    #my $command_common_part3 = "\t$file_header";
    #my $command = "$command_common_part1"."20"."$command_common_part2"."$command_common_part3";   
    #my $command2 = "$command_common_part1"."1"."$command_common_part2"."$command_common_part3";
    #my $command3 = "$command_common_part1"."20 -t g"."$command_common_part2"."$command_common_part3";
    #my $command4 = "$command_common_part1"."1 -t g"."$command_common_part2"."$command_common_part3";
    
    #sysopen (FH, "$commands_filename", O_RDONLY) or die "Can't open $commands_filename\n";
    #flock (FH, LOCK_EX);
    #my @lines = <FH>;                 
    #close FH;
    #foreach my $line (@lines) {
    #    chomp $line;
    #    if (($line eq $command)||($line eq $command2)||($line eq $command3)||($line eq $command4)) {
    #        $status = "queued";    
    #    }
    #}
    #done
    
    my $report_file = "$TREEMAP_globals::userdata_dir/$task_id"."_report.txt";
    my $there_was_a_placement = 0;
    if (-e $report_file) {
        open (IN, "$report_file");
        while (<IN>) {
            chomp $_;
            $there_was_a_placement = 1 if (/Placement/);
            $status = "ML completed, visualization running" if ($_ eq "Done."); #mltreemap.pl is done
        }    
    }
    
    $status = "failed" if (($status eq "ML completed, visualization running") &&  !$there_was_a_placement);
    
    if ($status eq "ML completed, visualization running") {
    
        my $path = "$TREEMAP_globals::userdata_dir/$task_id/final_RAxML_outputs/";
        
        if (!(-e $path)) {
            $status = "Expired"; #"Expired" should be replaced by "expired"
        } else {
        
            opendir (PATH, "$path") or die "Error, the directory $path does not exist!\n";
            my @files = readdir PATH;
            closedir (PATH);      
            my $nr_of_files = @files + 0;
            $status = "failed" unless ($nr_of_files > 2); #the files . and .. are also present...
        
            my $last_denominator = "";
            foreach my $file (@files) {
                if ($file =~ /\A(.)_(.+)_RAxML_parsed.txt/) {
                    my $denominator = $1;
                    my $contig = $2;
                    $finished_runs{$task_id}{$contig}{$denominator} = 1;
                    $last_denominator = $denominator;
                }
            }
            my $file = "$TREEMAP_globals::userdata_dir/$task_id/images/summary/$last_denominator"."_concatenated_RAxML_outputs.txt_image_circular.png";
            $status = "completed" if (-e $file);
        }
    }
    
    return ($status, \%finished_runs);
}


#######################################################################################################
## spawn_independent_child_process
##
## ok, this routine is a bit of a hack. 
##
## It is needed, however, if we reliably want to create a background-process from within a CGI-script.
## We run mod_perl, so CGI-scripts are actually executed within an apache-child-process. This is
## not a safe place to spawn children, really (apache child-processes may be terminated at any time, 
## funny things go on with mod_perl's caching of modules and Perl itself ...)
##
## So, what we do is this: We drop into a special file the command we want executed.
##
## Then, some external daemon which is always running is polling that file and actually starting the
## command in the background. I know this is ugly, but it has proven safe and reliable ... ;)
## [for the external daemon, check here: cgi_bin/subcommand_executor.pl]
#######################################################################################################

sub spawn_independent_child_process {

    my ($self, $command_line) = @_;

    chomp $command_line;
    $command_line =~ s/\n//g;
    return unless (length ($command_line) > 10);
    
    my $filename ="$TREEMAP_globals::process_starter_file";

    if (not -e $filename) { return; }
    
    sysopen (FH, "$filename", O_RDWR | O_APPEND);
    flock (FH, LOCK_EX);
    
    my @lines = <FH>;
    
    # truncate the file to zero and write out again.
    
    truncate (FH, 0);
    seek (FH, 0, 0);        # necessary when changing from read- to write-access
    foreach my $line (@lines) { print FH $line; }
    
    print FH "$command_line\n";
    close FH;
}

#############################################################################################
## make_unique_id
##
## this routine makes a unique identifier consisting of alphanumeric letters, length 12.
## The identifier is made in a way that is guaranteed to be unique (no two calls to 
## the routine will generate the same two identifiers more frequently than 1 in 10^z, with z 
## being quite large), 
## and it is also virtually impossible to predetermine from the outside what the next
## identifier will be, so users cannot guess the identifiers of other users.
##
## The identifiers generated here can be used as public session- task- or user-Ids.
#############################################################################################

sub make_unique_id {

    my ($self) = @_;
    
    ## first, specify the alphabet of the identifier. This is URL-safe, contains no whitespace and such.
    ## beware: capitalization generally *does* matter in the ids here ...

    my @chars = ('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 
		 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'Y', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
		 '0', '1', '2', '3', '4', '5', '6', '7', '8', '9');
    my $num_chars = scalar @chars;

    ## get the local time. This is one element of making unique and pseudorandom identifiers.
    ## other elements are the IP-number, process-number, and an actual random number from the C-library.

    my ($sec, $min, $hour, $mday, $mon, $year) = localtime ();
    my $foreign_ip = "no_ip";
    if (exists $ENV{REMOTE_ADDR}) { $foreign_ip = $ENV{REMOTE_ADDR}; } 
    my $process_id = $$;
    my $random_no = int (rand 1000) + 1;

    my $inputstring = "$random_no$hour$foreign_ip$mon$process_id$mday$sec$year$min";
    $inputstring =~ s/[^\d]//g;     ## remove all non-digits;

    # now shuffle it.
    
    my $length = length ($inputstring); my @output = (); my $outputstring = "";
    
    for (my $i = 0; $i < $length; $i++) { $output[$i] = "-"; }
    
    for (my $i = 0; $i < $length; $i++) {
	
	my $character = chop $inputstring;
	my $position = int (rand ($length));
	until ($output[$position] eq "-") {
	    $position++; if ($position == $length) { $position = 0; }
	}
	$output[$position] = "$character";
    }
    
    for (my $i = 0; $i < $length; $i++) { $outputstring .= "$output[$i]"; }
    
    # now transliterate it.
    
    $outputstring =~ tr/0123456789/8357012649/;             
    
    # and produce two halfs of 14 digits each:
    
    my @numbers = (substr ($outputstring, 0, 14), substr ($outputstring, 14, 14));
    
    # map to the alphabet and truncate to no more than 12 characters.

    my $outputstring2 = "";
    
    foreach my $number (@numbers) {
	while ($number > 1) {
	    my $index = $number % $num_chars;
	    $outputstring2 .= $chars[$index];
	    $number = int ($number / $num_chars);
	}
    }
    
    my $finalstring = substr ($outputstring2, 1, 12);

    return $finalstring;
}
  
  
1;





