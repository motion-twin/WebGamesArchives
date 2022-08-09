/*
	$Id:  $
*/


import frusion.client.FrusionClient;
import frusion.server.CommandParameter;


/*
	Class: frusion.service.FrutiCard
	Fruticard Service handler	
*/
class frusion.service.FrutiCard 
{


/*------------------------------------------------------------------------------------
 * Public members
 *------------------------------------------------------------------------------------*/


	public var gameName : String;
	

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
		Function: FrutiCard
		Constructor
	*/
	public function FrutiCard( gameName : String, frusionClient : FrusionClient )
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
		this.callbackList.onGetPublicSlot		= "fa";
		this.callbackList.onListAvailableSlots 	= "fb";
		this.callbackList.onLoadSlot 			= "fc";
		this.callbackList.onUpdateSlot 			= "fd";
		this.callbackList.onClearSlot			= "fe";
		this.frusionClient.registerCallbackList( callbackList );
		
				
		// creating appropriate commands		
		this.commandList = new Object();
		this.commandList.getPublicSlot		= "fa";
		this.commandList.listAvailableSlots = "fb";
		this.commandList.loadSlot 			= "fc";
		this.commandList.updateSlot			= "fd";
		this.commandList.clearSlot 			= "fe";		
		
	}


/*------------------------------------------------------------------------------------
 * Public methods calling FrusionClient
 *------------------------------------------------------------------------------------*/ 


	/*
		Function: getPublicSlot
		Retrieve the public slot of specified user
		
		Parameters:
		slotOwner : String
	*/
	public function getPublicSlot( slotOwner : String ) : Void
	{
		this.frusionClient.sendCommand( 
				this.commandList.getPublicSlot, 
				new Array( 
					new CommandParameter( "u", slotOwner ), 
					new CommandParameter( "g", this.gameName ) ) );
	}
	
	

	/*
		Function: listAvailableSlots
		This command returns a list of slot slots available for specified game
	*/
	public function listAvailableSlots() : Void
	{
		_global.debug( "FrutiCard:listAvailableSlots");
		this.frusionClient.sendCommand( 
				this.commandList.listAvailableSlots, 
				new Array( 
					new CommandParameter( "g", this.gameName ) ) );
	}
	
	
	/*
		Function: loadSlot
		Retrieve specified slot (create new one if not found)
		
		Parameters:
		slotId : Number : slot Id
	*/
	public function loadSlot( slotId : Number ) : Void
	{
		this.frusionClient.sendCommand( 
				this.commandList.loadSlot, 
				new Array( 
					new CommandParameter( "s", slotId ), 
					new CommandParameter( "g", this.gameName ) ) );
	}
	
	
	/*
		Function: updateSlot
		Update slot content
		
		Parameters:
		slotId : Number : slot Id
	*/
	public function updateSlot( slotId : Number ) : Void
	{
		this.frusionClient.sendCommand( 
				this.commandList.updateSlot, 
				new Array( 
					new CommandParameter( "s", slotId ), 
					new CommandParameter( "g", this.gameName ) ) );
	}
	
	
	/*
		Function: clearSlot
		Delete a slot
		
		Parameters:
		slotId : Number : slot Id
	*/
	public function clearSlot( slotId : Number ) : Void
	{
		this.frusionClient.sendCommand( 
				this.commandList.clearSlot, 
				new Array( 
					new CommandParameter( "s", slotId ), 
					new CommandParameter( "g", this.gameName ) ) );
	}
	

/*------------------------------------------------------------------------------------
 * Public callback methods from FrusionClient
 *------------------------------------------------------------------------------------*/ 


	public function onGetPublicSlot( node : XML ) : Void
	{
		this.broadcastMessage("onGetPublicSlot", node);		
	}
	
	
	public function onListAvailableSlots( node : XML ) : Void
	{
		_global.debug("FrutiCard:onListAvailableSlots");
		this.broadcastMessage("onListAvailableSlots", node);		
	}
	
	
	public function onLoadSlot( node : XML ) : Void
	{
		this.broadcastMessage("onLoadSlot", node);		
	}
	
	
	public function onUpdateSlot( node : XML ) : Void
	{
		this.broadcastMessage("onUpdateSlot", node);		
	}
	
	
	public function onClearSlot( node : XML ) : Void
	{
		this.broadcastMessage("onClearSlot", node);		
	}



/*------------------------------------------------------------------------------------
 * Intrinsic methods for AsBroadcaster
 *------------------------------------------------------------------------------------*/


	function broadcastMessage(){}
	function addListener(){}
	function removeListener(){}


}
