/*
Frutiparc 2 File Manager
$Id: FPFileMng.as,v 1.47 2005/08/04 16:06:03  Exp $

Class: FPFileMng
*/
class FPFileMng extends FFileMng{//}
	
	var contactListeners:Array;
	var listeners:Object;
	var unreadMail:Number;
	
	var desktopLoader:HTTP;
	var contactLoader:HTTP;
	var blackListLoader:HTTP;
	
	var discInFrusion:Object;
	var flFrusionOn:Boolean = false;
	
	function FPFileMng(){
		super();

		this.contactListeners = new Array();
		this.listeners= new Object();
	}
	
	function init(){
		super.init();
		this.loadBlackList();
	}

	/*-----------------------------------------------------------------------
		Function: onLoadTree(success,data)
		� documenter
	 ------------------------------------------------------------------------*/	
	function onLoadTree(success,data){
		if(super.onLoadTree(success,data)){
			this.unreadMail = Number(data.firstChild.attributes.m);
			_global.debug("You have "+unreadMail+" unread mail !");
			
			if(this.unreadMail > 0){
				_global.me.digitalScreen.unSleep(2);
			}
			
			this.desktopLoader = new HTTP("ff/ls",{},{type: "xml",obj: this,method: "onLoadDesktop"});
			this.contactLoader = new HTTP("ff/ls",{uid: this.mycontact,r: 1,s: 1},{type: "xml",obj: this,method: "onLoadContact"});
		}else{
			_global.openErrorAler(Lang.fv("fileMng.loading_tree"));
		}
	}
	
	/*-----------------------------------------------------------------------
		Function: wantContact(obj,method)
		� documenter
	 ------------------------------------------------------------------------*/	
	function wantContact(obj,method){
		this.contactListeners.push({obj: obj,method: method});
	}
	
	/*-----------------------------------------------------------------------
		Function: refreshContact()
		� documenter
	 ------------------------------------------------------------------------*/		
	function refreshContact(){
		this.contactLoader = new HTTP("ff/ls",{uid: mycontact,r: 1},{type: "xml",obj: this,method: "onLoadContact"});
	}
	
	/*-----------------------------------------------------------------------
		Function: onLoadContact(success,d)
		� documenter
	 ------------------------------------------------------------------------*/		
	function onLoadContact(success,d){
		if(!success){
			_global.debug("Error loading contact");
			_global.openErrorAler(Lang.fv("fileMng.loading_contact"));
			return false;
		}
		
		_global.onIdentComplete();
		
		var contactList = analyseXml(d.lastChild);
		for(var i=0;i<contactListeners.length;i++){
			this.contactListeners[i].obj[this.contactListeners[i].method](contactList);
		}
	}
	
	/*-----------------------------------------------------------------------
		Function: loadBlackList()
		� documenter
	 ------------------------------------------------------------------------*/		
	function loadBlackList(){
		this.blackListLoader = new HTTP("ff/ls",{uid: "blacklist"},{type: "xml",obj: this,method: "onLoadBlackList"});
	}
	
	/*-----------------------------------------------------------------------
		Function: onLoadContact(success,d)
		� documenter
	 ------------------------------------------------------------------------*/		
	function onLoadBlackList(success,d){
		if(!success){
			_global.debug("Error loading blacklist");
			_global.openErrorAler(Lang.fv("fileMng.loading_blacklist"));
			return false;
		}
		var blackListObj = this.analyseXml(d.lastChild);
		if(_global.myBlackList == undefined){
			_global.myBlackList = new BlackList(blackListObj,{obj: _global.myBlackListCache,methodAdd: "addUser",methodRemove: "removeUser"});
		}
	}

