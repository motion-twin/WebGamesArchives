/*
	$Id: FrusionServer.as,v 1.1 2003/11/13 16:04:32  Exp $
*/


import frusion.server.XMLServer;
import frusion.server.XMLCommand;
import frusion.server.CommandParameter;
import frusion.gamedisc.GameDisc;


/*
	Class: frusion.server.FrusionServer
	Server for all frusion clients. Must be initialized at project startup.
	This class implements the singleton Design Pattern. 
	To get the one and only one instance of the singleton, call FrusionServer.getInstance();
	
*/
class frusion.server.FrusionServer extends LocalConnection
{


/*------------------------------------------------------------------------------------
 * Private members
 *------------------------------------------------------------------------------------*/


	private var frusionClient : LocalConnection;
	private var xmlsocket : XMLServer;
	private var user : String;
	private var password : String;
	private var sid : String;
	private var userIP : String;
	private var pingInterval : Object;
	private var pingInit: Number;
	private var pingTime: Number;
	private var internalCommandList : Object;
	private var outgoingConnectionName : String;
	private var receivingConnectionName : String;
	private var callbackList : Object;
	private var gameDisc : GameDisc;	


/*------------------------------------------------------------------------------------
 * Private static members
 *------------------------------------------------------------------------------------*/


	private static var instance : FrusionServer;
	private static var count : Number = 0;
		 

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


	/*
		Function: connect
		Tries to connect to host.

	 	Parameters:
	 	- host : String - host we want to connect to 
	 	- port : Number - port on the host we want to connect to 
	*/
	private function XMLServerConnect( host : String, port : Number ) : Void
	{
		this.xmlsocket.connect( host, port );
	}			

	
	/*
		Function: FrusionServer
		Private constructor
	*/
	private function FrusionServer()
	{
		super();

		// Inits connection to Server
		this.xmlsocket = new XMLServer();
		
		
		// Inits connection to get information from the client
		// Note: use of underscore is important as connections 
		// through different domains need this to find the shared LocalConnection 
		// see flash doc (allow domain)
		this.receivingConnectionName = "_frusionServer";		
		this.connect( this.receivingConnectionName );

		
		// create internal services
		this.internalCommandList = new Object();
		this.internalCommandList.error 			= "a";
		this.internalCommandList.serviceinfo 	= "b";
		this.internalCommandList.time 			= "c";
		this.internalCommandList.ip 			= "d";
		this.internalCommandList.ping 			= "e";
		this.internalCommandList.ident 			= "k";
		
		
		// create internal callbacklist
		this.callbackList = new Object();
		this.callbackList.onError 		= "a";
		this.callbackList.onServiceinfo = "b";
		this.callbackList.onTime 		= "c";
		this.callbackList.onIp 			= "d";
		this.callbackList.onIdent 		= "k";		
		this.callbackList.onPing 		= "e";
	}
	

/*------------------------------------------------------------------------------------
 * Public static methods
 *------------------------------------------------------------------------------------*/

	
	/*
		Function: getInstance
		Singleton function to get the one and only one server instance
		
		Returns:
		FrusionServer - only one available instance fo the server 
	*/
	public static function getInstance() : FrusionServer
	{
		if( FrusionServer.instance == null )
			FrusionServer.instance = new FrusionServer();
		
		FrusionServer.count++;

		_global.debug( "FrusionServer:getInstance - number: " + FrusionServer.count );
		
		return FrusionServer.instance;	
	}
	
	
	/*
		Function: getInstanceCount
		Get the count of calls to FrusionServer.getInstance().

		Returns:
		count - count of calls to FrusionServer.getInstance().
	*/
	public static function getInstanceCount() : Number
	{
		return FrusionServer.count;
	}
	


/*------------------------------------------------------------------------------------
 * Public methods
 *------------------------------------------------------------------------------------*/


