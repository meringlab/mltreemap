package TREEMAP_globals;

## - this code copied from the STRING project - many lines may not make sense for TREEMAP - ##

############################################################################################################
## TREEMAP_globals.pm
##
## This routine defines global constants, parameters, colors, directories, etc ... for the TREEMAP project.
############################################################################################################

## first, we need to find out the current 'home'-directory of TREEMAP.
## this path is not hardcoded here, but set at runtime - relative to the calling scripts, which 
## are all located in the 'cgi_bin' or in the 'scripts' directory. This way, the whole source tree can
## reside in different parts of the filesystem, with no changes to the code needed whatsoever.

($treemap_root_dir) = $0 =~ /\A(.*)\/(cgi_bin|scripts)/;

unless ($treemap_root_dir) {   ## if the above failed, we are probably using the debugger,
                               ## or a script outside of the TREEMAP setup. 
                               ## in this case, we use the hardcoded path below.

    #$treemap_root_dir = "/local/titan1/manuels/treemap/";
}

## now set some directories (all relative to the root directory).

$userdata_dir = "$treemap_root_dir/data/userdata";
$userparams_dir = "$treemap_root_dir/data/userparams";
$access_dir = "$treemap_root_dir/access";
$bin_dir = "$treemap_root_dir/cgi_bin";
$html_dir = "$treemap_root_dir/html";
$download_dir = "$treemap_root_dir/download";
$protected_download_dir = "$treemap_root_dir/download_protected";
$treemap_images = "$treemap_root_dir/images";
$tree_data_dir = "$treemap_root_dir/tree_data";
$mltreemap_perl_dir = "$treemap_root_dir/mltreemap_perl";
$mltreemap_imagemaker_dir = "$treemap_root_dir/mltreemap_imagemaker";
$pleiades_dir_base = "/local/erisdb/www_mering/manuels/mltreemap_neu_tmp";

## webserver cgi dir path - allows for easy changes, especially during
## CVS development. This is not an actually existing directory, but an
## alias defined in the Apache configuration files.

$cgi_bin_dir = "/treemap_cgi";

## process-starter_file: used to run processes in the background. We want these to reside outside of apache/modperl,
## so we use a background daemon polling a file with commandlines.
## CVM: Is this a security problem ? The daemon is not running as root ... but has privileges in the STRING world.

$process_starter_file = "$treemap_root_dir/processes/__commandlines__";

## various version-numbers and adresses currently in use are listed below.
##
## (version numbers are needed to prevent certain files from being cached in the users' browser when
## STRING updates happen. Without versioning here, new code will meet old files (css/javascript/java), which 
## spells disaster).

$java_applet_version = "1_76";
$overlib_version = "4513";
$js_script_version = "6236";
$css_version = "7234";
$db_version_restricted_previous_download = "6_2";
$view_title_versioning = "44";

$treemap_documentation_html_file = "$html_dir/documentation.html";

## which genomes do we currently get from ENSEMBL ?

%ensembl_genome_organisms = (7227 => "Drosophila_melanogaster",
			     180454 => "Anopheles_gambiae",
			     7955 => "Danio_rerio",
			     31033 => "Fugu_rubripes",
			     10116 => "Rattus_norvegicus",
			     10090 => "Mus_musculus",
			     9606 => "Homo_sapiens",
			     9598 => "Pan_troglodytes",
			     9031 => "Gallus_gallus",
			     6239 => "Caenorhabditis_elegans",
			     6238 => "Caenorhabditis_briggsae");

## various color values

$webcolor_emphasis = "#A8A8DF";
$webcolor_standard_grey = "#E6E2E6";

$webcolor_light = "#EAECF4";
$webcolor_light_grey = "#F6F4F6";

## color values by manuels

$webcolor_grey = "#CCCCCC";

##

$evidence_transfer_bitscore_cutoff = 60;

## examples for the input page:

%input_examples = (1 => ["Farm_Soil_A", "Minnesota Farm Soil, Contig #28552", "29vdh9kqXnNA"],
		   2 => ["Farm_Soil_B", "Minnesota Farm Soil, Contig #31197", "NwORQfCGW1NG"],
		   3 => ["Ocean_Water_A", "Sargasso Sea Surface Water, Contig AACY01099717", "S2MCddv6e4qY"],
		   );

