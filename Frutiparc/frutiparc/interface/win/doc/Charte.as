class win.doc.Charte extends win.Doc{//}

	//var myDoc:cp.Document;
	
	/*-----------------------------------------------------------------------
		Function: ConfirmMail()
	 ------------------------------------------------------------------------*/	
	function Charte(){
		this.init();	
		//_global.debug("win.doc.Charte()");
	}

	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		
		//_root.test+="winDocCharte init\n"
		
		this.frameInfo = {
			flBackground:true,
			mainStyleName:"frDef"
		}
		this.docInfo = {
			flDocumentFit:true
		}
		//
		this.flTabable = false;
		this.flResizable = false;
		//this.flDocumentFit = true;
		super.init();
		//
		this.topIconList.splice(0,3);
		//
		this.pos.w = 500
		this.pos.h = 100
		//
		this.endInit();
		this.moveToCenter();
	}
	
	function ok(){
		this.box.tryToClose();
	}
	
	/*-----------------------------------------------------------------------
		Function: genDocument()
	------------------------------------------------------------------------*/	
	function genDocument(){
		super.genDocument();

		var str = Lang.fv("ext.gaspard_present",{u: _global.me.name});
		this.doc = new XML(str);
	}
	

//{	
}




