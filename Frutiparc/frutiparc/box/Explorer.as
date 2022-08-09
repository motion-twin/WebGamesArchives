/*
$Id: Explorer.as,v 1.28 2004/08/03 12:25:35  Exp $

Class: box.Explorer
*/
class box.Explorer extends box.Standard{//}
	var list;
	var history:Array;
	var history_pos:Number = 0;
	var uid:String;
	var listLoader:HTTP;
	var boxAlertLinked:Array;
	var haveActivateListener:Boolean;
	
	var currentSort:Object;
	var currentFolderType:Object;
	
	
	function Explorer(obj){
		this.winType = "winExplorer";
		this.history = new Array();
		this.boxAlertLinked = new Array();
		this.haveActivateListener = false;
		
		this.currentSort = {field: "name",sens: "ASC"};
		
		for(var n in obj){
			this[n] = obj[n];
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
			if(this.uid != undefined){
				this.getList();
			}
		}

		return rs;
	}

	function close(){
		if(this.uid != undefined){
			_global.explorerMng.rm(this.uid);
			_global.fileMng.removeListener(this.uid,this);
		}
		this.emptyList();
		_global.mainCnx.traceFlush();
		super.close();
	}

	function getList(folder){
		if(this.uid == folder) return;
		if(folder == undefined && this.uid != undefined) var folder = this.uid;
		
		for(var i=0;i<this.boxAlertLinked.length;i++){
			_global.topDesktop.rmBox(this.boxAlertLinked[i]);
		}
		this.boxAlertLinked = new Array();
		
		if(this.history_pos == 0){
			this.history.push(folder);
		}
		if(this.uid != undefined && folder != this.uid){
			_global.explorerMng.rm(this.uid);
			_global.fileMng.removeListener(this.uid,this);
			this.haveActivateListener = false;
		}
		
		this.uid = folder;
		
		if(!this.haveActivateListener){
			_global.explorerMng.push(folder);
			_global.fileMng.addListener(folder,this);
			this.haveActivateListener = true;
		}
		
		this.listLoader = new HTTP("ff/ls",{uid: this.uid},{type: "xml",obj: this,method: "onLoadList"});
		this.window.displayWait();
		this.window.removeAlert();
	}

	function getParent(){
		if(this.list.parent != undefined && this.list.parent.length > 0 && this.list.parent != "root"){
			this.getList(this.list.parent);
		}
	}

	// TODO; ajouter des boutons, v�rifier que �a fonctionne...
	function getPrevious(){
		if(-this.history_pos < this.history.length - 1){
			this.history_pos -= 1;
			this.getList(this.history[this.history.length -1 + this.history_pos]);
		}
	}

	function getNext(){
		if(this.history_pos < 0){
			this.history_pos += 1;
			this.getList(this.history[this.history.length -1 + this.history_pos]);
		}
	}

