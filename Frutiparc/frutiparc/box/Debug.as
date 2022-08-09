/*
$Id: Debug.as,v 1.29 2007/03/30 13:43:24  Exp $

Class box.Debug
*/
class box.Debug extends box.Standard{
	static var allBox:Array = new Array();

	var content:Array;
	var myCnx:Object;
	var cmdLog:Array;
	var cmdLogCursor:Number;

	function Debug(){
		this.content = new Array();
		this.cmdLog = new Array();
		this.cmdLogCursor = 0;
		
		if(allBox == undefined) allBox = new Array();
		if(_global.flDebug) allBox.push(this);
	}
	
	function preInit(){
		
		//_root.test+="Debug preinit\n"
		
		this.desktopable = true;
		this.tabable = true;	

		this.winType = "winDebug";
		
		if(this.title == undefined) this.setTitle(Lang.fv("debug"));
		super.preInit();
	}

	function init(slot,depth){
		//_root.test+="Debug init\n"		
		var rs = super.init(slot,depth);

		if(rs){
			this.window.mainField.maxDisplayed = 90;
			this.window.mainField.defaultFont = "Courier New";
		}
		
	}

	function addText(str){
		this.content.push(str);
		if(this.content.length > 90){
			this.content.splice(0,this.content.length - 90);
		}
		if(this.flShow){
			this.window.mainField.addText(str);
		}
	}

	function hide(){
		this.window.mainField.clean();

		return super.hide();
	}

	function show(){
		/*
		for(var i=0;i<this.content.length;i++){
			this.window.mainField.addText(this.content[i]);
		}
		*/
		this.window.mainField.addText(this.content.join("<br/>"));
		return super.show();
	}

	function onEnter(){
		if(this.analyseInput(this.window.getInput())){
			this.window.setInput("");
		}
	}

