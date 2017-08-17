#! /usr/bin/perl -w

###############################################################################################
## treemap_input_page.pl
## 
## this is the first script executed when starting a TreeMap session. 
###############################################################################################

use strict;
use warnings;

use CGI;                                 ## standard CPAN-module for CGI-communication.

use lib '../lib';
use TREEMAP_globals;                     ## paths, versions, etc ... 
use TREEMAP_navigation;                  ## unified look and feel, menus, dialogs ...
use TREEMAP_parse_userinput;             ## to parse and verify the user-input ...
use TREEMAP_usersettings_repository;     ## to (re-)identify the current user ...

## ok, first get the user input - if there is any (otherwise, safe defaults are provided).

my $input = _parse_user_input;
my $usersettings = $input->{usersettings};

## now let's print the first part of the page.
## this is done through the 'TREEMAP_navigation' module, because the first part of the page
## is common to all TREEMAP-pages. It contains menus, scripts, styles, icons and stuff.
##
## in addition, the inputpage (and only the inputpage) will also attempt to place a cookie.

my $is_main_page = 1;
my $nav = new TREEMAP_navigation ($input->{taskId}, $input->{sessionId}, $input->{userId},$is_main_page);
$nav->attempt_cookie ("on");
$nav->set_title_illustration_visibility ("on") unless $input->{menu_call} eq "1";
$nav->set_active_main_menu_item ($input->{menu_call});
$nav->print_navigation_top;

## this page is initially not connected to any specific task in particular, so we deactivate the saving of any task-related data for now.
## (unless this is actually a re-visit, in which case some real input data may have been provided earlier).

if ($input->{new_data_needed}) {
    $input->{taskdata}->set_data_dirty_flag (0);
}

## ok. now for some HTML output specific to this page. We will print three 'dialog'-boxes ... 
## One of them will allow user input, and the two others will display some general propaganda.

my $go_button_extras = "class='treemapSubmitButton' style='width: 54px; height: 25px; text-align: center;'";
my $reset_button_extras = "class='treemapResetButton' style='width: 60px; height: 25px; text-align: center;'";
my $tasks_button_extras = "class='treemapTasksButton' style='width: 60px; height: 25px; text-align: center;'";

## ok, before we do anything else we need to open the <form>-tag to avoid unwanted line-breaks later 
## (the <form> tag introduces line-breaks in some contexts).

print "<table border='0' cellpadding='0' cellspacing='0' style='text-align: left;'><tr><td>";
print "<form id='input_form' action='/treemap_cgi/launch_treemap_job.pl' method='post' enctype='multipart/form-data'>";

print "<table border='0' cellpadding='0' cellspacing='0' width='769'>\n";
print "<tr><td colspan='4'>&nbsp;</td></tr>";
print "<tr><td colspan='4'>&nbsp;</td></tr>";

## alright, now the input form:

print "<tr>\t";
print "<td colspan='4' style=\"background:url('/treemap_images/additional_images/Input_box_top.png') no-repeat left bottom; HEIGHT: 48px;\"></td>\n";
print "</tr>\n";
print "<tr style=\"background:url('/treemap_images/additional_images/background_grey.png')\">";
print "<td rowspan='5' style=\"background:url('/treemap_images/additional_images/Input_box_left.png') left bottom; background-repeat:repeat-y; WIDTH: 15px;\"></td>\n";
print "<td colspan='2' style='white-space: nowrap; padding: 5px;'>\n";
print "<span style='color: black;font-family:Verdana,Helvetica,Arial,sans-serif; font-size: 12px;'>";
print "enter up to 50'000 DNA sequences in <a class='normal_reference' href='http://en.wikipedia.org/wiki/FASTA_format'>FASTA</a> format:</span>\n";
print "<br/><textarea name='seed_sequence' rows='5' cols='1' style='width: 100%;'></textarea>&nbsp;<br/>\n";
#print "<span class='treemap_example'>(or look at precomputed examples: "; #reactivate when nice precomputed examples exist.
#my $nr_examples = scalar keys %TREEMAP_globals::input_examples;
#foreach my $example (sort {$a <=> $b} keys %TREEMAP_globals::input_examples) {
#    my ($short_hand, $job_identifier, $example_taskId) = @{$TREEMAP_globals::input_examples{$example}};
#    print "<a href=";
#    print "'/treemap_cgi/show_task_status.pl?nru=1&taskId=$example_taskId&amp;userId=$input->{userId}&sessionId=$input->{sessionId}&status_page_type=5'>";
#    print "$short_hand</a>";
#    print ",&nbsp;" if $example < $nr_examples;
#}
#print ")</span>";
print "</td>\n";
print "<td rowspan='5' style=\"background:url('/treemap_images/additional_images/Input_box_right.png') right bottom; background-repeat:repeat-y; WIDTH: 15px;\">";
print "</td>\n";
print "</tr>\n";

