import Data;
import mt.bumdum.Lib;

typedef Glad = {

	keep:Float,
	ct:Float,
	flKeep:Bool,
	status:Array<Bool>,

	flBallerina:Bool,
	retryAttack:Bool,
	counter:Bool,
	timeLimit:Float,
	sabotage:Weap,

	gl:Gladiator,
	wp:Weap,
	life:Int,
	init:Float,
	weapons:Array<Weap>,
	supers:Array<Sup>,
	team:Int,
	lifeLog:Array<Int>

}

typedef Team = {
	prop:TeamProperty,
	stats:Array<Int>,

}
enum TeamStat {
	DODGE;
	PARADE;
	DISARM;
	RIPOSTE;
	COUNTER;
	FOL_FRAG;
	DAMAGE_MAX;
	STRIKE;
	MISSILE_LIGHT;
	//MISSILE_HEAVY;
}

class Arena{//}

	var baseSeed:Int;
	public var teamWin:Int;
	var currentInit:Float;
	var idr:Int;
	var seed:mt.Rand;

	var teams:Array<Team>;
	public var achievements:Array<Array<String>>; // 6chars : a-z 1-6
	public var glads:Array<Glad>;
	public var cadavers:Array<Glad>;
	public var history:Array<_Action>;
	public var handicap:Array<Int>;

	public function new(baseSeed:Int){
		this.baseSeed = baseSeed;
		handicap = [0,0];
		achievements = [[],[]];
		init();
	}
	public function init() {
		seed = new mt.Rand(baseSeed);
		idr = 0;
		glads = [];
		cadavers = [];
		history = [];
		teams = [];
		for( i in 0...2 ) teams.push(getBlankTeam());

	}
	function getBlankTeam (){
		var stats = [];
		var max = Type.getEnumConstructs( TeamStat ).length;
		for( i in 0...max ) stats.push(0);

		return {
			prop : {
				_poi:null,
				_sab:null,
				_st:null,
			},
			stats:stats,

		}
	}

	public function noHistory() {
		history = null;
	}

	inline function hist(h) {
		if( history != null ) history.push(h);
	}

	// PUBLIC
	public function addGladiator( id, team, skin, level, levels, name, inter=true  ){
		var gl = new Gladiator(id,name);
		gl.setLevels(level,levels);
		var gl = addGlad(gl,team);

		//if( teams[gl.team].sabotage ) gl.sabotage = gl.weapons[seed.random(gl.weapons.length)];

		hist( AddFighter( id, team, skin, level, levels, name, inter )  );
		return gl;
	}
	public function setTeamProperty( teamId, property ){
		teams[teamId].prop = property;
	}

	function addFollower( id, team, ft:_Followers){
		var gl = new Gladiator(id,null,ft);
		addGlad(gl,team);
		hist( AddFollower( id, team, ft )  );
	}
	function addGlad(gl:Gladiator,team){

		var a = [];
		var b = [];
		for( w in gl.weapons ) a.push( Data.WEAPONS[Type.enumIndex(w)] );
		for( s in gl.supers) b.push( Reflect.copy( Data.SUPERS[Type.enumIndex(s)] ) );

		var o:Glad = {
			flKeep:false,
			retryAttack:false,
			counter:false,
			timeLimit:null,
			sabotage:null,
			flBallerina:gl.flBallerina,
			status:[],
			keep:0.0,
			ct:0.25+(20/(10+gl.speed))*0.75,
			gl:gl,
			wp:Data.WEAPONS[Type.enumIndex(gl.defaultWeapon)],
			life:gl.getLife(),
			init:gl.startInit + seed.rand()*10,
			weapons:a,
			supers:b,
			team:team,
			lifeLog:[]
		}
		/*
		// FOLLOWER : INIT PENALTY
		if( o.gl.fol != null ){
			o.init += 10+o.life*2;
		}
		// WARM BLOOD : INIT BONUS
		//if( gl.flWarmBlooded )o.init -= 100;
		*/

		//
		glads.push(o);
		return o;
	}
	function initFollowers(){
		for( g in glads ){
			for( f in g.gl.followers ){
				addFollower( idr++, g.team, f );
			}
		}
	}

