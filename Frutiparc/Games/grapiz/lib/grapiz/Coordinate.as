//
// $Id: Coordinate.as,v 1.1.1.1 2004/01/26 15:09:48  Exp $
// 

import grapiz.Direction;

class grapiz.Coordinate
{
    public var x : Number;
    public var y : Number;

    public function Coordinate( defaultX:Number, defaultY:Number )
    {
        this.x = defaultX;
        this.y = defaultY;
    }

    public function copy() : Coordinate 
    {
        return new Coordinate(this.x, this.y);
    }

    public function move( d : Direction, n : Number ) : Void
    {
        if (n == undefined) n = 1;

        var mx : Number = 0;
        var my : Number = 0;

        switch (d) {
            case Direction.North:
                mx = -1;
                my = -1;
                break;
            case Direction.South:
                mx = 1;
                my = 1;
                break;
            case Direction.NorthWest:
                my = -1;
                break;
            case Direction.NorthEast:
                mx = -1;
                break;
            case Direction.SouthWest:
                mx = 1;
                break;
            case Direction.SouthEast:
                my = 1;
                break;
            case Direction.East:
                break;
            case Direction.West:
                break;
            case Direction.BadDirection:
                break;
        }
        x += (mx * n);
        y += (my * n);
    }

    public function next( d : Direction ) : Coordinate
    {
        var result : Coordinate = this.copy();
        result.move(d, 1);
        return result;
    }

    public function toString() : String
    {
        return "[" + x + " : " + y + "]";
    }
}

//EOF

