class ac.Effect extends Action{//}

	static var FL_BG_CACHE = false
	
	var data:DataEffect;
	var fxId:float;
	var pow:float;
	var timer:float;
	
	var from:Card;
	var bmc:MovieClip;
	
	var pList:Array<Paillette>
	var partList:Array<Paillette>
	var trg:Array<Sprite>;
	var spikeList:Array<{>MovieClip, vr:float, c:float, vc:float, card:Sprite }>
	var rootList:Array<{ x:float, y:float, a:float, va:float, decal:float, pid:int, xMin:float, yMin:float, xMax:float, yMax:float, flSwap:bool, size:float, leafSide:int,speed:float }>
	var windList:Array<{ x:float, y:float, a:float, speed:float, ca:float, lma:float, card:Card }>
		
	var ln:{dx:float,dy:float,vx:float,vy:float,ecx:float,ecy:float,seg:int,screen:MovieClip,ma:Array<Array<{>Phys,link:int}>>}
	var copy:{>MovieClip,bmp:flash.display.BitmapData};
	static var COLORS = [0xFF0000,0x88FF00,0x0000FF,0xCCCCFF,0xFFFFBB]
	
	
	var plans:Array<{>MovieClip,bmp:flash.display.BitmapData}>
	
	
	function new(d){
		super(d)
		data = downcast(primedata);
	}
	function init(){
		//Log.trace("fx!")
		super.init();
		if(Cs.game.flPenguin){
			kill();
			return;
		}
		if( FL_BG_CACHE ){
			copy = downcast(Cs.game.dm.empty(Game.DP_CARD))
			copy.bmp = new flash.display.BitmapData(Cs.mcw,Cs.mch,true,0x00000000);
			copy.bmp.draw( Cs.game.mcCards, new flash.geom.Matrix(), null, null, null, null )
			copy.attachBitmap(copy.bmp,0)
			Cs.game.mcCards._visible = false;
		}
		
		/* TRACE INFO
		Log.clear();
		Log.trace("FX!")
		Log.trace(data)
		//*/
		// RESET PLASMA
		Cs.game.resetPlasma();
		Cs.game.mcPaillette.filters = []
		Cs.game.mcPaillette._alpha = 100
		
		// FX ID
		fxId = data.$fxId

		// FROM
		from = Card.getCard(data.$from);
		from.fxFlash(1);
		
		// TRG
		trg = [];
		switch( data.$typeTarget){
			case 2:
				var pl = Cs.game.getPlayer(data.$targets[0])
				trg = [ upcast(pl.avatar) ]
				break;
			default:
				for( var i=0; i<data.$targets.length; i++ )trg.push(Card.getCard(data.$targets[i]));
				break;
		}

		pList = []
		partList = []
		//Log.trace(fxId)
		switch(fxId){
			case 0:
			case 1:
			case 2:
				pow = fxId
				initStandard(12+fxId*10);
				break
			case 5:
			case 6:
			case 7:
				pow = (fxId-5)
				initShot();
				break;
			case 10: // BUFF
				initBuff();
				break;
			
			case 11: // FLASH LIB
			case 12: // FLASH GRAVEYARD
				initFlashDeck();
				break;
			case 20: // HEAL
				initHeal(30);
				break;
			case 30: // LIGHTNING
				initLightning();
				break;
			case 40: // SPIKE
				initSpikes();
				break;
			case 80: // RACINES
				initRoots();
				break;
			case 81: // WIND
				initWind();
				break;						
			case 100: // VOL
				from.front();
				initWings();
				break;
			default:
				kill()
				break;
		}
		
		
		
		
		
		
	}
	function update(){
		super.update();
		if(timer>0){
			timer-=Timer.tmod;
		}
		switch(fxId){
			case 0:
			case 1:
			case 2:
				updateStandard();
				break
			case 5:
			case 6:
			case 7:
				updateShot();
				break;
			case 10:
				updateBuff();
				break;
			case 11:
			case 12:
				updateFlashDeck();
				break;			
			case 20:
				updateHeal();
				break;
			case 30:
				updateLightning();
				break;	
			case 40:
				updateSpikes();
				break;		
			case 80:
				updateRoots();
				break;
			case 81:
				updateWind();
				break;	
			case 100:
				updateWings();
				break;
			default:
				kill()
				break;
		}
				
		
	}
	
