#! /usr/bin/perl -w

###################################################################################################
## show_download_page.pl
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

print "<br/>&nbsp;<br/>";
print "<table border='0'>";
print "<tr><td colspan='4' align='left'><b>A) Phylogenetic Marker Genes</b><br/>&nbsp;<br/>";
print "MLTreeMap uses a selected set of 40 protein-coding marker genes, deemed to be the most phylogenetically informative. ";
print "<br/>For these, hand-curated alignments are available:</td></tr>";

print "<tr><td colspan='4'>&nbsp;</td></tr>\n";

print "<tr>";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0012.fa'>COG0012.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0016.fa'>COG0016.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0018.fa'>COG0018.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0048.fa'>COG0048.fa</a></td>\n";
print "</tr><tr>";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0049.fa'>COG0049.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0052.fa'>COG0052.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0080.fa'>COG0080.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0081.fa'>COG0081.fa</a></td>\n";
print "</tr><tr>";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0085.fa'>COG0085.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0087.fa'>COG0087.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0088.fa'>COG0088.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0090.fa'>COG0090.fa</a></td>\n";
print "</tr><tr>";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0091.fa'>COG0091.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0092.fa'>COG0092.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0093.fa'>COG0093.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0094.fa'>COG0094.fa</a></td>\n";
print "</tr><tr>";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0096.fa'>COG0096.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0097.fa'>COG0097.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0098.fa'>COG0098.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0099.fa'>COG0099.fa</a></td>\n";
print "</tr><tr>";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0100.fa'>COG0100.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0102.fa'>COG0102.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0103.fa'>COG0103.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0124.fa'>COG0124.fa</a></td>\n";
print "</tr><tr>";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0172.fa'>COG0172.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0184.fa'>COG0184.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0185.fa'>COG0185.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0186.fa'>COG0186.fa</a></td>\n";
print "</tr><tr>";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0197.fa'>COG0197.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0200.fa'>COG0200.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0201.fa'>COG0201.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0202.fa'>COG0202.fa</a></td>\n";
print "</tr><tr>";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0215.fa'>COG0215.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0256.fa'>COG0256.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0495.fa'>COG0495.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0522.fa'>COG0522.fa</a></td>\n";
print "</tr><tr>";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0525.fa'>COG0525.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0533.fa'>COG0533.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0541.fa'>COG0541.fa</a></td>\n";
print "<td style='padding: 3px;'><a class='normal_reference' href='/treemap_download/COG0552.fa'>COG0552.fa</a></td>\n";
print "</tr>";

print "<tr><td colspan='4'>&nbsp;</td></tr>";
print "<tr><td colspan='4'>&nbsp;</td></tr>";

print "<tr><td colspan='4' align='left'><b>B) Reference Phylogeny</b><br/>&nbsp;<br/>";
print "MLTreeMap can be based on any reference phylogeny of completely sequenced genomes. <br/>";
print "We currently use an extended tree-of-life phylogeny based on the phlyogeny shown below (Ciccarelli et. al., Science 2006):</td></tr>";
print "<tr><td colspan='4'>&nbsp;</td></tr>\n";
print "<tr><td colspan='4'>";

print "<table border='0'>";

