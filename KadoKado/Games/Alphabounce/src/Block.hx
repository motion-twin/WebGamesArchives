import mt.bumdum.Phys;
import mt.bumdum.Sprite;
import mt.bumdum.Lib;
import KKApi;

class Block {//}

	var flIce:Bool;
	public var flDeath:Bool;
	public var root:flash.MovieClip;
	public var x:Int;
	public var y:Int;
	public var type:Int;
	public var life:Float;
	public var color:Int;
	public var score:KKConst;
	var blink:flash.MovieClip;

	public function new(px,py,?t){

		Game.me.block++;
		Game.me.blocks.push(this);

		x = px;
		y = py;
		Game.me.grid[x][y] = this;
		flIce = false;
		flDeath = false;

		//
		root = Game.me.bdm.attach("mcBlock",0);
		root._x = Cs.getX(x);
		root._y = Cs.getY(y);
		root._width = Cs.BW;
		root._height = Cs.BH;

		//
		if(t!=null)setType(t);
		//

	}

	public function setType(t){
		type = t;
		if(type<10){

			life = Math.min(type,5);
			type = 0;
			color = Game.me.bmpPaint.getPixel(x,y);
			score =  Cs.SCORE_BLOCK;
			if(type>5)trace(type);
		}else if(type<=12){
			var id = type-10;
			score = Cs.SCORE_BONUS[id];
			life = 0;
			color = [0xB3FD02,0x0BCDFD,0xFF5599][id];
		}

		switch(type){
			case 13:
				life = 0;
				score = Cs.SCORE_0;
				color = 0xFFFFFF;
		}


		if(type>13)trace(type);

		setSkin(root);

	}

	public function setColor(col){
		color = col;
		Col.setColor(root.smc.smc,color);
	}
	public function setLife(n){
		life = n;
		if(root.smc!=null)root.smc.gotoAndStop(Std.int(life)+1);
		if(color!=null)setColor(color);
	}
	public function setSkin(mc){
		if(type<5){
			mc.gotoAndStop(1);

		}else if(type<=12){
			var id = type-10;
			mc.gotoAndStop(id+2);
		}else{
			mc.gotoAndStop(type-8);
		}
		if(mc.smc!=null)mc.smc.gotoAndStop(Std.int(life)+1);
		Col.setColor(mc.smc.smc,color);
	}

