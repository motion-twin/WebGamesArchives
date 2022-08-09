import mt.bumdum9.Lib;

typedef STSlot = {>flash.display.MovieClip, id:Int, a:Float };

class Stacker extends Game{//}

	static var MAT_SHAPE = new phx.Material(0,0.4,1);
	static var MA = 72;

	var sc:Float;
	var ww:Float;
	var timer:Float;

	var bdm:mt.DepthManager;

	var shape:Phx;
	var shapes:List<Phx>;
	var slots:List<STSlot>;

	override function init(dif:Float){
		gameTime =  600-100*dif;
		super.init(dif);
		sc = 1.0;
		ww = 220-dif*100;
		attachElements();

	}
	
	function attachElements(){

		var board = dm.empty(1);
		bdm = new mt.DepthManager(board);
		var fl = new flash.filters.DropShadowFilter();
		fl.color = 0;
		fl.distance = 4;
		fl.angle = 135;
		fl.strength = 0.2;
		board.filters = [fl];

		// WORLD
		initWorld();
		var aabb = new phx.col.AABB(0,0,Cs.mcw,Cs.mch);
		world = new phx.World( aabb, new phx.col.BruteForce() );
		world.gravity.set(0,0.3);

		// GROUNDS
		var gl = Cs.mch-40;
		var shape = phx.Shape.makeBox(ww,20,MA+((Cs.mcw-MA)-ww)*0.5,gl);
		world.addStaticShape(shape);
		var mc = bdm.attach("stacker_ground",1);
		mc.x = MA+(Cs.mcw-MA)*0.5;
		mc.y = gl+10;
		getSmc(mc).scaleX = (ww - 20) * 0.01;
		bg = dm.attach("stacker_bg",0);
		for( i in 0...2 ){
			var mmc:flash.display.MovieClip = Reflect.field(mc, "$b" + i);
			mmc.x = (i*2-1)*(ww-40)*0.5;
		}

		//
		shapes = new List();
		initSlots();
		initShape();
		
		

	}

	override function update(){
		super.update();
		world.step(1,5);
		switch(step){
			case 1 :
				updateShape();
			case 2 :
				if(timer--==0){
					if( slots.length>0 ) initShape();
					else endShapes();
				}
			case 3 :
				var energy = 0.0;
				for( island in world.islands )energy += island.energy;
				if(energy<0.15)timer --;
				else timer -= 0.05;
				if(timer<=0)setWin(true,10);

		}
		updateSlots();

		for( sh in shapes ){
			if( sh.y > Cs.mch )setWin(false,10);
		}


	}

	// SLOTS
	function initSlots(){
		slots = new List();

		var proba = [0,0,0,0,1,1,1,1,2,2,2,2];

		for( i in 0...7 ){
			var index = Std.random(proba.length);
			var id = proba[index];
			proba.splice(index,1);
			var sp = getSlotPos(i);
			var mc:STSlot = cast bdm.attach("stacker_shape",1);
			mc.x = sp.x;
			mc.y = sp.y;
			mc.id = id;
			mc.a = 0;
			if( mc.id == 1 && Std.random(2)==0 )mc.a += 0.77;
			if( dif>0.5 && i>2 && mc.id == 2 && Std.random(2)==0 )mc.a += 3.14;
			mc.gotoAndStop(mc.id+1);
			mc.rotation = mc.a/0.0174;
			slots.add(mc);
			//Filt.glow(mc,2,2,0x8F99BC);
		}
	}
	function updateSlots(){
		var id = 0;
		for( mc in slots ){
			var sp = getSlotPos(id);
			var dy = sp.y - mc.y;
			var lim = 8;
			mc.y += Num.mm(-lim,dy*0.4,lim);
			id++;
		}
	}
	function getSlotPos(id){
		return {
			x:36,
			y:36+id*62,
		};
	}

	// SHAPE
	function initShape(){
		step = 1;

		var mc = slots.pop();
		shape = new Phx(mc);
		shape.game = this;

		var mp = getMousePos();
		shape.material = MAT_SHAPE;
		shape.setPos(mp.x,mp.y);
		shape.setAngle(mc.a);
		//shape.setStatic(true);
		//trace(shape.body.properties.angularFriction);
		//shape.body.properties = new phx.Properties(
		shape.body.properties.angularFriction = 1;
		//trace(shape.body.properties.biasCoef);
		shape.body.properties.biasCoef = 0.4;

		switch(mc.id){
			case 0:
				shape.setBox(44*sc,44*sc);
			case 1:
				shape.setBox(16*sc,50*sc);
				shape.setBox(50*sc,16*sc);
			case 2:

				shape.setPol( [[0.,-30],[-15.,-4],[-30.,22],[0.,22],[30.,22],[15.,-4]] );

		}
		mc.alpha = 1;
	}
	function updateShape(){
		var mp = getMousePos();
		var ma = 32;
		if(mp.x<MA+ma)mp.x = 100;
		if(mp.x>Cs.mcw-ma)mp.x = Cs.mcw-ma;
		if(mp.y<ma)mp.y = ma;
		if(mp.y>Cs.mch-80)mp.y = Cs.mch-80;
		shape.setPos(mp.x,mp.y);


		var flCollision = false;
		for( arb in shape.body.arbiters ){
			var p = arb.contacts;
			while(p!=null){
				if(p.updated)flCollision = true;
				p.updated = false;
				p = p.next;
			}
		}

		shape.root.alpha = flCollision?0.5:1;
		shape.setVit(0,0);
		//world.activate(shape.body);
		if( !flCollision && click )drop();

		//for( arb in shape.body.arbiters )shape.body.arbiters.remove(arb);

	}
	function drop(){
		shape.setStatic(false);
		step = 2;
		timer = 10;
		shapes.push(shape);
	}

	function endShapes(){
		timeProof = true;
		step = 3;
		timer = 30;
	}




//{
}

