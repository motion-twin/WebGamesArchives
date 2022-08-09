class but.TextCustom extends but.Text{//}
	
	/*-----------------------------------------------------------------------
		Function: TextCustom()
		constructeur
	------------------------------------------------------------------------*/	
	function TextCustom(){
		this.init();
		
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/	
	function init(){
		//this.flResizable=true;
		this.initCustomMode()
		super.init();
		this.defineCustomAction();
	}
	
	/*-----------------------------------------------------------------------
		Function: updateSize()
	------------------------------------------------------------------------*/	
	function updateSize(){
		this.but._xscale = this.width;
		this.but._yscale = this.height;	
	}
//};
}