	// FIGHTER
	public function fight(){

		initFollowers();


		for( gl in glads  ){
			// HANDICAP
			gl.init += handicap[gl.team];
			// SABOTAGE
			if( gl.gl.fol == null && teams[gl.team].prop._sab && gl.weapons.length > 0 ) {
				gl.sabotage = gl.weapons[seed.random(gl.weapons.length)];
			}
		}


		//var inits = "";
		for( i in 0...1000 ){
			sortGlads();
			currentInit = glads[0].init;
			//inits += Std.int(currentInit)+";";
			action(glads[0]);
			checkDeaths();
			if(teamWin!=null){
				endFight();
				break;
			}
		}
		//trace(inits);


	}
	function endFight(){
		hist( EndFight(teamWin) );

		// PERFECT
		var gl = getMainGlad(teamWin);
		if( gl.life == gl.gl.getLife() ) achievements[teamWin].push("perfec");

		//trace("_____");
		//trace("_____");
		var a = Type.getEnumConstructs( TeamStat );
		for( i in 0...2 ){
			var stats = teams[i].stats;
			var ach = achievements[i];
			//trace(teams[i].stats);
			for( k in 0...stats.length ){
				var st = Type.createEnum(TeamStat,a[k]);//Type.getEnum( a[k] );
				var value = stats[k];
				switch(st){
					case DODGE :			if( value >= 10 ) 	ach.push("dodge");
					case PARADE :			if( value >= 20 ) 	ach.push("parade");
					case DISARM :			if( value >= 8 ) 	ach.push("disarm");
					case RIPOSTE :			if( value >= 8 ) 	ach.push("ripost");
					case COUNTER :			if( value >= 5 ) 	ach.push("countr");
					case FOL_FRAG :			if( value >= 3 ) 	ach.push("folfra");
					case DAMAGE_MAX :		if( value >= 50 ) 	ach.push("barbar");
											if( value >= 100 ) 	ach.push("brute");
					case STRIKE :			if( value >= 20 ) 	ach.push("tornad");
					case MISSILE_LIGHT :	if( value >= 20 ) 	ach.push("dca");
					//case MISSILE_HEAVY :	if( value >= 8 ) 	ach.push("bombar");
				}
			}
		}


	}

	function sortGlads(){
		var f = function(a:Glad,b){
			if(a.init<b.init)return -1;
			return 1;
		}
		glads.sort(f);
	}
	function action(glad:Glad){
		//trace(currentInit);

		// CHECK LEAVE
		if( glad.timeLimit != null ){
			//trace("lifetime : "+Std.int(glad.timeLimit)+";"+Std.int(currentInit));
			if( currentInit > glad.timeLimit ){
				glads.remove(glad);
				glads.remove(glad);
				hist( Leave(glad.gl.id) );
				return;
			}
		}

		// CHECK SUPPORT
		var o = teams[glad.team].prop._st;
		if( o!=null && seed.rand() < 1-glad.life/glad.gl.getLife() ){
			teams[glad.team].prop._st = null;
			var gl = addGladiator( o._s, glad.team, o._gfx, o._lvl, o._bits, "support", false );
			gl.timeLimit = currentInit + 280;
			gl.init += currentInit;
			glad.init += 100;
			return;
		}


		// CHECK SUPER
		var sup = drawSuper(glad,10);
		if(sup!=null){
			if( useSuper(sup,glad) ) return;
		}

		// DRAW WEAPON
		if( holdWeapon(glad) ) glad.flKeep = true;
		var nwp = drawWeapon(glad,10);
		if( seed.rand() < glad.keep ){
			glad.keep *= 0.5;
			nwp = null;
		}
		if( nwp != null && nwp != glad.wp ){
			glad.flKeep = false;
			if( holdWeapon(glad) )trashWeapon(glad);
			glad.wp = nwp;
			glad.keep = 0.5;
			var sab = glad.wp == glad.sabotage;
			hist( Weapon(glad.gl.id,glad.wp.id,sab) );
			if( sab ){
				glad.weapons.remove(glad.wp);
				glad.wp = Data.WEAPONS[Type.enumIndex(glad.gl.defaultWeapon)];
				glad.init += 100;
				glad.sabotage = null;
				return;
			}
		}

		var type = glad.wp.type;
		if( glad.wp.type == Brawl && glad.flKeep && holdWeapon(glad) && seed.random(glad.wp.deg)==0 ){
			type = Throw;
		}


		// ATTAQUE
		switch( type ){
			case Brawl:

				var def = getOpponent(glad);
				hist(MoveTo(glad.gl.id,def.gl.id,0));

				if( def.status[1]!=true && testCounter(glad,def) ){
					st(def,COUNTER);
					attack(def,glad);

				} else {
					attacks(glad,def);
				}

				if(glad.life>=0)hist(MoveBack(glad.gl.id));

			case Throw:
				var def = getOpponent(glad);
				throwAttack(glad,def);

			default :
		}

		// POISON
		if( teams[glad.team].prop._poi && isAlive(1-glad.team) ){
			var damage = Math.ceil(glad.gl.getLife()/50);
			hit(glad,damage);
			hist(Poison(glad.gl.id,damage) );
		}


		var tp = glad.wp.tempo*glad.ct + seed.random(10);
		if( glad.gl.flHeavyArms && glad.wp.dt == 4 )tp*=0.75;

		glad.init += tp ;

		// CHECK STRIKER END ACTION
		if( glad.timeLimit!=null && glad.init >= glad.timeLimit ){
			glad.init = currentInit;
			glad.timeLimit = 0;
		}


		if( glad.status[0] )setStatus(glad,0,false);
	}

