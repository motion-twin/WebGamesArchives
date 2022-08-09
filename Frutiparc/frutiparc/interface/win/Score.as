/*
$Id: Score.as,v 1.18 2004/02/05 15:30:23  Exp $

Class: box.Shop
*/
class win.Score extends win.Advance{//}
	
	var flMenu:Boolean;
	var menuTree:cp.Tree;
	var mcDate:cp.DateSelector;
	var displayPanel:cp.Document;
	
	/*-----------------------------------------------------------------------
		Function: Score()
	 ------------------------------------------------------------------------*/	
	function Score(){
		this.init();	
	}

	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		//this.iconLabel="Score"
		//_root.test+="winScoreInit\n"
		super.init();
		this.endInit();
	}
	
	function initFrameSet(){
		
		super.initFrameSet();
		

		// initialise la frame menu
		
		var margin = Standard.getMargin();
		margin.x.min = 6;
		margin.x.ratio = 1;
		
		var args = {
			flMask:true
		}	
		var frame = {
			name:"tree",
			link:"cpTree",
			type:"compo",
			min:{w:160,h:60},
			margin:margin,
			flBackground:true,
			mainStyleName:"frScore",			
			args:args
		}
		this.menuTree = this.margin.left.newElement( frame );
		this.margin.left.bigFrame = this.margin.left.tree;
		
		// initialise la frame menu
		
		var margin = Standard.getMargin();
		margin.x.min = 6;
		margin.x.ratio = 1;
		margin.y.min = 6;
		margin.y.ratio = 1;
		
		var args = {

		}
		var frame = {
			name:"date",
			link:"cpDateSelector",
			type:"compo",
			min:{w:160,h:0},
			margin:margin,
			mainStyleName:"frScore",
			args:args
		}
		this.mcDate = this.margin.left.newElement( frame );
			
		
		// initialise la frame show
		var margin = Standard.getMargin();
		margin.x.min = 6;
		margin.x.ratio = 1;
		this.main.newElement({ name:"showFrame", type:"h", min:{w:300,h:200}, flBackground:true, mainStyleName:"frScore", margin:margin})
		this.main.bigFrame = this.main.showFrame;

		// initialise le panel d'affichage
		var args = {
		
		}
		var margin = Standard.getMargin();
		margin.y.min = 4;
		margin.y.ratio = 1;
		var frame = {
			name:"displayPanel",
			link:"cpDocument",
			type:"compo",
			min:{w:0,h:0},
			mainStyleName:"frScoreLight",
			args:args,
			margin: margin
		}
		this.displayPanel = this.main.showFrame.newElement( frame );
		this.main.showFrame.bigFrame = this.main.showFrame.displayPanel;
		
		
		
	}

	function setTree(a){	
		this.menuTree.setList(a)
	}
	
	function setDay(date){
		this.mcDate.setDay(date)
	}

	function setDisplayPanel(pageObj){
		this.displayPanel.removeWait();
		this.displayPanel.setPageObj(pageObj);
		this.frameSet.update();
	}
	
	function displayWait(){
		this.displayPanel.setPageObj();
		this.displayPanel.displayWait();
	}
	
	
	//
	
//{	
}



