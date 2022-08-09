class sb.Round extends ScrollBar{//}

	// A RECEVOIR
	
	var color:Object;
	var curve:Number;
	var marginInside:Number;
	var fond:MovieClip;
	var square:MovieClip;
	var shadeSpace:Number
	
	function Round(){}
	
	function init(){
		
		//_root.test+="ScrollBar init\n"
		
		super.init();
		var a = this._ymouse;
		
		this.minSquareSize = 16;
		if(this.size==undefined)	this.size = 12;
		if(this.shadeSpace==undefined)	this.shadeSpace = 1;
		if(this.curve==undefined)	this.curve = this.size/2;
		if(this.marginInside==undefined)this.marginInside = 0;
		//FEMC.initDraw(this)
		this.createEmptyMovieClip("fond",1)
		this.fond.initDraw();
		this[this.firSizeLong] = this.size+this.margin.side*2
	}
	
	function initSquare(){
		this.createEmptyMovieClip("square",2)
		this.square.initDraw();
		super.initSquare();
	}
	
	function resizeSquare(){
		super.resizeSquare();
		this.drawSquare()
	};
	
	function drawSquare(){
		this.square.clear();
		var pos = {x:0,y:0};
		pos[this.firSize] = this.size - this.marginInside*2;
		pos[this.dirSize] = this.squareLong;
		
		//var style = this.win.style.global
		FEMC.drawSmoothSquare(this.square,pos,this.color.fore.shade,this.curve)
		pos[this.fir] += this.shadeSpace;
		pos[this.dir] += this.shadeSpace;
		pos[this.firSize] -= this.shadeSpace*2;
		pos[this.dirSize] -= this.shadeSpace*2;
		FEMC.drawSmoothSquare(this.square,pos,this.color.fore.main,this.curve-this.shadeSpace);		
	}
	
	function buildScrollBar(){
		//_root.test+="buildScrollBar\n"
		super.buildScrollBar();
		
		this.fond.clear();
		var pos = new Object();
		var style = this.win.style[this.mainStyleName];
		pos[this.fir] = this.mask[this.firSize]+this.margin.side;
		pos[this.dir] = this.margin.top;
		pos[this.firSize] = this.size;
		pos[this.dirSize] = this.long;
		//FEMC.setColor(this,style.color.inline,this.curve)
		FEMC.drawSmoothSquare(this.fond,pos,this.color.back.dark,this.curve);
		pos[this.fir] += this.shadeSpace;
		pos[this.dir] += this.shadeSpace;
		pos[this.firSize] -= this.shadeSpace*2;
		pos[this.dirSize] -= this.shadeSpace*2;
		FEMC.drawSmoothSquare(this.fond,pos,this.color.back.shade,this.curve-this.shadeSpace);
		
		
		this[this.firSizeLong] = this.size+this.margin.side*2
		this[this.dirSizeLong] = this.mask[this.dirSize]
	};


//{	
}


/*


//--------------------- ScrollBar sbWindow -------------------

function sbWindowClass(){
	this.init();
}
sbWindowClass.prototype = new scrollBarClass();
Object.registerClass("sbWindow",sbWindowClass)

sbWindowClass.prototype.init = function(){
	super.init();
	
	this.minSquareSize=10;
	
	if(this.margin){
		this.bg._x = this.margin.left;
		this.top._x = this.margin.left;
		this.bot._x = this.margin.left+16;
		this.square._x = this.margin.left;
		this.margin.top = this.margin.top+16;
		this.square._y = this.margin.top+16;
	}	
}
sbWindowClass.prototype.buildScrollBar = function(){
	this.long = Math.round( this.mask[this.dirSize] - (32+this.margin.top+this.margin.bottom) );
	this.bot._y = this.margin.top+32+this.long;
}

//--------------------- ScrollBar sbRoundSlot -------------------

function sbRoundSlotClass(){
	this.init();
}
sbRoundSlotClass.prototype = new scrollBarClass();
Object.registerClass("sbRoundSlot",sbRoundSlotClass)

sbRoundSlotClass.prototype.init = function(){
	super.init();
	this.minSquareSize=16;
	if(this.color==undefined){
		this.color = {
			square:ftSwatch[0],
			bg:ftSwatch[4]
		}
	}
	this.square.setcolor(this.color.square);
	this.bg.setcolor(this.color.bg);
	
	if(this.margin){
		this.bg._x = this.margin.left;
		this.square._x = this.margin.left;
		this.margin.top = this.margin.top;
		this.square._y = this.margin.top;
	}
	this.bg.top.gotoAndStop(1);
	this.bg.mid.gotoAndStop(1);
	this.bg.bot.gotoAndStop(1);
	this.square.top.gotoAndStop(1);
	this.square.mid.gotoAndStop(1);
	this.square.bot.gotoAndStop(1);
	
};
sbRoundSlotClass.prototype.resizeSquare = function(){
	this.square.mid._height = Math.max( Math.round(this.long * this.sizeRatio), this.minSquareSize )-16;
	this.square.bot._y = this.square.mid._height+8
};
sbRoundSlotClass.prototype.buildScrollBar = function(){
	this.bg.mid._height = Math.round( this.mask[this.dirSize]-(16+this.margin.top+this.margin.bottom));
	this.bg.bot._y = 8+this.bg.mid._height
};



*/










