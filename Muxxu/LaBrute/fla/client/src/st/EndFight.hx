package st;
import Data;
import mt.bumdum.Lib;

class EndFight extends State{//}


	var winner:Fighter;
	var wait:Int;


	public function new(team) {
		super();

		for( f in Game.me.fighters ){
			if( f.team == team ){
				f.playAnim("win");
				if(f.gladiator.fol==null && f.flInter )winner = f;
			}
		}

		wait = 15;

	}


	override function update() {
		super.update();


		if( Std.random(3)==0 && wait>-120 ){
			var ec = 100;
			var p = new Part(Game.me.dm.attach("mcPetal",Game.DP_FIGHTERS));
			var a = Math.random()*6.28;
			var dist = Math.random()*100;
			p.x = winner.x + Math.cos(a)*dist;//(Math.random()*2-1)*ec;
			p.y = winner.y + Math.sin(a)*dist;//(Math.random()*2-1)*ec;
			p.z = -600;
			p.setScale(40);
			p.weight = 0.02+Math.random()*0.1;
			p.vr = (Math.random()*2-1)*8;
			p.root._rotation = Math.random()*360;
			//p.fadeType = 0;
			//p.friction = 0.98;
			p.onGroundHit = function(){
				p.root.stop();
				p.root = null;
				p.kill();
			};
			Col.setColor(p.root,Col.objToCol(Col.getRainbow(Math.random())));

		}

		if( wait-- == 0 ){
			var mc = Game.me.dm.attach("mcWinMsg",Game.DP_INTER);
			mc._x = Cs.mcw*0.5;
			mc._y = Cs.mch;
			var str = winner.gladiator.name+Lang.MISC[8];
			Reflect.setField(mc,"_txt",str.toUpperCase());
			flash.Lib.getURL(Game.me.data._end,"_self");
		}

	}









//{
}
