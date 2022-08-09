/*
	$Id: FakeManager.as,v 1.1 2003/11/13 16:04:32  Exp $
*/


import frusion.server.FrusionServer;
import frusion.FakeFrusionSlot ;
import frusion.gamedisc.GameDiscLoader;
import frusion.gamedisc.GameDisc;
import frusion.util.Callback;


/*
	Class: FakeManager
*/
class frusion.FakeManager
{


/*------------------------------------------------------------------------------------
 * Private members
 *------------------------------------------------------------------------------------*/


	private var fs : FakeFrusionSlot;
	private var sid : Number;
	

/*------------------------------------------------------------------------------------
 * Public members 
 *------------------------------------------------------------------------------------*/

	public var gameDisc : GameDisc;

/*------------------------------------------------------------------------------------
 * Public methods
 *------------------------------------------------------------------------------------*/

	
	/*
		Function: FakeManager
		Constructor
	*/
	public function FakeManager(sid) {
	  this.sid = sid ;
	}
	
		
	/*
		Function: launchGameDisc
		Get information for a game disc and creates a new frusion slot
	*/
	public function launchGameDisc( id : String )
	{
		_global.debug( "FakeManager:launchGameDisc id=" + id );
		
		var gdl : GameDiscLoader = new GameDiscLoader();
		gdl.loadGameDisc( id, new Callback( this, "onLaunchGameDisc" ), this.sid );
	}
	
	
	/*
		Function: onLaunchGameDisc
		CALLBACK. creates a new slot when the game disc information have been retrieved by the GameDiscLoader
	*/
	public function onLaunchGameDisc( gd: GameDisc )
	{
		_global.debug( "FakeManager:onLaunchGameDisc =" + gd.id );

		// Creates a new slot for the frusion and launch the fake slot
		this.fs = new FakeFrusionSlot( gd );
		this.fs.init( this.sid );
		
		// store game disc
		this.gameDisc =  gd ;

	    var frusionServer : FrusionServer ;
	    frusionServer = FrusionServer.getInstance() ;
	    frusionServer.init( String(_root.login), String(_root.pass), String(this.sid), this.gameDisc ) ;
	}

}
