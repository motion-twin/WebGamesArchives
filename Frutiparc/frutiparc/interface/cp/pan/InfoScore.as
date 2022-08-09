
class cp.pan.InfoScore extends cp.Panel{

	/*-----------------------------------------------------------------------
		Function: InfoScore()
		constructeur
	------------------------------------------------------------------------*/	
	function InfoScore(){
		this.init();
	}
	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/	
	function init(){
		super.init();
	}
	
	/*-----------------------------------------------------------------------
		Function: genContent()
	------------------------------------------------------------------------*/	
	function genContent(){
		this.attachMovie("mcInfoScore","content",2);
		var style = this.win.style[this.mainStyleName]
		this.content.panel.setColor(style.color.inline,true)	
	}	
	
}

