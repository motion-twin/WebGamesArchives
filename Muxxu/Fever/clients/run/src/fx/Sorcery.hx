package fx;
import Protocole;
import mt.bumdum9.Lib;

class Sorcery extends mt.fx.Fx{//}

	public var ok:Bool;
	var id:Int;
	var island:world.Island;
	var hero:world.Hero;
	var timer:Int;
	var step:Int;
	var parts:Array<pix.Part>;
	var mon:world.ent.Monster;
	
	var bolt:flash.display.Sprite;
	var tornado:pix.Sprite;
	var fireballs:Array<{base:flash.display.Sprite,fb:pix.Sprite, mon:world.ent.Monster, sq:world.Square}>;
	var hdisc:FxHalfDisc;
	var dir:Int;
	var cur:world.Square;
	var work:Array<world.ent.Monster>;
	
	var casualty:Array<Int>;
	
	public function new(id:Int) {
		super();
		this.id = id;
		hero = World.me.hero;
		island = hero.island;
		step = 0;
		
		ok = false;
		switch(id) {
			case 0 : ok = island.monsters.length > 0;
			case 1 : ok = island.monsters.length > 0;
			case 2 :
				for( mon in island.monsters ) {
					if( mon.sq.x == hero.sq.x || mon.sq.y == hero.sq.y ) {
						ok = true;
						break;
					}
				}
		}
		
		if( !ok ) {
			kill();
			return;
		}

		hero.sprite.setAnims( Gfx.hero.getAnims(["hero_sorcery","hero_sorcery_loop"]) );
		parts = [];
		timer = 0;
		
		casualty = [];
		
		// INIT
		switch(id) {
			case 0 :

				mon = hero.getNearestMonster();
				bolt = new flash.display.Sprite();
				bolt = island.dm.add(bolt, world.Island.DP_ELEMENTS);
				bolt.x = mon.x;
				bolt.y = mon.y -1;
				hdisc = new FxHalfDisc();
				hdisc.scaleX = hdisc.scaleY = 0;
				bolt.addChild(hdisc);
			
			case 1:
		
				fireballs = [];
				var work = [];
				var a = island.monsters.copy();
				for( sq  in island.zone ) if( sq.ent == null ) work.push(sq);
				Arr.shuffle(work);
				
				while( a.length > 0 || work.length > island.zone.length * 0.5  ) {
					var sq = null;
					var mon = null;
					if( a.length > 0 ) {
						mon = a.pop();
						sq = mon.sq;
					}else {
						sq = work.pop();
					}
					
					var sp = new pix.Sprite();
					sp.setAnim(Gfx.fx.getAnim("fireball"));
					var dist = 150 + Std.random(200);
					sp.x = -dist;
					sp.y = -dist;
					
					var base = new flash.display.Sprite();
					base.addChild(sp);
					island.dm.add(base, world.Island.DP_ELEMENTS);
					var pos = sq.getCenter();
					base.x = pos.x;
					base.y = pos.y;
					
					fireballs.push( { fb:sp, base:base, sq:sq, mon:mon } );
				
				}
				
			case 2:
				work = [];
				tornado = new pix.Sprite();
				tornado.setAnim(Gfx.fx.getAnim("tornado"));
				island.dm.add(tornado, world.Island.DP_ELEMENTS);
				coef = 0;
				cur = hero.sq;
				for( ray in 1...20 ){
					for( di in 0...4 ) {
						var d = Cs.DIR[di];
						var nx = hero.sq.x + d[0]*ray;
						var ny = hero.sq.y + d[1]*ray;
						var sq = island.get(nx, ny);
						if( sq == null ) break;
						for( m in island.monsters ) {
							if( sq.ent == m ) {
								mon = m;
								dir = di;
								break;
							}
						}
						if( mon != null ) break;
					}
					if( mon != null ) break;
				}
				
				
			
			
		}
		
		

		//island.sortElements();
		
		
	
		
	}
	
	

