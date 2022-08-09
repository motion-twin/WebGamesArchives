class Item{//}


	var type:int;
	var faerie:sp.pe.Cursor;
	var sub:MovieClip;
	var info:{id:int,freq:int,min:int,txt:String}
	
	
	static var itemList = [
		//CARAC
		{ id:0,		freq:400,	lvl:10	}	// GANTS +1
		{ id:1,		freq:50,	lvl:30	}	// GANTS +2
		{ id:2,		freq:10,	lvl:70	}	// GANTS +3
		{ id:5,		freq:400,	lvl:10	}	// BOTTES +1
		{ id:6,		freq:50,	lvl:30	}	// BOTTES +2
		{ id:7,		freq:10,	lvl:70	}	// BOTTES +3
		{ id:10,	freq:300,	lvl:10	}	// COEUR +1
		{ id:11,	freq:40,	lvl:30	}	// COEUR +2
		{ id:12,	freq:8,		lvl:70	}	// COEUR +3
		{ id:15,	freq:400,	lvl:10	}	// DIADEME +1
		{ id:16,	freq:50,	lvl:30	}	// DIADEME +2
		{ id:17,	freq:10,	lvl:70	}	// DIADEME +3
		{ id:20,	freq:400,	lvl:10	}	// IDOLE +1
		{ id:21,	freq:50,	lvl:30	}	// IDOLE +2
		{ id:22,	freq:10,	lvl:70	}	// IDOLE +3
		{ id:25,	freq:400,	lvl:10	}	// PERLE +1
		{ id:26,	freq:50,	lvl:30	}	// PERLE +2
		{ id:27,	freq:10,	lvl:70	}	// PERLE +3
		
		{ id:30,	freq:0,		lvl:0	}	// FLASK
		{ id:31,	freq:600,	lvl:0	}	// CLE
		
		// POWER
		{ id:40,	freq:20,	lvl:30	}	// INVISIBILITE
		{ id:41,	freq:10,	lvl:20	}	// MASQUE DE PEUR
		{ id:42,	freq:10,	lvl:60	}	// REGENERATION LIFE
		{ id:43,	freq:10,	lvl:70	}	// REGENERATION MANA
		{ id:44,	freq:15,	lvl:50	}	// MORE EXP
		{ id:45,	freq:5,		lvl:40	}	// CASQUE A CORNE
		{ id:46,	freq:100,	lvl:10	}	// TOTOCHE
		
		
		// 50 - 60 = CARAC ALL	= Globe
		
		// 60 - 70 = COLORATION
		
		{ id:70,	freq:700,	lvl:0	}	// POTION PETITE
		{ id:71,	freq:300,	lvl:10	}	// POTION MOYENNE
		{ id:72,	freq:80,	lvl:20	}	// GROSSE POTION
		
		// 80 -90 = bag
		
		// 100-200	SCROLLS - DYNAMIQUES	
	
	]
		
	static var foodList = [
	
		{ id:300,	freq:800,	lvl:0	}
		{ id:303,	freq:300,	lvl:0	}
		{ id:306,	freq:500,	lvl:0	}
		{ id:309,	freq:600,	lvl:0	}
		{ id:312,	freq:500,	lvl:0	}
		
		{ id:315,	freq:75,	lvl:10	}
		{ id:318,	freq:125,	lvl:10	}
		{ id:321,	freq:125,	lvl:10	}
		{ id:324,	freq:175,	lvl:10	}
		{ id:327,	freq:125,	lvl:10	}
		
		{ id:330,	freq:8,		lvl:20	}
		{ id:333,	freq:12,	lvl:20	}
		{ id:336,	freq:20,	lvl:20	}
		{ id:339,	freq:18,	lvl:20	}
		{ id:342,	freq:24,	lvl:20	}
		{ id:345,	freq:16,	lvl:20	}
		{ id:348,	freq:2,		lvl:20	}
		{ id:351,	freq:6,		lvl:20	}
		{ id:354,	freq:4,		lvl:20	}
		
	]
		
	
	static function initItemList(){
		// ADD SPELLS
		for( var i=0; i<Spell.spellList.length; i++ ){
			var s = Spell.spellList[i]
			
			// SCROLLS
			var o = {
				id:100+s.id,
				freq:int(s.freq*0.5),
				lvl:s.lvl
			}
			itemList.push(o);
			
			// BOOK
			o = {
				id:200+s.id,
				freq:int(s.freq*0.2),
				lvl:int(s.lvl*2)
			}
			itemList.push(o);	
		}
		
		//COLORATION
		for( var i=0; i<10; i++ ){
			var o = { id:60+i,	freq:50,	lvl:20	}
			itemList.push(o)
		}
		
		//CARAC ALL
		for( var i=0; i<6; i++ ){
			var o = { id:50+i,	freq:8,		lvl:50	}
			itemList.push(o)
		}		
		
	}
	
	static function getRandomId(fi,level){
		
		// SPECIFIC
		

		// BAG
		if( Cm.card.$bag < 3 ){
			var b = Cm.card.$bag+2
			/*
			if( Std.random( int(Math.max( 1, Math.pow(b,b)-level*0.5 )) ) == 0 ){
				return 80+Cm.card.$bag;
			}
			*/
			
			if( Cs.aventure.level > Cm.card.$bag*20 && Std.random(2+Cm.card.$bag*20) == 0 ){
				return 80+Cm.card.$bag;
			}
			
		}
		
		if( Cm.card.$bag == 0 )return null;
		
		// FLASK
		var sl = scanInventory()
		if( Math.random()*Math.pow(sl[30]+2,3) < 1 )return 30;
		
		// CONSTRUCTION DE LA LISTE
		var tossList = null;
		if(Std.random(4)==0){
			tossList = itemList
		}else{
			tossList = foodList
		}
			
		var list = new Array();
		var sum = 0;
		for( var i=0; i<tossList.length; i++ ){
			var o = tossList[i]
			
			//Manager.log( (fi.fs.$level >= o.min && fi.fs.$level != null)+"||"+(o.min == null)+"&&"+(level >= o.lvl)  )
			if( level >= o.lvl  ){
				//Manager.log("+"+o.id)
				list.push([o.id,o.freq])
				sum += o.freq;
			}
			//Manager.log( o.min+","+o.lvl+","+fi.fs.$level )
		}
			
		// TIRAGE
		var n = Std.random(sum)
		var s = 0;
		for( var i=0; i<list.length; i++ ){
			s += list[i][1];
			if( s > n ){
				return list[i][0];
			}
		}
		Manager.log("Item.getRandomId Error!!!")
		return null;
		
	}
	
	static function getSortedList(){
		var list = new Array();
		for( var i=0; i<itemList.length; i++ ){
			var o = itemList[i]
			list.push({id:o.id,score:(o.lvl*3)/(o.freq+1)})
		}
		for( var i=0; i<foodList.length; i++ ){
			var o = foodList[i]
			list.push({id:o.id,score:(o.lvl*3)/(o.freq+1)})
		}
		
		var f = fun(a,b){
			if(a.score > b.score ) return 1;
			if(b.score > a.score ) return -1;
			return 0;
		}
		list.sort(f)
		return list;		
	}
	
	static function scanInventory(){
		var list = new Array();
		for( var i=0; i<400; i++)list[i]=0;
		
		var ls = Cm.card.$faerie
		for( var i=0; i<ls.length; i++){
			var ls2 = ls[i].$inv
			for( var n=0; n<ls2.length; n++){
				list[ls2[n]]++
			}			
		}
		
		var ls3 = Cm.card.$inv
		for( var i=0; i<ls3.length; i++){
			list[ls3[i]]++
		}
		
		return list;
	}
	
	static function newIt(n):It{
		var item = null;
		
		if( 0 <= n && n < 30 ){
			item = new it.Carac();
		}
		if( 40 <= n && n < 50 ){
			item = new it.SpecialPower();
		}		
		if( 50 <= n && n < 60 ){
			item = new it.CaracAll();
		}		
		if( 60 <= n && n < 70 ){
			item = new it.Color();
		}				
		if( 70 <= n && n < 80 ){
			item = new it.Potion();
		}		
		if( 80 <= n && n < 90 ){
			item = new it.Bag();
		}
		
		if( 100 <= n && n < 200 ){
			item = new it.Scroll();
		}
		
		if( 200 <= n && n < 300 ){
			item = new it.Book();
		}
		
		if( 300 <= n && n < 400 ){
			item = new it.Food();
		}

		if( item == null ){
			switch(n){
				case 30:
					item = new it.Flask();
					break;
				case 31:
					item = new it.Key();
					break;				
			}
		}
		
		item.setType(n)
		return item;
	}
	
	
	/*	
	// INSTANCE	
	
	function new(){
		
		
	}
	
	function setType(n){
		type = n
		gotoAndStop(string(type+1))
		info = getInfo();
		switch(type){
			case 30:	// FLASK
				break;
		}
	}
	
	function addFaerie(fi){
		if( type != 30 ) Manager.log("ERROR: insert Faerie in non-Flask Item");
		
		// GRAPHIQUE
		var sp = new sp.pe.Cursor()
		sp.setInfo(fi)
		sp.init();	
		sp.birth(Std.createEmptyMC(sub,1))
		sp.skin._xscale = 220;
		sp.skin._yscale = 220;
		sp.body.body.stop();
		
		faerie = sp;

	}
	
	function removeFaerie(){
		faerie.kill();
	}
	
	function getInfo(){
		for( var i=0; i<itemList.length; i++ ){
			var o = itemList[i]
			if(o.id==type){
				return o;
			}
		}
		Manager.log("ERROR item id not found")
		return null;
	}
	
	function getInfoMsg(){
		return new Msg(info.txt);
	}
	*/
	
	
//{	
}














