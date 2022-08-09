//
// $Id: AvailableMove.as,v 1.2 2004/02/25 13:32:14  Exp $
//

/**
 * Instances of this class are produces by the grapiz.Board class to represent
 * available moves for a selected token.
 */
class grapiz.AvailableMove 
{
    public var target    : grapiz.Coordinate;
    public var direction : grapiz.Direction;

    public function AvailableMove( c:grapiz.Coordinate, d:grapiz.Direction )
    { //{{{
        this.target = c;
        this.direction = d;
    } //}}}

    public function toString() : String
    { //{{{
        return "Available move target=" + target +" direction="+direction;
    } //}}}
}

//EOF
