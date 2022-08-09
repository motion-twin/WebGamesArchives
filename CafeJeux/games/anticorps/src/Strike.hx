import Common;
import mt.bumdum.Lib;



class Strike {//}


	public var cosmo:pix.Cosmo;
	public var type:Int;
	public var mcSlash:flash.MovieClip;
	public var harm:Array<pix.Cosmo>;

	public function new(?cosmo,?type) {
		Game.me.anims.push(this);
		this.cosmo = cosmo;
		this.type = type;

		harm = [cosmo];

	}


	// UPDATE
	public function update(){



		//if(mc==null)trace("!");
		var mc = cosmo.mcWeapon.smc;
		mc._xscale = 100;
		mc._yscale = 100;
		mc.nextFrame();

		switch(type){
			case 0: updateSword(mc);
			case 1: updateMedecine(mc);
		}


	}

	public function updateSword(mc){
		if( mc._currentframe == 5 ){
			var mc = Game.me.mdm.attach("mcSlashAnim",Game.DP_COSMO);
			mc._x = cosmo.x + cosmo.head.x;
			mc._y = cosmo.y + cosmo.head.y;
			mc._xscale = cosmo.sens*100;
			mc._rotation = (cosmo.ga+1.57)/0.0174;
			mcSlash = mc;
		}

		if( mc._currentframe == 6 ){

			var fa = Num.hMod(cosmo.ga+cosmo.sens*1.57,3.14);


			var list = Game.me.cosmos.copy();
			for( c in list ){
				if(c!=cosmo){
					var dx = (c.x+c.head.x) - (cosmo.x+cosmo.head.x);
					var dy = (c.y+c.head.y) - (cosmo.y+cosmo.head.y);

					var dist = Math.sqrt(dx*dx+dy*dy);

					if( dist < 40 ){

						var a = Math.atan2(dy,dx);
						var da = Num.hMod(fa-a,3.14);

						if( da>-0.5 && da<1.7){

							c.setState(Fly);
							c.vx = Math.cos(c.ga)*2;
							c.vy = Math.sin(c.ga)*2;
							c.incHp(-40);
						}

					}

				}
			}
		}


		if( mc._currentframe == 35 ){
			kill();
		}
	}
	public function updateMedecine(mc){

		if( mc._currentframe == 6 ){

			var fa = Num.hMod(cosmo.ga+cosmo.sens*1.57,3.14);

			var trg = null;
			var distMax = 40.0;

			var list = Game.me.cosmos.copy();
			for( c in list ){
				if(c!=cosmo){
					var dx = (c.x+c.head.x) - (cosmo.x+cosmo.head.x);
					var dy = (c.y+c.head.y) - (cosmo.y+cosmo.head.y);

					var dist = Math.sqrt(dx*dx+dy*dy);
					if( dist < distMax){

						var a = Math.atan2(dy,dx);
						var da = Num.hMod(fa-a,3.14);
						//da = 0;
						//fa = 3.14;
						//trace("fa:"+fa);

						var ndx = Math.cos(fa)*dx - Math.sin(fa)*dy;
						var ndy = Math.cos(fa)*dy - Math.sin(fa)*dx;


						if( ndx>0 && Math.abs(ndy)<10 ){

							distMax = dist;
							trg = c;

						}
						//trace(ndx+";"+ndy);
					}
				}
			}

			if(trg!=null){
				trg.heal(30);
				trg.setState(Fly);
				trg.vx = Math.cos(fa)*2;
				trg.vy = Math.sin(fa)*2;
				trg.over();
			}




		}

		if( mc._currentframe == 20 ){
			kill();
		}

	}

	public function kill(){
		cosmo.removeWeapon();
		Game.me.anims.remove(this);
	}



//{
}











