/********************************
 *	KALUGA 2 - INTRO	*
 ********************************/
 
 
 function init(){
	 
		
		 
	 attachMovie("che","che",100);
	 
	 scene=1;
	 
	 interval=2;
	 vit=interval;
// 	 che.gotoAndPlay("run");
	 
	 compt=0;
	 stand=true;

	
// 	 treeList = new Array(); 
// 	 treeMax=10;
	 	 
	 vit2=5;
	 
	 change=true;
	 
// 	 genTree();
// 	 attachMovie("mask","mask",10);
	 
}
	 
	 
	 
	 
 function main(){
	 
	 
	 Std.update();
	tmod=Std.tmod;
// 	 trace(scene);
	 
// 	 mask._alpha-=1.5;
	 
// 	 if(mask._alpha<=2){
// 		mask.removeMovieClip();		 
// 	}
	
	
	
	 
	 if(scene==3){
		interval=0;
		 
		all.sub.che.gotoAndPlay("speed");
		scene=0;
		all.sub.che.o.gotoAndStop(2);
	 }
	 
	  if(scene==6){
		interval=0;

		all.sub.che.gotoAndPlay("run");
		scene=0;
		all.sub.che.o.gotoAndStop(2);
	 }
	 
	 if(scene==8){
		interval=0;
		 vitFor=0;

		all.sub.grassEmpty.gotoAndStop(5);
		
		all.sub.forestEmpty.gotoAndStop(5);
		all.sub.che.gotoAndPlay("fast");
		scene=0;
		all.sub.che.o.gotoAndStop(2);
	 }
	 
	 if(scene==10){
		interval=0;
		 vitFor=0;

		all.sub.grassEmpty.gotoAndStop(5);
		
		all.sub.forestEmpty.gotoAndStop(5);
		all.sub.che.gotoAndPlay("faster");
		scene=0;
		all.sub.che.o.gotoAndStop(2);
	 }
	 
	 
	  if(scene==12){
		interval=0;
		 vitFor=0;

		all.sub.grassEmpty.gotoAndPlay(1);
		
		all.sub.forestEmpty.gotoAndPlay(1);
		all.sub.che.gotoAndPlay("fil");
		scene=0;
		all.sub.che.o.gotoAndStop(2);
	 }
	 
	 compt++;
	 
		 
	 vit--;
	 
	 

	 if(vit<=0){	 
		 all.sub.che.nextFrame(); 
		 vit=interval;
	 }
	 
	 if(compt>=200 && stand==true && all.sub.che._currentframe==1){
		interval=4;
		 all.sub.che.gotoAndPlay("stand");
		 stand=false;
	}
	 
	 all.sub.forest1._x-=vitFor;

	 all.sub.grass1._x-=vitFor*1.5;
	 all.sub.grass2._x-=vitFor*1.5;
	 
	
	
	//boucle grass	
	 if(all.sub.grass1._x<=0 && all.sub.grass1._x>all.sub.grass2._x){
		 all.sub.grass2._x=all.sub.grass1._x+1535;
	}
	
	if(all.sub.grass2._x<=0 && all.sub.grass1._x<all.sub.grass2._x){
		 all.sub.grass1._x=all.sub.grass2._x+1535;
	}
	 

	 
	 
}


	
