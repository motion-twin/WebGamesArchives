/*
	$Id: GameDiscLoader.as,v 1.8 2003/11/20 10:18:47  Exp $
*/


import frusion.gamedisc.GameDisc;
import frusion.gamedisc.GameFile;
import frusion.util.Callback;
import util.Misc;

/*
	Class: GameDiscLoader
*/
class frusion.gamedisc.GameDiscLoader
{


/*------------------------------------------------------------------------------------
 * Public members
 *------------------------------------------------------------------------------------*/


	public var callback : Callback;
	 

/*------------------------------------------------------------------------------------
 * Public methods
 *------------------------------------------------------------------------------------*/

	
	/*
		Function: GameDiscLoader
		Constructor
	*/
	public function GameDiscLoader() {}
	
	
	
	/*
		Function: loadGameDisc
		Loads a game disc. Gets its information from HTTP Server
		
		Parameters:
		- id: Number - game uid
		- callback: Callback - callback function to call when loeading is finished
	*/
	public function loadGameDisc( id : String, callback : Callback, sid: Number ) : Void
	{		
		this.callback = callback;

		// Calls disc loading animation
		_global.fileMng.callListeners( id, "initMove" );
				
		// ask for GameDisc information		
		var loader = new HTTP("do/ld", {u:id, sid:sid}, {type: "xml", obj: this, method:"onLoadGameDisc"} );
	}
	


/*------------------------------------------------------------------------------------
 * Private methods
 *------------------------------------------------------------------------------------*/
	
	
	/*
		Function: onLoadGameDisc
		CALLBACK method called once the gamedisc is loaded;
	*/
	private function onLoadGameDisc( success, node ) : Void
	{
		// parse XML information
		var n = node.lastChild;
		if(n.attributes.k != undefined)
		{
			//this.openError();
		}

		// get disc properties : height, width and open mode
		var prop : Object = FEString.propParse(n.attributes.p);			
		var discType = n.attributes.t;		
		var swfName = n.attributes.n;
		var discId = n.attributes.u;		
		
		// getting swf size and id
		var id : String;
		var size : Number;
		var swfName : String;
		var files : Object;
		files = new Object() ;
		for(var x=n.firstChild;x.nodeType>0;x=x.nextSibling){
			if(x.nodeName == "s")
			{
				if( x.attributes.n == undefined )
				{
				  _global.debug("onLoadGameDisc: file \"index\" added") ;
					files["index"]= new GameFile( x.attributes.u, x.attributes.s );  
				}
				else
				{

				  // Code de remplacement (temporaire !!) du "." par "_"
				  var name = x.attributes.n ;
				  if ( name.indexOf(".") )
				  {
				    //name = name.substr(0,name.indexOf(".")) + "_" + name.substr(name.indexOf(".")+1) ;
				    name = Misc.strReplace( name, ".", "_", 0 );
				  }
				  
				  _global.debug("onLoadGameDisc: file \""+name+"\" added") ;
					files[name]= new GameFile( x.attributes.u, x.attributes.s );  
				}
			}
		}	
		
		// create GameDisc and execute callback
		this.callback.execute( new GameDisc( discType, swfName, discId, prop.w, prop.h, prop.m, files ) );		
	}
	
}