
class Standard{//}
	
	static function getStruct(){
		var struct = {
			order:"x",
			x:{
				size:30,
				space:0,
				align:"start",
				margin:0,
				sens:1
				
			},
			y:{
				size:30,
				space:0,
				align:"start",
				margin:0,
				sens:1
			},
			limit:false	
		}
		return struct;
	}

	static function getSmallStruct(){
		var struct = {
			order:"x",
			x:{
				size:24,
				space:2,
				align:"center",
				margin:2,
				sens:1
				
			},
			y:{
				size:24,
				space:2,
				align:"center",
				margin:2,
				sens:1
			},
			limit:"x"	
		}
		return struct;
	}
	
	
	static function getMargin(){
		var margin = {
			x:{
				min:0,
				ratio:0.5,
				align:0
				
			},
			y:{
				min:0,
				ratio:0.5,
				align:0
			}	
		}
		return margin;
	}

	static function getTextStyle(){
		var ts = {
			def:{
				textFormat:{
					color: 0x000000,
					font: "Verdana",
					size: 10
				},
				fieldProperty:{
					selectable:false
				}
			}	
		}
		return ts;
	}
	
	static function getTreeStyle(){
		
		var treeStyle = new Array();
		
		for(var i=0; i<4; i++){
			var sts = Standard.getTextStyle();
			if(i>0){
				sts.def.color = 0x444444;
				sts.def.bold = true;
			}				
		treeStyle[i] = { ts:sts.def, bullet:"standardBullet" };
		};
					
		treeStyle[1].ts.textFormat.size += 6;
		treeStyle[2].ts.textFormat.size += 4;
		treeStyle[3].ts.textFormat.size += 2;
		treeStyle[4].ts.textFormat.size += 0;

		return treeStyle;
	
	}
	
	static function getOldWinStyle(){
		var ws = {
			global:{
				outline:1,
				inline:2,	
				curve:10,
				color:{
					main:		0xFFFFFF,//0xFF0000,//0xFFFFFF,
					inline:		0xDDDDDD,
					outline:	0x444444
				}
			},
			content:{
				inline:1,
				outline:2,
				curve:3,
				color:{
					main:		0xD6F7B5,
					inline:		0xBaF082,
					outline:	0xDDDDDD,
					dark:		0x94DB39,
					overdark:	0x66AA22,
					light:		0xE8FFC0
				}	
			},	
			content2:{
				outline:2,
				inline:2,
				curve:3,
				color:{
					main:		0xE4f499,
					inline:		0xDCEE5B,
					outline:	0xDDDDDD
				}	
			},
			content3:{
				outline:2,
				inline:2,
				curve:3,
				color:{
					main:		0xFFDFDF,
					inline:		0xFFBBBB,//0xFEABAB
					outline:	0xDDDDDD,
					dark:		0xEE8888,
					text:		0x772222,
					textdark:	0x550000
				}	
			},
			content4:{
				inline:0,
				outline:2,
				curve:3,
				color:{
					main:		0xFFFFFF,
					inline:		0xDDDDDD,
					outline:	0xDDDDDD,
					dark:		0xAAAAAA,
					overdark:	0x888888 
				}				
			}
		}
		return ws;
	}

	static function getWinStyle(){
		var ws = {
			global:{
				color:[
					_global.colorSet.white,
					_global.colorSet.green
				]
			},
			frFileStandard:{
				color:[
					_global.colorSet.yellow,
					_global.colorSet.yellow
				]	
			},
			frFileTrash:{
				color:[
					_global.colorSet.green,
					_global.colorSet.green
				]	
			},
			frFileBlackList:{
				color:[
					_global.colorSet.purple,
					_global.colorSet.purple
				]	
			},			
			frSystem:{			// DEVRAIT ETRE MERGE AVEC GLOBAL ?
				bgInfo:{
					inline:0
				},
				color:[
					_global.colorSet.white,
					_global.colorSet.green,
					_global.colorSet.white
				]		
			},
			frRoomList:{
				color:[
					_global.colorSet.pink,
					_global.colorSet.pink,
					_global.colorSet.pink
				]		
			},
			frScore:{
				color:[
					_global.colorSet.orange,
					_global.colorSet.orange,
					_global.colorSet.orange
				]		
			},
			frScoreLight:{
				color:[
					_global.colorSet.orange,
					_global.colorSet.orange,
					_global.colorSet.orange
				]		
			},			
			frSheet:{
				color:[
					_global.colorSet.green,
					_global.colorSet.green,	
					_global.colorSet.pink
				]
			},
			frKikooz:{
				color:[
					_global.colorSet.brown,
					_global.colorSet.brown
				]
			},			
			frDef:{
				color:[
					_global.colorSet.green,
					_global.colorSet.green
				]	
			},
			frInfo:{
				color:[
					_global.colorSet.yellow,
					_global.colorSet.yellow
				]	
			}			
		}
		return ws
	}

