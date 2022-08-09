/*
$Id: FrutizInfo.as,v 1.26 2005/08/04 16:06:03  Exp $

Class: FrutizInfo
*/
class FrutizInfo {//}

	static var rankingList:Object;
	
	//////////////
	
	private var listeners:Object;
	private var box;
	
	// state of external object
	private var state:Object; // state: 0 = not required ; 1 = loading ; 2 = OK
	
	// state of each local data loading
	private var state_int:Object;
	private var user:String;
	
	public var basic:Object;
	public var frutiz:Object;
	public var scores:Object;
	public var award_history:Object;
	public var perso:Object;
	public var bonus:Object;
	
	private var fcardCallBack:Object;

	private var fscnx:CBeeLocal;
	private var fsWaitingCmd:Array;
	private var fsready:Boolean = false;
	
	
	public function FrutizInfo(obj){
		//_root.test+="bonjour\n"
		for(var n in obj){
			this[n] = obj[n];
		}
		
		this.state_int = {utrace: 0,basic: 0,uinfo: 0,rankinglist: 0,rankingresult: 0,award: 0,award_history: 0,fcardlist: 0};

		this.state = {basic: 0,frutiz: 0,scores: 0,perso: 0,bonus: 0,award_history: 0};
		this.listeners = {basic: [],frutiz: [],scores: [],perso: [],bonus: [],award_history: []};

		this.basic = undefined;
		this.frutiz = undefined;
		this.scores = undefined;
		this.perso = undefined;
		this.bonus = undefined;
		this.award_history = undefined;
		
		this.fcardCallBack = new Object();
		
	}

	// called when I will be killed
	public function onKill(){
		_global.mainCnx.strace(this.user,this,true);
		this.deleteFScoreCnx();
	}
	
	//
	public function getFrutiCard(game,callBack){
		var rid = FEString.uniqId();
		
		this.fcardCallBack[game] = callBack;
		_global.mainCnx.addListener("fcardgetpublicslot",this,"onFCard","r",rid);
		_global.mainCnx.cmd("fcardgetpublicslot",{u: this.user,g: game,r: rid});
	}
	
	function onFCard(node){
		_global.mainCnx.removeListenerCmd("fcardgetpublicslot","r",node.attributes.r);
		
		if(node.attributes.k != undefined){
			_global.openErrorAlert(Lang.fv("error.cbee."+node.attributes.k));
		}
		
		var callBack = this.fcardCallBack[node.attributes.g];
		callBack.obj[callBack.method](ext.util.MTSerialization.unserialize(node.firstChild.nodeValue),node.attributes.g);
		
		delete this.fcardCallBack[node.attributes.g];
	}
	
	// to call to add a callBack in listeners$
	// if I not have the info, I launch the process to get it here
	// return true si l'info �tait d�j� pr�te � �tre affich�e, false sinon
	public function weWant(cat,callBack){
		if(this.listeners[cat] == undefined || this.state[cat] == undefined){
			_global.debug("FrutizInfo::weWant(): Unknow category: "+cat);
			return ;
		}
		
		// todo: pushUniq
		this.listeners[cat].push(callBack);
		var s = this.state[cat];
		
		if(s == 0){
			// launch the process to get it
			this.getInfos(cat);
		}else if(s == 2){
			// send it to the new listener directly
			callBack.obj[callBack.method](callBack.args);
			return true;
		}
		
		return false;
	}
	
	// Remove a callBack from a listener
	public function weWantNoMore(cat,callBack){
		var arr = this.listeners[cat];
		for(var i=0;i<arr.length;i++){
			var cb = arr[i];
			if(cb.obj == callBack.obj && cb.method == callBack.method){
				this.listeners[cat].splice(i,1);
			}
		}
	}
	
	// Remove all listeners to an object in all cat listeners' list
	// Call this function when an object is killed
	public function onCloseObj(obj){
		for(var cat in this.listeners){
			var arr = this.listeners[cat];
			for(var i=0;i<arr.length;i++){
				if(arr[i].obj == obj){
					this.listeners[cat].splice(i,1);
				}
			}
		}
	}
	
