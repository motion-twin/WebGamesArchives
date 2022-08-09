// 
// Copyright (c) 2004 Motion-Twin
//
// $Id: Coordinate.as,v 1.7 2004/03/11 11:35:19  Exp $
// 
import frutibandas.Direction;

/**
 * Representation of a board coordinate.
 */
class frutibandas.Coordinate 
{
    public var x : Number;
    public var y : Number;
    
    /**
     * Constructor.
     *
     * @param x Default x
     * @param y Default y
     */
    public function Coordinate( x:Number, y:Number )
    {
        if (x == undefined) x = -1;
        if (y == undefined) y = -1;
        this.x = x;
        this.y = y;
    }

    /**
     * Duplicate coordinate.
     *
     * @return a copy of this object
     */
    public function copy() : Coordinate
    {
        return new Coordinate(x, y);
    }

    /**
     * Move coordinate once to specified direction.
     */
    public function move(d:Direction) : Void
    {
        switch (d) {
            case Direction.Up:
                y--;
                break;
                
            case Direction.Down:
                y++;
                break;
                
            case Direction.Left:
                x--;
                break;
                
            case Direction.Right:
                x++;
                break;
                
            default:
                throw new Error("Unable to move coordinate to BadDirection");
                break;
        }
    }

    /**
     * Retrieve neighboor coordinate.
     *
     * @return a new Coordinate object
     */
    public function next(d:Direction) : Coordinate
    {
        var result : Coordinate = this.copy();
        result.move(d);
        return result;
    }

    /**
     * Generate a string representation of the coordinate.
     *
     * @return a string representation of this object
     */
    public function toString() : String
    {
        return "["+x+":"+y+"]";
    }

    /**
     * Tells if this coordinate is a valid positive coordinate.
     */
    public function isValid() : Boolean
    {
        return (this.x >= 0 && this.y >= 0);
    }

    public function equals( c:Coordinate ) : Boolean
    {
        return (x == c.x && y == c.y);
    }
}

//EOF

