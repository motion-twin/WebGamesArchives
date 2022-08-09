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
		if(h.secSelected!=null ){

			if(ico==null)ico=downcast(dm.attach("mcIcon",1));

			ico._alpha = (h.secAmmo==0)?50:100

			ico.gotoAndStop( string(h.secSelected+1));
			var frame = 1+int((h.secAmmo/100)*40);

			ico.wheel.gotoAndStop(string(frame));
		}
	}

}