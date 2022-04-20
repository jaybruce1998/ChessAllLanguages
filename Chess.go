package Chess
import "GoChess/Square"
type Chess struct
{
	board [8][8]Square.Square
	boards []Square.Square
	moves int
	epr int
	epc int
	wkr int
	wkc int
	bkr int
	bkc int
	turn char
	cap char
}
func 