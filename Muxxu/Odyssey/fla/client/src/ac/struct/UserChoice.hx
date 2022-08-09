package ac.struct;
import Protocole;
import mt.bumdum9.Lib;
import mt.bumdum9.Rush;



class UserChoice extends ac.Action {//}
	
	
	
	override function init() {
		super.init();
		
		activate();
	}
	
	function activate() {
		
		game.activate(this);
		step = 0;
		
		// CHECK PLAYABLE
		var playable = false;
		for ( h in game.heroes ) {
			h.board.unfreeze = 0;
			for ( b in h.board.balls ) {
				if ( !b.grey ) {
					playable = true;
					break;
				}
			}
		}
		if ( !playable ) {
			for ( h in game.heroes ) new fx.NotPlayable(h.board);
			nextStep();
		}
	}

	override function update() {
		super.update();
		switch(step) {
			case 0 :
				if( Game.me.waitRefill ) {
					var e = new ac.Refill();
					e.onFinish = activate;
					add(e);
				}
				
			case 1 : // NOT PLAYABLE ;
				if ( timer > 60 ) {
					tick();
					kill();
				}
		}
		
	}
	
	public function tick() {
		for ( h in game.heroes ) h.onPlayTurn();
		game.deactivate();
	}
	
	public function select(board:Board, b:Ball) {
		
		var hero = board.hero;
		var gen = [];
		
		if ( b.type == HEAL && hero.have(ALCHEMY) ) 										gen.push(MECHA_CRYSTAL);
		if ( hero.have(WAKIZASHI) && b.isSword() && b.group.list.length >= 3 )				gen.push(SWORD);
		if ( b.type == MECHA_CRYSTAL && hero.have(FLUX_CONTROL) ) 							gen.push(MEDITATE);
		if ( b.group.list.length >= 3 && hero.have(SPECIAL_RECIPE) ) 						gen.push(HEAL);
		if ( b.isJar() && b.group.list.length == 1 && hero.have(SURPRISE) ) 				gen.push([SHIELD,SWORD,MECHA_CRYSTAL][Std.random(3)]);
		if ( b.type == HEAL && hero.have(DEPOSIT) ) 										gen.push(JAR);
		if ( b.type == FRENZY && hero.have(CHAMP_AT_THE_BIT) ) 								gen = gen.concat([SWORD,SWORD]);
		if ( Ball.isAttack(b.type) && b.group.list.length <= 2 && hero.have(PARADE) ) 		gen.push(SHIELD);
		if ( b.group.list.length >= 3 && hero.haveBall(MECHA_CYCLE) ) 						gen.push(MECHA_CRYSTAL);
		if ( hero.have(MECHA_BLADE) && b.type == SWORD ) 									gen.push(MECHA_CRYSTAL);
		if ( b.type == MIRROR ) 															gen.push(Game.me.monster.getRandomBallType());
		

		
		//
		tick();
		
		//
		add( new ac.Burst(board, b.group.list, gen) );
		add( new ac.Fall(board) );
		switch(b.type) {
			case FROZEN(bt) :	onEndTasks = kill;
			default : 			onEndTasks = callback( playBall, b );
		}
		step = 2;
	}
	
	
	// COMBO
	public function getCombo(com:ComboData):Combo {
		
		var round = ac.struct.Round.current;
		var turn = ac.struct.HeroTurn.current;
		
		var bdata = Data.BALLS[Type.enumIndex(com.type)];
		
		var trg = Game.me.monster;
		
		var status = com.hero.haveStatus;
		var stock = com.hero.readStock;
		
		var spendStock = 0;
		var time = 0;
		var power = com.num;
	
		var extraTurn = null;
		var extraTurnSkill = null;
		var damageTypes = [PHYSICAL];
		var desc = bdata.desc;
		var maxBreath = com.hero.board.breathes.length + com.num;
	
		var addExtra = function( ?skill:SkillType, ?heroes:Array<Hero>, ?balls:Array<BallType>) {
			if ( Lambda.has(Round.current.used, skill) ) return false;
			if ( heroes == null ) heroes = [com.hero];
			extraTurn = { heroes:heroes, balls:balls };
			extraTurnSkill = skill;
			return true;
		}
		
		var have = function(sk:SkillType, addDesc=false) {
			if ( !com.hero.have(sk) ) 		return false;
			if ( addDesc ) {
				var sdata = Data.SKILLS[Type.enumIndex(sk)];
				desc += "<br/><br/>"+sdata.name+" : "+sdata.desc2;
			}
			return true;
		}
		
		var clampRegen = function() {
		
			if ( power > com.hero.board.breathes.length ) power = com.hero.board.breathes.length;
			if ( power == 0 ) desc += "<p>Stockez plus de souffle avant d'utiliser cette rune.</p>";
		}
		
		// GENERIC
		if( com.type != MEDITATE ) power += stock(MEDITATE);
		if( com.num >= 3 ) have(SPECIAL_RECIPE, true);		// GEN
		if ( com.num == 1 && have(QUICK) )	addExtra(game.heroes);
		
		// VARS
		var frenzy = stock(FRENZY) > 0;
		
		/// ATTACK
		if ( Ball.isAttack(com.type) ) {
			power += stock(CARROT);
			
			// COUNTER
			var counter = stock(COUNTER);
			if ( counter > power ) counter = power;
			power += counter;
			
			// OTHERS
			if ( status(STA_BLIND) ) 					power--;
			if ( com.hero.haveBall(COURAGE) ) 			power++;
			if ( com.hero.haveBall(ORI_SWORD) )			power++;
			if ( com.hero.armor > 0 && have(PARANOIA) )	power++;
			if ( trg.haveStatus(STA_WEAK_POINT) && have(VICIOUS) ) power += 2;
			
		
			if ( have(SUPA_GLUE) ) damageTypes.push( SKILL_KILLER(FLYING) );
			
			if ( com.num <= 2 )	have(PARADE, true);	// GEN
			
		
			
			// FRENZY
			if ( frenzy ) {
				spendStock++;
				addExtra([SWORD, AXE, CONTROL]);
			}
			
			// OPPORTUNITY
			var adata = trg.getNextActionData();
			if ( adata.attack && have(OPPORTUNITY,true) ) damageTypes.push( PIERCE );
						
			
			//
			
		}
		
		
		// SWITCH
		switch(com.type) {
			case SWORD, SWORD_RED :
				power += stock(SWORD);
				have(ICE_KATANA, true);
				
				if ( status(STA_FIRE_SWORD) ) 				power += 2;
				if ( status(STA_IAIDO) ) 					power += 3;
				if ( have(SHARP_EDGE) && com.num>= 3 )		power += 1;
				if ( have(AMBIDEXTROUS, true) ) 			addExtra(AMBIDEXTROUS, [SWORD, SWORD_RED]);
				if( have(DOUBLE_THICKNESS,true) )			damageTypes.push(ACID);
				
				if( trg.isHalfLife() ) 							have(BISECTION, true);
				if ( com.num >= 3 ) 							have(WAKIZASHI, true);
				if ( com.num >= 3 && have(FINE_BLADE, true) )	damageTypes.push(PIERCE);
				
				if ( have(GIGANTIC_BLADE) && power < 4 ) 	desc = bdata.desc2;
				if ( have(POISON_BLADE) ) damageTypes.push( POISON );
				
			case HAMMER :
				if ( !frenzy) time++;
				else spendStock++;
				damageTypes.push(ACID);
				if ( have(FLICK, true) && com.num == 1 ) {
					time = 0;
					addExtra(FLICK);
				}
				if ( have(STRONG_WRISTS) ) time--;
				if ( com.num >= 5 ) have(KNOCK_OUT, true);
				if ( time > 0 ) desc += bdata.desc2;
				
			case AXE :
				if ( !frenzy) time++;
				else spendStock++;
				if ( have(DOUBLE_EDGE) ) {
					power *= 2;
					timer++;
				}else {
					power++;
				}
				if ( have(STRONG_WRISTS) ) time--;
				if ( com.num >= 4 && have(POWERFUL) ) damageTypes.push(ACID);
				if ( time > 0 ) desc += bdata.desc2;
				
				if ( have(THROWING_AXE, true) ) 	damageTypes.push(PROJECTILE);

			case SHIELD :
				power += stock(POTATO);
				have(GATHER_POWER, true);
				have(GATHER_INFORMATIONS, true);
				have(GATHER_SPIRIT, true);
				if ( have(BARK_SKIN) ) power++;
				if ( have(HOLD_POSITION) ) {
					var a = game.heroes.copy();
					a.remove(com.hero);
					addExtra( HOLD_POSITION, a);
				}
				
				// TEXT
				var p_resist = 3;
				var m_resist = 4;
				if ( have(TEMPERED_STEEL) ) p_resist += 1;
				if ( have(HOLY_SHIELD) ) 	m_resist += 3;
				var str = bdata.desc2.split("$p_resist").join(""+p_resist);
				str = str.split("$m_resist").join(""+m_resist);
				desc += "<br/><br/>" + str;
				
			case HEAL :
				var mult = 2;
				if ( have( CHLOROPHILE ) ) mult++;
				power *= mult;
				if ( have(HIPPOCRATIC_OATH) ) desc = Data.SKILLS[Type.enumIndex(HIPPOCRATIC_OATH)].desc2;
				
				clampRegen();
				
				have(ALCHEMY, true);		// GEN
				if ( com.num >= 3 ) have(DRUNKEN_MASTER, true);
				have(BENEVOLENCE, true);
				
				
			case MECHA_CRYSTAL, MECHA_SHARD :
				if ( have(FAST_CASTER) ) addExtra(FAST_CASTER);
				if ( power == 1 && have(FULMINOMANCY) ) addExtra(FULMINOMANCY);
				desc = mechaDesc(com.hero, power);

			// HERATUS
			case TURNIP :
				power *= 2;
				clampRegen();
				have(TURNIP_UP, true );
				if ( have(BIG_EATER) ) addExtra(BIG_EATER);
				
				
			case CARROT :
				power *= 2;
				clampRegen();
				have(CARROT_UP, true );
				if ( have(BIG_EATER) ) addExtra(BIG_EATER);
				
				
			case POTATO :
				power *= 2;
				clampRegen();
				have(POTATO_UP, true );
				if ( have(BIG_EATER) ) addExtra(BIG_EATER);
				
				
			// CELEIDE
			case BOW :
				
				damageTypes.push(PROJECTILE);
				
				if ( power <= 2 && have(FAST_SHOT) ) addExtra(FAST_SHOT);
				
				if ( stock(ADD_FIRE) > 0 ) {
					damageTypes.push(FIRE);
					power+=2;
					if ( have(GUNPOWDER) ) power++;
				}
				if ( stock(ADD_ICE) > 0 ) 		damageTypes.push(ICE(2));
				if ( stock(ADD_POISON) > 0 ) 	damageTypes.push(POISON);

				if ( have(PRECISION) && com.num == 1 ) damageTypes.push(PIERCE);

				if ( game.monster.have(FLYING) && have(BALL_TRAP) ) power += power;


			case ADD_FIRE, ADD_ICE, ADD_POISON :

			case CHAIN :
			case STONE :
				
			// STIRENX
			case ICE_BLAST :
				if ( power > maxBreath ) power = maxBreath;
				time = power >> 1;
				if ( have(ABSOLUTE_ZERO, true ) ) time++;
								
			case FROZEN(t) :
			
			// TORKISH
			
			// GLORIA
			case FLOWER :
				time = power;
				have(NATURAL_HEALING, true);
				if ( have(FLOWER_POWER) ) time++;
			
			case FOREST_HEART :
				power = 2;
				clampRegen();
				
			// DOLSKIN
			case MEDITATE :		if ( com.num == 1 && have(EQUILIBRIUM) ) addExtra(EQUILIBRIUM);
				
			// HORAS
			case MADNESS :		//if ( have(MECHA_DREAMS) ) desc = bdata.desc2;
			case SHUFFLER :		addExtra();
			case PILL :			addExtra();
				
			// EPIVONE
			case THIEF :
				time =	Math.floor( power * 0.5 );
				power =	Math.ceil( power * 0.5 );
				have(BACK_STAB, true);
				if ( have(SWIFT_HAND) ) addExtra(SWIFT_HAND);
				
			case KUNAI :
				var mult = 1;
				if ( have(KUNAI_BELT) ) mult++;
				power *= mult;
				
			case BOOT :
			
			// TASULYS
			case JAR, JAR_CRACKED :
				if ( have(SHELL) ) power = com.num;
				if ( com.num == 1 ) have(SURPRISE, true);
				if ( com.num >= 3 && have(COLLECTION) ) addExtra([JAR, JAR_CRACKED, JAR_POISON]);
				
			//
			case MIRROR :
				addExtra(game.heroes);
			default :
		}
		
		// CELERITE
		if ( extraTurn == null && com.hero.haveStatus(STA_CELERITY) ) {
			addExtra(TURNIP_UP); // FALSE SKILL EMULATE CELERITY;
		}
		
		
		return {
			power:power,
			time:time,
			damageTypes:damageTypes,
			extraTurn:extraTurn,
			extraTurnSkill:extraTurnSkill,
			desc:desc,
			data:com,
			spendStock:spendStock,
		};
		
	}
	
