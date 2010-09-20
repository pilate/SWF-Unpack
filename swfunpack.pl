#!/usr/local/bin/perl

use warnings;
use strict;

use Compress::Zlib;

# Subroutine that attempts to uncompress swf data passed to it
sub uncompress_flash_contents {
    # Give arguments a name
    my ($flashContents) = @_;
  
    # 'unpack' SWF structure
    my ($SWFText, $SWFVersion, $SWFSize, $packedSWF) = unpack("A3 c V a*", $flashContents);
  
    # Check for compressed identifier
    if ($SWFText ne "CWS") {
        return undef;
    }
  
    # Do uncompress
    my $unpackedSWF = Compress::Zlib::uncompress($packedSWF) 
        or return undef;
        
    # Return repack of header and uncompressed data
    pack("A3 c V a*", "FWS", $SWFVersion, $SWFSize, $unpackedSWF);
}

# Check script arguments
if ($#ARGV != 0) {
  die "Usage:\n\tperl $0 <file>\n";
}

# Prepare file names
my $inputFileName = shift(@ARGV);
my $outputFileName = $inputFileName . ".unp";

# Read file contents into scalar
open(INPUT, $inputFileName)
  or die "Failed to open file.";
binmode(INPUT);
my $fileContents = join("",<INPUT>);
close(INPUT);

# uncompress contents
my $unpackedFile = &uncompress_flash_contents($fileContents)
    or die "Error while uncompressing.";

# Create new file and write results
open(NEWFILE, ">", $outputFileName) 
  or die "Failed to create destination file";
binmode(NEWFILE);
print NEWFILE $unpackedFile;
close(NEWFILE);

printf("\nSuccessfully unpacked %s to %s\n", $inputFileName, $outputFileName);