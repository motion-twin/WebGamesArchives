/*
	$Id:  $
*/


import frusion.client.FrusionClient;
import frusion.server.CommandParameter;


/*
	Class: frusion.service.FrutiScore
	FrutiScore Service handler	
*/
class frusion.service.FrutiScore
{


/*------------------------------------------------------------------------------------
 * Private members
 *------------------------------------------------------------------------------------*/


	private var frusionClient : FrusionClient;
	private var callbackList : Object;	
	private var commandList : Object;	


/*------------------------------------------------------------------------------------
 * Public methods
 *------------------------------------------------------------------------------------*/

	
	/*
		Function: FrutiScore
		Constructor
	*/
	public function FrutiScore( frusionClient : FrusionClient )
	{	
		// Prepare broadcasting interface
		AsBroadcaster.initialize(this);			
		
			
		// Add listener to current service
		this.frusionClient = frusionClient ;
		this.frusionClient.addListener(this);				
		
		// Registering callback list
		this.callbackList = new Object();
		this.callbackList.onListModes			= "v";
		this.callbackList.onStartGame		 	= "o";
		this.callbackList.onEndGame 			= "p";
		this.callbackList.onSaveScore 			= "q";
		this.callbackList.onListRankings		= "l";
		this.callbackList.onRankingResult		= "m";
		this.callbackList.onUserResult			= "n";		
		this.frusionClient.registerCallbackList( callbackList );
		
				
		// creating appropriate commands		
		this.commandList = new Object();
		this.commandList.listModes			= "v";
		this.commandList.startGame		 	= "o";
		this.commandList.endGame 			= "p";
		this.commandList.saveScore 			= "q";
		this.commandList.listRankings		= "l";
		this.commandList.rankingResult		= "m";
		this.commandList.userResult			= "n";		
	}


/*------------------------------------------------------------------------------------
 * Public methods calling FrusionClient
 *------------------------------------------------------------------------------------*/ 


	/*
		Function: listModes
		List available modes for specified disc
		
		Parameters:
		discId : String (MD5)
	*/
	public function listModes( discId : String ) : Void
	{
		this.frusionClient.sendCommand( 
				this.commandList.listModes, 
				new Array( 
					new CommandParameter( "d", discId ) ) );
	}
	

	/*
		Function: startGame
		Initialize a new game. 
		The server will return the disc type if game successfully initialized (0,1,2,3).
		
		Parameters:
		d - disc id (md5)
		m - game mode	
	*/
	public function startGame( d : String, m : Number ) : Void
	{
		this.frusionClient.sendCommand( 
				this.commandList.startGame, 
				new Array( 
					new CommandParameter( "d", d ),
					new CommandParameter( "m", m ) ) );
	}


	/*
		Function: endGame
		End current play. 
		This command requires no attribute as the server can retrieve 
		the latest unfinished player game.
	*/
	public function endGame() : Void
	{
		this.frusionClient.sendCommand( 
				this.commandList.endGame, 
				new Array() );
	}


	/*
		Function: saveScore
		Save some scores for the current play. 
		The server will provide a list of results depending of score progression 
		on each available rankings.
	*/
	public function saveScore() : Void
	{
		//XXX todo
	}



	/*
		Function: listRankings
		Retrieve a list of available rankings for later consultation. 
		If no attribute is specified, the server will return a list of all current rankings.
	*/
	public function listRankings() : Void
	{
		this.frusionClient.sendCommand( 
				this.commandList.listRankings, 
				new Array() );
	}


	/*
		Function: rankingResult
		Retrieve specified ranking results (scores and players).
		
		Parameters:
		- rk - ranking id
		- s - result start
		- l - result limit		
	*/
	public function rankingResult( rk : Number, s: Number, l : Number ) : Void
	{
		this.frusionClient.sendCommand( 
				this.commandList.listRankings, 
				new Array( 
					new CommandParameter( "rk", rk ),
					new CommandParameter( "s", s ),
					new CommandParameter( "l", l ) ) );
	}


	/*
		Function: userResult
		Retrieve current user result on many rankings OR mixed users results on many rankings.
	*/
	public function userResult() : Void
	{
		//XXX todo
	}


/*------------------------------------------------------------------------------------
 * Public callback methods from FrusionClient
 *------------------------------------------------------------------------------------*/ 


	public function onListModes( node : XML ) : Void
	{
		this.broadcastMessage("onListModes", node);		
	}
	

	public function onStartGame( node : XML ) : Void
	{
		this.broadcastMessage("onStartGame", node);		
	}


	public function onEndGame( node : XML ) : Void
	{
		this.broadcastMessage("onEndGame", node);		
	}


	public function onSaveScore( node : XML ) : Void
	{
		this.broadcastMessage("onSaveScore", node);		
	}


	public function onListRankings( node : XML ) : Void
	{
		this.broadcastMessage("onListRankings", node);		
	}


	public function onRankingResult( node : XML ) : Void
	{
		this.broadcastMessage("onRankingResult", node);		
	}
	

	public function onUserResult( node : XML ) : Void
	{
		this.broadcastMessage("onUserResult", node);		
	}


/*------------------------------------------------------------------------------------
 * Intrinsic methods for AsBroadcaster
 *------------------------------------------------------------------------------------*/


	function broadcastMessage(){}
	function addListener(){}
	function removeListener(){}


}