	// PLAY
	public function playBall(ball:Ball) {
		onEndTasks = kill;
		
		// VARS
		var type = ball.type;
		var num = ball.group.list.length;
		
		var board = ball.board;
		var hero = board.hero;
		var trg = game.monster;
		
		var have = hero.have;
		var haveStatus = hero.haveStatus;
		
		var powBonus = 0;
		
		// APPLY
		var list:Array<ComboData> = [];
		for ( b in ball.group.list ) {
			var cdata:ComboData = null;
			for ( com in list ) {
				if ( com.type == b.type || b.generic) {
					cdata = com;
					break;
				}
			}
			if ( cdata == null ) {
				cdata = { hero:b.board.hero, type:b.type, num:0, alt:SWORD };
				if ( b.type == ORI_HELMET ) powBonus++;
				list.push(cdata);
			}
			cdata.num++;
		}
		
		// BOOT x2
		if ( ball.group.type == BOOT ) {
			for ( cdata in list ) cdata.num++;
		}
		
		
		// MADNESS SWITCH
		for ( cdata in list ) {
			if ( cdata.type == MADNESS ) {
				cdata.type = ball.group.alt;
				if ( hero.have(INSANITY_POWER) ) cdata.num++;
			}
		}
		
		// POWER BONUS
		for ( gr in list ) gr.num += powBonus;
		
		
		
		// APPLY
		for ( cdata in list ) {
			var com = getCombo(cdata);
			if ( com.power > 0 )  applyCombo( com );
		}
	
		
		// EMPTY SPECIAL STOCK
		hero.grabStock(COUNTER);
		
		//
		hero.majRunes();
		hero.majInter();
	}

