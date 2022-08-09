import flash.display.Sprite;

@:bind
class ArmorBit extends Sprite {
	public function new(){
		super();
	}
}

@:bind
class UserInterface extends Sprite {
	var warningBorder : Sprite;
	public var level : flash.text.TextField;
	public var timebg : flash.display.Sprite;
	public var time : flash.text.TextField;
	public var score : flash.text.TextField;
	public var optTimer : {>flash.display.Sprite,
			_t1:Sprite,
			_t2:Sprite,
			_t3:Sprite,
			_t4:Sprite,
			_t5:Sprite,
			_t6:Sprite,
			_t7:Sprite,
			_t8:Sprite,
			_t9:Sprite,
			_t10:Sprite,
			_t11:Sprite
			};

	var option : Option;
	var ticks : Array<Sprite>;
	var armorBits : Array<ArmorBit>;

	public function new(){
		super();
		score.text = "";
		optTimer.visible = false;
		option = null;
		ticks = [
			optTimer._t1, optTimer._t2, optTimer._t3, optTimer._t4, optTimer._t5, optTimer._t6,
			optTimer._t7, optTimer._t8, optTimer._t9, optTimer._t10, optTimer._t11
		];
		armorBits = new Array();
		for (i in 0...KKApi.val(Game.instance.armor)){
			var bit = new ArmorBit();
			bit.y = 2;
			bit.x = Game.W - (bit.width + 2) * (i + 1);
			armorBits.push(bit);
			addChild(bit);
		}
		warningBorder.visible = false;
		timebg.visible = false;
		time.visible = false;
	}

	public function enableTime(){
		timebg.visible = true;
		time.visible = true;
	}

	public function updateArmorBits(){
		var i = 0;
		for (b in armorBits)
			b.visible = ++i <= KKApi.val(Game.instance.armor);
	}

	public function gotOption( opt:Option ){
		if (option != null){
			optTimer.removeChild(option);
		}
		optTimer.visible = true;
		for (t in ticks)
			t.visible = true;
		optTimer.addChild(opt);
		opt.x = 0;
		opt.y = -2;
		option = opt;
	}

	public function update( now:Float ){
		warningBorder.visible = Game.instance.warZone.visible;
		if (option != null && Game.instance.activeOption == null){
			optTimer.removeChild(option);
			option = null;
			optTimer.visible = false;
		}
		else if (option != null){
			var duration = option.time;
			var done = now - option.start;
			var perTick = duration / (ticks.length+1) ;
			var nticks = Math.floor( (duration - done) / perTick );
			for (i in 0...ticks.length)
				ticks[i].visible = i < nticks;
		}
	}
}