	// STANDARD
	function initStandard(max){
		var el = from.data.$element
		
		
		// TRG
		
		if(data.$typeTarget!=2){
			for( var i=0; i<trg.length; i++ ){
				var card:Card = downcast(trg[i])
				card.fxFlash(1)
				card.flh = {val:0,sens:0.5}
			}
		}
		
		//
		switch(el){
			case 0: // FIRE
				var inc = -10
				var m = 1			
				Cs.game.setPlasmaFader([[0],[2, m,m,m,1, inc*0.5,inc,inc,-40 ], [3,0,-1] ])
				break;
			
			case 1: // WOOD
				var inc = -20
				var m = 1.1
				//Cs.game.setPlasmaFader([[0],[1,4],[2, m,m,m,1, inc,inc,inc*0.5,-15 ] ])
				break;
			
			case 2: // WATER
			
				var m = 1
				var inc = -40
				Cs.game.setPlasmaFader([[2, m,m,m,1, inc*2,inc*0.8,inc*0.05,-20 ],[1,4],[0] ])

				var fl = new flash.filters.GlowFilter()
				fl.blurX = 5
				fl.blurY = 5
				fl.strength = 5
				fl.color = 0xFFFFFF
				fl.knockout = true
				Cs.game.mcPaillette.filters = [fl]
				Cs.game.mcPaillette._alpha = 0
				//Cs.game.mcPaillette._visible = false;
				break;
			case 3: // LIGHTNING
				break;
				
			case 4: // SKY
				break;
				

		}
		
		// PARTS
		var trgId = 0
		var maxRange = 0
		for( var i=0; i<max; i++){
			var p = new Paillette(null)
			p.setStartPos(from)
			p.angle = from.getAng(p)//Math.random()*6.28
			p.speed = 3+Math.random()*8
			p.speedMax = 14+Math.random()*6
			p.setVit(p.speed);
			p.frict = 1
			p.setTrg(trg[trgId])
			p.sleep = Math.random()*14
			maxRange = Math.max( maxRange, p.getDist(trg[trgId]))
			p.angleCoef = 0.1
			p.angleSpeed = 0.2
			p.bList = [[0]]
			trgId = (trgId+1)%trg.length;
			
			pList.push(p)
			
			
			p.setSkin(el+1)
			
			switch(el){
				case 0: // FIRE
					p.root.blendMode = BlendMode.ADD
					p.flOrient = true;
					p.root.smc.gotoAndPlay(string(Std.random(p.root.smc._totalframes)+1))
					break;
				
				case 1: // WOOD
					p.root.blendMode = BlendMode.ADD
					p.setScale(30+Math.random()*50)
					break;
				
				case 2: // WATER
					break;
				case 3: // LIGHTNING
					p.root.blendMode = BlendMode.ADD
					p.root.smc.gotoAndPlay(string(Std.random(p.root.smc._totalframes)+1))
					break;
					
				case 4: // SKY
					var sens = Std.random(2)*2-1
					p.vr = Math.random()*8*sens
					p.root.smc._xscale = sens*100
					p.setScale(50+Math.random()*100)
					//Log.trace(p.root._visible)
					break;
					

			}
		}
		
		// TIMER
		timer = 32+maxRange*0.065
	}
	function updateStandard(){
		if( timer<0 ||Cs.game.flClick ){
			for( var i=0; i<pList.length; i++){
				
				var pai = pList[i]
				var pt = pai.trg
				var p = pai.morphToPart()
				var a = pt.getAng(p)
				var sp = Math.min( 100/pt.getDist(p), 10)
				var c = 0.2
				p.vx = p.vx*c+Math.cos(a)*sp
				p.vy = p.vy*c+Math.sin(a)*sp
				p.fadeType = 0
				//
				pai.root = null;
				pai.kill();	
				switch(from.data.$element){
					case 1:
						p.root.smc.gotoAndPlay(string(5+Std.random(10)))
						p.weight = 0.1+Math.random()*0.1
						p.timer += 20+Math.random()*20
						p.setScale(p.scale*2)
						p.root.blendMode = null;
						var inc = -20
						var m = 1.1					
						Cs.game.setPlasmaFader([[0],[1,4],[2, m,m,m,1, inc,inc,inc*0.5,-30 ] ])
						
						break;
				}				
			}
			
			// TRG
			if(data.$typeTarget!=2){
				for( var i=0; i<trg.length; i++ ){
					var card:Card = downcast(trg[i])
					card.flh.sens = -2
				}
			}			
			kill();
		}
	}

