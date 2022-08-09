class kaluga.MC{//}	
	
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
	
	
	
//{	
}