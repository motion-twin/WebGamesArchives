import Common;
import Anim;

typedef MsgInter =  {>flash.MovieClip,fieldName:flash.TextField,fieldDesc:flash.TextField,timer:Int,option:flash.MovieClip}

class HelpTip {

	public var x(default,null) : Int;
	public var y(default,null) : Int;
	public var mc : MsgInter;
	public var game : Game;

	public function new(game) {
		mc.timer = null;
		this.game = game;
	}

	public function display(voption ) {
		var option;
		var name;
		var desc;

		if( voption >= 100 ) {
			option = voption - 100; // Affichage de l'aide de la porte
			name = Lang.INFO_NAME[option];
			desc = Lang.INFO_DESC[option];
		}
		else {
			option = voption;
			name = Lang.ACTION_NAME[option];
			desc = Lang.ACTION_DESC[option];
		}

		if( mc == null ){
			mc = cast game.dm.attach("helpTip",Const.DP_INVISIBLE);
			mc._y = -60;
		}
		mc.gotoAndStop( if(voption>=100) 2 else 1 );
		mc.smc.gotoAndStop( mc._currentframe );

		mc.timer = null;
		mc.fieldName.text = name;
		mc.fieldDesc.text = desc;

		if( voption >= 100 )
			mc.option._visible = false;
		else {
			mc.option._visible = true;
			mc.option.gotoAndStop(option+1);
		}

		mc.fieldDesc._y = 38 - Std.int(mc.fieldDesc.textHeight*0.5);
	}

	public function hide() {
		mc.timer = 5;
	}

	public function update() {
		if( mc != null ){
			if(mc.timer!=null){
				if(mc.timer--<0){
					mc._y += (mc._y-1);
					if(mc._y<-60){
						mc.removeMovieClip();
						mc = null;
					}
				}
			}else{
				mc._y *= 0.5;
			}
			mc._y = Std.int(mc._y);
		}
	}

	public function clean() {
		mc.removeMovieClip();
		mc = null;
	}
}
