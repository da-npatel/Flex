package com.digitalaisle.uilibrary.containers
{
	import com.digitalaisle.uilibrary.supportClasses.ContainerBase;
	
	import mx.controls.Image;
	import mx.events.StateChangeEvent;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.casalib.util.LoadItemUtil;
	
	import spark.components.VideoPlayer;
	
	public class AssetContainer extends ContainerBase
	{
		[SkinPart(required="true")]
		public var image:Image;
		
		[SkinPart(required="true")]
		public var videoPlayer:VideoPlayer;
		
		private var _source:String;
		
		public function AssetContainer()
		{
			super();
			addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, onCurrentStateChange);
		}
		
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance)
			{
				
			}
		}
		
		protected function onCurrentStateChange(e:StateChangeEvent):void
		{
			switch(e.newState)
			{
				case "image":
					image.source = _source;
					break;
				case "video":
					videoPlayer.source = _source;
					break;
			}
		}
		
		[Bindable]
		public function get source():String
		{
			return _source;
		}
		
		public function set source(value:String):void
		{
			if(_source == value)
				return;
			
			_source = value;
			
			var ext:String = _source.substr(_source.lastIndexOf('.') + 1).toLowerCase();
			
			if (LoadItemUtil.IMAGE_EXTENSIONS.indexOf(ext) > -1)
				currentState = "Image";
			else if (LoadItemUtil.SWF_EXTENSIONS.indexOf(ext) > -1)
				currentState = "Image";
			else if (LoadItemUtil.VIDEO_EXTENSIONS.indexOf(ext) > -1)
				currentState = "Video";
			else
				MonsterDebugger.trace(this, "Warning: Could not determine file type of: " + _source, MonsterDebugger.COLOR_WARNING);		
		}
	}
}