/*----------------------------------------------

		FRUTIPARC 2 Frutiz

----------------------------------------------*/

class win.Frutiz extends WinStandard{//}

	// CONSTANTES
	var base:Number = 42//56;
	
	// PARAMETRE
	var iconList:Array; // vient de la box
	
	// VARIABLES
	var flAdvancedMode:Boolean;
	var info:Object;
	var leftIconList:Array;
	var rightIconList:Array;
	var categoryList:Array;
	
	
	var displayInfo:Object;
	
	// REFERENCES
	var screen:cp.FrutiScreen;
	var upInfo:cp.FrutizBasicInfo;
	var mcLeftIconList:cp.IconListBasic;
	var mcRightIconList:cp.IconListBasic;
	var explorer:cp.Document;
	var barLevel:bar.Level;
	
	
	
	function Frutiz(){
		if(this.iconList==undefined) this.iconList = new Array();
	
		this.init();
	}
	
	function init(){
		//_root.test+="[winFrutiz] init()\n"
		this.flTrace = true;
		
		this.genIconList([]);
		this.genDisplayInfo();
		this.flAdvancedMode = false;
		super.init();
		
		
		
		/* HACK
		this.box.frutizInfo = {
			
			basic : {
				nickname : 		"bumdum",
				xpLevel : 		4,
				xpCompletionRate : 	0.13,
				age : 			25,
				birthday :		"1983-22-09",
				gender :		"M",
				country : 		"France",
				region :		"Pyr-Atlantiques",		
				fBouille:		"000602000000020000",
				presence:		1,
				flMute:			false,
				status:			{
								internal:"forum",
								external:"rien",
								emote:2
							}
			},
			
			frutiz:{
				profession:		"modérateur",
				sign:			"banane",
				rate:			98.47,
				age:			3,
				xpLevel : 		4,
				xpCompletionRate : 	0.13,
				subday:			"2004-01-12"
				
			},
			perso:{
				firstname:		"Benjamin",
				lastname:		"Soulé",
				age:			25,
				gender:			"M",
				birthday :		"1983-22-09",
				city:			"Bordeux",
				country : 		"France",
				region :		"Pyr-Atlantiques",
				profession:		"Infographiste"
				
				
			},			
			bonus:{
				comment: "Blablablablabla...",
				url: "http://mon-site-a-moi.mon-hebergement-qui-est-cool.com"					
			},
			scores:{
				ranking:[
					{ discName:"bkiwi",		id: 5, title: "Burning Kiwi",	score: "5'55",		pos: 50		},
					{ discName:"snake",		id: 5, title: "Frutisnake 3",	score: "120780",	pos: 13		},
					{ discName:"hammer",		id: 4, title: "C.hammerfest",	score: "370780",	pos: 1		},
					{ discName:"ball",		id: 5, title: "Motionball 2",	score: "3210",		pos: 154	},
					{ discName:"grapiz",		id: 5, title: "Grapiz",		score: "28 victoires",	pos: 2		},
					{ discName:"bandas",		id: 5, title: "Frutibandas",	score: "2 victoires",	pos: 1289	}
				],
				awards:[
					{
						game: "bkiwi",
						value: 1,
						days: 5
					},
					{
						game: "grapiz",
						value: 2,
						days: 0
					},
					{
						game: "grapiz",
						value: 2,
						days: 0
					},
					{
						game: "grapiz",
						value: 2,
						days: 0
					},
					{
						game: "grapiz",
						value: 2,
						days: 0
					},
					{
						game: "grapiz",
						value: 2,
						days: 0
					},
					{
						game: "grapiz",
						value: 2,
						days: 0
					},
					{
						game: "grapiz",
						value: 2,
						days: 0
					},
					{
						game: "grapiz",
						value: 2,
						days: 0
					},
					
					{
						game: "hammer",
						value: 3,
						days: 5
					}						
				],
				fcardList:[
					"bkiwi",
					"mb2",
					"snake3"
				]				
			}
		}

		//*/
		
		this.categoryList = [
			"frutiz",
			"perso",
			"scores",
			"bonus"
		];
		
		
		
		
		this.endInit();
		this.loadInfo("basic")
		//this.upInfo.setInfo(this.box.frutizInfo.basic);
		
		// j'ai enlevé ça paske ça avait l'air de poser pb... faut voir si c bien ce qu'il fallait faire
		//this.screen.addContent("frutibouille",{},1);
		
		
	
	}
	
	function genDisplayInfo(){
		this.displayInfo = {
			frutiz:[
				{ n:"frutiJob :",			v:"frutiJob" 				},	
				{ n:"consécration :",			v:"frutiRate", 		s:" %"		},	
				{ n:"niveau :",				v:"xpLevel" 				},	
				{ n:"frutiAge :",			v:"frutiAge", 		s:" mois"	},	
				{ n:"inscription :",			v:"subday" 				}	
			],
			perso:[
				{ n:"Prénom :",				v:"firstname" 		},	
				{ n:"Nom :",				v:"lastname" 		},	
				{ n:"Date de naissance :",		v:"birthday" 		},
				{ n:"Activité :",			v:"realJob" 		},	
				{ n:"Pays :",				v:"country" 		},	
				{ n:"Région :",				v:"region" 		},	
				{ n:"Ville :",				v:"city" 		}	
			]
		}
	}
	
	function genIconList(){
		this.leftIconList = new Array();
		for(var i=0;i<this.iconList.length;i++){
			var o = this.iconList[i];
			
			this.leftIconList.push(
				{link:"butPush", param:{
						link:"butPushSmallWhite",
						frame:o.frame,
						outline:2,
						curve:4,
						buttonAction:{ 
							onRelease:[{obj: this.box,method: "execCallBack",args: o.callBack}]
						},
						tipId: o.tipId
					}
				}
			);
		}

		this.rightIconList = [
			{link:"butPush", param:{
					link:"butPushSmallPink",
					frame:13,
					outline:2,
					curve:4,
					buttonAction:{ 
						onPress:[{
							obj:this,
							method:"toggleAdvancedMode"
						}]
					}
				}
			}		
		];
			
	}
	
