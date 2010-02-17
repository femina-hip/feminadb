// tooltip widget
function toggleTooltip(event, element) { 
  var __x = Event.pointerX(event);
  var __y = Event.pointerY(event);
  element.setStyle({top: (__y + 5) + 'px', left: (__x - 40) + 'px'});
  //alert(__x+","+__y);
  //element.style.top = __y + 5;  
  //element.style.left = __x - 40;
  element.toggle();
}
