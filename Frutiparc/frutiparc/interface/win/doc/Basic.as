class win.doc.Basic extends win.Doc{//}
	
	function Basic(){
		this.init();
	}
	
	
	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		
		//_root.test+="winDocConfirmMail init\n"
		
		if(this.frameInfo == undefined) this.frameInfo = new Object();
		if(this.frameInfo.flBackground == undefined) this.frameInfo.flBackground = true;
		if(this.frameInfo.mainStyleName == undefined) this.frameInfo.mainStyleName = "frSystem";
		
		if(this.docInfo == undefined){
			this.docInfo = {
				flDocumentFit:true
			}
		}
		
		
		if(this.doc == undefined){
			var flDspWait = true;
			this.doc = new XML();
		}

		//
		this.flTabable = false;
		this.flResizable = false;
		//this.flDocumentFit = true;
		super.init();
		
		this.endInit();
		if(flDspWait)this.displayWait();
	}
	
	
//{
}