	// SHOT
	function initShot(){
		var el = from.data.$element
		
		
		// PLASMA
		Cs.game.setPlasmaFader(null)
		Cs.game.mcPaillette.filters = []
		Cs.game.mcPaillette._alpha = 100
		switch(el){
			case 0: // FIRE
				break;
		}
		
		// PARTS
		for( var i=0; i<trg.length; i++ ){
			var p = new Paillette(null)
			p.x = from.x
			p.y = from.y
			p.setTrg(trg[i])
			p.angle = p.getAng(p.trg)
			p.setVit(20)
			p.setSkin(el+6)
			p.orient();
			p.frict = 1
			p.setScale(50+pow*50)
			pList.push(p)
			switch(el){
				case 0: // FIRE
					Cs.glow(p.root,18,5,0xFFFF88)
					break;
				
				case 1: // WOOD
					break;
				
				case 2: // WATER
					break;
				
				case 3: // LIGHTNING
					break;
				
				case 4: // SKY
					break;
			}
		}
		// TIMER
		//timer = 20+maxRange*0.065
	}
	function updateShot(){
		
		for( var k=0; k<pList.length; k++ ){
			var mp = pList[k]
			if(mp==null)break;
			if( Math.abs(Cs.hMod(mp.getAng(mp.trg)-mp.angle, 3.14)) > 1 || Cs.game.flClick ){
				var max = 20+pow*12
				var ray = 10+pow*5
				
				max = Math.max(10, max/trg.length)
				
				for( var i=0; i<max; i++){
					var p = new Spark(null);
					var a = i/max * 6.28
					var ca = Math.cos(a)
					var sa = Math.sin(a)
					var sp = 4 + i%5 + Math.random()*4
					p.x = mp.trg.x + ca*ray
					p.y = mp.trg.y + sa*ray
					p.vx = ca*sp
					p.vy = sa*sp
					p.timer = 30+Math.random()*40
					p.length = 2
					p.size = 2
					p.color = [0xFFFFFF,COLORS[from.data.$element]]
					p.gz = 0.3+Math.random()*0.3
					p.z = 0
					p.vz = -( 4+Math.random()*5 -sp*0.4 )
					p.initOp()
				}
				mp.kill();
				pList.splice(k--,1)
			}
		}
		
		if(pList.length==0){
			kill()
		}
		
	}
	
	// BUFF
	function initBuff(){
		for( var i=0; i<trg.length; i++ ){
			downcast(trg[i]).fxAura( COLORS[from.data.$element] );
		}
		timer = 20
	}
	function updateBuff(){
		if( timer<0 ||Cs.game.flClick ){
			kill();
		}
	}

	// FLASH DECK
	function initFlashDeck(){
		var pl = Cs.game.getPlayer(data.$targets[0]);
		var deck = pl.pack;
		if(fxId==12)deck = pl.graveyard;
		
		for( var i=0; i<64; i++ ){
			var p = new fx.Line(Cs.game.dm.attach("partPix",Game.DP_PART));
			p.x = deck.x+(Math.random()*2-1)*Card.WW*0.4;
			p.y = deck.y+(Math.random()*2-1)*Card.HH*0.4;
			p.weight = -(0.2+Math.random()*0.4);
			p.cy = 3;
			p.timer = 10+Math.random()*10;
			p.freezeTimer = Math.random()*10;
			p.root.blendMode = BlendMode.ADD;
			Cs.glow(p.root,20,2,0xFFFFFF);

		}
		timer = 30;
	}
	function updateFlashDeck(){
		if( timer<0 ||Cs.game.flClick )kill();
	}
	
