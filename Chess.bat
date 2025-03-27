@echo off
title Chess
color 0a
setlocal enabledelayedexpansion

set board[0,0]=R& set board[0,1]=N& set board[0,2]=B& set board[0,3]=K& set board[0,4]=Q& set board[0,5]=B& set board[0,6]=N& set board[0,7]=R
for /L %%x in (0,1,7) do (
	set board[1,%%x]=P
	for /L %%y in (2,1,5) do set board[%%y,%%x]=.
	set board[6,%%x]=p
)
set board[7,0]=r& set board[7,1]=n& set board[7,2]=b& set board[7,3]=k& set board[7,4]=q& set board[7,5]=b& set board[7,6]=n& set board[7,7]=r

set turn=1
set wkr=0
set wkc=3
set bkr=7
set bkc=3
set epr=8
set wcl=0
set wcr=0
set bcl=0
set bcr=0

:printBoard
cls
if %turn%==1 goto printWhiteBoard
echo   h g f e d c b a
for /L %%y in (0,1,7) do (
	set /a dispY=%%y+1
	echo !dispY! !board[%%y,0]! !board[%%y,1]! !board[%%y,2]! !board[%%y,3]! !board[%%y,4]! !board[%%y,5]! !board[%%y,6]! !board[%%y,7]!
)
goto moveLoop
:printWhiteBoard
echo   a b c d e f g h
for /L %%y in (7,-1,0) do (
	set /a dispY=%%y+1
	echo !dispY! !board[%%y,7]! !board[%%y,6]! !board[%%y,5]! !board[%%y,4]! !board[%%y,3]! !board[%%y,2]! !board[%%y,1]! !board[%%y,0]!
)
:moveLoop
set /p move=Enter your move (e.g., e2e4): 
if "%move%"=="gg" goto end
call :isLegalMove %move%
if %errorlevel%==1 (
    echo Invalid move. Try again.
    goto moveLoop
)
set /a r1=%move:~1,1%-1
call :getColumn %move:~0,1% hgfedcba
set c1=%errorlevel%
set /a r2=%move:~3,1%-1
call :getColumn %move:~2,1% hgfedcba
set c2=%errorlevel%
call :move %r1% %c1% %r2% %c2%
goto printBoard

:getColumn
set c=%2
for /L %%i in (0,1,7) do if "!c:~%%i,1!"=="%1" exit /b %%i
exit /b 8

:isValidNumber
for /L %%i in (0,1,7) do if "%%i"=="%1" exit /b 0
exit /b 1

:anyCanMove
for /L %%r in (0,1,7) do for /L %%c in (0,1,7) do (
	call :anyCanMoveTo %%r %%c
	if !errorlevel!==0 (
	echo %turn% %%r %%c
	exit /b 0)
)
exit /b 1

:anyCanMoveTo
for /L %%r in (0,1,7) do for /L %%c in (0,1,7) do (
	call :canMove %%r %%c %1 %2
	if !errorlevel!==0 exit /b 0
)
exit /b 1

:isLegalMove
setlocal
set move=%1
set /a r1=%move:~1,1%-1
call :isValidNumber %r1%
if %errorlevel%==1 exit /b 1
call :getColumn %move:~0,1% hgfedcba
if %errorlevel%==8 exit /b 1
set c1=%errorlevel%
set /a r2=%move:~3,1%-1
call :isValidNumber %r2%
if %errorlevel%==1 exit /b 1
call :getColumn %move:~2,1% hgfedcba
if %errorlevel%==8 exit /b 1
set c2=%errorlevel%
if "%move:~4,1%" NEQ "" exit /b 1

