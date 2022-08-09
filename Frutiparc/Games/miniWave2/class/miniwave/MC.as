class miniwave.MC{//}
	
	static function setPColor(mc,color,percent){
		if(typeof color == "number"){
			var hex = color.toString(16)
			var color = {
				r:Number("0x"+(hex.substring(0,2))),
				g:Number("0x"+(hex.substring(2,4))),
				b:Number("0x"+(hex.substring(4,6)))
			}			
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
		
	static function setColor(mc,o,negFlag){

		if(o.r != undefined ){
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
	
	static function drawSmoothSquare(mc,pos,col,curve){
		
		mc.moveTo(	pos.x+curve,		pos.y									)

		mc.beginFill(col)

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
	
//{	
}
