	function onLoadList(success,d){
		if(!success){
			this.window.displayError(Lang.fv("error.host_unreachable"));
			return;
		}

		this.emptyList();
    
		this.initList(_global.fileMng.analyseXml(d.lastChild));
		_global.mainCnx.traceFlush();

		if(this.list == undefined){
			this.window.displayError(Lang.fv("error.unknow_folder"));
			return;
		}
		
		_global.fileMng.accessFile(this.uid);

		this.setTitle(this.list.desc[0]);
		
		
		var obj = new Object();
		if(this.list.parent != undefined && this.list.parent.length > 0 && this.list.parent != "root"){
			obj.flUp = true;
		}else{
			obj.flUp = false;
		}
		
		if(FEString.startsWith(this.uid,"inv")){
			obj.flRemoveAll = false;
			obj.flNewDirectory = false;
			obj.styleName = "frFileStandard";
		}else if(this.uid == _global.fileMng.recyclebin){
			obj.flRemoveAll = true;
			obj.flNewDirectory = false;
			obj.styleName = "frFileTrash";
		}else{
			obj.flRemoveAll = false;
			if(this.uid == _global.fileMng.inbox || this.uid == _global.fileMng.draftbox || this.uid == _global.fileMng.outbox || this.uid == _global.fileMng.blackbox || this.uid == _global.fileMng.inventory || this.uid == "blacklist" || this.list.tpl == "mail"){
				obj.flNewDirectory = false;
			}else{
				obj.flNewDirectory = true;
			}
			
			if(this.uid == _global.fileMng.messages || this.uid == _global.fileMng.inbox || this.uid == _global.fileMng.draftbox || this.uid == _global.fileMng.outbox || this.uid == _global.fileMng.blackbox || this.list.tpl == "mail"){
				obj.flMail = true;
			}else{
				obj.flMail = false;
			}
	
			if(this.uid == "blacklist"){
				obj.styleName = "frFileBlackList";
			}else{
				obj.styleName = "frFileStandard";
			}
		}
		
		if(this.list.tpl == "mail"){
			if(this.uid == _global.fileMng.outbox || this.uid == _global.fileMng.draftbox){
				obj.lister = [
					{displayName:Lang.fv("explorer.fields.to"),name:"to",min:140,sortName: "to"},
					{displayName:Lang.fv("explorer.fields.subject"),name:"name",min:200, big:true,sortName: "name"},
					{displayName:Lang.fv("explorer.fields.date"),name:"dateDsp",min:80,sortName: "date"}
				];
			}else{
				obj.lister = [
					{displayName:Lang.fv("explorer.fields.from"),name:"from",min:140,sortName: "from"},
					{displayName:Lang.fv("explorer.fields.subject"),name:"name",min:200, big:true,sortName: "name"},
					{displayName:Lang.fv("explorer.fields.date"),name:"dateDsp",min:80,sortName: "date"}
				];
			}
			this.currentSort = {field: "date",sens: "DESC"};
		}else{
			this.currentSort = {field: "name",sens: "ASC"};
		}
		
		this.currentFolderType = obj;
		
		var alertArr = new Array();
		if(this.uid == _global.fileMng.disccollector){
			if(this.checkBlackFDInList()){
				alertArr.push(Lang.fv("explorer.alert.use_disc"));
			}else if(!this.checkFDInList()){
				alertArr.push(Lang.fv("explorer.alert.no_more_disc"));
			}
			
		}else if(this.uid == "blacklist"){
			alertArr.push(Lang.fv("explorer.alert.blacklist"));
			
		}else if(this.uid == _global.fileMng.mycontact && this.listSize() < 3 && !this.checkFolderInList()){
			alertArr.push(Lang.fv("explorer.alert.create_contact"));
			
		}else if(this.uid == _global.fileMng.mycontact && this.getNbContactInList() > 15){
			alertArr.push(Lang.fv("explorer.alert.too_much_contact"));
			
		}else if(this.uid == _global.fileMng.mycontact && random(100) < 10){
			alertArr.push(Lang.fv("explorer.alert.invite_contact"));
			
		}else if(this.uid == _global.fileMng.inbox && this.listSize() <= 1){
			alertArr.push(Lang.fv("explorer.alert.inbox_empty",{u: _global.me.name}));
			
		}else if(this.uid == _global.fileMng.inventory && this.listSize() < 2){
			alertArr.push(Lang.fv("explorer.alert.inventory_empty"));
		}
		
		this.displayList();
		this.window.displayAlert(alertArr);
	}
	
	function sortBy(field){
		if(field == this.currentSort.field){
			// on inverse
			this.currentSort.sens = (this.currentSort.sens == "ASC")?"DESC":"ASC";
		}else{
			// on choisi ce champ en ASC par default
			this.currentSort.field = field;
			this.currentSort.sens = "ASC";
		}
		
		this.displayList();
	}

	function initList(infos){
		var oldList = infos.list;
		var newList:Array = new Array();
		for(var i=0;i<oldList.length;i++){
			newList[i] = new IconFileBox(oldList[i],this);
		}
		infos.list = newList;
		this.list = infos;
	}
	
	function displayList(){
		if(this.currentSort.sens == "ASC"){
			this.list.list.sortOn([this.currentSort.field,"name"],Array.CASEINSENSITIVE);
		}else{
			this.list.list.sortOn([this.currentSort.field,"name"],Array.CASEINSENSITIVE | Array.DESCENDING);
		}
		
		for(var i=0;i<this.currentFolderType.lister.length;i++){
			if(this.currentFolderType.lister[i].sortName == this.currentSort.field){
				this.currentFolderType.lister[i].sort = (this.currentSort.sens=="DESC");
			}else{
				this.currentFolderType.lister[i].sort = undefined;
			}
		}
		
		this.window.setFolderType(this.currentFolderType);
		this.window.displayList(this.list);
	}

