import api.AKApi;
import api.AKProtocol;

class Contract {
	
	static var count = 0;

	var mc : gfx.Objectif;
	var finished : Bool;

	function new(){
	}

	public function init(){
		var i = count++;
		mc = new gfx.Objectif();
		mc.x = 13 + (mc.width+14) * i;
		mc.y = Game.H + 2;//428;
		Game.me.dm.add(mc,Game.DP_UI);
		new mt.fx.Sleep( new mt.fx.Tween(mc,mc.x,428), null, 10+i*25 );

		finished = false;

		mc.gotoAndStop(1);
		mc._txt.selectable = false;

		mc.filters = [
			new flash.filters.GlowFilter( 0xEEC55F, 1, 1.2, 1.2, 100 )
		];

		updateDescription();
		check();
	}

	public function isDone() : Bool {
		return false;
	}

	public function onGroup( group : Group ) : Void {
		check();
	}

	public function onValidate( points : api.AKConst ) : Void {
		check();
	}

	function description(){
		return "TODO";
	}

	function updateDescription(){
		this.mc._txt.text = description();
	}

	function check(){
		if( finished )
			return;
		if( isDone() ){
			finished = true;

			function upd(){
				updateDescription();
				mc.gotoAndStop(2);

				mc.filters = [
					new flash.filters.GlowFilter( 0x6AC24D, 1, 1.2, 1.2, 100 )
				];

			}
			new mt.fx.Sleep( new mt.fx.Flash( mc ), upd, 10 );
		}
	}

	function flash(){
		new mt.fx.Sleep( new mt.fx.Flash( mc ), updateDescription, 10 );
	}
}

// Faire X combo de Y triangles
// Faire X combo de Y couleurs différentes
// Faire X combo de Y triangles d'une seule couleur
// Faire X combo de Y triangles [COULEUR]

// Faire X points

class Combo extends Contract {
	
	var nbCombo : api.AKConst;
	var nbGroups : api.AKConst;
	var nbColors : Null<api.AKConst>;
	var colorId : Null<api.AKConst>;
	var done : mt.flash.Volatile<Int>;
	
	public function new( nbCombo, nbGroups : Int, ?nbColors, specificColor = false ){
		super();
		this.nbCombo = AKApi.const(nbCombo);
		this.nbGroups = AKApi.const(nbGroups);
		if( nbColors != null )
			this.nbColors = AKApi.const(nbColors);
		if( nbColors != null && nbColors == 1 && specificColor )
			this.colorId = AKApi.const( Game.me.seed.random( Game.MAX_ID.get() ) );
		this.done = 0;
	}

	public override function init(){
		super.init();
		if( nbColors == null )
			mc._icon.gotoAndStop( 2 );
		else if( nbColors.get() == 1 && colorId == null )
			mc._icon.gotoAndStop( 4 );
		else if( colorId != null )
			mc._icon.gotoAndStop( 5 + colorId.get() );
		else
			mc._icon.gotoAndStop( 3 );		
	}

	public override function onValidate( pts ){
		function upd(){
			if( Game.me.groups != nbGroups.get() )
				return false;
			if( nbColors != null && Game.me.colors.length != nbColors.get() )
				return false;
			if( colorId != null && Game.me.colors[0] != colorId.get() )
				return false;
			return true;
		}
		if( done < nbCombo.get() && upd() ){
			done++;
			flash();
		}
		check();
	}

	public override function isDone(){
		return done >= nbCombo.get();
	}

	public override function description(){
		var d = done==0 ? "" : (done + " /  ");
		if( nbColors == null )
			return Text.contract_simple({_done: d, _nbCombo: nbCombo.get(),_nbGroups: nbGroups.get()});
		else if( nbColors.get() == 1 && colorId == null )
			return Text.contract_1color({_done: d, _nbCombo: nbCombo.get(),_nbGroups: nbGroups.get()});
		else if( colorId != null )
			return Text.contract_this_color({_done: d, _nbCombo: nbCombo.get(), _nbGroups: nbGroups.get(), _color: textColor()});
		else
			return Text.contract_colors({_done: d, _nbCombo: nbCombo.get(), _nbColors: nbColors.get()});
	}

	function textColor(){
		return Text.resolve("color"+colorId.get());
	}

}

class Point extends Contract {
	
	var required : api.AKConst;
	var done : mt.flash.Volatile<Int>;

	public function new( required ){
		this.required = AKApi.const(required);
		this.done = 0;
		super();
	}

	public override function init(){
		super.init();
		mc._icon.gotoAndStop( 1 );
	}

	public override function isDone(){
		return done >= required.get();
	}

	public override function onValidate( pts ){
		if( isDone() )
			return;
		done += pts.get();
		if( done > required.get() )
			done = required.get();
		flash();
		check();
	}

	public override function description(){
		var d = done==0 ? "" : (showNum(done) + " / ");
		return Text.contract_points({_done: d, _pts: showNum(required.get())});
	}

	function showNum( pts : Int ) : String {
		var s = Std.string(pts);
		if( pts >= 1000000 )
			return s.substr(0,-6)+" "+s.substr(-6,-3)+" "+s.substr(-3,3);
		else if( pts >= 1000 )
			return s.substr(0,-3)+" "+s.substr(-3,3);
		else
			return s;
	}

}
