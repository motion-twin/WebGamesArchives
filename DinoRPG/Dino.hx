package db;
import mt.db.Types;
import db.SessionData.DinozSessionData;
import Data;
using mt.Std;
class Dino extends neko.db.Object {

	static function RELATIONS(): Array<Relation> {
		return [
			{ prop : "owner", key : "uid", manager : User.manager, lock : false, cascade : true },
			{ prop : "follow", key : "fid", manager : Dino.manager, lock : false },
			{ prop : "mission", key : "mid", manager : Mission.manager, lock : false },
		];
	}
	public static var manager = new DinoManager(Dino);

	public var id : SId;
	public var name : SNull<SString<16>>;
	public var date : SDateTime;
	public var uid(default,null) : SNull<SInt>;
	public var fid : SNull<SInt>;
	public var xp : SInt;
	public var level : SInt;
	public var life : SInt;
	public var maxLife : SInt;
	public var gfx(default,updateGfx) : SString<16>;
	private var gchk : SInt;
	public var pos(default,null) : SEncoded;
	public var action : SBool;
	public var gather : SBool;
	public var timer : SNull<SDateTime>;
	public var actionTimer : SDateTime;
	public var fire : SInt;
	public var wood : SInt;
	public var water : SInt;
	public var thunder : SInt;
	public var air : SInt;

	public var mid : SNull<SInt>;
	public var status : SNull<SEncoded>;

	public var owner(dynamic,dynamic) : User;
	public var follow(dynamic, dynamic) : SNull<Dino>;
	public var mission(dynamic,dynamic) : SNull<Mission>;
	public var friend : SNull<SEncoded>;
	
	public function new( family : data.Family ) {
		super();
		level = 1;
		date = Date.now();
		action = true;
		gather = true;
		xp = 0;
		maxLife = 100;
		life = maxLife;
		pos = Data.MAP.list.dnv.mid;
		gfx = UID.CHARS.charAt(family.gfx) + UID.CHARS.charAt(0) + UID.make(11) + UID.CHARS.charAt(0) + UID.CHARS.charAt(0) + UID.CHARS.charAt(0);
		setElements(family.elements);
		actionTimer = DateTools.delta(Date.now(), DateTools.minutes(30));
	}

	public function canAct() {
		return action && life > 0 && status == null && !isActionLocked();
	}

	public function isActionLocked() {
		return (level < Config.HACK_PROTECTION_LEVEL && xp >= nextLevelXP() && canLevelUp());
	}
	
	public dynamic function canHeal() { return true; }

	function updateGfx(g) {
		this.gfx = g;
		this.gchk = calculateCheckSum(this.gfx);
		return g;
	}

	public static function calculateCheckSum( gfx : String ) {
		var tot = 0;
		for( i in 0...gfx.length ) {
			var x = UID.CHARS.indexOf(gfx.charAt(i));
			x ^= ( x >> 3 ) & 0xB3FDC8;
			x = (x << 2) + x + (x & 0xFF);
			tot = ((tot * 5) ^ x) & 0xFFFFFFF;
		}
		return tot;
	}

	public function listPossibleMoves() {
		var m = getMap();
		var moves = new List();
		for( m in m.moves )
			if( Script.eval(this,m.cond) )
				moves.add(m.target);
		return moves;
	}

	public function canMoveTo( pos : data.Map ) {
		var nexts = listPossibleMoves();
		for( p in nexts )
			if( p == pos.mid )
				return true;
		return false;
	}

	public function canBeFollowed():Bool {
		return !hasSkill(Data.SKILLS.list.brave) || hasEquip(Data.OBJECTS.list.trouil);
	}
	
	public function canFollow( d: Dino ):Bool {
		if ( followers().length > 0 ) return false;
		if ( !d.canBeFollowed() ) return false;
		
		var isBrave = hasSkill(Data.SKILLS.list.brave);
		if ( isBrave ) {
			//un Dinoz brave normal ne peut rejoindre de groupe
			if ( isBrave && !hasEquip(Data.OBJECTS.list.trouil) ) return false;
			//mais équipé correctement, il a une chance
			var haveEltAffinity = false;
			var elts = getFamily().elements;
			var elts2 = d.getFamily().elements;
			for ( i in 0...Data.VOID ) {
				if ( elts[i] * elts2[i] > 0 ) {
					haveEltAffinity = true;
					break;
				}
			}
			return haveEltAffinity;
		} else {
			return true;
		}
	}
	
