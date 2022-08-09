import Protocole;
import mt.bumdum9.Lib;


class Hero extends Ent{//}
	
	public static var DATA = mt.data.Mods.parseODS( "client.ods", "heroes", DataHero );

	public var stock:mt.flash.Volatile<Int>;
	var magicResistance:mt.flash.Volatile<Int>;
	
	public var stockType:BallType;
	
	public var armorLife:mt.flash.Volatile<Int>;
	public var armorLifeMax:mt.flash.Volatile<Int>;
	
	public var balls:Array<BallType>;
	public var board:Board;
	
	public var data:DataHero;
	public var ghost:HeroGhost;


	public function new(gm,ghost) {
		super(gm);

		this.ghost = ghost;
		data = DATA[Type.enumIndex(ghost.type)];
		
		//lvl = Gameplay.getLevel(ghost.xp);
		balls = data.balls.copy();
		armor = 0;
		magicResistance = 0;
		armorLife = 0;
		armorLifeMax = 3;
		stock = 0;
		
		//
		applySkills();
		
		// BOARD
		board = new Board(this);
		game.dm.add(board, Game.DP_BOARDS );
		board.readGrid(0);
		
		// FOLK
		folk = new Folk();
		folk.setHero(ghost.tid, ghost.type);
		folk.getStandPos = getStandPos;
		
		// INIT
		for ( sk in ghost.skills ) {
			switch(sk) {
				case GHOST_FORM : 		addStatus(STA_GHOST_FORM);
				case IAIDO : 			addStatus(STA_IAIDO);
				case DODGER : 			addStatus(STA_DODGE);
				case CALM :				setStock(MEDITATE, 1);
				case HERMETIC :			magicResistance += 50;
				case ROYAL_BLOOD :		magicResistance += 30;
				case TEMPERED_STEEL :	armorLifeMax++;
				case FOOLHARDY_CHARGE :	setStock(SWORD, 2);
				default :
			}
		}
		if ( ghost.type == Dolskin && !have(VISION) ) addStatus(STA_BLIND);
		resetArmor();
		
		
	}
	public function applySkills() {
		for ( sk in ghost.skills ) {
			switch(sk) {
				case ARROW_ICE:
				
					balls.remove(ADD_FIRE);
					balls.push(ADD_ICE);
					
				case ARROW_POISON :
					balls.remove(ADD_FIRE);
					balls.push(ADD_POISON);
					
				default :
			}
		}
	}

	// MECHA
	public function getMechaData(power) {
		var id = power - 1;
		if ( id >= Data.SPELL_MAX ) {
			id = Data.SPELL_MAX;
			if ( have(VORTEX) ) id++;
		}

		if ( have(ICE_CORE) && id == 2 ) id = 3;
	
		var base = Data.SPELLS[id];
		var data:DataSpell = {
			id:base.id,
			name:base.name,
			cost:base.cost,
			desc:base.desc,
			desc2:base.desc,
			a:base.a,
			b:base.b
		}
		
		// MODS
		var check = function (sk:SkillType) {
			if ( have( sk) ) {
				data.desc += "<br/>"+Data.SKILLS[Type.enumIndex(sk)].desc2;
				return true;
			}
			return false;
		}
		
		switch(id) {
			case 0 : // FIREFLY
				if ( check( FULMINOMANCY ) ) data.a++;
				check( WISP_HEALING );
				check( EVIL_DRAIN );
			
			case 1 : // BARRIER
				check( MAGIC_HEALING );
				check( DARKNESS );
				check( MAGIC_SHIELD );
				if (check( MECHA_ARMOR ) ) data.a++;
				
			case 2 : // FIREBALL
				if ( check(PYROMANCY) )		data.a++;
				if ( have(ICE_CORE) ) 		data.a--;

			case 3 : // ICEBALL
				if ( have(NIXOMANCY) ) data.b++;
		}
		
		if ( have(FORBIDDEN_ALCHEMY ) ) data.a++;
		
		
		return data;
	}
	
	// UPKEEP
	public override function onUpkeep() {
		super.onUpkeep();
		//board.onUpkeep();
		
		if ( have(STRAITJACKET) ) {
			var ball = board.getBall(MADNESS);
			if ( ball != null ){
				var a = getMadList();
				ball.morph( a[Std.random(a.length)] );
				ball.fxSpawn();
			}
		}
		

		
		
	}

	// STOCK
	public function setStock(type, n) {
		

		// RESET
		if ( stockType != type ) stock = 0;
		
		// ASSIGN TYPE
		stockType = type;
		
		// SET / ADD
		stock += n;
		

		
	}
	public function grabStock(type) {
		if ( stock == 0 || stockType != type ) return 0;
		var n = stock;
		stock = 0;
		return n;
	}
	public function readStock(type) {
		if ( stockType != type ) return 0;
		return stock;
	}
	public function spendStock(type,?num){
		if ( stockType != type ) return 0;
		if ( num == null || num > stock ) num = stock;
		stock -= num;
		return num;
		
		
	}
	
	public function haveStock(type, use=false) {
		var ok = stockType == type && stock > 0;
		if ( ok && use ) stock--;
		return  ok;
	}
	public function unfreshStock() {
		if ( stock == 0 ) return;
		
		/*
		if ( stockFresh ) {
			stockFresh = false;
			return;
		}
		*/
		
		switch(stockType) {
						
			// FOREVER
			case ADD_FIRE, ADD_ICE, ADD_POISON :
			
			// LEAK
			case RAGE :
				stock--;
			
			// RESET
			default :	//stock = 0;
		}
		majInter();
		
	}

