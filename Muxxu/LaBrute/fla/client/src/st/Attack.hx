package st;
import Data;
import mt.bumdum.Lib;

class Attack extends State{//}

	var flDecDamage:Bool;

	var flBack:Bool;
	var flDisarm:Bool;
	var flDisarmShield:Bool;
	var flDisarmAttacker:Bool;

	var att:Fighter;
	var def:Fighter;
	var sab:_Weapons;

	var dx:Float;
	var dy:Float;
	var sx:Float;
	var sy:Float;

	var defColor:Int;
	var damage:Int;


	public function new(aid,tid,damage,sab:_Weapons,dis,disShield,disAtt) {
		//trace(">"+sab);
		this.sab = sab;
		this.damage = damage;
		flDisarm = dis;
		flDisarmShield = disShield;
		flDisarmAttacker = disAtt;
		super();
		step = 0;
		att = Game.me.getFighter(aid);
		def = Game.me.getFighter(tid);


		var tx = def.x - ( def.ray + att.getRange() )*def.side;
		var ty = def.y+1;

		sx = att.x;
		sy = att.y;
		dx = tx - sx;
		dy = ty - sy;

		var dist = Math.sqrt(dx*dx+dy*dy);
		cs = 20/dist;
		step = 0;


		/*
		if( cs < 1 ){

		}else{
			attack();
		}
		*/




		setMain();



	}


	override function update() {
		super.update();
		//haxe.Log.clear();





		switch(step){
			case 0: // RUN
				att.x = sx +dx*coef;
				att.y = sy +dy*coef;
				if(coef>=1){
					attack();
				}


			case 1: // ATTAQUE

				
				if( flDecDamage && coef > 0.2 ){
					flDecDamage = false;
					impact();
				}
			
				if( flDisarmAttacker && coef > 0.4 ){
					
					flDisarmAttacker = false;
					var wp = att.fxThrow();
					wp.x -= (att.team*2-1)*45;
					wp.vz -= 2;
					att.setWeapon(att.gladiator.defaultWeapon);
					att.fxHurt(-1);
				}
				
			
				if( defColor != null) {
					Col.setPercentColor(def.root,Std.int((1-coef)*150),defColor);
				}
				
				if(coef==1 && !att.flAnim && !def.flAnim ){
					//att.backToNormal();
					def.backToNormal();
					end();
					kill();
				}

		}



	}

	public function attack(){



		//trace("attack!");

		step = 1;
		cs = 0.1;
		coef = 0;


		



		var anim = Data.WEAPONS[Type.enumIndex(att.wp)].anim;
		switch( anim ) {
			case Fist: att.playAnim("fist");
			case Slash: att.playAnim("slash");
			case Estoc:	att.playAnim("estoc");
			case Whip: att.playAnim("whip");
		}


		if( damage>0 ){

			flDecDamage = true;

		}else if( damage < 0 ){
			def.dodge();
		}else{
			def.parry();
		}

	}

	function impact(){
		var ma = 5;
		var hx = (Math.random()*2-1)*ma  + att.x-(att.getRange()+12)*att.side;
		var hy = (Math.random()*2-1)*ma  + att.y;


		// SABOTAGE
		if(sab!=null){
			def.removeWeapon(sab);
			def.fxThrow(null,Type.enumIndex(sab)+1);
		}

		// DISARM
		if(flDisarm){
			def.fxThrow();
			def.setWeapon(def.gladiator.defaultWeapon);
			var p = new Phys( Game.me.dm.attach("fxOnde",Game.DP_FIGHTERS) );
			p.x = hx;
			p.y = hy;
			p.z = -55;
			p.setScale(60+this.damage);
			p.root._xscale = -att.side*p.scale;
			p.root.blendMode = "add";
			p.updatePos();
		}
		
		// DISARM SHIELD
		if( flDisarmShield )def.dropShield();

		//
		def.hurt(damage,-1);

		//*
		// SPARK
		var p = new Phys( Game.me.dm.attach("fxImpact",Game.DP_FIGHTERS) );
		p.x = hx;
		p.y = hy;
		p.z = -55;
		p.setScale(50+this.damage*0.5);
		p.root._xscale = -att.side*p.scale;
		p.updatePos();
		if( flDisarmAttacker || flDisarm  ) fxOnde(hx,hy);
		
		// HIT FX
		switch( def.hitFx ){
			case 0 :
				var mc = Game.me.dm.attach("mcFxResist",Game.DP_PARTS);
				mc._x = def.root._x;
				mc._y = def.root._y - 28;	
				defColor = 0xFFFF00;
		}
		att.hitFx = null;
		
		
		//
		//Filt.glow(p.root,4,2,0xFFFFFF);
		//*/
		// ONDE
		
		// SMOFE
		/*
		for( i in 0...5 ){
			var p = new Part( Game.me.dm.attach("fxSmoke",Game.DP_FIGHTERS) );
			var ma = 8;
			p.x = hx + (Math.random()*2-1)*ma;
			p.y = hy + (Math.random()*2-1)*ma;
			p.z = -55;
			p.weight = -(0.1+Math.random()*0.2);
			p.setScale(50+this.damage);
			p.root._xscale = -att.side*p.scale;
			p.updatePos();
			var bl = 16-i*2;
			Filt.blur(p.root,bl,bl);
			//p.vr = (Math.random()*2-1)*16;
			p.friction = 0.9;
			p.timer = 20+Math.random()*30;
			p.vx = -att.side*Math.random()*8;
			p.setAlpha(0.75);
			p.fadeLimit = 20;
			///p.fadeType = 0;

		}
		*/
		//Filt.glow(p.root,4,2,0xFFFFFF);
	}

	
	function fxOnde(hx,hy){
			
		var p = new Phys( Game.me.dm.attach("fxOnde",Game.DP_FIGHTERS) );
		p.x = hx;
		p.y = hy;
		p.z = -55;
		p.setScale(60+this.damage);
		p.root._xscale = -att.side*p.scale;
		p.root.blendMode = "add";
		p.updatePos();		
	}






//{
}