package TREEMAP_taskdata_repository;

## - this code has been copied from the STRING project - some lines may not make sense for TREEMAP - ##

############################################################################################
## TREEMAP_taskdata_repository.pm:
##
## this package implements a persistent storage for task-related data in the TREEMAP
## software-system. Persistent storage (on the hard-disk of the server) is needed because 
## TREEMAP is implemented using the CGI-mechanism ... so between CGI-calls, the server 
## actually forgets all its data.
##
## [in the TREEMAP project, very little is actually stored here. Most stuff is stored
##  in flatfiles - because the TREEMAP website grew out of a scripting-pipeline ... ]
##
## conceived by DJ, used and extended Mathilde and Nelly, and extensively re-designed by CvM.
############################################################################################

use strict;
use warnings;

use Storable qw(lock_store lock_retrieve);

use lib '../lib';
use TREEMAP_globals;

#########################################################################################
## constructor.
##
## this just makes the object and sets all task-related data to safe defaults. To fill the 
## object with data, use either of the subroutines 'generate_basic_data' or 
## 'retrieve_data_from_storage'.
#########################################################################################

sub new {
  
    my ($that, $taskId) = @_;
   
    unless ($taskId) { die "TREEMAP_taskdata_repository must be initialised with a task ID\n"; }
    
    my $class = ref($that) || $that;          ## this is Perl's pseudomagic for their fake
    my $self = {};                            ## object model. 
    bless $self, $class;                      
    
    $self->{taskId} = ($taskId or "_notask");
    $self->{sessionId} = "_nosession";
    $self->{userId} = "_nouser";
    
    ## defaults (hopefully safe):

    $self->{no_marker_genes_in_query_sequence} = 0;

    $self->{need_phylo_data} = 1;                          ## these are flags on whether specific parts still remain to be computed
    $self->{need_coexpression_data} = 1;                   ## (improves speed: most stuff is only loaded on demand).
    $self->{need_datasets_data_experimental} = 1;
    $self->{need_datasets_data_database_import} = 1;
    $self->{need_abstracts_data} = 1;
    $self->{targetmode} = 'proteins';
    $self->{active_evidence_channels} = { channel1 => "on",
					  channel2 => "on",
					  channel3 => "on",
					  channel4 => "on",
					  channel5 => "on",
					  channel6 => "on",
					  channel7 => "on" };

    $self->{direct_neighbor} = 1; 
    $self->{textmining_direct_neighbor} = 1; 
    $self->{network_depth} = 1;
    $self->{network_coordinates} = undef;
    $self->{use_java} = "no";
    $self->{interpretation_view} = "no";
    $self->{additional_network_nodes} = 0;
    $self->{limit} = 10;
    $self->{required_score} = $TREEMAP_globals::medium_confidence;
    $self->{high_conf_fac} = 80;    
    $self->{node1} = "_unassigned";
    $self->{node2} = "_unassigned";
    $self->{selected_coexpr_item_1} = "first";
    $self->{selected_coexpr_item_2} = "first";
    $self->{NEIGH_collapse_info_nodes} = "first";
    $self->{PHYLO_collapse_info_nodes} = "first";
    $self->{FUSION_collapse_info_nodes} = "first";
    $self->{NEIGH_propor_gene_sizes} = "n";
    $self->{FUSION_propor_gene_sizes} = "n";
    $self->{NEIGH_zoom} = "0.03";
    $self->{FUSION_zoom} = "0.03";
    $self->{launch_blast} = undef;
    $self->{seed_sequence_crc} = "_not_set_yet_";
    $self->{query_species_taxon} = "_unassigned";
    $self->{selected_species} = undef;
    $self->{buttons_string} = "neigh_fus_phylo_micro_exp_database_textmining_network";

    $self->{visibility_flags}{textmining}{show_all_direct} = "off";
    $self->{visibility_flags}{textmining}{show_all_transferred} = "off";

    $self->{data_dirty} = 1;
    
    
    # that's it for construction purposes
    
    return $self;
}


######################################################################################################
## destructor.
##
## upon destruction at the latest, this object will write itself to disk - if it's status is 'dirty'.
## scripts may also call 'write_data_to_disk' explicitly anytime.
######################################################################################################

