/*
	$Id: $
*/


/*
	Class: frusion.server.XMLServer
	XML Server for FrusionServer. 
*/
class frusion.server.XMLServer extends XMLSocket
{


/*------------------------------------------------------------------------------------
 * Private members
 *------------------------------------------------------------------------------------*/

	
	private var host : String;
	private var port : Number;
	private var connected : Boolean;
	private var interval : Object;
		

/*------------------------------------------------------------------------------------
 * Public methods
 *------------------------------------------------------------------------------------*/


	/*
		Function: XMLServer 
		Constructor
	*/
	public function XMLServer()
	{
		this.connected = false;
		XML.prototype.ignoreWhite = true;
		AsBroadcaster.initialize(this);			
	}
	



/*------------------------------------------------------------------------------------
 * Public methods redefining parent
 *------------------------------------------------------------------------------------*/
	
	/*
		Function: connect
		Attempts to connect to specified server on specified port		
	*/
	public function connect( host : String, port : Number )
	{
		//this.debug("XMLServer:Connect");
		//this.debug("Attempt to connect to "+host+" on port "+port);
		this.host = host;
		this.port = port;
		super.connect(host,port);
	}


	/*
		Function: reconnect
		Attempts to reconnect after a given interval
		
		Parameters:
		- time : Number - time in ms		
	*/	
	public function reconnect( time : Number ) : Void
	{
		if(this.interval == undefined)
		{
			this.interval = setInterval(this,"connect",time,this.host,this.port);
		}
	}


	/*
		Function: send
		Send an xml command to server
		
		Parameters:
		xmlCommand - XML - command to send		
	*/
	public function send( xmlCommand : XML ) : Boolean
	{
		//this.debug("XMLServer:send");
		if(!this.connected)
		{
			this.debug("Must be connected to send data !");
			return false;
		}
		
		// send XML
		super.send( xmlCommand );

		//this.debug("[S] "+FEString.unHTML(xmlCommand.toString()));
		return true;
	}
	
	
/*------------------------------------------------------------------------------------
 * Callaback methods
 *------------------------------------------------------------------------------------*/

	
	/*
		Function: onConnect.
		CALLBACK
	*/
	public function onConnect( success : Boolean ) : Void
	{	
		if( success )
		{
			//this.debug("XMLServer:onConnect");
			this.debug("Connected to "+this.host+" on port "+this.port);
			this.connected = true;
			this.broadcastMessage("onXMLServerConnect");
		}		
	}
	
	
	/*
		Function: onXML
		CALLBACK.
	*/
	public function onXML( node : XML ) : Void
	{
		// to get already good step
		this.broadcastMessage("onXML", node.firstChild);
	}
	
		

/*------------------------------------------------------------------------------------
 * Private methods
 *------------------------------------------------------------------------------------*/


	/*
		Function: debug
		Appends message to _global.debug if it exists...  
	*/
	private function debug( message : String ) : Void
	{
		_global.debug(message);
	}


/*------------------------------------------------------------------------------------
 * Intrinsic methods for AsBroadcaster
 *------------------------------------------------------------------------------------*/


	function broadcastMessage(){}
	function addListener(){}
	function removeListener(){}
		

}