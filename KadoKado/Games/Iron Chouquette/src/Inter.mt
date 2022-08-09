class Inter{
	var dm:DepthManager;
	var root:MovieClip;
	var h:Hero
	
	var ico:{>MovieClip, wheel:MovieClip}
	
	function new(mc){
		root = mc
		dm = new DepthManager(root)
		root._x = Cs.mcw
	}
	
	function update(){
		if(h.secondary.selected!=null ){
			
			if(ico==null)ico=downcast(dm.attach("mcIcon",1));
		
			ico._alpha = (h.secondary.ammo==0)?50:100
			
			ico.gotoAndStop( string(h.secondary.selected+1));
			var frame = 1+int((h.secondary.ammo/100)*40);

			ico.wheel.gotoAndStop(string(frame));
		}
	}

}