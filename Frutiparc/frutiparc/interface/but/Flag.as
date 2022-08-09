class but.Flag extends But{//}
	
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

	var flActive:Boolean;
	var variable:String;
	
	var crtPos:Number;

	
	/*-----------------------------------------------------------------------
		Function: Push()
		constructeur
	------------------------------------------------------------------------*/
	function Flag(){
		this.init();
	};
	
	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/	
	function init(){
		if(this.flActive == undefined) this.flActive = false;
		if(this.outline == undefined)this.outline = 2;
		if(this.curve == undefined)this.curve = 4;
		if(this.color == undefined)this.color = 0xDDDDDD;
		if(this.frame == undefined)this.frame = 1;
				
		this.attachMovie(this.link,"gfx",2,this.initObj)
		this.gfx._x = this.outline
		this.gfx._y = this.outline;
		this.gfx.icon.gotoAndStop(Number(this.frame));
		
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
		
		this.updateActive();
	};
	
	/*-----------------------------------------------------------------------
		Function: setPos(y)
	------------------------------------------------------------------------*/	
	function setPos(y){
		this.gfx._y = this.outline+y+((this.flActive && y == 0)?1:0);
		this.crtPos = y;
	};
	
	function updateActive(){
		if(this.flActive){
			this.gfx.gotoAndStop(2);
		}else{
			this.gfx.gotoAndStop(1);
		}
		this.setPos(this.crtPos);
	}
	
	function toggle(){
		this.doc.setVariable(this.variable,!this.flActive)
		this.updateActive();
	}
	
	function valSetTo(v){
		this.flActive = v;
		this.updateActive();
	}	
	

//{	
};