	function initFrameSet(){
		super.initFrameSet();

		
		// BARRE HAUT
		var margin = Standard.getMargin()
		margin.x.min = 12
		margin.y.min = 5
		margin.y.ratio = 1
		var frame = {
			margin:margin,
			name:"up",
			type:"h",
			min:{w:0,h:this.base}
		}		
		this.margin.top.newElement( frame )
	
			// SCREEN
			var xpWidth = 36//40 
			var marginExt = 0
			var args = {
				fix:{w:this.base+xpWidth,h:this.base}
			};
			var margin = Standard.getMargin()
			margin.x.min = marginExt
			margin.y.min = marginExt
			var frame = {
				margin:margin,
				name:"screenFrame",
				link:"frutiScreen",
				type:"compo",
				mainStyleName:"frSystem",
				min:{w:this.base+marginExt+xpWidth,h:this.base+marginExt},
				args:args
			};
			this.screen = this.margin.top.up.newElement( frame )

			// MID
			var frame = {
				name:"mid",
				type:"w",
				min:{w:240,h:this.base}
			}		
			this.margin.top.up.newElement( frame )			
			this.margin.top.up.bigFrame = this.margin.top.up.mid;	
				// INFO
				var args = {
				};
				var frame = {
					name:"info",
					link:"cpFrutizBasicInfo",
					type:"compo",
					min:{w:200,h:20},
					args:args
				};
				this.upInfo = this.margin.top.up.mid.newElement( frame )
				this.margin.top.up.mid.bigFrame = this.margin.top.up.mid.info;			
				// ICONS
				var margin = Standard.getMargin();
				margin.x.min = 4
				margin.x.ratio = 1
				var frame = {
					name:"icon",
					type:"h",
					margin:margin,
					min:{w:200,h:0}
				}		
				this.margin.top.up.mid.newElement( frame )				
					// LEFT ICONS
					var struct = Standard.getSmallStruct();
					struct.x.margin = 0;
					struct.y.margin = 0
					struct.x.align = "start"
					struct.y.align = "start"
					//struct.x.sens = -1;
					var args = {
						//flMarker:true,
						list:this.leftIconList,
						struct:struct,
						flMask:true,
						mask:{flScrollable:false}
						
					};
					var frame = {
						name:"left",
						link:"basicIconList",
						type:"compo",
						min:{w:20,h:24},
						args:args
					}
					this.mcLeftIconList = this.margin.top.up.mid.icon.newElement( frame )
					this.margin.top.up.mid.icon.bigFrame = this.margin.top.up.mid.icon.left;
					// RIGHT ICONS
					var struct = Standard.getSmallStruct();
					struct.x.margin = 0
					struct.y.margin = 0
					struct.x.align = "end"
					struct.y.align = "start"
					var args = {
						//flMarker:true,
						list:this.rightIconList,
						struct:struct,
						mask:{flScrollable:false}
					};
					var frame = {
						name:"right",
						link:"basicIconList",
						type:"compo",
						min:{w:26,h:24},
						args:args
					}
					this.mcRightIconList = this.margin.top.up.mid.icon.newElement( frame )
			
	}
	
	function initDesktopMode(){	 // SURCHARGE VOLONTAIRE NE PAS EFFACER
	
	}

	function initInterface(){
		super.initInterface();
		this.mcInterface.onPress = function(){
			_parent.box.activate();
			_parent.initDrag();
		}
		this.mcInterface.onRelease = this.mcInterface.onReleaseOutside = function(){
			_parent.endDrag();
		}
	}
	
	// ADVANCED
	
	function toggleAdvancedMode(){
		if(!this.flAdvancedMode){
			this.initAdvancedMode();
		}else{
			this.exitAdvancedMode();
		}
		this.flAdvancedMode = !this.flAdvancedMode
		this.update();
	}
	
	function initAdvancedMode(){
		//_root.test+="[winFrutiz]initAdvancedMode()\n"
		
		var args = {
			//pageObj:{pos:{x:0,y:0,w:0,h:0},lineList:[{height:10}]},//new XML("<p><l><t>coucou</t></l></p>")
			//flDocumentFit:true
			//flNeverEnding:true,
			flMask:true
		};
		var margin = Standard.getMargin();
		margin.y.min = 4
		margin.y.ratio = 1
		var frame = {
			margin:margin,
			name:"explorer",
			link:"cpDocument",
			mainStyleName:"frSheet",
			type:"compo",
			flBackground:true,
			min:{w:250,h:244},
			args:args
		};
		this.explorer = this.main.newElement( frame )
		this.explorer.displayWait();
		this.loadInfo("frutiz");

	}
	
	function exitAdvancedMode(){
		
		this.main.removeElement("explorer")
		this.pos.h = this.base//+400;
		
	}
	
	//	
	function getPageObj(cat){
		// BASE
		var pageObj = {
			pos:{x:0,y:0,w:250,h:240},
			lineList:[]
		}
		// MENU
		//this.getListLine()
		var info = this.box.frutizInfo[cat];
		pageObj.lineList = pageObj.lineList.concat(this.getMenuLine(cat)) //this.getMenuLine(cat)//push(this.getMenuLine(cat))//concat(this.getMenuLine(cat))
		//_root.test+="this.box.frutizInfo.sign("+this.box.frutizInfo.sign+")\n"
		switch(cat){
			case "frutiz":
				pageObj.lineList.push(this.getTitleLine("frutisigne"))
				var line = [
					{	type:"spacer",	big:2	},
					//*
					{	
						type:"url",
						dy:25,
						param:{
							url: Path.frutiSign,
							param:{
								_xscale:50,
								_yscale:50,
								sign:this.box.frutizInfo.frutiz.signb
							}
						}						
					},
					{	type:"spacer",	big:1	},
					//*/
					{	
						type:"url",
						dy:25,
						param:{
							url: Path.frutiSign,
							param:{
								sign:this.box.frutizInfo.frutiz.sign
							}
						}						
					},
					{	type:"spacer",	big:1	},
					{	
						type:"url",
						dy:25,
						param:{
							url: Path.frutiSign,
							param:{
								_xscale:50,
								_yscale:50,
								sign:this.box.frutizInfo.frutiz.signb
							}
						}						
					},					
					{	type:"spacer",	big:2	}
					
				]
				pageObj.lineList.push({list:line,height:60})
				pageObj.lineList = pageObj.lineList.concat(this.getListLine(this.displayInfo.frutiz,info))
			
				if( info.blogName.length > 0 ){
					var bline = [
						{
							type:"spacer",
							width:14
						},
						
						{
							type:"text",
							big:1.5,
							param:{
							
								sid: 1,
								text: "frutiBlog :"
							}
						},
						{
							type:"text",
							big:1,
							param:{
								sid: 1,
								text: info.blogName,
								buttonAction: {
									onRelease: [
										{
											obj: this.box,
											method: "getUrl",
											args: info.blogUrl
										}
									]
								},
								textFormat:{
									align:"right"
								}
							}
						},
						{
							type:"spacer",
							width:14
						}
					];
					
					pageObj.lineList.push({list:bline});
				}
				break;
			case "perso":
				pageObj.lineList = pageObj.lineList.concat(this.getListLine(this.displayInfo.perso,info))
				break;
			case "scores":
				/*
				scores: [{
					id: 5, // ranking_id : pourra être utile par la suite
					title: "Terre Grise", // nom du classement
					score: "5'55", // score en lui même, déjà formatté
					pos: 5
				},
				*/
				// MEDAILLE DU JOUR
				if(info.awards.length>0){
					pageObj.lineList.push(this.getTitleLine("Médailles"))
					pageObj.lineList.push(this.getAwardsLine(info.awards))
					pageObj.lineList.push({height:8})
					pageObj.lineList.push(this.getSepLine())
				}
				// SCORE DU JOUR
				pageObj.lineList.push(this.getTitleLine("Scores du jour"))
				pageObj.lineList = pageObj.lineList.concat(this.getRankingLines(info.ranking))
				pageObj.lineList.push({height:8})
				pageObj.lineList.push(this.getSepLine())
				
				// JEUX POSSEDES
				//_root.test+="info.fcardList.length("+info.fcardList.length+")\n"
				if(info.fcardList.length>0){
					pageObj.lineList.push(this.getTitleLine("Fruticard !"))
					for(var i=0; i<info.fcardList.length; i++){
						var gameName = info.fcardList[i];
						var o =	{	
							type:"text",
							big: 1,
							param:{
								sid: 1,
								text: Lang.gameName(gameName),
								buttonAction: {
									onRelease: [
										{obj:this, method:"loadFrutiCard",args:gameName}
									]
								},
								fieldProperty:{
									selectable:true
								},
								textFormat:{
									bold:true,
									align:"center"
								}
							}
						}
						pageObj.lineList.push({list:[o]});
					}
					pageObj.lineList.push({height:8})
					pageObj.lineList.push(this.getSepLine())
				}
				break;
			case "bonus":
				// URL
				var flContent = false;
				//_root.test+="info.comment("+info.comment+")\n"
				if(info.url!=undefined && info.url.length){
					flContent = true;
					pageObj.lineList.push( this.getTitleLine("Site Internet") )
					var list = [
						{ type:"spacer",	big:1 },
						{
							type:"text",
							width: 300,
							param:{
								//sid: 1,
								text: info.url,
								buttonAction: {
									onRelease: [
										{
											obj: this.box,
											method: "getUrl",
											args: info.url
										}
									]
								},
								fieldProperty:{
									selectable:true
								},
								textFormat:{
									//bold:true,
									align:"center"
								}
							}						
						},
						{ type:"spacer",	big:1 }
					]
					pageObj.lineList.push( {list:list,height:32} )
				}
				if(info.comment!=undefined && info.comment!=""){
					flContent = true;
					pageObj.lineList.push( this.getTitleLine("Commentaire") )
					var list = [
						{ type:"spacer",	width:8 },
						{
							type:"text",
							big:1,
							param:{
								text: info.comment,
								textFormat:{
									align:"center"
								}				
							}						
						},
						{ type:"spacer",	width:8 }
					]
					pageObj.lineList.push( {list:list} )
				}				
				
				if(flContent){
					pageObj.lineList.push(this.getSepLine())
				}else{
					pageObj.lineList.push( this.getTitleLine("aucune info") )
				}
				
				
				break;
		}
		pageObj.lineList = pageObj.lineList.concat(this.getEndLine(cat))
		return pageObj;
	}
	
