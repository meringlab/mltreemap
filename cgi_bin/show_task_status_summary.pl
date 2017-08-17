#! /usr/bin/perl -w

###################################################################################################
## show_task_status_summary.pl
## 
###################################################################################################

use strict;
use warnings;

use lib '../lib';
use TREEMAP_job_control;                   ## flow control, queues, generate unique IDs, ...
use TREEMAP_parse_userinput;               ## to parse the user-input coming from the CGI (stdin) ...
use TREEMAP_navigation;                    ## used for a unified look-and-feel.
use TREEMAP_globals;

## allright, let's start: fetch the CGI parameters.

my $input = _parse_user_input ();            ## this returns a hash of parameter->value pairs (with save defaults when nothing was provided).
my $taskdata = $input->{taskdata};           ## an empty taskdata repository is also provided.
my $usersettings = $input->{usersettings};
my $taskId = $input->{taskId};
my $status = $input->{status};

## create the navigation object, which will output most of the actual html code ...

my $is_main_page = 0;
my $navigation = new TREEMAP_navigation ($input->{taskId}, $input->{sessionId}, $input->{userId},$is_main_page);
$navigation->print_navigation_top ();

## internal consistency check: must have a valid taskId at this point (was checked in '_parse_user_input' ...)

if ($input->{new_data_needed}) {
    $navigation->gen_error ("Sorry - internal error: this page must be called with a valid task-id.");
    exit;
}

my ($submission_time, $job_identifier) = (undef, undef);
if (exists $usersettings->{submitted_tasks}{$taskId}) {
    ($submission_time, $job_identifier) = @{$usersettings->{submitted_tasks}{$taskId}};
}
my $local_submission_time = "unspecified date";
if (defined $job_identifier) {
    $local_submission_time = scalar localtime ($submission_time);
} else {
    $job_identifier = "unspecified sequence";
}

print "<br/>&nbsp;<br/>\n";
print "<table border='0' cellpadding='3' width='80%'>\n";

print "<tr><td align='center'><b>Results for job <i>'$job_identifier'</i></b></td></tr>\n";
print "<tr><td align='center'><b>(submitted on $local_submission_time)</b></td></tr>\n";
print "</table><br/>\n";

print "<table border='0' cellpadding='0' cellspacing='0' width='80%'>\n";

print "<tr><td style='width: 1\%;'>";
print "<div style=\"background:url('/treemap_images/result_box/tabbase.bottom.long.png') right bottom; background-repeat:repeat-x; margin:0px; padding:0px\"/>\n";
print "<div style=\"background:url('/treemap_images/result_box/tabbase.lowerleft.png') no-repeat left bottom; \"/>\n";
print "&nbsp;<br/>&nbsp;<br/>&nbsp;</td>";

print "<td style='width: 1\%;'>";
print "<div style=\"background:url('/treemap_images/result_box/tabbase.bottom.long.png') right bottom; background-repeat:repeat-x; margin:0px; padding:0px\"/>\n";
print "<div style=\"background:url('/treemap_images/result_box/tabbase.lowerright.png') no-repeat right bottom; \"/>\n";
print "&nbsp;<br/>&nbsp;<br/>&nbsp;</td></tr>"; 

print "<tr><td colspan='7' style=\"background-color:$TREEMAP_globals::webcolor_standard_grey\">";
print "<div style=\"background:url('/treemap_images/result_box/body.bottom.png') right bottom; background-repeat:repeat-x; margin:0px; padding:0px\"/>\n";
print "<div style=\"background:url('/treemap_images/result_box/body.upperright.png') right top; background-repeat:repeat-y; margin:0px; padding:0px\"/>\n";
print "<div style=\"background:url('/treemap_images/result_box/body.lowerright.png') no-repeat right bottom;\"/>\n";
print "<div style=\"background:url('/treemap_images/result_box/body.upperleft.png') left top; background-repeat:repeat-y; margin:0px; padding:0px\"/>\n";
print "<div style=\"background:url('/treemap_images/result_box/body.lowerleft.png') no-repeat left bottom; padding: 5px 8px 5px 8px;\"/>\n";

