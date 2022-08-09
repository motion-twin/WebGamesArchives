class but.Push extends But{//}
	
	var link:String;	// nom de linkage du gfx
	var initObj:Object;	// passé au gfx attaché
	
	var frame:Number;
	var outline:Number;
	var curve:Number;
	var color:Number;
	
	var bg:MovieClip;
	var mask:MovieClip;
	var gfx:MovieClip;
	
	var flTrace:Boolean;	//DEBUG
	
	/*-----------------------------------------------------------------------
		Function: Push()
		constructeur
	------------------------------------------------------------------------*/
	function Push(){
		//_root.test+="initButPush link("+this.link+") initObj("+this.initObj+")\n"
		this.init();
	};
	
	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/	
	function init(){
		//_root.test+="buttonAction obj("+this.buttonAction.obj+") method("+this.buttonAction.method+") args("+this.buttonAction.args+")\n"
		//_root.test+="initButPush\n"
		
		if(this.outline == undefined)this.outline = 2;
		if(this.curve == undefined)this.curve = 4;
		if(this.color == undefined)this.color = 0xDDDDDD;
		if(this.frame == undefined)this.frame = 1;
				
		this.attachMovie(this.link,"gfx",2,this.initObj)
		this.gfx._x = this.outline
		this.gfx._y = this.outline;
		//_root.test+="Number(this.frame)"+Number(this.frame)+" typeof("+typeof Number(this.frame)+")\n"
		this.gfx.icon.gotoAndStop(Number(this.frame));
		//_root.test+="this.gfx"+this.gfx._x+"\n"
		
		if(this.gfx.width)
			var w = this.gfx.width;
		else
			var w = this.gfx._width;
		
		if(this.gfx.height)
			var h = this.gfx.height;
		else
			var h = this.gfx._height;		
		
		this.createEmptyMovieClip("bg",1);
		this.bg.initDraw();
		//if(this.flTrace=="1")_root.test+="h+this.outline*2 ("+h+")\n";	//DEBUG
		FEMC.drawSmoothSquare(this.bg,{x:0,y:0,w:w+this.outline*2,h:h+this.outline*2},this.color,this.curve+this.outline);
		this.createEmptyMovieClip("mask",3);
		this.mask.initDraw();
		FEMC.drawSmoothSquare(this.mask,{x:this.outline,y:this.outline,w:w,h:h},this.color,this.curve);
		
		this.gfx.setMask(this.mask);
		
		this.but = this.gfx;
		
		super.init();
		
		this.setButtonMethod("onRollOut",	this,	"setPos",0);
		this.setButtonMethod("onDragOut",	this,	"setPos",0);
		this.setButtonMethod("onReleaseOutside",this,	"setPos",0);
		this.setButtonMethod("onRollOver",	this,	"setPos",1);
		this.setButtonMethod("onPress",		this,	"setPos",2);
		this.setButtonMethod("onRelease",	this,	"setPos",1);
		
		this.setMin()
	};
	
	/*-----------------------------------------------------------------------
		Function: setPos(y)
	------------------------------------------------------------------------*/	
	function setPos(y){
		//_root.test+="setPos("+y+")\n"
		this.gfx._y = y+this.outline
	};	

//{	
};