	function getTitleLine(title,width){
		var margin = Standard.getMargin();
		margin.y.min = 8
		margin.y.ratio = 1
		
		if(width == undefined)width = title.length*10;
		
		var line = {
			
			list:[
				{
					type:"spacer",
					width:14
					//big:1
				},
				{
					type:"line",
					size:2,
					//width:80,
					big:1,
					param:{
						margin:margin
					}
				},
				{
					type:"text",
					width:width,//120,
					param:{
						sid: 2,
						text: title,
						textFormat:{
							align:"center"
						}
					}						
				},
				{
					type:"line",
					size:2,
					//width:80,
					big:1,
					param:{
						margin:margin
					}
				},
				{
					type:"spacer",
					width:14
				}					
			]
		}
		return line			
	}

	function getEndLine(currentCat){
		var lineList = new Array();
		// LIGNE
		var line = {
			big:1
		} 
		lineList.push(line)
		return 	lineList			
	}
		
	function getMenuLine(currentCat){
		//_root.test+="getMenuLine()\n"
		
		var lineList = new Array();
		var line;
		// ESPACE
		line = {height:4}
		lineList.push(line)
		
		//MENU
		var list = new Array();
		for( var i=0; i<this.categoryList.length; i++ ){
			var cat = this.categoryList[i]
			var sid = 1
			if(currentCat==cat)sid+=10;
			var o =	{	
				type:"text",
				big: 1,
				param:{
					//min: {w: 100},
					sid: sid,
					text: cat,
					buttonAction: {
						onRelease: [
							{obj:this, method:"loadInfo",args:cat}
						]
					},
					fieldProperty:{
						selectable:true
					},
					textFormat:{
						bold:true,
						align:"center"
					}
				}
			}
			list.push(o)
		}
		lineList.push({list:list})
		
		// LIGNE
		var line = {
			big:1,
			height:8,
			list:[
				{
					type:"line",
					size:2,
					big:1
				}
			]
		} 
		lineList.push(line)
		
		return 	lineList			
	}
	
	function getSepLine(){
		var margin = Standard.getMargin()
		margin.x.min = 28
		var line = {
			height:2,
			list:[
				{
					type:"line",
					size:2,
					big:1,
					//width:240,
					param:{
						margin:margin
					}
				}
			]
		}
		return line				
	}
	
	function getRankingLines(list){
		var lines = new Array();
		for( var i=0; i<list.length; i++ ){
			var o = list[i];
			var pos = Lang.card2ord(o.pos);
			var score = Lang.displayScoreType(o.score,o.type);

			var line = [
				{
					type:"spacer",
					big:1
				},
				{
					type:"link",
					link:"gfxList",
					width:20,
					dx:10,
					dy:10,
					param:{
						link:"icoInterne",
						frame:o.discName
					}
				},						
				{
					type:"text",
					width:120,
					param:{
						sid: 1,
						text: o.title,
						buttonAction: {
							onRelease: [
								{obj: _global.uniqWinMng,method: "displayRanking",args: {rk: o.id,pos: o.pos}}
							]
						}
					}
				},
				{
					type:"text",
					width:80,
					param:{
						sid: 1,
						text: score,
						textFormat:{
							align:"right"
						}
					}
				},
				{	
					type:"text",
					width:80,
					param:{
						sid: 1,
						text: pos,
						textFormat:{
							align:"right"
						}
					}
				},						
				{
					type:"spacer",
					big:1
				}
			]
			lines.push({list:line})
		}
		return lines		
	}
	
	function getAwardsLine(list){
		var line = { height:40,list:[]};
		line.list.push({type:"spacer",big:1});
		for (var i=0; i<list.length; i++){
			_root.test+="o.game("+o.game+") o.discName("+o.discName+")\n"
			var o = list[i];
			var e = {
				type:"url",
				param:{
					url:Path.awards,
					min:{w:30},
					param:{
						frame:o.game,
						value:o.value,
						day:o.day
					}
				}
			}			
			line.list.push(e);
			line.list.push({type:"spacer",big:1});
			
		}
		//line.list.push({type:"spacer",big:1});
		return line;
	}
		
	function getListLine(list,info){
		var lines = new Array();
		lines.push(this.getSepLine())
		for( var i=0; i<list.length; i++ ){
			var o = list[i];
			var name = info[o.v];
			if(o.s!=undefined) name+=o.s;
			
			var line = [
				{
					type:"spacer",
					width:14
				},
				
				{
					type:"text",
					big:1.5,
					param:{
						sid: 1,
						text: o.n
					}
				},
				{
					type:"text",
					big:1,
					param:{
						sid: 1,
						text: name,
						textFormat:{
							align:"right"
						}
					}
				},
				{
					type:"spacer",
					width:14
				}
			]
			lines.push({list:line})
			//pageObj.lineList.push({list:line})		
		}
		lines.push(this.getSepLine())
		//lines = lines.concat(this.getSepLine())
		return lines
	}

