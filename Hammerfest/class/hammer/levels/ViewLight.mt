class levels.ViewLight {
	static var BASE_SIZE = Data.CASE_WIDTH;

	var world				: levels.SetManager;
	var depthMan			: DepthManager;
	var data				: levels.Data;

	var levelId				: int;
	var size				: float;
	var scalef				: float;

	var mc					: MovieClip;
	var bg					: MovieClip;


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(w, dm, lid) {
		world = w;
		depthMan = dm;
		levelId	= lid;
		data = world.levels[lid];
		if ( data==null ) {
			GameManager.fatal("ERROR: null view");
		}
		scale(1);
	}


	function scale(f:float) {
		scalef = f;
		size = BASE_SIZE*f;
	}


	function attach(vx,vy) {
		mc.removeMovieClip();
		mc = depthMan.empty(Data.DP_BACK_LAYER);
		mc._x = vx;
		mc._y = vy;

		var map = data.$map;

		mc.lineStyle(1,0x999999,100);
		mc.moveTo(-5,0);
		mc.lineTo(BASE_SIZE * Data.LEVEL_WIDTH*scalef-5, 0);
		mc.lineTo(BASE_SIZE * Data.LEVEL_WIDTH*scalef-5, BASE_SIZE * Data.LEVEL_HEIGHT*scalef);
		mc.lineTo(-5, BASE_SIZE * Data.LEVEL_HEIGHT*scalef);
		mc.lineTo(-5, 0);


		for (var cy=0;cy<Data.LEVEL_HEIGHT;cy++) {
			for (var cx=0;cx<Data.LEVEL_WIDTH;cx++) {
				if ( map[cx][cy]>0 ) {
					var x = cx*size + size*0.1;
					var y = cy*size + size*0.1;
					mc.lineStyle(1,0xffffff,100);
					mc.moveTo(x, y);
					mc.lineTo(x+size*0.9, y);
					mc.lineTo(x+size*0.9, y+size*0.9);
					mc.lineTo(x, y+size*0.9);
					mc.lineTo(x, y);

					mc.lineTo(x+size*0.9, y+size*0.9);
					mc.moveTo(x+size*0.9, y);
					mc.lineTo(x, y+size*0.9);

				}
			}
		}
	}


	function strike() {
		mc.lineStyle(2,0x990000,100);
		mc.moveTo(-5,0);
		mc.lineTo(BASE_SIZE * Data.LEVEL_WIDTH*scalef-5, BASE_SIZE * Data.LEVEL_HEIGHT*scalef);
		mc.moveTo(BASE_SIZE * Data.LEVEL_WIDTH*scalef-5, 0);
		mc.lineTo(-5, BASE_SIZE * Data.LEVEL_HEIGHT*scalef);
	}


	/*------------------------------------------------------------------------
	DESTRUCTION
	------------------------------------------------------------------------*/
	function destroy() {
		mc.removeMovieClip();
	}
}