print "<tr style=\"background:url('/treemap_images/additional_images/background_grey.png')\">";
print "<td>&nbsp;or upload a FASTA file:<br/>&nbsp;<input name='fastafile' type='file' maxlength='10000000' accept='text/*'/></td>\n";
print "<td>";
print "<table>";
print "<tr><td><input type='checkbox' name='use_geba' value='1'/> use the GEBA reference phylogeny (<a class='normal_reference' ";
print "href='http://www.ncbi.nlm.nih.gov/pubmed/20033048'>Ref</a>)</td></tr>";
print "<tr><td><input type='checkbox' name='do_bootstrapping' value='1'/> turn on non-parametric bootstrapping</td></tr>";
print "</table>";
print "</td>\n";
print "</tr>\n";
print "<tr style=\"background:url('/treemap_images/additional_images/background_grey.png')\"><td colspan='2'>&nbsp;</td></tr>\n";

print "<tr style=\"background:url('/treemap_images/additional_images/background_grey.png')\"><td style='white-space: nowrap; padding: 5px;'>\n";
print "&nbsp;<br/><span style='color: black;font-family:Verdana,Helvetica,Arial,sans-serif; font-size:12px;'>provide an identifier for your job (optional):</span>";
print "<br/><input name='job_identifier' style='width: 26em;'/>&nbsp;";
print "<input name='userId' value='$input->{userId}' type='hidden'/>\n";
print "<input name='sessionId' value='$input->{sessionId}' type='hidden'/>\n";
print "</td>\n";

print "<td rowspan='1' align='left' valign='bottom'>";
print "<i>Note:</i><br/>- your sequence preferably contains ";
print "<a class='normal_reference' href='/treemap_html/marker_genes.txt'>marker genes</a> ...<br/>";
print "- here are some input sequences: ";
my $nr_sequences = scalar keys %TREEMAP_globals::input_sequences;
foreach my $example_sequence (sort {$a <=> $b} keys %TREEMAP_globals::input_sequences) {
    my ($short_hand, $job_identifier, $sequence) = @{$TREEMAP_globals::input_sequences{$example_sequence}};
    print "<a href='#' class='normal_reference' onclick='document.getElementById(\"input_form\").seed_sequence.value=\"$sequence\";\n";
    print "document.getElementById(\"input_form\").job_identifier.value=\"$job_identifier\"; return false;'>$short_hand</a>";
    print ",&nbsp;" if $example_sequence < $nr_sequences;
}
print "<br/>- <a class='normal_reference' href='http://mltreemap.org/treemap_cgi/show_download_page.pl?menu_call=3'>download</a> the stand-alone version for large datasets<br/>";
print "</td>\n";

print "</tr>";
print "<tr style=\"background:url('/treemap_images/additional_images/background_grey.png')\"><td style='text-align: left; white-space: nowrap; ' valign='bottom'>&nbsp;<br/>";

## go and reset buttons. The old code is commented out. I don't wan't to use Javascript unless it is essential.
## I keep the outcommented part because it's an example of a working java script...

print "<input type='submit' value='GO !'/>&nbsp;\n";
print "<input type='reset' value='Reset'/>\n";

## the "go!"-button:

