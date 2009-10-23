#$Id: gzip.pm 517 2009-10-23 15:52:21Z maj $

package PerlIO::via::gzip;
use strict;
use warnings;
use Compress::Zlib;
use Carp;
our $VERSION = '0.01';
our $COMPRESSION_LEVEL;
our $COMPRESSION_STRATEGY;
our $INSTANCE = 128;

sub PUSHED { 
    no strict qw(refs);
    my $stat;
    ${'PUSHED'.$INSTANCE} = { mode => $_[1] };
    bless \*{'PUSHED'.$INSTANCE++}, $_[0];
}

sub OPEN {
    my ($obj, $pth, $mode) = @_;
    $mode = O($obj)->{mode};
    # tweak mode for zlib
    $mode =~ s/\+//;
    $mode .= 'b' unless $mode =~ /b/;
    if (defined $COMPRESSION_LEVEL || defined $COMPRESSION_STRATEGY) {
	$mode .= $COMPRESSION_LEVEL.$COMPRESSION_STRATEGY if $mode =~ /w/; 
    }
    O($obj)->{gzh} = gzopen($pth, $mode);
    croak "failed(OPEN): ".O($obj)->{gzh}->gzerror 
	unless O($obj)->{gzh}->gzerror == Z_OK;
    1;
}


sub FILL {
    my ($obj, $fh) = @_;
    my $line = '';
    my $ret = O($obj)->{gzh}->gzreadline($line);
    croak "failed(FILL): ".O($obj)->{gzh}->gzerror unless $ret >= 0;
    return $line;
}

sub WRITE {
    my ($obj, $buf, $fh) = @_;
    my $len = O($obj)->{gzh}->gzwrite($buf);
    croak "failed(WRITE): ".O($obj)->{gzh}->gzerror 
	unless O($obj)->{gzh}->gzerror == Z_OK;
    return $len;
}

sub FLUSH {
    my ($obj, $fh) = @_;
    return O($obj)->{gzh}->gzflush if (O{$obj}->{mode} =~ /w/);
    return 0;
}

sub CLOSE {
    my ($obj, $fh) = @_;
    return O($obj)->{gzh}->gzclose;
}

sub O {
    my $sym = shift;
    no strict qw(refs);
    if (ref($sym) =~ /via|GLOB/) {
	return ${*$sym{SCALAR}};
    }    
    else {
	croak("Don't understand the arg");
    }
}
1;
__END__
=pod 

=head1 NAME

PerlIO::via::gzip - PerlIO layer for gzip (de)compression

=head1 SYNOPSIS

 # compress
 open( $cfh, ">:via(gzip)", 'stdout.gz' );
 print $cfh @stuff;

 # decompress
 open( $fh, "<:via(gzip)", "stuff.gz" );
 while (<$fh>) {
    ...
 }

=head1 DESCRIPTION

This module provides a PerlIO layer for transparent gzip compression,
using L<Compress::Zlib>. The zlib library must be available on your
machine.

Don't forget to flush.

=head1 Changing compression parameters

On write, compression level and strategy default to the defaults specified in 
L<Compress::Zlib>. To hack these, set

 $PerlIO::via::gzip::COMPRESSION_LEVEL

to a digit between 0 (fastest) and 9 (best), and 

 $PerlIO::via::gzip::COMPRESSION_STRATEGY

to 'f' for filtered data, 'h' for Huffman-only compression, or 'R' for
run-length encoding, per L<Compress::Zlib>.

=head1 SEE ALSO

L<PerlIO|perlio>, L<PerlIO::via>, L<Compress::Zlib>

=head1 AUTHOR - Mark A. Jensen

 Email maj -at- fortinbras -dot- us
 http://fortinbras.us
 http://bioperl.org/wiki/Mark_Jensen

=cut


