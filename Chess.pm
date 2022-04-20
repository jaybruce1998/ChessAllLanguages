#!/usr/bin/perl
package Chess;
use Square;
use Move;
sub new
{
	my @pieces=("Rk", "Kt", "Bp", "Kg", "Qn", "Bp", "Kt", "Rk");
	my @board;
	my $class=shift;
	my $self={
		_boards=>(),
		_boardDex=>0,
		_moves=>0,
	};
	for(my $r=0; $r<8; $r++)
	{
		for(my $c=0; $c<8; $c++)
		{
			$board[$r][$c]=new Square(" ", "  ");
		}
	}
  	for(my $c=0; $c<8; $c++)
  	{
  		$board[0][$c]=new Square("W", $pieces[$c]);
  		$board[1][$c]=new Square("W", "Pn");
  		$board[6][$c]=new Square("B", "Pn");
  		$board[7][$c]=new Square("B", $pieces[$c]);
  	}
	bless $self, $class;
	$self->setVariables(\@board, 8, 8, 0, 3, 7, 3, "W", "B");
	return $self;
}
sub setVariables
{
	my ($self, $board, $epr, $epc, $wkr, $wkc, $bkr, $bkc, $turn, $cap)=@_;
	$self->{_board}=$board;
	$self->{_epr}=$epr;
	$self->{_epc}=$epc;
	$self->{_wkr}=$wkr;
	$self->{_wkc}=$wkc;
	$self->{_bkr}=$bkr;
	$self->{_bkc}=$bkc;
	$self->{_turn}=$turn;
	$self->{_cap}=$cap;
}
sub boardCopy
{
	my ($self)=@_;
	my @board;
	for(my $r=0; $r<8; $r++)
	{
		for(my $c=0; $c<8; $c++)
		{
			my $square=$self->{_board}[$r][$c];
			$board[$r][$c]=new Square($square->{_color}, $square->{_type});
		}
	}
	return @board;
}
sub changeTurns
{
	my ($self)=@_;
	my $turn=$self->{_turn};
	$self->{_turn}=$self->{_cap};
	$self->{_cap}=$turn;
}
sub canPawnMove
{
	my ($self, $r1, $c1, $r2, $c2)=@_;
	my $r=$r1-$r2;
	my $a=abs($r);
	my $c=abs($c1-$c2);
  	if($r==0||$a>2||$r>0&&$self->{_turn} eq "W"||$r<0&&$self->{_turn} eq "B")
  	{
  		return false;
  	}
  	if($c==1)
  	{
  		return $a==1&&($self->{_board}[$r2][$c2]->{_color} eq $self->{_cap}||$r1==$self->{_epr}&&$c2==$self->{_epc});
  	}
  	if($c==0&&$self->{_board}[$r2][$c2]->{_color} eq " ")
  	{
  		return $a==1||$self->{_board}[$r2+r/2][$c2]->{_color} eq " "&&!$self->{_board}[$r1][$c1]->{_moved};
  	}
  	return false;
}
sub canKnightMove
{
	my ($self, $r1, $c1, $r2, $c2)=@_;
	my $r=abs($r1-$r2);
	my $c=abs($c1-$c2);
	return $r<3&&$c<3&&$r+$c==3;
}
sub canRookMove
{
	my ($self, $r1, $c1, $r2, $c2)=@_;
  	if($r1!=$r2&&$c1!=$c2)
  	{
  		return false;
  	}
  	if($r1>$r2)
  	{
  		my $t=$r1;
  		$r1=$r2;
  		$r2=$t;
  	}
  	elsif($c1>$c2)
  	{
  		my $t=$c1;
  		$c1=$c2;
  		$c2=$t;
  	}
  	if($r1!=$r2)
  	{
  		for(my $r=$r1+1; $r<$r2; $r++)
  		{
  			if($self->{_board}[$r][$c1]->{_color} ne " ")
  			{
  				return false;
  			}
  		}
  	}
  	else
  	{
  		for(my $c=$c1+1; $c<$c2; $c++)
  		{
  			if($self->{_board}[$r1][$c]->{_color} ne " ")
  			{
  				return false;
  			}
  		}
  	}
  	return 1;
}
sub canBishopMove
{
	my ($self, $r1, $c1, $r2, $c2)=@_;
  	if($r1>$r2)
  	{
  		my $t=$r1;
  		$r1=$r2;
  		$r2=$t;
  		$t=$c1;
  		$c1=$c2;
  		$c2=$t;
  	}
  	my $r=$r2-$r1;
  	my $c=$c1-$c2;
  	if($r!=abs($c))
  	{
  		return false;
  	}
  	if($c<0)
  	{
  		for(my $i=1; $i<$r; $i++)
  		{
  			if($self->{_board}[$r1+$i][$c1+$i]->{_color} ne " ")
  			{
  				return false;
  			}
  		}
  	}
  	else
  	{
  		for(my $i=1; $i<$r; $i++)
  		{
  			if($self->{_board}[$r1+$i][$c1-$i]->{_color} ne " ")
  			{
  				return false;
  			}
  		}
  	}
  	return 1;
}
sub canKingMove
{
	my ($self, $r1, $c1, $r2, $c2)=@_;
  	my $r=abs($r1-$r2);
  	my $c=$c1-$c2;
  	my $a=abs($c);
  	if($a<2)
  	{
  		return $r<2;
  	}
  	if($r>0||$self->{_board}[$r1][$c]->{_moved}||$a!=2)
  	{
  		return false;
  	}
  	if($c==2)
  	{
  		return $self->{_board}[$r2][$c1-1]->{_color} eq " "&&$self->{_board}[$r2][$c2]->{_color} eq " "&&!$self->{_board}[$r2][0]->{_moved};
  	}
  	return $self->{_board}[$r2][$c1]->{_color} eq " "&&$self->{_board}[$r2][$c1+1]->{_color} eq " "&&$self->{_board}[$r2][$c2]->{_color} eq " "&&!$self->{_board}[$r2][7]->{_moved};
}
sub move
{
	my ($self, $r1, $c1, $r2, $c2)=@_;
	my @copy=$self->boardCopy();
	my @boards=$self->{_boards};
	my $index=$self->{_boardDex}++;
	$boards[$index]=\@copy;
	$self->{_boards}=\@boards;
  	if($self->{_board}[$r1][$c1]->{_type} eq "Kg")
  	{
  		$self->{_epr}=8;
  		if($self->{_turn} eq "W")
  		{
  			$self->{_wkr}=$r2;
  			$self->{_wkc}=$c2;
  		}
  		else
  		{
  			$self->{_bkr}=$r2;
  			$self->{_bkc}=$c2;
  		}
  		if(abs($c1-$c2)==2)
  		{
  			if($c2==1)
  			{
  				$self->{_board}[$r2][2]=new Square($self->{_board}[$r2][0]->{_color}, $self->{_board}[$r2][0]->{_type});
  				$self->{_board}[$r2][0]=new Square(" ", "  ");
  			}
  			else
  			{
  				$self->{_board}[$r2][4]=new Square($self->{_board}[$r2][7]->{_color}, $self->{_board}[$r2][7]->{_type});
  				$self->{_board}[$r2][7]=new Square(" ", "  ");
  			}
  		}
  	}
  	elsif($self->{_board}[$r1][$c1]->{_type} eq "Pn")
  	{
  		$self->{_moves}=-1;
  		if(abs($r1-$r2)==2)
  		{
  			$self->{_epr}=$r2;
  			$self->{_epc}=$c2;
  		}
  		else
  		{
  			if($r1==$self->{_epr}&&$c2==$self->{_epc})
  			{
  				$self->{_board}[$r1][$c2]=new Square(" ", "  ");
  			}
  			elsif($r2==0||$r2==7)
  			{
  				$self->{_board}[$r1][$c1]->{_type}="Qn";
  			}
  			$self->{_epr}=8;
  		}
  	}
  	else
  	{
  		$self->{_epr}=8;
  	}
  	if($self->{_board}[$r2][$c2]->{_color} eq " ")
  	{
  		$self->{_moves}++;
  	}
  	else
  	{
  		$self->{_moves}=0;
  	}
  	$self->{_board}[$r2][$c2]=new Square($self->{_board}[$r1][$c1]->{_color}, $self->{_board}[$r1][$c1]->{_type});
    $self->{_board}[$r2][$c2]->{_moved}=true;
  	$self->{_board}[$r1][$c1]=new Square(" ", "  ");
  	$self->changeTurns();
}
sub canMove
{
	my ($self, $r1, $c1, $r2, $c2, $real)=@_;
  	if($self->{_board}[$r1][$c1]->{_color} ne $self->{_turn} or $self->{_board}[$r2][$c2]->{_color} eq $self->{_turn})
  	{
  		return false;
  	}
  	if($real!=0)
  	{
  		$chess=new Chess();
		my @copy=$self->boardCopy();
  		$chess->setVariables(\@copy, $self->{_epr}, $self->{_epc}, $self->{_wkr}, $self->{_wkc}, $self->{_bkr}, $self->{_bkc}, $self->{_turn}, $self->{_cap});
  		if($self->{_board}[$r1][$c1]->{_type} eq "Kg"&&abs($c1-$c2)==2)
  		{
	  		$chess->changeTurns();
	  		if($chess->anyCanMoveTo($r1, $c1, false))
	  		{
	  			return false;
	  		}
	  		$chess->changeTurns();
	  		my $c=$c1+($c2-$c1)/2;
	  		$chess->move($r1, $c1, $r2, $c);
	  		if($chess->anyCanMoveTo($r2, $c, false))
	  		{
	  			return false;
	  		}
	  		$chess->move($r2, $c, $r1, $c1);
	  	}
	  	$chess->move($r1, $c1, $r2, $c2);
	  	if($self->{_turn} eq "W")
	  	{
	  		if($chess->anyCanMoveTo($chess->{_wkr}, $chess->{_wkc}, false)!=0)
	  		{
	  			return false;
	  		}
	  	}
	  	elsif($chess->anyCanMoveTo($chess->{_bkr}, $chess->{_bkc}, false)!=0)
	  	{
	  		return false;
	  	}
  	}
	if($self->{_board}[$r1][$c1]->{_type} eq "Pn")
	{
		return $self->canPawnMove($r1, $c1, $r2, $c2);
	}
	elsif($self->{_board}[$r1][$c1]->{_type} eq "Kt")
	{
		return $self->canKnightMove($r1, $c1, $r2, $c2);
	}
	elsif($self->{_board}[$r1][$c1]->{_type} eq "Rk")
	{
		return $self->canRookMove($r1, $c1, $r2, $c2);
	}
	elsif($self->{_board}[$r1][$c1]->{_type} eq "Bp")
	{
		return $self->canBishopMove($r1, $c1, $r2, $c2);
	}
	elsif($self->{_board}[$r1][$c1]->{_type} eq "Qn")
	{
		return $self->canRookMove($r1, $c1, $r2, $c2)!=0||$self->canBishopMove($r1, $c1, $r2, $c2);
	}
	return $self->canKingMove($r1, $c1, $r2, $c2);
}
sub anyCanMoveTo
{
	my ($self, $r2, $c2, $real)=@_;
  	for(my $r=0; $r<8; $r++)
  	{
  		for(my $c=0; $c<8; $c++)
  		{
  			if($self->canMove($r, $c, $r2, $c2, $real)!=0)
  			{
  				return 1;
  			}
  		}
  	}
  	return false;
}
sub anyCanMove
{
	my ($self)=@_;
  	for(my $r=0; $r<8; $r++)
  	{
  		for(my $c=0; $c<8; $c++)
  		{
  			if($self->anyCanMoveTo($r, $c, 1)!=0)
  			{
  				return 1;
  			}
  		}
  	}
  	return 0;
}
sub equals
{
	my ($self, $board)=@_;
  	for(my $r=0; $r<8; $r++)
  	{
  		for(my $c=0; $c<8; $c++)
  		{
  			if(!$self->{_board}[$r][$c]->equals($board[$r][$c]))
  			{
  				return false;
  			}
  		}
  	}
  	return 1;
}
sub state
{
	my ($self)=@_;
  	if($self->{_moves}==100)
  	{
  		return "Draw by 50-move rule";
  	}
  	my $s="";
  	my $n=0;
  	my $w=0;
  	my $b=0;
  	$self->changeTurns();
  	if(($self->{_turn} eq "W"&&$self->anyCanMoveTo($self->{_bkr}, $self->{_bkc}, false)||$self->{_turn} eq "B"&&$self->anyCanMoveTo($self->{_wkr}, $self->{_wkc}, false))!=0)
	{
  		$s="Check";
	}
  	$self->changeTurns();
  	if($self->anyCanMove()==0)
  	{
  		if($s eq "Check")
  		{
  			return "Checkmate";
  		}
  		return "Stalemate";
  	}
  	for($self->{_boards})
  	{
  		if($self->equals($_))
  		{
  			$n++;
  		}
  	}
  	if($n==2)
  	{
  		return "Draw by 3-fold repetition";
  	}
  	for(my $r=0; $r<8; $r++)
  	{
  		for(my $c=0; $c<8; $c++)
  		{
  			if($self->{_board}[$r][$c]->{_type} eq "Rk"||$self->{_board}[$r][$c]->{_type} eq "Qn"||$self->{_board}[$r][$c]->{_type} eq "Pn")
  			{
  				return $s;
  			}
  			elsif($self->{_board}[$r][$c]->{_color} eq "W")
  			{
  				$w++;
  			}
  			elsif($self->{_board}[$r][$c]->{_color} eq "B")
  			{
  				$b++;
  			}
  		}
  	}
  	if($w<2&&$b<2)
  	{
  		return "Draw by insufficient material";
  	}
  	return $s;
}
sub randomMove
{
	my ($self)=@_;
  	my @moves;
  	my $size=0;
  	for(my $r1=0; $r1<8; $r1++)
	{
  		for(my $c1=0; $c1<8; $c1++)
  		{
  			for(my $r2=0; $r2<8; $r2++)
  			{
  				for(my $c2=0; $c2<8; $c2++)
  				{
  					if($self->canMove($r1, $c1, $r2, $c2, 1)!=0)
  					{
  						$moves[$size++]=new Move($r1, $c1, $r2, $c2);
  					}
  				}
  			}
  		}
	}
  	my $move=$moves[rand @moves];
  	$self->move($move->{_r1}, $move->{_c1}, $move->{_r2}, $move->{_c2});
}
sub toString
{
	my ($self)=@_;
	my $s=" h  g  f  e  d  c  b  a\n";
	for(my $r=0; $r<8;)
	{
		for(my $c=0; $c<8; $c++)
		{
			$s=$s.$self->{_board}[$r][$c]->toString();
		}
		$r++;
		$s="$s $r\n";
	}
	return $s;
}
1;