/*
$Id: Chat.as,v 1.59 2007/03/30 13:43:24  Exp $

Class: box.Chat
*/
class box.Chat extends box.Standard{
	var content:Array;
	var lastSendTimer:Array;
	var userList:UserListMng;
	var joined:Boolean = false; // I have joined the channel
	var oJoined:Boolean = false; // In private mode, the other user have joined
	var group:String;
	var user:String;
	var cmode:String;
	var topic:String;
	var passwd:String;
	var userActionListenerList:Array;
	var destSlot;
	var invitationSended:Boolean = false;
	var oldPresence:Number;
	var myStats:Object;
	var activePen:Number;
	var flMode:Boolean = false;
  var wallpaper:Object;
	
	var animAntiFlood:Object;

  var lastCallModerator:Number;
	
	var winCompoOpen:Object;

	var goodAnswer:String;
	var points:Object;

	var blueMode:Boolean = false;
	
	function Chat(infos){
		for(var n in infos){
			this[n] = infos[n];
		}
		
		this.content = new Array();
		this.lastSendTimer = new Array();
		this.userActionListenerList = new Array();
		this.userList = new UserListMng()
		this.winCompoOpen = {screenList: false,userList: false};
		this.animAntiFlood = {last: getTimer(),nb: 0}

		if(this.group != undefined){
			if(this.user != undefined){
				_global.debug("Mode discussion priv�e (join)");
				this.cmode = "private";
				this.join();
			}else{
				_global.debug("Mode salon (join)");
				this.cmode = "channel";
				this.join();
			}
		}else{
			if(this.user != undefined){
				_global.debug("Mode discussion priv�e (create)");
				this.cmode = "private";
				if(_global.myBlackListCache.isIn(this.user)){
					this.addText(Lang.fv("chat.warnblacklist",{u: this.user}));
				}
			}else{
				_global.debug("Mode salon priv� (create)");
				this.cmode = "channel";
			}
			this.createChannel();
		}

		_global.mainCnx.addListener("ident",this,"onIdent");
		_global.mainCnx.addListener("onClose",this,"onCnxClose");

		if(this.cmode == "private"){
			_global.chatMng.setBox(this.user,this);
			_global.mainCnx.atrace(this.user,this,"onStatusObj");
			this.refreshTitle();

			// TODO: recoder tout �a !
			/*
			this.so = SharedObject.getLocal(me+"_private_"+this.user);
			if(this.so.data.content != undefined){
				this.content = this.so.data.content;
			}else{
				this.so.data.content = new Array();
			}
			*/
		}else if(this.cmode == "channel"){
			_global.channelMng.pushUniq(this.group);
		}

		if(this.winType == undefined){
			if(this.cmode == "private"){
				this.winType = "winChat";
			}else{
				this.winType = "winChat";
			}
		}

	}
	
	function close(){
		this.part();
		this.userList.rmAll();
		if(this.cmode == "private"){
			_global.chatMng.unsetBox(this.user);
			_global.mainCnx.strace(this.user,this);
		}else{
			_global.channelMng.rm(this.group);
		}
		_global.mainCnx.removeListenerCmdObj("ident",this);
		_global.mainCnx.removeListenerCmdObj("onClose",this);
		super.close();
	}

	function tryToClose(){
		if(this.cmode == "private" && this.joined && this.oJoined){
			var b = _global.chooseInviteBehavior(_global.userPref.getPref("invite_chat_behavior"),this.user);
			if(b == "P" || b == "R"){
				_global.debug("Je suis en mode demander/refuser les discussions avec cet utilisateur, je ferme donc vraiment");
				this.close();
			}else{
				this.move(_global.trashSlot);
			}
		}else{
			this.close();
		}
	}

	function preInit(){
		this.desktopable = true;
		this.tabable = true;
		super.preInit();
	}

	function init(slot,depth){
		var rs = super.init(slot,depth);

		if(rs){
		}else{
			if(this.cmode == "private" && this.mode != "trash" && this.joined && !this.oJoined && !this.invitationSended){
				this.inviteChat();
			}
		}
		
		return rs;
	}

