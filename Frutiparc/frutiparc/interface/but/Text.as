class but.Text extends But{//}

	var width:Number;
	var height:Number;
	var textStyle:Object;
	var textInfo:TextInfo;
	var field:TextField;
	var margin;
	var text:String;
	
	function Text(){

	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/	
	function init(){
		//this.flMarker = true
		this.attachMovie("transp","but",80)
		
		super.init();

		if(this.width==undefined)this.width=100;
		if(this.height==undefined)this.height=32;
		if(this.text==undefined)this.text="noText";
		if(this.margin==undefined){
			this.margin = Standard.getMargin();
		}
		this.attachField();		
		this.updateSize();	// SALE
	};
	
	function attachField(){
		
		this.textInfo = new TextInfo(this.textStyle)

		this.textInfo.pos = { x:this.margin.x.min*this.margin.x.ratio, y:0, w:this.width-this.margin.x.min, h:20 };
		this.textInfo.attachField(this,"field",30);	

		this.setText(this.text);
		this.field._height = this.field.textHeight+6;
		var h = this.field._height;
		if(this.margin.min.y!=undefined){
			h+=this.margin.min.y*2;
		}

		if(this.height==undefined){
			this.height = h;
			this.field._y = this.margin.min.y;
		}else{
			this.field._y = (this.height-h)/2;
		}
			
	}
	
	/*-----------------------------------------------------------------------
		Function: updateSize(col)
	------------------------------------------------------------------------*/		
	/*
	function updateSize(){
		
		//_root.test = ">"+this.width+"\n"
		this.field._width = this.width-(this.margin.x.min)
		//_root.test+="this.Button("+this.but+")\n"
		this.but._xscale = this.width
		this.but._yscale = this.height
	}
	*/
	
	/*-----------------------------------------------------------------------
		Function: setTextColor(col)
	------------------------------------------------------------------------*/	
	function setTextColor(col){
		this.field.textColor = col;
	};
	
	/*-----------------------------------------------------------------------
		Function: setText(str)
	------------------------------------------------------------------------*/	
	function setText(str){
		//_root.test+="setText: "+str+"\n"
		if(str == undefined || str.length == 0){
			this.field.text = " ";
		}else{
			this.field.text = str;
		}
		//this.field.text = "youpi";
	}

	function updateSize(){
		super.updateSize()
		this.field._width = this.width
		this.field._height = this.height
		this.but._xscale = this.width
		this.but._yscale = this.height		
	}
	
	
//{	
};
