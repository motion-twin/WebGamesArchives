import GameData._ArtefactId ;


typedef IData = {
	var le : Array<Int> ;
	var lo : Array<{o : _ArtefactId, qty : Int}> ;
	var q : Array<{o : _ArtefactId, qty : Int, qid : Int}> ;
	var belt : Array<_ArtefactId> ;
}


class Inventory {
	
	public var elements : Array<Int> ;
	public var objects : Array<{o : _ArtefactId, qty : Int}> ;
	public var belt : Array<_ArtefactId> ;
	
	public var quests : Array<{o : _ArtefactId, qty : Int, qid : Int}> ;
	public var user : db.User ;
	
	
	
	public function new () {
	}
	
	
	static public function create(d : IData, u : db.User) : Inventory {
		var i = new Inventory() ;
		if (d == null) {
			i.elements = new Array() ;
			for (k in Data.ELEMENTS.keys()) {
				i.elements[Std.parseInt(k)] = 0 ;
			}
			
			i.elements[0] = 2 ;
			i.elements[1] = 2 ;
			i.elements[3] = 2 ;
			
			i.objects = new Array() ;
			i.quests = new Array() ;
			i.belt = new Array() ;
			if (u.beltSize > 0) {
				for (j in 0...u.beltSize)
					i.belt.push(null) ;
			}
		} else {
			i.elements = d.le ; 
			i.objects = d.lo; 
			i.quests = d.q ;
			if (d.belt != null)
				i.belt = d.belt ;
			else {
				i.belt = new Array() ;
				if (u.beltSize > 0) {
					for (j in 0...u.beltSize)
						i.belt.push(null) ;
				}
			}
		}
		
		i.user = u ;
		
		return i ;
	}
	
	
	public function updateBeltSize(s : Int) {
		if (s <= belt.length)
			throw "invalid belt size : " + s + " ==> " + belt.length ;
		
		for(i in belt.length...user.beltSize)
			belt[i] = null ;
	}
	
	
	public function lessBeltSize() {
		var nr = new Array() ;
		for(i in 0...belt.length -1) {
			nr[i] = null ;
		}
		
		var c = 0 ;
		for (o in belt) {
			if (o == null)
				continue ;
			nr[c] = o ;
			c++ ;
			if (c >= nr.length)
				break ;
		}
		
		belt = nr ;
	}
	
	
	public function recalBelt() {
		if (belt == null || belt.length == 0)
			return ;
		
		for (i in 0...belt.length) {
			var b = belt[i] ;
			if (b == null)
				continue ;
			if (!hasObject(b))
				belt[i] = null ;
		}
		
	}
	


	function checkBeltSize(index : Int) {
		if (index < belt.length)
			return ;
		
		throw "belt too small for " + index ;	
	}
	
	
	public function getBelt() : Array<{o : _ArtefactId, open : Bool}> {
		var res = new Array() ;
		for (i in 0...4) {
			if (i < belt.length)
				res.push({o : belt[i], open: true}) ;
			else 
				res.push({o : null, open : false}) ;
		}
		return res ;
	}
	
	
	public function dropBelt(index : Int) {
		checkBeltSize(index) ;
		belt[index] = null ;
	}
	
	
	public function addToBelt(o : _ArtefactId, index : Int) {
		checkBeltSize(index) ;
		var q = getQuantity(o) ;
		if (q <= 0)
			throw "no " + Std.string(o) + " in your inventory" ;
		//beltSearchAndDrop(o, q - 1) ;
		var qtyMax = switch(o) {
						case _Empty : 3 ;
						case _PolarBomb : 1 ;
						default : 0 ; // <--- 1 seul objet de mm type utilisable par partie
					}
				
		beltSearchAndDrop(o, qtyMax, q - 1) ; 
		belt[index] = o ;
	}
	
	
	function beltSearchAndDrop(o : _ArtefactId, qty : Int, invQty : Int) {
		var c = 0 ;
		for (i in 0...belt.length) {
			if (!Type.enumEq(belt[i], o))
				continue ;
			c++ ;
			if (c > qty || c > invQty)
				belt[i] = null ;
		}
	}
	
	public function hasAll(l : Array<{o : _ArtefactId, qty : Int}>) : Bool {
		if (l == null || l.length == 0)
			return true ;
		
		for (o in l) {
			if (!has(o.o, o.qty))
				return false ;
		}
		
		return true ;
	}
	
