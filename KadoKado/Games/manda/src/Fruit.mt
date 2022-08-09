class Fruit extends Item {
	
	var dmanager : DepthManager;
	var add_queue : bool;
	
	function new(id,mc,dman) {
		super(id,mc,6 + (Std.random(200)/100));
		scale = 0.75;
		add_queue = true;
		dmanager = dman;
	}

	static function basePoints(id) {
		id++;
		if( id <= 25 )
			return id * KKApi.val(Const.C5);
		else if( id <= 60 )
			return KKApi.val(Const.C200) + (id - 25) * KKApi.val(Const.C10);
		else if( id <= 100 )
			return KKApi.val(Const.C700) + (id - 60) * KKApi.val(Const.C20);
		else if( id <= 145 )
			return KKApi.val(Const.C1900) + (id - 100) * KKApi.val(Const.C30);
		else if( id <= 170 )
			return KKApi.val(Const.C4000) + (id - 145) * KKApi.val(Const.C50);
		else
			return KKApi.val(Const.C6000) + (id - 170) * KKApi.val(Const.C100);
	}

	function points() {
		return KKApi.const(basePoints(id));
	}

	function createShade() {
		var shade = dmanager.attach("fruit",Const.PLAN_FRUITS_SHADE);
		shade.gotoAndStop("ombre");
		downcast(shade).f.gotoAndStop(id+1);
		return shade;	
	}

}