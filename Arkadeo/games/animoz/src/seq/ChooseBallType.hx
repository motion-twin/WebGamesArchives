package seq;
import mt.bumdum9.Lib;
import mt.bumdum9.Rush;
import Protocol;

using Lambda;
using mt.bumdum9.MBut;
using mt.Std;
class ChooseBallType extends mt.fx.Sequence {
	
	static var HELP_COLOR = 0x884400;
	
	var balls:Array<ent.Ball>;
	var pool:Array<ent.Ball>;
	var page:SP;
	var bx:Int;
	var by:Int;
	var title:TF;
	var help:TF;
	
	public function new() {
		super();
		var a = Type.allEnums(BallType);
		//
		for( p in Game.me.pool )
			a.remove(p);
		for( p in Cs.DISABLED_POOL )
			a.remove(p);
		//
		a.shuffle(Game.me.seed.random);
		// PAGE
		page = new SP();
		Game.me.dm.add(page, Game.DP_INTER);
		// SELECTOR
		balls = [];
		var count = 2;
		for( i in 0...count ) {
			var bt = a.pop();
			var b = new ent.Ball(bt);
			var sq = Game.me.getSquare(i == 0?2:5, 3);
			b.setSquare(sq);
			
			new fx.ScaleIn(b);
			balls.push(b);
		}
	}
	
	override function update() {
		super.update();
		switch(step) {
			case 0 :
				if( timer == 50 ) init();
				
			case 1 :	// SELECT
				//var id = api.AKApi.getEvent();
				//if( id != null ) select( balls[id] );
			case 2 :	// LEAVE
				if( title.alpha > 0 ) title.alpha -= 0.1;
				if( timer == 60 ) {
					for( b in pool ) b.kill();
					kill();
					new seq.Play();
				}
			case 99:
		}
	}

	var helpBox:SP;
	function init() {
		nextStep();
		// ACTIONS
		Game.me.bindOnSquareSelected( select );
		if( !api.AKApi.isReplay() )
		{
			function emit(p_sq : Square)
			{
				if( p_sq.getBall() != null )
					Game.me.emitSquareSelectedEvent(p_sq);
			}
			for( b in balls )
			{
				if( b == null || b.square == null ) continue;
				b.square.setAction( callback( emit , b.square),
									callback( over, b ), 
									callback( out, b ) );
			}
		}
		// INSTRUCTIONS
		var f = getField();
		page.addChild(f);
		f.width = Cs.WIDTH;
		//TODO Localisation !
		f.text = Texts.select_animal;
		f.y = 10;
		f.height = 32;
		Filt.glow(f, 2, 8, 0x336622);
		title = f;
		// HELP
		helpBox = new SP();
		page.addChild(helpBox);
		
		var f = new TF();
		var tf = f.getTextFormat();
		tf.font = "verdana";
		tf.align = flash.text.TextFormatAlign.CENTER;
		tf.size = 10;
		tf.color = 0xFFFFFF;
		f.defaultTextFormat = tf;
		f.selectable = false;
		f.width = 300;
		f.text = "";
		f.multiline = f.wordWrap = true;
		helpBox.addChild(f);
		help = f;
		helpBox.filters = [
			new flash.filters.GlowFilter( Col.brighten(HELP_COLOR, 100), 1, 2,2, 10),
			new flash.filters.DropShadowFilter(5, 45, 0, 0.25, 0, 0, 1),
		];
		// POOL
		pool = [];
		var ec = 40;
		bx = (Cs.WIDTH - (Game.me.pool.length - 1) * ec)>>1;
		by = Cs.HEIGHT - 68;
		for( bt in Game.me.pool ) {
			var b = new ent.Ball(bt);
			b.x = bx;
			b.y = by;
			b.updatePos();
			bx += ec;
			pool.push(b);
			MBut.makeBut(b.root, callback(over, b, true), callback(over, b, true), callback(out, b) );
		}
	}
	
	function select( square : Square ) {
		var b = square.getBall();
		out(b);
		pool.push(b);
		Game.me.completePool.push(b.type);
		Game.me.saveState();
		for( b2 in balls ) {
			b2.square.removeActions();
			if( b2 == b ) {
				var e = new fx.TweenEnt(b2, bx, by, 0.05);
				e.curveInOut();
				e.onFinish = allLeave;
			} else {
				//b2.burst();
				var s = new fx.Escape(b2);
			}
		}
		nextStep();
		Game.me.unbindOnSquareSelected(select);
	}
	
	function over(b:ent.Ball, ?up=false) {
		
		var data = ent.Ball.DATA[Type.enumIndex(b.type)];
		var desc = Texts.ALL.get(Std.string(b.type) + "_DESC");
		var name = Texts.ALL.get(Std.string(b.type)+"_NAME");
		help.htmlText = "<b><font size='16' color='"+Col.getWeb(Col.brighten(HELP_COLOR,200))+"'>"+name + "</font></b>\n" + desc;
		helpBox.visible = true;
		helpBox.graphics.clear();
		helpBox.graphics.beginFill(HELP_COLOR);
		help.width = help.textWidth + 12;
		help.height = help.textHeight + 12;
		var ww = Std.int(help.width) >> 1;
		helpBox.graphics.drawRoundRect( -ww, 0, ww * 2, help.textHeight + 12, 8, 8 );
		helpBox.graphics.endFill();
		help.x = -ww;
		
		helpBox.x = b.x;
		helpBox.y = b.y + (up ? -100 : 20);
		
		helpBox.mouseEnabled = false;
		helpBox.mouseChildren = false;
	}
	
	function out(b:ent.Ball) {
		helpBox.visible = false;
	}
	
	function allLeave() {
		var sleep = 0;
		for( b in pool ) {
			var e = new fx.TweenEnt(b, -40, b.y, 0.025);
			e.curveIn(2);
			var e = new mt.fx.Sleep(e, null, sleep);
			sleep += 4;
		}
	}
	
	function getField(color=0xFFFFFF) {
		return TField.get(color, 26, "coaster", 0);
	}
	
	override function kill() {
		super.kill();
		page.parent.removeChild(page);
	}
}
