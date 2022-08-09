package fx;

/**
 * Explode a movie clip !
 */

class Explode extends mt.fx.Fx
{
	public var mc : flash.display.DisplayObject;
	public var mc2 : flash.display.MovieClip; //particules
	public var particules : Array < mt.fx.Part < flash.display.Sprite >> ;
	public var colors : Array<Int>;
	
	/**
	 *
	 * @param	mc
	 * @param	circleNum=15			Circle parts number
	 * @param	partsNum=10				Bitmap parts number
	 * @param	?colors=Array<Int>		Array of colors used for circle particules
	 */
	override public function new(mc: flash.display.Sprite,circleNum=15,partsNum=10,?colors:Array<Int>,?hideMc=true,?circleSize=4)
	{
		super();
		this.mc = mc;
		mc2 = new flash.display.MovieClip();
		mc.parent.addChild(mc2);
		
		if(colors != null) {
			this.colors = colors;
		}else {
			this.colors = [0,0x666666,0x666666,0x666666,/*0xCB0E5F*/0xAA0000,0xFFFFFF];
		}
		
		//mc2.x = Level.CENTER.x;
		//mc2.y = Level.CENTER.y;
		//mc2.rotation = mc.rotation;
		
		particules = [];
		
		//circle parts
		//var circles = [];
		//for(i in 0...circleNum) {
			//var c = createCircle(0,0,circleSize);
			//mc2.addChild(c);
			//var particule = new mt.fx.Part(c);
			//particule.vx = Std.random(8)-4;
			//particule.vy = 0 - Std.random(10);
			//particule.weight = 0.5;
			//particule.vr = 5;
			//particule.setGround( 20, 0.5, 0.5,12);
			//particule.onBounceGround = function() { particule.kill(); };
			//particules.push(particule);
		//}
		
		//bitmap parts
		if(partsNum>0){
		
			var slices = mt.bumdum9.Tools.slice(mc, partsNum);
		
			for(particule in slices) {
				//particule.setPos(15,0);
				mc2.addChild(particule.root);
				particule.vx = Std.random(8)-4;
				particule.vy = 0 - Std.random(10);
				particule.weight = 0.2;
				particule.vr = 5;
				//particule.setGround( 20, 0.5, 0.5,12);
				//particule.onBounceGround = function() { particule.kill(); };
				particules.push(particule);
			}
		}
		
		if(hideMc)	mc.visible = false;
		
	}
	
	
	public function createCircle(x,y,?maxSize=4) {
		var c = new flash.display.Sprite();
		var color = 0;
		color = colors[ Std.random(colors.length) ];
		c.graphics.beginFill(color);
		c.graphics.drawCircle(x, y, Std.random(maxSize) + 1);
	//	c.graphics.drawCircle(x-3, y-3, Std.random(4) + 1);
		return c;
		
	}
	
	
}