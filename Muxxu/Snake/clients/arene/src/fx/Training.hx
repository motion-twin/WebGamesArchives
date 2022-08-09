package fx;
import Protocole;
import mt.bumdum9.Lib;

class Training extends Fx {//}
	
	var lifetime:Float;
	var buts:Array<But>;
	var box:flash.display.Sprite;
	var fieldControl:flash.text.TextField;
	static public var me:Training;
	
	public function new() {
		me = this;
		super();
		
		// BOX
		box = new flash.display.Sprite();
		Game.me.dm.add(box, 0);
		
		// BUT
		buts =  [];
		var but = new But(Lang.OPTIONS, Game.me.togglePause,null,null,4 );
		but.x = 28;
		but.y = 74;
		but.mx = 2;
		Col.setColor(but, 0, 20);
		box.addChild(but);
		buts.push(but);
		
		var but = new But(Lang.QUIT, leave,null,null,4 );
		but.x = 28;
		but.y = 90;
		but.mx = 2;
		Col.setColor(but, 0, 20);
		box.addChild(but);
		buts.push(but);
		
		
		// STAGE
		new fx.IncWidth(48);
		new fx.IncHeight(-8);
		
		// FIELDCONTROL
		fieldControl = Cs.getField(0xCCFF88, 8, -1, "nokia");
		fieldControl.y = Cs.mch;
		box.addChild(fieldControl);
		
	}
	
	public override function update() {
		if( Panel.me != null ) return;
		for( but in buts )but.update();
		
		// CONTROL DESC
		if( fieldControl.y > Cs.mch - 13 ) fieldControl.y--;
		fieldControl.htmlText = Lang.DESC_CONTROL[ Type.enumIndex(Game.me.controlType)];
		fieldControl.width = fieldControl.textWidth + 3;
		fieldControl.x = Std.int((Cs.mcw-fieldControl.width)*0.5);
		
		// CLEAN BLOOD
		if( Game.me.gtimer % 2 == 0 ) {
			var bmp = Stage.me.gore.bitmapData;
			var ct = new flash.geom.ColorTransform( 1, 1, 1, 1, 0, 0, 0, -10);
			var ct = new flash.geom.ColorTransform( 1, 1, 1, 1, 0, 0, 0, -10);
			bmp.colorTransform(bmp.rect,ct);
			Stage.me.renderBg(bmp.rect);
		}
	
	}

	function leave() {
		if( Panel.me != null ) return;
		kill();
		if(sn.dead) {
			Game.me.endGame();
			return;
		}
		Game.me.exit();
		

	}
	
	
	override function kill() {
		super.kill();
		box.parent.removeChild(box);
	}
	
	
//{
}



//








