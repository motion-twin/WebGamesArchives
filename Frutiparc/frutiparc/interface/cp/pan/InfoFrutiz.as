
class cp.pan.InfoFrutiz extends cp.Panel{

	/*-----------------------------------------------------------------------
		Function: InfoFrutiz()
		constructeur
	------------------------------------------------------------------------*/	
	function InfoFrutiz(){
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
		this.attachMovie("mcInfoFrutiz","content",2);
		var style = this.win.style[this.mainStyleName]
		//this.content.interface.setColor(style.color.dark,true)
		this.content.slot.setColor(style.color.inline,true)		
	}	
	
}