	// HEAL
	function initHeal(max){
		for( var k=0; k<trg.length; k++){
			var pmax = Math.min(20,max/trg.length)
			for( var i=0; i<pmax; i++){
				var p = Cs.game.newPart("partTwinkle")
				Cs.setStartPos(p,trg[k])
				p.freeze(Math.random()*10)
				p.vr = (Math.random()*2-1)*20
				p.timer = p.freezeTimer + 10 + Math.random()*10
				p.fadeType = 0
				p.root.blendMode = BlendMode.ADD
				var col = {
					r:Std.random(255),
					g:Std.random(255),
					b:Std.random(255)
				}
				Cs.setPercentColor( p.root, 20, Cs.objToCol(col) )
			}
		}
		timer = 20
		
	}
	function updateHeal(){
		if( timer<0 ||Cs.game.flClick )kill();
	}
	
	// LIGHTNING
	function initLightning(){
		var t = trg[0]
		var seg = int(from.getDist(t)/16)
		ln = {
			dx:0,//(Math.random()*2-1)*50,
			dy:-10,//(Math.random()*2-1)*100,
			vx:0,//(Math.random()*2-1)*3,
			vy:-8,//(Math.random()*2-1)*3,
			ecx:(t.x-from.x)/seg,
			ecy:(t.y-from.y)/seg,
			seg:seg,
			screen:Cs.game.dm.empty(Game.DP_PART),
			ma:[]
		}
		
		// MINI ARCS
		for( var k=0; k<2; k++ ){
			ln.ma.push([])
			for( var i=0; i<3; i++ ){
				var sp = downcast(new Phys(null))//Cs.game.dm.attach("partTest",Game.DP_PART)))
				var card:Sprite = trg[0]
				if(k==0)card = upcast(from);
				Cs.setStartPos(sp,card)
				sp.link = 1+Std.random(5)
				ln.ma[k].push(sp)
			}
		}
		//
		timer = 25
		ln.screen.blendMode = BlendMode.ADD
		Cs.game.setPlasmaFader(null)
		Cs.game.mcPlasma.bmp.fillRect(Cs.game.mcPlasma.bmp.rectangle,0x88000000)
		
	
	}
	function updateLightning(){
		
		
		//
		var fr = Math.pow(0.95,Timer.tmod)
		ln.dx += ln.vx*Timer.tmod;
		ln.dy += ln.vy*Timer.tmod;
		ln.dx *= fr
		ln.dy *= fr
		//
		ln.screen.clear();
		
		var a = []
		// ARC PRINCIPALE
		var noise = 14//8
		for( var i=0; i<ln.seg; i++ ){
			var c = Math.sin(i/(ln.seg-1)*3.14)
			var px = from.x + ln.ecx*i + c*((Math.random()*2-1)*noise +ln.dx) ;
			var py = from.y + ln.ecy*i + c*((Math.random()*2-1)*noise +ln.dy) ;
			a.push([px,py,4,c])
		}
		
		// MINI ARCS
		var scc = from.scale/100
		var mx = Card.WW*0.5*scc
		var my = Card.HH*0.5*scc
		for( var k=0; k<ln.ma.length; k++ ){
			for( var i=0; i<ln.ma[k].length; i++ ){
				var sp = ln.ma[k][i]
				var card:Sprite = trg[0];
				if(k==0)card=upcast(from);
				
				// MOVE
				sp.toward(card,0.5,12);
				var dist = sp.getDist(card)
				
				// TRACE ARC
				a.push( [ sp.x, sp.y, null ] )
				var index = int(Math.max(1,7-dist*0.1))
				var end = { x:a[index][0], y:a[index][1] }
				if(k==1){
					end.x = a[ln.seg-index][0]
					end.y = a[ln.seg-index][1]
				}
				var seg = sp.getDist(end) / 16//16
				var ecx = (end.x-sp.x)/seg
				var ecy = (end.y-sp.y)/seg
				for( var n=0; n<seg; n++){
					var c = Math.sin(n/(seg-1)*3.14)
					var px = sp.x + ecx*n + c*((Math.random()*2-1)*noise*0.5 + 0  ) ;
					var py = sp.y + ecy*n + c*((Math.random()*2-1)*noise*0.5 - 20 ) ;
					a.push( [ px, py , 0.5, 0 ] )
				}
				
				
				
				/*
				
				a.push( [ a[index][0], a[index][1],0.5, 0 ] )
				*/
				
				
				//
				if( dist<10 )Cs.setStartPos(sp,card);
			}
		}
		
		// DRAW
		for( var n=0; n<2; n++ ){
			var sizeBonus = (1-n)*8//*27
			var color = 0xFFFFFF
			if(n==0)color = 0x333300;
			ln.screen.moveTo(from.x,from.y);	
			for( var i=0; i<a.length; i++ ){
				var p = a[i]
				if(p[2]==null){
					ln.screen.moveTo(p[0],p[1])
				}else{
					Std.cast(ln.screen).lineStyle( (p[2]+sizeBonus)*(p[3]*0.5+0.5) ,color,100,null,null,"$square".substring(1),"$miter".substring(1),8);
					ln.screen.lineTo(p[0],p[1])
				}
			}
		}
		
		if( timer<0 ||Cs.game.flClick ){

			//Cs.game.mcPlasma.bmp.fillRect(Cs.game.mcPlasma.bmp.rectangle,0x00000000)
			//
			Cs.game.plasmaDraw(ln.screen)
			var m = 2
			var inc = 8
			Cs.game.setPlasmaFader([ [2, m,m,m,1, inc,inc,inc,-12 ],[1,6] ] )
			//
			for( var i=0; i<ln.ma.length; i++ )while(ln.ma[i].length>0)ln.ma[i].pop().kill();
			ln.screen.removeMovieClip();
			ln = null;			
			//
			kill();		
		}
		
		//
		//Cs.game.plasmaDraw(ln.screen)
		
	}
	