	static function getButTextBasicBehavior(){
		return {
			type:"colorText",
			color:{press:0xDDDDDD, over:0xE7756B}		
		};
	}

	static function getDocStyle(style){
		//_root.test+=" getDocStyle("+style+")\n"
		var c0 = style.color[0];
		var c1 = style.color[1];
		var c2 = style.color[2];
		var tsg = Standard.getTextStyle();
		
		var ts = {
			fieldProperty:tsg.def.fieldProperty,
			textFormat:tsg.def.textFormat
		}
		ts.textFormat.color = c0.overdark

		var ds = {
			inputColor:c1,
			bgTextColor:c0,
			outlineColorNum:c0.shade,
			ts : ts
		};
		ds.s =  new Array()
		for(var i=0; i<20; i++){
			ds.s[i] = FEObject.recursiveClone(ts);
			//ds.s[i].endParagraphSpacing		???
		};
		
		var mainColor = c0.darkest;		//0x226600
		var titleColor = c0.overdark;		//0x113300//0xFF5555//
		var secondTitleColor = c2.darkest;
		var mainTitleColor = c2.overdark;
		
 		ds.s[0].textFormat.color = mainColor;
		ds.s[0].textFormat.size = 10;
		ds.s[0].textFormat.leftMargin = 6;
		ds.s[0].space = 0;
		
 		ds.s[1].textFormat.color = titleColor
		ds.s[1].textFormat.size = 11;
		ds.s[1].textFormat.leftMargin = 4;
		ds.s[1].space = 1;
		
		ds.s[2].textFormat.color = titleColor
		ds.s[2].textFormat.size = 12;
		ds.s[2].textFormat.leftMargin = 2;
		ds.s[2].textFormat.bold = true;	
		ds.s[2].space = 2;
		
		ds.s[3].textFormat.color = titleColor
		ds.s[3].textFormat.size = 13;
		ds.s[3].textFormat.bold = true;		
		ds.s[3].space = 3;
		
		ds.s[4].textFormat.color = secondTitleColor
		ds.s[4].textFormat.size = 15;
		ds.s[4].textFormat.bold = true;
		ds.s[4].space = 4;

		ds.s[5].textFormat.color = mainTitleColor
		ds.s[5].textFormat.size = 16;
		ds.s[5].textFormat.bold = true;	
		ds.s[5].space = 5;

 		ds.s[11].textFormat.color = secondTitleColor
		ds.s[11].textFormat.size = 11;
		ds.s[11].textFormat.leftMargin = 4;
		ds.s[11].space = 1;

		return ds;
	}
	
