package mt.gx.algo;

enum RuleResult {
	Success;
	CantDecide;
}

@:allow(mt.gx.algo.RuleFile)
class Rule<Ctx>{
	var perceive : Ctx -> Float;
	var operate : Ctx -> Void;
	var weight : Float;
	var enabled : Bool;
	
	public function new(p,o){
		weight = 0.0;
		perceive=p;
		operate=o;
		enabled=true;
	}
}

//ask rules for weight, individually, strips from enabled and 0 pointed then randoms one

class RuleFile<Ctx>{
	var mind : Array<mt.gx.algo.Rule<Ctx>>;
	var temp : List<mt.gx.algo.Rule<Ctx>>;
	
	public dynamic function rand(maxval) {
		return mt.gx.Dice.rollF( 0, maxval );
	}
	
	public function new( ){
		mind=[];
	}
	
	/**
	 * @param	p : functions that returns a wight according to the context
	 * returning 0 or less means the rule will not be used as a possible issue
	 * @param	o : function that operate this rule file
	 */
	public function addRule( p : Ctx -> Float,o : Ctx -> Void){
		mind.push( new Rule( p,o) );
	}
	
	public function tick( context : Ctx ){
		if(mind.length==0) return CantDecide;
		
		var s = 0.;
		var temp = new List();
		for ( m in mind ) {
			if (!m.enabled) continue;
			var p = m.perceive(context);
			m.weight = p;
			if ( p > 0.0 ){
				temp.add( m );
				s += p;
			}
		}
		
		var sr = rand(s);
		for ( p in temp ) {
			s -= p.weight;
			if ( s <= 0.0 ) {
				p.operate(context);
				return Success;
			}
		}
		
		return CantDecide;
	}
	
	public function enableRule(r:Rule<Ctx>, onOff : Bool ){
		r.enabled = onOff; 
	}
	
	
	
}
	