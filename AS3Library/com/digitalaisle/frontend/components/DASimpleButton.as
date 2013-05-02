package com.digitalaisle.frontend.components {
		
	import com.digitalaisle.frontend.enums.ActionType;
	import com.digitalaisle.frontend.events.UserTouchEvent;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.ImageLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.valueObjects.ImageLoaderObject;
	
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.IStyleManager2;
	
	import spark.components.BorderContainer;
	import spark.components.Group;
	import spark.core.SpriteVisualElement;
	import spark.primitives.BitmapImage;
	
	public class DASimpleButton extends Group {
		
		private var _imageIdle:String = "";								// Optional URL of desired IDLE state image asset
		private var _imageDown:String = "";								// Optional URL of desired DOWN state image asset
		private var _imageDisabled:String = "";							// Optional URL of desired DISABLED state image asset
		private var _width:int = 100;									// Explicit button width
		private var _height:int = 30;									// Explicit button height
		private var _toggle:Boolean;									// Flags toggle button mode (click on/click off)
		private var _selected:Boolean;									// Flags button as selected (toggle mode only)
		private var _disabled:Boolean;									// Flags button as disabled		
		private var _scaleImages:Boolean;								// Flags images to match button width and height (not yet implemented) 
		private var _maintainAspectRatio:Boolean;						// Flags images to fit "inside" button width and height (not yet implemented)
		private var _value:*;											// An optional value button can retain for external usage 
		private var _showVectorArt:Boolean = true;						// Flag if default slider styles should be programmatically drawn if no skin images are available
		
		private var _styleNameIdle:String = "dabuttonidle";				// Default css selector for IDLE state
		private var _styleNameDown:String = "dabuttondown";				// Default css selector for DOWN state
		private var _styleNameDisabled:String = "dabuttondisabled";		// Default css selector for DISABLED state
		
		private var lq:LoaderMax;										// Image assets LoaderMax instance
		private var imgldr:ImageLoader;									// ImageLoader instance
		private var imgobj:ImageLoaderObject;							// ValueObject for ImageLoader instance
		private const idlename:String = "idle";							// Shorthand id for referencing IDLE image loader content
		private const downname:String = "down";							// Shorthand id for referencing DOWN image loader content
		private const disabledname:String = "disabled";					// Shorthand id for referencing DISABLED image loader content
		
		private var hitarea:SpriteVisualElement;						// VisualElement mapped to all user interaction
		private var idlestate:Group;									// Container for IDLE (default) state
		private var idleborder:BorderContainer;							// Vector art for IDLE (default) state
		private var downstate:Group;									// Container for DOWN state
		private var downborder:BorderContainer;							// Vector art for DOWN state
		private var disabledstate:Group;								// Container for DISABLED state
		private var disabledborder:BorderContainer;						// Vector art for DISABLED state		
		private var sm:IStyleManager2;									// MX StyleManager reference
		private var defaultidlestyle:CSSStyleDeclaration;				// Default vector art css styles for IDLE state
		private var defaultdownstyle:CSSStyleDeclaration;				// Default vector art css styles for DOWN state
		private var defaultdisabledstyle:CSSStyleDeclaration;			// Default vector art css styles for DISABLED state
		
		public function DASimpleButton() {
			super();
						
			hitarea = new SpriteVisualElement();
			idlestate = new Group();
			idleborder = new BorderContainer();			
			idlestate.addElement(idleborder);
			downstate = new Group();
			downborder = new BorderContainer();
			downstate.addElement(downborder);
			disabledstate = new Group();
			disabledborder = new BorderContainer();
			disabledstate.addElement(disabledborder);
									
			// Create default styles for button states
			sm = FlexGlobals.topLevelApplication.styleManager;
			
			defaultidlestyle = new CSSStyleDeclaration();
			defaultdownstyle = new CSSStyleDeclaration();
			defaultdisabledstyle = new CSSStyleDeclaration();
			
			
			with(defaultidlestyle){
				setStyle("backgroundColor", 0x999999);				
				setStyle("backgroundAlpha", .75);
				setStyle("borderAlpha", .75);				
				setStyle("borderColor", 0x666666);						
			}				
			
			with(defaultdownstyle){
				setStyle("backgroundColor", 0xbbbbbb);
				setStyle("backgroundAlpha", .75);
				setStyle("borderAlpha", .75);
				setStyle("borderColor", 0x6666ff);
			}				
			
			with(defaultdisabledstyle){
				setStyle("backgroundColor", 0x666666);
				setStyle("backgroundAlpha", .75);
				setStyle("borderAlpha", .75);
				setStyle("borderColor", 0x333333);
			}
			
			lq = new LoaderMax();
						
			downstate.visible = false;
			disabledstate.visible = false;
			
			showVectorArt = false;
		}
		
		protected function loadAssets():void {			
			imgobj = new ImageLoaderObject();			
						
			if(_imageIdle.length > 0 && lq.getLoader(idlename) == null){				
				imgobj.name = idlename;				
				imgldr = new ImageLoader(_imageIdle, imgobj);
				lq.append(imgldr);
			}
			if (_imageDown.length > 0 && lq.getLoader(downname) == null) {
				imgobj.name = downname;		
				imgldr = new ImageLoader(_imageDown, imgobj);
				lq.append(imgldr);
			}
			if (_imageDisabled.length > 0 && lq.getLoader(disabledname) == null) {
				imgobj.name = disabledname;
				imgldr = new ImageLoader(_imageDisabled, imgobj);
				lq.append(imgldr);
			}
			lq.addEventListener(LoaderEvent.CHILD_FAIL, onAssetFail, false, 0, true);
			lq.addEventListener(LoaderEvent.CHILD_COMPLETE, onAssetLoaded, false, 0, true);
			lq.addEventListener(LoaderEvent.COMPLETE, onAssetsComplete, false, 0, true);
			lq.load();
		}
		
		protected function onAssetFail(e:LoaderEvent):void {
			//trace(e.target+" failed");
			e.target.dispose(true);			
		}
		
		protected function onAssetLoaded(e:LoaderEvent):void {
			
		}
		
		protected function onAssetsComplete(e:Event):void {			
			lq.removeEventListener(LoaderEvent.COMPLETE, onAssetsComplete);
			var ldr:ImageLoader;
			var bmp:BitmapImage = new BitmapImage();			
			if(lq.getLoader(idlename) != null){ // Use images for button states
				ldr = lq.getLoader(idlename);
				bmp.source = new Bitmap(ldr.rawContent.bitmapData, "auto", true);
				
				// Defaulted height/width of button to match that of the idle asset
				this.width = ldr.rawContent.bitmapData.width;
				this.height = ldr.rawContent.bitmapData.height;
				
				idlestate.addElement(bmp);
				/*if(lq.getLoader(disabledname) != null){
					ldr = lq.getLoader(disabledname);
				} else {
					ldr = lq.getLoader(idlename);
				}*/
			} 
			
			if(lq.getLoader(downname)!= null)
			{
				ldr = lq.getLoader(downname);
				bmp = new BitmapImage();
				bmp.source = new Bitmap(ldr.rawContent.bitmapData, "auto", true);
				downstate.addElement(bmp);
			}
			
			if(lq.getLoader(disabledname) != null)
			{
				ldr = lq.getLoader(disabledname);
				bmp = new BitmapImage();
				bmp.source = new Bitmap(ldr.rawContent.bitmapData, "auto", true);
				disabledstate.addElement(bmp);
			}
				
			invalidateProperties();
			invalidateSize();
			invalidateDisplayList();
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		override protected function commitProperties():void {			
			super.commitProperties();			
		}
		
		override protected function measure():void {
			super.measure();
			//measuredWidth = measuredHeight = 100;
			//measuredMinWidth = measuredMinHeight = 30;	
		}
		
		override protected function createChildren():void {
			super.createChildren();		
									
			addElement(idlestate);
			addElement(downstate);
			addElement(disabledstate);		
			addElement(hitarea);			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(!disabled){
				enable();
			} else{
				disable();
			}
			
			with(hitarea.graphics){
				clear();
				beginFill(0xff00ff, 0);
				drawRect(0,0,width,height);
				endFill();
			}
						
		}
		
		protected function onMouseDown(e:MouseEvent):void {			
			select();
		}
		
		protected function onClick(e:MouseEvent):void {			
			if(_toggle){
				_selected = !_selected;	
				if(_selected){
					select();			
				} else {
					deselect();
				}
			} else {
				deselect();
			}
			dispatchEvent(new UserTouchEvent(UserTouchEvent.TOUCH, 0, ActionType.CLICK, localToGlobal(new Point(mouseX, mouseY))));
		}
		
		protected function enable():void { 		
			disabledstate.visible = false;
			hitarea.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			if(_toggle){
				if(_selected){
					select();					
				} else {
					deselect();
				}
			} else {				
				hitarea.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);				
			} 
		}
		
		protected function disable():void {
			idlestate.visible = false;
			downstate.visible = false;
			disabledstate.visible = true;
			hitarea.removeEventListener(MouseEvent.CLICK, onClick);			
		}
		
		protected function select():void {
			downstate.visible = true;
			idlestate.visible = false;		
		}
		
		protected function deselect():void {
			idlestate.visible = true;
			downstate.visible = false;
		}
		
		protected function setButtonStyle():void {	
			if(lq.getLoader(idlename) != null || !_showVectorArt){ // Use button images				
				idleborder.alpha = 0;
				return;
			} 
			
			if(lq.getLoader(downname) != null || !_showVectorArt){ // Use button images				
				downborder.alpha = 0;
				return;
			} 
			
			if(lq.getLoader(disabledname) != null || !_showVectorArt){ // Use button images				
				disabledborder.alpha = 0;
				return;
			} 
			
								
			if(sm.getStyleDeclaration("."+_styleNameIdle) != null) {
				idleborder.styleName = _styleNameIdle;				
			} else {
				idleborder.styleName = defaultidlestyle;
			}
			
			if(lq.getLoader(downname) == null){
				if(sm.getStyleDeclaration("."+_styleNameDown) != null){
					downborder.styleName = _styleNameDown;
				} else {
					downborder.styleName = defaultdownstyle;
				}
			}
			if(lq.getLoader(disabledname) == null){
				if(sm.getStyleDeclaration("."+_styleNameDisabled) != null){
					disabledborder.styleName = _styleNameDisabled;
				} else {
					disabledborder.styleName = defaultdisabledstyle;
				}				
			}
		}
		
		public function destroy():void {
			lq.empty(true, false);
			lq.removeEventListener(LoaderEvent.CHILD_COMPLETE, onAssetLoaded);
			lq.removeEventListener(LoaderEvent.COMPLETE, onAssetsComplete);
			hitarea.removeEventListener(MouseEvent.CLICK, onClick);
			hitarea.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);			
		}
		
		
		
		// Getters & Setters ============================================================================================================
				
		public function get toggle():Boolean { return _toggle; }
		public function set toggle(value:Boolean):void { _toggle = value; }
		
		[Bindable]
		public function set imageIdle(value:String):void { _imageIdle = value; loadAssets(); }
		public function get imageIdle():String { return _imageIdle; }
		
		[Bindable]
		public function set imageDown(value:String):void { _imageDown = value; loadAssets(); }
		public function get imageDown():String { return _imageDown; }
		
		[Bindable]
		public function set imageDisabled(value:String):void { _imageDisabled = value; loadAssets(); }
		public function get imageDisabled():String { return _imageDisabled; }
		
		public function get disabled():Boolean { return _disabled; }
		public function set disabled(value:Boolean):void { 
			_disabled = value;
			if(_disabled) {
				disable();
			}
		}
		public function get selected():Boolean { return _selected; }
		public function set selected(value:Boolean):void {
			_selected = value;
			if(_selected){
				select();
			} else {
				deselect();
			}
		}

		public function get styleNameIdle():String {
			return _styleNameIdle;
		}

		public function set styleNameIdle(value:String):void
		{
			_styleNameIdle = value;
			setButtonStyle();
		}

		public function get styleNameDown():String
		{
			return _styleNameDown;
		}

		public function set styleNameDown(value:String):void
		{
			_styleNameDown = value;
			setButtonStyle();
		}

		public function get styleNameDisabled():String
		{
			return _styleNameDisabled;
		}

		public function set styleNameDisabled(value:String):void
		{
			_styleNameDisabled = value;
			setButtonStyle();
		}

		public function get value():* {
			return _value;
		}

		public function set value(value:*):void	{
			_value = value;
		}

		public function get scaleImages():Boolean {
			return _scaleImages;
		}

		public function set scaleImages(value:Boolean):void	{
			_scaleImages = value;
		}

		public function get maintainAspectRatio():Boolean
		{
			return _maintainAspectRatio;
		}

		public function set maintainAspectRatio(value:Boolean):void
		{
			_maintainAspectRatio = value;
		}

		public function get showVectorArt():Boolean
		{
			return _showVectorArt;
		}

		public function set showVectorArt(value:Boolean):void {
			_showVectorArt = value;			
			trace("NO VECTOR ART");
			if(!_showVectorArt){
				idleborder.visible = false;
				downborder.visible = false;
				disabledborder.visible = false;
			}			
		}
	}
}
