/*
$Id: CBeeLocal.as,v 1.5 2003/10/25 14:26:39  Exp $
*/
class CBeeLocal extends LocalConnection {
	var cmdList:Object;
	var listeners:Object;
	var specificListeners:Object;
	var initialized:Boolean;
	var connected:Boolean;
	var logged:Boolean;
	var port:Number;
	var lc_name:String;
	
	function CBeeLocal(obj){
		for(var n in obj){
			this[n] = obj[n];
		}

		this.cmdList = new Object();
		this.cmdList.onclose = "onclose";
		this.cmdList.onconnect = "onconnect";

		#include "../cmdList.as"

		this.listeners = new Object();
		this.specificListeners = new Object();

		this.initialized = false;
		this.connected = false;
		this.logged = false;
		this.lc_name = "fp_cblc_"+_root.sid+"_"+this.port+"_"+FEString.randomId();

		this.addListener("ident",this,"onIdent");
	};

	function init(){
		this.connect(this.lc_name);

		var lc = new LocalConnection();
		lc.onStatus = function(obj){
			_global.debug("Status: "+obj.level);
			if(obj.level == "error"){
				this.obj.looseLocalConnection();
			}else{
				this.obj.initialized = true;
			}
		};
		lc.obj = this;
		
		_global.debug("J'appel: fp_cbeeMng_"+_root.sid);
		_global.debug(lc.send("fp_cbeeMng_"+_root.sid,"addListener",this.port,this.lc_name));
		lc.send("fp_cbeeMng_"+_root.sid,"getStatus",this.port,this.lc_name);

	}

	function looseLocalConnection(){
		this.initialized = false;
		this.onClose();
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
		var node = new XML(node);
		node = node.firstChild;
		var cmdName = node.nodeName.toLowerCase();
		this.callListenersArray(this.listeners[cmdName],node);
		for(var attrib in node.attributes){
			this.callListenersArray(this.specificListeners[cmdName][attrib][node.attributes[attrib]],node);
		}
	}

	function onStatus(obj){
		if(obj.connected) this.onConnect(true);
		this.logged = obj.logged;
	}

	function onIdent(node){
		if(node.attributes.k == undefined) this.logged = true;
		else this.logged = false;
	}

	function send(s){
		if(!this.initialized || !this.connected) return false;

		var lc = new LocalConnection();
		lc.onStatus = function(obj){
			if(obj.level == "error"){
				this.obj.looseLocalConnection();
			}
		};
		lc.obj = this;
		lc.send("fp_cbee_"+this.port+"_"+_root.sid,"send",s);
	}

	function cmd(a,b,c){
		if(!this.initialized || !this.connected) return false;

		var lc = new LocalConnection();
		lc.onStatus = function(obj){
			if(obj.level == "error"){
				this.obj.looseLocalConnection();
			}
		};
		lc.obj = this;
		lc.send("fp_cbee_"+this.port+"_"+_root.sid,"cmd",a,b,c);
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
