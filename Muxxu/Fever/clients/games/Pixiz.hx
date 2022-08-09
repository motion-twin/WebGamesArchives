import mt.bumdum9.Lib;

typedef PixizCaps = {>flash.display.MovieClip,cid:Int,dec:Int,by:Float};

class Pixiz extends Game{//}

	static var COLORS = [
		[0xEC0202,0xFC61AE,0x980A0A],
		[0xEECC44,0xF4FDA4,0xFF9900],
		[0xAAEF65,0x2E8118,0x3CA321],
		[0x3D84ED,0x85CCFA,0x5C16C7],
	];

	var flyDec:Int;
	var glowTimer:Float;
	var flh:Null<Float>;
	var particulator:Float;
	var ballMax:Int;
	var ballScore:Int;
	var currentId:Int;
	var colorMax:Int;
	var wingDecal:Float;
	var xInc:Float;
	var yInc:Float;
	var caps:List<PixizCaps>;
	var blink:List<PixizCaps>;
	var pix:{>Phys, a:Float};

	override function init(dif:Float){
		gameTime =  520-100*dif;
		super.init(dif);
		ballScore = 0;
		ballMax = 8;
		colorMax = 1;
		if(dif>0.1)colorMax++;
		if(dif>0.35)colorMax++;
		if(dif>0.7)colorMax++;
		if(dif>0.9)ballMax++;
		if(dif>1)ballMax++;

		ballMax -= colorMax;

		currentId = 0;
		glowTimer = 0.0;
		flyDec= 0;
		attachElements();
		colorPix(currentId);
	}
	var faerie:Pixiz_faerie;
	function attachElements(){


		bg = dm.attach("pixiz_bg",0);

		// PIX
		pix = cast newPhys("Pixiz_faerie");
		pix.x = Cs.mcw*0.5;
		pix.y = Cs.mch*0.5;
		pix.a = 0;
		pix.frict = 0.7;
		pix.updatePos();
		pix.setScale(1.2);

		wingDecal = 0.0;
		yInc = 0.0;
		xInc = 0.0;
		particulator = 0.0;
		
		faerie = cast pix.root;
		faerie.body.stop();

		caps = new List();

		var ma = 20;
		for( cid in 0...colorMax ){
			for( i in 0...ballMax){
				var x = 0.0;
				var y = 0.0;
				while(true){
					x = ma+Math.random()*(Cs.mcw-2*ma);
					y = ma+Math.random()*(Cs.mch-2*ma);
					var dx = Cs.mcw*0.5-x;
					var dy = Cs.mch*0.5-y;
					var flBreak = Math.sqrt(dx*dx+dy*dy) > 80;
					if(flBreak){
						for( cap in caps ){
							var dx = cap.x-x;
							var dy = cap.y-y;
							if( Math.sqrt(dx*dx+dy*dy) < 30 ){
								flBreak = false;
								break;
							}
						}
					}
					if(flBreak)break;
				}

				var mc:PixizCaps = cast dm.attach("pixiz_caps",Game.DP_SPRITE);
				mc.x = x;
				mc.y = y;
				mc.by = y;
				mc.cid = cid;
				mc.dec = Std.random(628);
				var mmc:flash.display.MovieClip = cast(mc).smc;
				Col.setColor(mmc,COLORS[cid][0]);
				caps.push(mc);



			}
		}



	}

	override function update(){


		switch(step){
			case 1:	// CLICK
				var mp = getMousePos();
				var dx = mp.x - pix.x;
				var dy = mp.y - pix.y;
				var dist = Math.sqrt(dx*dx+dy*dy);
				if(dist<30)step++;

			case 2: // MOVE
				movePix();
				checkCols();
				
			case 3: // DESTRCUT
		}


		/// GLOW
		if(glowTimer--<=0){
			glowTimer = 30;
			for( mc in blink )new mt.DepthManager(mc).attach("pixiz_blink",0);
		}

		
		// FLH
		flashPix();


		super.update();
	}
	function flashPix() {
		if(pix == null) return;
		var cg = 1.0;
		if( flh !=null ){
			cg += (flh/100)*2;
			var prc = flh;
			flh *= 0.9;
			if(flh<1){
				flh=null;
				prc = 0;
			}
			Col.setPercentColor(pix.root,prc*0.01,0xFFFFFF);

		}
		pix.root.filters = [];
		Filt.glow(pix.root,2,4*cg,0xFFFFFF);
		Filt.glow(pix.root,10,1*cg,0xFFFFFF);
	}
	
