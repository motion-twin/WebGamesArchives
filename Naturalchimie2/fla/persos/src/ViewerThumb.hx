class ViewerThumb {
	
	static var viewer : ViewerThumb;
	public var dm : mt.DepthManager ;
	
	
	var face 		: String;
	var thumb 		: Display;
	var thumbMC		: flash.MovieClip;
	
	static var DP_EDITOR_PERSO	 = 2 ;
	
	
	static function main(){
		if (haxe.Firebug.detect())
			haxe.Firebug.redirectTraces();
		viewer = new ViewerThumb();
		
	}
	
	function new(){
		init() ;
		//flash.Lib._root.onEnterFrame = mainloop;
	}
		
	function mainloop(){
		thumb.update();
	}
	
	function init(){
		var rootFace = Reflect.field(flash.Lib._root, "face");
		face = if (rootFace != null && face == null) rootFace else if (face != null) face else "85;85;23;72;38;58;77;49;14;72;75;94;78;86;26;11;95;29;31;16;65;27;43;78;63;52;01";

		
		dm = new mt.DepthManager(flash.Lib.current) ;
		thumbMC = dm.empty(DP_EDITOR_PERSO);

		thumbMC._x = -Cs.THUMBW/2;
		thumbMC._y = 0;
			
		thumb = new Display(thumbMC);
		thumb.initThumb(110,90,face) ;
	}
	
	

	
	
	
}