sub DESTROY {

    my ($self) = @_;

    return unless ($self->{data_dirty} == 1);

    $self->write_data_to_disk ();
}

###################################################################################################
## subroutine write_data_to_disk:
## 
## this is the routine which actually implements the persistence of the task/session data.
## NOTE: changing the spelling of variables will break the usage of pre-existing data, so 
##       be careful there. Adding stuff should be fine.
###################################################################################################

sub write_data_to_disk {

    my ($self) = @_;

    return unless ($self->{data_dirty} == 1);

    my $data;
    
    $data->{no_marker_genes_in_query_sequence} = $self->{no_marker_genes_in_query_sequence};
    $data->{nodes} = $self->{nodes};
    $data->{edges} = $self->{edges};
    $data->{targetmode} = $self->{targetmode};
    $data->{active_evidence_channels} = $self->{active_evidence_channels};
    $data->{sessionId} = $self->{sessionId};
    $data->{userId} = $self->{userId};
    $data->{visibility_flags} = $self->{visibility_flags};
    $data->{query_items} = $self->{query_items};
    $data->{seed_sequence} = $self->{seed_sequence};
    $data->{seed_sequence_crc} = $self->{seed_sequence_crc};
    $data->{query_species_taxon} = $self->{query_species_taxon};
    $data->{required_score} = $self->{required_score};
    $data->{network_depth} = $self->{network_depth};
    $data->{use_java} = $self->{use_java};
    $data->{interpretation_view} = $self->{interpretation_view};
    $data->{additional_network_nodes} = $self->{additional_network_nodes};
    $data->{network_coordinates} = $self->{network_coordinates};
    $data->{taskId} = $self->{taskId};
    $data->{species} = $self->{species};
    $data->{need_phylo_data} = $self->{need_phylo_data};
    $data->{need_coexpression_data} = $self->{need_coexpression_data};
    $data->{need_datasets_data_experimental} = $self->{need_datasets_data_experimental};
    $data->{need_datasets_data_database_import} = $self->{need_datasets_data_database_import};
    $data->{need_abstracts_data} = $self->{need_abstracts_data};
    $data->{node1} = $self->{node1};
    $data->{node2} = $self->{node2};    
    $data->{selected_coexpr_item_1} = $self->{selected_coexpr_item_1};
    $data->{selected_coexpr_item_2} = $self->{selected_coexpr_item_2};
    $data->{fusions} = $self->{fusions};
    $data->{coexpression} = $self->{coexpression};
    $data->{experiments} = $self->{experiments};
    $data->{database_sets_database_import} = $self->{database_sets_database_import};
    $data->{database_sets_experimental} = $self->{database_sets_experimental};
    $data->{abstracts_data} = $self->{abstracts_data};
    $data->{limit} = $self->{limit};
    $data->{direct_neighbor} = $self->{direct_neighbor};
    $data->{textmining_direct_neighbor} = $self->{textmining_direct_neighbor};
    $data->{high_conf_fac} = $self->{high_conf_fac};
    $data->{selected_species} = $self->{selected_species};
    $data->{NEIGH_collapse_info_nodes} = $self->{NEIGH_collapse_info_nodes};
    $data->{PHYLO_collapse_info_nodes} = $self->{PHYLO_collapse_info_nodes};
    $data->{FUSION_collapse_info_nodes} = $self->{FUSION_collapse_info_nodes};
    $data->{launch_blast} = $self->{launch_blast};
    $data->{NEIGH_propor_gene_sizes} = $self->{NEIGH_propor_gene_sizes};
    $data->{FUSION_propor_gene_sizes} = $self->{FUSION_propor_gene_sizes};
    $data->{NEIGH_zoom}  = $self->{NEIGH_zoom};
    $data->{FUSION_zoom} = $self->{FUSION_zoom};
    $data->{buttons_string} = $self->{buttons_string};
    
    lock_store $data,"$TREEMAP_globals::userdata_dir/taskdata_$self->{taskId}" or die $!;
    
    $self->{data_dirty} = 0;
    
}

