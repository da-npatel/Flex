package com.digitalaisle.uilibrary.keypads
{
	import com.digitalaisle.utils.ScreenResoultionUtil;
	import com.greensock.TweenLite;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import spark.components.TextInput;

	public class OffScreenKeyboard extends Keyboard
	{
		private static var MAX_HEIGHT:Number;
		private static var MAX_WIDTH:Number;
		
		private var _caller:TextInput;
		private var _isClosed:Boolean = true;
		protected var appResolution:Point = ScreenResoultionUtil.screenResolution;
		
		//TODO: Autoclose functionality after a certain duration
		public function OffScreenKeyboard()
		{
			super();
			
			//var appResolution:Point = ScreenResoultionUtil.screenResolution;
			MAX_HEIGHT = height =  Math.round(appResolution.y * .35);
			MAX_WIDTH = width = Math.round(appResolution.x * .50);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		public function open(caller:TextInput = null, inputType:String = "default"):void
		{
			type = inputType;
			
			if(caller)
			{
				_caller = caller;
				inputField.displayAsPassword = caller.displayAsPassword;
				inputField.text = caller.text;
				inputValue = caller.text;
			}else
			{
				inputValue = ""
				inputField.text = inputValue;
			}
			
			
			
			if(_isClosed)
			{
				var pos:Point = finalPos;
				TweenLite.to(this, .5, {x: pos.x, y: pos.y, alpha: 1, onComplete: onKeyboardOpen});
			}
		}
		
		public function close():void
		{
			if(!_isClosed)
			{
				var pos:Point = initialPos;
				TweenLite.to(this, .5, {x: pos.x, y: pos.y, alpha: 0});
				_isClosed = true;
			}
		}
		
		override protected function done():void
		{
			super.done();
			
			if(_caller)
				_caller.text = inputValue;
			close();
			//dispatchEvent(new Event("KeyBoardClosed"));
		}
		
		private function onAddedToStage(e:Event):void
		{
			x = initialPos.x;
			y = initialPos.y;
		}
		
		private function onKeyboardOpen():void
		{
			_isClosed = false;
		}
		
		public function get initialPos():Point
		{
			return new Point((appResolution.x - MAX_WIDTH)/2, appResolution.y);
		}
		
		public function get finalPos():Point
		{
			return new Point((appResolution.x - MAX_WIDTH)/2, appResolution.y - (height + 20));
		}
		
		override public function set inputValue(value:String):void
		{
			super.inputValue = value;
			if(_caller)
				_caller.text = value;
		}
	}
}