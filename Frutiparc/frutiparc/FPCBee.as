/*
$Id: FPCBee.as,v 1.44 2005/08/04 16:06:02  Exp $

Class: FPCBee
	Frutiparc specific cbee manager
*/
class FPCBee extends CBee{
	// 
	var pingTime:Number = 0;
	var pingInit:Number = 0;
	// interval for ping/time method
	var pingInterval:Number;
	var timeInterval:Number;
	// close() called, don't try to reconnect
	var forceClose:Boolean = false;
	// identified ?
	var logged:Boolean = false;

	//
	var debugBox:box.Debug;
	
	// interval for connect method
	var interval:Number;
	
	// 
	var ip:String;	
	var login:String;
	var pass:String;
	
	//
	var flConnectIsInit:Boolean = false;
	
	// 
	var traced:Object;	
	var infoBasicCache:Object;
	var atraceToFlush:Array = new Array();
	var straceToFlush:Array = new Array();

	function FPCBee(o){
		this.cmdList.statusobj = "statusobj";
		this.cmdList.afterip = "afterip";
		
		#include "cmdList.as"

		this.traced = new Object();
		this.infoBasicCache = new Object();

		if(_global.flDebug){
			this.debugBox = new box.Debug();
			this.debugBox.myCnx = this;
			this.debugBox.setTitle("Debug XML");
			//_global.trashSlot.addBox(this.debugBox);
			_global.desktop.addBox(this.debugBox);
		}
	}

	function debug(str){
		this.debugBox.addText(str);
	}

	function connect(host,port){
		// XXX To test !!!
		//if( this.forceClose ) return;
        
		this.forceClose = false;

		super.connect(host,port);
		
		if(!this.flConnectIsInit){
			#include "cmdList2.as"
			
			this.addListener("ping",this,"onPing");
			this.addListener("ip",this,"onIP");
			this.addListener("time",this,"onTime");
			this.addListener("ident",this,"onIdent");
			this.addListener("trace",this,"onTrace");
			this.addListener("tracecallback",this,"onTrace");
			this.addListener("status",this,"onStatus");
			this.addListener("fbouille",this,"onFbouille");
			this.addListener("invisible",this,"onInvisible");
			this.addListener("onmute",this,"onMute");
			this.addListener("endmute",this,"onEndMute");
			
			this.flConnectIsInit = true;
		}
		
	}

	function onConnect(success){
		super.onConnect(success);

		this.logged = false;
		if(success){
			clearInterval(this.interval);
			this.interval = undefined;

			this.pingInterval = setInterval(this,"ping",  60000); // 1 minute
			this.timeInterval = setInterval(this,"time",1200000); // 20 minutes
			this.cmd("time");
			this.cmd("ip");



		}else{
			this.reconnect();
		}
	}

	function onClose(){
		_root.test+=" coucou les zamis !\n"
		this.debug("FPBcee::onClose");
		clearInterval(this.pingInterval);
		clearInterval(this.timeInterval);
		this.pingInterval = undefined;
		this.timeInterval = undefined;
		this.logged = false;
		this.ip = undefined;

		super.onClose();
		if(!this.forceClose){
			this.reconnect();
		}
	}

	function onXML(x){
		if(x.lastChild.attributes.k != undefined){
			this.debug("CBee error: "+Lang.fv("error.cbee."+x.lastChild.attributes.k));
		}
		return super.onXML(x);
	}

	function close(){
		this.debug("Connection closed voluntarily");
		this.forceClose = true;
		
		clearInterval(this.interval);
		this.interval = undefined;
		
		super.close();
	}

	function send(x){
		// Send only command <= ident when not logged
		var cmd = x.nodeName.toString();
		if((cmd.length > 1 || cmd > this.cmdList.ident) && !this.logged){	
			this.debug("Must be logged to send command: "+x.nodeName);
			return false;
		}
		return super.send(x);
	}

	function reconnect(){
		if(this.interval == undefined){
			this.debug("Try to reconnect");
			//this.connect(this.host,this.port);
			this.interval = setInterval(this,"connect",3000,this.host,this.port);
		}
	}