if ($status eq "completed") {
    
    print "<table border='0' cellspacing='5'>";
    print "<tr><td style='padding-right: 20px;'>";
    print "<b>Summary page:</b><br/><br/>";
    print "<a class='normal_reference' href='/treemap_userdata/$taskId.tar.gz'>Download</a>";
    print " the tar repository containing all results for your job.";
    print "<br/><br/><br/>The concatenated results of your job are displayed in the visualisation(s) below:";
    print "</td></tr>\n";


    my %functional_cogs = ("18srRNA" => 2, "16srRNA" => 3, COG1850 => 4, _K02586 => 5, _K02588 => 6, p_a_moA => 7, dsr_v2_ => 8, phocryp => 9, hzo_hao => 10, bssAref => 11, mcrAref => 12);
    my %nr_analysis = (1 => "Phylogenetic analysis", 2 => "rRNA analysis, 18s", 3 => "rRNA analysis, 16s", 4 => "Functional analysis, RuBisCO", 5 => "Functional analysis, nitrogenase (nifD)", 6 => "Functional analysis, nitrogenase (nifH)", 7 => "Functional analysis, methane monooxygenase" , 8 => "Functional analysis, dsrAB", 9 => "Functional analysis, Photolyase/Cryptochrome", 10 => "Functional analysis HZO/HAO", 11 => "Functional analysis, bssA",12 => "Functional analysis, mcrA");
    my %funcs = (1 => "p", 2 => "b", 3 => "a", 4 => "r", 5 => "n", 6 => "h", 7 => "m", 8 => "d", 9 => "c", 10 => "e", 11 => "w", 12 => "y");
    my $size_of_funcs_hash = (keys %funcs) + 0;
    my $no_picture_available_yet = 1;
    
    foreach my $nr (sort {$a <=> $b} keys %nr_analysis) {
    
        my $func = $funcs{$nr};
        my $analysis = $nr_analysis{$nr};
        
        my $circular_file = "$TREEMAP_globals::userdata_dir/$taskId/images/summary/$func"."_concatenated_RAxML_outputs.txt_image_circular.png";
        
        if (-e "$circular_file") {
            $no_picture_available_yet = 0;
        } else {
            if (($func eq "p") && (-e "$TREEMAP_globals::userdata_dir/$taskId/images/summary/g"."_concatenated_RAxML_outputs.txt_image_circular.png")) {
                $func = "g"; #i.e. we run the geba analysis...
                $no_picture_available_yet = 0;
                $circular_file = "$TREEMAP_globals::userdata_dir/$taskId/images/summary/$func"."_concatenated_RAxML_outputs.txt_image_circular.png";  
            } else {
                if ($no_picture_available_yet && ($nr == $size_of_funcs_hash)) { 
                    print "</tr><tr><td>&nbsp;<br/>Sorry, this task is currently still running on our server.<br/>&nbsp;<br/>Please return later.<br/>&nbsp;<br/>\n";
                    print "<form action='show_task_status_summary.pl' method='get'><p>";
                    print "<input type='hidden' name='taskId' value='$taskId'/>";
                    print "<input type='hidden' name='sessionId' value='$input->{sessionId}'/>";
                    print "<input type='hidden' name='userId' value='$input->{userId}'/>";
                    print "<input type='hidden' name='status_page_type' value='$input->{status_page_type}'/>";
                    print "<input type='submit' value='Refresh'/></p></form></td></tr>";
                }
                next;
            }
        }
          
        print "<tr><td colspan='2'><hr/></td></tr>\n";
        print "<tr><td style='padding-right: 20px;'><b>$analysis</b>:</td>"; 
        
        my $directory = "$TREEMAP_globals::userdata_dir/$taskId/images/summary/";
        my $directory_for_tag = "/treemap_userdata/$taskId/images/summary/";
        my $filename_common_part = "$func"."_concatenated_RAxML_outputs.txt_image_";
        my $circular_file_name_compact = "$filename_common_part"."circular.compact.png";
        my $circular_file_name = "$filename_common_part"."circular.png";;
        my $linear_file_name_compact = "$filename_common_part"."straight.compact.png";
        my $linear_file_name = "$filename_common_part"."straight.png";
   
    
        my $image_file_to_show = "$directory$circular_file_name_compact";
        my $image_tag_to_show = "<img alt='' src='$directory_for_tag$circular_file_name_compact' width='800' height='800'/>";
        
        unless (-e $image_file_to_show) {
            print "</tr><tr><td>&nbsp;<br/>Sorry, unable to read the image file.<br/>&nbsp;<br/>It may have expired (results expire after about two weeks)";
            print "<br/>&nbsp;<br/></td></tr>\n";
            next;
        }	

        print "</tr><tr><td><a class='normal_reference' href='$directory_for_tag/$filename_common_part$input->{status_page_image_type}.png'>";
        print "high&nbsp;resolution&nbsp;version</a><br/>";
        print "</td></tr>";

        my $lines_printed = 0;

        print "<tr><td colspan='2'>";

        print $image_tag_to_show;
        print "</td></tr>\n";
    }
    print "</table>\n";
} else {
    print "<table border='0' cellspacing='5'>";
    print "<tr><td style='padding-right: 20px;'>";
    print "<b>Summary page:</b><br/><br/>Sorry, neither phylogenetic nor functional placements could be made based on your sequence(s).<br/><br/>";
    print "<a class='normal_reference' href='/treemap_userdata/$taskId.tar.gz'>Download</a>";
    print " the tar repository containing intermediate results (if any).<br/>&nbsp;";
    print "</td></tr></table>";    
}
print "</td></tr></table>"; 

$navigation->print_navigation_bottom ();
