#! /usr/bin/perl -w

###################################################################################################
## show_submitted_jobs.pl
## 
##
###################################################################################################

use strict;
use warnings;

use lib '../lib';
use TREEMAP_navigation;                    ## used for a unified look-and-feel.
use TREEMAP_parse_userinput;               ## to parse the user-input coming from the CGI (stdin) ...
use TREEMAP_taskdata_repository;
use TREEMAP_usersettings_repository;

## allright, let's start: fetch the CGI parameters.

my $input = _parse_user_input ();            ## this returns a hash of parameter->value pairs (with save defaults when nothing was provided).
my $usersettings = $input->{usersettings};   ## ... as well as any information we may already now about the current user.

## this page is not connected to any specific task in particular, so we deactivate the persistence of any task-related data:

$input->{taskdata}->set_data_dirty_flag (0);

## create the navigation object, which will output most of the actual html code ...

my $is_main_page = 0;
my $navigation = new TREEMAP_navigation ($input->{taskId}, $input->{sessionId}, $input->{userId},$is_main_page);
$navigation->set_active_main_menu_item ($input->{menu_call});

$navigation->print_navigation_top ();

my $nr_of_jobs = scalar keys %{$usersettings->{submitted_tasks}};

if ($nr_of_jobs < 1) {

    $navigation->gen_error ("Sorry - no jobs found.<br/>&nbsp;<br/>".
			    "(Jobs are stored for two weeks; ".
			    "note that you need to enable cookies in order to have jobs remembered once you close the browser window).");
    exit;
}

my $print_text = "";

my $nr_jobs_to_delete = 0;
if (exists $input->{jobs_to_delete}) {
    $nr_jobs_to_delete = scalar keys %{$input->{jobs_to_delete}};
}

$print_text .= "<br/>&nbsp;<br/>\n";

$print_text .= "<table border='0' cellspacing='0' cellpadding='2' width='90\%'>\n";

## are we to delete any jobs ?

my $delete_message = "&nbsp;";

if ($nr_jobs_to_delete > 0) { 
    my $nr_jobs_actually_deleted = 0;
    foreach my $task_id (keys %{$input->{jobs_to_delete}}) {
	if (exists $usersettings->{submitted_tasks}{$task_id}) {
	    delete $usersettings->{submitted_tasks}{$task_id};
	    $usersettings->set_data_dirty_flag (1);
	    $nr_jobs_actually_deleted += 1;
	}
    }
    if ($nr_jobs_actually_deleted > 0) {
	my $message = "1 job has been deleted";
	if ($nr_jobs_actually_deleted > 1) { $message = "$nr_jobs_actually_deleted jobs have been deleted"; }
	$delete_message = "<i><font color='red'>$message</font></i>";
    }
}

$nr_of_jobs = scalar keys %{$usersettings->{submitted_tasks}};

$print_text .= "<tr><td colspan='11'>&nbsp;$delete_message</td></tr>";
$print_text .= "<tr><td colspan='8' align='left' style='white-space;'>";
$print_text .= "Below is a list of the queries you have submitted; results are stored for at least two weeks.";
$print_text .= " Only 25 results per job are displayed on this page. The rest is available for download on the line with your job identifier in bold print.</td>";
$print_text .= "<td colspan='3' rowspan='2' valign='middle' align='center'>";
$print_text .= "<form action='show_submitted_jobs.pl'>";
$print_text .= "<p style=\"display:inline;\">";
$print_text .= "<input name='sessionId' value='$input->{sessionId}' type='hidden'/>\n";
$print_text .= "<input name='userId' value='$input->{userId}' type='hidden'/>\n";
$print_text .= "<input name='menu_call' value='2' type='hidden'/>\n";
$print_text .= "<input type='submit' value='refresh'/></p>\n";
$print_text .= "</form>\n";
$print_text .= "</td></tr>";
$print_text .= "<tr><td colspan='8' align='left' style='white-space: nowrap; padding-right: 20px;'>";
$print_text .= "You may bookmark this page (but we will also recognize you on future visits if you have ";
$print_text .= "<a class='normal_reference' href='http://en.wikipedia.org/wiki/HTTP_cookie'>cookies</a> enabled).</td></tr>\n";
$print_text .= "<tr><td colspan='11'>&nbsp;</td></tr>";

