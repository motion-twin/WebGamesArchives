class box.Doc extends box.Standard{
	
	var doc:String;
	var pageObj;
	
	function Doc(){
		this.winType = "winDocBasic";
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
			if(this.doc != undefined){
				this.window.removeWait();
				this.window.setDoc(this.doc);
				//_global.debug("SetDoc: "+FEString.unHTML(this.doc.toString()));
			}else if(this.pageObj != undefined){
				this.window.removeWait();
				this.window.setPageObj(this.pageObj);
			}
		}else{
			// change mode init
		}

		return rs;
	}
	
	function setPageObj(po){
		this.pageObj = po;
		this.window.removeWait();
		this.window.setPageObj(po);
	}
	
	function setDoc(doc){
		this.doc = doc;
		this.window.removeWait();
		this.window.setDoc(doc);
	}


}
