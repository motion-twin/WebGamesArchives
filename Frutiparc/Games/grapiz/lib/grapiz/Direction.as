//
// $Id: Direction.as,v 1.2 2004/01/26 18:11:21  Exp $
// 

/**
 *
 * var d : Direction = Direction.North;
 * var o : Direction = d.oposite();
 * if (o == Direction.South) {
 *     // ...
 *     trace( o.toNumber() );
 * }
 */
class grapiz.Direction 
{
    public static var North         : Direction = new Direction(0);
    public static var NorthEast     : Direction = new Direction(1);
    public static var East          : Direction = new Direction(2);
    public static var SouthEast     : Direction = new Direction(3);
    public static var South         : Direction = new Direction(4);
    public static var SouthWest     : Direction = new Direction(5);
    public static var West          : Direction = new Direction(6);
    public static var NorthWest     : Direction = new Direction(7);
    public static var BadDirection  : Direction = new Direction(-1);
    
    public static var list : Array = [North, NorthEast, SouthEast, South, SouthWest, NorthWest];
    
    private static var names : Array = [
        "North", "North-East", "East", "South-East", "South", "South-West", "West", "North-West"
    ];

    private var value : Number;

    private function Direction( value : Number )
    {
        this.value = value;
    }

    public function toNumber() : Number
    {
        return this.value;
    }

    public function toString() : String
    {
        if (this == BadDirection) 
            return "Bad-Direction";
        return Direction.names[ this.value ];
    }

    public function oposite() : Direction
    {
        if (this == North)     return South;
        if (this == NorthEast) return SouthWest;
        if (this == NorthWest) return SouthEast;
        if (this == South)     return North;
        if (this == SouthEast) return NorthWest;
        if (this == SouthWest) return NorthEast;
        return BadDirection;
    }

    public static function valueOf(d:Number) : Direction
    {
        switch (d) {
            case North.value:
                return North;
            case NorthEast.value:
                return NorthEast;
            case NorthWest.value:
                return NorthWest;
            case South.value:
                return South;
            case SouthEast.value:
                return SouthEast;
            case SouthWest.value:
                return SouthWest;
            default:
                return BadDirection;
        }
    }
}

//EOF