	function getFrutiCardLines(frutiCard,gameName){		// DEVRAIT ETRE PLACE DANS UN SWF EXTERENE D'UNE MANIERE OU D'UN AUTRE

		/*
		_root.test = "getFrutiCardLines("+frutiCard+")\n"
		for(var e in frutiCard){
			_root.test+="- "+e+" = "+frutiCard[e]+"\n"
		}
		*/
		/* HACK BKIWI
		frutiCard = {
			$ws:1,
			$wss:1,
			$wc:0,
			$wcs:1,
			$ac:[1,1,0,0,1],
			$ts:[
				{  $fcLap:150000, $fcTotal:150000,	$lapCar:1,	$totalCar:2 },
				{  $fcLap:150000, $fcTotal:150000,	$lapCar:1,	$totalCar:1 },
				{  $fcLap:150000, $fcTotal:150000,	$lapCar:0,	$totalCar:1 },
				{  $fcLap:150000, $fcTotal:150000,	$lapCar:3,	$totalCar:2 },
				{  $fcLap:150000, $fcTotal:150000,	$lapCar:3,	$totalCar:0 },
				{  $fcLap:150000, $fcTotal:150000,	$lapCar:3,	$totalCar:3 }
			]
		}
		//*/
		/* HACK SNAKE3
		var fruits = new Array()
		for(var i=0; i<322;i++){
			if(random(i)<80){
				fruits.push( random(20)+1 )
			}else{
				fruits.push( undefined )
			}
		}
		
		frutiCard = {
			$fruits:fruits,	//322
			$record:456131
		}
		//*/
		/* HACK SWAPOU
		frutiCard = { 
			$chars : [
				true,
				true,
				true,
				true,
				true,
				false,
				false
			],
			$record: 1250,
			$classic_record: 15320,
			$swap: 157546,
			$duel: 152
		};
		//*/

		switch(gameName){

			case "bkiwi" :		//{ 	BKIWI
				//_global.debug("bkiwi card version("+frutiCard.$ver+")\n")
				
				var lines = new Array();
				var line;
				
				lines.push({height:10})
			
				// INFO
				var awardList = ["$wss", "$ws", "$wcs", "$wc"]
				var raceName = ["green hill","banana derby","terre grise","solstice","jupiter IV","mistral kiwi"]
				var teamName = ["ultra orange","uwe wing","fury hun","sonic brain","kiwix"]					
				
				// LISTE DE COUPES
				line = {height:86,list:[]}
				line.list.push({type:"spacer",big:2});
				for( var i=0; i<awardList.length; i++ ){
					var o = {
						type:"url",
						dy:4,
						param:{
							url:Path.bkiwi_cup,
							min:{w:30},
								
							param:{
								frame:i+1,
								available:frutiCard[awardList[i]]
							}
						}
					}
					line.list.push(o)
					line.list.push({type:"spacer",big:1});
				}
				lines.push(line)	

				// LISTE DE VOITURES
				lines.push(this.getTitleLine("voitures"))
				line = {height:32,list:[]}
				line.list.push( { type:"spacer", width:-16, big:1 } );
				for(var i=0; i<5; i++){
					_global.debug("voiture("+i+")  = "+frutiCard.$ac[i])
					var alpha = 20+frutiCard.$ac[i]*80
					var o = {
						type:"url",
						dy:4,
						param:{
							url:Path.bkiwi_team,
							param:{
								data:[ teamName[i] ]
							},
							_alpha:alpha
						}
					}
					line.list.push(o)
					line.list.push({type:"spacer",big:1});				
				}
				lines.push(line)
				//lines.push(this.getSepLine())

				// LISTE DES TEMPS :

				for(var i=0; i<6; i++){
					var info = frutiCard.$ts[i]
					
					
					if(isFinite(info.$fcLap)){
						lines.push(this.getTitleLine(raceName[i]))
						for(var l=0; l<2; l++){
							var text, rec, car;
							if(l==0){
								text = "meilleur tour :"
								rec = info.$fcLap;
								car = teamName[info.$lapCar]
								
							}else{
								text = "meilleur course :"
								rec = info.$fcTotal;
								car = teamName[info.$totalCar]
							}
							line = [
								{
									type:"spacer",
									big:1
								},
								{
									type:"url",
									param:{
										url:Path.bkiwi_team,
										min:{w:30},
										param:{
											data:[car]
										}
									}
								},
								{
									type:"text",
									width:120,
									param:{
										sid: 1,
										text: text
									}
								},
								{
									type:"text",
									width:80,
									param:{
										sid: 1,
										text: ext.util.MTNumber.getTimeStr(rec,"'","''"),
										textFormat:{
											align:"right"
										}
									}
								},
								{
									type:"spacer",
									big:1
								}
							]
							lines.push({list:line})
						}
					}
				}
				
				//END
				lines.push({height:20})
				lines.push(this.getSepLine())
				
				return lines //}
			case "snake3" :		//{ 	SNAKE3

				// INFOS
				var totalFruit = 322
				var arrayLength = 343
				var dFruit = 0;
				var tFruit = 0;
				var gFruit = 0;
				var id = 0;
				for(var i=0; i<arrayLength; i++){
					var fruit = frutiCard.$fruits[i];
					//_root.test+="fruit("+frutiCard.$fruit+")\n"
					if(fruit!=undefined){
						dFruit++;
						tFruit += fruit;
						if(i<=300)id = i;
					}
				}
				var pourcentage = (Math.round((dFruit/totalFruit)*1000)/10)+"%" 
				if( id <= 40 )  
					gFruit = id * 5;  
				else if( id <= 90 )  
					gFruit = 200 + (id - 40) * 10;  
				else if( id <= 150 )  
					gFruit = 700 + (id - 90) * 20;  
				else if( id <= 220 )  
					gFruit = 1900 + (id - 150) * 30;  
				else if( id <= 260 )  
					gFruit = 4000 + (id - 220) * 50;  
				else if( id <= 300 )  
					gFruit = 6000 + (id - 260) * 100;  
				else 
					gFruit = - (id - 320) * 250;

				var lines = new Array();
				var line,list;
				
				// BASE
				list = [
					{	
						type:"spacer",
						big:1
					},
					{
						type:"text",
						width:300,
						param:{
							sid: 2,
							text: this.box.frutizInfo.basic.nickname+" à ramassé "+tFruit+" fruits !" ,
							textFormat:{
								align:"center",
								color:0xE7756B
							}
						}
					},
					{	
						type:"spacer",
						big:1
					}				
				]
				lines.push({list:list})
				lines.push({height:10})
				
				// MEILLEUR SCORE
				_global.debug("[ Snake3 Card ] moi ma fruticard elle dit "+frutiCard.$record+"\n")
				lines = lines.concat( this.getRecordLines( "meileur score", frutiCard.$record+" points" ) )
				/*
				lines.push(this.getTitleLine("meileur score"))
				list = [
					{	
						type:"spacer",
						big:1
					},
					{
						type:"text",
						width:200,
						param:{
							sid: 1,
							text: frutiCard.$record+" points" ,
							textFormat:{
								align:"center"
							}
						}
					},
					{	
						type:"spacer",
						big:1
					}				
				];
				lines.push({list:list})				
				lines.push({height:10})
				*/
				
				// COLLECTION

				lines.push(this.getTitleLine("collection"))
				list = [
					{	
						type:"spacer",
						big:1
					},
					{
						type:"text",
						width:300,
						param:{
							sid: 1,
							text: dFruit+" sur "+totalFruit+" ont été découverts" ,
							textFormat:{
								align:"center"
							}
						}
					},
					{	
						type:"spacer",
						big:1
					}				
				];
				lines.push({list:list})

				list = [
					{	
						type:"spacer",
						big:1
					},
					{
						type:"text",
						width:300,
						param:{
							sid: 1,
							text: "( "+pourcentage+" )" ,
							textFormat:{
								align:"center"
							}
						}
					},
					{	
						type:"spacer",
						big:1
					}				
				];
				lines.push({list:list})				
				lines.push({height:10})
				
				// PLUS GROS FRUIT
				lines = lines.concat( this.getRecordLines( "le plus gros fruit", gFruit+" points" ) )
				/*
				lines.push(this.getTitleLine("plus gros fruit"))
				list = [
					{	
						type:"spacer",
						big:1
					},
					{
						type:"text",
						width:200,
						param:{
							sid: 1,
							text: gFruit+" points" ,
							textFormat:{
								align:"center"
							}
						}
					},
					{	
						type:"spacer",
						big:1
					}				
				];
				lines.push({list:list})	
				*/
				lines.push({big:1})
				return lines
				//}
			case "grapiz" :		//{ 	MULTI
			case "bandas" :

				var lines = new Array();
				// MULTI STATS
				lines = lines.concat( this.getMultiStatsLines( frutiCard ) )
				return lines //}
			case "swapou2" :	//{ 	SWAPOU2

				var lines = new Array();

				var bigLine = {height:240,list:[]}
				
					// LISTE DES PERSOS
					var page = {type:"page",lineList:[],width:190}
					var max = 7
					page.lineList.push(this.getTitleLine("personnages"))
					line = {height:168,list:[]}
					line.list.push( { type:"spacer", big:1 } );
					var dx = 0
					var dy = 80
					var r = 60;
					for(var i=0; i<max; i++){
						var a = 6.28*(i/max) -2
						var f = i;
						if(!frutiCard.$chars[i]) f += 10;
						var o = {
							type:"url",
							dx: dx + Math.cos(a)*r,
							dy: dy + Math.sin(a)*r,
							param:{
								url:Path.swapou_chars,
								param:{
									//rot:a/(Math.PI/180),
									frame:f
									
								}
							}
						}
						line.list.push(o)
						//line.list.push({type:"spacer",big:1});				
					}
					line.list.push( { type:"spacer", big:1 } );
					page.lineList.push(line)
					page.lineList.push(this.getSepLine())
				
				bigLine.list.push(page)
					
					var page = {type:"page",lineList:[],width:140}
					
					// SCORE NORMAL
					page.lineList = page.lineList.concat(this.getRecordLines("normal",frutiCard.$record+" points"))	
					// SCORE CLASSIC
					page.lineList = page.lineList.concat(this.getRecordLines("classic",frutiCard.$classic_record+" points"))	
					// SWAPS
					page.lineList = page.lineList.concat(this.getRecordLines("swaps",frutiCard.$swap+" swaps"));					
					// DUELS
					// page.lineList = page.lineList.concat(this.getRecordLines("duels",frutiCard.$duel+" victoires"));					

				bigLine.list.push(page)	
					
	
				lines.push(bigLine)
				
				return lines;
				//}
			case "mb2" :		//{	MB2
				//_global.debug("bkiwi card version("+frutiCard.$ver+")\n")
				var lines = new Array();
				var line;
				
				// LISTE DE COUPES
				line = {height:44,list:[]}
				line.list.push({type:"spacer",big:2});
				var list = frutiCard.$dungeons_done
				for( var i=0; i<5; i++ ){

					
					var frame  = i+10
					if( frutiCard.$dungeons_done[i] ) frame+=10;
					var o = {
						type:"url",
						dy:4,
						param:{
							url:Path.mb2_ball,
							min:{w:40},
							param:{
								scale:100,
								frame:frame
								
							}
						}
					}
					if(i==4){
						line.list.splice(5,0,o,{type:"spacer",big:1})
					}else{
						line.list.push(o)
						line.list.push({type:"spacer",big:1});
					}
					//_root.test += ">("+Path.mb2_ball+")\n"
				}
				lines.push(line)

				// LISTE DES TEMPS
				lines.push(this.getTitleLine("course"))
				
				var raceName = [ "jaune","vert","rouge","orange","bleu","métal","violet" ]
				
				//lines.push(this.getTitleLine(raceName[i]))
				
				
				for( var i=0; i<raceName.length; i++){
					var list = frutiCard.$records[i]
					
					for( var n=0; n<list.length; n++ ){
						var o = list[n]
						//_root.test+="youhu("+o.$c+")\n"
						if(!o.$c){
							//_root.test+="glum\n"
							line = [
								{
									type:"spacer",
									big:1
								},
								{
									type:"text",
									width:120,
									param:{
										sid: 1,
										text:raceName[i]
									}
								},								
								{
									type:"text",
									width:80,
									param:{
										sid: 1,
										text: ext.util.MTNumber.getTimeStr(o.$t*10,"'","''"),
										textFormat:{
											align:"center"
										}
									}
								},
								{
									type:"spacer",
									big:1
								}
							]
							lines.push({list:line})
							break;
						}						
					}				
					
				}
				
				// CLASSIC
				lines = lines.concat( this.getRecordLines( "classic", frutiCard.$classic_score+" niveaux" ) ) 
				
				//END
				lines.push({height:20})
				lines.push(this.getSepLine())
				
				return lines //}
			case "kaluga": 		//{	KALUGA
				var lines = new Array();				
				
				//
				// EPREUVES
				var info = {$level:[]}
				if( frutiCard.$classic.$s > 0 ){
					var o = {
						$s:frutiCard.$classic.$s,
						$t:frutiCard.$classic.$t,
						$name:"essai"
					}
					info.$level.push(o)
				}
				if( frutiCard.$trial.$tria.$s > 0 ){
					//_root.test+="info["+frutiCard.$trial.$tria.$s+"]\n"
					var o = {
						$s:frutiCard.$trial.$tria.$s,
						$t:frutiCard.$trial.$tria.$t,
						$name:"triathlon"
					}
					info.$level.push(o)
				}
				if( frutiCard.$trial.$hept.$s > 0 ){
					var o = {
						$s:frutiCard.$trial.$hept.$s,
						$t:frutiCard.$trial.$hept.$t,
						$name:"heptathlon"
					}
					info.$level.push(o)
				}
				lines = lines.concat( this.getKalugaModeLines("épreuve",info,"pts") )

				// OLYMPIQUE
				var name = [ "lancer de vers", "dexteripomme", "lancer d'ecureuil", "planter de vers", "lancer de fourmi", "plantapomme", "course de grenouille" ]
				var list = frutiCard.$trial.$list
				var info = {$level:[]}
				for( var i=0; i<list.length; i++ ){
					var o = list[i]
					
					// VERIFIE LE SCORE MAX
					var max = 0
					var tz = -1
					for( var t=0; t<o.$tz.length; t++ ){
						if(o.$tz[t].$s>max){
							max = o.$tz[t].$s
							tz = t
						}
					}
					
					
					//_root.test+="o.max"
					if( tz!=-1 ){
						info.$level.push({$s:max,$t:tz,$name:name[i]});
						
					}
					
				}
				lines = lines.concat(this.getKalugaModeLines("olympique",info,"cm"))
				
				
				// MODE
				var md = [ "$chrono", "$survival", "$invasion", "$ring" ]
				var name = [ "mode chrono", "mode survie", "mode invasion", "mode piste" ]
				var difName = ["facile","standard","difficile","infernal"]
				for(var i=0; i<md.length; i++ ){
					var info = frutiCard[md[i]]
					//_root.test+="info>"+info+"\n"
					if(i==0){
						var a = new Array();
						for(var n=0; n<info.$level.length; n++){
							if(frutiCard.$mode[2][n]){
								var list = info.$level[n]
								a.push( {$s:list[list.length-1], $t:10} )
							}
							//_root.test+="list[list.length-1]("+list[list.length-1]+")\n"
							//_root.test+="list("+list+")\n"
						}
						info.$level = a
						
					}
					for( var n=0; n<info.$level.length; n++){
						//_root.test+="difName[n]("+difName[n]+")\n"
						info.$level[n].$name = difName[n]
					}
					
					lines = lines.concat(this.getKalugaModeLines(name[i],info,"time"))
				}
				
				// PANIER
				//
				lines.push(this.getTitleLine("panier"))
				var p = frutiCard.$stat.$fruit
				//p = 1000 // HACK

				var line = [
					{
						type:"spacer",
						big:1
					},
					{
						type:"text",
						width:200,
						param:{
							sid: 1,
							text: p+" fruits !",
							textFormat:{
								align:"center"
							}
						}
					},					
					{
						type:"spacer",
						big:1
					}
				]
				lines.push({list:line})	


			
				var line = [
					{
						type:"spacer",
						big:1
					},
					{
						type:"url",
						dy:2,
						param:{
							url:Path.kaluga_panier,
							min:{w:160,h:130},
							param:{
								frame:Math.floor( Math.pow(p,0.3) )
							}
						}
					},				
					{
						type:"spacer",
						big:1
					}
				]
				lines.push({list:line})	
				
				
				//END
				//lines.push({height:10})
				lines.push(this.getSepLine())
				lines.push({height:20})
				//lines.push(this.getSepLine())
				
				return lines;
			
				break; //}
			case "miniwave": 	//{	MINIWAVE
				var lines = new Array();				
				
				
				
				//{ RANK
				var list = [
					{type:"spacer",big:1},
					{
						type:"url",
						dy:4,
						param:{
							url:Path.miniwave_rank,
							param:{
								frame:frutiCard.$lvl
							}
						}
					},					
					{type:"spacer",big:1}
				]
				lines.push({height:60,list:list}) //}					
				//{ VAISSEAUX
				lines.push(this.getTitleLine("vaisseaux"))
				line = {height:32,list:[]}
				line.list.push( { type:"spacer", width:-16, big:1 } );
				var list = frutiCard.$ship
				for(var i=0; i<list.length; i++){
					var alpha = 20+list[i]*80
					var o = {
						type:"url",
						dy:4,
						param:{
							url:Path.miniwave_ship,
							param:{
								frame:i,
								_alpha:alpha
							}
						}
					}
					line.list.push(o)
					line.list.push({type:"spacer",big:1});				
				}
				lines.push(line) //}				
				//{ ARCADE
				lines.push( this.getTitleLine("arcade") )
				lines.push( this.getSimpleScoreLine( "meilleur score :", frutiCard.$arcade.$bestScore ) )
				lines.push( this.getSimpleScoreLine( "niveau maximum atteint :", frutiCard.$arcade.$bestLevel ) )
				//}
				//{ BONUS
				lines.push( this.getTitleLine("bonus") )
				var list = frutiCard.$cons.$bonus
				var blank = true
				for( var i=0; i<list.length; i++ ){
					var score = list[i]
					if( score > 0 ){
						blank = false;
						lines.push( this.getSimpleScoreLine( "mission "+(i+1)+" :", score+" %" ) )
					}
				}
				if(blank)lines.pop(); //}
				//{ SPECIAL
				lines.push( this.getTitleLine("spécial") )
				var list = [
					{ link:"$letter", name:"mode lettre" },
					{ link:"$survival", name:"mode sentinelle" },
					{ link:"$time", name:"mode fuite" }
				]
				var blank = true
				for( var i=0; i<list.length; i++ ){
					var score = frutiCard[list[i].link]
					if( score > 0 ){
						blank = false;
						lines.push( this.getSimpleScoreLine(  list[i].name, score ) )
					}
				}
				if(blank)lines.pop();	//}			
				//{ TABLEAU DE CHASSE 
				lines.push(this.getTitleLine("tableau de chasse"))
				var nameList = [ 
					"Fraise-bouclier",
					"Orangeonaute",
					"Banana",
					"Clémentine mécanique",
					"Kamikaze",
					"Cerises-duo",
					"Fraise des bois",
					"Poire sous cloche",
					"Astro-Pamplemousse",
					"Cosmo-Prune",
					"Coing mutant",
					"Figue-laser",
					"Batmandarine",
					"Pomme d'épines",
					"Astro-Datte",
					"Pruneau magnétique",
					"Mûre chercheuse",
					"Citrus",
					"Astéropulpe",
					"Baies à tête chercheuse",
					"Aigrelle assassine",
					"Mangue-strike",
					"Tyson",
					"Cosmirabelle",
					"Astro-Quetsch",
					"Ananas sauvage",
					"Myrtillerie lourde",
					"Fraise-shuriken",
					"Aubergine folle",
					"Space-Groseille",
					"Pêche astronomique",
					"Abricot guerrier",
					"Nectarine trou-noir",
					"Pruneau passe-muraille",
					"Astro-raisin",
					"Betterave astrale",
					"Scarabé pulpé",
					"Space-Kumquat",
					"Poivri le poivron violent",
					"Kiwi interstellaire",	
					"Prune sidérale",
					"Prune paralysante",
					"Demon lemon",
					"Pêche jongleuse",
					"Courge céleste",
					"Bulbe spatial",
					"Cosmo-Cassis",
					"Pois casseur",
					"Brugnon cuirassé",
					"Nitro-pruneau",
					"Letter-monster"
				]
				var list = frutiCard.$badsKill
				for( var i=0; i< list.length-1; i++ ){
					n = list[i]
					if( n>0 ){
						var line = [
							{
								type:"spacer",
								big:1
							},
							{
								type:"url",
								dy:-2,
								param:{
									url:Path.miniwave_bads,
									min:{w:20},
									param:{
										frame:i
									}
								}
							},						
							{
								type:"text",
								width:160,
								param:{
									sid: 1,
									text: nameList[i]
								}
							},
							{
								type:"text",
								width:60,
								param:{
									sid: 1,
									text: n,
									textFormat:{
										align:"right"
									}
								}
							},
							{
								type:"spacer",
								big:1
							}
						]
						lines.push({list:line})					
						
					}
				}
				//}
				
				

				
				//
				lines.push({height:8})	
				lines.push(this.getSepLine())
				lines.push({height:20})			
				return lines; //}				
			case "minipixiz": 	//{	MINIWAVE
				var lines = new Array();

				// ETOILES ET DIAMANTS + titre
				var index = int(Math.min( Math.pow(frutiCard.$stat.$run, 0.16 ), 8))
				var tl = [
					"Apprenti",
					"Ami des fées",
					"Etudiant en esoterisme",
					"Chercheur en esoterisme",
					"Expert",
					"Collectionneur de fées",
					"Maitre des fées",
					"Seigneur des fées",
					"Souverain des fées"
				]
				lines.push(this.getTitleLine(tl[index]))
				
				var line = {height:30,list:[]}
				line.list.push( { type:"spacer", width:75 } )
				for( var i=0; i<5; i++ ){
					var o = {
						type:"url",
						param:{
							url:Path.minipixiz_award,
							param:{
								frame:i+1,
								shade:(i<frutiCard.$diam)?0:1
							}
						}
					}
					line.list.push(o)
					line.list.push( { type:"spacer", width:24 } )
				}
				line.list.push( { type:"spacer", width:18 } )
				var o = {
					type:"url",
					param:{
						url:Path.minipixiz_award,
						param:{
							num:frutiCard.$star,
							shade:(frutiCard.$star==0)?1:0
						}
					}
				}
				line.list.push(o)
				lines.push(line)
				
				// FEE
				if( frutiCard.$current != null ){
					var fs = frutiCard.$faerie[frutiCard.$current]
					//lines.push(this.getTitleLine("fée actuelle"))
					lines.push(this.getTitleLine(fs.$name+" ( niveau "+(fs.$level+1)+" )"))
					
				
					var bigLine = {height:120,list:[]}
					
						// LISTE DES PERSOS
						var page = {type:"page",lineList:[],width:114}
						//page.lineList.push(this.getTitleLine(fs.$name))
						line = {height:100,list:[]}
						line.list.push( { type:"spacer", width:14 } );
						var o = {
							type:"url",
							dy:4,
							param:{
								url:Path.minipixiz_faeries,
								
								param:{
									frame:1+fs.$skin[0],
									col1:fs.$skin[1],
									col2:fs.$skin[2],
									col3:fs.$skin[3]
								}
							}
						}
						line.list.push(o)
						page.lineList.push(line)
						//page.lineList.push(this.getSepLine())
					
					bigLine.list.push(page)
						
					bigLine.list.push({ type:"spacer", width:9 })
						
						var page2 = {type:"page",lineList:[],width:240}
						
						// CARACS
						var bLine = {height:62,list:[]}
							var pg0 = {type:"page",lineList:[],width:90}
	
							pg0.lineList.push(this.getWildScoreLine("force",fs.$carac[0]))
							pg0.lineList.push(this.getWildScoreLine("rapidité",fs.$carac[1]))	
							pg0.lineList.push(this.getWildScoreLine("vie",fs.$carac[2]))
							bLine.list.push(pg0)
							
							var pg1 = {type:"page",lineList:[],width:90}
							
							pg1.lineList.push(this.getWildScoreLine("intel",fs.$carac[3]))	
							pg1.lineList.push(this.getWildScoreLine("sagesse",fs.$carac[4]))	
							pg1.lineList.push(this.getWildScoreLine("mana",fs.$carac[5]))
							bLine.list.push(pg1)
						
						page2.lineList = page2.lineList.concat(bLine)
						
						// SPELL
						var ln = 0
						while(fs.$spell.length > 0 && ln < 3 ){
							ln++
							var line = { height:20,list:[] }
							line.list.push( { type:"spacer", width:6 } );
							for( var i=0; i<8; i++ ){
								if( fs.$spell.length == 0 )break;
								var sid = fs.$spell.pop();
								var o = {
									type:"url",
									param:{
										url:Path.minipixiz_spell,
										param:{
											frame:1+sid
										}
									}
								}
								line.list.push(o)
								line.list.push( { type:"spacer", width:21 } )				
							}
							//line.list.push( { type:"spacer", big:1 } )
							page2.lineList.push(line)	
						}
						
							
					bigLine.list.push(page2)

					lines.push(bigLine)
					lines.push({height:8})
						
				}
				
				
				// STATISTIQUES
				lines.push(this.getTitleLine("statistiques"))
				var st = frutiCard.$stat
				var a = new Array();
					// DUNGEON
				var dt = frutiCard.$dungeon.$lvl + frutiCard.$dungeon.$loop*5
					
					// ITEM
				var si = 0
				for( var i=0; i< st.$item.length; i++ ){
					if( st.$item[i]!=null )si++
				}
					// FOOD
				var fi = 0
				for( var i=0; i< st.$eat.length; i++ ){
					if( st.$eat[i]!=null )fi++
				}
				
				// CONSTRUCTION DE LA TABLE
				var a = [
					//[ "titre",			title				],
					[ "jours de jeu",		frutiCard.$time.$d		],
					[ "record forêt",		"niv. "+(st.$forestMax+1)	],
					[ "record arbre creux",		"niv. "+st.$treeMax		],
					[ "donjons terminés",		dt				],
					[ "objets différents",		si				],
					[ "plats différents",		fi				],
					[ "missions terminées",		st.$misNum			]
				

				]
					// PARTIES
				var nl = [ "forêts", "bassin", "donjon", "arc-en-ciel","arbre creux" ]
				for( var i=0; i< st.$game.length; i++ ){
					var n = st.$game[i]
					if(n > 0 ){
						a.push(["parties "+nl[i], n])
					}
				}

				for( var i=0; i<a.length; i++ ){
					lines.push(getSimpleScoreLine( a[i][0], a[i][1] ))
				}
				
				
				
				// CHASSE
				lines.push(this.getTitleLine("tableau de chasse"))
				var nl = [
					"diablotin",
					"demon mineur",
					"demon majeur",
					"ombre",
					"furie"
				]
				for( var i=0; i<5; i++ ){
					lines.push(getSimpleScoreLine( nl[i], st.$kill[i] ))
				}
				
				//
				lines.push({height:3})
				lines.push(this.getSepLine())
				
				//*
				// STAR
				var line = { height:100,list:[] }
				line.list.push({type:"spacer",width:12})
				var o = {
					type:"url",
					param:{
						url:Path.minipixiz_luz,
						param:{
							star:frutiCard.$star
						}
					}
				}
				line.list.push(o)
				lines.push(line)
				lines.push(this.getSepLine())
				lines.push({height:10})
				//*/
				
				return lines; //}
			default :
				_global.debug("type de card inconnu ("+gameName+")\n")

		}	
	
		
	}	
	
