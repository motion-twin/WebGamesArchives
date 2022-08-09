class it.Flask extends It{//}

	var sub:MovieClip;
	var cursor:sp.pe.Cursor
	
	var icon:MovieClip;
	
	function new(){
		link = "itemFlask"
	}
	
	function init(){
		super.init();
	}	
	
	function updatePic(pic){
		super.updatePic(pic);
		
		if(fi!=null){
			clean();
			if(fi.fs.$mission!=null){
				var mc = Std.attachMC(Std.cast(pic).sub,"mcIconMission",1)
				mc._xscale = 360;
				mc._yscale = 360;
				icon = mc
			}else{
				var sp = new sp.pe.Cursor()
				sp.setInfo(fi)
				sp.init();	
				sp.birth(Std.createEmptyMC(Std.cast(pic).sub,1))
				sp.skin._xscale = 220;
				sp.skin._yscale = 220;
				sp.body.body.stop();
				cursor = sp;
			}
			
		}else{
			clean();
		}
	}
	
	function removeCursor(){
		cursor.kill();
	}
	
	function getName(){
		return "Bocal residentiel";
	}
	
	function getDesc(){
		
		var str = ""
		if(fi==null){
			str = "Il sert à abriter les fées, pour y loger votre fée cliquer en appuyant sur la barre espace"
		}else if(fi.fs.$mission!=null){
			str =  fi.fs.$name+" est actuellement en mission. Elle reviendra"
			var d = Cm.card.$mis[fi.fs.$mission].$d
			switch(d){
				case 1:
					str += " demain."
					break;
				case 2:
					str += " après-demain."
					break;
				default:
					str += " dans "+d+" jours."
					break;
			}
			
			
		}else{

			var action = Lang.FLASK_ACTION[Math.floor((fi.fs.$moral-0.1)/4)]
			str = fi.fs.$name+" ( niv."+(fi.fs.$level+1)+" ) "+action[Std.random(action.length)]+"dans ce bocal."
		}
		
		
		return  str
	}
	
	function clean(){
		if(cursor!=null)removeCursor();
		if(icon!=null){
			icon.removeMovieClip();
			icon = null;
		}
	}

	
	
//{	
}
