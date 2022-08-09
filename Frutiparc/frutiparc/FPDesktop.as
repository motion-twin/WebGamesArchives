/*

$Id: FPDesktop.as,v 1.47 2007/03/30 13:43:24  Exp $
*/
class FPDesktop extends Desktop{//}
	var mcDesk:MovieClip;
	var mc:MovieClip;
	var list:Array;

	function FPDesktop(){
		//_root.test += "Youhou !!!";
	}

	function init(slotList,depth,flGo){
		super.init(slotList,depth,flGo);
		
		this.list = new Array();

		var mcName = "DesktopBg"+FEString.uniqId();
		this.slotList.mc.attachMovie("DesktopBg",mcName,this.baseDepth + Depths.desktop.bg);
		this.mcDesk = this.slotList.mc[mcName];

		this.mcDesk._x = _global.main.cornerX;
		this.mcDesk._y = _global.main.cornerY;

		this.mcDesk.attachMovie("transp","but",5);
		this.mcDesk.but.dropBox = this;
		this.mcDesk.but._xscale = _global.mcw;
		this.mcDesk.but._yscale = _global.mch;
		this.mcDesk.but.useHandCursor = false;

		_global.fileMng.addListener("root",this);
	}

	function addBox(box){
		box.mode = "desktop";
		super.addBox(box);
		
		if(!this.flActive){
			this.warning();
		}
	}
	
	function setDepth(depth){
		super.setDepth(depth);

		this.mcDesk.swapDepths(this.baseDepth + Depths.desktop.bg);
	}

	function tab(box,flGo){
		var nTab:FPTab = new FPTab({slot: this,box: box});
		//nTab.title = box.title;

		_global.slotList.addSlot(nTab,flGo);

		//this.move(box,nTab);
	}

	function onActivate(){
		this.displayIconList();
		this.mcDesk._visible = true;
		//this.mcDesk._alpha = 100;
		this.mc.activate();
		super.onActivate();
	}
	
	function onDeactivate(){
		this.mcDesk.iconList.removeMovieClip();
		this.mcDesk._visible = false;
		//this.mcDesk._alpha = 22;
		this.mc.deactivate();
		super.onDeactivate();
	}
	
	function onWarning(){
		this.mc.warning();
		super.onWarning();
	}
	
	function onStopWarning(){
		this.mc.stopWarning();
		super.onStopWarning();
	}

	function onStageResize(){
		if(_global.frameMode) return false;
		
		for(var i=0;i<this.arr.length;i++){
			this.arr[i].onStageResize();
		}
		this.mcDesk._x = _global.main.cornerX;
		this.mcDesk._y = _global.main.cornerY;
		this.mcDesk.but._xscale = _global.mcw - _global.main.cornerX;
		this.mcDesk.but._yscale = _global.mch - _global.main.cornerY;

		this.mcDesk.iconList.extWidth = _global.mcw - _global.main.cornerX;
		this.mcDesk.iconList.extHeight = _global.mch - _global.main.cornerY;
		this.mcDesk.iconList.updateSize();

	}

	function getMenu(){
		var list;

		if(_global.me.name == "bumdum" || _global.me.name == "deepnight" || _global.me.name == "yota" || _global.me.name == "whitetigle" || _global.me.name == "skool" || _global.me.name == "warp" || _global.me.name == "roger" || _global.me.name == "test" || _global.me.name == "ernest" || _global.me.name == "hiko" || _global.me.name.toLowerCase() == "gaspard" || _global.me.name.toLowerCase() == "snowstar") {
			list = [
				/*
				{title: "Afficher debug", action:{onRelease: [{obj:_global, method:"moveDebugToDesktop"}]}},
				{title: "Cr�er accessoires", action:{onRelease: [{obj:_global.desktop, method:"addBox",args: new box.NewBouille()}]}},
				*/
				{title: "Invisibilit�", action:{onRelease: [{obj:_global.mainCnx, method:"cmd",args: "invisible"}]}}
			];
			
		}else{
			list = [];
		}
		
		//list.push({title: "Envoyer debug", action:{onRelease: [{obj:_global, method:"sendDebugContent"}]}});
		
		var name;
		if(_global.main.mainBar.flHalfHide){
			name = "Afficher barre";
		}else{
			name = "Mode rapide";
		}
		list.push({title:"Se d�connecter", action:{onRelease: [{obj:_global, method:"logout"}]}});
		list.push({title:"Mode light", action:{onRelease: [{obj:_global, method:"golight"}]}});
		list.push({title:name, action:{onRelease: [{obj:_global.main.mainBar, method:"toggleHalfHide"}]}});
		list.push({title:"Recherche", action:{onRelease: [{obj:_global.uniqWinMng, method:"open",args: "search"}]}});
    
		return list;
	}

	function iconClick(ico){
		if(ico.type == "folder"){
			_global.explorerMng.open(ico.uid);
		}else if(ico.type == "link"){
			eval(ico.desc[1])();
		}
	}

	function setTitle(t){
		this.mc.setTitle(t);
		super.setTitle(t);
	}

	function close(){
		this.mcDesk.removeMovieClip();
		_global.fileMng.removeListener("root",this);
		super.close();
	}
	
