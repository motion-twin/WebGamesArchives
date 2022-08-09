class Dialog{//}
	
	var x:float;
	var y:float;
	var timer:float;
	var frame:int;
		
	var txt:String;
	var skin:{>MovieClip,field:TextField,cadre:{>MovieClip,pic:MovieClip},pan:MovieClip,pointe:MovieClip}
	
	function new(t){
		txt = t
		timer = 18+t.length*1.9
		x = 4
 		y = 4
		frame = 1
	}
	

	function setSkin(mc){
		skin = mc
		mc.field._width = Math.min(Math.max(70,txt.length*3),130)
		mc.field.text = txt
		mc.field._height = (mc.field.textHeight+1)*1.17
		//mc.field._y = 22-mc.field.textHeight*0.5
		mc._x = x;
		mc._y = y
		mc.gotoAndStop(string(frame))
		
		drawCadre(mc.field._width+1, mc.field._height)
		
	}
	
	function kill(){
		if(skin!=null){
			Manager.slot.dial = null
			skin.removeMovieClip();
		}
	}
	
	function drawCadre(w:float,h:float){
		
		var col = [0xAB9CC9,0xE7E3F0]
		for( var i=0; i<2; i++ ){
			var b = 2-i*2
			var pos = {
				x:-b,
				y:-b,
				w:w+2*b
				h:h+2*b
			}
			drawSmoothSquare(pos,4+2*b,col[i])
		}


		
	}
	
	function drawSmoothSquare(pos:{x:float,y:float,w:float,h:float},curve,col){
		var mc = skin.pan
		mc.moveTo(	pos.x+curve,		pos.y									)
		mc.beginFill(col,100)
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
	
	function setPic(fi){
		skin.cadre = downcast( Std.attachMC( skin, "mcDialogPicture", 1 ) )
		Mc.setPic(skin.cadre.pic,fi.skin)
		skin.cadre._x = - 44
	}

	function setPNJ(id){
		skin.cadre = downcast( Std.attachMC( skin, "mcDialogPNJPicture", 1 ) )
		skin.cadre.gotoAndStop(string(id+1))
		skin.cadre._x = - 44
	}
	
	
	
	
	
	
	
//{	
}