	function analyseInput(str:String){
		str = FEString.trim(str);
		
		if(str.length <= 0) return false;
		if(FEString.startsWith(str,"/") || FEString.startsWith(str,"asv")){
			var arr = str.split(" ");
			var cmd = arr[0].toLowerCase();
			var end = str.substr(arr[0].length+1);

			switch(cmd){
				case "/invite":
					this.invite(arr[1]);
					break;
				case "/kick":
				case "/eject":
					if(this.flMode && arr[1].length){
						this.eject(this.userList.getRealUserName(arr[1]));
					}
					break;
				case "/ban":
					if(this.flMode && arr[1].length){
						this.ban(this.userList.getRealUserName(arr[1]));
					}
					break;
				case "/chat":
				case "/pv":
				case "/mp":
					_global.chatMng.open(_global.desktop,this.userList.getRealUserName(arr[1]));
					break;
				case "/frutiz":
				case "/fiche":
				case "/user":
				case "/usr":
				case "/utilisateur":
					if(arr[1].length){
						_global.frutizInfMng.open(this.userList.getRealUserName(arr[1]),undefined,this.group);
					}
					break;
				case "/topic":
				case "/sujet":
					if(end.length <= 0) return false;
					if(end.length > _global.maxMessageLength.topic){
						this.addText(Lang.fv("error.chat.topic_too_long"));
						return false;
					}
					
					var x = new XML();
					var reply = FEString.uniqId();
					_global.mainCnx.addListener("topic",this,"onChangeTopic","r",reply);
					_global.mainCnx.cmd("topic",{g: this.group,r: reply},x.createTextNode(end));
					break;
				case "/gaspard":
					_global.chatMng.open(_global.desktop,"gaspard");
					break;
				case "/aide":
				case "/help":
				case "/?":
					this.addText(Lang.fv("chat.cmd.help"));
					break;
				case "/stat":
				case "/stats":
				case "/statistiques":
				case "/statistics":
					if(this.myStats == undefined){
						this.addText(Lang.fv("chat.cmd.stats.none"));
					}else{
						var txt = Lang.fv("chat.cmd.stats.head",{t: FEString.unHTML(this.topic)});
						txt += Lang.fv("chat.cmd.stats.time_elapsed",{t: Lang.formatDuration(getTimer() - this.myStats.initTime)});
						if(this.myStats.nbMsg > 0){
							txt += Lang.fv("chat.cmd.stats.nb_msg",{n: this.myStats.nbMsg});
						}
						if(this.myStats.nbMsg > 1){
							txt += Lang.fv("chat.cmd.stats.msg_time_avg",{t: Lang.formatDuration((getTimer() - this.myStats.initTime) / this.myStats.nbMsg)});
							txt += Lang.fv("chat.cmd.stats.msg_time_max",{t: Lang.formatDuration(this.myStats.maxTimeTweenMsg)});
						}
						txt += Lang.fv("chat.cmd.stats.foot");
						
						this.addText(txt);
					}
					break;
				case "/image":
				case "/img":
					if(!(_global.me.flAnimator && (FEString.startsWith(this.group,"quizz") || this.cmode != "channel" || this.passwd != undefined ))) return false;

          if(arr.length < 5 || isNaN(Number(arr[1])) || isNaN(Number(arr[2]))){
						this.addText("<i>Syntaxe: /image width height url title</i>");
						return false;
					}					

					var width = Number(arr[1]);
					var height = Number(arr[2]);
					var url = arr[3];
					var title = end.substring(arr[1].length+arr[2].length+arr[3].length+3,end.length);
					this.sendImage( width, height, url, title );
					break;
				case "/testimg":
				case "/testimage":
					if(!_global.me.flAnimator) return false;

          if(arr.length < 5 || isNaN(Number(arr[1])) || isNaN(Number(arr[2]))){
						this.addText("<i>Syntaxe: /testimage width height url title</i>");
						return false;
					}					

					var width = Number(arr[1]);
					var height = Number(arr[2]);
					var url = arr[3];
					var title = end.substring(arr[1].length+arr[2].length+arr[3].length+3,end.length);
					_global.desktop.addBox(
			      new box.DocScreen({
			        pos: {
			          w: width,
			          h: height
			        },
			        doc: new XML('<p><l><u u="'+url+'"/></l></p>'),
			        title: title
				    })
				  );
					break;					
				case "/reponse":
				case "/answer":
					this.goodAnswer = end.toLowerCase();
					break;
				case "/blueon":
					this.blueMode = true;
					this.addText("Mode bleu activ�");
					break;
				case "/blueoff":
					this.blueMode = false;
					this.addText("Mode bleu d�sactiv�");
					break;
				case "/initpoint":
					this.points = new Object();
					this.addText("Syst�me de points initialis�");
					break;
				case "/point":
					if(this.points == undefined){
						this.addText("Commencez par faire /initpoint");
					}else{
						var u = arr[1];
						var p = arr[2];
						if(p == undefined) p = 1;
						p = Number(p);
						if(u == undefined || u.length <= 0){
							this.addText("Vous devez sp�cifier un utilisateur !");
						}else{
							u = this.userList.getRealUserName(u);
							if(!this.userList.isInList(u)){
								this.addText("L'utilisateur "+u+" n'a pas �t� trouv� !");
							}else{
								if(this.points[u] == undefined){
									this.points[u] = p;
									if(_global.me.flAnimator && FEString.startsWith(this.group,"quizz")) this.sendMsgAnimator(u+" gagne "+p+" point(s)");
								}else{
									this.points[u] += p;
									if(_global.me.flAnimator && FEString.startsWith(this.group,"quizz")) this.sendMsgAnimator(u+" gagne "+p+" point(s) suppl�mentaire(s), ce qui fait "+this.points[u]+" points");
								}
							}
						}
					}
					break;
				case "/viewpoint":
					var s = "-------- Tableau de scores --------<br/>";
					for(var n in this.points){
						s += "<b>"+n+": </b>"+this.points[n]+" point(s)<br/>";
					}
					s += "-----------------------------------";
					this.addText("<i>"+s+"</i>");
					break;
				case "/sendpoint":
					var s = "</b>R�capitulatif des scores<br/>";
					for(var n in this.points){
						s += "<b>"+n+": </b>"+this.points[n]+" point(s)<br/>";
					}
					s += "<b>";
					if(_global.me.flAnimator && FEString.startsWith(this.group,"quizz")) this.sendMsgAnimator(s);
					break;
				case "/asv":
				case "asv":
				case "/qui":
					var u = arr[1];
          if(FEString.unHTML(u) != u) return false;
					if(u.length && cmd != "asv"){
						var ib = _global.mainCnx.getInfoBasic(u);
						if(ib == undefined){
							this.addText(Lang.fv("chat.cmd.asv.not_found",{u: u}));
						}else{
							if(ib.gender == "F"){
								var fColor = "BB4444";
							}else{
								var fColor = "242169";
								ib.gender = "M";
							}
							var str = "";
							str += '<font color="#'+fColor+'">'+Lang.fv("chat.cmd.asv."+ib.gender+".response",{u: u,a: ib.age,c: ib.country,r: ib.region,l: ib.xpLevel,o: this.userList.isInList(u)?Lang.fv("chat.cmd.asv."+ib.gender+".on_channel"):Lang.fv("chat.cmd.asv."+ib.gender+".not_on_channel")})+"</font><br/>";
							this.addText(str);
						}
					}else{
						var a = this.userList.getUserArray();
						var str = "";
						for(var i=0;i<a.length;i++){
							var ib = _global.mainCnx.getInfoBasic(a[i]);
							if(ib != undefined){
								if(ib.gender == "F"){
									var fColor = "BB4444";
								}else{
									var fColor = "242169";
									ib.gender = "M";
								}
								str += '<font color="#'+fColor+'">'+Lang.fv("chat.cmd.asv."+ib.gender+".response",{u: a[i],a: ib.age,c: ib.country,r: ib.region,l: ib.xpLevel,o: ''})+"</font><br/>";
							}
						}
						this.addText(str);
					}
					break;
				case "/!":
					if(this.cmode == "channel" && this.flMode && arr[1].length){
						var msg = end.substr(arr[1].length+1);
						var x = new XML();
						var n = x.createTextNode(FEString.unHTML(msg));
						var u = this.userList.getRealUserName(arr[1]);
						_global.mainCnx.cmd("senduserongroup",{g: this.group,u: u,t: "w"},n);
						this.addText(Lang.fv("chat.cmd.warn_send_to_user.sended",{u: u,m: msg}));
					}
					break;
        case "/give":
        case "/donne":
        case "/kikooz":
          if(arr.length < 3 || isNaN(Number(arr[1]))){
						this.addText("<i>Syntaxe: /donne kikooz user [message]<br/>Exemple: /donne 3 deepnight Parce qu'il est sympa !</i>");
						return false;
					}

          var kikooz = Number(arr[1]);
          var user = arr[2];
          var msg = end.substr(arr[1].length+arr[2].length+2);
          
					if( _global.me.flAnimator ){
	          var l:HTTP = new HTTP("do/give",{k: kikooz,u: user,r: msg},{type: "xml",obj: this,method: "onGive"});
					}else{
						_global.topDesktop.addBox(new box.Alert({
						 text: Lang.fv("chat.give",{u: user,k: kikooz}),
						 butActList: [
							{name: "Oui",action: {obj: this, method: "doGive",args: {k: kikooz,u: user,r: msg}}},
							{name: "Non"}
						 ]
						}));
					}

          break;
				case "/g":
					if(_global.me.flMode && arr[1].length){
						var msg = end.substr(arr[1].length+1);
						if(msg.length == 0) msg = "index";
						var x = new XML();
						var n = x.createTextNode(msg);
						var u = this.userList.getRealUserName(arr[1]);
						_global.mainCnx.cmd("senduserongroup",{g: this.group,u: u,t: "g"},n);
						this.addText(Lang.fv("chat.cmd.gaspard_send_to_user.sended",{u: u,m: msg}));
					}
					break;
				case "/mykikooz":
				case "/kikoozrestants":
				case "/meskikooz":
					if( !_global.me.flAnimator ) return false;

					var l:HTTP = new HTTP("do/give",{},{type: "xml",obj: this,method: "onMyKikooz"});
					break;
				case "/q":
				case "/quit":
				case "/quitter":
				case "/fermer":
				case "/exit":
				case "/close":
					this.tryToClose();
					break;
				case "/log":
				case "/logs":
				case "/histo":
					if(!_global.me.flMode && !_global.me.flAnimator) return false;

					getURL("javascript:fp_openHisto('"+_root.sid+"','"+this.group+"')","");
					break;
				default:
					this.addText(Lang.fv("chat.cmd.unknow",{n: cmd}));
					break;
			}

			return true;
		}

		if(!this.joined) return false;
		if(this.cmode == "private" && !this.oJoined) return false;

		if(this.cmode == "channel" && this.passwd == undefined){
			var m = "pub";
		}else{
			var m = "priv";
		}
		if(str.length > _global.maxMessageLength[m]){
			this.addText(Lang.fv("error.chat.message_too_long"));
			return false;
		}
		if(m == "pub" && _global.mainCnx.isInvisible(_global.me.name)){
			return false;
		}
		
		if(!this.checkFlood()) return true;

		str = FEString.unHTML(str);
		
		if(this.findAction(str)){
			return true;
		}

		if(this.cmode == "channel" && this.passwd == undefined){
			if(FEString.countUpperCase(str) / str.length > 0.5){
				this.addText(Lang.fv("chat.toomanyuppercase"));
				return true;
			}

			if(FEString.checkRepeat(str,12)){
				if(random(20) == 0){
					this.addText(Lang.fv("chat.repeat2"));
				}else{
					this.addText(Lang.fv("chat.repeat"));
				}
				return true;
			}

			str = FEString.rmNewLine(str);
		}else{
			//str = FEString.parseUrls(str);
		}
		
		this.animAntiFlood.nb = 0;

		if(FEString.startsWith(str,"!") && this.flMode && this.cmode != "private"){
			this.sendMsgMode(str.substr(1));
		}else if(_global.me.flAnimator && FEString.startsWith(this.group,"quizz")){
			if(FEString.startsWith(str,"!")){
				this.sendMsgMode(str.substr(1));
			}else if(FEString.startsWith(str,"�") == this.blueMode){
				if(FEString.startsWith(str,"�")){
					str = str.substr(1)
				}
	      this.sendMsg(str);
			}else{
				if(FEString.startsWith(str,"�")){
					str = str.substr(1)
				}
				this.sendMsgAnimator(str);
			}
    }else{
			this.sendMsg(str);
		}
		return true;
	}

