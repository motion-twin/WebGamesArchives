package mt.ui;

class ButtonData< T:flash.display.Sprite, K > extends Button<T> {
	public var data:Null<K>;
	public function new( p_mc:T, p_data:K ) {
		super(p_mc);
		this.data = p_data;
	}
	
	override function dispose()
	{
		super.dispose();
		this.data = null;
	}
}
