/*
 	$Id:$
*/


#include "../frutiengine/MovieClip.class.as"


import frusion.FakeManager;
import frusion.server.FrusionServer;

 
// Attach beautiful screenTop
this.attachMovie( "screenTop", "screenTop", 0);
this.screenTop._x = 0;
this.screenTop._y = 0;


// Setting network environment
_global.baseURL = "http://www.beta.frutiparc.com/";
_global.swfURL = "http://www.beta.frutiparc.com/swf/";
System.security.allowDomain("www.beta.frutiparc.com");


// Setting up other globals
_global.servTime = new RunDate();
_global.localTime = new RunDate();


// Setting up debug mode
if(_root.debugOn != undefined)
{
	_root.createTextField("dbgTextField",5000,20,20,400,600);
	_root.dbgTextField.variable = "_root.test";
	_root.dbgTextField.selectable = true;
	_root.dbgTextField.wordWrap = true;
	_root.dbgTextField.html = false;
	
	_root.test = "";
		
	_global.debug = function(str){
		_root.test += str+"\n";
	}
} 


// temporary function to clear log
function clearLog() : Void { _root.test = ""; }


// Lauching Frutiparc frusion Slot which will launch a popup window with the game
manager = new FakeManager( _root.sid );
manager.launchGameDisc( _root.id, _root.login );


// Launching frusion server local connection
var host : String = "www.beta.frutiparc.com";
var port : Number = 2000;
