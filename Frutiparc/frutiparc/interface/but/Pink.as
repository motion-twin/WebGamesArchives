class but.Pink extends But{
	
	var marge:Number;
	var mid;
	var right;
	var left;
	var textField;
	
	/*-----------------------------------------------------------------------
		Function: Pink()
		constructeur
	------------------------------------------------------------------------*/
	function Pink(){
		this.init();
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/	
	function init(){
		super.init();
		if(this.marge==undefined)this.marge=10;
		this.setButtonMethod("onRollOut",this,"allGotoAndStop",1);
		this.setButtonMethod("onDragOut",this,"allGotoAndStop",1);
		this.setButtonMethod("onReleaseOutside",this,"allGotoAndStop",1);
		this.setButtonMethod("onRollOver",this,"allGotoAndStop",2);
		this.setButtonMethod("onPress",this,"allGotoAndStop",3);
		this.setButtonMethod("onRelease",this,"allGotoAndStop",2);
		this.allGotoAndStop(1)	
	};
	
	/*-----------------------------------------------------------------------
		Function: allGotoAndStop(num)
	------------------------------------------------------------------------*/	
	function allGotoAndStop(num){
		this.left.gotoAndStop(num);
		this.mid.gotoAndStop(num);
		this.right.gotoAndStop(num);
		this.textField._y = num-1
	}

	/*-----------------------------------------------------------------------
		Function: setText(str)
	------------------------------------------------------------------------*/	
	function setText(str){
		this.textField.text = str;
		this.textField._width = this.textField.textWidth+this.marge*2;
		this.mid._width = this.textField._width-16
		this.right._x = this.mid._x + this.mid._width;
		this.but._xscale = this.textField._width
	}
};
