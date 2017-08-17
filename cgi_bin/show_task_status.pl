#! /usr/bin/perl -w

###################################################################################################
## show_task_status.pl
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
my $contig = $input->{contig};

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
print "<br/>&nbsp;<br/>\n";

my @header_widthes = (undef, 10, 25, 13, 34, 16);
my @header_names = (undef, "Input", "BLAST &amp; COG-mapping", "Genewise", "Maximum Likelihood Testing", "Visualization");
my @header_classes = ();
for (my $index = 1; $index <= 5; $index++) { 
    $header_classes[$index] = 'result_table_header_normal';
    $header_classes[$index] = 'result_table_header_selected' if $index eq $input->{status_page_type};
}

print "<table border='0' cellpadding='0' cellspacing='0' width='80%'>\n";

print "<tr><td style='width: 1\%;'>";
print "<div style=\"background:url('/treemap_images/result_box/tabbase.bottom.long.png') right bottom; background-repeat:repeat-x; margin:0px; padding:0px\"/>\n";
print "<div style=\"background:url('/treemap_images/result_box/tabbase.lowerleft.png') no-repeat left bottom; \"/>\n";
print "&nbsp;<br/>&nbsp;<br/>&nbsp;</td>";

for (my $index = 1; $index <= 5; $index++) { 
    my $url =  "show_task_status.pl?taskId=$input->{taskId}&amp;userId=$input->{userId}&amp;sessionId=$input->{sessionId}&amp;status_page_type=$index&amp;contig=$contig";
    $url .= "&amp;nru=1" if $input->{nru};
    
    if ($header_classes[$index] eq 'result_table_header_normal') {
        print "<td style='width: $header_widthes[$index]\%;'>";
        print "<div style=\"background:url('/treemap_images/result_box/tab.upper.png') right top; background-repeat:repeat-x; margin:0px; padding:0px\"/>\n";       
        print "<div style=\"background:url('/treemap_images/result_box/tab.upperright.png') no-repeat right top;\"/>\n";
        print "<div style=\"background:url('/treemap_images/result_box/tab.upperleft.png') no-repeat left top;\"/>\n"; 
        print "<div style=\"background:url('/treemap_images/result_box/tabbase.bottom.long.png') right bottom; background-repeat:repeat-x; margin:0px; padding:0px\"/>\n";      
        print "<div style=\"background:url('/treemap_images/result_box/tab.lowerright.png') no-repeat right bottom;\"/>\n";
        print "<div style=\"background:url('/treemap_images/result_box/tab.lowerleft.png') no-repeat left bottom;\"/>\n";       
        
        print "&nbsp;&nbsp;&nbsp;Step $index<br/>";
        print "&nbsp;&nbsp;&nbsp;<a class='blacknondecorated' href='$url'><b>$header_names[$index]</b></a><br/>&nbsp;";
        print "</td>";
    } else {
        print "<td>";
        print "<div style=\"background:url('/treemap_images/result_box/tabselected.upper.png') right top; background-repeat:repeat-x; margin:0px; padding:0px\"/>\n";
        print "<div style=\"background:url('/treemap_images/result_box/tabselected.upperright.png') no-repeat right top;\"/>\n";
        print "<div style=\"background:url('/treemap_images/result_box/tabselected.upperleft.png') no-repeat left top;\"/>\n";       
        print "<div style=\"background:url('/treemap_images/result_box/tabselected.lowerleft.png') no-repeat left bottom;\"/>\n";
        print "<div style=\"background:url('/treemap_images/result_box/tabselected.lowerright.png') no-repeat right bottom;\"/>\n";
                
        print "&nbsp;&nbsp;&nbsp;Step $index<br/>";
        print "&nbsp;&nbsp;&nbsp;<a class='blacknondecorated' href='$url'><b>$header_names[$index]</b></a><br/>&nbsp;";
        print "</td>";    
    }
}

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