	/*-----------------------------------------------------------------------
		Function: onLoadDesktop(success,d)
		� documenter
	 ------------------------------------------------------------------------*/		
	function onLoadDesktop(success,d){
		if(!success){
			_global.debug("Error loading desktop");
			_global.openErrorAler(Lang.fv("fileMng.loading_desktop"));
			return;
		}
		var d = d.lastChild;	
		var l = new Array();
		for(var n=d.firstChild;n.nodeType>0;n=n.nextSibling){
			if(n.nodeName == "e"){
				l.push({uid: n.attributes.u,type: n.attributes.t,size: n.attributes.s,date: n.attributes.d,access: n.attributes.a,desc: n.firstChild.nodeValue.toString().split("\r\n")});
			}else if(n.nodeName == "f"){
				var i = _global.fileMng.tree[n.attributes.u];
				l.push({uid: n.attributes.u,type: "folder",desc: [i.name,i.type]});
			}
		}
		
		l.push({type: "link",desc: [Lang.fv("forum"),"openForum"],uid: "linkForum"});
		l.push({type: "folder",uid: "blacklist",desc: ["Liste noire","blacklist"]});
		l.push({type: "link",desc: ["Les salons",_global.uniqWinMng,"open","roomList"],uid: "linkChat"});
		l.push({type: "link",desc: ["Mon historique",_global.uniqWinMng,"open","userLog"],uid: "linkHisto"});
		l.push({type: "link",desc: ["Pr�f�rences",_global.uniqWinMng,"open","pref"],uid: "linkPreference"});
		l.push({type: "link",desc: ["Scores",_global.uniqWinMng,"open","score"],uid: "linkScore"});
		l.push({type: "link",desc: ["Boutique",_global.uniqWinMng,"open","shop"],uid: "linkShop"});
		l.push({type: "link",desc: ["Frutiblogs",_global,"openBlog"],uid: "linkBlogs"});
		l.push({type: "link",desc: ["Club",_global,"openClub"],uid: "linkClub"});

		_global.desktop.setIconList(l);
	}

	/*-----------------------------------------------------------------------
		Function: getName(t,desc)
		� documenter
	 ------------------------------------------------------------------------*/		
	function getName(t,desc){
		switch(t){
			case "mail":
				return desc[1];
				break;
			case "contact":
				if(FEString.endsWith(desc[0],"@frutiparc.com")){
					return desc[0].substr(0,desc[0].length-14);
				}else{
					return desc[0];
				}
				break;
			case "folder":
			default:
				return desc[0];
				break;
		}
	}
	
	/*-----------------------------------------------------------------------
		Function: addListener(uid,obj)
		� documenter
	 ------------------------------------------------------------------------*/		
	function addListener(uid,obj){
		if(listeners[uid] == undefined){
			listeners[uid] = new Array();
		}
		listeners[uid].pushUniq(obj);
	}
	
	/*-----------------------------------------------------------------------
		Function: removeListener(uid,obj)
		� documenter
	 ------------------------------------------------------------------------*/		
	function removeListener(uid,obj){
		listeners[uid].rm(obj);
	}
	
	/*-----------------------------------------------------------------------
		Function: callListeners(folder,action,file)
		� documenter
	 ------------------------------------------------------------------------*/		
	function callListeners(folder,action,file){
		var arr = listeners[folder];

		for(var i=0;i<arr.length;i++){
			if(typeof(file) == "object"){
				var info = arr[i][action]( FEObject.clone(file));
			}else{
				var info = arr[i][action](file);
			}
		}
		return info;
	}
	

	/*-----------------------------------------------------------------------
		Function: make
			Create a new file
		
		Parameters:
			props - Object - new file properties (type,desc)
			folder - String - folder in which the file must be created (desktop if not defined)
	
		See Also:
			<FPFileMng.copy>
	 ------------------------------------------------------------------------*/		
	function make(props,folder,extra){
		_global.debug("Attempt to create a file of type "+props.type+" with desc[0] "+props.desc[0]+" in folder "+folder);
		
		if(props.type == "contact"){
			var addr = props.desc[0];
			var p = addr.indexOf("<");
			if(p >= 0){
				props.desc[0] = addr.substring(p+1,addr.length-1);
			}
		}
		
		if(folder != undefined && folder != "root"){
			var loader = new HTTP("ff/mk",{t: props.type,d: props.desc.join("\n"),folder: folder},{type: "xml",obj: this,method: "onMake"},undefined,extra);
		}else{
			var loader = new HTTP("ff/mk",{t: props.type,d: props.desc.join("\n")},{type: "xml",obj: this,method: "onMake"},undefined,extra);
		}
	}
	
	/*-----------------------------------------------------------------------
		Function:  onMake
			Called by an HTTP object when receiving response of a make action
	 ------------------------------------------------------------------------*/		
	function onMake(success,x,extra){
		if(!success){
			_global.openErrorAlert(Lang.fv("error.host_unreachable"));
			return ;
		}
		
		x = x.lastChild;
		if(x.attributes.k != undefined){
			_global.openErrorAlert(Lang.fv("error.fileMng.make")+Lang.fv("error.http."+x.attributes.k));
			return;
		}
		if(x.attributes.f == ""){
			var newFolder = "root";
		}else{
			var newFolder = x.attributes.f;
		}
		var inf = new Object();
		inf.uid = x.attributes.u;
		inf.type = x.attributes.t;
		inf.date = x.attributes.d;
		inf.desc = x.firstChild.nodeValue.toString().split("\r\n");
		inf.parent = x.attributes.f;
		inf.pos = extra.pos;
		
		if(inf.type == "folder"){
			this.tree[inf.uid] = {name: inf.desc[0], type: inf.desc[1],tpl: x.attributes.p,childs:new Array(),parent: inf.parent};
		}
		
		this.callListeners(newFolder,"addFile", inf);
		
		_global.mainCnx.traceFlush();
	}

