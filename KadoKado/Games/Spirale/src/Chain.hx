import mt.bumdum.Lib;

class Chain {//}
	public var list:Array<Ball>;
	public var pos:Float;
	public var vit:Float;
	public var combo:mt.flash.Volatile<Int>;
	public var comboTimer:mt.flash.Volatile<Float>;
	public var cci:Int;

	public function new(?index){
		if(index==null)
			index = Game.me.chains.length;
		Game.me.chains.insert(index,this);
		list = [];
		pos = 1;
		vit = 0;
		//for( i in 0...n )addBall();
	}

	public function update(){
		var index = getIndex();
		var next = Game.me.chains[index+1];
		var top = pos - list.length*Cs.ec;
		if( top < 0.2 )
			Game.me.danger();

		if (comboTimer!=null){
			comboTimer -= mt.Timer.tmod;
			if(comboTimer < 0 ){
				combo = null;
				comboTimer = null;
			}
		}

		//for( b in list ) if(b.flDeath)trace("DEAD HERE [0]"+list.length);

		// COMBO SPEEDER
		var flCombo = false;
		var couple = null;
		if( next !=null ){
			var spd = 0.00055;
			var b1 = next.list[0];
			var b2 = list[list.length-1];
			if( b1 != null && b2 != null && b1.col == b2.col && b1.col != 4 ){
				flCombo = true;
				comboTimer = 20;
				next.vit += spd*mt.Timer.tmod;
				vit -= spd*0.5*mt.Timer.tmod;
				couple = [b1,b2];
				b1.incFlash(0.1);
				b2.incFlash(0.1);
			}
		}

		//for( b in list ) if(b.flDeath)trace("DEAD HERE [1]"+list.length);

		// FIRST
		if(index==0){

			// SPEED START
			if( Game.me.flStart ){
				if( top>0.6  ) vit -= 0.004;
				else	Game.me.flStart = false;
			}

			// BLOCKAGE
			if( top>1.1 ){
				comboTimer=null;
				combo = null;
				if(vit>0)vit = 0;
			}


			// AVANCE
			if(comboTimer==null){
				var mult = 1.0;
				if(Game.FL_TEST && flash.Key.isDown(flash.Key.SPACE))mult = 16;
				var lim = 0.9;
				if(Game.me.lastPos>lim)mult += (Game.me.lastPos-lim)*10;
				vit += (-Game.me.speed*mult-vit)*0.25*mt.Timer.tmod  ;

			}

			// SPAWN
			var to = 0;
			while( pos<Cs.COEF_START ){

				pos += Cs.ec;
				var b = new Ball(true);
				b.chain = this;
				list.unshift(b);
				if(to++>10)break;

			}



		}

		// HACK CORRECTION
		if(list.length==0){
			kill();
			return;
		}


		// JOIN
		var p = Cs.getPos(top);
		if( top < next.pos ){
			var dif = next.pos-top;
			pos += dif;
			var v = Math.max(vit,next.vit);
			var index = list.length-1;

			join(next);
			vit = v;
			if(flCombo)cci = index;
		}

		// MOVE
		vit *= Math.pow(0.97,mt.Timer.tmod);
		pos+=vit*mt.Timer.tmod;
		updatePos();

		// ECLAIR
		if( couple != null )couple[0].fxLink(couple[1]);

		// JOINER

		/* // V1
		var p = Cs.getPos(top);
		if( top < next.pos ){
			var index = list.length-1;
			join(next);
			if(flCombo){
				vit += 0.012;
				cci = index;
				//checkCombo(index);
			}
		}
		/*/ // V2

		/*
		var p = Cs.getPos(top);
		if( top < next.pos ){
			var dif = next.pos-top;
			pos -= dif;
			var v = Math.max(vit,next.vit);
			var index = list.length-1;

			join(next);
			vit = v;
			if(flCombo)cci = index;
		}
		*/

		//*/

		// MARK
		//Game.me.mark(p.x,p.y);


		// GAMEOVER
		if( top+Cs.ec<Cs.COEF_END ){
			Game.me.initGameOver();
		}

	}

