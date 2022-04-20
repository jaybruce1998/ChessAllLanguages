class Square {
  constructor(color, type) {
  	this.color=color;
  	this.type=type;
  	this.moved=color===' ';
  }
  equals(square)
  {
  	return this.color===square.color&&this.type===square.type;
  }
  toString()
  {
  	return this.color+this.type;
  }
}
class Chess {
  constructor() {
  	const pieces=["Rk", "Kt", "Bp", "Kg", "Qn", "Bp", "Kt", "Rk"];
  	this.boards=[];
  	this.moves=0;
  	this.setVariables([], 8, 8, 0, 3, 7, 3, "W", "B");
  	for(let r=0; r<8; r++)
  	{
  		this.board.push([]);
  		for(let c=0; c<8; c++)
  			this.board[r].push(new Square(" ", "  "));
  	}
  	for(let c=0; c<8; c++)
  	{
  		this.board[0][c]=new Square("W", pieces[c]);
  		this.board[1][c]=new Square("W", "Pn");
  		this.board[6][c]=new Square("B", "Pn");
  		this.board[7][c]=new Square("B", pieces[c]);
  	}
  }
  boardCopy()
  {
  	let board=[];
  	for(let r=0; r<8; r++)
  	{
  		board.push([]);
  		for(let c=0; c<8; c++)
  			board[r].push(new Square(this.board[r][c].color, this.board[r][c].type));
  	}
  	return board;
  }
  setVariables(board, epr, epc, wkr, wkc, bkr, bkc, turn, cap)
  {
  	this.board=board;
  	this.epr=epr;
  	this.epc=epc;
  	this.wkr=wkr;
  	this.wkc=wkc;
  	this.bkr=bkr;
  	this.bkc=bkc;
  	this.turn=turn;
  	this.cap=cap;
  }
  changeTurns()
  {
  	const t=this.turn;
  	this.turn=this.cap;
  	this.cap=t;
  }
  canPawnMove(r1, c1, r2, c2)
  {
  	const r=r1-r2, a=Math.abs(r), c=Math.abs(c1-c2);
  	if(r===0||a>2||r>0&&this.turn==="W"||r<0&&this.turn==="B")
  		return false;
  	if(c===1)
  		return a===1&&(this.board[r2][c2].color===this.cap||r1===this.epr&&c2===this.epc);
  	if(c===0&&this.board[r2][c2].color===" ")
  		return a===1||this.board[r2+r/2][c2].color===" "&&!this.board[r1][c1].moved;
  	return false;
  }
  canKnightMove(r1, c1, r2, c2)
  {
  	const r=Math.abs(r1-r2), c=Math.abs(c1-c2);
  	return r<3&&c<3&&r+c===3;
  }
  canRookMove(r1, c1, r2, c2)
  {
  	if(r1!==r2&&c1!==c2)
  		return false;
  	if(r1>r2)
  	{
  		const t=r1;
  		r1=r2;
  		r2=t;
  	}
  	else if(c1>c2)
  	{
  		const t=c1;
  		c1=c2;
  		c2=t;
  	}
  	if(r1!==r2)
  		for(let r=r1+1; r<r2; r++)
  		{
  			if(this.board[r][c1].color!==" ")
  				return false;
  		}
  	else
  		for(let c=c1+1; c<c2; c++)
  			if(this.board[r1][c].color!==" ")
  				return false;
  	return true;
  }
  canBishopMove(r1, c1, r2, c2)
  {
  	if(r1>r2)
  	{
  		let t=r1;
  		r1=r2;
  		r2=t;
  		t=c1;
  		c1=c2;
  		c2=t;
  	}
  	const r=r2-r1, c=c1-c2;
  	if(r!==Math.abs(c))
  		return false;
  	if(c<0)
  		for(let i=1; i<r; i++)
  		{
  			if(this.board[r1+i][c1+i].color!==" ")
  				return false;
  		}
  	else
  		for(let i=1; i<r; i++)
  			if(this.board[r1+i][c1-i].color!==" ")
  				return false;
  	return true;
  }
  canKingMove(r1, c1, r2, c2)
  {
  	const r=Math.abs(r1-r2), c=c1-c2, a=Math.abs(c);
  	if(a<2)
  		return r<2;
  	if(r>0||this.board[r1][c1].moved||a!==2)
  		return false;
  	if(c===2)
  		return this.board[r2][c1-1].color===" "&&this.board[r2][c2].color===" "&&!this.board[r2][0].moved;
  	return this.board[r2][c1+1].color===" "&&this.board[r2][c2].color===" "&&this.board[r2][c1+2].color===" "&&!this.board[r2][7].moved;
  }
  move(r1, c1, r2, c2)
  {
  	this.boards.push(this.boardCopy());
  	if(this.board[r1][c1].type==="Kg")
  	{
  		this.epr=8;
  		if(this.turn==="W")
  		{
  			this.wkr=r2;
  			this.wkc=c2;
  		}
  		else
  		{
  			this.bkr=r2;
  			this.bkc=c2;
  		}
  		if(Math.abs(c1-c2)===2)
  			if(c2===1)
  			{
  				this.board[r2][2]=new Square(this.board[r2][0].color, this.board[r2][0].type);
  				this.board[r2][0]=new Square(" ", "  ");
  			}
  			else
  			{
  				this.board[r2][4]=new Square(this.board[r2][7].color, this.board[r2][7].type);
  				this.board[r2][7]=new Square(" ", "  ");
  			}
  	}
  	else if(this.board[r1][c1].type==="Pn")
  	{
  		this.moves=-1;
  		if(Math.abs(r1-r2)===2)
  		{
  			this.epr=r2;
  			this.epc=c2;
  		}
  		else
  		{
  			if(r1===this.epr&&c2===this.epc)
  				this.board[r1][c2]=new Square(" ", "  ");
  			else if(r2===0||r2===7)
  				this.board[r1][c1].type="Qn";
  			this.epr=8;
  		}
  	}
  	else
  		this.epr=8;
  	if(this.board[r2][c2].color===" ")
  		this.moves++;
  	else
  		this.moves=0;
  	this.board[r2][c2]=new Square(this.board[r1][c1].color, this.board[r1][c1].type);
    this.board[r2][c2].moved=true;
  	this.board[r1][c1]=new Square(" ", "  ");
  	this.changeTurns();
  }
  canMove(r1, c1, r2, c2, real)
  {
  	if(this.board[r1][c1].color!==this.turn||this.board[r2][c2].color===this.turn)
  		return false;
  	if(real)
  	{
  		const chess=new Chess();
  		chess.setVariables(this.boardCopy(), this.epr, this.epc, this.wkr, this.wkc, this.bkr, this.bkc, this.turn, this.cap);
  		if(this.board[r1][c1].type==="Kg"&&Math.abs(c1-c2)===2)
  		{
	  		chess.changeTurns();
	  		if(chess.anyCanMoveTo(r1, c1, false))
	  			return false;
	  		chess.changeTurns();
	  		const c=c1+(c2-c1)/2;
	  		chess.move(r1, c1, r2, c);
	  		if(chess.anyCanMoveTo(r2, c, false))
	  			return false;
	  		chess.move(r2, c, r1, c1);
	  	}
	  	chess.move(r1, c1, r2, c2);
	  	if(this.turn==="W")
	  	{
	  		if(chess.anyCanMoveTo(chess.wkr, chess.wkc, false))
	  			return false;
	  	}
	  	else if(chess.anyCanMoveTo(chess.bkr, chess.bkc, false))
	  		return false;
  	}
  	if(this.board[r1][c1].type==="Pn")
  		return this.canPawnMove(r1, c1, r2, c2);
  	else if(this.board[r1][c1].type==="Kt")
  		return this.canKnightMove(r1, c1, r2, c2);
  	else if(this.board[r1][c1].type==="Rk")
  		return this.canRookMove(r1, c1, r2, c2);
  	else if(this.board[r1][c1].type==="Bp")
  		return this.canBishopMove(r1, c1, r2, c2);
  	else if(this.board[r1][c1].type==="Qn")
  		return this.canRookMove(r1, c1, r2, c2)||this.canBishopMove(r1, c1, r2, c2);
  	return this.canKingMove(r1, c1, r2, c2);
  }
  anyCanMoveTo(r2, c2, real)
  {
  	for(let r=0; r<8; r++)
  		for(let c=0; c<8; c++)
  			if(this.canMove(r, c, r2, c2, real))
  				return true;
  	return false;
  }
  anyCanMove()
  {
  	for(let r=0; r<8; r++)
  		for(let c=0; c<8; c++)
  			if(this.anyCanMoveTo(r, c, true))
  				return true;
  	return false;
  }
  equals(board)
  {
  	for(let r=0; r<8; r++)
  		for(let c=0; c<8; c++)
  			if(!this.board[r][c].equals(board[r][c]))
  				return false;
  	return true;
  }
  state()
  {
  	if(this.moves===100)
  		return "Draw by 50-move rule";
  	let s="", n=0, w=0, b=0;
  	this.changeTurns();
  	if(this.turn==="W"&&this.anyCanMoveTo(this.bkr, this.bkc, false)||this.turn==="B"&&this.anyCanMoveTo(this.wkr, this.wkc, false))
  		s="Check";
  	this.changeTurns();
  	if(!this.anyCanMove())
  		return s==="Check"?"Checkmate":"Stalemate";
  	for(let board of this.boards)
  		if(this.equals(board))
  			n++;
  	if(n===2)
  		return "Draw by 3-fold repetition";
  	for(let r=0; r<8; r++)
  		for(let c=0; c<8; c++)
  			if(this.board[r][c].type==="Rk"||this.board[r][c].type==="Qn"||this.board[r][c].type==="Pn")
  				return s;
  			else if(this.board[r][c].color==="W")
  				w++;
  			else if(this.board[r][c].color==="B")
  				b++;
  	return w<2&&b<2?"Draw by insufficient material":s;
  }
  moveString(r1, c1, r2, c2)
  {
  	return String.fromCharCode(104-c1)+(+r1+1)+" to "+String.fromCharCode(104-c2)+(+r2+1);
  }
  randomMove()
  {
  	let moves=[];
  	for(let r1=0; r1<8; r1++)
  		for(let c1=0; c1<8; c1++)
  			for(let r2=0; r2<8; r2++)
  				for(let c2=0; c2<8; c2++)
  					if(this.canMove(r1, c1, r2, c2, true))
  						moves.push([r1, c1, r2, c2]);
  	const move=moves[parseInt(Math.random()*moves.length)];
  	this.move(move[0], move[1], move[2], move[3]);
  	return this.moveString(...move);
  }
  toString()
  {
  	return (" H  G  F  E  D  C  B  A<br/>"+this.board.map((a, i)=>a.join("")+" "+(i+1)).join("<br/>")).replace(/ /g, "&nbsp;");
  }
}
const chess=new Chess();
function move(move)
{
	const r1=move[1]-1, c1=104-move.charCodeAt(), r2=move[4]-1, c2=104-move.charCodeAt(3);
	if(chess.canMove(r1, c1, r2, c2, true))
	{
		chess.move(r1, c1, r2, c2);
		chess.randomMove();
		document.getElementById("board").innerHTML=chess.toString();
	}
	else
		chess.randomMove();
	document.getElementById("move").value="";
	document.getElementById("move").focus();
}