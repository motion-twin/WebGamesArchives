
import mt.bumdum9.Lib;

private typedef Orc = { sp:pix.Sprite, di:Int, dist:Float };

class SuperKnight extends Game{//}


	static var BASE_SPAWN = 30;

	var cex:Int;
	var cey:Int;
	var knight:pix.Element;
	var di:Int;
	var strike:Int;
	var timer:Int;
	var speed:Float;
	var orcs:Array<Orc>;
	var chief:Orc;
	var ground:BMP;
	
	override function init(dif:Float){
		gameTime =  400;
		super.init(dif);
				
		//X2
		box.scaleX = box.scaleY = 2;
		
		//BG
		bg = new flash.display.MovieClip();
		bg.graphics.beginFill(0x555555);
		bg.graphics.drawRect(0, 0, Cs.mcw, Cs.mch);
		dm.add(bg, 0);
		
		var fr = Gfx.games.get("knight_tile");
		ground = new BMP( Std.int(Cs.mcw * 0.5), Std.int(Cs.mch * 0.5), false, 0x846131 );
		var max = 13;
		var path  = 6;
		var a = [];
		for( x in 0...max ) for( y in 0...max ) {
			if( Math.abs(x - path) <= 1 || Math.abs(y - path) <= 1 ) fr.drawAt(ground, x * 16 -3, y * 16 -2);
			else a.push({x:x,y:y});
		}
		Arr.shuffle(a);
		for( i in 0...32 ) {
			var p = a.pop();
			switch(Std.random(2)){
				case 0 :
					var fr = Gfx.games.get(Std.random(3), "knight_holes");
					fr.drawAt( ground, p.x*16+Std.random(8), p.y * 16+Std.random(8));
				case 1 :
					var fr = Gfx.games.get(4+Std.random(4), "knight_holes");
					fr.drawAt( ground, p.x*16+Std.random(12), p.y * 16+Std.random(12));
			}
		}

		dm.add( new flash.display.Bitmap(ground), 0 );
		
		//
		cex = Std.int(Cs.mcw * 0.25);
		cey = Std.int(Cs.mcw * 0.25);
		
		// KNIGHT
		knight = new pix.Element();
		knight.drawFrame(Gfx.games.get("super_knight"));
		dm.add(knight,1);
		knight.x = cex;
		knight.y = cey;
	
		//
		strike = 0;
		timer = 0;
		speed = 0.5+dif*3;
		orcs = [];
		//
		step = 1;
		
		//
		for( i in 0...3 ) spawn(i);
		update();
		
	}
	

	override function update(){

		super.update();
		
		switch(step) {
			case 1:
				majKnight();
				
				// ORCS
				if( timer -- <= 0 ) spawn();
				var a = orcs.copy();
				for( o in a ) {
					o.dist -= speed;
					var d = Cs.DIR[o.di];
					o.sp.x = cex - d[0] * o.dist;
					o.sp.y = cey - d[1] * o.dist;
					o.sp.pxx();
					if( o.dist < 18 && strike > 0 && di == (o.di+2)%4 ) {
						orcs.remove(o);
						//o.sp.kill();
						o.sp.anim = null;
						o.sp.drawFrame(Gfx.games.get("orc_die"));
						var e = new mt.fx.Blink(o.sp, 12, 4, 4);
						e.onFinish = o.sp.kill;
					}
					if( o.dist < 8 ) {
						chief = o;
						setDir(chief, 0);
						explodeArmor();
						step++;
					}
				}
				if( step == 2 ) {
					for( o in orcs ) {
						o.di = -1;
						o.sp.anim.play(0);
					}
				}
			
			case 2:
				timer ++;
				if( timer == 12 ) {
					knight.visible = false;
					chief.di = -1;
					setDir(chief, 0);
					step++;
				}
				

			case 3:
				for( o in orcs ) {
					var a = 0.25;
					var sp = speed * 2;
					if( o == chief ) {
						sp *= 0.75;

					}else{
						var dx = chief.sp.x - o.sp.x;
						var dy = chief.sp.y - o.sp.y;
						a = Math.atan2(dy, dx);

					}
					o.sp.x += Math.cos(a) * sp;
					o.sp.y += Math.sin(a) * sp;
					o.sp.pxx();
					setDir(o, Cs.getAngleDir(a));
					
					
				}
				
				for( o in orcs ) {
					for (o2 in orcs ) {
						if( o == o2 ) continue;
						var dx = o.sp.x - o2.sp.x;
						var dy = o.sp.y - o2.sp.y;
						var dist = Math.sqrt(dx * dx + dy * dy);
						var d = 12-dist;
						if( d > 0 ) {
							var a = Math.atan2(dy, dx);
							var ca = Math.cos(a) * d * 0.5;
							var sa = Math.sin(a) * d * 0.5;
							
								o.sp.x += ca;
								o.sp.y += sa;

								o2.sp.x -= ca;
								o2.sp.y -= sa;
						
							o.sp.pxx();
							o2.sp.pxx();
						}

						
					}
				}
				
				
				
			
		}
		
		dm.ysort(1);
		//

		
		
		
	}
	
	override function outOfTime() {
		setWin(true);
	}
	
	function majKnight() {
	
		
		if( strike == 0 ){
		
			var mp = getMousePos();
			var dx = mp.x - Cs.mcw * 0.25;
			var dy = mp.y - Cs.mch * 0.25;
			di = Cs.getAngleDir(Math.atan2(dy, dx));
			if( click ) strike = Std.int(20/speed);
		
		}else {
			strike--;
			
		}
		
		var fr = di;
		if( strike > 0 ) fr += 4;
		knight.drawFrame(Gfx.games.get(fr,"super_knight"));
	}

	function spawn(adv=0) {
		var sp = new pix.Sprite();
		dm.add(sp,1);

		var o = { sp:sp, di:-1, dist:120.0 };
		setDir(o, Std.random(4));
		orcs.push( o);
		timer = Std.int(BASE_SPAWN / speed);
		o.dist -= adv * timer * speed;
	}
	

	function explodeArmor() {
		setWin(false, 48);
		strike = 0;
		timer = 0;
		knight.drawFrame( Gfx.games.get("knight_naked"));
		
		
		var ec = 5;
		for( i in 0...7 ) {
			var p = new pix.Part();
			p.drawFrame( Gfx.games.get(i, "knight_armor"));
			p.setPos( knight.x + Std.random(ec * 2) - ec, knight.y + Std.random(ec * 2) - ec);
			p.weight = 0.1 + Math.random() * 0.1;
			p.vy = -(0.5 + Math.random() * 2);
			p.vx = (Math.random() - 0.5) * 2;
			p.frict = 0.95;
			p.setGround( knight.y + 4 + Std.random(6), 0.8, 0.5);
			dm.add(p,1);
			
		}
		
		
	}



	function setDir(orc:Orc, di:Int) {
		if( orc.di == di ) return;
		orc.di = di;
		var anim = ["orc_side", "orc_front", "orc_side", "orc_back"][di];
		if( orc == chief && !knight.visible ) anim = "orc_carry";
		orc.sp.setAnim( Gfx.games.getAnim(anim));
		 orc.sp.scaleX = ( orc.di == 2 )?-1:1;
	}

	override function kill() {
		super.kill();
		ground.dispose();
	}
	
//{
}


















