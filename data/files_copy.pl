#! /usr/bin/perl -w

use strict;
use warnings;

opendir (PATH, "userdata") or die "Error, this directory userdata does not exist!\n";
my @files = readdir PATH;
closedir (PATH);

foreach my $file (@files) {
    if ($file =~ /(.+)_sequence.txt/) {
        my $job_id = $1;
        unless (-e "/local/erisdb/www_mering/manuels/mltreemap_userdata_repository/$job_id"."_sequence.txt") {
            my $copy_command1 = "cp userdata/$file /local/erisdb/www_mering/manuels/mltreemap_userdata_repository/";
            my $mkdir_command = "mkdir /local/erisdb/www_mering/manuels/mltreemap_userdata_repository/$job_id";
            my $copy_command2 = "cp -r userdata/$job_id/final_outputs/ /local/erisdb/www_mering/manuels/mltreemap_userdata_repository/$job_id";
            system ($copy_command1);
            system ($mkdir_command);
            system ($copy_command2);
        }
    }
}