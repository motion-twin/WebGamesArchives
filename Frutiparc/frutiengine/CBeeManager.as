/*
$Id: CBeeManager.as,v 1.13 2004/03/19 18:14:44  Exp $

Class: CBeeManager
*/
class CBeeManager extends LocalConnection{
	var className:String = "CBee";
	var timeout:Number = 1000;
	var cnxTimeout:Number = 60000;
	var cbeeCnx:Object;
	var interval:Number;
	
	function CBeeManager(o){
		for(var n in o){
			this[n] = o[n];
		}
		this.cbeeCnx = new Object();

		this.interval = setInterval(this,"checkAll",this.timeout);
	};

	function check(){
	};

	/*
	Function: addListener
		Add a localConnection to listeners of a cbee object.
		Create cbee object if not exists

	Parameters:
		port - The server port
		lc - localConnection's name / object

	See Also:
		<CbeeManager.removeListener>

	*/
	function addListener(port,lc,notRecallMe){
		if(port == undefined || lc == undefined){
			_global.debug("Can't add listener "+((typeof(lc)=="string")?lc:"[object]")+" for port "+port);
			return;
		}
		_global.debug("Add listener "+((typeof(lc)=="string")?lc:"[object]")+" for port "+port);
		if(this.cbeeCnx[port] == undefined){
			this.addCnx(port,false);
		}else if(!this.cbeeCnx[port].cbee.connected){
			this.cbeeCnx[port].cbee.connect(_global.cbeeHost,port);
		}else{
			if(notRecallMe == undefined && this.cbeeCnx[port].cbee.logged){
				var n = new XML();
				n.nodeName = this.cbeeCnx[port].cbee.cmdList.ident;
				n.attributes.l = this.cbeeCnx[port].cbee.login;
				if(typeof(lc) == "string"){
					new LocalConnection().send(lc,n.toString());
				}else if(lc != undefined){
					lc.onXML(n);
				}
			}
		}

		this.cbeeCnx[port].listeners.pushUniq(lc);

		return this.cbeeCnx[port].lc;
	};

	function getStatus(port,lc){
		var obj = {
			connected: this.cbeeCnx[port].cbee.connected,
			logged: this.cbeeCnx[port].cbee.logged
		};
		if(typeof(lc) == "string"){
			new LocalConnection().send(lc,"onStatus",obj);
		}else if(lc != undefined){
			lc.onStatus(obj);
		}
		return obj;
	};

	/*
	Function: removeListener
		Remove a localConnection of listeners of a cbee object.
		Launch a timeout for deleting the cbee object after ten minutes, if there's no more listener

	Parameters:
		port - The server port
		lc - localConnection's name / object

	See Also:
		<CbeeManager.addListener>
	*/
	function removeListener(port,lc,forceClose){
		_global.debug("Remove listener "+lc+" for port "+port);
		this.cbeeCnx[port].listeners.rm(lc);

		if(this.cbeeCnx[port].listeners.length == 0){
			if(forceClose){
				this.removeCnx(port);
			}else{
				this.cbeeCnx[port].emptyTime = getTimer();
			}
		}
	};


	function addCnx(port,force,obj){
		_global.debug("Add connection on port "+port+" (class: "+this.className+")");
		
		var theClass = eval(this.className);
		var cbee = new theClass(obj);
		
		// TODO: Voir comment am�liorer �a
		if(_global.me.name != undefined){
			cbee.login = _global.me.name
		}
		if(_global.me.pass != undefined){
			cbee.pass = _global.me.pass;
		}
		
		cbee.connect(_global.cbeeHost,port);
		cbee.setGlobalListener({obj: this,method: "onGlobalListener"});
		var lc = new CBeeLC(cbee);
		// TODO: mettre �a ailleurs !
		lc.connect("fp_cbee_"+port+"_"+_root.sid);

		this.cbeeCnx[port] = {
			cbee: cbee,
			lc: lc,
			listeners: new Array(),
			emptyTime: getTimer(),
			force: force
		};

		return cbee;
	};

	function removeCnx(port){
		_global.debug("Remove connection on port "+port);

		this.cbeeCnx[port].cbee.setGlobalListener(undefined);
		this.cbeeCnx[port].cbee.close();
		delete this.cbeeCnx[port];
	};

	function onGlobalListener(port,event,data){
		var aCC = this.cbeeCnx[port];
		if(event == "onClose" && !aCC.force && aCC.listeners.length == 0){
			this.removeCnx(port);
		}
		for(var i=0;i<aCC.listeners.length;i++){
			var e = aCC.listeners[i];
			if(typeof(e) == "string"){
				if(data instanceof XMLNode || data instanceof XML){
					new LocalConnection().send(e,event,data.toString());
				}else{
					new LocalConnection().send(e,event,data);
				}
			}else{
				e[event](data);
			}
		}
	};

	function checkAll(){
		for(var port in this.cbeeCnx){
			var aCC = this.cbeeCnx[port];
			if(!aCC.force && aCC.listeners.length == 0 && getTimer() - aCC.emptyTime > this.cnxTimeout){
				this.removeCnx(port);
			}else{
				for(var i=0;i<aCC.listeners.length;i++){
					var e = aCC.listeners[i];
					if(typeof(e) == "string"){
						var lc = new LocalConnection();
						lc.onStatus = function(infosObj){
							if(infosObj.level == "error"){
								this.cm.removeListener(this.port,this.name);
							}
						};
						lc.cm = this;
						lc.port = port;
						lc.name = e;
						lc.send(e,"check");
					}
				}
			}
		}
	};
}
