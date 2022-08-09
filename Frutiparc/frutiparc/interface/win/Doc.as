class win.Doc extends win.Advance{//}

	var myDoc:cp.Document;
	var doc:XML;
	var pageObj:Object;
	
	
	var docMinSize:Object;
	//var flDocumentFit:Boolean
	
	var frameInfo:Object;
	var docInfo:Object;
	
	/*-----------------------------------------------------------------------
		Function: Doc()
	 ------------------------------------------------------------------------*/	
	function Doc(){
		//this.init();	
	}

	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		//if(this.flDocumentFit==undefined)this.flDocumentFit=false;
		if(this.docMinSize==undefined)this.docMinSize={w:10,h:10};
		super.init();
		//this.endInit();
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/	
	function initFrameSet (){
		//_root.test+="winDoc initFrameSet\n"
		super.initFrameSet()
		this.genDocument();
						
		var args = {
		};

		if( this.doc != undefined ) args.doc = this.doc;
		if( this.pageObj != undefined ) args.pageObj = this.pageObj;

		if(this.docInfo != undefined){
			for(var elem in this.docInfo){
				args[elem] = this.docInfo[elem];
			};
		}
		
		var frame = {
			name:"docFrame",
			type:"compo",
			link:"cpDocument",
			min:this.docMinSize,
			args:args
		};
		if(this.frameInfo != undefined){
			for(var elem in this.frameInfo){
				frame[elem] = this.frameInfo[elem];
			};
		}
		
		this.myDoc = this.main.newElement(frame);
		this.main.bigFrame = this.main.infoFrame;
	};
	
	/*
	function onFrameSetUpdate(){
		if(this.flDocumentFit){
			this.myDoc.min.h = this.myDoc.getHeight()
			//_root.test+="this.myDoc.getHeight() + this.margin.top.minInt.h + this.margin.bottom.minInt.h -->"+(this.myDoc.getHeight() + this.margin.top.minInt.h + this.margin.bottom.minInt.h)+"\n"
			//this.pos.h = 68//this.myDoc.getHeight() + this.margin.top.minInt.h + this.margin.bottom.minInt.h;
		}
		//_root.test+="this.myDoc.getHeight()("+this.myDoc.getHeight()+")\n"
		super.onFrameSetUpdate();
	};
	*/
	function genDocument(){
	
	}
	
	// APPELS BOX	
	
	function displayWait(){
		this.myDoc.setDoc(new XML());
		this.myDoc.displayWait();
		this.frameSet.update();
	}
	
	function removeWait(){
		this.myDoc.removeWait();
	}

	function setDoc(doc){
		this.doc = doc;
		this.myDoc.setDoc(doc)
		this.frameSet.update();
	}
	function setPageObj(pageObj){
		this.doc = doc;
		this.myDoc.setPageObj( pageObj )
		this.frameSet.update();
	}	
	
	function scrollContent(px){
		this.myDoc.mask.y.path.pixelScroll(px);
	}
	
//{
}