	// SPIKES
	function initSpikes(){
		spikeList = []
		/*
		for( var i=0; i<2; i++ ){
			newSpike();
		}
		*/
		var inc = -20
		var m = 1.1
		Cs.game.setPlasmaFader([[2, m,m,m, 1, inc,inc,inc, -20 ],[1,4] ])
		
		timer = 50
		Cs.game.dm.swap(Cs.game.mcPlasma, Game.DP_CARD )
		for( var i=0; i<trg.length; i++ ){
			Cs.game.dm.over(trg[i].root)
		}
		
		//Cs.game.mcPlasma.bmp.fillRect(Cs.game.mcPlasma.bmp.rectangle,0xFF000000)
	}
	function newSpike(){
		var mc = downcast(Cs.game.dm.attach("partSpike",Game.DP_PART))
		mc._rotation = Math.random()*360
		mc.vr = (Math.random()*2-1)*5
		mc.c =  0
		mc.vc = 0.1+Math.random()*0.2
		mc.card = trg[Std.random(trg.length)]
		mc._x = mc.card.x;
		mc._y = mc.card.y;
		mc.blendMode = BlendMode.ADD
		mc._visible = false;	
		mc.gotoAndStop(string(from.data.$element+1))
		
		spikeList.push(mc)
		
		return mc;
	}
	function updateSpikes(){
		for( var i=0; i<spikeList.length; i++ ){
			var mc = spikeList[i]
			mc._rotation += mc.vr*Timer.tmod;
			mc.c += mc.vc*Timer.tmod;
			mc._xscale = 100 + (Math.sin(mc.c)+1)*120;
			mc._yscale = 10+90*Math.sin(mc.c)
			mc._y = mc.card.y + Math.sin(mc._rotation*0.0174)*16.5
			if(mc.c>3.14){
				mc.removeMovieClip();
				spikeList.splice(i--,1);
			}
			Cs.game.plasmaDraw(mc)
		}
		var max = 12
		while(spikeList.length<max)newSpike();
	
		/*
		if( Math.random()<0.5){ 
			for( var i=0; i<trg.length; i++ ){
				var card = trg[i]
				card.root.blendMode = BlendMode.ADD
				Cs.game.plasmaDraw(card.root)
				card.root.blendMode = BlendMode.NORMAL
			}
		}
		*/
		// INNER GLOW
		for( var i=0; i<trg.length; i++ ){
			var card = trg[i]
			var fl = new flash.filters.GlowFilter();
			var b = Math.sin((timer/100)*3.14)*60
			fl.blurX = b
			fl.blurY = b
			fl.inner  = true;
			fl.color = 0xFFFFFF
			//fl.strength = 2
			card.root.filters = [fl];
		}
		
			
		if( timer<0 ||Cs.game.flClick ){
			/*
			var inc = -40
			var m = 1.2
			Cs.game.setPlasmaFader([[2, m,m,m, 1, inc,inc,inc, -40 ],[1,8] ])
			Cs.game.mcPlasma.ftimer = 12
			*/
			while(spikeList.length>0)spikeList.pop().removeMovieClip();
			Cs.game.dm.swap(Cs.game.mcPlasma, Game.DP_PAILLETTE )
			Cs.game.fadeBg(0)
			
			// PARTS
			for( var i=0; i<32; i++ ){
				var p = Cs.game.newPart("partLight");
				var card = trg[Std.random(trg.length)];
				Cs.setSidePos(p,card);
				var a = card.getAng(p);
				var sp = 0.5+Math.random()*2.5;
				var side = 10;
				p.vx = Math.cos(a)*sp;
				p.vy = Math.sin(a)*sp;
				p.x += Math.cos(a)*side;
				p.y += Math.sin(a)*side;
				p.timer = 10+Math.random()*10;
				p.setScale(100+Math.random()*150);
				p.fadeType = 0;
			}
			
			// CARDS
			for( var i=0; i<trg.length; i++ ){
				var card = trg[i]
				card.root.filters = [];
			}
			
			//
			kill();
		}

		
		Cs.game.mcPlasma.ftimer = 100
	}
	