###################################################################################################
## retrieve_data_from_storage
## 
## This routine is called upon to revive everything we previously knew about the current task,
## but have forgotten because the CGI-mechanism allows no persistent storage between script
## calls. The function returns FALSE when unsuccessful, this could indicate that the task
## has expired (happens after a few days), but the user still wants to re-access it (possibly  
## because he has bookmarked some results). If so, a message should be shown to him explaining that
## results (tasks) in general do expire...
###################################################################################################

sub retrieve_data_from_storage {

    my ($self) = @_;
    return 0 unless (exists $self->{taskId});
    return 0 unless ($self->{taskId});

    my $storage_file = "$TREEMAP_globals::userdata_dir/taskdata_$self->{taskId}";
    unless (-e $storage_file) {
	$self->set_data_dirty_flag (0);    ## to prevent re-creation of an expired session.
	return 0;                          ## (if dirty-flag is zero, will not write to disc upon destruction).
    }
    
    my $data =  lock_retrieve ($storage_file);
    unless ($data) {
	$self->set_data_dirty_flag (0);    
	return 0;
    }
    
    $self->{no_marker_genes_in_query_sequence} = $data->{no_marker_genes_in_query_sequence};
    $self->{nodes} = $data->{nodes};
    $self->{edges} = $data->{edges};
    $self->{targetmode} = $data->{targetmode};
    $self->{active_evidence_channels} = $data->{active_evidence_channels};
    $self->{sessionId} = $data->{sessionId};
    $self->{userId} = $data->{userId};
    $self->{visibility_flags} = $data->{visibility_flags};
    $self->{query_items} = $data->{query_items};
    $self->{seed_sequence} = $data->{seed_sequence};
    $self->{seed_sequence_crc} = $data->{seed_sequence_crc};
    $self->{query_species_taxon} = $data->{query_species_taxon};
    $self->{required_score} = $data->{required_score};
    $self->{network_depth} = $data->{network_depth};
    $self->{use_java} = $data->{use_java};
    $self->{interpretation_view} = $data->{interpretation_view};
    $self->{additional_network_nodes} = $data->{additional_network_nodes};
    $self->{network_coordinates} = $data->{network_coordinates};
    $self->{species} = $data->{species};
    $self->{need_phylo_data} = $data->{need_phylo_data};
    $self->{need_coexpression_data} = $data->{need_coexpression_data};
    $self->{need_datasets_data_experimental} = $data->{need_datasets_data_experimental};
    $self->{need_datasets_data_database_import} = $data->{need_datasets_data_database_import};
    $self->{need_abstracts_data} = $data->{need_abstracts_data};
    $self->{node1} = $data->{node1};
    $self->{node2} = $data->{node2};
    $self->{selected_coexpr_item_1} = $data->{selected_coexpr_item_1};
    $self->{selected_coexpr_item_2} = $data->{selected_coexpr_item_2};
    $self->{fusions} = $data->{fusions};
    $self->{coexpression} = $data->{coexpression};
    $self->{experiments} = $data->{experiments};
    $self->{database_sets_database_import} = $data->{database_sets_database_import};
    $self->{database_sets_experimental} = $data->{database_sets_experimental};
    $self->{abstracts_data} = $data->{abstracts_data};
    $self->{limit} = $data->{limit};
    $self->{direct_neighbor} = $data->{direct_neighbor};
    $self->{textmining_direct_neighbor} = $data->{textmining_direct_neighbor};
    $self->{high_conf_fac} = $data->{high_conf_fac};
    $self->{selected_species} = $data->{selected_species};
    $self->{NEIGH_collapse_info_nodes} = $data->{NEIGH_collapse_info_nodes};
    $self->{PHYLO_collapse_info_nodes} = $data->{PHYLO_collapse_info_nodes};
    $self->{FUSION_collapse_info_nodes} = $data->{FUSION_collapse_info_nodes};
    $self->{launch_blast} =$data->{launch_blast};
    $self->{NEIGH_propor_gene_sizes} = $data->{NEIGH_propor_gene_sizes};
    $self->{FUSION_propor_gene_sizes} = $data->{FUSION_propor_gene_sizes};
    $self->{NEIGH_zoom} = $data->{NEIGH_zoom};
    $self->{FUSION_zoom} = $data->{FUSION_zoom};
    $self->{buttons_string} = $data->{buttons_string};

    $self->set_data_dirty_flag (0);

    return 1;
}

