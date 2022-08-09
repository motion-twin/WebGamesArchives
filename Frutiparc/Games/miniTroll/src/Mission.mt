class Mission extends Slot{//}

	var dialList:Array<{time:float,txt:String}>
	var dialType:int;
	var step:int;
	var index:int;
	var seed:int;
	var timer:float;
	
	var faerie:Array<FaerieSeed>
	var flagList:Array<bool>
	
	var s0:MovieClip;
	var s1:MovieClip;
	var slot:MovieClip;
	
	var butAccept:Button;
	//var nameList:Array<{s:String,r:String}>
	
	var fieldTitle:TextField;
	var fieldDesc:TextField;
	var fieldInfo:TextField;
	
	var fieldPrc:TextField;
	
	var winString:String;
	var looseString:String;
	
	
	function new(){
		dpCursorFront = 6
		dpCursorBack = 4
		dialType = 0
		dialList = new Array();
		super();
	}
	
	function init(){
		super.init();
		
		dialType = 1
		step = 1
		gotoAndStop("1")
		if( Cm.card.$mission == null || Cm.getNightCoef()<0.2 ){
			dialList = [
				{ time:40,	txt:"Toc, toc..." }
				{ time:120,	txt:"..." }
				{ time:60,	txt:"Toc, toc, toc..." }
				{ time:80,	txt:"Apparament, il n'y a personne..." }
			]
		}else{
			
			dialList.push({ time:40,	txt:"Toc, toc..." })
			
			if( Std.random(2)==0)	dialList.push({ time:120,	txt:"..." })
			if( Std.random(6)==0)	dialList.push({ time:60,	txt:"Toc, toc, toc..." })
			if( Std.random(10)==0)	dialList.push({ time:80,	txt:"..." })
			
			dialList.push({ time:20+Math.random()*40,	txt:"openDoor" })
			dialList.push({ time:20,	txt:Lang.getSent(Lang.GROMELIN_OPEN) })
			
			if(Cm.card.$help[Cs.HELP_GROMELIN]==null){
				Cm.callHelp(Cs.HELP_GROMELIN)
				dialList.push({ time:30,	txt:"Que fais-tu là petit homme ?" });
				if( Cm.card.$faerie.length > 0 ){
					dialList.push({ time:50,	txt:"Ho mais c'est une fée que tu à la ?" });
					dialList.push({ time:20,	txt:"J'ai peut etre du travail pour tes fées..." });
				}else{
					dialList.push({ time:20,	txt:"C'est pas ici que tu trouveras une fée, tu ferai mieux d'aller voir du coté du bassin..." });
				}
				dialList.push({ time:10,	txt:"Si tu veux gagner de chouettes objets sans te fatiguer, envoie moi tes fées..." });
				dialList.push({ time:10,	txt:"...Je peux leur trouver du travail je connais bien ce pays." });
				dialList.push({ time:20,	txt:"Reviens me voir avec tes fées !" });
				dialList.push({ time:50,	txt:"Attention ! Je ne m'occupe que des fées correctement conditionnées... Pas de fées sans bocal!" });
				dialList.push({ time:20,	txt:"closeDoor" });
			}else{
				if( Cm.card.$faerie.length > 0 ){
					faerie = new Array();
					for( var i=0; i<Cm.card.$faerie.length; i++ ){
						var fs = Cm.card.$faerie[i]
						if( fs.$mission == null && fs.$pos != null ){
							faerie.push(fs)
						}
					}
					if( faerie.length > 0 ){
						dialList.push({ time:20,	txt:"Voyons voir..." });
						var str = "Mmmmhhh... J'ai peut etre du boulot pour "
						for( var i=0; i<faerie.length; i++ ){
							str += faerie[i].$name
							if( i+1 == faerie.length ) str +=". ";
							if( i+2 == faerie.length ) str +=" et ";
							if( i+2 < faerie.length ) str +=",  ";							
						}
						dialList.push({ time:20,	txt:str });
						dialList.push({ time:10,	txt:"Rentre donc a l'interieur..." });
						dialList.push({ time:10,	txt:"gotoMission" });
						
						
					}else{
						dialList.push({ time:10,	txt:"Grumph.... Tu m'as dérangé pour rien..." });
						dialList.push({ time:10,	txt:"Tu n'as pas de fées pretes a recevoir une mission..." });
						dialList.push({ time:10,	txt:"N'oublies pas que je ne m'occupe que des fées qui sont dans un bocal !" });
						dialList.push({ time:20,	txt:"closeDoor" });
					}
					
					
				}else{
					dialList.push({ time:30,	txt:"Grrr... Reviens me voir quand tu aura des fées petit homme..." });
					dialList.push({ time:60,	txt:"closeDoor" });
				}				
			}

			
		}
		
	}

	function maskInit(){
		super.maskInit()
		initButQuit();
		
		//var d = speak("Bonjour, je suis Gromelin.")
		//speak("Tu vas bien?")
	}
	
	function update(){
		super.update();
		
		switch(step){
			

			case 1:
				/*
				if(Key.isDown(Key.SPACE)){
					initMissionPanel();
				}
				*/
				playDial();
				break;
			case 2:
				break;
			/*
			case 10:
				playDial();
				if( dial == null && dialList.length == 0 ){
					step = 11
					timer = 20
				}
				break;
			*/
			case 11:
				timer -= Timer.tmod;
				if(timer<0){
					Manager.fadeSlot("menu",Cs.mcw*0.5,Cs.mch*0.5)
					step = 99
				}
				break;
			
		}
		
	}
	
	function playDial(){
		if(dialList.length > 0 ){
			var d = dialList[0];
			if(d.time>0){
				if( dial == null ){
					d.time -= Timer.tmod;
				}
			}else{
				switch(d.txt){
					case "openDoor":
						dialType = 0
						gotoAndStop("2")
						break;
					case "closeDoor":
						gotoAndStop("1")
						step = 11
						timer = 16
						break;
					case "gotoMission":
						initMissionPanel();
						break;
					default:
						speak(d.txt);
						break;
				}
				
				dialList.shift();
			}
		}
	}
	
	function attachDialog(d){
		
		switch(dialType){
			case 0:
				d.x = 60
				d.y = 76
				super.attachDialog(d);
				//d.skin.pointe._yscale = -100
				//var h = d.skin.pan._height
				//d.skin.pointe._y = h
				//d.skin._y -= h
				break;
			case 1:
				super.attachDialog(d);
				d.skin.pointe._visible = false;
				break;
		}

	}	
	
	// MISSION
	function initMissionPanel(){
		gotoAndStop("3")
		step = 2
		index = 0
		displayMission()
		// BUTTONS
		var me = this
		s0.onPress = fun(){
			me.incIndex(-1)
		}
		s1.onPress = fun(){
			me.incIndex(1)
		}
		
		butAccept.onPress = fun(){
			me.initValidatePanel();
		}
		
	}
	
	function displayMission(){
		var info = Cm.card.$mission[index]
		var mis = Lang.MISSION[info[1]]
		seed = info[4]
		var nameList = getNameList()
		
		var desc = getMissionText( mis.desc[1], nameList )
		desc = Std.cast(Tools.replace)(desc,"$day",info[2]+" jours")
		desc = Std.cast(Tools.replace)(desc,"$dif",Lang.MISSION_DIF[info[0]])
		
		winString = getMissionText( mis.desc[2], nameList )
		looseString = getMissionText( mis.desc[3], nameList )		// HERE
		
		fieldTitle.text = getMissionText( mis.desc[0], nameList )
		fieldDesc.text = desc
		fieldDesc._y = 96 -(fieldDesc.textHeight*0.9)*0.5
		fieldInfo.text = "type: "+mis.type+"\ndifficulté: "+Lang.MISSION_DIF_RANK[info[0]]+"\ndurée: "+info[2]+" jours"
		
		var it = Item.newIt(info[3])
		var mc = it.getPic(new DepthManager(slot),1)
		mc._xscale = mc._yscale = 50
		
	}
	

	function incIndex(inc){
		index = int(Cs.mm(0,index+inc,Cm.card.$mission.length-1))
		displayMission();
	}
	
	function getMissionText(str,list){
		for( var i=0; i<list.length; i++ ){
			var info = list[i]
			str = Std.cast(Tools.replace)(str,info.s,info.r)
		}
		
		var faerieName = Cm.genFaerieName()
		str = Std.cast(Tools.replace)(str,"$faerieName",faerieName)
		
		return str
		
	}
	
	function getNameList(){

		var list = new Array();
		var bl = [
			{n:"$thief",		l:Lang.WORD_THIEF		},	
			{n:"$kingdom",		l:Lang.WORD_KINGDOM		},	
			{n:"$history",		l:Lang.WORD_HISTORY		},
			{n:"$funGame",		l:Lang.WORD_FUN_GAME		},
			{n:"$longTime",		l:Lang.WORD_LONG_TIME		},	
			{n:"$victims",		l:Lang.WORD_VICTIMS		},
			{n:"$2fromLocation",	l:Lang.WORD_FROM_LOCATION	},
			{n:"$fromLocation",	l:Lang.WORD_FROM_LOCATION	},
			{n:"$2atLocation",	l:Lang.WORD_AT_LOCATION		},
			{n:"$atLocation",	l:Lang.WORD_AT_LOCATION		},
			{n:"$badName",		l:Lang.WORD_BAD_NAME		},
			{n:"$actionPastFun",	l:Lang.WORD_ACTION_PAST_FUN	},
			{n:"$lostObject",	l:Lang.WORD_LOST_OBJECT		},
			{n:"$period",		l:Lang.WORD_PERIOD		},
			{n:"$super",		l:Lang.WORD_SUPER		},
			{n:"$fromInvader",	l:Lang.WORD_FROM_INVADER	}
			
		]		
		for( var i=0; i<bl.length; i++ ){
			var info = bl[i]
			var str = getSeedSent(info.l)
			list.push({s:info.n,r:str})
			
							
		}
		list.push({s:"$2faerieName",r:getSeedFaerieName()})
		list.push({s:"$faerieName",r:getSeedFaerieName()})
		
		

		return list;
	
	}
	
	function getSeedSent(list){
		var str = list[seed%list.length]
		seed = int(Math.pow(seed,2)%(10000+str.length))	
		return str
		
	}
	
	function getSeedFaerieName(){
		var p0 = Lang.nameSyl0[seed%Lang.nameSyl0.length].substring(1)
		var p1 = Lang.nameSyl1[seed%Lang.nameSyl1.length].substring(1)
		var str = p0+p1
		seed = int(Math.pow(seed,2)%(10000+str.length))	
		return str
	}
	
	// VALIDATE
	function initValidatePanel(){
		
		flagList = new Array();
		gotoAndStop("4")
		fieldPrc.text="0%"
		for( var i=0; i<faerie.length; i++ ){
			var mc = downcast( dm.attach("mcMissionFaerieSlot",5) )
			mc._x = 40
			mc._y = 54+i*16
			mc.fieldName.text = faerie[i].$name
			mc.stop();
			mc.id = i
			mc.box.onPress = callback(this,toggle,mc)
			flagList[i] = false;
		}
		butAccept.onPress = callback(this,validate)
	}
	
	
	function toggle(mc){
		flagList[mc.id] = !flagList[mc.id]		
		mc.gotoAndStop(flagList[mc.id]?"2":"1")
		fieldPrc.text = Math.floor(getCoef()*100)+"%"
	}

	function getCoef(){

		var info = Cm.card.$mission[index]
		var mis = Lang.MISSION[info[1]]
		
		var resultList = new Array();
		for( var i=0; i<flagList.length; i++ ){
			if(flagList[i]){
				
				var list = mis.test
				var m = 0
				for( var n=0; n<list.length; n++ ){
					var fi  = Cm.getFaerie(faerie[i])
					m += fi.carac[list[n]]
				}
				
				m /= list.length
				
				resultList.push(m)
				
			}
		}
		var result = 0
		for( var i=0; i<resultList.length; i++ ){
			result += resultList[i]
		}
		result /= 1+(resultList.length-1)*0.3
		
		var coef = Math.min( result/(2+info[0]*2),  1 )

		return coef		
	}
	
	function validate(){
		var list = new Array()
		for( var i=0; i<flagList.length; i++ ){
			if(flagList[i])list.push(faerie[i]);
		}
		var str = ""
		var flVictory = null
		if( Math.random() < getCoef() ){
			flVictory = true;
			str = winString
		}else{
			flVictory = false;
			str = looseString
		}
		
		Cm.addMission( index, list, flVictory, str )
		quit();
	}
	
	function quit(){
		super.quit()
		butAccept.onPress = null
	}
	
	
	
	/*
	
	
	$mission:[
			[ 12, 0,137 ]				// DIF - TYPE - DUREE -  ITEM

		]
	
	
	
	*/
	
	
	
	
	
	
//{	
}