package com.digitalaisle.frontend.components
{
	import com.digitalaisle.frontend.controls.StaticScrollbar;
	import com.digitalaisle.frontend.drawing.DynamicShape;
	import com.digitalaisle.uilibrary.events.DAContentScrollerEvent;
	import com.greensock.TweenLite;
	import com.gskinner.utils.Janitor;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.core.IVisualElement;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.Group;
	import spark.core.SpriteVisualElement;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	import spark.layouts.supportClasses.LayoutBase;

	[Style(name="scrollThumbColor",type="uint",format="Color",inherit="yes")]
	
	public class DAContentScroller extends Group
	{
		public static const VERTICAL:String = "vertical";
		public static const HOTIZONTAL:String = "horizontal";
		public static const TOP:String = "top";
		public static const BOTTOM:String = "bottom";
		
		private static var DECAY:Number = 0.93;
		private static var MOUSE_DOWN_DECAY:Number = 0.5;
		private static var SPEED_SPRINGNESS:Number = 0.4;
		private static var MAX_VELOCITY:Number = 50;
		private static var TOUCH_BUFFER:Number = 0.20;
		private var STRETCH_RESTRICTION:int;
		
		public var scrollType:String;
		public var autoResetPosition:Boolean = true;
		
		private var _scrollDirection:String;
		private var _showScrollbar:Boolean = true;
		private var _easeSpeed:Number = .5;
		private var _textStyleName:String;
		private var _gap:int = 5;
		
		// PRIVATE
		private var _numContents:int;
		private var _isMouseDown:Boolean = false;
		private var _velocity:Number = 0;
		private var _mouseDownPos:Number = 0;
		private var _point:Point;
		private var _mouseDownPoint:Point = new Point();
		private var _mouseUpPoint:Point = new Point();
		private var _lastMouseDownPoint:Point = new Point();
		private var _janitor:Janitor;
		private var _curPos:Number;
		private var _dragDirection:String;
		protected var scrollCanvas:Group;
		protected var scrollCanvasMask:SpriteVisualElement;
		protected var scrollBarElement:SpriteVisualElement;
		
		
		/** Scrollbar Properties **/
		protected var defaultScrollbarWidth:int = 6;
		protected var defaultScrollbarHeight:int = 60;
		
		private var _scrollProperty:String;
		private var totalScrollableArea:Number;
		private var totalViewableArea:Number;
		
		public function DAContentScroller()
		{
			super();
			_janitor = new Janitor(this);
			scrollDirection = VERTICAL;
			//addEventListener(Event.REMOVED, onComponentRemoved, false, 0, true);
			addEventListener(FlexEvent.ADD, onComponentEnable, false, 0, true);
			addEventListener(FlexEvent.SHOW, onComponentEnable, false, 0, true);
			addEventListener(FlexEvent.HIDE, onComponentDisable, false, 0, true);
			addEventListener(FlexEvent.REMOVE, onComponentDisable, false, 0, true);
		}
		
		public function addContent(content:IVisualElement):void
		{
			if(content)
				scrollCanvas.addElement(content);
		}
		
		public function addContentAt(content:IVisualElement, index:int):void
		{
			if(content)
				scrollCanvas.addElementAt(content, index);	
		}
		
		public function getContentAt(index:int):IVisualElement 
		{
			if(scrollCanvas && scrollCanvas.numElements > index) {
				return scrollCanvas.getElementAt(index);
			}else return null;
		}
		
		public function removeContent(content:IVisualElement):void
		{
			if(content)
				scrollCanvas.removeElement(content);
		}
		
		public function removeContentAt(index:int):void
		{
			scrollCanvas.removeElementAt(index);
		}
		
		
		public function removeAllContent():void
		{
			scrollCanvas.removeAllElements();
		}
		
		public function tweenTo(position:Object, easeSpeed:Number = .5):void
		{
			if(position is String)
			{
				if(position == TOP)
					TweenLite.to(scrollCanvas, easeSpeed, populateTweenObject(0));
				else if(position == BOTTOM)
					TweenLite.to(scrollCanvas, easeSpeed, populateTweenObject(totalScrollableArea - totalViewableArea));
			}else if(position is Number)
			{
				if(position > 0)
					tweenTo(TOP, easeSpeed);
				else if(position > (totalScrollableArea - totalViewableArea))
					tweenTo(BOTTOM, easeSpeed);
				else
					TweenLite.to(scrollCanvas, easeSpeed, populateTweenObject(position as Number));
			}
			
		}
		
		public function moveTo(position:Object):void
		{
			
		}
		
		/**
		 * 
		 * 
		 */		
		override protected function createChildren():void
		{
			super.createChildren();
			
			var contentChildren:Array = [];
			while(numChildren > 0)
			{
				contentChildren.push(removeElementAt(0));
			}
			
			scrollCanvas = new Group();
			scrollCanvas.layout = determineLayoutBase();
			scrollCanvas.addEventListener(ResizeEvent.RESIZE, onResized,  false, 0, true);
			addElement(scrollCanvas);
			
			var scrollThumbColor:uint = 0x666666;
			
			if(getStyle("scrollThumbColor")) {
				scrollThumbColor = getStyle("scrollThumbColor");
			}
			
			// Create scrollbar instance
			var staticScrollbar:StaticScrollbar = new StaticScrollbar(height, defaultScrollbarWidth, defaultScrollbarHeight, true, scrollThumbColor);
			staticScrollbar.name = "scrollbar";
			staticScrollbar.mouseEnabled = false;
			
			scrollCanvasMask = new SpriteVisualElement();
			var maskSprite:DynamicShape = new DynamicShape();
			maskSprite.doDrawRect(width, height);
			scrollCanvasMask.addChild(maskSprite);
			scrollCanvas.mask = scrollCanvasMask;
			
			scrollBarElement = new SpriteVisualElement();
			scrollBarElement.addChild(staticScrollbar);
			scrollBarElement.mouseEnabled = false;
			addElement(scrollBarElement);
			addElement(scrollCanvasMask);

			for(var i:int = 0; i < contentChildren.length; i++)
			{
				scrollCanvas.addElement(contentChildren[i]);
			}

			contentChildren = [];
		}
		
		/**
		 * 
		 * @param unscaledWidth
		 * @param unscaledHeight
		 * 
		 */		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
		}
		
		
		/**
		 * 
		 * @param pos
		 * @return 
		 * 
		 */		
		private function getDirection(pos:Number):String
		{
			var prevPos:Number = _curPos;
			_curPos = pos;
			var direction:String;
			if (prevPos > _curPos) 
				direction = "top";
			else if (prevPos < _curPos) 
				direction = "bottom";
			else 
				direction = "none";
			return direction;
		}
		
		
		/**
		 * 
		 * 
		 */		
		protected function release():void
		{
			_isMouseDown = false;
			_janitor.removeEventListener(stage, MouseEvent.MOUSE_UP, onStageMouseUp, false, true);
			_janitor.removeEventListener(stage, MouseEvent.MOUSE_MOVE, onStageMouseMove, false, true);
			//stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			//stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			
			if(!hasEventListener(Event.ENTER_FRAME))
				_janitor.addEventListener(this, Event.ENTER_FRAME, onDragTimerTrigger, false, true);
				//addEventListener(Event.ENTER_FRAME, onDragTimerTrigger);
		}
		
		
		/**
		 * 
		 * @param position
		 * @return 
		 * 
		 */		
		private function populateTweenObject(position:Number):Object
		{
			var tweenObject:Object = new Object();
			tweenObject.onUpdate = onTweenUpdate;
			//tweenObject.onComplete = onTweenEnd;
			tweenObject[_scrollProperty] = position;
			return tweenObject;
		}
		
		private function disable():void
		{
			_isMouseDown = false;
			_janitor.cleanUpEventListeners();
		}
		
		private function enable():void
		{
			_isMouseDown = false;
		}
		
		
		
		protected function onTweenUpdate():void
		{
			updateScrollbarPosition();
		}
		
		
		/**
		 * 
		 * 
		 */		
		protected function updateScrollbarPosition():void
		{
			var percentage:Number = Math.round(((-scrollCanvas[_scrollProperty])/(totalScrollableArea - height)) * 100);
			(scrollBarElement.getChildByName("scrollbar") as StaticScrollbar).thumbPosition(percentage, false);	
		}
		
		private function determineLayoutBase():LayoutBase
		{
			var layout:LayoutBase;
			if(scrollDirection == VERTICAL){
				layout = new VerticalLayout();
				VerticalLayout(layout).gap = gap;
			}else{
				layout = new HorizontalLayout();
				HorizontalLayout(layout).gap = gap;
			}
			return layout;
		}
		
		
		/**
		 * 
		 * @param e
		 * 
		 */		
		private function onTouchMouseDown(e:MouseEvent):void
		{
			if (!_isMouseDown)
			{
				if(!hasEventListener(Event.ENTER_FRAME))
					_janitor.addEventListener(this, Event.ENTER_FRAME, onDragTimerTrigger, false, true);

				// Set initial properties
				_mouseDownPoint = new Point(e.stageX, e.stageY);
				_lastMouseDownPoint = new Point(e.stageX, e.stageY);
				_point = new Point(e.stageX, e.stageY);
				_isMouseDown = true;
				_mouseDownPos = scrollCanvas[_scrollProperty];
				
				// Adding Stage Mouse Handlers
				//stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
				//stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
				_janitor.addEventListener(stage, MouseEvent.MOUSE_UP, onStageMouseUp, false, true);
				_janitor.addEventListener(stage, MouseEvent.MOUSE_MOVE, onStageMouseMove, false, true);
			}
		}
		
		private function onTouchMouseUp(e:MouseEvent):void
		{	
			//_isPressed = false;
		}
		
		
		/**
		 * 
		 * @param e
		 * 
		 */		
		private function onDragTimerTrigger(e:Event):void
		{
			// decay the velocity
			if(_isMouseDown) 
				_velocity *= MOUSE_DOWN_DECAY;
			else
				_velocity *= DECAY;

			// if not mouse down, then move the element with the velocity
			if (!_isMouseDown)
			{
				var y:Number = scrollCanvas[_scrollProperty];
			
				if((y + _velocity) > STRETCH_RESTRICTION)
				{
					// Tween Back
					TweenLite.to(scrollCanvas, _easeSpeed, populateTweenObject(0));
					//removeEventListener(Event.ENTER_FRAME, onDragTimerTrigger);
					_janitor.removeEventListener(this, Event.ENTER_FRAME, onDragTimerTrigger, false, true);

				}else if((y + _velocity) <  -((totalScrollableArea - totalViewableArea) + STRETCH_RESTRICTION))
				{
					// Tween Back
					TweenLite.to(scrollCanvas, _easeSpeed, populateTweenObject(-(totalScrollableArea - totalViewableArea)));
					//removeEventListener(Event.ENTER_FRAME, onDragTimerTrigger);
					_janitor.removeEventListener(this, Event.ENTER_FRAME, onDragTimerTrigger, false, true);
				}
				else
				{
					scrollCanvas[_scrollProperty] = y + _velocity;
					updateScrollbarPosition();
				}
				
				
				// User in replacement of Math.abs for increased performce
				var velocity:Number = -_velocity;
				if(velocity < 0) velocity = -velocity;
				
				// Remove ENTER FRAME if velocity reaches below variable
				if(velocity < 0.5) 
				{
					_janitor.removeEventListener(this, Event.ENTER_FRAME, onDragTimerTrigger, false, true);
					//removeEventListener(Event.ENTER_FRAME, onDragTimerTrigger);
					
					// Checks to see if the position is not 100% at the top or the bottom so it can be placed there
					if(scrollCanvas[_scrollProperty] < -(totalScrollableArea - totalViewableArea) && scrollCanvas[_scrollProperty] > -((totalScrollableArea - totalViewableArea) + STRETCH_RESTRICTION))
					{
						// Tween Back
						TweenLite.to(scrollCanvas, _easeSpeed, populateTweenObject(-(totalScrollableArea - totalViewableArea)));
					}else if( scrollCanvas[_scrollProperty] > 0 && scrollCanvas[_scrollProperty] < STRETCH_RESTRICTION)
					{
						// Tween Back
						TweenLite.to(scrollCanvas, _easeSpeed, populateTweenObject(0));
					}
					
					dispatchEvent(new DAContentScrollerEvent(DAContentScrollerEvent.SCROLL_STOPPED));
				}
			}
		}
		
		
		/**
		 * 
		 * @param e
		 * 
		 */		
		private function onStageMouseMove(e:MouseEvent):void
		{
			if (_isMouseDown)
			{
				_dragDirection = scrollDirection == VERTICAL ? getDirection(this.mouseY) : getDirection(this.mouseX);
				
				switch(_dragDirection)
				{
					case "top":
						if(scrollCanvas[_scrollProperty] > -((totalScrollableArea - totalViewableArea) + STRETCH_RESTRICTION) )
						{
							_point = new Point(e.stageX, e.stageY);
				
							// Update the position
							scrollCanvas[_scrollProperty] = _mouseDownPos + (_point[_scrollProperty] - _mouseDownPoint[_scrollProperty]);
						}else
						{
							release();
						}
						break;
					case "bottom":
						if(scrollCanvas[_scrollProperty] < STRETCH_RESTRICTION)
						{	
							_point = new Point(e.stageX, e.stageY);
							scrollCanvas[_scrollProperty] = _mouseDownPos + (_point[_scrollProperty] - _mouseDownPoint[_scrollProperty]);
						}else
						{
							release();
						}
						break;
				}
				
				// Update the scoll canvas' position
				//var point:Point = new Point(e.stageX, e.stageY);
				scrollCanvas[_scrollProperty] = _mouseDownPos + (_point[_scrollProperty] - _mouseDownPoint[_scrollProperty]);
				
				// update the velocity
				_velocity += ((_point[_scrollProperty] - _lastMouseDownPoint[_scrollProperty]) * SPEED_SPRINGNESS);
				_lastMouseDownPoint = _point;
				
				updateScrollbarPosition();
			}
			
			e.updateAfterEvent();
		}
		
		
		/**
		 * 
		 * @param e
		 * 
		 */		
		private function onStageMouseUp(e:MouseEvent):void
		{
			if (_isMouseDown)
			{
				_isMouseDown = false;
				
				if(stage)
				{
					_janitor.removeEventListener(stage, MouseEvent.MOUSE_UP, onStageMouseUp, false, true);
					_janitor.removeEventListener(stage, MouseEvent.MOUSE_MOVE, onStageMouseMove, false, true);
				}
				
				/*try{
					if(stage.hasEventListener(MouseEvent.MOUSE_UP)) 
						stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
					if(stage.hasEventListener(MouseEvent.MOUSE_MOVE)) 
						stage.removeEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
				}catch(e:TypeError)
				{
				}*/
			}
		}
		
		private function onComponentEnable(e:FlexEvent):void
		{
			enable();
		}
		
		private function onComponentDisable(e:FlexEvent):void
		{
			disable();
		}
		
		private function onComponentRemoved(e:Event):void
		{
			_janitor.cleanUpEventListeners();
		}
		
		private function onResized(e:ResizeEvent):void
		{
			var isScrollbarNeeded:Boolean = true;
			
			if(scrollDirection == VERTICAL)
			{
				totalScrollableArea = scrollContentHeight;
				totalViewableArea = height;
			}else
			{
				isScrollbarNeeded = false;
				totalScrollableArea = scrollContentWidth;
				totalViewableArea = width;
			}
			
			if(autoResetPosition)
			{
				scrollCanvas[_scrollProperty] = 0;
				updateScrollbarPosition();
			}
			
			if(totalScrollableArea <= totalViewableArea)
			{
				isScrollbarNeeded = false;
				if(scrollCanvas.hasEventListener(MouseEvent.MOUSE_DOWN))
					scrollCanvas.removeEventListener(MouseEvent.MOUSE_DOWN, onTouchMouseDown);
			}else
			{
				if(!scrollCanvas.hasEventListener(MouseEvent.MOUSE_DOWN))
					scrollCanvas.addEventListener(MouseEvent.MOUSE_DOWN, onTouchMouseDown, false, 0, true);
			}
				
			if(isScrollbarNeeded)
			{
				scrollBarElement.x = width - (defaultScrollbarWidth + 4);
				scrollBarElement.y = 0;
				(scrollBarElement.getChildByName("scrollbar") as StaticScrollbar).thumbSize(totalScrollableArea);
				scrollBarElement.visible = showScrollbar;
			}else
				scrollBarElement.visible = false;
		}

		public function get scrollPosition():Point
		{
			if(scrollCanvas)
				return new Point(scrollCanvas.x, scrollCanvas.y);
			else 
				return new Point();
		}
		
		public function get scrollContentHeight():Number
		{
			return scrollCanvas.height;
		}
		
		public function get scrollContentWidth():Number
		{
			return scrollCanvas.width;
		}

		public function get gap():int
		{
			return _gap;
		}
		/**
		 * TODO: Tie in the gap to update the gap of the layout defined by the  
		 * @param value
		 * 
		 */		
		public function set gap(value:int):void
		{
			_gap = value;
		}
		
		override public function set width(value:Number):void
		{
			super.width = value;
			// TODO: Make reusable class out of this (GraphicsUtil)
			if(scrollCanvasMask)
			{
				scrollCanvasMask.graphics.clear();
				scrollCanvasMask.graphics.beginFill(0xFFFFFF, 0);
				scrollCanvasMask.graphics.drawRect(0, 0, width, height);
				scrollCanvasMask.graphics.endFill();
			}
		}
		
		override public function set height(value:Number):void
		{
			super.height = value;
			if(scrollCanvasMask)
			{
				scrollCanvasMask.graphics.clear();
				scrollCanvasMask.graphics.beginFill(0xFFFFFF, 0);
				scrollCanvasMask.graphics.drawRect(0, 0, width, height);
				scrollCanvasMask.graphics.endFill();
			}
			
			if(scrollBarElement)
			{
				(scrollBarElement.getChildByName("scrollbar") as StaticScrollbar).trackHeight = value;
				(scrollBarElement.getChildByName("scrollbar") as StaticScrollbar).thumbSize(totalScrollableArea);
			}
			STRETCH_RESTRICTION = value * .10;
		}
		
		
		public function get numContents():int
		{
			if(scrollCanvas)
				return scrollCanvas.numElements;
			else
				return 0;
		}
		
		[Inspectable(category="General", enumeration="vertical,horizontal", defaultValue="vertical")]
		public function get scrollDirection():String
		{
			return _scrollDirection;
		}

		public function set scrollDirection(value:String):void
		{
			_scrollDirection = value;
				
			_scrollProperty = _scrollDirection == VERTICAL ? "y" : "x";
			if(scrollBarElement && showScrollbar)
				scrollBarElement.visible = value == VERTICAL ? true : false;
			if(scrollCanvas)
				scrollCanvas.layout = determineLayoutBase();
		}

		public function get showScrollbar():Boolean
		{
			return _showScrollbar;
		}

		public function set showScrollbar(value:Boolean):void
		{
			_showScrollbar = value;
			if(scrollBarElement)
				scrollBarElement.visible = value;
		}

	}
}