class box.DocOnIdent extends box.Doc{
	
	var pos:Object; // {w,h}
	var styleName:String;
	var flBackground:Boolean;
	var flDocumentFit:Boolean;
	
	function DocOnIdent(obj){
		for(var n in obj){
			this[n] = obj[n];
		}
		
		
		
		if(this.winOpt == undefined) this.winOpt = new Object();
		this.winOpt.frameInfo = {mainStyleName: this.styleName,flBackground: this.flBackground}
		
		if(this.pos.w != undefined && this.pos.h != undefined){
			this.winOpt.docInfo = new Object();
			if(this.flDocumentFit){
				this.winOpt.docInfo.flDocumentFit = true;
			}else{
				this.winOpt.docInfo.flDocumentFit = false;
				this.winOpt.docInfo.flMask = true;
			}
			//this.winOpt.docInfo.pos = {x: 0,y: 0,w: this.pos.w,h: this.pos.h};
			this.winOpt.docInfo.min = {w: this.pos.w,h: this.pos.h};
			this.winOpt.flResizable = false;
		}
		
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
			this.window.moveToCenter();
		}else{
			// change mode init
		}

		return rs;
	}
	
	// Called on window closing
	// This method MUST call super.close()
	function close(){
		_global.docOnIdent.next();
		super.close();
	}
	
	function onWheel(delta){
		this.window.scrollContent(-10 * delta);
	}
	
	function exec(str){
		var arr = str.split(",");
		var o = eval(arr[0]);
		o[arr[1]](arr[2]);
		
		this.tryToClose();
	}
	
}