%input_sequences = (1 => ["seq1", "Whale Bone, off Santa Cruz, Read AGZO7495.g2",
			  "NNNTTTTTTTCCATGACAGACTGGCTGAGAACCTCCTGTGATGAACCGGCGTTGCGATATACGACAGCGAGCGAGGGCTGCTCGCGGATGCGCTCTTCAG\\n".
			  "TCAGATTGACCTGCACCGGGCATATGGTGGAGTGGTGCCGGAGCTGGCTTCGCGTGACCACGTCAAGCGGTTGGTGCCGTTGATGCGTGAAGTATTTGAT\\n".
			  "CAGGCTGGTCTACAGCCAGGCGAGGTCGATGGCGTGGTTTATACGGCTGGCCCGGGTCTGGTTGGGGCGCTGTTGGTTGGCGGCGCTTGTGCGCGCGCGC\\n".
			  "TGGCCTTTGCCTGGGGCGTGCCGGCGCTGGGCGTGCATCACATGGAAGGTCATCTGTTGGCCCCCATGCTGGAAGCGTCTCCTCCTGCGTTCCCTTTTGT\\n".
			  "CGCGCTGCTGGTGTCGGGTGGTCATACCCAACTGGTCCGGGTGGACGGCATTGGTGAGTATCAACTCTTGGGTGAATCGTTGGACGATGCCGCCGGTGAA\\n".
			  "GCCTTTGACAAGACCGCCAAGCTGATGGGGCTGCCTTACCCCGGTGGCCCCGAGATCGCTCGCCTGGCCGAAGAGGGCGAAGCCGGCGTCTTTGTTTTCC\\n".
			  "CGCGCCCCATGACGGACCGCCCCGGTCTGGATTTTAGTTTCAGTGGTTTGAAAACATCGGTGCTGAATGCCTGGCAGCGCTGCCAGCAGGAAGGGGAGGT\\n".
			  "CAGTCATCANGTGCAGGCCGATCTGGCGCTGGGGTTTGAAACTGCCTGTAGTGGAAACGCTGACCATCAAGTGTAAGCGCGCACTCAAGCAGACGGGGCT\\n".
			  "CAAGCGGCTGGTGATTGCTGGCGGTGTCAGTGCCAACCAGCGCCTGCGCGCTAACCTGGAAAAAATGACCGCTGGTCTGAAAGGCGAGGTGGTTTATGCA\\n".
			  "CGTCCCGCCTTCTGCACGGACAATGGGCCCCTGATTGCCTACGCCGGCTGTCACCGGTG"],
		    2 => ["seq2", "Acid Mine Drainage, Read XYG41370.g1", 
			  "NNNNCCATGGCTCGTACGCACAAGAANAAGGCGGAAAGAGGGGAAGGAGAGTTTAAGCGCATGACCCTTAGGATCCTTGAATTGCAGGATTATTACATTA\\n".
			  "AATTTTCAATAGATGGAATCGATTCAGGAATTGCCAACTCCATAAGGAGGACTCTGATCAACGATATCCCGAAACTTGCCATTGAAAAGGTCACATTCCA\\n".
			  "TCATGGCCAGATAAGGGATGGAGAGGGAAATGTCTATGATAGCTCCCTGCCTCTTTTTGATGAGATTGTCGCTCATCGTCTTGGACTGATTCCACTTGTC\\n".
			  "ACCGACCCAAAGATGAACTTCAGGAATGAATGCAGCTGCGGAGGTCAGGGATGTCCCCTGTGCACAATGACATATTCAATCAACAAGATCGGCCCGGCAA\\n".
			  "TGGTCACATCTGGAGATCTCCAGCCAGTGGGAAATCCGGAACTCGTTCCAGCAGACAGAAACATACCAATAGTGAAACTGGGACCAAAGCAGGCAATACT\\n".
			  "TGTGACAGCAGAGGCGATAATGGGAAGGGGTCGGGATCACACAAAATGGCAGGCGACATCTGGTGTTTCATATAAATATCACAGGGAACTCAGGATAACC\\n".
			  "AAAGCCGACTTCGAAAACTGGGAATTCTACAAGGAAAAATGCCCAAAAAGTGTGCTTTCAGAAGATTCAAAGCAGATCAGCTTCACCGACGATGACAGGT\\n".
			  "GCCCATGGATTTCACAGCTGCTGGACAGGCAGGGAGTGAAGATCATAGAGGATGACACAAATTTCATTTTCCAGTTTGAAACAGATGGTTCCTACAAGGC\\n".
			  "AATTGACGTTCTCCAGTACGCCATGAAGAGACTGCCGCAGAGGCTCAACACACTCCTGGACAGCCTTGTAACCCCAGACTGACCATAATATTATTTCATT\\n".
			  "ACCTTCCCATATGACATAATTATGAACGATTTTTTCAAGTCGCTTGACGCCCTTGAAAAGGATGTAATGGAAGGAATCAATCGCA"],
			3 => ["seq3", "Pyrococcus horikoshii, two reads", 
			  ">P. horikoshii part_read0\\n".
			  "GGGCTTTAGCCTCCTTCACCGCTTCCACGATTTTCTGCCTGTCAAAGGCCATTCTAGACATCCCTCCTTAGTTTTTATATTAAAAATTCAAGGGGGAGTA\\n".
			  "AAAGAGGATATTTTTAAACTTTTCCTCACTCCTTCTCGGCCTTCTCAAAAAGTTCGTCATAAACCCCCTCATCAATTTCCCTTTGTACAATCCTCGGATC\\n".
			  "CTTCCCTTCAACCGTAACCCCCATGCTTAAGGCCGTTCCAATGACCTCCTTAGCTGCCGCTTTTAATGTTAGTGCGAGCATTTGACTTCTCTTCATCTTG\\n".
			  "GCTATTTTTATAACCTGTTCCATGGTTAAGTTACCAACGATGTTGTGCTTAGGTTCTCCACTTCCCTTCTCAAGTCCAAGTTCCTTCTTTATCAACTGAC\\n".
			  "TCGTCGGTGGAACACCGACCTCAATTTCGAACTGCTTTGTTACTGGATCAACTATTATCTTCACTGGAACCTGCATTCCGGCGAATTCCTTAGTCGCTTC\\n".
			  "GTTTATCTTATCAACGACTTGCTTTACATTTAATCCAAGTGGTCCTATCGCGGGACCAAGAGGAGGACCGGGAGTTGCCTTTCCTCCCTCAACTAGAACC\\n".
			  "TCAACGACCTGCTTCTTCATTCCCTCTCACCTCATTCCTCCTTCTGACGCTTGCTTATAAGCCTAACGTATTCCCCTCTAACAGTTACTGGAATCGGTAC\\n".
			  "TATAGCTCCAATAAGCTCAACTACTATCTCATCCTTGCTTTCATCAACCCTAACAACCTTTGCCTTTTCACCCTTGAAGGGTCCAGAGATTAGTTCAACG\\n".
			  "ATATCTCCAGGTTCAAGGCCACTAACAGCAGGCTTCTCCTCGAGGAAATGTTCGATCTCGCTAAAGGGAATCTCTCCGGGTAAAACACCTCTCGCATGCC\\n".
			  ">P. horikoshii part_read84\\n".
			  "ATGATGGTGCTCCGCATGAAAGTTGAGTGGTATCTTGACTTCGTTGATCTAAACTATGAACCTGGAAGGGATGAGCTGATAGTGGAATACTACTTTGAGC\\n".
			  "CGAACGGTGTCTCCCCAGAGGAAGCCGCCGGTAGGATAGCCAGCGAGAGTTCTATTGGTACTTGGACAACACTCTGGAAGCTTCCGGAGATGGCGAAGAG\\n".
			  "GAGTATGGCTAAGGTTTTCTACTTAGAAAAACACGGGGAGGGATACATAGCTAAGATAGCCTACCCCCTAACTCTCTTCGAGGAGGGAAGCCTAGTTCAA\\n".
			  "TTGTTCAGTGCAGTAGCTGGAAACGTCTTTGGAATGAAGGCTTTGAAAAACCTAAGACTACTGGACTTCCATCCACCATATGAATACTTAAGGCACTTTA\\n".
			  "AAGGCCCCCAGTTTGGGGTTCAGGGAATAAGGGAGTTCATGGGCGTTAAGGACAGGCCATTAACGGCAACGGTTCCAAAGCCAAAGATGGGGTGGAGCGT\\n".
			  "TGAGGAATATGCTGAGATAGCTTACGAACTCTGGAGTGGTGGTATAGACCTTCTAAAGGATGATGAGAACTTCACGAGCTTTCCCTTCAACAGGTTTGAA\\n".
			  "GAGAGGGTCAGAAAGCTCTACAGGGTTAGGGATAGGGTTGAGGCCGAGACTGGGGAAACTAAGGAATATCTGATAAATATAACGGGCCCAGTTAACATTA\\n".
			  "TGGAGAAGAGAGCAGAGATGGTTGCCAATGAGGGAGGACAGTACGTGATGATAGATATAGTGGTGGCAGGATGGAGCGCCCTCCAGTATATGAGGGAAGT\\n".
			  "TACCGAAGATCTAGGCTTAGCAATACATGCCCACAGGGCTATGCATGCAGCTTTCACAAGGAACCCAAGGCATGGAATAACTATGCTAGCCTTGGCAAAG"],
		    );
