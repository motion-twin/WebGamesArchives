/*
$Id: MovieClip.class.as,v 1.26 2003/10/07 07:34:56  Exp $

Class: MovieClip
*/
/*
Function: setColor
	todo
	
Parameters:
	o - todo
	negFlag - todo
*/
MovieClip.prototype.setColor = function(o,negFlag){
	
	//_root.test += "setColor:"+o+" mc:"+this+"\n"
	
	if(o.r){
		if(o.a==undefined)o.a=255;
		var col ={
			rb:o.r,
			gb:o.g,
			bb:o.b,
			ab:o.a
		}		
	}else if(typeof o == "number"){

		var hexa = o.toString(16)
		var col ={
			rb:Number("0x"+hexa.substr(0,2)),
			gb:Number("0x"+hexa.substr(2,2)),
			bb:Number("0x"+hexa.substr(4,2))
		};		
	}else{
		_root.Test+="setColor Error :"+this+"\n"
	}
	if(negFlag){
		col.ra = -100;
		col.ga = -100;
		col.ba = -100;
	}else{
		col.ra = 100;
		col.ga = 100;
		col.ba = 100;
		col.rb -= 255;
		col.gb -= 255;	
		col.bb -= 255;	
	}
	
	
	this.customColor = new Color(this);
	this.customColor.setTransform(col);

};
ASSetPropFlags(MovieClip.prototype, "setColor", 1);

/*
Function: killColor
	todo
*/
MovieClip.prototype.killColor = function(){
		var col ={
			ra:100,
			ga:100,
			ba:100,
			aa:100,
			rb:0,
			gb:0,
			bb:0,
			ab:0
		}	
	this.customColor.setTransform(col)
};
ASSetPropFlags(MovieClip.prototype, "killColor", 1);

/*
Function: morphToButton
	todo
*/
MovieClip.prototype.morphToButton = function(){

	this.onRollOver = function(){
		this.gotoAndStop(2)
		this.onFrutiRollOver()
	}
	this.onRollOut = function(){
		this.gotoAndStop(1)
		this.onFrutiRollOut()
	}
	this.onDragOut = function(){
		this.gotoAndStop(1)
		this.onFrutiDragOut()
	}
	this.onPress = function(){
		this.gotoAndStop(3)
		this.onFrutiPress()
	}
	this.onRelease = function(){
		this.gotoAndStop(2)
		this.onFrutiRelease()
	}
	this.onReleaseOutside = function(){
		this.gotoAndStop(1)
		this.onFrutiReleaseOutside()
	}
	this.stop();
};
ASSetPropFlags(MovieClip.prototype, "morphToButton", 1);

MovieClip.prototype.toString = function(l){
	if(this == _root) return "_root";
	
	if(l == undefined){
		return "[MovieClip: "+this._parent.toString(l+1)+"."+this._name+"]";
	}else{
		if(l > 10){
			return "..";
		}else{
			return this._parent.toString(l+1)+"."+this._name;
		}
	}
};
ASSetPropFlags(MovieClip.prototype, "toString", 1);


//---------  FONCTIONS DE DESSINS  ----------------------
/*
Function: initDraw
	todo
*/
MovieClip.prototype.initDraw = function(){
	this.lineStyle()
	this.lastColor=0x000000
}
ASSetPropFlags(MovieClip.prototype, "initDraw", 1);

/*
Function: drawSquare
	todo
	
Parameters:
	pos - todo
	col - todo
*/
MovieClip.prototype.drawSquare = function(pos,col){
	if(col==undefined)col=this.lastColor;
	this.moveTo(pos.x,pos.y)
	this.beginFill(col)
	this.lineTo(pos.x+pos.w,	pos.y		)
	this.lineTo(pos.x+pos.w,	pos.y+pos.h	)
	this.lineTo(pos.x,		pos.y+pos.h	)
	this.lineTo(pos.x,		pos.y		)
	this.endFill()
};
ASSetPropFlags(MovieClip.prototype, "drawSquare", 1);

/*
Function: drawOval
	todo
	
Parameters:
	pos - todo
	col - todo
*/
MovieClip.prototype.drawOval = function(pos,col){
	if(col==undefined)col=this.lastColor;
	var w2 = pos.w/2
	var h2 = pos.h/2
	
	this.moveTo(pos.x+w2,pos.y)
	this.beginFill(col)
	this.curveTo(pos.x+pos.w,	pos.y,		pos.x+pos.w,	pos.y+h2	)
	this.curveTo(pos.x+pos.w,	pos.y+pos.h,	pos.x+w2,	pos.y+pos.h	)
	this.curveTo(pos.x,		pos.y+pos.h,	pos.x,		pos.y+h2	)
	this.curveTo(pos.x,		pos.y,		pos.x+w2,	pos.y		)
	this.endFill()
};
ASSetPropFlags(MovieClip.prototype, "drawRound", 1);