	function getSimpleScoreLine( name, score ){
		var line = [
			{
				type:"spacer",
				big:1
			},
			{
				type:"text",
				width:160,
				param:{
					sid: 1,
					text: name
				}
			},
			{
				type:"text",
				width:60,
				param:{
					sid: 1,
					text: score,
					textFormat:{
						align:"right"
					}
				}
			},
			{
				type:"spacer",
				big:1
			}
		]
		return {list:line}				
		
	}
	
	function getWildScoreLine( name, score ){
		var line = [
			{
				type:"text",
				width:58,
				param:{
					sid: 1,
					text: name
				}
			},
			{
				type:"text",
				width:20,
				param:{
					sid: 1,
					text: score,
					textFormat:{
						align:"right"
					}
				}
			}
		]
		return {list:line}				
		
	}	
	
	function getKalugaModeLines(name, info, displayMode){
		var lines = new Array();
		//if( difName == undefined ) difName = ["facile","standard","difficile","infernal"];
		lines.push( this.getTitleLine(name) )
		for( var i=0; i<info.$level.length; i++){
			var score = info.$level[i].$s
			var dScore
			switch(displayMode){
				case "cm":
					dScore = score+" cm"
					break;
				case "time" :
					dScore = ext.util.MTNumber.getTimeStr(score,"'","''")
					break;
				case "pts" :
					dScore = score+" pts"
					break;				
			}
			if(score != 0 && score != 600000){
				var line = [
					{
						type:"spacer",
						big:1
					},
					{
						type:"url",
						dy:2,
						param:{
							url:Path.kaluga_tz,
							min:{w:20},
							param:{
								frame:info.$level[i].$t+1
							}
						}
					},						
					{
						type:"text",
						width:120,
						param:{
							sid: 1,
							text: info.$level[i].$name//difName[i]
						}
					},
					{
						type:"text",
						width:80,
						param:{
							sid: 1,
							text: dScore,
							textFormat:{
								align:"right"
							}
						}
					},
					{
						type:"spacer",
						big:1
					}
				]
				lines.push({list:line})
			}
		}
		if(lines.length==1)lines = [];
		return lines;
	};
	