	// ROOTS
	function initRoots(){
		plans = []
		for( var i=0; i<2; i++ ){
			var mc = downcast(Cs.game.dm.empty(Game.DP_CARD));
			mc.bmp = new flash.display.BitmapData(Cs.mcw,Cs.mch,true,0x00000000);
			mc.attachBitmap(mc.bmp,0);
			plans.push(mc);
			if(i==0)Cs.game.dm.under(mc);
		}
		rootList = []
		for( var i=0; i<10; i++ ){
			var card = trg[Std.random(trg.length)]
			
			var ww = Card.WW*0.5*card.scale/100,
			var hh = Card.HH*0.5*card.scale/100,
			var o = {
				x:card.x+(Math.random()*2-1)*ww
				y:card.y+(Math.random()*2-1)*hh
				a:Math.random()*6.28,
				va:0,
				decal:Math.random()*628,
				xMin:card.x-ww,
				yMin:card.y-hh,
				xMax:card.x+ww,
				yMax:card.y+hh,
				speed:8+Math.random()*6
				flSwap:null,
				size:100,
				leafSide:1,
				pid:0
			}
			rootList.push(o)
		}
		timer = 70
	}
	function updateRoots(){
		

		//var speed = 8*Timer.tmod;
		var mc = Cs.game.dm.attach("mcRoot",Game.DP_FRONT);
		
		for( var i=0; i<rootList.length; i++ ){
			var o = rootList[i]
			var speed = o.speed*Timer.tmod;
			o.va += (Math.random()*2-1)*0.15
			o.va *= Math.pow(0.9,Timer.tmod)
			o.a += o.va*Timer.tmod
			// LIM
			/*
			var flWillFlip = false;
			if( o.x<o.xMin || o.x>o.xMax ){
				o.a = Math.atan2(Math.sin(o.a),-Math.cos(o.a))
				o.x = Cs.mm( o.xMin, o.x, o.xMax )
				flWillFlip = true;
				
			}
			if( o.y<o.yMin || o.y>o.yMax ){
				o.a = Math.atan2(-Math.sin(o.a),Math.cos(o.a))
				o.y = Cs.mm( o.yMin, o.y, o.yMax )
				o.pid = (o.pid+1)%2
				flWillFlip = true;
			}
			*/
			/*
			var da = null
			if( o.x > o.xMax )da = Cs.hMod(-3.14-o.a,3.14);
			if( o.x < o.xMin )da = Cs.hMod(0-o.a,3.14);
			if( o.y > o.yMax )da = Cs.hMod(-1.57-o.a,3.14);
			if( o.y < o.yMin )da = Cs.hMod(1.57-o.a,3.14);
			*/
		
			var ta = null
			if( o.x > o.xMax )ta = -3.14;
			if( o.x < o.xMin )ta = 0;
			if( o.y > o.yMax )ta = -1.57;
			if( o.y < o.yMin )ta = 1.57;	
			
			var ata = []
			
			
			
			if(ta!=null){
				var da =  Cs.hMod(ta-o.a,3.14);
				var la = 0.7
				if( Math.abs(da)>0.1 )o.a += Cs.mm(-la,da,la);
				if(o.flSwap){
					o.pid = (o.pid+1)%2
					o.flSwap = false;
				}
			}else{
				o.flSwap = true;
			}
			
			// SIZE
			//o.size = Math.max(100,o.size-Timer.tmod)
			
			// MOVE
			mc._x = o.x
			mc._y = o.y
			mc._rotation = o.a/0.0174
			mc._xscale = speed
			mc._yscale = o.size
			o.x += Math.cos(o.a)*speed
			o.y += Math.sin(o.a)*speed
			
			// ADJUST
			o.a = Cs.hMod(o.a,3.14)
			
			// DRAW
			Cs.drawMc( plans[o.pid].bmp, mc )
			
			// LEAF
			if( Math.random()/Timer.tmod < 0.05 ){
				var leaf = downcast(Cs.game.newPart("mcLianeLeaf"));//Cs.game.dm.attach("mcLianeLeaf", Game.DP_PART)
				leaf.x = o.x;
				leaf.y = o.y;
				leaf.root._rotation = mc._rotation;
				leaf.setScale(20+Math.random()+50);
				leaf.root.smc._yscale *= o.leafSide;
				leaf.center = {
					x:(o.xMin+o.xMax)*0.5,
					y:(o.yMin+o.yMax)*0.5
				}
				o.leafSide*=-1;
			}
			
			
			//
			//if(flWillFlip)o.pid = (o.pid+1)%2;
			

			
		}
		/*
		for( var i=0; i<plans.length; i++ ){
			var bmp = plans[i].bmp;
			var inc = -1
			var ct = new flash.geom.ColorTransform( 1,1,1, 1, inc,inc,inc, 0 )
			bmp.colorTransform( bmp.rectangle, ct );		
		}
		*/
		mc.removeMovieClip();
		if( timer<0 ||Cs.game.flClick )endRoots();
	}
	function endRoots(){
		// FEUILLES
		for( var i=0; i<Cs.game.partList.length; i++ ){
			var p = downcast(Cs.game.partList[i])
			var a = p.getAng(p.center);
			var dist = p.getDist(p.center);
			var sp = Math.min( 200/dist, 10+Math.random()*2)
			p.vx = -Math.cos(a)*sp
			p.vy = -Math.sin(a)*sp
			p.timer = 15+Math.random()*10;
			p.vr = (Math.random()*2-1)*8
			p.fadeType = 0
		}
		
		// PART
		for( var i=0; i<16; i++ ){
			var p = Cs.game.newPart("partLight");
			var card = trg[Std.random(trg.length)];
			Cs.setSidePos(p,card);
			var a = card.getAng(p);
			var sp = 0.5+Math.random()*2.5;
			var side = 10;
			p.vx = Math.cos(a)*sp;
			p.vy = Math.sin(a)*sp;
			p.x += Math.cos(a)*side;
			p.y += Math.sin(a)*side;
			p.timer = 10+Math.random()*10;
			p.setScale(100+Math.random()*150);
			p.fadeType = 0;
		}
		
		//FLASH
		for( var i=0; i<trg.length; i++ ) downcast(trg[i]).fxFlash(1);
		
		while(plans.length>0){
			var mc = plans.pop()
			mc.bmp.dispose();
			mc.removeMovieClip()
		}
	
		kill();
	}
	
