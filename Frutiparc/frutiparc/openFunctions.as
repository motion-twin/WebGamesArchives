_global.openForum = function(){
	// TODO: écrire ce test plus proprement
	for(var i=0;i<_global.slotList.arr.length;i++){
		if(_global.slotList.arr[i] instanceof FPForumSlot){
			_global.slotList.activate(slotList.arr[i]);
			return;
		}
	}
	_global.slotList.addSlot(new FPForumSlot(),true);
};

_global.openFrusion = function(){
	// TODO: écrire ce test plus proprement
	for(var i=0;i<_global.slotList.arr.length;i++){
		if(_global.slotList.arr[i] instanceof FPFrusionSlot){
			_global.slotList.activate(slotList.arr[i]);
			return;
		}
	}
	_global.slotList.addSlot(new FPFrusionSlot(),true);
};

_global.openClub = function(s){
	if(s != undefined){
		if(s.indexOf('?') > 0){
			getURL("javascript:fp_openPopup('/club/"+s+"&sid="+_root.sid+"','Club','width=700,height=500,resizable=yes,scrollbars=yes')","");
		}else{
			getURL("javascript:fp_openPopup('/club/"+s+"?sid="+_root.sid+"','Club','width=700,height=500,resizable=yes,scrollbars=yes')","");
		}
	}else{
		getURL("javascript:fp_openPopup('/club/?sid="+_root.sid+"','Club','width=700,height=500,resizable=yes,scrollbars=yes')","");
	}
};

_global.openAlert = function(str,title){
	_global.topDesktop.addBox(new box.Alert({text: str,title: title}));
};

_global.openErrorAlert = function(str){
	_global.openAlert(str,"Erreur");
};

_global.openInbox = function(){
	if(_global.fileMng.inbox != ""){
		_global.explorerMng.open(_global.fileMng.inbox);
	}
};

_global.openGame = function(){
	if(_global.fileMng.disccollector != ""){
		_global.explorerMng.open(_global.fileMng.disccollector);
	}
};

_global.onIdentComplete = function(){
	_global.uniqWinMng["_"+"login"].close();
};

_global.openBlog = function( user ){
	if( user != undefined ){
		getUrl("http://"+user+".frutiparc.com/","_blank");
	}else{
		getUrl("http://blogs.frutiparc.com/","_blank");
	}
};

_global.logout = function(){
	getUrl("/light/logout?sid="+_root.sid,"_self");
};

_global.golight = function(){
	getUrl("/light/?sid="+_root.sid,"_self");
};

///////////

_global.uniqWinMng = new Object();
_global.uniqWinMng.open = function(type,slot,args){
	if(slot == undefined) slot = _global.desktop;

	if(this["_"+type] != undefined){
		this["_"+type].activate();
	}else{
		var b;
		switch(type){
			case "userLog":
				b = new box.UserLog(args);
				break;
			case "siteLog":
				b = new box.SiteLog(args);
				break;
			case "kikoozLog":
				b = new box.KikoozLog(args);
				break;
			case "roomList":
				b = new box.RoomList(args);
				break;
			case "pref":
				b = new box.Pref(args);
				break;
			case "score":
				b = new box.Score(args);
				break;
			case "help":
				b = new box.Help(args);
				break;
			case "shop":
				b = new box.Shop(args);
				break;
			case "confirm":
				b = new box.ConfirmMail(args);
				break;
			case "login":
				b = new box.Login(args);
				break;
			case "editinfo":
				b = new box.EditInfo(args);
				break;
			case "kikooz":
				b = new box.Kikooz(args);
				break;
			case "editbouille":
				b = new box.EditFrutibouille(args);
				break;
      case "search":
        b = new box.Search();
        break;
		}
		slot.addBox(b);
	}
};
ASSetPropFlags(_global.uniqWinMng, "open", 1);


_global.uniqWinMng.setBox = function(t,box){
	this["_"+t] = box;
};
ASSetPropFlags(_global.uniqWinMng, "setBox", 1);

_global.uniqWinMng.unsetBox = function(t){
	delete this["_"+t];
};
ASSetPropFlags(_global.uniqWinMng, "unsetBox", 1);

_global.uniqWinMng.displayHelp = function(o){
	if(this["_"+"help"] == undefined){
		this.open("help",undefined,{openContent: o});
	}else{
		this["_"+"help"].getContentObj(o);
	}
}
ASSetPropFlags(_global.uniqWinMng, "displayHelp", 1);

