//
// $Id: BoardTextPrinter.as,v 1.1.1.1 2004/01/26 15:09:48  Exp $
// 

import grapiz.Coordinate;
import grapiz.Token;

class grapiz.BoardTextPrinter 
{
    private var board : grapiz.Board;

    public function BoardTextPrinter( board : grapiz.Board ) 
    {
        this.board = board;
    }

    public function print() : String
    {
        var result : String = "";
        var radius : Number = board.getSize();
        var marks  : Array  = new Array();
        for (var i=0; i<radius; i++) {
            var o = { d:(radius-i), x:i, y:0 };
            marks.push( o );
        }
        var t = 0;
        for (var i=radius; i<(radius*2); i++) {
            var o1 = { d:0, x:i, y:t };
            marks.push( o1 );
            t++;
            var o2 = { d:1, x:i, y:t };
            marks.push( o2 );
        }
        for (var i=0; i<=radius; i++) {
            var o = { d:i, x:(radius*2), y:(radius+i) };
            marks.push( o );
        }
        t = 2;

        for (var i=0; i<marks.length; i++) {
            var d = marks[i];
            for (var s=0; s < d.d; s++) {
                result += "     ";
            }
            while ((d.x >= 0) && (d.y >= 0) && (d.y <= (2*radius)) && ((d.y - d.x) <= radius)) {
                var coord  : Coordinate = new Coordinate(d.x, d.y);
                var sprite : grapiz.Token = this.board.getAt( coord );
                if (sprite == undefined) {
                    result += "(" + d.x + ":" + d.y + ")=.   ";
                }
                else {
                    result += "(" + d.x + ":" + d.y + ")=" + sprite.getTeam() + "   ";
                }
                d.x --;
                d.y ++;
            }
            result += "\n";
        }
        return result;
    }
}

//EOF

