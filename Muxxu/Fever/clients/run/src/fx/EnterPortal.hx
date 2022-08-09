package fx;
import Protocole;
import mt.bumdum9.Lib;

class EnterPortal extends mt.fx.Fx{//}
	
	var mask:SP;
	var hero:world.Hero;
	var island:world.Island;
	var sq:world.Square;
	var step:Int;
	var timer:Int;

	public function new() {
		super();
		
		hero = World.me.hero;
		island = hero.island;
		sq = hero.sq;
		var hh = 8;
		mask = new SP();
		mask.graphics.beginFill(0xFF0000);
		mask.graphics.drawRect(0, 0, 16, 16+hh);
		island.dm.add(mask, world.Island.DP_ELEMENTS);
		
		var pos = hero.sq.getCenter();
		mask.x = pos.x - 8;
		mask.y = pos.y - (8+hh);
		
		hero.sprite.mask = mask;
		
		step = 0;
	}
	
	override function update() {
		super.update();
		#if dev
		//timer += 10;
		#end
		switch(step) {
			
			case 0: // WALK IN
				var max = 8 - Math.abs( (hero.root.y-8) - mask.y);

				for(  i in 0...Std.int(max) ) {
				
					var p = new pix.Part();
					p.drawFrame(Gfx.fx.get(0, "spark_twinkle"));
					var pos = sq.getCenter();
					var dc = (Math.random() - 0.5) ;
					p.setPos( pos.x + dc* 12, pos.y - 16);
					p.timer = 10 + Std.random(10);
					island.dm.add(p, world.Island.DP_FX);
				
					p.vx = dc * 2;
					p.vy = -Math.random() * 2;
					p.frict = 0.96;
				}
				
				if( hero.root.y - 8 < mask.y && max == 0 ) {
					
					timer = 0;
					step++;
				}
				
			case 1: // WAIT
				if( timer++ >= 12 ) {
					World.me.action = null;
					initFilter();
					step++;
					timer = 0;
				}
			
			case 2: // TWIST
				timer++;
				var c = (timer / 10);
				var bmp = World.me.screen.bitmapData;
				
				var lim = 200;
				for( i in 0...4 ) {
					var color = Col.getRainbow2( ((timer / 20) + i*0.12 ) % 1 );
					if( timer > lim ) color = Col.shuffle(color, timer - lim);
					switch(i){
						case 0 : bmp.fillRect( new flash.geom.Rectangle(0, 0, bmp.width, 1), color );
						case 1 : bmp.fillRect( new flash.geom.Rectangle(0, 0, 1, bmp.height), color );
						case 2 : bmp.fillRect( new flash.geom.Rectangle(0, bmp.height - 1, bmp.width, 1), color );
						case 3 : bmp.fillRect( new flash.geom.Rectangle(bmp.width - 1, 0, 1, bmp.height), color );
					}
					
				}
				
				
				var base = bmp.clone();
				bmp.applyFilter(base, bmp.rect, new flash.geom.Point(0, 0), dis);
				dis.scaleX = c;
				dis.scaleY = c;
				base.dispose();
				
				var co = 1.02;
				var inc = 1;
				bmp.colorTransform(bmp.rect, new flash.geom.ColorTransform(co, co,co, 1, inc, inc, inc, 0));

				

				if( timer > lim + 50 ) 	bigBang();
				
			case 3 : // SCROLL
			
				timer++;
				if( timer%4 == 0 ) scroller.y -= 1;
				#if dev
				//scroller.y-=2;
				#end
				
				if( scroller.y + scroller.height < 80 ) {
					step++;
					buts = [];
					for( i in 0...2 ) {
						var b  = getBut([Lang.rep(Lang.ENDING_EXPLORE,curArp),Lang.rep(Lang.ENDING_LEAVE_TO,newArp)][i]);
						b.x = 40;
						b.y = 100 + i * 20;
						b.addEventListener( flash.events.MouseEvent.CLICK, 	callback(choose, i) );
						buts.push(b);
					}
				}
				
			case 4 : // CHOOSE

			case 5 : // FADE
				var lim = 40;
				if( timer++ > lim ) {
					Col.setColor(base, 0, -(timer - lim));
					Col.setColor(buts[1], 0, Std.int((timer-lim)*0.5) );
				}
				if( timer > 255 + lim ) {
					
					step++;
				}
				
		}
	}
	
	
	