	function ping(){
		if(this.pingInit > 0) return false;
		this.pingInit = _global.localTime.getTime();
		this.cmd("ping");

		return true;
	}
	
	function time(){
		this.cmd("time");
	}

	function onPing(){
		this.pingTime = _global.localTime.getTime() - this.pingInit;
		this.pingInit = 0;

		this.debug("Ping: "+this.pingTime+"ms");
	}

	function onTime(node){
		_global.servTime.setFromString(FEString.trim(node.firstChild.nodeValue.toString()));
		this.debug("Server time: "+Lang.formatDate(_global.servTime.getDateObject(),"long_complete"));
	}

	function onIP(node){
		this.ip = FEString.trim(node.firstChild.nodeValue.toString());
		this.debug("My IP: "+this.ip);

		if(_global.sidAutoInit || (this.login != undefined && this.pass != undefined)){
			this.ident();
		}
	}

	function onIdent(node){
		if(this.logged) return false;
		
		if(node.attributes.k != undefined){
			this.logged = false;
		}else{
			// TODO: redemander du trace des users
			this.debug("Logged successfully on "+this.login);
			this.logged = true;
		}
		
		// It's not the first connection !
		if(this.cnxNb > 1){
			
			// => Ask server for trace users in this.traced
			var x = new XML();
			for(var n in this.traced){
				if(this.traced[n].listeners == 0) continue;
				
				var xUsr = new XML();
				xUsr.nodeName = "u";
				xUsr.attributes.u = n;
				x.appendChild(xUsr);
			}
			if(x.hasChildNodes()){
				this.cmd("trace",{},x);
			}
			
		}
	}

	function ident(l,p){
		if( _global.sidAutoInit ){
			return this.cmd("ident",{s: _root.sid,l: "",m: ""});
		}
		if(l != undefined && p != undefined){
			this.login = l;
			this.pass = p;
		}

		if(this.ip == undefined){
			this.debug("Ident requires IP");
			return false;
		}

		if(this.logged){
			this.debug("Already logged");
			return false;
		}

		if(this.login != undefined && this.pass != undefined){
			return this.cmd("ident",{m: MD5.encode(this.ip+MD5.encode(this.pass)),l: this.login,s: _root.sid});
		}else{
			return false;
		}
	}

	function atrace(user,obj,method,autoFlush,autoTrace){
		if(autoFlush == undefined) var autoFlush = true;
		if(autoTrace == undefined) var autoTrace = false;
		
		if(typeof(user) == "object"){
			var x = new XML();
			for(var i=0;i<user.length;i++){
				var usrReal = String(user[i]);
				var usr = String(usrReal).toLowerCase();
				
				if(this.traced[usr] != undefined){
					if(!autoTrace){
						this.traced[usr].listeners++;
					}else{
						this.traced[usr].autoListeners++;
					}
					if(obj != undefined){
						obj[i][method[i]](this.traced[usr]);
					}
				}else{
					this.traced[usr] = new Object();
					if(!autoTrace){
						this.traced[usr].listeners = 1;
						this.traced[usr].autoListeners = 0;
					}else{
						this.traced[usr].listeners = 0;
						this.traced[usr].autoListeners = 1;
					}
				}
				
				// Lorsqu'on est pas en autoTrace et que c'est le premier listener non auto => demande au serveur
				if(!autoTrace && this.traced[usr].listeners == 1){
					if(autoFlush){
						var xUsr = new XML();
						xUsr.nodeName = "u";
						xUsr.attributes.u = usrReal;
						x.appendChild(xUsr);
					}else{
						if(!this.straceToFlush.rm(usrReal)) this.atraceToFlush.pushUniq(usrReal);
					}
				}
				
				if(obj != undefined){
					this.addListener("statusobj",obj[i],method[i],"user",usr);
				}
			}
			if(x.hasChildNodes()){
				this.cmd("trace",{},x);
			}
		}else{
			var userReal = user;
			var user = String(user).toLowerCase();
			if(this.traced[user] != undefined){
				if(!autoTrace){
					this.traced[user].listeners++;
				}else{
					this.traced[user].autoListeners++;
				}
				if(obj != undefined){
					obj[method](this.traced[user]);
				}
			}else{
				this.traced[user] = new Object();
				if(!autoTrace){
					this.traced[user].listeners = 1;
					this.traced[user].autoListeners = 0;
				}else{
					this.traced[user].listeners = 0;
					this.traced[user].autoListeners = 1;
				}
				
			}
			
			// Lorsqu'on est pas en autoTrace et que c'est le premier listener non auto => demande au serveur
			if(!autoTrace && this.traced[user].listeners == 1){
				if(autoFlush){
					this.cmd("trace",{u: userReal});
				}else{
					if(!this.straceToFlush.rm(userReal)) this.atraceToFlush.pushUniq(userReal);
				}
			}
			
			if(obj != undefined){
				this.addListener("statusobj",obj,method,"user",user);
			}
			return this.traced[user];
		}
	}

