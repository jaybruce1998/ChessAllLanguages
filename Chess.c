#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
typedef struct square
{
	char color;
	char type[2];
	int moved;
}Square;
typedef struct chess
{
	Square *board[8][8];
	Square ****boards;
	int numBoards, boardsSize, moves, epr, epc, wkr, wkc, bkr, bkc;
	char turn, cap;
}Chess;
int canMove(Chess *chess, int r1, int c1, int r2, int c2, int real);
Square ****getBoards(int n)
{
	Square**** boards=malloc(n*sizeof(Square***));
	for(int i=0; i<n; i++)
	{
		boards[i]=malloc(8*sizeof(Square**));
		for(int j=0; j<8; j++)
			boards[i][j]=malloc(8*sizeof(Square*));
	}
	return boards;
}
void freeBoards(Square**** boards, int n)
{
	for(int i=0; i<n; i++)
	{
		for(int j=0; j<8; j++)
			free(boards[i][j]);
		free(boards[i]);
	}
	free(boards);
}
Square *newSquare(char color, char type[2])
{
	Square *square=malloc(sizeof(Square));
	square->color=color;
	square->type[0]=type[0];
	square->type[1]=type[1];
	square->moved=color==' ';
	return square;
}
Chess *initialize(Square *board[8][8], int wkr, int wkc, int bkr, int bkc, char turn, char cap)
{
	Chess *chess=malloc(sizeof(Chess));
	for(int r=0; r<8; r++)
		for(int c=0; c<8; c++)
			chess->board[r][c]=newSquare(board[r][c]->color, board[r][c]->type);
	chess->boards=getBoards(1);
	chess->numBoards=0;
	chess->boardsSize=1;
	chess->moves=0;
	chess->epr=8;
	chess->wkr=wkr;
	chess->wkc=wkc;
	chess->bkr=bkr;
	chess->bkc=bkc;
	chess->turn=turn;
	chess->cap=cap;
	return chess;
}
Chess *newChess()
{
	Square *board[8][8];
	char pieces[8][2]={"Rk", "Kt", "Bp", "Kg", "Qn", "Bp", "Kt", "Rk"};
	for(int r=2; r<6; r++)
		for(int c=0; c<8; c++)
			board[r][c]=newSquare(' ', "  ");
	for(int c=0; c<8; c++)
	{
		board[0][c]=newSquare('W', pieces[c]);
		board[1][c]=newSquare('W', "Pn");
		board[6][c]=newSquare('B', "Pn");
		board[7][c]=newSquare('B', pieces[c]);
	}
	return initialize(board, 0, 3, 7, 3, 'W', 'B');
}
void changeTurns(Chess *chess)
{
	char t=chess->turn;
	chess->turn=chess->cap;
	chess->cap=t;
}
int canPawnMove(Chess *chess, int r1, int c1, int r2, int c2)
{
	int r=r1-r2, a=abs(r), c=abs(c1-c2);
	if(r==0||a>2||r>0&&chess->turn=='W'||r<0&&chess->turn=='B')
		return 0;
	if(c==1)
		return a==1&&(chess->board[r2][c2]->color==chess->cap||r1==chess->epr&&c2==chess->epc);
	if(c==0&&chess->board[r2][c2]->color==' ')
		return a==1||chess->board[r2+r/2][c2]->color==' '&&!chess->board[r1][c1]->moved;
	return 0;
}
int canKnightMove(Chess *chess, int r1, int c1, int r2, int c2)
{
	int r=abs(r1-r2), c=abs(c1-c2);
	return r<3&&c<3&&r+c==3;
}
int canRookMove(Chess *chess, int r1, int c1, int r2, int c2)
{
	if(r1!=r2&&c1!=c2)
		return 0;
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
			if(chess->board[r][c1]->color!=' ')
				return 0;
		}
	else
		for(int c=c1+1; c<c2; c++)
			if(chess->board[r1][c]->color!=' ')
				return 0;
	return 1;
}
int canBishopMove(Chess *chess, int r1, int c1, int r2, int c2)
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
		return 0;
	if(c<0)
		for(int i=1; i<r; i++)
		{
			if(chess->board[r1+i][c1+i]->color!=' ')
				return 0;
		}
	else
		for(int i=1; i<r; i++)
			if(chess->board[r1+i][c1-i]->color!=' ')
				return 0;
	return 1;
}
int canKingMove(Chess *chess, int r1, int c1, int r2, int c2)
{
	int r=abs(r1-r2), c=c1-c2, a=abs(c);
	if(a<2)
		return r<2;
	if(r>0||chess->board[r1][c1]->moved||a!=2)
		return 0;
	if(c==2)
		return chess->board[r2][c1-1]->color==' '&&chess->board[r2][c2]->color==' '&&!chess->board[r2][0]->moved;
	return chess->board[r2][c1+1]->color==' '&&chess->board[r2][c2]->color==' '&&chess->board[r2][c1+2]->color==' '&&!chess->board[r2][7]->moved;
}
int anyCanMoveTo(Chess *chess, int r2, int c2, int real)
{
	for(int r=0; r<8; r++)
		for(int c=0; c<8; c++)
			if(canMove(chess, r, c, r2, c2, real))
				return 1;
	return 0;
}
int anyCanMove(Chess *chess)
{
	for(int r=0; r<8; r++)
		for(int c=0; c<8; c++)
			if(anyCanMoveTo(chess, r, c, 1))
				return 1;
	return 0;
}
int equals(Chess *chess, Square ***board)
{
	for(int r=0; r<8; r++)
		for(int c=0; c<8; c++)
			if(chess->board[r][c]->color!=board[r][c]->color||strcmp(chess->board[r][c]->type, board[r][c]->type)!=0)
				return 0;
	return 1;
}
void move(Chess *chess, int r1, int c1, int r2, int c2)
{
	for(int r=0; r<8; r++)
		for(int c=0; c<8; c++)
			chess->boards[chess->numBoards][r][c]=newSquare(chess->board[r][c]->color, chess->board[r][c]->type);
	if(++chess->numBoards==chess->boardsSize)
	{
		chess->boardsSize*=2;
		Square ****boards=malloc(chess->boardsSize*sizeof(Square***));
		for(int i=0; i<chess->numBoards; i++)
			boards[i]=chess->boards[i];
		for(int i=chess->numBoards; i<chess->boardsSize; i++)
		{
			boards[i]=malloc(8*sizeof(Square**));
			for(int j=0; j<8; j++)
				boards[i][j]=malloc(8*sizeof(Square*));
		}
		free(chess->boards);
		chess->boards=boards;
	}
	if(strcmp(chess->board[r1][c1]->type, "Kg")==0)
	{
		chess->epr=8;
		if(chess->turn=='W')
		{
			chess->wkr=r2;
			chess->wkc=c2;
		}
		else
		{
			chess->bkr=r2;
			chess->bkc=c2;
		}
		if(abs(c1-c2)==2)
		{
			if(c2==1)
			{
				free(chess->board[r2][2]);
				free(chess->board[r2][0]);
				chess->board[r2][2]=newSquare(chess->turn, "Rk");
				chess->board[r2][0]=newSquare(' ', "  ");
			}
			else
			{
				free(chess->board[r2][4]);
				free(chess->board[r2][7]);
				chess->board[r2][4]=newSquare(chess->turn, "Rk");
				chess->board[r2][7]=newSquare(' ', "  ");
			}
		}
	}
	else if(strcmp(chess->board[r1][c1]->type, "Pn")==0)
	{
		chess->moves=-1;
		if(abs(r1-r2)==2)
		{
			chess->epr=r2;
			chess->epc=c2;
		}
		else
		{
			if(r1==chess->epr&&c2==chess->epc)
				chess->board[r1][c2]=newSquare(' ', "  ");
			else if(r2==0||r2==7)
			{
				chess->board[r1][c1]->type[0]='Q';
				chess->board[r1][c1]->type[1]='n';
			}
			chess->epr=8;
		}
	}
	else
		chess->epr=8;
	if(chess->board[r2][c2]->color==' ')
		chess->moves++;
	else
		chess->moves=0;
	chess->board[r1][c1]->moved=1;
	free(chess->board[r2][c2]);
	chess->board[r2][c2]=chess->board[r1][c1];
	chess->board[r1][c1]=newSquare(' ', "  ");
	changeTurns(chess);
}
int canMove(Chess *chess, int r1, int c1, int r2, int c2, int real)
{
	if(chess->board[r1][c1]->color!=chess->turn||chess->board[r2][c2]->color==chess->turn)
		return 0;
	if(real)
	{
		Chess *other=initialize(chess->board, chess->wkr, chess->wkc, chess->bkr, chess->bkc, chess->turn, chess->cap);
		if(strcmp(other->board[r1][c1]->type, "Kg")==0&&abs(c1-c2)==2)
		{
	  		changeTurns(other);
	  		if(anyCanMoveTo(other, r1, c1, 0))
	  			return 0;
	  		changeTurns(other);
	  		int c=c1+(c2-c1)/2;
	  		move(other, r1, c1, r2, c);
	  		if(anyCanMoveTo(other, r2, c, 0))
	  			return 0;
	  		move(other, r2, c, r1, c1);
	  	}
	  	move(other, r1, c1, r2, c2);
	  	if(chess->turn=='W')
	  	{
	  		if(anyCanMoveTo(other, other->wkr, other->wkc, 0))
	  			return 0;
	  	}
	  	else if(anyCanMoveTo(other, other->bkr, other->bkc, 0))
	  		return 0;
	}
	if(strcmp(chess->board[r1][c1]->type, "Pn")==0)
		return canPawnMove(chess, r1, c1, r2, c2);
	else if(strcmp(chess->board[r1][c1]->type, "Kt")==0)
		return canKnightMove(chess, r1, c1, r2, c2);
	else if(strcmp(chess->board[r1][c1]->type, "Rk")==0)
		return canRookMove(chess, r1, c1, r2, c2);
	else if(strcmp(chess->board[r1][c1]->type, "Bp")==0)
		return canBishopMove(chess, r1, c1, r2, c2);
	else if(strcmp(chess->board[r1][c1]->type, "Qn")==0)
		return canRookMove(chess, r1, c1, r2, c2)||canBishopMove(chess, r1, c1, r2, c2);
	return canKingMove(chess, r1, c1, r2, c2);
}
char* state(Chess *chess)
{
	if(chess->moves==100)
		return "Draw by 50-move rule";
	char* s="";
	int n=0, w=0, b=0;
	changeTurns(chess);
	if(chess->turn=='W'&&anyCanMoveTo(chess, chess->bkr, chess->bkc, 0)||chess->turn=='B'&&anyCanMoveTo(chess, chess->wkr, chess->wkc, 0))
		s="Check";
	changeTurns(chess);
	if(!anyCanMove(chess))
		return strcmp(s, "Check")==0?"Checkmate":"Stalemate";
	for(int i=0; i<chess->numBoards; i++)
		if(equals(chess, chess->boards[i]))
			n++;
	if(n==2)
		return "Draw by 3-fold repetition";
	for(int r=0; r<8; r++)
		for(int c=0; c<8; c++)
			if(strcmp(chess->board[r][c]->type, "Rk")==0||strcmp(chess->board[r][c]->type, "Bp")==0||strcmp(chess->board[r][c]->type, "Qn")==0)
				return s;
			else if(chess->board[r][c]->color=='W')
				w++;
			else if(chess->board[r][c]->color=='B')
				b++;
	return w<2&&b<2?"Draw by insufficient material":s;
}
void randomMove(Chess *chess)
{
	int moves[200][4];
	int i=0;
	for(int r1=0; r1<8; r1++)
		for(int c1=0; c1<8; c1++)
			for(int r2=0; r2<8; r2++)
				for(int c2=0; c2<8; c2++)
					if(canMove(chess, r1, c1, r2, c2, 1))
					{
						moves[i][0]=r1;
						moves[i][1]=c1;
						moves[i][2]=r2;
						moves[i++][3]=c2;
					}
	int *m=moves[rand()%i];
	move(chess, m[0], m[1], m[2], m[3]);
}
void printBoard(Chess *chess)
{
	printf(" h  g  f  e  d  c  b  a\n");
	for(int r=0; r<8;)
	{
		for(int c=0; c<8; c++)
			printf("%c%s", chess->board[r][c]->color, chess->board[r][c]->type);
		printf(" %d\n", ++r);
	}
}
int endsWith(const char *str, const char *suffix)
{
    if (!str || !suffix)
        return 0;
    size_t lenstr = strlen(str);
    size_t lensuffix = strlen(suffix);
    if (lensuffix > lenstr)
        return 0;
    return strncmp(str + lenstr - lensuffix, suffix, lensuffix) == 0;
}
int main()
{
	srand(time(NULL));
	Chess *chess=newChess();
	char *status="";
	printBoard(chess);
	while(strncmp("Draw", status, 4)!=0&&!endsWith(status, "mate"))
	{
		for(int b=1; b;)
		{
			char m[10];
			fgets(m, 10, stdin);
			int r1=m[1]-'1', c1='h'-m[0], r2=m[4]-'1', c2='h'-m[3];
			if(r1<0||r1>7||c1<0||c1>7||r2<0||r2>7||c2<0||c2>7)
				printf("That is not a valid move!\n");
			else if(canMove(chess, r1, c1, r2, c2, 1))
			{
				move(chess, r1, c1, r2, c2);
				status=state(chess);
				printBoard(chess);
				printf("%s\n", status);
				b=0;
			}
			else
				printf("That is not a legal move!\n");
		}
		if(strncmp("Draw", status, 4)!=0&&!endsWith(status, "mate"))
		{
			randomMove(chess);
			status=state(chess);
			printBoard(chess);
			printf("%s\n", status);
		}
	}
	return 0;
}