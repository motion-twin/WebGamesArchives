class fc.pan.CreateGame extends fc.Panel{//}

	
	//MOVIECLIPS
	var doc:cp.Document;
	
	function CreateGame(){
		this.init();
	}
	
	function init(){
		this.title = "Creer une partie"
		super.init();
	}
	
	function display(){
		super.display();
		//this.initDoc();
		this.initButton();		
	}
	
	function setDoc(doc){
		//_root.test+="[PanCreateGame]initDoc\n"
		var ws = Standard.getWinStyle();
		var style = Standard.getFrusionDocStyle(ws.frDef);
		
		//_global.debug("this.root.manager.gamePanel="+this.root.manager.gamePanel);
		
		var initObj={
			doc:doc,//this.root.manager.gamePanel,
			docStyle:style
		};
		//_root.test+="this.root.manager.gamePanel("+this.root.manager.gamePanel+")\n"
		this.attachMovie("cpDocument","doc",this.dp_main,initObj);
		this.update();
	}
	
	function update(){
		super.update();
		this.doc._y = this.marginUp
		this.doc.extWidth = this.size.w;
		this.doc.extHeight = this.size.h-(this.marginUp+this.marginBottom)
		this.doc.updateSize();
	}
	
	function initButton(){
		this.genButton("créer la partie",{obj:this,method:"create"});
        //this.genButton("boire un poulpe");
		//this.genButton("options");
	}
		
	function create(){
		//_root.test+="[CreateGame] create("+this.doc.card.time.value+")\n"
		this.root.manager.createGame(this.doc.card)
	}
	
//{	
}