print "<tr><td align='left' valign='top'><img src='/treemap_download/tree_Feb15_72dpi.gif' alt='' width='499' height='469'/></td>\n";
print "<td align='left'>tree-of-life reference phylogeny:<br/>\n";
print "<a class='normal_reference' href='/treemap_download/tree_of_life_circular.png'>tree_of_life_circular.png</a>\n";
print "<br/>&nbsp;<br/>rRNA based reference phylogeny:<br/>\n";
print "<a class='normal_reference' href='/treemap_download/rRNA_circular.png'>rRNA_circular.png</a>\n";
print "<br/>&nbsp;<br/>fungi reference phylogeny:<br/>\n";
print "<a class='normal_reference' href='/treemap_download/fungi_circular.png'>fungi_circular.png</a>\n";
print "<br/>&nbsp;<br/>RuBisCo family phylogeny:<br/>\n";
print "<a class='normal_reference' href='/treemap_download/RuBisCo_circular.png'>RuBisCo_circular.png</a>\n";
print "<br/>&nbsp;<br/>Nitrogenase (nifH) family phylogeny:<br/>\n";
print "<a class='normal_reference' href='/treemap_download/nifH_circular.png'>nifH_circular.png</a>\n";
print "<br/>&nbsp;<br/>Nitrogenase (nifD) family phylogeny:<br/>\n";
print "<a class='normal_reference' href='/treemap_download/nifD_circular.png'>nifD_circular.png</a>\n";
print "<br/>&nbsp;<br/>Methane monooxygenase family phylogeny:<br/>\n";
print "<a class='normal_reference' href='/treemap_download/MMO_circular.png'>MMO_circular.png</a>\n";
print "<br/>&nbsp;<br/>HZO/HAO family phylogeny:<br/>\n";
print "<a class='normal_reference' href='/treemap_download/hzo_hao_circular.png'>hzo_hao_circular.png</a>\n";
print "<br/>&nbsp;<br/>dsrAB family phylogeny:<br/>\n";
print "<a class='normal_reference' href='/treemap_download/dsrAB_circular.png'>dsrAB_circular.png</a>\n";
print "<br/>&nbsp;<br/>photolyase/cryptochrome family phylogeny:<br/>\n";
print "<a class='normal_reference' href='/treemap_download/phocryp_circular.png'>phocryp_circular.png</a>\n";
print "<br/>&nbsp;<br/>pufM family phylogeny:<br/>\n";
print "<a class='normal_reference' href='/treemap_download/pufM_circular.png'>pufM_circular.png</a>\n";

print "<br/>&nbsp;<br/>Supplementary info for the tree-of-life reference phylogeny:\n";
print "<br/>&nbsp;<br/>tree data in Newick format:<br/>\n";
print "<a class='normal_reference' href='/treemap_download/tree_of_life.txt'>tree_of_life.txt</a>\n";
print "<br/>&nbsp;<br/>underlying protein alignment (Phylip format):<br/>\n";
print "<a class='normal_reference' href='/treemap_download/tree_of_life.phy'>tree_of_life.phy</a>\n";
print "</td></tr>\n";
print "<tr><td colspan='2' align='left'>(C) Science Magazine, 2006</td></tr>\n";

print "</table>\n";

print "</td></tr>";

print "<tr><td colspan='4'>&nbsp;</td></tr>";
print "<tr><td colspan='4'>&nbsp;</td></tr>";
print "<tr><td colspan='4' align='left'><b>C) Stand-alone MLTreeMap</b><br/>&nbsp;<br/>";
print "The pipeline of MLTreeMap can be downloaded and installed individually:</td></tr>\n";
print "<tr><td colspan='4' align='left'>";

print "<br/>&nbsp;<br/>Version history:<br/>\n";
print "<a class='normal_reference' href='/treemap_download/Version_history.pdf'>Version_history.pdf</a>\n";
print "<br/>&nbsp;<br/>The MLTreeMap stand-alone package:<br/>\n";
print "<a class='normal_reference' href='/treemap_download/MLTreeMap_package_2_061.tar.gz'>MLTreeMap_package_2_061.tar.gz</a>\n";
print "<br/>&nbsp;<br/>A guide to the installation and usage of MLTreeMap:<br/>\n";
print "<a class='normal_reference' href='/treemap_download/MLTreeMap_guide_2_061.pdf'>MLTreeMap_guide_2_061.pdf</a>\n";
print "<br/>&nbsp;<br/>The MLTreeMap imagemaker:<br/>\n";
print "<a class='normal_reference' href='/treemap_download/MLTreeMap_imagemaker_2_061.tar.gz'>MLTreeMap_imagemaker_2_061.tar.gz</a>\n";
print "<br/>&nbsp;<br/>A guide to the installation and usage of the MLTreeMap imagemaker:<br/>\n";
print "<a class='normal_reference' href='/treemap_download/MLTreeMap_imagemaker_guide_2_061.pdf'>MLTreeMap_imagemaker_guide_2_061.pdf</a>\n";
print "<br/>&nbsp;<br/>A guide to adding new reference phylogenies to MLTreeMap:<br/>\n";
print "<a class='normal_reference' href='/treemap_download/Addon_guide.pdf'>Addon_guide.pdf</a>\n";