	function onDrop(ico,mc){
		var destUid = "root";
		for(var i=0; i<this.list.length; i++){
			if(this.list[i].uid == ico.uid){
				//_global.debug("on a d�j� l'uid: "+ico.uid);
				//this.list[i].pos = {x: this.mcDesk.iconList._xmouse,y: this.mcDesk.iconList._ymouse}
				var point = { x:_global.dragIcon._x, y:_global.dragIcon._y}
				this.mcDesk.iconList.globalToLocal(point)
				this.list[i].pos = {x: point.x+_root._x,y:point.y+_root._y}
				// TODO: l� tu mettre � jour l'icone this.list[i]
				//_root._alpha = 50;
				this.mcDesk.iconList.removeFromList(this.list[i] )
				this.mcDesk.iconList.addToList( this.newIconObj(this.list[i]) )
				return false;
			}
		}
		if(ico.uid == "new"){
			_global.fileMng.make(ico,destUid,{pos: {x: _xmouse,y: _ymouse}});
		}else{
			if(Key.isDown(Key.CONTROL)){
				_global.fileMng.copy(ico.uid,destUid,{pos: {x: _xmouse,y: _ymouse}});
			}else{
				_global.fileMng.move(ico.uid,destUid,{pos: {x: _xmouse,y: _ymouse}});
			}
		}
	}
	
	function emptyList(){
		for(var i=0;i<this.list.length;i++){
			this.list[i].onKill();
		}
		this.list = new Array();
	}
	
	function initList(l){
		this.emptyList();
		for(var i=0;i<l.length;i++){
			this.list.push(new IconFileBox(l[i],this));
		}
		_global.mainCnx.traceFlush();
	}

	function setIconList(l){
		this.initList(l);
		this.displayIconList();
	}
	
	function cleanIcon(){
		this.setIconList(new Array());
	}

	// TODO: nettoyer un peu
	/*
	function displayIconList(){
		
		// Init List struct
		var l:Array = new Array();
		for(var i=0; i<this.list.length; i++){
			var icon:IconFileBox = this.list[i]

			var o = new Object();
			o.param = icon;
			if(icon.type == "disc"){
				o.link = "fileIconFull"
			}else{
				o.link = "fileIconStandard"
			}
			l.push(o);
		}

		// CREATION DES PARAMETRES DE LA LISTE
		var struct = Standard.getStruct()
		//_root.test+="oh la jolie Structure ! : struct.x.size="+struct.x.size+"\n"
		struct.x.size = 60;
		//_root.test+="oh la jolie Structure ! : struct.x.size="+struct.x.size+"\n"
		struct.y.size = 60;
		struct.x.space = 8;
		struct.y.space = 8;	
		struct.x.margin = 10;
		struct.y.margin = 10;	
		var param = {
			list : l,
			struct : struct,
			extWidth : _global.mcw - _global.main.cornerX,
			extHeight : _global.mch - _global.main.cornerY,
			_x:30,
			_y:10,
			flTrace:true,
			flMask:true
		}

		// ATTACHEMENT DE LA LISTE
		if(this.mcDesk.iconList != undefined){
			this.mcDesk.iconList.removeMovieClip();
		}
		this.mcDesk.attachMovie("fileIconList","iconList",6,param);
		this.mcDesk.iconList.build();
		this.mcDesk.iconList.updateSize();

	}
	*/
	function displayIconList(){
		// Init List struct
		var l:Array = new Array();
		for(var i=0; i<this.list.length; i++){
			l.push(this.newIconObj(this.list[i]));
		}
		var margin = Standard.getMargin();
		margin.x.min = 18;
		margin.y.min = 12;
		var textColor =  _global.wallPaper.txtColor;
		if( textColor == undefined ) textColor = _global.colorSet.green.overdark;
		var param = {
			list : l,
			extWidth : _global.mcw - _global.main.cornerX,
			extHeight : _global.mch - _global.main.cornerY,
			textColor:textColor,
			margin:margin,
			flTrace:true,
			flMask:true
		}

		// ATTACHEMENT DE LA LISTE
		if(this.mcDesk.iconList != undefined){
			this.mcDesk.iconList.removeMovieClip();
		}
		this.mcDesk.attachMovie("cpDragIconList","iconList",6,param);
		this.mcDesk.iconList.setList(l);
		this.mcDesk.iconList.updateSize();

	}

	function newIconObj(icon:IconFileBox){
		var o = new Object();
		o.param = icon;
		o.pos = icon.pos;
		if(icon.type == "disc"){
			o.link = "fileIconFull"
		}else{
			o.link = "fileIconStandard"
		}
		return o;	
		
	}
	
	function addFile(obj){		// PUSH
		//_root.test+="addFile()\n"
		obj.parent = undefined;
		var box = new IconFileBox(obj,this)
		this.list.push(box);
		//_global.mainCnx.traceFlush();
		this.mcDesk.iconList.addToList( this.newIconObj(box) )
		//this.displayIconList();
	}

	function rmUid(uid){
		for(var i=0;i<this.list.length;i++){
			var o = this.list[i];
			if(o.uid == uid){
				this.mcDesk.iconList.removeFromList( o )
				o.onKill();
				this.list.splice(i,1);
				//this.displayIconList();
				return o;
			}
		}
	}
	
	function getList(uid){
		_global.explorerMng.open(uid);
	}
	
	function getIconLabel(){
		return "desktop";
	}
//{
}