	override function update() {
		super.update();
		switch(step) {
			case 0 :
			
				var n = 4;
				if( timer > 32 ) n--;
				if( timer > 64 ) n--;
				if(World.me.timer % n == 0) genPart();
				updateParts();
				
				
				if( timer++ == 80 ) {
					step = (id+1) * 10;
					timer = 0;
					hero.sprite.setAnims(Gfx.hero.getAnims(["hero_slash","hero_stand"]));
					if(mon!=null && !isImmune(mon) )mon.sprite.anim.play(0);
					
					for( p in parts ) {
						switch(id) {
							case 0,1,2:
								p.vy = -(1 + Math.random() * 10);
								p.vx *= 0.5;
								p.timer = 10 + Std.random(10);
							
						}
					}
				}
				
				
				
				
				
			case 10 :	// BOLT A
	
			
			
				var lim = 16;
				var coef = timer++ / lim;
				var c = Math.min(Math.sin(coef * 3.14)*1.5,1);
				var c2 = Num.mm(0,Math.sin((coef-0.15) * 3.14),1);
				

				
				// HDISC
				hdisc.scaleX = hdisc.scaleY = c2*0.3;
				
				// LINE
				var ec = 20;
				var side = 2;
				var a = [{x:0.0,y:0.0}];
				for( i in 0...10 ) {
					var pos = a[0];
					var x = pos.x + (Math.random() * 2 - 1) * side;
					var y = pos.y - ec;
					a.unshift( { x:x, y:y } );
					side++;
				}
			
			
				// DRAW
				var gfx = bolt.graphics;
				gfx.clear();
				
				for( i in 0...2){
					var first = true;
					var size = c * 16;
					if( i == 1 ) size = 2;
					for( p in a ) {
						size *= 0.85;
						gfx.lineStyle(size,0xFFFFFF);
						if( first ) {
							gfx.moveTo( p.x, p.y );
							first = false;
							continue;
						}
						var nx = p.x;
						var ny = p.y;
						if( i == 1 ) {
							nx += Std.random(16)-8;
							ny += Std.random(16)-8;
						}
						
						gfx.lineTo( nx, ny );
					}
				}
				
				// BOLT
				bolt.filters = [];
				Filt.glow(bolt, 4*c, 4*c, 0xFFFF00);
				Filt.glow(bolt, 10*c, 1*c, 0xFFFF00);
				bolt.blendMode = flash.display.BlendMode.ADD;
				
				//
				Col.setPercentColor(mon,c, 0);
				if( mon.visible && coef > 0.5 ) disloke(mon);
				
				
				if( coef == 1 ) {
					gfx.clear();
					bolt.parent.removeChild(bolt);
					end();
				}


			case 20 :	// FIREBALL
				var a  = fireballs.copy();
				for( o in a ) {
					o.fb.y += 5;
					o.fb.x = o.fb.y;
					o.fb.pxx();
					if( o.fb.y > 0 ) {
						o.fb.kill();
						o.base.parent.removeChild(o.base);
						fireballs.remove(o);
						if( o.mon != null ) 	disloke(o.mon);
						new mt.fx.Shake(World.me.island, 0, 8, 0.5);
						
						var p = new pix.Sprite();
						p.setAnim(Gfx.fx.getAnim("square_explosion"));
						var pos = o.sq.getCenter();
						p.x = pos.x;
						p.y = pos.y;
						p.pxx();
						island.dm.add(p, world.Island.DP_ELEMENTS);
						p.anim.onFinish = p.kill;

						
						 new mt.fx.Flash(World.me.island, 0.2);
						
					}
				}
				if( a.length == 0 ) end();
				
			case 30 : // TORNADO
				coef += 0.1;
				var d = Cs.DIR[dir];
				while(coef>1) {
					coef--;
					cur = island.get(cur.x + d[0], cur.y + d[1]);
					for( m in island.monsters ) {
						if( isImmune(m) ) continue;
						if( m.sq == cur ) {
							tornado.addChild(m);
							m.x -= tornado.x;
							m.y -= tornado.y;
							work.push(m);
							
							var mask = new flash.display.Sprite();
							var pos = m.sq.getCenter();
							tornado.addChild(mask);
							mask.graphics.beginFill(0xFF0000);
							mask.graphics.drawRect( -8, -42, 16, 32);
							m.mask = mask;

							casualty.push(m.sq.id);
							//trace("tornado!!");
						}
					}
				}
				var a = work.copy();
				for( mon in a ) {
					if( isImmune(mon) ) continue;
					if(World.me.timer%2==0)mon.y++;
					if( mon.y > 16 ) {
						mon.death();
						mon.mask.parent.removeChild(mon.mask);
						work.remove(mon);
					}
				}
				if( cur == null || cur.distTo(hero.sq)>6 ) {
					for( mon in work ) mon.death();
					tornado.kill();
					end();
					return;
				}
				
				
				var pos = cur.getCenter();
				tornado.x = pos.x + coef * d[0]*16;
				tornado.y = pos.y + coef * d[1] * 16;
				tornado.pxx();
				//island.sortElements();
				
				for( mon in island.monsters ) {
					if( isImmune(mon) ) continue;
					var dx = mon.x - tornado.x;
					var dy = mon.y - tornado.y;
					var dist = Math.sqrt(dx * dx + dy * dy);
					var lim = 14;
					if( dist < lim ) {
						var c = Math.pow( 1 - dist / lim, 0.5);
							mon.sprite.y = -c * 20;
							mon.sprite.pxx();
						
					}
				}
				
				
				
				
		}
	
		
	}
	