	function emptyList(){
		for(var i=0;i<this.list.list.length;i++){
			this.list.list[i].onKill();
		}
	}
	
	function checkBlackFDInList(){
		for(var i=0;i<this.list.list.length;i++){
			var f = this.list.list[i];
			if(f.type == "disc" && f.desc[0] == "0") return true;
		}
		return false;
	}
	
	function checkFDInList(){
		for(var i=0;i<this.list.list.length;i++){
			var f = this.list.list[i];
			if(f.type == "disc") return true;
		}
		return false;
	}
	
	function listSize(){
		return this.list.list.length;
	}
	
	function getNbContactInList(){
		var n = 0;
		for(var i=0;i<this.list.list.length;i++){
			var f = this.list.list[i];
			if(f.type == "contact") n++;
		}
		return n;
	}
	
	function checkFolderInList(){
		for(var i=0;i<this.list.list.length;i++){
			var f = this.list.list[i];
			if(f.type == "folder") return true;
		}
		return false;
	}
		
	function onDrop(obj){
		var destUid = this.uid;
		for(var i=0;i<this.list.list.length;i++){
			if(this.list.list[i].uid == obj.uid){
				return ;
			}
		}
		if(obj.uid == "new"){
			_global.fileMng.make(obj,destUid);
		}else{
			if(Key.isDown(Key.CONTROL)){
				_global.fileMng.copy(obj.uid,destUid);
			}else{
				_global.fileMng.move(obj.uid,destUid);
			}
		}
	}

	function addFile(obj){
		obj.parent = this.uid;
		this.list.list.push(new IconFileBox(obj,this));
		//_global.mainCnx.traceFlush();
		this.window.displayList(this.list);
	}

	function rmUid(uid){
		for(var i=0;i<this.list.list.length;i++){
			var t = this.list.list[i];
			if(t.uid == uid){
				t.onKill();
				//_global.mainCnx.traceFlush();
				this.list.list.splice(i,1);
				this.window.displayList(this.list);
				return t;
			}
		}
	}
	
	function onParentModified(newParent){
		this.list.parent = newParent;
	}
	
	function refresh(){
		this.getList();
	}
	
	function tryToRemoveAll(){
		if(this.uid != _global.fileMng.recyclebin) return false;
		
		// hum, j'suis pas sur de ce que je fais l�...
		if(this.boxAlertLinked.length > 0) return false;
		
		var nBox = new box.Alert({
			title: Lang.fv("explorer.empty_recyclebin"),
			text: Lang.fv("explorer.empty_recyclebin_query"),
			butActList: [
				{
					name: Lang.fv("yes"),
					action: {obj: this,method: "removeAll"}
				},
				{
					name: Lang.fv("no"),
					action: {obj: this,method: "cleanAlertLinked"}
				}
			]
		});
		
		this.boxAlertLinked.push(nBox);
		
		_global.topDesktop.addBox(nBox);
	}
	
	function cleanAlertLinked(){
		// hum, j'suis pas sur de ce que je fais l�...
		this.boxAlertLinked = new Array();
	}
	
	function removeAll(){
		if(this.uid != _global.fileMng.recyclebin) return false;
		
		_global.fileMng.emptyRecycleBin();
		this.cleanAlertLinked();
	}
	
	function addFolder(fName){
		_global.fileMng.make({type: "folder",desc: [fName]},this.uid);
	}
	
	function newMail(){
		_global.desktop.addBox(new box.Mail());
	}

  function specialClick(obj){
    if(FEString.startsWith(obj.uid,"invpicto,")){
      var cat = obj.uid.substr(obj.uid.indexOf(",")+1);
      getURL("javascript:fp_openPopup('/fb/picto_pop?sid="+_root.sid+"&cat="+escape(cat)+"','fb_picto_forum','width=350,height=350,resizable=yes,scrollbars=yes')");
      return true;
    }else if(obj.type == "bouille"){
      _global.mainCnx.cmd("fbouille",{f: obj.desc[1]});
      if(obj.desc[0] == "Bananocle"){
         _global.uniqWinMng.open("search");
      }
      return true;
    }else if(obj.type == "wallpaper"){
      _global.wallPaper.loadWP(obj.desc[1],obj.desc[2]);
      return true;
    }

    return false;
  }
	
	function onWheel(delta){
		this.window.scrollContent(-10 * delta);
	}
//{
}