	private function callListeners(cat){
		var arr = this.listeners[cat];
		for(var i=0;i<arr.length;i++){
			var o = arr[i];
			o.obj[o.method](o.args);
		}
	}
	
	private function updateStateFromInt(){	
		var i = this.state_int;
		var s = this.state;
		
		if(i.utrace == 2 && (i.basic == 2 || i.uinfo == 2)){
			s.basic = 2;
		}else if(i.utrace >= 1 && (i.basic >= 1 || i.uinfo >= 1)){
			s.basic = 1;
		}else{
			s.basic = 0;
		}
		
		s.frutiz = i.uinfo;
		s.perso = i.uinfo;
		s.bonus = i.uinfo;
		
		if(i.rankinglist == 2 && i.rankingresult == 2 && i.award == 2 && i.fcardlist == 2){
			s.scores = 2;
		}else if(i.rankinglist >= 1 && i.rankingresult >= 1 && i.award >= 1 && i.fcardlist >= 1){
			s.scores = 1;
		}else{
			s.scores = 0;
		}
		
	}
	
	private function getInfos(cat){
		switch(cat){
			// requires utrace + ( _global.getInfoBasic | userInfo )
			case "basic":
				if(this.state_int.utrace == 0){
					this.getIntInfo("utrace");
				}
				if(this.state_int.uinfo == 0){
					var inf = _global.mainCnx.getInfoBasic(this.user);
					if(inf != undefined){
						if(this.basic == undefined) this.basic = new Object();
						for(var n in inf){
							this.basic[n] = inf[n];
						}
						this.state_int.basic = 2;

						this.updateStateFromInt();
					}else{
						this.getIntInfo("uinfo");
					}
				}
				break;
				
			// requires userInfo
			case "frutiz":
				if(this.state_int.uinfo == 0){
					this.getIntInfo("uinfo");
				}
				break;
				
			// requires userInfo
			case "perso":
				if(this.state_int.uinfo == 0){
					this.getIntInfo("uinfo");
				}
				break;
				
			// requires userInfo
			case "bonus":
				if(this.state_int.uinfo == 0){
					this.getIntInfo("uinfo");
				}			
				break;
				
			case "scores":
				if(this.state_int.award == 0){
					this.getIntInfo("award");
				}
				if(this.state_int.rankinglist == 0){
					this.getIntInfo("rankinglist");
				}
				if(this.state_int.rankinglist == 2 && this.state_int.rankingresult == 0){
					this.getIntInfo("rankingresult");
				}
				if(this.state_int.fcardlist == 0){
					this.getIntInfo("fcardlist");
				}
				
			default:
				break;
		}
		
		
		// If the state is already OK !
		if(this.state[cat] == 2){
			this.callListeners(cat);
		}
	}
	
	private function getIntInfo(int_cat){
		switch(int_cat){
			case "utrace":
				this.state_int.utrace = 1;
				
				_global.mainCnx.atrace(this.user,this,"onStatusObj",true);
				break;
			case "uinfo":		
				this.state_int.uinfo = 1;
				
				var rid = FEString.uniqId();
				_global.mainCnx.addListener("userinfo",this,"onUserInfo","r",rid);
				_global.mainCnx.cmd("userinfo",{u: this.user,r: rid});
				break;
				
			case "award":
				this.state_int.award = 1;
			
				var rid = FEString.uniqId();
				_global.mainCnx.addListener("awarduser",this,"onAward","r",rid);
				_global.mainCnx.cmd("awarduser",{u: this.user,r: rid});
				break;
				
			case "rankinglist":
				var currentDate = _global.servTime.getDateObject();
				currentDate.setHours(12);
				currentDate.setMinutes(0);
				currentDate.setSeconds(0);
				currentDate = Lang.formatDate(currentDate,"prog_server")
				
				// try to get it localy
				if(rankingList != undefined && rankingList.date == currentDate){
					this.state_int.rankinglist = 2;
				}else{
					this.state_int.rankinglist = 1;
					this.createFScoreCnx();
					var rid = FEString.uniqId();
					this.fscnx.addListener("listrankings",this,"onListRankings","r",rid);
					this.fscmd("listrankings",{dt: currentDate,r: rid});
				}
				break;
				
			case "rankingresult":
				if(this.state_int.rankinglist != 2){
					if(this.state_int.rankinglist == 0) this.getIntInfo("rankinglist");					
					return false;
				}
				
				this.state_int.rankingresult = 1;
				this.createFScoreCnx();
				var rid = FEString.uniqId();
				this.fscnx.addListener("userresult",this,"onUserResult","r",rid);
				var c = new XML();
				c.nodeName = "u";
				c.attributes.u = this.user;
				this.fscmd("userresult",{rs: rankingList.list.join(","),r: rid},c);

				break;
				
			case "fcardlist":
				this.state_int.fcardlist = 1;
			
				var rid = FEString.uniqId();
				_global.mainCnx.addListener("fcardlist",this,"onFCardList","r",rid);
				_global.mainCnx.cmd("fcardlist",{u: this.user,r: rid});

				break;
		}
		
		this.updateStateFromInt();
	}
	
