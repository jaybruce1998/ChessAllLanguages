#!/usr/bin/perl
package Square;
sub new
{
	my $class=shift;
	my $self={
		_color=>shift,
		_type=>shift,
		_moved=>shift,
	};
	bless $self, $class;
	return $self;
}
sub equals
{
	my($self, $square)=@_;
	return $self->{_color} eq $square->{_color}&&$self->{_type} eq $square->{_type};
}
sub toString
{
	my($self)=@_;
	return "$self->{_color}$self->{_type}";
}
1;