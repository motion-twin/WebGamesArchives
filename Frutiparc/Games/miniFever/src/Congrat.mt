class Congrat extends Slot{//}


	var fieldMain:TextField;
	var fieldShade:TextField;
	
	var titem:MovieClip;
	
	function new(){
		super();
	}
	
	function init(){
		super.init();
		
		initContent();
		
		onPress = leave;
		
		
	}
	
	function initContent(){
		var type = infoList[0]
		var str = null
		
		titem._visible = false
		
		switch(type){
			case 0:
			case 1:
			case 2:
			case 3:
				str = Lang.CONGRAT_ARCADE_0;
				str = Tools.replace(str,"$dif",Lang.DIF_LEVEL[type]);
				if(type<3){
					if( Cm.card.$arcade[type+1] == null ){
						str += Lang.CONGRAT_ARCADE_1;
						str = Tools.replace(str,"$dif",Lang.DIF_LEVEL[type+1]);
					}
				}else{
					if( Cm.card.$ultitem == false ){
						str += Lang.CONGRAT_ARCADE_2;
					}
				}
				Cm.finishArcade(type);
				break;
			case 16: // RECORD CHRONO
				str = Lang.CONGRAT_CHRONO_RECORD
				str = Tools.replace(str,"$time",Cs.getTimeString(infoList[1]));
				break;
			case 20: // POTIONS SUPPLEMENTAIRE
				str = Lang.CONGRAT_TRAIN
				str = Tools.replace(str,"$color",Lang.SIGN_COLOR[infoList[2]]);
				break;
				
			case 21: // POTION -> PRIZE
				var n = infoList[1]
				str = Lang.CONGRAT_PRIZE_TRAIN_0
				str = Tools.replace( str, "$color",Lang.SIGN_COLOR[n]);
				str = Tools.replace( str, "$num", string(Cm.TRAIN_PRIZE_LIMIT) );
				if( n<3 ){
					str += Lang.CONGRAT_PRIZE_TRAIN_1
				}else if( n==4 ){
					str += Lang.CONGRAT_PRIZE_TRAIN_2
				}else if( n==5 ){
					str += Lang.CONGRAT_PRIZE_TRAIN_3
				}
				titem._visible = true;
				titem.gotoAndStop(string(20+n))
				
				
				break;
			case 90: // CHRONO TOP PRIZE
				str = Lang.CONGRAT_CHRONO_WALLPAPER;
				str = Tools.replace(str,"$min",string(Cm.CHRONO_TOP_LIMIT/60000));
				titem._visible = true;
				titem.gotoAndStop("11")
				break;
			case 100: // NEW TRAIN
				var id = infoList[1]
				str = Lang.CONGRAT_NEW_TRAIN;
				str = Tools.replace(str,"$game",Lang.GAME_NAME[id]);
				str = Tools.replace(str,"$num",string(Cm.TRAIN_LIMIT));
				titem._visible = true;
				titem.gotoAndStop(string(100+id))				
				break
			
			
			
		}
		if(type>=80 && type<90){
			str = Lang.CONGRAT_CHRONO_TITEM;
			str = Tools.replace(str,"$min",string(Cm.CHRONO_LIMIT/60000));
			titem._visible = true;
			titem.gotoAndStop(string(type-79))

		}
		
		if(type>1000){
			var lvl = type-1000;
			str = Lang.CONGRAT_FEVER_RECORD;
			var index = int(Math.min(lvl/100,0.99)*Lang.FEVER_TITLE.length);
			str = Tools.replace(str,"$title",Lang.FEVER_TITLE[index]);
			
		}		
		fieldMain.text = str
		fieldShade.text = str		
		
		
		fieldMain._y = 140 - fieldMain.textHeight*0.5//*0.85
		if(titem._visible)fieldMain._y += 20;
		
		fieldShade._y = fieldMain._y+1	
	}
	
	
	function update(){
		super.update();
		
	}
	
	
	
//{	
}










