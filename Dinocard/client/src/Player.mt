class Player {//}

	static var GMX = 8
	static var GMY = 6

	static var MARGIN = 206;
	static var CR = 0.7;

	static var dSize = 1
	static var eSize = 0.7

	var flHero:bool;

	var life:int;
	var side:int;
	var dside:int;
	var packGrow:int;
	var introStep:int

	var rightMargin:float;
	var redLife:float;

	var data:DataPlayer;
	var graveyard:Deck;
	var pack:Deck;

	var objects:Array<Card>;
	var energies:Array<Card>
	var dinoz:Array<Card>

	var mcIcon:MovieClip;

	var avatar:{>Sprite, sub:{>MovieClip, fieldName:TextField, life:{>MovieClip field:TextField}}, shake:float, bx:float, by:float, flash:float }

	var mcl:MovieClipLoader;

	// NOTE :
	// dside = 1 / 2
	// side = -1 / 1



	function new(d){
		data  = d;

		dside = (Cs.game.mainPlayerId==data.$id)?1:0;
		side = dside*2-1;


		objects = new Array();
		energies = new Array();
		dinoz = new Array();

		rightMargin = 0
		introStep = 0

		var n = data.$life
		if(n==null)n = 12;
		setLife(n)

		initInterface();
	}

	function initInterface(){

		//
		var w = Card.WW*CR
		var h = Card.HH*CR
		var my = 50
		var mx = (MARGIN - 3*w)/4
		var y = my +dside*(Cs.mch-2*my)

		// AVATAR
		avatar = downcast( new Sprite(Cs.game.dm.attach( "mcAvatar", Game.DP_GROUND)) );
		avatar.sub = downcast(avatar.root);
		avatar.sub.fieldName.text = data.$name;
		avatar.sub.life.field.text = string(life);
		Cs.glow(avatar.sub.life,3,3,0x1B7EA9);
		avatar.bx = mx + w*0.5;
		avatar.by = y;
		avatar.x = avatar.bx;
		avatar.y = avatar.by;
		avatar.scale = 70;
		avatar.root._visible = false;
		avatar.flash = 100;
		if( data.$avatar == null ){
			Cs.log("Generation d'un avatar",2);
			data.$avatar = [0,0];
			while(data.$avatar.length<6)data.$avatar.push(Std.random(10));
		}
		downcast(avatar.root).img.cl = data.$avatar;
		Cs.loadAvatar(downcast(avatar.root).img);
		var vic = Cs.game.victory[dside]
		for( var i=0; i<vic; i++ ){
			var mc = Std.attachMC(avatar.root,"mcVictory",20+i)//Cs.game.dm.attach( "mcVictory", Game.DP_GROUND)
			mc._x = - Card.WW*0.7*0.5
			mc._y = 16 + i*15 - Card.HH*0.7*0.5
		}


		//Log.trace(avatar.img.trg)


		// PACK
		pack = new Deck(null);
		pack.setFace(false);
		pack.x = mx + w*1.5 +mx;
		pack.y = y;
		pack.updatePos();
		packGrow = 0;
		pack.name = "Pack "+data.$packName

		// GRAVEYARD
		graveyard = new Deck(null);
		graveyard.setFace(true)
		graveyard.setList([])
		graveyard.x = mx + w*2.5 +mx*2;
		graveyard.y = y;
		graveyard.updatePos();
		graveyard.name = "$Cimetière".substring(1);
	}

	//
	function update(){

		switch(introStep){
			case 0:
				if( packGrow-1 < data.$cardMax ){
					packGrow++
					var list = Cs.game.round.$pack1.duplicate();
					if(Cs.game.playerList[1]==this)list = Cs.game.round.$pack2.duplicate();



					while(list.length<data.$cardMax)list.push(0);
					list = list.slice(0,packGrow)
					pack.setList(list)
				}else{
					introStep++
					displayAvatar();
					Cs.setPercentColor(avatar.root,avatar.flash,0xFFFFFF)
				}
				break;
			case 1:
				var prc = avatar.flash
				avatar.flash *= 0.9
				if(prc<2){
					prc = 0
					introStep = null;
				}
				Cs.setPercentColor(avatar.root,avatar.flash,0xFFFFFF)
				break;

			case 2: //ENDING

				var flReady = true
				var a = [pack,graveyard]
				for( var i=0; i<a.length; i++ ){
					var deck = a[i]
					if(deck.list.length>0){
						deck.list.pop();
						deck.updateTop();
						flReady = false;
					}
				}
				if(flReady){
					introStep = null;
				}
				break;

		}

		if(avatar.shake!=null){
			avatar.shake *= 0.85
			var sh = avatar.shake
			if(avatar.shake<0.5){
				avatar.shake = null
				sh = 0
				setMoodBack();
			}
			var mc = downcast(avatar.root).img.trg
			//avatar.x = avatar.bx + (Math.random()*2-1)*sh
			//avatar.y = avatar.by + (Math.random()*2-1)*sh
			mc._x =  (Math.random()*2-1)*sh + 60
			mc._y =  (Math.random()*2-1)*sh
		}

		if(redLife!=null){
			redLife = Math.max(redLife-73*Timer.tmod,0)
			Cs.setPercentColor(avatar.sub.life,50-Math.cos(redLife*0.01)*50,0xFF0000)
			if(redLife==0)redLife = null;
		}

	}
	function faster(){
		if(introStep==1 || introStep== 0 ){
			var list = Cs.game.round.$pack1.duplicate();
			if(Cs.game.playerList[1]==this)list = Cs.game.round.$pack2.duplicate();
			while(list.length<data.$cardMax)list.push(0);
			pack.setList(list)
			displayAvatar();
			Cs.setPercentColor(avatar.root,0,0xFFFFFF)

			introStep = null;
		}
	}

	// ADD
	function addDinoz(card,n){
		/*
		var str="addDinoz : ";
		for( var i=0; i<dinoz.length; i++){
			str+=dinoz[i].id+" ; "
		}
		*/

		var pos = getDinozPos(n);
		dinoz[n] = card;
		orderDinoz(1);

		/*
		str+=" ---> ";
		for( var i=0; i<dinoz.length; i++){
			str+=dinoz[i].id+" ; "
		}
		Log.trace(str);
		*/

	}
	function removeDinoz(card){
		dinoz.remove(card)
	}

	function orderDinoz(sc:float){
		var ods = dSize
		updateDinozSize();
		if(ods!=dSize)getOpponent().orderDinoz(sc);

		for( var i=0; i<dinoz.length; i++ ){
			var card = dinoz[i]
			if(card!=null){
				var pos = getDinozPos(i);
				card.goto( pos.x, pos.y, dSize*100 )
				card.trg.sc = sc
			}
		}


	}
	static function updateDinozSize(){
		dSize = 99999
		for( var i=0; i<Cs.game.playerList.length; i++ ){
			var pl = Cs.game.playerList[i]
			var space = Cs.mcw-(MARGIN+GMX*(pl.dinoz.length+2)+pl.rightMargin)
			dSize = Math.min( dSize, Math.min( (space/pl.dinoz.length)/Card.WW, 1) )
		}

	}

	// UP
	function updateAllPos(){
		//Log.clear()
		//Log.trace("updateAllPos!")
		orderObjects();
		orderEnergies();
		for( var i=0; i<Cs.game.playerList.length; i++ ){
			var pl = Cs.game.playerList[i]
			//Log.trace("pl "+i+" : "+pl.rightMargin)
			pl.orderDinoz(3);
		}
	}

	// OBJECTS
	function addObject(card){
		for( var i=0; i<Cs.game.playerList.length; i++  ){
			var pl = Cs.game.playerList[i];
			if( pl != this ){
				for( var n=0; n<pl.objects.length; n++){
					if( pl.objects[n] == card ){
						pl.objects.splice(n,1);
						break;
					}
				}
			}
		}
		objects.push(card)
		updateAllPos();
	}
	function orderObjects(){

		var sq = Math.max( 0.7, 1-(objects.length-1)*0.1 )

		var margin = 5
		var my = Math.max( margin, (Cs.mch*0.5)-(sq*Card.HH*objects.length) )*0.5;
		var ey = ( (Cs.mch*0.5-2*my)-(sq*Card.HH*objects.length) ) / (objects.length-1)
		if(objects.length<2)ey=0;

		for( var i=0; i<objects.length; i++ ){
			var card = objects[i]
			var tx = Cs.mcw - ( sq*Card.WW*0.5 + margin )
			var ty = Cs.mch*0.25+(side*Cs.mch*0.25)  + my + i*(ey+sq*Card.HH) + (sq*Card.HH*0.5)
			card.goto(tx,ty,sq*100)
			card.front();
		}

		if(objects.length==0){
			rightMargin = 0
		}else{
			rightMargin = margin*2 + sq*Card.WW
		}

	}

	// ENERGY
	function orderEnergies(){
		var m =  (Cs.mcw-(MARGIN+GMX*2+rightMargin+(energies.length*Card.WW*0.7)) ) / (energies.length-1)
		if(energies.length<2)m=0;
		m = Math.min(m,5)

		for(var i=0; i<energies.length; i++ ){
			var c = energies[i]
			var pos = getEnergyPos(i,int(m));
			c.goto(pos.x,pos.y,70);
		}
	}

	// LIFE
	function setLife(n){
		if(life>n){
			avatar.shake = 8
			redLife = 1800
			setMood(1)
		}
		//
		if(n<=0){
			var fl = new flash.filters.ColorMatrixFilter();
			fl.matrix = [
				1, 0, 0, 0, 0,
				0, 0, 0, 0, 0,
				0, 0, 0, 0, 0,
				0, 0, 0, 1, 0,
			]
			downcast(avatar.root).img.filters = [fl]
		}else{
			downcast(avatar.root).img.filters = []
		}

		life = n;
		avatar.sub.life.field.text = string(life);
	}

	// MOOD
	function displayAvatar(){
		avatar.root._visible = true
		setMood(0);
	}
	function setMood(n){

		/*
		Log.clear();
		//Log.setColor(0xFFFFFF)
		Log.trace(System.security.sandboxType )
		Log.trace(downcast(avatar.root).img.trg._visible)
		Log.trace(downcast(avatar.root).img.trg.apply)
		*/

		var cl = data.$avatar.duplicate();
		cl[1] = n
		Cs.applyAvatar( downcast(avatar.root).img.trg, cl );
	}
	function setMoodBack(){
		var cl = data.$avatar.duplicate();
		cl[1] = (life>3)?0:2
		Cs.applyAvatar( downcast(avatar.root).img.trg, cl );
	}
	/*
	function setEndMood(){

		var op = getOpponent();
		if(life>0 && op.life<=0){
			setMood(4);
			Cs.game.victory[int((side+1)*0.5)]++;
			Cs.game.setFlashMessage("VICTOIRE!",side,null)
		}else if(life<=0 && op.life>0){
			setMood(1);
			Cs.game.setFlashMessage("DEFAITE!",side,null)
		}else{
			setMood(0);
			Cs.game.setFlashMessage("MATCH NUL!",side,null)
		}

	}
	*/
	// ICON
	function setIcon(n:int){
		//Log.trace("				"+side+" : setIcon("+n+")")
		if(n==0){
			mcIcon.removeMovieClip();
			mcIcon = null;
			return;
		}
		if(mcIcon==null){
			//mcIcon = Cs.game.dm.attach( "mcTurnIcon", Game.DP_GROUND)
			mcIcon = Std.attachMC(avatar.root,"mcTurnIcon",10)
			mcIcon._x = Card.WW*0.5*0.7 - 8
			mcIcon._y = Card.HH*0.5*0.7 - 8

		}
		mcIcon.gotoAndStop(string(n))
	}

	// GET
	function getEnergyPos(n,m){
		if(m==null)m=GMX
		var sens = side
		return {
			x:MARGIN+GMX + (n+0.5)*(Card.WW*0.7) + n*m
			y:Cs.mch*0.5 + ( Cs.mch*0.5 - ( GMY+0.5*Card.HH*0.7 ) )*sens
		}

	}
	function getDinozPos(n){
		var sens = side

		return {
			x:MARGIN+GMX + (n+0.5)*Card.WW*dSize + n*GMX
			//y:Cs.mch*0.5 + (Cs.mch*0.5-(2*GMY+Card.HH*eSize))*0.5*sens
			y:Cs.mch*0.5 + (Cs.mch*0.5-(2*GMY+Card.HH*eSize))*0.5*sens
		}
	}
	function getOpponent(){
		for( var i=0; i<Cs.game.playerList.length; i++ ){
			var pl = Cs.game.playerList[i]
			if(pl!=this)return pl;
		}
		Log.trace("Opponent not found !")
		return null;
	}
	function getName(){
		return Cs.getBold(data.$name)
	}

	// KILL
	function kill(){
		mcIcon.removeMovieClip();
		pack.kill();
		graveyard.kill();
		avatar.kill();

	}

//{
}







