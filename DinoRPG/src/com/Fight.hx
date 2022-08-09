// COMMON FIGHT DATA STRUCTURES

typedef FighterInfos = {
	var _fid : Int;
	var _side : Bool;
	var _name : String;
	var _life : Int;
	var _size : Int;
	var _gfx : String;
	var _dino : Bool;
	var _props : Array<_Property>;
}

enum _Property {
	_PBoss;
	_PStatic;
	_PGroundOnly;
	_PDark;
	_PNothing;
	// **** insérer ICI *****
}

enum _LifeEffect {
	_LNormal; // assault and counters
	_LObject;
	_LSkull(size:Float);
	_LAcid;
	_LPoison;
	_LHeal;
	_LExplode;
	_LBurn(max:Int);
	_LFire;
	_LWood;
	_LWater;
	_LLightning;
	_LAir;
	_LGold;
	// **** insérer ICI *****
	_LTodo;
}

// EFFET ASSAUTS
enum _Effect {
	_EBack;
	_ECounter;
	_EDrop;
	_EEject;
	_EFlyCancel;
	_EIntangCancel;
	_EIntangBreak;
	_EMissed;
	// **** insérer ICI *****
}

enum _GroupEffect {
	_GrFireball;
	_GrLava;
	_GrBlow;
	_GrMeteor;
	_GrVigne;
	_GrWaterCanon;
	_GrShower;
	_GrLevitRay;
	_GrLightning;
	_GrCrepuscule;
	_GrMistral;
	_GrTornade;
	_GrDisc;
	_GrHole;
	_GrIce;
	_GrProjectile( type:String, ?move:String, ?speed:Float );
	_GrShower2( type : Int );
	_GrTremor;
	_GrChainLightning;
	_GrDeluge;
	_GrHeal(type:Int);
	_GrCharge;
	_GrJumpAttack( type:String );
	_GrNone;
	_GrAnim(link:String);
	_GrInvoc(link:String);
	_GrSylfide;
	_GrRafale(link:String, power:Int, speed:Float);
	// **** insérer ICI *****
	_GrTodo;
}

enum _SuperEffect {
	_SFAura( fid:Int, color:Int, ?frame:Int );
	_SFSnow( fid:Int, frame:Int, ?glowColor:Int, ?rainbowPercent:Int );
	_SFSwamp( fid:Int );
	_SFCloud( fid:Int, type:Int, col:Int );
	_SFFocus( fid:Int, color:Int );
	_SFDefault( fid:Int );
	_SFAura2( fid:Int, color:Int, ?frame:Int, ?type : Int );
	_SFAttach( fid:Int, link : String );
	_SFHypnose( fid:Int, tid:Int );
	_SFSpeed( fid:Int, a:Array<Int> );
	_SFEnv7( frame : Int, destroy : Bool );
	_SFAnim( fid:Int, link:String );
	_SFRay( fid:Int );
	_STired( fid:Int);
	_SFRandom( fid:Int, frame:String, ok:Bool );
	_SFAttachAnim( fid:Int, anim:String, ?frame:String );
	_SFLeaf( fid:Int, link:String );
	_SFMudWall( fid:Int, remove:Bool );
	_SFBlink( fid:Int, color:Int, alpha:Int );
	_SFGenerate( fid:Int, color:Int, strength:Float, radius:Float );
	// **** insérer ICI *****
}

enum _GotoEffect {
	_GNormal;
	_GSpecial( col:Int,col2:Int );
	_GOver;
	// **** insérer ICI *****
	_GTodo;
}

