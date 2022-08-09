/*
	$Id: FrusionClient.as,v 1.1 2003/11/13 16:04:32  Exp $
*/


import frusion.server.XMLCommand;
import frusion.gamedisc.GameDisc;


/*
	Class: frusion.client.FrusionClient
	Client for the singleton FrusionServer.	
*/
class frusion.client.FrusionClient extends LocalConnection
{


/*------------------------------------------------------------------------------------
 * Public members
 *------------------------------------------------------------------------------------*/


	public var identified : Boolean = false;
	

/*------------------------------------------------------------------------------------
 * Private members
 *------------------------------------------------------------------------------------*/


	private var frusionServer : LocalConnection;
	private var outgoingConnectionName : String
	private var receivingConnectionName : String
	private var callbackList : Object;
	private var gameDisc : GameDisc;
	private var user: String;
	

/*------------------------------------------------------------------------------------
 * public methods
 *------------------------------------------------------------------------------------*/

	
	/*
		Function: FrusionClient
		Public constructor
	*/
	public function FrusionClient()
	{
		super();
		
		//_global.debug( "FrusionClient" );
		// Inits connection to send info to server
		this.outgoingConnectionName = "_frusionserver";
		this.frusionServer = new LocalConnection();			
		this.frusionServer.onStatus = function( infoObject)
		{
//			for(var n in infoObject)
//				_global.debug( n + "=" + infoObject[n] );
			
			if (infoObject.level == "error" )
			   _global.debug("Connection to server failed.");
			else
			   _global.debug("Connection to server ok.");
		}
		
		
		// Inits connection to get information from the server
		// Note: use of underscore is important as connections 
		// through different domains need this to find the shared LocalConnection 
		// see flash doc (allow domain)
		this.receivingConnectionName = "_frusionclient";		
		this.connect( this.receivingConnectionName );
		
		// Create listeners
		AsBroadcaster.initialize(this);
		
		this.callbackList = new Object();
							
	}
	
	
	/*
		Function: getService
		Open a connection to the specified service
		
		Parameters:
		- serviceName : Number - the service name or port on host 
	*/
	public function getService( serviceName : Number ) : Void
	{
		//_global.debug( "FrusionClient:getService=" +  serviceName);
		//_global.debug( "service asked=" + serviceName );
		// Note: use of underscore is important as connections 
		// through different domains need this to find the shared LocalConnection 
		// see flash doc (allow domain)
		this.frusionServer.send( this.outgoingConnectionName, "getService", "www.beta.frutiparc.com", serviceName);
	} 
	
	
	/*
		Function: registerCallbackList
		Registers client callback functions.
		
		Parameters:
		- callback : Object - list of callback functions
		
	*/
	public function registerCallbackList( callbackList : Object ) : Void
	{
		// updating list with new callbacks
		for( var n in callbackList )
			this.callbackList[n] =  callbackList[n];

		/*
		for( var n in this.callbackList )
			_global.debug( "n=" + n );
		*/	
	}
	
	
	/*
		Function: sendCommand
		Send an xml command to server
		
		Parameters:
		commandName - String : command name		
		parameters - Array of CommandParameter(s) objects: all the command parameters		
	*/	
	public function sendCommand( commandName: String, parameters: Array ) : Void
	{
		//_global.debug( "FrusionClient:sendCommand=" + commandName );
		this.frusionServer.send( this.outgoingConnectionName, "sendClientCommand", XMLCommand.buildCommand( commandName, parameters, null ) )
	}
	

	/*
		Function: sendCommandWithText
		Send an xml command to server with an xml node
		
		Parameters:
		commandName - String : command name		
		parameters - Array of CommandParameter(s) objects: all the command parameters
		data - Object 		
	*/	
	public function sendCommandWithText( commandName: String, parameters: Array, data ) : Void
	{
		//_global.debug( "FrusionClient:sendCommand=" + commandName );
		this.frusionServer.send( this.outgoingConnectionName, "sendClientCommand", XMLCommand.buildCommand( commandName, parameters, data ) )
	}