	public function followers() { return manager.search({ fid : id }, true); }

	public function getFriend():data.Monster {
		if( friend == null )
			return null;
		if( !Data.MONSTERS.existsId( friend ) )
			return null;
		return Data.MONSTERS.getId( friend );
	}
	
	public function group() {
		var group = new List();
		group.add(this);
		for( d in followers() )
			if( d.canAct() )
				group.add(d);
		return group;
	}

	public function moveTo( newpos : data.Map, ?stopFollow : Bool ) {
		pos = newpos.mid;
		if( stopFollow )
			fid = null;
		update();
		if( stopFollow ) {
			for( d in followers() ) {
				d.follow = null;
				d.update();
			}
		}
		if( owner != null )
			owner.incrVar(Data.USERVARS.list.moves);
	}

	public function getEvolution() { return UID.CHARS.indexOf(gfx.charAt(1)); }
	public function setEvolution( v : Int ) { gfx = gfx.charAt(0) + UID.CHARS.charAt(v) + gfx.substr(2); }
	
	public function getMaxLevel() {
		var level = Config.INITIAL_MAX_LEVEL;
		if( hasEffect( Data.EFFECTS.list.lvlup1 ) )
			level += 10;
		if( hasEffect( Data.EFFECTS.list.lvlup2 ) )
			level += 10;
		if( hasEffect( Data.EFFECTS.list.lvlup3 ) )
			level += 10;
		if( getFamily().id == Data.DINOZ.list.trice.id )
			level += 10;
		if( level > Config.ABSOLUTE_MAX_LEVEL )
			level = Config.ABSOLUTE_MAX_LEVEL;
		return level;
	}
	
	public function canLevelUp() { return level < getMaxLevel(); }
	
	public function levelUp( elt : Int ) {
		xp -= nextLevelXP();
		level++;
		var evo = getEvolution();
		if( evo < 9 ) {
			evo++;
			setEvolution(evo);
		}
		var elts = getElements();
		elts[elt]++;
		setElements(elts);
		owner.points++;
		owner.update();
		update();
		
		//reset our farming tracker
		if( id > 0 && owner != null && owner.twinId != null ) {
			db.DinoVar.setValue( this, Data.DINOVARS.list.farmer, 0 );
		}
		
		if( owner != null && owner.twinId != null ) {
			var V = Data.USERVARS.list;
			var uvar = [V.upfire, V.upwood, V.upwatr, V.upthun, V.upair][elt];
			owner.incrVar(uvar);
			owner.incrVar(V.lvlup);
		}
		
		var team = ClanTeam.manager.search( { did:id }, true).first();
		if( team != null ) {
			team.power = handler.CDC.getDinoPower(this);
			team.update();
		}
	}
	
	public function isInTeam() { return ClanTeam.manager.search( { did:id }, false).first() != null; }
	public function getOwner() : User { return owner; }
	public function setOwner( u, reset ) {
		var old = owner;
		// update dinoz
		owner = u;
		if( reset ) {
			life = maxLife;
			xp = 0;
		}
		follow = null;
		// update points
		if( old != null ) {
			old.ndinoz--;
			old.points -= this.level;
			old.update();
			if( old == App.user ) {
				for( dinf in App.session.dinoz ) {
					if( dinf.id == id ) {
						App.session.dinoz.remove(dinf);
						break;
					}
				}
				var dojo = old.getDojo();
				if( dojo != null && dojo.champion == this) {
					var tmp = old.listDinos().first();
					if( tmp != null ) {
						var dojo = db.Dojo.manager.get(dojo.id, true);
						dojo.champion = tmp;
						dojo.update();
					}
				}
			}
		}
		if( u != null ) {
			u.ndinoz++;
			u.points += this.level;
			u.update();
		}
		// stop follow
		if( id != null ) {
			var fl = manager.search({ fid : id }, true);
			for( d in fl ) {
				d.follow = null;
				d.update();
			}
		}
	}
	
	public function setElements( elts : Array<Int> ) {
		fire = elts[0];
		wood = elts[1];
		water = elts[2];
		thunder = elts[3];
		air = elts[4];
	}
	
	public function getElements() { return [fire, wood, water, thunder, air]; }
	
	public function getFamily() {
		return Data.DINOZ_FAMILY[UID.CHARS.indexOf(gfx.charAt(0))];
	}
	