	public function updatePos(){
		var p = pos;
		for( b in list ){
			b.setPos(p);
			p -= Cs.ec;
			b.maj();

		}
	}

	public function addBall(?b:Ball){
		if(b==null)b = new Ball(true);
		b.chain = this;
		list.push(b);
	}

	public function insert(b:Ball,trg:Ball){

		var index = trg.getIndex();


		//
		if(trg.col==4){
			trg.from = trg.pos;
			trg.unchain();
			Game.me.shots.push(trg);
			trg.vx = b.vx;
			trg.vy = b.vy;
			trg= null;

		}else{
			if(  Num.hMod(trg.getLauncherAngle() - b.getLauncherAngle(), 3.14) > 0 )  index ++;
		}







		if( index == null ){
			Col.setPercentColor(trg.root,100,0xFF0000);
			Col.setPercentColor(b.root,100,0x00FF00);
			trace("WARNING!!! no index !");
			trace(" trg chain Index : "+trg.chain.getIndex());
			trace(" trg root._visible : "+trg.root._visible );
			trace(" trg.flDeath: "+trg.flDeath );
		}



		b.chain = this;
		list.insert(index,b);
		Game.me.shots.remove(b);
		if( trg != null ) pos += Cs.ec*0.5;
		b.pos = pos+index*Cs.ec;

		// GET LINE
		checkCombo(index);

		//
		for( b in list )b.flInsert = true;


	}

	public function checkCombo(index){
		var color = list[index].col;
		var lim = [index,index];
		var to = 0;
		for( i in 0...2 ){
			var sens = i*2-1;
			while(true){
				var n = lim[i]+sens;
				if( list[n].col == color && color!=4 )lim[i] += sens;
				else break;
				if(to++>100){
					trace("INFINITE LOOP");
					trace("color"+color);
					trace("index"+index);
					break;
				}
			}
		}

		var id = lim[0];
		var length = 1 + lim[1] - lim[0];

		if( length >= Cs.COMBO_LIMIT ){


			// DESTRUCTION
			var mx = 0.0;
			var my = 0.0;
			for( i in 0...length ){
				var ball = list[id];
				mx+=ball.x;
				my+=ball.y;
				ball.explode();
			}
			mx /= length;
			my /= length;

			// SEPARATION

			if( list.length > id ){
				splice(id);

				// CHECK INTEGRITY
				//for( b in list )if(b.flDeath)		trace("Separated dead Balls [0]");
				//for( b in chain.list )if(b.flDeath)	trace("Separated dead Balls [1]");

			}



			// SCORE
			var sc = KKApi.cmult(Cs.SCORE_BALL,KKApi.const(length));
			if( combo!=null ){
				sc = KKApi.cmult(sc,KKApi.const(combo));

				var mc = Game.me.dm.attach("mcMulti",Game.DP_FX);
				mc._x = mx;
				mc._y = my;
				Reflect.setField(mc,"_val","x"+combo);
				mc._xscale = mc._yscale = 100+combo*20;
				Filt.glow(mc,4,6,Cs.COLORS_DARK[color]);
			}else{
				combo = 1;
			}


			// COMBO
			comboTimer = 20;
			combo++;


			KKApi.addScore(sc);
		}
	}


	public function splice(id){
		var a = list.splice(id,list.length-id);
		var chain = new Chain(getIndex()+1);
		chain.pos = a[0].pos;
		while(a.length>0)chain.addBall(a.shift());


			// AUTODESTRUCTION
			if(list.length==0)kill();

	}



	public function join(c:Chain){

		for( b in c.list )b.chain = this;
		list = list.concat(c.list);
		c.kill();
	}
	public function getIndex(){
		var id = 0;
		for( ch in Game.me.chains ){
			if( ch == this )return id;
			id++;
		}
		return null;
	}


	public function kill(){
		Game.me.chains.remove(this);

	}





//{
}