##################################################################################################
## subroutine generate_basic_data():
##
## this routine will collect and retrieve primary predictions and annotations for one or
## several input-items (used for both STRING operation modes, 'proteins' and 'cogs').
## This routine is only called after the user-input has been checked relatively thouroughly, so
## any remaining problems/errors will fail silently (this module has no means of communicating
## with the user).
##################################################################################################

sub generate_basic_data {

    my ($self, $sessionId, $userId, $targetmode, $query_items, $required_score, 
	$limit, $network_depth, $additional_network_nodes, $active_evidence_channels) = @_;
    
    $self->{sessionId} = $sessionId;
    $self->{userId} = $userId;
    $self->{targetmode} = $targetmode;
    $self->{active_evidence_channels} = $active_evidence_channels;
    $self->{query_items} = $query_items;
    $self->{required_score} = $required_score;
    $self->{limit} = $limit;
    $self->{network_depth} = $network_depth;
    $self->{additional_network_nodes} = $additional_network_nodes;
    
    return 1;
}


###################################################################################################
## subroutines get_... ()
##
## various small subroutines for users of this modules to retrieve aspects of the data.
###################################################################################################

sub get_colors {

    # returns the colors of an input list of nodes
    
    my ($self, $nodes) = @_;  
    my $colors = {};
    
    foreach my $node (@$nodes) {
	$colors->{$node} = 0xffffff;   ## default is white
	$colors->{$node} = $self->{nodes}->{$node}->{color} if (exists $self->{nodes}->{$node});
	$colors->{$node} = 0xffffff if $colors->{$node} eq "white";
    }

    ## now for a special case:
    ## if both interest_nodes are set, and both are outside the normal nodes, 
    ## we assign two different shades of grey to them - for the sake of 
    ## being able to discriminate them in the various viewers.

    if ($self->{node2} ne "_unassigned") {
	unless (exists $colors->{$self->{node2}}) {
	    if ($self->{node1} ne "_unassigned") {
		unless (exists $colors->{$self->{node1}}) {
		    my @sorted_nodes = sort { $a cmp $b } ($self->{node2}, $self->{node1});
		    $colors->{$sorted_nodes[0]} = 0xB3B3B3;
		    $colors->{$sorted_nodes[1]} = 0xE2E2E2;
		}
	    }
	}
    }

    return $colors;
}

sub get_query_items { 
    
    my ($self) = @_;
    return $self->{query_items};
}

sub get_network_depth {

    my ($self) = @_;
    return $self->{network_depth};
}

sub get_required_score {

    my ($self) = @_;
    return $self->{required_score};
}

sub get_limit {

    my ($self) = @_;
    return $self->{limit};
}

###################################################################################################
## subroutine: get_annotations ()
###################################################################################################

sub get_annotations {

    # returns the annotations for either an edge
    # or a node - if you want nodes, pass it a list of nodes
    # if you want edges, pass two list: one of start nodes, the other
    # of end nodes
    
    my $edge_or_node = 'edge';
    my $self = shift;
    my $cogs1 = shift or die "must be passed cogs in get_annotations\n";
    my $cogs2 = shift or $edge_or_node = 'node';
    my $annotations = {};
    
    if ($edge_or_node =~ /node/){
	# nodes are easy - just loop through them
	foreach my $node (@{$cogs1}) {
	    die "$node does not exist in this network!" unless exists $self->{nodes}->{$node};
	    @{$annotations->{$node}} = @{$self->{nodes}->{$node}->{annotation}};
	}
    } elsif ($edge_or_node =~ /edge/) {
	# get the numkber of edges for the loop and check consistency
	my $n_edges = $cogs2;
	if ($n_edges != $cogs1) { die "mismatched edge node list"; }
	# now loop through each edge - checking both possible edge keys
	for(my $i = 0; $i < $n_edges; $i++) {
	    my $key = "$cogs1->[$i]$cogs2->[$i]";
	    my $alt_key = "$cogs2->[$i]$cogs1->[$i]";
	    if(exists($self->{edges}->{$key})) {
		$annotations->{$key} = $self->{edges}->{$key}->{annotation};
	    } elsif(exists($self->{edges}->{$alt_key})) {
		$annotations->{$alt_key} = $self->{edges}->{$alt_key}->{annotation};
	    } 
	}
    } 
    
    return $annotations;
}