_global.uniqWinMng.displayRanking = function(o){
	if(this["_"+"score"] == undefined){
		this.open("score",undefined,{rankingPosToDisplay: o});
	}else{
		this["_"+"score"].displayRankingPos(o);
	}
}
ASSetPropFlags(_global.uniqWinMng, "displayRanking", 1);

_global.uniqWinMng.displayShop = function(id){
  id = Number(id);
  
	if(this["_"+"shop"] == undefined){
		this.open("shop",undefined,{displayedPack: id});
	}else{
		this["_"+"shop"].displayPack(id);
	}
}
ASSetPropFlags(_global.uniqWinMng, "displayShop", 1);
//////////

_global.chatMng = new Object();
_global.chatMng.open = function(slot,usr,grp,passwd){
	var b = this["_"+usr];

	if(usr.toLowerCase() == Lang.fv("help.name").toLowerCase()){
		_global.uniqWinMng.open("help",slot);
	}else{
		if(b == undefined){
			_global.debug("new box.Chat("+usr+","+grp+")");
			var b = new box.Chat({user: usr,group: grp,passwd: passwd,destSlot: slot});
			this["_"+usr] = b;
			_global.trashSlot.addBox(b);
			return true;
		}else if(grp != undefined && passwd != undefined){
			_global.debug("User: "+usr+", switchToGroup("+grp+")");
			b.switchToGroup(grp,passwd);
		}
		if(b.slot != slot && slot != _global.trashSlot){
			_global.debug("User: "+usr+", move (from chatMng)");
			b.move(slot);
		}
	}
	b.activate();
	return false;
};
ASSetPropFlags(_global.chatMng, "open", 1);

_global.chatMng.setBox = function(usr,box){
	_global.debug("Define box for "+usr);
	this["_"+usr] = box;
};
ASSetPropFlags(_global.chatMng, "setBox", 1);

_global.chatMng.unsetBox = function(usr){
	_global.debug("Undefine box for "+usr);
	delete this["_"+usr];
};
ASSetPropFlags(_global.chatMng, "unsetBox", 1);

_global.chatMng.listAll = function(){
	var r =  "";
	for(var n in this){
		r += n+"["+this[n].mode+"]["+this[n].slot.title+"]["+(this[n].slot == _global.desktop)+"]["+(this[n].slot == _global.trashSlot)+"]\n";
	}
	return r;
};
ASSetPropFlags(_global.chatMng, "listAll", 1);

_global.chatMng.onChangeWallpaper = function(url,alpha){
   for(var n in this){
      this[n].onChangeWallpaper(url,alpha);
   }
}
ASSetPropFlags(_global.chatMng, "onChangeWallpaper", 1);

//////////

_global.frutizInfMng = new Object();
_global.frutizInfMng.open = function(user,slot,group){
	if(slot == undefined) slot = _global.desktop;
	
	if(this["_"+user] != undefined){
		this["_"+user].activate();
	}else{
		var b = new box.Frutiz({user: user,group: group});
		this["_"+user] = b;
		slot.addBox(b);
	}
};
ASSetPropFlags(_global.frutizInfMng, "open", 1);

_global.frutizInfMng.setBox = function(user,box){
	if(this["_"+user] != undefined) this["_"+user].close();
	this["_"+user] = box;
};
ASSetPropFlags(_global.frutizInfMng, "setBox", 1);

_global.frutizInfMng.unsetBox = function(user){
	delete this["_"+user];
};
ASSetPropFlags(_global.frutizInfMng, "unsetBox", 1);


//////////

_global.channelMng = new Array();
_global.channelMng.open = function(grp,passwd){
	// TODO: virer ça :
	clearInterval(_global.IntervalALaCon);
	if(this.pushUniq(grp)) _global.desktop.addBox(new box.Chat({group: grp,passwd: passwd}));
};

_global.channelMng.create = function(topic){
	_global.desktop.addBox(new box.Chat({topic: topic}));
};
ASSetPropFlags(_global.channelMng, "create", 1);

//////////

_global.explorerMng = new Array();
_global.explorerMng.open = function(uid){
	if(this.indexOf(uid) < 0) _global.desktop.addBox(new box.Explorer({uid: uid}));
};

//////////

