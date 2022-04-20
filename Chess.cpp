#include <iostream>
#include <vector>
using namespace std;
class Square
{
private:
	char color;
	string type;
	bool moved;
public:
	Square()
	{
		color=' ';
		type="  ";
		moved=true;
	}
	Square(char otherColor, string otherType)
	{
		color=otherColor;
		type=otherType;
		moved=false;
	}
	void move()
	{
		moved=true;
	}
	void promote()
	{
		type="Qn";
	}
	char getColor()
	{
		return color;
	}
	string getType()
	{
		return type;
	}
	bool hasMoved()
	{
		return moved;
	}
	bool equals(Square square)
	{
		return color==square.getColor()&&type==square.getType();
	}
	string toString()
	{
		return color+type;
	}
};
class Chess
{
private:
	Square board[8][8];
	vector<vector<vector<Square> > > boards;
	int moves, epr, epc, wkr, wkc, bkr, bkc;
	char turn, cap;
	void initialize(int wkr, int wkc, int bkr, int bkc, char turn, char cap)
	{
		this->wkr=wkr;
		this->wkc=wkc;
		this->bkr=bkr;
		this->bkc=bkc;
		this->turn=turn;
		this->cap=cap;
		epr=8;
		moves=0;
	}
	void changeTurns()
	{
		char t=turn;
		turn=cap;
		cap=t;
	}
	bool canPawnMove(int r1, int c1, int r2, int c2)
	{
		int r=r1-r2, a=abs(r), c=abs(c1-c2);
		if(r==0||a>2||r>0&&turn=='W'||r<0&&turn=='B')
			return false;
		if(c==1)
			return a==1&&(board[r2][c2].getColor()==cap||r1==epr&&c2==epc);
		if(c==0&&board[r2][c2].getColor()==' ')
			return a==1||board[r2+r/2][c2].getColor()==' '&&!board[r1][c1].hasMoved();
		return false;
	}
	bool canKnightMove(int r1, int c1, int r2, int c2)
	{
		int r=abs(r1-r2), c=abs(c1-c2);
		return r<3&&c<3&&r+c==3;
	}
	bool canRookMove(int r1, int c1, int r2, int c2)
	{
		if(r1!=r2&&c1!=c2)
			return false;
		if(r1>r2)
		{
			int t=r1;
			r1=r2;
			r2=t;
		}
		else if(c1>c2)
		{
			int t=c1;
			c1=c2;
			c2=t;
		}
		if(r1!=r2)
			for(int r=r1+1; r<r2; r++)
			{
				if(board[r][c1].getColor()!=' ')
					return false;
			}
		else
			for(int c=c1+1; c<c2; c++)
				if(board[r1][c].getColor()!=' ')
					return false;
		return true;
	}
	bool canBishopMove(int r1, int c1, int r2, int c2)
	{
		if(r1>r2)
		{
			int t=r1;
			r1=r2;
			r2=t;
			t=c1;
			c1=c2;
			c2=t;
		}
		int r=r2-r1, c=c1-c2;
		if(r!=abs(c))
			return false;
		if(c<0)
			for(int i=1; i<r; i++)
			{
				if(board[r1+i][c1+i].getColor()!=' ')
					return false;
			}
		else
			for(int i=1; i<r; i++)
				if(board[r1+i][c1-i].getColor()!=' ')
					return false;
		return true;
	}
	bool canKingMove(int r1, int c1, int r2, int c2)
	{
		int r=abs(r1-r2), c=c1-c2, a=abs(c);
		if(a<2)
			return r<2;
		if(r>0||board[r1][c1].hasMoved()||a!=2)
			return false;
		if(c==2)
			return board[r2][c1-1].getColor()==' '&&board[r2][c2].getColor()==' '&&!board[r2][0].hasMoved();
		return board[r2][c1+1].getColor()==' '&&board[r2][c2].getColor()==' '&&board[r2][c1+2].getColor()==' '&&!board[r2][7].hasMoved();
	}
	vector<vector<Square> > boardCopy()
	{
		vector<vector<Square> > copy(8);
		for(int r=0; r<8; r++)
			for(int c=0; c<8; c++)
				copy[r].push_back(Square(board[r][c].getColor(), board[r][c].getType()));
		return copy;
	}
	bool anyCanMoveTo(int r2, int c2, bool real)
	{
		for(int r=0; r<8; r++)
			for(int c=0; c<8; c++)
				if(canMove(r, c, r2, c2, real))
					return true;
		return false;
	}
	bool anyCanMove()
	{
		for(int r=0; r<8; r++)
			for(int c=0; c<8; c++)
				if(anyCanMoveTo(r, c, true))
					return true;
		return false;
	}
	bool equals(vector<vector<Square> > board)
	{
		for(int r=0; r<8; r++)
			for(int c=0; c<8; c++)
				if(!this->board[r][c].equals(board[r][c]))
					return false;
		return true;
	}

public:
	Chess()
	{
		string pieces[]={"Rk", "Kt", "Bp", "Kg", "Qn", "Bp", "Kt", "Rk"};
		for(int c=0; c<8; c++)
	  	{
	  		board[0][c]=Square('W', pieces[c]);
	  		board[1][c]=Square('W', "Pn");
	  		board[6][c]=Square('B', "Pn");
	  		board[7][c]=Square('B', pieces[c]);
	  	}
	  	initialize(0, 3, 7, 3, 'W', 'B');
	}
	Chess(vector<vector<Square> > board, int wkr, int wkc, int bkr, int bkc, char turn, char cap)
	{
		for(int r=0; r<8; r++)
			for(int c=0; c<8; c++)
				this->board[r][c]=Square(board[r][c].getColor(), board[r][c].getType());
		initialize(wkr, wkc, bkr, bkc, turn, cap);
	}
	void move(int r1, int c1, int r2, int c2)
	{
		boards.push_back(boardCopy());
		if(board[r1][c1].getType()=="Kg")
		{
			epr=8;
			if(turn=='W')
			{
				wkr=r2;
				wkc=c2;
			}
			else
			{
				bkr=r2;
				bkc=c2;
			}
			if(abs(c1-c2)==2)
			{
				if(c2==1)
				{
					board[r2][2]=Square(board[r2][0].getColor(), board[r2][0].getType());
					board[r2][0]=Square(' ', "  ");
				}
				else
				{
					board[r2][4]=Square(board[r2][7].getColor(), board[r2][7].getType());
					board[r2][7]=Square(' ', "  ");
				}
			}
		}
		else if(board[r1][c1].getType()=="Pn")
		{
			moves=-1;
			if(abs(r1-r2)==2)
			{
				epr=r2;
				epc=c2;
			}
			else
			{
				if(r1==epr&&c2==epc)
					board[r1][c2]=Square(' ', "  ");
				else if(r2==0||r2==7)
					board[r1][c1].promote();
				epr=8;
			}
		}
		else
			epr=8;
		if(board[r2][c2].getColor()==' ')
			moves++;
		else
			moves=0;
		board[r1][c1].move();
		board[r2][c2]=board[r1][c1];
		board[r1][c1]=Square(' ', "  ");
		changeTurns();
	}
	bool canMove(int r1, int c1, int r2, int c2, bool real)
	{
		if(board[r1][c1].getColor()!=turn||board[r2][c2].getColor()==turn)
			return false;
		if(real)
		{
			Chess chess(boardCopy(), wkr, wkc, bkr, bkc, turn, cap);
			if(board[r1][c1].getType()=="Kg"&&abs(c1-c2)==2)
			{
		  		chess.changeTurns();
		  		if(chess.anyCanMoveTo(r1, c1, false))
		  			return false;
		  		chess.changeTurns();
		  		int c=c1+(c2-c1)/2;
		  		chess.move(r1, c1, r2, c);
		  		if(chess.anyCanMoveTo(r2, c, false))
		  			return false;
		  		chess.move(r2, c, r1, c1);
		  	}
		  	chess.move(r1, c1, r2, c2);
		  	if(turn=='W')
		  	{
		  		if(chess.anyCanMoveTo(chess.wkr, chess.wkc, false))
		  			return false;
		  	}
		  	else if(chess.anyCanMoveTo(chess.bkr, chess.bkc, false))
		  		return false;
		}
		if(board[r1][c1].getType()=="Pn")
			return canPawnMove(r1, c1, r2, c2);
		else if(board[r1][c1].getType()=="Kt")
			return canKnightMove(r1, c1, r2, c2);
		else if(board[r1][c1].getType()=="Rk")
			return canRookMove(r1, c1, r2, c2);
		else if(board[r1][c1].getType()=="Bp")
			return canBishopMove(r1, c1, r2, c2);
		else if(board[r1][c1].getType()=="Qn")
			return canRookMove(r1, c1, r2, c2)||canBishopMove(r1, c1, r2, c2);
		return canKingMove(r1, c1, r2, c2);
	}
	string state()
	{
		if(moves==100)
			return "Draw by 50-move rule";
		string s="";
		int n=0, w=0, b=0;
		changeTurns();
		if(turn=='W'&&anyCanMoveTo(bkr, bkc, false)||turn=='B'&&anyCanMoveTo(wkr, wkc, false))
			s="Check";
		changeTurns();
		if(!anyCanMove())
			return s=="Check"?"Checkmate":"Stalemate";
		for(int i=0; i<boards.size(); i++)
			if(equals(boards[i]))
				n++;
		if(n==2)
			return "Draw by 3-fold repetition";
		for(int r=0; r<8; r++)
			for(int c=0; c<8; c++)
				if(board[r][c].getType()=="Rk"||board[r][c].getType()=="Qn"||board[r][c].getType()=="Pn")
					return s;
				else if(board[r][c].getColor()=='W')
					w++;
				else if(board[r][c].getColor()=='B')
					b++;
		return w<2&&b<2?"Draw by insufficient material":s;
	}
	void randomMove()
	{
		vector<vector<int> > moves;
		for(int r1=0; r1<8; r1++)
			for(int c1=0; c1<8; c1++)
				for(int r2=0; r2<8; r2++)
					for(int c2=0; c2<8; c2++)
						if(canMove(r1, c1, r2, c2, true))
						{
							vector<int> myMove{r1, c1, r2, c2};
							moves.push_back(myMove);
						}
		vector<int> move=moves[rand()%moves.size()];
		this->move(move[0], move[1], move[2], move[3]);
	}
	string toString()
	{
		string s=" h  g  f  e  d  c  b  a\n";
		for(int r=0; r<8;)
		{
			for(int c=0; c<8; c++)
				s+=board[r][c].toString();
			s+=' '+to_string(++r)+"\n";
		}
		return s;
	}
};
int main()
{
	srand((unsigned) time(0));
	Chess chess;
	string state="";
	cout<<chess.toString()<<endl;
	while(!(state.find("Draw")==0||state.size()>3&&state.compare(state.size()-4, state.size(), "mate")==0))
	{
		string move;
		bool b=true;
		while(b)
		{
			cin >> move;
			int r1=move[1]-'1', c1='h'-move[0], r2=move[4]-'1', c2='h'-move[3];
			if(r1<0||r1>7||c1<0||c1>7||r2<0||r2>7||c2<0||c2>7)
				cout<<"That is not a valid move!\n";
			else if(chess.canMove(r1, c1, r2, c2, true))
			{
				chess.move(r1, c1, r2, c2);
				state=chess.state();
				cout<<chess.toString()<<state<<endl;
				b=false;
			}
			else
				cout<<"That is not a legal move!\n";
		}
		if(!(state.find("Draw")==0||state.size()>3&&state.compare(state.size()-4, state.size(), "mate")==0))
		{
			chess.randomMove();
			state=chess.state();
			cout<<chess.toString()<<state<<endl;
		}
	}
	return 0;
}