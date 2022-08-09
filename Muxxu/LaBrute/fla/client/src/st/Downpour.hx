package st;
import Data;
import mt.bumdum.Lib;

class Downpour extends State{//}


	var timer:Int;
	var bx:Float;
	var att:Fighter;
	var def:Fighter;
	var weapons:Array<_Weapons>;
	var damages:Array<Int>;
	var pos:Array<Phys>;
	var ray:Float;


	public function new(aid,a:Array<_Weapons>,dmg:Array<Int>) {
		super();
		weapons = a;
		damages = dmg;
		att = Game.me.getFighter(aid);


		for( f in Game.me.fighters ){
			if(f.gladiator.fol == null && f.team != att.team )def = f;
		}


		setMain();

		coef = 0;
		cs = 0.1;
		step = 0;

		att.playAnim("jump");
		bx = att.x;
		//trace("downpour!");

	}



	override function update() {
		super.update();

		switch(step){
			case 0:
				var c = coef;
				att.x = bx*(1-c) + Cs.mcw*0.5*c;
				att.z = -Math.sin(c*1.57)*300;
				if( coef == 1 ){
					step = 1;
					timer = 0;
					ray = 0;
					pos = [];
				}

			case 1:
				att.root._rotation -= 1.5;
				att.z -= 3;
				att.x += att.side*1;

				if(timer++>2){
					timer= 0;
					var wid = weapons.pop();
					var dmg = damages.pop();

					var p = new Part( Game.me.dm.attach("mcGroundWeapon",Game.DP_FIGHTERS) );
					p.root.gotoAndStop(Type.enumIndex(wid)+1);
					p.root._xscale *= -att.side;
					while(true){
						var r = 10+Math.random()*ray;
						var a = Math.random()*6.28;
						p.x = def.x + Math.cos(a)*r;
						p.y = def.y + Math.sin(a)*r;
						p.timer = 120;
						ray += 1;
						var flBreak = true;
						for( o in pos ){
							var dx = p.x-o.x;
							var dy = p.y-o.y;
							if( Math.sqrt(dx*dx+dy*dy) < 20  ){
								flBreak = false;
								break;
							}
						}
						if(flBreak)break;
					}
					pos.push(p);

					// ANIM
					att.playAnim("estoc");

					//att.x += att.side*4;


					// IMPACT
					var imp = new Phys( Game.me.dm.attach("mcGroundStrike",Game.DP_FIGHTERS) );
					imp.x = p.x;
					imp.y = p.y;
					imp.setScale(30);
					imp.root._xscale *= -att.side;

					imp.root.blendMode = "add";

					// HURT
					def.hurt(dmg);


					// REMOVE
					att.removeWeapon(wid);


					if( weapons.length == 0 ){
						att.root._rotation = 0;
						att.playAnim("jump");
						step=2;
						coef = 0;
					}
				}





			case 2:
				att.x = bx*coef + Cs.mcw*0.5*(1-coef);
				att.z = -Math.pow((1-coef),0.5)*300;

				if(coef>=1){
					att.playAnim("land");
					end();
					kill();
				}


		}


	}


//{
}
















