package fight;
import data.Skill;

class FakeDino extends db.Dino {

	static var __rtti = null;

	public var skills(default,null) : IntHash<db.Skill>;
	public var effects(default,null) : List<db.Effect>;
	public var equip(default,null) : List<db.Equip>;
	public var strategy : Bool;

	public function new( fam ) {
		skills = new IntHash();
		effects = new List();
		equip = new List();
		super(fam);
		id = -1;
		xp = 0;
		var me = this;
		var o = {
			money : 0,
			points : 0,
			update : function() { },
			hasOneSkill : function(s : data.Skill) { return me.skills.exists(s.sid); },
			winMoney : null,
			incrVar: function(u:data.UserVar, ?incr = 1, ?twinoid=true) { },
		};
		o.winMoney = function(m) {
			o.money += m;
		};
		owner = cast o;
		if( fam.skill != null )
			doLearn(fam.skill);
	}

	public function doLearn( skill : data.Skill ) {
		var s = new db.Skill();
		s.sid = skill.sid;
		s.dino = this;
		if( strategy && skill.type == SAttack && getFamily().levelup[skill.elt] < 100 )
			s.active = false;
		else
			s.active = skill != Data.SKILLS.list.kamikz;
		s.unlocked = false;
		
		skills.set(s.sid,s);
	}

	public function create(user:db.User) {		
		var d = new db.Dino(getFamily());
		d.owner = user;
		d.setElements(getElements());
		d.level = level;
		d.life = life;
		d.maxLife = maxLife;
		d.gfx = gfx;
		d.xp = xp;
		d.gchk = gchk;
		d.insert();
		
		var d = db.Dino.manager.get(d.id, true);
		for( s in skills ) {
			var sk = new db.Skill();
			sk.did = d.id;
			sk.sid = s.sid;
			sk.active = s.active;
			sk.unlocked = s.unlocked;
			try sk.insert() catch(e:Dynamic) {};
		}
		d.update();
		return d;
	}
	
	public function unlock(elt) {
		var inf = Skills.getLevelupInfos(this, elt);
		for( s in inf.skills ) {
			if( s.unlocked )
				continue;
			var sinf = Data.SKILLS.getId(s.sid);
			if( sinf.elt != inf.elt && sinf.elt2 != inf.elt && sinf.elt3 != inf.elt )
				continue;
			skills.get(s.sid).unlocked = true;
		}
		// additionally, unlock all dependencies that have not been previously unlocked
		for( s in inf.unlock ) {
			for( rid in s.require ) {
				var s = skills.get(s.sid);
				if( s == null || s.unlocked )
					continue;
				skills.get(s.sid).unlocked = true;
			}
		}
	}
	
	public function doLevelUp( learn, rnd, ?elt ) {
		var inf = Skills.getLevelupInfos(this, elt);
		if( inf == null )
			throw "No more skills to learn";
		levelUp(inf.elt);
		if( !learn ) 
			return null;
		
		if( inf.learn.length == 0 ) {
			for( s in skills ) {
				if( Data.SKILLS.getId(s.sid).elt != inf.elt )
					continue;
				s.unlocked = true;
			}
			return null;
		}
		
		var found = inf.learn[rnd(inf.learn.length)];
		Skills.learn(this,found);
		doLearn(found);
		return found;
	}
	
	public override function followers() {
		return new List();
	}

	public override function getSkills() {
		return skills;
	}
	
	public override function hasSkill( s : data.Skill ) {
		return skills.exists(s.sid);
	}

	public override function getEquip(?lock) {
		return equip;
	}
	
	public override function getEffects(?lock) {
		return effects;
	}

	public override function hasEffect( e : data.Effect ) {
		for( f in effects )
			if( f.eid == e.eid )
				return true;
		return false;
	}

	public override function hasEquip( obj : data.Object ) {
		for( e in equip )
			if( e.oid == obj.oid )
				return true;
		return false;
	}

	public override function removeEffect( e : data.Effect ) {
		for( f in effects )
			if( f.eid == e.eid )
				return effects.remove(f);
		return false;
	}

	public override function addEffect( e : data.Effect ) {
		for( f in effects )
			if( f.eid == e.eid )
				return false;
		var fx = new db.Effect();
		fx.dino = this;
		fx.eid = e.eid;
		effects.add(fx);
		return true;
	}

	public override function hasDoneMission( m : data.Mission ) {
		return false;
	}

	public override function insert() {
	}

	public override function update() {
	}

	public override function delete() {
	}

	public override function sync() {
	}

}