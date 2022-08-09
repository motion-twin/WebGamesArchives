package fx;
import Protocole;
import mt.bumdum9.Lib;

class Score extends pix.Text
{//}
	public var timer:Int;
	public function new(x, y, score) {
		var str = Std.string(score);
		var font =  Gfx.fontA;
		if ( score < 0 ) {
			font = Gfx.fontB;
			//str = str.substr(1);
		}
		
		super(font);
		this.x = x;
		this.y = y;
		pxx();
		
		align = 0.5;
		ec -= 2;
		setText(str);
		
		Stage.me.dm.add(this, Stage.DP_FX);
		setWave(6, 0,  60, 80, 0.9);
		timer = 40;
	}
	override function update() {
		
		
		if ( --timer == 0 ) {
			squeeze( -0.15 );
		}
		if ( timer<0 && coef == 0 ) {
			kill();
		}
		
		super.update();
	}
	
	
//{
}












