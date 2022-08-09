class cp.FBConsole extends Component{//}
	

	//VARIABLES
	var val:Number;
	var id:Number;
	//var pal:Array;
	var style:Object;
	//var info:Object;

	//MOVIECLIPS
	var left:but.Push;
	var right:but.Push;
	var animList:AnimList;
	var colorSample:MovieClip;
	var field:TextField;
	//REFERENCES
	var parent:MovieClip;
	
	
	function FBConsole(){
		this.init();
	}
	
	function init(){
		//_root.test+="FBC("+this.val+")\n"
		super.init();
		this.animList = new AnimList();
		//this.info = this.parent.info[this.id]
		this.attachArrow();
		if(this.parent.info[this.id].type=="color"){
			this.attachSampleColor();
		}else{
			this.attachText();
		}
	}
	
	function attachArrow(){
		var param = {
			link:"butPushSmallPink",
			frame:11,
			buttonAction:{
				onPress:[{obj:this,method:"incValue",args:-1}]
			}
		}
		this.attachMovie("butPush","left",20,param);
		var param = {
			link:"butPushSmallPink",
			frame:10,
			buttonAction:{
				onPress:[{obj:this,method:"incValue",args:1}]
			}
		}		
		//param.frame = 10;
		//param.buttonAction.onPress[0].args = 1;
		this.attachMovie("butPush","right",21,param);	
		
	}
	
	function incValue(inc){
		var max = 0
		if(!isNaN(this.parent.info[this.id].max))max=this.parent.info[this.id].max; 
		//_root.test="incValue("+inc+")\n"
		//_root.test+=" - max:"+max+"\n"
		//_root.test+=" - this.parent.info[this.id].max:"+this.parent.info[this.id].max+"\n"
		this.val = Math.min(Math.max(0,this.val+inc),max);
		this.parent.setVal(id,this.val);
		if(this.parent.info[this.id].type=="color")this.updateColor();
	}
	
	function attachSampleColor(){
		this.createEmptyMovieClip("colorSample",30)
	};
	
	function attachText(){
		var ti = new TextInfo(this.style.textFormat.font);
		
		//ti.pos = { x:this.height, y:0, w: ,h:this.height };
		ti.textFormat.align = "center"
		ti.attachField(this,"field",30);
		this.field.text = this.parent.info[this.id].name;	
		_global.debug("Héhéhé: "+this.parent.info[this.id]);
	};
	
	function updateSampleColor(){
		this.clear();
		this.colorSample.clear();
		var m = 10
		//Contour
		var pos = {x:this.height+m,y:2,w:this.width-(this.height*2 + m*2),h:this.height-4}
		var col = this.win.style.global.color.inline;
		FEMC.drawSmoothSquare(this,pos,col,12)
		//Sample
		var s = {
			outline:0,
			inline:2,	
			curve:10,
			color:{
				main:		0xFFFFFF,
				inline:		0xBBBBBB
			}
		}
		pos.x += 2; pos.y += 2;	pos.w -= 4; pos.h -= 4;
		FEMC.drawCustomSquare(this.colorSample,pos,s)
		this.updateColor();

	};

	function updateColor(){
		FEMC.setColor(this.colorSample,_global.generalPalette[this.val])
	}
	
	function updateText(){
		this.field._x = this.height;
		this.field._width = this.width-this.height*2;
		this.field._height = this.height;	
	};
	

	
	function updateSize(){
		super.updateSize();
		this.right._x = this.width - this.height;
		if(this.parent.info[this.id].type=="color"){
			this.updateSampleColor();
		}else{
			this.updateText();
		}
	};
	
	
	
	
//{	
}








