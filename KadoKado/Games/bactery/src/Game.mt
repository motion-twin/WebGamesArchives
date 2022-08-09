class Game {//}

	var root_mc : MovieClip;
	var dmanager : DepthManager;
	var level : Level;
	var lock : bool;
	var sel : Bille;
	volatile var init_timer : float;

	var fList : Array<{mc:MovieClip,prc:float}>
	var pList : Array<Part>

	var stats : {
		$n : int,
		$k : int,
		$m : int,
		$w : int,
		$b : int
	};

	function new(mc) {
		root_mc = mc;
		init_timer = 1;
		dmanager = new DepthManager(mc);
		dmanager.attach("bg",Const.PLAN_BG);
		level = new Level(this);
		level.init();
		stats = {
			$k : 0,
			$n : 0,
			$m : 0,
			$w : 0,
			$b : 0
		};

		// FX
		fList = new Array();
		pList = new Array();

	}

	function onSelect(b : Bille) {
		if( lock || init_timer > 0 )
			return;
		if( sel == null ) {
			b.select(true);
			sel = b;
		} else {
			var s = sel;
			sel.select(false);
			sel = null;
			if( b.x == s.x && b.y == s.y )
				return;
			stats.$n++;
			lock = true;
			level.swap(s,b);
		}
	}

	function main() {
		init_timer -= Timer.deltaT;
		level.main();

		// FX
			// FLASH
			for(var i=0; i<fList.length; i++ ){
				var info = fList[i]
				if(info.prc < 1 ){
					fList.splice(i--,1)
					info.prc = 0
				}
				Mc.setPercentColor(info.mc,info.prc,0xFFFFFF)
				info.prc *= Math.pow(0.85,Timer.tmod)
				//info.prc -= 2+(100-info.prc)*0.5

			}
			// PART
			var list = pList.duplicate();
			for( var i=0; i<list.length; i++ ){

				list[i].update();
			}

	}

	function destroy() {
	}

	// FX
	function flash(mc){
		fList.push({mc:mc,prc:100})
	}

	function newPart(link){
		var p = new Part();
		var d = Const.PLAN_PART
		//if(link=="animBlob")d = Const.PLAN_UNDER;	// :#)
		var mc  = dmanager.attach(link,Const.PLAN_PART)
		p.setSkin(mc);

		p.game = this;
		pList.push(p);
		p.init();

		return p;
	}

//{
}