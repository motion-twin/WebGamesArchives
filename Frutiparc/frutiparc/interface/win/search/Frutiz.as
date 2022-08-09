class win.search.Frutiz extends win.Search {//}

	
	//CONSTANTES
	var blocMax:Number = 6
	
	// VARIABLES
	var infoCountry:String;//[Lang.fv("subscribe.country_combo_title")];
	var infoRegion:String;//[Lang.fv("subscribe.country_combo_title")];
	
	function Frutiz(){
		_root.test+="[win.search.Frutiz] init()\n"
		this.init();
	}
	
	function init(){
		super.init();
		
		if( infoCountry == undefined ) infoCountry = "france;bresil;canada;gomoland;zealmy"
		infoRegion = "Choisissez un pays !"
		
		this.endInit();
		//
	};
	
	function updateSearchFrame(){
		super.updateSearchFrame()
		if( !this.flAdvance ){
			this.doc.removeVariableListener("country","country_combo_on_change");
		}else{
			this.doc.addVariableListener("country",{obj: this.box,method: "onCountryChange",uniq: "country_combo_on_change"});
		}
	}
	
	function getSearchLines(){
		var lines = new Array();
		
		var list = [
			{
				type:"text",
				width:60,
				param:{
					text:"pseudo :"
				}
			},
			{
				type:"input",
				//width:80,
				param:{
					variable:"pseudo",
					fieldProperty: { maxChars:18, restrict:"0-9a-zA-Z" }
				}
			},
			{	type:"spacer",	width:4	},
			{	type:"button",
				param:{
					initObj:{txt:"ok"},
					buttonAction:{onPress:[{obj:this,method:"launchSearch"}]}
				}
			}	
		]
		_root.test+="this.flAdvanceAvailable("+this.flAdvanceAvailable+")\n"
		if( this.flAdvanceAvailable ){
			var o = {
				type:"button",
				dx:3,
				param:{
					initObj:{txt:"avancée"},
					buttonAction:{onPress:[{obj:this,method:"toggleAdvance"}]}
				}			
			}
			list.push(o)
		}
			
		
		lines.push({list:list})
		
		return lines
		
	}	
	
	function getAdvanceSearchLines(){
		var lines = new Array();
		
		// SEXE AGE
		var list = [
			{
				type:"text",
				width:48,
				param:{
					text:"sexe :"
					
				}
			},
			{	
				type:"radio",
				width: 76,
				param:{
					variable: "gender",
					val: "M",
					text:"Masculin"// Lang.fv("gender.M")
				}
			},
			{
				type:"radio",
				width: 76,
				param:{
					variable: "gender",
					val: "F",
					text:"Feminin" //Lang.fv("gender.F")
				}
			},
			{	
				type:"radio",
				width: 60,
				param:{
					variable: "gender",
					val: "",
					text: "Tous"
				}
			}		
		]
		lines.push({list:list})
		
		// AGE
		var list = [
			{
				type:"text",
				width:66,
				param:{
					text:"age min :"
					
				}
			},
			{
				type:"input",
				width:40,
				param:{
					variable:"ageMin",
					fieldProperty: {maxChars: 2,restrict: "0-9"}

				}
			},
			{	type:"spacer",	width:12	},
			{
				type:"text",
				width:66,
				param:{
					text:"age max :"
				}
			},			
			{
				type:"input",
				width:40,
				param:{
					variable:"ageMax",
					fieldProperty: {maxChars: 2,restrict: "0-9"}
				}
			}
		]
		lines.push({list:list})		
		
		// PAYS
		var list = [
			{	type:"text",
				width:50,
				param:{
					text:"pays :"
				}
			},
			{	type:"comboBox",
				big:100,
				param:{
					name: "country",
					variable: "country",
					text: this.infoCountry
				}
			}
		]	
		lines.push({list:list})	
		
		// REGION
		var list = [
			{	type:"text",
				width:50,
				param:{
					text:"region :"
				}
			},
			{	type:"comboBox",
				big:100,
				param:{
					name: "region",
					variable: "region",
					text: this.infoRegion
				}
			}
		]	
		lines.push({list:list})		
		
		//
		return lines;
	}

	function onUpdateSearchFrame(){
		if(this.flAdvance){
			this.doc.addVariableListener("country",{obj: this.box,method: "onCountryChange",uniq: "country_combo_on_change"});
		}else{
			this.doc.removeVariableListener("country","country_combo_on_change");
		}
	}
	
	function updateRegionCombo(t){
		this.doc.console.region.text = t;
		this.doc.console.region.initElementList();
		this.doc.setVariable("region",0);
		this.doc.console.region.valSetTo(0); // pour s'assurer que l'affichage est bien mis à jour	
	}

	function displayBloc(list,page,searchMax){
		// BLOCS
		this.cleanPage();
		var w = mWidth 
		var h = 50
		for(var i=0; i<list.length; i++){
			var info = list[i]

			
			//*
			var args={
				info:info
			}
			var frame = {
				name:"bloc"+i,
				link:"cpSearchSlot",
				type:"compo",
				//margin:margin,
				flBackground:false,
				mainStyleName:"frSheet",
				min:{w:w,h:h},
				args:args
			}
			this.main.showFrame.newElement(frame)
			//*/
		}
		
		
		// PAGE
		var pageMax = Math.ceil(searchMax/blocMax)
		var str = page+"/"+pageMax+" - "+searchMax+" réponse"
		if(searchMax>1)str += "s";
		this.pageSelector.setText(str)
		
		this.frameSet.update();
		/*
		
		this.pos.w = 0
		this.pos.h = 0
		this.updateSize();
		this.frameSet.update();
		*/
		
	}
	
	function cleanPage(){
		for(var i=0; i<this.blocMax; i++ ){
			this.main.showFrame.removeElement("bloc"+i);
		}		
	}
	
	function launchSearch(){
		//*
		if(!Key.isDown(Key.ENTER)){
			super.launchSearch()
		}else{
			var list = new Array();
			for( var i=0; i<4; i++ ){
				var o = 	{
					xpLevel:1,
					xpCompletionRate:0.75,
					nickname:"bumdum",
					gender:"M",
					age:26,
					birthday:"20-01-1978",
					country:"France",
					countryCode:1,
					sregion:"Gironde",
					city:"Bordeaux",
					fbouille:"0000020K01000d0301040t00",
					presence:0,//(0,1,2),
					status:{}			
				}
				list.push(o)
			}	
	
			displayBloc(list,0,124)		
		}
	}
	
	
	
//{
};