enum _History {
	_HAdd( f : FighterInfos, ?fxt : _AddFighterEffect );
	_HAnnounce( fid : Int, skill : String );
	_HObject( fid : Int, name : String, oid : String );
	_HLost( fid : Int, life : Int, fx : _LifeEffect );
	_HStatus( fid : Int, s : _Status );
	_HNoStatus( fid : Int, s : _Status );
	_HRegen( fid : Int, life : Int, fx : _LifeEffect );
	_HDamages( fid : Int, tid : Int, life : Null<Int>, l : _LifeEffect, ?fx : _Effect );
	_HDamagesGroup( fid : Int, tids : List<{ _tid : Int, _life : Null<Int> }>, fx : _GroupEffect );
	_HFx( fx : _SuperEffect );
	_HDead( fid : Int );
	_HGoto( fid : Int, tid : Int, fx : _GotoEffect );
	_HReturn( fid : Int );
	_HPause( time : Int );
	_HFinish( bh0:_EndBehaviour, bh1:_EndBehaviour );
	_HAddCastle( c : CastleInfos );
	_HTimeLimit( t : Int );
	_HCastleAttack( fid : Int, life : Int, ?fx : _CastleEffect );
	_HDisplay( ?fx : _DisplayEffect );
	_HText( txt : String );
	_HTalk( fid : Int, txt : String );
	_HEscape( fid : Int );
	_HMoveTo(fid:Int, x:Int, y:Int);
	_HFlip(fid:Int);
	_SpawnToy(tid:Int, x:Int, y:Int, ?z:Int, ?vx:Float, ?vy:Float, ?vz:Float);
	_DestroyToy(tid:Int);
	_HWait(ms:Int);
	_HLog(log:String);
	_HNotify(lid:List<Int>, n:_Notification);
	_HEnergy(fids:Array<Int>, energies:Array<Int>);
	_HMaxEnergy(fids:Array<Int>, energies:Array<Int>);
	// **** insérer ICI *****
}

enum _EndBehaviour {
	_EBStand;
	_EBRun;
	_EBEscape;
	_EBGuard;
	// **** insérer ICI *****
}

enum _Status {
	_SSleep;
	_SFlames;
	_SIntang;
	_SFly;
	_SSlow;
	_SQuick;
	_SStoned;
	_SShield;
	_SBless;
	_SPoison(pow:Int);
	_SHeal(pow:Int);
	_SBurn(pow:Int);
	_SMonoElt(elt:Int);
	_SDazzled(pow:Int);
	_SStun;
	// **** insérer ICI *****
}

enum _Notification {
	_NSlow;// malus de VITESSE permanent
	_NQuick;// bonus de VITESSE permanent
	_NSilence;// restriction d'INVOCATION
	_NSharignan;// peut copier des TECHNIQUES
	_NNoUse;// restriction d'INVENTAIRE
	_NDown;// malus en RECUPERATION, ENERGIE, ENDURANCE
	_NUp;// bonus en RECUPERATION, ENERGIE, ENDURANCE
	_NFire;// bonus de DEFENSE feu
	_NWood;// bonus de DEFENSE bois
	_NWater;// bonus de DEFENSE eau (invocation baleine blanche)
	_NThunder;// bonus de DEFENSE foudre (invocation golem)
	_NAir;// bonus de DEFENSE air (?)
	_NInitUp;// bonus d'INITIATIVE (invocation bénédiction des fées)
	_NInitDown;// malus d'INITIATIVE
	_NSnake;// bonus d'ESQUIVE (invocation roi des singes)
	_NStrong;// bonus en DEFENSE (invocation bouddha)
	_NShield;// Dinoz protégé par un autre
	_NMonoElt;// Dinoz bloqué sur un élément
	// **** insérer ICI *****
	_NTodo;
}

enum _AddFighterEffect {
	_AFStand;
	_AFJump;
	_AFRun;
	_AFGrow;
	_AFFall;
	_AFGround;
	_AFPos(x:Int, y:Int, ?aft:_AddFighterEffect);
	_AFAnim(link:String);
	// **** insérer ICI *****
}

enum _CastleEffect {
	// **** insérer ICI *****
}

typedef CastleInfos = {
	var _life : Int;
	var _max : Int;
	var _cage : Null<String>; // type de monstres null = rien
	var _ground : Int; // 0 : rien, n:frame de decor sol sous-devant le chateau
	var _armor : Int; // 0 : rien, n:frame du renfort
	var _repair : Int; // 0:rien, n:frame du gobelin *
	var _color : Int;
	var _invisible : Bool;
}

enum _DisplayEffect {
	// **** insérer ICI *****
}

typedef _Data = {
	var _dino : String;
	var _sdino : String;
	var _smonster : String;
	var _equip : String;
	var _bg : String;
	var _debrief : String;
	var _mtop : Int;
	var _mbottom : Int;
	var _mright : Int;
	var _ground : String;
	var _history : List<_History>;
	var _check : String;
	var _dojo : String;
	
	@:optional var _debug : String;
}