#print "<script type='text/javascript'>\n";  
#print "<!--\n";
#print "document.write ('<img src=\"/treemap_images/additional_images/button_go_dark.png\" width=\"54\" height=\"25\" usemap=\"#submit_button_map\" alt=\"\"/>');\n";
#print "-->\n";
#print "</script>\n";
#print "<noscript>\n";
#print "<div><input type='submit' value='GO !' $go_button_extras/></div>\n";
#print "</noscript>\n";

## the "reset"-button:

#print "<script type='text/javascript'>\n";  
#print "<!--\n";
#print "document.write ('<img src=\"/treemap_images/additional_images/button_reset_dark.png\" width=\"60\" height=\"25\" usemap=\"#reset_button_map\" alt=\"\"/>');\n";
#print "-->\n";
#print "</script>\n";
#print "<noscript>\n";
#print "<div><input type='reset' value='Reset' $reset_button_extras/></div>\n";
#print "</noscript>\n";

print "</td>\n";

print "<td align='left' style='white-space: nowrap;'>";
print "</td>\n";

print "</tr>\n";
print "<tr>\n";
print "<td colspan='4' align='right' valign='bottom' style=\"background:url('/treemap_images/additional_images/Input_box_bottom.png') no-repeat left top; HEIGHT: 19px;\">";
print "</td>\n";
print "</tr>\n";
print "<tr>\n";
print "<td colspan='4'>&nbsp;";
print "</td>\n";
print "</tr>\n";

#print "</table>";
#$nav->gen_info_box_bottom;

#print "</td>\n";
#print "</tr>\n";

## and now the visualizer box.



## and now the section with general information / references / Logos.

print "<tr>\n";
#print "<table border='0' cellpadding='0' cellspacing='0' width='769'>\n";
print "<td colspan='4' style=\"background:url('/treemap_images/additional_images/Info_box_top.png') no-repeat left bottom; HEIGHT: 48px;\"></td>\n";
#print "</td>\n";
print "</tr>\n";
print "<tr>\n";
print "<td style=\"background:url('/treemap_images/additional_images/Info_box_left.png') left bottom; background-repeat:repeat-y; WIDTH: 15px;\"><p>&nbsp;</p>";
print "</td>\n";
print "<td colspan='2'>\n";

print "<table>\n";
print "<tr>\n";
print "<td style='padding: 3px; white-space: nowrap;'>\n";
print "The MLTreeMap publication can be found ";
print "<a class='normal_reference' href='http://www.biomedcentral.com/1471-2164/11/461'>here</a>.\n";
print "</td>\n";
print "<td align='right' rowspan='5' style='padding: 5px;'>\n";
print "&nbsp;&nbsp;&nbsp;&nbsp;<img src='/treemap_images/triple_logo.png' usemap='#DOUBLELOGO' width='165' height='130' alt=''/>\n";
print "<map name='DOUBLELOGO' id='DOUBLELOGO'>\n";
print "<area alt='Bork homepage' href='http://www.bork.embl.de/j/' ";
print "coords='0,0,80,60' shape='rect'/>\n";
#print "coords='3,2,89,2,90,22,53,22,55,39,29,56,2,44' shape='poly'/>\n";
print "<area alt='Mering homepage' href='http://www.imls.uzh.ch/research/vonmering.html' ";
print "coords='80,0,165,60' shape='rect'/>\n";
#print "coords='109,32,116,3,159,3,161,54,67,58,66,33' shape='poly'/>\n";
print "<area alt='SIB homepage' href='http://www.isb-sib.ch/' ";
print "coords='25,70,135,130' shape='rect'/>\n";
print "</map>\n";
print "</td>\n";
print "</tr>\n";

print "<tr>\n";
print "<td style='padding: 3px; white-space: nowrap;'>\n";
print "MLTreeMap uses orthology information from the ";
print "<a class='normal_reference' href='http://www.ncbi.nlm.nih.gov/COG/'>COG database</a> (<a class='normal_reference' ";
print "href='http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&amp;db=PubMed&amp;list_uids=12969510&amp;dopt=Abstract'>Ref</a>).\n";
print "</td></tr>\n";

