import Protocole;
import mt.bumdum9.Lib;
import Game;

class Inter {//}
	
	public var width:Float;
	
	public var score:pix.Text;
	public var timer:flash.text.TextField;
	public var frutibar:Frutibar;
	
	var shields:Array<pix.Sprite>;
	
	public var root:flash.display.Sprite;
	public static var me:Inter;
	
	public function new() {
		me = this;
		root = new flash.display.Sprite();
		Game.me.dm.add(root, Game.DP_INTER);
		root.x = Game.MARGIN;
		root.y = -100;
		
		width = Stage.me.width;
		var shadowFilter = new flash.filters.DropShadowFilter(1, 90, 0x004400, 1, 0, 0, 4);
		var x = 0;
		

		
		// SCORE
		score = new pix.Text(Gfx.fontD);
		root.addChild(score);
		score.x = x;
		score.y = 5 ;
		score.ec += 1;
		score.filters = [shadowFilter];
		majScore();
		x += 39;
		
		// TIME
		var tw = 28;
		timer = Cs.getField(0xFFFFFF,8,-1);
		timer.x = Std.int(width-tw);
		timer.y = 1;
		timer.text = "00:00";
		timer.width = timer.textWidth + 5;
		root.addChild(timer);
		timer.filters = [shadowFilter];
		
	
		// SHIELD
		shields = [];
		for( i in 0...Game.me.shieldMax ) {
			var sp = new pix.Sprite();
			sp.drawFrame(Gfx.main.get(0, "shield"),0,0);
			sp.x = x;
			sp.y = 2;
			root.addChild(sp);
			x += 8;
			shields.push(sp);
		}
		x += 1;
		
		// FRUTIBARRE
		frutibar = new Frutibar( Std.int(width-100), 0 );
		frutibar.x = x;
		frutibar.y = 2;
		majFrutipower(0);
		
		
	}
	public function majShields() {
		var count = Game.me.shield;
		var coef = Game.me.shieldCoef;
		
		for( sh in shields ) {
			var frame = 0;
			if( count > 0 ) {
				count--;
				frame = 9;
			}else if( coef > 0 ) {
				frame = Std.int(coef * 9);
				coef = 0;
			}
			sh.drawFrame( Gfx.main.get(frame, "shield") );
		}
	}
	public function majFrutipower(c) {
		frutibar.set(c);
		//if ( Game.FRUTIPOWER_PREVIEW ) Game.me.majFrutipowerPreview();
	}
	public function majScore() {
		var str = Std.string(Game.me.score);
		while (str.length < 6) str = "0" + str;
		score.setText(str);
		if( Game.me.score == 0 ) return;
		score.setWave(0, 2, 40, 90, 0.8);
	}
	
	public function updateChrono(time:Float) {
		timer.text = Cs.formatTime(time);
		Game.me.gameLog.chrono = time;
	}
	
	// MOUSE ICON
	public var mouseIcon:Part;
	public function updateMouseIcon() {
		if( Game.me.controlType != CT_MOUSE || Game.me.demo ||  Game.me.mode == GM_REPLAY ) {
			if(mouseIcon != null ) {
				mouseIcon.kill();
				mouseIcon = null;
			}
			flash.ui.Mouse.show();
			return;
		}

		if( mouseIcon == null ) {
			mouseIcon = Part.get();
			mouseIcon.sprite.setAnim(Gfx.main.getAnim("mouse_icon"));
			mouseIcon.sprite.anim.stop();
			mouseIcon.dropShade();
			Stage.me.dm.add(mouseIcon.sprite, Stage.DP_FX);
		}
		
		var pos = Cs.getMousePos(Stage.me.root);
		pos.x += fx.Brandy.DECAL.x;
		pos.y += fx.Brandy.DECAL.y;
		pos = Stage.me.clamp(pos.x, pos.y, 5);
		
		mouseIcon.x = pos.x;
		mouseIcon.y = pos.y;

		
		var visible = Stage.me.isIn(pos.x, pos.y, 8);
		if( visible ) 	flash.ui.Mouse.hide();
		else			flash.ui.Mouse.show();
		
	}
	
	public function setThrust(flag) {
		if( mouseIcon == null ) return;
		mouseIcon.sprite.anim.play(flag?1:0);
		if( flag && Game.me.gtimer % 10 == 0 ) new fx.Flash(mouseIcon.sprite);
	}


	
	
//{
}








