package TREEMAP_usersettings_repository;

##########################################################################################
## TREEMAP_usersettings_repository
##
## This module enables persistent storage of user-provided parameters and selections.
##
## Now, when working with real users, we found out that they often want to use several browser
## windows at once, and actually with *different* user-settings in each ... We made this 
## possible through a hierarchy of storage files: There is one, global, user-specific file
## which survives a long time, and is re-identified using cookies. Within a session, however,
## userdata can also be stored under a sessionId. For reading, the sessionId-storage has precedence
## over userId-storage - for writing, both are always written. We also need file-locking,
## because two browser windows can easily try to write to the same file at the same time.
##
## WARNING: when setting or retrieving data from this module, do exclusively use the 
##          'set_' and 'get_' routines. Otherwise, some heuristics for speed-improvements 
##          (dirty-flag) will backfire on you.
##
## NOTE: all default settings for user-parameters are specified here, go through this
##       module to get them and do not store them elsewhere.
##########################################################################################

use strict;
use warnings;

use lib '../lib';
use TREEMAP_globals;

use Storable qw(lock_store lock_nstore lock_retrieve);    ## to serialize Perl data-structures and store them in a file

#########################################################################################
## constructor.
##
## this just makes the object and sets all values to safe defaults. To fill the 
## object with data, use either the subroutine 'retrieve_data_from_storage', or 
## any of the 'set_XXX'-routines.
#########################################################################################

sub new {
  
    my ($that, $userId, $sessionId) = @_;
   
    unless ($userId) { die "TREEMAP_usersettings_repository must be initialised with a UserId\n"; }
    
    my $class = ref($that) || $that;                  ## this is Perl's pseudomagic for their fake
    my $self = {};                                    ## object model. 
    bless $self, $class;                      
    
    $self->{userId} = ($userId or "_nouser");
    $self->{sessionId} = ($sessionId or "_nosession");

    ## defaults (hopefully safe):

    $self->{submitted_tasks} = {};

    $self->{data_dirty} = 0;
    
    # that's it for construction purposes
    
    return $self;
}

###################################################################################################
## subroutine: insert_new_task ()
##
##
###################################################################################################

sub insert_new_task {

    my ($self, $taskId, $submit_time, $job_identifier) = @_;

    if (exists $self->{submitted_tasks}{$taskId}) {
	warn "WARNING: tried to insert task '$taskId' into usersetting-repository, but existed already !\n";
	return;
    }
    $self->{submitted_tasks}{$taskId} = [$submit_time, $job_identifier];

    $self->set_data_dirty_flag (1);
}

###################################################################################################
## subroutine: delete_stored_task ()
##
##
###################################################################################################

sub delete_stored_task {

    my ($self, $taskId) = @_;

    unless (exists $self->{submitted_tasks}{$taskId}) {
	warn "WARNING: tried to delete task '$taskId' from usersettings-repository, but did not exist there !\n";
	return;
    }

    delete $self->{submitted_tasks}{$taskId};
    
    $self->set_data_dirty_flag (1);
}


###################################################################################################
## retrieve_data_from_storage
## 
## This routine is called upon to revive everything we previously knew about the current user,
## but have forgotten because the CGI-mechanism allows no persistent storage between script
## calls. The function returns FALSE when unsuccessful, this could indicate that the parameters
## has expired (this happens after a few weeks), but the user still wants to re-access it (possibly  
## because he has bookmarked some results). If so, a message should be shown to them explaining that
## parameters (userIds) in general do expire...
###################################################################################################

sub retrieve_data_from_storage {

    my ($self) = @_;

    my $session_storage_file = "$TREEMAP_globals::userdata_dir/usersettings.$self->{sessionId}";
    my $user_storage_file = "$TREEMAP_globals::userparams_dir/usersettings.$self->{userId}";

    my $session_data = undef;               ## session data are 'per browser window' ...
    my $user_data = undef;                  ## ... user data are 'per browser cookie'.

    if (-e $session_storage_file) { $session_data = lock_retrieve ($session_storage_file); }
    if (-e $user_storage_file) { $user_data = lock_retrieve ($user_storage_file); }

    unless (defined $user_data) {             ## to prevent re-creation of an expired session.
	$self->set_data_dirty_flag (0);       ## (if dirty-flag is zero, will not write to disc upon destruction).
	return 0;
    }
    
    ## load all the data from the user repository ...

    $self->{submitted_tasks} = $user_data->{submitted_tasks} if exists $user_data->{submitted_tasks};
    
    ## and override some entries from the session repository (if desired).

    ## - none so far - (for the treemap project)

    return 1;
}


###################################################################################################
## set_data_dirty_flag
##
## use this routine to manipulate the 'dirty'-flag. This flag specifies whether the user has in
## fact changed any parameters just now, or whether we are accessing the parameters for read-only
## purposes. In the latter case we need not write to disk upon destruction, this saves execution
## time.
###################################################################################################

sub set_data_dirty_flag {

    my ($self, $flag) = @_;
    $self->{data_dirty} = $flag;
}


###################################################################################################
## destructor
##
## use as a safety-net in case we have not yet written the data to the disk ...
## scripts may also call 'write_data_to_disk' explicitly, in which case the dirty-flag will be 
## zero and nothing will happen here.
###################################################################################################

sub DESTROY {

    my ($self) = @_;

    return unless ($self->{data_dirty} == 1);

    $self->write_data_to_disk ();
}

###################################################################################################
## write_data_to_disk
##
## store all the relevant information in a small binary file on disk, and set dirty-flag to 0.
## NOTE: changing the spelling of variables will break the usage of pre-existing data, so 
##       be careful there. Adding stuff should be fine.
###################################################################################################

sub write_data_to_disk {

    my ($self) = @_;

    return unless ($self->{data_dirty} == 1);

    return if ($self->{userId} eq "_nouser");

    my %data;
    
    $data{submitted_tasks} = $self->{submitted_tasks};
    
    lock_store \%data, "$TREEMAP_globals::userparams_dir/usersettings.$self->{userId}" or die $!;
    
    $self->{data_dirty} = 0;

    return if ($self->{sessionId} eq "_nosession");

    lock_store \%data, "$TREEMAP_globals::userdata_dir/usersettings.$self->{sessionId}" or die $!;
}

1;

















