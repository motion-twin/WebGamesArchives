class cp.Counter extends Component{//}

	var iconSize:Number = 20;
	
	var value:String;
	var textStyle:Object;
	var ecart:Number;
	var align:String;
	
	var field:MovieClip;
	var icon:MovieClip;
	
	// DEBUG
	// var marker:MovieClip;
	
	
	function Counter(){
		this.init();
	}
	
	function init(){
		//this.flMarker = true;
		//_root.test+="counterInit("+this.iconSize+")\n"
		if( this.ecart == undefined )this.ecart=2;
		if( this.align == undefined )this.align="right";
		if( this.value == undefined )this.value="---"
		
		super.init();
		
	}
	
	function genContent(){
			
		super.genContent();
		//_root.test+="genCounterConent textStyle:"+this.textStyle+"\n"
		var textInfo = new TextInfo(this.textStyle);
		textInfo.textFormat.align  = this.align;
		
		var policeSize = textInfo.textFormat.size;
		var h = Math.max(textInfo.textFormat.size,this.iconSize);
		this.min.h = h;
		
		textInfo.pos = { x:0, y:-1, w:400, h:h };		
		textInfo.attachField(this,"field",24);
		this.field.variable = "value";
		this.field._y = 0//(h-(policeSize+4))/2;
		
		this.attachMovie("iconCounter","icon",40);
		this.icon._y = (h-this.iconSize)/2 -2;
		
	}
	
	function updateSize(){
		super.updateSize();
		if(this.align == "left"){
			this.icon._x = this.ecart;
			this.field._x = this.iconSize+this.ecart;
			this.field._width = this.width-(this.iconSize+(this.ecart*3));
		}else if(this.align == "center"){
			var w = this.field.textWidth+4+this.ecart+this.iconSize
			this.field._width = this.field.textWidth+2
			this.field._x = (this.width-w)/2
			this.icon._x = this.field._x + this.field._width + this.ecart
		}else{
			this.icon._x = this.width-(this.iconSize+this.ecart+4);
			this.field._x = this.ecart;
			this.field._width = this.width-(this.iconSize+(this.ecart*3)-2);
		}
	}
	
	function setKikooz(n){
		this.value = String(n)
		if(this.align=="center")this.updateSize();
	}
//{
}