	// BRAWL
	function attacks(att:Glad,def:Glad){

		var flRipose = def.status[1]!=true;

		attack(att,def);

		var combo:Float = ( att.gl.combo + att.wp.combo + att.gl.agility ) * 0.01;

		while( seed.rand() < combo || att.retryAttack ){
			if( def.counter ) break;
			combo *= 0.5;
			att.retryAttack = false;
			attack(att,def);
		}
		checkDeaths();
		if( flRipose && testRiposte(att,def) ){
			st( att, RIPOSTE );
			attack(def,att);
		}

	}
	function attack(att:Glad,def:Glad){

		if(att.life<=0)return;

		var damage = getBrawlDamage(att,def)  ;


		if( testParade(att,def) ){
			damage = 0;
			st(def,PARADE);
			if( def.gl.flCounter )def.counter = true;
		}
		if( testEsquive(att,def) ){
			damage = -1;
			st(def,DODGE);
		}


		var sab = null;
		var dis = false;
		var disShield = false;
		if( damage>=0 && def.gl.shieldLevel>0 && att.gl.disarm+att.wp.dis > seed.random(300) ){
			st(att,DISARM);
			disShield = true;
			def.gl.shieldLevel = 0;
			def.gl.parry -= Gladiator.SHIELD_VALUE;
		}


		if( damage > 0 ){

			// VANDALISM
			if( att.gl.flVandalism ){

				var a = [];
				for( w in def.weapons )if(w.id!=def.wp.id)a.push(w);

				if( a.length > 0 ){
					var w = a[seed.random(a.length)];
					def.weapons.remove(w);
					sab = w.id;
				}

			}

			// DISARM
			if( holdWeapon(def) && att.gl.disarm+att.wp.dis > seed.random(100) ){
				st(att,DISARM);
				dis = true;
				def.weapons.remove(def.wp);
				def.wp = Data.WEAPONS[Type.enumIndex(def.gl.defaultWeapon)];
			}

		}

		// DISARM ATTACKER
		var disAtt = damage >= 0 && def.gl.flIronHead && holdWeapon(att) && seed.rand() < 0.3;
		if( disAtt ){
			st(def,DISARM);
			att.weapons.remove(att.wp);
			att.wp = Data.WEAPONS[0];
		}

		if( damage > 0 ){
			damage = hit(def,damage);
			st(att,STRIKE);
			stDamMax(att,damage);
		}
		hist( Attack( att.gl.id, def.gl.id, damage, sab, dis, disShield, disAtt ) );


		if( damage <= 0 && att.gl.flStayer && seed.rand() < 0.7 ) {
			att.retryAttack = true;
		}


	}
	function throwAttack(att:Glad,def:Glad){
		var damage = getThrowDamage(att);


		if( testParade(att,def,10)  ){
			damage = 0;
		}
		if( testEsquive(att,def,2) ){
			damage = -1;
		}



		if( damage > 0 ){
			damage = hit(def,damage);
			st(att,STRIKE);
			stDamMax(att,damage);
		}
		hist( ThrowAttack( att.gl.id, def.gl.id, damage ) );

		if( att.wp.type != Throw ){
			att.weapons.remove(att.wp);
			att.wp = Data.WEAPONS[0];
			//st(att,MISSILE_HEAVY);
		}else{
			st(att,MISSILE_LIGHT);
		}

		checkDeaths();


	}

