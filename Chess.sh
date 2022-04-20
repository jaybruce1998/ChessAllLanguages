#!/bin/bash
setSquare()
{
	local i=`expr $1 \* 8 + $2`
	colors[$i]=$3
	types[$i]=$4
	moved[$i]=$5
}
changeTurns()
{
	local t=$turn
	turn=$cap
	cap=$t
}
abs()
{
	if [ $1 -lt $2 ]
	then
		return `expr $2 - $1`
	fi
	return `expr $1 - $2`
}
move()
{
	local r1=$1
	local c1=$2
	local i=`expr $r1 \* 8 + $c1`
	local r2=$3
	local c2=$4
	local j=`expr $r2 \* 8 + $c2`
	if [ $5 = 0 ]
	then
		boardColors+=(${colors[@]})
		boardTypes+=(${types[@]})
	fi
	if [ ${types[$i]} = Kg ]
	then
		epr=8
		if [ $turn == W ]
		then
			wkr=$r2
			wkc=$c2
		else
			bkr=$r2
			bkc=$c2
		fi
		abs $c1 $c2
		if [ $? = 2 ]
		then
			if [ $c2 = 1 ]
			then
				setSquare $r2 2 $turn Rk 0
				setSquare $r2 0 " " "  " 0
			else
				setSquare $r2 4 $turn Rk 0
				setSquare $r2 7 " " "  " 0
			fi
		fi
	elif [ "${types[$i]}" = Pn ]
	then
		numMoves=-1
		abs $r1 $r2
		if [ $? = 2 ]
		then
			epr=$r2
			epc=$c2
		else
			if [ $r1 = $epr -a $c2 = $epc ]
			then
				setSquare $r1 $c2 " " "  " 0
			elif [ $r2 = 0 -o $r2 = 7 ]
			then
				types[$i]=Qn
			fi
		fi
	else
		epr=8
	fi
	if [ "${colors[$j]}" = " " ]
	then
		numMoves=`expr $numMoves + 1`
	else
		numMoves=0
	fi
	setSquare $r2 $c2 $turn ${types[$i]} 0
	setSquare $r1 $c1 " " "  " 0
	changeTurns
}
canRookMove()
{
	local r1=$1
	local c1=$2
	local r2=$3
	local c2=$4
	if [ $r1 != $r2 -a $c1 != $c2 ]
	then
		return 1
	fi
	if [ $r1 -gt $r2 ]
	then
		local t=$r1
		r1=$r2
		r2=$t
	elif [ $c1 -gt $c2 ]
	then
		local t=$c1
		c1=$c2
		c2=$t
	fi
	if [ $r1 != $r2 ]
	then
		local r=`expr $r1 + 1`
		while [ $r -lt $r2 ]
		do
			local i=`expr $r \* 8 + $c1`
			if [ "${colors[$i]}" != " " ]
			then
				return 1
			fi
			r=`expr $r + 1`
		done
	else
		local c=`expr $c1 + 1`
		while [ $c -lt $c2 ]
		do
			local i=`expr $r1 \* 8 + $c`
			if [ "${colors[$i]}" != " " ]
			then
				return 1
			fi
			c=`expr $c + 1`
		done
	fi
	return 0
}
canBishopMove()
{
	local r1=$1
	local c1=$2
	local r2=$3
	local c2=$4
	if [ $r1 -gt $r2 ]
	then
		local t=$r1
		r1=$r2
		r2=$t
		t=$c1
		c1=$c2
		c2=$t
	fi
	local r=`expr $r2 - $r1`
	local c=`expr $c2 - $c1`
	abs $c1 $c2
	if [ $r != $? ]
	then
		return 1
	fi
	if [ $c -gt 0 ]
	then
		local i=1
		while [ $i -lt $r ]
		do
			local n=`expr $r1 + $i`
			n=`expr $n \* 8 + $c1 + $i`
			if [ "${colors[$n]}" != " " ]
			then
				return 1
			fi
			i=`expr $i + 1`
		done
	else
		local i=1
		while [ $i -lt $r ]
		do
			local n=`expr $r1 + $i`
			n=`expr $n \* 8 + $c1 - $i`
			if [ "${colors[$n]}" != " " ]
			then
				return 1
			fi
			i=`expr $i + 1`
		done
	fi
	return 0
}
canEasyMove()
{
	local r1=$1
	local c1=$2
	local r2=$3
	local c2=$4
	local i=$5
	local j=$6
	local r=$7
	local c=$8
	if [ ${types[$i]} = Pn ]
	then
		if [ $r = 0 -o $r -gt 2 -o $r1 -gt $r2 -a $turn = W -o $r1 -lt $r2 -a $turn = B ]
		then
			return 1
		fi
		if [ $c = 1 ]
		then
			if [ $r = 1 ]
			then
				if [ "${colors[$j]}" = $cap -o $r1 = $epr -a $c2 = $epc ]
				then
					return 0
				fi
			fi
		elif [ $c = 0 -a "${colors[$j]}" = " " ]
		then
			local h=`expr $r1 - $r2`
			h=`expr $r2 + $h / 2`
			h=`expr $h \* 8 + $c2`
			if [ $r = 1 -o "${colors[$h]}" = " " -a ${moved[$i]} = 1 ]
			then
				return 0
			fi
		fi
	elif [ ${types[$i]} = Kt ]
	then
		local p=`expr $r + $c`
		if [ $r -lt 3 -a $c -lt 3 -a $p = 3 ]
		then
			return 0
		fi
	elif [ ${types[$i]} = Rk ]
	then
		canRookMove $r1 $c1 $r2 $c2
		if [ $? = 0 ]
		then
			return 0
		fi
	elif [ ${types[$i]} = Bp ]
	then
		canBishopMove $r1 $c1 $r2 $c2
		if [ $? = 0 ]
		then
			return 0
		fi
	elif [ ${types[$i]} = Qn ]
	then
		canRookMove $r1 $c1 $r2 $c2
		if [ $? = 0 ]
		then
			return 0
		fi
		canBishopMove $r1 $c1 $r2 $c2
		if [ $? = 0 ]
		then
			return 0
		fi
	else
		local i0=`expr $r2 \* 8`
		local i1=`expr $i0 + 1`
		local i2=`expr $i1 + 1`
		local i3=`expr $i2 + 2`
		local i4=`expr $i3 + 1`
		local i5=`expr $i4 + 1`
		local i6=`expr $i5 + 1`
		if [ $c -lt 2 ]
		then
			if [ $r -lt 2 ]
			then
				return 0
			fi
		elif [ $r -gt 0 -o ${moved[$i]} = 0 -o $c != 2 ]
		then
			return 1
		elif [ $c2 = 1 ]
		then
			if [ "${colors[$i1]}" = " " -a "${colors[$i2]}" = " " -a ${moved[$i0]} = 1 ]
			then
				return 0
			fi
		elif [ "${colors[$i3]}" = " " -a "${colors[$i4]}" = " " -a "${colors[$i5]}" = " " -a ${moved[$i6]} = 1 ]
		then
			return 0
		fi
	fi
	return 1
}
canMove()
{
	local r1=$1
	local c1=$2
	local i=`expr $r1 \* 8 + $c1`
	local r2=$3
	local c2=$4
	local j=`expr $r2 \* 8 + $c2`
	local real=$5
	abs $r1 $r2
	local r=$?
	abs $c1 $c2
	local c=$?
	if [ "${colors[$i]}" != $turn -o "${colors[$j]}" = $turn ]
	then
		return 1
	fi
	canEasyMove $r1 $c1 $r2 $c2 $i $j $r $c
	if [ $? = 1 ]
	then
		return 1
	fi
	if [ $real = 0 ]
	then
		local gc=("${colors[@]}")
		local gt=("${types[@]}")
		local gm=("${moved[@]}")
		local gMoves=$numMoves
		local gEpr=$epr
		local gEpc=$epc
		local gWkr=$wkr
		local gWkc=$wkc
		local gBkr=$bkr
		local gBkc=$bkc
		local gTurn=$turn
		local gCap=$cap
		local ret=0
		if [ ${types[$i]} = Kg -a $c = 2 ]
		then
			changeTurns
			anyCanMoveTo $r1 $c1 1
			if [ $? = 0 ]
			then
				ret=1
			else
				changeTurns
				local c3=`expr $c2 - $c1`
				c3=`expr $c1 + $c3 / 2`
				move $r1 $c1 $r2 $c3 1
				anyCanMoveTo $r1 $c3 1
				if [ $? = 0 ]
				then
					ret=1
				fi
				move $r2 $c3 $r1 $c1 1
			fi
		fi
		if [ $ret = 0 ]
		then
			move $r1 $c1 $r2 $c2 1
			if [ $turn = B ]
			then
				anyCanMoveTo $wkr $wkc 1
				if [ $? = 0 ]
				then
					ret=1
				fi
			else
				anyCanMoveTo $bkr $bkc 1
				if [ $? = 0 ]
				then
					ret=1
				fi
			fi
		fi
		colors=("${gc[@]}")
		types=("${gt[@]}")
		moved=("${gm[@]}")
		numMoves=$gMoves
		epr=$gEpr
		epc=$gEpc
		wkr=$gWkr
		wkc=$gWkc
		bkr=$gBkr
		bkc=$gBkc
		turn=$gTurn
		cap=$gCap
		if [ $ret = 1 ]
		then
			return 1
		fi
	fi
	return 0
}
anyCanMoveTo()
{
	local r2=$1
	local c2=$2
	local real=$3
	local r1=0
	while [ $r1 -lt 8 ]
	do
		local c1=0
		while [ $c1 -lt 8 ]
		do
			canMove $r1 $c1 $r2 $c2 $real
			if [ $? = 0 ]
			then
				return 0
			fi
			c1=`expr $c1 + 1`
		done
		r1=`expr $r1 + 1`
	done
	return 1
}
anyCanMove()
{
	local r=0
	while [ $r -lt 8 ]
	do
		local c=0
		while [ $c -lt 8 ]
		do
			anyCanMoveTo $r $c 0
			if [ $? = 0 ]
			then
				return 0
			fi
			c=`expr $c + 1`
		done
		r=`expr $r + 1`
	done
	return 1
}
equals()
{
	local r=0
	while [ $r -lt 8 ]
	do
		local c=0
		while [ $c -lt 8 ]
		do
			local i=`expr $r \* 8 + $c`
			local j=`expr $1 + $i`
			if [ "${colors[$i]}" != "${boardColors[$j]}" -o "${types[$i]}" != "${boardTypes[$j]}" ]
			then
				return 0
			fi
			c=`expr $c + 1`
		done
		r=`expr $r + 1`
	done
	return 1
}
updateState()
{
	state=""
	if [ $numMoves = 100 ]
	then
		state="Draw by 50-move rule"
		return 0
	fi
	local n=0
	local w=0
	local b=0
	changeTurns
	if [ $turn = W ]
	then
		anyCanMoveTo $bkr $bkc 1
		if [ $? = 0 ]
		then
			state="Check"
		fi
	else
		anyCanMoveTo $wkr $wkc 1
		if [ $? = 0 ]
		then
			state="Check"
		fi
	fi
	changeTurns
	anyCanMove
	if [ $? = 1 ]
	then
		if [ $state = "Check" ]
		then
			state="Checkmate"
		else
			state="Stalemate"
		fi
		return 0
	fi
	local i=0
	local l=${#boardColors[@]}
	while [ $i -lt $l ]
	do
		equals $i
		n=`expr $n + $?`
		i=`expr $i + 64`
	done
	if [ $n = 2 ]
	then
		state="Draw by 3-fold repetition"
		return 0
	fi
	local r=0
	while [ $r -lt 8 ]
	do
		local c=0
		while [ $c -lt 8 ]
		do
			i=`expr $r \* 8 + $c`
			if [ "${types[$i]}" = Rk -o "${types[$i]}" = Qn -o "${types[$i]}" = Pn ]
			then
				return 1
			elif [ "${colors[$i]}" = W ]
			then
				w=`expr $w + 1`
			elif [ "${colors[$i]}" = B ]
			then
				b=`expr $b + 1`
			fi
			c=`expr $c + 1`
		done
		r=`expr $r + 1`
	done
	if [ $w -lt 2 -a $b -lt 2 ]
	then
		state="Draw by insufficient material"
		return 0
	fi
	return 1
}
moveRandom()
{
	local r1=`expr $RANDOM % 8`
	local c1=`expr $RANDOM % 8`
	local r2=`expr $RANDOM % 8`
	local c2=`expr $RANDOM % 8`
	canMove $r1 $c1 $r2 $c2 0
	if [ $? = 0 ]
	then
		move $r1 $c1 $r2 $c2 0
	else
		moveRandom
	fi
}
randomMove()
{
	local r1=0
	local n=0
	while [ $r1 -lt 8 ]
	do
		local c1=0
		while [ $c1 -lt 8 ]
		do
			local r2=0
			while [ $r2 -lt 8 ]
			do
				local c2=0
				while [ $c2 -lt 8 ]
				do
					canMove $r1 $c1 $r2 $c2 0
					if [ $? = 0 ]
					then
						a[$n]=$r1
						b[$n]=$c1
						c[$n]=$r2
						d[$n]=$c2
						n=`expr $n + 1`
					fi
					c2=`expr $c2 + 1`
				done
				r2=`expr $r2 + 1`
			done
			c1=`expr $c1 + 1`
		done
		r1=`expr $r1 + 1`
	done
	n=`expr $RANDOM % $n`
	move ${a[$n]} ${b[$n]} ${c[$n]} ${d[$n]} 0
}
showBoard()
{
	local r=0
	echo " h  g  f  e  d  c  b  a"
	while [ $r -lt 8 ]
	do
		local c=0
		while [ $c -lt 8 ]
		do
			local i=`expr $r \* 8 + $c`
			printf "${colors[$i]}${types[$i]}"
			c=`expr $c + 1`
		done
		r=`expr $r + 1`
		echo " $r"
	done
}
ord() {
  return `expr 104 - $(printf '%d' "'$1")`
}
pieces=(Rk Kt Bp Kg Qn Bp Kt Rk)
r=0
while [ $r -lt 8 ]
do
	c=0
	while [ $c -lt 8 ]
	do
		setSquare $r $c " " "  " 0
		c=`expr $c + 1`
	done
	r=`expr $r + 1`
done
c=0
while [ $c -lt 8 ]
do
	setSquare 0 $c W ${pieces[$c]} 1
	setSquare 1 $c W Pn 1
	setSquare 6 $c B Pn 1
	setSquare 7 $c B ${pieces[$c]} 1
	c=`expr $c + 1`
done
boardColors=()
boardTypes=()
numMoves=0
epr=8
epc=8
wkr=0
wkc=3
bkr=7
bkc=3
turn=W
cap=B
state=""
showBoard
while true
do
	read m
	if [ ${#m} = 5 ]
	then
		r1=`expr ${m:1:1} - 1`
		ord ${m:0:1}
		c1=$?
		r2=`expr ${m:4:1} - 1`
		ord ${m:3:1}
		c2=$?
		if [ $r1 -lt 0 -o $r1 -gt 7 -o $c1 -lt 0 -o $c1 -gt 7 -o $r2 -lt 0 -o $r2 -gt 7 -o $c2 -lt 0 -o $c2 -gt 7 ]
		then
			echo "That is not a valid move!"
		fi
		canMove $r1 $c1 $r2 $c2 0
		if [ $? = 0 ]
		then
			move $r1 $c1 $r2 $c2 0
			showBoard
			updateState
			if [ $? = 0 ]
			then
				echo $state
				exit 0
			else
				echo $state
				randomMove
				#moveRandom
				showBoard
				updateState
				if [ $? = 0 ]
				then
					echo $state
					exit 0
				fi
				echo $state
			fi
		else
			echo "That is not a legal move!"
		fi
	else
		echo "That is not a valid move!"
	fi
done