	// PIX
	function movePix(){
		if(pix == null) return;
		var mp = getMousePos();
		var dx = mp.x - pix.x;
		var dy = mp.y - pix.y;
		var dist = Math.sqrt(dx*dx+dy*dy);
		var ta = Math.atan2(dy,dx);
		var da = Num.hMod(ta-pix.a,3.14);
		var lim = 0.6;
		pix.a += Num.mm(-lim,da*0.3,lim);

		var acc = Math.min(dist/80,1)*6;

		pix.vx += Math.cos(pix.a)*acc;
		pix.vy += Math.sin(pix.a)*acc;

		// FX
		particulator += Math.sqrt(pix.vx*pix.vx+pix.vy*pix.vy);
		var lim = 3;
		while(particulator>lim){
			particulator-=lim;
			fxTwinkle();
		}


		// GFX
		var dy = Num.mm( 0, 0.5+pix.y*0.15 , 1 ) - yInc;
		yInc += dy*0.2;
	

		var xi = xInc;
		var yi = yInc;
		var a = ta;
		yi = (1+Math.sin(a))*0.5;
		xi = Math.cos(a)*2;


		// BODY
		faerie.body.gotoAndStop(1+Math.floor(yi*40));

		// AILE HAUTEUR
		faerie.w0.w.w.scaleY = 1-0.8*yi;
		faerie.w1.w.w.scaleY = 1-0.8*yi;


		// BATTEMENT
			wingDecal = (wingDecal+(80-pix.vy*16))%628;

			// SCALE
			var sup = Math.cos(wingDecal/100)*45*(1-yi) + 75*yi;
			faerie.w0.w.w.scaleX = faerie.w1.w.scaleX = (50+sup)*0.01;

			// ROTATION
			faerie.w0.w.rotation = (Math.cos(wingDecal/100)*70)*yi;
			faerie.w1.w.rotation = (Math.cos(wingDecal/100)*70)*yi;



		// DECALAGE
		var dx  = pix.vx-xi;
		xi += dx*0.2;

		var mod1 = xi*12;
		var mod2 = -xi*50;

		if( pix.vx > 0 ){
			faerie.w0.scaleX =   1 + mod1/100;
			faerie.w1.scaleX =   1 + mod2/100;
		}else{
			faerie.w0.scaleX =   1 - mod2/100;
			faerie.w1.scaleX =   1 - mod1/100;
		}

		// PENCHE
		pix.root.rotation = xi*12;
		faerie.body.rotation = xi * 5;

		

	}
	function colorPix(cid:Int){

		var col = COLORS[cid];
		
		Col.setColor(faerie.w0.w,		col[0] );
		Col.setColor(faerie.w1.w,		col[0] );
		Col.setColor(faerie.body.tete.kami,	col[1] );
		Col.setColor(faerie.body.epaule.m,	col[2] );
		Col.setColor(faerie.body.corps.m,	col[2] );

		blink = new List();
		for( mc in caps )if(mc.cid == currentId)blink.push(mc);



		/*
		Mc.setColor( Std.cast(body).tete.kami, fi.skin.col1 )
		Mc.setColor(  Std.cast(body).body.col, fi.skin.col2 )
		Mc.setColor( body.w0.w, fi.skin.col3 )
		Mc.setColor( body.w1.w, fi.skin.col3 )
		*/
	}