	// APPLY
	public function applyCombo(com:Combo) {
		
		var trg = Game.me.monster;
		var hero = com.data.hero;
		var type = com.data.type;
		var have = hero.have;
		
		// SHORTCUTS
		var me = this;
		var stk = function(?t,?pow) {
			if ( t == null) t = type;
			if ( pow == null) pow = com.power;
			hero.setStock(t, pow );
		};
		var mid = function() { me.add( new ac.MoveMid(hero.folk) ); };
		var back = function() { me.add( new ac.hero.MoveBack(hero.folk) ); };
		var anim = function(str = "atk") { me.add( new ac.hero.AnimAction(hero, str) ); };
		var atk = function(power, damageTypes) {
			mid();
			hero.grabStock(CARROT);
			hero.grabStock(SWORD);
			me.add( new ac.hero.Attack(hero, trg, power, damageTypes) );
			back();
			
		}
		var regen = function(power) {
			me.add( new ac.hero.Regeneration(hero,power) );
		}
		var shield = function(power) {
			me.add( new ac.hero.IncArmor(hero,power) );
		}

		// MEDITATE
		if ( hero.haveStock(MEDITATE)  ) {
			if ( type == MEDITATE ) {
				if( !have(CONCENTRATION) ) hero.spendStock(MEDITATE);
			}else {
				var n = hero.spendStock(MEDITATE);
				if( have(MIND_CONTROL) ){
					n -= 3;
					if ( n > 0 ) hero.setStock(MEDITATE, n);
				}
				
			}
		}
		
		// APPLY
		switch(com.data.type) {
			case SWORD, SWORD_RED :

				if ( have(ICE_KATANA) )								com.power += hero.board.unfreeze;
				if ( have(GIGANTIC_BLADE) && com.power < 4 ) {
					stk( SWORD, com.data.num+(hero.have(TWIRL)?1:0));
				}else {
					if ( have(BISECTION) && trg.isHalfLife() && Std.random(2)==0 ) {
						add( new ac.hero.Bisection(hero,trg) );
					}else {
						atk( com.power, com.damageTypes );
					}
				}
				
				
			case HAMMER :
			if ( com.data.num >= 5 && have(KNOCK_OUT) )		com.damageTypes.push(STUN);//for( i in 0...2 ) trg.firstChain.unshift(AC_WAIT);
			atk( com.power, com.damageTypes );
				if ( com.time > 0 ) 						hero.addStatus(STA_CLOCK, com.time);
				
				
			case AXE :
				if ( have(THROWING_AXE) ) 	add( new ac.hero.Projectile(hero, trg, 1, com.power, com.damageTypes ) );
				else						atk( com.power, com.damageTypes );
				
				if ( com.time > 0 ) hero.addStatus(STA_CLOCK, com.time);
				
			case SHIELD :
				hero.grabStock(POTATO);
				shield(com.power);
				if ( have(LIMITED_PATIENCE) ) 		stk(FRENZY, 1);
				if ( have(GATHER_POWER) )			add( new ac.hero.Regeneration(hero, 3));
				if ( have(GATHER_SPIRIT) )			stk(MEDITATE, 2);
				if ( have(GATHER_INFORMATIONS) && !trg.haveStatus(STA_WEAK_POINT) )	add( new ac.hero.FindWeakPoint(hero, trg));
				
			case HEAL :
				if ( have(HIPPOCRATIC_OATH) ) {
					
					var a = [0, 0, 0];
					var pow = com.power;
					while(pow>0){
						var hid = 0;
						for ( h in game.heroes ) {
							a[hid++]++;
							if (--pow == 0 ) break;
						}
					}
					var hid = 0;
					
					
					for ( h in game.heroes ) {
						//h.incBreath(a[hid]);
						me.add( new ac.hero.Regeneration(h,a[hid]) );
						hid++;
					}
					
					
				}else {
					regen(com.power);
				}
				
				if ( have(DRUNKEN_MASTER) ) 						shield(1);
				if ( have(BENEVOLENCE) ) 							add( new ac.hero.HealGroupStatus(com.data.num) );
				if ( have(LIMITED_PATIENCE) ) 						stk(FRENZY,1);
				
			case MECHA_CRYSTAL, MECHA_SHARD :
				castMecha(hero, com.power, trg);
			

			// HERATUS
			case TURNIP :
				regen(com.power);
				if ( have(ROOT_SERUM) && hero.haveStatus(STA_POISON) ) hero.removeStatus(STA_POISON);
				
			case CARROT :
				regen(com.power);
				if ( have( CARROT_UP) ) stk(CARROT,com.power);
				
			case POTATO :
				regen(com.power);
				if( have( POTATO_UP) ) stk(POTATO,com.power);
			
			// CELEIDE
			case BOW :
				add( new ac.hero.Projectile(hero, trg, 0, com.power, com.damageTypes ) );
				if ( !have(NIMBLE_FINGERS) ) hero.addStatus(STA_BOW_RELOAD, 1);
				hero.spendStock(ADD_FIRE,1);
				hero.spendStock(ADD_ICE,1);
				hero.spendStock(ADD_POISON,1);

			case ADD_FIRE, ADD_ICE, ADD_POISON : stk();
		
			// ESPIROTH
			case CHAIN :
			case STONE :
				
			// STIRENX
			case ICE_BLAST :
				mid();
				var str = "atk";
				if ( hero.folk.haveAnim("ice")) str = "ice";
				anim(str);
				add( new ac.hero.magic.IceBlast(hero, com) );
				back();
			
			case BURNING_HOPE :
				add( new ac.hero.Hope(hero) );
				
			case FROZEN_HAMMER, FROZEN_SHIELD, FROZEN_HEAL :
				
			
			// TORKISH
			case RAGE :
				hero.stock = 0;
				hero.setStock(RAGE, com.power);
				
			case MUSIC :
				for ( h in game.heroes ) h.setStock(RAGE, 3);
			
			// GLORIA
			case FLOWER :			add(new ac.hero.Flower(hero,com.time));
			case FOREST_HEART :		add( new ac.hero.Regeneration(hero, com.power) );
	
				
			// DOLSKIN
			case MEDITATE :
				stk();
				
			// EGOINE
			case CROSS :
				trg.addStatus(STA_WEAK_POINT);
				
			case TABLET :
				add( new ac.hero.Sedative(hero) );
				
			case DART :
				var a = [PROJECTILE, PIERCE, POISON, POISON ];
				//for ( i in 0...com.power) a.push(POISON);
				add( new ac.hero.Projectile(hero, trg, 2, com.power, [POISON] ) );

			case COURAGE :
		
			// HORAS
			case SHUFFLER :
				add( new ac.hero.ShuffleBoard(hero) );
				
			case PILL :
				add( new ac.hero.MorphAll(hero, MADNESS, hero.getMadList() ) );
			
			// EPIVONE
			case THIEF :
				atk( com.power, [PHYSICAL, STEAL(com.time), STEALTH] );
				if ( have(BACK_STAB) ) hero.setStock(KUNAI, 1);
				
			case KUNAI :
				stk();
				
			case BOOT :
			case BOMB :
				atk( 1, [PHYSICAL, FIRE] );
				
			case SMOKE :
				add( new ac.hero.SmokeBomb(hero) );
				
			// TASULYS
			case JAR, JAR_CRACKED :
				stk(JAR);
				if ( have(THROW) )	atk(1, [PROJECTILE, PHYSICAL]);
				add( new ac.hero.JarSuck(hero, trg) );
				
			case JAR_POISON :
				for ( i in 0...3 ) trg.addStatus(STA_POISON);
				
			// MAUGRINE
			case CONTROL :
				shield(1);
				
			case FRENZY :
				stk();
				
			// ANTONES
			case CROWN :
				for ( h in game.heroes ) {
					me.add( new ac.hero.Regeneration(h, 4) );
					h.armorLife = h.armorLifeMax;
					h.majInter();
				}
				
			// GODS
			//case BREEZE :			add( new ac.hero.god.Withdraw(hero,2) );
			case BREEZE :			add( new ac.hero.god.Breeze(hero,2) );
			case HARMATTAN :		add( new ac.hero.god.Harmattan(hero,2) );
			
			case BUD :				add( new ac.hero.god.Bud(hero, 3) );
			
			case MECHA_BOMB :		add( new ac.hero.god.MechaBomb(hero,1));//
			
			case MAGIC_DROP :
			case TRIDENT :			add(new ac.hero.god.Trident(hero, 4));
			
			case ANGER :			add(new ac.hero.god.Anger(hero,0));
			case WARHAMMER :		add(new ac.hero.god.Warhammer(hero,0));
			
			// ORICHALQUE
			case ORI_HELMET :
			
			//
			case MIRROR :
			case CYCLOP_EYE : 		add(new ac.hero.CyclopEye(hero,Game.me.monster));
			
			
			default :
				trace("TODO: " + type);
				
				
			
				
			
		}
		
		// EXTRA TURN
		if ( com.extraTurn != null ) {
			HeroTurn.current.extraTurn( com.extraTurn.heroes, com.extraTurn.balls);
			if( com.extraTurnSkill != null ) Round.current.used.push(com.extraTurnSkill);
		}
		
		// SPEND
		if ( com.spendStock > 0 ) {
			if ( hero.stockType == FRENZY  && have(FEELING_BETTER) ) add(new ac.hero.Regeneration(hero, 2));
			hero.stock -= com.spendStock;
			if ( hero.stock < 0 ) hero.stock = 0;
		}
		
		
	}
	
