package ac ;

import mt.bumdum.Lib;
import Fight ;

class DamagesGroup extends State {

	var f : Fighter ;
	var targets : List<{t : Fighter, life : Int}> ;
	var life : Int ;
	var fxt:_GroupEffect;
	var fx:State;

	public function new(f : Fighter, tt :  List<{t : Fighter, life : Int}> , fxt : _GroupEffect) {
		super();
		this.f = f ;
		this.targets = tt ;
		this.fxt = fxt ;
		addActor(f);
		for ( o in tt )
			addActor(o.t);
	}

	override function init() {
		super.init();
		fx = getFx(fxt);
		if( fx == null ) endSpell()
		else fx.endCall = endSpell;
	}

	function endSpell(){
		//for(o in targets)o.t.damages(o.life,dfx) ;
		end();
	}

	function getFx(fxt){
		var list = [];
		for ( o in targets ) {
			if(  o.life == null ) o.t.launchAnim("special");
			list.push(o);
		}
		//
		var mfx:fx.GroupEffect = null;
		switch(fxt){
			case _GrFireball:			mfx = new fx.gr.Fireball( f, list );
			case _GrBlow:				mfx = new fx.gr.Blow( f, list );
			case _GrLava:				mfx = new fx.gr.Lava( f, list );
			case _GrMeteor:				mfx = new fx.gr.Meteor( f, list );
			case _GrVigne:				mfx = new fx.gr.Vigne( f, list );
			case _GrWaterCanon:			mfx = new fx.gr.WaterCanon( f, list );
			case _GrShower:				mfx = new fx.gr.Shower( f, list, 0 );
			case _GrShower2(type):		mfx = new fx.gr.Shower( f, list, type );
			case _GrLevitRay:			mfx = new fx.gr.LevitRay( f, list );
			case _GrLightning:			mfx = new fx.gr.Lightning( f, list );
			case _GrCrepuscule:			mfx = new fx.gr.Crepuscule( f, list );
			case _GrMistral:			mfx = new fx.gr.Mistral( f, list );
			case _GrTornade:			mfx = new fx.gr.Tornade( f, list );
			case _GrDisc:				mfx = new fx.gr.Disc( f, list );
			case _GrHole:				mfx = new fx.gr.Hole( f, list );
			case _GrIce:				mfx = new fx.gr.Ice( f, list );
			case _GrProjectile(type,move,speed):	mfx = new fx.gr.Projectile( f, list, type, move, speed );
			case _GrTremor:				mfx = new fx.gr.Tremor( f, list );
			case _GrJumpAttack(type):	mfx = new fx.gr.JumpAttack( f, list, type );
			case _GrChainLightning:		mfx = new fx.gr.ChainLightning( f, list );
			case _GrHeal(type):			mfx = new fx.gr.Heal( f, list, type );
			case _GrCharge:				mfx = new fx.gr.Charge( f, list );
			case _GrAnim(anim):			mfx = new fx.gr.Anim(f, list, anim);
			case _GrInvoc(link):		mfx = new fx.gr.Invoc(f, list, link);
			case _GrSylfide:			mfx = new fx.gr.Sylfide(f, list);
			case _GrRafale(link,power,speed):
										mfx = new fx.gr.Rafale(f, list, link, power, speed);
			case _GrTodo:
				mfx = new fx.gr.Fireball( f, list );
				trace("DEFAULT_FX");
			default :	trace("Unknown fx("+Type.enumIndex(fxt)+")");
		}
		return mfx;
	}
}



































