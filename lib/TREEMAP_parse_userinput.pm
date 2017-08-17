package TREEMAP_parse_userinput;

## - this code copied from the STRING project - some of the lines may not make sense for TREEMAP - ##

use strict;
use warnings;

use CGI;

use lib '../lib';
use TREEMAP_globals;
use TREEMAP_navigation;
use TREEMAP_job_control;
use TREEMAP_taskdata_repository;
use TREEMAP_usersettings_repository;

require Exporter;

our @ISA    = qw (Exporter);
our @EXPORT = qw (_parse_user_input);

##########################################################################################################
## _parse_user_input
##
## this routine assumes being called from a CGI-script within the STRING setup. It parses the CGI data on
## stdin, and returns a single hash summarizing what it found. For a whole range of stuff, it will assume
## safe defaults when nothing is provided on the CGI.
##########################################################################################################

sub _parse_user_input {

    ## alright, let's see what we got on stdin.

    my $cgi = new CGI;
    
    my $input = {};
    
    ## first, see who we are and what we have been doing so far:
    
    $input->{taskId} = ($cgi->param ("taskId") or "_notask") ;
    $input->{sessionId} = ($cgi->param ("sessionId") or "_nosession");
    $input->{userId} = ($cgi->param ("userId") or "_nouser");
    $input->{nru} = ($cgi->param ("nru") or undef);
    $input->{ip} = ($ENV{REMOTE_ADDR} or undef);
    
    ## well, have we been provided with a userId ? if not, there is one last place to look for one: 
    ## the cookie jar. A previous visit to STRING may have created a cookie, which might just have been 
    ## re-sent by the user's browser. If so, retrieve the UserId from there.
    ##
    ## we have to be careful though -- we will use the userId to access a file later. In principle, this could be 
    ## exploited by a 'poisened cookie' ... so we will do some basic checking here (length, content). 
    
    if ($input->{userId} eq "_nouser") {
	if (exists $ENV{HTTP_COOKIE}) {
	    my @cookies = split /; /, $ENV{HTTP_COOKIE};
	    foreach my $cookie (@cookies) {
		next if ((length $cookie) > 50);
		if ($cookie =~ /\Atreemap_embl_userid=(\w+)\z/) {
		    $input->{userId} = $1;
		}
	   }
	}
    }
    
    ## still no userId? Make a new one then. 
    
    if ($input->{userId} eq "_nouser") {   
	my $job_control = new TREEMAP_job_control ();
	$input->{userId} = $job_control->{userId};
    }

    ## same for the sessionId. If we have none, this is the first STRING page this browser-window is showing today.
    ## make a new sessionId then.
    
    if ($input->{sessionId} eq "_nosession") {
	my $job_control = new TREEMAP_job_control ();
	$input->{sessionId} = $job_control->{sessionId};
    }

    ## next, input which is common to all views:
    ## (note that some of these parameters can be set to '0' - which is not the same as not being set at all ... have to be careful there).

    ## now, input that may be relevant only to some pages/views:

    ## -- launch_treemap_job.pl -- ##
    $input->{seed_sequence} = ($cgi->param ("seed_sequence") or '_unassigned');
    $input->{fastafile} = ($cgi->param ("fastafile") or undef);
    $input->{job_identifier} = ($cgi->param ("job_identifier") or 'unassigned');
    $input->{menu_call} = ($cgi->param ("menu_call") or '_unassigned');
    $input->{do_bootstrapping} = ($cgi->param ("do_bootstrapping") or '0');
    $input->{use_geba} = ($cgi->param ("use_geba") or '0');

    ## -- show_submitted_jobs.pl -- ##
    
    $input->{select_all} = ($cgi->param ("select_all") or 0);
    
    foreach my $param ($cgi->param ()) {
	   if ($param =~ /\Adelete_job_(\w+)\z/) {
	       $input->{jobs_to_delete}{$1} = 1;
	   }
    }
        
    ## -- task status page -- ##
    $input->{status_page_type} = ($cgi->param ("status_page_type") or '1');
    $input->{status_page_image_type} = ($cgi->param ("status_page_image_type") or 'circular');
    $input->{contig} = ($cgi->param ("contig") or 'summary');
    
    ## -- task status summary page -- ##
    $input->{status} = ($cgi->param ("status") or 'failed');
    
    ## -- input page -- ##
    $input->{identifier} = ($cgi->param ("identifier") or "_unassigned");
    $input->{sequence} = ($cgi->param ("sequence") or "_unassigned");

    ## now, we need to take care of various default scenarios.
    ## check if we were given a taskId. If yes, this means that we can recover information from previous visits ...
    
    $input->{new_data_needed} = 0;
    if ($input->{taskId} eq "_notask") { 
	my $job_control = new TREEMAP_job_control;
	$input->{taskId} = $job_control->{taskId};
	$input->{new_data_needed} = 1;
    }
    
    ## now generate the taskdata repository ... and fill it from the persistent storage if applicable.
    ## if successful, we can regenerate sessionId and userId from the storage.
    
    $input->{taskdata} = new TREEMAP_taskdata_repository ($input->{taskId});

    unless ($input->{new_data_needed}) {
	
	my $result = $input->{taskdata}->retrieve_data_from_storage ();
	unless ($result) { 
	    my $nav = new TREEMAP_navigation ($input->{taskId}, $input->{sessionId}, $input->{userId});
	    $nav->print_navigation_top ();
	    $nav->show_expiration_message ();
	    exit;
	}
	$input->{sessionId} = $input->{taskdata}->{sessionId} unless (exists $input->{nru});
	$input->{userId} = $input->{taskdata}->{userId} unless (exists $input->{nru});
    }

    $input->{taskdata}->{sessionId} = $input->{sessionId};
    $input->{taskdata}->{userId} = $input->{userId};
    
    ## now check the user-repository for this user's settings (or for safe defaults, if we have a naive user).
    ## conversely, store any relevant settings that may have been provided by the user just now.
    
    $input->{usersettings} = new TREEMAP_usersettings_repository ($input->{userId}, $input->{sessionId});

    unless ($input->{userId} eq "_nouser") { $input->{usersettings}->retrieve_data_from_storage (); }
    
    ## if the user indicated that he wanted to upload a file, get it now ...
    
    if ($input->{fastafile}) {
        $input->{fastafile_data} = undef;
        my $upload_filehandle = $cgi->upload ("fastafile");
        if ($upload_filehandle) {
            binmode $upload_filehandle;

            my $data;
            while (read $upload_filehandle, $data, 10000000) {
                $input->{fastafile_data} .= $data;
            }
        }
	   $input->{seed_sequence} = $input->{fastafile_data};
    }
    return $input;
}
