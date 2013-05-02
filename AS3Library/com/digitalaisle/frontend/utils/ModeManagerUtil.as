package com.digitalaisle.frontend.utils
{
	import com.digitalaisle.frontend.events.ModeManagerEvent;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	public class ModeManagerUtil extends EventDispatcher
	{
		
		private var _currentPosition:int = 0;
		private var _clickThruPath:Array = new Array();
		private var _dictionaryValues:Dictionary = new Dictionary();
		private var _isInitialMode:Boolean;
		
		public function ModeManagerUtil() {}
		
		
		public function next(mode:int, dictionaryValue:Object):void
		{
			_currentPosition++;
			_clickThruPath.push({mode: mode});
			_dictionaryValues["Mode=" + mode + ",ValueID=" + _currentPosition] = dictionaryValue;
			
			if(_currentPosition > 1)
			{
				_isInitialMode = false;
			}else
			{
				_isInitialMode = true;
			}
			
			dispatchEvent(new ModeManagerEvent(ModeManagerEvent.NEXT, false, false, mode, _currentPosition));
		}
		
		
		public function prev():void
		{
			var mode:int;
			if(_currentPosition > 1)
			{
				_currentPosition--;
				_clickThruPath.pop();

				mode = _clickThruPath[_currentPosition - 1].mode;
			}else
			{
				//Reset 
				_currentPosition = 0;
				_clickThruPath = [];
				_isInitialMode = true;
				mode = -1;
			}
			
			dispatchEvent(new ModeManagerEvent(ModeManagerEvent.PREV, false, false, mode, _currentPosition));
		}
		
		public function startOver():void
		{
			_currentPosition = 1;
			_isInitialMode = true;
			_clickThruPath = _clickThruPath.slice(0, 1);
			var mode:int = _clickThruPath[0].mode;
			
			dispatchEvent(new ModeManagerEvent(ModeManagerEvent.PREV, false, false, mode, _currentPosition));
		}
		
		public function getDictionaryValueOf(position:int):Object
		{
			var value:Object;
			
			if(position)
			{
				if(position > _currentPosition || position < 1)
				{
					position = _currentPosition;
				}
			}else
			{
				position  = _currentPosition;
			}
			
			var mode:int = _clickThruPath[position - 1].mode;
			value = _dictionaryValues["Mode=" + mode + ",ValueID=" + position];
			return value;
		}
		
		
		public function destroy():void
		{
			_clickThruPath = [];
		}

		public function get isInitialMode():Boolean
		{
			return _isInitialMode;
		}

	}
}