########################################################
## subroutine: get_orders ()
##
##
########################################################

sub get_orders {
  
    # returns the display-order for a list of nodes
    
    my ($self, $nodes) = @_;
    
    my $order = {};
    
    return $order unless ($nodes);

    foreach my $node (@$nodes) {	
	next unless exists $self->{nodes}->{$node};
	$order->{$node} = $self->{nodes}->{$node}->{order};
    }
    
    return $order;
}

###################################################################################################
## subroutine: get_nodes ()
##
## subroutine to return list of nodes in the network
## subject to certain criteria
## can either return all nodes - "all"
## those directly linked (i.e. network depth of 1) - "linked"
## input orthgroups - "input"
## or a specified range of network depths - "range" followed by 1 or two numbers
## DEFAULT is all
###################################################################################################

sub get_nodes {
    
    my ($self, $query_type, $range_low, $range_high) = @_;
    
    $query_type = 'all' unless ($query_type);
    $range_low = 0 unless ($range_low);
    $range_high = 1000 unless ($range_high);

    my $nodes = [];    
    
    if ($query_type =~ /all/) {

	foreach my $node (keys %{$self->{nodes}}) {
	    push @$nodes, $node;
	}

    } elsif ($query_type =~ /input/) {

	foreach my $node (keys %{$self->{nodes}}) {
	    if ($self->{nodes}->{$node}->{depth} == 0) {
		push @$nodes, $node;
	    }
	}

    } elsif ($query_type =~ /linked/) {

	foreach my $node (keys %{$self->{nodes}}) {
	    if($self->{nodes}->{$node}->{depth} == 1) {
		push @$nodes, $node;
	    }
	}

    } elsif ($query_type =~ /range/) {

	foreach my $node (keys %{$self->{nodes}}) {
	    if ($self->{nodes}->{$node}->{depth} >= $range_low) {
		if ($self->{nodes}->{$node}->{depth} <= $range_high) {
		    push @$nodes, $node;
		    
		}
	    }	
	} 		  

    } else {

	die "invalid input to get_nodes - must be either 'all','linked','input' or 'range', was '$query_type'.";
    }	
        
    return $nodes;
}

###################################################################################################
## subroutines: get_[x]scores ()
##
## several routines of this type return scores for a bunch of nodes.
###################################################################################################

sub get_nscores {
 
    my ($self, $nodes) = @_;
    my $nscores = {};
    foreach my $node (@$nodes) {
	next unless exists $self->{nodes}->{$node};
	if ($self->{nodes}->{$node}->{depth} == 1) {
	    $nscores->{$node} = $self->{nodes}->{$node}->{nscore};
	}
    }
    return $nscores;
}

sub get_fscores {

    my ($self, $nodes) = @_;
    my $fscores = {};
    foreach my $node (@$nodes) {
	next unless exists $self->{nodes}->{$node};
	if ($self->{nodes}->{$node}->{depth} == 1) {
	    $fscores->{$node} = $self->{nodes}->{$node}->{fscore};
	}
    }
    return $fscores;
}

sub get_pscores {
    
    my ($self, $nodes) = @_;
    my $pscores = {};
    foreach my $node (@$nodes) {
	next unless exists $self->{nodes}->{$node};
	if ($self->{nodes}->{$node}->{depth} == 1) {
	    $pscores->{$node} = $self->{nodes}->{$node}->{pscore};
	}
    }
    return $pscores;
}

sub get_hscores {
    
    my ($self, $nodes) = @_;
    my $hscores = {};
    return $hscores if $self->{targetmode} eq "cogs";       ## no hscores in cog-mode !
    foreach my $node (@$nodes) {
	next unless exists $self->{nodes}->{$node};
	if ($self->{nodes}->{$node}->{depth} == 1) {
	    $hscores->{$node} = $self->{nodes}->{$node}->{hscore};
	}
    }
    return $hscores;
}

