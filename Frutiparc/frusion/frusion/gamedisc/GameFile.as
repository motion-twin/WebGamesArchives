/*
	$Id: $
*/


/*
	Class: GameFile
	The GameFile class stores game file information
*/
class frusion.gamedisc.GameFile
{


/*------------------------------------------------------------------------------------
 * Public members
 *------------------------------------------------------------------------------------*/


	public var id : String;				// game id represented by an MD5 key
	public var size : Number;			// swf game size in bytes
	
	 

/*------------------------------------------------------------------------------------
 * Public methods
 *------------------------------------------------------------------------------------*/

	
	/*
		Function: GameFile
		Constructor
		
		Parameters:
		- id : String - game id represented by an MD5 string
		- size : Number - game swf file size
	*/
	public function GameFile( id : String, size : Number )
	{
		this.id = id;
		this.size = size;
	}
	
	
}