#include "../../ext/inc/deep/debug.as"
#include "inc/main.as"

var BOOK_X = 10 ;
var BOOK_Y = 30 ;
var PAGE_WIDTH = 297 ;
var PAGE_HEIGHT = 443 ;
var BOOK_WIDTH = PAGE_WIDTH*2 ;
var BOOK_HEIGHT = PAGE_HEIGHT ;
var LINE_LENGTH = 1000 ;

var FLIP_SPEED = 1 ;
var FRICTION = 0.95 ;

var AUTOFALL_LIMIT = 20 ;

var LEFT = 0 ;
var RIGHT = 1 ;


/*------------------------------------------------------------------------
    MET À JOUR LE MASQUE DE FLIP PAGE
 ------------------------------------------------------------------------*/
function update() {

  // Masque de page
  var ratio = leftPage._rotation/90 ;
  var angRad = Math.PI/180 * (ratio*45) ;
  var dx = LINE_LENGTH * Math.sin(angRad) ;
  var dy = LINE_LENGTH * Math.cos(angRad) ;

  leftMask.clear() ;
  leftMask.lineStyle() ;
  leftMask.beginFill(0xff0000,100) ;
  leftMask.moveTo( BOOK_X, BOOK_Y-BOOK_HEIGHT*0.5 ) ;
  leftMask.lineTo( BOOK_X, BOOK_Y+BOOK_HEIGHT ) ;
  leftMask.lineTo( BOOK_X+PAGE_WIDTH, BOOK_Y+BOOK_HEIGHT + PAGE_WIDTH ) ;
  leftMask.lineTo( BOOK_X+PAGE_WIDTH+dx, BOOK_Y+BOOK_HEIGHT + PAGE_WIDTH-dy ) ;
  leftMask.endFill() ;

  rightMask.clear() ;
  rightMask.lineStyle() ;
  rightMask.beginFill(0xff0000,100) ;
  rightMask.moveTo( BOOK_X, BOOK_Y-BOOK_HEIGHT*0.5 ) ;
  rightMask.lineTo( BOOK_X, BOOK_Y+BOOK_HEIGHT ) ;
  rightMask.lineTo( BOOK_X+PAGE_WIDTH, BOOK_Y+BOOK_HEIGHT + PAGE_WIDTH ) ;
  rightMask.lineTo( BOOK_X+PAGE_WIDTH+dx, BOOK_Y+BOOK_HEIGHT + PAGE_WIDTH-dy ) ;
  rightMask.endFill() ;

  leftPage.setMask(leftMask) ;
  rightPage.setMask(rightMask) ;

  // Ombre de la page
  leftPage.grad._alpha = ratio * 100 ;

  // Ombre portée sous le coin
  dropCorner._rotation = 45 * ratio ;
  dropCorner._alpha = ratio * 85 ;

  // Ombre portée sous la page large
  dropLarge._rotation = 45 * ratio ;
  if ( currentPage>=2 )
    dropLarge._alpha = (1-ratio*1.5) * 90 ;
  else
    dropLarge._alpha = 0 ;

}


/*------------------------------------------------------------------------
    MISE À JOUR DU CONTENU D'UNE PAGE
 ------------------------------------------------------------------------*/
function updateTemplate(mc, id, side) {
  var total = fruitList[id] ;
  var title = "Fruit "+id ;
  var value = id*id*5 ;

  mc.title.text = title ;
  mc.value.text = value ;

  // Skin
  if ( total == undefined ) {
    mc.skin._visible = false ;
    mc.hiddenSkin._visible = true ;
  }
  else {
    mc.skin._visible = true ;
    mc.hiddenSkin._visible = false ;
  }
  mc.skin.gotoAndStop(id+1) ;
  mc.hiddenSkin.gotoAndStop(id+1) ;


  // Pagination
  if ( side==LEFT ) {
    mc.pageLeft.text = id+1 ;
    mc.pageRight.text = "" ;
  }
  else {
    mc.pageLeft.text = "" ;
    mc.pageRight.text = id+1 ;
  }

  // Compte
  if ( total==undefined )
    mc.count.text = "Aucun" ;
  else
    mc.count.text = total ;
}


/*------------------------------------------------------------------------
    RETOUR
 ------------------------------------------------------------------------*/
function previousPage() {
  currentPage -= 2 ;
  updatePages() ;
}


/*------------------------------------------------------------------------
    SUIVANTE
 ------------------------------------------------------------------------*/
function nextPage() {
  currentPage+=2 ;
  updatePages() ;
}


/*------------------------------------------------------------------------

 ------------------------------------------------------------------------*/
function updatePages() {
  // Couverture
  if ( currentPage==0 ) {
    book.hole._visible = true ;
  }
  else {
    book.hole._visible = false ;
  }

  updateTemplate(book.left, currentPage-2, LEFT) ;
  updateTemplate(book.right, currentPage+1, RIGHT) ;
  updateTemplate(leftPage.tpl, currentPage, LEFT) ;
  if ( currentPage>0 ) {
    rightPage.gotoAndStop(2) ;
    updateTemplate(rightPage.tpl, currentPage-1, RIGHT) ;
  }
  else
    rightPage.gotoAndStop(3) ;
}


/*------------------------------------------------------------------------
    ARRONDI À 2 CHIFFRES (fonction de debug)
 ------------------------------------------------------------------------*/
function rnd(n) {
  return Math.round(n*1000)/1000 ;
}