	function checkFlood(){
		var t = _global.localTime.getTime();
		if(
				 t - this.lastSendTimer[0] < _global.floodMinDuration[0]
			|| t - this.lastSendTimer[1] < _global.floodMinDuration[1]
			|| t - this.lastSendTimer[2] < _global.floodMinDuration[2]
			|| t - this.lastSendTimer[3] < _global.floodMinDuration[3]
		){
			var r = false;
			this.addText(Lang.fv("chat.flood"));
			_global.onFlood();
		}else{
			var r = true;
		}

		// Delete > 3
		this.lastSendTimer.splice(3,1);
		this.lastSendTimer.pushAt(0,t);

		return r;
	}

	function addText(str,mode,fColor){
		if(this.cmode == "private"){
			// TODO: recoder tout �a
			/*
			if(!FEString.startsWith(str,"<i>")){
				this.so.data.content.push(str);
				if(this.so.data.content.length > userPref.getPref("cache_length")){
					this.so.data.content.splice(0,this.so.data.content.length - userPref.getPref("cache_length"));
				}
			}
			*/
		}
		var refreshNeeded = false;
		if(mode != undefined){
			var i = this.content.getIndexByProperty("mode",mode);
			if(i >= 0){
				this.content.splice(i,1);
				var refreshNeeded = true;
			}
		}
		this.content.push({str: str,mode: mode,fColor: fColor});
		if(this.content.length > _global.userPref.getPref("cache_length")){
			this.content.splice(0,this.content.length - _global.userPref.getPref("cache_length"));
		}
		if(this.flShow){
			if(!refreshNeeded){
				this.window.mainField.addText(str,fColor);
			}else{
				this.window.mainField.clean();
				for(var i=0;i<this.content.length;i++){
					this.window.mainField.addText(this.content[i].str,this.content[i].fColor);
				}
			}
		}
	}