	/*
	 	Function: init
	 	Init server information to identify user succesfully
	 	
	 	Parameters:
	 	- user : String - user we use to connect to service
	 	- password : String - unencrypted user password 
	 	- sid : String - current session id
	*/
	public function init( user : String, password : String, sid : String, gameDisc : GameDisc )
	{
		// backup parameters ;)
		this.user = FEString.trim( user );
		this.password = FEString.trim( password );
		this.sid = FEString.trim( sid );
		this.gameDisc = gameDisc;
	}


	/*
		Function: ip
		send an ip command to XMLServer
	*/
	public function ip() : Void
	{
		this.xmlsocket.send( XMLCommand.buildCommand( "d", new Array(), null ) ); 
	}
	

	/*
		Function: ping
		send a ping command to XMLServer
	*/
	public function ping() : Void
	{
		this.xmlsocket.send( XMLCommand.buildCommand( "e", new Array(), null ) ); 
	}
	
	
	/*
		Function: ident
		send an ident command to XMLServer
	*/
	public function ident() : Boolean
	{
		_global.debug( "FrusionServer:ident" );
		if(this.userIP == undefined)
		{
			this.debug("Ident requires IP");
			return false;
		}

		/*
		if(this.logged)
		{
			this.debug("Already logged");
			return false;
		}
		*/

		if(this.user != undefined && this.password != undefined)
		{
			this.xmlsocket.send( 
				XMLCommand.buildCommand( 
					"k", 
					new Array( 
						new CommandParameter( "m", MD5.encode(this.userIP + MD5.encode(this.password) ) ), 
						new CommandParameter( "l", this.user ), 
						new CommandParameter( "s", this.sid ) ), 
					null ) );					 
		}
		else
		{
			return false;
		}
						
	}
	
	
	/*
		Function: time
		send a time command to XMLServer
	*/
	public function time() : Void
	{
		this.xmlsocket.send( XMLCommand.buildCommand( "c", new Array(), null ) ); 
	}


/*------------------------------------------------------------------------------------
 * Public methods called by client
 *------------------------------------------------------------------------------------*/
 
	
	/*
	 	Function: getService
	 	Connect to a CBee service
	 	
	 	Parameters:
	 	- host : String - host we want to connect to 
	 	- port : Number - port on the host we want to connect to 
	 	- user : String - user we use to connect to service
	 	- password : String - unencrypted user password 
	 	- sid : String - current session id
	*/
	public function getService( host : String, port : Number ) : Void
	{				
		// connect to the service
		this.xmlsocket.addListener( this );
		
		// connect and try to ident in the callback
		this.XMLServerConnect( host, port );
	}
	
	
	/*
		Function: sendClientCommand
		Send a command which is sent by the client
		
		Parameters:
		- command : XMLCommand 
	*/
	public function sendClientCommand( command : XML ) : Void
	{
		_global.debug( "FrusionServer:sendClientCommand" );
		this.xmlsocket.send( command );
	}
	
	
	/*
		Function: getGameDisc()
		Returns current game disc to client 
	*/
	public function getGameDisc() : Void
	{
		_global.debug( "FrusionServer:getGameDisc" );
		_global.debug( "FrusionServer:gd="+this.gameDisc ) ;
		_global.debug( "FrusionServer:id="+this.gameDisc.id ) ;
		this.frusionClient.send( this.outgoingConnectionName, "onGetGameDisc", this.gameDisc );
	}
		
	
	/*
		Function: getUser
		Returns current user to client
	*/
	public function getUser() : Void
	{
		_global.debug( "FrusionServer:getUser=" + this.user );
		this.frusionClient.send( this.outgoingConnectionName, "onGetUser", this.user );
	}
	
	
/*------------------------------------------------------------------------------------
 * XMLServer callbacks
 *------------------------------------------------------------------------------------*/
		
	
	/*
		Function: onXMLServerConnect
		CALLBACK. After connection to server
	*/
	public function onXMLServerConnect()
	{
		//_global.debug( "FrusionServer:onXMLServerConnect");
		
		// Inits connection to send info to client
		this.outgoingConnectionName = "_frusionclient";
		this.frusionClient = new LocalConnection();
		this.frusionClient.onStatus = function( infoObject)
		{
			for(var n in infoObject)
				_global.debug( n + "=" + infoObject[n] );
			
			if (infoObject.level == "error" )
			   _global.debug("FrusionServer:onXMLServerConnect : Connection to client failed.");
			else
			   _global.debug("FrusionServer:onXMLServerConnect : Connection to client ok.");
		}

		
		//_global.debug( "FrusionServer:onXMLServerConnect" );
		
		// ping every 60000 ms
		this.pingInterval = setInterval(this, "ping", 60000);
		
		// sending a time command
		this.time();
		
		// sending an ip command to begin ident process
		this.ip();		
	}

	
	/*
		Function : onXML
		CALLBACK. called when any xml information is received in the XMLServer 
	*/
	public function onXML( node: XML ) : Void
	{
		//_global.debug( "FrusionServer:onXML" );
		
		// get k code value because all internal commands have
		// their code inferior to k		
		var kString : String = "k";
		var kIndex : Number = kString.charCodeAt(0);
		 

		// get nodeName and code		
		var xmlReceived = new XML( node.toString());
		xmlReceived = xmlReceived.lastChild;
		var nodeName : String = xmlReceived.nodeName;
		var l : Number = nodeName.length;
		var nodeNameCode : Number = 0;
		if( l > 1 )
		{
			for( var i : Number = 0; i < l ; i++ )
				nodeNameCode += nodeName.charCodeAt(i);
		}
		else
		{
			nodeNameCode = nodeName.charCodeAt(0);
		}	
			

		// if commands code are inferior to k let's use internal commands
		// else send node to client for further analysis		
		if( nodeNameCode <= kIndex )
		{
			// call function lsited in callbackList
			for(var n in this.callbackList)
			{
				if(this.callbackList[n] == xmlReceived.nodeName)
				{	
					this[n](node);
					break;
				}
			}		
		}
		else
		{
			// dispatch info to client
			// toString temporary ???
			this.frusionClient.send( this.outgoingConnectionName, "onXML", node.toString() );
		}
	}


