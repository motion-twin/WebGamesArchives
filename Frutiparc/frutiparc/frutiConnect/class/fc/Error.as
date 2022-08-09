class fc.Error extends MovieClip{//}
	
	// CONSTANTES
	var width:Number = 300;
	var height:Number = 200;
	var border:Number = 2;
	var mTop:Number = 20
	var mBottom:Number = 30
		
	// PARAM
	var title:String;
	var text:String;
	var color:Number;
	var butList:Array;
	
	// MOVIECLIP 
	var cross:MovieClip;
	var butDrag:Button;
	var field:TextField;
	var titleField:TextField;
	
	function Error(){
		this.init();
	}
	
	function init(){
		//_root.test+="[Error]init()\n"
		this.display()		
		this.setText(this.text)
	}
	
	function display(){
		// DRAW
		this.clear();
		var pos = { x:-this.border, y:-this.border, w:this.width+this.border*2, h:this.height+this.border*2 }
		FEMC.drawSquare(this,pos,0xFFFFFF);		
		var pos = { x:0, y:0, w:this.width, h:this.height }
		FEMC.drawSquare(this,pos,this.color);
		// LINE
		var pos = { x:0, y:this.mTop-2, w:this.width, h:2 }
		FEMC.drawSquare(this,pos,0xFFFFFF);
		// CROSS
		this.attachMovie("cross","cross",12)
		this.cross._x = this.width
		this.cross.onPress = function(){
			_parent.kill();
		}
		// DRAG
		this.attachMovie("transp","butDrag",13)
		this.butDrag.onPress = function (){
			_parent.startDrag();
		}
		this.butDrag.onRelease = function (){
			_parent.stopDrag();
		}
		this.butDrag._xscale =	this.width;
		this.butDrag._yscale =	this.mTop;
		
		// TITLE
		var ti = new TextInfo();
		ti.textFormat.color = 0xFFFFFF;
		ti.textFormat.bold = true;
		ti.textFormat.size = 12;
		ti.fieldProperty.selectable =false;
		ti.pos = { x:0, y:0, w:this.width, h:this.mTop };
		ti.attachField(this,"titleField",8);
		this.titleField.text = this.title
			
		// TEXT
		ti.pos = { x:0, y:this.mTop, w:this.width, h:this.height };
		ti.textFormat.align = "center"
		ti.attachField(this,"field",10);
		this.field.text = this.text
		this.field.multiline = true
		this.field._y = this.mTop+((this.height-(this.mTop+this.mBottom))-this.field.textHeight)/2	

		// BUTTON
		var n = this.butList.length
		var max = 0
		for(var i=0; i<n; i++){
			var but = this.butList[i]
			var initObj = {
				color:this.color,
				text:but.text,
				callback:but.callback,
				flDestroyParent:true		// Je sais... y'a pas de quoi etre fier			
			}
			this.attachMovie("fcBasicButton","but"+i,20+i,initObj);
			var mc:fc.BasicButton = this["but"+i];
			mc._x = 0;
			mc._y = this.height - this.mBottom;
			max+=mc.width
		}
		var space = (this.width-max)/(n+1)
		var x = space
		for(var i=0; i<n; i++){
			var mc:fc.BasicButton = this["but"+i];
			mc._x = x;
			x+=mc.width+space
		}

	}
	
	function setText(text){
		this.text = text
		//this.text.multiline = true;
	}
	
	function kill(){
		this.removeMovieClip();
	}


	











//{	
}