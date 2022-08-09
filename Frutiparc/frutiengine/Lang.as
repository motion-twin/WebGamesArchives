/*
$Id: Lang.as,v 1.16 2004/05/05 14:21:45  Exp $

Class: Lang
	Common functions for localized texts
	
Note:
	Require a _global.langText object
*/
class Lang{
	static var varName = "langText";
	
	/*
	Function: fv
		Pick a localized string and format using properties of an object
		
	Parameters:
		str - Path in the langText object to the wanted string
		obj - Object containing properties to apply in string
	
	Returns:
		Formatted string
		
	See Also:
		<FEString.formatVars>
	*/
	static function fv(str:String,obj:Object){
		var base = eval("_global."+varName+"."+str);
		if(base != undefined){
			return FEString.formatVars(base,obj);
		}else{
			return "[ERR] "+str;
		}
	}
	
	
	static function formatDateObject(obj:Object,format:String){
		obj.A = _global[varName].date.day_short[obj.b];
		obj.a = _global[varName].date.day[obj.b];
		obj.M = _global[varName].date.month_short[obj.n];
		obj.m = _global[varName].date.month[obj.n];
		
		if(format != undefined){
			var base = _global[varName].date["format_"+format];
		}
		if(base != undefined){
			return FEString.formatVars(base,obj);
		}else{
			return FEString.formatVars("$Y-$N-$D $H:$I:$S",obj);
		}
	}

	static function formatDate(date:Date,format:String){
		return formatDateObject(FEDate.getCompleteObject(date),format);
	}
	
	static function formatDateString(date:String,format:String){
		return formatDate(FEDate.newFromString(date),format);
	}
	
	static function formatDateTime(t:Number,format:String){
		return formatDate(FEDate.newFromTime(t),format);
	}
	
	static function formatDuration(dur:Number,format:String){
		dur = Math.round(dur);
		
		var obj = new Object();
		obj.m = dur % 1000;
		obj.s = Math.floor(dur/1000)%60;
		obj.i = Math.floor(dur/60000)%60;
		obj.h = Math.floor(dur/3600000);
		
		if(format == undefined) var format = "default";
		
		//
		if(obj.h > 0){
			return FEString.formatVars(_global[varName].duration["format_"+format].h,obj);
		}else if(obj.i > 0){
			return FEString.formatVars(_global[varName].duration["format_"+format].i,obj);
		}else if(obj.s){
			return FEString.formatVars(_global[varName].duration["format_"+format].s,obj);
		}else{
			return FEString.formatVars(_global[varName].duration["format_"+format].m,obj);
		}
	}
	
	static function displayScoreType(score,ty){
		switch(ty){
			case "millisecond":
				var ms = score % 1000;
				var s = Math.floor(score / 1000) % 60;
				var m = Math.floor(score / 60000);
				return ((m>0)?m+'\'':'') + ((m>0)?FENumber.toStringL(s,2):s)+'"' + FENumber.toStringL(ms,3);
			case "xp":
				var l = UserMng.xpToLevel(score);
				var c = Math.floor(UserMng.xpLevelCompletionRate(score) * 100);
				return "Niv. "+l+", "+FENumber.toStringL(c,2)+"%";
			case "rate":
				return (Math.round(score * 100) / 100)+"%";
			case "ptmb2":
				if(score < 100){
					return (score+1)+"%";
				}else{
					return Math.floor(score/100)+", "+((score%100)+1)+"%";
				}
			default:
				return score;
		}
	}

	// 1 -> 1st (1er), 2 -> 2nd (2�me), 3 -> 3rd (3�me), 4 -> 4th (4�me) etc..
	static function card2ord(p:Number){
		p = Number(p);
		switch(p){
			case 1:
				return p+_global.langText.ordinal.first;
			case 2:
				return p+_global.langText.ordinal.second;
			case 3:
				return p+_global.langText.ordinal.third;
			case 4:
				return p+_global.langText.ordinal.fourth;
			case 5:
				return p+_global.langText.ordinal.fifth;
			default:
				return p+_global.langText.ordinal.def;
		}
	}
	
	static function country(co){
		var r = _global[varName].countries[co].name;
		if(r == undefined){
			return "Inconnu";
		}else{
			return r;
		}
	}
	
	static function region(co,rg){
		var r = _global[varName].countries[co].region[rg];
		if(r == undefined){
			return "Inconnu";
		}else{
			return r;
		}
	}
	
	static function sign(fs){
		fs = Number(fs);
		return _global.langText.sign[fs];
	}
	
	static function gameName(discName){
		var r = _global[varName].disc_to_game[discName];
		if(r == undefined){
			return discName;
		}else{
			return r;
		}
	}
	
	static function getTipDoc(id){
		return _global[varName].tip_doc[id];

	}
}
