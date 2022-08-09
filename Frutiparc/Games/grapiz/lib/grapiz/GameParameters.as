// 
// $Id: GameParameters.as,v 1.8 2004/05/06 11:10:53  Exp $
//

class grapiz.GameParameters
{
    private static var TIMES   : Array = [600000, 480000, 360000, 300000, 180000];
    private static var PLAYERS : Array = [2, 3, 4];
    private static var BOARDS  : Array = [3, 4, 5];

    public var nbrPlayers : Number;
    public var time       : Number;
    public var boardSize  : Number;

    public function GameParameters( data )
    {
        this.time       = TIMES[ data.time.value ];
        this.nbrPlayers = PLAYERS[ data.nbrPlayers.value ];
        this.boardSize  = BOARDS[ data.boardSize.value ];
    }

    public function toString() : String
    {
        var s : String = "";
        s += "::: grapiz.GameParameters :::\n";
        s += " + nbr players = " + nbrPlayers + "\n";
        s += " + time        = " + time + "\n";
        s += " + board size  = " + boardSize + "\n";
        return s;
    }
}

//EOF