sub get_ascores {
    
    my ($self, $nodes) = @_;
    my $ascores = {};
    foreach my $node (@$nodes) {
	next unless exists $self->{nodes}->{$node};
	if ($self->{nodes}->{$node}->{depth} == 1) {
	    $ascores->{$node} = $self->{nodes}->{$node}->{ascore};
	}
    }
    return $ascores;
}

sub get_escores {
    
    my ($self, $nodes) = @_;
    my $escores = {};
    foreach my $node (@$nodes) {
	next unless exists $self->{nodes}->{$node};
	if ($self->{nodes}->{$node}->{depth} == 1) {
	    $escores->{$node} = $self->{nodes}->{$node}->{escore};
	}
    }
    return $escores;
}

sub get_dscores {
    
    my ($self, $nodes) = @_;
    my $dscores = {};
    foreach my $node (@$nodes) {
	next unless exists $self->{nodes}->{$node};
	if ($self->{nodes}->{$node}->{depth} == 1) {
	    $dscores->{$node} = $self->{nodes}->{$node}->{dscore};
	}
    }
    return $dscores;
}

sub get_tscores {
    
    my ($self, $nodes) = @_;
    my $tscores = {};
    foreach my $node (@$nodes) {
	next unless exists $self->{nodes}->{$node};
	if ($self->{nodes}->{$node}->{depth} == 1) {
	    $tscores->{$node} = $self->{nodes}->{$node}->{tscore};
	}
    }
    return $tscores;
}

sub get_closest_input_nodes {

    my ($self, $nodes) = @_;
    my $closest_input_nodes = {};
    foreach my $node (@$nodes) {
	next unless exists $self->{nodes}->{$node};
	if ($self->{nodes}->{$node}->{depth} == 1) {
	    $closest_input_nodes->{$node} = $self->{nodes}->{$node}->{closest_input_node};
	}
    }
    return $closest_input_nodes;
}

sub get_scores {
  
    my ($self, $nodes) = @_;    
    my $scores = {};
    foreach my $node (@$nodes) {
	next unless exists $self->{nodes}->{$node};
	if($self->{nodes}->{$node}->{depth} == 1) {
	    $scores->{$node} = $self->{nodes}->{$node}->{score};
	}
    }
    return $scores;
}

sub get_active_evidence_channels {
    
    my ($self) = @_;
    return $self->{active_evidence_channels};
}


###################################################################################################
###################################################################################################
###################################################################################################

sub query_node {

    ## return data about a node

    my ($self, $node_name) = @_;
    
    my ($label) = ($self->{nodes}->{$node_name}->{preferred_name} or $node_name);

    return ($label);
}

sub query_edge {
	
    # return data about an edge

    my ($self, $edge_name) = @_;
    my ($node1, $node2, $score, $nscore, $fscore, $pscore, $hscore, $ascore, $escore, $dscore, $tscore, $physscore) = 
	("-", "-", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);

    return undef unless (exists $self->{edges}->{$edge_name});

    my $edge = $self->{edges}->{$edge_name};

    $node1 = $edge->{start};
    $node2 = $edge->{end};
    $score = $edge->{score};

    $nscore = $edge->{nscore};
    $fscore = $edge->{fscore};
    $pscore = $edge->{pscore};
    $hscore = $edge->{hscore};
    $ascore = $edge->{ascore};
    $escore = $edge->{escore};
    $dscore = $edge->{dscore};
    $tscore = $edge->{tscore};
    $physscore = $edge->{physscore};

    return ($node1, $node2, $score, $nscore, $fscore, $pscore, $hscore, $ascore, $escore, $dscore, $tscore, $physscore);
}

###################################################################################################
###################################################################################################
###################################################################################################

sub get_edges {

    my $self = shift;
    my $query_type = shift; $query_type = 'all' unless ($query_type);
    
    my $edges = [];
    
    if($query_type =~ /all/) {
	foreach my $edge (keys %{$self->{edges}}) {
	    push @$edges, $edge;
	}
    }
    
    return $edges;
}

