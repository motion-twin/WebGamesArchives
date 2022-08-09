class win.Ghost extends MovieClip{//}
	
	var pos:Object;
	var decalSizeX:Number;
	var decalSizeY:Number;

	//MovieClip
	var c1:MovieClip;
	var c2:MovieClip;
	var c3:MovieClip;
	var c4:MovieClip;
	var s1:MovieClip;
	var s2:MovieClip;
	var s3:MovieClip;
	var s4:MovieClip;
	
	function Ghost(){
	}
	
	/*-----------------------------------------------------------------------
		Function: updateSize()
	 ------------------------------------------------------------------------*/
	function updateSize(){
		c2._x = this.pos.w;
		c3._x = this.pos.w;
		c3._y = this.pos.h;
		c4._y = this.pos.h;
		s1._width = this.pos.w-20;
		
		s2._x = this.pos.w 
		s2._height = this.pos.h-20;
		
		s3._y = this.pos.h
		s3._width = this.pos.w-20;
		
		s4._height = this.pos.h-20;	
	}

	/*-----------------------------------------------------------------------
		Function: watchSize()
	 ------------------------------------------------------------------------*/
	function watchSize(w,h){
		this.pos.w = Math.max(this._xmouse+this.decalSizeX, w)
		this.pos.h = Math.max(this._ymouse+this.decalSizeY, h)
		//_root.test+="this.decalSizeX"+this.decalSizeX+" -- w:"+w+"\n"
		this.updateSize()	
	}	
	
//{	
}