print "<br/>&nbsp;<br/>Previous_versions:\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_package_2_06.tar.gz'>MLTreeMap_package_2_06.tar.gz</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_package_2_051.tar.gz'>MLTreeMap_package_2_051.tar.gz</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_package_2_05.tar.gz'>MLTreeMap_package_2_05.tar.gz</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_package_2_04.tar.gz'>MLTreeMap_package_2_04.tar.gz</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_package_2_034.tar.gz'>MLTreeMap_package_2_034.tar.gz</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_package_2_032.tar.gz'>MLTreeMap_package_2_032.tar.gz</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_package_2_031.tar.gz'>MLTreeMap_package_2_031.tar.gz</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_package_2_03.tar.gz'>MLTreeMap_package_2_03.tar.gz</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_package_2.011.tar.gz'>MLTreeMap_package_2.011.tar.gz</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_package_2.01.tar.gz'>MLTreeMap_package_2.01.tar.gz</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_guide_2_06.pdf'>MLTreeMap_guide_2_06.pdf</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_guide_2_05.pdf'>MLTreeMap_guide_2_051.pdf</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_guide_2_05.pdf'>MLTreeMap_guide_2_05.pdf</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_guide_2_04.pdf'>MLTreeMap_guide_2_04.pdf</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_guide_2_034.pdf'>MLTreeMap_guide_2_034.pdf</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_guide_2_032.pdf'>MLTreeMap_guide_2_032.pdf</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_guide_2_031.pdf'>MLTreeMap_guide_2_031.pdf</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_guide.pdf'>MLTreeMap_guide.pdf</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_imagemaker_2_06.tar.gz'>MLTreeMap_imagemaker_2_06.tar.gz</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_imagemaker_2_051.tar.gz'>MLTreeMap_imagemaker_2_051.tar.gz</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_imagemaker_2_05.tar.gz'>MLTreeMap_imagemaker_2_05.tar.gz</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_imagemaker_2_04.tar.gz'>MLTreeMap_imagemaker_2_04.tar.gz</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_imagemaker_2_032.tar.gz'>MLTreeMap_imagemaker_2_032.tar.gz</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_imagemaker_2_03.tar.gz'>MLTreeMap_imagemaker_2_03.tar.gz</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_imagemaker.tar.gz'>MLTreeMap_imagemaker.tar.gz</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_imagemaker_guide_2_06.pdf'>MLTreeMap_imagemaker_guide_2_06.pdf</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_imagemaker_guide_2_051.pdf'>MLTreeMap_imagemaker_guide_2_051.pdf</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_imagemaker_guide_2_05.pdf'>MLTreeMap_imagemaker_guide_2_05.pdf</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_imagemaker_guide_2_04.pdf'>MLTreeMap_imagemaker_guide_2_04.pdf</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_imagemaker_guide_2_032.pdf'>MLTreeMap_imagemaker_guide_2_032.pdf</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_imagemaker_guide_2_03.pdf'>MLTreeMap_imagemaker_guide_2_03.pdf</a>\n";
print "<br/><a class='normal_reference' href='/treemap_download/MLTreeMap_imagemaker_guide.pdf'>MLTreeMap_imagemaker_guide.pdf</a>\n";

print "</td></tr>\n";
print "</table>\n";

$navigation->print_navigation_bottom ();