print "<tr>\n";
print "<td style='padding: 3px; white-space: nowrap;'>\n";
print "Up-to-date genomes &amp; proteins are maintained at <a class='normal_reference' href='http://www.ncbi.nlm.nih.gov/refseq/'>";
print "Refseq</a>, <a class='normal_reference' href='http://www.ensembl.org/'>ENSEMBL</a>";
print " and <a class='normal_reference' href='http://string-db.org/'>STRING</a>.\n";
print "</td>\n";
print "</tr>\n";
print "<tr>\n";
print "<td style='padding: 3px;'>\n";
print "Maximum Likelihood is computed using the <a class='normal_reference' href='http://icwww.epfl.ch/~stamatak/index-Dateien/Page443.htm'>RAxML</a> software ";
print "(<a class='normal_reference' ";
print "href='http://www.ncbi.nlm.nih.gov/pubmed/16928733'>Ref</a>).";
print "</td>\n";
print "</tr>\n";
print "<tr>\n";
print "<td colspan='1' style='padding: 5px;'>\n";
print "&nbsp;<br/><b>What's New?</b> This is release 2.061 of MLTreeMap - <a class='normal_reference' href='/treemap_download/Version_history.pdf'>version history</a> ";
print "- the ";
print "<a class='normal_reference' href='mailto:mering\@imls.uzh.ch'>authors</a> welcome any suggestions or comments.";
print "</td>\n";
print "</tr>\n";
print "</table>\n";

print "</td>\n";
print "<td style=\"background:url('/treemap_images/additional_images/Info_box_right.png') right bottom; background-repeat:repeat-y; WIDTH: 15px;\">\n";
print "</td>\n";
print "</tr>\n";
print "<tr>\n";
print "<td colspan= '4' style=\"background:url('/treemap_images/additional_images/Info_box_bottom.png') no-repeat left top; HEIGHT: 19px;\">\n";
print "</td>\n";
print "</tr>\n";
print "<tr>";
print "<td colspan='4'>&nbsp;\n";
print "</td>\n";
#print "</table>";
print "</tr>\n";
print "</table>\n";
print "</form>\n";
print "</td>\n";
print "</tr>\n";
print "</table>\n";

## in case we have been provided a sequence through the CGI-interface, we echo it back to the user,
## but only after having cleaned it a bit.

if ($input->{sequence} ne "_unassigned") {
    $input->{sequence} = uc $input->{sequence};       ## upcase it ...
    $input->{sequence} =~ s/[^A-Z]//g;                ## remove non-letters and whitespace (including line-breaks) ...
    my $tmp = "";                                     ## ... and re-insert line-breaks every thirty characters.
    my $length = length $input->{sequence};
    for (my $pos = 0; $pos < $length; $pos += 30) {
	$tmp .= substr ($input->{sequence}, $pos, 30);
	$tmp .= "\n";
    }
    $input->{sequence} = $tmp;
}

print "<map name='submit_button_map' id='submit_button_map'><area alt='submit_button' coords='1,1,54,25' shape='rect' ";
print "href='/treemap_cgi/launch_treemap_job.pl' ";
print "lang='JavaScript' onclick='document.getElementById(\"input_form\").submit(); return false;'/></map>\n";
print "<map name='reset_button_map' id='reset_button_map'><area alt='reset_button' coords='1,1,60,25' shape='rect' ";
print "href='/treemap_cgi/treemap_input_page.pl' ";
print "lang='JavaScript' onclick='document.getElementById(\"input_form\").reset(); return false;'/></map>\n";
print "<map name='tasks_button_map' id='tasks_button_map'><area alt='reset_button' coords='1,1,160,25' shape='rect' ";
print "href='/treemap_cgi/show_submitted_jobs.pl?sessionId=$input->{sessionId}&amp;userId=$input->{userId}'/></map>\n";

## refill the input items in the current page. 
## We cannot do that earlier, because otherwise the Reset-button would not work. 

$input->{sequence} =~ s/\n/\\n/g;
$input->{sequence} =~ s/\r//g;

unless ($input->{sequence} eq "_unassigned") {
    print "<script type='text/javascript'>\n";  
    print "document.getElementById(\"input_form\").seed_sequence.value=\"$input->{sequence}\";\n";
    print "--></script>\n";
}

## print the invariant, closing parts of the page.

$nav->print_navigation_bottom;

## that's it.

exit;