_global.fileViewMng = new Object();
_global.fileViewMng.getBox = function(uid){
	return this["_"+uid];
};
ASSetPropFlags(_global.fileViewMng, "getBox", 1);

_global.fileViewMng.setBox = function(uid,box){
	if(this["_"+uid] != undefined) this["_"+uid].close();
	this["_"+uid] = box;
};
ASSetPropFlags(_global.fileViewMng, "setBox", 1);

_global.fileViewMng.unsetBox = function(uid){
	delete this["_"+uid];
};
ASSetPropFlags(_global.fileViewMng, "unsetBox", 1);

//////////

_global.createDragIcon = function(ico,x,y){
	_global.dragIconOrig = ico;
	var mcName = "dragIcon"+FEString.uniqId();
	if(ico.type == "disc"){
		_global.main.attachMovie("fileIconFull",mcName,Depths.dragIcon,ico);
	}else{
		_global.main.attachMovie("fileIconStandard",mcName,Depths.dragIcon,ico);
	}
	_global.dragIcon = main[mcName];
	_global.dragIcon.startDrag();
	
	if(x != undefined && y != undefined){
		_global.dragIcon._x = _xmouse - x;
		_global.dragIcon._y = _ymouse - y;
	}else{
		_global.dragIcon._x = _xmouse;
		_global.dragIcon._y = _ymouse;
	}
	
	Mouse.addListener(listener.dragIconMouse);
	
	_global.dragListener.callListeners("start",ico.type,ico);
	_global.dragListener.callListeners("start","alltype",ico);
};

_global.deleteDragIcon = function(){
	if(_global.dragIcon != undefined){

		if(_global.dragIconOrig.comeFromFrusion){
			delete _global.dragIconOrig.comeFromFrusion;
			_global.fileMng.frusionDiscStopDrag();
		}
	
		_global.dragListener.callListeners("stop",dragIcon.type,dragIcon);
		_global.dragListener.callListeners("stop","alltype",dragIcon);

		_global.dragIcon.removeMovieClip();
		Mouse.removeListener(listener.dragIconMouse);
		_global.dragIconOrig.onEndDrag();
		_global.dragIconOrig = undefined;
	}
};


//////////

_global.dragListener = new Object();
_global.dragListener.arr = new Object();
_global.dragListener.addListener = function(type,list){
	if(this.arr[type] == undefined){
		this.arr[type] = new Array();
	}
	this.arr[type].push(list);
};
_global.dragListener.removeListener = function(type,list){
	if(this.arr[type] == undefined){
		return false;
	}
	for(var i=0;i<this.arr[type].length;i++){
		var o = this.arr[type][i];
		if(o.obj == list.obj && o.startMethod == list.startMethod && o.stopMethod == list.stopMethod){
			this.arr[type].splice(i);
			return true;
		}
	}
	return false;
};
_global.dragListener.callListeners = function(a,type,obj){
	if(this.arr[type] == undefined){
		return false;
	}
	if(a == "start"){
		for(var i=0;i<this.arr[type].length;i++){
			var o = this.arr[type][i];
			o.obj[o.startMethod](obj);
		} 
	}else if(a == "stop"){
		for(var i=0;i<this.arr[type].length;i++){
			var o = this.arr[type][i];
			o.obj[o.stopMethod](obj);
		}
	}
	return true;
};

//////////

_global.onFileClick = function(obj){
	//_global.debug("On clique sur "+obj.uid+" [type: "+obj.type+"] [name: "+obj.name+"] [DeleteIsDown: "+Key.isDown(Key.DELETEKEY)+"]");
	if(Key.isDown(Key.DELETEKEY)){
		_global.debug("parent: "+obj.parent+", recyclebin: "+_global.fileMng.recyclebin);
		if(obj.parent == _global.fileMng.recyclebin){
			// nthg to do ?
		}else{
			_global.fileMng.moveToRecycleBin(obj.uid);
		}
		return;
	}
	switch(obj.type){
		case "folder":
			explorerMng.open(objq.uid);
			break;
		case "contact":
			if(obj.name.indexOf("@") < 0){
				if(obj.name.toLowerCase() == Lang.fv("help.name").toLowerCase()){
					_global.chatNow(obj.name);
				}else{
					_global.frutizInfMng.open(obj.name,_global.desktop);
				}
			}else{
				_global.openMail(obj.name);
			}
			break;
		case "disc":
			/*
			var b = _global.fileViewMng.getBox(obj.uid);
			if(b == undefined){
				_global.desktop.addBox(new box.GameInfo(obj));
			}else{
				b.activate();
			}
			*/
			break;
		case "mail":
			var b = _global.fileViewMng.getBox(obj.uid);
			if(b == undefined){
				_global.desktop.addBox(new box.ViewMail(obj));
			}else{
				b.activate();
			}
			break;
		case "text":
			//_global.desktop.addBox(new box.ViewText(obj));
			break;
		case "link":
			if(typeof(obj.desc[1]) == "string"){
				eval(obj.desc[1])(obj);
			}else{
				obj.desc[1][obj.desc[2]](obj.desc[3]);
			}
			break;
    case "url":
			if(obj.desc[2] != undefined){
				getURL(obj.desc[1],obj.desc[2]);
			}else{
	      getURL(obj.desc[1],"");
			}
      break;
	}
};

