/*
	$Id: $
*/


import frusion.gamedisc.GameDisc;


/*
	Class: frusion.FakeFrusionSlot
*/
class frusion.FakeFrusionSlot
{


/*------------------------------------------------------------------------------------
 * Private members
 *------------------------------------------------------------------------------------*/


	private var gd : GameDisc;


/*------------------------------------------------------------------------------------
 * Public methods
 *------------------------------------------------------------------------------------*/
	
	/*
	 	Function: FakeFrusionSlot
	 	Constructor
	*/	
	public function FakeFrusionSlot( gd : GameDisc )
	{
		this.gd = gd;
	}
	
	
	/*
		Function: init
		Emulates FPFrusionSlot init behaviour for launching a game in popup mode
		
		Note:
		- discType : Number - represents the type of disc ( black (=0), white(=1), etc...)
		- gameName : String - name of the game
		- id : String - game id represented by an MD5 string
		- size : Number - game swf file size
		- width : Number - width of the game to load
		- height : Number - height of the game to load
		- mode : String - open mode, internal (="i") for games loaded within frutiparc, external for loading in popup or external frames		 
	*/
	public function init(sid)
	{
		_global.debug( "FakeFrusionSlot - Launching popup window ("+this.gd.files["index"].id+")" );
		
				
		getURL("javascript:fp_goURLResize('http://www.beta.frutiparc.com/frusion/?sid="+sid
				+ "&discType="+ this.gd.discType
				+ "&gameName="+ this.gd.swfName
				+ "&u="+ this.gd.id
				+ "&id="+ this.gd.files["index"].id
				+ "&size="+ this.gd.files["index"].size
				+ "&width="+ this.gd.width
				+ "&height="+ this.gd.height
				+ "&w="+ this.gd.width
				+ "&h="+ this.gd.height
				+ "&mode="+ this.gd.mode
				+ "',2,"
				+ this.gd.width +"," 
				+ this.gd.height + ")","");
	}
}
