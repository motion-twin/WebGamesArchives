class kaluga.sp.phys.Panier extends kaluga.sp.Phys{//}
	
	// CONSTANTES
	var dp_fruit:Number = 400;
	var dp_score:Number = 300;
	//
	var ray:Number = 90;
	var openLevel:Number = 53;
	var openRay:Number = 42;
	var cBoundGround:Number = 0.6;
	var cBoundSide:Number = 0.5;
	var glurpSpeed:Number = 0.1;	//0.01
	var grapName:Array;
	
	
	// VARIABLES
	var animList:kaluga.AnimList;
	var flScore:Boolean;
	var fNum:Number;
	var sNum:Number;
	var grappe:Number;
	var fruitList:Array;
	
	//REFENCES
	var lastScore:MovieClip;
	
	//
	var panier:MovieClip;
	
	function Panier(){
		this.init();
	}
	
	function init(){
		//_root.test+="[Panier] init\n"
		this.fruitList = new Array();
		this.flScore=false;
		this.animList = new kaluga.AnimList();
		super.init();
		this.initGrapName();
		this.fNum = 0;
		this.sNum = 0;
		this.grappe = 0;
		
	}
	
	function initDefault(){
		if(this.weight == undefined) this.weight = 10;
		super.initDefault();
	}
	
	function initGrapName(){
		this.grapName = [
			"Zero-grappe ",
			"Mono-grappe ",
			"Mini-grappe ",
			"Grappe ",
			"Grosse-grappe ",
			"Enorme-grappe ",
			"Super-grappe ",
			"Mega-grappe ",
			"Atomique-grappe ",
			"Hypopo-grappe ",
			"Divine-grappe ",
			"Maestro-grappe "
		]
	}
	
	function update(){
		super.update();
		// FRICTION
		if(this.flGround){
			this.vitx *= Math.pow(0.75,kaluga.Cs.tmod);;		
		}
		// SOL
		var gy = this.map.height - this.map.groundLevel;
		if(this.y+this.ray> gy){
			this.y = gy-this.ray
			if(this.vity>6){
				this.vity *= -this.cBoundGround
			}else{
				if(this.parentLink == undefined){
					this.vity = 0;
					this.flGround = true;
				}
			}
		}
		// BORDS
		var limitLeft = 0;
		var limitRight = this.map.width;

		if( this.x + this.openRay > limitRight ){
			this.x = limitRight - (this.openRay)
			this.vitx *= -this.cBoundSide

		}		
		if( this.x - this.openRay < limitLeft ){
			this.x = limitLeft + this.openRay
			this.vitx *= -this.cBoundSide
		}
		// FRUIT
		for(var i=0; i<this.fruitList.length; i++){
			this.fruitList[i].update();
		}		

		// SCORELIST
		/*
		for(var i=0; i<this.scoreList.length; i++){
			var mc = this.scoreList[i];
		}
		*/
		
		
		this.endUpdate();		
	}
	
	function endUpdate(){
		super.endUpdate();
		this._x += this.vitx*kaluga.Cs.tmod
		this._rotation = this.vitx/2 *kaluga.Cs.tmod
	}
	
	function addFruit(fruit){
		// _root.test+="addFruit\n"
		// this.game.onAddFruit(fruit);
		this.game.onAddFruit();
		if( this.game.endingGame ) return;
		
		if( this.game.type == "$classic" ){
			// POINTS
			if(fruit.flScoreAble && fruit.antList.length==0){
				var point = Math.round((fruit.weight-fruit.crunch)*100)*(fruit.flGold?10:1)
				if( point>0 ){
					this.addScore(point)
					var bonus = this.checkCombo(fruit)
					if(bonus>0){
						point += bonus
					}
					this.game.mng.sfx.play("sBonus")
				}
				this.game.score += point
			}else{
				this.game.scroller.put("beurk!","-500");
				this.game.score -= 500
			}
			this.game.updateScore();
		}else{
			this.game.mng.sfx.play("sBonus")
		}
		
		//
		this.game.mng.card.$stat.$fruit += 1;
	
		// GFX
		this.fNum++;
		this.attachMovie("spPhysFruit","fruit"+this.fNum,this.dp_fruit+this.fNum,fruit);
		var mc = this["fruit"+this.fNum]
		mc.flPanier = true;
		mc.panier = this;
		//
		mc.x = fruit.x - this.x
		mc.y = fruit.y - this.y
		mc._x = mc.x
		mc._y = mc.y
		mc.pomme._rotation = fruit.pomme._rotation
		mc.updateAspect();
		delete mc.depth;
		fruit.kill();
		this.fruitList.push(mc);

		//
		this.fNum++;
		this.attachMovie("maskPanier", "mask"+this.fNum, this.dp_fruit+this.fNum)
		var mask = this["mask"+this.fNum]
		mc.setMask(mask);
		mc.mask = mask;
	}
	
	function removeFruit(fruit){
		for(var i=0; i<this.fruitList.length; i++){
			if( this.fruitList[i] == fruit){
				this.fruitList.splice(i,1)
			}
		}
	}
	
	function addScore(score){
		
		//
		this.sNum = (this.sNum+1)%40;
		this.attachMovie("numb","score"+sNum,this.dp_score+sNum,{num:score,scale:80});
		var mc = this["score"+sNum];
		var h = -20;
		if( this.lastScore._visible ){
			h += (this.lastScore.pos.y+20)-(this.lastScore._height+4);
		};
		mc.regular =	{ x:0, y:-10 };
		mc.pos = 	{ x:0, y:h };
		this.animList.addSlide("anim"+sNum,mc,{obj:this,method:"endAnimScore",args:mc});
		this.lastScore = mc;
		this.grappe++;
	}
	
	function endAnimScore(mc){
		mc.animId = setInterval(this,"removeScore",1000,mc)
		//_root.test+="removeMe()\n"
	}
	
	function removeScore(mc){
		//_root.test+="removeScore("+this.grappe+")\n"
		clearInterval(mc.animId);
		mc.animId = setInterval(this,"turnOutScore",40,mc)
		mc.rot = 0.1
		if(this.grappe>1){
			var bonus = Math.pow(2,Math.min(this.grappe,11))*10
			this.game.scroller.put(this.grapName[this.grappe],"+"+bonus)
			this.game.score += bonus
			this.game.stat.bestVal("Grappe maximum",this.grappe)
			this.game.updateScore();
		}
		this.grappe = 0;
	}	
	
	function turnOutScore(mc){
		mc.rot *= Math.pow(1.4,kaluga.Cs.tmod)
		mc._rotation = mc.rot
		mc._xscale = 100-mc.rot/2
		mc._yscale = 100-mc.rot/2
		if(mc.rot>200){
			clearInterval(mc.animId);
			mc.removeMovieClip();
		}
	}
	
	function checkCombo(fruit){
		var n = 0;
		var b = 0;
		var name = ""

		if(fruit.flScNoLink ){
			b += 2;
			name += "pure "
		}
		if(fruit.flScSide ){
			b += 2;
			name += "rondade "
		}
		if(fruit.flScBound ){
			b += 4;
			name += "ricochet "
		}
		if(fruit.flScHead ){
			b += 10;
			name += "tete "
		}
		if(fruit.flScSquirrel ){
			b += 12;
			name += "ecureuil "
		}
		if(fruit.flScBird ){
			b += 24;
			name += "corbeau "
		}		
		if(fruit.flScLateral ){
			b += 8;
			name += "lateral "
		}
		if(fruit.flScDunk ){
			b += 10;
			name += "dunk "
		}

		if(fruit.flScDirect ){
			b += 4;
			name += "direct "
		}
		
		name = this.replace( name, "rondade ricochet ",		"double-bande "			)
		name = this.replace( name, "double-bande tete ",		"triple-impact "		)
		name = this.replace( name, "triple-impact ecureuil ",	"quadruple-impact "		)
		name = this.replace( name, "quadruple-impact corbeau ",	"pentacle mystique "		)
		name = this.replace( name, "rondade lateral ",		"shaker "			)
		name = this.replace( name, "double-bande lateral ",		"double-shaker "		)
		name = this.replace( name, "pure direct ",			"coup-de-bol "			)
		name = this.replace( name, "pure dunk direct ",		"lucky dunk "			)
		name = this.replace( name, "pure ecureuil ",		"wild ecureuil "		)
		name = this.replace( name, "ecureuil corbeau ",		"nature cooperation "		)
		name = this.replace( name, "pure corbeau ",			"wild corbeau "			)
		name = this.replace( name, "wild nature cooperation ",	"harmonie "			)
		name = this.replace( name, "ecureuil corbeau tete",		"trinitée "			)
		name = this.replace( name, "pure tete ",			"tete plongeante "		)
		name = this.replace( name, "rondade ecureuil ",		"wild side "			)
		name = this.replace( name, "latéral dunk ",			"demi-lune "			)
		name = this.replace( name, "demi-lune direct ",		"pleine-lune "			)
		name = this.replace( name, "shaker dunk ",			"maxi-shaker "			)
		name = this.replace( name, "rondade tete ",			"tete déviée "			)
		name = this.replace( name, "pure tete déviée",		"tete plongeante déviée "	)
		name = this.replace( name, "déviée dunk ",			"du mammouth "			)
		name = this.replace( name, "ricochet tete ",		"alouette "			)
		name = this.replace( name, "alouette lateral ",		"alouette courbée"		)
		name = this.replace( name, "ricochet corbeaux ",		"croc "				)
		name = this.replace( name, "tete dunk ",			"granite "			)
		name = this.replace( name, "rondade dunk ",			"coquelicot "			)
		
		//_root.test+="shoot : "+name+"\n"
		b*=10
		if(b>0)this.game.scroller.put(name,"+"+b);
		if(name!="")this.game.statCombo.incVal(name,1)
		return b;
		
		
		/*
		var txt,flDCheck;
		switch(n){
			case 1 :
				txt = "tir direct";
				break;
			case 2 :
			case 34 :
				txt = "ricochet";
				break;
			case 3 :
			case 35 :
				txt = "ricochet direct";
				break;			
			case 4 :
			case 36 :
				txt = "cabriole";
				break;
			case 5 :
			case 37 :
				txt = "cabriole directe";
				break;			
			case 6 :
			case 38 :
				txt = "double-bande";
				break;
			case 7 :
			case 39 :
				txt = "double-bande directe";
				break;
			case 8 :
				txt = "tete";
				break;
			case 9 :
				txt = "tete directe";
				break;
			case 10 :
			case 42 :
				txt = "tete plongeante";
				break;				
			case 11 :
			case 43 :
				txt = "tete plongeante directe";
				break;
			case 12 :
				txt = "tete décentrée";
				break;
			case 13 :
				txt = "tete décentrée directe";
				break;
			case 14 :
			case 30 :
				txt = "Triple Impact";
				break;
			case 15 :
			case 31 :
				txt = "Triple Impact direct";
				break;
			case 16 :					// DUNK
				txt = "Dunk";
				break;
			case 17 :
				txt = "Dunk direct";
				break;
			case 18 :
			case 19 :
			case 50 :
			case 51 :
				txt = "Dunk Granite";
				break;
			case 20 :
			case 52 :
				txt = "Dunk Etheré";
				break;
			case 21 :
			case 53 :			
				txt = "Dunk Etheré direct";
				break;		
			case 22 :
			case 23 :
			case 54 :			
			case 55 :			
				txt = "Dunk Diamant";
				break;
			case 24 :
				txt = "Head-Dunk";
				break;
			case 25 :
				txt = "Head-Dunk direct";
				break;
			case 26 :
			case 27 :
				txt = "Tete de granite";
				break;					
			case 28 :
			case 29 :
				txt = "Meteore";
				break;
			case 32 :					// NOLINK
			case 33 : 
				txt = "Chanceux";
				break;
			case 40 :
				txt = "Tete aérienne";
				break;
			case 41 :
				txt = "Tete aérienne directe";
				break;
			case 44 :
				txt = "Tete rectifiée";
				break;
			case 45 :
				txt = "Tete rectifiée directe";
				break;
			case 46 :
				txt = "Triple Impact seraphique";
				break;
			case 47 :
				txt = "Triple Impact seraphique parfait";
				break;
			case 48 :
			case 49 :
				txt = "Lucky dunk";
				break;
			case 56 :
				txt = "Sublime Head-dunk";
				break;
			case 57 :
				txt = "Sublime Head-Dunk direct";
				break;
			case 58 :
			case 59 :
				txt = "Sublime granity overflow";
				break;					
			case 60 :
			case 61 :
				txt = "Comete";
				break;		
			case 62 :
				txt = "Trinitée";
				break;
			case 63 :
				txt = "Trinitée anteSemeith";
				break;
			case 64 :
				txt = "Ecureuil Shot";
				break;			
			case 64 :
				txt = "Ecureuil Shot direct";
				break;	
			case 66 :
				txt = "Ecureuil Drop";
				break;
			case 67 :
				txt = "Ecureuil Drop direct";
				break;				
			case 68 :
				txt = "Ecureuil Side";
				break;
			case 69 :
				txt = "Ecureuil Side direct";
				break;
			case 70 :
				txt = "Motion-Twin";
			case 71 :
				txt = "Motion-Twin direct";
			case 72 :
				txt = "Ecureuil Clash";				
				break;
			case 73 :
				txt = "Ecureuil Clash direct";				
				break;
			case 74 :
				txt = "Ecureuil Drop Clash";				
				break;
			case 75 :
				txt = "Ecureuil Drop Clash direct";				
				break;					
			case 76 :
				txt = "Ecureuil Side Clash direct";				
				break;
			case 77 :
				txt = "Ecureuil Side Clash direct";				
				break;
			case 78 :
				txt = "Quadruple Impact";				
				break;
			case 79 :
				txt = "Quadruple Impact direct";				
				break;
			case 80 :
				txt = "Ecureuil Dunk";				
				break;
			case 81 :
				txt = "Ecureuil Dunk direct";				
				break;
			case 82 :
				txt = "Ecureuil Dunk Granite";				
				break;					
			case 83 :
				txt = "Ecureuil Dunk Granite direct";				
				break;	
			case 84 :
				txt = "Ecureuil Dunk Etheré";				
				break;					
			case 85 :
				txt = "Ecureuil Dunk Etheré direct";				
				break;
			case 86 :
				txt = "Ecureuil Dunk Diamant";				
				break;
			case 87 :
				txt = "Ecureuil Dunk Diamant direct";				
				break;
			case 88 :	// 64 + 16 + 8
				txt = "Ecureuil Torrent";				
				break;
			case 89 :
				txt = "Ecureuil Torrent direct ";				
				break;
			case 90 :	// 64 + 16 + 8 + 2
				txt = "Ecureuil Torrent Drop ";				
				break;
			case 91 :	// 64 + 16 + 8 + 2
				txt = "Ecureuil Torrent Drop Direct";	
			case default:
				break;
		}
		*/
		
	
	
	}
	
	function replace(str,search,replace){
		var preText = "", newText = "";

		if(search.length==1) return str.split(search).join(replace);
		
		var position = str.indexOf(search);
		if(position == -1) return str;
		
		do { 
			position = str.indexOf(search); 
			preText = str.substring(0, position) 
			str = str.substring(position + search.length) 
			newText += preText + replace; 
		} while(str.indexOf(search) != -1) 
		newText += str; 
		return newText; 
	} 	
//{	
}