package ;

/**
 * ...
 * @author de
 */

enum E_DIRS
{
	RIGHT;
	DOWN;
	LEFT;
	UP;
}


class Dirs
{
	public static var LIST = [ 	{x:1,	y:0},
								{x:0, 	y:1},
								{x:-1, 	y:0},
								{x:0, 	y: -1 } ];
								
								
	public static function inv( d : E_DIRS)
	{
		switch(d)
		{
			case UP: return DOWN;
			case DOWN: return UP;
			
			case LEFT: return RIGHT;
			case RIGHT: return LEFT;
		}
	}
	
	public static function parse(s:String)
	{
		return
		switch(s)
		{
			case "up": E_DIRS.UP;
			case "right": E_DIRS.RIGHT;
			case "down": E_DIRS.DOWN;
			case "left": E_DIRS.LEFT;
			default: return null;
		}
	}
}