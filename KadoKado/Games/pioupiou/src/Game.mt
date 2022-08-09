class Game { //}

	var mc : MovieClip;
	var level : Level;	
	var hero : Hero;
	var dmanager : DepthManager;
	var interf : DepthManager;
	var bg : MovieClip;
	var meter : MovieClip;
	var scroll : MovieClip;
	var data : { $b : Array<int>, $l : int };

	function new(mc) {
		this.mc = mc;
		bg = Std.attachMC(mc,"bg",0);
		scroll = Std.createEmptyMC(mc,1);
		dmanager = new DepthManager(scroll);
		interf = new DepthManager(Std.createEmptyMC(mc,2));
		meter = interf.attach("meter",10);
		setMeter(0);
		level = new Level(this);
		hero = new Hero(this);
		data = { $b : [0,0,0], $l : 0 };
	}

	function setMeter(n : int) {
		downcast(meter).field.text = n+"$M".substr(1,1);
	}

	function main() {
		level.main();
		hero.main();
	}

	function destroy() {
	}
//{
}