###################################################################################################
## subroutine: generate_phylo_data
###################################################################################################

sub generate_phylo_data {

    my $self = shift;
}

###################################################################################################
## subroutine: get_phylo_data ()
###################################################################################################

sub get_phylo_data {
    
    
    # subroutine returns a list of present species and a hash of a hash containing
    # the species for a given COG
    # input is a list of cogs
    
    my $self = shift;
    my $cogs = shift or die "must be passed cogs in get_phylo_data";
    
    #	print "Starting get phylo data<br>";
    
    my $species = {};
    my $present_species = ();
    
    
    # check if we need to get the data
    if($self->{need_phylo_data}) {
	#		print "Need new data from database<br>";
	$self->generate_phylo_data();
    }
    
    # give the present species
    foreach my $beast (keys %{$self->{species}}) {
	push @{$present_species}, $beast;
    }
    
    # and the cog specific ones
    foreach my $cog (@{$cogs}) {
	die unless exists $self->{nodes}->{$cog};
	foreach my $beast (keys %{$self->{nodes}->{$cog}->{species}}) {
	    $species->{$cog}->{$beast} = 1;
	}
    }
    
    # all done
    
    return ($present_species, $species);    
}

###################################################################################################
## subroutine: generate_coexpression_data ()
###################################################################################################

sub generate_coexpression_data {

    my ($self, $input_nodes, $linked_nodes, $interest_node1, $interest_node2) = @_;
}

###################################################################################################
## subroutine: generate_coexpression_data_proteins ()
###################################################################################################

sub generate_coexpression_data_proteins {
    
    my ($self, $input_nodes, $linked_nodes, $interest_node1, $interest_node2) = @_;
}

###################################################################################################
## subroutine: generate_coexpression_data_cogs ()
##
##
###################################################################################################

sub generate_coexpression_data_cogs { 
    
    my ($self, $input_nodes, $linked_nodes, $interest_node1, $interest_node2) = @_;
}

####################################################################################################
## subroutine: generate_abstracts_data ()
####################################################################################################

sub generate_abstracts_data {

    my ($self, $input_nodes, $linked_nodes, $direct_neighbor, $interest_node1, $interest_node2) = @_;

}

####################################################################################################
## subroutine: generate_abstracts_data_cogs ()
####################################################################################################

sub generate_abstracts_data_cogs {

    my ($self, $input_nodes, $linked_nodes, $direct_neighbor, $interest_node1, $interest_node2) = @_;
}

####################################################################################################
## subroutine: generate_abstracts_data_proteins ()
####################################################################################################

sub generate_abstracts_data_proteins {

    my ($self, $input_nodes, $linked_nodes, $direct_neighbor, $interest_node1, $interest_node2) = @_;
}

####################################################################################################
## subroutine: generate_datasets_data ()
####################################################################################################

sub generate_datasets_data {
    
    my ($self, $input_nodes, $linked_nodes, $interest_node1, $interest_node2, $data_channel) = @_;
}

####################################################################################################
## subroutine: generate_datasets_data_cogs ()
####################################################################################################

sub generate_datasets_data_cogs {

    my ($self, $input_nodes, $linked_nodes, $interest_node1, $interest_node2, $data_channel) = @_;
}

####################################################################################################
## subroutine: generate_datasets_data_proteins ()
####################################################################################################

sub generate_datasets_data_proteins {

    my ($self, $input_nodes, $linked_nodes, $interest_node1, $interest_node2, $data_channel) = @_;
}

###################################################################################################
## subroutine: get_coexpression_data ()
###################################################################################################

sub get_coexpression_data {

    my ($self, $input_nodes, $linked_nodes, $interest_node1, $interest_node2) = @_;
    
    ## if no interest nodes where provided we can use the standard data (which may have been pre-stored).
    ##
    ## if, on the other hand, interest-nodes are provided we have to create the data de novo.

    my $use_standard_data = 1;
    
    if ($interest_node2) {
	$use_standard_data = 0 unless $interest_node2 eq "_unassigned"; 
    }
    if ($interest_node1) {
	$use_standard_data = 0 unless $interest_node1 eq "_unassigned";
    }

    if ($use_standard_data) {

	if ($self->{need_coexpression_data}) {
	    my $data = $self->generate_coexpression_data ($input_nodes, $linked_nodes, undef, undef);
	    if ($data) {
		$self->{coexpression} = $data;
		$self->{need_coexpression_data} = 0;
		$self->set_data_dirty_flag (1);
	    }		
	}
	return undef unless (exists $self->{coexpression});
	return $self->{coexpression};
    
    } else {

	return $self->generate_coexpression_data ($input_nodes, $linked_nodes, $interest_node1, $interest_node2);
    }
}

