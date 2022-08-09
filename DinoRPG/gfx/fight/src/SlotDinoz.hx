import Scene;

import mt.bumdum.Lib;
import mt.kiroukou.motion.Tween.TFx;
using mt.kiroukou.motion.Tween;
class SlotDinoz {

	var loaded:Int;
	var id:Int;
	var sens:Int;
	var bx:Float;
	var by:Float;
	var damageTimer:Float;
	var fighter:Fighter;
	var body:flash.MovieClip;
	
	public var root: { > flash.MovieClip,
		bar:flash.MovieClip,
		bar2:flash.MovieClip,
		_hit:flash.MovieClip,
		_energy:flash.MovieClip,
		_maxEnergy:flash.MovieClip,
		skin: { > flash.MovieClip,
			_init:String->Int->Bool->Void
		}
	};
	
	var col:Column;
	public function new(id, f:Fighter) {

		this.id = id;
		this.col = Scene.me.columns[id];
		root = cast col.dm.attach("mcSlotDinoz", 0);
		root._visible = Main.me.flDisplay;

		root._x = -(id * 2 - 1) * ((f.intSide == 1) ? 3 : 10);
		root._y = 3 + 40 * col.slots.length;
		Filt.glow(root, 2, 8, 0x6A4F26);
		col.slots.push(this);
		root.bar2._visible = false;
		sens = 1;

		if(f == null) {
			setLife( Main.me.castle.life / Main.me.castle.max );
			var mc = new mt.DepthManager(root.skin).attach("mcCastle", 0);
			mc._x = 28;
			mc._y = -15;
			mc._xscale = mc._yscale = 40;
			var mc:flash.MovieClip = cast(mc).wall;
			mc.stop();
			return;
		}

		fighter = f;
		setLife( f.life / f.lifeMax );
		if( f.energy != null ) {
			setMaxEnergy(f.maxEnergy);
			setEnergy(f.energy);
		} else {
			hideEnergyBar();
		}
		f.slot = this;
		
		if( f.isDino ) {
			var margin = 10;
			var side = 36;
			Main.me.photomaton.setSkin(fighter.gfx);
			var bmp = Main.me.photomaton.getPortrait(side,margin);
			root.skin.attachBitmap(bmp,0);
			var sens = -fighter.intSide;
			root.skin._x = -margin + (fighter.intSide+1) * 0.5 * (side + 2 * margin);
			root.skin._y = -margin;
			root.skin._xscale = sens * 100;
		} else {
			root._visible = false;
		}
	}

	public function update() {
		if( damageTimer != null ) {
			sens = -sens;
			damageTimer -= mt.Timer.tmod;
			if(damageTimer < 0) damageTimer = 0;

			root.skin._x = bx + Math.random() * damageTimer * sens;
			if( damageTimer < 5 ) {
				root.bar2._yscale += (root.bar._yscale - root.bar2._yscale) * 0.5;
			}
			if( damageTimer == 0 ) {
				damageTimer = null;
				Col.setColor( root.skin, 0, 0);
			}
		}
		//if( fighter.energy != null )
		//	root.hit._yscale = root.hit._yscale + (root.energy._yscale - root.hit._yscale) * 0.5;
	}

	public function setLife(c:Float) {
		root.bar2._yscale = root.bar._yscale;
		root.bar._yscale = c*100;
	}

	public function setMaxEnergy( e : Int ) {
		root._maxEnergy.tween(TFx.TEaseOut).to( 0.5, _yscale = (200 - e) );
	}
	
	public function setEnergy(e:Int) {
		root._hit._yscale = root._energy._yscale;
		root._hit.tween(TFx.TEaseOut).to( 0.5, _yscale = e );
		root._energy._yscale = e;
	}
	
	public function hideEnergyBar() {
		root._hit._visible = false;
		root._energy._visible = false;
		root._maxEnergy._visible = false;
	}
	
	public function fxDamage() {
		damageTimer = 15;
		Col.setColor( root.skin, 0xFF0000 );
		root.bar2._visible = true;
	}
}