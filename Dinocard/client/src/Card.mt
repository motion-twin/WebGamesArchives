class Card extends Sprite{//}

	static var WW = 84;
	static var HH = 117;
	static var FRAME_MAX = 14;
	
	static var DP_TOKEN = 3;
	static var DP_ENERGY = 2;
	
	static var INFOS:Array<DataCard>
	static var INST:Array<DataCardInstance>
	static var CAPACITIES:Array<DataCapacity>
	
	var flFace:bool;
	var flShadow:bool;
	var flUpdateTokens:bool;
	var flCardInfo:bool;
	
	var id:int;
	//var side:int;
	var flipSens:int;
	var flipFrame:float;
	var endTimer:float;
	
	
	// DINOZ
	var level:int;
	var strength:int;
	var endurance:int;	
	var capacities:Array<int>
	
	//
	var inst:DataCardInstance
	var data:DataCard;
	var dataDinoz:DataDinoz
	
	var owner:Player;
	var tokens:Array<Array<Token>>
	var remDamList:Array<MovieClip>
	var addDamList:Array<MovieClip>
	var enchants:Array<Card>
	var enchantTarget:Card;
	
	var area:MovieClip
	
	var pdm:DepthManager;
	var dm:DepthManager;
	var cdm:DepthManager;
	var face:{>MovieClip, icon:MovieClip, slotType:MovieClip, slotAtt:MovieClip, textArea:MovieClip, slotDef:MovieClip, mcLevel:MovieClip, bg:MovieClip, cadre:{>MovieClip,pic:MovieClip}, fieldEcl:TextField,fieldAtt:TextField, fieldDef:TextField, fieldHigh:TextField, fieldLevel:TextField, field:TextField }
	var back:{>MovieClip, logo:MovieClip }
	var mcFlame:MovieClip;
	var butInfo:Array<{>MovieClip,field:TextField,but:Button}>
	
	var trg:{ c:float, sc:float, bx:int, by:int, dx:int, dy:int, bsc:float, dsc:float, flip:bool }
	
	var cardInfo:Card;
	var cardInfoEnchants:Array<Card>;
	var aura:{>MovieClip,fl:flash.filters.GlowFilter};
	var flh:{val:float,sens:float}
	
	function new(mc){
		if(mc==null){
			pdm = Cs.game.dm
			if( ac.Effect.FL_BG_CACHE )pdm = Cs.game.cdm
			mc = pdm.attach("mcCard",Game.DP_CARD);
		}
		mc.cacheAsBitmap = true;
		super(mc);
		dm = new DepthManager(mc)
		
		flShadow = false;
		Cs.game.cardList.push(this)
		tokens = new Array();
		enchants = new Array();
		//
		root.stop();
		flipFrame = 0
		flFace = false;
		setBack()

		area = downcast(root).empty//downcast(root).area
		downcast(area).hitArea = downcast(root).area
		downcast(root).area._visible = false;
		
		//Log.clear();
		//Log.setColor(0xFFFFFF);
		//Log.trace("--- CREA DE LA CARTE ---");
		
		/*
		area.onRollOver = callback(this,tick,50)
		area.onRollOut = callback(this,tick,100)
		area.onDragOut = area.onRollOut
		*/
		
	}
	function tick(n){
		root._alpha = n
	}
	
	//
	function update(){
		if(trg!=null)updateTrg();
		if(flUpdateTokens)updateTokens();
		if(aura!=null)updateAura();
		if(flh!=null)updateFlash();
		if(flipSens!=null)updateFlip();
		if(Cs.game.step==3)endFade();
		super.update();
	}
	
	// MOVE
	function goto(tx,ty,tsc){
		var tol = 1
		if( Math.abs(x-tx)<tol && Math.abs(y-ty)<tol  )return;
		
		trg = {
			c:0,
			bx:int(x),
			by:int(y),
			dx:int(tx-x),
			dy:int(ty-y),
			bsc:scale,
			dsc:tsc-scale,
			flip:false,
			sc:1
		}
		
		updateFace()
		if(tsc==null){
			trg.dsc=null;
		}
		front();
	}

	function moveTo(tx,ty){
		x = tx;
		y = ty
		
		for( var i=0; i<enchants.length; i++ ){
			var pos = getEnchantPos(i)
			var card = enchants[i]
			card.x = pos.x;
			card.y = pos.y;
			card.setScale(scale)
		}
	}
	function updateTrg(){
		trg.c = Math.min(trg.c+Cs.game.speed*trg.sc,1)
		
		if(trg.dsc!=null){
			setScale( trg.bsc + trg.dsc*trg.c );
		}
		moveTo( trg.bx + trg.dx*trg.c, trg.by + trg.dy*trg.c )
		
		if(trg.c==1){
			if(trg.flip)flip();
			var flUpdateFace = trg.dsc!=null
			trg = null;
			if(flUpdateFace)updateFace();
			
		}
		
	}
	function front(){
		pdm.over(root)	
	}
	
	// SET
	function setId(n:int){
		id = n;
		inst = getInst(id);
		
		
		//data = getCardData(inst.$cid);
		setData(getCardData(inst.$cid));
		
		root._rotation = 0;
		if(inst==null)root._rotation = 10;
		
		//Log.trace("--setID("+inst.$cid+") --> inst id ("+id+")")

	}
	function setData(d){
		data = d
		switch(data.$type){
			case 0:
				dataDinoz = downcast(data);
				level = dataDinoz.$energy.length;
				strength = dataDinoz.$strength;
				endurance = dataDinoz.$endurance;
				break;
			default:
				dataDinoz = null
				strength = null
				endurance = null
				capacities = null
				break;
		}
	
		capacities = data.$capacities;
		
		if(flFace)setFace();
		if(!flFace)setBack();
	}
	
	function setEnergy(n){
		data = new DataCard();
		data.$type = 3;
		data.$element = n;
		updateFace();
	}
	function setArt(id:int){
		//var mc = Std.attachMC(face.cadre.pic,"mcArt",0)
		//mc.gotoAndStop(string(id+1))
		
		var mc = Std.createEmptyMC(face.cadre.pic,0)
		mc._xscale = 50
		mc._yscale = 50
		//var imgUrl  = "http://www.dinocard.net/gfx/card/artwork/"
		//var imgUrl  = downcast(Std.getRoot()).$imgUrl
		var url = Cs.game.imgUrl+id+".jpg"
		//Log.trace(url)
		if(id==null)return;
		
		
		//downcast(mc).loadMovie(url)
		
		var mcl = new MovieClipLoader();
		mcl.loadClip(url,mc);

		mcl.onLoadComplete = fun(mc){Cs.game.displayFlashMessage()}
		
		//var mcl = new MovieClipLoader();
		//Log.trace(id+1)
	}
	function copyCard(card){
		x = card.x;
		y = card.y;
		setScale(root._xscale);
	}
	
	// FACE
	
	function updateFace(){
		var height = 40
		switch(data.$type){
			case 0:
				var astr = [string(strength),string(endurance)]
				if(trg!=null)astr = ["",""];
				setText( face.fieldEcl, [9,12,16], string(dataDinoz.$eclosion) );
				setText( face.fieldAtt, [9,12,16], astr[0] );
				setText( face.fieldDef, [9,12,16], astr[1] );
			
				var dec = -2.5
			
				face.fieldEcl._y = dec+22 - face.fieldEcl.textHeight*0.5
				face.fieldAtt._y = dec+34 - face.fieldAtt.textHeight*0.5
				face.fieldDef._y = dec+46 - face.fieldDef.textHeight*0.5
			
			
				if( scale == 70 || scale == 100 ||true ){
					Cs.glow(face.fieldEcl,2,10,0xDD6600 )
					Cs.glow(face.fieldAtt,2,10,0xFF0000 )
					Cs.glow(face.fieldDef,2,10,0x0000FF )
				}else{
					face.fieldEcl.filters = []
					face.fieldAtt.filters = []
					face.fieldDef.filters = []
				}
				face.slotAtt._visible = true;
				face.slotDef._visible = true;
				face.icon._visible = false;
				
				Cs.game.makeHint(face.slotType,Cs.getBold("Eclosion:")+" Ce dinoz pourra éclore s'il possède "+dataDinoz.$eclosion+" jeton(s) éclosion(s) ou plus.",-1,-1);
				Cs.game.makeHint(face.slotAtt,Cs.getBold("Attaque:")+" Somme de dégats infligés par "+data.$name+" à chaque attaque.",-1,-1);
				Cs.game.makeHint(face.slotDef,Cs.getBold("Défense:")+" "+data.$name+" ira au cimetière s'il subit "+endurance+" dégat(s).",-1,-1);
				
				break;
			default:
				face.fieldEcl.text=""
				face.fieldAtt.text=""
				face.fieldDef.text=""
				face.slotAtt._visible = false;
				face.slotDef._visible = false;
				face.icon._visible = true;
				break;
		}
		//face.field.size
		
		// FOND
		face.bg.gotoAndStop(string(data.$element+1))
		
		
		// NAME
		{
			var str = ""
			if(trg==null)str = data.$name	
			face.fieldHigh._y = -56
			setText(face.fieldHigh,[5,10,14],Cs.getBold( str ))
			Cs.glow(face.fieldHigh,2,10,0 )
			if(Cs.game.flPenguin)face.fieldHigh.textColor = 0x000000;
			
		}
		
		// LEVEL
		{
			var str = ""
			if(trg==null)str = string(data.$energy.length)			
			face.fieldLevel._y = -58
			setText( face.fieldLevel, [9,12,16], str );
			Cs.glow(face.fieldLevel,2,10,0x449900 )
			switch(data.$type){
				case 0:
					Cs.game.makeHint(downcast(face.mcLevel),Cs.getBold("Niveau:")+" Pour poser ce dinoz, vous devez posséder une énergie "+getEnergyName(data.$element)+". Pour pouvoir éclore, Ce dinoz doit avoir "+dataDinoz.$eclosion+" compteurs éclosion.",0,0);
					break;
				default: 
					Cs.game.makeHint(downcast(face.mcLevel),Cs.getBold("Niveau:")+" Pour lancer ce sort, vous devez posséder "+data.$energy.length+" énergie(s) dont au moins une énergie "+getEnergyName(data.$element)+".",0,0);
					break;
			}
		}
		

		
		
		// DESC
		face.field._height = height*(100/face.field._yscale)
		var str = ""
		if(trg==null)str = getDesc();
		setText(face.field,[5,10,14],str)
		face.field._y = 14
		
		if(flCardInfo && face.field.textHeight>32)Cs.game.makeHint(face.textArea,str,0,-1);
		//if(scale < 200 )Cs.game.makeHint(root,str,0,-1);
		
		// ICON
		face.icon.gotoAndStop(string(data.$type+1))
		switch(data.$type){
			case 0:
				Cs.game.makeHint(face.icon,Cs.getBold("Dinoz:")+" Les dinoz attaquent votre adversaire ou les Dinoz adverses. Attention : Vous ne pouvez poser que 3 dinoz à la fois.",-1,-1);
				break;
			case 1:
				Cs.game.makeHint(face.icon,Cs.getBold("Objet:")+" Les cartes objets sont posées sur la partie droite du terrain. Les objets sont actifs en permanence.",-1,-1);
				break;
			case 2:
				Cs.game.makeHint(face.icon,Cs.getBold("Enchantement:")+" Les enchantements ciblent un dinoz ou un oeuf pour modifier ses compétences.",-1,-1);
				break;
			case 3:
				Cs.game.makeHint(face.icon,Cs.getBold("Incantation:")+" Les incantations sont lancées directement si vous avez possédez les énergies suffisantes.",-1,-1);
				break;					
		}
		//face.icon._xscale = 10000/scale;
		//face.icon._yscale = 10000/scale;
		if(Cs.game.flPenguin){
			var a = [face.fieldLevel,face.fieldAtt,face.fieldDef]
			for( var i=0; i<a.length; i++ ){
				var tf = a[i]
				tf.embedFonts = false
				tf.textColor = 0x000000;
				tf.background = true;
			}
			//face.fieldLevel.embedFonts = false
		}

				
	}
	function setFace(){
		//Log.trace("setFace!")
		face = downcast(root).face
		setArt(data.$id)
		updateFace();

		var cdm = new DepthManager(face);
		// ENERGY
		
		for( var i=0; i<data.$energy.length; i++ ){
			var str = data.$energy.charAt(i);
			var fr = 7
			if(str=="$F".substring(1))fr=1;
			if(str=="$B".substring(1))fr=2;
			if(str=="$E".substring(1))fr=3;
			if(str=="$J".substring(1))fr=4;
			if(str=="$C".substring(1))fr=5;
			if(str=="$A".substring(1))fr=6;
			var mc = cdm.attach("mcManaBall",0);
			mc.gotoAndStop(string(fr));
			mc._x = (WW*0.5-15) - i*7;
			mc._y = 7;
			mc._xscale = 50;
			mc._yscale = 50;
			
		}		
		
		
	}
	function setBack(){
		//Log.trace("setBack!")
		var el = data.$element;
		back = downcast(root).back
		var egg = 0;
		if(data.$type==0){
			egg = 1;
		}
		back.logo.gotoAndStop(string(el+egg*5+1))
	}
	
	function setText(field,a:Array<float>,str){
	
		var size = a[1];
		var dec = -4
		if(scale==200){
			size = a[0];
			dec = 0
		}
		if(scale==70){
			size = a[2];
			dec = -4.5
		}
		if(scale==50){
			size = 5;
			dec = -5
		}
		
		field.htmlText = Cs.getSizeFont( str, size ) 
		
		var tf = new TextFormat();
		tf.leading = -1
		field.setTextFormat(0,100000,tf);	
		field._y += dec
		
	}
	
	function flip(){
		flFace = !flFace
		flipSens = flFace?1:-1
	}
	function flipIn(){
		if(!flFace)flip();
	}
	function flipOut(){
		if(flFace)flip();
	}
	function instantFlipIn(){
		flFace = true
		root.gotoAndStop(string(FRAME_MAX+1))
		setFace()
	}
	function updateFlip(){
		flipFrame+=flipSens*(FRAME_MAX*Cs.game.speed)*Timer.tmod;
		if( flipFrame<0 || flipFrame>=FRAME_MAX ){
			flipFrame = Cs.mm(0,flipFrame,FRAME_MAX)
			flipSens = null
		}
		root.gotoAndStop(string(int(flipFrame)+1))
				
	}
	
	// 
	function birth(){
		flipIn();
		setToken(Token.ECLOSION,0)

		// FX
		fxBirth(32);
	
	}
	function unbirth(){
		flipOut();
	}
	
	
	// TOKEN
	function addToken(id):Token{
		//Log.trace("addToken!")
		var mc = downcast(dm.attach("mcToken",DP_TOKEN));
		
		var ray = Math.random()*10;
		var a = Math.random()*6.28;
		mc._x = Math.cos(a)*ray;
		mc._y = Math.sin(a)*ray;
		flUpdateTokens = true;
		/*
		var aa = [" dommage"," éclosion"]
		Cs.game.makeHint(mc,"oOoh!!! Un marqueur"+aa[id]+" !!",-1,-1)
		*/
		return mc;
	}
	function updateTokens(){
		//Log.print("updateTokens!")
		
		flUpdateTokens = false;
		
		// BUILD LIST
		var list = new Array();
		for( var i=0; i<tokens.length; i++ ){
			var a = tokens[i]
			for( var n=0; n<a.length; n++ )list.push(a[n])
		}
		
		
		// MOVE ALL
		for( var i=0; i<list.length; i++ ){
			var t0 = list[i]
			for( var n=i+1; n<list.length; n++ ){
				var t1 = list[n]
				var dx = t0._x - t1._x;
				var dy = t0._y - t1._y;
				var dist = Math.sqrt(dx*dx+dy*dy)
				var dif = dist-Token.RAY*2
				if(dif<-0.5){
					//Log.print(dif)
					flUpdateTokens = true;
					var a = Math.atan2(dy,dx);
					var ca = Math.cos(a)
					var sa = Math.sin(a)
					var d = dif*0.5
					t0._x -= ca*d
					t0._y -= sa*d
					t1._x += ca*d
					t1._y += sa*d
				}
			}
		}
		
		
	}
	function setToken(id:int,n:int){
		//Log.trace("setToken("+id+","+n+")")
		if(tokens[id]==null) tokens[id] = new Array();
		var list = tokens[id]
		while( list.length>n ){
			var mc = list.pop()
			mc.gotoAndPlay("remove")
			list.remove(mc)
			
		}
		while( list.length<n ){
			var mc = addToken(id)
			mc.gfx.gotoAndStop(string(id+1))
			list.push(mc)
		}
		
	}
	function removeAllToken(){
		for( var i=0; i<tokens.length; i++ ){
			var list = tokens[i]
			while(list.length>0)list.pop().removeMovieClip();
		}
	}
	
	// INFOS
	function initInfo(){
		area.onPress = callback(this,showInfo)
		area.useHandCursor = false;
	}
	function removeInfo(){
		
		area.onPress = null
		area.useHandCursor = false;
	}
	function showInfo(){
		if( !Cs.game.flPause )return;
		if( !owner.flHero && !flFace )return;
		
		//
		Cs.game.setFader(50)
		Cs.game.mcFader.onPress = callback(this,hideInfo)
		
		
		// CARD INFO
		cardInfo = new Card(null);
		cardInfo.setScale(200)
		cardInfo.setId(id)
		cardInfo.flCardInfo = true;
		
		var px = x
		var py = y
		var par = root._parent
		while(par!=null){
			px += par._x;
			py += par._y;
			par = par._parent;
		}
		
		cardInfo.x = Cs.mm(WW,px,Cs.mcw-WW)
		cardInfo.y = Cs.mm(HH,py,Cs.mch-HH)
		
		
		cardInfo.toggleShadow();
		cardInfo.updatePos();
		cardInfo.instantFlipIn();
		
		Cs.game.dm.swap(cardInfo.root, Game.DP_FRONT)
		
		// CLONE
		cardInfo.strength = strength
		cardInfo.endurance = endurance
		cardInfo.capacities = capacities
		cardInfo.updateFace();

		Cs.game.cardList.remove(cardInfo)
		//Cs.game.setPlasmaFader(null)
		//Cs.game.fadeBg(50)
		Cs.game.cardInfoTrg = this
		
		
		// ENCHANTS
		var m = 10+Card.WW*0.5
		var sx = m
		var space = cardInfo.x-(Card.WW*0.5+2*m)

		if( cardInfo.x<Cs.mcw*0.5 ){
			sx = cardInfo.x+Card.WW*0.5+m
			space = Cs.mcw-(sx+m)
		}
		var margin = (space-(enchants.length*Card.WW*2)) / (enchants.length-1)
		if(enchants.length==1)margin = 0
		//var mx = sx + space*0.5
		cardInfoEnchants = []
		for( var i=0; i<enchants.length; i++ ){
			var bc = enchants[i]
			//var coef = (i/enchant.length)*2-1
			var c = new Card(null);
			c.setScale(200)
			c.setId(bc.id)
			c.x = sx + Card.WW + (margin+Card.WW*2)*i
			c.y = cardInfo.y
			
			c.toggleShadow();
			cardInfo.updatePos();
			c.instantFlipIn();
			c.face.bg.onRollOver = callback(this,showEnchant,c)
			c.face.bg.onRollOut = callback(this,hideEnchant,c)
			c.face.bg.onDragOut = c.face.bg.onRollOut
			Cs.game.dm.swap(c.root, Game.DP_FRONT)
			Cs.game.cardList.remove(cardInfo)
			cardInfoEnchants.push(c)
			
			//
			var dec = i*3
			var line = Std.attachMC(cardInfo.root,"mcEnchantLink",i)
			line._x = 0
			line._y = - Card.HH*0.5
			line._xscale =  (c.x - cardInfo.x )*0.5
			line._yscale =  Math.max(20,100-i*20)
			//line.onRollOut = callback(this,showEnchant,c)
			
		}
		
		// GLOW
		var a = cardInfo.root.filters
		var fl = new flash.filters.GlowFilter()
		fl.blurX = 4
		fl.blurY = 4
		fl.strength = 3
		fl.color = 0xFFFFFF
		a.push(fl)
		cardInfo.root.filters = a;
		
		// BUT
		//cardInfo.initSiteInfo();
		butInfo = []
		var sens = -1
		if(cardInfo.y<Cs.mch*0.5)sens = 1;
		for( var i=0; i<2; i++ ){
			if(i!=1 || (data.$wish && data.$range!=3) ){
				var mc = downcast(Cs.game.dm.attach("mcCardButton",Game.DP_FRONT));
				mc._x = cardInfo.x;
				mc._y = cardInfo.y + (Card.HH + 3 + (i+0.5)*24)*sens
				var proba = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,2]
				var text2 = ["ajouter à vos recherches","je veux cette carte!","j'en rêve la nuit..."][proba[Std.random(proba.length)]];
				mc.field.text = ["voir la carte sur le site",text2][i]
				mc.but.onRelease = callback(this,goSite)
				if(i==1)mc.but.onRelease = callback(this,addToWishList,mc)
				mc.filters = [fl]
				butInfo.push(mc)
			}
		}
		


		
		
	}
	function hideInfo(){
		if( cardInfo == null )return;
		//Cs.game.fadeBg(0)
		Cs.game.removeFader();
		
		cardInfo.kill();
		cardInfo = null;
		Cs.game.cardInfoTrg = null
		
		while(cardInfoEnchants.length>0)cardInfoEnchants.pop().kill();
		while(butInfo.length>0)butInfo.pop().removeMovieClip();
		
	}	
	function getInfo(){
		Log.clear();
		Log.trace("------------- CARD INFO ---------------")
		Log.trace("id:"+data.$id)
		Log.trace("Description:\n"+data.$desc)
		Log.trace("---------------------------------------")
	}
	
	function getName(){
		return Cs.getBold(data.$name)
	}
	function getDesc(){
		//Log.clear()
		//Log.trace("getDesc!"+data.$capacities)
		var desc = ""
		
		for( var n=1; n<=2; n++ ){
			for( var i=0; i<capacities.length; i++ ){
				var info = getCapacity(capacities[i]);
				//Log.trace(">"+info.$name)
				if(n==info.$display){
					switch(n){
						case 1:
							if(desc!="") desc+=", "
							var nameUrl = "<a href=\"asfunction:catchLink,"+capacities[i]+"\">"+info.$name+"</a>"
							desc += Cs.getBold(Cs.getColFont(nameUrl,"#880000"));
							downcast(face).catchLink = callback(this,catchLink)
							break;
						case 2:
			
							if(desc!="") desc+="\n"
							desc += info.$desc
	

							break;				
					}
				}

			}
		}
		if(desc!="")desc+="\n";
		
		
		if( data.$desc!=null && data.$desc!="" ){	
			desc += data.$desc+"\n"
		}
		if(data.$flavor!=null && data.$flavor!=""){	
			desc += Cs.getItalic(Cs.getColFont("'"+data.$flavor+"'","#333333"))
		}
		
		return desc;
	}
	
	function showEnchant(enchant){
		//goto(x,y-10,200)
		//trg.sc = 2
		/*
		for( var i=0; i<cardInfoEnchants.length; i++){
			var c = cardInfoEnchants[i]
			c.front();
		}
		*/
		//if(cardInfoEnchants.length>1)enchant.y = y-10;
		enchant.front();
	}
	function hideEnchant(enchant){
		//enchant.y = y
	}	
	
	function goSite(){
		var lv = new LoadVars();
 		lv.send(Cs.game.viewUrl+string(data.$id),"_blank",null)
	}
	function addToWishList(mc){
		var lv = new LoadVars();
 		lv.load(Cs.game.addUrl+string(data.$id))
		butInfo.remove(mc);
		mc.removeMovieClip();
		data.$wish = false;
	}	
	
	// ENCHANT
	function getEnchantPos(n){
		n+=1
		return {x:x+n*2,y:y+n*6}
	}
	function disenchant(){
		if( enchantTarget != null ){
			enchantTarget.enchants.remove(this);
			enchantTarget = null
		}
	}
	
	// SHADOW
	function toggleShadow(){
		flShadow = !flShadow
		if(flShadow){
			var fl = new flash.filters.GlowFilter();
			fl.blurX = 10
			fl.blurY = 10
			fl.color = 0x3C1D11
			fl.strength = 0.5
			root.filters = [fl]
		}else{
			root.filters = []
		}
	}
	
	// FX
	function fxAura(color:int){
		fxFlash(1);
	
		// AURA
		aura = downcast(Cs.game.dm.attach("mcCard",Game.DP_PART))
		var fl = new flash.filters.GlowFilter();
		fl.blurX = 0
		fl.blurY = 0
		fl.color = color
		fl.strength = 3
		fl.alpha = 1
		fl.knockout = true;
		aura.fl = fl
		aura._x = x;
		aura._y = y;
		aura._xscale = scale
		aura._yscale = scale
		
		// PARTS
		for( var i=0; i<14; i++ ){
			var p = new Spark(null);//Cs.game.newPart("partLight");
			sidePart(p)
			var a = Math.atan2(p.y-y,p.x-x)
			var sp = 1.5 + Math.random()*3.5
			p.vx = Math.cos(a)*sp;
			p.vy = Math.sin(a)*sp;
			p.timer = 50+Math.random()*50
			p.updatePos();
			
			p.glow = 5
			p.length = 3
			p.size = 3
			p.color = [0xFFFFFF,color]
			p.gz = 0.3+Math.random()*0.3
			p.z = 0
			p.vz = -( 2+Math.random()*2 -sp*0.1 )
			p.initOp()
			
		}		
		
	}
	function updateAura(){
		aura.fl.blurX += 6*Timer.tmod;
		aura.fl.blurX *= Math.pow(0.9,Timer.tmod);
		aura.fl.blurY = aura.fl.blurX
		aura.fl.strength -= 0.15

		aura.stop();
		aura.filters = [Std.cast(aura.fl)]
		if(aura.fl.strength<0.1){
			aura.removeMovieClip();
			aura = null;
		}
	}
	function fxFlash(c){
		//return;
		flh = {val:100,sens:-c}
	}
	function updateFlash(){
		var prc = flh.val
		flh.val *= Math.pow( (1+flh.sens*0.1), Timer.tmod)
		flh.val = Cs.mm(0,flh.val+flh.sens*Timer.tmod,100)
		if(flh.val == 0){
			flh = null
			prc = 0
		}
		if(flh.val == 100){
			flh.sens = -flh.sens
		}
		Cs.setPercentColor(root,prc,0xFFFFFF);
	}
	function fxBirth(max){
		for( var i=0; i<max; i++ ){
			var p = Cs.game.newPart("partLight");
			sidePart(p)
			var a = Math.atan2(p.y-y,p.x-x)
			var sp = 0.5 + Math.random()*1.5
			p.vx = Math.cos(a)*sp;
			p.vy = Math.sin(a)*sp;
			p.timer = 10+Math.random()*10
			p.setScale(100+Math.random()*100)
			p.updatePos();
		}	
	}
	function sidePart(p){
		var c0 = Std.random(2)*2-1
		var c1 = Math.random()*2-1
		if(Std.random(2)==0){
			var c = c0;
			c0 = c1;
			c1 = c;
		}
		p.x = x+c0*Card.WW*0.5;
		p.y = y+c1*Card.HH*0.5
	}
	function endFade(){
		if(endTimer==null)return;
		if(endTimer>0){
			endTimer -= Timer.tmod;
		}else{
			scale = Math.max( 0, scale-10*Timer.tmod);
			setScale(scale);
			if(scale==0)kill();
		}
	}
	
	function setEnergie(){
		if(mcFlame!=null)return;
		mcFlame = dm.attach("mcFlame",5)
		mcFlame._rotation = 90
		mcFlame.blendMode = BlendMode.ADD
		Cs.glow(mcFlame,10,0.5,0xFFFFFF)
		var sc = 150
		mcFlame._xscale = sc
		mcFlame._yscale = sc
	}
	
	// GET
	static function getInst(id){
		for( var i=0; i<INST.length; i++ ){
			var inst = INST[i];
			if(inst.$id == id)return inst;
		}
		//Log.trace("Instance["+id+"] not found !")
		return null;
	}
	static function getCardData(cid){
		for( var i=0; i<INFOS.length; i++ ){
			var dc = INFOS[i]
			if(dc.$id ==  cid)return dc;
		}
		Log.trace("CardData["+cid+"] not found ! LastAction("+Action.DEBUG_LAST+")")
		return null;		
	}	
	static function getCard(id){
		for( var i=0; i<Cs.game.cardList.length; i++ ){
			var card = Cs.game.cardList[i]
			if( card.id == id ){
				return card;
			}
		}
		//Log.trace("Card["+id+"] not found ! LastAction("+Action.DEBUG_LAST+")")
		
		return null;
	}
	static function getCapacity(id){
		for( var i=0; i<CAPACITIES.length; i++ ){
			var inst = CAPACITIES[i];
			if(inst.$id == id)return inst;
		}
		Log.trace("Capacity["+id+"] not found !")
		return null;
	}
	
	// NAME
	static function getEnergyName(n){
		var en = ["de feu","de bois","d'eau","de foudre","de ciel"]
		return en[n];
	}
	
	// CATCHLINK
	function catchLink(str){
		//Cs.game.mcLog.field.multiline = true;
		var info = getCapacity(int(str));
		Cs.log(Cs.getBold(info.$name)+":"+info.$desc,2)
		//Cs.game.mcLog.field.multiline = false;
	}
		
	//
	function setEclosionHint(n:int){
		var max = "?"
		if(owner.flHero)max = string(dataDinoz.$eclosion);
		Cs.game.removeHint(area);
		Cs.game.makeHint(area,"oeuf de Dinoz\n(éclosion "+n+"/"+max+")",0,-1);
	}
	
	//
	function kill(){
		super.kill();
		if(cardInfo!=null)hideInfo();
		aura.removeMovieClip();
		Cs.game.cardList.remove(this)
	}
	
//{
}



















