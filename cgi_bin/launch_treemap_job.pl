#! /usr/bin/perl -w

###################################################################################################
## launch_treemap_job.pl
##
##
##
###################################################################################################

use strict;
use warnings;
use Fcntl qw(:DEFAULT :flock);       # for file-locking.

use lib '../lib';
use TREEMAP_parse_userinput;               ## to parse the user-input coming from the CGI (stdin) ...
use TREEMAP_navigation;                    ## used for a unified look-and-feel.
use TREEMAP_taskdata_repository;
use TREEMAP_globals;

## allright, let's start: fetch the CGI parameters (i.e. the user input).

my $input = _parse_user_input ();             ## this returns a hash of parameter->value pairs (with save defaults when nothing was provided).
my $taskdata = $input->{taskdata};            ## an empty taskdata repository is also provided ...
my $usersettings = $input->{usersettings};    ## ... as well as any information we may already now about the current user.

## create a navigation object. For now, do not print any html ... we first need to verify userinput and such.
## only upon successful job-launching can we decide that we want this page to be leading on, to the status page (requesting a reload in the page header).

my $is_main_page = 0;
my $navigation = new TREEMAP_navigation ($input->{taskId}, $input->{sessionId}, $input->{userId},$is_main_page);

## check for trivial user-input errors

my ($sequence_length,$nr_of_sequences) = &check_for_user_input_errors ($input, $navigation);

my $task_id = $input->{taskId};
my $ip = $input->{ip};

new TREEMAP_taskdata_repository ($input->{taskId});
    
## launch the blast searches, store the user-, session-, and taskId, and inform the user. 

$taskdata->{userId} = $input->{userId};
$taskdata->{sessionId} = $input->{sessionId};

if ($nr_of_sequences <= 100) { #if below 100 for testing: PLEASE CHANGE IT BACK AS SOON AS POSSIBLE
    &launch_actual_searches ($input, $navigation);
} else {
    &launch_actual_searches_pleiades ($input, $navigation);
}

my $current_time = time ();

$usersettings->insert_new_task ($input->{taskId}, $current_time, $input->{job_identifier});

&print_userinfo($ip,$task_id);
&show_please_wait_message_and_exit ($input, $sequence_length, $navigation);    ## that's it: we're done.


#########################################################################################################################################
## subroutine: check_for_user_input_errors ()
##
## some trivial errors made by users are dealt with here.
#########################################################################################################################################
    
sub check_for_user_input_errors {
    
    my ($input, $navigation) = @_;
        
    unless ($input->{new_data_needed}) {
	$navigation->print_navigation_top ();
	$navigation->gen_error ("Sorry - internal error: shall not have a taskId in '$0'");
	exit;
    }

    if ($input->{seed_sequence} eq "_unassigned") {
	my $message = "You have not provided any sequence";
	&show_message_with_ok_button ($input, $navigation, $message, "error");
	exit;
    }

    $input->{seed_sequence} = lc $input->{seed_sequence};        ## lower case all characters ...
    $input->{seed_sequence} =~ s/\r\n/\n/g;
    
    if (($input->{seed_sequence} =~ /\A\>/) && !($input->{seed_sequence} =~ /\n/)) {
        my $message = "Your sequence seems to be in FASTA format but it contains no newline ";
        $message .= "to finish the sequence name.Please have a closer look at your file or contact the authors..";
        &show_message_with_ok_button ($input, $navigation, $message, "error");
        exit;
    }
    
    my $seed_sequence_for_check = $input->{seed_sequence};
    
    if ($seed_sequence_for_check =~ /.*>[^\n]*\Z/) {
        my $message = "The last sequence appears to be empty.";
        &show_message_with_ok_button ($input, $navigation, $message, "error");
        exit;
    }
    
    my %sequence_names = ();
    while ($seed_sequence_for_check =~ />(.+?)\n/g) {
        if (exists $sequence_names{$1}) {
            my $message = "The sequence name $1 appears more than once in your input.";
            &show_message_with_ok_button ($input, $navigation, $message, "error");
            exit;
        } elsif (length($1) > 60) {
            my $message = "One or more of your sequence names exceed 60 characters. Please shorten them\n";
            &show_message_with_ok_button ($input, $navigation, $message, "error");
            exit; 
        } else {
            $sequence_names{$1} = 1;    
        }
    }
    
    $seed_sequence_for_check =~ s/>.+\n/>/g;                    ## remove the name(s) from the FASTA header(s) ...
    $seed_sequence_for_check =~ s/[^a-z>]//g;                   ## and all non-letters in the remainder ...
    $seed_sequence_for_check =~ s/\A>//;                        ## remove the first fasta ">" (if existent);
    
    ## is it of the right length ?
    
    my @sequences = split /\>/, $seed_sequence_for_check;
    
    my $nr_of_sequences = @sequences;
    
    if ($nr_of_sequences > 50000) {
        my $message = "Sorry, you entered too many sequences (the current limit is 50'000).";
        &show_message_with_ok_button ($input, $navigation, $message, "error");
        exit;
    }
    my $longest_sequence = 0;
    foreach my $sequence (@sequences) {
        my $sequence_length = length $sequence;
        $longest_sequence = $sequence_length if ($sequence_length > $longest_sequence);
        if ($sequence_length < 100) { 
            next;    
        }
        if ($sequence_length > 100000) { 
            my $message = "Sorry, the sequence you provided is too long (the limit currently is at 100 kb).";
            $message = "Sorry, at least one of the sequences you provided is too long (the limit currently is at 100 kb)." if ($nr_of_sequences > 1);
            &show_message_with_ok_button ($input, $navigation, $message, "error");
            exit;
        }    
       
        ## does it smell like DNA ?

        my $nucleotide_counter = 0;
        my @letters = split //, $sequence;
        foreach my $letter (@letters) { $nucleotide_counter++ if ($letter =~ /[acgtx]/); }
        my $ratio = $nucleotide_counter / $sequence_length;

        unless ($ratio > 0.5) {  ## This does not look like a DNA sequence. Studid user ....	
            my $message = "The sequence you provided does not appear to be DNA (please do not enter protein sequences).";
            $message = "Sorry, at least one of the sequences you provided does not appear to be DNA (please do not enter protein sequences)." if ($nr_of_sequences > 1);
            &show_message_with_ok_button ($input, $navigation, $message, "error");
            exit;
        }
        ## ok - everything is fine. return the sequence length ...
    }
    
    if ($longest_sequence < 100) { 
        my $message = "The sequence you provided is too short (less than 100 nucleotides).";
        $message = "All your sequences are too short (less than 100 nucleotides)." if ($nr_of_sequences > 1);
        &show_message_with_ok_button ($input, $navigation, $message, "error");
        exit;
    }
    my $total_sequences_length = (length $input->{seed_sequence}) - $nr_of_sequences; #subtract the amount of ">" letters
    
    return ($total_sequences_length,$nr_of_sequences);
}


