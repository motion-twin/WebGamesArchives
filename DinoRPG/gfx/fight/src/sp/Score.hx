package sp;
import mt.bumdum.Phys;
import mt.bumdum.Lib;


class Score extends Phys{//}

	var sy:Float;

	public function new(mc,x:Float,y:Float,n,?type){
		super(mc);
		this.x = x;
		this.y = y;

		timer  = 40;
		fadeType = 0;

		var field : flash.TextField = (cast root).field;
		field.text = Std.string(n);

		setScale(100+n*2);


		var colors = [];
		switch(type){
			case 0:	  // GAIN
				vy = -1.5;
				frict = 0.95;
				colors = [0xFFFFFF,0x00AA00];

			default : // LOSS LIFE
				vy = -8;
				weight = 0.8;
				colors = [0xFFFFFF,0xAA0000];


		}

		field.textColor = colors[0];
		Filt.glow(root,2,4,colors[1]);


	}


	public override function update(){
		if(sy==null)sy = y;
		super.update();

		var lim = sy-25;
		if( vy>0 && y>lim ){
			y = lim;
			vy *= -0.8;
		}

	}









//{
}