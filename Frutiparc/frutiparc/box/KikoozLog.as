class box.KikoozLog extends box.Standard{
	
	function KikoozLog(obj){
		this.winType = "winKikoozLog";
		
		for(var n in obj){
			this[n] = obj[n];
		}
		this.title = Lang.fv("kikooz_log.title");
		
		_global.uniqWinMng.setBox("kikoozLog",this);
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
			this.getLog();
		}else{
			// change mode init
		}

		return rs;
	}
	
	function getLog(){
		this.window.displayError(Lang.fv("please_wait"));
		
		var loader:HTTP = new HTTP("ft/log",{},{type: "xml",obj: this,method: "onLog"});
	}
	
	function onLog(success,node){
		if(!success){
			this.window.displayError(Lang.fv("error.host_unreachable"));
			return;
		}
		node = node.firstChild;
		if(node.nodeName != "l"){
			this.window.displayError(Lang.fv("error.host_unreachable"));
			return;
		}
		
		var arr = new Array();
		for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){
			var o = new Object();
			var lang_var;
			var icoFrame;
			if(n.nodeName == "b"){
				lang_var = "buy";
				o.n = n.attributes.n;
				icoFrame = 20;
			}else if(n.nodeName == "c"){
				lang_var = "kcall";
				o.c = n.attributes.c;
				icoFrame = 1;
			}else if(n.nodeName == "g"){
				lang_var = "godfather";
				o.f = n.attributes.f;
				icoFrame = 10;
      }else if(n.nodeName == "a"){
        lang_var = "anim";
        o.f = n.attributes.f;
        icoFrame = 1;
      }else{
				continue;
			}
			o.k = n.attributes.k;
			arr.push({
				time: n.attributes.t,
				content: Lang.fv("kikooz_log"+"."+lang_var,o),
				type: icoFrame
			});
		}
		
		if(arr.length == 0){
			this.window.displayError(Lang.fv("kikooz_log.empty"));
		}else{
			this.window.setLog(arr);
		}
	}
	
	function close(){	
		_global.uniqWinMng.unsetBox("kikoozLog");
		super.close();
	}
	
	function onWheel(delta){
		if(delta < 0){
			this.window.nextPage();
		}else{
			this.window.prevPage();
		}
	}

}