	function testCounter(att:Glad,def:Glad){
		return seed.rand() < ( def.gl.counter+(def.wp.zone-att.wp.zone) )*0.1;
	}
	function testParade(att:Glad,def:Glad,?c:Float){
		if(def.status[1])return false;
		if(c!=0)c=1;
		var n  = def.gl.parry + def.wp.par - att.wp.per ;
		return seed.rand()*c <  n*0.01;
	}
	function testEsquive(att:Glad,def:Glad,?c:Float){
		if(def.status[1])return false;
		if(c!=0)c=1;

		// BALLERINE
		if(def.flBallerina){
			//trace('esquive!');
			def.flBallerina = false;
			return true;
		}

		var agg = Num.mm( -40, (def.gl.agility-att.gl.agility)*2, 40 );
		var n  = Math.min( def.gl.dodge + def.wp.dod + agg - (att.gl.accuracy+att.wp.rap), 90 ) ;
		return seed.rand()*c <  n*0.01;
		return false;
	}
	function testRiposte(att:Glad,def:Glad){
		if( def.counter ){
			//trace("ripost");
			def.counter = false;
			return true;
		}
		var n  = def.gl.riposte + def.wp.rip ;
		return seed.rand() <  n*0.01;
	}

	// INC_STAT
	function st( gl:Glad, n:TeamStat ) {
		if( gl.gl.fol != null ) return;
		teams[gl.team].stats[Type.enumIndex(n)]++;
	}
	function tst( team, n:TeamStat ) {
		teams[team].stats[Type.enumIndex(n)]++;
	}
	function stDamMax(gl:Glad, dam:Int ){
		if( gl.gl.fol != null ) return;
		var stats = teams[gl.team].stats;
		if( dam > stats[Type.enumIndex(DAMAGE_MAX)] ) stats[Type.enumIndex(DAMAGE_MAX)] = dam;
	}