	function checkCols() {
		//if( win != null ) return;
		flyDec = (flyDec + 23) % 628;
		for( mc in caps ) {
			//DEC
			var d = (flyDec+mc.dec)%628;
			mc.y = mc.by + Math.cos(d*0.01)*3;

			// COLS
			var dx = mc.x - pix.x;
			var dy = mc.y - pix.y;
			var flOk = mc.cid == currentId;
			if( Math.sqrt(dx*dx+dy*dy) < (flOk?26:20) ){
				if( flOk ){
					var ec = 10;
					for( i in 0...16 ){
						var p = newPhys("pixiz_vanish");
						p.x = mc.x + (Math.random()*2-1)*ec;
						p.y = mc.y + (Math.random()*2-1)*ec;
						p.sleep = Std.random(20);
						p.root.visible = false;
						p.root.stop();
						p.weight = -(0.1+Math.random()*0.1);
						p.root.blendMode = flash.display.BlendMode.ADD;
						p.root.alpha = 0.5;
						p.timer = 18;
						Col.setPercentColor(p.root,0.5+Math.random()*0.5,COLORS[mc.cid][0]);
					}


					//
					mc.parent.removeChild(mc);
					caps.remove(mc);

					//
					ballScore++;
					if(ballScore == ballMax ){
						currentId++;

						fxColorOk();

						if( currentId == colorMax ){
							setWin(true,10);
							step = 3;
						}else{
							ballScore = 0;
							colorPix(currentId);
						}
					}
				}else{
					setWin(false,30);
					fxEnd(mc);
					pix.kill();
					mc.parent.removeChild(mc);
					pix = null;
					step = 3;
					return;
				}
			}
		}
	}

	//FX
	function fxTwinkle(){
		var ec = 6;
		var c = 0.1+Math.random()*0.4;
		var p = newPhys("pixiz_twinkle");
		p.x = pix.x + (Math.random()*2-1)*ec;
		p.y = pix.y + (Math.random()*2-1)*ec;
		p.root.gotoAndPlay(Std.random(10)+1);
		p.vx = pix.vx*c;
		p.vy = pix.vy*c;
		p.weight = 0.05+Math.random()*0.1;
		p.timer = 16 + Std.random(10);
		p.setScale(0.3+Math.random()*0.5);
		return p;
	}
	function fxEnd(mc:PixizCaps){
		// BOOM
		var max = 8;
		for( i in 0...max ){
			var c = i/max;
			var ec  = c*20;
			var sp  = new Phys( dm.attach("pixiz_explosion",Game.DP_PART));
			sp.setScale(1-(c*0.5));
			sp.x = mc.x + (Math.random()*2-1)*ec;
			sp.y = mc.y + (Math.random()*2-1)*ec;
			sp.sleep = Std.int(c*6);
			sp.root.stop();
			sp.root.visible = false;
			sp.root.rotation = Math.random()*360;
			sp.vr = (Math.random()*2-1)*16;
			sp.fr = 0.92;
			sp.weight = -Math.random() * 0.35 * c;
			sp.timer = 17;
		}

		//
		fxBoomTwinkle(48,6);

	}
	function fxBoomTwinkle(max,speedMax,?cv:Float){
		var cr = 6;
		for( i in 0...max ){
			var p = fxTwinkle();
			var a = i/max*6.28;
			var sp = 2+Math.random()*speedMax;
			p.vx = Math.cos(a)*sp;
			p.vy = Math.sin(a)*sp;
			p.frict = 0.92;
			p.x += p.vx*cr;
			p.y += p.vy*cr;
			p.timer += 20;
			if(cv!=null){
				p.vx += pix.vx*cv*(0.5+Math.random()*0.5);
				p.vy += pix.vy*cv*(0.5+Math.random()*0.5);
			}
		}
	}

	function fxColorOk(){
		flh = 100;
		fxBoomTwinkle(24,4);
		var mc = dm.attach("fx_onde",Game.DP_PART);
		mc.x = pix.x;
		mc.y = pix.y;
		glowTimer = 0;
	}
//{
}
















