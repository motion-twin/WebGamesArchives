/*
$Id: Shop.as,v 1.60 2004/07/09 16:48:20  Exp $

Class: box.Shop
*/
class win.Shop extends win.Advance{//}
	
	// CONSTANTES
	var topLeftBarHeight:Number = 22;
	
	// VARIABLES
	var flMenu:Boolean;
	var displayMode:String;
	var iconList:Array;
	var item:Object;
	
	
	var menuTree:cp.Tree;
	var cpMenu:cp.ProductMenu;
	var cpInfo:cp.Document;
	var cpCounter:cp.Counter;
	
	
	/*-----------------------------------------------------------------------
		Function: Shop()
	 ------------------------------------------------------------------------*/	
	function Shop(){
		this.init();	
	}

	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		//this.iconLabel="shop"
		//_root.test+="winShopInit\n"
		this.genIconList();
		
		super.init();
		this.endInit();
		
		this.flMenu = false
		if(this.item!=undefined){
			this.displayItem(this.item);
		}
		
	}
	
	function genIconList(){
		this.iconList = [
			{link:"butPush", param:{
					link:"butPushSmallWhite",
					frame:20,
					outline:2,
					curve:4,
					tipId: "shop_kikooz_log",
					buttonAction:{ 
						onPress:[{
							obj: _global.uniqWinMng,
							method: "open",
							args: "kikoozLog"
						}]
					}
				}
			},
			{link:"butPush", param:{
					link:"butPushSmallWhite",
					frame:21,
					outline:2,
					curve:4,
					tipId: "shop_obtain_kikooz",
					buttonAction:{ 
						onPress:[{
							obj: this.box,
							method: "obtainKikooz"
						}]
					}
				}
			}
		]
	}
	
	/*-----------------------------------------------------------------------
		Function: initFrameSet()
	 ------------------------------------------------------------------------*/	
	function initFrameSet(){
		
		super.initFrameSet();

		// TOPLEFTBAR
		var margin = Standard.getMargin();
		margin.x.min = 8;
		margin.x.ratio = 1;
		this.margin.left.newElement( { name:"bar", type:"h", min:{w:140,h:this.topLeftBarHeight}, margin:margin } )	
		// COMPTEUR DE KIKOOZ
			
			var ts = Standard.getTextStyle()
			ts.def.textFormat.size = 14;
			ts.def.textFormat.bold = true;
			ts.def.textFormat.color = _global.colorSet.brown.overdark
			
			var args = {
				//value:254,
				align:"left",
				textStyle:ts.def
			}

	
			var frame = {
				name:"kikoozFrame",
				link:"cpCounter",
				type:"compo",
				min:{w:70,h:this.topLeftBarHeight},
				flBackground:true,
				mainStyleName:"frKikooz",
				args:args
			}
			
			this.cpCounter = this.margin.left.bar.newElement( frame )
			
			// ICONLIST
			var struct = Standard.getSmallStruct();
			struct.x.margin = 0
			struct.y.margin = 0
			struct.x.align = "end"
			struct.y.align = "start"
			var args = {
				//flMarker:true,
				list:this.iconList,
				struct:struct,
				mask:{flScrollable:false}
			};
			var frame = {
				name:"iconList",
				link:"basicIconList",
				type:"compo",
				min:{w:70,h:this.topLeftBarHeight},
				args:args
			}			
			this.margin.left.bar.newElement( frame )
			
		
		// MENU
		// var list = this.getSpecimenList();
		var args = {
			width:140,
			flMask:true
		}
		var margin = Standard.getMargin();
		margin.x.min = 8;
		margin.x.ratio = 1;
		margin.y.min = 16;
		margin.x.ratio = 1;
		var frame = {
			name:"menuFrame",
			link:"cpTree",
			type:"compo",
			min:{w:140,h:60},
			margin:margin,
			flBackground:true,
			mainStyleName:"frSystem",			
			args:args
		}
		this.menuTree = this.margin.left.newElement( frame )
		this.margin.left.bigFrame = this.margin.left.menuFrame;
		
		// initialise la frame show
		var margin = Standard.getMargin();
		margin.x.min = 8;
		margin.x.ratio = 1;
		//margin.y.min = 12;
		//margin.y.ratio = 0
		this.main.newElement({ name:"showFrame", type:"h", min:{w:300,h:200}, flBackground:true, margin:margin})
		this.main.bigFrame = this.main.showFrame;
			
			// initialise la frame productInfo
			var args = {
				//mainStyleName:"content",
				flMask:true			
			}
			var margin = Standard.getMargin();
			margin.y.min = 4;
			margin.y.ratio = 1;
			
			//var margin = Standard.getMargin();
			var frame = {
				name:"menuInfoFrame",
				margin: margin,
				link:"cpDocument",
				type:"compo",
				min:{w:200,h:200},
				mainStyleName:"frSheet",
				args:args
			}			
			this.cpInfo = this.main.showFrame.newElement(frame)
			this.main.showFrame.bigFrame = this.main.showFrame.menuInfoFrame;
		

		// BAR
		var margin = Standard.getMargin();
		margin.y.min = 6
		margin.y.ratio = 1
		this.main.newElement( { name:"bar", type:"h", min:{w:10,h:10}, margin:margin } )	
			
			// FDDRIVE
			/*
			var margin = Standard.getMargin();
			margin.x.min = 8;
			margin.x.ratio = 1;			
			var args = {}
			var frame = {
				name:"FDDriveFrame",
				link:"cpFDDrive",
				type:"compo",
				min:{w:72,h:72},
				args:args,
				margin:margin
			}		
			this.main.bar.newElement(frame);
			*/
			// EMPTY
			this.main.bar.newElement( { name:"empty", type:"h" } )
			this.main.bar.bigFrame = this.main.bar.empty
			// BUTKIKOOZ
			var args={
				link:"butPushMoreKikooz",
				frame:3,
				outline:2,
				curve:6,
				buttonAction:{ 
					onPress:[{
						obj:this.box,
						method:"obtainKikooz"
					}]
				}
			}
			var frame = {
				name:"pushKikooz",
				link:"butPush",
				type:"compo",
				min:{w:100,h:60},
				args:args
			}		
			this.main.bar.newElement(frame);
			//*/
			
			
	}

	/*-----------------------------------------------------------------------
		Function:  setTree()
	 ------------------------------------------------------------------------*/	
	function setTree(a){	
		/* > 0:10 trops tard pour la recursivit�
		this.list = new Array()
		for(var i=0; i<a.length; i++){
			this.list.push( newElement(a[i]) )
		}
		this.menuTree.setList(this.list)
		*/
		this.menuTree.setList(a)
	}
	
	/*-----------------------------------------------------------------------
		Function: newElement(e)
	 ------------------------------------------------------------------------*/	
	function newElement(e){
		var element = new Object;
		if(e.list!=undefined){
			element.list = new Array()
			for(var i=0; i<e.list.length; i++){
				element.list.push(newElement(e.list[i]))
			}
		}else{
			element.buttonAction = {}
		}
		
		return element;
		
	}
	
	/*-----------------------------------------------------------------------
		Function:  displayItem(item)
			{  
			  id: 2,  
			  name: "Burning Kiwi",  
			  type: "game",  
			  quantity: 0, // -1 si illimit�  
			  description: "string � passer � un champ HTML flash",  
			  price: {  
			    price: 50,  
			    // Dates de validit�s du prix  
			    start: undefined | "2003-12-23 22:45:33", // pour l'affichage d'une date, y'a d�j� toutes les fonctions disponibles  
			    end: undefined | "2003-12-23 22:45:33",  
			    comment: "Prix public" // l� c'est un champ facultatif o� on peut mettre par exemple "Promotion reserv�e aux frutiz ayant une frutibouille rouge", ou ce genre de choses  
			  }
			  screens: Array;
			  video: Array;
			  comment: Number;
			}
	------------------------------------------------------------------------*/	
	function displayItem(item){	
		if(!this.flMenu)this.attachMenu();
		this.item = item;
		
		//_root.test+="dispayItem\n"
		var butList = new Array();
		
		
		//butList.push( {name:"test",action: {obj: this, method:"displayItemPage", args:"test"}} )

		var needDescButton = false;
    
		if( item.screens.length ){
			needDescButton = true; 
			butList.push( {name:"Images",action: {obj: this, method:"displayItemPage", args:"screenshot"}} )
		}
		
		if(needDescButton){
			butList.unshift( {name:"Description",action: {obj: this, method:"displayItemPage", args:"description"}} )
		}
		
		
		if(!item.alreadyBuy){
			butList.unshift( {name: Lang.fv("shop.buy"),action: {obj: this.box,method: "buy",args: this.item.id}} )
		}
		
		
		this.cpMenu.setItem( this.item.picto, butList );

		
		this.displayItemPage("description")
		//this.displayItemPage("test")
	}
	
	function displayItemPage(type){
		//_root.test+="dispayItemPage("+type+")\n"
		
		var doc_str = "<p>";
		
		switch(type){
			case "description" :
				// Product name
				doc_str += '<l><t s="4">'+this.item.name+'</t></l>';
				doc_str += FEString.replaceBackSlashN(this.item.description);
				
				if(item.alreadyBuy){
					doc_str += '<l><t s="3">'+Lang.fv("shop.already_have")+'</t></l>';
				}else{
					doc_str += '<l><t s="3">'+Lang.fv("shop.price",{p: this.item.price.price})+'</t></l>';
					if(this.item.price.end != undefined || this.item.price.comment != undefined){

						var ln_price = '<l><t s="2">';
						if(this.item.price.comment != undefined){
							ln_price += Lang.fv("shop.price_comment",{c: this.item.price.comment})
						}
						if(this.item.price.end != undefined && this.item.price.comment != undefined){
							ln_price += " ";
						}	
						if(this.item.price.end != undefined){
							ln_price += Lang.fv("shop.price_end",{d: Lang.formatDateString(this.item.price.end,'short')})
						}
						ln_price += '</t></l>';
						doc_str += ln_price;
            
					}
				}
				if(this.item.quantity > -1){
					doc_str += '<l><t s="2">'+Lang.fv("shop.pack_quantity",{q: this.item.quantity})+'</t></l>';
				}
         
        if(this.item.screens.length > 0){
          doc_str += '<l><t s="2">'+this.item.screens.length+' images disponibles !</t></l>';
        }
        
				break;

			case "screenshot" :
        var list = this.item.screens;
				
				/*  HACK
				list = [
				     {
				       returnId:0,
				       title: "Image truc machin",
				       thumb: {width:146, height:100, url:"s:/ss/kaluga/kaluga01s.jpg"}
				     },
				     {
				       returnId:1,
				       title: "Image truc bidule",
				       thumb: {width:146, height:100, url:"s:/ss/kaluga/kaluga02s.jpg"}
				     },
				     {
				       returnId:2,
				       title: "Kaluga en short",
				       thumb: {width:146, height:100, url:"s:/ss/kaluga/kaluga02s.jpg"}
				     },
				     {
				       returnId:3,
				       title: "Kaluga aime les radis",
				       thumb: {width:146, height:100, url:"s:/ss/kaluga/kaluga01s.jpg"}
				     },
				     {
				       returnId:4,
				       title: "Mangez des corbeaux",
				       thumb: {width:146, height:100, url:"s:/ss/kaluga/kaluga02s.jpg"}
				     },
				     {
				       returnId:5,
				       title: "Contre l'arm�e Syrienne",
				       thumb: {width:146, height:100, url:"s:/ss/kaluga/kaluga02s.jpg"}
				     }			     
				]
				//*/
				     
				doc_str += '<l h="8"></l><l>';
				for( var i=0; i<list.length; i++ ){
					var o = list[i]
					
					var m = 10
					var w = o.thumb.width+m
					var h = o.thumb.height
					
					doc_str += '<p w="'+w+'" h="'+(h+20)+'">'
					doc_str += '<l><u u="'+o.thumb.url+'" w="'+w+'" h="'+h+'"><p><glAction o="doc.win.box" m="displayScreenshot" a="'+o.returnId+'"></glAction></p></u></l>'
					doc_str += '<l><t w="'+(w-m)+'">'+o.title+'<p><textFormat align="center"/></p></t></l>'
					doc_str += '</p>'
					
				}
				doc_str +='</l>'
				break;
				
			case "test" :
				doc_str += '<l>'
				for(var i=0; i<10; i++)doc_str += '<t w="80" s="4">coucou</t>';
				doc_str += '</l>';
				doc_str += '<l>'
				doc_str += '<t w="80" s="4">faefa</t><t w="80" s="4">faefa</t>';
				doc_str += '</l>';				
				
				break;
			default :
				doc_str += '<l>'
				for(var i=0; i<10; i++)doc_str += '<t w="80" s="4">coucou</t>';
				doc_str += '</l>';
			
				break;			
			
		}
		
		doc_str += "</p>";
		var doc = new XML();
		doc.ignoreWhite = true;
		doc.parseXML(doc_str);
		this.cpInfo.setDoc(doc);
		this.main.update()		
		
		
		
	}
	
	/*-----------------------------------------------------------------------
		Function:  displayError(str)
	 ------------------------------------------------------------------------*/	
	function displayError(str){	
		if(this.flMenu) this.detachMenu();
	}
	
	/*-----------------------------------------------------------------------
		Function:  displayWait()
	 ------------------------------------------------------------------------*/	
	function displayWait(){	

	}
	
	/*-----------------------------------------------------------------------
		Function:  setKikooz(k)
			Appel�e lorsque le nombre de kikooz a chang�
	 ------------------------------------------------------------------------*/	
	function setKikooz(k){
		this.cpCounter.setKikooz(k)
	}

	/*-----------------------------------------------------------------------
		Function:  attachMenu()
			initialise la frame productMenu
	 ------------------------------------------------------------------------*/	
	function attachMenu(){
		// 
		var args = {
			//flBackground:true,
			//mainStyleName:"content"
		}
		var margin = Standard.getMargin();
		margin.x.min = 12;
		margin.y.min = 4;
		margin.y.ratio = 1;
		var frame = {
			name:"menuProductFrame",
			link:"cpProductMenu",
			type:"compo",
			margin:margin,
			args:args
		}
		this.flMenu = true;
		this.cpMenu = this.main.showFrame.newElement(frame,0)
		
		this.frameSet.update();
	}

	/*-----------------------------------------------------------------------
		Function:  detachMenu()
	 ------------------------------------------------------------------------*/	
	function detachMenu(){
		this.main.showFrame.removeElement("menuProductFrame")
		this.flMenu = false;
		
		this.frameSet.update();
	}

	/*-----------------------------------------------------------------------
		Function:  onBuyError(str)
			Appel�e en cas d'erreur sur une action d'achat
			
		Parameters:
			str - string - Chaine de caract�re contenant l'erreur � afficher
	 ------------------------------------------------------------------------*/	
	function onBuyError(str){
		// TODO
	}
	
	/*-----------------------------------------------------------------------
		Function:  onBuySuccess(k)
			Appel�e lorsqu'une action d'achat a r�ussie
			
		Parameters:
			k - number - nouveau solde du compte du frutiz en kikooz (la fonction setKikooz est appel�e �galement)
	 ------------------------------------------------------------------------*/	
	function onBuySuccess(k){
		// TODO
	}
	
	function scrollText(px){
		this.cpInfo.mask.y.path.pixelScroll(px);
	}

	//
	
	function testAlpha(){
		_root._alpha = 50
	}
	
//{	
}