call :canMove %r1% %c1% %r2% %c2%
if %errorlevel%==1 exit /b 1
if %turn%==1 goto whiteMovedKing
set kr=%bkr%
set kc=%bkc%
goto strictCastleCheck
:whiteMovedKing
set kr=%wkr%
set kc=%wkc%
:strictCastleCheck
set /a turn=%turn%*-1
if %kr% NEQ %r1% goto inCheckCheck
if %kc% NEQ %c1% goto inCheckCheck
set kr=%r2%
set kc=%c2%
set /a cDif=%c2%-%c1%
if %c1% GTR %c2% set /a cDif=%c1%-%c2%
if %cDif% NEQ 2 goto inCheckCheck
call :anyCanMoveTo %kr% 3
if %errorlevel%==0 goto doneCheckingMovement
set /a mc=(%r2%+3)/2
call :anyCanMoveTo %kr% %mc%
if %errorlevel%==0 goto doneCheckingMovement
:inCheckCheck
set cPc=!board[%r2%,%c2%]!
set cPn=!board[%r1%,%c2%]!
call :basicMove %r1% %c1% %r2% %c2%
call :anyCanMoveTo %kr% %kc%
set board[%r1%,%c1%]=!board[%r2%,%c2%]!
set board[%r2%,%c2%]=%cPc%
set board[%r1%,%c2%]=%cPn%
set /a turn=%turn%*-1
if %errorlevel%==0 exit /b 1
exit /b 0
:doneCheckingMovement
set /a turn=%turn%*-1
exit /b %errorlevel%

:basicMove
set r1=%1
set c1=%2
set r2=%3
set c2=%4
set board[%r2%,%c2%]=!board[%r1%,%c1%]!
set board[%r1%,%c1%]=.
if "!board[%r2%,%c2%]!"=="P" goto enPassanting
if "!board[%r2%,%c2%]!" NEQ "p" exit /b 0
:enPassanting
if %r1% NEQ %epr% exit /b 0
if %c2%==%epc% set board[%r1%,%c2%]=.
exit /b 0

:move
set r1=%1
set c1=%2
set r2=%3
set c2=%4
call :basicMove %r1% %c1% %r2% %c2%
if turn==1 goto whiteMove

if %r1% NEQ 7 goto blackKingUpdater
if %c1% NEQ 0 goto blackRookUpdater
set bcl=1
goto blackKingUpdater
:blackRookUpdater
if %c1% NEQ 7 goto blackKingUpdater
set bcr=1
:blackKingUpdater
set rDif=%r1%-%r2%
if %r1% NEQ %bkr% goto pawnUpdater
if %c1% NEQ %bkc% goto pawnUpdater
set bkr=%r2%
set bkc=%c2%
if %r1% NEQ 7 goto pawnUpdater
if %c1% NEQ 4 goto pawnUpdater
set bcl=1
set bcr=1
if %c2% NEQ 1 goto rightblackCastle
call :basicMove 7 0 7 2
goto pawnUpdater
:rightblackCastle
if %c2% NEQ 5 goto pawnUpdater
call :basicMove 7 7 7 4
goto pawnUpdater

:whiteMove
if %r1% NEQ 0 goto whiteKingUpdater
if %c1% NEQ 0 goto whiteRookUpdater
set wcl=1
goto whiteKingUpdater
:whiteRookUpdater
if %c1% NEQ 7 goto whiteKingUpdater
set wcr=1
:whiteKingUpdater
set rDif=%r2%-%r1%
if %r1% NEQ %wkr% goto pawnUpdater
if %c1% NEQ %wkc% goto pawnUpdater
set wkr=%r2%
set wkc=%c2%
if %r1% NEQ 0 goto pawnUpdater
if %c1% NEQ 4 goto pawnUpdater
set wcl=1
set wcr=1
if %c2% NEQ 1 goto rightWhiteCastle
call :basicMove 0 0 0 2
goto pawnUpdater
:rightWhiteCastle
if %c2% NEQ 5 goto pawnUpdater
call :basicMove 0 7 0 4
:pawnUpdater
set /a turn=%turn%*-1
if %rDif% NEQ 2 exit /b 0
set epr=%r2%
set epc=%c2%
exit /b 0

:canMove
set r1=%1
set c1=%2
set r2=%3
set c2=%4
set /a rDif=%r2%-%r1%
set arDif=%rDif%
if %r1% GTR %r2% set /a arDif=%r1%-%r2%
set /a cDif=%c2%-%c1%
if %c1% GTR %c2% set /a cDif=%c1%-%c2%
set piece=!board[%r1%,%c1%]!

if %turn%==1 goto canWhiteMove
call :getColumn !board[%r2%,%c2%]! rnbqkp
if %errorlevel% NEQ 8 exit /b 1
set /a rDif=%r1%-%r2%
set cl=%bcl%
set cr=%bcr%
if %piece%==p goto canPawnMove
if %piece%==r goto canRookMove
if %piece%==n goto canKnightMove
if %piece%==b goto canBishopMove
if %piece%==q goto canBlackQueenMove
if %piece%==k goto canKingMove
exit /b 1