######################################################################################################
## subroutine: show_please_wait_message_and_exit ()
##
## this subroutine implements the polling mode. Displays a message along the lines of 'please wait',
## and makes sure that this script here will be called again in a few seconds.
######################################################################################################

sub show_please_wait_message_and_exit {

    my ($input, $sequence_length, $navigation) = @_;

    $navigation->set_polling_url ("show_submitted_jobs.pl?sessionId=$input->{sessionId}&amp;userId=$input->{userId}&amp;menu_call=2", 7);
    $navigation->activate_rotating_logo ();
    $navigation->print_navigation_top ();

    print "<p>&nbsp;</p>\n";
    print "  <table border='0' cellspacing='10'>\n";
    print "    <tr><td align='left'>Your job has been submitted (length: $sequence_length nt).</td></tr>\n";
    print "    <tr><td align='left'>TREEMAP will now start.</td></tr>\n";
    print "    <tr><td align='left'>--> you will be transferred to the job status window shortly.</td></tr>\n";
    print "  </table>\n";
    print "<form method='get' action='show_submitted_jobs.pl'><p style=\"display:inline;\">\n";
    print "    <input type='hidden' name='sessionId' value='$input->{sessionId}'/>\n";
    print "    <input type='hidden' name='userId' value='$input->{userId}'/>\n";
    print "    <input type='hidden' name='menu_call' value='2'/>\n";
    print "    <input type='submit' value='go there now'/>\n";
    print "   </p></form>\n";

    $navigation->print_navigation_bottom ();
    exit;
}


###################################################################################################
## subroutine: launch_actual_searches ()
##
###################################################################################################

sub launch_actual_searches { 

    my ($input, $navigation) = @_;
    my $job_id = $input->{job_identifier};  
    $job_id =~ s/[^>a-zA-Z0-9.]/_/g; #filenames are generated from the sequence names later on, so we have to limit the characters.
    my $sequence_filename = "$TREEMAP_globals::userdata_dir/$input->{taskId}"."_sequence.txt";
    if (open (FH_BLSEQ, "> $sequence_filename")) {
        print FH_BLSEQ ">$job_id\n" unless ($input->{seed_sequence} =~ /\A>/); #ad a fasta header if not present.
        print FH_BLSEQ "$input->{seed_sequence}\n";
        close FH_BLSEQ;
    }
    my $b_val = 1;
    $b_val = 20 if ($input->{do_bootstrapping});
    my $use_geba = "";
    $use_geba = "-t g " if ($input->{use_geba});
    my $command = "$TREEMAP_globals::mltreemap_perl_dir/mltreemap.pl -i $sequence_filename -b $b_val $use_geba";
    $command .= "-o $TREEMAP_globals::userdata_dir/$input->{taskId}/ > $TREEMAP_globals::userdata_dir/$input->{taskId}"."_report.txt";
    &spawn_independent_child_process ($command);
}

###################################################################################################
## subroutine: launch_actual_searches_pleiades ()
##
###################################################################################################

