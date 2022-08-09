class mode.FjvEnd extends Mode
{
	var fCookie			: SharedObject;
	var scr				: {>MovieClip, field:TextField};
	var bg				: MovieClip;
	var timer			: float;
	var fxList			: Array<MovieClip>;
	var fl_name			: bool;
	var fl_win			: bool;

	/*------------------------------------------------------------------------
	CONSTRUCTEUR
	------------------------------------------------------------------------*/
	function new(m,win) {
		super(m);
		var baseTime = Std.parseInt( Std.getVar(Std.getRoot(),"$time"), 10 );
		if ( Std.isNaN(baseTime) ) baseTime = 30;
		fl_win = win;
		fCookie = SharedObject.getLocal("$fjv_data");
		_name = "$fjv_end";
		scr = downcast( depthMan.attach("hammer_fjv_end",Data.DP_INTERF) );
		bg = depthMan.attach("hammer_fjv_bg",Data.DP_SPECIAL_BG);
		if ( fl_win ) {
			scr.gotoAndStop("2");
		}
		else {
			scr.gotoAndStop("1");
		}
		fCookie = SharedObject.getLocal("$fjv_data");
		timer = Std.parseInt( Std.getVar( downcast(fCookie.data), "timer" ), 10 );
		var list = Std.getVar( downcast(fCookie.data), "list" );
		var name = Std.getVar( downcast(fCookie.data), "name" );
		if ( list==null ) {
			list = new Array();
		}
		if ( name!=null ) {
			var score = Std.parseInt( Std.getVar( downcast(fCookie.data), "score" ), 10 );
			list.push( {name:name, win:fl_win, score:score} );
			Std.setVar( downcast(fCookie.data), "name", null );
		}
		while (list.length>50) {
			list.splice(0,1);
		}
		Std.setVar( downcast(fCookie.data), "list", list );
		var txt = "";
		for (var i=0;i<list.length;i++) {
			txt+=list[i].name+" -> "+list[i].win+" ("+list[i].score+")\r\n";
		}
		System.setClipboard(txt);
		if ( timer<=0 || timer==null || Std.isNaN(timer) ) {
			timer = baseTime*Data.SECOND;
		}
		if ( fl_win ) {
			timer = 2*baseTime*Data.SECOND;
		}
//		if ( timer>0 ) {
//			playMusic(1);
//		}
		fxList = new Array();
		fl_name = (timer<=0);
	}


	/*------------------------------------------------------------------------
	FIN DE MODE
	------------------------------------------------------------------------*/
	function endMode() {
		scr.removeMovieClip();
		bg.removeMovieClip();
		super.endMode();
	}

	function focus() {
		var path = Std.cast(scr.field);
		Selection.setFocus(path);
		Selection.setSelection(scr.field.text.length,scr.field.text.length);
	}



	/*------------------------------------------------------------------------
	BOUCLE PRINCIPALE
	------------------------------------------------------------------------*/
	function main() {
		super.main();
		if ( fl_win && Std.random(2)==0 && fxList.length<40 ) {
			var fx = depthMan.attach("hammer_fx_fjv", Data.DP_FX);
			fx._x = Std.random(Data.DOC_WIDTH);
			fx._y = -15;
			fx._xscale = Std.random(50)+10;
			fx._yscale = fx._xscale;
			fxList.push(fx);
		}

		for (var i=0;i<fxList.length;i++) {
			var fx = fxList[i];
			fx._y += Timer.tmod * (Std.random(20)/10) + 3*(100-fx._alpha)/100;
			fx._x += Timer.tmod * Std.random(3) * (Std.random(2)*2-1);
			fx._alpha -= Timer.tmod * 2;
			if ( fx._alpha<=0 ) {
				fx.removeMovieClip();
				fxList.splice(i,1);
				i--;
			}
		}


		if ( !fl_name ) {

			timer-=Timer.tmod;
			Std.setVar( downcast(fCookie.data), "timer", timer );
			var sec = Math.ceil(timer/Data.SECOND)
			if ( sec>=60 ) {
				var min = Math.floor(sec/60);
				scr.field.text = min+":"+Data.leadingZeros(sec-min*60,2);
			}
			else {
				scr.field.text = "0:"+Data.leadingZeros(sec,2);
			}

			if ( timer<=0 ) {
				fl_name = true;
				scr.gotoAndStop("3");
				focus();
			}
		}
		else {
			var name = Tools.replace( scr.field.text, "\r", "" );
			name = Tools.replace( name, "\n", "" );
			name = Data.cleanLeading(name);
			if ( name.length>0 && Key.isDown(Key.ENTER) ) {
				Std.setVar( downcast(fCookie.data), "name", name );
				manager.startGameMode( new mode.Fjv(manager,0) );
			}
		}


	}

}