:canWhiteMove
call :getColumn !board[%r2%,%c2%]! RNBQKP
if %errorlevel% NEQ 8 exit /b 1
set cl=%wcl%
set cr=%wcr%
if %piece%==P goto canPawnMove
if %piece%==R goto canRookMove
if %piece%==N goto canKnightMove
if %piece%==B goto canBishopMove
if %piece%==Q goto canRookMove
if %piece%==K goto canKingMove
exit /b 1

:canPawnMove
if %rDif%==1 goto canPawnMoveOneSquare
if %rDif%==2 goto canPawnMoveTwoSquares
exit /b 1
:canPawnMoveOneSquare
if %cDif%==1 goto canPawnCapture
if %cDif% NEQ 0 exit /b 1
if "!board[%r2%,%c2%]!"=="." exit /b 0
:canPawnCapture
if %cDif% NEQ 1 exit /b 1
if "!board[%r2%,%c2%]!" NEQ "." exit /b 0
if %r1% NEQ %epr% exit /b 1
if %c2%==%epc% exit /b 0
:canPawnMoveTwoSquares
if %cDif% NEQ 0 exit /b 1
set /a mr=(%r1%+%r2%)/2
if "!board[%mr%,%c2%]!" NEQ "." exit /b 1
if "!board[%r2%,%c2%]!"=="." exit /b 0
exit /b 1

:canBlackQueenMove
set piece=Q
:canRookMove
if %rDif%==0 goto canRookMoveHorizontally
if %cDif% NEQ 0 goto queenCheck
if %r1% LSS %r2% goto canRookMoveDown
set t=%r1%
set r1=%r2%
set r2=%t%
:canRookMoveDown
set /a r1=%r1%+1
set /a r2=%r2%-1
for /L %%i in (%r1%,1,%r2%) do if "!board[%%i,%c2%]!" NEQ "." exit /b 1
exit /b 0
:canRookMoveHorizontally
if %c1% LSS %c2% goto canRookMoveRight
set t=%c1%
set c1=%c2%
set c2=%t%
:canRookMoveRight
set /a c1=%c1%+1
set /a c2=%c2%-1
for /L %%i in (%c1%,1,%c2%) do if "!board[%r1%,%%i]!" NEQ "." exit /b 1
exit /b 0

:canKnightMove
if %arDif% GTR 2 exit /b 1
if %cDif% GTR 2 exit /b 1
set /a difs=%arDif%+%cDif%
if %difs%==3 exit /b 0
exit /b 1

:queenCheck
if %piece% NEQ Q exit /b 1
:canBishopMove
if %arDif% NEQ %cDif% exit /b 1
if %r1% LSS %r2% goto canMoveBishopDown
set r1=%r2%
set t=%c1%
set c1=%c2%
set c2=%t%
:canMoveBishopDown
set add=1
if %c1% LSS %c2% goto bishopRightLoop
:bishopLeftLoop
if %add%==%cDif% exit /b 0
set /a r=%r1%+%add%
set /a c=%c1%-%add%
if "!board[%r%,%c%]!" NEQ "." exit /b 1
set /a add=%add%+1
goto bishopLeftLoop
:bishopRightLoop
if %add%==%cDif% exit /b 0
set /a r=%r1%+%add%
set /a c=%c1%+%add%
if "!board[%r%,%c%]!" NEQ "." exit /b 1
set /a add=%add%+1
goto bishopRightLoop

:canKingMove
if %arDif% GTR 2 exit /b 1
if %arDif%==2 goto canCastle
if %cDif% GTR 1 exit /b 1
exit /b 0
:canCastle
if %c1% LSS %c2% goto canCastleRight
if %cl%==1 exit /b 1
if "!board[%r2%,1]!" NEQ "." exit /b 1
if "!board[%r2%,2]!"=="." exit /b 0
exit /b 1
:canCastleRight
if %cr%==1 exit /b 1
if "!board[%r2%,4]!" NEQ "." exit /b 1
if "!board[%r2%,5]!" NEQ "." exit /b 1
if "!board[%r2%,6]!"=="." exit /b 0
exit /b 1

:end
echo Lol get pwned