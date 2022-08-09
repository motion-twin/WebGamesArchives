class FaerieInfo{//}

	var fs:FaerieSeed;
	var carac:Array<int>
	var spell:Array<int>
	var spellList:Array<spell.Base>
	var shotList:Array<spell.Shot>

	var sPow:Array<bool>

	// LINK
	var intFace:inter.Face
	var intLife:inter.Life;
	var intMana:inter.Mana;
	var intDialog:inter.Dialog;	

	
	var skin:{
		num:int
		col1:int,
		col2:int,
		col3:int,
	}
	
	var itList:Array<It>
	
	function new(){
	
	}
	
	function setFaerieSeed(f){
		
		fs=f;
		
		carac = fs.$carac.duplicate();
		spell = fs.$spell.duplicate();
		sPow = new Array();
		skin = {
			num : fs.$skin[0]
			col1 : fs.$skin[1]
			col2 : fs.$skin[2]
			col3 : fs.$skin[3]
		}
		
		initItems();
		initSpellList();
		
		
		
	}

	function initItems(){
		itList = new Array();
		
		for( var i=0; i<fs.$inv.length; i++ ){
			var n = fs.$inv[i]
			if(n!=null){
				var it = Item.newIt(n)
				it.fi = this;
				it.init();
				it.faerieEffect();
				itList.push(it)
			}
		}
		
		for( var i=0; i<Cm.card.$inv.length; i++ ){
			var n = Cm.card.$inv[i]
			if(n!=null){
				var it = Item.newIt(n)
				//it.fi = this;
				it.init();
				it.groupEffect(this);
				//itList.push(it)
			}
		}		
	}

	function initSpellList(){
		spellList = new Array();
		shotList = new Array();
		for( var i=0; i<spell.length; i++ ){
			var s = Spell.newSpell(spell[i])
			s.fi = this;
			if( s.flShoot ){
				shotList.push(downcast(s))
			}else{
				spellList.push(s)
			}
		}
		
		var f = fun(a,b){
			if(a.cost > b.cost ) return -1;
			if(b.cost > a.cost ) return 1;
			return 0;
		}
		
		shotList.sort(f)
		
	}
	
	function getNextExpLimit(){
		//return 1
		return Math.pow((fs.$level+1),2)*50
	}

	function setNextLevelUp(){
		
		var sid = null
		var t = 0;
		while(true){
			sid = Spell.getRandomId(this);
			var flBreak = true;
			for( var i=0; i<fs.$spell.length; i++ ){
				if(fs.$spell[i]==sid){
					flBreak = false;
					//Manager.log("not:"+sid)
				}
			}
			if(flBreak)break;
			if(t++>100){
				Manager.log("setNextLevelUp Spell error!")
				break;
			}
		}

		var cid = null
		t = 0;
		while(true){
			cid = Std.random(8)
			if( fs.$carac[cid] < 7 ) break;
			if(t++>100){
				Manager.log("setNextLevelUp Carac error!")
				break;
			}			
		}		
		
		
		fs.$next = [ cid, sid ] 
				
	}
	
	function levelUp(n){

		//Manager.log("level up ("+string(n)+")")
		incMoral(4);
		var next = getNextExpLimit()
		if( fs.$exp < next ){
			Manager.log("Level Up improbable...");
			return;
		}
		fs.$exp -= next;		
		fs.$level++

		switch(n){
			case 0:
				var car = fs.$next[0]
				fs.$carac[car]++
				carac[car]++
				Manager.log( "Apprentissage : +1 en "+it.Carac.carNameList[car] )
				break;
			case 1:
				var sid = fs.$next[1]
				fs.$spell.push(sid);
				spell.push(sid);
				initSpellList();
				Manager.log( "Apprentissage : "+Spell.newSpell(sid).getName() )
				break;
		}
		setNextLevelUp()
		
	}
	
	function eat(id){
		//$fs.hunger = Math.min($fs.hunger+4,20)
		incHunger(4)
		
		Cm.incEatStat(id)
		
		if( Cs.indexOf(fs.$taste[0],id) != null || id >=10 ){
			incMoral(3)
		}
		if( Cs.indexOf(fs.$taste[1],id) != null ){
			incMoral(-3)
		}
	}
	
	//
	function incLife(inc){
		fs.$life = int( Cs.mm(0,fs.$life+inc,carac[Cs.LIFE]) )
	}
	
	function incMana(inc){
		fs.$mana = int( Cs.mm(0,fs.$mana+inc,carac[Cs.MANA]*2) )
	}
	
	function incMoral(inc){
		fs.$moral = int( Cs.mm(0,fs.$moral+inc,20) )
	}
	
	function incHunger(inc){
		fs.$hunger = int( Cs.mm(0,fs.$hunger+inc,20) )
	}
	
	function incExp(inc){
		if(sPow[Cs.POW_EXP])inc*=1.5;
		fs.$exp += inc;
	}
	
	// GET
	function getBestShotAvailable(){
		for( var i=0; i<shotList.length; i++ ){
			var shot = shotList[i]
			if( fs.$mana >= shot.cost ){
				return shot;
			}
		}
		return null;
	} 
	
	// IS
	function isReadyForBattle(){
		var flag =  fs.$life > 0 && fs.$moral > 0
		if( fs.$mood[Cs.M_NUMB]==1 || fs.$mood[Cs.M_DISEASE]==1 ) flag = false;
		return flag;
	}
	
	
	// UPKEEP
	
	function upkeep(){
		
		var flFree = Cm.card.$current != Cm.getFaerieIndex(fs)
		
		// REGENERE LA FEE
		var maxLife = Math.ceil( (fs.$hunger/20) * carac[Cs.LIFE] )
		fs.$life = int( Math.max( fs.$life, maxLife ) )
		if( maxLife == 0 ){
			if(fs.$life > 0){
				Manager.addMsg( fs.$name+" a vraiment très faim !" );
				fs.$life --;
			}else{
				if(flFree){
					Manager.addMsg( fs.$name+" est morte de faim dans son bocal..." );
				}else{
					Manager.addMsg( fs.$name+" s'est enfuie car elle avait trop faim !" );
				}
				erase();
				return;
			}
		}else{
			if(fs.$hunger<10)Manager.addMsg( fs.$name+" a faim !" );
		}
		
		// VERIFIE SI LA FEE A FAIM
		fs.$hunger -= 4
		if( fs.$hunger <= 0 ){
			fs.$hunger = 0;
			fs.$moral -= 1;		
		}
		
		// VERIFIE SI LA FEE EST ENFERMEE OU LIBRE
		if( !flFree ){
			fs.$moral -= 1;	
		}else{
			if(fs.$moral<10)fs.$moral += 1;
			// VERIFIE SI LA FEE S'EST FAIT LA MALLE
			if( fs.$moral < 3 ){
				Manager.addMsg( fs.$name+" s'est enfuie pendant la nuit !" );
				erase();
				return;
			}
		}
		
		// REMET LE MORAL A 0;
		if( fs.$moral <= 0 ){
			fs.$moral = 0;
		}
		
		// EFFECTUE LES BEHAVIOUR
		var bl = fs.$behaviour
		for( var i=0; i<bl.length; i++ ){
			if( bl[i] == 1 ){
				switch(i){
					case Cs.PSYCHOANALYST:
						if( Std.random(5)==0 )tryToPsySibling();
						break;
					case Cs.CANNIBALISM:
						if( fs.$hunger == 0 && fs.$life <= 1 )tryToEatSibling();
						break;
					case Cs.CLEPTOMAN:
						if( Std.random(3) == 0 )tryToStealSibling();
						break;
					case Cs.APATHY:
						break;					
					case Cs.SCHYZO:
						if( Std.random(10) == 0 )schizoSwap();
						break;					
				}
			}
		}
		
		// MOODS
		fs.$mood = new Array();
			// NUMB
			if( Std.random(30) == 0  ){
				
				var list = [
					 fs.$name+" est un peu endormie aujourd'hui !",
					 fs.$name+" a un peu trop fait la fête hier soir.",
					 fs.$name+" n'a pas reussi à fermer l'oeil de la nuit.",
					 fs.$name+" a du mal à se réveiller ce matin.",
					 fs.$name+" n'a pas du tout la forme ce matin."
				]
				
				Manager.addMsg( list[Std.random(list.length)] );
				fs.$mood[Cs.M_NUMB] = 1;
				
			}else if( fs.$behaviour[Cs.APATHY] == 1 && Cm.card.$time.$d%3 == 0 ){
				Manager.addMsg( fs.$name+" est un peu endormie aujourd'hui !" );
				fs.$mood[Cs.M_NUMB] = 1;
			}
			// DISEASE
			if( Std.random(50) == 0  ){
				
				var list = [
					 fs.$name+" ne se sent pas très bien aujourd'hui.",
					 fs.$name+" n'est pas dans son assiette ce matin.",
					 fs.$name+" est malade aujourd'hui, elle ne pourra pas vous aider.",
					 fs.$name+" semble avoir de la fièvre ce matin.",
				]
				
				Manager.addMsg( list[Std.random(list.length)] );
				fs.$mood[Cs.M_DISEASE] = 1;
				
			}else if( fs.$behaviour[Cs.HYPOCONDREAC] == 1 && Cm.card.$time.$d%3 == 1 ){
				Manager.addMsg( fs.$name+" ne se sent pas très bien aujourd'hui." );
				fs.$mood[Cs.M_DISEASE] = 1;
			}			
		
		// EVENTS
		
			
			
		
		
	}
	
	function erase(){
		var index = Cm.getFaerieIndex(fs)
		Manager.log("Erase Faerie index("+index+") current("+Cm.card.$current+")")
		if( index == Cm.card.$current ){
			Cm.card.$current = null;
		}else{
			if( Cm.card.$current > index ){
				Cm.card.$current--;
			}
		}
		Cm.card.$faerie.splice(index,1)			
	};

	// BEHAVIOUR
	function tryToEatSibling(){
		var list = Std.cast(Tools.shuffle)(Cm.card.$faerie)
		for( var i=0; i<list.length; i++ ){
			var fso = list[i];
			if(fso != fs && fso.$mission == null ){
				if( fs.$level > fso.$level*2 ){
					Manager.addMsg(fs.$name+" a dévoré "+fso.$name+", elle se sent beaucoup mieux à présent")
					fs.$hunger += 15
					Cm.getFaerie(fso).erase(); 
					return;
				}else if( fs.$level > fso.$level ){
					Manager.addMsg(fs.$name+" a tellement faim qu'elle a essayé de manger "+fso.$name+" !!")
					return;
				}	
			}
		}
	}
	
	function tryToStealSibling(){
		var list = Std.cast(Tools.shuffle)(Cm.card.$faerie)
		for( var i=0; i<list.length; i++ ){
			var fso = list[i];
			if(fso != fs && fso.$mission == null ){
				var i0 = null
				var i1 = null
				for( var n=0; n<fs.$bagMax; n++ ){
					if( i0 == null || fs.$inv[n] == null ){
						i0 = n;
					}
				}
				
				for( var n=0; n<fso.$bagMax; n++ ){
					if( fso.$inv[n] != null ){
						i1 = n;
					}
				}				
				
				if( i1 != null ){
					var id0 = fs.$inv[i0]
					var id1 = fso.$inv[i1]
					fs.$inv[i0] = id1;
					fso.$inv[i1] = id0;
					
					Manager.addMsg( "Pendant la nuit, "+fso.$name+" a perdu l'objet suivant : "+Item.newIt(id1).getName() )
					return;
				}
			}
		}
	}
	
	function tryToPsySibling(){
		var list = Std.cast(Tools.shuffle)(Cm.card.$faerie)
		for( var i=0; i<list.length; i++ ){
			var fso = list[i];
			if(fso != fs && fso.$mission == null ){
				for( var n=1; n<fso.$behaviour.length; i++ ){
					var id = fso.$behaviour[n]
					if( id == 1 ){
						Manager.addMsg( fs.$name+" pense avoir décelé en "+fso.$name+" une forme de "+Lang.behaviourName[n]+"." )
					} 
				
				}
				
			}
		}
	}
		
	function schizoSwap(){
		var list = fs.$carac.duplicate();
		fs.$carac[0] = list[3]
		fs.$carac[1] = list[4]
		fs.$carac[2] = list[5]
		fs.$carac[3] = list[0]
		fs.$carac[4] = list[1]
		fs.$carac[5] = list[2]		
	}
	
	// REACT
	function react(list){
		var str = sent(list[fs.$humor])
		if( str != null ){
			speak(str)
		}
	}
	
	function getRichStr(str:String):String{
		// $cloud
		str = Std.cast(Tools.replace)(str,"$cloud",sent(Lang.CLOUD_SHAPE))
		
		// $name
		str = Std.cast(Tools.replace)(str,"$name",fs.$name)
		
		// $other
		var test = Std.cast(Tools.replace)(str,"$other","-")
		if( test.length != str.length ){
			if( Cm.card.$faerie.length > 1){
				var lst = Cm.card.$faerie.duplicate();
				lst = Std.cast(Tools.shuffle)(lst)
				for( var i=0; i<lst.length; i++ ){
					var ofs = lst[i]
					if( ofs!=fs){
						str = Std.cast(Tools.replace)(str,"$other",ofs.$name)
						break;
					}
					Manager.log("Error 1796 !")
				}
			}else{
				return null;
			}
		}
		// $like
		var lst  = fs.$taste[0]
		var id = 300
		if( lst.length > 0 ){
			id = 300+lst[Std.random(lst.length)]*3
		}
		str = Std.cast(Tools.replace)(str,"$like",downcast(Item.newIt(id)).getQt2())
		
		// $dislike
		lst  = fs.$taste[1]
		id = 300
		if( lst.length > 0 ){
			id = 300+lst[Std.random(lst.length)]*3
		}
		str = Std.cast(Tools.replace)(str,"$dislike",downcast(Item.newIt(id)).getQt2())
		
		return str;
		
	}
	
	function reactCombo(sum){
		if(sum > 36){
			react(Lang.superComboCheerList)
		}else if( sum > 16 ){
			react(Lang.comboCheerList)
		}
		
	}
	
	function reactItem(type){
		var it = downcast(Item.newIt(type))
		var str = null;
		if( type >= 300 ){
			
			for( var n=0; n<2; n++ ){
				var list = fs.$taste[n]
				for( var i=0; i<list.length; i++ ){
					if(it.id == list[i]){
						str = sent( Lang.SENT_GET_FOOD[n][fs.$humor] )
					}
				}
			}
			if( str == null ){
				if(it.id>=10){
					str = sent( Lang.SENT_GET_FOOD[2][fs.$humor] );
				}else{
					str = sent( Lang.SENT_GET_FOOD[3][fs.$humor] );
				}
				
			}
			str = Std.cast(Tools.replace)(str,"$food",it.getQt2())
			speak(str);
			
		}else{
			str = sent( Lang.SENT_GET_ITEM[fs.$humor] );
			var obj = Lang.getItemFamily(type)

			str = Std.cast(Tools.replace)(str,"$item",obj)
			speak(str);
		}
		
		
		
	}
	
	function speak(str){
		if(fs.$life>0){
			if( sPow[Cs.POW_TOTOCHE] ){
				if(Std.random(4)==0){
					str = sent(Lang.TOTOCHE_WORD);
				}else{
					return;
				}
			}
			str = getRichStr(str);
			if(str != null && str != "null" )Manager.slot.speak( str );
		}
	}
	
	function reactAmbience(){
		var list = Lang.SENT_GAME_AMBIENT_NORMAL;
		var rnd  = 3
		var c = Cs.game.getCoefFull()
		if( c < 0.1 ){
			list = Lang.SENT_GAME_AMBIENT_FINISH;
			rnd = 3
		}
		if( Cs.game.impList.length> 0 ){
			list = Lang.SENT_GAME_AMBIENT_BATTLE;
			rnd = 1
		}
		if( c > 0.5 ){
			list = Lang.SENT_GAME_AMBIENT_STRESS;
			rnd = 2
		}
		if(Std.random(rnd)==0)react(list);
	}
	
	function sent(list){
		return list[Std.random(list.length)]
	}
	
	
	// MSG
	function getMsgTaste(){
		
		var str = ""
		var list = fs.$taste[0]
		var flName = false
		if( list.length >0 ){
			flName = true;
			str+=fs.$name+" aime "
			for( var i=0; i<list.length; i++ ){
				var it = Item.newIt( 300+list[i]*3 )
				
				str += it.getQt();

				if( i+1 == list.length ) str +=". ";
				if( i+2 == list.length ) str +=" et ";
				if( i+2 < list.length ) str +=", ";
			}
		}
		list = fs.$taste[1]
		if( list.length >0 ){
			if(flName){
				str += "Elle "
			}else{
				str += fs.$name+" "
			}

			str+="déteste "
			for( var i=0; i<list.length; i++ ){
				var it = Item.newIt( 300+list[i]*3 )
				str += it.getQt();
				if( i+1 == list.length ) str +=". ";
				if( i+2 == list.length ) str +=" et ";
				if( i+2 < list.length ) str +=",  ";
			}
		}		
		return str	
	}
	
	// IS
	function isAvailable(){
		return fs.$mission == null
	}
	

//{	
}



