/*
Function: drawSmoothSquare
	todo
	
Parameters:
	pos - todo
	col - todo
	curve - todo
*/
MovieClip.prototype.drawSmoothSquare = function(pos,col,curve){
	
	//_root.test+="mc("+this+") draw("+pos.x+","+pos.y+","+pos.w+","+pos.h+")"+curve+"\n";
	
	if(curve==0){
		this.drawSquare(pos,col);
		return;
	}
	
	if(col==undefined)col=this.lastColor;
	this.moveTo(	pos.x+curve,		pos.y									)
	this.beginFill(col)
	this.lineTo(	pos.x+(pos.w-curve),	pos.y									)
	this.curveTo(	pos.x+pos.w,		pos.y,			pos.x+pos.w,		pos.y+curve		)
	this.lineTo(	pos.x+pos.w,		pos.y+(pos.h-curve)							)
	this.curveTo(	pos.x+pos.w,		pos.y+pos.h,		pos.x+(pos.w-curve),	pos.y+pos.h		)
	this.lineTo(	pos.x+curve,		pos.y+pos.h								)
	this.curveTo(	pos.x,			pos.y+pos.h,		pos.x,			pos.y+(pos.h-curve)	)
	this.lineTo(	pos.x,			pos.y+curve								)
	this.curveTo(	pos.x,			pos.y,			pos.x+curve,		pos.y			)
	
	this.endFill()
}
ASSetPropFlags(MovieClip.prototype, "drawSmoothSquare", 1);

/*
Function: drawCustomSquare
	todo
	
Parameters:
	pos - todo
	col - todo
	flag - todo
*/
MovieClip.prototype.drawCustomSquare = function(pos,o){
	
	//_root.test+="drawCustomSquare pos:"+pos+" o:"+o+"\n"
	
	var out = o.outline
	var i = o.inline
	var c = o.curve
	
	//_root.test+="out"+out+"\n"
	//_root.test+="i"+i+"\n"
	//_root.test+="c"+c+"\n"
	
	if(out>0)this.drawSmoothSquare(	{x:pos.x-out,		y:pos.y-out,		w:pos.w+out*2,		h:pos.h+out*2	},o.color.outline,	c+out 	);
	if(i>0)this.drawSmoothSquare(	{x:pos.x,		y:pos.y,		w:pos.w,		h:pos.h		},o.color.inline,	c	);
	this.drawSmoothSquare(		{x:pos.x+i,		y:pos.y+i,		w:pos.w-i*2,		h:pos.h-i*2	},o.color.main,		c-i	);
		
		
		
}
ASSetPropFlags(MovieClip.prototype, "drawCustomSquare", 1);

/*
Function: drawCustomOval
	todo
	
Parameters:
	pos - todo
	o - todo
*/
MovieClip.prototype.drawCustomOval = function(pos,o){
	
	var out = o.outline
	var i = o.inline
	var c = o.curve
	
	if(out>0)this.drawOval(	{x:pos.x-out,	y:pos.y-out,	w:pos.w+out*2,	h:pos.h+out*2	},o.color.outline	);
	if(i>0)this.drawOval(	{x:pos.x,	y:pos.y,	w:pos.w,	h:pos.h		},o.color.inline	);
	this.drawOval(		{x:pos.x+i,	y:pos.y+i,	w:pos.w-i*2,	h:pos.h-i*2	},o.color.main		);
	
}
ASSetPropFlags(MovieClip.prototype, "drawCustomOval", 1);

/*
Function: drawPoly
	todo
	
Parameters:
	arr - todo
	col - todo
*/
MovieClip.prototype.drawPoly = function(arr,col){
	
	_root.test+="drawPoly!\n"
	if(col==undefined)col=this.lastColor;
	var pos = arr[0]
	this.moveTo(pos.x,pos.y);
	this.beginFill(col)
	for(var i=1; i<arr.length; i++){
		var pos = arr[i]
		_root.test+="lineTo:"+pos.x+","+pos.y+"\n"
		this.lineTo(pos.x,pos.y)
	}
	this.endFill()

}
ASSetPropFlags(MovieClip.prototype, "drawPoly", 1);

//-----------------------------------------------------

/*
Function: addMovieClip
	todo
	
Parameters:
	n - todo
	attach - todo
*/
MovieClip.prototype.addMovieClip = function(n,attach){
	this.depth++
	if(attach){
		this.attachMovie(n,n+"_"+this.depth,this.depth)
	}else{
		this.createEmptyMovieClip(n+"_"+this.depth,this.depth)
	}
	//_root.test+="create :"+this[n+"_"+this.depth]+"\n"
	return this[n+"_"+this.depth]
};
ASSetPropFlags(MovieClip.prototype, "addMovieClip", 1);

/*
Function: setPos
	todo
	
Parameters:
	varname - todo
	pos - todo
*/
MovieClip.prototype.setPos = function(varname,pos){
	this["_"+varname] = pos;
};
ASSetPropFlags(MovieClip.prototype, "setPos", 1);

/*
Function: getPos
	todo
	
Parameters:
	varname - todo
*/
MovieClip.prototype.getPos = function(varname){
	return this["_"+varname];
};
ASSetPropFlags(MovieClip.prototype, "getPos", 1);

/*
Function: saveMousePos
	todo
*/
MovieClip.prototype.saveMousePos = function(){
	this._xmouse_saved = this._xmouse;
	this._ymouse_saved = this._ymouse;
};
ASSetPropFlags(MovieClip.prototype, "saveMousePos", 1);