	function cleanText(){
		this.content = new Array();
		this.window.mainField.clean();
	}

	function hide(){
		this.window.mainField.clean();
		this.winCompoOpen.screenList = this.window.flScreenList;
		this.winCompoOpen.userList = this.window.flUserList;
		
		if(this.winCompoOpen.screenList) this.window.toggleScreenList();
		if(this.winCompoOpen.userList) this.window.toggleUserList();
		
		return super.hide();
	}

	function show(){
		this.window.mainField.clean();
		var str = "";
		for(var i=0;i<this.content.length;i++){
			if(i > 0) str += "<br/>";
			str += "<font color=\"#"+this.content[i].fColor.toString(16)+"\">"+this.content[i].str+"</font>";
		}
		this.window.mainField.addText(str);
		
		if(this.winCompoOpen.screenList) this.window.toggleScreenList();
		if(this.winCompoOpen.userList) this.window.toggleUserList();

		return super.show();
	}

	function createChannel(){
		var reply = FEString.uniqId();
		_global.mainCnx.addListener("createChannel",this,"onCreateChannel","r",reply);
		if(this.cmode == "private"){
			this.topic = Lang.fv("chat.privatetopic",{m: _global.me.name,u: this.user});
		}
		if(this.topic != undefined){
			this.topic = FEString.trim(FEString.rmNewLine(this.topic));
			var x = new XML();
			var t = x.createTextNode(this.topic);
		}
		if(this.cmode == "private"){
			this.invitationSended = false;
			_global.mainCnx.cmd("createChannel",{u: this.user,r: reply},t);
		}else{
			_global.mainCnx.cmd("createChannel",{r: reply},t);
		}
	}

	function inviteChat(){
		if(!this.joined){
			_global.debug("Must be on channel before try to invitechat the other user");
			return false;
		}
		if(this.oJoined){
			_global.debug("The other user have already joined, no ?");
			return false;
		}
		this.invitationSended = true;
		_global.mainCnx.cmd("inviteChat",{u: this.user,g: this.group});
	}

	function invite(user){
		if(!this.joined){
			_global.debug("Must be on channel before try to invite someone else");
			return false;
		}
		
		if(this.userList.isInList(user)){
			return false;
		}
		
		var reply = FEString.uniqId();
		_global.mainCnx.addListener("invite",this,"onInvite","r",reply);
		_global.mainCnx.cmd("invite",{u: user,g: this.group,r: reply});
	}
	
	function send(t,x){
		var o = {g: this.group};
		if(t != "m" && t != undefined){
			o.t = t;
		}
		if(this.activePen != undefined){
			o.p = this.activePen;
		}
		
		//
		if(this.cmode == "channel" && this.passwd == undefined){
			_global.me.xpFlagAdd("pbChatMsg");
		}else{
			_global.me.xpFlagAdd("pvChatMsg");
		}
		
		_global.mainCnx.cmd("send",o,x);
	}

	function sendMsg(str){
		var x = new XML();
		var n = x.createTextNode(str);
		this.send("m",n);
	}
	
	function sendMsgMode(str){
		var x = new XML();
		var n = x.createTextNode(str);
		this.send("w",n);
	}

  function sendMsgAnimator(str){
    var x = new XML();
    var n = x.createTextNode(str);
    this.send("c",n);
  }
	
	function sendAction(id){
		var x = new XML();
		var n = x.createTextNode(id);
		this.send("a",n);
	}

	function sendKikooz(k,u){
		var x = new XML();
		x.nodeName = "g";
		x.attributes.k = k;
		x.attributes.u = u;
		this.send("g",x);
	}

  function sendWallpaper(url,alpha){
    var str = alpha+";"+url;
    var x = new XML();
    var c = x.createTextNode(str);
    this.send("b",c);
  }

	function sendImage( width, height, url, title ){
		var x = new XML();
		x.nodeName = "i";
		x.attributes.w = width;
		x.attributes.h = height;
		x.attributes.u = url;
		x.appendChild( x.createTextNode(title) );
		this.send("i",x);
	}

	function part(){
		if(this.group != undefined){
			if(this.joined){
				_global.mainCnx.cmd("part",{g: this.group});
			}
			_global.mainCnx.removeListenerCmdObj("userlist",this,"g",this.group);
			_global.mainCnx.removeListenerCmdObj("userleaved",this,"g",this.group);
			_global.mainCnx.removeListenerCmdObj("userjoined",this,"g",this.group);
			_global.mainCnx.removeListenerCmdObj("userkicked",this,"g",this.group);
			_global.mainCnx.removeListenerCmdObj("userbanned",this,"g",this.group);
			_global.mainCnx.removeListenerCmdObj("topic",this,"g",this.group);
			_global.mainCnx.removeListenerCmdObj("send",this,"g",this.group);
			_global.mainCnx.removeListenerCmdObj("join",this,"g",this.group);
			_global.mainCnx.removeListenerCmdObj("refuse",this,"g",this.group);
			_global.mainCnx.removeListenerCmdObj("onban",this,"g",this.group);
			_global.mainCnx.removeListenerCmdObj("onkick",this,"g",this.group);
			_global.mainCnx.removeListenerCmdObj("senduserongroup",this,"g",this.group);
			_global.mainCnx.removeListenerCmdObj("moderatorcalled",this,"g",this.group);
			
		}
		this.joined = false;
		this.oJoined = false;
	}

	function join(){

		_global.mainCnx.addListener("join",this,"onJoin","g",this.group);
		if(this.passwd != undefined){
			_global.mainCnx.cmd("join",{g: this.group,p: this.passwd});
		}else{
			_global.mainCnx.cmd("join",{g: this.group});
		}
	}
	
	function addUserActionListener(obj,method){
		this.userActionListenerList.push({obj: obj,method: method});
	}
	
	function removeUserActionListener(obj,method){
		for(var i=0;i<this.userActionListenerList.length;i++){
			var row = this.userActionListenerList[i];
			if(row.obj == obj && row.method == method){
				this.userActionListenerList.splice(i,1);
				return true;
			}
		}
		return false;
	}
	
