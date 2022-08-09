class fc.BasicButton extends MovieClip{//}
	
	// CONSTANTES
	var height:Number = 20;
	var border:Number = 2;
	var margin:Number = 10;
	
	
	// PARAM
	var text:String;
	var color:Number;
	var callback:Object;
	var flDestroyParent;

	// VARIABLES
	var width:Number;

	
	// MOVIECLIP 
	var butTransp:MovieClip;
	var field:TextField;
	
	function BasicButton(){
		this.init();
	}
	
	function init(){
		this.display();
	}
	
	function display(){
		// TEXT
		var ti = new TextInfo();
		ti.textFormat.color = 0xFFFFFF;
		ti.textFormat.bold = true;
		ti.textFormat.size = 12;
		ti.fieldProperty.selectable =false;
		ti.pos = { x:margin, y:0, w:100, h:this.height };
		ti.attachField(this,"field",8);
		this.field.text = this.text
		this.width = this.field.textWidth+this.margin*2

		// DRAW
		this.clear();
		var pos = { x:-this.border, y:-this.border, w:this.width+this.border*2, h:this.height+this.border*2 }
		FEMC.drawSquare(this,pos,0xFFFFFF);		
		var pos = { x:0, y:0, w:this.width, h:this.height }
		FEMC.drawSquare(this,pos,this.color);			
		
		
		// BUT
		this.attachMovie("transp","butTransp",10)
		this.butTransp.c = this.callback
		this.butTransp.onPress = function (){
			this.c.obj[this.c.method](this.c.args)
			if(_parent.flDestroyParent)_parent._parent.kill();
		}
		this.butTransp._xscale =	this.width;
		this.butTransp._yscale =	this.height;		
	}
	
	
	
	
	
	
	
	
//{	
}