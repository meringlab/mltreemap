#! /usr/bin/perl -w

############################################################################
## subcommand_executor.pl
##
##
############################################################################

use strict;
use warnings;

use Fcntl qw(:DEFAULT :flock);    # for file-locking.

use lib  '../lib';
use TREEMAP_globals;


## first, we need to check whether this script is in fact already running.
## in this case, we fail gracefully. To identify this instantiation of the
## script, we use a unique identifier that was passed as parameter 1.

my $unique_id = $ARGV[0] or die "ERROR: need unique process id !\n";
my $executable_path = $0; 
my @path_components = split /\//, $executable_path;
my $executable_name = pop @path_components;

my $instantiation_counter = 0;
my $output = `ps auxw | grep $unique_id`;
my @output = split /\n/, $output;
foreach my $line (@output) {
    next unless ($line =~ /$unique_id/);
    next unless ($line =~ /$executable_name/);
    $instantiation_counter++;    
}

if ($instantiation_counter > 1) {
    die "NOTE: executor script already running. not started. check \"ps auxw\"i!\n";
}

my $filename = $TREEMAP_globals::process_starter_file;   #

if (not -r $filename) {
    print STDERR "ERROR: file '$filename' does not exist !!\n";
    exit;
}

## this will loop forever and throw jobs as needed.

