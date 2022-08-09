package ac ;

import Fighter.Mode ;
import mt.bumdum.Lib ;


class Text extends State {//}


	var flInit:Bool;
	var text : String ;

	var index : Float;
	var speed : Float;

	var step:Int;

	var panel:{>flash.MovieClip,field:flash.TextField};

	public function new(str) {
		super();
		text = str ;
		flInit = false;
		for( f in Main.me.fighters )
			if(f.mode == Waiting )
				addActor(f);
		step  = 0;
		index = 0;
		speed = 0.75;
	}

	function initBubble(){
	}

	override function init() {
		flInit = true;
		panel = cast Scene.me.dm.attach("mcTopText",Scene.DP_PARTS);
		var me = this;
		Scene.me.setClick(function(){me.speed=2;},true);
	}

	public override function update(){
		super.update();
		if(castingWait)return;
		if(!flInit)init();

		switch(step){
			case 0:
				index+=speed;
				var str = text.substr(0,Math.floor(index));
				setText(str);
				if(index>=text.length){
					step=null;
					Scene.me.setClick( endTalk ,true, true);
				}
			case 1:

				panel._alpha = (1-coef)*100;
				if(coef==1){
					panel.removeMovieClip();
					end();
				}

		}
	}
	public function endTalk(){
		step = 1;
		coef = 0;
		spc = 0.2;
	}

	public function setText(str){
		panel.field.text = str;
		panel.field._y = 32 - panel.field.textHeight*0.5;
	}

//{
}