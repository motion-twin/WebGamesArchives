class but.TextBasic extends but.Text{//}
	
	// CONSTANTE
	var iconMargin:Number = 2;
	
	var behavior;
	var carre;
	
	// PARAMS
	var flBackground:Boolean;
	//var flTrace:Boolean;
	var bgColor:Number;
	var iconInfo:Object;	
	
	// MOVIECLIP
	var icon:MovieClip;
	
	/*-----------------------------------------------------------------------
		Function: TextBasic()
	------------------------------------------------------------------------*/	
	function TextBasic(){
		this.init();
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	------------------------------------------------------------------------*/	
	function init(){
		if(this.height == undefined)this.height = 20;
		super.init();
		/*
		_root.test+="butTextBasicInit\n"
		_root.test+="- text:"+this.text+"\n"
		_root.test+="- textInfo:"+this.textInfo+"\n"
		_root.test+="- textStyle:"+this.textStyle+"\n"
		_root.test+="- width:"+this.width+"\n"	
		*/		
		//_root.test+="butTextBasicInit this.but:"+this.but+" "+this.height+"\n"
		
		
		//this.height = 60;
		
		this.but._yscale = this.height;
		
		if(this.iconInfo)this.attachIcon();
		
		if(this.behavior==undefined) this.behavior = Standard.getButTextBasicBehavior();		
		this.setBehavior(this.behavior);
		
		if(this.flBackground){
			this.drawBackground(this.bgColor)
		}
		
	};
	
	function attachIcon(){	// a tester
		this.attachMovie(this.iconInfo.link,"icon",33)
		//_root.test+="this.icon("+this.icon+")\n"
		this.icon._x = this.iconMargin + this.iconInfo.size/2
		this.icon._y = this.iconInfo.size/2
	}
	
	function setIconFrame(frameNumber){
		this.icon.gotoAndStop(frameNumber);
	}
	
	/*-----------------------------------------------------------------------
		Function: initBehavior()
	------------------------------------------------------------------------*/	
	function setBehavior(behavior){
		//if(this.flTrace)_root.test+="setBehavior()\n"
		this.behavior = behavior
		
		if(this.behavior.color.base == undefined){
			this.behavior.color.base = this.field.textColor;
		}else{
			this.field.textColor = this.behavior.color.base
		}
		if(this.behavior.color.over == undefined) this.behavior.color.over = this.behavior.color.base;
		if(this.behavior.color.press == undefined) this.behavior.color.press = this.behavior.color.base;
		
		if(this.behavior.type=="colorText"){

			this.setButtonMethod("onRollOver",	this,"setTextColor",this.behavior.color.over);
			this.setButtonMethod("onPress",		this,"setTextColor",this.behavior.color.press);
			this.setButtonMethod("onRollOut",	this,"setTextColor",this.behavior.color.base);
			this.setButtonMethod("onDragOut",	this,"setTextColor",this.behavior.color.base);
			this.setButtonMethod("onReleaseOutside",this,"setTextColor",this.behavior.color.base);
			this.setButtonMethod("onRelease",	this,"setTextColor",this.behavior.color.over);
			
		}else if(this.behavior.type=="colorBackground"){
			
			this.setButtonMethod("onRollOver",	this,"showBackground");
			this.setButtonMethod("onRollOut",	this,"hideBackground");
			this.setButtonMethod("onDragOut",	this,"hideBackground");
			this.setButtonMethod("onReleaseOutside",this,"hideBackground");	
			
			this.setButtonMethod("onRollOver",	this,"setTextColor",this.behavior.color.over);
			this.setButtonMethod("onPress",		this,"setTextColor",this.behavior.color.press);
			this.setButtonMethod("onRollOut",	this,"setTextColor",this.behavior.color.base);
			this.setButtonMethod("onDragOut",	this,"setTextColor",this.behavior.color.base);
			this.setButtonMethod("onReleaseOutside",this,"setTextColor",this.behavior.color.base);
			this.setButtonMethod("onRelease",	this,"setTextColor",this.behavior.color.over);
		}
		
		this.setTextColor(this.behavior.color.base)
		
		
	}
	
	/*-----------------------------------------------------------------------
		Function: updateSize()
	------------------------------------------------------------------------*/	
	function updateSize(){
    super.updateSize();
		
    if(this.flBackground)this.drawBackground(this.bgColor);
		if(this.iconInfo){
			this.field._x = this.iconInfo.size + this.iconMargin*2
		}
	}
	
	/*-----------------------------------------------------------------------
		Function: showBackground()
	------------------------------------------------------------------------*/	
	function showBackground(){
		this.drawBackground(this.behavior.color.bg);
		//this.carre._visible = true;
	}
	
	/*-----------------------------------------------------------------------
		Function: hideBackground()
	------------------------------------------------------------------------*/	
	function hideBackground(){
		//this.carre._visible = false;
		if(this.flBackground){
			this.drawBackground(this.bgColor);
		}else{
			this.clear();
		}
	}

		/*-----------------------------------------------------------------------
		Function: drawBackground()
	------------------------------------------------------------------------*/	
	function drawBackground(col){

		this.clear();
		pos = {x:0,y:0,w:this.width,h:this.height}
		FEMC.drawSquare(this,pos,col)
	}	
	
	
	
	
//{
};












