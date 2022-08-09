
class cp.pan.KikoozAllo extends cp.Panel{//}

	/*-----------------------------------------------------------------------
		Function: InfoStat()
		constructeur
	------------------------------------------------------------------------*/	
	function KikoozAllo(){
		this.init();
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/	
	function init(){
		this.flBackground=false;
		super.init();
		this.min.w = 190;
		this.min.h = 180;
	}
	
	/*-----------------------------------------------------------------------
		Function: genContent()
	------------------------------------------------------------------------*/	
	function genContent(){
		this.attachMovie("mcKikoozAllo","content",2);
		//var style = this.win.style[this.mainStyleName]
		//this.content.interface.setColor(style.color.dark,true)
		//this.content.slot.setColor(style.color.inline,true)		
		
	}
	
//{
}