	// SUPER
	function useSuper(s:Sup,glad:Glad){

		var opp = getOpponent(glad);

		switch(s.id){
			case THIEF:
				if( opp.wp.id != opp.gl.defaultWeapon ){
					if(glad.wp.id != glad.gl.defaultWeapon ){
						if(seed.random(4)==0) trashWeapon(glad); else return false;
					}
				}else{
					return false;
				}
				opp.weapons.remove(opp.wp);
				glad.wp = opp.wp;
				glad.keep = 1;
				glad.weapons.push(glad.wp);
				opp.wp = Data.WEAPONS[0];
				hist( Steal( glad.gl.id, opp.gl.id )  );
				opp.init += 30+opp.ct;


			case BRUTE:
				if(glad.status[0])return false;
				setStatus(glad,0,true);

			case NET:

				var opp2 = getOpponent(glad,true);
				if(opp2!=null)opp = opp2;


				hist( Net( glad.gl.id, opp.gl.id )  );
				setStatus(opp,1,true);

				if( opp.gl.fol == null ){
					opp.init += Std.int( Math.max(260 - Math.pow(opp.gl.force,0.5)*10, 50) );
				}else{
					opp.init += 100000;
				}
				glad.init += 20*glad.ct;



			case MEDECINE:
				var damage = glad.gl.getLife()-glad.life;
				if( damage < 50 ) return false;
				var life = Std.int(damage*(0.25+seed.rand()*0.25));
				hist( Medecine( glad.gl.id, life )  );
				glad.life += life;
				glad.init += 15;
				teams[glad.team].prop._poi = false;

			case BOMB:
				var damage = 15+seed.random(10);

				for( opp in glads ){
					if(opp.team!=glad.team){
						damage = hit(opp,damage);
					}
				}
				hist( Bomb( glad.gl.id, damage )  );
				checkDeaths();
				glad.init += 50*glad.ct;

			case GRAB:


				if( glad.wp.id != glad.gl.defaultWeapon){
					if(seed.random(4)==0)trashWeapon(glad); else return false;
				}
				var damage = getGrabDamage(glad,opp)*4;
				damage = hit( opp, damage );
				hist( Grab( glad.gl.id, opp.gl.id, damage )  );
				checkDeaths();
				glad.init += 100*glad.ct;

			case SHOUT:
				var a = [];
				var b = [];
				for( g in glads )if( g.gl.fol!=null && g.team!=glad.team && g.status[1] != true )a.push(g);
				if( a.length == 0 ) return false;
				for( g in a ){
					if( seed.random(2)==0 ){
						glads.remove(g);
						b.push(g.gl.id);
					}
				}
				if( b.length == 0 ) return false;
				hist(  Escape(glad.gl.id,b) );

			case HYPNO:

				var a = [];
				for( g in glads )if( g.gl.fol!=null && g.team!=glad.team && g.status[1] != true ){
					g.team = 1-g.team;
					a.push(g.gl.id);
				}
				if( a.length == 0 ) return false;
				hist(  Hypno(glad.gl.id,a) );

			case DOWNPOUR:
				if( glad.weapons.length>2 ){

					var def = getOpponent(glad,false);

					var b = [];
					var max = Std.int(b.length*0.5);
					for( w in glad.weapons )b.push(w);
					b.remove( glad.wp );
					var max = glad.weapons.length*0.5;
					while( b.length > max )b.splice(seed.random(b.length),1);

					var wps = [];
					for( w in b ){
						wps.push(w.id);
						glad.weapons.remove(w);
					}

					var damages = [];
					for( wp in b ){
						var damage = Std.int( ( wp.deg + glad.gl.force*0.1 + glad.gl.agility*0.15 ) * (1+seed.rand()*0.5) );
						damage -= def.gl.armor;
						if( damage < 1 ) damage = 1;
						damage = hit(def,damage);
						damages.push(damage);
					}

					hist(  Downpour(glad.gl.id,wps,damages) );
					checkDeaths();
					glad.init += 200*glad.ct;

				}

			case TRAPPER :
				var lifeMax = glad.gl.getLife();
				if( glad.life+20 < lifeMax && cadavers.length > 0 ){
					var cad = cadavers.pop();
					var c = 0.0;
					switch( cad.gl.fol ){
						case DOG_0, DOG_1, DOG_2 :		c = 0.2;
						case PANTHER :					c = 0.3;
						case BEAR : 					c = 0.5;
					}
					var heal = Std.int(c*lifeMax);
					if( glad.life+heal > lifeMax ) heal = lifeMax - glad.life;
					glad.life += heal;
					glad.init += 15;

					hist( MoveTo(glad.gl.id,cad.gl.id,-20) );
					hist( Eat( glad.gl.id, heal, cad.gl.id )  );
					hist( MoveBack(glad.gl.id) );

				}



		}

		s.use--;
		if( s.use == 0 ){
			for( o in glad.supers ){
				if(o.id == s.id ){
					glad.supers.remove(o);
					break;
				}
			}

		}


		return true;

	}

	// CHECK DEATH
	function checkDeaths(){
		var list= glads.copy();
		for( g in list ){
			if(g.life<=0){

				hist( Death( g.gl.id ) );

				if(g.gl.fol!=null){
					tst(1-g.team,FOL_FRAG);
					cadavers.push(g);
					glads.remove(g);
				}

				if( g.gl.fol == null ){
					if( g.timeLimit != null ){
						g.timeLimit = 0;
					}else{
						teamWin = 1-g.team;
					}
				}
			}
		}
	}