my $job_id = $job_identifier;
&communicate_input($taskId, $navigation, $contig) if $input->{status_page_type} eq "1";
&communicate_blast_status ($taskId, $navigation, $contig) if $input->{status_page_type} eq "2";
&communicate_genewise_status ($taskId, $navigation, $contig) if $input->{status_page_type} eq "3";
&communicate_ml_status ($taskId, $navigation, $contig) if $input->{status_page_type} eq "4";
&communicate_visualization_status ($taskId, $navigation, $contig) if $input->{status_page_type} eq "5";

print "</td></tr></table>\n";

$navigation->print_navigation_bottom ();

exit;

####################################################################################################################################
## subroutine: communicate_input ()
##
####################################################################################################################################

sub communicate_input {

    my ($taskId, $navigation, $contig) = @_;
        
    my $contig_name_for_files = $contig;
    #note: the next two lines have to be kept the same as the ones in mltreemap.pl
    $contig_name_for_files =~ s/\s/_/g;
    $contig_name_for_files =~ s/\//_/g;
    my $sequence_input_file = "$TREEMAP_globals::userdata_dir/$taskId"."_sequence.txt";
    my $contig_sequence_file = "$TREEMAP_globals::userdata_dir/$taskId/various_outputs/$contig_name_for_files"."_sequence.txt";
    
    print "<table border='0' cellspacing='5' width='100\%'>";

    
    my $error_message = "</tr><tr><td>&nbsp;<br/>Sorry, I wasn't able to read the result file.<br/>&nbsp;<br/>It may have expired (results expire after about two weeks)";
    $error_message .= "<br/>&nbsp;<br/></td></tr>\n";
     
    print $error_message unless (-e $sequence_input_file);
	
    unless (-e $contig_sequence_file) {
        open (IN, "$sequence_input_file");
        open (OUT, "> $contig_sequence_file");
        my $do_print = 0;
        while (<IN>) {
            chomp $_;
            $do_print = 0 if (/\A>/);
            $do_print = 1 if (/\A$contig_name_for_files/);
            print OUT "$_\n" if ($do_print); 
        }
        close IN;
        close OUT;
        print "$error_message" unless (-e $contig_sequence_file);
    }
    
    print "<tr><td style='padding-right: 20px;' colspan='2'>Your input sequence is shown below:</td></tr>\n";         
    print "<tr><td colspan='2'><hr/></td></tr>\n";

    print "<tr><td style='white-space: nowrap;' valign='bottom' align='left'>";
    print "<a class='normal_reference' href='/treemap_userdata/$taskId/various_outputs/$contig_name_for_files";
    print "_sequence.txt'>download the sequence</a></td></tr>";

    my $lines_printed = 0;

    open (FH, "$contig_sequence_file") or return;

    print "<tr style=\"background-color:#FFFFFF\"><td colspan='2' style='font-family: monospace;'>";

    while (<FH>) {

	if ($lines_printed > 40) {
	    print "&nbsp;&nbsp;[...]&nbsp;&nbsp;<br/>\n";
	    last;
	}
	$lines_printed += 1;
 	chomp $_; 
	my $sequence = $_;
	my @sequence_chars = split //, $sequence;
	my $chars_printed = 0;
	foreach my $residue (@sequence_chars) {
	    print "$residue";
	    $chars_printed += 1;
#	    print "&nbsp;" unless $chars_printed % 10;
	    print "<br/>" unless $chars_printed % 80;
	}
	print "&nbsp;<br/>\n";
    }
    print "</td></tr>\n";
    
    print "</table>\n";
    return;
}

####################################################################################################################################
## subroutine: communicate_blast_results ()
##
####################################################################################################################################

