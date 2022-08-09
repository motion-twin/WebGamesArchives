package ac ;

import Fighter.Mode ;
import mt.bumdum.Lib ;


class Talk extends State {//}

	var f : Fighter ;
	var text : String ;

	var index : Int;
	var speed : Float;
	var multi : Int;
	var width : Int;

	var step:Int;

	var bub:{>flash.MovieClip,field:flash.TextField,corner:flash.MovieClip};

	public function new(f: Fighter,str) {
		super();
		this.f = f ;
		text = str ;
		if( f.mode != Dead)addActor(f);
		for( fi in Main.me.fighters )
			if(fi.mode == Waiting && fi != f )
				addActor(fi);

		step  = 0;
		index = 0;
		speed = 0.6;
		multi = 1;

		timer = 0;
		//init();
	}

	public function setText(str){
		bub._visible = true;
		bub.field.text = str;
		bub.smc._height = bub.field.textHeight;
		bub.field._y = -(bub.field.textHeight+5);
		bub.field._height = (bub.field.textHeight+8);
	}


	override function init() {

		// BUBBLE
		bub = cast Scene.me.dm.attach("mcTextBubble",Scene.DP_LOADING);
		bub._x = f.root._x;
		bub._y = f.root._y-(f.height+10);

		width = 100;
		if( text.length > 30 )width = 150;
		if( text.length > 200 )width = 200;
		if( text.length > 300 )width = 400;

		bub.field._width = width;
		Filt.glow(bub.smc,12,10,0xFFFFFF);
		Filt.glow(bub,2,2,0);
		setText(text);

		var mx = (bub._width+5)*0.5 - 20;
		var my = bub._height-10;
		bub._x = Num.mm( mx, bub._x, Cs.mcw-mx );
		bub._y = Num.mm( my, bub._y, Cs.mch );
		bub._visible = false;
		bub.blendMode = "layer";

		bub.field._x = -width*0.5;
		bub.smc._width = bub.field.textWidth+10;
		//
		var me = this;
		Scene.me.setClick(function(){me.multi=2;},true);
	}

	public override function update(){
		super.update();
		if(castingWait)return;
		switch(step){
			case 0:
				timer += speed*multi;
				while(timer>=1){
					timer--;
					index++;
					var str = text.substr(0,index);
					setText(str);
					var ch = text.substr(index-1,1);
					switch(ch){
						case ".":	timer -= 10;
						case "!":	timer -= 10;
						case "?":	timer -= 10;
						case ",":	timer -= 5;
						default:
							var n = ch.charCodeAt(0);
							if( n>=65 && n<=90 )timer += speed;
					}
					if(index>=text.length){
						step=null;
						Scene.me.setClick( endTalk ,true, true);
						return;
					}
				}

			case 1:
				bub._alpha = (1-coef)*100;
				if(coef==1){
					bub.removeMovieClip();
					end();
				}

		}
	}
	public function endTalk(){
		step = 1;
		coef = 0;
		spc = 0.2;
	}
//{
}