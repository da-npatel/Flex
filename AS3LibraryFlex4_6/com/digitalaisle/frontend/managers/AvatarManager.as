package com.digitalaisle.frontend.managers
{
	import com.digitalaisle.frontend.components.DAAvatarPlayer;
	import com.greensock.dataTransfer.XMLManager;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
		
	public class AvatarManager extends EventDispatcher
	{
		private static var instance:AvatarManager;
		private static var allowInstantiation:Boolean;
		public var defaultAvatarPlayer:DAAvatarPlayer;
		
		private var _avatarXML:XMLManager = new XMLManager();
		private var _avatarList:ArrayCollection = new ArrayCollection();
		private var _filePrefix:String;
		private var _isDisabled:Boolean = false;
		
		public static function getInstance():AvatarManager
		{			
			if (instance == null) {
				allowInstantiation = true;
				instance = new AvatarManager();
				allowInstantiation = false;
			}
			return instance;
		}
		
		
		public function AvatarManager()
		{
			if (!allowInstantiation) 
			{
				throw new Error("Error: Instantiation failed: Use AvatarManager.getInstance() instead of new.");
			}
		}
		
		
		public function loadAvatars(xmlSource:String):void
		{
			_avatarXML.addEventListener(IOErrorEvent.IO_ERROR, onXMLIOError, false, 0, true);
			_avatarXML.addEventListener(Event.COMPLETE, onXMLLoaded, false, 0, true);			
			_avatarXML.load(xmlSource);
		}
		
		/**
		 * 
		 * @param label
		 * 
		 */		
		public function play(label:String, cuePoint:String = null/*, ignoreIfPlayed:Boolean = false*/):void
		{
			
			if(defaultAvatarPlayer)
			{
				if(_isDisabled)
				{
					_isDisabled = false;
					defaultAvatarPlayer.visible = true;
				}
				
				for(var i:int = 0; i < _avatarList.length; i++)
				{
					if(label == _avatarList[i].label)
					{
						defaultAvatarPlayer.source = _avatarList[i].source;
						
						if(cuePoint != null)
						{
							defaultAvatarPlayer.play();
							defaultAvatarPlayer.pause();
							defaultAvatarPlayer.gotoAndPlayCuePoint(cuePoint);
						}else
						{
							defaultAvatarPlayer.play();
						}
						
						/*if(ignoreIfPlayed && hasBeenPlayed(label))
						{
							defaultAvatarPlayer.load()
							defaultAvatarPlayer.pause();
							
							// RESET NEEDED!
						}else
						{
							//defaultAvatarPlayer.source = _avatarList[i].source;
							defaultAvatarPlayer.play();
						}*/

						_avatarList[i].hasBeenPlayed = true;
						return;
					}
				}	
			}else
			{
				trace("There is no defaualt video player defined");
			}		
		}
		
		
		/**
		 * 
		 * 
		 */		
		public function pause():void
		{
			defaultAvatarPlayer.pause();
		}
		
		public function stop():void
		{
			defaultAvatarPlayer.stop();
		}
		
		public function disable():void
		{
			_isDisabled = true;
			defaultAvatarPlayer.visible = false;
		}
		
		
		public function fetchAvatarByLabel(label:String):String
		{
			var fileURL:String;
			
			for(var i:int = 0; i < _avatarList.length; i++)
			{
				if(label == _avatarList[i].label)
				{
					fileURL = _avatarList[i].source;
				}
			}
			return fileURL;
		}
		
		
		public function hasBeenPlayed(label:String):Boolean
		{
			var hasBeenPlayed:Boolean = false;
			
			for(var i:int = 0; i < _avatarList.length; i++)
			{
				if(label == _avatarList[i].label)
				{
					hasBeenPlayed = _avatarList[i].hasBeenPlayed;
					break;
				}
			}
			return hasBeenPlayed;
		}
		
		private function onXMLIOError(e:IOErrorEvent):void {
			FlexGlobals.topLevelApplication.log.write("IOError loading Avatar XML");
		}
		
		private function onXMLLoaded(e:Event):void
		{
			var parsedObject:Object = e.target.parsedObject.Avatars[0];
			
			for(var i:int = 0; i < parsedObject.Avatar.length; i++)
			{
				//trace(parsedObject.Avatar[i].source);
				_avatarList.addItem({label: parsedObject.Avatar[i].label, source: parsedObject.Avatar[i].source, hasBeenPlayed: false});
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}

		public function get avatarList():ArrayCollection
		{
			return _avatarList;
		}

		public function set avatarList(value:ArrayCollection):void
		{
			_avatarList = value;
		}

	}
}