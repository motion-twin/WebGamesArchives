package mt.fx;

class Manager {

	public var fxs:Array<Fx>;

	public function new(){
		fxs = [];
		if( Fx.DEFAULT_MANAGER == null ) Fx.DEFAULT_MANAGER = this;
	}

	public function update() {
		var a = fxs.copy();
		for( fx in a ) {
			fx.update();
		}
	}
	
	public function add(fx:Fx) {
		if( fx.manager != null )
			fx.manager.remove(fx);
		fx.manager = this;
		fxs.push(fx);
	}
	
	public function remove(fx:Fx) {
		fxs.remove(fx);
		fx.manager = null;
	}
	
	public function clean() {
		while( fxs.length > 0 )
			fxs[0].kill();
	}
	
	public function over(fx:Fx) {
		remove(fx);
		add(fx);
	}
	
	public function under(fx:Fx) {
		remove(fx);
		fxs.unshift(fx);
	}
	
	public function destroy() {
		while( fxs.length > 0 )
			fxs[0].kill();
		fxs = null;
	}
}
