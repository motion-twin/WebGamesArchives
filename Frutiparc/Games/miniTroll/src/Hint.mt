class Hint{//}

	var fade:float;

	var parent:MovieClip;
	
	var skin:{>MovieClip,bg:MovieClip,field:TextField}
	
	function new(mc,txt,w){

		parent = mc
		skin = downcast( Manager.slot.dm.attach("mcHint", Slot.DP_HINT) )
		
		if( w != null ){
			skin.field.multiline = true;
			skin.field._width = w
		}
		skin.field.text = txt
		if( w == null )	skin.field._width = skin.field.textWidth+4;
		
		skin.field._height = skin.field.textHeight+4;
		
		skin.bg._xscale = skin.field._width+2
		skin.bg._yscale = skin.field._height
		
		if( w == null )skin.bg._yscale-=2;
		
		var dec = 10
		skin._x = Cs.mm( 0, Manager.slot._xmouse-skin.bg._xscale, Cs.mcw-skin.bg._xscale )
		skin._y = Cs.mm( 0, Manager.slot._ymouse-skin.bg._yscale, Cs.mcw-skin.bg._yscale )
	}
	
	function kill(){
		skin.removeMovieClip();
	}

	
//{	
}