	function strace(user,obj,autoFlush,autoTrace){
		if(autoFlush == undefined) var autoFlush = true;
		if(autoTrace == undefined) var autoTrace = false;
		
		if(typeof(user) == "object"){
			var x = new XML();
			for(var i=0;i<user.length;i++){
				var usrReal = user[i];
				var usr = String(usrReal).toLowerCase();
				if(this.traced[usr] != undefined){
					if(!autoTrace){
						this.traced[usr].listeners--;
					}else{
						this.traced[usr].autoListeners--;
					}
					
			
					// On vient de supprimer le dernier listener non auto => on pr�vient le serveur
					if(!autoTrace && this.traced[usr].listeners <= 0){
						if(autoFlush){
							var xUsr = new XML();
							xUsr.nodeName = "u";
							xUsr.attributes.u = usrReal;
							x.appendChild(xUsr);
						}else{
							if(!this.atraceToFlush.rm(usrReal)) this.straceToFlush.pushUniq(usrReal);
						}
					}
					
					// On n'a plus aucun listener (auto ou non) sur cet utilisateur => on nettoie ici
					// if !autoFlush => made in traceFlush
					if(autoFlush || autoTrace){
						if(this.traced[usr].listeners <= 0 && this.traced[usr].autoListeners <= 0){
							this.cleanInfoBasicCache(usr);
							delete this.traced[usr];
						}
					}
				}
				if(obj != undefined){
					this.removeListenerCmdObj("statusobj",obj[i],"user",usr);
				}
			}
			if(x.hasChildNodes()){
				this.cmd("stoptrace",{},x);
			}
		}else{
			var userReal = user;
			var user = String(user).toLowerCase();
			if(this.traced[user] != undefined){
				if(!autoTrace){
					this.traced[user].listeners--;
				}else{
					this.traced[user].autoListeners--;
				}
				
				
				// On vient de supprimer le dernier listener non auto => on pr�vient le serveur
				if(!autoTrace && this.traced[user].listeners <= 0){
					if(autoFlush){
						this.cmd("stoptrace",{u: userReal});
					}else{
						if(!this.atraceToFlush.rm(userReal)) this.straceToFlush.pushUniq(userReal);
					}
				}
				
				
				// On n'a plus aucun listener (auto ou non) sur cet utilisateur => on nettoie ici	
				// if !autoFlush => made in traceFlush
				if(autoFlush || autoTrace){
					if(this.traced[user].listeners <= 0 && this.traced[user].autoListeners <= 0){
						this.cleanInfoBasicCache(user);
						delete this.traced[user];
					}
				}
			}
			
			if(obj != undefined){
				this.removeListenerCmdObj("statusobj",obj,"user",user);
			}
		}
	}
	
	function traceFlush(Void):Void{
		// STOP TRACE (straceToFlush)
		var x = new XML();
		for(var i=0;i<this.straceToFlush.length;i++){
			var user = this.straceToFlush[i];
			
			var xUsr = new XML();
			xUsr.nodeName = "u";
			xUsr.attributes.u = user;
			x.appendChild(xUsr);
			
			// 
			var o = this.traced[user];
			if(o.listeners == 0 && o.autoListeners == 0){
				this.cleanInfoBasicCache(user);
				delete this.traced[user];
			}
		}
		if(x.hasChildNodes()){
			this.cmd("stoptrace",{},x);
		}
		this.straceToFlush = new Array();
		
		// ACTIVE TRACE (atraceToFlush)
		var x = new XML();
		for(var i=0;i<this.atraceToFlush.length;i++){
			var xUsr = new XML();
			xUsr.nodeName = "u";
			xUsr.attributes.u = this.atraceToFlush[i];
			x.appendChild(xUsr);
		}
		if(x.hasChildNodes()){
			this.cmd("trace",{},x);
		}
		this.atraceToFlush = new Array();
	}