	function onChangeTopic(node){
		if(node.attributes.k != undefined){
			this.addText(Lang.fv("error.chat.change_topic",{e: Lang.fv("error.cbee."+node.attributes.k)}));
		}
		_global.mainCnx.rmListenerCmdObj("topic",this,"r",node.attributes.r);
	}

	function onInvite(node){
		if(node.attributes.k != undefined){
			this.addText(Lang.fv("error.chat.invite",{u: node.attributes.u,e: Lang.fv("error.cbee."+node.attributes.k)}));
		}else{
			this.addText(Lang.fv("chat.invite_sent",{u: node.attributes.u}));
		}
		_global.mainCnx.rmListenerCmdObj("invite",this,"r",node.attributes.r);
	}

	function onCreateChannel(node){
		if(node.attributes.k == undefined){
			this.group = node.attributes.g;
			this.joined = true;
			this.flMode = true;
			if(this.cmode == "private"){
				this.addText(Lang.fv("chat.waitother",{u: this.user}),1);
				this.inviteChat();
			}else{
				this.addText(Lang.fv("chat.onjoin",{t: FEString.unHTML(this.topic)}));
        this.passwd = "";
				_global.channelMng.pushUniq(this.group);
			}
			if(this.destSlot != undefined){
				this.move(this.destSlot);
			}
			
			this.destSlot = undefined;
			this.initAfterJoin();
		}else{
			if(node.attributes.k == "201" && node.attributes.u != undefined){ // user_unknow, c'est � dire non connect�
				_global.topDesktop.addBox(new box.Alert({
					text: Lang.fv("chat.nouser",{u: node.attributes.u}),
					butActList: [
						{
							name: Lang.fv("cancel")
						},
						{
							name: Lang.fv("contact_by_mail"),
							action:{
								obj: _global,
								method: "openMail",
								args: node.attributes.u+"@frutiparc.com"
							}
						}
					]
				}));
			}else{
				_global.openErrorAlert(Lang.fv("error.chat.create_channel")+Lang.fv("error.cbee."+node.attributes.k));
			}
			this.close();
		}
		_global.mainCnx.rmListenerCmdObj("createChannel",this,"r",node.attributes.r);
	}

	function onJoin(node){
		if(node.attributes.k == undefined){
			this.joined = true;
			this.topic = node.firstChild.firstChild.nodeValue.toString();
			if(this.cmode == "private"){
				//this.oJoined = true;
				//this.addText(Lang.fv("chat.initprivate",{u: this.user}));
			}else{
				this.addText(Lang.fv("chat.onjoin",{t: FEString.unHTML(this.topic)}));
			}
			this.initAfterJoin();
		}else{
			if(Number(node.attributes.k) == 200 && this.cmode == "private"){
				this.group = undefined;
				this.createChannel();
			}else{
				this.joined = false;
				_global.openErrorAlert(Lang.fv("error.chat.join_channel")+Lang.fv("error.cbee."+node.attributes.k));
				this.close();
			}
		}
		_global.mainCnx.rmListenerCmdObj("join",this,"group",this.group);

    if(_global.me.flMode){
      this.onIamMode();
    }
		if(_global.me.flAnimator){
			this.onIamAnim();
		}
	}

	function onRefuse(node){
		this.addText(Lang.fv("chat.onrefuse",{u: node.attributes.u}));
		if(this.cmode == "private" && node.attributes.u == this.user){
			this.addText(Lang.fv("chat.contactbymail",{u: node.attributes.u}),1);
			this.oJoined = false;
		}
	}

	function onUserJoined(node){
		if(node.attributes.u == undefined) return;
	
		var infoBasic = UserMng.formatInfoBasic(node);
		this.userList.addUser(node.attributes.u,infoBasic,(node.attributes.m=="1"));
		_global.mainCnx.setInfoBasic(node.attributes.u,infoBasic);
		
		if(node.attributes.u == _global.me.name){
			this.flMode = (node.attributes.m=="1");
		}
		
		this.refreshTitle();
		var dspJoin = false;
		if(this.cmode == "private"){
			if(node.attributes.u == this.user){
				this.oJoined = true;
				this.addText(Lang.fv("chat.initprivate",{u: node.attributes.u}),1);
        this.onChatReady();
			}else{
				_global.debug(node.attributes.u+" nous rejoint => passage en channel");
				this.chat2channel();
				var dspJoin = true;
			}
		}else{
			var dspJoin = true;
		}
		if(dspJoin){
			if(_global.userPref.getPref("ch_dsp_join")){
				this.addText(Lang.fv("chat.userjoined",{u: node.attributes.u}));
			}
		}
		
	}

	function onUserLeaved(node){
		if(node.attributes.u == undefined) return;
		
		var r = this.userList.rmUser(node.attributes.u);
		this.refreshTitle();
		if(this.cmode == "private"){
			if(node.attributes.u == this.user){
				this.oJoined = false;
				if(this.mode == "trash"){
					this.close();
				}else{
					this.addText(
						Lang.fv("chat.privatedcnx",{u: node.attributes.u})+". "+
						Lang.fv("chat.contactbymail",{u: node.attributes.u})
					,1);
				}
			}
		}else{
			if(_global.userPref.getPref("ch_dsp_leave") && r){
				this.addText(Lang.fv("chat.userleaved",{u: node.attributes.u}));
			}
		}
		
	}

	function onKick(node){
		if(node.attributes.u == _global.me.name){
			this.joined = false;
			this.close();
		}else{
			var r = this.userList.rmUser(node.attributes.u);
			this.refreshTitle();
			if(_global.userPref.getPref("ch_dsp_kick") && r){
				this.addText(Lang.fv("chat.userkicked",{u: node.attributes.u}));
			}
		}
	}

	function onBan(node){
		if(node.attributes.u == _global.me.name){
			this.joined = false;
			this.close();
		}else{
			var r = this.userList.rmUser(node.attributes.u);
			this.refreshTitle();
      if(r){
        if(this.flMode){
				  this.addText(Lang.fv("chat.userbanned",{u: node.attributes.u}));          
        }else if(_global.userPref.getPref("ch_dsp_leave")){
				  this.addText(Lang.fv("chat.userleaved",{u: node.attributes.u}));
        }
			}
		}
	}

