class box.SiteLog extends box.Standard{
	
	function SiteLog(obj){
		this.winType = "winSiteLog";
		
		for(var n in obj){
			this[n] = obj[n];
		}
		this.title = Lang.fv("site_log.title");
		
		_global.uniqWinMng.setBox("siteLog",this);
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
			_global.me.addListener("siteLog",{obj: this,method: "onSiteLog"});
			this.onSiteLog(_global.me.siteLog);
		}else{
			// change mode init
		}

		return rs;
	}
	
	function close(){	
		_global.uniqWinMng.unsetBox("siteLog");
		_global.me.removeListener("siteLog",this);
		super.close();
	}
	
	/*
	arr = [
		{ time: "2003-12-01 23:56:53", content: "Text du log" },
		...
	]
	*/
	function onSiteLog(arr){
		_global.debug("onSiteLog");
		_global.me.onDisplaySiteLog();
		if(arr.length == 0){
			this.window.displayError(Lang.fv("site_log.empty"));
		}else{
			this.window.setLog(arr);
		}
	}
	
	function onWheel(delta){
		if(delta < 0){
			this.window.nextPage();
		}else{
			this.window.prevPage();
		}
	}

}
