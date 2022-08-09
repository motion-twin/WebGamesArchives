/*
 	$Id:$
*/


#include "../frutiengine/MovieClip.class.as"


import frusion.gamedisc.GameDisc;
import frusion.client.FrusionLoader;
import frusion.client.FrusionClient;
import frusion.server.XMLCommand;
import frusion.server.CommandParameter;

 
// Setting network environment
_global.swfURL = "http://www.beta.frutiparc.com/swf/";
System.security.allowDomain("www.beta.frutiparc.com");


// Setting up temporary tmod
_global.tmod = 1;


// Getting info from HTML
if(_root.sid == undefined){_root.sid="debug";}
if(_root.disc_type == undefined){_root.disc_type = 0;}
if( _root.debugOn == undefined ) { _root.debugOn = 1;}


// Setting up debug mode
if(_root.debugOn != undefined)
{
	_root.createTextField("dbgTextField",5000,0,0,Stage.width,Stage.height);
	_root.dbgTextField.variable = "_root.test";
	_root.dbgTextField.selectable = false;
	_root.dbgTextField.wordWrap = true;
	_root.dbgTextField.html = false;
	
	_root.test = "";
	
	_global.debug = function(str){
		_root.test += str+"\n";
	}
} 


//_global.debug("new frusion");

// Loading frusion
gameDisc = new GameDisc( _root.disc_type, _root.gameName, _root.id , _root.width, _root.height, "e", null );
fl = new FrusionLoader( _global.swfURL, this, gameDisc );