	function onSend(node){
		if(_global.userPref.getPref("ch_dsp_h")){
			var h = Lang.formatDate(_global.localTime.getDateObject(),"time_chat");
		}else{
			var h = "";
		}
		var cmd = node.attributes.t;
		if(cmd == undefined) cmd = "m";

    if(cmd != "b" && cmd != "i"){
    	if(this.mode == "trash"){
	    	this.move(_global.desktop);
   		}
   		if(this.cmode == "private" || (this.cmode == "channel" && this.passwd != undefined)){
	 		   if(this.mode == "desktop"){
	    			this.activate();
			   }
			   this.slot.warning();
   		}
    }

		
		if(node.attributes.p != undefined){
			var fColor = FEColor.toRGBInt(_global.penList[Number(node.attributes.p)]);
		}else{
			var fColor = undefined;
		}

		if(cmd == "i"){
		/*
	    _global.desktop.addBox(
	      new box.DocScreen({
	        pos: {
	          w: Number(node.firstChild.attributes.w),
	          h: Number(node.firstChild.attributes.h)
	        },
	        doc: new XML('<p><l><u u="'+node.firstChild.attributes.u+'"/></l></p>'),
	        title: node.firstChild.firstChild.nodeValue.toString()
	      })
	    );
		*/
    }else if(cmd == "b"){
      if(node.attributes.u == _global.me.name) return false;
      
      var str = node.firstChild.nodeValue.toString();
      if(str.length <= 0){
         this.wallpaper = {url: null,alpha: null};
      }else{
         var arr = str.split(";");
				 if( arr[1].substr(0,27) == "http://img.frutiparc.com/wp" ){
					 this.wallpaper = {url: arr[1],alpha: Number(arr[0])};
				 }
      }
      this.window.setWallpaper(this.wallpaper.url,this.wallpaper.alpha);
      
      return ;
    }else if(cmd == "m" || cmd == "w" || cmd == "c"){
			this.myStats.nbMsg++;
			if(this.myStats.nbMsg > 1){
				var msgTime = getTimer();
				var timeTweenMsg = msgTime - this.myStats.lastMsgTime;
				if(timeTweenMsg > this.myStats.maxTimeTweenMsg){
					this.myStats.maxTimeTweenMsg = timeTweenMsg;
				}
			}else{
				var msgTime = getTimer();
			}
			this.myStats.lastMsgTime = msgTime;
			
		
			var actObj = {id: 1};
			var msg = node.firstChild.nodeValue.toString();
			if(msg == undefined || msg == "undefined") return false;

			if(this.goodAnswer != undefined){
				if( !_global.me.flAnimator || !this.userList.isMode(node.attributes.u) ){
					var msgl = msg.toLowerCase();
					if(msgl.indexOf(this.goodAnswer) >= 0){
						_global.openAlert("La bonne r�ponse a �t� donn�e par "+node.attributes.u+" ["+msgl+"]","Bonne r�ponse !");
						this.goodAnswer = undefined;
					}
				}
			}
			
			if(cmd == "w"){
				fColor = FEColor.toRGBInt(_global.penRedMode);
				msg = "<b>"+msg+"</b>";
			}
      if(cmd == "c"){
				fColor = FEColor.toRGBInt(_global.penBlueAnimator);      
				msg = "<font size=\"14\"><b>"+msg+"</b></font>";
      }
			if(node.attributes.u == "admin"){
				this.addText(Lang.fv("chat.msg_admin",{u: node.attributes.u,m: msg,h: h}),undefined,fColor);
			}else{
				this.addText(Lang.fv("chat.msg",{u: node.attributes.u,m: msg,h: h}),undefined,fColor);
			}
			actObj.length = msg.length;
		}else if(cmd == "a"){
			var actObj = {id: node.firstChild.nodeValue.toString()};
			this.addText(Lang.fv("chat.action."+node.firstChild.nodeValue.toString(),{u: node.attributes.u,h: h}),undefined,fColor);
		}else if(cmd == "g"){
			if( node.firstChild.attributes.u == _global.me.name ){
				this.addText(Lang.fv("chat.givemsg",{u: node.attributes.u,k: node.firstChild.attributes.k,h: h}),undefined,fColor);
			}
		}else{
			return false;
		}
		
		
		this.onUserAction(String(node.attributes.u),actObj);
	}
	
	function onSendUser(node){
		if(this.mode == "trash"){
			this.move(_global.desktop);
		}
		if(this.cmode == "private" || (this.cmode == "channel" && this.passwd == undefined)){
			if(this.mode == "desktop"){
				this.activate();
			}
			this.slot.warning();
		}
		
		if(_global.userPref.getPref("ch_dsp_h")){
			var h = Lang.formatDate(_global.localTime.getDateObject(),"time_chat");
		}else{
			var h = "";
		}
		
		var cmd = node.attributes.t;
		if(cmd == "w"){
			var actObj = {id: 1};
			var msg = node.firstChild.nodeValue.toString();
			if(msg == undefined || msg == "undefined") return false;

			var fColor = FEColor.toRGBInt(_global.penRedMode);
			msg = "<b>"+msg+"</b>";
			
			this.addText(Lang.fv("chat.msg",{u: node.attributes.u,m: msg,h: h}),undefined,fColor);
			actObj.length = msg.length;
		}else if(cmd == "g"){
			_global.uniqWinMng.displayHelp({t: node.firstChild.nodeValue.toString()})
			return false;
		}else{
			return false;
		}
		
		this.onUserAction(String(node.attributes.u),actObj);
	}
	
	function onUserAction(usr,actObj){
		this.userList.onUserAction(usr,actObj);
		var sObj = _global.mainCnx.getStatusObj(usr);
		for(var i=0;i<this.userActionListenerList.length;i++){
			var list = this.userActionListenerList[i];
			list.obj[list.method](usr,sObj.fbouille,actObj);
		}
	}
	
