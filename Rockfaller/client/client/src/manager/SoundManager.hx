package manager ;

import data.Settings;
import mt.flash.Sfx;

import Common;
import Protocol;

import data.LevelDesign;

/**
 * ...
 * @author Tipyx
 */

class SoundManager
{
	#if cpp
		static var SBANK 			= Sfx.importFromAssets("sfxOgg");
	#else
		static var SBANK 			= Sfx.importFromAssets("sfx_low");
	#end

	static var sMenu			: mt.flash.Sfx;
	static var sGame			: mt.flash.Sfx;
	static var sWin				: mt.flash.Sfx;
	static var sLose			: mt.flash.Sfx;

	static var arHover			: Array<mt.flash.Sfx>;
	static var sPopIn			: mt.flash.Sfx;
	static var sPopOut			: mt.flash.Sfx;
	static var sStar1			: mt.flash.Sfx;
	static var sStar2			: mt.flash.Sfx;
	static var sStar3			: mt.flash.Sfx;
	static var sLifeLost		: mt.flash.Sfx;

	static var sLoot			: mt.flash.Sfx;
	static var sLootText		: mt.flash.Sfx;

	static var arRockPop		: Array<mt.flash.Sfx>;
	static var arCombo			: Array<mt.flash.Sfx>;
	static var sMoves			: mt.flash.Sfx;
	static var sIce				: mt.flash.Sfx;
	static var sBubblePop		: mt.flash.Sfx;
	static var sBubbleExplode	: mt.flash.Sfx;
	static var sBlocBreak		: mt.flash.Sfx;
	static var sSelectRocks		: mt.flash.Sfx;
	static var sUnselectRocks	: mt.flash.Sfx;
	static var sBombIgnite		: mt.flash.Sfx;
	static var sBombPop			: mt.flash.Sfx;
	static var sBombLine		: mt.flash.Sfx;
	static var sBombPlus		: mt.flash.Sfx;
	static var sBombColor		: mt.flash.Sfx;
	static var sGoldExplode		: mt.flash.Sfx;
	static var sBombCiv			: mt.flash.Sfx;
	static var sGeyser			: mt.flash.Sfx;
	static var arFallRocks		: Array<mt.flash.Sfx>;
	static var sShakingRock		: mt.flash.Sfx;
	static var arRotation		: Array<mt.flash.Sfx>;
	static var arRockRollOver	: Array<mt.flash.Sfx>;

#if mBase
	static var volume_music				: Float		= 1;
#else
	static var volume_music				: Float		= 0.5;
#end
	static var volume_sfx				: Float		= 1;
	static var volume_hover				: Float		= 0.5;
	static var volume_moves				: Float		= 0.25;

	static var isDownloading			: Bool		= false;
	static var isMusicMenuReady			: Bool		= false;
	static var isMusicGameReady			: Bool		= false;

	static var delayer					: mt.Delayer;
	static var numTry					: Int;

	public static function CREATE_PART_1() {
		delayer = new mt.Delayer(Settings.FPS);
		numTry = 1;

	#if cpp
		isMusicMenuReady = true;
		isMusicGameReady = true;
		sMenu = SBANK.Rockfaller_interface();
		sGame = SBANK.Rockfaller_ingame();
	#else
		if( sMenu == null )
			sMenu = SBANK.empty();
		if( sGame == null )
			sGame = SBANK.empty();
	#end
		sWin = SBANK.Rockfaller_WIN();
		sLose = SBANK.Rockfaller_LOST();
	}
	
	public static function CREATE_PART_2(){		
		arHover = [SBANK.hover1(), SBANK.hover2(), SBANK.hover3(), SBANK.hover4()];
		sPopIn = SBANK.panneau_in();
		sPopOut = SBANK.panneau_out();
		sStar1 = SBANK.stars_1();
		sStar2 = SBANK.stars_2();
		sStar3 = SBANK.stars_3();
		sLifeLost = SBANK.life_lost();
		
		sLoot = SBANK.treasure();
		sLootText = SBANK.treasure_text();
		
		arRockPop = [SBANK.new1(), SBANK.new2(), SBANK.new3()];
	}
	
