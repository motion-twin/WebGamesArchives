package mod;
import Common;



class Watch extends Mode{//}

	public function new(?cosmo) {
		super(cosmo);
		Game.me.setMsg("Tour de votre adversaire...");
	}

	// UPDATE
	override function update(){
		//MMApi.print("mod.Watch");
		super.update();
		//if(cosmo.state!=Ground)return;
		if(Game.me.moveStack.length>0){
			var n = Game.me.moveStack.shift();
			switch(n){
				case -1:	cosmo.walk(n);
				case 1:		cosmo.walk(n);
				case 2:
					var a = Game.me.moveStack;
					var x = a.shift();
					var y = a.shift();
					var gid = a.shift();

					cosmo.goto(x,y,gid);
					cosmo.ga = cosmo.getNormal();

					for( p in cosmo.pods ){
						p.dec = a.shift();
						p.gid = a.shift();
						p.x = a.shift();
						p.y = a.shift();
						p.anim = null;
						p._x = p.x - cosmo.x;
						p._y = p.y - cosmo.y;
						p._rotation = cosmo.getNormal(p)/0.0174;
					}

					cosmo.updatePos();
					cosmo.head.x = cosmo.head.tx;
					cosmo.head.y = cosmo.head.ty;

					//Game.me.checkMines(cosmo.x,cosmo.y);
					//Game.me.checkMines(cosmo.x,cosmo.y);
					// Game.me.applyDanger(cosmo);
					cosmo.applyDanger();

			}
			cosmo.applyDanger();
		}
	}

	override function kill(){
		Game.me.setMsg();
		super.kill();
	}



//{
}