	function onUserList(node){
		if(node.attributes.k == undefined){
			//this.userList.rmAll();
			for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){
				if(n.nodeName != "u") continue;
				
				if(this.cmode == "private" && n.attributes.u == this.user && !this.oJoined){
					this.oJoined = true;
					this.addText(Lang.fv("chat.initprivate",{u: n.attributes.u}),1);
          this.onChatReady();
				}
				if(n.attributes.u == _global.me.name){
					this.flMode = (n.attributes.m=="1");
				}
				
				var infoBasic = UserMng.formatInfoBasic(n);
				this.userList.addUser(n.attributes.u,infoBasic,(n.attributes.m=="1"),false);
				_global.mainCnx.setInfoBasic(n.attributes.u,infoBasic);
			}
			if(this.cmode == "private" && this.userList.length > 2){
				_global.debug("Le userList contient au moins trois personnes => channel");
				this.chat2channel();
			}
			this.userList.onChange();
		}
		this.refreshTitle();
	}

	function onTopic(node){
		if(node.firstChild.nodeValue != undefined){
			this.topic = node.firstChild.nodeValue.toString();
			this.refreshTitle();
		}
	}

	function onEnter(){
		if(this.analyseInput(this.window.getInput())){
			this.window.setInput("");
		}
	}
	
	function onIdent(x){
		if(x.attributes.k != undefined) return;
		this.join();
	}

  function onModeratorCalled(node){
    var fColor = FEColor.toRGBInt(_global.penRedMode);
    this.addText(Lang.fv("chat.moderator_called_channel",{u: node.attributes.u}),undefined,fColor);
  }
	
	function onCnxClose(){
		this.joined = false;
		this.oJoined = false;
		if(this.cmode == "private"){
			this.addText(Lang.fv("chat.dcnx"),1);
		}else{
			this.addText(Lang.fv("chat.dcnx"));
		}
		if(this.mode == "trash") this.close();
	}

	function chat2channel(){
		this.cmode = "channel";
		_global.chatMng.unsetBox(this.user);
		_global.channelMng.pushUniq(this.group);
		this.refreshTitle();
		_global.mainCnx.strace(this.user,this);
		this.user = undefined;
   
    this.wallpaper = {url: null,alpha: null};
    this.window.setWallpaper(this.wallpaper.url,this.wallpaper.alpha);
	}

	function initAfterJoin(){
		if(this.cmode == "private"){
			this.refreshTitle();
		}else{
			this.refreshTitle();
		}
		
		
		this.myStats = {
			initTime: getTimer(),
			nbMsg: 0,
			maxTimeTweenMsg: 0,
			lastMsgTime: undefined
		
		};
		
		// Remove old listener if found
		_global.mainCnx.removeListenerCmdObj("userlist",this,"g",this.group);
		_global.mainCnx.removeListenerCmdObj("userleaved",this,"g",this.group);
		_global.mainCnx.removeListenerCmdObj("userjoined",this,"g",this.group);
		_global.mainCnx.removeListenerCmdObj("userkicked",this,"g",this.group);
		_global.mainCnx.removeListenerCmdObj("userbanned",this,"g",this.group);
		_global.mainCnx.removeListenerCmdObj("topic",this,"g",this.group);
		_global.mainCnx.removeListenerCmdObj("send",this,"g",this.group);
		_global.mainCnx.removeListenerCmdObj("join",this,"g",this.group);
		_global.mainCnx.removeListenerCmdObj("refuse",this,"g",this.group);
		_global.mainCnx.removeListenerCmdObj("onban",this,"g",this.group);
		_global.mainCnx.removeListenerCmdObj("onkick",this,"g",this.group);
		_global.mainCnx.removeListenerCmdObj("senduserongroup",this,"g",this.group);
		_global.mainCnx.removeListenerCmdObj("moderatorcalled",this,"g",this.group);
		
		// Add wanted listeners
		_global.mainCnx.addListener("userlist",this,"onUserList","g",this.group);
		_global.mainCnx.addListener("userleaved",this,"onUserLeaved","g",this.group);
		_global.mainCnx.addListener("userjoined",this,"onUserJoined","g",this.group);
		_global.mainCnx.addListener("userkicked",this,"onUserKicked","g",this.group);
		_global.mainCnx.addListener("userbanned",this,"onUserBanned","g",this.group);
		_global.mainCnx.addListener("topic",this,"onTopic","g",this.group);
		_global.mainCnx.addListener("send",this,"onSend","g",this.group);
		_global.mainCnx.addListener("refuse",this,"onRefuse","g",this.group);
		_global.mainCnx.addListener("onban",this,"onBan","g",this.group);
		_global.mainCnx.addListener("onkick",this,"onKick","g",this.group);
		_global.mainCnx.addListener("senduserongroup",this,"onSendUser","g",this.group);
		_global.mainCnx.addListener("moderatorcalled",this,"onModeratorCalled","g",this.group);
		
		this.userList.rmAll();
		_global.mainCnx.cmd("userlist",{g: this.group});
	}

	function switchToGroup(grp,passwd){
		if(this.group == grp && this.joined) return false;
		if(this.group == grp && this.passwd == passwd) return false;
		this.part();
		this.group = grp;
		this.passwd = passwd;
		this.join();
	}

	function onStatusObj(obj){
		if(obj.presence == 1 && this.cmode == "private"){
			if(this.joined){
				if(!this.oJoined && this.mode != "trash"){
					this.inviteChat();
				}
			}else if(oldPresence == 0){
				this.createChannel();
			}
		}
		this.oldPresence = obj.presence;
	}
	
	function findAction(str){
		var aId = _global.me.fbouilleActionStr[String(str)];
		if(aId != undefined){
			if(this.animAntiFlood.nb >= 2 || (getTimer() - this.animAntiFlood.last) < 5000){
				this.addText(Lang.fv("chat.anim_anti_flood"));
			}else{
				this.animAntiFlood.last = getTimer();
				this.animAntiFlood.nb++;
				this.sendAction(aId);
			}
			return true;
		}else{
			return false;
		}
	}
	
	function userToBlackList(){
		_global.debug("userToBlackList");
		if(this.cmode == "private"){
			if(this.mode == "trash"){
				this.close();
			}else{
				this.addText(Lang.fv("chat.warnblacklist",{u: this.user}));
			}
		}
	}
	
	function onDrop(ico){
		if(ico.type == "contact" && FEString.endsWith(ico.desc[0].toLowerCase(),"@frutiparc.com")){
			this.invite(ico.name);
		}
	}
	
	function refreshTitle(){
		if(this.cmode == "private"){
			this.setTitle(this.user);
		}else{
			this.setTitle(this.topic+" ("+this.userList.length+")");
		}
	}
	
	function onWheel(delta){
		this.window.scrollText(-10 * delta);
	}
	
	function getPenActiveList(){
		var a = new Array();
		for(var i=0;i<_global.penItemList.length;i++){
			a.push(_global.me.hasItem(_global.penItemList[i]));
		}
		return a;
	}
	
	function selectPen(id){
		this.activePen = id;
	}
	
	function getActivePen(){
		return this.activePen;
	}
	
	function eject(user){
		if(this.flMode && this.cmode == "channel"){
			_global.mainCnx.cmd("kick",{u: user,g: this.group});
		}
	}
	
	function ban(user){
		if(_global.me.flAnimator && this.group == "quizz"){
			var t = _global.servTime.getTime() + 24 * 60 * 60 * 1000; // time + 24 hours
			var end = Lang.formatDateTime(t,"prog_server");
			_global.mainCnx.cmd("ban",{u: user,g: this.group,e: end});
		}else if(this.flMode && this.cmode == "channel" && this.passwd == undefined){
			_global.mainCnx.cmd("ban",{u: user,g: "0"});
		}
	}
	
	function openFrutizInfo(u){
		_global.frutizInfMng.open(u,undefined,this.group);
	}
	
	function getTipDoc(u){
		var ib = _global.mainCnx.getInfoBasic(u);
		
		return {
			type: "html",
			html: Lang.fv("chat.u_tip",{a: ib.age,c: ib.country,r: ib.region,l: ib.xpLevel})
		};
	}
	
	function getTipDocLong(u){
		var ib = _global.mainCnx.getInfoBasic(u);
		
		return {
			type: "html",
			html: Lang.fv("chat.u_tip_long",{u:u,a: ib.age,c: ib.country,r: ib.region,l: ib.xpLevel})
		};
	}

  function whining(){
    if(this.cmode != "channel" || this.passwd != undefined){
      _global.openErrorAlert("Cette action n'est disponible que sur les salons publics.");
    }else if(this.userList.modePresent()){
      _global.openErrorAlert("Un ou plusieurs mod�rateurs sont d�j� pr�sents sur ce salon.");
    }else if(this.lastCallModerator != undefined && _global.localTime.getTime() - this.lastCallModerator < 60000){
      _global.openErrorAlert("Vous venez de pr�venir les mod�rateurs !"); 
    }else{
    	_global.topDesktop.addBox(new box.Alert({
		   text: Lang.fv("chat.call_moderator"),
 	 		 butActList: [
   	    {name: "Oui",action: {obj: this, method: "callModerator"}},
	 	    {name: "Non"},
	 	    {name: "C'est quoi ?",action: {obj: _global.uniqWinMng,method: "displayHelp",args: {t: "appel"}}}
	 	   ]
 	    }));
    }
  }

	function doGive( a ){
		var l:HTTP = new HTTP("do/give",a,{type: "xml",obj: this,method: "onGive"});
	}

  function callModerator(){
    this.lastCallModerator = _global.localTime.getTime();
    _global.mainCnx.cmd("callmoderator",{g: this.group});
  }

  function onIamMode(){
    if(this.cmode == "channel" && this.passwd == undefined){
       this.addText("<a href=\"javascript:fp_openHisto('"+_root.sid+"','"+this.group+"')\">... voir les messages pr�c�dents ...</a>");
      // this.addText("<a href=\"javascript:fp_openPopup('/do/chat_log?sid="+_root.sid+"&c="+this.group+"#end','Histo"+this.group+"','width=450,height=300')\">... voir les messages pr�c�dents ...</a>");
    }
  }

  function onIamAnim(){
    if(FEString.startsWith(this.group,"quizz")){
       this.addText("<a href=\"javascript:fp_openHisto('"+_root.sid+"','"+this.group+"')\">... ouvrir le log...</a>");
      // this.addText("<a href=\"javascript:fp_openPopup('/do/chat_log?sid="+_root.sid+"&c="+this.group+"#end','Histo"+this.group+"','width=450,height=300')\">... voir les messages pr�c�dents ...</a>");
    }
  }

  function onChangeWallpaper(url,alpha){
    if(this.cmode == "private"){
      this.sendWallpaper(url,alpha);
    }
  }

  function onChatReady(){
    if(_global.wallPaper.url != undefined){
      this.sendWallpaper(_global.wallPaper.url,_global.wallPaper.pvAlpha);
    }
  }
  

  function onGive(success,xml){
    if(!success){
      this.addText("<i>Erreur durant le don : "+Lang.fv("error.host_unreachable")+"</i>");
      return;
    }
    if(xml.firstChild == undefined || xml.firstChild.attributes.k == undefined){
      this.addText("<i>Erreur durant le don : "+Lang.fv("error.http.1")+"</i>");
      return;
    }
    
    xml = xml.firstChild;
    if(xml.attributes.k != "0"){
      this.addText("<i>Erreur durant le don : "+Lang.fv("error.http."+xml.attributes.k,xml.attributes)+"</i>");
      return;
    }

    this.addText("<i>Don r�ussi ! Vous avez maintenant "+xml.attributes.a+" kikooz disponibles.</i>");
    if( _global.me.flAnimator )
			this.sendMsgAnimator(xml.attributes.u+" a gagn� "+xml.attributes.g+" kikooz !");
		else
			this.sendKikooz(xml.attributes.g,xml.attributes.u);
  }

	function onMyKikooz(success,xml){
		if(!success){
			this.addText("<i>MyKikooz error: host unreachable</i>");
			return;
		}
		if(xml.firstChild == undefined || xml.firstChild.attributes.k == undefined){
			this.addText("<i>MyKikooz error: bad format</i>");
			return;
		}

		xml = xml.firstChild;
    if(xml.attributes.k != "0"){
      this.addText("<i>MyKikooz error : "+Lang.fv("error.http."+xml.attributes.k,xml.attributes)+"</i>");
      return;
    }

		this.addText("<i>Il me reste "+xml.attributes.a+" kikooz distribuables cette semaine.</i>");
	}
}