####################################################################################################
## subroutine: get_datasets_data ()
##
####################################################################################################

sub get_datasets_data {

    my ($self, $input_nodes, $linked_nodes, $interest_node1, $interest_node2, $data_channel) = @_;

    ## if no interest nodes where provided we can use the standard data (which may have been pre-stored).
    ##
    ## if, on the other hand, interest-nodes are provided we have to create the data de novo.

    my $use_standard_data = 1;
    
    if ($interest_node2) {
	$use_standard_data = 0 unless $interest_node2 eq "_unassigned"; 
    }
    if ($interest_node1) {
	$use_standard_data = 0 unless $interest_node1 eq "_unassigned";
    }

    if ($use_standard_data) {

	if ($self->{"need_datasets_data_$data_channel"}) {
	    my $data = $self->generate_datasets_data ($input_nodes, $linked_nodes, undef, undef, $data_channel);
	    if ($data) {
		$self->{"database_sets_$data_channel"} = $data;
		$self->{"need_datasets_data_$data_channel"} = 0;
		$self->set_data_dirty_flag (1);
	    }		
	}
	return undef unless (exists $self->{"database_sets_$data_channel"});
	return $self->{"database_sets_$data_channel"};
    
    } else {

	return $self->generate_datasets_data ($input_nodes, $linked_nodes, $interest_node1, $interest_node2, $data_channel);
    }
}

####################################################################################################
## subroutine: get_pubmed_abstracts ()
####################################################################################################

sub get_pubmed_abstracts {

    my ($self, $input_nodes, $linked_nodes, $direct_neighbor, $interest_node1, $interest_node2) = @_;

    ## if no interest nodes where provided we can use the standard data (which may have been pre-stored).
    ##
    ## if, on the other hand, interest-nodes are provided we have to create the data de novo.

    my $use_standard_data = 1;
    
    if ($interest_node2) {
	$use_standard_data = 0 unless $interest_node2 eq "_unassigned"; 
    }
    if ($interest_node1) {
	$use_standard_data = 0 unless $interest_node1 eq "_unassigned";
    }

    if ($use_standard_data) {

	if ($self->{need_abstracts_data}) {
	    my $data = $self->generate_abstracts_data ($input_nodes, $linked_nodes, $direct_neighbor, undef, undef);
	    if ($data) {
		$self->{abstracts_data} = $data;
		$self->{need_abstracts_data} = 0;
		$self->set_data_dirty_flag (1);
	    }		
	}
	return undef unless (exists $self->{abstracts_data});
	return $self->{abstracts_data};
    
    } else {

	return $self->generate_abstracts_data ($input_nodes, $linked_nodes, $direct_neighbor, $interest_node1, $interest_node2);
    }
}

#########################################################################################################
## subroutine: set_network_coordinates ()
##
#########################################################################################################

sub set_network_coordinates {

    my ($self, $coordinates) = @_;

    $self->{network_coordinates} = $coordinates;
    $self->set_data_dirty_flag (1);
}

#########################################################################################################
## subroutine: get_network_coordinates ()
##
#########################################################################################################

sub get_network_coordinates {
    
    my ($self) = @_;
    
    return $self->{network_coordinates};
}

###################################################################################################
## subroutine: get_species_selected_by user ()
##
## CvM: This routine still needed / in use ?
###################################################################################################

sub get_species_selected_by_user {

    my $self = shift;
    return $self->{selected_species};
}


###################################################################################################
## subroutine: set_data_dirty_flag ()
###################################################################################################

sub set_data_dirty_flag {

    my ($self, $flag) = @_;
    $self->{data_dirty} = $flag;
}




1;

















