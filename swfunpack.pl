#!/usr/local/bin/perl

use warnings;
use strict;

use Compress::Zlib;

if ($#ARGV != 0) {
  die "Usage:\n\tperl $0 <file>\n";
}

# Prepare file names
my $inputFileName = shift(@ARGV);
my $outputFileName = $inputFileName . ".unp";

open(INPUT, $inputFileName)
  or die "Open file failure.";
binmode(INPUT);

# Read file contents
my @fileContents = <INPUT>;

# Read/unpack SWF header
my $SWFData = substr($fileContents[0],0,8);
my ($SWFHeader, $SWFVersion, $SWFSize) = unpack("A3 c V", $SWFData);

# Check for compressed header
if ($SWFHeader ne "CWS") {
  die "Not Compressed.\n";
}

# Strip SWF header from file contents
$fileContents[0] = substr($fileContents[0],8);

# Uncompress remaining data
my $unpackedSWF = Compress::Zlib::uncompress(join("", @fileContents)) 
  or die "Unpack Error";

# Open and/or create new file
open(NEWFILE, ">", $outputFileName) 
  or die "Unable to create new file";
binmode(NEWFILE);

# Repack header and write new SWF
print NEWFILE pack("A3 c V", "FWS", $SWFVersion, $SWFSize);
print NEWFILE $unpackedSWF;

print "\nSuccessfully unpacked " . $inputFileName . " to " . $outputFileName . "\n";