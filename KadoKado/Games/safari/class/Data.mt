class Data {

  // *** DEPTHS
  static var uniq=0 ;
  static var DP_BG = uniq++ ;
  static var DP_SHADOW = uniq++ ;
  static var DP_CAR_BODY = uniq++ ;
  static var DP_CAR_DRAW = uniq++ ;
  static var DP_CAR_WHEEL = uniq++ ;
  static var DP_TARGET = uniq++ ;
  static var DP_FX = uniq++ ;
  static var DP_INTERF = uniq++ ;

  static var uniqTarget=0 ;
  static var DRONE = uniqTarget++ ;
  static var BIG = uniqTarget++ ;
  static var WARPER = uniqTarget++ ;
  static var OPTION = uniqTarget++ ;

  static var PROBA_SPAWN = 100 ;
  static var PROBA_BIG = 35 ;
  static var PROBA_DRONE = 900 ;
  static var PROBA_WARPER = 100 ;


  // *** SCROLLER
  static var SLICES = 26 ;
  static var SLICE_HEIGHT = 2 ;
  static var MIN_SPEED = 3 ;
  static var SCROLLER_SPEED = 19.0;

  static var GROUND_Y = 280 ;
  static var GROUND_SPEED = 0.9 ;

  // *** GAMEPLAY
  static var GRAVITY = 2 ;
  static var COMBO_TIMER = 30 ;
  static var LEVELING_SPEED = 0.0010// 0.0009;
  static var MAX_WARP = 8 ;
  static var SHOCKWAVE_FACTOR = 3 ;
  static var MIN_TARGETS = 2 ;
  static var MAX_MISSES = 3 ;
  static var MULTI_TIMER = 300 ;

  // *** CAR
  static var CAR_X = 190 ;
  static var CAR_WIDTH = 50 ;
  static var BODY_Y = 15 ;
  static var WHEEL_SCALE = 100 ;
  static var CANON_X = -10 ;
  static var CANON_Y = -55 ;

  static var AMMO = 12 ;
  static var AMMO_X = 5 ;
  static var AMMO_Y = 295 ;
  static var AMMO_WIDTH = 7 ;
  static var RELOAD = 1.5 ;
  static var HEAT = 3 ;

  // *** FX
  static var SMOKE = 1 ;
  static var EXPLOSION = 2 ;
  static var SHOCKWAVE = 3 ;
  static var GIB_MISC = 1 ;
  static var GIB_DRONE = 2 ;
  static var GIB_BIG = 3 ;
  static var GIB_WARPER = 4 ;
  static var GIB_OPTION = 5 ;

  static var C25 = KKApi.const(25);
}
