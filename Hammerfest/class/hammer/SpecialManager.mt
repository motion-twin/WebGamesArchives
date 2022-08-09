class SpecialManager
{

	var game		: mode.GameMode;
	var player		: entity.Player;

	var phoneMC		: {  >MovieClip, lines:MovieClip, screen:{>MovieClip, field:TextField}  };
	var clouds		: Array< {>MovieClip,speed:float} >;

	var permList	: Array<int>;
	var tempList	: Array< {id:int,end:float} >;

	var actives		: Array<bool>;

	var recurring	: Array< {timer:float, baseTimer:float, fl_repeat:bool, func:void->void} >


	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(g,p) {
		game = g;
		player = p;

		permList = new Array();
		tempList = new Array();
		actives = new Array();

		recurring = new Array();
		clouds = new Array();
	}


	/*------------------------------------------------------------------------
	ACTIVATION D'UN EFFET PERMANENT
	------------------------------------------------------------------------*/
	function permanent(id) {
		if ( actives[id]!=true ) {
			actives[id] = true;
			permList.push(id);
		}
	}


	/*------------------------------------------------------------------------
	ACTIVATION D'UN EFFET TEMPORAIRE
	------------------------------------------------------------------------*/
	function temporary(id, duration) {
		// si null, dure jusqu'à la fin du level en cours
		if ( duration==null ) {
			duration = 99999;
		}

		if ( actives[id]!=true ) {
			actives[id] = true;
			tempList.push( {id:id,end:game.cycle+duration} );
		}
	}


	/*------------------------------------------------------------------------
	ACTIVATION D'UN EFFET PERMANENT GLOBAL (RARE)
	------------------------------------------------------------------------*/
	function global(id) {
		game.globalActives[id] = true;
	}



	/*------------------------------------------------------------------------
	ARRÊTE TOUS LES EFFETS TEMPORAIRES
	------------------------------------------------------------------------*/
	function clearTemp() {
		while (tempList.length>0) {
			interrupt( tempList[0].id );
			tempList.splice(0,1);
		}
	}


	/*------------------------------------------------------------------------
	ARRÊTE TOUS LES PERMANENTS
	------------------------------------------------------------------------*/
	function clearPerm() {
		while (permList.length>0) {
			interrupt( permList[0] );
			permList.splice(0,1);
		}
	}

	/*------------------------------------------------------------------------
	ARRÊTE TOUS LES EFFETS SPÉCIAUX RÉCURRENTS
	------------------------------------------------------------------------*/
	function clearRec() {
		recurring = new Array();
	}


	/*------------------------------------------------------------------------
	AJOUTE UN ÉVÈNEMENT RÉCURRENT
	------------------------------------------------------------------------*/
	function registerRecurring( func, t, fl_repeat ) {
		recurring.push( {
			timer:t*1.0,
			baseTimer:t,
			func: func,
			fl_repeat: fl_repeat
		} );
	}

	/*------------------------------------------------------------------------
	SPAWN UN ITEM DONNÉ AU DESSUS DE CHAQUE DALLE DU NIVEAU
	------------------------------------------------------------------------*/
	function levelConversion(id,sid) {
		var s = game.world.scriptEngine.script.toString();
		game.world.scriptEngine.safeMode();
//		game.world.scriptEngine.clearScript();
		game.killPop();
		var n=0;
		for (var y=0;y<Data.LEVEL_HEIGHT;y++) {
			for (var x=0;x<Data.LEVEL_WIDTH;x++) {
				if ( game.world.checkFlag( {x:x,y:y}, Data.IA_TILE_TOP) ) {
					var t=n*2;
					if ( n<4 ) t=1;
					game.world.scriptEngine.insertScoreItem( id, sid, game.flipCoordCase(x),y, t, null, true, false);
					n++;
				}
			}
		}
		game.perfectItemCpt = n;
//		game.world.scriptEngine.compile();
	}


	/*------------------------------------------------------------------------
	EFFETS DES ZODIAQUES
	------------------------------------------------------------------------*/
	function getZodiac(id:int) {
		game.fxMan.attachBg(Data.BG_CONSTEL,id,Data.SECOND*4);
		var l = game.getBadClearList();
		for (var i=0;i<l.length;i++) {
			entity.item.ScoreItem.attach(game, l[i].x, l[i].y-Data.CASE_HEIGHT*2, 169,0);
		}
	}

	/*------------------------------------------------------------------------
	EFFETS DES POTIONS DU ZODIAQUE
	------------------------------------------------------------------------*/
	function getZodiacPotion(id:int) {
		var l = game.getBadClearList();
		for (var i=0;i<l.length;i++) {
			entity.item.ScoreItem.attach(game, l[i].x, l[i].y-Data.CASE_HEIGHT*2, 169,0);
		}
	}


	/*------------------------------------------------------------------------
	DONNE LE BONUS PERFECT
	------------------------------------------------------------------------*/
	function onPerfect() {
		interrupt(81);
		interrupt(96);
		interrupt(97);
		interrupt(98);

		var bonus = 50000;
		var mc : { > MovieClip, bonus:String, label:String };
		mc = downcast(game.depthMan.attach("hammer_fx_perfect",Data.DP_INTERF));
		mc._x = Data.GAME_WIDTH*0.5;
		mc._y = Data.GAME_HEIGHT*0.5;
		mc.label = Lang.get(11);
		if ( actives[95] ) { // effet sac à thunes
			mc.bonus = ""+bonus*2;
		}
		else {
			mc.bonus = ""+bonus;
		}
		var pl = game.getPlayerList();
		for (var i=0;i<pl.length;i++) {
			pl[i].getScoreHidden(Math.floor(bonus/pl.length));
		}
	}

	/*------------------------------------------------------------------------
	EVENT: RAMASSE UN DIAMANT DE CONVERSION
	------------------------------------------------------------------------*/
	function onPickPerfectItem() {
		game.perfectItemCpt--;
		if ( game.perfectItemCpt<=0 ) {
			onPerfect();
		}
	}


	/*------------------------------------------------------------------------
	TÉLÉPORTATION VERS UN NIVEAU BONUS
	------------------------------------------------------------------------*/
//	function gotoSpecialLevel( did, lid ) {
//		game.destroyList(Data.BAD);
//		var link	= new levels.PortalLink();
//		link.from_did	= did;
//		link.from_lid	= lid;
//		link.from_pid	= 0;
//		link.to_did		= game.currentDim;
//		link.to_lid		= game.world.currentId;
//		link.to_pid		= -1;
//		Data.LINKS.push(link);
//		game.switchDimensionById( did, lid, -1 );
//	}


	/*------------------------------------------------------------------------
	EXÉCUTE L'EFFET D'UN EXTEND
	------------------------------------------------------------------------*/
	function executeExtend(fl_perfect) {
		game.registerMapEvent( Data.EVENT_EXTEND, null );
		game.manager.logAction("$ext");
		var a = game.fxMan.attachFx(Data.GAME_WIDTH/2,Data.GAME_HEIGHT/2,"extendSequence");
		a.lifeTimer = 9999;
		game.destroyList(Data.BAD);
		game.destroyList(Data.BAD_BOMB);
		game.destroyList(Data.SHOOT);

		player.lives++;
		game.gi.setLives(player.pid, player.lives);
		if ( fl_perfect ) {
			var mc : { > MovieClip, bonus:String, label:String };
			mc = downcast(game.depthMan.attach("hammer_fx_perfect",Data.DP_INTERF));
			mc._x = Data.GAME_WIDTH*0.5;
			mc._y = Data.GAME_HEIGHT*0.2;
			mc.label = Lang.get(11);
			if ( actives[95] ) { // effet sac à thunes
				mc.bonus = "300000";
			}
			else {
				mc.bonus = "150000";
			}
			player.getScoreHidden(150000);
		}
	}


	/*------------------------------------------------------------------------
	LANCE UN WARPZONE "+N" LEVEL
	------------------------------------------------------------------------*/
	function warpZone(w:int) {
		var arrival = game.world.currentId+w;
		game.manager.logAction("$WZ>"+arrival);
		var i = game.world.currentId+1;
		while (i<=arrival) {
			if ( game.isBossLevel(i) ) {
				arrival = i;
			}
			if ( game.world.isEmptyLevel(i,game) ) {
				arrival = i-1;
			}
			i++;
		}

		// téléportation impossible
		if ( arrival==game.world.currentId ) {
			game.fxMan.attachAlert( Lang.get(34) );
			return;
		}

		game.world.view.detach();
		game.forcedGoto( arrival );
	}


	/*------------------------------------------------------------------------
	EXÉCUTE UN ITEM SPÉCIAL
	------------------------------------------------------------------------*/
	function execute(item:entity.item.SpecialItem) {
		var id = item.id;
		var subId = item.subId;
		var auto = 0;

		switch (id) {

			// *** 0. extends
			case auto++:
				if (actives[27]) {
					player.getScore(item,25);
				}
				player.getScoreHidden(5);
				player.getExtend(subId);
			break;

			// *** 1. shield or
			case auto++:
				player.shield(Data.SECOND*10);
			break;

			// *** 2. shield argent
			case auto++:
				player.shield(Data.SECOND*60);
			break;

			// *** 3. ballon de plage
			case auto++:
				entity.supa.Ball.attach(game);
			break;

			// *** 4. lampe or: multi bombes (2)
			case auto++:
				if ( !actives[5] ) {
					player.maxBombs = player.initialMaxBombs+1;
					permanent(id);
				}
			break;

			// *** 5. lampe noire: multi bombes (5)
			case auto++:
				player.maxBombs = player.initialMaxBombs+4;
				permanent(id);
			break;

			// *** 6. yin yang: freeze all
			case auto++:
				var l = game.getBadClearList();
				for (var i=0;i<l.length;i++) {
					l[i].freeze(Data.FREEZE_DURATION*2);
				}
			break;

			// *** 7. chaussure: speed up player
			case auto++:
				player.speedFactor = 1.5;
				permanent(id);
			break;

			// *** 8. étoile: supa bubble
			case auto++:
				entity.supa.Bubble.attach(game);
				entity.supa.Bubble.attach(game);
			break;

			// *** 9. oeil sauron: supa poids
			case auto++:
				entity.supa.Tons.attach(game);
			break;

			// *** 10. téléphone: effet nokia
			case auto++:
//				phoneMC.removeMovieClip();
//				phoneMC = downcast( game.depthMan.attach("hammer_fx_phone", Data.DP_TOP) );
//				phoneMC._x -= game.xOffset;
//				phoneMC.screen.blendMode = BlendMode.HARDLIGHT;
//				phoneMC.lines._visible = GameManager.CONFIG.fl_detail;
//				temporary(id, null);
			break;

			// *** 11. Parapluie rouge: next level
			case auto++:
				warpZone(1);
			break;

			// *** 12. Parapluie bleu: next level x 2
			case auto++:
				warpZone(2);
			break;

			// *** 13. Casque de moto: kicke les bombes plus loin
			case auto++:
				permanent(id);
			break;

			// *** 14. champignon bleu
			case auto++:
				permanent(id);
				interrupt(15);
				interrupt(16);
				interrupt(17);
			break;

			// *** 15. champignon rouge
			case auto++:
				permanent(id);
				interrupt(14);
				interrupt(16);
				interrupt(17);
			break;

			// *** 16. champignon vert
			case auto++:
				permanent(id);
				interrupt(14);
				interrupt(15);
				interrupt(17);
			break;

			// *** 17. champignon or
			case auto++:
				permanent(id);
				interrupt(14);
				interrupt(15);
				interrupt(16);
			break;

			// *** 18. pissenlit: chute lente
			case auto++:
				permanent(id);
				player.fallFactor = 0.55;
			break;

			// *** 19. tournesol
			case auto++:
				entity.supa.Smoke.attach(game);
				var l = game.getBadClearList();
				game.fxMan.attachBg(Data.BG_ORANGE,null,Data.SECOND*3);
				for (var i=0;i<l.length;i++) {
					l[i].forceKill(null);
				}
			break;

			// *** 20. coffre trésor
			case auto++:
				for (var i=0;i<5;i++) {
					var s = entity.item.ScoreItem.attach(game,item.x,item.y,0,Std.random(4))
					s.moveFrom(item,8);
				}
			break;

			// *** 21. enceinte
			case auto++:
				var bad : entity.Bad = downcast(game.getOne(Data.BAD_CLEAR));
				if (bad!=null) {
					game.fxMan.attachFx( bad.x, bad.y-Data.CASE_HEIGHT, "hammer_fx_pop" );
					bad.forceKill(null);
					game.fxMan.attachBg(Data.BG_SINGER,null,Data.SECOND*3);
				}
			break;

			// *** 22. chaussure pourrie
			case auto++:
				interrupt(7);
				player.curse(Data.CURSE_SLOW);
				player.speedFactor = 0.6;
				temporary(id,Data.SECOND*40);
			break;

			// *** 23. boule de cristal
			case auto++:
				var l = game.getBadClearList();
				for (var i=0;i<l.length;i++) {
					var b = l[i];
					var s = entity.shoot.PlayerPearl.attach(game, player.x, player.y-Data.CASE_WIDTH);
					s.moveToTarget( l[i], s.shootSpeed );
					s.fl_borderBounce = true;
					s.setLifeTimer( Data.SECOND*3 + Std.random(400)/10 );
					s._yOffset = 0;
					s.endUpdate();
				}
			break;

			// *** 24. cristal de neige
			case auto++:
				entity.supa.IceMeteor.attach(game);
			break;

			// *** 25. flamme de glace: rideau de fireballs
			case auto++:
				var s;
				for (var i=0;i<4;i++) {
					s = entity.shoot.PlayerFireBall.attach(game, Data.GAME_WIDTH*0.125+Data.GAME_WIDTH*0.25*i, 10);
					s.moveDown( s.shootSpeed );
				}
				for (var i=0;i<4;i++) {
					s = entity.shoot.PlayerFireBall.attach(game, Data.GAME_WIDTH*0.25+Data.GAME_WIDTH*0.25*i, Data.GAME_HEIGHT-10);
					s.moveUp( s.shootSpeed );
				}
			break;

			// *** 26. ampoule
			case auto++:
				permanent(id);
				game.updateDarkness();
			break;

			// *** 27. nenuphar: points pour les extends
			case auto++:
				permanent(id);
			break;

			// *** 28. coupe en argent
			case auto++:
				game.fxMan.attachBg(Data.BG_STAR,null,Data.SECOND*9);
				var l = game.getBadClearList();
				for (var i=0;i<l.length;i++) {
					l[i].knock(Data.SECOND*10);
				}
			break;

			// *** 29. bague or: tir fireball
			case auto++:
				player.changeWeapon(Data.WEAPON_S_FIRE);
				temporary(id, Data.WEAPON_DURATION);
			break;

			// *** 30. lunettes bleues
			case auto++:
				game.flipX(true);
				temporary(id,Data.SECOND*30);
			break;

			// *** 31. lunettes rouges
			case auto++:
				game.flipY(true);
				temporary(id,Data.SECOND*30);
			break;

			// *** 32. as pique: transforme tous les bads en cristaux
			case auto++:
				var l = game.getBadClearList();
				for (var i=0;i<l.length;i++) {
					l[i].destroy();
					entity.item.ScoreItem.attach(game,l[i].x,l[i].y-Data.CASE_HEIGHT,0,0);
				}
			break;

			// *** 33. as trefle
			case auto++:
				var l = game.getBadClearList();
				for (var i=0;i<l.length;i++) {
					l[i].destroy();
					entity.item.ScoreItem.attach(game,l[i].x,l[i].y-Data.CASE_HEIGHT,0,2);
				}
			break;

			// *** 34. as carreau
			case auto++:
				var l = game.getBadClearList();
				for (var i=0;i<l.length;i++) {
					l[i].destroy();
					entity.item.ScoreItem.attach(game,l[i].x,l[i].y-Data.CASE_HEIGHT,0,5);
				}
			break;

			// *** 35. as coeur
			case auto++:
				var l = game.getBadClearList();
				for (var i=0;i<l.length;i++) {
					l[i].destroy();
					entity.item.ScoreItem.attach(game,l[i].x-Data.CASE_WIDTH,l[i].y-Data.CASE_HEIGHT,0,6);
					entity.item.ScoreItem.attach(game,l[i].x+Data.CASE_WIDTH,l[i].y-Data.CASE_HEIGHT,0,6);
				}
			break;

			// *** 36. Igor supplémentaire
			case auto++:
				player.lives++;
				game.gi.setLives(player.pid, player.lives);
				game.fxMan.attachShine( item.x, item.y-Data.CASE_HEIGHT*0.5 );
			break;

			// *** 37. collier cristal: tir de perles
			case auto++:
				player.changeWeapon(Data.WEAPON_S_ICE);
				temporary(id, Data.WEAPON_DURATION);
			break;

			// *** 38. totem
			case auto++:
				var s = entity.supa.Arrow.attach(game);
				s.setLifeTimer(Data.SUPA_DURATION);
			break;

			// *** 39. stone head: Igor  fait trembler le décor en tombant
			case auto++:
				player.fallFactor = 1.6;
				temporary(id,null);
			break;

			// *** 40-51. signes du zodiac
			case auto++:  getZodiac(id-40) ; break ; // sagittaire
			case auto++:  getZodiac(id-40) ; break ; // capricorne
			case auto++:  getZodiac(id-40) ; break ; // lion
			case auto++:  getZodiac(id-40) ; break ; // taureau
			case auto++:  getZodiac(id-40) ; break ; // balance
			case auto++:  getZodiac(id-40) ; break ; // belier
			case auto++:  getZodiac(id-40) ; break ; // scorpion
			case auto++:  getZodiac(id-40) ; break ; // cancer
			case auto++:  getZodiac(id-40) ; break ; // verseau
			case auto++:  getZodiac(id-40) ; break ; // gemeau
			case auto++:  getZodiac(id-40) ; break ; // poisson
			case auto++:  getZodiac(id-40) ; break ; // vierge

			// *** 52-63. potions du zodiac
			case auto++:  getZodiacPotion(id-40) ; break ; // sagittaire
			case auto++:  getZodiacPotion(id-40) ; break ; // capricorne
			case auto++:  getZodiacPotion(id-40) ; break ; // lion
			case auto++:  getZodiacPotion(id-40) ; break ; // taureau
			case auto++:  getZodiacPotion(id-40) ; break ; // balance
			case auto++:  getZodiacPotion(id-40) ; break ; // belier
			case auto++:  getZodiacPotion(id-40) ; break ; // scorpion
			case auto++:  getZodiacPotion(id-40) ; break ; // cancer
			case auto++:  getZodiacPotion(id-40) ; break ; // verseau
			case auto++:  getZodiacPotion(id-40) ; break ; // gemeau
			case auto++:  getZodiacPotion(id-40) ; break ; // poisson
			case auto++:  getZodiacPotion(id-40) ; break ; // vierge

			// *** 64. arc en ciel: spawn d'extends
			case auto++:
				for (var i=0;i<5;i++) {
					var pt = {
						x	: Std.random(Data.LEVEL_WIDTH),
						y	: Std.random(Data.LEVEL_HEIGHT),
					}
					pt = game.world.getGround(pt.x,pt.y);
					var s = entity.item.SpecialItem.attach( game, pt.x*Data.CASE_WIDTH,pt.y*Data.CASE_HEIGHT, 0, Std.random(7) );
				}
			break;

			// *** 65. bouée canard: points pour chaque bad
			case auto++:
				var l = game.getBadList();
				for (var i=0;i<l.length;i++) {
					if ( (l[i].types&Data.BAD_CLEAR)>0 ) {
						player.getScore( l[i], 2500 );
					}
					else {
						player.getScore( l[i], 600 );
					}

				}
			break;

			// *** 66. cactus: saut donnant des points
			case auto++:
				permanent(id);
			break;

			// *** 67. bague emeraude: tir fleches
			case auto++:
				player.changeWeapon(Data.WEAPON_S_ARROW);
				temporary(id, Data.WEAPON_DURATION);
			break;

			// *** 68. bougie
			case auto++:
				permanent(id);
				game.updateDarkness();
			break;

			// *** 69. tortue: ralentissement bads
			case auto++:
				global(id);
				temporary(id,Data.SECOND*30);
				var l = game.getBadClearList();
				for (var i=0;i<l.length;i++) {
					l[i].updateSpeed();
					l[i].animFactor*=0.6;
				}
			break;

			// *** 70. trefle: kick de bombe donnant des points
			case auto++:
				permanent(id);
			break;

			// *** 71. tete dragon: double fireball horizontale
			case auto++:
				var s;
				s = entity.shoot.PlayerFireBall.attach(game, item.x, item.y);
				s.moveLeft( s.shootSpeed );
				s = entity.shoot.PlayerFireBall.attach(game, item.x, item.y);
				s.moveRight( s.shootSpeed );
			break;

			// *** 72. chapeau magicien: remplace les bads par des cristaux (valeur incrémentale)
			case auto++:
				game.destroyList(Data.ITEM);
				game.destroyList(Data.BAD_BOMB);

				var l = game.getList(Data.BAD_CLEAR);
				var n = 1;
				for (var i=0;i<l.length;i++) {
					var b : entity.Bad = downcast(l[i]);
					entity.item.ScoreItem.attach(game, b.x,b.y, 0, n);
					b.destroy();
					n++;
				}
			break;

			// *** 73. feuille d'arbre: points gagnés en marchant
			case auto++:
				permanent(id);
			break;

			// *** 74. fantome orange: spawn bonbons
			case auto++:
				for (var i=0;i<7;i++) {
					var it = entity.item.ScoreItem.attach(
						game,Std.random(Data.GAME_WIDTH), Data.GAME_HEIGHT,
						3, null
					);
					it.moveToAng(-20-Std.random(160),Std.random(15)+10);
				}
			break;

			// *** 75. fantome bleu
			case auto++:
				for (var i=0;i<7;i++) {
					var it = entity.item.ScoreItem.attach(
						game,Std.random(Data.GAME_WIDTH), Data.GAME_HEIGHT,
						4, null
					);
					it.moveToAng(-20-Std.random(160),Std.random(15)+10);
				}
			break;

			// *** 76. fantome vert
			case auto++:
				for (var i=0;i<7;i++) {
					var it = entity.item.ScoreItem.attach(
						game,Std.random(Data.GAME_WIDTH), Data.GAME_HEIGHT,
						5, null
					);
					it.moveToAng(-20-Std.random(160),Std.random(15)+10);
				}
			break;

			// *** 77. poisson bleu: cristaux bleus à la fin du level
			case auto++:
				var me = game;
				game.endLevelStack.push(
				fun() {
					for (var i=0;i<5;i++) {
						entity.item.ScoreItem.attach(me, Std.random(Data.GAME_WIDTH),-30-Std.random(50), 0,0);
					}
				}
				);
			break;

			// *** 78. poisson rouge
			case auto++:
				var me = game;
				game.endLevelStack.push(
				fun() {
					for (var i=0;i<5;i++) {
						entity.item.ScoreItem.attach(me, Std.random(Data.GAME_WIDTH),-30-Std.random(50), 0,2);
					}
				}
				);
			break;

			// *** 79. poisson jaune
			case auto++:
				var me = game;
				game.endLevelStack.push(
				fun() {
					for (var i=0;i<5;i++) {
						entity.item.ScoreItem.attach(me, Std.random(Data.GAME_WIDTH),-30-Std.random(50), 0,3);
					}
				}
				);
			break;

			// *** 80. escargot: ralentissement bads
			case auto++:
				global(id);
				temporary(id,Data.SECOND*30);
				var l = game.getBadClearList();
				for (var i=0;i<l.length;i++) {
					l[i].updateSpeed();
					l[i].animFactor*=0.3;
				}
			break;

			// *** 81. perle bleue
			case auto++:
				game.destroyList(Data.BAD);
				game.destroyList(Data.ITEM);
				game.destroyList(Data.BAD_BOMB);
				levelConversion(Data.CONVERT_DIAMANT,0);
				temporary(id, Data.SECOND*19);
			break;

			// *** 82. pyramide dorée: strike
			case auto++:
				onStrike();
			break;

			// *** 83. pyramide noire: suite de strikes
			case auto++:
				temporary(id,null);
				registerRecurring( callback(this,onStrike), Data.SECOND, true );
				onStrike();
				game.fxMan.attachBg(Data.BG_PYRAMID,null,9999);
			break;

			// *** 84. talisman pluie de feu
			case auto++:
				var c : {>MovieClip, speed:float};
				c = downcast( game.depthMan.attach("hammer_fx_clouds", Data.DP_SPRITE_BACK_LAYER) );
				c.speed	= 0.5;
				c._y		+= 9;
				clouds.push(c);
				var f = new flash.filters.BlurFilter();
				f.blurX		= 4;
				f.blurY		= f.blurX;
				c.filters = [f];
				c = downcast( game.depthMan.attach("hammer_fx_clouds", Data.DP_SPRITE_TOP_LAYER) );
				c.speed	= 1;
				clouds.push(c);
				temporary(id,null);
				registerRecurring( callback(this,onFireRain), Data.SECOND*0.8, true );
				onFireRain();
				game.fxMan.attachBg(Data.BG_STORM,null,9999);
			break;

			// *** 85. marteau
			case auto++:
				var s = entity.shoot.Hammer.attach(game,player.x,player.y);
				s.setOwner(player);
				temporary(id,null);
			break;

			// *** 86. bonbon fantome: mode ghostbuster, chaque bad donne 666pts
			case auto++:
				var glow = new flash.filters.GlowFilter();
				glow.color		= 0x8cc0ff;
				glow.alpha		= 0.5;
				glow.strength	= 100;
				glow.blurX		= 2;
				glow.blurY		= 2;
				player.filters = [glow];
				temporary(id,Data.SECOND*60);
//				global(id);
				game.fxMan.attachBg(Data.BG_GHOSTS,null,Data.SECOND*57);
				var l = game.getBadList();
				for (var i=0;i<l.length;i++) {
					glow.alpha		= 1.0;
					glow.color		= 0xff5500;
					l[i].filters	= [glow];
				}
			break;

			// *** 87. larve bleue: transforme un bad au hasard en larve bleue
			case auto++:
				var bad = game.getOne(Data.BAD_CLEAR);
				if ( bad!=null ) {
					if ( game.getBadClearList().length==1 ) {
						entity.item.ScoreItem.attach(game, bad.x,bad.y, Data.DIAMANT,null);
					}
					else {
						entity.item.SpecialItem.attach(game, bad.x,bad.y, id,subId);
					}
					game.fxMan.attachShine( bad.x, bad.y-Data.CASE_HEIGHT*0.5 );
					bad.destroy();
				}
			break;

			// *** 88. pokute: curse retrecissement
			case auto++:
				player.curse(Data.CURSE_SHRINK);
				game.fxMan.attachShine(player.x, player.y);
				player.scale(50);
				temporary(id,Data.SECOND*30);
			break;

			// *** 89. oeuf mutant: transforme un bad en une tzongre
			case auto++:
				var e = game.getOne(Data.BAD_CLEAR);
				if ( e!=null ) {
					entity.bad.flyer.Tzongre.attach(game,e.x,e.y-Data.CASE_HEIGHT);
					e.destroy();
				}
			break;

			// *** 90. cornes goldorak: trébuche à la moindre chute
			case auto++:
				temporary(id,Data.SECOND*40);
				player.curse(6);
			break;

			// *** 91. chapeau luffy: curse anti attaque
			case auto++:
				player.curse(Data.CURSE_PEACE);
				game.fxMan.attachShine(player.x, player.y);
				temporary(id,Data.SECOND*15);
			break;

			// *** 92. chapeau rose: duplicateur bombes
			case auto++:
				permanent(id);
			break;

			// *** 93. mailbox: spawn de colis
			case auto++:
				game.destroyList(Data.BAD);
				game.destroyList(Data.ITEM);
				game.destroyList(Data.BAD_BOMB);
				var n=6;
				do {
					var pt = {
						x:Std.random(Data.GAME_WIDTH),
						y:Std.random(Data.GAME_HEIGHT)
					}
					if ( player.distance(pt.x,pt.y) >= 100 ) {
						var e = entity.item.SpecialItem.attach(game,pt.x,pt.y, 101,null);
						e.setLifeTimer(null);
						n--;
					}
				} while (n>0);
			break;

			// *** 94. anneau antok: offre un item à points supplémentaire par level
			case auto++:
				global(id);
				permanent(id);
			break;

			// *** 95. sac à thunes: multiplicateur
			case auto++:
				player.curse(Data.CURSE_MULTIPLY);
				permanent(id);
			break;

			// *** 96. perle orange: conversion
			case auto++:
				game.destroyList(Data.BAD);
				game.destroyList(Data.ITEM);
				game.destroyList(Data.BAD_BOMB);
				levelConversion(Data.CONVERT_DIAMANT,1);
				temporary(id, Data.SECOND*19);
			break;

			// *** 97. perle verte: conversion
			case auto++:
				game.destroyList(Data.BAD);
				game.destroyList(Data.ITEM);
				game.destroyList(Data.BAD_BOMB);
				levelConversion(Data.CONVERT_DIAMANT,2);
				temporary(id, Data.SECOND*19);
			break;

			// *** 98. perle rose: conversion
			case auto++:
				game.destroyList(Data.BAD);
				game.destroyList(Data.ITEM);
				game.destroyList(Data.BAD_BOMB);
				levelConversion(Data.CONVERT_DIAMANT,3);
				temporary(id, Data.SECOND*19);
			break;


			// *** 99. Touffe Chourou: scores réguliers jusqu'a la fin du lvl
			case auto++:
				registerRecurring( callback(this,onPoT), Data.SECOND*2, true );
				player.fl_chourou = true;

				temporary(id,null);
			break;


			// *** 100. poupée guu
			case auto++:
				temporary(id,Data.SECOND*30);
				game.fxMan.attachBg(Data.BG_GUU,null,Data.SECOND*30);
				var mc = game.depthMan.attach("hammer_fx_cloud",Data.DP_PLAYER);
				player.stick(mc,0,-80);
				player.setElaStick(0.4);
			break;


			// *** 101. colis mystérieux
			case auto++:
				if ( Std.random(2)==0 ) {
					player.getScore( item, 5000 );
				}
				else {
					var b = entity.bomb.bad.PoireBomb.attach(game,item.x, item.y);
					b.moveUp(10);
				}
			break;

			// *** 102. carotte !
			case auto++:
				game.world.scriptEngine.playById(100);
				game.huTimer = 0;
				player.getScore(item,4*25000);
//				player.playAnim(Data.ANIM_PLAYER_CARROT);

				player.fl_carot = true;
			break;

			// *** 103. coeur 1
			case auto++:
				player.lives++;
				game.gi.setLives(player.pid, player.lives);
				game.fxMan.attachShine( item.x, item.y-Data.CASE_HEIGHT*0.5 );
				game.randMan.remove(Data.RAND_ITEMS_ID, id);
			break;

			// *** 104. coeur 2
			case auto++:
				player.lives++;
				game.gi.setLives(player.pid, player.lives);
				game.fxMan.attachShine( item.x, item.y-Data.CASE_HEIGHT*0.5 );
				game.randMan.remove(Data.RAND_ITEMS_ID, id);
			break;

			// *** 105. coeur 3
			case auto++:
				player.lives++;
				game.gi.setLives(player.pid, player.lives);
				game.fxMan.attachShine( item.x, item.y-Data.CASE_HEIGHT*0.5 );
				game.randMan.remove(Data.RAND_ITEMS_ID, id);
			break;

			// *** 106. livre champignons
			case auto++:
				for (var i=0;i<5;i++) {
					var s = entity.item.ScoreItem.attach(game,item.x,item.y,1047+Std.random(4),null)
					s.moveFrom(item,8);
				}
			break;

			// *** 107. livre étoiles
			case auto++:
				for (var i=0;i<5;i++) {
					var s = entity.item.ScoreItem.attach(game,item.x,item.y,0,0) // todo: etoile à pts
					s.moveFrom(item,8);
				}
			break;

			// *** 108. parapluie vert
			case auto++:
				warpZone(3);
			break;

			// *** 109. flocon 1
			case auto++:
				game.fxMan.attachShine( item.x, item.y-Data.CASE_HEIGHT*0.5 );
				game.randMan.remove(Data.RAND_ITEMS_ID, id);
			break;

			// *** 110. flocon 2
			case auto++:
				game.fxMan.attachShine( item.x, item.y-Data.CASE_HEIGHT*0.5 );
			break;

			// *** 111. flocon 3
			case auto++:
				game.fxMan.attachShine( item.x, item.y-Data.CASE_HEIGHT*0.5 );
			break;

			// *** 112. pioupiouz
			case auto++:
				player.head = Data.HEAD_PIOU;
				player.replayAnim();
			break;

			// *** 113. cape tuberculoz
			case auto++:
				player.getScore(item,75000);
				player.head = Data.HEAD_TUB;
				player.replayAnim();
			break;

			// *** 114. item mario
			case auto++:
				temporary(id, null);
				player.curse(Data.CURSE_MARIO);
			break;

			// *** 115. volleyfest
			case auto++:
				permanent(id);
			break;

			// *** 116. joyau ankhel
			case auto++:
				player.lives++;
				game.gi.setLives(player.pid, player.lives);
				player.getScore(item, 70000);
			break;

			// *** 117. clé de gordon
			case auto++:
				game.giveKey(12);
				player.getScore(item, 10000);
			break;

			default:
				GameManager.warning("illegal item id="+id);
			break;
		}
	}



	/*------------------------------------------------------------------------
	UN EFFET SE TERMINE
	------------------------------------------------------------------------*/
	function interrupt(id:int) {
		if ( !actives[id] ) {
			return;
		}
		actives[id] = false;
		game.fxMan.clearBg();

		switch (id) {

			// *** 4. lampes or et noire
			case 4: case 5:
				player.maxBombs = player.initialMaxBombs;
			break;

			// *** 7. chaussure
			case 7:
				player.speedFactor = 1.0;
			break;

			case 10:
				phoneMC.removeMovieClip();
			break;

			// *** 18. pissenlit
			case 18:
				player.fallFactor = 1.1;
			break;

			// *** 22. chaussure
			case 22:
				player.speedFactor = 1.0;
				player.unstick();
			break;

			// *** 29. bague or
			case 29:
				if ( player.currentWeapon==Data.WEAPON_S_FIRE) {
					player.changeWeapon(null);
				}
			break;

			// *** 30. lunettes bleues
			case 30:
				game.flipX(false);
			break;

			// *** 31. lunettes rouges
			case 31:
				game.flipY(false);
			break;

			// *** 37. collier cristal
			case 37:
				if ( player.currentWeapon==Data.WEAPON_S_ICE) {
					player.changeWeapon(null);
				}
			break;

			case 39:
				player.fallFactor = 1.1;
			break;

			// *** 67. bague emeraude
			case 67:
				if ( player.currentWeapon==Data.WEAPON_S_ARROW) {
					player.changeWeapon(null);
				}
			break;

			// *** 69. tortue
			case 69:
				game.globalActives[id]=false;
				var l = game.getBadClearList();
				for (var i=0;i<l.length;i++) {
					l[i].updateSpeed();
					l[i].animFactor*=1/0.6;
				}
			break;

			// *** 80. escargot
			case 80:
				game.globalActives[id]=false;
				var l = game.getBadClearList();
				for (var i=0;i<l.length;i++) {
					l[i].updateSpeed();
					l[i].animFactor*=1/0.3;
				}
			break;

			// *** 81. perle bleue
			case 81:
				game.destroyList(Data.PERFECT_ITEM);
//				game.world.scriptEngine.clearScript();
				// source de bug potentielle pour les scripts prévus pour s'exécuter
				// apres la fin du level !
			break;

			// *** 84. talisman pluie de feu
			case 84:
				clearRec();
				for (var i=0;i<clouds.length;i++) {
					clouds[i].removeMovieClip();
				}
				clouds = new Array();
			break;

			// *** 86. bonbon fantome
			case 86:
//				game.globalActives[id]=false;
				var l = game.getBadList();
				for (var i=0;i<l.length;i++) {
					l[i].alpha=100;
					l[i].filters = null;
				}
				player.filters = null;
			break;

			// *** 88. pokute
			case 88:
				player.unstick();
				player.scale(100);
			break;


			// *** 90. Malédiction de goldorak
			case 90:
				player.unstick();
			break;

			// *** 91. chapeau luffy
			case 91:
				player.unstick();
			break;


			// *** 94. anneau antok
			case 94:
				game.globalActives[id]=false;
			break;


			// *** 95. sac à thunes
			case 95:
				player.unstick();
			break;

			// *** 96/97/98. perles (voir commentaire sur 81)
			case 96: case 97: case 98:
				game.destroyList(Data.PERFECT_ITEM);
//				game.world.scriptEngine.clearScript();
			break;

			// *** 99: Touffe Chourou
			case 99:
				player.fl_chourou = false;
				player.replayAnim();
				clearRec();
			break;


			// *** 100. poupée guu
			case 100:
				game.fxMan.attachFx( player.sticker._x, player.sticker._y, "hammer_fx_pop" );
				player.unstick();
				player.scale(100);
			break;

			// *** 114. mode mario
			case 114:
				player.unstick();
			break;
		}
	}


	/*------------------------------------------------------------------------
	EVENT: STRIKE!
	------------------------------------------------------------------------*/
	function onStrike() {
		var blist = game.getList(Data.BAD_CLEAR);

		if ( blist.length==0 || blist==null ) {
			return;
		}

		var bad : entity.Bad;
		var n = 0;
		do {
			bad = downcast(blist[n]);
			n++;
		} while (bad.fl_kill==true)

		if ( bad.fl_kill==false ) {
			var s = game.depthMan.attach("hammer_fx_strike", Data.FX);
			s._x = Data.DOC_WIDTH/2;
			s._y = bad._y-Data.CASE_HEIGHT*0.5;
			var dir = Std.random(2)*2-1;
			s._xscale *= dir;
			s._yscale = Std.random(50)+50;
			game.fxMan.attachShine(bad.x, bad.y);
			bad.forceKill( dir*(Std.random(10)+15) );
		}
	}


	/*------------------------------------------------------------------------
	EVENT: PLUIE DE FEU
	------------------------------------------------------------------------*/
	function onFireRain() {
		var x = Std.random(Math.round(Data.GAME_WIDTH))+50;
		var s = entity.shoot.FireRain.attach(game,x,-Std.random(50));
		s.moveToAng(95+Std.random(30),s.shootSpeed);
	}


	/*------------------------------------------------------------------------
	EVENT: POINTS OVER TIME
	------------------------------------------------------------------------*/
	function onPoT() {
		player.getScore(player, 250);
	}


	/*------------------------------------------------------------------------
	MAIN
	------------------------------------------------------------------------*/
	function main() {

		// Gestion des évènements spéciaux récurrents du niveau
		for (var n=0;n<recurring.length;n++) {
			var e = recurring[n];
			e.timer-=Timer.tmod;
			if ( e.timer<=0 ) {
				e.func();
				// Répétition
				if ( e.fl_repeat ) {
					e.timer = e.baseTimer+e.timer;
				}
				else {
					recurring.splice(n,1);
					n--
				}
			}
		}


		// Ecran de portable
		if ( phoneMC._name!=null ) {
			var d = new Date();
			var str = ""+d.getHours();
			if ( str.length<2 ) str = "0"+str;
			str = str+":";
			if ( d.getMinutes()<10 ) {
				str = str+"0"+d.getMinutes();
			}
			else {
				str = str+d.getMinutes();
			}
			phoneMC.screen.field.text = str;
		}


		// Gestion de durée de vie des temporaires
		for (var i=0;i<tempList.length;i++) {
			if ( game.cycle >= tempList[i].end ) {
				interrupt( tempList[i].id );
				tempList.splice(i,1);
				i--;
			}
		}


	}
}
