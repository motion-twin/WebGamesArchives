class fc.Panel extends MovieClip{//}
	
	
	
	//VARIABLE
	
	// CONSTANTES
	var dp_main:Number = 100;
	var dp_title:Number = 20;
	var dp_button:Number = 20
	var dp_cross:Number = 4;
	//
	var marginUp:Number = 18;
	var marginBottom:Number = 20;
	var lineHeight:Number = 2;
	
	
	// VARIABLES
	var butNum:Number;
	var butList:Array;	
	var title:String;
	var size:Object;
	
	// REFERENCE
	var root:FrutiConnect;
	var slot:fc.Slot;
	var col:Object;
	
	// MOVIECLIPS
	var titleField:TextField;
	var cross:MovieClip;
	

	function Panel(){
	}
		
	function init(){
		this._visible = this.slot.flOpen;
		this.butNum=0;
		this.butList = new Array();
		this.size = new Object();
		this.display();
	}
	
	function display(){
		this.initTitle();
	}
	
	function initTitle(){
		// TITLE
		var tf = new TextInfo();
		tf.textFormat.color = 0xFFFFFF
		tf.textFormat.bold = true;
		tf.textFormat.size = 12;
		tf.fieldProperty.selectable =false;
		tf.attachField(this,"titleField",this.dp_title)
		this.titleField.text = this.title
		this.titleField._height = this.marginUp
		// CROSS
		this.attachMovie("cross","cross",this.dp_cross)
		this.cross.onPress = function(){
			this._parent._parent.toggle();
		}	
	}
	
	function update(){
		//_root.test+="bonjour c moi le super\n"

		this.clear();
		
		//TITLE

		this.titleField._width = this.size.h	
		this.cross._x = this.size.w;
		this.drawLine(this.marginUp);
		
		
		//BUTTON
		var x = 0
		for(var i=0; i<this.butList.length; i++){
			var mc = this.butList[i];
			x+= mc.width;
			mc._x = this.size.w-x;
			mc._y = this.size.h-this.marginBottom;
		}

		
	}
	
	function genButton(name,callback){
		this.butNum = (this.butNum+1)%20;
		this.createEmptyMovieClip("but"+this.butNum,this.butNum);
		var mc = this["but"+this.butNum];
		var h = this.lineHeight;
		//FIELD
		var tf = new TextInfo();
		tf.textFormat.color = 0xFFFFFF;//0x888800
		tf.textFormat.size = 11;
		tf.textFormat.bold = true;
		tf.textFormat.align = "center";
		tf.attachField(mc,"field",1);
		mc.field.text = name;
		mc.field._y = h;
		mc.field._height = this.marginBottom-h;
		mc.width = mc.field.textWidth+16
		mc.field._width = mc.width;
		//BG
		var pos = {x:0,y:0,w:mc.width, h:this.marginBottom};
		FEMC.drawSquare(mc,pos,0xFFFFFF)
		//COLOR
		var pos = {x:h,y:h,w:mc.width-h,h:this.marginBottom-h};
		FEMC.drawSquare(mc,pos,this.col.main)
		//ACTION
		if(callback!=undefined){
			mc.callback = callback;
			mc.onPress = function(){
				this.callback.obj[this.callback.method](this.callback.args)
			}
		}else {
			_root.test+="createTrame\n"
			mc.createEmptyMovieClip("butMask",2);
			mc.butMask.attachMovie("trame","trame",1)
			mc.butMask.createEmptyMovieClip("mask",2);
			var pos = {x:0,y:0,w:mc.width,h:this.marginBottom};
			FEMC.drawSquare(mc.butMask.mask,pos,0xFF0000)
			mc.butMask.trame.setMask(mc.butMask.mask)
		}
		//_root.test+="genButton("+mc.field+")\n"
		this.butList.push(mc)
	}
	
	function kill(){
		this.removeMovieClip();
	}		
	
	// GFX
	
	function drawLine(h){
		var pos = {x:0, y:h, w:this.size.w, h:this.lineHeight };
		FEMC.drawSquare(this,pos,0xFFFFFF);
	}

	
//{	
}