	public function hasAllQuest(l : Array<{o : _ArtefactId, qty : Int}>) : Bool {
		if (l == null || l.length == 0)
			return true ;
		
		for (o in l) {
			if (!hasQuest(o.o, o.qty))
				return false ;
		}
		
		return true ;
	}

	
	public function drop(l : Array<{o : _ArtefactId, qty : Int}>, ?r : Recipe) : Bool {
		if (l == null || l.length == 0) {
			return false ;
		}
		
		var haveAll = true ; 

		
		for (o in l) {

			if (o.qty < 0) {
				App.logError("WARNING : inventory drop with negative qty : " + Std.string(l)) ;
				return false ;
			}

			switch(o.o) {
				case _Elt(e) : 
					if (elements[e] == null || elements[e] < o.qty)
						haveAll = false ;
					
					if (elements[e] == null) 
						continue ;
					
					elements[e] -= o.qty ;
					if (elements[e] < 0)
						elements[e] = 0 ;
					
				default : 
					var found = false ;	

					switch(o.o) {
						case _QuestObj(id) :
							if (id == "kubor1" || id == "kubor2" || id == "kubor3")
								continue ;

							var isQuest = quests != null && user.qid != null && r != null && r.questOnly ; //reserved questObj required
							var isSpecial = id == "menthol" || id == "milk" || id == "geminishregular" ;
						
							if (isQuest) {
								for (io in quests) {
									if (user.qid != io.qid || !Type.enumEq(o.o, io.o))
										continue ;
									
									found = true ;
									if (io.qty < o.qty)
										haveAll = false ;
									
									io.qty -= o.qty ;
									if (io.qty < 0)
										io.qty = 0 ;
									
									break ;
								}
								
								
								if (!found && !isSpecial) {
									haveAll = false ;
								}
							}	
							
							if (!isQuest || (isQuest && !found && isSpecial)) { //questobj in normal inventory (menthol/milk/geminishregular)
								for (io in objects) {
									if (!Type.enumEq(o.o, io.o))
										continue ;
									
									found = true ;
									if (io.qty < o.qty)
										haveAll = false ;
									
									io.qty -= o.qty ;
									if (io.qty < 0)
										io.qty = 0 ;
									
									if (belt.length > 0)
										beltSearchAndDrop(io.o, io.qty, io.qty) ;
									
									break ;
								}
								
								if (!found)
									haveAll = false ;
								
							}

						default : 
							for (io in objects) {
						
								if (!Type.enumEq(o.o, io.o))
									continue ;
								
								found = true ;
								if (io.qty < o.qty) {
									haveAll = false ;	
								}
								
								io.qty -= o.qty ;
								if (io.qty < 0)
									io.qty = 0 ;

								if (Type.enumEq(o.o, _Stamp))
									user.updateStampSmiley(io.qty) ;
								
								if (belt.length > 0)
									beltSearchAndDrop(io.o, io.qty, io.qty) ;
								
								break ;
							}
							
							if (!found)
								haveAll = false ;
						
					}
					
					
				/*	if (!found) {
						switch(o.o) {
							
							case _QuestObj(id) :
								if (quests != null && user.qid != null) {
									var qfound = false ;
									for (io in quests) {
										if (user.qid != io.qid || !Type.enumEq(o.o, io.o))
											continue ;
										
										qfound = true ;
										if (io.qty < o.qty)
											haveAll = false ;
										
										io.qty -= o.qty ;
										if (io.qty < 0)
											io.qty = 0 ;
										
										break ;
									}
									
									if (!qfound)
										haveAll = false ;
									
								} else
									haveAll = false ;

							default : haveAll = false ;
						}
					}
				*/
			}
		}
		
		return haveAll ;
	}
	
	
	public function dropQuest(l : Array<{o :_ArtefactId, qty : Int}>) : Bool {
		if (l == null || l.length == 0)
			return false ;
		
		var haveAll = true ; 
		
		for (o in l) {			
			var found = false ;			
			for (io in quests) {
				if (user.qid != io.qid || !Type.enumEq(o.o, io.o))
					continue ;
				
				found = true ;
				if (io.qty < o.qty)
					haveAll = false ;
				
				io.qty -= o.qty ;
				if (io.qty < 0)
					io.qty = 0 ;
				
				break ;
			}
			
			if (!found)
				haveAll = false ;
		}
		
		return haveAll ;
	}
	
	
	public function add(x : Dynamic, ?q = 1) {
		if (Std.is(x, _ArtefactId)) {
			var o : _ArtefactId = x ;
			switch(o) {
				case _Elt(e) :
					addElement(e, q) ;
				default : 
					addObject(o, q) ;
			}
		} else 
			addElement(x, q) ;
	}
	
	
	public function addElement(ne : Int, ?q = 1) {
		if (elements == null)
			elements = new Array() ;
		
		switch(ne) {
			case 11 : mt.db.Twinoid.goals.increment(user, "eor", q) ; //db.UserTitle.add(Data.TITLES.getName("eor"), user, q) ; //pepite d'or
			case 15 : mt.db.Twinoid.goals.increment(user, "eabys", q) ; //db.UserTitle.add(Data.TITLES.getName("eabys"), user, q) ; //abysonne
			case 19 : mt.db.Twinoid.goals.increment(user, "emag", q) ; //db.UserTitle.add(Data.TITLES.getName("emag"), user, q) ; //magma
			case 23 : mt.db.Twinoid.goals.increment(user, "eprim", q) ; //db.UserTitle.add(Data.TITLES.getName("eprim"), user, q) ; //primoterre
			case 27 : mt.db.Twinoid.goals.increment(user, "evort", q) ; //db.UserTitle.add(Data.TITLES.getName("evort"), user, q) ; //coeur de vortex
			case 28 : mt.db.Twinoid.goals.increment(user, "echro", q) ; //db.UserTitle.add(Data.TITLES.getName("echro"), user, q) ; //chronium	
		}
		
		var e = elements[ne] ;
		if (e != null)
			elements[ne] += q ;
		else 
			elements[ne] = q ;
		
	}
	
	
	public function addObject(no : _ArtefactId, ?q : Int) {
		
		if (objects == null)
			objects = new Array() ;
		
		switch(no) {
			case _Elt(e) : 
				addElement(e, q) ;
				return ;
			/*case _QuestObj(idx) : // utile en cas de recette qui recquiert un objet de quête
				return ;*/ 
			case _Block(level) :
				return ;
			case _Neutral :
				return ;
			case _CountBlock(level) :
				return ;
			case _DigReward(o) :
				return ;
			case _Joker :
				return ;
			
			
			default : //continue 
		}
		/*
		if (!Data.getArtefactInfo(no).inv) //pas un objet d'inventaire
			return ;
		*/
		for (o in objects) {
			//if (o.o == no) {
			if (Type.enumEq(o.o, no)) {
				o.qty += if (q == null) 1 else q ;

				if (Type.enumEq(no, _Stamp))
					user.updateStampSmiley(o.qty) ;

				return ;
			}
		}
		objects.push({o : no, qty : if (q == null) 1 else q}) ;
		if (Type.enumEq(no, _Stamp))
				user.updateStampSmiley(if (q == null) 1 else q) ;
	}
	
	
	public function remove(x : Dynamic, ?q : Int) {
		if (Std.is(x, _ArtefactId)) {
			var o : _ArtefactId = x ;
			switch(o) {
				case _Elt(e) :
					removeElement(e, q) ;
				default : 
					removeObject(o, q) ;
			}
		} else 
			removeElement(x, q) ;
	}
	
	
	public function removeElement(re : Int, ?q : Int) {
		if (elements == null)
			throw "no elements in inventory" ;
		
		var e = elements[re] ;
		
		if (e == null || (if (q != null) e < q else e <= 0))
			throw "not enough elements " + re + " to remove" ; 
		
		elements[re] -= if (q == null) 1 else q ;
	}
	
	
	public function removeObject(ro : _ArtefactId, ?q : Int) {
		switch(ro) {
			case _Elt(e) : 
				removeElement(e, q) ;
				return ;
			default : //continue 
		}
			
		if (objects == null)
			throw "no elements in inventory" ;
		
		for (o in objects) {
			if (!Type.enumEq(o.o, ro))
				continue ;
			
			if ((q != null && o.qty < q) || (q == null && o.qty < 1))
				throw "not enough objects " + ro + " to remove" ; 
		
			o.qty -= if (q == null) 1 else q ;

			if (Type.enumEq(ro, _Stamp))
				user.updateStampSmiley(o.qty) ;

			if (belt.length > 0 /*&& o.qty == 0*/)
				beltSearchAndDrop(o.o, o.qty, o.qty) ;
			
			return ;
		}
		
		throw "object " + ro + " to remove not found" ; 
	}
	
	
	public function addQuest(qid : Int, no : _ArtefactId, ?q : Int) {
		if (quests == null)
			quests = new Array() ;
		
		for (o in quests) {
			if (qid == o.qid && Type.enumEq(o.o, no)) {
				o.qty += if (q == null) 1 else q ;
				return ;
			}
		}
		quests.push({o : no, qty : if (q == null) 1 else q, qid : qid}) ;
	}
	
	
	public function removeQuest(qid : Int, ro : _ArtefactId, ?q : Int) {
		if (quests == null)
			throw "no quest objects in inventory" ;
		
		for (o in quests) {
			if (qid != o.qid || !Type.enumEq(o.o, ro))
				continue ;
			
			if ((q != null && o.qty < q) || (q == null && o.qty < 1))
				throw "not enough objects " + ro + " to remove" ; 
		
			o.qty -= if (q == null) 1 else q ;
			return ;
		}
		
		throw "quest object " + ro + " to remove not found" ; 
	}
	
	
	public function flushQuest(q : Int) {
		if (quests == null)
			return ;
		
		for (o in quests.copy()) {
			if (o.qid == q)
				quests.remove(o) ;
		}
		if (quests.length == 0)
			quests = null ;
		
		
	}
	
	
	public function hasQuest(so : _ArtefactId, q : Int) : Bool {
		if (q == null)
			throw "hasQuest : q is null" ;
		
		if (quests == null || quests.length == 0 || user.qid == null)
			return false ;
		
		for (o in quests) {
			if (o.qid == user.qid && Type.enumEq(o.o, so))
				return o.qty >= q ;
		}
		return false ;
	}
	
	
	public function getDatas() : IData {
		return {le : elements, lo : objects, belt : belt, q : quests} ;
	}
	
	
	public function hasElement(se : Int, ?qty = 1) : Bool {
		if (elements == null || elements.length == 0)
			return false ;
		
		var eqty = elements[se] ;
		return eqty != null && eqty >= qty ;
	}
	
	
	public function hasObject(so : _ArtefactId, ?qty = 1) : Bool {
		if (objects == null || objects.length == 0)
			return false ;
		
		for (o in objects) {
			if (Type.enumEq(o.o, so))
				return o.qty >= qty ;
		}
		return false ;
	}
	
	
	public function has(x : Dynamic, ?qty = 1) : Bool {
		if (Std.is(x, _ArtefactId)) {
			var o : _ArtefactId = x ;
			switch(o) {
				case _Elt(e) :
					return hasElement(e, qty) ;
				case _QuestObj(id) : 
					return hasObject(o, qty) || hasQuest(o, qty) ;
				case _Joker : return true ;
				default : 
					return hasObject(o, qty) ;
			}
		} else 
			return hasElement(x) ;
	}
	
	
	public function getElementQuantity(e : Int) : Int {
		if (elements == null || elements.length == 0)
			return 0 ;
		
		return if (elements[e] == null) 0 else elements[e] ;
	}
	
	
	public function getObjectQuantity(so : _ArtefactId) : Int {
		switch(so) {
			case _Elt(e) : 
				return getElementQuantity(e) ;
			default : 
		}
		
		
		if (objects == null || objects.length == 0)
			return 0 ;
		
		
		for (o in objects) {
			try {
				if (Type.enumEq(o.o, so))
					return o.qty ;
			}catch(e:  Dynamic) {
				trace(o.o + " # " + so) ;
			}
		}
	
		return 0 ;
	}
	
	
	public function getQuantity(x : Dynamic) : Int {
		return if (Std.is(x, _ArtefactId)) getObjectQuantity(x) else getElementQuantity(x) ;
	}
	
	
	public function getQuestQuantity(so : _ArtefactId, ?qid : Int) : Int {
		if (qid == null)
			qid = user.qid ;
		
		if (quests == null || quests.length == 0 || qid == null)
			return 0 ;
		
		for (o in quests) {
			if (o.qid == qid && Type.enumEq(o.o, so))
				return o.qty ;
		}
		return 0 ;
	}
	
	
	