	// WIND
	function initWind(){
		Cs.game.mcPlasma.blendMode = BlendMode.ADD
		windList = []
		for( var i=0; i<3; i++ )newWind();
		timer = 80
		//
		var inc = 0
		var m = 1			
		Cs.game.setPlasmaFader([[2, m,m,m,1, -8,0,0,-10 ],[1,2] ])		
		
	}
	function updateWind(){
	
		// GEN
		if(timer>20)newWind();

		// UPDATE
		var mc = Cs.game.dm.attach("mcWindLine",Game.DP_FRONT);
		
		for( var i=0; i<windList.length; i++ ){
			var o = windList[i]
			var sp = o.speed*Timer.tmod;
			var ta = o.card.getAng(o)+3.14
			var da = Cs.hMod(ta-o.a,3.14)
			o.a += Cs.mm( -o.lma, da*o.ca, o.lma )

			mc._x = o.x
			mc._y = o.y
			mc._rotation = o.a/0.0174
			mc._xscale = sp;
			Cs.game.plasmaDraw(mc)
			o.a = Cs.hMod(o.a,3.14)
			
			o.x += Math.cos(o.a)*sp;
			o.y += Math.sin(o.a)*sp;
			
			var dx = Math.abs(o.x-o.card.x)
			var dy = Math.abs(o.y-o.card.y)
			
			if( timer<20 ){
				o.speed += 0.5*Timer.tmod
				o.ca += (1-o.ca)*0.1
				o.lma = 6.57
			}
			
			if( (dx<Card.WW*0.5*o.card.scale/100 && dy<Card.HH*0.5*o.card.scale/100) ){
				o.ca = Math.min(o.ca+0.01*Timer.tmod,1)
				o.lma += 0.05*Timer.tmod;
				if(dx+dy<15)windList.splice(i--,1)
			}
			
		}
		
		//
		Cs.game.mcPlasma.ftimer = 50 
		mc.removeMovieClip();
		if( timer<0 ||Cs.game.flClick )endWind();
		
	}
	function newWind(){
		
		var o = {
			x:0,
			y:0,
			card:downcast(trg[Std.random(trg.length)]),
			a:-1.57,
			ca:0.1+Math.random()*0.1,
			lma:0.4+Math.random()*0.4,
			speed:12+Math.random()*8
		}
		Cs.setStartPos(o,from)
		windList.push(o)
		return o;
	}	
	function endWind(){
		Cs.game.mcPlasma.blendMode = BlendMode.NORMAL
		kill();
	}
	
	// WINGS
	function initWings(){
		
		for( var i=0; i<2; i++){
			var mc = from.dm.attach("mcWing",2)
			var sens = (i*2-1)
			mc._x = sens*(Card.WW*from.scale/100)*0.5
			//mc._yscale = card.owner.side*100;
			mc._xscale = sens*100
		}	
		timer = 8
	}
	function updateWings(){
		if( timer<0 || Cs.game.flClick ){
			kill();
		}
	}
	
	//
	function kill(){
		if( FL_BG_CACHE ){
			copy.bmp.dispose();
			copy.removeMovieClip();
			Cs.game.mcCards._visible = true;
		}
		super.kill();
	}
	
//{
}

