	function getRecordLines( title, record ){
		var lines = new Array();
		lines.push(this.getTitleLine(title))
		var list = [
			{	
				type:"spacer",
				big:1
			},
			{
				type:"text",
				width:200,
				param:{
					sid: 1,
					text: record  ,
					textFormat:{
						align:"center"
					}
				}
			},
			{	
				type:"spacer",
				big:1
			}
		];
					
		lines.push({list:list})				
		lines.push({height:10})
		return lines;
		
	}
	
	function getMultiStatsLines( frutiCard ){
		
		var lines = new Array();
		
		var roomList = [
			{ n:"match amicaux",	v:"$f" },
			{ n:"challenge",	v:"$c" },
			{ n:"championnat",	v:"$l" }
		]
		
		var statList = [
			"victoires",
			"défaites",
			"égalités"
		]
		
		var rankingList = [
			"score actuel",
			"score minimum",
			"score maximum"
		]
			
			
		for( var i=0; i<roomList.length; i++ ){
			var s = roomList[i]
			var name = roomList[i].n; 
			lines.push(this.getTitleLine(name))
			
			if( name == "championnat" ){
				for( var ii=0; ii<rankingList.length; ii++ ){
					var list = [
						{
							type:"spacer",
							big:1
						},
						{
							type:"text",
							width:120,
							param:{
								sid: 1,
								text:rankingList[ii]
							}
						},
						{
							type:"text",
							width:80,
							param:{
								sid: 1,
								text: frutiCard.$ls[ii],
								textFormat:{
									align:"right"
								}
							}
						},
						{
							type:"spacer",
							big:1
						}					
					]
					lines.push({list:list})
				}				
				lines.push({height:6})
			}	
			
			for( var ii=0; ii<statList.length; ii++ ){
				var list = [
					{
						type:"spacer",
						big:1
					},
					{
						type:"text",
						width:120,
						param:{
							sid: 1,
							text:statList[ii]
						}
					},
					{
						type:"text",
						width:80,
						param:{
							sid: 1,
							text: frutiCard[roomList[i].v][ii],
							textFormat:{
								align:"right"
							}
						}
					},
					{
						type:"spacer",
						big:1
					}					
				]
				lines.push({list:list})	
			}
		}
		
		return lines
	
	}
	
	
	//
	
