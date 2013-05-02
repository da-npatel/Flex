package com.digitalaisle.frontend.controls
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	
	public class StaticScrollbar extends Sprite
	{
		//private var _scrollTrack:DynamicShape;					// Shape that represents the scrollbar track
		protected var scrollThumb:Shape;							// Shape that represents the scrollbar thumb						
		private var _trackHeight:Number;						// Height of the scrollbar track
		private var _trackWidth:Number;							// Width of the scrollbar track
		private var _trackColor:uint;							// Color of the scrollbar track
		private var _defaultThumbHeight:Number;					// Default height of the scrollbar thumb
		private var _thumbHeight:Number;						// Altered height of the scrollbar thumb
		private var _thumbWidth:Number;
		private var _thumbColor:uint;							// Color of the scrollbar thumb
		private var SCROLL_SPEED:Number = .3
		
			
		public function StaticScrollbar(trackHeight:Number, scrollbarWidth:int = 10, defaultThumbHeight:int = 20, isRounded:Boolean = false, thumbColor:uint = 0x666666)
		{
			super();

			_trackHeight = trackHeight;
			//_trackWidth = trackWidth;
			//_trackColor = trackColor;
			_defaultThumbHeight = defaultThumbHeight;
			_thumbColor = thumbColor;
			_thumbHeight = _defaultThumbHeight;
			_thumbWidth = scrollbarWidth;
			
			if(isRounded)
			{
				
			}
			
			// CREATES the DynamicShape objects
			createShapes();
		}
		
		
		/**
		 * Positions the thumb position based on a percentage paremeter.  There is also the option to tween the thumb to its position or snap to it.  
		 * @param percentage:Number The percentage viewed of the mapped content 
		 * @param tween:Boolean If true, scroll thumb's position will be tweened.  If false, the position will simply be snapped to.
		 */		
		public function thumbPosition(percentage:Number, tween:Boolean = false):void		// position == content's position
		{

			if(percentage > 100)
			{
				percentage = 100;
			}else if(percentage <= 0)
			{
				percentage = 0;
			}
			
			var _scrollBarPositionValue:Number = (_trackHeight - _thumbHeight) * (percentage/100);
			
			// DETERMINE the style of the 
			if(tween)
			{
				TweenLite.to( scrollThumb, SCROLL_SPEED, { y:_scrollBarPositionValue, ease:Cubic.easeOut});
			}else
			{
				scrollThumb.y = _scrollBarPositionValue;
			}
			
		}
		
		/**
		 * Adjusts the height of the thumb based on the content height.  Also, the height is restricted to the set default thumb height
		 * @param contentHeight:Number A number that represents the height of the content being mapped to.
		 */		
		public function thumbSize(contentHeight:Number):void
		{
			// If content height is greater than the container height, show it, otherwise hide it
			if (contentHeight > _trackHeight)
			{
				visible = true;
			}else {
				visible = false;
				
				// TERMINTATE any running Tweens
				TweenLite.killTweensOf(scrollThumb);
				return;
			}
			
			// DETERMINE the alterted height of the scroll thumb
			_thumbHeight = Math.ceil((_trackHeight / contentHeight) * _trackHeight);
			
			// Set minimum size for scroll thumb
			if (_defaultThumbHeight > _thumbHeight) 
			{ 
				_thumbHeight = _defaultThumbHeight;
			}
			
			generateThumbShape(_thumbWidth, _thumbHeight, _thumbColor)
		}
		
		
		public function update():void
		{
			
		}
		
		
		/**
		 *	Creates the Dynamic Shapes and assigns them to the display list 
		 */		
		private function createShapes():void
		{
			scrollThumb = new Shape();
			generateThumbShape(_thumbWidth, _thumbHeight, _thumbColor);
			addChild(scrollThumb);
		}
		
		
		protected function generateThumbShape(width:Number, height:Number, color:uint = 0x000000):void
		{
			//var scrollThumb:Shape = new Shape();
			scrollThumb.graphics.clear();
			scrollThumb.graphics.beginFill(color);
			scrollThumb.graphics.drawRoundRect(-1, 0, width, height, 7, 7);
			scrollThumb.graphics.endFill();
			
			//return scrollThumb;
		}

		public function get defaultThumbHeight():Number
		{
			return _defaultThumbHeight;
		}

		public function set defaultThumbHeight(value:Number):void
		{
			_defaultThumbHeight = value;
		}

		public function get trackHeight():Number
		{
			return _trackHeight;
		}
		
		public function set trackHeight(value:Number):void
		{
			_trackHeight = value;
		}

		public function get thumbColor():uint
		{
			return _thumbColor;
		}

		public function get trackColor():uint
		{
			return _trackColor;
		}


	}
}