	function analyseInput(str){
		var last = this.cmdLog[this.cmdLog.length-1];
		if(str != last){
			this.cmdLog.push(str);
		}
		this.cmdLogCursor = 0; 
	
		if(FEString.startsWith(str,"/")){
			if(FEString.startsWith(str,"/ping")){
				_global.mainCnx.ping();
			}else if(FEString.startsWith(str,"/time")){
				_global.mainCnx.cmd("time");
			}else if(FEString.startsWith(str,"/ip")){
				_global.mainCnx.cmd("ip");
			}else if(FEString.startsWith(str,"/ident")){
				var arr = str.split(" ");
				var login = arr[1];
				var pass = MD5.encode(arr[2]);
				_global.mainCnx.ident(login,pass);

			}else if(FEString.startsWith(str,"/join")){
				var arr = str.split(" ");
				var group = arr[1];
				_global.channelMng.open(group);

			}else if(FEString.startsWith(str,"/create")){
				var topic = str.substr(7);
				_global.desktop.addBox(new box.Chat({topic: topic}));

			}else if(FEString.startsWith(str,"/chat")){
				var arr = str.split(" ");
				var user = arr[1];
				_global.chatMng.open(_global.desktop,user);
				
			}else if(FEString.startsWith(str,"/emote")){
				var arr = str.split(" ");
				var e = arr[1];
				_global.me.status.setEmote(e);
				
			}else if(FEString.startsWith(str,"/traceinfo")){
				var arr = str.split(" ");
				var n = String(arr[1]).toLowerCase();
				var end = (_global.mainCnx.traced[n]==undefined)? "not traced" : "traced. listeners: "+_global.mainCnx.traced[n].listeners+", autoListeners: "+_global.mainCnx.traced[n].autoListeners;
				_global.debug("User "+n+" is currently "+end);
				
			}else if(FEString.startsWith(str,"/tracesize")){
				var nb = 0;
				var l = 0;
				var al = 0;
				for(var n in _global.mainCnx.traced){
					var o = _global.mainCnx.traced[n];
					nb++;
					l += o.listeners;
					al += o.autoListeners;
				}
				_global.debug(nb+" user traced, "+l+" listeners, "+al+" autoListeners.");
				
			}else if(FEString.startsWith(str,"/isincontact")){
				var arr = str.split(" ");
				var n = String(arr[1]).toLowerCase();
				if(_global.myContactListCache.isIn(n)){
					_global.debug(n+" is in my contactList !");
				}else{
					_global.debug(n+" isn't in my contactList !");
				}
				
			}else if(FEString.startsWith(str,"/isinblack")){
				var arr = str.split(" ");
				var n = String(arr[1]).toLowerCase();
				if(_global.myBlackListCache.isIn(n)){
					_global.debug(n+" is in my blackList !");
				}else{
					_global.debug(n+" isn't in my blackList !");
				}
				
			}else if(FEString.startsWith(str,"/status")){
				var arr = str.split(" ");
				var n = String(arr[1]).toLowerCase();
				var o = _global.mainCnx.traced[n];
				if(o == undefined){
					_global.debug(n+" isn't in tracelist");
				}else{
					var str = "";
					str += "******* / "+n+" status \ *******"+"<br/>";
					
					str += "Listeners: "+o.listeners+"<br/>";
					str += "AutoListeners: "+o.autoListeners+"<br/>";
					str += "Presence : "+o.presence+"<br/>";
					str += "Frutibouille : "+o.fbouille+"<br/>";
					str += "EndMute : "+o.endMute+"<br/>";
					str += "Status : {<br/>"
					str += "\tinternal: "+o.status.internal+"<br/>";
					str += "\texternal: "+o.status.external+"<br/>";
					str += "\temote: "+o.status.emote+"<br/>";
					str += "}<br/>";
				
					str += "******* \                     / *******"
					_global.debug(str);
				}
				
			}else if(FEString.startsWith(str,"/pref")){
				var arr = str.split(" ");
				_global.debug("Pr�f�rence: "+arr[1]+" = "+_global.userPref.getPref(arr[1]));			
				
			}else if(FEString.startsWith(str,"/invisible")){
				_global.mainCnx.cmd("invisible");
				
			}else if(FEString.startsWith(str,"/window")){
				var arr = str.split(" ");
				_global.debug("Window de la box de l'user : "+arr[1]+" = "+_global.chatMng["_"+arr[1]].window);
				
			}else if(FEString.startsWith(str,"/servtime")){
				
				_global.debug("_global.servTime: "+Lang.formatDate(_global.servTime.getDateObject(),"long_complete"));

			}else if(FEString.startsWith(str,"/swfload")){
				
				_global.debug("-------------- * SWFLOAD REPORT * --------------");
				for(var n in FEMCLoader.urlList){
					_global.debug(n+" : "+(FEMCLoader.urlList[n].loaded?'loaded':'loading...'));
				}
				_global.debug("---------- * END OF SWFLOAD REPORT * ----------");
				
			}else if(FEString.startsWith(str,"/sign")){
				var o = _global.servTime.getCurrentFSign();
				_global.debug("Signe actuel: "+Lang.sign(o.sign)+" ("+Math.round(o.signCompletion*100)+"%) ["+o.sign+"]");
				_global.debug("Ascendant actuel: "+Lang.sign(o.sign)+" ("+Math.round(o.signbCompletion*100)+"%) ["+o.sign+"]");
				
			}else if(FEString.startsWith(str,"/cachesize")){
				_global.debug("Utilisateurs en cache: "+_global.mainCnx.countInfoBasicCache());
		  
      }else if(FEString.startsWith(str,"/bouillelist")){
         _global.debug("Liste de mes bouilles :");
         for(var i = 0;i<_global.me.bouilleList.length;i++){
            o = _global.me.bouilleList[i];
            _global.debug(o.name+" : "+o.bouille);
         }

			
			}else{
				_global.debug("Unknow command");
			}
		/*
		}else if(FEString.startsWith(str,"<")){
			if(this.myCnx == undefined){
				_global.mainCnx.send(str);
			}else{
				this.myCnx.send(str);
			}
		*/
		}else{
			_global.debug("[DBG] "+str);
		}
		return true;
	}
	
	function onWheel(delta){
		this.window.scrollText(-10 * delta);
	}
	
	function onUp(){
		this.cmdLogCursor++;
		this.cmdLogCursor = Math.max(0,Math.min(this.cmdLogCursor,this.cmdLog.length));
		
		this.window.setInput(this.cmdLog[this.cmdLog.length - this.cmdLogCursor]);
	}
	
	function onDown(){
		this.cmdLogCursor--;
		this.cmdLogCursor = Math.max(0,Math.min(this.cmdLogCursor,this.cmdLog.length));
		
		this.window.setInput(this.cmdLog[this.cmdLog.length - this.cmdLogCursor]);
	}
}