	public static function CREATE_PART_3(){
		arCombo = [SBANK.combo1(), SBANK.combo2(), SBANK.combo3(), SBANK.combo4(), SBANK.combo5(), SBANK.combo6(), SBANK.combo7(), SBANK.combo8(), SBANK.combo9()];
		sMoves = SBANK.compteur_moves();
		sIce = SBANK.ice_explose();
		sBubblePop = SBANK.bubble_appear();
		sBubbleExplode = SBANK.bubble_pop();
		sBlocBreak = SBANK.rock_break();
		sSelectRocks = SBANK.ingame_press();
		sUnselectRocks = SBANK.ingame_release();
		sBombPop = SBANK.blue_bomb_appear();
		sBombIgnite = SBANK.blue_bomb_explose();
		sBombLine = SBANK.bonus_line();
		sBombPlus = SBANK.bonus_cross();
		sBombColor = SBANK.bonus_explose_one();
		sGoldExplode = SBANK.gold_break();
		sBombCiv = SBANK.bombeCiv();
		sGeyser = SBANK.geyser();
	}
	
	public static function CREATE_PART_4(){
		arFallRocks = [SBANK.chute01(), SBANK.chute02(), SBANK.chute03(), SBANK.chute04(), SBANK.chute05(), SBANK.chute06(), SBANK.chute07(), SBANK.chute08(), SBANK.chute09(), SBANK.chute10()];
		sShakingRock = SBANK.rocks_rumble_loop();
	}
	
	public static function CREATE_PART_5(){
		arRotation = [SBANK.rotation1(), SBANK.rotation2(), SBANK.rotation3(), SBANK.rotation4(), SBANK.rotation5(), SBANK.rotation6()];
		arRockRollOver = [SBANK.rocks_mouseover1(), SBANK.rocks_mouseover2(), SBANK.rocks_mouseover3(), SBANK.rocks_mouseover4(), SBANK.rocks_mouseover5(), SBANK.rocks_mouseover6()];
		//arRollOver = [SBANK.hover1(), SBANK.hover2(), SBANK.hover3(), SBANK.hover4()];
		
		//mt.flash.EventTools.listen(flash.Lib.current.stage, flash.events.FocusEvent.FOCUS_IN, function (e) { trace("trololo"); });
		//mt.flash.EventTools.listen(flash.Lib.current.stage, flash.events.Event.MOUSE_LEAVE, function (e) { trace("trolola"); });
	}

	static function initDownloads() {
		if (Settings.INIT_CLIENT != null) {
			Sfx.SHOW_PROGRESS_BARS = false;
			if (!isMusicMenuReady) {
				sMenu = new mt.flash.Sfx(null);
				trace("init downloading menu music");
				isDownloading = true;
				Sfx.download(sMenu, Settings.INIT_CLIENT.urlSounds + "Rockfaller_interface.mp3", function(sfx) {
					sMenu.setVolume(volume_music);
					isMusicMenuReady = true;
					isDownloading = false;
					numTry = 1;
				}, function (str) {
					delayer.addFrameBased("", function () {
						isDownloading = false;
						numTry++;
					}, numTry * 15 * Settings.FPS);
				});
			}
			else if (!isMusicGameReady) {
				sGame = new mt.flash.Sfx(null);
				trace("init downloading game music");
				isDownloading = true;
				Sfx.download(sGame, Settings.INIT_CLIENT.urlSounds + "Rockfaller_ingame.mp3", function(sfx) {
					sGame.setVolume(volume_music);
					isMusicGameReady = true;
					isDownloading = false;
					numTry = 1;
				}, function (str) {
					delayer.addFrameBased("", function () {
						isDownloading = false;
						numTry++;
					}, numTry * 15 * Settings.FPS);
				});
			}
		}
	}

