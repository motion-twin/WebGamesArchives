class Ship extends Phys {//}

	static var RAY = 22;
	static var COOLDOWN = 20 ;



	var speed:float;
	volatile var coolDown:float;
	volatile var fireRate:float
	var vx:float;
	var vr:float;
	var angle:float;
	var type:float;
	var hWidth:int;
	var hHeight:int
	volatile var shield:int;
	var flh:float;
	var mcBubble:MovieClip;

	function new(mc:MovieClip){
			super(mc)

			x = 150;
			y = 285;
			vx = 0;
			vr = 0 ;
			hWidth = 22;
			hHeight = 15;

			coolDown = 0;
			angle = 0;
			shield = 0;

			initState();


			var flt = new flash.filters.GlowFilter();
			flt.color = 0x3333FF;
			flt.alpha = 0.1;
			flt.blurX = 15;
			flt.blurY = 15;
			flt.strength = 0.8;
			root.filters = [flt];
		}

	function initState(){
		type = 1;
		speed = 4;
		fireRate = 20

	}

	function update(){

		super.update();
		//root.filters = [];
		// CONTROLE
		control();

		// SLOW DOWN
		if(!Key.isDown(Key.RIGHT) && !Key.isDown(Key.LEFT)){
			vx *= Math.pow(0.1,Timer.tmod);
			angle *= Math.pow(0.7,Timer.tmod);
		}
		x += vx * Timer.tmod;

		// HIT TEST
		if((x+RAY)>300) x=(300-RAY);
		if((x-RAY)<0) x=RAY;

		//COOLDOWN
		if (coolDown>0){
			coolDown -= Timer.tmod;
		}
		//INCLINAISON
		root._rotation = angle;

		//
		if(mcBubble!=null){
			mcBubble._x = x;
			mcBubble._y = y;
		}
		//
		updateFlasher();

	}

	function control(){
		if(Key.isDown(Key.RIGHT)){
			x += speed;
			angle = (angle*0.89)+5;

		}
		if (Key.isDown(Key.LEFT)) {
			x -= speed;
			angle = (angle*0.89)-5;
		}

		if (Key.isDown(Key.SPACE))  {
			if (coolDown<=0 && Cs.game.step==1) newShot(type);
		}
	}

	function newShot(type){
		coolDown = fireRate;
		if (type == 1) {
			var shot = new Shot(null,0);

			var xShot:float;
			var yShot:float;
			var radAngle: float

			radAngle = (angle+90)*(Math.PI/180);
			shot.vx = -(Math.cos(radAngle)*shot.sShot);
			shot.vy = Math.sin(-radAngle)*shot.sShot;
			shot.root._rotation = angle;
			shot.x = x;
			shot.y = y-RAY;
			Cs.game.hero.root.gotoAndPlay("shoot");

		}

		if (type == 2) {
			/*
			var shot = new Shot(null,0);
			var lshot = new Shot(null,0);
			var rshot = new Shot(null,0);

			coolDown = COOLDOWN;

			var xShot:float;
			var yShot:float;
			var radAngle: float

			radAngle = (angle+90)*(Math.PI/180);
			shot.vx = -(Math.cos(radAngle)*shot.sShot);
			shot.vy = Math.sin(-radAngle)*shot.sShot;
			shot.root._rotation = angle;
			shot.x = x;
			shot.y = y-RAY;

			radAngle = (angle+90+17.5)*(Math.PI/180);
			lshot.vx = -(Math.cos(radAngle)*lshot.sShot);
			lshot.vy = Math.sin(-radAngle)*lshot.sShot;
			lshot.root._rotation = angle;
			lshot.x = x+10;
			lshot.y = y-RAY;
			lshot.root._rotation = (angle+17.5);

			radAngle = (angle+90-17.5)*(Math.PI/180);
			rshot.vx = -(Math.cos(radAngle)*rshot.sShot);
			rshot.vy = Math.sin(-radAngle)*rshot.sShot;
			rshot.root._rotation = angle;
			rshot.x = x-10;
			rshot.y = y-RAY;
			rshot.root._rotation = (angle-17.5);

			/*/ // version factorisée
			for( var i=0; i<3; i++ ){
				var orient = i-1
				var shot = new Shot(null,0);
				var radAngle = (angle+90+orient*17.5)*(Math.PI/180);
				shot.vx = -(Math.cos(radAngle)*shot.sShot);
				shot.vy = Math.sin(-radAngle)*shot.sShot;
				shot.root._rotation = radAngle/0.0174 - 90
				shot.x = x+10*orient;
				shot.y = y-RAY;
			}
			//*/
			Cs.game.hero.root.gotoAndPlay("shoot");

		}

		}

	function shooted(m){
		if (shield == 0){
			explode();
		}else {
			shield-- ;
			m.kill();
			if(shield==0){
				mcBubble.gotoAndPlay("burst")//removeMovieClip();
				mcBubble = null;
			}
		}
	}

	function explode(){
		eAnim();
		kill();
	}

	function eAnim(){
		root.gotoAndPlay("die");
	}

	function initBubble(){
		if(mcBubble!=null)return;
		shield = 1
		mcBubble = Cs.game.dm.attach("mcBubble",1)
		mcBubble._x = x;
		mcBubble._y = y;

	}

	function flasher(){
		flh = 100
	}
	function updateFlasher(){
		if(flh!=null){
			var prc = flh
			flh *= 0.9
			if(flh<1){
				prc = 0
				flh = null
			}
			Cs.setPercentColor(root,prc,0xFFFFF)
		}
	}

	function kill(){
		KKApi.gameOver({})
		Cs.game.hero = downcast({x:x,y:y});
		root = null
		super.kill();
	}

//{
}