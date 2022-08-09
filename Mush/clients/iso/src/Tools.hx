package ;

import Types;
/**
 * ...
 * @author de
 */

class Tools 
{
	public static function getItemId ( d: DepInfos)
	{
		return 
		switch(d.gameData)
		{
			case Equipment( i, _ ): return i;
			default:
		}
		
		return null;
	}
	
}