	public static function SET_VOLUME(vol:Int = -1) {
		if (Common.HAS_FLAG(LevelDesign.USER_DATA, UserFlags.UFMusic)) {
			volume_music = 0.5;
		}
		else {
			volume_music = 0;
		}
		
		if (Common.HAS_FLAG(LevelDesign.USER_DATA, UserFlags.UFSFX)) {
			volume_sfx = 1;
			volume_hover = 0.5;
			volume_moves = 0.25;
		}
		else {
			volume_sfx = 0;
			volume_hover = 0;
			volume_moves = 0;
		}
		
		if (sMenu != null && sMenu.isPlaying()) sMenu.setVolume(volume_music);
		if (sGame != null && sGame.isPlaying()) sGame.setVolume(volume_music);
		if (sWin != null && sWin.isPlaying()) sWin.setVolume(volume_music);
		if (sLose != null && sLose.isPlaying()) sLose.setVolume(volume_music);
	}

	// MUSIC
	public static function PLAY_MENU_MUSIC() {
		STOP_GAME_MUSIC();
		STOP_WIN_JINGLE();
		STOP_LOSE_JINGLE();
		if (!sMenu.isPlaying()) sMenu.playLoop(999999, volume_music);
	}

	public static function STOP_MENU_MUSIC() {
		if (sMenu.isPlaying()) sMenu.stop();
	}

	public static function PLAY_GAME_MUSIC() {
		STOP_MENU_MUSIC();
		STOP_WIN_JINGLE();
		STOP_LOSE_JINGLE();
		if (!sGame.isPlaying()) sGame.playLoop(999999, volume_music);
	}

	public static function STOP_GAME_MUSIC() {
		if (sGame.isPlaying()) sGame.stop();
	}

	public static function PLAY_WIN_JINGLE() {
		STOP_GAME_MUSIC();
		if (!sWin.isPlaying()) sWin.playLoop(1, volume_music);
	}

	public static function STOP_WIN_JINGLE() {
		if (sWin.isPlaying()) sWin.stop();
	}

	public static function PLAY_LOSE_JINGLE() {
		STOP_GAME_MUSIC();
		if (!sLose.isPlaying()) sLose.playLoop(1, volume_music);
	}

	public static function STOP_LOSE_JINGLE() {
		if (sLose.isPlaying()) sLose.stop();
	}

	// SFX
	public static function POPIN_SFX(hp:mt.deepnight.deprecated.HProcess) {
		hp.delayer.addFrameBased("", function () {
			sPopIn.play(volume_sfx);				
		}, Settings.FPS / 4);
	}

	public static function POPOUT_SFX() {
		sPopOut.play(volume_sfx);
	}

	public static function STARS1_SFX() {
		if (!sStar1.isPlaying()) sStar1.play(volume_sfx);
	}

	public static function STARS2_SFX() {
		if (!sStar2.isPlaying()) sStar2.play(volume_sfx);
	}

	public static function STARS3_SFX() {
		if (!sStar3.isPlaying()) sStar3.play(volume_sfx);
	}

	public static function LIFE_LOST_SFX() {
		sLifeLost.play(volume_sfx);
	}

	public static function TREASURE_SFX() {
		sLoot.play(volume_sfx);
	}

	public static function TREASURE_TEXT_SFX() {
		sLootText.play(volume_sfx);
	}

	public static function SHOOTING_STAR_SFX() {
		SBANK.etoile_filante().play(volume_moves);
	}

	public static function POP_ROCK_SFX() {
		arRockPop[Std.random(arRockPop.length)].play(volume_sfx);
	}

	public static function COLLECT_SFX() {
		SBANK.collect_element().play(volume_moves);
	}

	public static function GOLD_EXPLODE_SFX() {
		if (!sGoldExplode.isPlaying())
			sGoldExplode.play(volume_sfx);
	}

	public static function BOMB_CIV_EXPLODE_SFX() {
		if (!sBombCiv.isPlaying())
			sBombCiv.play(volume_sfx);
	}

	public static function BOMB_POP_SFX() {
		//if (!sBombPop.isPlaying())
			sBombPop.play(volume_sfx);
	}