	function onTrace(node){
		//_global.debug("FPCBee.onTrace()");
		if(node.hasChildNodes()){
			node = node.firstChild;
		}	
		for(;node.nodeType>0;node=node.nextSibling){
			if(node.attributes.u == undefined) continue;
			
			var user = String(node.attributes.u).toLowerCase();
			//_global.debug("onTrace "+user);
			// modify this.traced[user]
			var obj = this.traced[user];
			if(obj == undefined){
				//_global.debug("Je cr�e pour "+user);
				var obj = {
					listeners: 0,
					autoListeners: 0
				}
				this.traced[user] = obj;				
			}
	
			// fbouille
			if(node.attributes.f != undefined){
				obj.fbouille = node.attributes.f;
			}
			// presence
			if(node.attributes.p != undefined){	
				obj.presence = Number(node.attributes.p);
			}
			// status
			if(node.attributes.s != undefined){
				obj.status = StatusMng.analyseStr(node.attributes.s);
			}
			if(node.attributes.mu != undefined){
				obj.endMute = node.attributes.mu;
			}
			if(obj.endMute != undefined && obj.endMute != "0000-00-00 00:00:00"){
				obj.status.emote = 7;
			}
			//_global.debug("FBouille de "+user+" : "+obj.status.fbouille);

			this.callListenersArray(this.specificListeners["statusobj"]["user"][user],obj);

		}
	}
	
	function onMute(node){
		var user = String(node.attributes.u).toLowerCase();
		var obj = this.traced[user];
		obj.endMute = node.attributes.mu;
		if(obj.endMute == undefined) _global.debug("WARN: mute without enddate... [user: "+user+"]");
		obj.status.emote = 7;
		
		this.callListenersArray(this.specificListeners["statusobj"]["user"][user],obj);
	}
	
	function onEndMute(node){
		var user = String(node.attributes.u).toLowerCase();
		var obj = this.traced[user];
		obj.endMute = undefined;
		obj.status.emote = 0;
		
		this.callListenersArray(this.specificListeners["statusobj"]["user"][user],obj);
	}
	
	function onStatus(node){
		if(node.attributes.u == undefined && node.attributes.s != undefined){
			node.attributes.u = _global.me.name;
			this.onTrace(node);
		}
	}
	
	function onInvisible(node){
		if(node.attributes.u == undefined && node.attributes.p != undefined){
			node.attributes.u = _global.me.name;
			this.onTrace(node);
		}
	}

  function onFbouille(node){
    if(node.attributes.u == undefined){
      node.attributes.u = _global.me.name;
      this.onTrace(node);
    }
  }
	
	/*
	Function: getStatusObj
		Get the current status object of an user (work only if the user is currently traced)
		
	Parameters:
		usr - The user's name
		
	Returns:
		A classic status object (fbouille/presence/status) if the user is currently traced, undefined else
	*/
	function getStatusObj(usr){
		usr = String(usr).toLowerCase();
		return this.traced[usr];
	}

	function isInvisible(usr){
		var o = this.getStatusObj(usr);
		return o.presence == 2;
	}
	
	function setInfoBasic(usr,info){
		usr = String(usr).toLowerCase();
		this.infoBasicCache[usr] = info;
	}
	
	function getInfoBasic(usr){
		usr = String(usr).toLowerCase();
		return this.infoBasicCache[usr];
	}
	
	function cleanInfoBasicCache(usr){
		usr = String(usr).toLowerCase();
		delete this.infoBasicCache[usr];
	}
	
	function countInfoBasicCache(){
		var i = 0;
		for(var	n in this.infoBasicCache){
			i++;
		}
		return i;
	}
}
