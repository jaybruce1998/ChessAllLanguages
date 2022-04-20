<?php
	session_start();
?>
<title>Chess</title>
<tt>
<?php
	class Square
	{
		private $color;
		private $type;
		private $moved;
		function __construct($color, $type)
		{
			$this->color=$color;
			$this->type=$type;
			$this->moved=$color==' ';
		}
		function color()
		{
			return $this->color;
		}
		function type()
		{
			return $this->type;
		}
		function moved()
		{
			return $this->moved;
		}
		function move()
		{
			$this->moved=true;
		}
		function promote()
		{
			$this->color="Qn";
		}
		function equals($square)
		{
			return $this->color==$square->color&&$this->type==$square->type;
		}
		function toString()
		{
			return $this->color.$this->type;
		}
	}
	class Chess
	{
		private $boards;
		private $moves;
		private $epr;
		private $epc;
		private $board;
		private $wkr;
		private $wkc;
		private $bkr;
		private $bkc;
		private $turn;
		private $cap;
		function __construct()
		{
			$pieces=["Rk", "Kt", "Bp", "Kg", "Qn", "Bp", "Kt", "Rk"];
			$this->boards=[];
			$this->moves=0;
			$this->epr=8;
			$this->epc=8;
			$this->setVariables([], 0, 3, 7, 3, "W", "B");
			for($r=0; $r<8; $r++)
			{
				$this->board[$r]=[];
				for($c=0; $c<8; $c++)
					$this->board[$r][$c]=new Square(' ', "  ");
			}
			for($c=0; $c<8; $c++)
			{
		  		$this->board[0][$c]=new Square("W", $pieces[$c]);
		  		$this->board[1][$c]=new Square("W", "Pn");
		  		$this->board[6][$c]=new Square("B", "Pn");
		  		$this->board[7][$c]=new Square("B", $pieces[$c]);
		  	}
		}
		function boardCopy()
		{
			$board=[];
			for($r=0; $r<8; $r++)
			{
				$board[$r]=[];
				for($c=0; $c<8; $c++)
					$board[$r][$c]=new Square($this->board[$r][$c]->color(), $this->board[$r][$c]->type());
			}
			return $board;
		}
		function setVariables($board, $wkr, $wkc, $bkr, $bkc, $turn, $cap)
		{
			$this->board=$board;
			$this->wkr=$wkr;
			$this->wkc=$wkc;
			$this->bkr=$bkr;
			$this->bkc=$bkc;
			$this->turn=$turn;
			$this->cap=$cap;
		}
		function changeTurns()
		{
			$t=$this->turn;
			$this->turn=$this->cap;
			$this->cap=$t;
		}
		function canPawnMove($r1, $c1, $r2, $c2)
		{
			$r=$r1-$r2;
			$a=abs($r);
			$c=abs($c1-$c2);
		  	if($r==0||$a>2||$r>0&&$this->turn=='W'||$r<0&&$this->turn=='B')
		  		return false;
		  	if($c==1)
		  		return $a==1&&($this->board[$r2][$c2]->color()==$this->cap||$r1==$this->epr&&c2==$this->epc);
		  	if($c==0&&$this->board[$r2][$c2]->color()==' ')
		  		return $a==1||$this->board[$r2+$r/2][$c2]->color()==' '&&!$this->board[$r1][$c1]->moved();
		  	return false;
		}
		function canKnightMove($r1, $c1, $r2, $c2)
		{
			$r=abs($r1+$r2);
			$c=abs($c1-$c2);
			return $r<3&&$c<3&&$r+$c==3;
		}
		function canRookMove($r1, $c1, $r2, $c2)
		{
			if($r1!=$r2&&$c1!=$c2)
				return false;
			if($r1>$r2)
			{
				$t=$r1;
				$r1=$r2;
				$r2=$t;
			}
			else if($c1>$c2)
			{
				$t=$c1;
				$c1=$c2;
				$c2=$t;
			}
			if($r1!=$r2)
				for($r=$r1+1; $r<$r2; $r++)
				{
					if($this->board[$r][$c1]->color()!=' ')
						return false;
				}
			else
				for($c=$c1+1; $c<$c2; $c++)
					if($this->board[$r1][$c]->color()!=' ')
						return false;
			return true;
		}
		function canBishopMove($r1, $c1, $r2, $c2)
		{
			if($r1>$r2)
			{
				$t=$r1;
				$r1=$r2;
				$r2=$t;
				$t=$c1;
				$c1=$c2;
				$c2=$t;
			}
			$r=$r2-$r1;
			$c=$c1-$c2;
			if($r!=abs($c))
				return false;
			if($c<0)
				for($i=1; $i<$r; $i++)
				{
					if($this->board[$r1+$i][$c1+$i]->color()!=' ')
						return false;
				}
			else
				for($i=1; $i<$r; $i++)
					if($this->board[$r1+$i][$c1-$i]->color()!=' ')
						return false;
			return true;
		}
		function canKingMove($r1, $c1, $r2, $c2)
		{
			$r=abs($r1-$r2);
			$c=$c1-$c2;
			$a=abs($c);
			if($a<2)
				return $r<2;
			if($r>0||$this->board[$r1][$c1]->moved()||$a!=2)
				return false;
			if($c==2)
				return $this->board[$r2][$c1-1]->color()==' '&&$this->board[$r2][$c2]->color()==' '&&!$this->board[$r2][0]->moved();
			return $this->board[$r2][$c1+1]->color()==' '&&$this->board[$r2][$c2]->color()==' '&&$this->board[$r2][$c1+2]->color()==' '&&!$this->board[$r2][7]->moved();
		}
		function move($r1, $c1, $r2, $c2)
		{
			array_push($this->boards, $this->boardCopy());
			if($this->board[$r1][$c1]->type()=="Kg")
			{
				$this->epr=8;
				if($this->turn=='W')
				{
					$this->wkr=$r2;
					$this->wkc=$c2;
				}
				else
				{
					$this->bkr=$r2;
					$this->bkc=$c2;
				}
				if(abs($c1-$c2)==2)
					if($c2==1)
					{
						$this->board[$r2][2]=new Square($this->board[$r2][0]->color(), $this->board[$r2][0]->type());
						$this->board[$r2][0]=new Square(' ', "  ");
					}
					else
					{
						$this->board[$r2][4]=new Square($this->board[$r2][7]->color(), $this->board[$r2][7]->type());
						$this->board[$r2][7]=new Square(' ', "  ");
					}
			}
			else if($this->board[$r1][$c1]->type()=="Pn")
			{
				$this->moves=-1;
				if(abs($r1-$r2)==2)
				{
					$this->epr=$r2;
					$this->epc=$c2;
				}
				else
				{
					if($r1==$this->epr&&$c2==$this->epc)
						$this->board[$r1][$c2]=new Square(' ', "  ");
					else if($r2==0||$r2==7)
						$this->board[$r1][$c1]->promote();
					$this->epr=8;
				}
			}
			else
				$this->epr=8;
			if($this->board[$r2][$c2]->color()==" ")
				$this->moves++;
			else
				$this->moves=0;
			$this->board[$r2][$c2]=new Square($this->board[$r1][$c1]->color(), $this->board[$r1][$c1]->type());
			$this->board[$r2][$c2]->move();
			$this->board[$r1][$c1]=new Square(' ', "  ");
			$this->changeTurns();
		}
		function canMove($r1, $c1, $r2, $c2, $real)
		{
			if($this->board[$r1][$c1]->color()!=$this->turn||$this->board[$r2][$c2]->color()==$this->turn)
				return false;
			if($real)
			{
				$chess=new Chess();
				$chess->setVariables($this->boardCopy(), $this->wkr, $this->wkc, $this->bkr, $this->bkc, $this->turn, $this->cap);
				if($this->board[$r1][$c1]->type()=="Kg"&&abs($c1-$c2)==2)
				{
			  		$chess->changeTurns();
			  		if($chess->anyCanMoveTo($r1, $c1, false))
			  			return false;
			  		$chess->changeTurns();
			  		$c=$c1+($c2-$c1)/2;
			  		$chess->move($r1, $c1, $r2, $c);
			  		if($chess->anyCanMoveTo($r2, $c, false))
			  			return false;
			  		$chess->move($r2, $c, $r1, $c1);
			  	}
			  	$chess->move($r1, $c1, $r2, $c2);
			  	if($this->turn=='W')
			  	{
			  		if($chess->anyCanMoveTo($chess->wkr, $chess->wkc, false))
			  			return false;
			  	}
			  	else if($chess->anyCanMoveTo($chess->bkr, $chess->bkc, false))
			  		return false;
			}
			if($this->board[$r1][$c1]->type()=="Pn")
				return $this->canPawnMove($r1, $c1, $r2, $c2);
			else if($this->board[$r1][$c1]->type()=="Kt")
				return $this->canKnightMove($r1, $c1, $r2, $c2);
			else if($this->board[$r1][$c1]->type()=="Rk")
				return $this->canRookMove($r1, $c1, $r2, $c2);
			else if($this->board[$r1][$c1]->type()=="Bp")
				return $this->canBishopMove($r1, $c1, $r2, $c2);
			else if($this->board[$r1][$c1]->type()=="Qn")
				return $this->canRookMove($r1, $c1, $r2, $c2)||$this->canBishopMove($r1, $c1, $r2, $c2);
			return $this->canKingMove($r1, $c1, $r2, $c2);
		}
		function anyCanMoveTo($r2, $c2, $real)
		{
			for($r=0; $r<8; $r++)
				for($c=0; $c<8; $c++)
					if($this->canMove($r, $c, $r2, $c2, $real))
						return true;
			return false;
		}
		function anyCanMove()
		{
			for($r=0; $r<8; $r++)
				for($c=0; $c<8; $c++)
					if($this->anyCanMoveTo($r, $c, true))
						return true;
			return false;
		}
		function equals($board)
		{
			for($r=0; $r<8; $r++)
				for($c=0; $c<8; $c++)
					if(!$this->board[$r][$c]->equals($board[$r][$c]))
						return false;
			return true;
		}
		function state()
		{
			if($this->moves==100)
				return "Draw by 50-move rule";
			$s="";
			$n=0;
			$w=0;
			$b=0;
			$this->changeTurns();
			if($this->turn=='W'&&$this->anyCanMoveTo($this->bkr, $this->bkc, false)||$this->turn=='B'&&$this->anyCanMoveTo($this->wkr, $this->wkc, false))
				$s="Check";
			$this->changeTurns();
			if(!$this->anyCanMove())
				return $s=="Check"?"Checkmate":"Stalemate";
			foreach($this->boards as $board)
				if($this->equals($board))
					$n++;
			if($n==2)
				return "Draw by 3-fold repetition";
			for($r=0; $r<8; $r++)
				for($c=0; $c<8; $c++)
					if($this->board[$r][$c]->type()=="Rk"||$this->board[$r][$c]->type()=="Qn"||$this->board[$r][$c]->type()=="Pn")
						return $s;
					else if($this->board[$r][$c]->color()=='W')
						$w++;
					else if($this->board[$r][$c]->color()=='B')
						$b++;
			return $w<2&&$b<2?"Draw by insufficient material":$s;
		}
		function randomMove()
		{
			$moves=[];
			for($r1=0; $r1<8; $r1++)
				for($c1=0; $c1<8; $c1++)
					for($r2=0; $r2<8; $r2++)
						for($c2=0; $c2<8; $c2++)
							if($this->canMove($r1, $c1, $r2, $c2, true))
								array_push($moves, [$r1, $c1, $r2, $c2]);
			$move=$moves[rand(0, count($moves)-1)];
			$this->move($move[0], $move[1], $move[2], $move[3]);
		}
		function toString()
		{
			$s=" H  G  F  E  D  C  B  A<br/>";
			for($r=0; $r<8;)
			{
				for($c=0; $c<8; $c++)
					$s=$s.$this->board[$r][$c]->toString();
				$s=$s." ".++$r."<br/>";
			}
			return str_replace(" ", "&nbsp;", $s);
		}
	}
	$state=isset($_SESSION["state"])?$_SESSION["state"]:"";
	$move=isset($_POST['move'])?$_POST['move']:"MASON";
	if(isset($_POST['reset']))
	{
		$_SESSION["chess"]=new Chess();
		$_SESSION["state"]="";
		echo($_SESSION["chess"]->toString());
	}
	else if(strlen($move)!=5)
		echo("That is not a valid move!");
	else if(isset($_POST['submit'])&&!(str_starts_with($state, "Draw")||str_ends_with($state, "mate")))
	{
		$r1=$move[1]-1;
		$c1=104-ord($move[0]);
		$r2=$move[4]-1;
		$c2=104-ord($move[3]);
		$chess=$_SESSION["chess"];
		if($chess->canMove($r1, $c1, $r2, $c2, true))
		{
			$chess->move($r1, $c1, $r2, $c2);
			$state=$chess->state();
			if(!(str_starts_with($state, "Draw")||str_ends_with($state, "mate")))
			{
				$chess->randomMove();
				$state=$chess->state();
			}
		}
		else
			$state="That is not a legal move!";
		$_SESSION["state"]=$state;
		echo($chess->toString());
		echo($state);
	}
	else
		echo "You are not in a game!";
?>
</tt>
<form method="POST">
	<input type='submit' name="reset" value="Reset"/>
</form>
<form method="POST">
	<input type='text' id="move" name="move"/><br/>
	<input type='submit' name='submit' value='Move'/>
</form>
<script type="text/javascript">
	document.getElementById('move').focus();
</script>