$print_text .= "<tr>";
$print_text .= "<td colspan='11'>";

my $value = "1";
$value = "0" if ($input->{select_all} == 1);

$print_text .= "<table border='0' cellspacing='0' cellpadding='2' width='100\%'>\n";

$print_text .= "<tr>\n";
$print_text .= "<td style='width: 1\%; padding: 4px 1px 4px 1px; background-color:$TREEMAP_globals::webcolor_standard_grey'></td>\n";
$print_text .= "<td style='width: 2\%; padding: 4px 1px 4px 1px; background-color:$TREEMAP_globals::webcolor_standard_grey'>";
if ($nr_of_jobs > 1) {
    $print_text .= "<form action='show_submitted_jobs.pl?sessionId=$input->{sessionId}&amp;userId=$input->{userId}&amp;menu_call=2' method='post'>";
    $print_text .= "<p style=\"display:inline;\">\n";
	$print_text .= "<input type='hidden' name='sessionId' value='$input->{sessionId}'/>";
	$print_text .= "<input type='hidden' name='userId' value='$input->{userId}'/>";
	$print_text .= "<input type='hidden' name='menu_call' value='2'/>";
	$print_text .= "<input type='hidden' name='select_all' value='$value'/>";
    $print_text .= "<input type='image' src='/treemap_images/additional_images/checkbox.png'/></p>";
    $print_text .= "</form>";
}
$print_text .= "</td>\n";
$print_text .= "<td style='width: 1\%; padding: 4px 1px 4px 1px; background-color:$TREEMAP_globals::webcolor_standard_grey'></td>\n";
$print_text .= "<td style='width: 50\%; padding: 4px 1px 4px 1px; background-color:#BBB8BC' align='center'><b>job&nbsp;identifier</b></td>\n";
$print_text .= "<td style='width: 1\%; padding: 4px 1px 4px 1px; background-color:$TREEMAP_globals::webcolor_standard_grey'></td>\n";
$print_text .= "<td style='width: 16\%; padding: 4px 1px 4px 1px; background-color:#BBB8BC' align='center'><b>submission time</b></td>\n";
$print_text .= "<td style='width: 1\%; padding: 4px 1px 4px 1px; background-color:$TREEMAP_globals::webcolor_standard_grey'></td>\n";
$print_text .= "<td style='width: 15\%;padding: 4px 1px 4px 1px; background-color:#BBB8BC' align='center'><b>status</b></td>\n";
$print_text .= "<td style='width: 1\%; padding: 4px 1px 4px 1px; background-color:$TREEMAP_globals::webcolor_standard_grey'></td>\n";
$print_text .= "<td style='width: 11\%; padding: 4px 1px 4px 1px; background-color:#BBB8BC' align='center'><b>results</b></td>\n";
$print_text .= "<td style='width: 1\%; padding: 4px 1px 4px 1px; background-color:$TREEMAP_globals::webcolor_standard_grey'></td>\n";
$print_text .= "</tr><tr><td colspan='11'>&nbsp;</td></tr>\n";


$print_text .= "<tr><td colspan='11'><form action='show_submitted_jobs.pl?sessionId=$input->{sessionId}&amp;userId=$input->{userId}&amp;menu_call=2' method='post'>\n";
$print_text .= "<table border='0' cellspacing='0' cellpadding='2' width='100\%'>";

## now list the actual jobs ...

my %identifier_of_job = ();
my %submission_time_of_job = ();

foreach my $task_id (keys %{$usersettings->{submitted_tasks}}) {
    my ($submission_time, $job_identifier) = @{$usersettings->{submitted_tasks}{$task_id}};
    $identifier_of_job{$task_id} = $job_identifier;
    $submission_time_of_job{$submission_time}{$task_id} = 1;
    
   
}

