class but.icon.Standard extends but.Icon{//}
	
	
	
	
	// CONSTANTES
	var bx:Number = 3
	var by:Number = 4
	var textRatio = 0.5
	
	
	// PARAMETRES
	
	
	var titleField:TextField;
		
	/*-----------------------------------------------------------------------
		Function: Standard()
		constructeur
	------------------------------------------------------------------------*/
	function Standard(){
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
		
		var size = this.width*(1-this.textRatio)
		
		// ICON
		var scale = size * this.icoRatio //size * this.icoScale / 100;			// = 36px
		this.ico._x = (this.width-size)/2;
		this.ico._xscale = scale;
		this.ico._yscale = scale;
		//BUT
		this.but._xscale = this.width;
		this.but._yscale = this.height;
		//FIELD
		var ti = new TextInfo();
		//{x:-bx, y:32, w:size+bx*2, h:24+by};//{x:0, y:32, w:size, h:28};
		ti.pos = { 
			x:0,
			y:size,
			w:this.width,
			h:this.height*this.textRatio
		}
		ti.textFormat.align = "center";
		ti.textFormat.color = this.textColor;
		ti.attachField(this,"titleField",this.dp_field);
		this.titleField.multiline = true;
		this.titleField.wordWrap = true;
		this.titleField.text = this.name;
	}
	
	
	
//{
}