sub communicate_blast_status {

    my ($taskId, $navigation, $contig) = @_;
    
    my $contig_name_for_files = $contig;
    #note: the next two lines have to be kept the same as the ones in mltreemap.pl
    $contig_name_for_files =~ s/\s/_/g;
    $contig_name_for_files =~ s/\//_/g;
    my $summary_file = "$TREEMAP_globals::userdata_dir/$taskId/various_outputs/$contig_name_for_files"."_blast_result_purified.txt";
    
    print "<table border='0' cellspacing='5'>";
    print "<tr><td style='padding-right: 20px;' colspan='2'>Your sequence has been searched against the clusters of orthologous genes (COGs) in the STRING ";
    print "database - in order to check for marker genes. Results are shown below:</td></tr>\n";
                
    my %functional_cogs = ("18srRNA" => 2, "16srRNA" => 3, COG1850 => 4, _K02586 => 5, _K02588 => 6, p_a_moA => 7, dsr_v2_ => 8, phocryp => 9, hzo_hao => 10, bssAref => 11, mcrAref => 12);
    my %nr_analysis = (1 => "Phylogenetic analysis", 2 => "rRNA analysis, 18s", 3 => "rRNA analysis, 16s", 4 => "Functional analysis, RuBisCO", 5 => "Functional analysis, nitrogenase (nifD)", 6 => "Functional analysis, nitrogenase (nifH)", 7 => "Functional analysis, methane monooxygenase" , 8 => "Functional analysis, dsrAB", 9 => "Functional analysis, Photolyase/Cryptochrome", 10 => "Functional analysis HZO/HAO", 11 => "Functional analysis, bssA",12 => "Functional analysis, mcrA");
            
    unless (-e "$summary_file") {
	   print "</tr><tr><td>&nbsp;<br/>Sorry, I wasn't able to read the result file.<br/>&nbsp;<br/>It may have expired (results expire after about two weeks)";
	   print "<br/>&nbsp;<br/></td></tr>\n";
    }
    
    my %blast_summary_file_content = ();
    open (FH, "$summary_file") or return;
    while (<FH>) {
        chomp;
        my (undef, undef, undef, undef, $orthgroup, undef) = split;
        if (exists $functional_cogs{$orthgroup}) {
            my $nr = $functional_cogs{$orthgroup};
            $blast_summary_file_content{$nr}{$_} = 1;
        } else {
            $blast_summary_file_content{1}{$_} = 1;
        }
    }
    
    foreach my $nr (sort {$a <=> $b} keys %blast_summary_file_content) {
    
        my $analysis = $nr_analysis{$nr};
    
        print "<tr><td colspan='2'><hr/></td></tr>\n";
        print "<tr><td style='padding-right: 20px;'><b>$analysis</b>:</td>";
    
        print "<td style='padding-left: 20px; white-space: nowrap;' valign='bottom' align='right'>";
        print "<a class='normal_reference' href='/treemap_userdata/$taskId/various_outputs/$contig_name_for_files";
        print "_blast_result_purified.txt'>download this result</a></td></tr>";

        print "<tr style=\"background-color:#FFFFFF\"><td colspan='2' style='font-family: monospace;'>";

        print "<table border='0' cellspacing='5'>";
        print "<tr>";
        print "<td style='text-align: center;'><i>start</i></td><td></td>";
        print "<td style='text-align: center;'><i>end</i></td><td></td>";
        print "<td style='text-align: center;'><i>orientation</i></td><td></td>";
        print "<td style='text-align: center;'><i>COG</i></td><td></td>";
        print "<td style='text-align: center;'><i>bitscore</i></td>";
        print "</tr>\n";
        print "<tr><td colspan='9'></td></tr>\n";

    
        my $lines_printed = 0;
        foreach my $line (sort {$a cmp $b} keys %{$blast_summary_file_content{$nr}}) {
            next unless $line;
            if ($lines_printed > 40) {
                print "<tr><td colspan='9'>&nbsp;&nbsp;[...]&nbsp;&nbsp;<br/></td></tr>\n";
                last;
            }
            my ($query, $start_position, $end_position, $orientation, $orthgroup, $bitscore) = split /\t/, $line;
            my $style = "style='text-align: center; color: red;'";
            print "<tr>";
            print "<td $style>$start_position</td><td></td>";
            print "<td $style>$end_position</td><td></td>";
            print "<td $style>$orientation</td><td></td>";
            print "<td $style>$orthgroup</td><td></td>";
            print "<td $style>$bitscore</td>";
            print "</tr>\n";
            $lines_printed += 1;
        }

        print "</table>\n";
        print "</td></tr>\n";
    
    }

    print "</table>\n";
    return;
}

