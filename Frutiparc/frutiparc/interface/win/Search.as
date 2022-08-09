class win.Search extends win.Advance{//}

	
	//CONSTANTES
	var mWidth:Number;
	
	// VARIABLES
	var flAdvanceAvailable:Boolean
	var flAdvance:Boolean;
	
	// REFERENCES
	var pageSelector:cp.PageSelector;
	var doc:cp.Document;
	
	
	function Search(){
		
	}
	
	function init(){
		//_root.test+= "version ok\n"
		this.mWidth = 270
		this.flResizable = false;
		this.flAdvance = false;
		super.init();
		this.updateSearchFrame();
		
		//		
	};
	
	function initFrameSet(){
		//_root.test+="initFrameSet()\n"
		super.initFrameSet();
		
		// FRAME SEARCH
		var initObj = {
			flNeverEnding:false,
			flDocumentFit:true		
		}
		var margin = Standard.getMargin();
		margin.y.min = 6
		margin.y.ratio = 0
		var frame = {
			name:"search",
			link:"cpDocument",
			type:"compo",
			margin:margin,
			min:{w:mWidth,h:20},
			args:initObj,
			mainStyleName:"frSystem"
		}
		this.doc = this.main.newElement(frame)
		
		
		// FRAMESHOW
		this.main.newElement({ name:"showFrame", type:"w", min:{w:mWidth,h:0}})
		this.main.bigFrame = this.main.showFrame;


		// PAGE CONTROL
		var margin = Standard.getMargin();
		margin.x.min = 10
		var args = {
		}
		var frame = {
			name:"pageSelector",
			link:"cpPageSelector",
			type:"compo",
			margin:margin,
			min:{w:mWidth,h:24},
			args:args
		}
		this.pageSelector = this.margin.bottom.newElement(frame)
		//this.pageSelector.setText("1/5")
	}
	
	function updateSearchFrame(){

		var pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[]
		}

		pageObj.lineList = pageObj.lineList.concat( this.getSearchLines() )
		if( this.flAdvance && this.flAdvanceAvailable) pageObj.lineList = pageObj.lineList.concat( this.getAdvanceSearchLines() );
		doc.setPageObj(pageObj)
		
		this.onUpdateSearchFrame();
	}
	
	function onUpdateSearchFrame(){
		
	}
	
	function getSearchLines(){
		
	}
	
	function getAdvanceSearchLines(){

	}

	
	function toggleAdvance(){
		//_root.test+="toggleAdvance!!\n"
		flAdvance = ! flAdvance;
		this.box.onAdvanceSearch(this.flAdvance);
		this.updateSearchFrame();
		this.updateSize();
		this.updateSize();
	}
	
	function launchSearch(){
		var info = new Object();
		for( var elem in this.doc.card ){
			info[elem] = this.doc.card[elem].value
		}
		this.box.launchSearch(info)
		this.pageSelector.setText("chargement...")
		this.frameSet.update();		
	}
	
	
	function getInput(n){
		return this.doc.card[n].value;
	}
	
	function prevPage(){
		
		if(!this.box.prevPage())return;
		this.pageSelector.setText("chargement...")
		this.frameSet.update();
	}

	function nextPage(){
		/*
		var f = this.box.nextPage()
		_root.test+= "f->"+f+"\n"
		if(!f)return;
		*/
		if(!this.box.nextPage())return;
		this.pageSelector.setText("chargement...")
		this.frameSet.update();
	}
	
//{
};

