	public function getEquip(?lock=false) {
		return db.Equip.manager.search({ did : id }, lock);
	}
	
	public function getEffects(?lock=false) {
		return db.Effect.manager.search({ did : id }, lock);
	}
	
	public function hasEffect( e : data.Effect ) {
		if( e.session ) {
			if( App.session.seffects != null )
				for( f in App.session.seffects )
					if( f.did == id && f.fx == e.eid )
						return true;
			return false;
		}
		return !db.Effect.manager.search({ did : id, eid : e.eid }, false).isEmpty();
	}
	
	public function removeEffect( e : data.Effect ) {
		if( e.session ) {
			if( App.session.seffects != null )
				for( f in App.session.seffects )
					if( f.did == id && f.fx == e.eid )
						return App.session.seffects.remove(f);
			return false;
		}
		var fx = db.Effect.manager.getWithKeys({ did : id, eid : e.eid }, false);
		if( fx == null )
			return false;
		fx.delete();
		return true;
	}
	
	public function addEffect( e : data.Effect ) {
		if( e.session ) {
			var l = App.session.seffects;
			if( l == null ) {
				l = new Array();
				App.session.seffects = l;
			}
			for( f in l )
				if( f.did == id && f.fx == e.eid )
					return false;
			l.push({ did : id, fx : e.eid });
			return true;
		}
		var fx = new Effect();
		fx.dino = this;
		fx.eid = e.eid;
		try fx.insert() catch(e:Dynamic) { return false; }
		return true;
	}
	
	public function hasDoneMission( m : data.Mission ) {
		return db.Mission.manager.count({ did : id, mid : m.mid, done : true }) > 0;
	}
	
	public function getEquipSize() {
		return Skills.calculateEquipSize(this);
	}
	
	public function getSkills():IntHash<db.Skill> {
		var h = new IntHash();
		for( s in Skill.manager.search({ did : id }, false) )
			h.set(s.sid, s);
		return h;
	}
	
	//can't use cache here, see how sphere's methods are learned !
	public function hasSkill( skill : data.Skill ) {
		return Skill.manager.getWithKeys( { did : this.id, sid:skill.sid } ) != null;
	}
	
	public function hasEquip( obj : data.Object ) {
		return Equip.manager.count({ did : id, oid : obj.oid }) > 0;
	}
	
	public function getMap() { return Data.MAP.getId(pos); }
	
	public function getStatus() { return if( status == null ) null else Data.STATUS.getId(status); }
	
	public function getCurrentView( ?m ) {
		return handler.PlaceActions.getCurrentView(this, if( m == null ) getMap() else m);
	}
	
	public function processDayElapsed() {
		if( life > 0 && Data.MAP.list.fountj.mid == pos && owner.hasCollection(Data.COLLECTION.list.perle) )
			life += 5;
		if( life > 0 && hasEquip(Data.OBJECTS.list.regen) )
			life += 10;
		if( status == Data.STATUS.list.decong.sid )
			status = null;
		
		var bal2 = Data.OBJECTS.list.mbala2.oid;
		for( e in getEquip() ) {
			if( e.oid == bal2 ) {
				var e = db.Equip.manager.get(e.id);
				e.oid = Data.OBJECTS.list.mbalan.oid;
				e.update();
			}
		}
		
		if( actionTimer == null ) {
			actionTimer = Date.now();
		}
		
		if( status == Data.STATUS.list.conva.sid && owner != null ) {
			// TODO Config.FREE_MODE
			action = false;
			gather = false;
			Object.add( R_Misc, Data.OBJECTS.list.irma, 1, owner );
		}
		
		if( Config.FREE_MODE )
			action = gather = true;
	}
	
	// LVL 1-10 = ~1200 XP TOTAL, next = ~190 XP
	// LVL 1-30 = ~9500 XP TOTAL, next = ~800 XP
	// LVL 1-50 = ~45000 XP TOTAL, next = ~3500 XP
	public function nextLevelXP() { return 	canLevelUp() ? computeNextLevelXP() : 0; }
	
	inline public function computeNextLevelXP() {
		return Std.int(100 * Math.pow(1.075, level-1));
	}
	
	inline public static function getLevelXP(level:Int) {
		return Std.int(100 * Math.pow(1.075, level-1));
	}
	