	/*
		Function: onPing
		CALLBACK. After ping command
	*/
	public function onPing( node : XML ) : Void
	{
		this.pingTime = _global.localTime.getTime() - this.pingInit;
		this.pingInit = 0;

	}



	/*
		Function: onTime
		CALLBACK. After time command
	*/
	public function onTime( node : XML )  : Void
	{
		_global.servTime.setFromString(FEString.trim(node.toString()));
		//this.debug("Server time: "+Lang.formatDate(_global.servTime.getDateObject(),"long_complete"));
	}


	/*
		Function: onIp
		CALLBACK. After ip command
	*/
	public function onIp( node : XML ) : Void
	{
		this.userIP = FEString.trim(node.firstChild.nodeValue.toString());
		if(this.user != undefined && this.password != undefined)
			this.ident();
	}
		

	/*
		Function: onIdent
		CALLBACK. After ident command
	*/
	public function onIdent( node : XML ) : Void
	{
		_global.debug( "FrusionServer:onIdent - identification received");
		this.frusionClient.send( this.outgoingConnectionName, "onIdent", node );
	}
	
	
/*------------------------------------------------------------------------------------
 * Public methods redefining parent
 *------------------------------------------------------------------------------------*/


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


	/*
	 	Function: allowDomain
	 	Inits connection to Frutiparc server. 
	 		 	
	 	 Parameters:
	 	 - sendingDomain : String - the name of the incoming request's domain  
	*/
	public function allowDomain( sendingDomain : String ) : Boolean
	{
		//XXX Troisi�me domaine swf
		//_global.debug( "allowDomain");
	  	return( sendingDomain=="www.beta.frutiparc.com" || sendingDomain == "hq.motion-twin.com" );
	}	
	
}