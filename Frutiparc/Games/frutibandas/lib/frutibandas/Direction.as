// 
// Copyright (c) 2004 Motion-Twin
//
// $Id: Direction.as,v 1.7 2004/02/26 19:52:57  Exp $
// 

/**
 * Representation of a board direction.
 *
 * There's only four known directions so this class cannot be instantiated by
 * client code. Ones must use statics Direction.Up, Direction.Down, Direction.Left,
 * Direction.Right.
 *
 * The static BadDirection direction is used to detect invalid Direction which
 * can be passed to Direction.valueOf() method.
 *
 * > var myDirection : Direction = Direction.valueOf(0); // should be Up
 * > if (myDirection === Direction.BadDirection) {
 * >     trace("Bad direction");
 * > }
 * > 
 * > var myDirection      : Direction = Direction.Up;
 * > var opositeDirection : Direction = myDirection.oposite();
 * > if (opositeDirection == Direction.Down) {
 * >    trace("Down as expected integer value is : " 
 * >          + opositeDirection.toNumber());
 * > }
 * 
 */
class frutibandas.Direction 
{
    public  static var Up           : Direction = new Direction(0);
    public  static var Right        : Direction = new Direction(1);
    public  static var Down         : Direction = new Direction(2);
    public  static var Left         : Direction = new Direction(3);
    public  static var BadDirection : Direction = new Direction(-1);

    private static var Strings      : Array = ["Up", "Right", "Down", "Left"];
    private static var LogStrings   : Array = ["le haut", "la droite", "le bas", "la gauche"];

    private var value : Number;
    
    /**
     * Private constructor.
     */
    private function Direction(val:Number)
    {
        value = val;
    }
 
    /**
     * Get the number representation of this direction.
     */
    public function toNumber() : Number 
    {
        return value;
    }

    /**
     * Get the oposite direction of this object.
     */
    public function oposite() : Direction
    {
        if (this == Up)    return Down;
        if (this == Down)  return Up;
        if (this == Left)  return Right;
        if (this == Right) return Left;
        return BadDirection;
    }

    /**
     * Get the direction name.
     */
    public function toString() : String
    {
        return Strings[value];
    }

    public function toLogString() : String
    {
        return LogStrings[value];
    }
    
    /**
     * Get the static Direction bound to specified integer.
     */
    public static function valueOf( v : Number ) : Direction
    {
        if (v == Up.value)    return Up;
        if (v == Down.value)  return Down;
        if (v == Left.value)  return Left;
        if (v == Right.value) return Right;
        return BadDirection;
    }
}
//EOF