	var dis:flash.filters.DisplacementMapFilter;
	var base:SP;
	var scroller:SP;
	var fieldEnd:TF;
	var newArp:String;
	var curArp:String;
	var buts:Array<SP>;
	
	function initFilter() {
		
		var bmp = World.me.screen.bitmapData;
		var morph = new BMP(bmp.width, bmp.height, false, 0 );
		
		// MORPH
		var cx = morph.width * 0.5;
		var cy = morph.height * 0.5;
		for( x in 0...morph.width ) {
			for( y in 0...morph.height ) {
				var dx = x - cx;
				var dy = y - cy;
				var a = Math.atan2(dy, dx) + 1.57;
				var dist = Math.sqrt(dx * dx + dy * dy);
				var d = 128;
				var r = 128 + Std.int(Math.cos(a) * d);
				var g = 128 + Std.int(Math.sin(a) * d);
				var b = 128;
				var color = Col.objToCol( { r:r, g:g, b:b } );
				morph.setPixel(x, y, color);
			}
		}
		
		//flash.Lib.current.addChild(new flash.display.Bitmap(morph));
		
		dis = new flash.filters.DisplacementMapFilter( morph, new flash.geom.Point(0, 0), 1, 2, 1, 1, flash.filters.DisplacementMapFilterMode.CLAMP );
		
		

		
		
	}
	
	function bigBang() {
		
		var bmp = World.me.screen.bitmapData;
		bmp.fillRect(bmp.rect, 0);
		step++;
		
		//
		base = new SP();
		base.addChild(World.me.screen);
		base.scaleX = base.scaleY = 2;
		scroller = new SP();
		scroller.y = 200;
		
		// FIELD

		var a = Lang.col( Lang.ARCHIPELS[WorldData.me.wid], "#CCFF77");
		var b = Lang.col( Lang.ARCHIPELS[WorldData.me.wid+1], "#FFCC77");
		newArp = b;
		curArp = a;
		
		fieldEnd = Cs.getField(0xFFFFFF, 8, -1, "nokia");
		fieldEnd.wordWrap = true;
		fieldEnd.multiline = true;
		fieldEnd.width = 164;
		fieldEnd.x = (Cs.mcw * 0.5 - fieldEnd.width) * 0.5;
		fieldEnd.htmlText = Lang.ENDING_TEXT+"\n\n\n\n\n"+Lang.rep( Lang.ENDING_QUESTION, a, b);
		fieldEnd.height = fieldEnd.textHeight+10;
		
		
		scroller.addChild(fieldEnd);
		base.addChild(scroller);
		flash.Lib.current.addChild(base);
		
		//
		var e = new mt.fx.Flash(base, 0.02);
		e.curveIn(2);
		e.maj();
		
	}
	function faster(e) {
		if( step == 3 ) scroller.y -= 4;
		timer += 2;
	}
	
	function getBut(str) {
		var but = new SP();
		var f = Cs.getField(0xFFFFFF, 8, -1, "nokia");
		f.htmlText = str;
		f.width = f.textWidth + 3;
		f.height = f.textHeight + 3;
		but.addChild(f);
		base.addChild(but);
		
		var ww = f.width;
		var hh = f.height;
		
		paintBut(but, ww, hh, 0x777777, 2);
		
		but.addEventListener( flash.events.MouseEvent.MOUSE_OVER, 	callback(paintBut, but, ww, hh, 0xFFFFFF, 1) );
		but.addEventListener( flash.events.MouseEvent.MOUSE_OUT, 	callback(paintBut, but, ww, hh, 0x777777, 2) );
		but.buttonMode = true;
		
		
		return but;
	}
	
	function paintBut(but:SP, ww:Float , hh:Float, color:Int, ma:Int, ?e) {
		ma = 2;
		var g = but.graphics;
		g.clear();
		g.beginFill(color);
		g.drawRect( -ma, -ma,  ww+ 2 * ma, hh + 2 * ma);
		g.endFill();
		g.beginFill(0);
		g.drawRect( 0, 0,ww, hh);
		g.endFill();
	}
	
	function choose(id,?e) {
		World.me.send( _EndGame(id) );
		new mt.fx.Flash(buts[id]);
		new mt.fx.Vanish(buts[1 - id]);
		for( b in buts ) {
			b.mouseEnabled = false;
			b.mouseChildren = false;
			b.buttonMode = false;
		}
		step++;
		timer =  0;
	}
	
	
//{
}




















