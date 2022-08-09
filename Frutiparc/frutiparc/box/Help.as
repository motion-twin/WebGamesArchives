/*
$Id: Help.as,v 1.7 2005/08/04 16:06:03  Exp $

Class: box.Help
*/
class box.Help extends box.Standard{
	var userList:UserListMng;
	var previousArr:Array;
	var current:Object;
	var loading:Boolean;
	var lastSearchTimer:Number;
	
	var openContent:Object;
	
	function Help(obj){
		this.winType = "winHelp";
		
		for(var n in obj){
			this[n] = obj[n];
		}
		
		this.title = Lang.fv( "help.title", {t: Lang.fv("please_wait")} );

		this.userList = new UserListMng();
		this.previousArr = new Array();
		this.loading = false;
		this.lastSearchTimer = 0;
		
		_global.uniqWinMng.setBox("help",this);
	}
	
	function preInit(){
		// called only at start of the first init
		this.desktopable = true;
		this.tabable = true;
		super.preInit();
	}

	function init(slot,depth){
		var rs = super.init(slot,depth);

		if(rs){
			// first init
			if(_global.me.logged){
				this.userList.addUser(_global.me.name);
			}
			this.userList.addUser(Lang.fv("help.name"));
			if(this.openContent != undefined){
				this.loadContent(openContent);
			}else{
				this.loadContent({i: 1});
			}
		}else{
			// change mode init
		}

		return rs;
	}
	
	function close(){
		_global.uniqWinMng.unsetBox("help");
		super.close();
	}
	
	function getContent(id){
		if(id == undefined) var id = 1;
		if(this.current != undefined) this.previousArr.push(this.current);
		
		this.loadContent({i: id});
	}
	
	function getContentByT(t){
		if(this.current != undefined) this.previousArr.push(this.current);
		
		this.loadContent({t: t});
	}
	
	function getContentObj(o){
		if(this.current != undefined) this.previousArr.push(this.current);
		this.loadContent(o);
	}
	
	function getPrevious(){
		if(this.previousArr.length > 0){
			//this.getContent();
			this.loadContent(this.previousArr.pop());
		}
	}


	function search(s){
		this.window.displayWait();
		this.loading = true;
		var loader:HTTP = new HTTP("fh/search",{s: s},{type: "xml",obj: this,method: "onSearch"});	
		
	}
	
	function onSearch(success,x){
		this.loading = false;
		
		if(!success){
			_global.openErrorAlert(Lang.fv("error.host_unreachable"));
			return ;
		}

		this.setTitle(Lang.fv( "help.title", {t: Lang.fv("help.search")} ));
		x = x.firstChild;
		var nbResult = Number(x.attributes.n);
		if(nbResult < 1){
			this.window.displayNoResult();
		}else if(nbResult == 1){
			var n=x.firstChild;
			this.getContent(Number(n.attributes.i));
			
		}else{
			var arr:Array = new Array();
			for(var n=x.firstChild;n.nodeType>0;n=n.nextSibling){
				arr.push({i: n.attributes.i,n: n.attributes.n});
			}
			this.window.displayResult({nb: nbResult,method: x.attributes.m,list: arr});
		}
	}
	
	function undoSearch(){
		this.loadContent(this.current);
	}

	function loadContent(o){
		this.window.displayWait();
		this.loading = true;
		this.current = o;
		var loader:HTTP = new HTTP("fh/get",o,{type: "xml",obj: this,method: "onGetContent"});	
	}
	
	function onGetContent(success,x){
		this.loading = false;

		if(!success){
			_global.openErrorAlert(Lang.fv("error.host_unreachable"));
			return ;
		}
		
		x = x.firstChild;
		if(x.attributes.k != undefined || x.nodeName != "h"){
			var e = (x.attributes.k == undefined)?1:x.attributes.k;
			_global.openErrorAlert(Lang.fv("error.http."+e));
			return ;
		}
		
		// Analyse received XML
		var id:Number      = Number(x.attributes.i);
		var title:String   = x.attributes.n;
		var links:Object   = new Object(); // [type][] = {i: ,n: }
		var content:String = "";
		
		for(var c=x.firstChild;c.nodeType>0;c=c.nextSibling){
			if(c.nodeName == "c"){
				var content = c.firstChild.nodeValue.toString();
			}else if(c.nodeName == "l"){
				for(var t=c.firstChild;t.nodeType>0;t=t.nextSibling){
					var ltype = t.attributes.t;
					if(links[ltype] == undefined) links[ltype] = new Array();
					links[ltype].push({i: Number(t.attributes.i),n: t.attributes.n});
				}
			}
		}
		
		this.setTitle(Lang.fv( "help.title", {t: title} ));
		this.window.displayContent({id: id,title: title,content: content,links: links,back: (this.previousArr.length > 0)});
	}
	
	function getIconLabel(){
		return "winChat";
	}
	
	function onEnter(){
		if(this.analyseInput(this.window.getInput())){
			this.window.setInput("");
		}
	}
	
	function analyseInput(str:String){
		str = FEString.trim(str);
		
		if(str.length <= 0) return false;
		
		if(getTimer() - this.lastSearchTimer > 2500){
			this.lastSearchTimer = getTimer();
			this.search(str);
			return true;
		}else{
			return false;
		}
		
	}
	
	function onWheel(delta){
		this.window.scrollText(-10 * delta);
	}
}