	/*-----------------------------------------------------------------------
		Function: move
			Move an existing file to a folder
			
		Parameters:
			file - String - File's UID
			newFolder - String - new folder's uid. If not defined, the file will be moved on desktop
			
		See Also:
			<FPFileMng.copy>
	 ------------------------------------------------------------------------*/		
	function move(file,newFolder,extra){
		//if(this.tree[newFolder] == undefined) return false;
		_global.debug("Move file "+file+" to folder "+newFolder);
		this.callListeners(file,"initMove");
		if(newFolder != undefined && newFolder != "root"){
			var loader = new HTTP("ff/mv",{f: file,folder: newFolder},{type: "xml",obj: this,method: "onMove"},undefined,extra);
		}else{
			var loader = new HTTP("ff/mv",{f: file},{type: "xml",obj: this,method: "onMove"},undefined,extra);
		}
	}
	
	function moveToRecycleBin(file){
		this.move(file,this.recyclebin);
	}
	
	/*-----------------------------------------------------------------------
		Function:  onMove
			Called by an HTTP object when receiving response of a move action
	 ------------------------------------------------------------------------*/		
	function onMove(success,x,extra){
		if(!success){
			_global.openErrorAlert(Lang.fv("error.host_unreachable"));
			return ;
		}
		
		x = x.lastChild;
		if(x.attributes.k != undefined){
			_global.openErrorAlert(Lang.fv("error.fileMng.move")+Lang.fv("error.http."+x.attributes.k));
			for(var n=x.firstChild;n.nodeType>0;n=n.nextSibling){
				if(n.nodeName != "f") continue;
				this.callListeners(n.attributes.u,"onMoveError");
			}
			return;
		}
		if(x.attributes.f == "" || x.attributes.f == undefined){
			var newFolder = "root";
		}else{
			var newFolder = x.attributes.f;
		}
		for(var n=x.firstChild;n.nodeType>0;n=n.nextSibling){
			if(n.nodeName != "f") continue;
			
			if(n.attributes.k != undefined){
				this.callListeners(n.attributes.u,"onMoveError");
				_global.openErrorAlert(Lang.fv("error.fileMng.move")+Lang.fv("error.http."+n.attributes.k));
				return;
			}else{
				if(n.attributes.p == "" || n.attributes.p == undefined){
					var oldFolder = "root";
				}else{
					var oldFolder = n.attributes.p;
				}

				var inf = new Object();
				inf.uid = n.attributes.n;
				if(x.attributes.f == "" || x.attributes.f == undefined){
					inf.parent = "root";
				}else{
					inf.parent = x.attributes.f;
				}
				inf.type = n.attributes.t;
				inf.date = n.attributes.d;
				inf.access = n.attributes.a;
				inf.desc = n.firstChild.nodeValue.toString().split("\r\n");
				inf.pos = extra.pos;

				
				if(inf.type == "folder"){
					this.tree[inf.uid].parent = newFolder;
				}
				
				this.callListeners(inf.uid,"onParentModified",inf.parent);
				this.callListeners(oldFolder,"rmUid",n.attributes.u);
				this.callListeners(newFolder,"addFile",inf);
			}
		}
		_global.mainCnx.traceFlush();
	}
	
	/*-----------------------------------------------------------------------
		Function: copy
			Copy an existing file to a folder
			
		Parameters:
			file - String - File's UID
			newFolder - String - new folder's uid. If not defined, the file will be moved on root
			
		See Also:
			<FPFileMng.move>,<FPFileMng.make>
	 ------------------------------------------------------------------------*/		
	function copy(file,newFolder,extra){
		_global.debug("Copy file "+file+" to folder "+newFolder);
		if(newFolder != undefined && newFolder != "root"){
			var loader = new HTTP("ff/cp",{f: file,folder: newFolder},{type: "xml",obj: this,method: "onCopy"},undefined,extra);
		}else{
			var loader = new HTTP("ff/cp",{f: file},{type: "xml",obj: this,method: "onCopy"},undefined,extra);
		}
	}
	