_global.chatNow = function(user){
	_global.chatMng.open(_global.desktop,user);	
};

_global.getFileContextMenu = function(obj){
	var r = new ContextMenu();
	r.hideBuiltInItems();
	/*
	r.onSelect = function(mc,me){
		_global.debug("onSelect, by mc "+mc);
	};
	*/
	
	switch(obj.type){
		case "contact":
			if(obj.name == _global.me.name){
				r.customItems.push(new FECMItem(Lang.fv("context_menu.contact.my_info"),{obj: _global.frutizInfMng,method: "open",args: obj.name}));
				r.customItems.push(new FECMItem(Lang.fv("context_menu.contact.edit_my_info"),{obj: _global.uniqWinMng,method: "open",args: "editinfo"}));
			}else{
				if(obj.name.indexOf("@") < 0){
					r.customItems.push(new FECMItem(Lang.fv("context_menu.contact.chat_now"),{obj: _global,method: "chatNow",args: obj.name}));
				}
				r.customItems.push(new FECMItem(Lang.fv("context_menu.contact.email"),{obj: _global,method: "openMail",args: obj.desc[0]}));
				if(obj.name.indexOf("@") < 0){
					r.customItems.push(new FECMItem(Lang.fv("context_menu.contact.view_info"),{obj: _global.frutizInfMng,method: "open",args: obj.name}));
					r.customItems.push(new FECMItem(Lang.fv("context_menu.contact.add_to_contact"),{obj: _global.fileMng,method: "addUserToContact",args: obj.name}));
				}
			}
			break;
		case "folder":
			r.customItems.push(new FECMItem(Lang.fv("context_menu.folder.open_new_window"),{obj: _global.explorerMng,method: "open",args: obj.uid}));
			if( obj.desc[1] == "recyclebin" ){
				r.customItems.push(new FECMItem(Lang.fv("context_menu.folder.empty_recyclebin"),{obj: _global.fileMng,method: "emptyRecycleBin"}));
			}else if( obj.desc[1] == "inbox" ){
				r.customItems.push(new FECMItem(Lang.fv("context_menu.folder.inbox_delete_read"),{obj: _global.fileMng,method: "deleteReadMail",args: obj.uid}));
				r.customItems.push(new FECMItem(Lang.fv("context_menu.folder.inbox_delete_all"),{obj: _global.fileMng,method: "deleteMail",args: obj.uid}));
			}else if( obj.desc[1] == "outbox" ){
				r.customItems.push(new FECMItem(Lang.fv("context_menu.folder.clean_outbox"),{obj: _global.fileMng,method: "deleteMail",args: obj.uid}));
			}else if( obj.desc[1] == "blackbox" ){
				r.customItems.push(new FECMItem(Lang.fv("context_menu.folder.clean_blackbox"),{obj: _global.fileMng,method: "deleteMail",args: obj.uid}));
			}
			break;
		case "link":
			if(obj.uid == "linkForum"){
				// TODO : open in new window
			}else if(obj.uid == "linkShop"){
				// TODO: obtain kikooz
			}
	}
	
	r.customItems.push(new FECMItem(Lang.fv("context_menu.help"),{obj: _global.uniqWinMng,method: "open",args: "help"},true));
	
	return r;
};

_global.getWindowContextMenu = function(type,box){
	var r = new ContextMenu();
	r.hideBuiltInItems();
	
	switch(type){
		case "winChat":
			//r.customItems.push(new FECMItem("Chat OK!"));
			break;
	}

	r.customItems.push(new FECMItem(Lang.fv("context_menu.help"),{obj: _global.uniqWinMng,method: "open",args: "help"},true));
	
	return r;

}

