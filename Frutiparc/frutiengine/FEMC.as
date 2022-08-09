
class FEMC{//}

	static function setColor(mc,o,negFlag){
		//var col;
		//col = new Object();
		if(o.r != undefined ){
			//if(o.a==undefined)o.a=255;
			if(o.a==undefined)o.a=0;
			var col ={
				rb:o.r,
				gb:o.g,
				bb:o.b,
				ab:o.a
			}		
		}else if(typeof o == "number"){
	
			col ={
				rb: (o >> 16) & 255,
				gb: (o >> 8) & 255,
				bb: o & 255
			}		
			
			
		}else{
			//_root.test+="setColor Error :"+mc+" o="+o+"("+(typeof o)+")\n"
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
			
		mc.customColor = new Color(mc);
		mc.customColor.setTransform(col);
		
	
	};

	static function setPColor(mc,color,percent){
		//_root.test+="typeof color "+typeof color+"\n"
		if(typeof color == "number"){
			color = FENumber.toColorObj(color);
		}
		
		if(mc.colorObject==undefined){
			mc.colorObject = {
				actual:{
					col:{r:0,g:0,b:0},
					percent:100
				}
			}
			mc.colorObject.col = new Color(mc)
		}
	
		if(color!=undefined)mc.colorObject.actual = { col:color, percent:percent };
		
		var act = mc.colorObject.actual
		
		var coef = (100-act.percent)/100
		var r = act.col.r * coef
		var g = act.col.g * coef
		var b = act.col.b * coef
		
		
		var tr = {
			ra:act.percent,
			ga:act.percent,
			ba:act.percent,
			aa:100,	
			rb:r,
			gb:g,
			bb:b,
			ab:0
		}

		mc.colorObject.col.setTransform(tr)
		
	};	

	static function killColor(mc){
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
		mc.customColor.setTransform(col)
	};
	
	/*
	Function: morphToButton
		todo
	*/
	static function morphToButton(mc){
	
		mc.onRollOver = function(){
			this.gotoAndStop(2)
			this.onFrutiRollOver()
		}
		mc.onRollOut = function(){
			this.gotoAndStop(1)
			this.onFrutiRollOut()
		}
		mc.onDragOut = function(){
			this.gotoAndStop(1)
			this.onFrutiDragOut()
		}
		mc.onPress = function(){
			this.gotoAndStop(3)
			this.onFrutiPress()
		}
		mc.onRelease = function(){
			this.gotoAndStop(2)
			this.onFrutiRelease()
		}
		mc.onReleaseOutside = function(){
			this.gotoAndStop(1)
			this.onFrutiReleaseOutside()
		}
		mc.stop();
	};

	static function toString(mc,l){
		if(mc == _root) return "_root";
		
		if(l == undefined){
			return "[MovieClip: "+mc._parent.toString(l+1)+"."+mc._name+"]";
		}else{
			if(l > 10){
				return "..";
			}else{
				return mc._parent.toString(l+1)+"."+mc._name;
			}
		}
	};
	
	
	//---------  FONCTIONS DE DESSINS  ----------------------
	/*
	Function: initDraw
		todo
	*/
	static function initDraw(mc){
		mc.lineStyle()
		mc.lastColor=0x000000
	}
	
	/*
	Function: drawSquare
		todo
		
	Parameters:
		pos - todo
		col - todo
	*/
	static function drawSquare(mc,pos,col){
		if(col==undefined)col=mc.lastColor;
		
		mc.moveTo(pos.x,pos.y)
		mc.beginFill(col)
		mc.lineTo(pos.x+pos.w,	pos.y		)
		mc.lineTo(pos.x+pos.w,	pos.y+pos.h	)
		mc.lineTo(pos.x,		pos.y+pos.h	)
		mc.lineTo(pos.x,		pos.y		)
		mc.endFill()
	};

	/*
	Function: drawOval
		todo
		
	Parameters:
		pos - todo
		col - todo
	*/
	static function drawOval(mc,pos,col){
		if(col==undefined)col=mc.lastColor;
		var w2 = pos.w/2
		var h2 = pos.h/2
		
		mc.moveTo(pos.x+w2,pos.y)
		mc.beginFill(col)
		mc.curveTo(pos.x+pos.w,	pos.y,		pos.x+pos.w,	pos.y+h2	)
		mc.curveTo(pos.x+pos.w,	pos.y+pos.h,	pos.x+w2,	pos.y+pos.h	)
		mc.curveTo(pos.x,		pos.y+pos.h,	pos.x,		pos.y+h2	)
		mc.curveTo(pos.x,		pos.y,		pos.x+w2,	pos.y		)
		mc.endFill()
	};
	
	/*
	Function: drawSmoothSquare
		todo
		
	Parameters:
		pos - todo
		col - todo
		curve - todo
	*/
	static function drawSmoothSquare(mc,pos,col,curve){
		
		if(curve<=0){
			FEMC.drawSquare(mc,pos,col);
			return;
		}
		
		//if(col==undefined)col=mc.lastColor;
		mc.moveTo(	pos.x+curve,		pos.y									)
		if(typeof col == "number"){
			mc.beginFill(col)
		}else{
			//_root.test+="mc.beginGradientFill\n"
			mc.beginGradientFill( col.type, col.colors, col.alphas, col.ratios, col.matrix );
		}
		mc.lineTo(	pos.x+(pos.w-curve),	pos.y									)
		mc.curveTo(	pos.x+pos.w,		pos.y,			pos.x+pos.w,		pos.y+curve		)
		mc.lineTo(	pos.x+pos.w,		pos.y+(pos.h-curve)							)
		mc.curveTo(	pos.x+pos.w,		pos.y+pos.h,		pos.x+(pos.w-curve),	pos.y+pos.h		)
		mc.lineTo(	pos.x+curve,		pos.y+pos.h								)
		mc.curveTo(	pos.x,			pos.y+pos.h,		pos.x,			pos.y+(pos.h-curve)	)
		mc.lineTo(	pos.x,			pos.y+curve								)
		mc.curveTo(	pos.x,			pos.y,			pos.x+curve,		pos.y			)
		mc.endFill()
	}
	
	/*
	Function: drawCustomSquare
		todo
		
	Parameters:
		pos - todo
		col - todo
		flag - todo
	*/
	static function drawCustomSquare(mc,pos,o,chromeFlag){
		
		//_root.test+="draw:mc("+mc+") pos("+pos.w+","+pos.h+") o(o.color("+o.color+"))\n";
		var out = o.outline
		var i = o.inline
		var c = o.curve
		if(out==undefined)out=0;
		if(i==undefined)i=0;
		if(c==undefined)c=0;
		
		//_root.test+="out("+out+"),i("+i+"),c("+c+")"
		/*
		if(flag){
			_root.test+="o.color.main("+o.color.main+")\n"
			_root.test+="o.color.inline("+o.color.inline+")\n"
		}
		*/
		
		if(out>0)FEMC.drawSmoothSquare(	mc, {x:pos.x-out,	y:pos.y-out,	w:pos.w+out*2,	h:pos.h+out*2	},o.color.outline,	c+out 		);
		if(i>0)FEMC.drawSmoothSquare(	mc, {x:pos.x,		y:pos.y,	w:pos.w,	h:pos.h		},o.color.inline,	c		);
		FEMC.drawSmoothSquare(		mc, {x:pos.x+i,		y:pos.y+i,	w:pos.w-i*2,	h:pos.h-i*2	},o.color.main,		Math.max(c-i,0)	);
		
		if(chromeFlag){
			var col = {
				type:"linear",
				colors:[ 0xFFFFFF, 0xFFFFFF ],
				alphas:[ 80, 0 ],
				ratios:[ 0, 0xFF ],
				matrix:{ matrixType:"box", x:pos.x, y:pos.y, w:pos.w, h:10, r:3.14/2}//(45/180)*Math.PI }		
			}
			FEMC.drawSmoothSquare(		mc, {x:pos.x+i,		y:pos.y+i,	w:pos.w-i*2,	h:10	},col,		Math.max(c-i,0)	);	
		}
			
	}
		
	/*
	Function: drawCustomOval
		todo
		
	Parameters:
		pos - todo
		o - todo
	*/
	static function drawCustomOval(mc,pos,o){
		
		//_root.test+="draw:mc("+mc+") pos("+pos.w+","+pos.h+") o(o.color("+o.color+"))\n";
		
		var out = o.outline;
		var i = o.inline;
		if(out==undefined)out=0;
		if(i==undefined)i=0;
		
		if(out>0)FEMC.drawOval(	mc, {x:pos.x-out,	y:pos.y-out,	w:pos.w+out*2,	h:pos.h+out*2	},o.color.outline	);
		if(i>0)FEMC.drawOval(	mc, {x:pos.x,	y:pos.y,	w:pos.w,	h:pos.h		},o.color.inline	);
		FEMC.drawOval(		mc, {x:pos.x+i,	y:pos.y+i,	w:pos.w-i*2,	h:pos.h-i*2	},o.color.main		);
		
	}

	/*
	Function: drawPoly
		todo
		
	Parameters:
		arr - todo
		col - todo
	*/
	static function drawPoly(mc,arr,col){
		
		_root.test+="drawPoly!\n"
		if(col==undefined)col=mc.lastColor;
		var pos = arr[0]
		mc.moveTo(pos.x,pos.y);
		mc.beginFill(col)
		for(var i=1; i<arr.length; i++){
			var pos = arr[i]
			_root.test+="lineTo:"+pos.x+","+pos.y+"\n"
			mc.lineTo(pos.x,pos.y)
		}
		mc.endFill()
	
	}
	
	//-----------------------------------------------------
	
	/*
	Function: addMovieClip
		todo
		
	Parameters:
		n - todo
		attach - todo
	*/
	static function addMovieClip(mc,n,attach){
		mc.depth++
		if(attach){
			mc.attachMovie(n,n+"_"+mc.depth,mc.depth)
		}else{
			mc.createEmptyMovieClip(n+"_"+mc.depth,mc.depth)
		}
		//_root.test+="create :"+mc[n+"_"+mc.depth]+"\n"
		return mc[n+"_"+mc.depth]
	};
	
	/*
	Function: setPos
		todo
		
	Parameters:
		varname - todo
		pos - todo
	*/
	static function setPos(mc,varname,pos){
		mc["_"+varname] = pos;
	};

	/*
	Function: getPos
		todo
		
	Parameters:
		varname - todo
	*/
	static function getPos(mc,varname){
		return mc["_"+varname];
	};
	
	/*
	Function: saveMousePos
		todo
	*/
	static function saveMousePos(mc){
		mc._xmouse_saved = mc._xmouse;
		mc._ymouse_saved = mc._ymouse;
	};
		
//{	
}


