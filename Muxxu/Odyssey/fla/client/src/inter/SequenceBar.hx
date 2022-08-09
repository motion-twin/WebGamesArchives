package inter;
import Protocole;
import mt.bumdum9.Lib;
using mt.bumdum9.MBut;


class SequenceBar extends SP {//}

	public static var WIDTH = 20;
	public static var HEIGHT = Scene.HEIGHT;
	
	var sequence:Array<MC>;
	
	var mon:Monster;
	
	public function new(mon:Monster) {
		this.mon = mon;
		super();
		x = Game.me.fgs[0]._timeline.x;
		sequence = [];
		
		/*
		var gfx = graphics;
		gfx.beginFill(0,0.5);
		gfx.drawRect(0, 0, WIDTH, HEIGHT);
		*/
	}
	

	public function maj() {
		for ( el in sequence ){
			el.removeEvents();
			removeChild(el);
		}
		sequence = [];
		
		var a = [];
		for ( ac in mon.firstChain ) a.push(ac);
		
		var k = 0;
		while ( a.length < 10 ) {
			var id = (k++ + mon.sequenceId) % mon.sequence.length;
			a.push(mon.sequence[id]);
		}
		
		var k = 0;
		var max = 8;
		var alpha = 1.0;
		for ( ac in a ) {
			var el = new ActionIcons();
			
			el.gotoAndStop( Type.enumIndex(ac) + 1 );
			el.x = 52 - k*17 ;
			el.y = 5;
			
			el.filters = [new flash.filters.DropShadowFilter(1, 45, 0, 1, 0, 0, 100)];
			addChild(el);
			sequence.push(el);
			if( k > 0 )	el.alpha = (1.2 - k / max)*0.5;
			k++;
			
			//if ( k++ > 0) el.alpha = 0.5;
			
			var data = Data.ACTIONS[Type.enumIndex(ac)];
			
			var hint = "<div class='monster_action'><h1><img src='"+Main.path+"/img/actions/action_"+Type.enumIndex(ac)+".png' alt='"+data.name+"' /> " + data.name + "</h1><p>" + data.desc + "</p></div>";
			Game.me.makeHint(el, hint);
		
			if ( k == max) break;
		}
	}

	
//{
}