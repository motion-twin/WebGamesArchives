class box.UserLog extends box.Standard{
	
	function UserLog(obj){
		this.winType = "winUserLog";
		
		for(var n in obj){
			this[n] = obj[n];
		}
		this.title = Lang.fv("user_log.title");
		
		_global.uniqWinMng.setBox("userLog",this);
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
			_global.me.addListener("userLog",{obj: this,method: "onUserLog"});
			this.onUserLog(_global.me.userLog);
		}else{
			// change mode init
		}

		return rs;
	}
	
	function close(){	
		_global.uniqWinMng.unsetBox("userLog");
		_global.me.removeListener("userLog",this);
		super.close();
	}
	
	/*
	arr = [
		{ time: "2003-12-01 23:56:53", content: "Text du log" },
		...
	]
	*/
	function onUserLog(arr){
		_global.me.onDisplayUserLog();
		if(arr.length == 0){
			this.window.displayError(Lang.fv("user_log.empty"));
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
