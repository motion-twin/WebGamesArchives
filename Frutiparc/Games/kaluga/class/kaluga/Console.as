class kaluga.Console extends MovieClip{//}

	// CONSTANTES
	var graphStep:Number = 100
	var graphMax:Number = 8
	var statMax:Number = 5



	// VARIABLES
	var pNum:Number;
	var index:Number;
	var tzList:Array;



	// REFERENCE
	var current:MovieClip;
	var menu:kaluga.Menu
	// MOVIECLIP
	var but:Button;
	var pic:MovieClip;
	var graphic:MovieClip;


	function Console(){
		this.init();
	}

	function init(){
		this.index = -1;
		this.pNum = 0;
		this.genTzList();
		this.initBut();
		//this.attachTzongre(index)

		this.initBar();
		this.nextTzongre();

	}

	function update(){
		//_root.test+="o"
		this.drawBar();
	}

	function genTzList(){
		this.tzList = new Array();
		var list = this.menu.mng.card.$tz;
		for( var i=0; i<list.length; i++ ){
			if( list[i] )this.tzList.push(i);
		}
		//_root.test+="tzList("+this.tzList+")\n"
		/*
		this.tzList = [
			{ id:0,	name:"Kaluga",	weight:0.3,	nbPower:2,	nbBoost:1,	nbBoostFrict:0.98,	nbResist:0.90,	nbThrust:0.9, 	nbTurn:2.4,	nbTurnMalus:0.8,	nbPower:0.04,	nbDodge:1.8,	nbMulti:0,	nbCombo:0,	nbFilMax:200,	cligneRand:200,	stats:[3,4,4,3,3]		},
			{ id:1, name:"Piwali",	weight:0.4,	nbPower:2,	nbBoost:3,	nbBoostFrict:0.99,	nbResist:0.99,	nbThrust:0.9, 	nbTurn:1.8,	nbTurnMalus:0.8,	nbPower:0.12,	nbDodge:1.4,	nbMulti:0,	nbCombo:0,	nbFilMax:110,	cligneRand:40, 	stats:[1,2,3,4,1]		},
			{ id:2, name:"Nalika",	weight:0.2,	nbPower:0.5,	nbBoost:1.5,	nbBoostFrict:0.96,	nbResist:0.75,	nbThrust:0.9, 	nbTurn:3.2,	nbTurnMalus:0.2,	nbPower:0.02,	nbDodge:1.0,	nbMulti:0,	nbCombo:0,	nbFilMax:300,	cligneRand:200, stats:[6,5,1,1,6]		},
			{ id:3, name:"Gomola",	weight:0.6,	nbPower:5,	nbBoost:4,	nbBoostFrict:0.75,	nbResist:0.90,	nbThrust:0.9, 	nbTurn:1.4,	nbTurnMalus:0.4,	nbPower:0.06,	nbDodge:2.8,	nbMulti:0,	nbCombo:1,	nbFilMax:150,	cligneRand:200,	stats:[3,1,5,6,2]		},
			{ id:4, name:"Makulo",	weight:0.25,	nbPower:1.5,	nbBoost:7,	nbBoostFrict:0.985,	nbResist:0.95,	nbThrust:0.9, 	nbTurn:3.8,	nbTurnMalus:0.4,	nbPower:0.06,	nbDodge:3.4,	nbMulti:0,	nbCombo:0,	nbFilMax:220,	cligneRand:100,	stats:[2,6,6,2,4]		}
		]
		*/
	}

	function initBut(){
		var d  = 80
		this.attachMovie("transp","but",200)
		this.but.onPress = function(){
			if(this._parent.tzList.length>0)this._parent.nextTzongre();
		}
		this.but._x = d;
		this.but._xscale = kaluga.Cs.mcw - (this._x+d);
		this.but._yscale = kaluga.Cs.mch;
	}

	function nextTzongre(){
		this.menu.mng.sfx.play("sWind");
		this.current.flGoAway = true;
		this.current.shadow.flGoAway = true;
		this.index = (this.index+1)%tzList.length;
		var id = this.tzList[this.index]
		var info = this.menu.mng.tzInfo[id]
		this.attachTzongre(id);
		this.drawGraphic(info)
		var stats = info.stats
		for( var i=0; i<this.statMax; i++ ){
			var bonus = 0.5
			//_root.test+="stats[i]("+((stats[i]+bonus)/(6+bonus))*120+")\n"
			this["bar"+i].h = ((stats[i]+bonus)/(6+bonus))*120
		}
	}

	function attachTzongre(index){
		var d = this.pNum++
		this.pic.attachMovie( "portrait"+index, "portrait"+d, 10000-d )
		var mc = this.pic["portrait"+d]
		mc.flGoAway = false;
		mc.gotoAndPlay(2)
		this.current = mc;

		this.gotoAndStop(this.tzList[this.index]+1)
		//SHADOW
		var d = this.pNum++
		this.pic.attachMovie( "portrait"+index, "portrait"+d, 10000-d )
		mc.shadow = this.pic["portrait"+d]
		mc.shadow._alpha = 40;

	}

	function drawGraphic(info){
		var step =	160 / this.graphStep;
		var ratio =	120 / this.graphMax;
		this.graphic.line.clear();
		this.graphic.line.lineStyle(1,0xBAD595)

		for ( var i=0; i<Math.round(this.graphStep/10); i++ ){
			this.graphic.line.lineStyle(1,0xBAD595,0)
			this.graphic.line.lineTo( 10*step*i, -120	)
			this.graphic.line.lineStyle(1,0xBAD595,100)
			this.graphic.line.lineTo( 10*step*i, 0		)
		}

		this.graphic.line.lineStyle(1,0xBAD595)
		this.graphic.line.beginFill(0xF5F8F0)
		this.graphic.line.moveTo( 0, -info.nbPower*ratio )
		//_root.test+="this.lineTo("+(step*i)+","+(power*ratio)+")\n"
		for ( var i=0; i<=this.graphStep; i++ ){
			var power = 0.5+info.nbPower + info.nbBoost*(1-Math.pow(info.nbBoostFrict,i*2)) - (info.weight*3.5)
			this.graphic.line.lineTo( step*i, -power*ratio)
			//_root.test+="this.lineTo("+(step*i)+","+(power*ratio)+")\n"
		}
		this.graphic.line.lineTo(160,0);
		this.graphic.line.lineTo(0,0);
		this.graphic.line.endFill();

	}

	function initBar(){
		var s = 10
		var w = (180-(10*(this.statMax-1)))/this.statMax
		for( var i=0; i<this.statMax; i++ ){
			this.attachMovie("statBar","bar"+i,110+i);
			var mc = this["bar"+i]
			mc._xscale = w
			mc._yscale = 10
			mc._x = 260+i*(w+s)
			mc._y = 470
			this.attachMovie("iconBar","icon"+i,120+i);
			var ico = this["icon"+i]
			ico._x = mc._x;
			ico._y = mc._y;
			ico._xscale = ico._yscale = w
			ico.gotoAndStop(i+1)
			//_root.test+="mc("+mc+")\n"
		}
	};

	function drawBar(){
		for( var i=0; i<this.statMax; i++ ){
			//_root.test=mc.h
			var mc = this["bar"+i]
			mc._yscale = mc._yscale*0.9 + mc.h*0.1
		}
	}


//{
}





























