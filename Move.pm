#!/usr/bin/perl
package Move;
sub new
{
	my $class=shift;
	my $self={
		_r1=>shift,
		_c1=>shift,
		_r2=>shift,
		_c2=>shift,
	};
	bless $self, $class;
	return $self;
}
1;