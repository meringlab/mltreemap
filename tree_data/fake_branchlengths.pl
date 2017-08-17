#! /usr/bin/perl -w

use strict;
use warnings;

open (TREE, "Aug25_N2_root.phy_phyml_tree_ohne_length.txt") or die "Can't find the tree file\n";

open (TREEOUT, "> Aug25_N2_root.phy_phyml_tree.txt");

while (<TREE>) {
    s/,/:0\.05,/g;
    s/\)/:0\.05\)/g;
    s/\;/:0\.05\;/g;
    print TREEOUT $_;
}
close TREE;
close TREEOUT;