	//
	public function damage(ball:Ball){

		if(flIce){
			explode();
			return;
		}

		if( ball.type == Cs.BALL_ICE ){
			iceIt();
			return;
		}

		var n = ball.damage;
		if(life>=n){
			setLife(life-n);

			// BLINK
			var mc = Game.me.dm.attach("mcBlink",Game.DP_BLOCK);
			mc._x = root._x;
			mc._y = root._y;
			mc._xscale = root._xscale;
			mc._yscale = root._yscale;
			blink = mc;
			//
			KKApi.addScore(Cs.SCORE_BOUNCE);

		}else{
			explode();
		}
	}
	function iceIt(){

		type = 0;
		score = Cs.SCORE_ICE;
		flIce = true;
		var mc = new mt.DepthManager(root).attach("mcIce",0);
		mc.gotoAndStop(Std.random(mc._totalframes)+1);
		var nx = Std.random(2);
		var ny = Std.random(2);
		mc._xscale = (nx*2-1)*100;
		mc._yscale = (ny*2-1)*100;
		mc._x = (1-nx)*30;
		mc._y = (1-ny)*10;

	}
	public function explode(){


		KKApi.addScore(score);

		// PARTS
		var max = Std.int( Num.mm( 2, 24-Sprite.spriteList.length*0.25, 16 ) );
		if(type<5){

			var mc = Game.me.dm.attach("partExplode",Game.DP_PARTS);
			mc._x = root._x;
			mc._y = root._y;
			mc._xscale = root._xscale;
			mc._yscale = root._yscale;
			if(color!=null)	Col.setColor(mc,color);
			for( n in 0...max ){
				var p = new fx.Part( Game.me.dm.attach("mcPart",Game.DP_PARTS) );
				initExplode(p);
				p.bouncer.setPos(p.x,p.y);
				p.updatePos();
				if(color!=null)	Col.setColor(p.root,color);
				/*
				if(flIce){
					new mt.DepthManager(p.root).attach("mcIceStone",0);
				}
				*/

			}
			if( Math.random()<Cs.OPTION_COEF && Game.me.options.length< Cs.MAX_OPTION )Game.me.newOption(null,Cs.getX(x+0.5),Cs.getY(y+0.5));

		}else if(type<=12){


			var ma = -0.5;
			for( i in 0...max ){
				var p = new Phys( Game.me.dm.attach("partTwinkle",Game.DP_PARTS) );
				var a = i/max * 6.28;
				var ray = 5+Math.random()*20;
				p.x = Cs.getX(x+0.5) + Math.cos(a)*ray ;
				p.y = Cs.getY(y+0.5) + Math.sin(a)*ray ;

				p.timer = 10+Math.random()*10;
				p.fadeType = 0;
				p.setScale(50+Math.random()*100);
				p.sleep = Math.random()*(ray-5);
				p.vy -= Math.random();
				p.root.blendMode = "add";
				p.root.gotoAndPlay(Std.random(2)+1);
				p.updatePos();

			}
		}

		// EFFECT
		switch(type){
			case 13:
				var b = Game.me.newBall();
				b.moveTo( root._x+Cs.BW*0.5,root._y+Cs.BH*0.5);
				b.setAngle(Math.random()*6.28);
				for( n in 0...max ){
					var p = new fx.Part( Game.me.dm.attach("partGlass",Game.DP_PARTS) );
					initExplode(p);
					p.bouncer.setPos(p.x,p.y);
					p.root._rotation = Math.random()*2-1;
					p.vr = (Math.random()*2-1)*12;
					p.setScale(p.scale*(1+Math.random()*0.6));
					p.root.gotoAndStop(Std.random(p.root._totalframes)+1);
					p.updatePos();
				}
		}



		// PART ICE
		if(flIce){
			for( n in 0...Std.int(max*0.5) ){
				var p = new Phys( Game.me.dm.attach("partIceShard",Game.DP_PARTS) );
				initExplode(p);
				p.weight*=0.5;
				p.root._rotation = Math.atan2(p.vy,p.vx)/0.0174;
				p.vr = (Math.random()*2-1)*6;

			}
		}

		//
		// PART SCORE
		if(KKApi.val(score)>=200){
			var o = Col.colToObj(color);
			o.r = Std.int(Math.max(o.r-100,0));
			o.g = Std.int(Math.max(o.g-100,0));
			o.b = Std.int(Math.max(o.b-100,0));
			Game.me.displayScore(Cs.getX(x+0.5),Cs.getY(y+0.5),KKApi.val(score),Col.objToCol(o),1);

			/*
			var psc = new Phys( Game.me.dm.attach("mcScore",Game.DP_PARTS) );
			psc.x = Cs.getX(x+0.5);
			psc.y = Cs.getY(y+0.5);
			psc.vy = -0.5;
			psc.timer =  30;
			var field:flash.TextField = (cast psc.root).field;
			field.text = Std.string(KKApi.val(score));
			psc.fadeLimit = 5;
			psc.fadeType = 0;

			var o = Col.colToObj(color);
			o.r = Std.int(Math.max(o.r-100,0));
			o.g = Std.int(Math.max(o.g-100,0));
			o.b = Std.int(Math.max(o.b-100,0));
			Filt.glow(cast field, 4, 2, Col.objToCol(o));
			*/
		}
		//
		kill();
	}
	function initExplode(p){

		var cx = root._x + Cs.BW*0.5;
		var cy = root._y + Cs.BH*0.5;

		p.x = Cs.getX(x+Math.random());
		p.y = Cs.getY(y+Math.random());
		var dx = p.x-cx;
		var dy = p.y-cy;
		var a = Math.atan2(dy,dx);
		var sp = Math.sqrt(dx*dx+dy*dy)*0.2;
		p.vx = Math.cos(a)*sp;
		p.vy = Math.sin(a)*sp;
		//
		p.timer = 10+Math.random()*30;
		p.weight = 0.05+Math.random()*0.1;
		p.fadeType = 0;
		p.frict = 0.98;
		p.setScale(p.weight*700);
	}


	//
	public function kill(){
		flDeath = true;
		Game.me.removeBlock();
		if(blink._visible)blink.removeMovieClip();
		Game.me.grid[x][y] = null;
		Game.me.blocks.remove(this);
		root.removeMovieClip();
	}


//{
}