	public function getAllElements() : Array<{o : _ArtefactId, qty : Int}> {
		var res = new Array() ;
		for (i in 0...elements.length) {
			var e = elements[i] ;
			if (e == null || e <= 0)
				continue ;
			res.push({o : _Elt(i), qty : e}) ;
		}

		return res ;
	}
	
	public function _getAllElements() : Array<{_o : _ArtefactId, _qty : Int}> {
		var res = new Array() ;
		for (i in 0...elements.length) {
			var e = elements[i] ;
			if (e == null || e <= 0)
				continue ;
			res.push({_o : _Elt(i), _qty : e}) ;
		}

		return res ;
	}
	
	
	public function getAllObjects(?caulOnly = false, ?useOnly = false, ?playable = false, ?noquest = false) : Array<{o : _ArtefactId, qty : Int}> {
		var f = new Array() ;
		for (o in objects) {
			if (o.qty <= 0 || (caulOnly && !Data.getArtefactInfo(o.o).caul) || (useOnly && Data.getArtefactInfo(o.o).action == null) || (playable && !Data.getArtefactInfo(o.o).playable))
				continue ;
			f.push(o) ;
		}
		
		if (caulOnly && !noquest && quests != null && user.qid != null) {
			for (o in quests) {
				switch(o.o) {
					case _QuestObj(id) : 
						//nothing to do
					default : 
						continue ;
				}
				
				if (o.qid != user.qid || o.qty <= 0 || !Data.getArtefactInfo(o.o).caul)
					continue ;
				f.push(o) ;
			}
		}
		
		return f ;
	}
	
	
	public function _getAllObjects(?caulOnly = false, ?useOnly = false, ?playable = false, ?noquest = false) : Array<{_o : _ArtefactId, _qty : Int}> {
		var f = new Array() ;
		for (o in objects) {
			if (o.qty <= 0 || (caulOnly && !Data.getArtefactInfo(o.o).caul) || (useOnly && Data.getArtefactInfo(o.o).action == null) || (playable && !Data.getArtefactInfo(o.o).playable))
				continue ;
			f.push({_o : o.o, _qty : o.qty}) ;
		}
		
		if (caulOnly && !noquest && quests != null && user.qid != null) {
			for (o in quests) {
				switch(o.o) {
					case _QuestObj(id) : 
						//nothing to do
					default : 
						continue ;
				}
				
				if (o.qid != user.qid || o.qty <= 0 || !Data.getArtefactInfo(o.o).caul)
					continue ;
				
				
				f.push({_o : o.o, _qty : o.qty}) ;
			}
		}
		
		return f ;
	}
	
