#!/usr/bin/env perl
#some helper functions

package myLib ;
use Exporter 'import' ;
@EXPORT_OK = qw(
    matrixToHash
    hashToMatrix
    csvToMatrix
    readFile
    mergeHashes
    matrixToCsv
    writeFile
    detectAnomalies
    leastSquaresLinearFit
) ;
use Data::Dumper ;

use strict;
use warnings;

my $SHOW_DEBUG = 1 ;



sub matrixToHash {
#converts matrix of arbitrary layers to data hash. Returns data hash and order 
#hash stores. Order hash keys record hierarchy level number, each key points to
#headings of that hierarchy. Assumes that first element of each row is defined 
#if it's a row without headings

    
    my $matrix_in_pointer = $_[0] ;
    my @matrix_in = @{$matrix_in_pointer} ;
    
    my @rows ;
    my @elements ;
    my %temp_hash ;
    my %hierarchy_hash;
    my %data_hash ;
    
    my $row_counter = 0 ;
    my $column_counter = 0 ;
    my $flag = 0 ; 
    my $hierarchy_counter = 1 ;
    my $dat_start_row ;
    my $heading ;
    my $data ;

    my @headings ;

    foreach my $row (@{$matrix_in_pointer}) {
#        my @headings ;
        my @elements = @{$row} ;
        if ($elements[0] ne "") {
#            my @headings ;
            if ($flag == 0 ) {
                $dat_start_row = $row_counter ;
                $flag = 1 ;
            }
            foreach my $element (@elements) {
                if ($column_counter == 0) {
                    $heading = $element ;
                    push(@headings , $heading) ;
                }
                else {
                    $data = $element ;
                    if ($dat_start_row == 1) {
                        $data_hash{$heading}{$matrix_in[0][$column_counter]} = $data ;      
                    }
                    elsif ($dat_start_row == 2) {
                        $data_hash{$heading}{$matrix_in[0][$column_counter]}{$matrix_in[1][$column_counter]} = $data ;
                    }
                    elsif ($dat_start_row == 3){
                        $data_hash{$heading}{$matrix_in[0][$column_counter]}{$matrix_in[1][$column_counter]}{$matrix_in[2][$column_counter]} = $data ;
                    }
                    elsif ($dat_start_row == 4){
                        $data_hash{$heading}{$matrix_in[0][$column_counter]}{$matrix_in[1][$column_counter]}{$matrix_in[2][$column_counter]}{$matrix_in[3][$column_counter]} = $data ;
                    }
                }
                $column_counter ++ ;
            }
            $hierarchy_hash{0} = \@headings ;
#            @headings = () ;
        }
        elsif ($elements[0] eq "") {
            my @headings ;
            foreach my $element (@elements) {
                if ($element ne "") {
#                    if ($temp_hash{$element} != 1 || !-e $temp_hash{$element}) 
                    if (!$temp_hash{$element}) {
            print"i got here bitch\n" ;

                        $temp_hash{$element} = 1 ;
                        push(@headings , $element) ;
                        print"element: $element \n" ;
                    }
                    
                }
            }
            $hierarchy_hash{$hierarchy_counter} = \@headings ; 
#            @headings = () ;
            $hierarchy_counter ++ ;
        }
        $row_counter ++ ;
        $column_counter = 0 ;
        if($SHOW_DEBUG) { print"matrixtohash headings:\n" ; print Dumper(\@headings) ; }
    }
    return(\%data_hash, \%hierarchy_hash) ; 
}
#
sub hashToMatrix {
#takes in data hash and hierarchy hash, converts to matrix

    my $data_hash_pointer = $_[0] ; 
    my $hierarchy_hash_pointer = $_[1] ; 

    my %data_hash = %{$data_hash_pointer} ;
    my %hierarchy_hash = %{$hierarchy_hash_pointer} ;

    my @levels ;
    my @matrix ;
    
    foreach my $level (keys %{$hierarchy_hash_pointer}) {
        push(@levels , $level) ;
    }

    @levels = sort(@levels) ;


    my $layers = $levels[-1] ;

    for (my $i = 0; $i < $layers; $i++) {
        $matrix[$i][0] = "" ;
    }
    
    if ($layers == 1) {
        foreach my $layer_1_heading (@{$hierarchy_hash{1}}) {
            push(@{$matrix[0]} , $layer_1_heading) ;
        }
        foreach my $layer_0_heading (@{$hierarchy_hash{0}}) {
            my @row ; 
            push(@row , $layer_0_heading) ;
            foreach my $layer_1_heading (@{$hierarchy_hash{1}}) {
                if (!defined($data_hash{$layer_0_heading}{$layer_1_heading})) {
                    push(@row , "") ;
                }
                else {
                    push(@row , $data_hash{$layer_0_heading}{$layer_1_heading}) ;
                }
            }
            push(@matrix , \@row) ;
            @row = () ;
        }
    }
    if ($layers == 2) {
        foreach my $layer_1_heading (@{$hierarchy_hash{1}}) {
            foreach my $layer_2_heading (@{$hierarchy_hash{2}}) {
                push(@{$matrix[0]} , $layer_1_heading) ;
                push(@{$matrix[1]} , $layer_2_heading) ;
            }
        }
        foreach my $layer_0_heading (@{$hierarchy_hash{0}}) {
            my @row ; 
            push(@row , $layer_0_heading) ;
            foreach my $layer_1_heading (@{$hierarchy_hash{1}}) {
                foreach my $layer_2_heading (@{$hierarchy_hash{2}}) {
                    if (!defined($data_hash{$layer_0_heading}{$layer_1_heading}{$layer_2_heading})) {
                        push(@row , "") ;
                    }
                    else {
                        push(@row , $data_hash{$layer_0_heading}{$layer_1_heading}{$layer_2_heading}) ;
                    }
                }
            }
            push(@matrix , \@row) ;
#            @row = () ;
        }
    }
    if ($layers == 3) {
        foreach my $layer_1_heading (@{$hierarchy_hash{1}}) { 
            foreach my $layer_2_heading (@{$hierarchy_hash{2}}) {
                foreach my $layer_3_heading (@{$hierarchy_hash{3}}) {
                    push(@{$matrix[0]} , $layer_1_heading) ;
                    push(@{$matrix[1]} , $layer_2_heading) ;
                    push(@{$matrix[2]} , $layer_3_heading) ;
                }
            }
        }
        foreach my $layer_0_heading (@{$hierarchy_hash{0}}) {
            my @row ; 
            push(@row , $layer_0_heading) ;
            foreach my $layer_1_heading (@{$hierarchy_hash{1}}) {
                foreach my $layer_2_heading (@{$hierarchy_hash{2}}) {
                    foreach my $layer_3_heading (@{$hierarchy_hash{3}}) {
                        if (!defined($data_hash{$layer_0_heading}{$layer_1_heading}{$layer_2_heading}{$layer_3_heading})) {
                            push(@row , "") ;
                        }
                        else {
                            push(@row , $data_hash{$layer_0_heading}{$layer_1_heading}{$layer_2_heading}{$layer_3_heading}) ;
                        }
                    }
                }
            }
            push(@matrix , \@row) ;
#            @row = () ;
        }
    }
    if ($layers == 4) {
        foreach my $layer_4_heading (@{$hierarchy_hash{4}}) {
            foreach my $layer_3_heading (@{$hierarchy_hash{3}}) {
                foreach my $layer_2_heading (@{$hierarchy_hash{2}}) {
                    foreach my $layer_1_heading (@{$hierarchy_hash{1}}) {
                        push(@{$matrix[0]} , $layer_1_heading) ;
                        push(@{$matrix[1]} , $layer_2_heading) ;
                        push(@{$matrix[2]} , $layer_3_heading) ;
                        push(@{$matrix[4]} , $layer_4_heading) ;
                    }
                }
            }
        }
        foreach my $layer_0_heading (@{$hierarchy_hash{0}}) {
            my @row ;
            push(@row , $layer_0_heading) ;
            foreach my $layer_4_heading (@{$hierarchy_hash{4}}) {
                foreach my $layer_3_heading (@{$hierarchy_hash{3}}) {
                    foreach my $layer_2_heading (@{$hierarchy_hash{2}}) {
                        foreach my $layer_1_heading (@{$hierarchy_hash{1}}) {
                            if (!defined($data_hash{$layer_0_heading}{$layer_1_heading}{$layer_2_heading}{$layer_3_heading}{$layer_4_heading})) {
                                push(@row, "") ;
                            }
                            else {
                                push(@row , $data_hash{$layer_0_heading}{$layer_1_heading}{$layer_2_heading}{$layer_3_heading}{$layer_4_heading}) ;
                            }
                        }
                    }
                }
            }
            push(@matrix , \@row) ;
            @row = () ;
        }
    }
    return \@matrix ; 
}
#
sub csvToMatrix {
#converts csv to matrix format, returns matrix pointer
    my $csv_file_path = $_[0] ;
    if ($csv_file_path !~ /^.*\.csv$/) {
        die "Invalid file type, csv_to_matrix requires csv file input.\n" ;
    }
    my $contents = readFile($csv_file_path) ;
    my @rows = split(/\n/, $contents) ;
    foreach my $row (@rows) {
        my @elements ;
        @elements = split(/,/, $row, -1) ; #-1 to keep empty trailing elements
        if($SHOW_DEBUG){ print"Row from csv:\n" ; print Dumper(\@elements) ; }
        $row = \@elements ;
#        @elements = () ;
    }

    my @matrix = @rows ;

    return \@matrix ;
}
#
sub readFile {

    my $path = $_[0] ;
    local $/ ;

    open(FILE, $path) or die "Can't read file 'filename' [$!]\n" ;
    my $document = <FILE> ;
    close(FILE) ;
    return $document ;
}
#
sub mergeHashes {
#takes in list of hashes to merge. Order matters

    my @data_hashes = @{$_[0]} ;
    my @hierarchy_hashes = @{$_[1]} ;

    my %new_data_hash ; 
    my %new_hierarchy_hash ;

    my @list_of_layers ;

    my %data_hash ;
    my %hierarchy_hash ;

    my $levels ;

    my %temp_hash ;

    foreach my $hierarchy_hash_pointer (@hierarchy_hashes) {
        my @layers ;
        foreach my $key (keys %{$hierarchy_hash_pointer}) {
            push(@layers , $key) ;
            $new_hierarchy_hash{$key} = 1 ;
        }
        @layers = sort(@layers) ;
        if ($SHOW_DEBUG) { print"layers:\n" ; print Dumper(\@layers) ; }
        push(@list_of_layers , $layers[-1]) ;
        @layers = () ;
    }

    if ($SHOW_DEBUG) { print"list of layers:\n" ; print Dumper(\@list_of_layers) ; }
    if ($SHOW_DEBUG) { print "Size of list of layers: $#list_of_layers\n" ; }

    for (my $i = 0;  $i <= $#list_of_layers; $i++) {
        for (my $j = 0; $j <= $#list_of_layers; $j++) {
            if ($SHOW_DEBUG) { print"comparison elements: $list_of_layers[$i] and $list_of_layers[$j]\n"}
            if ($list_of_layers[$i] != $list_of_layers[$j]) {
                die "ERROR: Hashes aren't of the same levels of hierarchy! \nEXITING...\n" ;
            }
        }
    }

    $levels = $list_of_layers[0] ;
    
    foreach my $data_hash_pointer (@data_hashes) {
        %data_hash = %{$data_hash_pointer} ;
        foreach my $key (keys %data_hash) {
            if ($levels == 0) {
                $new_data_hash{$key} = $data_hash{$key} ; 
            }
            else {
                foreach my $subkey (keys %{$data_hash{$key}}) {
                    if ($levels == 1) {
                        $new_data_hash{$key}{$subkey} = $data_hash{$key}{$subkey} ; 
                    }
                    else {
                        foreach my $subsubkey (keys %{$data_hash{$key}{$subkey}}) {
                            if ($levels == 2) {
                                $new_data_hash{$key}{$subkey}{$subsubkey} = $data_hash{$key}{$subkey}{$subsubkey} ; 
                            }
                            else {
                                foreach my $subsubsubkey (keys %{$data_hash{$key}{$subkey}{$subsubkey}}) {
                                    if ($levels == 3) {
                                        $new_data_hash{$key}{$subkey}{$subsubkey}{$subsubsubkey} = $data_hash{$key}{$subkey}{$subsubkey}{$subsubsubkey} ; 
                                    }
                                    else {
                                        foreach my $subsubsubsubkey (keys %{$data_hash{$key}{$subkey}{$subsubkey}{$subsubsubkey}}) {
                                            if ($levels == 4) {
                                                $new_data_hash{$key}{$subkey}{$subsubkey}{$subsubsubkey}{$subsubsubsubkey} = $data_hash{$key}{$subkey}{$subsubkey}{$subsubsubkey}{$subsubsubsubkey} ; 
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    foreach my $key (keys %new_hierarchy_hash) {
        my @headings ;
        foreach my $hierarchy_hash_pointer (@hierarchy_hashes) {
            %hierarchy_hash = %{$hierarchy_hash_pointer} ;
            %temp_hash = map { $_ => 1} @headings ;
            foreach my $element (@{$hierarchy_hash{$key}}) {
                if (!exists($temp_hash{$element})) {
                    push(@headings, $element) ;
                }
            }
#            print Dumper(\@headings) ;
#            push(@headings, @{$hierarchy_hash{$key}}) ;
#            print Dumper(\@headings) ;
        }
        $new_hierarchy_hash{$key} = \@headings ;
    }
    return (\%new_data_hash , \%new_hierarchy_hash) ;
}
#
#sub matrixToCsv {
#    
#    my $matrix_pointer = $_[0] ;
#    my $csv_file_path = $_[1] ;
#
#    my $string = "";
#
#    my $i ;
#    my @row_array ;
#
#    foreach my $row (@{matrix_in_pointer}) {
#        $i = 0 ;
#        @row_array = @{$row} ;
#        foreach my $item (@{$row}) {
#            if ($i == $#row_array) {
#                $string .= "$item\r" ;
#            }
#            else {
#                $string .= "$item," ;
#            }
#        }
#
#    }
#    
#    write_file($csv_file_path, $string, ">") ;
#}
#
#sub writeFile {
#
#    my $file_path = $_[0] ;
#    my $string = $_[1] ;
#    my $write_type = $_[2] ;
#
#    open(my $fh, $write_type, $file_path) or die "Could not open file '$file_path' $!" ;
#    print $fh "$string\n" ;
#    close $fh ;
#    print "Done writing to file '$file_path'!\n" ;
#
#
#}
#
#sub detectAnomalies {
##takes slope, y intercept, and variance of fitted data and x, y values of data 
##point of interest. Returns 1 if the point lies more than x*sigma away from fit
#
#    my $slope = $_[0] ;
#    my $y_intercept = $_[1] ;
#    my $sigma = $_[2] ;
#    my $x = $_[3] ;
#    my $y = $_[4] ;
#    my $num_of_devs = $_[5] ;
#
#    my $expected_y = $slope * $x + $y_intercept ;
#
#    my $residual = abs($y - $expected_y) ;
#    
#    if ($residual > $num_of_devs * $sigma) {
#        return 1 ;
#    }
#
#    else {
#        return 0 ;
#    }
#
#
#}
#
sub leastSquaresLinearFit {
#takes in x and y arrays of data, returns slope, y-intercept, correlation R^2, 
#and sigma

    my $x_array = $_[0] ;
    my $y_array = $_[1] ;

    my $line_fit = Statistics::LineFit -> new() ;
    $line_fit -> setData($x_array , $y_array) or die "Invalid data\n" ;
    my ($intercept , $slope) = $line_fit -> coefficients() ;
    defined $intercept or die "Can't fit line if x values are all equal\n" ;
    my $r_squared = $line_fit -> rSquared() ;
    my $sigma = $line_fit -> sigma() ;


    return ($slope , $intercept , $r_squared , $sigma) ;
}
