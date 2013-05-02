package com.digitalaisle.uilibrary.components.panels
{
	import com.digitalaisle.uilibrary.components.buttons.DASimpleButton;
	import com.digitalaisle.uilibrary.data.PanelObject;
	import com.digitalaisle.uilibrary.skins.ListPanelSkin;
	import com.digitalaisle.uilibrary.supportClasses.PanelBase;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import spark.components.Image;
	import spark.components.RichText;
	
	public class ListPanel extends PanelBase
	{
		/*[SkinPart(required="true")]
		public var panelButton:DASimpleButton;*/
		[SkinPart(required="true")]
		public var thumbnail:Image;
	[SkinPart(required="false")]
	public var labelDisplay1:RichText;
		
		private var _thumbnailAsset:String;
		
		public function ListPanel()
		{
			super();
			setStyle("skinClass", ListPanelSkin);
		}
		
		override protected function applySettings(settingsObj:PanelObject):void
		{
			super.applySettings(settingsObj);
			
			thumbnailAsset = settingsObj.thumbnailAsset;
			upStateAsset = settingsObj.upStateAsset;
			downStateAsset = settingsObj.downStateAsset;
			
		}

		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance)
			{
				case panelButton:
					try{
						if(buttonStyleName)
							panelButton.styleName = buttonStyleName;
					}catch(errObject:Error){
						MonsterDebugger.trace(this, "Warning: The following button style, " + buttonStyleName + ", is not available.  Please check the Style.css to make sure that the button style exists.", MonsterDebugger.COLOR_WARNING);
					}
					break;
				case thumbnail:
					if(_thumbnailAsset)
					{
						thumbnail.source = _thumbnailAsset;
						thumbnail.mouseEnabled = false;
					}
						
					break;
					
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
		}
		
		override public function set settings(value:PanelObject):void
		{
			super.settings = value;
			
		}
		
		override public function set downStateAsset(value:String):void
		{
			super.downStateAsset = value;
			if(panelButton)
				panelButton.downStateAsset = value;
		}
		
		override public function set upStateAsset(value:String):void
		{
			super.upStateAsset = value;
			if(panelButton)
				panelButton.upStateAsset = value;
		}
		
		override public function set disabledStateAsset(value:String):void
		{
			super.disabledStateAsset = value;
			if(panelButton)
				panelButton.disabledStateAsset = value;
		}
		
		public function get thumbnailAsset():String
		{
			return _thumbnailAsset;
		}
		
		public function set thumbnailAsset(value:String):void
		{
			if(_thumbnailAsset == value)
				return;
			_thumbnailAsset = value;
			if(thumbnail)
				thumbnail.source = value;
		}
	}
}