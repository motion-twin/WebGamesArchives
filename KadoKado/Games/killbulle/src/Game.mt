class Game {

	var root : MovieClip;
	var bg : MovieClip;
	var dmanager : DepthManager;
	var hero : Hero;
	var blobs : Array<Blob>;
	var camera_x : float;
	volatile var tsize : float;
	volatile var level : int;
	var updates : Array<void -> bool>;
	var stats : {
		$b : int,
		$s : int,
		$ts : int
	};

	volatile var blob_timer : float;
	var flash_timer : float;
	var flash_color : int;

	function new(mc) {
		root = mc;
		tsize = 0;
		blob_timer = 0;
		camera_x = Const.WIDTH / 2;
		dmanager = new DepthManager(mc);
		bg = dmanager.attach("bg",0);
		dmanager.attach("bg2",2);
		level = 1;
		stats = {
			$s : 0, $ts : 0, $b : 0
		};
		updates = new Array();
		hero = new Hero(this);
		blobs = new Array();
	}

	function addUpdate(f) {
		updates.push(f);
	}

	function genBlob() {
		var size = (Tools.randomProbas([100,level * 10,level]) + 1) * 50;
		var bid = Tools.randomProbas(Const.BONUS_PROBAS);
		var bonus = null;
		if( level >= Const.BONUS_START_LEVEL && bid > 0 ) {
			bonus = new Bonus(this,bid-1);
			size = 50;
		}
		var b = new Blob(this,size,bonus);		
		if( b.update() ) {
			tsize += size;
			blobs.push(b);
		}
	}

	function flash(color) {
		flash_timer = 100;
		flash_color = color;
	}

	function main() {

		if( blob_timer > 0 )
			blob_timer -= Timer.deltaT;

		if( flash_timer > 0 ) {
			var c = new Color(root);
			flash_timer -= 10 * Timer.tmod;
			if( flash_timer <= 0 )
				c.reset();
			else {
				var d = flash_timer / 100;
				var a = 100;
				c.setTransform({
					ra : a, rb : int((flash_color >> 16) * d),
					ga : a, gb : int(((flash_color >> 8)&255) * d),
					ba : a, bb : int((flash_color & 255) * d),
					aa : 100, ab : 0
				});
			}
		}

		if( Std.random(int((tsize / 100) * (Const.BLOB_PROBAS / Math.sqrt(level)) / Timer.tmod)) == 0 )
			genBlob();
		hero.update();
		var p = Math.pow(0.9,Timer.tmod);
		camera_x = camera_x * p + hero.x * (1-p);
		
		root._x = -Math.min(Math.max(camera_x - 150,0),Const.WIDTH - 300);
		bg._x = -root._x/3;
		
		var i;
		
		if( blob_timer <= 0 ) {
			for(i=0;i<blobs.length;i++)
				if( !blobs[i].update() ) {
					tsize -= blobs[i].size;
					blobs.splice(i--,1);
				}
		}

		for(i=0;i<updates.length;i++)
			if( !updates[i]() )
				updates.splice(i--,1);
	}

	function destroy() {
	}

}
