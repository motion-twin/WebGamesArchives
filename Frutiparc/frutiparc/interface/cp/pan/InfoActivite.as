
class cp.pan.InfoActivite extends cp.Panel{

	/*-----------------------------------------------------------------------
		Function: InfoActivite()
		constructeur
	------------------------------------------------------------------------*/	
	function InfoActivite(){
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
		this.attachMovie("mcInfoActivite","content",2);
		var style = this.win.style[this.mainStyleName]
		this.content.barTitle.setColor(style.color.dark,true)
		this.content.panel.setColor(style.color.inline,true)	
	}	
	
}