	// INVOCATION
	function genPart() {
		var a = Math.random() * 6.28;
		var ray = 16 + Math.random() * 16;
		var speed = 0.5+Math.random()*2;
		var p = new pix.Part();
		//p.drawFrame(Gfx.fx.get(0, "spark_twinkle"));
		p.setAnims( Gfx.fx.getAnims(["spark_grow","spark_grow_loop"]) );
		island.dm.add(p, world.Island.DP_FX);
		p.xx = hero.root.x + Math.cos(a)*ray;
		p.yy = hero.root.y + Math.sin(a) * ray - 8;
		p.updatePos();
		a += 1.57;
		p.vx = Math.cos(a) * speed;
		p.vy = Math.sin(a) * speed;
		p.frict = 0.95;
		parts.push(p);
		//Col.setColor(p, [0xFFFF00, 0xFF6600, 0x0066FF][id],-255);
		Col.overlay2(p, [0xFFFF00, 0xFF6600, 0x0066FF][id],-255);
	}
	function updateParts() {
		var a = parts.copy();
		for( p in a ) {
			var coef = 0.02;
			var dx = hero.root.x - p.x;
			var dy = (hero.root.y - 8) - p.y;
			p.vx += dx * coef;
			p.vy += dy * coef;
			var dist = Math.sqrt(dx * dx + dy * dy);
			
			if( dist < 4 ) {
				p.kill();
				parts.remove(p);
			}
			
		}
	}
	
	// VOLT
	function disloke(mon:world.ent.Monster) {
		if( isImmune(mon) ) return;
		
		mon.visible = false;
		mon.death();
		casualty.push(mon.sq.id);
		var max = 18;
		for( i in 0 ...max ) {
			var p = new pix.Part();
			p.drawFrame(Gfx.fx.get(0, "spark_twinkle"));
			island.dm.add(p, world.Island.DP_ELEMENTS);
			p.xx = mon.x + Std.random(9) - 4;
			p.yy = mon.y + Std.random(11) - 11;
			p.updatePos();
			var sc = Std.random(2) + 1;
			p.weight = -(0.015 + Math.random() * 0.75)/sc;
			p.vy = p.weight * 8;
			p.frict = 0.98;
			p.timer = 10 + Std.random(8);
			if( i == 0 ) p.timer += 10;
			p.scaleX = p.scaleY = sc;
			Col.setPercentColor(p, 1, 0);
		}
		
	}

	//
	function isImmune(mon:world.ent.Monster) {
		return mon.data._id == 11;
	}
	
	//
	function end() {
		hero.dir = -1;
		World.me.send( _Burn(casualty,[Volt,Fireball,Tornado][id]) );
		World.me.setControl(true);
	
		island.mapDistanceFrom(hero.sq);
		kill();
	}

	
//{
}