foreach my $submission_time (sort {$b <=> $a} keys %submission_time_of_job) {
    
    #format the timestring for display
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($submission_time);
    $year = $year + 1900 - 2000;
    $year = "0"."$year" if $year < 10;
    $mon += 1;
    $mon = "0"."$mon" if $mon < 10;
    $hour += 1;
    $hour = "0"."$hour" if $hour < 10;
    $min += 1;
    $min = "0"."$min" if $min < 10;
    $sec = "0"."$sec" if $sec < 10;
    my $local_submission_time = "$mday".".$mon".".$year"." $hour".":$min".":$sec";
    #done
    
    foreach my $task_id (sort {$a cmp $b} keys %{$submission_time_of_job{$submission_time}}) {
        
        my $status = "expired";
        my $finished_runs = "";

        if (-e "$TREEMAP_globals::userdata_dir/taskdata_$task_id") {
            $status = "unknown";
        }
        
        #check if it is a job on pleiades, which has been finished. If yes, transfer the data to kallisto.
        if (($status eq "unknown") && (! -e "$TREEMAP_globals::userdata_dir/$task_id.tar.gz") && (! -e "$TREEMAP_globals::pleiades_dir_base/userdata/$task_id.tar") && (-e "$TREEMAP_globals::pleiades_dir_base/userdata/$task_id.tar.gz")) {
            my $mv_command1 = "cp $TREEMAP_globals::pleiades_dir_base/userdata/a$task_id"."_sequence.txt $TREEMAP_globals::userdata_dir/$task_id"."_sequence.txt";
            my $mv_command2 = "cp -r $TREEMAP_globals::pleiades_dir_base/userdata/$task_id* $TREEMAP_globals::userdata_dir/";
            system ($mv_command1);
            system ($mv_command2);   
        }
        
        #done
     
        unless ($status eq "expired") {
            my $job_control = new TREEMAP_job_control ($task_id);
            ($status,$finished_runs) = $job_control->get_overall_status($task_id);
        }
        
        my $show_result_viewing_link = 1;
        $show_result_viewing_link = 0 if $status eq "expired";
        
        $print_text .= "<tr>";
        my $checked = "";
        $checked = "checked='checked'" if ($input->{select_all} == 1);	   
        $print_text .= "<td style='width: 3\%; background-color:$TREEMAP_globals::webcolor_standard_grey'><input type='checkbox' $checked name='delete_job_$task_id'/></td>\n";
        $print_text .= "<td style='width: 1\%;'></td>";
        $print_text .= "<td style='width: 50\%; text-align: left;'><b>$identifier_of_job{$task_id}</b></td>";
        $print_text .= "<td style='width: 1\%; '></td>";
        $print_text .= "<td style='width: 16\%; white-space: nowrap; text-align: left;'>$local_submission_time</td>";
        $print_text .= "<td style='width: 1\%'></td>";
        $print_text .= "<td style='width: 15\%; text-align: left;'><b>$status</b></td>";
        
        $print_text .= "<td style='width: 1\%; '></td>";
        $print_text .= "<td style='width: 11\%; white-space: nowrap; text-align: left;'>";
        if ((($status eq "failed") || ($status eq "completed")) && (-e "$TREEMAP_globals::userdata_dir/$task_id.tar.gz")) {
            $print_text .= "<a href='show_task_status_summary.pl?taskId=$task_id&amp;userId=$input->{userId}&amp;sessionId=$input->{sessionId}&amp;status=$status'>view results</a>" if $show_result_viewing_link;
        }
        $print_text .= "</td>";
        $print_text .= "<td style='width: 1\%; '></td>"; 
        
        $print_text .= "</tr>\n";    
        
        
        if ($status =~ /completed/) {
            my $count = 0;
            foreach my $contig (sort {$a cmp $b} keys %{$$finished_runs{$task_id}}) {
                $count++;
                
                my $job_identifier = $identifier_of_job{$task_id};
                    
                #$show_result_viewing_link = 0 if $status =~ /\ABLAST/;

                $print_text .= "<tr>";
                $print_text .= "<td style='width: 3\%; background-color:$TREEMAP_globals::webcolor_standard_grey'></td>\n";                
                $print_text .= "<td style='width: 1\%;'></td>";
                if ($count == 25) {
                    $print_text .= "<td colspan='7' style=' text-align: left;'>...</td>";
                    $print_text .= "</tr>\n";
                    last;    
                }
                $print_text .= "<td style='width: 50\%; text-align: left;'>$contig</td>";
                $print_text .= "<td style='width: 1\%; '></td>";
                $print_text .= "<td style='width: 16\%; white-space: nowrap; text-align: left;'>$local_submission_time</td>";
                $print_text .= "<td style='width: 1\%'></td>";
                $print_text .= "<td style='width: 15\%; text-align: left;'>$status</td>";
                $print_text .= "<td style='width: 1\%; '></td>";
                $print_text .= "<td style='width: 11\%; white-space: nowrap; text-align: left;'>";
                $print_text .= "<a href='show_task_status.pl?taskId=$task_id&amp;userId=$input->{userId}&amp;sessionId=$input->{sessionId}&amp;status_page_type=1&amp;contig=$contig'>view results</a>" if $show_result_viewing_link;
                $print_text .= "</td>";
                $print_text .= "<td style='width: 1\%; '></td>";
                $print_text .= "</tr>\n";
            }
        } else {
            #i.e. status eq running, failed or expired.
            
        }
    }
} 

