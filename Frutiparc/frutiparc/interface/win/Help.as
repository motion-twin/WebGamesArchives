class win.Help extends win.Dialog{//}
	
	var flUserList:Boolean;
	var flScreenList:Boolean;
	var leftIconList:Array;
	var mcLeftIconList:MovieClip;
	var lefIconListHMaxThin:Number;
	var lefIconListHMaxLarge:Number;
	var nbUser:Number;
	

	/*-----------------------------------------------------------------------
		Function: Chat()
		Constructeur
	 ------------------------------------------------------------------------*/		
	function Help(){
		this.init();
	}
	
	/*-----------------------------------------------------------------------
		Function: init()
	 ------------------------------------------------------------------------*/	
	function init(){
		//clearInterval(_global.IntervalALaCon)	//DEBUG
		//this.iconLabel="chat"			//DEBUG

		this.flUserList = false;
		this.flScreenList = false;	
		
		super.init();

		// A virer
		this.nbUser = 2
		
		this.genLeftIconList()
		this.displayLeftIconList();
		this.endInit()	
	}

	/*-----------------------------------------------------------------------
		Function: genLeftIconList()
	 ------------------------------------------------------------------------*/	
	function genLeftIconList(){
		this.leftIconList = [
			{link:"butPush", param:{
					link:"butPushSmallPink",
					frame:2,
					outline:2,
					curve:4,
					buttonAction:{ 
						onPress:[{
							obj:this,
							method:"toggleUserList"
						}]
					}
				}
			},
			{link:"butPush", param:{
					link:"butPushSmallPink",
					frame:3,
					outline:2,
					curve:4,
					buttonAction:{ 
						onPress:[{
							obj:this,
							method:"toggleScreenList"
						}]
					}
				}
			}
		];
			
		this.lefIconListHMaxThin =  4 + 26*this.leftIconList.length
		this.lefIconListHMaxLarge = 4 + 26*Math.ceil(this.leftIconList.length/3)
			
	}

	/*-----------------------------------------------------------------------
		Function: displayLeftIconList()
	 ------------------------------------------------------------------------*/
	function displayLeftIconList(){
		
		var struct = Standard.getStruct();
		struct.limit="x";
		struct.x.size = 24;
		struct.y.size = 24;
		struct.x.space = 2;
		struct.y.space = 2;
		struct.x.margin = 2;
		struct.y.margin = 2;
		struct.x.align = "center";
		
		var args = {
			list:leftIconList,
			struct:struct,
			flMask:true,
			mask:{flScrollable:false}
			//flTrace:true
		};
		
		var frame = {
			name:"leftIconListFrame",
			link:"basicIconList",
			type:"compo",
			min:{w:32,h:0},
			args:args
		}
		
		this.mcLeftIconList = this.margin.left.newElement( frame )
		this.margin.left.bigFrame = this.margin.left.leftIconListFrame;
	}

	/*-----------------------------------------------------------------------
		Function: toggleUserList()
	 ------------------------------------------------------------------------*/
	function toggleUserList(){
		if(!this.flUserList){
			this.displayUserList();
		}else{
			this.margin.right.removeElement("userListFrame")
		}
		this.frameSet.update();
		this.flUserList=!this.flUserList;
	}
	
	/*-----------------------------------------------------------------------
		Function: displayUserList()
	 ------------------------------------------------------------------------*/	
	function displayUserList(){
		var m = Standard.getMargin();
		m.x.min = 12;
		var frame = {
			type:"compo",
			name:"userListFrame",
			link:"cpUserList",
			margin:m
		};
		this.margin.right.newElement(frame);
		this.margin.right.bigFrame = margin.right.userListFrame;	
	}
	
	/*-----------------------------------------------------------------------
		Function: toggleScreenList()
	 ------------------------------------------------------------------------*/
	function toggleScreenList(){
		if(!this.flScreenList){
			this.displayScreenList();
			this.mcLeftIconList.min.h = this.lefIconListHMaxLarge
		}else{
			this.margin.left.removeElement("screenList")
			this.mcLeftIconList.min.h = this.lefIconListHMaxThin
		}
		
		//_root.test += "this.frLeftIconList.path.min.h  ----> "+this.frLeftIconList.path.min.h+"\n"
		
		this.frameSet.update();
		this.flScreenList=!this.flScreenList;
	}
	
	/*-----------------------------------------------------------------------
		Function: displayScreenList()
	 ------------------------------------------------------------------------*/	
	function displayScreenList(){
		var m = Standard.getMargin();
		m.x.min = 12;
		var frame = {
			type:"compo",
			name:"screenList",
			link:"cpScreenList",
			min:{w:100,h:200},
			win:this,
			margin:m
		};
		this.margin.left.newElement(frame,0);
		this.margin.left.bigFrame = this.margin.left.screenList;	
	}
	
	/*-----------------------------------------------------------------------
		Function: initMainField()
		
		Overload super initMainField
	 ------------------------------------------------------------------------*/	
	function initMainField(){
		// initialise la frame show
		var margin = Standard.getMargin();
		this.main.newElement({ name:"showFrame", type:"h", min:{w:200,h:200}, flBackground:true, margin:margin})
		this.main.bigFrame = this.main.showFrame;

	
		var frame = {
			name:"fieldFrame",
			link:"cpDocument",
			type:"compo",
			min:{w:200,h:200},
			mainStyleName:"frSheet",
			args:{
				flMask:true,
				flBackground:true
			}
			
		}
		this.mainField = this.main.showFrame.newElement(frame);
		this.main.showFrame.bigFrame = this.main.showFrame.fieldFrame;
	};

	
	/*-----------------------------------------------------------------------
		Function: displayContent(obj)
		
		obj: {
			id: Number
			title: String
			content: String
			links: {
				<link_type>: [
					{i: Number,n: String},
					...
				],
				...
			},
			back: Boolean
		}
	 ------------------------------------------------------------------------*/	
	function displayContent(obj){
		var pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[]
		}
		
		// First line: fname
		pageObj.lineList.push(
			{	
				list:[
					{	type:"text",
						big: 1,
						param:{
							sid: 4,
							text: obj.title
						}
					}
				]
			}
		);
		
		// Second line: content
		pageObj.lineList.push(
			{	
				list:[
					{	type:"text",
						big: 1,
						param:{
							win: this,
							text: obj.content,
							fieldProperty: {html: true,styleSheet: Standard.getStyleSheet()}
						}
					}
				]
			}
		);

		// Links
		for(var t in obj.links){
			var arr = obj.links[t];
			if(arr.length == 0) continue;
			
			// Link type title
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							big: 1,
							param:{
								sid: 2,
								text: Lang.fv("help.link_type."+t)
							}
						}
					]
				}
			);
			
			// Link list
			for(var a=0;a<arr.length;a++){
				pageObj.lineList.push(
					{	
						list:[
							{	type:"text",
								big: 1,
								param:{
									win: this,
									text: Lang.fv("help.link",arr[a]),
									fieldProperty: {html: true,styleSheet: Standard.getStyleSheet()}
								}
							}
						]
					}
				);
			}
		}
		
		// Add go back link
		if(obj.back){
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							big: 1,
							param:{
								win: this,
								sid: 2,
								text: Lang.fv("help.link_back"),
								fieldProperty: {html: true,styleSheet: Standard.getStyleSheet()}
							}
						}
					]
				}
			);
		}

		this.mainField.detachPage();
		this.mainField.pageObj = pageObj;
		this.mainField.attachPage();
	
		this.main.update();
	}
	
	function displayWait(){
		var pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[]
		}
		
		// First line: please_wait
		pageObj.lineList.push(
			{	
				list:[
					{	type:"text",
						big: 1,
						param:{
							sid: 2,
							text: Lang.fv("please_wait")
						}
					}
				]
			}
		);
	
		this.mainField.detachPage();
		this.mainField.pageObj = pageObj;
		this.mainField.attachPage();
	
		this.main.update();
	}
	
	function displayResult(obj){
		var pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[]
		}
		
		// First line: number of results
		pageObj.lineList.push({	
			list:[
				{	type:"text",
					big: 1,
					param:{
						sid: 2,
						text: Lang.fv((obj.method=="e")?"help.results_exact":"help.results_similar",{n: obj.nb})
					}
				}
			]
		});
		
		// Results
		for(var i=0;i<obj.list.length;i++){
			//_global.debug("Result: "+obj.list[i].n+" ["+obj.list[i].i+"]");
			pageObj.lineList.push(
				{	
					list:[
						{	type:"text",
							big: 1,
							param:{
								win: this,
								text: Lang.fv("help.link",obj.list[i]),
								fieldProperty: {html: true,styleSheet: Standard.getStyleSheet()}
							}
						}
					]
				}
			);
		}
		
		pageObj.lineList.push(
			{	
				list:[
					{	type:"text",
						big: 1,
						param:{
							win: this,
							sid: 2,
							text: Lang.fv("help.link_back"),
							fieldProperty: {html: true,styleSheet: Standard.getStyleSheet()}
						}
					}
				]
			}
		);
	
		this.mainField.detachPage();
		this.mainField.pageObj = pageObj;
		this.mainField.attachPage();
	
		this.main.update();
	}
	
	function displayNoResult(){
		var pageObj = {
			pos:{x:0,y:0,w:0,h:0},
			lineList:[]
		}
		
		// First line: no_result
		pageObj.lineList.push(
			{	
				list:[
					{	type:"text",
						big: 1,
						param:{
							sid: 2,
							text: Lang.fv("help.no_result")
						}
					}
				]
			}
		);
		
		// Second line: contact_me
		pageObj.lineList.push(
			{	
				list:[
					{	type:"text",
						big: 1,
						param:{
							win: this,
							text: Lang.fv("help.contact_me"),
							fieldProperty: {html: true,styleSheet: Standard.getStyleSheet()}
						}
					}
				]
			}
		);
		
		// And then, the goBack link
		pageObj.lineList.push(
			{	
				list:[
					{	type:"text",
						big: 1,
						param:{
							win: this,
							sid: 2,
							text: Lang.fv("help.link_back"),
							fieldProperty: {html: true,styleSheet: Standard.getStyleSheet()}
						}
					}
				]
			}
		);
	
		this.mainField.detachPage();
		this.mainField.pageObj = pageObj;
		this.mainField.attachPage();
	
		this.main.update();
	}
	
//{
}


