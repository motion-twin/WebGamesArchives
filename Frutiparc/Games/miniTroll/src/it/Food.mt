class it.Food extends It{//}

	var id:int;

	
	static var NAME = [
		{ qt:"le pain",		qt2:"du pain",			name:"Pain "			}
		{ qt:"le raisin",	qt2:"du raisin",		name:"Raisin "			}
		{ qt:"la salade",	qt2:"une salade",		name:"Salade "			}
		{ qt:"les biscottes",	qt2:"une biscotte",		name:"Biscotte "		}
		{ qt:"les poires",	qt2:"une poire",		name:"Poire "			}
	                                
		{ qt:"les glaces",	qt2:"une glace",		name:"Glace "			}
		{ qt:"les oeufs",	qt2:"un oeuf",			name:"Oeuf "			}
		{ qt:"le gouda",	qt2:"du gouda",			name:"Gouda "			}
		{ qt:"les bananes",	qt2:"une banane",		name:"Banane "			}
		{ qt:"la brioche",	qt2:"une brioche",		name:"Brioche "			}
	                                
		{ qt:"--",		qt2:"de la barbapapa",		name:"Barbapapa "		}
		{ qt:"--",		qt2:"des nouilles chinoises",	name:"Nouilles chinoises "	}
		{ qt:"--",		qt2:"un poireau",		name:"Poireau "			}
		{ qt:"--",		qt2:"un melon",			name:"Melon "			}
		{ qt:"--",		qt2:"du maïs",			name:"Maïs "			}
		{ qt:"--",		qt2:"des cerises",		name:"Cerise "			}
		{ qt:"--",		qt2:"des sushis",		name:"Sushi "			}
		{ qt:"--",		qt2:"une tarte aux fruits",	name:"Tarte aux fruits"	}
		{ qt:"--",		qt2:"des Yakitori",		name:"Yakitori "		}
                                    

		
	]
	
	function setType(t){
		super.setType(t);
		id = Math.floor((type-300)/3)
		//inc = (type%5)+1;
	}	
		
	function new(){
		super();
		flUse = true;
		link = "itemFood"
	}
	
	function use(fi){
		super.use(fi)
		

		fi.eat(id)

		type++;
		var size = (type-300)%3
		
		if( size == 0 ){
			type = null
		}

		
	}	
	
	function getPic(dm,dp){
		var pic = super.getPic(dm,dp);
		

		var fr = Math.floor((type-300)/3)+1
		var frs = ((type-300)%3)+1
		pic.gotoAndStop(string(fr))
		downcast(pic).sub.gotoAndStop(string(frs))
		
		return pic;
	}

	function getName(){
		return NAME[id].name;
	}	
	
	function getDesc(){
		return "La nourriture permet à vos fées de rester en forme et de regagner leurs points de vie plus vite pendant la nuit."
	}
	
	function getQt(){
		return NAME[id].qt;
	}
	
	function getQt2(){
		return NAME[id].qt2;
	}

//{	
}


