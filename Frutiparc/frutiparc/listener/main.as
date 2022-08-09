class listener.main{//}

	

	static function onIdent(node){

		if(node.attributes.k == undefined){

			_global.me.logged = true;

			_global.me.name = node.attributes.l;

			_global.me.pass = _global.mainCnx.pass;

			_global.me.xp = Number(node.attributes.x);

			_global.me.fbouille = node.attributes.f;

			_global.mainCnx.login = _global.me.name;

			

			if(node.attributes.mu != undefined){

				_global.me.flMuted = true;

				_global.me.endMute = node.attributes.mu;

			}

			

			if(!_global.me.haveBeenLogged){

				_global.mainCnx.atrace(_global.me.name,_global.main.mainBar.screen,"onStatusObj");

				_global.main.mainBar.screen.setAction({obj: _global.frutizInfMng,method: "open",args: _global.me.name});



				

				var rid = FEString.uniqId();

				_global.mainCnx.addListener("userinfo",listener.main,"onUserInfo","r",rid);

				_global.mainCnx.cmd("userinfo",{u: _global.me.name,r: rid});



				var rid2 = FEString.uniqId();

				_global.mainCnx.addListener("channellist",listener.main,"onChannelList");

				_global.mainCnx.cmd("channellist");



				_global.mainCnx.addListener("xpposition",listener.main,"onXPPosition");



			}

			

			_global.mainCnx.cmd("xpposition");



      // Computer id

      var so = SharedObject.getLocal("global");

      

      if(so.data.cid == undefined){

         so.data.cid = _root.sid;

      }

      			

			var loader = new HTTP("do/onident",{c: so.data.cid},{type: "xml",obj: listener.main,method: "onHTTPIdent"});

			_global.me.haveBeenLogged = true;

			

		}else{

			_global.mainCnx.strace(_global.me.name,_global.main.mainBar.screen);

			_global.me.logged = false;

			_global.me.name = _global.mainCnx.login;

			_global.me.pass = _global.mainCnx.pass;

			_global.desktop.setTitle(Lang.fv("desktop"));

			_global.desktop.cleanIcon();

			

			// Display activate account window

			if(Number(node.attributes.k) == 53){

				_global.uniqWinMng.open("confirm");

			}

		}

	}



	static function onChannelList(node){

		_global.channelNames = new Object();



		for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){

			if(n.nodeName == "g"){		

				_global.channelNames[ n.attributes.g ] = n.firstChild.firstChild.nodeValue.toString();

			}

		}

	}

	

	static function onUserInfo(node){

		_global.mainCnx.rmListenerCmd("userinfo","r",node.attributes.r);

		

		if(_global.flDebug) return false;

		var age = UserMng.birthdayToAge(node.attributes.bd);



    _global.me.age = age;

		

		/*

		if(age >= 18){

			var channel = "senior";

    }else if(age >= 14){

      var channel = "bienvenue";

		}else if(age == 0){

			var channel = (random(1)==0)?"junior":"bienvenue";

		}else{

			var channel = "junior";

		}

		

		_global.channelMng.open(channel);

		*/

	}

	

	static function onXPPosition(node){

		//_global.mainCnx.rmListenerCmd("xpposition","r",node.attributes.r);

		

		_global.me.xppos = Number(node.attributes.p);

	}

	

	static function onHTTPIdent(success,xml){

		if(!success){

			_global.openErrorAlert(Lang.fv("error.http_on_ident"));

		}else{

			xml = xml.firstChild;

			_global.fileMng.init();

			_global.me.kikooz = Number(xml.attributes.k);

			_global.me.previousTime = xml.attributes.p;

			

			var items = xml.attributes.i.split(",");

			for(var i=0;i<items.length;i++){

				_global.me.addItem(items[i]);

			}

			

			if(xml.attributes.f != undefined){

				var fbouillePart = xml.attributes.f.split(",");

				_global.uniqWinMng.open("editbouille",undefined,{fbouille: _global.me.fbouille,part: fbouillePart});

			}

			

			if(xml.attributes.m == "1"){

				_global.me.flMode = true;

			}

      

      if(xml.attributes.a == "1"){

         _global.me.flAnimator = true;

      }

			

			for(var n=xml.firstChild;n.nodeType>0;n=n.nextSibling){

				switch(n.nodeName){

					// MyPrefs

					case "mp":

						_global.userPref.useMyPref(n.firstChild.nodeValue.toString());

						break;

						

					// UserLog

					case "ul":

						_global.me.emptyUserLog();

						for(var c=n.firstChild;c.nodeType>0;c=c.nextSibling){

							if(c.nodeName != "l") continue;

							_global.me.addUserLog({time: c.attributes.d,type: Number(c.attributes.t),content: c.firstChild.nodeValue.toString()});

						}

						break;

						

					// SiteLog

					case "sl":

						_global.me.emptySiteLog();

						for(var c=n.firstChild;c.nodeType>0;c=c.nextSibling){

							if(c.nodeName != "l") continue;

							_global.me.addSiteLog({time: c.attributes.d,type: Number(c.attributes.t),content: c.firstChild.nodeValue.toString()});

						}

						break;

						

					// DocOnIdent

					case "di":

						var arr = new Array();

						for(var c=n.firstChild;c.nodeType>0;c=c.nextSibling){

							arr.push({doc: c.firstChild,pos: {w: Number(c.attributes.w),h: Number(c.attributes.h)},styleName: c.attributes.s,flBackground: (c.attributes.b=="1"),flDocumentFit: (c.attributes.f=="1"||c.attributes.f==undefined),title: c.attributes.t});

						}

						_global.docOnIdent.go(arr);

						break;

          

          // bouilleList

          case "bl":

            _global.me.bouilleList = new Array();

            for(var c=n.firstChild;c.nodeType>0;c=c.nextSibling){

               _global.me.bouilleList.push({bouille: c.attributes.b,name: c.firstChild.nodeValue.toString()});

            }

            break;

				}

			}



      // 

      var wp = _global.userPref.getPref("wallpaper");

      if(wp.length){

         var arr = wp.split("|");

         _global.wallPaper.loadWP(arr[0],arr[1]);

      }



			// channel

			var dc = _global.userPref.getPref("default_channel");

			switch( dc ){

				case 13:

					_global.uniqWinMng.open("roomList");

					break;

				case 0:

					dc = random(10)+2;

				default:

					var channels = new Array(null,null,"pomme","abricot","poire","fraise","citron","kiwi","raisin","orange","cerise","banane","quizz","","rencontre");

					var channel = channels[ dc ];

					if( channel != null ){

						_global.channelMng.open(channel);

					}				

			}







      

		}

	}

	

	static function onInviteChat(node){

		if(node.attributes.u == _global.me.name) return false;

	

		if(node.attributes.p != undefined && node.attributes.u != undefined ){

			var usrLower = node.attributes.u.toLowerCase();

			if(_global.chatMng["_"+usrLower] != undefined){

				_global.chatMng.open(_global.trashSlot,node.attributes.u,node.attributes.g,node.attributes.p);

			}else{

				var r = _global.chooseInviteBehavior(_global.userPref.getPref("invite_chat_behavior"),node.attributes.u);

				switch(r){

					case "A":

						_global.chatMng.open(_global.trashSlot,node.attributes.u,node.attributes.g,node.attributes.p);

						break;

					case "P":

						_global.chatInvite.open({

							id: node.attributes.u,

							text: Lang.fv("chat.invite_private",{u: node.attributes.u}),

							yesAct: {obj: _global.chatMng,method: "open",args: [_global.desktop,node.attributes.u,node.attributes.g,node.attributes.p]},

							noAct:	{obj: _global.mainCnx,method: "cmd",args: ["refuse",{u: node.attributes.u,g: node.attributes.g}]}

						});

						/*

						_global.topDesktop.addBox(new box.Alert({

							text: Lang.fv("chat.invite_private",{u: node.attributes.u}),

							butActList: [

								{name: "Oui",action: },

								{name: "Non",action: }

							]

						}));

						*/

						break;

					case "R":

						_global.mainCnx.cmd("refuse",{u: node.attributes.u,g: node.attributes.g});

						break;

				}

			}// end if chat exists

		}

	}// end function

	

	static function onInvite(node){

		if(node.attributes.r != undefined) return false;

		

		if(node.attributes.g != undefined && node.attributes.u != undefined ){

			if(node.attributes.u == _global.me.name) return false;

			if(_global.channelMng.isIn(node.attributes.g)) return false;

			

			var r = _global.chooseInviteBehavior(_global.userPref.getPref("invite_channel_behavior"),node.attributes.u);

			

			switch(r){

				case "A":

					_global.channelMng.open(node.attributes.g,node.attributes.p)

					break;

				case "P":

					_global.channelInvite.open({

						id: node.attributes.g,

						text: Lang.fv("chat.invite_channel",{u: node.attributes.u,t: node.firstChild.nodeValue.toString()}),

						yesAct: {obj: _global.channelMng,method: "open",args: [node.attributes.g,node.attributes.p]},

						noAct:	{obj: _global.mainCnx,method: "cmd",args: ["refuse",{u: node.attributes.u,g: node.attributes.g}]}

					});

					

					/*

					_global.topDesktop.addBox(new box.Alert({

						text: Lang.fv("chat.invite_channel",{u: node.attributes.u,t: node.firstChild.nodeValue.toString()}),

						butActList: [

							{name: "Oui",action: },

							{name: "Non",action: }

						]

					}));

					*/

					

					break;

				case "R":

					_global.mainCnx.cmd("refuse",{u: node.attributes.u,g: node.attributes.g});

					break;

			}

		}

	}

	

	static function onXPReceived(node){

		_global.me.xp += Number(node.attributes.a);

	}

	

	static function onXPStolen(node){

		_global.me.xp -= Number(node.attributes.a);

	}

	

	static function onAdminSend(node){

		var cmd = node.firstChild.nodeName;

		switch(cmd){

			// TODO

			default:

				break;

		}

	}

	

	static function onNewMail(node){

		_global.fileMng.callListeners(_global.fileMng.inbox,"refresh");

		_global.me.digitalScreen.unSleep(2);

		if(_global.userPref.getPref("dsp_newmail_alert")){

			_global.openAlert(Lang.fv("mail.newmail",{f: node.attributes.from,s: node.firstChild.nodeValue.toString()}),Lang.fv("mail.youvegotmail"));

		}

	}

	

	static function onNewForumMsg(node){

		_global.me.digitalScreen.unSleep(1);

	}

	

	static function onNewUserLog(node){

		_global.me.addUserLog({time: node.attributes.date,type: node.attributes.type,content: node.firstChild.nodeValue.toString()});

	}

	

	static function onNewSiteLog(node){

		_global.me.addSiteLog({time: node.attributes.date,type: node.attributes.type,content: node.firstChild.nodeValue.toString()});

	}

	

	static function onActivateFeature(node){

		switch(node.attributes.command_name){

			// KikoozUpdate

			case "ku":

				_global.me.kikooz = Number(node.firstChild.nodeValue.toString());

				break;

			case "di":

				var arr = new Array();

				for(var c=node.firstChild;c.nodeType>0;c=c.nextSibling){

					arr.push({doc: c.firstChild,pos: {w: Number(c.attributes.w),h: Number(c.attributes.h)},styleName: c.attributes.s,flBackground: (c.attributes.b=="1"),flDocumentFit: (c.attributes.f=="1"||c.attributes.f==undefined),title: c.attributes.t});

				}

				_global.docOnIdent.go(arr);

				break;

			default:

				break;

		}

	}

	

	static function onChangeBg(node){

		// TODO (attention, ici il ne faut pas le changer tout de suite, mais après random() secondes

	}

	

	

	static function onMute(node){

		if(node.attributes.u == _global.me.name){

			_global.me.flMuted = true;

			_global.me.endMute = node.attributes.mt;

		}

	}

	

	static function onEndMute(node){

		if(node.attributes.u == _global.me.name){

			_global.me.flMuted = false;

			_global.me.endMute = undefined;

		}

	}

	

	static function onClose(){

		if(_global.cnxAlertBox == undefined){

			_global.cnxAlertBox = new box.Alert({title: Lang.fv("please_wait"),text: Lang.fv("connecting"),butActList: []});

			_global.topDesktop.addBox(_global.cnxAlertBox);

		}

		_global.me.logged = false;

		_global.desktop.cleanIcon();

	}

	

	static function onConnect(){

		_global.me.logged = false;

		_global.desktop.cleanIcon();

	}

	

	static function onIp(node){

		_global.debug("c onIp qui est appelé !!");

		if(_global.cnxAlertBox != undefined){

			_global.cnxAlertBox.close();

			delete _global.cnxAlertBox;

		}



		if( _global.sidAutoInit ){

			//_global.mainCnx.ident();

			return;

		}

		

		if((_global.mainCnx.login == undefined || _global.mainCnx.pass == undefined) && !_global.mainCnx.haveBeenLogged){

			_global.uniqWinMng.open("login");

		}

	}

	

	static function onKick(node){

		if(node.attributes.k != undefined){

			_global.openErrorAlert(Lang.fv("error.kick",{e: Lang.fv("error.cbee."+node.attributes.k)}));

		}

	}

	

	static function onBan(node){

		if(node.attributes.k != undefined){

			_global.openErrorAlert(Lang.fv("error.ban",{e: Lang.fv("error.cbee."+node.attributes.k)}));

		}		

	}



  static function onModeratorCalled(node){

    if(_global.channelMng.isIn(node.attributes.g)){

      return false;

    }

    _global.topDesktop.addBox(new box.Alert({

      text: Lang.fv("chat.moderator_called",{f: _global.channelNames[ node.attributes.g ],g: node.attributes.g,u: node.attributes.u}),

      butActList: [

         {name: "Oui",action: {obj: _global.channelMng,method: "open",args: node.attributes.g}},

         {name: "Non"},

         {name: "Totoche",action: {obj: listener.main,method: "mute",args: node.attributes.u}}

      ]

    }));

  }



  static function mute(user){

		var t = _global.servTime.getTime() + 10 * 60 * 1000; // time + 10 minutes

		var end = Lang.formatDateTime(t,"prog_server");

    

    _global.mainCnx.cmd("mute",{u: user,e: end});

  }

  

	static function onSessInit(success,vars){

		

		if(!success || vars.sid == undefined || vars.length == 0){

			_global.openErrorAlert(Lang.fv("error.session_init"));

		}

		_root.sid = vars.sid;

		

		// TODO: voir si on peut l'ajouter en header, afin de rendre plus chiant l'execution des requette HTTP depuis un browser

		HTTP.defaultParams.sid = _root.sid;

		

		_global.userPref.loadPrefDef();

		

		_global.debugLC.connect("fp_debug_"+_root.sid);

		_global.cbeeMng.connect("fp_cbeeMng_"+_root.sid);

		

		_global.mainCnx = _global.cbeeMng.addCnx(_global.cbeePort.frutichat,true);

		_global.me.status.setCnx(_global.mainCnx);

		_global.mainCnx.addListener("ident",listener.main,"onIdent");

		_global.mainCnx.addListener("onClose",listener.main,"onClose");

		_global.mainCnx.addListener("onConnect",listener.main,"onConnect");

		_global.mainCnx.addListener("inviteChat",listener.main,"onInviteChat");

		_global.mainCnx.addListener("invite",listener.main,"onInvite");

		_global.mainCnx.addListener("adminSend",listener.main,"onAdminSend");

		

		_global.mainCnx.addListener("newmail",listener.main,"onNewMail");

		_global.mainCnx.addListener("newforummsg",listener.main,"onNewForumMsg");

		_global.mainCnx.addListener("newuserlog",listener.main,"onNewUserLog");

		_global.mainCnx.addListener("newsitelog",listener.main,"onNewSiteLog");

		_global.mainCnx.addListener("activatefeat",listener.main,"onActivateFeature");

		_global.mainCnx.addListener("changebg",listener.main,"onChangeBg");

		

		_global.mainCnx.addListener("xpstolen",listener.main,"onXPStolen");

		_global.mainCnx.addListener("xpreceived",listener.main,"onXPReceived");

		

		_global.mainCnx.addListener("onmute",listener.main,"onMute");

		_global.mainCnx.addListener("endmute",listener.main,"onEndMute");

		

		_global.mainCnx.addListener("kick",listener.main,"onKick");

		_global.mainCnx.addListener("ban",listener.main,"onBan");	

    _global.mainCnx.addListener("moderatorcalled",listener.main,"onModeratorCalled");

		



		//*

		_global.mainCnx.addListener("ip",listener.main,"onIp");

		/*/

		_global.mainCnx.addListener("ip",listener.main,"onIpDebug");

		//*/

	}

	

	static function onCBeeService(success,node){

		if(!success){

			_global.openErrorAlert(Lang.fv("error.host_unreachable"));

		}else{

			node = node.firstChild;

			if(node.attributes.host != undefined){

				_global.cbeeHost = node.attributes.host;

			}

			for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){

				if(n.nodeName != "service") continue;

				_global.cbeePort[n.attributes.name] = Number(n.attributes.port);

			}



			if( _global.sidAutoInit ){

				listener.main.onSessInit(true,{sid: _root.sid});

			}

		}

	}

	

	static function onLang(success,node){

		if(!success){

			//_global.openErrorAlert(Lang.fv("error.host_unreachable"));

		}else{

			node = node.firstChild;

			for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){

				

				// countries

				if(n.nodeName == "ct"){

					_global.langText.countries = new Object();

					for(var m=n.firstChild;m.nodeType>0;m=m.nextSibling){

						if(m.nodeName!="c") continue;

						_global.langText.countries[m.attributes.c] = {name: m.attributes.n,regionName: m.attributes.tn,displayCode: (m.attributes.d=="1")}

						

						var arr = new Object();

						var nb = 0;

						// List all regions

						for(var r=m.lastChild;r.nodeType>0;r=r.previousSibling){

							if(r.nodeName != "r") continue;

							arr[r.attributes.c] = r.firstChild.nodeValue.toString();

							nb++;

						}

						

						_global.langText.countries[m.attributes.c].region = arr;

						_global.langText.countries[m.attributes.c].regionNb = nb;

					}

				}else if(n.nodeName == "gn"){

					_global.langText.disc_to_game = new Object();

					

					for(var m=n.firstChild;m.nodeType>0;m=m.nextSibling){

						if(m.nodeName!="g") continue;

						_global.langText.disc_to_game[m.attributes.d] = m.firstChild.nodeValue.toString();

					}

				

				// TipDoc

				}else if(n.nodeName == "td"){

					_global.langText.tip_doc = new Object();

					

					for(var m=n.firstChild;m.nodeType>0;m=m.nextSibling){

						if(m.nodeName!="d") continue;

						

						

						

						switch(m.attributes.t){

							case "h":

								_global.langText.tip_doc[m.attributes.i] = {

									html: m.firstChild.toString(),

									type: "html"

								}

								break;

							case "d":

								_global.langText.tip_doc[m.attributes.i] = {

									html: m.firstChild,

									type: "doc"

								}

								break;

							case "t":

							default:

								_global.langText.tip_doc[m.attributes.i] = {

									text: m.firstChild.nodeValue.toString(),

									type: "text"

								}

								break;

						}

						

						

					}

					

				

				// Misc. extern values

				}else if(n.nodeName == "ex"){

					_global.langText.ext = new Object();

					

					for(var m=n.firstChild;m.nodeType>0;m=m.nextSibling){

						if(m.nodeName!="c" || m.attributes.n == undefined) continue;

						

						if(m.firstChild.nodeType == 3){

							_global.langText.ext[m.attributes.n] = m.firstChild.nodeValue.toString();

						}else{

							_global.langText.ext[m.attributes.n] = m.firstChild.toString();

						}

						

					}

				}

				

				

			}

		}

	

	}

	

	

/*

	static function onIpDebug(node){

		

		if(_global.cnxAlertBox != undefined){

			_global.cnxAlertBox.close();

			delete _global.cnxAlertBox;

		}



		if( _global.sidAutoInit ){

			//_global.mainCnx.ident();

			return;

		}

		

		if((_global.mainCnx.login != undefined && _global.mainCnx.pass != undefined) || _global.mainCnx.haveBeenLogged) return false;

		

		_global.mainCnx.ip = node.firstChild.nodeValue.toString();

		if(Key.isDown(Key.SPACE)){

			listener.main.onIp(node);

		}else{

			_global.debug("IP inconnue");

			listener.main.onIp(node);

			// _global.mainCnx.addListener("ip",listener.main,"onIp");

		}

	}

//*/	

//{

}

/* A recoder n'importe ou mais pas là

_global.fWarningFlood = 0;

_global.onFlood = function(){

	_global.fWarningFlood++;

	if(fWarningFlood > 5) fKillAll("flood");

};

_global.fKillAll = function(str){

	// TODO: Envoyer str au serveur

};

*/