####################################################################################################################################
## subroutine: communicate_genewise_status ()
##
####################################################################################################################################

sub communicate_genewise_status {

    my ($taskId, $navigation, $contig) = @_;
    
    my $contig_name_for_files = $contig;
    #note: the next two lines have to be kept the same as the ones in mltreemap.pl
    $contig_name_for_files =~ s/\s/_/g;
    $contig_name_for_files =~ s/\//_/g;
    my $summary_file = "$TREEMAP_globals::userdata_dir/$taskId/various_outputs/$contig"."_genewise_result_summary.txt";

    print "<table border='0' cellspacing='5'>";
    print "<tr><td style='padding-right: 20px;' colspan='2'>Your sequence has been searched against the clusters of orthologous genes (COGs) in the STRING ";
    print "database - in order to check for marker genes. Results are shown below:</td></tr>\n";
                
    my %functional_cogs = ("18srRNA" => 2, "16srRNA" => 3, COG1850 => 4, _K02586 => 5, _K02588 => 6, p_a_moA => 7, dsr_v2_ => 8, phocryp => 9, hzo_hao => 10, bssAref => 11, mcrAref => 12);
    my %nr_analysis = (1 => "Phylogenetic analysis", 2 => "rRNA analysis, 18s", 3 => "rRNA analysis, 16s", 4 => "Functional analysis, RuBisCO", 5 => "Functional analysis, nitrogenase (nifD)", 6 => "Functional analysis, nitrogenase (nifH)", 7 => "Functional analysis, methane monooxygenase" , 8 => "Functional analysis, dsrAB", 9 => "Functional analysis, Photolyase/Cryptochrome", 10 => "Functional analysis HZO/HAO", 11 => "Functional analysis, bssA",12 => "Functional analysis, mcrA");
            
    unless (-e "$summary_file") {
	   print "</tr><tr><td>&nbsp;<br/>Sorry, I wasn't able to read the result file.<br/>&nbsp;<br/>It may have expired (results expire after about two weeks)";
	   print "<br/>&nbsp;<br/></td></tr>\n";
    }
    
    my %genewise_summary_file_content = ();
    open (FH, "$summary_file") or return;
    while (<FH>) {
        chomp;
        my ($orthgroup, undef, undef, undef, undef) = split;
        if (exists $functional_cogs{$orthgroup}) {
            my $nr = $functional_cogs{$orthgroup};
            $genewise_summary_file_content{$nr}{$_} = 1;
        } else {
            $genewise_summary_file_content{1}{$_} = 1;
        }
    }
    
    foreach my $nr (sort {$a <=> $b} keys %genewise_summary_file_content) {
    
        my $analysis = $nr_analysis{$nr};
    
        print "<tr><td colspan='2'><hr/></td></tr>\n";
        print "<tr><td style='padding-right: 20px;'><b>$analysis</b>:</td>";
    
        print "<td style='padding-left: 20px; white-space: nowrap;' valign='bottom' align='right'>";
        print "<a class='normal_reference' href='/treemap_userdata/$taskId/various_outputs/$contig_name_for_files";
        print "_genewise_result_summary.txt'>download this result</a></td></tr>";

        print "<tr style=\"background-color:#FFFFFF\"><td colspan='2' style='font-family: monospace;'>";
    
        my $lines_printed = 0;
        foreach my $line (sort {$a cmp $b} keys %{$genewise_summary_file_content{$nr}}) {
            next unless $line;
            if ($lines_printed > 40) {
                print "&nbsp;&nbsp;[...]&nbsp;&nbsp;<br/>\n";
                last;
            }
            $lines_printed += 1;
            my ($orthgroup, $start_position, $end_position, $orientation, $peptide) = split /\t/, $line;
            print "&gt;peptide_$lines_printed ($orthgroup.$start_position.$end_position.$orientation)<br/>";
            my @peptide_chars = split //, $peptide;
            my $chars_printed = 0;
            foreach my $residue (@peptide_chars) {
                print "$residue";
                $chars_printed += 1;
                print "<br/>" unless $chars_printed % 80;
            }
            print "&nbsp;<br/>\n";
        }
        print "</td></tr>\n";
    }

    print "</table>\n";
    return;

}