	/*-----------------------------------------------------------------------
		Function:  onCopy
			Called by an HTTP object when receiving response of a copy action
	 ------------------------------------------------------------------------*/		
	function onCopy(success,x,extra){
		if(!success){
			_global.openErrorAlert(Lang.fv("error.host_unreachable"));
			return ;
		}
		
		x = x.lastChild;
		if(x.attributes.k != undefined){
			_global.openErrorAlert(Lang.fv("error.fileMng.copy")+Lang.fv("error.http."+x.attributes.k));
			return;
		}
		if(x.attributes.f == ""){
			var newFolder = "root";
		}else{
			var newFolder = x.attributes.f;
		}
		for(var n=x.firstChild;n.nodeType>0;n=n.nextSibling){
			if(n.attributes.k != undefined){
				_global.openErrorAlert(Lang.fv("error.fileMng.copy")+Lang.fv("error.http."+n.attributes.k));
				return;
			}else{
				var inf = new Object();
				inf.uid = n.attributes.u;
				inf.parent = n.attributes.p;
				inf.type = n.attributes.t;
				inf.date = n.attributes.d;
				inf.desc = n.firstChild.nodeValue.toString().split("\r\n");
				inf.pos = extra.pos;
				this.callListeners(newFolder,"addFile", inf);
			}
		}
		_global.mainCnx.traceFlush();
	}
	
	function emptyRecycleBin(){
		_global.debug("Empty recycle bin");
		var loader = new HTTP("ff/erb",{},{type: "xml",obj: this,method: "onEmptyRecycleBin"});
	}
	
	function onEmptyRecycleBin(success,x){
		if(!success){
			_global.openErrorAlert(Lang.fv("error.host_unreachable"));
			return false;
		}
		
		x = x.lastChild;
		if(x.nodeName != 'r'){
			_global.openErrorAlert(Lang.fv("error.http.1"));
			return false;
		}
		
		if(x.attributes.k != "0"){
			_global.openErrorAlert(Lang.fv("error.fileMng.empty_recyclebin")+Lang.fv("error.http."+x.attributes.k));
			this.callListeners(this.recyclebin,"refresh");
			return false;
		}
		
		this.callListeners(this.recyclebin,"refresh");
	}
	
	function deleteMail(uid){
		_global.debug("Delete mail of folder "+uid);
		var loader = new HTTP("ff/dm",{u: uid,r: 0},null);
	}	
	
	function deleteReadMail(uid){
		_global.debug("Delete read mail of folder "+uid);
		var loader = new HTTP("ff/dm",{u: uid,r: 1},null);
	}		
	
	function addUserToContact(name){
		if(!_global.myContactListCache.isIn(name)){
			this.make({type: "contact",desc: [name+"@frutiparc.com"]},this.mycontact);
			
			// TODO: hum... mettre �a ailleurs ?
			if(!_global.main.sideList.flActive) _global.main.sideList.toggle();
		}
	}
	
	function addMailToContact(addr){
		this.make({type: "contact",desc: [addr]},this.mycontact);
			
		// TODO: hum... mettre �a ailleurs ?
		if(!_global.main.sideList.flActive) _global.main.sideList.toggle();
	}
	
	function addUserToBlackList(name){
		if(!_global.myBlackListCache.isIn(name)){
			this.make({type: "contact",desc: [name+"@frutiparc.com"]},'blacklist');
		}
	}
	
	function removeUserFromBlackList(name){
		if(_global.myBlackListCache.isIn(name)){
			var u = _global.myBlackList.getUidOfUser(name);
			if(u == undefined){
				return _global.debug("WARN: user "+name+" is in blackListCache but not in blackList...");
			}
			
			this.moveToRecycleBin(u);
		}
	}
	
	// 
	function accessFile(uid : String){
		this.callListeners(uid,"onAccess");
		if(uid == this.inbox){
			_global.me.digitalScreen.sleep(2);
		}
	}
	
	//
	
	function frusionOn(file:Object){
		this.flFrusionOn = true;
		this.discInFrusion = file;
		if(file.parent == undefined || file.parent == ""){
			var fold = "root";
		}else{
			var fold = file.parent;
		}
		this.callListeners(fold,"rmUid",file.uid);
	}
	
	function frusionOff(){
		this.flFrusionOn = false;
	}
	
	function frusionDiscStopDrag(){
		if(!this.flFrusionOn){
			if(this.discInFrusion.parent == undefined || this.discInFrusion.parent == ""){
				var fold = "root";
			}else{
				var fold = this.discInFrusion.parent;
			}
			
			this.callListeners(fold,"addFile",this.discInFrusion);
			this.discInFrusion = undefined;
		}
	}
	
	function isFileValid(node){
		if(this.discInFrusion == undefined) return true;
		
		if(node.nodeName == "e" && node.attributes.u == this.discInFrusion.uid){
			return false;
		}
		return true;
	}
//{
}