sub launch_actual_searches_pleiades { 

    my ($input, $navigation) = @_;
    my $job_id = $input->{job_identifier};  
    $job_id =~ s/[^>a-zA-Z0-9.]/_/g; #filenames are generated from the sequence names later on, so we have to limit the characters.
        
    my $sequence_filename = "/local/erisdb/www_mering/manuels/mltreemap_neu_tmp/userdata/a$input->{taskId}"."_sequence.txt";
    
    my $cp_command = "cp /local/erisdb/www_mering/manuels/mltreemap_neu_tmp/userdata/$input->{taskId}"."_sequence.txt $sequence_filename";
    system ($cp_command);
  
    if (open (FH_BLSEQ, "> $sequence_filename")) {
        print FH_BLSEQ ">$job_id\n" unless ($input->{seed_sequence} =~ /\A>/); #ad a fasta header if not present.
        print FH_BLSEQ "$input->{seed_sequence}\n";
        close FH_BLSEQ;
    }
    my $b_val = 1;
    $b_val = 20 if ($input->{do_bootstrapping});
    my $use_geba = "";
    $use_geba = "-t g " if ($input->{use_geba});
    my $command = "/local/erisdb/www_mering/manuels/mltreemap_neu_tmp/mltreemap_perl/mltreemap.pl -m 7 -i $sequence_filename -b $b_val $use_geba";
    $command .= "-o /local/erisdb/www_mering/manuels/mltreemap_neu_tmp/userdata/$input->{taskId}/ -c s > /local/erisdb/www_mering/manuels/mltreemap_neu_tmp/userdata/$input->{taskId}"."_report.txt";
    &spawn_independent_child_process_pleiades ($command);
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

    my ($command_line) = $_[0];
    chomp $command_line;
    $command_line =~ s/\n//g;
    return unless (length ($command_line) > 10);
    
    my $filename ="$TREEMAP_globals::process_starter_file";

    if (not -e $filename) { return; }
    
    sysopen (FH, "$filename", O_RDWR);
    flock (FH, LOCK_EX);
    
    my @lines = <FH>;
    
    # truncate the file to zero and write out again.
    
    truncate (FH, 0);
    seek (FH, 0, 0);        # necessary when changing from read- to write-access
    foreach my $line (@lines) { print FH $line; }
    print FH "$command_line\n";
    close FH;
}

######################################################################################################
## spawn_independent_child_process_pleiades
##
#######################################################################################################

sub spawn_independent_child_process_pleiades {

    my ($command_line) = $_[0];
    chomp $command_line;
    $command_line =~ s/\n//g;
    return unless (length ($command_line) > 10);
    
    my $filename ="/local/erisdb/www_mering/manuels/mltreemap_neu_tmp/processes/__commandlines_pleiades__";

    if (not -e $filename) { return; }
    
    sysopen (FH, "$filename", O_RDWR);
    flock (FH, LOCK_EX);
    
    my @lines = <FH>;
    
    # truncate the file to zero and write out again.
    
    truncate (FH, 0);
    seek (FH, 0, 0);        # necessary when changing from read- to write-access
    foreach my $line (@lines) { print FH $line; }
    print FH "$command_line\n";
    close FH;
}


########################################################################################
## subroutine: show_message_with_ok_button ()
##
## this shows a 'dialog-type' message, with a title and an OK-button. Clicking the 
## button brings the user back to the TREEMAP input page.
########################################################################################

sub show_message_with_ok_button {

    my ($input, $nav, $message, $title) = @_;

    $nav->print_navigation_top ();
    print "<br/>&nbsp;<br/>\n";
    $nav->gen_table_top ("$title ...", 160, 60);
    print "<br/>\n";
    print "$message\n";
    print "<br/>&nbsp;<br/>\n";
    print "<form action='treemap_input_page.pl' method='post'><p style=\"display:inline;\">\n";
    print "<input type='hidden' name='userId' value='$input->{userId}'/>\n";
    print "<input type='hidden' name='sessionId' value='$input->{sessionId}'/>\n";
    print "<input type='hidden' name='sequence' value='$input->{seed_sequence}'/>\n";
    print "<input type='submit' value=\" go back \"/></p>\n";
    print "</form>\n";
    $nav->gen_table_bot ();
    $nav->print_navigation_bottom ();
    
    return 1;
}

#########################################################################################################################################
## subroutine: print_userinfo ()
##
##
#########################################################################################################################################
    
sub print_userinfo {
    
    my $ip = shift;
    my $task_id = shift;
    
    my @time = 0;
    my $timearray = 0;
    my $timestring = 0;
    @time = gmtime;
    $time[4] += 1;
    $time[5] -= 100;
    while ($timearray <= 5) {
	   if ($time[$timearray] < 10) {
	       $time[$timearray] = "0" . $time[$timearray];
	   }
	   $timearray += 1;
    }
    $timestring = "$time[0]$time[1]$time[2].$time[3].$time[4].$time[5]";
    
    open (OUT, ">> $TREEMAP_globals::treemap_root_dir/mltreemap_users.txt") or die "Can't append to mltreemap_users.txt\n";
    
    print OUT "$timestring\t$ip\t$task_id\n";
    
    close OUT;
}