	/*
		Function: getGameDisc
		Ask server for loaded game disc
	*/
	public function getGameDisc() : Void
	{
		//_global.debug( "FrusionClient:getGameDisc");
		this.frusionServer.send( this.outgoingConnectionName, "getGameDisc", null );		
	}
	

	/*
		Function: getUser
		Ask server for current user
	*/
	public function getUser() : Void
	{
		// _global.debug( "FrusionClient:getUser");
		this.frusionServer.send( this.outgoingConnectionName, "getUser", null );		
	}


	/*
		Function logError
		Log errors
		
		Parameters:
		- user : String - current user		
		- message : String - error message
		
		Note: please encrypt data before using logError...
	*/
	public function logError( user: String, message : String) : Void
	{
		// Check if don't have username already stored
	} 
	
	
/*------------------------------------------------------------------------------------
 * Public methods incoming from LocalConnection
 *------------------------------------------------------------------------------------*/

	
	/*
		Function : onXML
		Called by FrusionServer when XML information has arrived 
		and are not to be treated by the server.
		The function parses xml and see if it finds the callback to call
		in its callback list
		
		Parameters:
		-node : XML - the node sent by the server
	*/	
	public function onXML( node : String ) : Void
	{	
		var xmlReceived = new XML( node.toString());		
		for(var n in this.callbackList)
		{			
			if(this.callbackList[n] == xmlReceived.firstChild.nodeName)
			{
				_global.debug( "n=" + n );
				_global.debug( "this.callbackList[n]=" + this.callbackList[n] );
				this.broadcastMessage( n, node );
				break;
			}
		}		
	}
	
	
	/*
		Function: onIdent
	*/
	public function onIdent( node : XML ) : Void
	{
		//_global.debug("FrusionClient:onIdent and identified ok");

		this.identified = true;
		
		this.broadcastMessage( "onIdent", node );
	}
	
	
	/*
		Function: onGetGameDisc
	*/
	public function onGetGameDisc( gd:GameDisc ) : Void
	{
		//_global.debug("FrusionClient:onGetGameDisc");
				
		this.gameDisc = gd ;
		
		_global.debug( "onGetGameDisc: gd.id=" +this.gameDisc.id ); 
		_global.debug( "onGetGameDisc: swfName=" +this.gameDisc.swfName );
		 
		this.broadcastMessage( "onGetGameDisc", this.gameDisc );
	}
	

	/*
		Function: onGetUser
	*/
	public function onGetUser( user : String ) : Void
	{
		//_global.debug("FrusionClient:onGetUser");
				
		this.user = user;
				
		this.broadcastMessage( "onGetUser", user );
	}

	 
/*------------------------------------------------------------------------------------
 * Public methods redefining parent
 *------------------------------------------------------------------------------------*/


	/*
	 	Function: allowDomain
	 	Inits connection to Frutiparc server. 
	 		 	
	 	 Parameters:
	 	 - sendingDomain : String - the name of the incoming request's domain  
	*/		
	public function allowDomain( sendingDomain ) : Boolean
	{
		//_global.debug( "allowDomain_client");
		//XXX Troisi�me domaine swf
	  	return( sendingDomain == "www.beta.frutiparc.com" || sendingDomain == "hq.motion-twin.com" );
	}	
	
	
	/*
	 	Function: allowInsecureDomain
	 	Inits connection to Frutiparc server. 
	 	Note: not used by flash 6 swf
	 	
	 	 Parameters:
	 	 - sendingDomain : String - the name of the incoming request's domain  
	*/
	public function allowInsecureDomain( sendingDomain: String ) : Boolean
	{
		//XXX Troisi�me domaine swf
		//_global.debug( "allowInsecureDomain");
	  	return( sendingDomain=="www.beta.frutiparc.com" || sendingDomain == "hq.motion-twin.com" );
	}	
	

/*------------------------------------------------------------------------------------
 * Intrinsic methods for AsBroadcaster
 *------------------------------------------------------------------------------------*/


	function broadcastMessage(){}
	function addListener(){}
	function removeListener(){}
		
	
}