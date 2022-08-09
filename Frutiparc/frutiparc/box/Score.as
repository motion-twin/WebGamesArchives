class box.Score extends box.Standard{
	
	var currentDate:Date;
	
	var currentRankingId:String;
	var currentStart:Number;
	var currentRanking:Object;
	var rankingList:Object;
	
	var currentGameScoreId:Number;
	var currentGameScore:Object;
	var rankingResultToRequire:Object;
	var currentGame:String;
	
	var nbResult:Number;
	var myRanks:Object;
	
	var awards:Array;
	
	var flLoading:Boolean = false;
	var lastRequest:Number;
	var minTimeTweenRequest:Number = 1500;
	var cnx:Object;
	var rankingPosToDisplay; // {rk,pos} : display this ranking/pos after loading rankinglist
	
	function Score(obj){
		this.winType = "winScore";
		
		this.nbResult = 10;
		
		for(var n in obj){
			this[n] = obj[n];
		}
		
		_global.uniqWinMng.setBox("score",this);
		
		if(this.currentDate == undefined){
			this.currentDate = _global.servTime.getDateObject();
			this.currentDate.setHours(12);
			this.currentDate.setMinutes(0);
			this.currentDate.setSeconds(0);
		}
		
		this.lastRequest = getTimer() - this.minTimeTweenRequest;
		this.setTitle(Lang.fv("scores")) 
		
		_global.me.xpFlagAdd("boxScoreOpened");
	}
	
	function preInit(){
		// called only at start of the first init
		this.desktopable = true;
		this.tabable = true;
		super.preInit();
	}

	function init(slot,depth){
		var rs = super.init(slot,depth);

		if(rs){
			// first init
			this.cnx = new CBeeLocal({port: _global.cbeePort.frutiscore});
			this.cnx.addListener("ident",this,"onIdent");
			this.cnx.init();
			this.cnx.addListener("xpranking",this,"onXPRanking");
			this.cnx.addListener("rateranking",this,"onRateRanking");
		}else{
			// change mode init
		}

		return rs;
	}
	
	function close(){
		this.cnx.removeListenerCmd("rankingresult","rk",this.currentRankingId);
		this.cnx.removeListenerCmd("xpranking");
		this.cnx.removeListenerCmd("rateranking");
		this.cnx.close();
		delete this.cnx;
		_global.uniqWinMng.unsetBox("score");
		super.close();
	}
	
	function onIdent(node){
		if(node.attributes.k != undefined){
			// TODO: error
		}else{
			this.onChangeDate();
		}
	}
	
	function nextDate(){
		if(this.flLoading) return false;
		
		this.currentDate.setTime( this.currentDate.getTime() + 24 * 3600 * 1000 );
		this.onChangeDate();
	}
	
	function prevDate(){
		if(this.flLoading) return false;
		
		this.currentDate.setTime( this.currentDate.getTime() - 24 * 3600 * 1000 );
		this.onChangeDate();
	}
	
	// str = 23-12-2003
	function setDate(str:String){
		if(this.flLoading) return false;
		
		var a = str.split("-");
		var y = FENumber.toStringL(Number(a[2].substr(0,4)),2);
		var m = FENumber.toStringL(Number(a[1].substr(0,2)),2);
		var d = FENumber.toStringL(Number(a[0].substr(0,2)),2);
		this.currentDate = FEDate.newFromString(y+"-"+m+"-"+d+" 12:00:00");
		this.onChangeDate();
	}

	function onChangeDate(){
		this.window.setDay(this.currentDate)
		this.getRankingList();
	}
	
	function getRankingList(){
		if(this.flLoading) return false;
		this.flLoading = true;
		this.window.setTree([{text: Lang.fv("loading")}]);
		if(getTimer() - this.lastRequest < this.minTimeTweenRequest){
			return this.callLater(arguments);
		}else{
			this.lastRequest = getTimer();
		}
		
		var uid = FEString.uniqId();
		this.cnx.addListener("listrankings",this,"onRankingList","r",uid);
		this.cnx.cmd("listrankings",{r: uid,dt: Lang.formatDate(this.currentDate,"prog_server")});
	}
	
	function onRankingList(node:XMLNode){
		if(node.attributes.r == undefined) return false;
		this.cnx.removeListenerCmd("listrankings","r",node.attributes.r);
		
		this.myRanks = undefined;

		var tree = new Array();
		
		this.rankingList = new Object();
		var rankingToDisplay;
		for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){
			if(n.nodeName != "s") continue;
				
			var sArr:Array = new Array();
			
			for(var m=n.firstChild;m.nodeType>0;m=m.nextSibling){
				if(m.nodeName != "rk") continue;
				
				this.rankingList[m.attributes.rk] = {name: m.attributes.rn,start: m.attributes.sst,end: m.attributes.et,gameScore: Number(m.attributes.gs),game: m.attributes.g,category: n.attributes.ty,type: m.attributes.ty,nbResult: undefined};
				sArr.push({text: m.attributes.rn,action: {obj: this,method: "getRanking",args: m.attributes.rk},bulletLink: "scoreBullet"});
				
				//this.rankingGame[m.attributes.rk] = ;

				if(this.currentGameScoreId != undefined && !isNaN(this.currentGameScoreId) && Number(m.attributes.gs) == this.currentGameScoreId && m.attributes.rk != this.currentRankingId){
					rankingToDisplay = m.attributes.rk;
				}
				
			}
			
			if(n.attributes.ty == "C"){
				var bf = 10;
			}else{
				var bf = 11;
			}
			tree.push({text: Lang.fv("score.ranking_type."+n.attributes.ty),list: sArr,flOpen: true,bulletLink: "scoreBullet",bulletFrame: bf});
		}
		
		tree.push({text: Lang.fv("score.xp_ranking"),action: {obj: this,method: "getXPRanking"},bulletLink: "scoreBullet",bulletFrame: 12});
		tree.push({text: Lang.fv("score.rate_ranking"),action: {obj: this,method: "getRateRanking"},bulletLink: "scoreBullet",bulletFrame: 12});
		
		this.window.setTree(tree);
		this.flLoading = false;
		
		
		if(this.rankingPosToDisplay != undefined){
			this.displayRankingPos(this.rankingPosToDisplay);
		}else if(rankingToDisplay != undefined){
			this.getRanking(rankingToDisplay);
		}
	}
	
	function getRanking(rId:String,start:Number,force:Boolean){
		if(rId == undefined) return false;
		if(start == undefined) start = 0;
		//if(rId == this.currentRankingId && start == this.currentStart) return false;
		
		if(!force){
			if(this.flLoading) return false;
			if(getTimer() - this.lastRequest < this.minTimeTweenRequest){
				this.window.displayWait();
				return this.callLater(arguments);
			}
		}
		this.window.displayWait();
		this.flLoading = true;
		this.lastRequest = getTimer();

		var needMyPos:Boolean;
		if(this.currentRankingId != rId){
			this.cnx.removeListenerCmd("rankingresult","rk",this.currentRankingId);
			this.cnx.addListener("rankingresult",this,"onRanking","rk",rId);
			
			needMyPos = true;
		}
		
		this.currentRankingId = rId;
		this.currentStart = start;
		
		this.currentRanking = this.rankingList[this.currentRankingId];
		
		
		if(this.myRanks == undefined){
			this.rankingResultToRequire = {rId: rId,start: start};
			this.getMyRanks();
		}else{
			if(this.currentRanking.gameScore != this.currentGameScoreId || this.currentRanking.game != this.currentGame){
				this.currentGameScoreId = this.currentRanking.gameScore;
				this.currentGame = this.currentRanking.game;

				// get gameScoreInfo, then rankingresult
				this.rankingResultToRequire = {rId: rId,start: start,okRequired: 2,ok: 0};
				this.cnx.addListener("GameScoreInfo",this,"onGameScoreInfo","gs",this.currentGameScoreId);
				this.cnx.cmd("gameScoreInfo",{gs: this.currentGameScoreId});
				
				// get Award
				var uid = FEString.uniqId();
				_global.mainCnx.addListener("awardgame",this,"onAward","r",uid);
				_global.mainCnx.cmd("awardgame",{r: uid,g: this.currentRanking.game});
			}else{

				// have already gameScoreInfo, get directly rankingresult
				if(this.currentRanking.nbResult == undefined){	
					this.cnx.cmd("rankingresult",{rk: rId,s: start,l: this.nbResult,c: 1});
				}else{
					this.cnx.cmd("rankingresult",{rk: rId,s: start,l: this.nbResult});
				}
			}
		}
	}
	
	function displayRankingPos(obj){
		this.getRanking(obj.rk,Math.floor((obj.pos-1)/this.nbResult)*this.nbResult);
	}
	
	function getNextPage(){
		if(this.currentRankingId == "_xp"){	
			this.getXPRanking(this.currentStart + this.nbResult);	
		}else if(this.currentRankingId == "_rate"){	
			this.getRateRanking(this.currentStart + this.nbResult);	
		}else{
			this.getRanking(this.currentRankingId,this.currentStart + this.nbResult);	
		}
	}
	
	function getPrevPage(){
		if(this.currentRankingId == "_xp"){	
			this.getXPRanking(this.currentStart - this.nbResult);	
		}else if(this.currentRankingId == "_rate"){	
			this.getRateRanking(this.currentStart - this.nbResult);	
		}else{
			if(this.currentStart > 0) this.getRanking(this.currentRankingId,this.currentStart - this.nbResult);
		}
	}
	
	function getMyRanks(){	
		this.flLoading = true;
		var rid:String = FEString.uniqId();
		this.cnx.addListener("UserResult",this,"onMyRanks","r",rid);
		var rs = new Array();
		for(var i in rankingList){
			rs.push(String(i));
		}
		this.cnx.cmd("UserResult",{rs: rs.join(","),r: rid});
	}
	
	function onMyRanks(node){
		this.cnx.removeListenerCmd("UserResult","r",node.attributes.r);
		this.myRanks = new Object();
		
		for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){
			this.myRanks[n.attributes.rk] = {pos: n.attributes.p,score: n.attributes.s,t: n.attributes.t,details: n.attributes.d}
		}
		
		if(this.rankingResultToRequire != undefined){
			var t = this.rankingResultToRequire;
			this.rankingResultToRequire = undefined;
			this.getRanking(t.rId,t.start,true);
		}
	}
	
	function onGameScoreInfo(node){
		this.cnx.removeListenerCmd("GameScoreInfo","gs",this.currentGameScoreId);
		
		this.currentGameScore = {};
		for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){
			if(n.nodeName == "ds"){
				this.currentGameScore.dataSpec = new Array();
				this.currentGameScore.columnTotalWidth = 0;
				for(var x=n.firstChild;x.nodeType>0;x=x.nextSibling){
					var obj = {type: x.attributes.t,name: x.attributes.n,width: Number(x.attributes.w),dat: x.firstChild.nodeValue.toString()};
					if(obj.type == "t"){
						obj.align = x.attributes.a;
					}
					this.currentGameScore.columnTotalWidth += obj.width;
					this.currentGameScore.dataSpec.push(obj);
				}
			}
		}
		
		if(this.rankingResultToRequire != undefined){
			this.rankingResultToRequire.ok++;
			if(this.rankingResultToRequire.okRequired == undefined || this.rankingResultToRequire.ok == this.rankingResultToRequire.okRequired){
				var t = this.rankingResultToRequire;
				this.rankingResultToRequire = undefined;
				this.getRanking(t.rId,t.start,true);
			}
		}
	}
	
	function onAward(node){
		_global.mainCnx.removeListenerCmd("awardgame","r",node.attributes.r);
		
		this.awards = new Array();
		for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){
			if(n.nodeName != "a") continue;
			this.awards[Number(n.attributes.v)-1] = {user: n.attributes.u,days: Number(n.attributes.d)};
		}
		
		if(this.rankingResultToRequire != undefined){
			this.rankingResultToRequire.ok++;
			if(this.rankingResultToRequire.okRequired == undefined || this.rankingResultToRequire.ok == this.rankingResultToRequire.okRequired){
				var t = this.rankingResultToRequire;
				this.rankingResultToRequire = undefined;
				this.getRanking(t.rId,t.start,true);
			}
		}
	}
	
	function onRanking(node){		
		
		if(node.attributes.c != undefined){
			this.currentRanking.nbResult = Number(node.attributes.c);
		}
		
		var pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[]
		}
		
	
		this.setTitle(Lang.fv("score.rk_title",{n: this.currentRanking.name,d: Lang.formatDate(this.currentDate,"short_date_only")}));
		
		// Display awards (only on page 1, if 3 awards available and currentRanking type is challenge)
		if(this.currentStart == 0 && this.awards.length == 3 && this.currentRanking.category == "C"){
			var frutizIcon = [
				{
					uid: "new",
					type: "contact",
					name: this.awards[0].user,
					desc: [this.awards[0].user+"@frutiparc.com"]
				},
				{
					uid: "new",
					type: "contact",
					name: this.awards[1].user,
					desc: [this.awards[1].user+"@frutiparc.com"]
				},
				{
					uid: "new",
					type: "contact",
					name: this.awards[2].user,
					desc: [this.awards[2].user+"@frutiparc.com"]
				}
			];
		
			var list:Array = [
				{ type: "spacer", big: 1 },
				{	type:"url",
					param:{
						url:Path.awards,
						min:{w:20},
						param:{
							frame:this.currentRanking.game,
							value:1,
							day:this.awards[0].days,
							scale: 50
						}
					}
				},
				{	type:"text",
					big: 1,
					param:{
						sid: 2,
						min: {w: 50},
						text: this.awards[0].user,
						menu: _global.getFileContextMenu(frutizIcon[0]),
						buttonAction: {
							onRelease: [
								{obj: _global,method: "onFileClick",args: frutizIcon[0]}
							]
						},
						// cf. un peu plus bas
						fieldProperty:{
							selectable: true
						},
						textFormat: {align: "left"}
					}
				},
				{ type: "spacer", big: 1 },
				{	type:"url",
					param:{
						url:Path.awards,
						min:{w:20},
						param:{
							frame:this.currentRanking.game,
							value:2,
							day:this.awards[1].days,
							scale: 50
						}
					}
				},
				{	type:"text",
					big: 1,
					param:{
						sid: 2,
						min: {w: 50},
						text: this.awards[1].user,
						menu: _global.getFileContextMenu(frutizIcon[1]),
						buttonAction: {
							onRelease: [
								{obj: _global,method: "onFileClick",args: frutizIcon[1]}
							]
						},
						// cf. un peu plus bas
						fieldProperty:{
							selectable: true
						},
						textFormat: {align: "left"}
					}
				},
				{ type: "spacer", big: 1 },
				{	type:"url",
					param:{
						url:Path.awards,
						min:{w:20},
						param:{
							frame:this.currentRanking.game,
							value:3,
							day:this.awards[2].days,
							scale: 50
						}
					}
				},
				{	type:"text",
					big: 1,
					param:{
						sid: 2,
						min: {w: 50},
						text: this.awards[2].user,
						menu: _global.getFileContextMenu(frutizIcon[2]),
						buttonAction: {
							onRelease: [
								{obj: _global,method: "onFileClick",args: frutizIcon[2]}
							]
						},
						// cf. un peu plus bas
						fieldProperty:{
							selectable: true
						},
						textFormat: {align: "left"}
					}
				},
				{ type: "spacer", big: 1 }
			]
			pageObj.lineList.push({list:list});
		}
		
		if(!node.hasChildNodes()){
			var list:Array = [
				{	type:"text", // frutiz
					big: 1,
					param:{
						sid: 2,
						min: {w: 100},
						text: Lang.fv("score.empty_ranking")
					}
				}
			]
			pageObj.lineList.push({list:list});
			
			if(this.currentStart > 0){
				var list:Array = [
					{	type:"button", // button prev
						param:{
							initObj: { txt: Lang.fv("score.prev") },
							buttonAction: {onRelease: [{obj: this,method: "getPrevPage"}]}
						}
					}
				]
				pageObj.lineList.push({list:list});
			}
			
		}else{
			var myRank = this.myRanks[this.currentRankingId];
			
			if(myRank == undefined){
				pageObj.lineList.push({list:[{
					type:"text", 
						big: 1,
						param:{
							sid: 2,
							min: {w: 100},
							text: Lang.fv("score.my_rank.empty"),
							textFormat: {align: "center"}
						}
				}]});
			}else{
				pageObj.lineList.push({list:[{
					type:"text", // frutiz
						big: 1,
						param:{
							sid: 2,
							min: {w: 100},
							text: Lang.fv("score.my_rank.details",{p: Lang.card2ord(myRank.pos),s: Lang.displayScoreType(Number(myRank.score),node.attributes.ty)}),
							buttonAction: {onRelease: [{obj: this,method: "displayRankingPos",args: {rk: this.currentRankingId,pos: myRank.pos}}]},
							textFormat: {align: "center"}
						}
				}]});
			}
		
			var maxRkPos = this.currentStart + this.nbResult;
			if(maxRkPos < 100){
				var rankingPosWidth = 25;
			}else if(maxRkPos < 1000){
				var rankingPosWidth = 35;
			}else{
				var rankingPosWidth = 45;
			}
		
			////////////// Columns titles ///////////////////////
			var list:Array = [
				{	type:"spacer", // rankingPos
					width: rankingPosWidth
				},
				{	type:"spacer", // fbouille
					width: 20
				},
				{	type:"text", // frutiz
					big: 1,
					param:{
						sid: 2,
						min: {w: 100},
						text: Lang.fv("score.column_title.frutiz")
					}
				},
				{	type:"text", // score
					width: 85,
					param:{
						sid: 2,
						text: Lang.fv("score.score_type."+node.attributes.ty),
						textFormat: {align: "right"}
					}
				}
			];

			// Additionnal fields
			if(this.currentGameScore.dataSpec != undefined){
				for(var n=0;n<this.currentGameScore.dataSpec.length;n++){
					var o = this.currentGameScore.dataSpec[n];
					list.push(
						{	type:"text",
							width: o.width,
							param:{
								sid: 2,
								text: o.name,
								textFormat: {align: (o.align==undefined)?'center':o.align}
							}
						}
					);
				}
			}

			list.push(
				{	type:"text", // hour
					width: 60,
					param:{
						sid: 2,
						text: Lang.fv("score.column_title.hour")
					}
				}
			);
			pageObj.lineList.push({list:list});

			////////////// Columns ///////////////////////
			var p:Number = this.currentStart;
			for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){
				p++;

				var frutizIcon = {
					uid: "new",
					type: "contact",
					name: n.attributes.u,
					fbouille: n.attributes.f,
					desc: [n.attributes.u+"@frutiparc.com"]
				}


				var list:Array = [
					{	type:"text", // rankingPos
						width: rankingPosWidth,
						param:{
							sid: 1,
							text: Lang.fv("score.column.rpos",{p: p}),
							textFormat: {align: "left",bold: true}
						}
					},
					{	type:"link", // fbouille
						link: "frutibouille",
						width: 20,
						param: {
							id: n.attributes.f,
							menu: _global.getFileContextMenu(frutizIcon) // TODO: faire que ça marche !!
						}
					},
					{	type:"text", // frutiz
						big: 1,
						param:{
							min: {w: 100},
							sid: 1,
							text: n.attributes.u,
							menu: _global.getFileContextMenu(frutizIcon),
							buttonAction: {
								onRelease: [
									{obj: _global,method: "onFileClick",args: frutizIcon}
								],
								onDragOut: [
									{obj: _global,method: "createDragIcon",args: frutizIcon}
								]
							},
							// TODO: trouve un truc plus crade encore :p
							fieldProperty:{ // non pas pour que ça soit selectable (le buttonAction nique tout ça de toute façon) mais pour que le menu fonctionne :)
								selectable: true
							}
						}
					},
					{	type:"text", // score
						width: 85,
						param:{
							sid: 1,
							text: Lang.displayScoreType(Number(n.attributes.s),node.attributes.ty),
							textFormat: {align: "right"}
						}
					}
				];

				// Additionnal fields
				if(this.currentGameScore.dataSpec != undefined){
					var misc_data = ext.util.MTSerialization.unserialize(n.attributes.d);
					if(misc_data == null){
						misc_data = n.attributes.d;
					}
					
					for(var i=0;i<this.currentGameScore.dataSpec.length;i++){
						var o = this.currentGameScore.dataSpec[i];
						
						switch(o.type){
							case "t": // text
								list.push(
									{	type:"text",
										width: o.width,
										param:{
											sid: 1,
											text: FEString.formatVars(o.dat,misc_data),
											textFormat: {align: (o.align==undefined)?'center':o.align}
										}
									}
								);
								break;
							case "s": // swf
								list.push(
									{	type:"url",
										width: o.width,
										param:{
											url: FEString.formatVars(Path.scoreDataMisc,{u: o.dat}),
											param: {data: misc_data}
										}
									}
								);
								break;
						} // end switch type

					}// end for dataSpec
				} // end if

				list.push(
					{	type:"text", // hour
						width: 60,
						param:{
							sid: 1,
							text: Lang.formatDateString(n.attributes.t,"time_short")
						}
					}
				);
				pageObj.lineList.push({list:list,min: {h: 20}});

			} // end for scores
			
			
			var list:Array = [];
			
			if(this.currentStart > 0){
				list.push(
					{	type:"button", // button prev
						param:{
							initObj: { txt: Lang.fv("score.prev") },
							buttonAction: {onRelease: [{obj: this,method: "getPrevPage"}]}
						}
					}
				);
			}
			list.push(
				{	type:"spacer", // central spacer
					big: 1
				}
			);
			if(this.currentStart + this.nbResult < this.currentRanking.nbResult || (this.currentRanking.nbResult == undefined && p == this.currentStart + this.nbResult)){
				list.push(
					{	type:"button", // button prev
						param:{
							initObj: { txt: Lang.fv("score.next") },
							buttonAction: {onRelease: [{obj: this,method: "getNextPage"}]}
						}
					}
				);
			}
			
			pageObj.lineList.push({height:4})
			pageObj.lineList.push({list:list});
			
		} // end if hasChildNodes()
		
		if(this.currentGameScore.columnTotalWidth == undefined) this.currentGameScore.columnTotalWidth = 0;
		this.window.main.showFrame.min.w = 310 + this.currentGameScore.columnTotalWidth;
		this.window.main.showFrame.min.h = 100 + this.nbResult * 20;
		this.window.setDisplayPanel(pageObj);
		this.flLoading = false;
	} // end function
	
	function getXPRanking(start){
		if(this.flLoading) return false;
		this.flLoading = true;
		this.window.displayWait();
		if(getTimer() - this.lastRequest < this.minTimeTweenRequest){
			return this.callLater(arguments);
		}else{
			this.lastRequest = getTimer();
		}
		
		this.window.displayWait();
		
		if(start == undefined) start = 0;
		this.currentStart = start;
		this.currentRankingId = "_xp";
		this.cnx.cmd("xpranking",{s: start,l: this.nbResult});
		
	}
	
	function onXPRanking(node){
		_global.debug("onXPRanking");
		var pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[]
		}
		
		this.setTitle(Lang.fv("score.xp_ranking"));
		
		if(!node.hasChildNodes()){
			var list:Array = [
				{	type:"text", // frutiz
					big: 1,
					param:{
						sid: 2,
						min: {w: 100},
						text: Lang.fv("score.empty_ranking")
					}
				}
			]
			pageObj.lineList.push({list:list});
			
			if(this.currentStart > 0){
				var list:Array = [
					{	type:"button", // button prev
						param:{
							initObj: { txt: Lang.fv("score.prev") },
							buttonAction: {onRelease: [{obj: this,method: "getPrevPage"}]}
						}
					}
				]
				pageObj.lineList.push({list:list});
			}
			
		}else{
	
			var maxRkPos = this.currentStart + this.nbResult;
			if(maxRkPos < 100){
				var rankingPosWidth = 25;
			}else if(maxRkPos < 1000){
				var rankingPosWidth = 35;
			}else{
				var rankingPosWidth = 45;
			}
		
			////////////// Columns titles ///////////////////////
			var list:Array = [
				{	type:"spacer", // rankingPos
					width: rankingPosWidth
				},
				{	type:"spacer", // fbouille
					width: 20
				},
				{	type:"text", // frutiz
					big: 1,
					param:{
						sid: 2,
						min: {w: 100},
						text: Lang.fv("score.column_title.frutiz")
					}
				},
				{	type:"text", // score
					width: 95,
					param:{
						sid: 2,
						text: Lang.fv("score.score_type.xp"),
						textFormat: {align: "right"}
					}
				}
			];
			pageObj.lineList.push({list:list});

			////////////// Columns ///////////////////////
			var p:Number = this.currentStart;
			for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){
				p++;

				var frutizIcon = {
					uid: "new",
					type: "contact",
					name: n.attributes.u,
					fbouille: n.attributes.f,
					desc: [n.attributes.u+"@frutiparc.com"]
				}


				// TODO; changer la largueur de la colonne selon la position
				var list:Array = [
					{	type:"text", // rankingPos
						width: rankingPosWidth,
						param:{
							sid: 1,
							text: Lang.fv("score.column.rpos",{p: p}),
							textFormat: {align: "left",bold: true}
						}
					},
					{	type:"link", // fbouille
						link: "frutibouille",
						width: 20,
						param: {
							id: n.attributes.f,
							menu: _global.getFileContextMenu(frutizIcon) // TODO: faire que ça marche !!
						}
					},
					{	type:"text", // frutiz
						big: 1,
						param:{
							min: {w: 100},
							sid: 1,
							text: n.attributes.u,
							menu: _global.getFileContextMenu(frutizIcon),
							buttonAction: {
								onRelease: [
									{obj: _global,method: "onFileClick",args: frutizIcon}
								],
								onDragOut: [
									{obj: _global,method: "createDragIcon",args: frutizIcon}
								]
							},
							// TODO: trouve un truc plus crade encore :p
							fieldProperty:{ // non pas pour que ça soit selectable (le buttonAction nique tout ça de toute façon) mais pour que le menu fonctionne :)
								selectable: true
							}
						}
					},
					{	type:"text", // score
						width: 95,
						param:{
							sid: 1,
							text: Lang.displayScoreType(Number(n.attributes.s),"xp"),
							textFormat: {align: "right"}
						}
					}
				];


				pageObj.lineList.push({list:list,min: {h: 20}});

			} // end for scores
			
			
			var list:Array = [];
			
			if(this.currentStart > 0){
				list.push(
					{	type:"button", // button prev
						param:{
							initObj: { txt: Lang.fv("score.prev") },
							buttonAction: {onRelease: [{obj: this,method: "getPrevPage"}]}
						}
					}
				);
			}
			list.push(
				{	type:"spacer", // central spacer
					big: 1
				}
			);
			if(p == this.currentStart + this.nbResult){
				list.push(
					{	type:"button", // button prev
						param:{
							initObj: { txt: Lang.fv("score.next") },
							buttonAction: {onRelease: [{obj: this,method: "getNextPage"}]}
						}
					}
				);
			}
			
			pageObj.lineList.push({height:4})
			pageObj.lineList.push({list:list});
			
		} // end if hasChildNodes()
		
		this.window.main.showFrame.min.w = 300;
		this.window.main.showFrame.min.h = 80 + this.nbResult * 20;
		this.window.setDisplayPanel(pageObj);
		this.flLoading = false;
	}
	
	function getRateRanking(start){
		if(this.flLoading) return false;
		this.flLoading = true;
		this.window.displayWait();
		if(getTimer() - this.lastRequest < this.minTimeTweenRequest){
			return this.callLater(arguments);
		}else{
			this.lastRequest = getTimer();
		}
		
		this.window.displayWait();
		
		if(start == undefined) start = 0;
		this.currentStart = start;
		this.currentRankingId = "_rate";
		this.cnx.cmd("rateranking",{s: start,l: this.nbResult});
		
	}
	
	function onRateRanking(node){
		_global.debug("onRateRanking");
		var pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[]
		}
		
		this.setTitle(Lang.fv("score.rate_ranking"));
		
		if(!node.hasChildNodes()){
			var list:Array = [
				{	type:"text", // frutiz
					big: 1,
					param:{
						sid: 2,
						min: {w: 100},
						text: Lang.fv("score.empty_ranking")
					}
				}
			]
			pageObj.lineList.push({list:list});
			
			if(this.currentStart > 0){
				var list:Array = [
					{	type:"button", // button prev
						param:{
							initObj: { txt: Lang.fv("score.prev") },
							buttonAction: {onRelease: [{obj: this,method: "getPrevPage"}]}
						}
					}
				]
				pageObj.lineList.push({list:list});
			}
			
		}else{
	
			var maxRkPos = this.currentStart + this.nbResult;
			if(maxRkPos < 100){
				var rankingPosWidth = 25;
			}else if(maxRkPos < 1000){
				var rankingPosWidth = 35;
			}else{
				var rankingPosWidth = 45;
			}
		
			////////////// Columns titles ///////////////////////
			var list:Array = [
				{	type:"spacer", // rankingPos
					width: rankingPosWidth
				},
				{	type:"spacer", // fbouille
					width: 20
				},
				{	type:"text", // frutiz
					big: 1,
					param:{
						sid: 2,
						min: {w: 100},
						text: Lang.fv("score.column_title.frutiz")
					}
				},
				{	type:"text", // score
					width: 95,
					param:{
						sid: 2,
						text: Lang.fv("score.score_type.rate"),
						textFormat: {align: "right"}
					}
				}
			];
			pageObj.lineList.push({list:list});

			////////////// Columns ///////////////////////
			var p:Number = this.currentStart;
			for(var n=node.firstChild;n.nodeType>0;n=n.nextSibling){
				p++;

				var frutizIcon = {
					uid: "new",
					type: "contact",
					name: n.attributes.u,
					fbouille: n.attributes.f,
					desc: [n.attributes.u+"@frutiparc.com"]
				}


				// TODO; changer la largueur de la colonne selon la position
				var list:Array = [
					{	type:"text", // rankingPos
						width: rankingPosWidth,
						param:{
							sid: 1,
							text: Lang.fv("score.column.rpos",{p: p}),
							textFormat: {align: "left",bold: true}
						}
					},
					{	type:"link", // fbouille
						link: "frutibouille",
						width: 20,
						param: {
							id: n.attributes.f,
							menu: _global.getFileContextMenu(frutizIcon) // TODO: faire que ça marche !!
						}
					},
					{	type:"text", // frutiz
						big: 1,
						param:{
							min: {w: 100},
							sid: 1,
							text: n.attributes.u,
							menu: _global.getFileContextMenu(frutizIcon),
							buttonAction: {
								onRelease: [
									{obj: _global,method: "onFileClick",args: frutizIcon}
								],
								onDragOut: [
									{obj: _global,method: "createDragIcon",args: frutizIcon}
								]
							},
							// TODO: trouve un truc plus crade encore :p
							fieldProperty:{ // non pas pour que ça soit selectable (le buttonAction nique tout ça de toute façon) mais pour que le menu fonctionne :)
								selectable: true
							}
						}
					},
					{	type:"text", // score
						width: 95,
						param:{
							sid: 1,
							text: Lang.displayScoreType(Number(n.attributes.s),"rate"),
							textFormat: {align: "right"}
						}
					}
				];


				pageObj.lineList.push({list:list,min: {h: 20}});

			} // end for scores
			
			
			var list:Array = [];
			
			if(this.currentStart > 0){
				list.push(
					{	type:"button", // button prev
						param:{
							initObj: { txt: Lang.fv("score.prev") },
							buttonAction: {onRelease: [{obj: this,method: "getPrevPage"}]}
						}
					}
				);
			}
			list.push(
				{	type:"spacer", // central spacer
					big: 1
				}
			);
			if(p == this.currentStart + this.nbResult){
				list.push(
					{	type:"button", // button prev
						param:{
							initObj: { txt: Lang.fv("score.next") },
							buttonAction: {onRelease: [{obj: this,method: "getNextPage"}]}
						}
					}
				);
			}
			
			pageObj.lineList.push({height:4})
			pageObj.lineList.push({list:list});
			
		} // end if hasChildNodes()
		
		this.window.main.showFrame.min.w = 300;
		this.window.main.showFrame.min.h = 80 + this.nbResult * 20;
		this.window.setDisplayPanel(pageObj);
		this.flLoading = false;
	}	
	
	function callLater(args){
		var obj = {args: args};
		obj.interval = setInterval(this,"execCallLater",this.minTimeTweenRequest - getTimer() + this.lastRequest,obj);
		
		return false;
	}
	
	function execCallLater(obj){
		this.flLoading = false; // sans ça la fonction considère qu'il y a déjà un chargement en cours
		this.lastRequest = getTimer() - this.minTimeTweenRequest - 1; // recalage du lastRequest au cas où
		obj.args.callee.apply(this,obj.args);		
		clearInterval(obj.interval);
	}
}
