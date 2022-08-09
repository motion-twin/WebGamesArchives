/*
$Id: CBeeLocal.as,v 1.10 2004/03/19 18:14:44  Exp $
*/
class CBeeLocal{
	var cmdList:Object;
	var listeners:Object;
	var specificListeners:Object;
	var initialized:Boolean;
	var connected:Boolean;
	var logged:Boolean;
	var port:Number;
	var cbeeLC;
	
	function CBeeLocal(obj){
		for(var n in obj){
			this[n] = obj[n];
		}

		this.cmdList = new Object();
		this.cmdList.onclose = "onclose";
		this.cmdList.onconnect = "onconnect";

		#include "../../frutiparc/cmdList.as"

		this.listeners = new Object();
		this.specificListeners = new Object();

		this.initialized = false;
		this.connected = false;
		this.logged = false;

		this.addListener("ident",this,"onIdent");
	}

	function init(){
		if(this.port == undefined){
			_global.debug("CbeeLocalInt: Empty port: "+this.port);
			return;
		}
		
		#include "../../frutiparc/cmdList2.as"

		this.initialized = true;

		this.cbeeLC = _global.cbeeMng.addListener(this.port,this,true);
		
		var obj = _global.cbeeMng.getStatus(this.port);
		if(obj.connected) this.onConnect(true);
		if(obj.logged) this.callListenersArray(this.listeners[this.cmdList.ident]);
	}
	
	function close(){
		_global.cbeeMng.removeListener(this.port,this);
	}
	
	function check(){
	}

	function onConnect(success){
		if(success){
			this.connected = true;
		}else{
			this.connected = false;
		}
		this.logged = false;
		this.callListenersArray(this.listeners["onconnect"],success);
	}

	function onClose(){
		this.connected = false;
		this.logged = false;
		this.callListenersArray(this.listeners["onclose"]);
	}


	function onXML(node){
		var cmdName = node.nodeName.toLowerCase();
		this.callListenersArray(this.listeners[cmdName],node);
		for(var attrib in node.attributes){
			this.callListenersArray(this.specificListeners[cmdName][attrib][node.attributes[attrib]],node);
		}
	};

	function send(s){
		if(!this.initialized) return false;

		this.cbeeLC.send(s);
	}

	function cmd(cmd:String,attr:Object,child){
		var cbeeCmdName = this.cmdList[String(cmd).toLowerCase()]
		if(cbeeCmdName != undefined){
			var x = new XML();
			x.nodeName = cbeeCmdName;
			for(var n in attr){
				x.attributes[n] = attr[n];
			}
			if(child != undefined){
				if(typeof(child) == "string"){
					var child = new XML(child);
				}
				x.appendChild(child);
			}
			return this.send(x);
		}else{
			_global.debug("Unknow command "+cmd);
			return false;
		}
	}

	function onIdent(node){
		this.connected = true;
		if(node.attributes.k == undefined) this.logged = true;
		else this.logged = false;
	}

	function addListener(cmd,obj,method,attrib,value){
		var cmd = String(cmd).toLowerCase();
		var cbeeCmd = this.cmdList[cmd];
		if(attrib == undefined){
			if(this.listeners[cbeeCmd] == undefined){
				this.listeners[cbeeCmd] = new Array();
			}
			this.listeners[cbeeCmd].push({obj: obj,method: method});
		}else{
			var attrib = String(attrib);
			var value = String(value);
			if(this.specificListeners[cbeeCmd] == undefined){
				this.specificListeners[cbeeCmd] = new Object();
			}
			if(this.specificListeners[cbeeCmd][attrib] == undefined){
				this.specificListeners[cbeeCmd][attrib] = new Object();
			}
			if(this.specificListeners[cbeeCmd][attrib][value] == undefined){
				this.specificListeners[cbeeCmd][attrib][value] = new Array();
			}
			this.specificListeners[cbeeCmd][attrib][value].push({obj: obj,method: method});
		}
	}

	function removeListenerCmd(cmd,attrib,value){
		var cmd = String(cmd).toLowerCase();
		var cbeeCmd = this.cmdList[cmd];
		if(attrib == undefined){
			this.listeners[cbeeCmd] = new Array();
		}else{
			var attrib = String(attrib);
			var value = String(value);
			this.specificListeners[cbeeCmd][attrib][value] = new Array();
		}
	}

	function removeListenerCmdObj(cmd,obj,attrib,value){
		var cmd = String(cmd).toLowerCase();
		var cbeeCmd = this.cmdList[cmd];

		// TODO: comprendre pkoi le arguments.length est foireux
		if(attrib == undefined){
			for(var i=0;i<this.listeners[cbeeCmd].length;i++){
				if(this.listeners[cbeeCmd][i].obj == obj){
					this.listeners[cbeeCmd].splice(i,1);
					i--;
				}
			}
		}else{
			var attrib = String(attrib);
			var value = String(value);

			for(var i=0;i<this.specificListeners[cbeeCmd][attrib][value].length;i++){
				if(this.specificListeners[cbeeCmd][attrib][value][i].obj == obj){
					this.specificListeners[cbeeCmd][attrib][value].splice(i,1);
					i--;
				}
			}
		}
	}

	function callListenersArray(arr,node){
		for(var i=0;i<arr.length;i++){
			arr[i].obj[arr[i].method](node);
		}
	}
}