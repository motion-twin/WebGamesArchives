/*
	$Id:  $
*/


import frusion.client.FrusionClient;
import frusion.server.CommandParameter;


/*
	Class: frusion.service.FrutiChat
	FrutiChat Service handler	
*/
class frusion.service.FrutiChat 
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
		Function: FrutiChat
		Constructor
	*/
	public function FrutiChat( gameName : String, frusionClient : FrusionClient )
	{
		// Get game name
		this.gameName = gameName;
	
	
		// Prepare broadcasting interface
		AsBroadcaster.initialize(this);			
		
			
		// Add listener to current service
		this.frusionClient = frusionClient ;
		this.frusionClient.addListener(this);				
		
		// Registering callback list
		this.callbackList = new Object();
		/// XXX to do add callbacks
		this.frusionClient.registerCallbackList( callbackList );
		
				
		// creating appropriate commands		
		this.commandList = new Object();
		/// XXX to do add callbacks
		
	}


/*------------------------------------------------------------------------------------
 * Public methods calling FrusionClient
 *------------------------------------------------------------------------------------*/ 
		

/*------------------------------------------------------------------------------------
 * Public callback methods from FrusionClient
 *------------------------------------------------------------------------------------*/ 
	

/*------------------------------------------------------------------------------------
 * Intrinsic methods for AsBroadcaster
 *------------------------------------------------------------------------------------*/


	function broadcastMessage(){}
	function addListener(){}
	function removeListener(){}


}
