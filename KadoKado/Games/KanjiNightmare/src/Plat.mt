class Plat extends Sprite{//}

	var w:float;
	var bx:float;
	var gfx:{>MovieClip, mask:MovieClip,corner:MovieClip,text:MovieClip}
	var grap:Grap;
	
	function new(mc) {
		Cs.game.platList.push(this);
		super(mc);
		gfx = downcast(mc);
		
	}
	
	function setPlat(nx,ny,nw){
		var dx = nx-x
		x = nx;
		y = ny;
		w = nw;
		gfx.mask._xscale = w-38; 
		gfx.corner._x = w-19;
		gfx.text._x -= dx		
		updatePos();
	}
	
/*
	function initStep(n){
		super.initStep(n)
		switch(step){
			case Cs.ST_NORMAL:
				if(!flWalk){
					flWalk = true;
					root.gotoAndPlay("walk")
				}
				break;
			case Cs.ST_FLY:
				flGround = false;
				break;			
			case Cs.ST_CLIMB:
				root.gotoAndPlay("climb")
				break;
		}
	}

	function update() {
		super.update();
		switch(step){
			case Cs.ST_NORMAL:
				var dvx = sens*speed - vx
				var lim = 0.5
				vx += Math.min(Math.max(-lim,dvx),lim)*Timer.tmod 
				break;
			case Cs.ST_FLY:
				if(flFlyUp && vy>0 ){
					flFlyUp = false;
					root.gotoAndPlay("fly_down")
				}
				break;					
		}
		
	}
	*/
	
	function update(){
		super.update();
		//Log.print(x+w)
	}
	
	function explode(sx){
		var flKill = false;
		var wx = sx-x
		if(w-wx<100){
			flKill = true;
			wx = w
		}
		// FX
		if(sx+Cs.game.map._x > 0 ){
			
			// PARTS
			for( var i=0; i<wx*0.1; i++){
				var p = Cs.game.newPart("partDust");
				p.x = x + Math.random()*wx;
				p.y = y + Math.random()*8;
				p.setScale(100+Math.random()*100);
				p.weight = 0.1+Math.random()*0.3;
				p.timer = 20+Math.random()*10;
				p.fadeType = 0;
			}
			
			// PLAT
			var dig = wx
			var xd = x
			while(dig>30){
				
				var ww = Cs.mm(30,Math.random()*dig,100) 
				
				var p = new Part(Cs.game.mdm.empty(Game.DP_PLAT))
				p.x = xd+ww*0.5
				p.y = y+5
				var dm = new DepthManager(p.root)
				var pl = new Plat(dm.attach("mcPlat",0));
				pl.x = -ww*0.5
				pl.setPlat(pl.x,-5,ww)
				pl.root = null;
				pl.kill();
				
				p.weight = 0.2+Math.random()*0.2;
				p.vr = (Std.random(2)*2-1)*(0.5+Math.random()*(Math.max(4-ww*0.05,0)) )
				p.timer = 30+Math.random()*10;
				
				xd+=ww;
				dig-=ww;
				
			}
			
			// MONS
			for( var i=0; i<Cs.game.mList.length; i++){
				var mons = Cs.game.mList[i]
				if(mons.plat == this && (sx>mons.x || flKill) ){
					mons.initStep(2);
				}
			}
			// GRAP
			
			if(grap!=null){
				if(sx>grap.x  || flKill ){
					//grap.drop();
					Cs.game.hero.releaseGrap();
				}
			}
			
			
		}
		
		
		if(flKill){
			if(this==Cs.game.hero.plat){
				Cs.game.hero.initStep(Hero.FLY);
			}
			kill();
		}else{
			setPlat(x+wx,y,w-wx);
		}
		/*
		if(pl==Cs.game.hero.plat){
			Cs.game.hero.initStep(Hero.FLY);
		};
		removeMovieClip();
		*/
	}
	
	function isOut(tx){
		return tx<x ||tx>x+w;
	}
	
	function kill(){
		
		Cs.game.platList.remove(this);
		super.kill();
	}
//{
}








