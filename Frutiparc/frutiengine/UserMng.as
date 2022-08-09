/*
$Id: UserMng.as,v 1.16 2004/03/30 14:19:55  Exp $

Class: UserMng
*/
class UserMng{//}

	/*
	Function: xpToLevel
		Return the level corresponding to an amount of XP
		
	Parameters:
		xp - Number - The amount of XP
		
	See Also:
		<UserMng.levelToXp>,<UserMng.xpLevelCompletionRate>
	*/
	static function xpToLevel(xp){
		xp = Math.max(0,xp);
		return Math.floor(Math.sqrt(xp/10000)+1);
	}
	
	/*
	Function: xpToLevel
		Return the amount of XP corresponding to a level
		
	Parameters:
		level - Number - The level
		
	See Also:
		<UserMng.xpToLevel>,<UserMng.xpLevelCompletionRate>
	*/
	static function levelToXp(level){
		level = Math.max(1,level);
		return Math.pow(level-1,2)*10000;
	}
	
	/*
	Function: xpToLevel
		Return the completion rate of the current level from the amount of XP
		
	Parameters:
		xp - Number - The amount of XP
		
	See Also:
		<UserMng.xpToLevel>,<UserMng.levelToXp>
	*/
	static function xpLevelCompletionRate(xp){
		var level = xpToLevel(xp);
		var xpOk = xp - levelToXp(level);
		var xpBetweenTwoLevel = levelToXp(level + 1) - levelToXp(level);
		return xpOk / xpBetweenTwoLevel;
	}
	
	
	static function birthdayToAge(bd){
		if(bd == undefined || bd == "0000-00-00" || bd.length < 10){
			return 0;
		}else{
			var y = Number(bd.substr(0,4));
			var m = Number(bd.substr(5,2));
			var d = Number(bd.substr(8,2));
			
			var t = _global.localTime.getDateObject();

			var ly = t.getFullYear();
			var lm = t.getMonth()+1;
			var ld = t.getDate();
			
			if(lm > m || (lm == m && ld >= d)){
				return ly - y;
			}else{
				return ly - y - 1;
			}
		}
	}
	
	static function birthdayToMonthAge(bd){
		if(bd == undefined || bd == "0000-00-00 00:00:00" || bd.length < 19){
			return 0;
		}else{
			var y = Number(bd.substr(0,4));
			var m = Number(bd.substr(5,2));
			var d = Number(bd.substr(8,2));
			
			var t = _global.localTime.getDateObject();

			var ly = t.getFullYear();
			var lm = t.getMonth()+1;
			var ld = t.getDate();
			
			return (ly - y) * 12 + (lm - m) - (ld < d);
		}
	}

	static function formatInfoBasic(node){
		var obj = new Object();
		
		obj.xpLevel = xpToLevel(Number(node.attributes.x));
		obj.xpCompletionRate = xpLevelCompletionRate(Number(node.attributes.x));
		obj.nickname = node.attributes.u;
		obj.gender = node.attributes.sx;
		obj.age = birthdayToAge(node.attributes.bd);
		obj.birthday = node.attributes.bd;
		obj.country = Lang.country(node.attributes.co);
		obj.countryCode = node.attributes.co;
		obj.region = Lang.region(node.attributes.co,node.attributes.rg);
		
		return obj;
	}
	
	
	////// 

	var mcList:Array;
	var u;
	var flMode:Boolean;
	var sortString:String;
	var infoBasic:Object;
	
	function UserMng(u,iB,flMode){
		this.u = u;
		this.flMode = flMode;
		this.mcList = new Array();
		
		this.updateSortString();
		
		this.infoBasic = {
			status: {
				internal: undefined,
				external: undefined,
				emote: undefined
			},
			fbouille: "000503000000111010",
			presence: 0,
			xpLevel: 1,
			xpCompletionRate: 0,
			nickname: u,
			gender: "M",
			age: undefined,
			birthday: "",
			country: "",
			region: "",
			flMute: false
		}
		
		for(var n in iB){
			this.infoBasic[n] = iB[n];
		}
		
		_global.mainCnx.atrace(this.u,this,"onStatusObj",false,true);
	}

	function setMc(mc){
		if(mc == undefined){
			_global.debug("WARN : [UserMng] setMc() mc == undefined !!!")
			return;
		}

		var rs = this.mcList.pushUniq(mc);
		//_global.debug("["+this.u+"] setMc: "+rs+", "+mc+" [size: "+this.mcList.length+"]");
		
		if(this.infoBasic != undefined){
			mc.onInfoBasic(this.getInfoBasic());
		}
	}

	function unsetMc(mc){
		var rs = this.mcList.rm(mc);
		//_global.debug("["+this.u+"] unsetMc: "+rs+", "+mc+" [size: "+this.mcList.length+"]");
	}

	function onDelete(){
		_global.mainCnx.strace(this.u,this,false,true);
	}
	
	function onAction(act){
		for(var i=0;i<this.mcList.length;i++){
			this.mcList[i].onAction(act);
		}
	}

	function onStatusObj(obj){
		if(obj == undefined) return;
		
		for(var n in obj){
			this.infoBasic[n] = obj[n];
		}
		
		for(var i=0;i<this.mcList.length;i++){
			this.mcList[i].onInfoBasic(obj);
		}
	}
	
	function setInfoBasic(obj){
		for(var n in obj){
			this.infoBasic[n] = obj[n];
		}
	}
	
	function getInfoBasic(){
		return this.infoBasic;
	}
	
	function updateSortString(){
		if(this.flMode){
			this.sortString = "0"+u.toLowerCase();
		}else{
			this.sortString = "1"+u.toLowerCase();
		}
	}
//{
}