print STDERR "now entering eternal loop: successfully started.\n";
while (1) {

    sleep (1);
    sysopen (FH, "$filename", O_RDWR) or die "Can't open $filename\n";

    flock (FH, LOCK_EX);

    my @lines = <FH>;

    truncate (FH, 0);    ## truncate the file to zero.
    seek (FH, 0, 0);                 
    close FH;
    
    
    my $line = shift @lines;
    
    if (@lines) {
        sysopen (FH, "$filename", O_RDWR | O_APPEND) or die "Can't append to $filename\n";
        foreach my $line (@lines) {
            print FH $line;
        }
        close FH;  
    }
    
    next unless $line;
    
    chomp $line;
    my $command = $line;
        
    chdir($TREEMAP_globals::mltreemap_perl_dir);
    system ($command);
        
    $command =~ /\/data\/userdata\/(.+)_sequence/;
    my $taskId = $1;
        
    my $path = "$TREEMAP_globals::userdata_dir/$taskId/final_RAxML_outputs/";
    unless (opendir (PATH, "$path")) { warn "Error, your input directory ($path) does not exist!\n"; next; }
    my @files = readdir PATH;
    closedir (PATH);
    chdir($TREEMAP_globals::mltreemap_imagemaker_dir);
    my $mkdir_command = "mkdir $TREEMAP_globals::userdata_dir/$taskId/images";
    system ($mkdir_command);
      
    my $nr_of_files = 0;    
    foreach my $file (@files) {   
        if ($file =~ /((.).+)_RAxML_parsed.txt/) {
            my $filename_part = $1;
            my $denominator = $2;
            my $entire_filename = "$path$file";
            $nr_of_files++;
            my $imagemaker_out_dir = "$TREEMAP_globals::userdata_dir/$taskId/images/$filename_part/";
            my $imagemaker_command = "./mltreemap_imagemaker.pl -i $entire_filename -o $imagemaker_out_dir";
            system($imagemaker_command);
            
            #render the SVG images with inkscape
            print "prepare inkscape\n";
            my %inkscape_files = ();
            my %inkscape_commands = ();
            $inkscape_files{c}{infile} = "$imagemaker_out_dir$denominator"."_concatenated_RAxML_outputs.txt_image_circular.svg";
            $inkscape_files{c}{outfile}{"$imagemaker_out_dir$denominator"."_concatenated_RAxML_outputs.txt_image_circular.png"} = 1;
            $inkscape_files{c}{outfile}{"$imagemaker_out_dir$denominator"."_concatenated_RAxML_outputs.txt_image_circular.compact.png"} = 1;
            
            $inkscape_files{l}{infile} = "$imagemaker_out_dir$denominator"."_concatenated_RAxML_outputs.txt_image_straight.svg";
            $inkscape_files{l}{outfile}{"$imagemaker_out_dir$denominator"."_concatenated_RAxML_outputs.txt_image_straight.png"} = 1;
            $inkscape_files{l}{outfile}{"$imagemaker_out_dir$denominator"."_concatenated_RAxML_outputs.txt_image_straight.compact.png"} = 1;
            
            foreach my $image_form (sort {$a cmp $b} keys %inkscape_files) {
                my $infile = $inkscape_files{$image_form}{infile};
                foreach my $outfile (sort {$a cmp $b} keys %{$inkscape_files{$image_form}{outfile}}) {
                    my $dpi = 250;
                    $dpi = 75 if ($outfile =~ /compact.png\Z/);
                    my $inkscape_command = "../inkscape/inkscape -z $infile --export-dpi=$dpi --export-background=\"rgb(255,255,255)\" --export-png=$outfile > $outfile.inkscape.txt";
                    $inkscape_commands{$inkscape_command} = 1;   
                }    
            }
            foreach my $inkscape_command (sort {$a cmp $b} keys %inkscape_commands) {
                system ($inkscape_command);    
            } 
            #done       
        } else {
            next;    
        }
    }
    if (($nr_of_files > 1) || 1) { #do it always. It is slow, but easier to handle (should be improved somewhen)
        my $path2 = "$TREEMAP_globals::userdata_dir/$taskId/final_outputs/";
        my $imagemaker_out_dir = "$TREEMAP_globals::userdata_dir/$taskId/images/summary/";
        my $imagemaker_command2 = "./mltreemap_imagemaker.pl -i $path2 -o $TREEMAP_globals::userdata_dir/$taskId/images/summary/";
        system($imagemaker_command2);
        
        #render the SVG images with inkscape
        my %inkscape_files = ();
        unless (opendir (PATH, "$imagemaker_out_dir")) { warn "Error, your input directory ($imagemaker_out_dir) does not exist!\n"; next; }
        my @files = readdir PATH;
        closedir (PATH);
        foreach my $file (@files) {
            if ($file =~ /((.)_concatenated_RAxML_outputs.txt_image_(.+)).svg/) {
                my $filename_base = $1;
                my $denominator = $2;
                my $image_form = $3;
                $inkscape_files{$denominator}{$image_form}{infile} = "$imagemaker_out_dir$filename_base.svg";
                $inkscape_files{$denominator}{$image_form}{outfile}{"$imagemaker_out_dir$filename_base.png"} = 1;
                $inkscape_files{$denominator}{$image_form}{outfile}{"$imagemaker_out_dir$filename_base.compact.png"} = 1;
            }
        }       
        my %inkscape_commands = ();  
        foreach my $denominator (sort {$a cmp $b} keys %inkscape_files) {       
            foreach my $image_form (sort {$a cmp $b} keys %{$inkscape_files{$denominator}}) {
                my $infile = $inkscape_files{$denominator}{$image_form}{infile};
                foreach my $outfile (sort {$a cmp $b} keys %{$inkscape_files{$denominator}{$image_form}{outfile}}) {
                    my $dpi = 250;
                    $dpi = 75 if ($outfile =~ /compact.png\Z/);
                    my $inkscape_command = "../inkscape/inkscape -z $infile --export-dpi=$dpi --export-background=\"rgb(255,255,255)\" --export-png=$outfile > $outfile.inkscape.txt";
                    $inkscape_commands{$inkscape_command} = 1;   
                }    
            }
            foreach my $inkscape_command (sort {$a cmp $b} keys %inkscape_commands) {
                system ($inkscape_command);    
            } 
        }
        #done 
    }
    
    chdir($TREEMAP_globals::userdata_dir);
    my $tar_command = "tar cfvp $taskId.tar $taskId/";
    my $gzip_command = "gzip $taskId.tar";
    system ($tar_command);
    system ($gzip_command);
    print "done\n";
}
