class but.Group extends But{
	
	var link:String;
	var frame:Number;
	var gfx:MovieClip;
	var but:Button;
	
	/*-----------------------------------------------------------------------
		Function: Group()
		constructeur
	------------------------------------------------------------------------*/
	function Group(){
		this.init();
	};
	
	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/	
	function init(){
		this.attachMovie("butGroup"+this.link,"gfx",1);
		this.gfx.gotoAndStop(this.frame);
		this.but = this.gfx.but;
		super.init();
	};
};