if ($nr_of_jobs > 0) {
    $print_text .= "<tr><td style='background-color:$TREEMAP_globals::webcolor_standard_grey'>&nbsp;</td><td colspan='11'></td></tr>\n";
    $print_text .= "<tr><td style='background-color:$TREEMAP_globals::webcolor_standard_grey'>&nbsp;</td>";
    $print_text .= "<td colspan='10' align='left' style='background-image: url(/treemap_images/deletebuttonbackground.png); ";
    $print_text .= "background-repeat: no-repeat;'>";
    $print_text .= "<input type='hidden' name='sessionId' value='$input->{sessionId}'/>";
	$print_text .= "<input type='hidden' name='userId' value='$input->{userId}'/>";
	$print_text .= "<input type='hidden' name='menu_call' value='2'/>";
    $print_text .= "<input value='delete' type='submit'/></td></tr>";
}

$print_text .= "<tr><td colspan='12' align='center'>&nbsp;</td></tr>\n";
$print_text .= "<tr><td colspan='12' align='center'>&nbsp;</td></tr>\n";
$print_text .= "<tr><td colspan='12' align='center'>";

my @header_names = (undef, "Input", "BLAST &amp; COG-mapping", "Genewise", "Maximum Likelihood Testing", "Visualization");

$print_text .= "<table border='0' cellspacing='0'>";
$print_text .= "<tr><td>&nbsp;</td><td colspan='6' align='left' style='color:#555555; padding-bottom: 5px;'>&nbsp;&nbsp;";
$print_text .= "Below are the computing steps needed for each job:</td></tr>\n";
$print_text .= "<tr><td>&nbsp;</td>";
for (my $index = 1; $index <= 5; $index++) { 
    $print_text .= "<td class='result_table_header_inactive'>Step $index<br/>";
    $print_text .= "<b>$header_names[$index]</b>";
    $print_text .= "</td>";
}
$print_text .= "<td>&nbsp;</td></tr>";
$print_text .= "<tr><td>&nbsp;</td><td colspan='6' align='left' style='color:#555555; padding-top: 5px;'>";
$print_text .= "</td></tr>\n";
$print_text .= "</table>";
$print_text .= "</td></tr>\n";  

$print_text .= "</table></form></td></tr></table></td></tr>";

$print_text .= "</table>\n";

print "$print_text";

$navigation->print_navigation_bottom ();

