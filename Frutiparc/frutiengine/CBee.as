class CBee extends XMLSocket{
	var listeners:Object;
	var specificListeners:Object;
	var cmdList:Object;
	var host:String;
	var port:Number;
	var connected:Boolean;
	var globalListener:Object;
	var cnxNb:Number = 0;

	function CBee(o){
		for(var n in o){
			this[n] = o[n];
		}
		
		this.cmdList = new Object();
		this.cmdList.onclose = "onclose";
		this.cmdList.onconnect = "onconnect";

		this.listeners = new Object();
		this.specificListeners = new Object();

	}

	/*
	Function: debug
		Trace a debug message

	Parameters:
		str - String to trace
	*/
	function debug(str){
		_global.debug(str);
	}

	/*
	Function: connect
		Try to connect to the server

	Parameters:
		host - Server hostname
		port - Server port (> 1024)
	*/
	function connect(host,port){
		this.host = host;
		this.port = port;
		this.debug("Attempt to connect to "+host+" on port "+port);
		this.connected = false;
		super.connect(host,port);
	}

	function onConnect(success){
		this.callGlobalListener("onConnect",success);
		if(success){
			this.debug("Connected to "+this.host+" on port "+this.port);
			this.connected = true;
			this.cnxNb++;
		}else{
			this.debug("Unable to connect to "+this.host+" on port "+this.port);
			this.connected = false;
		}
		this.callListenersArray(this.listeners["onconnect"],success);
	}

	function onClose(){
		this.debug("Connection to "+this.host+" on port "+this.port+" closed");
		this.callGlobalListener("onClose");
		this.connected = false;
		this.callListenersArray(this.listeners["onclose"]);
	}

	function onXML(node){
		
		// DEBUG //
		if(_global.flDebug){
			var n2 = new XML(node.toString());
			n2 = n2.lastChild;
			for(var n in this.cmdList){
				if(this.cmdList[n] == n2.nodeName){
					var hrName = n;
					break;
				}
			}
			n2.nodeName = hrName;
			this.debug("[R] "+FEString.unHTML(n2.toString()));
			//_global.debug("[R] "+FEString.unHTML(n2.toString()));
		}
		// DEBUG //
		
		
		var nodeString = String(node)
		if(nodeString.length > 0){
			node = node.lastChild;

			var cmdName = node.nodeName.toLowerCase();
			this.callListenersArray(this.listeners[cmdName],node);
			for(var attrib in node.attributes){
				this.callListenersArray(this.specificListeners[cmdName][attrib][node.attributes[attrib]],node);
			}
			
			this.callGlobalListener("onXML",node);
		}
	};

	function setGlobalListener(obj){
		this.globalListener = obj;
	};

	function callGlobalListener(event,data){
		this.globalListener.obj[this.globalListener.method](this.port,event,data);
	}

	/*
	Function: send
		Send a string/xml to server

	Parameters:
		x - string/xml to send

	Returns:
		True if succeed (if connected)

	See Also:
		<CBee.cmd>
	*/
	function send(x){
		if(!this.connected){
			this.debug("Must be connected to send data !");
			return false;
		}
		super.send(x);

		if(_global.flDebug){
			// DEBUG //
			for(var n in this.cmdList){
				if(this.cmdList[n] == x.nodeName){
					var hrName = n;
					break;
				}
			}
			x.nodeName = hrName;

			this.debug("[S] "+FEString.unHTML(x.toString()));
			//_global.debug("[S] "+FEString.unHTML(x.toString()));
			// DEBUG //
		}
		
		return true;
	}

	/*
	Function: send
		Send a command to server

	Parameters:
		cmd - Coder's friendly command name
		attr - Object containing attributes of command (similar to xml.attributes object)
		child - Child xml/string to append in the command

	Returns:
		True if succeed

	See Also:
		<CBee.send>
	*/
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
			this.debug("Unknow command "+cmd);
			return false;
		}
	}

	/*
	Function: addListener
		Add a listener for a specific command

	Parameters:
		cmd - Coder's friendly command name
		obj - Object in which call the method
		method - Name of the method to call
		attrib - Required attribute name
		value - Required attribute value

	See Also:
		<CBee.removeListenerCmd>
		<CBee.removeListenerCmdObj>
	*/
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

	/*
	Function: removeListenerCmd
		Remove all listeners for a specific command (attrib/value)

	Parameters:
		cmd - Coder's friendly command name
		attrib - Required attribute name
		value - Required attribute value

	See Also:
		<CBee.addListener>
		<CBee.removeListenerCmdObj>
	*/
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

	/*
	Function: removeListenerCmdObj
		Remove listeners for a specific command (attrib/value), which call a specific object

	Parameters:
		cmd - Coder's friendly command name
		obj - Object in which the method was called
		attrib - Required attribute name
		value - Required attribute value

	See Also:
		<CBee.addListener>
		<CBee.removeListenerCmd>
	*/
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