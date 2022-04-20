class Square
	def initialize(color, type)
		@color=color
		@type=type
		@moved=color==' '
	end
	def equals(square)
		return @color==square.color()&&@type==square.type()
	end
	def promote()
		@type="Qn"
	end
	def move()
		@moved=true
	end
	def color()
		return @color
	end
	def type()
		return @type
	end
	def moved()
		return @moved
	end
	def toString()
		return @color+@type
	end
end
class Chess
	def initialize()
		pieces=["Rk", "Kt", "Bp", "Kg", "Qn", "Bp", "Kt", "Rk"]
		setVariables([], 0, 3, 7, 3, 'W', 'B')
		for r in 0..7
			@board[r]=[]
			for c in 0..7
				@board[r][c]=Square.new(' ', "  ")
			end
		end
		for c in 0..7
			@board[0][c]=Square.new('W', pieces[c])
			@board[1][c]=Square.new('W', "Pn")
			@board[6][c]=Square.new('B', "Pn")
			@board[7][c]=Square.new('B', pieces[c])
		end
		@moves=0
	end
	def boardCopy()
		board=[]
		for r in 0..7
			board[r]=[]
			for c in 0..7
				board[r][c]=Square.new(@board[r][c].color(), @board[r][c].type())
			end
		end
		return board
	end
	def setVariables(board, wkr, wkc, bkr, bkc, turn, cap)
		@board=board
		@wkr=wkr
		@wkc=wkc
		@bkr=bkr
		@bkc=bkc
		@turn=turn
		@cap=cap
		@boards=[]
		@epr=8
	end
	def changeTurns()
		t=@turn
		@turn=@cap
		@cap=t
	end
	def canPawnMove(r1, c1, r2, c2)
		r=r1-r2
		a=r.abs()
		c=(c1-c2).abs()
		if(r==0||a>2||r>0&&@turn=='W'||r<0&&@turn=='B')
			return false
		end
		if(c==1)
			return a==1&&(@board[r2][c2].color()==@cap||r1==@epr&&c2==@epc)
		end
		if(c==0&&@board[r2][c2].color()==' ')
			return a==1||(@board[r2+r/2][c2].color()==' '&&(not @board[r1][c1].moved()))
		end
		return false
	end
	def canKnightMove(r1, c1, r2, c2)
		r=(r1-r2).abs()
		c=(c1-c2).abs()
		return r<3&&c<3&&r+c==3
	end
	def canRookMove(r1, c1, r2, c2)
		if(r1!=r2&&c1!=c2)
			return false
		end
		if(r1>r2)
			t=r1
			r1=r2
			r2=t
		elsif(c1>c2)
			t=c1
			c1=c2
			c2=t
		end
		if(r1!=r2)
			for r in r1+1...r2
				if(@board[r][c2].color()!=' ')
					return false
				end
			end
		else
			for c in c1+1...c2
				if(@board[r2][c].color()!=' ')
					return false
				end
			end
		end
		return true
	end
	def canBishopMove(r1, c1, r2, c2)
		if(r1>r2)
			t=r1
			r1=r2
			r2=t
			t=c1
			c1=c2
			c2=t
		end
		r=r2-r1
		c=c1-c2
		if(r!=c.abs())
			return false
		end
		if(c<0)
			for i in 1...r
				if(@board[r1+i][c1+i].color()!=' ')
					return false
				end
			end
		else
			for i in 1...r
				if(@board[r1+i][c1-i].color()!=' ')
					return false
				end
			end
		end
		return true
	end
	def canKingMove(r1, c1, r2, c2)
		r=(r1-r2).abs()
		c=c1-c2
		a=c.abs()
		if(a<2)
			return r<2
		end
		if(r>0||@board[r1][c1].moved()||a!=2)
			return false
		end
		if(c==2)
			return @board[r2][c1-1].color()==' '&&@board[r2][c2].color()==' '&&!@board[r2][0].moved()
		end
		return @board[r2][c1+1].color()==' '&&@board[r2][c1+2].color()==' '&&@board[r2][c2].color()==' '&&!@board[r2][7].moved()
	end
	def move(r1, c1, r2, c2)
		@boards.push(boardCopy())
		if(@board[r1][c1].type()=="Kg")
			@epr=8
			if(@turn=='W')
				@wkr=r2
				@wkc=c2
			else
				@bkr=r2
				@bkc=c2
			end
			if((c1-c2).abs()==2)
				if(c2==1)
					@board[r2][2]=Square.new(@turn, "Rk")
					@board[r2][0]=Square.new(' ', "  ")
				else
					@board[r2][4]=Square.new(@turn, "Rk")
					@board[r2][7]=Square.new(' ', "  ")
				end
			end
		elsif(@board[r1][c1].type()=="Pn")
			@moves=-1
			if((r1-r2).abs()==2)
				@epr=r2
				@epc=c2
			else
				if(@epr==r1&&@epc==c2)
					@board[r1][c2]=Square.new(' ', "  ")
				elsif(r2==0||r2==7)
					@board[r2][c2].promote()
				end
				@epr=8
			end
		else
			@epr=8
		end
		if(@board[r2][c2].color()==' ')
			@moves+=1
		else
			@moves=0
		end
		@board[r2][c2]=Square.new(@turn, @board[r1][c1].type())
		@board[r2][c2].move()
		@board[r1][c1]=Square.new(' ', "  ")
		changeTurns()
	end
	def wkr()
		return @wkr
	end
	def wkc()
		return @wkc
	end
	def bkr()
		return @bkr
	end
	def bkc()
		return @bkc
	end
	def canMove(r1, c1, r2, c2, real)
		if(@board[r1][c1].color()!=@turn||@board[r2][c2].color()==@turn)
			return false
		end
		if(real)
			chess=Chess.new()
			chess.setVariables(boardCopy(), @wkr, @wkc, @bkr, @bkc, @turn, @cap)
			if(@board[r1][c1].type()=="Kg"&&(c1-c2).abs()==2)
				chess.changeTurns()
				if(chess.anyCanMoveTo(r1, c1, false))
					return false
				end
				chess.changeTurns()
				c=c1+(c2-c1)/2
				chess.move(r1, c1, r2, c)
				if(chess.anyCanMoveTo(r2, c, false))
					return false
				end
				chess.move(r2, c, r1, c1)
			end
			chess.move(r1, c1, r2, c2)
			if(@turn=='W')
				if(chess.anyCanMoveTo(chess.wkr(), chess.wkc(), false))
					return false
				end
			elsif(chess.anyCanMoveTo(chess.bkr(), chess.bkc(), false))
				return false
			end
		end
		if(@board[r1][c1].type=="Pn")
			return canPawnMove(r1, c1, r2, c2)
		elsif(@board[r1][c1].type=="Kt")
			return canKnightMove(r1, c1, r2, c2)
		elsif(@board[r1][c1].type=="Rk")
			return canRookMove(r1, c1, r2, c2)
		elsif(@board[r1][c1].type=="Bp")
			return canBishopMove(r1, c1, r2, c2)
		elsif(@board[r1][c1].type=="Qn")
			return canRookMove(r1, c1, r2, c2)||canBishopMove(r1, c1, r2, c2)
		end
		return canKingMove(r1, c1, r2, c2)
	end
	def anyCanMoveTo(r2, c2, real)
		for r in 0..7
			for c in 0..7
				if(canMove(r, c, r2, c2, real))
					return true
				end
			end
		end
		return false
	end
	def anyCanMove()
		for r in 0..7
			for c in 0..7
				if(anyCanMoveTo(r, c, true))
					return true
				end
			end
		end
		return false
	end
	def equals(board)
		for r in 0..7
			for c in 0..7
				if(!@board[r][c].equals(board[r][c]))
					return false
				end
			end
		end
		return true
	end
	def state()
		if(@moves==100)
			return "Draw by 50-move rule"
		end
	  	s=""
	  	n=0
	  	w=0
	  	b=0
	  	changeTurns()
	  	if(@turn=='W'&&anyCanMoveTo(@bkr, @bkc, false)||@turn=='B'&&anyCanMoveTo(@wkr, @wkc, false))
	  		s="Check"
	  	end
	  	changeTurns()
	  	if(!anyCanMove())
	  		if(s=="Check")
	  			return "Checkmate"
	  		end
	  		return "Stalemate"
	  	end
	  	for board in @boards
	  		if(equals(board))
	  			n+=1
	  		end
	  	end
	  	if(n==2)
	  		return "Draw by 3-fold repetition"
	  	end
	  	for r in 0..7
	  		for c in 0..7
	  			if(@board[r][c].type()=="Rk"||@board[r][c].type()=="Qn"||@board[r][c].type()=="Pn")
	  				return s
	  			elsif(@board[r][c].color()=='W')
	  				w+=1
	  			elsif(@board[r][c].color()=='B')
	  				b+=1
	  			end
	  		end
	  	end
	  	if(w<2&&b<2)
	  		return "Draw by insufficient material"
	  	end
	  	return s
	end
	def randomMove()
		moves=[]
		for r1 in 0..7
			for c1 in 0..7
				for r2 in 0..7
					for c2 in 0..7
						if(canMove(r1, c1, r2, c2, true))
							moves.push([r1, c1, r2, c2])
						end
					end
				end
			end
		end
		move=moves[(rand()*moves.length()).to_i()]
		move(move[0], move[1], move[2], move[3])
	end
	def toString()
		s=" h  g  f  e  d  c  b  a\n"
		for r in 0..7
			for c in 0..7
				s+=@board[r][c].toString()
			end
			s+=" "+(r+1).to_s()+"\n"
		end
		return s
	end
end
chess=Chess.new()
state=""
puts(chess.toString())
while(!(state.start_with?("Draw")||state.end_with?("mate")))
	b=true
	while(b)
		move=gets()
		r1=move[1].to_i()-1
		c1=104-move[0].ord()
		r2=move[4].to_i()-1
		c2=104-move[3].ord()
		if(r1<0||r1>7||c1<0||c1>7||r2<0||r2>7||c2<0||c2>7)
			puts("That is not a valid move!");
		elsif(chess.canMove(r1, c1, r2, c2, true))
			chess.move(r1, c1, r2, c2)
			state=chess.state()
			puts(chess.toString()+state)
			b=false
		else
			puts("That is not a legal move!")
		end
	end
	if(!(state.start_with?("Draw")||state.end_with?("mate")))
		chess.randomMove()
		state=chess.state()
		puts(chess.toString()+state)
	end
end