/*
Rappel des modes :

M = Mode
Def = Action par défaut
except = Condition pour l'exception (sauf si)
Alors = Action si l'exception est validée (alors)

A = Accepter
P = Demander (prompt)
R = Refuser

+---+-----+-------------+-------+
| M | Def |    except   | Alors |
+---+-----+-------------+-------+
| 0 |  A  |      -      |   -   |
| 1 |  A  |  blackList  |   R   |
| 2 |  A  |  blackList  |   P   |
| 3 |  P  |      -      |   -   |
| 4 |  P  |  blackList  |   R   |
| 5 |  P  | contactList |   A   |
| 6 |  R  |      -      |   -   |
| 7 |  R  | contactList |   A   |
| 8 |  R  | contactList |   P   |
+---+-----+-------------+-------+

*/
_global.chooseInviteBehavior = function(pref,user){
	// Check if the user is in contactList or blackList if necessary
	if(pref == 1 || pref == 2 || pref == 4){
		var except = _global.myBlackListCache.isIn(user);
	}
	if(pref == 5 || pref == 7 || pref == 8){
		var except = _global.myContactListCache.isIn(user);
	}
	
	switch(pref){
		case 0:
			return "A";
		case 1:
			return except?"R":"A";
		case 2:
			return except?"P":"A";
		case 3:
			return "P";
		case 4:
			return except?"R":"P";
		case 5:
			return except?"A":"P";
		case 6:
			return "R";
		case 7:
			return except?"A":"R";
		case 8:
			return except?"P":"R";
		default:
			return "A";
	}
}

_global.sendDebugContent = function(){
	var txt = "Version FP2-Beta: "+_global.fp_beta_ver+"\n";
	txt += "Connecté en tant que: "+_global.me.name+"\n";
	for(var i=0;i<box.Debug.allBox.length;i++){
		var b = box.Debug.allBox[i];
	
		txt += "Fenêtre '"+b.title+"' :\n-------\n";
		txt += b.content.join("\n");		
	}

	var loader = new HTTP("h/send_debug",{txt: txt},{type: "loadVars",obj: _global,method: "onSendDebugContent"},"POST");
};

_global.onSendDebugContent = function(success,vars){
	if(success){
		_global.openAlert("Debug envoyé, merci ! :)");
	}else{
		_global.openErrorAlert("Apparement même ça ça marche pas... grrr :(");
	}
};

_global.moveDebugToDesktop = function(){
	//for(var i=0;i<box.Debug.allBox.length;i++){
	//	box.Debug.allBox[i].move(_global.desktop);
	//}
	_global.stdDebugBox.move(_global.desktop);
};

_global.listChatBox = function(){
	_global.openAlert(_global.chatMng.listAll());
};

_global.onMailAddrClick = function(addr){
	var o = FEString.mailParse(addr);
	var o = o[0];
	var mail_name = o.n==undefined?o.m:o.n;
	
	if(mail_name.length > 30){
		win_title = mail_name.substr(0,27)+"...";
	}else{
		win_title = mail_name;
	}
	
	if(FEString.endsWith(o.m,"@frutiparc.com")){
		_global.frutizInfMng.open(mail_name);
	}else{
		_global.topDesktop.addBox(new box.Alert({text: Lang.fv("mail.on_mail_addr_click",{n: mail_name,m: o.m,a: addr}),title: win_title,butActList: [
			{ name: Lang.fv("mail.add_contact"), action: {obj: _global.fileMng,method: "addMailToContact",args: addr} },
			{ name: Lang.fv("mail.send_mail"), action: {obj: _global,method: "openMail",args: addr} }
		]}));
	}
};

_global.openMail = function(to){
	_global.desktop.addBox(new box.Mail({to: to}));
};

_global.docOnIdent = new Object();
_global.docOnIdent.go = function(arr){
	this.arr = arr;
	if(arr.length){
		this.current = 0;
		this.open();
		
	}
};
_global.docOnIdent.next = function(){
	this.current++;
	if(this.current >= this.arr.length){
		// pas sur qu'il y a kkchose à mettre ici	
	}else{
		this.open();
	}
};

_global.docOnIdent.open = function(){
	_global.desktop.addBox(new box.DocOnIdent(this.arr[this.current]));
}
