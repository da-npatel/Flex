package com.digitalaisle.frontend.components {
	
	import com.digitalaisle.frontend.enums.ActionType;
	import com.digitalaisle.frontend.events.DAValueSliderEvent;
	import com.digitalaisle.frontend.events.UserTouchEvent;
	import com.digitalaisle.frontend.utils.LoadQueue;
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.events.ResizeEvent;
	import mx.styles.CSSStyleDeclaration;
	
	import spark.components.BorderContainer;
	import spark.components.Group;
	import spark.components.Label;
	import spark.core.SpriteVisualElement;
	
	[Style(name="handleImageBitmap", type="flash.display.Bitmap", inherit="no")]
	[Style(name="sliderImageBitmap", type="flash.display.Bitmap", inherit="no")]

	public class DAValueSlider extends Group {
		
		// External Parameters
		private var _data:ArrayCollection;								// Data source for component values		
		private var _backgroundImage:String = "";						// Background image source (optional)
		private var _sliderBarImage:String = "";						// Slider bar image source (optional)
		private var _handleImage:String = "";							// Handle image source (optional)
		private var _labelImage:String = "";							// Primary label background image source (optional)		
		private var _stretchSliderBarImage:Boolean = true;					// Toggle to horizontally strech slider bar image		
		private var _sliderWidth:int = 700;								// Total slider component width
		private var _sliderHeight:int = 100;							// Total slider component height
		private var _sliderLabelStyleName:String = "";					// CSS style name for primary label		
		private var _sliderValueLabelStyleName:String = "";				// CSS style name for value labels
		private var _sliderValueLabelWidth:int = 300;
		private var _showValueLabels:Boolean = true;					// Value label visibility toggle
		private var _selectedValue:String = "";							// Programmatic value of currently selected label
		private var _selectedLabel:String = "";							// Display value of currently selected label
		private var _selectedIndex:int = -1;							// Index of currently selected label
		private var _showSelectedLabel:Boolean;							// Flags if the selected label is displayed in realtime using the slider's main label		
		private var _showSelectedValue:Boolean;							// Flags if the selected value is displayed in realtime using the slider's main label
		private var _padding:int = 15;									// Padding around and between slider elements		
		private var _continuous:Boolean;								// Slider will operate continuously between labels rather than snapping to the nearest
		private var _showTicks:Boolean;									// Flags if tick marks ( ' ) will be shown on values that have empty text labels
		private var _dragging:Boolean;									// Flag if user is currently dragging slider handle
		private var _ignoreFirstValue:Boolean;							// Flag if the first value in the slider should not be accepted as a selection
		private var _showVectorArt:Boolean = true;						// Flag if default slider styles should be programmatically drawn if no skin images are available
		private var _handleYOffset:int = 0;
		private var _handleXOffset:int = 0;
		private var _labelXOffset:int = 0;
		private var _legendStyleName:String = "";				// CSS style name for value labels
		private var _legendWidth:int = 700;
		private var _showLegend:Boolean = false;						// Flag to indicate if a Legend should be shown
		
		// Internal Parameters and Build Elements
		private var lq:LoadQueue;										// External assets LoadQueue
		private var hitarea:SpriteVisualElement;						// Designated area for user clicks
		private var imgslider:SpriteVisualElement;						// Slider image
		private var imghandle:SpriteVisualElement;						// Handle image
		private var imgbg:SpriteVisualElement;							// Background image		
		private var valuelabels:Array;									// Pointers to all value labels
		private var legendlabels:Array;									// Pointers to all legend labels
		private var ticks:Array;										// Array of mathematical locations for each value
		private var legend:BorderContainer;
		private var lbls:BorderContainer;
		private var defaultLabelStyle:CSSStyleDeclaration;
		private var defaultValueLabelStyle:CSSStyleDeclaration;
		private var defaultLegendStyle:CSSStyleDeclaration;
		private var sliderImageWidth:int;								// Derived width of slider bar from total slider width and primary label width
		private var setDefault:Boolean;									// Flag if valueSlider is passed a default inline value		
		private var distance:int;										// Distance between the first and last value label positions
		private var range:int;											// Range between the first and last value label values
		private var _valueLabelGap:int = -1;							// Vertical gap between value labels and the slider bar
		private var _valueLegendGap:int = 15;							// Vertical gap between the legend and the slider bar
		private var _loaded:Boolean;									// Prevents assets from being reloaded
		private var _initialData:Boolean = true;						// Flag if data source has not yet been set
		private var _updateDisplay:Boolean;								// Flag if displaylist has been initially refreshed
		private var _engaged:Boolean;									// Flag if user has used slider at least once
		
		public function DAValueSlider()	{
			super();			
			defaultLabelStyle = new CSSStyleDeclaration("tickertext");
			defaultLabelStyle.setStyle("fontFamily", "MyriadProBoldCFF");
			defaultLabelStyle.setStyle("fontWeight", "bold");
			defaultLabelStyle.setStyle("fontSize", 20);
			defaultLabelStyle.setStyle("lineHeight", 20);
			defaultLabelStyle.setStyle("color", 0x333333);
			defaultLabelStyle.setStyle("textAlign", "right");
			
			defaultValueLabelStyle = new CSSStyleDeclaration("tickertext");
			defaultValueLabelStyle.setStyle("fontFamily", "MyriadProCFF");
			defaultValueLabelStyle.setStyle("fontSize", 16);
			defaultValueLabelStyle.setStyle("lineHeight", 20);
			defaultValueLabelStyle.setStyle("color", 0x333333);
			defaultValueLabelStyle.setStyle("textAlign", "center");			
			
			defaultLegendStyle = new CSSStyleDeclaration("tickertext");
			defaultLegendStyle.setStyle("fontFamily", "MyriadProCFF");
			defaultLegendStyle.setStyle("fontSize", 16);
			defaultLegendStyle.setStyle("lineHeight", 20);
			defaultLegendStyle.setStyle("color", 0x333333);
			defaultLegendStyle.setStyle("textAlign", "center");
			
			lbls = new BorderContainer();
			lbls.setStyle("backgroundAlpha", "0");
			lbls.setStyle("borderVisible", false);
			
			legend = new BorderContainer();
			legend.setStyle("backgroundAlpha", "0");
			legend.setStyle("borderVisible", false);
			
			hitarea = new SpriteVisualElement();			
			imgslider = new SpriteVisualElement();
			imghandle = new SpriteVisualElement();	
			imghandle.useHandCursor = true;
			imgbg = new SpriteVisualElement();
			valuelabels = new Array();
			legendlabels = new Array();
			ticks = new Array();
			
			if(_valueLabelGap < 0){
				_valueLabelGap = _padding;
			}			
		}
		
		override protected function createChildren():void {
			super.createChildren();
					
			addElement(imgbg);			
			addElement(imgslider);
			addElement(lbls);
			if (_showLegend) {
				addElement(legend);
			}
			addElement(hitarea);
			addElement(imghandle);
		}
						
		protected function loadAssets():void {			
			lq = new LoadQueue();			
			lq.add(_labelImage);
			lq.add(_sliderBarImage);
			lq.add(_handleImage);
			lq.addEventListener("assetsloaded", buildSlider, false, 0, true);
			lq.addEventListener("emptyqueue", drawSlider, false, 0, true);
			lq.load();
		}
		
		private function buildSlider(e:Event):void {
			lq.removeEventListener("assetsloaded", buildSlider);	
			lq.removeEventListener("emptyqueue", drawSlider);
			
			
			
			//addBitmap(imgbg, _backgroundImage, );
			addBitmap(imgslider, _sliderBarImage, "sliderImageBitmap");			
			addBitmap(imghandle, _handleImage, "handleImageBitmap");
			
			resize();
						
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
		}
		
		private function drawSlider(e:Event):void {
			if(_showVectorArt){
				lq.removeEventListener("assetsloaded", buildSlider);
				lq.removeEventListener("emptyqueue", drawSlider);
				invalidateProperties();
				invalidateSize();
				invalidateDisplayList();
			}
		}
			
		override protected function commitProperties():void	{
			super.commitProperties();			
			if(width > 0){
				_sliderWidth = width;
			}
			if(height > 0){
				_sliderHeight = height;
			}
			
			if(_data == null){								
				return;
			}			
			invalidateDisplayList();
		}
		
		override protected function measure():void {
			super.measure();			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void	{			
			super.updateDisplayList(unscaledWidth, unscaledHeight);			
			if(_data == null || !_updateDisplay){
				return;
			}			
			
			if(getStyle("handleImageBitmap"))
			{
				if(getStyle("handleImageBitmap") is Class)
					imghandle.addChild(createButtonStateBitmap(getStyle("handleImageBitmap")));
				else if(getStyle("handleImageBitmap") is Bitmap)
					imghandle.addChild((getStyle("handleImageBitmap") as Bitmap));
			}
			
			if(getStyle("sliderImageBitmap"))
			{
				if(getStyle("sliderImageBitmap") is Class)
					imgslider.addChild(createButtonStateBitmap(getStyle("sliderImageBitmap")));
				else if(getStyle("sliderImageBitmap") is Bitmap)
					imgslider.addChild((getStyle("sliderImageBitmap") as Bitmap));
			}
				
			_updateDisplay = false; // Prevent recursive calls unless new _data is passed
					
			resize();
			
			// Remove any previous value labels
			if(lbls.numElements > 0){ 
				var max:int = lbls.numElements;
				var lbl:Label;
				for(var j:int=0; j<max; j++){
					lbl = lbls.getElementAt(j) as Label;					
					lbl.styleName = null;
					if(j == max - 1){
						lbl.removeEventListener(ResizeEvent.RESIZE, resizeValueLabel);
					}
				}				
				lbls.removeAllElements();
				valuelabels = new Array();	
				ticks = new Array();
			}
			
			// Remove any previous legend
			if(legend.numElements > 0){ 
				var max:int = legend.numElements;
				var lbl:Label;
				for(var j:int=0; j<max; j++){
					lbl = legend.getElementAt(j) as Label;					
					lbl.styleName = null;
					if(j == max - 1){
						lbl.removeEventListener(ResizeEvent.RESIZE, resizeLegendLabel);
					}
				}				
				legend.removeAllElements();
				legendlabels = new Array();					
			}
			
			// Build value labels
			var vl:Label;
			var useDefaultStyle:Boolean;
			if(_sliderValueLabelStyleName == ""){
				FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration(".slidervaluelabel", defaultValueLabelStyle, true);
				useDefaultStyle = true;
			}
			
			lbls.y = imgslider.y + imgslider.height + _valueLabelGap;
			
			for(var i:int=0; i<_data.length; i++){
				vl = new Label();
				vl.name = "vl"+i;
				vl.mouseEnabled = false;
				vl.styleName = useDefaultStyle ? "slidervaluelabel" : _sliderValueLabelStyleName;				 
				vl.maxWidth = _sliderValueLabelWidth;
				vl.maintainProjectionCenter = true;				
				if(_data[i].text.length > 0){
					vl.text = _data[i].text;
				} else if(_showTicks) {
					vl.text = "|";
				}
				
				if(i == _data.length - 1){
					vl.addEventListener(ResizeEvent.RESIZE, resizeValueLabel, false, 0, true);
				}					
			
				valuelabels.push(vl);
				if(_showValueLabels){
					lbls.addElement(vl);
				}
			}			
			
			if (_showLegend) {
				// Build the legend
				var ll:Label;				
			
				if(_legendStyleName == ""){
					FlexGlobals.topLevelApplication.styleManager.setStyleDeclaration(".sliderlegend", defaultLegendStyle, true);					
				}
				
				legend.x = (width - _legendWidth) / 2;
				legend.y = imgslider.y + imgslider.height + _valueLegendGap;
				
				for(var i:int=0; i<_data.length; i++){
					ll = new Label();
					ll.name = "ll"+i;
					ll.mouseEnabled = false;
					ll.styleName = _legendStyleName == "" ? "sliderlegend" : _legendStyleName;				 
					ll.maxWidth = _legendWidth;
					ll.maintainProjectionCenter = true;
					ll.maxDisplayedLines = 2;
					if(_data[i].legend.length > 0){
						ll.text = _data[i].legend;
					} 
					
					if(i == _data.length - 1){
						ll.addEventListener(ResizeEvent.RESIZE, resizeLegendLabel, false, 0, true);
					}					
					
					legendlabels.push(ll);
					legend.addElement(ll);					
				}
			}
			//enable();
		}
		
		private function resize():void {
			
			// Position the slider image
			imgslider.x = 0; 			
			imgslider.y = _sliderHeight/2 - imgslider.height/2;
			hitarea.y = imgslider.y;
			
			if(_stretchSliderBarImage){				
				sliderImageWidth = _sliderWidth - _padding*2;				
				imgslider.width = _sliderWidth;
				if(imgslider.numChildren > 0){
					imgslider.getChildAt(0).width = _sliderWidth;					
				}
			}
			
			// Position the handle image
			if(!_engaged){				
				imghandle.x = _handleXOffset; // -imghandle.width/2;
			}			
			imghandle.y = (_sliderHeight/2 - imghandle.height/2)  + handleYOffset ;	
			
			var m:Matrix;
			var m2:Matrix;
			if(imgslider.numChildren == 0){
				imgslider.height = 25;
				imgslider.graphics.clear();
				if(_showVectorArt){
					imgslider.graphics.lineStyle(1,0xaaaaaa,1,true);				
					m = new Matrix();				
					m.createGradientBox(imgslider.width, imgslider.height, (90*Math.PI/180));				
					imgslider.graphics.beginGradientFill(GradientType.LINEAR, [0xf2f2f2,0xdddddd], [1,1], [50,200], m); 
					imgslider.graphics.drawRect(0, 0, imgslider.width, 22);
					imgslider.graphics.endFill();
				}
			}else{
				imgslider.graphics.clear();
			}
			if(imghandle.numChildren == 0){
				imghandle.width = 30;
				imghandle.height = 45;
				imghandle.graphics.clear();
				if(_showVectorArt){
					imghandle.graphics.lineStyle(1,0xaaaaaa,1,true);				
					m2 = new Matrix();
					m2.createGradientBox(imghandle.width, imghandle.height);
					imghandle.graphics.beginGradientFill(GradientType.LINEAR, [0xf2f2f2, 0xdddddd], [1,1], [50,200], m);
					imghandle.graphics.drawRect(0, 0, 30, 45);
					imghandle.graphics.endFill();
				}
			}else{
				imghandle.graphics.clear();
			}	
			with(hitarea.graphics){
				clear();
				beginFill(0xff00ff, 0);				
				drawRect(0, 0, imgslider.width, _sliderHeight);
				endFill();
			}
		} 
		
		private function resizeValueLabel(e:ResizeEvent):void {
			e.target.removeEventListener(ResizeEvent.RESIZE, resizeValueLabel);
			var lbldist:int;
			var startlbls:Number;
			var endlbls:Number;
			var lbl:Label;
			
			ticks = new Array(lbls.numElements);
			
			// Position first and last labels to determine visual alignments
			lbl = lbls.getElementAt(0) as Label;
			lbl.x = imgslider.x + _labelXOffset;			
			ticks[0] = lbl.x + lbl.width/2;
			//trace("ticks[0] is "+ticks[0]);
			startlbls = lbl.x;
			lbl = lbls.getElementAt(lbls.numElements - 1) as Label;
			lbl.x = imgslider.x + imgslider.width - lbl.width + _labelXOffset;
			ticks[ticks.length-1] = lbl.x + lbl.width/2;
			endlbls = lbl.x;
			
			lbldist = endlbls - startlbls;
			distance = ticks[ticks.length - 1] - ticks[0]; // Save horizontal distance between first and last labels
			
			// Calculate value range of slider
			//trace(this.name+" ignoreFirstValue? "+_ignoreFirstValue);
			if(_ignoreFirstValue){
				range = _data[_data.length - 1].value - _data[1].value;
			} else {
				range = _data[_data.length - 1].value - _data[0].value; 
			}
			
			for(var i:int=1; i<lbls.numElements-1; i++){ // Position remaining labels
				if(lbls.getElementAt(i) is Label){
					lbl = lbls.getElementAt(i) as Label;
					lbl.x = imgslider.x + lbldist/(lbls.numElements - 1) * i + _labelXOffset;
					ticks[i] = lbl.x + lbl.width/2;
				}				
			}	
			enable();
		}
		
		private function resizeLegendLabel(e:ResizeEvent):void {
			e.target.removeEventListener(ResizeEvent.RESIZE, resizeLegendLabel);			
			var lbl:Label;			
			var prevLblY:Number;
			var prevLblHeight:Number;
			
			lbl = legend.getElementAt(0) as Label;
			lbl.x = 0;
			prevLblY = lbl.y = imgslider.y + imgslider.height + _valueLegendGap;
			prevLblHeight = lbl.height;
			
			for(var i:int=1; i<legend.numElements; i++){ 
				if(legend.getElementAt(i) is Label){
					lbl = legend.getElementAt(i) as Label;
					lbl.x = 0;
					prevLblY = lbl.y = prevLblY + prevLblHeight + _padding;
					prevLblHeight = lbl.height;
				}				
			}				
		}
		
		private function addBitmap(target:*, asset:String, stlyName:String):void {			
			try {
				var bmp:Bitmap = new Bitmap(Bitmap(lq.getAssetByURL(asset)).bitmapData, "auto", true);
				setStyle("stlyName", bmp);
				target.width = bmp.width;
				target.height = bmp.height;
				if(target.numChildren > 0){
					for(var i:int=0; i<target.numChildren; i++){
						target.removeChildAt(0);
					}					
				}
				target.graphics.clear();
				target.addChild(bmp);
			} catch (e:Error) {						
				return;
			}			
		}
						
		private function enable():void {			
			if(setDefault){				
				setDefault = false;
				if(continuous){					
					if(_selectedValue != ""){
						calculatePosition();
					}
				} else { // Regular mode (locks to value labels)
					//trace("selectedindex "+_selectedIndex+" "+valuelabels.length+" "+ticks);
					if(_selectedIndex >= 0 && _selectedIndex <= valuelabels.length){						
						_selectedValue = _data[_selectedIndex].value;
						_selectedLabel = _data[_selectedIndex].text;							
						animateTo(ticks[_selectedIndex] + _handleXOffset, 0.001);
					} else if(_selectedValue != ""){
						for(var i:int=0; i<_data.length; i++){
							if(_selectedValue == _data[i].value){								
								animateTo(ticks[i] + _handleXOffset);
							}
						}
					}else {
						_selectedIndex = 0;
						_selectedValue = _data[0].value;
						_selectedLabel = _data[0].text;						
					}
				}
			}			
			
			imghandle.addEventListener(MouseEvent.MOUSE_DOWN, startHandleDrag, false, 0, true);			
			hitarea.addEventListener(MouseEvent.MOUSE_DOWN, onSliderClick, false, 0, true);
			//imgslider.addEventListener(MouseEvent.MOUSE_DOWN, onSliderClick, false, 0, true);			
		}	
		
		private function disable():void {
			imghandle.removeEventListener(MouseEvent.MOUSE_DOWN, startHandleDrag);
			imgslider.removeEventListener(MouseEvent.MOUSE_DOWN, onSliderClick);
		}
		
		private function startHandleDrag(e:MouseEvent):void {
			_engaged = true;
			addEventListener(Event.ENTER_FRAME, dragHandle, false, 0, true);
			try { stage.addEventListener(MouseEvent.MOUSE_UP, stopHandleDrag, true, 0, true); } catch(e:Error) { }
		}
		
		private function dragHandle(e:Event):void { 
			imghandle.x = mouseX - imghandle.width/2;
			_dragging = true;			
			
			if(imghandle.x + imghandle.width/2 < ticks[0]) {
				imghandle.x = ticks[0] - imghandle.width/2;				
			}
			if(imghandle.x + imghandle.width/2 > ticks[ticks.length - 1]){				
				imghandle.x = ticks[ticks.length - 1] - imghandle.width/2;
			}
			if(continuous){
				calculateValue();				
			} else {
				getNearestLocation();
			}			
		}
		
		private function stopHandleDrag(e:MouseEvent):void {
			removeEventListener(Event.ENTER_FRAME, dragHandle);			
			try { stage.removeEventListener(MouseEvent.MOUSE_UP, stopHandleDrag); } catch (e:Error) { }
			if(_dragging){
				_dragging = false;
				if(!continuous){
					animateTo(getNearestLocation());
					// This will need to be tailored if the user releases outside of the viewable area (point will not be useful data...consider passing getNearestLocation() result instead)
					dispatchEvent(new UserTouchEvent(UserTouchEvent.TOUCH, 0, ActionType.CLICK, localToGlobal(new Point(mouseX, mouseY))));
				}
			}
		}
		
		private function calculateValue():void { // TODO Improve efficiency of these calculations per cycle
			var loc:Number = (imghandle.x + imghandle.width/2) - ticks[0];
			var perc:Number = loc / distance;			
			var value:int;
			value = _ignoreFirstValue ? Number(_data[1].value) + perc * range : Number(_data[0].value) + perc * range;		
			_selectedValue = value.toString();
			//trace(_data[0].value+" perc "+perc+" range "+range+" distance "+distance+" loc "+loc+" value "+value);			
			dispatchEvent(new DAValueSliderEvent(DAValueSliderEvent.CHANGED));
		}
		
		private function calculatePosition():void { // Calculates the handle location based on _selectedValue (continuous mode only)
			var perc:Number = int(_selectedValue) / range;
			var pos:int = perc * distance;			
			imghandle.x = imgslider.x + pos - imghandle.width/2;
			//trace("calculatePosition: "+pos+" "+imghandle.x);			
			dispatchEvent(new DAValueSliderEvent(DAValueSliderEvent.CHANGED));
		}
		
		private function onSliderClick(e:MouseEvent):void  {
			_engaged = true;
			if(continuous){
				var mx:int = mouseX;				
				if(mx < ticks[0]){ mx = ticks[0]; }
				if(mx > ticks[ticks.length - 1]){ mx = ticks[ticks.length - 1]; }
				animateToPoint(mx);				
			} else {
				animateTo(getNearestLocation());
			}			
			dispatchEvent(new UserTouchEvent(UserTouchEvent.TOUCH, 0, ActionType.CLICK, localToGlobal(new Point(mx, mouseY))));
			dispatchEvent(new DAValueSliderEvent(DAValueSliderEvent.CHANGED));
		}
		
		private function getNearestLocation():int {
			var loc:int;			
			var nearest:int = int.MAX_VALUE;
			var curr:int;
			var num:int;
			
			for(var i:int=0; i<ticks.length; i++){
				curr = Math.abs(mouseX - ticks[i]);
				if(curr < nearest){					
					loc = ticks[i] + _handleXOffset;
					num = i;
					nearest = curr;
				}
			}
			if(!continuous){				
				_selectedIndex = num;
				_selectedLabel = _data[num].text;
				_selectedValue = _data[num].value;		
				
				dispatchEvent(new DAValueSliderEvent(DAValueSliderEvent.CHANGED));
			}
			return loc;
		}
		
		private function animateTo(loc:int, duration:Number=.35):void {
			var newx:int = loc;
			if(newx > _sliderWidth)
				newx = _sliderWidth;
			TweenLite.killTweensOf(imghandle);			
			TweenLite.to(imghandle, duration, {x:newx, ease:Linear.easeInOut(0,0,0,0)});			
		}
		
		private function animateToPoint(loc:int, duration:Number=.35):void {
			var newx:int = loc > _sliderWidth ? _sliderWidth : loc;			
			TweenLite.killTweensOf(imghandle);			
			TweenLite.to(imghandle, duration, {x:newx, ease:Linear.easeInOut(0,0,0,0), onComplete:calculateValue});
		}
		
		private function createButtonStateBitmap(BtnClass:Class):Bitmap
		{
			var btnBitmap:Bitmap = new BtnClass();
			btnBitmap.smoothing = true;
			return btnBitmap;
		}
		
		override public function styleChanged(styleProp:String):void
		{
			super.styleChanged(styleProp);
			
			if(styleProp == "handleImageBitmap") {
				_updateDisplay = true;
				invalidateDisplayList();
			}
			
		}
		public function destroy():void {
			lq.removeEventListener("assetsloaded", buildSlider);
			lq.removeEventListener("emptyqueue", drawSlider);			
			try { stage.addEventListener(MouseEvent.MOUSE_UP, stopHandleDrag); } catch (e:Error) { }
			imghandle.removeEventListener(MouseEvent.MOUSE_DOWN, startHandleDrag);
			//imgslider.removeEventListener(MouseEvent.MOUSE_DOWN, onSliderClick);
			hitarea.removeEventListener(MouseEvent.MOUSE_DOWN, onSliderClick);
			removeEventListener(Event.ENTER_FRAME, dragHandle);
			lq.destroy();
			for (var i:int=0; i < valuelabels.length; i++){ 
				valuelabels[i].removeEventListener(ResizeEvent.RESIZE, resizeValueLabel);
			}
			for (var i:int=0; i < legendlabels.length; i++){ 
				legendlabels[i].removeEventListener(ResizeEvent.RESIZE, resizeLegendLabel);
			}
		}
		
		public function get sliderLabelStyleName():String { return _sliderLabelStyleName; }
		public function set sliderLabelStyleName(value:String):void { _sliderLabelStyleName = value; }		
		public function get sliderValueLabelStyleName():String { return _sliderValueLabelStyleName;	}
		public function set sliderValueLabelStyleName(value:String):void { _sliderValueLabelStyleName = value; }
		public function get legendStyleName():String { return _legendStyleName; }
		public function set legendStyleName(value:String):void { _legendStyleName = value; }
						
		public function get labelImage():String { return _labelImage; }		
		public function set labelImage(value:String):void { _labelImage = value; }	
		
		public function get handleImage():String { return _handleImage; }
		[Bindable]
		public function set handleImage(value:String):void { 
			if(handleImage == value)
				return;
			_handleImage = value;
			lq.addEventListener("assetsloaded", buildSlider, false, 0, true);
			lq.add(_handleImage);
			lq.load();
		}
		
		public function get sliderBarImage():String { return _sliderBarImage; }	
		[Bindable]
		public function set sliderBarImage(value:String):void {
			if(sliderBarImage == value)
				return;
			_sliderBarImage = value; 
			lq.addEventListener("assetsloaded", buildSlider, false, 0, true);
			lq.add(_sliderBarImage);
			lq.load();
		}
		public function get backgroundImage():String { return _backgroundImage; }
		public function set backgroundImage(value:String):void { _backgroundImage = value; }
		public function get stretchSliderBarImage():Boolean { return _stretchSliderBarImage; }
		public function set stretchSliderBarImage(value:Boolean):void { _stretchSliderBarImage = value; }
		public function get data():ArrayCollection { return _data; }
		public function set data(value:ArrayCollection):void {
			_data = value;				
			_updateDisplay = true;
			invalidateDisplayList();
			loadAssets();			
		}
		public function get showValueLabels():Boolean {	return _showValueLabels; }
		public function set showValueLabels(value:Boolean):void { _showValueLabels = value; }
		public function get selectedValue():String { return _selectedValue; }		
		public function set selectedValue(value:String):void {			
			_selectedValue = value;
			setDefault = true;			
		}
		public function get selectedIndex():int { return _selectedIndex; }		
		public function set selectedIndex(value:int):void {			
			_selectedIndex = value;
			setDefault = true;
		}		
		public function get selectedLabel():String { return _selectedLabel; }		
		public function get continuous():Boolean { return _continuous; }
		public function set continuous(value:Boolean):void { _continuous = value; }		
		public function get sliderValueLabelWidth():int { return _sliderValueLabelWidth; }
		public function set sliderValueLabelWidth(value:int):void { _sliderValueLabelWidth = value;	}
		public function get showSelectedLabel():Boolean { return _showSelectedLabel; }
		public function set showSelectedLabel(value:Boolean):void { _showSelectedLabel = value;	}	
		public function get showSelectedValue():Boolean	{ return _showSelectedValue; }
		public function set showSelectedValue(value:Boolean):void { _showSelectedValue = value; }
		public function get valueLabelGap():int { return _valueLabelGap; }
		public function set valueLabelGap(value:int):void { _valueLabelGap = value; }
		public function get showTicks():Boolean { return _showTicks; }
		public function set showTicks(value:Boolean):void { _showTicks = value; }
		public function get engaged():Boolean { return _engaged; }
		public function get dragging():Boolean { return _dragging; }
		public function get ignoreFirstValue():Boolean { return _ignoreFirstValue; }
		public function set ignoreFirstValue(value:Boolean):void { _ignoreFirstValue = value; }
		public function get showVectorArt():Boolean	{ return _showVectorArt; }
		public function set showVectorArt(value:Boolean):void {	_showVectorArt = value;	}
		public function get showLegend():Boolean	{ return _showLegend; }
		public function set showLegend(value:Boolean):void {	_showLegend = value;	}
		public function get valueLegendGap():int { return _valueLegendGap; }
		public function set valueLegendGap(value:int):void { _valueLegendGap = value; }
		public function get legendWidth():int { return _legendWidth; }
		public function set legendWidth(value:int):void { _legendWidth = value;	}
		
		public function get handleYOffset():int
		{
			return _handleYOffset;
		}

		public function set handleYOffset(value:int):void
		{
			_handleYOffset = value;
			
			imghandle.y += value;
		}

		public function get handleXOffset():int
		{
			return _handleXOffset;
		}
		
		public function set handleXOffset(value:int):void
		{
			_handleXOffset = value;			
		}
		
		public function get labelXOffset():int
		{
			return _labelXOffset;
		}
		
		public function set labelXOffset(value:int):void
		{
			_labelXOffset = value;			
		}
	}	
}