####################################################################################################################################
## subroutine: communicate_ml_status ()
##
####################################################################################################################################

sub communicate_ml_status {

    my ($taskId, $navigation, $contig) = @_;
    
    my $contig_name_for_files = $contig;
    #note: the next two lines have to be kept the same as the ones in mltreemap.pl
    $contig_name_for_files =~ s/\s/_/g;
    $contig_name_for_files =~ s/\//_/g;

    print "<table border='0' cellspacing='5'>";
    print "<tr><td style='padding-right: 20px;' colspan='2'>Your sequence has been searched against the clusters of orthologous genes (COGs) in the STRING ";
    print "database - in order to check for marker genes. Results are shown below:</td></tr>\n";
                
    my %functional_cogs = ("18srRNA" => 2, "16srRNA" => 3, COG1850 => 4, _K02586 => 5, _K02588 => 6, p_a_moA => 7, dsr_v2_ => 8, phocryp => 9, hzo_hao => 10, bssAref => 11, mcrAref => 12);
    my %nr_analysis = (1 => "Phylogenetic analysis", 2 => "rRNA analysis, 18s", 3 => "rRNA analysis, 16s", 4 => "Functional analysis, RuBisCO", 5 => "Functional analysis, nitrogenase (nifD)", 6 => "Functional analysis, nitrogenase (nifH)", 7 => "Functional analysis, methane monooxygenase" , 8 => "Functional analysis, dsrAB", 9 => "Functional analysis, Photolyase/Cryptochrome", 10 => "Functional analysis HZO/HAO", 11 => "Functional analysis, bssA",12 => "Functional analysis, mcrA");
    my %funcs = (1 => "p", 2 => "b", 3 => "a", 4 => "r", 5 => "n", 6 => "h", 7 => "m", 8 => "d", 9 => "c", 10 => "e", 11 => "w", 12 => "y");
    
    foreach my $nr (sort {$a <=> $b} keys %nr_analysis) {

        my $func = $funcs{$nr};
        my $raxml_filename_base = "_$contig_name_for_files"."_RAxML_parsed.txt";
        my $analysis = $nr_analysis{$nr};
        
        my $summary_file = "$TREEMAP_globals::userdata_dir/$taskId/final_RAxML_outputs/$func$raxml_filename_base";

        unless (-e "$summary_file") {
            if (($func eq "p") && (-e "$TREEMAP_globals::userdata_dir/$taskId/final_RAxML_outputs/g$raxml_filename_base")) {
                $func = "g"; #i.e. we run the geba analysis...
                $summary_file = "$TREEMAP_globals::userdata_dir/$taskId/final_RAxML_outputs/$func$raxml_filename_base";  
            } else {
                next;
                #print "</tr><tr><td>&nbsp;<br/>Sorry, I wasn't able to read the result file.<br/>&nbsp;<br/>It may have expired (results expire after about two weeks)";
                #print "<br/>&nbsp;<br/></td></tr>\n";
            }
        }
        
        print "<tr><td colspan='2'><hr/></td></tr>\n";
        print "<tr><td style='padding-right: 20px;'><b>$analysis</b>:</td>";
    
        print "<td style='padding-left: 20px; white-space: nowrap;' valign='bottom' align='right'>";
        print "<a class='normal_reference' href='/treemap_userdata/$taskId/final_RAxML_outputs/$func$raxml_filename_base'>download entire file</a></td></tr>";
    
        my $lines_printed = 0;
        open (FH, "$summary_file") or return;
        my $style = "style='text-align: left;'";
    
        #print "<tr><td colspan='2' style='font-family: monospace;'>";
        print "<tr style=\"background-color:#FFFFFF\"><td colspan='2' $style>";
    
        while (<FH>) {

	       if ($lines_printed > 40) {
	           print "&nbsp;&nbsp;[...]&nbsp;&nbsp;<br/>\n";
	           last;
	       }
            s/\>/\&gt;/g;
            s/\</\&lt;/g;
            s/\</\&amp;/g;
            s/_/ /g;
            print;
            print "<br/>\n";
            $lines_printed += 1;
        }
        print "</td></tr>\n";
    }

    print "</table>\n";
    return;
    
}

