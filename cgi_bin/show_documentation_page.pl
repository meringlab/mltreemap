#! /usr/bin/perl -w

###################################################################################################
## show_documentation_page.pl
## 
##
###################################################################################################

use strict;
use warnings;

use lib '../lib';
use TREEMAP_navigation;                    ## used for a unified look-and-feel.
use TREEMAP_parse_userinput;               ## to parse the user-input coming from the CGI (stdin) ...

## allright, let's start: fetch the CGI parameters.

my $input = _parse_user_input ();            ## this returns a hash of parameter->value pairs (with save defaults when nothing was provided).
my $taskdata = $input->{taskdata};           ## an empty taskdata repository is also provided.

## this page is not connected to any specific task in particular, so we deactivate the saving of any task-related data:

$input->{taskdata}->set_data_dirty_flag (0);

## create the navigation object, which will output most of the actual html code ...

my $is_main_page = 0;
my $navigation = new TREEMAP_navigation ($input->{taskId}, $input->{sessionId}, $input->{userId},$is_main_page);
$navigation->set_active_main_menu_item ($input->{menu_call});

$navigation->print_navigation_top ();

print "<br/>&nbsp;<br/><table border='0'><tr><td align='left' style='text-align: justify;'>";

if (open (FH, $TREEMAP_globals::treemap_documentation_html_file)) {

    while (<FH>) {
	
	chomp;
	print;

    }

} else {

    print "[Sorry, cannot open the documentation file. Please try again later]\n";

}

print "</td></tr></table>\n";

$navigation->print_navigation_bottom ();
