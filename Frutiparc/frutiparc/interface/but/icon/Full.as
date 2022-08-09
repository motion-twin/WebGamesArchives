class but.icon.Full extends but.Icon{//}
	
	var titleField:TextField;
		
	/*-----------------------------------------------------------------------
		Function: Full()
		constructeur
	------------------------------------------------------------------------*/
	function Full(){
		this.init();
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/
	function init(){
		super.init();
	}
	
	/*-----------------------------------------------------------------------
		Function: display()
	------------------------------------------------------------------------*/	
	function display(){
		super.display()
		
		// ICON
		var scale = 100 //this.height * this.icoRatio//100 * this.icoScale / 100;			// = 60px
		this.ico._xscale = scale;
		this.ico._yscale = scale;
		this.ico._x = (this.width-this.ico._width)/2 ;
		this.ico._y = (this.height-this.ico._height)/2 ;
		//BUT
		this.but._xscale = this.width;
		this.but._yscale = this.height;
		//FIELD

	}
//{
}