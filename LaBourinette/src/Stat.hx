enum KStat {
	DefPass; // x passe
	DefSave; // x picosafe
	DefPush; // x poussade
	DefAttack; // x attaque
	AttPaf; // x picopaf
	AttPush; // x poussade
	AttAttack; // x attaque
	ThrPrecision; // x précision de lancer
	ThrStrike; // x batteur battu
	BatTouch; // x batteur touche la balle
	BatField; // x batteur renvoie la balle correctement
	BatStar; // x batteur renvoie la balle en picostar
	GenFault; // faute effectuées non sifflées
}

class Stat {

	public var data : IntHash<{n:Int, v:Int, pn:Int, pv:Int}>;

	public function new(?h){
		data = h != null ? h : new IntHash();
	}

	public function count(k:KStat){
		get(k).n++;
	}

	public function success(k:KStat){
		var r = get(k);
		r.v++;
		if (r.n < r.v)
			r.n++;
	}

	public function concat(s){
		var me = this;
		tools.EnumTools.foreach(
			KStat,
			function(v){
				var its = s.get(v);
				var mine = me.get(v);
				mine.n += its.n;
				mine.v += its.v;
				if (mine.n < mine.v)
					mine.n = mine.v;
				mine.pn = its.n;
				mine.pv = its.v;
				if (mine.pn < mine.pv)
					mine.pn = mine.pv;
			}
		);
	}

	public static function sum(l:List<Stat>) : Stat {
		var result = new Stat();
		for (r in l)
			result.concat(r);
		return result;
	}

	public function get(k:KStat){
		var i = tools.EnumTools.indexOf(k);
		var s = data.get(i);
		if (s == null){
			s = { n:0, v:0, pn:0, pv:0 };
			data.set(i, s);
		}
		return s;
	}

	#if neko
	public function groups(){
		var list = new List();
		var me = this;
		tools.EnumTools.foreach(KStat, function(k){
			var v = me.get(k);
			v.n = sanitize(v.n);
			v.v = sanitize(v.v);
			v.pn = sanitize(v.pn);
			v.pv = sanitize(v.pv);
			if (v.n < v.v) v.n = v.v;
			if (v.pn < v.pv) v.pn = v.pv;
			list.add({
				k:k,
					label:Text.getText(Std.string(k)),
					n:v.n,
					v:v.v,
					pn:sanitize(v.pn),
					pv:sanitize(v.pv)
					});
		});
		var groups = tools.LambdaTools.group(list, function(v) return Std.string(v.k).substr(0,3));
		var result = new List();
		for (k in ["Gen","Thr","Def","Att","Bat"])
			result.add(
				{ k:k, label:Text.getText("Label"+k), stats:groups.get(k) }
			);
		return result;
	}

	static inline function sanitize(v:Int):Int{
		return v == null ? 0 : v;
	}
	#end
}