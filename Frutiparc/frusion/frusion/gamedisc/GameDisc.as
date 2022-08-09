/*
	$Id: GameDisc.as,v 1.6 2003/11/20 10:18:47  Exp $
*/


/*
	Class: GameDisc
	The GameDisc class stores game disc information
*/
class frusion.gamedisc.GameDisc
{


/*------------------------------------------------------------------------------------
 * Public members
 *------------------------------------------------------------------------------------*/


	public var discType : Number;		// disc_type 0=> black, 1=> white, etc...
	public var swfName : String;		
	public var id : String;				// game id represented by an MD5 key
	public var size : Number;			// swf game size in bytes
	public var width : Number;			// width of the game to load
	public var height : Number;			// height of the game to load
	public var mode : String;			// open mode i=>internal e=> external
	public var files : Object;			// object containing the file information
	
	 

/*------------------------------------------------------------------------------------
 * Public methods
 *------------------------------------------------------------------------------------*/

	
	/*
		Function: GameDisc
		Constructor
		
		Parameters:
		- discType : Number - represents the type of disc ( black (=0), white(=1), etc...)
		- gameName : String - name of the game
		- id : String - game id represented by an MD5 string
		- size : Number - game swf file size
		- width : Number - width of the game to load
		- height : Number - height of the game to load
		- mode : String - open mode, internal (="i") for games loaded within frutiparc, external for loading in popup or external frames
	*/
	public function GameDisc( discType : Number, swfName : String, id : String, width : Number, height : Number, mode : String, files : Object )
	{
		this.discType = discType;
		this.swfName = swfName;
		this.id = id;
//		this.size = size;
		this.width = width;
		this.height = height;
		this.mode = mode;
		this.files = files;
	}
	
	public function dump()
	{
		_global.debug("GameDisc.id       = "+this.id);
		_global.debug("GameDisc.discType = "+this.discType);
		_global.debug("GameDisc.swfName  = "+this.swfName);
	}
}