	// MECHA
	public function mechaDesc(hero:Hero,power) {

		
		var mdata = hero.getMechaData(power);
		
		var str = "<ul>";
		for ( id in 0...Data.SPELL_MAX+1 ) {
			
			var data = hero.getMechaData(id+1);
			var cost = "" + (id + 1);
			
			if ( id == 10 ) {
				cost = "10+" ;
				if ( hero.have(VORTEX) ) data = Data.SPELLS[11];
			}
			
			var ok = data.id == mdata.id;
			var spell_desc = "<li"+((ok)?" class='active'":"")+"><span class='mecha_cost'>" + cost + "</span> " + data.name +"</li>";
			if ( ok ) {
				var what = Cs.rep(data.desc,Cs.gnum(data.a));
				spell_desc += "<li class='nfo'>" + what + "</li>";
			}
			str += spell_desc;
		}
		return str+"</ul>";
	}

	
	public function castMecha(hero:Hero, power, trg:Monster) {
		
		var trg = game.monster;
		var data = hero.getMechaData(power);
		
		// DEV
		//data.id = MECHA_VORTEX;
		switch(data.id) {
				
			case FIREFLY :				add( new ac.hero.magic.FireFly( hero, trg ) );
			case MAGIC_BARRIER :		add( new ac.hero.magic.Barrier(hero) );
			case FIREBALL :				add( new ac.hero.magic.Fireball(hero,trg) );
			case REJUVENATION :			add( new ac.hero.magic.Rejuvenation(hero) );
			case ICE_BOLT :				add( new ac.hero.magic.Iceball(hero, trg, power) );
			case FIRE_SWORDS :			add( new ac.hero.magic.FireSword(hero) );
			case ICY_PRISON :			add( new ac.hero.magic.IcyPrison(hero, trg) );
			case EARTHQUAKE :			add( new ac.hero.magic.Earthquake(hero, trg) );
			case TORNADO :				add( new ac.hero.magic.Tornado(hero) );
			case LIGHTNING :			add( new ac.hero.magic.Lightning(hero,trg) );
			case MECHA_SURGE :			add( new ac.hero.magic.MechaSurge(hero) );
			case MECHA_VORTEX :			add( new ac.hero.magic.Vortex(hero, trg, power) );
			//	add( new ac.DirectDamage(hero, power, [MAGIC]));
				
		}
		hero.majInter();
	}
	
	// PLAY - TOOLS
	/*
	public function selfDamage(hero:Hero,n) {
		var balls = hero.board.getRandomBalls(n, true);
		for ( b in balls ) b.damage(null);
		fall(hero);
	}
	*/
	public function fall(hero:Hero) {
		add( new ac.Fall(hero.board) );
	}


	

	
//{
}






