package ac.hero.magic;
import Protocole;
import mt.bumdum9.Lib;
import mt.bumdum9.Tools;

private typedef Cycler = { part:mt.fx.Part<McChannelDust>, y:Float, ray:Float, dec:Float, sp:Float, timer:Int, join:Float, inside:Bool, hero:Hero };
private typedef ZEnt = { mc:SP, score:Int };

class Tornado extends ac.hero.MagicAttack {//}
	

	var cyclers:Array<Cycler>;

	public function new(agg) {
		super(agg);
		Scene.me.fadeTo(0xAA6688, 0.05);
	}
	
	override function start() {
		super.start();
		cyclers = [];
	
	}
	
	// UPDATE
	override function updateSpell() {
		super.updateSpell();
		

		
		updateCyclers()	;
		
		if ( timer == 100 ) {
			for ( h in Game.me.heroes ) {
				h.addStatus(STA_CELERITY);
				h.majInter();
			}
			
		}
		if ( timer < 120 ) addCycler();
		if ( timer == 160 ) {
			for ( o in cyclers ) {
				o.part.timer = 10 + Std.random(30);
				o.part.fadeType = 2;
			}
			Scene.me.fadeBack(0.02);
			kill();
		}
				
	}
	
	function updateCyclers() {
		
		
		// MOVE
		var a = cyclers.copy();
		var b:Array<ZEnt> = [];
		for( o in a ) {
			var p = o.part;
			o.dec = (o.dec + o.sp)%6.28;
			
			var tx = o.hero.folk.x +  Math.cos(o.dec)* o.ray;
			var ty = o.y;
			var dx = tx - p.x;
			var dy = ty - p.y;
			p.vx = dx * o.join;
			p.vy = dy * o.join;
			o.join += 0.002;
					
	
			Col.setColor(p.root, 0, Std.int( -Math.cos(o.dec+1.57)*120*Math.min(o.join*16,1) ) );
			
			
			if( o.timer-- == 0 ) {
				p.kill();
				cyclers.remove(o);
			}else {
				b.push({mc:cast p.root,score:Std.int( Math.sin(o.dec) * 100) } );
			}
			

			
		

		}
		
		// Z
		var f = function(a:ZEnt, b:ZEnt) {
			if(a.score < b.score ) return -1;
			return 1;
		}
		var id = 0;
		for( h in Game.me.heroes ) b.push( { mc:cast h.folk, score:id++ } );
		b.sort(f);
		
		for ( o in b ) {
			//if( o.mc.parent != null )
				Scene.me.dm.over(o.mc);
		}
	}
	
	function addCycler() {
		
		// PART
		var pos = { x:Std.random(Cs.mcw), y:Std.random(Cs.mch) };

		var p = new mt.fx.Part( new McChannelDust() );
		p.frict = 0.95;
		p.setScale(1+Math.random()*2);
		p.setPos( pos.x, pos.y);
		p.fadeIn(5);
		p.fadeType = 2;
		p.fadeLimit = 8;
		p.vr = 2 + Math.random() * 10;
		Col.setPercentColor(p.root.smc,1, Col.shuffle(0x8800FF,60) );
		Scene.me.dm.add(p.root, Scene.DP_FOLKS);
		
		var h = Math.random();
		
		var o:Cycler  = {
			part:p,
			y:(1-Math.pow(h,0.5)) * Scene.HEIGHT,
			ray:10 + Math.random() * 20 + h*60,
			dec:Math.random() * 6.28,
			sp:0.1,
			timer:120 + Std.random(120),
			join:0.0,
			inside:false,
			hero:Game.me.heroes[Std.random(Game.me.heroes.length)]
		}
		cyclers.push(o);


		
	}
	

	

	
//{
}


























