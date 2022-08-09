// 
// $Id: Coordinate.as,v 1.1.1.1 2004/01/26 15:09:48  Exp $
//

import grapiz.Direction;

class grapiz.gui.Coordinate 
{
    public var x : Number;
    public var y : Number;

    public function Coordinate(x:Number, y:Number)
    {
        this.x = x;
        this.y = y;
    }

    public function toString() : String
    {
        return "gui["+this.x+":"+this.y+"]";
    }

    public function move( direction : Direction, n : Number ) : Void
    {
        if (n == undefined) n = 1;

        if (direction == Direction.North) {
            this.y -= (grapiz.Globals.SlotHeight * n);
        }
        else if (direction == Direction.South) {
            this.y += (grapiz.Globals.SlotHeight * n);
        }
        else if (direction == Direction.NorthWest) {
            this.y -= (grapiz.Globals.SlotHeight / 2) * n;
            this.x -= (grapiz.Globals.SlotWidth * n);
        }
        else if (direction == Direction.NorthEast) {
            this.y -= (grapiz.Globals.SlotHeight / 2) * n;
            this.x += grapiz.Globals.SlotWidth * n;
        }
        else if (direction == Direction.SouthWest) {
            this.y += (grapiz.Globals.SlotHeight / 2) * n;
            this.x -= grapiz.Globals.SlotWidth * n;
        }
        else if (direction == Direction.SouthEast) {
            this.y += (grapiz.Globals.SlotHeight / 2) * n;
            this.x += grapiz.Globals.SlotWidth * n;
        }
    }

    public function copy() : Coordinate 
    {
        return new Coordinate(this.x, this.y);
    }

    public function equals( c : grapiz.gui.Coordinate ) : Boolean
    {
        return c.x == x && c.y == y;
    }
}

//EOF