	//### UNUSED - only for clean old beta bug (blocks/skats/questObj in inventory)
	public function cleanBeta(un : String) {
		for (o in objects.copy()) {
			var goOut = true ;
			
			
			switch(o.o) {
				case _Pa : goOut = false ;
				case _Stamp : goOut = false ;
				case _Pistonide : goOut = false ;
				case _Grenade(l) : goOut = false ;
				case _PolarBomb : goOut = false ;
				case _PearGrain(l) : goOut = false ;
				
				default : 
					//nothing to do
			}
		
			trace(Std.string(o.o) + " (" + un + ")<br/>") ;
			
			if (goOut) {
				objects.remove(o) ; 
				beltSearchAndDrop(o.o, o.qty, o.qty) ;
			}
			
			
		}
		
	}
	
	
	public function getAllQuests(q : Int) : Array<{qid : Int, o : _ArtefactId, qty : Int}> {
		if (quests == null || q == null)
			return null ;
		
		var f = new Array() ;
		for (o in quests) {
			if (o.qty <= 0)
				continue ;
			if (q > 0 && q != user.qid)
				continue ;
			f.push(o) ;
		}
		
		if (f.length == 0)
			return null ;
		
		return f; 
	}
	
	
	public function getAll(?caulOnly = false) : Array<{o : _ArtefactId, qty : Int}> {
		return getAllObjects(caulOnly).concat(getAllElements()) ;
	}
	
	
	
	
}