	private function onListRankings(node){
		this.fscnx.removeListenerCmd("listrankings","r",node.attributes.r);
		
		var currentDate = _global.servTime.getDateObject();
		currentDate.setHours(12);
		currentDate.setMinutes(0);
		currentDate.setSeconds(0);
		currentDate = Lang.formatDate(currentDate,"prog_server")
		
		rankingList = {date: currentDate,list: [],inf: {}};
		for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){
			if(n.nodeName != "s" || n.attributes.ty != "C") continue;
				
			for(var m=n.firstChild;m.nodeType>0;m=m.nextSibling){
				if(m.nodeName != "rk") continue;
				
				rankingList.inf[m.attributes.rk] = {name: m.attributes.rn,game: m.attributes.g,type: m.attributes.ty};
				rankingList.list.push(m.attributes.rk);
			}
		}
		
		this.state_int.rankinglist = 2;
		this.getIntInfo("rankingresult");
	}
	
	private function onUserResult(node){
		this.fscnx.removeListenerCmd("userresult","r",node.attributes.r);
		
		if(this.scores == undefined) this.scores = new Object();
		this.scores.ranking = new Array();
		
		for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){
			if(n.nodeName != "rk") continue;
			
			var rk = rankingList.inf[n.attributes.rk];
			
			this.scores.ranking.push({
				discName: rk.game,
				id: n.attributes.rk,
				title: rk.name,
				score: Number(n.attributes.s),
				pos: Number(n.attributes.p),
				type: rk.type
			});
		}
		
		this.state_int.rankingresult = 2;
		this.updateStateFromInt();
		
		if(this.state.scores == 2) this.callListeners("scores");
	}
	
	private function onAward(node){
		_global.mainCnx.removeListenerCmd("awarduser","r",node.attributes.r);
		
		if(this.scores == undefined) this.scores = new Object();
		this.scores.awards = new Array();
		
		for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){
			if(n.nodeName != "a") continue;
			
			this.scores.awards.push({game: n.attributes.g,discName: n.attributes.n,value: Number(n.attributes.v),days: Number(n.attributes.d)});
		}
		
		this.state_int.award = 2;
		this.updateStateFromInt();
		
		if(this.state.scores == 2) this.callListeners("scores");
	}
	
	private function onFCardList(node){
		_global.mainCnx.removeListenerCmd("fcardlist","r",node.attributes.r);
		
		if(this.scores == undefined) this.scores = new Object();
		this.scores.fcardList = new Array();
		
		for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){
			if(n.nodeName != "g") continue;
			
			this.scores.fcardList.push(n.attributes.g);
		}
		
		this.state_int.fcardlist = 2;
		this.updateStateFromInt();
		
		if(this.state.scores == 2) this.callListeners("scores");
	}
	
	private function onUserInfo(node){

		_global.mainCnx.rmListenerCmd("userinfo","r",node.attributes.r);
		
		if(node.attributes.k == "201"){
			this.box.onUserNotFound();
		}
		
		var b = UserMng.formatInfoBasic(node);
		
		_global.mainCnx.setInfoBasic(this.user,b);
		if(this.basic == undefined) this.basic = new Object();
		for(var n in b){
			this.basic[n] = b[n];
		}
		
		// FRUTIZ
		if(this.frutiz == undefined) this.frutiz = new Object();
		this.frutiz.xpLevel = this.basic.xpLevel;
		this.frutiz.xpCompletionRate = this.basic.xpCompletionRate;
		this.frutiz.frutiJob = node.attributes.fj;
		this.frutiz.sign = Lang.sign(node.attributes.fs);
		this.frutiz.signb = Lang.sign(node.attributes.fsb);
		this.frutiz.subday = Lang.formatDateString(node.attributes.ft,"day_short");
		this.frutiz.frutiAge = UserMng.birthdayToMonthAge(node.attributes.ft);
		this.frutiz.frutiRate = Number(node.attributes.fr);
		this.frutiz.blogName = node.attributes.bn;
		this.frutiz.blogUrl = "http://"+this.basic.nickname+".frutiparc.com/";
		
		// PERSO
		if(this.perso == undefined) this.perso = new Object();
		this.perso.age = this.basic.age;
		
		this.perso.birthday = Lang.formatDateString(this.basic.birthday,"day_short");
		this.perso.gender = this.basic.gender;
		this.perso.country = this.basic.country;
		this.perso.countryCode = this.basic.countryCode;
		this.perso.region = this.basic.region;
		
		this.perso.city = node.attributes.ct;
		this.perso.realJob = node.attributes.rj;
		this.perso.firstname = node.attributes.fn;
		this.perso.lastname = node.attributes.ln;
		
		// BONUS
		if(this.bonus == undefined) this.bonus = new Object();
		this.bonus.comment = node.attributes.cm;
		this.bonus.url = node.attributes.su;


		this.state_int.uinfo = 2;
		this.updateStateFromInt();
		
		if(this.state.basic == 2) this.callListeners("basic");
		if(this.state.frutiz == 2) this.callListeners("frutiz");
		if(this.state.perso == 2) this.callListeners("perso");
		if(this.state.bonus == 2) this.callListeners("bonus");
	}
	
	private function onStatusObj(obj){
		if(this.basic == undefined) this.basic = new Object();
		for(var n in obj){
			if(n == "listeners" || n == "autoListeners") continue;
			this.basic[n] = obj[n];
		}
		this.state_int.utrace = 2;
		this.updateStateFromInt();
		
		if(this.state.basic == 2){
			this.callListeners("basic");
		}
	}
	
	
	///// GESTION DE LA CNX A FRUTISCORE
	
	private function fscmd(n,a,x){
		if(this.fscnx != undefined && this.fsready){
			this.fscnx.cmd(n,a,x);
		}else{
			this.createFScoreCnx();
			this.fsWaitingCmd.push({n: n,a: a,x: x});
		}
	}
	
	private function createFScoreCnx(){
		if(this.fscnx != undefined) return;
		
		this.fsWaitingCmd = new Array();
		this.fsready = false;
		this.fscnx = new CBeeLocal({port: _global.cbeePort.frutiscore});
		this.fscnx.addListener("ident",this,"onFsCnxIdent");
		this.fscnx.addListener("onclose",this,"onFsCnxClose");
		this.fscnx.init();
	}
	
	private function deleteFScoreCnx(){
		this.fscnx.close();
		delete this.fscnx;
		this.fsready = false;
	}
	
	function onFsCnxIdent(node){
		if(node.attributes.k == undefined){
			this.fsready = true;
			for(var i=0;i<this.fsWaitingCmd.length;i++){
				var cmd = this.fsWaitingCmd[i];
				this.fscnx.cmd(cmd.n,cmd.a,cmd.x);
			}
		}
	}
	
	function onFsCnxClose(){
		this.fsready = false;
	}
	
//{
}