	public static function BOMB_EXPLODE_SFX() {
		if (sBombIgnite.isPlaying())
			sBombIgnite.stop();
		sBombIgnite.play(volume_sfx);
	}

	public static function BOMB_HOR_VER_SFX() {
		if (sBombLine.isPlaying())
			sBombLine.stop();
		sBombLine.play(volume_sfx);
		SBANK.bonus_line_ignit().play(volume_sfx);
	}

	public static function BOMB_CROSS_PLUS_SFX() {
		if (sBombPlus.isPlaying())
			sBombPlus.stop();
		sBombPlus.play(volume_sfx);
		SBANK.bonus_cross_ignit().play(volume_sfx);
	}

	public static function BOMB_COLOR_SFX() {
		if (sBombColor.isPlaying())
			sBombColor.stop();
		sBombColor.play(volume_sfx);
	}

	public static function ICE_EXPLODE_SFX() {
		if (!sIce.isPlaying())
			sIce.play(volume_sfx);
	}

	public static function BUBBLE_EXPLODE_SFX() {
		if (!sBubbleExplode.isPlaying())
			sBubbleExplode.play(volume_sfx);
	}

	public static function BUBBLE_POP_SFX() {
		if (!sBubblePop.isPlaying())
			sBubblePop.play(volume_sfx);
	}

	public static function BLOC_BREAKABLE_SFX() {
		if (!sBlocBreak.isPlaying())
			sBlocBreak.play(volume_hover);
	}

	public static function LAVA_SFX() {
		SBANK.lava().play(volume_sfx);
	}

	public static function COMBO_SFX(v:Int) {
		if (v > 8)
			v = 8;
		arCombo[v].play(volume_sfx);
	}

	public static function BOMB_CIV_SFX() {
		if (!sMoves.isPlaying())
			sMoves.play(volume_moves);
	}

	public static function ADD_MOVES_SFX() {
		SBANK.bonus_moves().play(volume_sfx);
	}

	public static function SCORE_LOOP_SFX() {
		SBANK.score_loop().play(volume_moves);
	}

	public static function SELECT_ROCKS_SFX() {
		if (!sSelectRocks.isPlaying()) sSelectRocks.play(volume_sfx);
	}

	public static function UNSELECT_ROCKS_SFX() {
		if (!sUnselectRocks.isPlaying()) sUnselectRocks.play(volume_sfx);
		if (sShakingRock.isPlaying()) sShakingRock.stop();
	}

	public static function FALL_ROCK_SFX() { // TODO
		arFallRocks[Std.random(arFallRocks.length)].play(volume_sfx);
	}

	public static function SHAKING_ROCKS_SFX() {
		if (!sShakingRock.isPlaying()) sShakingRock.play(volume_sfx);
	}

	public static function ROTATION_ROCKS_SFX() {
		arRotation[Std.random(arRotation.length)].play(volume_sfx);
	}

	public static function ROLLOVER_ROCKS_SFX() {
		arRockRollOver[Std.random(arRockRollOver.length)].play(volume_sfx);
	}

	public static function PICKAXE_SFX() {
		SBANK.piolet().play(volume_sfx);
	}

	public static function LOOT_SFX() {
		SBANK.taupi_loot().play(volume_sfx);
	}

	public static function TAUPI_GO_UP_SFX() {
		SBANK.taupi_monte().play(volume_sfx);
	}

	public static function TAUPI_GO_DOWN_SFX() {
		SBANK.taupi_gameover().play(volume_sfx);
	}

	public static function TAUPI_MOVE_SFX() {
		SBANK.taupi_move().play(volume_moves);
	}

	public static function HOVER_BTN_SFX() {
		arHover[Std.random(arHover.length)].play(volume_hover);
	}

	public static function CLOUDS_SFX() {
		SBANK.nuages().play(volume_sfx);
	}

	public static function GEYSER_SFX() {
		sGeyser.play(volume_sfx);
	}

	public static function UPDATE() {
		if (!isDownloading && (!isMusicMenuReady || !isMusicGameReady)) {
			initDownloads();
		}
	}
}