	// GLAD
	function drawWeapon(glad:Glad,sup){
		if( holdWeapon(glad) && seed.random(glad.weapons.length*2)==0 )return null;

		var sum = 0;
		for( o in glad.weapons )sum += o.toss;
		var rnd = seed.random(sum+sup);
		var sum = 0;
		for( o in glad.weapons ){
			sum += o.toss;
			if(sum>=rnd){
				return o;
			}
		}
		return null;
	}
	function trashWeapon(glad:Glad){
		glad.weapons.remove(glad.wp);
		hist( Trash(glad.gl.id) );
		glad.wp = Data.WEAPONS[Type.enumIndex(glad.gl.defaultWeapon)];
	}
	function drawSuper(glad:Glad,sup){

		var sum = 0;
		for( o in glad.supers )sum += o.toss;
		var rnd = seed.random(sum+sup);
		var sum = 0;
		for( o in glad.supers ){
			sum += o.toss;
			if(sum>=rnd){
				return o;
			}
		}
		return null;
	}
	function hit(glad:Glad,damage){
		if(glad.status[1])removeNet(glad);

		if( glad.gl.flIncrevable ){
			var max = Math.round(glad.gl.getLife()/5);
			if( damage > max ){
				damage = max;
				hist( FxResistDamage(glad.gl.id) );
			}
		}

		if( glad.timeLimit != null )	glad.timeLimit -= damage*5;
		else							glad.life -= damage;

		if( glad.gl.flSurvival && glad.life<=0 ){
			glad.gl.flSurvival = false;
			glad.life =1;

		}

		glad.lifeLog.push(damage);
		return damage;
	}

	function setStatus(glad:Glad,sid,flag){
		glad.status[sid] = flag;
		hist( Status(glad.gl.id,sid,flag) );

	}
	function removeNet(glad:Glad){
		setStatus(glad,1,false);
		glad.init = currentInit+50;
	}

	// TOOLS
	function getTeam(team,?flFol){
		var a = [];
		for( glad in glads ){
			if(glad.team==team ){
				if( flFol==null || ( flFol && glad.gl.fol!=null ) || ( !flFol && glad.gl.fol==null ) )a.push(glad);
			}
		}
		return a;
	}
	function getOpponent(glad:Glad,?flFol){
		var a = getTeam(1-glad.team,flFol);

		if( a.length>1 ){
			for( opp in a ){
				if(opp.status[1]==true){
					a.remove(opp);
					break;
				};

			}
		}
		if(a.length==0)return null;
		return a[seed.random(a.length)];
	}

	function getBrawlDamage(att:Glad,def:Glad){

		var coef = 0.2 + att.wp.deg*0.05;
		var damage =  (att.wp.deg + att.gl.force*coef)*(0.8+seed.rand()*0.4) ;
		if( att.status[0] )damage*=2;
		damage *= att.gl.damageCoef[att.wp.dt];

		if( def!=null ){
			if( def.gl.flLeadBones && att.wp.dt == 4 ) damage *= 0.7;
			damage -= def.gl.armor;
		}
		if(damage<=1)damage = 1;




		return Std.int(damage);



	}
	function getThrowDamage(att:Glad,?def:Glad){
		var damage = Std.int( ( att.wp.deg + att.gl.force*0.1 + att.gl.agility*0.15 ) * (1+seed.rand()*0.5) );
		if( def!=null ) damage -= def.gl.armor;
		if(damage<=1)damage = 1;
		return damage;
	}
	function getGrabDamage(att:Glad,def:Glad){
		var damage = Std.int( ( 10 + att.gl.force*0.6 ) * (0.8+seed.rand()*0.4) );
		if( att.status[0] )damage*=2;
		if( def!=null ) damage -= def.gl.armor;
		if(damage<=1)damage = 1;
		return damage;
	}
	function holdWeapon(glad:Glad){
		return glad.wp.id != glad.gl.defaultWeapon;
	}


	function isAlive(team){
		return getMainGlad(team).life > 0;
	}
	function getMainGlad(team){
		for( gl in glads ) if( gl.team == team && gl.gl.fol == null && gl.timeLimit == null ) return gl;
		return null;
	}




//{
}



