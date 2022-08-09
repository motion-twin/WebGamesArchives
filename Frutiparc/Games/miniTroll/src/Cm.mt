class Cm{//}

	static var VERSION = 1.1
	
	static var card:Card;
	static var pref:Pref;
	
	static var so:SharedObject
	
	
	// GENERAL
	
	static function loadFruticard(){
		var fc = null;
		if( Client.STANDALONE ){
			so = SharedObject.getLocal("miniPixiz/card");
			fc = downcast(so.data).fruticard;
			if(fc == null){
				fc = new Array();
				downcast(so.data).fruticard = fc;
			}
			
		}else{
			fc = Manager.client.slots;
		}
			
		
		card = downcast(fc[0])
		pref = downcast(fc[1])
		
		var flForceFormat = ( Key.isDown(70) && Key.isDown(Key.SPACE) )
		
		if(  card == null || flForceFormat  ){
			formatFruticard();
		}
		
		if( card.$vs < VERSION ){
			patchFruticard();			
		} 
		
		
		if( pref == null || flForceFormat ){
			formatPref();
		}
		
		Manager.log("current:"+Log.toString(Cm.card.$current))
		
	}
	
	static function formatFruticard(){
		
		
		Manager.log("-Format card-")
		
		card = {
			$time:{
				$t:Manager.date.getTime()//-1099217438781//-300000000
				$d:0
				$s:int( Manager.date.getHours()*60*60000 )
			}
			
			$current:null
			
			$vs:VERSION
			$bag:0
			$wind:int(Math.random()*100)/100
			
			$help:[]
			
			$key:0
			$star:0
			$diam:0
			$checkpoint:0
			$god:[false,false,false]
			
			$frog:false
			
			$inv:[]//[30,201,202,203,null,null]
			$faerie:[]
			$pond:{$fs:null,$d:0,$q:null}
			$dungeon:{$lvl:0,$f:false,$day:0,$loop:0}
			$rainbow:{$f:false,$day:null,$it:null}
			$mission:null
			$mis:[]
			$stat:{ $run:0, $game:[0,0,0,0,0], $item:[], $eat:[], $kill:[0,0,0,0,0], $forestMax:0, $treeMax:0, $misNum:0 }			
		}
		
		/* HACK
			card.$du3;
			card.$dungen.$f = true;
		
		
		//*/
		
		// SAVE
		/*
		var pc = new PersistCodec();
		var enc = pc.encode(card)
		var dec = pc.decode(enc);
		Manager.log("encode:\n"+enc)
		Manager.log("decode:\n"+Log.toString(dec))
		*/
		//Log.trace("ext")
		//Log.trace(Std.getGlobal("ext"))
		//Log.trace(Std.getGlobal("ext"))
		//Log.trace(Std.getGlobal("$ext".substring(1))[Std.cast("$util".substring(1))][ Std.cast("MTSerialization".subtring(1)) ][Std.cast("$serialize".substring(1))]);
		
		//var enc = ext.util.MTSerialization.serialize(card)
		//var dec = ext.util.MTSerialization.unserialize(enc)
		//Manager.log("ext.util.MTSerialization.serialize:\n")
		//Log.trace(Std.getGlobal("ext").util[ Std.cast("MTSerialization") ].serialize)
		
		//Log.trace("ext")
		//Log.trace("MTSerialization")
		//Manager.log("encode:\n"+enc)
		//Manager.log("dec:\n"+Log.toString(dec))
		
		//Manager.client.saveSlot(0,card)
		
		Manager.client.slots[0] = Std.cast(card); 
		Manager.client.saveSlot(0,null);
		
		if(Client.STANDALONE){
			downcast(so.data).fruticard[0] = card
		}
		
		
		// TEXTE DEPART
		var str = "Vos recherches sur les êtres féeriques vous ont amené aux frontières de votre pays natal.\nAprès une nuit à la belle étoile, vous décidez de partir à la recherche des fées dans cette mystérieuse forêt."
		Manager.addMsg(str)
		
		
		
	}
	
	static function patchFruticard(){
		Manager.log("patch card !!!")

		if( card.$vs < 0.341 ){ // PATCH 0.341 initCheckpoints
			if(card.$checkpoint==null)card.$checkpoint=0;
		}
	
		if( card.$vs < 0.35 ){ // PATCH 0.35 humor sur les fées
			for( var i=0; i<card.$faerie.length; i++){
				card.$faerie[i].$humor = Std.random(5)
			}
		}
		
		if( card.$vs < 0.37 ){ // Rajoute les éléments pour le mode tree
			card.$stat.$treeMax = 0
			card.$stat.$game[4] = 0
		}
		
		if( card.$vs < 1.00 ){ // Rajoute les éléments pour le mode tree
			formatFruticard();
		}		
		
		card.$vs = VERSION
		save();
	}
	
	static function formatPref(){
		Manager.log("formatPref!")
		pref = {
			$mouse:false,
			$sound:[1,1],
			$key:[Key.LEFT,Key.RIGHT,Key.SPACE,Key.DOWN,Key.UP]
			
		}
		Manager.client.slots[1] = Std.cast(pref); 
		Manager.client.saveSlot(1,null);		
		//downcast(so.data).fruticard[1] = pref
	}

	static function save(){
		Manager.client.saveSlot(0,null)
	}
	

	// UPKEEP
	
	static function updateTime(){
		var t = Manager.date.getTime()
		var et = t - card.$time.$t
		card.$time.$t = t
		card.$time.$s += et
		
		while( card.$time.$s > Cs.sDay ){
			Manager.flNewDay = true;
			card.$time.$s -= Cs.sDay;
			card.$time.$d += 1;			
			upkeep();

		}
		save();
	}
	
	static function upkeep(){
		Manager.log("upkeep!!")
		// FAERIE
		var list = new Array();
		for( var i=0; i<card.$faerie.length; i++){
			var fi = getFaerie(card.$faerie[i])
			list.push(fi);
		}

		for( var i=0; i<list.length; i++){
			var fi = list[i]
			if( getFaerieIndex(fi.fs) !=null && fi.isAvailable() )fi.upkeep();
		}
		
		// POND
		card.$pond.$d++
		if( card.$pond.$fs == null ){
			//Manager.log("card.$pond.$fs == null! ("+card.$pond.$d+")")
			if( ( card.$pond.$d > 2 && Std.random(2)==0 ) || card.$faerie.length == 0 ){
				card.$pond.$d = 0
				
				var fs = genFaerieSeed();
				var q =  Math.floor( Cs.mm(0,Math.pow(Std.random(card.$time.$d),0.3)-1,5) )
				
				//Manager.log(">>"+q)
				
				// AVANTAGES
				for( var i=0; i<q; i++ ){
					// EXCEPTIONNEL
					if( Math.random()>0.99 && i<q+1 ){	// ATLAS
						i++;
						fs.$inv.push(null)
					}else{
						// BASIC
						var c = Std.random(6)
						fs.$carac[c]++
					}
					
				}
				
				card.$pond.$fs = fs;
				card.$pond.$q = q;
				
				Manager.addMsg("On peut apercevoir une lueur étrange au fond du bassin...")
				
			}
		}else{
			if( card.$pond.$d > 1 ){
				card.$pond.$d = 0
				card.$pond.$fs = null;
				card.$pond.$q = null;
				
				Manager.addMsg("La lueur du bassin s'est éteinte cette nuit.")
				
			}
		}
		
		// DUNGEON
		if( card.$dungeon.$lvl < 5 && !card.$dungeon.$f  ){
			if(  Math.pow(card.$dungeon.$lvl+1,2)*5000 < card.$stat.$run  && (card.$time.$d-card.$dungeon.$day) > 4 ){	
				
				card.$dungeon.$f = true;
			
				var dun = ["petite tour ","grande tour ","bastide ", "forteresse ", "citadelle "]
				var adj = ["curieux ","étranges ", "farceurs ", "baroques ", "bizarres ", "biscornus ", "malfaisants ", "abominables ","exotiques ","extravagants ","saugrenus ","fantastiques ","mystérieux ","louches ","insolites ","incroyables ","énigmatiques ","grotesques ","cornus ","absurdes ","farfelus ","informes "]
			
				Manager.addMsg( "Une "+dun[card.$dungeon.$lvl]+"a été construite pendant la nuit. Des êtres "+adj[Std.random(adj.length)]+"semblent roder autour de celle-ci...")
			
			}
		}
		
		// FAERIE >16
		for( var i=0; i<card.$faerie.length; i++ ){
			var fs = card.$faerie[i]
			if( fs.$level >= 15 && card.$time.$d%fs.$moral == 0 ){
				var slist = [
					fs.$name + " aimerait pouvoir partir vers de nouveaux horizons... "
					"Lassée des batailles contre les démons "+fs.$name + " se plait de moins en moins à vos côtés."
					fs.$name + " rêve chaque nuit de commencer une nouvelle vie."
					fs.$name + " semble fatiguée par vos dernières aventures."
					fs.$name + " souhaite que vous lui rendiez sa liberté."
					fs.$name + " a le mal du pays..."
					fs.$name + " aimerait pouvoir revoir sa ville natale."
					"Les amies de "+fs.$name+" semblent lui manquer de plus en plus."
					"Après une multitude d'aventures à vos côtés, "+fs.$name+" aspire finalement à un peu plus de tranquillité."
					fs.$name + " est satisfaite du chemin parcouru à vos côtés. Désormais son voeux le plus cher est de pouvoir rejoindre ses soeurs."
				]
				Manager.addMsg( slist[ Std.random(slist.length)] )
			}
		}
		
		// RAINBOW
		var r = card.$rainbow
		if( r.$day != null ){
			r.$day++;
			if( r.$f ){
				if( r.$day > 0 ){
					removeRainbow();
				};
			}else{
				if( r.$day > 3 && Std.random(2) == 0 ){
					addRainbow();
				};
			}
		}
		
		// WIND
		card.$wind = int(Math.random()*100)/100
		
		// MISSION
		if( card.$stat.$run > 1000 && card.$faerie.length > 0 ){
			genMissions();			
		}
		for( var i=0; i<card.$mis.length; i++){
			var m = card.$mis[i]
			m.$d--
			if(m.$d == 0){
				validateMission(i)
				i--
			}
		}
		
		
		
		
	}
	// RAINBOW
	static function addRainbow(){
		var r = card.$rainbow
		r.$day = 0
		r.$f = true;
		r.$it = getRainbowItem();
		Manager.addMsg("Il y a un magnifique arc-en-ciel, ce matin !")
	}
	
	static function removeRainbow(){
		//Manager.log("removeRainbow!")
		var r = card.$rainbow	
		r.$day = 0;
		r.$f = false;
	}
	
	static function getRainbowItem(){
		var n = null
		if( card.$bag == 3 ){
			n = 83
		}else{
			var rnd = Std.random(100)
			if( rnd < 5  ){
				n = 71	// TODO
			}else if( rnd < 10 ){
				n = 71	// TODO
			}else if( rnd < 20 ){
				n = 72	
			}else if( rnd < 50 ){
				n = 60+Math.round((rnd-20)/3)
			}else{
				n = 71
			}
		}
		//Manager.log(">>>>"+n)
		return n;
	}
	
	// MISSIONS
	static function genMissions(){
		//Manager.log("Generation des nouvelles missions:")
		card.$mission = new Array();
		var time = [3,5,7,10,15,30]
		var giftList = Item.getSortedList();
		for( var i=0; i<time.length; i++ ){
			var list = new Array();
			var dif = Std.random( int(Math.min(i*2,6)) )
			var coef = (dif*2+i+Math.random()) / 18 
			var gift = giftList[int(coef*giftList.length)]
			var type = Std.random(Lang.MISSION.length)
			card.$mission.push([dif,type,time[i],gift.id,Std.random(10000)])
			//Manager.log("- Mission ("+time[i]+" jours) dif("+dif+") --> "+Item.newIt(gift.id).getName()+" !")
		}
	}
	
	static function addMission(id,list,flVictory,endStr){
		var info = card.$mission[id]
		var index = card.$mis.length
		card.$mis[index] = {
			$d:info[2],
			$gift:flVictory?info[3]:null,
			$type:info[1],
			$string:endStr
		}

		for( var i=0; i<list.length; i++ ){
			var fs = list[i]
			if( fs.$mission == null ){
				fs.$mission = index
			}else{
				Log.trace("ERROR Mission 0")
			}
		}
		card.$mission.splice(id,1)
		
		card.$stat.$misNum++;
		
	}
	
	static function validateMission(id){
		var mis = card.$mis[id]
		var fl = new Array();
		
		for( var i=0; i< card.$faerie.length; i++ ){
			var fs = card.$faerie[i]
			if( fs.$mission == id ){
				fs.$mission = null;
				fl.push(fs);
			}
		}
		if( fl.length == 0 )Log.trace("ERROR Mission 1");
		 
		var group = ""
		for( var i=0; i<fl.length; i++ ){
			group+=fl[i].$name
			if( i+1 == fl.length ) group +=" ";
			if( i+2 == fl.length ) group +=" et ";
			if( i+2 < fl.length )  group +=", ";	
		}
		
		
		if( mis.$gift != null ){
				
			var str = "Félicitation !\n"
			str += group
			if(fl.length>1){
				str += "ont "
			}else{
				str += "a "
			}
			str += mis.$string+"\n"
			str += "Vous avez gagné l'objet suivant : "+Item.newIt(mis.$gift).getName()+" !"
			
			var index = null
			for( var i=0; i<Cs.bagLimit[card.$bag]; i++ ){
				if(card.$inv[i]==null){
					index = i
					break;
				}
			}
			if( index != null ){
				var it = Item.newIt(mis.$gift)
				if(it.flGeneral){
					it.grab();
				}else{
					card.$inv[index] = mis.$gift;
				}
			}else{
				str += "\nMalheureusement, vous n'aviez pas assez de place dans votre inventaire pour cet objet. Il a donc été généreusement offert à l'AFD ( Associaiton des Fées Démunies ) qui vous remercie chaleureusement pour ce don.\n"
			}
			Manager.addMsg(str)
		}else{
			var str = group
			if(fl.length>1){
				str += "n'ont "
			}else{
				str += "n'a "
			}
			str += mis.$string
			Manager.addMsg(str)
		}
		
		// ELIMINE LA MISSION - RECALE LES INDEX DES FEES
		card.$mis.splice(id,1)
		for( var i=0; i<card.$faerie.length; i++ ){
			var fs = card.$faerie[i]
			if( fs.$mission > id )fs.$mission--;
		}
		
	}
	
	// MODIF
	
	static function getNewBag(n){
		card.$bag = n
	}
	
	static function winDungeon(){
		if(card.$dungeon.$lvl==4 ){
			var r = card.$rainbow;
			if(card.$rainbow.$day == null){
				addRainbow();
			}
			card.$dungeon.$loop++;
		}
		if( card.$dungeon.$lvl==2 ){
			freeOrnegon();
			/*
			if(!card.$frog)card.$frog = true;
			callHelp(Cs.HELP_ORNEGON)
			*/
		}
		
		if(card.$dungeon.$loop==0){
			Manager.client.giveItem("$diam_"+card.$dungeon.$lvl);
		}
		
		card.$dungeon.$lvl = (card.$dungeon.$lvl+1)%5;
		card.$dungeon.$f = false;
		card.$dungeon.$day = card.$time.$d;
		card.$diam = int(Math.max(card.$diam,card.$dungeon.$lvl))
	}
	
	static function freeFaerie(){
		var fs = card.$pond.$fs
		card.$pond.$fs = null;
		card.$pond.$q = 0;
		card.$current = card.$faerie.length
		card.$faerie.push(fs)
		callHelp(Cs.HELP_FIRST_FAERIE)
	}
	
	static function freeOrnegon(){
		card.$frog = true;
		callHelp(Cs.HELP_ORNEGON)
	}
		
	static function incKey(inc){
		Cm.card.$key = int( Cs.mm(0,card.$key+inc,9) ) 	
	}
	
	static function incEatStat(n:int){
		Manager.log("[CM] eat("+n+")")
		if(Cm.card.$stat.$eat[n]==null)Cm.card.$stat.$eat[n] = 0;
		Cm.card.$stat.$eat[n]++
		var s = Cm.card.$stat.$eat[n]
		var num = null
		if( s == 1  )		num = 3;
		if( s == 5 )		num = 2;
		if( s == 20 )		num = 1;
		if( num != null ){
			Manager.log("[CM] getFoodTitem("+(n*3+num)+")")
			Manager.client.giveItem("$food_"+(n*3+num));
			save();
		}
	}
	
	static function getItem(n:int){
		if( n!=31 && n<300 && Cm.card.$stat.$item[n]!=true ){
			Manager.log("[CM] getItemTitem("+(n+1)+")")
			Manager.client.giveItem("$item_"+(n+1));
			Cm.card.$stat.$item[n] = true
			save();
		}
	}
	
	// HELP
	static function callHelp(id){
		if(card.$help[id]!=null)return;
		card.$help[id] = true;
		
		switch(id){
			case Cs.HELP_FIRST_FAERIE:
				Manager.addMsg("Vous venez de trouver votre première fée !\nSon nom est "+card.$faerie[0].$name+". Prenez bien soin d'elle, si vous ne la nourissez pas assez ou si elle s'ennuie trop, elle partira !")
				break;
			case Cs.HELP_ORNEGON:
				Manager.addMsg("En quittant le donjon, vous trouvez une petite grenouille orange. Son nom est Ornegon, il fut comme vous un explorateur à la recherche de fées. Malheureusement, alors qu'il était perdu dans la forêt enchantée, il fut changé en grenouille par un seigneur démon.")
				break;
			case Cs.HELP_GROMELIN:
				Manager.addMsg("Grâce à Gromelin, vous pourrez désormais donner des missions à vos fées ! Attention, elles seront indisponibles pendant la durée de ces missions.\nChaque jour de nouvelles missions sont disponibles!!!")
				break;			
		}
		
		
		
	}
	
	// FAERIE GENERATOR
	static function genFaerieSeed(){
		
		var fs:FaerieSeed = {
			$name:genFaerieName()		
			$humor:Std.random(8)
			$carac:[1,1,1,1,1,1]
			$skin:[ 
				Std.random(6),
				Std.random(0xFFFFFF),
				Std.random(0xFFFFFF),
				Std.random(0xFFFFFF)
			]
			$mood:[]
			$next:[0,0]
			$pos:null
			$level:0
			$exp:0
			$hunger:4
			$moral:10
			$shot:0
			$spell:[20,0]
			$spellCoef:[]
			$taste:[]
			$behaviour:[]
			$inv:[]
			$mission:null
			$bagMax:2
			$life:0
			$mana:0
		}
		
		fs.$life = Math.ceil(fs.$carac[Cs.LIFE]);
		fs.$mana = fs.$carac[Cs.MANA]*2;
		
		// TASTE
		var like = new Array();
		var dislike = new Array();
		var table = [1.1,2,8,40,100,1000]
		while( Math.random()*table[like.length] < 1  ){
			var n = Std.random(5)
			if( Std.random(100) > 0 ) n+=5
			if( Cs.indexOf(like,n)==null ){
				like.push(n)
			}
		}
		while( Math.random()*table[dislike.length] < 1  ){
			var n = Std.random(5)
			if( Std.random(30) == 0 ) n+=5
			if( Cs.indexOf(like,n)==null && Cs.indexOf(dislike,n)==null ){
				dislike.push(n);
			}
		}
		fs.$taste = [like,dislike]
		
		// BEHAVIOUR
		if( Std.random(80) == 0 ) fs.$behaviour[Cs.PSYCHOANALYST] = 1
		if( Std.random(100) == 0 ) fs.$behaviour[Cs.CANNIBALISM] = 1
		if( Std.random(60) == 0 ) fs.$behaviour[Cs.CLEPTOMAN] = 1
		if( Std.random(60) == 0 ) fs.$behaviour[Cs.APATHY] = 1
		if( Std.random(100) == 0 ) fs.$behaviour[Cs.SCHYZO] = 1
		
		// NEXT LEVEL UP
		var fi = getFaerie(fs)
		fi.setNextLevelUp();
		
		
		return fs
	}
	
	static function genFaerieName(){
		var p0 = Lang.nameSyl0[Std.random(Lang.nameSyl0.length)].substring(1)
		var p1 = Lang.nameSyl1[Std.random(Lang.nameSyl1.length)].substring(1)
		return p0+p1
	}
	
	// FAERIE TOOL
	static function getFaerieIndex(fs){
		var list = card.$faerie;
		for( var i=0; i<list.length; i++ ){
			if(list[i]==fs)return i;
		}
		return null;
	}
	
	static function getCurrentFaerie():FaerieInfo{
		//var n = card.$current
		var fs = card.$faerie[card.$current]
		return getFaerie(fs)
	}
	
	static function getFaerie(fs):FaerieInfo{
		if(fs==null)return null;
		var fi = new FaerieInfo();
		fi.setFaerieSeed(fs)
		return fi;

		
	}	
	
	static function withdraw(n){
		var fi = getFaerie(card.$faerie[n])
		var str = fi.fs.$name+" est repartie au pays des fées ! "
		
		if( fi.fs.$level >= 15 ){
			str += "En souvenir de vos aventures, elle vous offre une étoile !"
			card.$star++;
		}
		Manager.addMsg(str)
		fi.erase();
		/*
		if( n == Cm.card.$current) Cm.card.$current = null;	
		Cm.card.$faerie.splice(n,1);
		*/
	}
	
	// TOOLS
	static function getNightCoef(){
		return card.$time.$s/ Cs.sDay;	
	}
	
	// DEBUG
	static function logStat(){
	
		Manager.log("Statistiques:")
		//*
		for( var i=0; i<card.$mission.length; i++ ){
			var info = card.$mission[i]
			Manager.log("Mission: dif:"+info[0]+" type:"+info[1]+" duree:"+info[2]+" item:"+info[3]+" seed:"+info[4]+"")
		}
		//*/
		/*
		Manager.log("Missions en cours:")
		for( var i=0; i<card.$mis.length; i++ ){
			var mis = card.$mis[i]
			Manager.log("Mission: durée:"+mis.$d+" type:"+mis.$type+" gift:"+mis.$gift+"")
		}
		*/
		/*
		// DATE
		Manager.log("Jour "+card.$time.$d+" ("+(Math.round((card.$time.$s/Cs.sDay)*100)/100)+")" )
		
		// PARTIES
		var list = card.$stat.$game
		var name = ["foret ","bassin ","donjon "]
		for( var i=0; i<list.length; i++){
			Manager.log("Mode "+name[i]+": "+list[i]+" partie(s)")
		}
		*/
		// ITEM
		/*
		list = game.$stat.item
		var str = "items ramassés"
		for( var i=0; i<list.length; i++){
			
		}
		log(str)			
		*/	
	}
	
	static function getBarbarellaSeed(){
		var fs = Cm.genFaerieSeed()
		for( var i=0; i<6; i++ ){
			//fs.$carac[i] = 1+Std.random(7);
			fs.$carac[i] = 7
		}
		fs.$skin = [10,0xFFDD00,0xFFFFFF,0xDDF0FF]
		//fs.$skin[0] = 10
		fs.$name = "$Barbarella".substring(1);
		fs.$level = 19
		fs.$spell = [20,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,21,22,23,24,25,26,27];
		fs.$life = fs.$carac[Cs.LIFE]
		fs.$humor = 0
		// CLEPTO
		//fs.$behaviour[Cs.CLEPTOMAN] = 1;
		// APATHY
		//fs.$behaviour[Cs.APATHY] = 1;				
		// DISEASE
		//fs.$behaviour[Cs.HYPOCONDREAC] = 1;		
		//
		return fs;
	}
	
//{	
}