	function loadInfo(cat){
		_global.debug("win.Frutiz::loadInfo("+cat+")");
		//_root.test+="loadInfo("+cat+")\n"

		var r = this.box.frutizInfo.weWant(cat,{obj:this,method:"onInfo",args:cat});
		// r == true si l'info été déjà prête, false si le chargement a débuté
		if(cat!="basic" && !r){
			this.explorer.displayWait();
			this.explorer.setPageObj();
		}
	}
	
	function onInfo(cat){
		
		//_root.test+="onInfo("+cat+")\n"
		
		var info = this.box.frutizInfo[cat];
		
		if(cat!="basic"){
			
			if(this.explorer.flWait)this.explorer.removeWait();
			this.displayPage( this.getPageObj(cat) );
			//_root.test+="+("+pageObj+")\n"
			/*
			_root.test="this.explorer.pageObj:"
			for(var elem in this.explorer.pageObj){
				_root.test+="-"+elem+" = "+this.explorer.pageObj[elem]+"\n"
			}
			*/
		}else{
			this.upInfo.setInfo(info);
			//_global.debug("Je balance au screen: {fbouille: "+info.fbouille+", status: "+info.status+"}");
			this.screen.onStatusObj({fbouille:info.fbouille,status: info.status,presence: info.presence})
			var initObj = {_x:this.base-2}
			this.barLevel = this.screen.addSupContent("barLevel",initObj)
			this.barLevel.setLevel(this.box.frutizInfo.basic.xpLevel,this.box.frutizInfo.basic.xpCompletionRate)
			//this.barLevel.setLevel(4,0.72)			
		}
				
	}

	function onFrutiCard(frutiCard,gameName){
		//_root.test+="onFrutiCard gameName("+gameName+") frutiCard("+frutiCard+")\n"
		// BASE
		var pageObj = {
			pos:{x:0,y:0,w:250,h:240},
			lineList:[]
		}
		// MENU
		pageObj.lineList = pageObj.lineList.concat(this.getMenuLine("queDalle"))
		pageObj.lineList = pageObj.lineList.concat(this.getFrutiCardLines(frutiCard,gameName))
		this.displayPage(pageObj);
	}
	
	function loadFrutiCard(gameName){
		_root.test+="loadFrutiCard("+gameName+")\n"
		this.box.frutizInfo.getFrutiCard( gameName, {obj:this, method:"onFrutiCard"} )

	}
	
	function displayPage(pageObj){
		this.explorer.setPageObj(pageObj);
		this.update();
		this.update();	// comme ça c'est deux fois plus rigolo	
	}
	
	
	function scrollText(delta){
		this.explorer.mask.y.path.pixelScroll(delta);
	}
	
	
//{
}


















