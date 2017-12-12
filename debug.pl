#!/usr/bin/env perl

use strict ;
use warnings ;

#LIBS
use myLib qw(
    csvToMatrix
    matrixToHash
    mergeHashes
    hashToMatrix
    ); 
use Data::Dumper ;

my $CSV_PATH = "/home/apurv/OneDrive/Documents/fitbit/sample.csv" ; 
my $CSV_PATH_2 = "/home/apurv/OneDrive/Documents/fitbit/sample1.csv" ;
my $CSV_PATH_3 = "/home/apurv/OneDrive/Documents/fitbit/sample2.csv" ;

my $matrix_pointer = csvToMatrix($CSV_PATH) ;
print"matrix from csv:\n" ;
print Dumper($matrix_pointer) ;

my ($data_hash_pointer, $hierarchy_hash_pointer) = matrixToHash($matrix_pointer) ;
print"data and hierarchy hashes from matrix: \n" ;
print Dumper($data_hash_pointer) ;
print Dumper($hierarchy_hash_pointer) ;

my $matrix_pointer_2 = csvToMatrix($CSV_PATH_2) ;
print"matrix from csv:\n" ;
print Dumper($matrix_pointer_2) ;

my ($data_hash_pointer_2, $hierarchy_hash_pointer_2) = matrixToHash($matrix_pointer_2) ;
print"data and hierarchy hashes from matrix: \n" ;
print Dumper($data_hash_pointer_2) ;
print Dumper($hierarchy_hash_pointer_2) ;

my @data_hashes = ($data_hash_pointer, $data_hash_pointer_2) ;
my @hierarchy_hashes = ($hierarchy_hash_pointer, $hierarchy_hash_pointer_2) ;

#my ($merged_data_hash_pointer, $merged_hierarchy_hash_pointer) = mergeHashes(\@data_hashes, \@hierarchy_hashes) ;

my $matrix_pointer_3 = csvToMatrix($CSV_PATH_3) ;
print"matrix from csv:\n" ;
print Dumper($matrix_pointer_3) ;

my ($data_hash_pointer_3, $hierarchy_hash_pointer_3) = matrixToHash($matrix_pointer_3) ;
print"data and hierarchy hashes from matrix: \n" ;
print Dumper($data_hash_pointer_3) ;
print Dumper($hierarchy_hash_pointer_3) ;

my @data_hashes_2 = ($data_hash_pointer, $data_hash_pointer_3) ;
my @hierarchy_hashes_2 = ($hierarchy_hash_pointer, $hierarchy_hash_pointer_3) ;

my ($merged_data_hash_pointer, $merged_hierarchy_hash_pointer) = mergeHashes(\@data_hashes_2, \@hierarchy_hashes_2) ;
print Dumper($merged_data_hash_pointer) ;
print Dumper($merged_hierarchy_hash_pointer) ;

my $merged_matrix_pointer = hashToMatrix($merged_data_hash_pointer, $merged_hierarchy_hash_pointer) ;
print"merged matrix:\n" ;
print Dumper($merged_matrix_pointer) ;
