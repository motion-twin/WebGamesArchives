
class Transition {

	var bmp : flash.display.BitmapData;
	var b : flash.display.Sprite;
	var m : Main;
	var enterIsland : Bool;
	
	public function new( m : Main ) {
		this.m = m;
		var mc = m.world.getMC();
		bmp = new flash.display.BitmapData(mc.stage.stageWidth, mc.stage.stageHeight);
		bmp.draw(mc, mc.transform.matrix);
		var bmp = new flash.display.Bitmap(bmp);
		b = new flash.display.Sprite();
		b.x = bmp.width * 0.5;
		b.y = bmp.height * 0.5;
		bmp.x = -b.x;
		bmp.y = -b.y;
		b.addChild(bmp);
		m.fx.add(b, 0);
	}
	
	public function cleanup() {
		bmp.dispose();
		if( b.parent != null ) b.parent.removeChild(b);
	}
		
	public function init( old : Null<Bool>, cur : Null<Bool> ) {
		b.alpha = 1;
		if( old == false && cur || cur == null )
			b.scaleX = b.scaleY = 1.01;
		enterIsland = old == false && cur == true;
	}
	
	public function update() {
		b.alpha -= 0.05;
		if( b.scaleX > 1 ) {
			b.scaleX *= 1.1;
			b.scaleY *= 1.1;
		} else if( b.scaleX < 1 ) {
			b.scaleX *= 0.9;
			b.scaleY *= 0.9;
		}
		if( b.alpha < 0 && enterIsland )
			m.displayInfos(m.curIsland.name);
		return b.alpha > 0;
	}
	
}