class Jackpot {

	var game : Game;
	var fruits : Array<{ id : int, mc : MovieClip }>;
	var encyclo : Array<int>;
	var slots : Array<{ mc : MovieClip, fruit : MovieClip, id : int }>;
	volatile var nturns : float;
	volatile var coins : int;

	var count2 : int;
	var count3 : int;

	function new(g) {
		game = g;
		coins = 0;
		nturns = 0;
		count2 = 0;
		count3 = 0;
		fruits = new Array();
		encyclo = new Array();
		slots = new Array();
		initSlots();
	}

	function initSlots() {
		var i;
		for(i=0;i<3;i++) {
			var mc = game.interf.attach("jackpot",Const.PLAN_JACKPOT);
			mc._x = 110 + i * 30;
			mc._y = 270;
			var fruit = downcast(mc).f;
			fruit.stop();
			slots.push({
				mc : mc,
				fruit : fruit,
				id : 0
			});
		}
	}

	function addFruit(id) {
		if( id == 75 ) // fruit cloche
			return;
		encyclo.push(id);
		while( encyclo.length > 10 )
			encyclo.shift();
	}

	function start() {
		if( nturns <= 0 )
			nturns = 100;
		else
			coins++;
	}

	function jackpot(id,big) {
		var pts = KKApi.cmult(KKApi.const(Fruit.basePoints(id)),(big ? Const.C20 : Const.C5));
		var _ = new PopScore(160,285,KKApi.val(pts),game.interf.empty(Const.PLAN_POPSCORE));
		KKApi.addScore(pts);
		if( big )
			count3++;
		else
			count2++;
	}

	function main() {
		if( nturns > 0 ) {
			nturns -= Timer.tmod;
			var i;
			for(i=0;i<3;i++)
				if( nturns > (2 - i) * 30  ) {
					var s = slots[i];
					var id = encyclo[Std.random(encyclo.length)];
					s.id = id;
					s.fruit.gotoAndStop(string(id+1));
					s.fruit._y = Std.random(30);
				}
				else
					slots[i].fruit._y = 15;
			if( nturns <= 0 ) {
				var b1 = slots[0].id == slots[1].id;
				var b2 = slots[1].id == slots[2].id;
				var b3 = slots[0].id == slots[2].id;
				if( b1 && b2 && b3 )
					jackpot(slots[0].id,true);
				else if( b1 || b3 )
					jackpot(slots[0].id,false);
				else if( b2 )
					jackpot(slots[1].id,false);
				if( coins > 0 ) {
					coins--;
					nturns = 100;
				}
			}
		}
	}

}