	// ARMOR
	public override function incArmor(n) {
		if ( armorLife == 0 && n > 0 ) armorLife = armorLifeMax;
		if ( armorLife < armorLifeMax && have(FORGE) ) armorLife++;
		
		super.incArmor(n);
		if ( armor == 0 ) armorLife = 0;
	}
	public override function armorCollide(dam) {
		return super.armorCollide(dam) || ( have(HERMETIC) && Lambda.has(dam.types, MAGIC) );
	}
	public override function applyArmor(dam) {
		var absorb = super.applyArmor(dam);
		armorLife--;
		if ( armorLife == 0 ) resetArmor();
		
		if ( have(RIPOSTE) ) {
			setStock(COUNTER, absorb<3?absorb:3);
		}
		
		return absorb;
	}
	public override function resetArmor() {
		if ( armor > 0 && game.groupHaveBall(SLOUGH)) {
			board.breathSpawn(armor);
		}
		armor = 0;
	}
	
	// DAMAGE
	public override function applyDamage(dam:Damage) {
		
		
		
		//
		var frontAttack = true;
		var stone = Lambda.has( dam.types, STONER );
		if ( stone ) frontAttack = false;
				
		// ORI_ARMOR
		if ( dam.value > 0 && haveBall(ORI_ARMOR ) ) {
			//var ball = haveBall(ORI_ARMOR);
			var ball = board.getBall(ORI_ARMOR);
			ball.fxActive();
			dam.value--;
		}
		
		// BALLS
		board.computeBallScores(frontAttack,stone);
		var balls = board.getRandomBalls(dam.value, true );

		// PERSECUTION
		if ( have(PERSECUTION) && Lambda.has(dam.types,PHYSICAL) ) {
			var a = [];
			for ( b in balls ) if ( b.type != MADNESS ) a.push(b);
			if ( a.length > 0 ) {
				var b = a[Std.random(a.length)];
				b.morph(MADNESS);
				balls.remove(b);
			}
		}

		var breathNum = have(STURDY)?1:0;
		
		for ( b in balls ) {
			if ( stone ) {
				b.petrify();
			}else {
				if ( breathNum-- > 0 ) new part.Breath(b.board, b.px, b.py);
				if ( have(GRUMPY) && readStock(RAGE) == 0 ) setStock(RAGE, 2);
				b.damage(dam);
				
			}
		}
		
		
		return balls.length;
		
	}

	//
	public override function fxHit() {
		board.fxHit();
		folk.play("hit", true);
	}
	public override function fxAbsorb() {
		board.fxArmor();
		new mt.fx.Flash(folk, 0.2);
	}
	
	// TOOLS
	public function getRandomBallType() {
		return balls[game.seed.random( balls.length )];
	}
	public function getPos() {
		var id = 0;
		for ( h in game.heroes ) {
			if ( h == this ) return id;
			id++;
		}
		return -1;
	}

	public override function getStandPos() {
		return (getPos() + 1) * 80;
	}
	public function isFirst() {
		return getPos() == Game.me.heroes.length-1;
	}
	public function getMadList() {
		var a = [SWORD, HEAL, SHIELD,MECHA_CRYSTAL];
		if ( have(MECHA_DREAMS) ) {
			a.push(MECHA_CRYSTAL);
			a.push(MECHA_CRYSTAL);
		}
		return a;
	}
	public function getMagicResistance() {
		var shieldBonus = 4;
		if ( have(HOLY_SHIELD) ) shieldBonus += 3;
		return magicResistance + armor * (shieldBonus) + (haveBall(ORI_SHIELD)?20:0);
		
	}
	
	// OVERRIDES
	public override function have(sk:SkillType) {
		for ( s in ghost.skills ) if (s == sk ) return true;
		return false;
	}
	public override function getSkills() {
		return ghost.skills.copy();
	}
	public override function majInter() {
		super.majInter();
		board.inter.maj();
	}
	public override function removeStatus(sta) {
		return super.removeStatus(sta);
		
		
	}
	
	//
	public function haveBall(bt:BallType) {
		for ( b in board.balls ) if ( b.type == bt ) return true;
		return false;
	}

	
	//
	public function checkDeath() {
		for ( b in board.balls ) if ( b.isAlive()  ) return false;
		if ( have(NO_PAIN) && readStock(RAGE) > 0 ) return false;
		return true;
	}
	
	//
	public function majRunes() {
		var gs = Gameplay.getGridSize(ghost);
		Game.me.majRunes(ghost.id, board.balls.length, gs.width*gs.height );
	}
	
	
	
	// KILL
	public function kill() {

		game.heroes.remove(this);
		folk.kill();
		board.writeGrid();
		board.kill();
		game.majPanels();
		
	}
	
	// DEV
	public static function getRandomBuild(type:HeroType, lvl:Int) {
		var data = DATA[Type.enumIndex(type)];
		var a = data.skills.copy();
		var build:HeroGhost =  { name : null, skills:[], knowledge:0, awakening:0, id:0, type:type, state:null, tid:Std.string(type).split("_").join("") };
		Gameplay.initHeroState(build);
		
		while( lvl>0 && a.length > 0 ) {
			var sk = a[Std.random(a.length)];
			var sdata = Data.SKILLS[Type.enumIndex(sk)];
			if ( sdata.price <= lvl ) {
				lvl -= sdata.price;
				build.skills.push(sk);
			}
			a.remove(sk);
		}
		
		return build;
	}
	

	
//{
}