####################################################################################################################################
## subroutine: communicate_visualization_status ()
##
####################################################################################################################################

sub communicate_visualization_status {

    my ($taskId, $navigation, $contig) = @_;

    my $contig_name_for_files = $contig;
    #note: the next two lines have to be kept the same as the ones in mltreemap.pl
    $contig_name_for_files =~ s/\s/_/g;
    $contig_name_for_files =~ s/\//_/g;
    
    print "<table border='0' cellspacing='5'>";
    print "<tr><td style='padding-right: 20px;'>The phylogenetic mapping can be visualized in the context of the reference phylogeny (which has been made ";
    print "from completely sequenced genomes). This is shown below; dark circles indicate the likely origin of your sequence (multiple circles ";
    print "indicate a weighted confidence range).</td></tr>\n";
    
    my %functional_cogs = ("18srRNA" => 2, "16srRNA" => 3, COG1850 => 4, _K02586 => 5, _K02588 => 6, p_a_moA => 7, dsr_v2_ => 8, phocryp => 9, hzo_hao => 10, bssAref => 11, mcrAref => 12);
    my %nr_analysis = (1 => "Phylogenetic analysis", 2 => "rRNA analysis, 18s", 3 => "rRNA analysis, 16s", 4 => "Functional analysis, RuBisCO", 5 => "Functional analysis, nitrogenase (nifD)", 6 => "Functional analysis, nitrogenase (nifH)", 7 => "Functional analysis, methane monooxygenase" , 8 => "Functional analysis, dsrAB", 9 => "Functional analysis, Photolyase/Cryptochrome", 10 => "Functional analysis HZO/HAO", 11 => "Functional analysis, bssA",12 => "Functional analysis, mcrA");
    my %funcs = (1 => "p", 2 => "b", 3 => "a", 4 => "r", 5 => "n", 6 => "h", 7 => "m", 8 => "d", 9 => "c", 10 => "e", 11 => "w", 12 => "y");
    my $size_of_funcs_hash = (keys %funcs) + 0;
    my $no_picture_available_yet = 1;
    
    foreach my $nr (sort {$a <=> $b} keys %nr_analysis) {
    
        my $func = $funcs{$nr};
        my $analysis = $nr_analysis{$nr};
        
        my $circular_file = "$TREEMAP_globals::userdata_dir/$taskId/images/$func"."_$contig_name_for_files/$func"."_concatenated_RAxML_outputs.txt_image_circular.png";
        
        if (-e "$circular_file") {
            $no_picture_available_yet = 0;
        } else {
            if (($func eq "p") && (-e "$TREEMAP_globals::userdata_dir/$taskId/images/g_$contig_name_for_files/g"."_concatenated_RAxML_outputs.txt_image_circular.png")) {
                $func = "g"; #i.e. we run the geba analysis...
                $no_picture_available_yet = 0;
                $circular_file = "$TREEMAP_globals::userdata_dir/$taskId/images/g_$contig_name_for_files/$func"."_concatenated_RAxML_outputs.txt_image_circular.png";  
            } else {
                if ($no_picture_available_yet && ($nr == $size_of_funcs_hash)) {
                    print "</tr><tr><td>&nbsp;<br/>Sorry, this task is currently still running on our server.<br/>&nbsp;<br/>Please return later.<br/>&nbsp;<br/>\n";
                    print "<form action='show_task_status.pl' method='get'><p>";
                    print "<input type='hidden' name='taskId' value='$taskId'/>";
                    print "<input type='hidden' name='sessionId' value='$input->{sessionId}'/>";
                    print "<input type='hidden' name='userId' value='$input->{userId}'/>";
                    print "<input type='hidden' name='status_page_type' value='$input->{status_page_type}'/>";
                    print "<input type='hidden' name='contig' value='$contig'/>";
                    print "<input type='submit' value='Refresh'/></p></form></td></tr>";
                }
                next;
            }
        }
          
        print "<tr><td colspan='2'><hr/></td></tr>\n";
        print "<tr><td style='padding-right: 20px;'><b>$analysis</b>:</td>"; 
        
        my $directory = "$TREEMAP_globals::userdata_dir/$taskId/images/$func"."_$contig_name_for_files/";
        my $directory_for_tag = "/treemap_userdata/$taskId/images/$func"."_$contig_name_for_files/";
        my $filename_common_part = "$func"."_concatenated_RAxML_outputs.txt_image_";
        my $circular_file_name_compact = "$filename_common_part"."circular.compact.png";
        my $circular_file_name = "$filename_common_part"."circular.png";;
        my $linear_file_name_compact = "$filename_common_part"."straight.compact.png";
        my $linear_file_name = "$filename_common_part"."straight.png";
   
    
        my $image_file_to_show = "$directory$circular_file_name_compact";
        my $image_tag_to_show = "<img alt='' src='$directory_for_tag$circular_file_name_compact' width='800' height='800'/>";
        my $image_type_switch_text = "non-circular image";
        my $image_type_switch_url = "show_task_status.pl?taskId=$taskId&amp;status_page_type=5&amp;sessionId=$input->{sessionId}&amp;userId=$input->{userId}&amp;contig=$contig";
        $image_type_switch_url .= "&amp;status_page_image_type=straight";
        $image_type_switch_url .= "&amp;nru=1" if $input->{nru};
    
        if ($input->{status_page_image_type} eq 'straight') {

            $image_file_to_show = "$directory$linear_file_name_compact";
            my $width = 800;
            my $height = 2880;
            #get the picture dimensions (the height is not constant, the more species, the longer the image...)
            open (IN, "$image_file_to_show.inkscape.txt");# or die "Error, the infofile $image_file_to_show.inkscape.txt cannot be opened!\n";
            while (<IN>) {
                chomp $_;
                if (/exported to (\d+) x (\d+) pixels/) {
                    $width = $1;
                    $height = $2    
                }
            }
            close IN;
            #done
            $image_tag_to_show = "<img alt='' src='$directory_for_tag$linear_file_name_compact' width='$width' height='$height'/>";
            $image_type_switch_text = "circular image";
            $image_type_switch_url = "show_task_status.pl?taskId=$taskId&amp;status_page_type=5&amp;sessionId=$input->{sessionId}&amp;userId=$input->{userId}&amp;contig=$contig";
            $image_type_switch_url .= "&amp;status_page_image_type=circular";
            $image_type_switch_url .= "&amp;nru=1" if $input->{nru};
        }


        unless (-e $image_file_to_show) {
            print "</tr><tr><td>&nbsp;<br/>Sorry, unable to read the image file.<br/>&nbsp;<br/>It may have expired (results expire after about two weeks)";
            print "<br/>&nbsp;<br/></td></tr>\n";
            next;
        }	

        print "</tr><tr><td><a class='normal_reference' href='$directory_for_tag/$filename_common_part$input->{status_page_image_type}.png'>";
        print "high&nbsp;resolution&nbsp;version</a><br/>";
        print "<a class='normal_reference' href='$image_type_switch_url'>$image_type_switch_text</a>";
        print "</td></tr>";

        my $lines_printed = 0;

        print "<tr><td colspan='2'>";

        print $image_tag_to_show;
        print "</td></tr>\n";
    }
    print "</table>\n";
    return;
}



