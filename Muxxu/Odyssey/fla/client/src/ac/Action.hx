package ac;
import Protocole;
import mt.bumdum9.Lib;



class Action  {//}
	
	
	var game:Game;
	
	var timer:Int;
	var step:Int;
	var coef:Float;
	var spc:Float;
	
	var sleep:Bool;
	
	
	public var onEndTasks:Void->Void;
	public var onFinish:Void->Void;
	
	var tasks:Array<Action>;
	public var parent:Action;	
	
	
	public function new() {
		
		game = Game.me;
		tasks = [];
		
		step = 0;
		coef = 0;
		spc = 0.1;
		
		sleep = true;
	}
	
	public function add(ac:Action,?onFinish) {
		tasks.push(ac);
		ac.parent = this;
		if ( onFinish != null ) ac.onFinish = onFinish;
	}
	public function insert(ac:Action) {
		tasks.unshift(ac);
		ac.parent = this;
	}
	public function first() {
		parent.tasks.remove(this);
		parent.tasks.unshift(this);
	}
	
	
	public function init() {
	
	}
	
	public function nextStep(?spc) {
		coef = 0;
		step++;
		timer = 0;
		if ( spc != null ) this.spc = spc;
	}
	
	public function update() {
		if (sleep) {
			init();
			sleep = false;
		}
		timer++;
		coef = Math.min(coef + spc, 1);
		//
		if (tasks.length > 0) {
			tasks[0].update();
			
		}else if ( onEndTasks != null ) {
			var f = onEndTasks;
			onEndTasks = null;
			f();
			
		}
		
	}
	
	
	public function kill() {
		if ( parent != null ) parent.tasks.remove(this);
		if ( onFinish != null ) onFinish();
	}
	
	public function ready() {
		return tasks.length == 0;
	}

	// TOOLS
	public function att(mc:SP, depth=-1) {
		if( depth == -1 ) depth = Scene.DP_FX;
		Scene.me.dm.add(mc, depth);
	}	
	
	
	
//{
}