	static function getFrusionDocStyle(style){

		var tsg = Standard.getTextStyle();
		
		var ts = {
			fieldProperty:tsg.def.fieldProperty,
			textFormat:tsg.def.textFormat
		}
		
		var green ={
			lightest:	0xFFFFFF,
			lighter:	0xF3FFD5,
			light:		0xDDFFBB,
			main:		0xCCF599,
			shade:		0xADE76B,
			dark:		0x94DB39,
			darker:		0x66AA22,
			darkest:	0x558811,
			overdark:	0x335511
		}
		var white={
			lightest:	0xFFFFFF,
			lighter:	0xFFFFFF,
			light:		0xFFFFFF,
			main:		0xFFFFFF,
			shade:		0xDDDDDD,
			dark:		0xAAAAAA,
			darker:		0x888888,
			darkest:	0x444444,
			overdark:	0x222222
		}		
		
		var ds = {
			outColor:white,
			inputColor:green,
			bgTextColor:green,
			outlineColorNum:green.darker
		};
		ds.s =  new Array()
		for(var i=0; i<8; i++){
			ds.s[i] = FEObject.recursiveClone(ts);
			//ds.s[i].endParagraphSpacing		???
		};
		
		var mainColor = 0xFFFFFF;		//0x226600
		var titleColor = 0xFFFFFF;		//0x113300//0xFF5555//
		var secondTitleColor = 0xFFFFFF;
		var mainTitleColor = 0xFFFFFF;
		
 		ds.s[0].textFormat.color = mainColor;
		ds.s[0].textFormat.size = 11;
		ds.s[0].textFormat.bold = true;
		ds.s[0].textFormat.leftMargin = 6;
		ds.s[0].space = 0;
		
 		ds.s[1].textFormat.color = titleColor
		ds.s[1].textFormat.size = 12;
		ds.s[1].textFormat.bold = true;
		ds.s[1].textFormat.leftMargin = 4;
		ds.s[1].space = 1
		
		ds.s[2].textFormat.color = titleColor
		ds.s[2].textFormat.size = 12;
		ds.s[2].textFormat.leftMargin = 2;
		ds.s[2].textFormat.bold = true;	
		ds.s[2].space = 2
		
		ds.s[3].textFormat.color = titleColor
		ds.s[3].textFormat.size = 13;
		ds.s[3].textFormat.bold = true;		
		ds.s[3].space = 3
		
		ds.s[4].textFormat.color = secondTitleColor
		ds.s[4].textFormat.size = 15;
		ds.s[4].textFormat.bold = true;
		ds.s[4].space = 4

		ds.s[5].textFormat.color = mainTitleColor
		ds.s[5].textFormat.size = 16;
		ds.s[5].textFormat.bold = true;	
		ds.s[5].space = 5
		
		return ds;		
	}
	
	static function getPrefForm(t){
		switch(t){
			case "bool":
				return new XML('<l><s b="1"/><r w="60" v="value" u="Y">'+Lang.fv("yes")+'</r><s b="1"/><r w="60" v="value" u="N">'+Lang.fv("no")+'</r><s b="1"/></l>');
			case "string":
				return new XML('<l><s w="20"/><i v="value" dy="1" b="1"></i><s w="20"/></l>');
			case "int":
				return new XML('<l><s w="20"/><i v="value" dy="1" b="1" r="0-9"></i><s w="20"/></l>');
		}
	}
	
	static var $styleSheet:TextField.StyleSheet;
	static function getStyleSheet(){
		if($styleSheet == undefined){
			$styleSheet = new TextField.StyleSheet();
			$styleSheet.setStyle("a:link", {
				color:'#344D67',
				textDecoration: 'none'
			});
			$styleSheet.setStyle("a:hover", {
				color:'#344D67',
				textDecoration: 'underline'
			});

		}
		
		return $styleSheet;
	}
	/*
	static function getFrutiCardLines(frutiCard,gameName){		// DEVRAIT ETRE PLACE DANS UN SWF EXTERENE D'UNE MANIERE OU D'UN AUTRE
		switch(gameName){
			
			case "bkiwi" :
				
				var lines = new Array();
				var line;
				
				// LISTE DE COUPES
				line = new Array();
				var awardList = ["ws", "wss", "wc", "wcs"]
				for( var i=0; i<awardList.length; i++ ){
					var bool = fruticard[awardList[i]]
					var o = {
						type:"url",
						param:{
							url:Path.awards,
							min:{w:30},
							param:{
								frame:"bkiwi",
								value:1,
								day:2
							}
						}
					}
					line.push(o)
				}
				lines.push(line)	
				// LISTE DE VOITURES
				
				lines.concat()
				
				line = [
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
							frame:"bkiwi"
						}
					},						
					{
						type:"text",
						width:120,
						param:{
							sid: 1,
							text: "lalatsouiiiiiiiiin!\n"
						}
					},
					{
						type:"text",
						width:80,
						param:{
							sid: 1,
							text: 3240,
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
							text: "gloups",
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
				return lines				
			case "snake3" :
				
				break;
			
			case "mb2" :
				
				break;
			default :
				_root._alpha = 50;

		}	

		
	}
	*/
//}
}





