	public function updateHeal() {
		if( status != Data.STATUS.list.heal.sid )
			return false;
		var infos = Skills.calculateHealInfos(this);
		if( infos.life == 0 )
			return false;
		timer = Date.fromTime(timer.getTime() + Std.int(infos.hours) * 60.0 * 60.0 * 1000.0);
		life += infos.life;
		if( owner != null )
			owner.incrVar( Data.USERVARS.list.healpv, infos.life);
		return true;
	}
	
	// TEMPLATES
	public function get_elements() {
		var e = getElements();
		var einfs = new List();
		for( i in 0...e.length )
			einfs.add({
				inf : Data.ELEMENTS[i],
				value : e[i],
			});
		return einfs;
	}
	
	public function getSpecialEquip() {
		return getEquip().map(function(e) return Data.OBJECTS.getId(e.oid)).filter(function(o) return o.lock);
	}
	
	public function get_equip() {
		var a = getEquip().map(function(e) {
			return Data.OBJECTS.getId(e.oid);
		});
		for( i in a.length...getEquipSize() )
			a.add(null);
		return a;
	}
	
	public function get_effects() {
		return getEffects().map(function(e) {
			return Data.EFFECTS.getId(e.eid);
		});
	}
	
	public function get_skills() {
		var l = new Array();
		for( s in getSkills() )
			l.push( { inf : Data.SKILLS.getId(s.sid), s : s } );
		
		l.sort(function(s1,s2) {
			var s1 = s1.inf;
			var s2 = s2.inf;
			if( s1.elt == s2.elt )
				return s1.level - s2.level;
			return s1.elt - s2.elt;
		});
		return l;
	}
	
	public function get_family() { return getFamily(); }
	public function get_place() { return getCurrentView(); }
	public function get_zone() { return Data.ZONES[Data.MAP.getId(pos).zone]; }
	public function get_status() { return getStatus(); }
	
	public function get_mapData( move ) {
		var data = handler.PlaceActions.getMapData(this,move);
		return StringTools.urlEncode(haxe.Serializer.run(data));
	}
	
	public function get_data() {
		var s = new StringBuf();
		s.add("data=");
		s.add(gfx);
		s.add("&chk=");
		s.add(gchk);
		s.add("&damages=");
		var f = life / maxLife;
		s.add(if( f < .10 ) 2 else if( f < .50 ) 1 else 0);
		if( status != null ) {
			var st = getStatus();
			switch( st.id ) {
			case "congel":
				s.add("&status=");
				s.add(st.id);
			default:
			}
		}
		return s.toString();
	}

	// SESSION
	public function sessionInfos() : DinozSessionData {
		return {
			id : id,
			name : name,
			state : if( status != null ) true else if( life == 0 ) null else action,
			pos : pos,
			posName : getMap().name,
			zone : this.get_zone().id,
			status : this.status,
			follow : fid,
			gfx : gfx,
			gchk : gchk,
			life : if( status != null ) null else life / maxLife,
			xp : if( !canLevelUp() ) 0 else xp / nextLevelXP(),
			sort : date.getTime(),
			actionTimer : this.actionTimer,
		};
	}

	public override function delete() {
		super.delete();
		if( uid != null ) {
			var owner = db.User.manager.get(uid);
			owner.points -= this.level;
			owner.ndinoz--;
			owner.update();
			if( owner == App.user )
				for( dinf in App.session.dinoz )
					if( dinf.id == id ) {
						App.session.dinoz.remove(dinf);
						break;
					}
		}
	}

	public override function insert() {
		super.insert();
		var f = getFamily();
		if( f.skill != null ) {
			var s = new Skill();
			s.dino = this;
			s.sid = f.skill.sid;
			s.active = true;
			s.insert();
		}
		if( owner == App.user ) {
			if( App.session.dinoz == null ) App.session.dinoz = [];
			App.session.dinoz.push(sessionInfos());
			App.session.updated();
		}
	}

	public override function update() {
		if( life <= 0 )
			life = 0;
		else if( life >= maxLife )
			life = maxLife;
		if( level >= getMaxLevel() )
			xp = 0;
		super.update();
		if( owner == App.session.user ) {
			var dl = App.session.dinoz;
			for( i in 0...dl.length ) {
				if( dl[i].id == id ) {
					dl.splice(i,1);
					dl.insert(i,sessionInfos());
					App.session.updated();
					return;
				}
			}
			if( status != null && status == Data.STATUS.list.congel.sid )
				return;
			dl.push(sessionInfos());
			App.session.updated();
		}
	}

	public override function toString() {
		return "#"+id+" "+name;
	}
	
}
