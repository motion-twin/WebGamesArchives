package mt.deepnight.deprecated;

typedef Talent = {
	id		: String,
	name	: String,
	desc 	: String,
	icon	: Null<String>,

	lvl		: Int,
	max		: Null<Int>,
	req		: Null<String>,
}


class TalentTree {
	public static var DEFAULT_TALENT_MAX = 3; // points max par talent
	public static var STEP_REQ = DEFAULT_TALENT_MAX; // points pour descendre d'un palier

	public var talents		: Hash<Talent>;
	public var points		: Hash<Int>;
	public var startPoints	: Hash<Int>;
	public var limit		: Int;
	public var used			: Int;

	public function new(htalents:Hash<Talent>, hpoints:Hash<Int>, l:Int) {
		talents = htalents;
		points = hpoints;
		startPoints = new Hash();
		for( k in points.keys() )
			startPoints.set(k,points.get(k));
		limit = l;
		updateTotal();
	}
	
	public static function unserializePoints( s : String ) : Hash<Int>{
		if( s == "" )
			return new Hash();
		var c = new mt.BitCodec(s,true);
		var n = c.read(10);
		var h = new Hash();
		for( i in 0...n ){
			var t = mt.db.Id.decode((c.read(15)<<15)|c.read(15));
			h.set(t,c.read(4));
		}
		var crc = c.crcStr();
		if( crc != s.substr(-crc.length,crc.length) )
			throw "Invalid CRC";
		return h;
	}

	public static function serializePoints( h : Hash<Int> ) : String {
		var c = new mt.BitCodec(null,true);
		var n = 0;
		for( e in h )
			n++;
		c.write(10,n);
		for( k in h.keys() ){
			var i = mt.db.Id.encode(k);
			c.write(15,i>>15);
			c.write(15,i&0x7fff);
			c.write(4,h.get(k));
		}
		return c.toString()+c.crcStr();
	}

	function updateTotal() {
		var n = 0;
		for(p in points)
			n+=p;
		used = n;
	}

	public function changeTalent(t:Talent, newValue:Int) {
		if( isValid(t, newValue) ) {
			points.set(t.id, newValue);
			updateTotal();
			return true;
		}
		else
			return false;
	}

	public function getValue(t:Talent) {
		return if(points.exists(t.id)) points.get(t.id) else 0;
	}
	
	public function getValueRatio(t:Talent) : Float {
		return getValue(t) / (if (t.max==null) DEFAULT_TALENT_MAX else t.max);
	}


	public function isAvailable(t:Talent) {
		if ( t.lvl*STEP_REQ > used )
			return false;
			
		if (t.req != null ) {
			var req = talents.get(t.req);
			var max = if (req.max==null) DEFAULT_TALENT_MAX else req.max;
			if ( points.get(t.req)<max )
				return false;
		}
		
		return true;
	}
	
	public function isMaxed(t:Talent) {
		return getValueRatio(t)>=1;
	}

	public function isValid(?changed:Talent, ?newValue:Int) {
		// ne peut pas diminuer un talent en dessous de ce qu'il était à la dernière sauvegarde
		if( changed != null ){
			if( newValue < 0 || newValue == null )
				return false;

			var o = startPoints.get(changed.id);
			if( o != null && o > newValue )
				return false;
		}

		// copie + vérif des valeurs individuelles des talents
		var pcopy = new Hash();
		var total = 0;
		for(t in talents) {
			pcopy.set(t.id, if(t==changed) newValue else getValue(t));
			var v = pcopy.get(t.id);
			total+=v;
			if( v<0 || t.max!=null && v>t.max || t.max==null && v>DEFAULT_TALENT_MAX)
				return false;
			if ( v>0 && used<t.lvl*STEP_REQ )
				return false;
		}

		// trop de points
		if(total>limit)
			return false;

		// dépendances
		for(t in talents) {
			if( t.req!=null && pcopy.get(t.id)>0 ) {
				var parent = talents.get(t.req);
				if( pcopy.get(parent.id) < parent.max )
					return false;
			}
		}
		
		// talents qui n'existent plus
		for (key in points.keys())
			if (!talents.exists(key))
				return false;
			

		// paliers
		if ( changed!=null && used<changed.lvl*STEP_REQ )
			return false;

		return true;
	}
}



