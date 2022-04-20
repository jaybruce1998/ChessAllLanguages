#!/usr/bin/perl
use Chess;
my $chess=new Chess();
my $state="";
print $chess->toString();
while(substr($state, 0, 4) ne "Draw" and substr($state, -5) ne "mate\n")
{
	my $b=1;
	while($b!=0)
	{
		my $move=<STDIN>;
		my $r1=substr($move, 1, 1)-1;
		my $c1=104-ord($move);
		my $r2=substr($move, 4)-1;
		my $c2=104-ord(substr($move, 3));
		if($r1<0||$r1>7||$c1<0||$c1>7||$r2<0||$r2>7||$c2<0||$c2>7)
		{
			print "That is not a valid move!\n";
		}
		elsif($chess->canMove($r1, $c1, $r2, $c2, true)!=0)
		{
			$chess->move($r1, $c1, $r2, $c2);
			$state=$chess->state()."\n";
			print $chess->toString();
			print $state;
			$b=false;
		}
		else
		{
			print "That is not a legal move!\n";
		}
	}
	if(substr($state, 0, 4) ne "Draw" and substr($state, -5) ne "mate\n")
	{
		$chess->randomMove();
		$state=$chess->state()."\n";
		print $chess->toString();
		print $state;
	}
}