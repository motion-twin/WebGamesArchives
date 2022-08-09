class box.Charte extends box.Standard{
	
	function Charte(obj){
		this.winType = "winDocCharte";
		
		for(var n in obj){
			this[n] = obj[n];
		}
		this.setTitle(Lang.fv("ext.welcome"));
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
		}else{
			// change mode init
		}

		return rs;
	}
	
	// Called on window closing
	// This method MUST call super.close()
	function close(){
		super.close();
	}
	
	// Called when an element want to close the window
	// This function can call this.close() or not...
	function tryToClose(){
		this.close();
	}

}
