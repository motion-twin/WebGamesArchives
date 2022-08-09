class cp.SearchSlot extends Component{//}
		
	// CONSTANTES

	var th:Number = 44
	var mLeft:Number = 24
		
	// VARIABLE
	var info:Object;

	/*	
	xpLevel
	xpCompletionRate
	- nickname
	gender
	- age,
	birthday,
	country,
	countryCode,
	- region,
	- city
	frutibouille
	presence:(0,1,2)
	status:Object;
	*/
	
	// MOVIECLIPS
	var screen:cp.FrutiScreen;
	var doc:cp.Document

	function SearchSlot(){
		this.init()
	}
	
	function init(){
		//this.fix = {w:130,h:45}
		super.init();
		this.initScreen();
		this.initDoc();
	}
	
	function initScreen(){
		// SCREEN
		var initObj = {
			fix:{w:th,h:th}
		};		
		this.content.attachMovie("frutiScreen","screen",10,initObj);
		this.screen = this.content.screen;
		this.screen.onStatusObj({fbouille:info.fbouille,status: info.status,presence: info.presence})
		this.screen._x = mLeft
		var me = this;
		this.screen.onPress = function(){
			me.select();
		}
		
		
		var m = 2
		// STATUS
		this.content.attachMovie("status","status",11);
		this.content.status._x = 2;
		this.content.status._y = 0;
		this.content.bg.gotoAndStop(2)
		this.updateStatus();
		
		// COUNTRY
		this.content.attachMovie("countryBox","country",12);
		this.content.country._x = 2;
		this.content.country._y = this.th*0.5;
		if( this.info.countryCode == "" ) this.info.countryCode = "ot";
		this.content.country.gotoAndStop(info.countryCode)
		
		
		
	}

	function initDoc(){
		
		var pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[]
		}
		
		// 1ere ligne
		var list= [
			{
				type:"text",
				width:110,
				param:{
					textFormat:{size:11, bold:true},
					text:info.nickname
				}
			},
			{
				type:"text",
				big:1,
				param:{
					textFormat:{size:10, align:"right"},
					fieldProperty:{multiline:false,wordWrap:false},
					text:info.region
				}
			}			
		]
		pageObj.lineList.push({list:list})
		
		// 2eme ligne
		var list= [
			{
				type:"text",
				width:60,
				param:{
					//textFormat:{size:11, bold:true},
					text:info.age +" ans"
				}
			},
			{
				type:"text",
				big:1,
				param:{
					textFormat:{size:10, align:"right"},
					fieldProperty:{multiline:false,wordWrap:false},
					text:info.city
				}
			}			
		]
		pageObj.lineList.push({list:list})		
		
		
		var x = mLeft + th + 8
		var mainStyleName = "frRoomList"
		if( info.gender == "M" ) mainStyleName = "frSheet"
		
		var initObj = {
			flTrace:true,
			win:this.win,
			width:190,
			height:th,
			mainStyleName:mainStyleName,
			pageObj:pageObj
		}		
		this.content.attachMovie("cpDocument","doc",20,initObj)
		this.doc = this.content.doc
		this.doc._x = x
		this.doc._y = 1
		this.doc.updateSize();
		var me = this
		this.doc.onPress= function(){
			me.select();
		}
				//_root.test+="doc("+this.doc+")\n"
		//_root.test+="doc.width("+this.doc.width+")\n"
		
	}
	
	function updateSize(){
		super.updateSize();
		this.screen.updateSize();
		this.updateInfoBackground();
	}
	
	function updateInfoBackground(){
		//_root.test+="updateInfoBackground()zz\n"
		this.content.clear();

		var m = 6+mLeft

		var p = {
			x:th+m,
			y:0,
			w:this.width-(th+m+2),
			h:th
		};
		
		var bg = _global.colorSet.pink;
		if(this.info.gender == "M") bg = _global.colorSet.green;

		
		var inf = {
			inline:2,
			outline:2,
			curve:4,
			color:{
				main:		bg.main,
				inline:		bg.shade,
				outline:	this.win.style.global.color[0].shade
			}	
		}
		
		FEMC.drawCustomSquare(this.content,p,inf,true)
		/*
		_root.test+="-"+this.content+"\n"
		_root.test+="-"+p+"\n"
		_root.test+="-"+inf+"\n"
		_root.test+="-"+FEMC.drawCustomSquare+"\n"
		*/
	}
	
	function updateStatus(){
		var o = info.status
		var mc = this.content.status
		if( o == undefined){
			mc.gotoAndStop(1);
		}else{
			//this.fbouille = o.fbouille;
			
			if(info.presence == 0){
				
				mc.gotoAndStop("presence");
				mc.ico.gotoAndStop(info.presence + 1);

				
			}else if(o.internal != undefined){
				mc.gotoAndStop("internal");
				mc.ico.gotoAndStop(o.internal);
			}else if(o.external != undefined){
				mc.gotoAndStop("external");
				mc.ico.gotoAndStop(o.external);			
			}else{

				mc.gotoAndStop("presence");
				mc.ico.gotoAndStop(info.presence + 1);				

			}
		}	
	}

	function select(){
		_root.test+="_global.frutizInfMng.open("+_global.frutizInfMng.open+")\n"
		_root.test+="info.nickname"+info.nickname+")\n"
		_global.frutizInfMng.open(info.nickname)
	}
	
//{
}

