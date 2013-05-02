package com.digitalaisle.uilibrary.components.panels
{
	import com.digitalaisle.uilibrary.data.PanelObject;
	import com.digitalaisle.uilibrary.skins.TitledPanelSkin;
	import com.digitalaisle.uilibrary.supportClasses.PanelBase;
	
	//Change MX Image to Spark Image - Start
	//import mx.controls.Image;
	import spark.components.Image;
	//End
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	public class TitledPanel extends PanelBase
	{
		[SkinPart(required="true")]
		public var background:Image;
		
		private var _backgroundAsset:String;
		
		public function TitledPanel()
		{
			super();
			setStyle("skinClass", TitledPanelSkin);
		}

		override protected function applySettings(settingsObj:PanelObject):void
		{
			super.applySettings(settingsObj);
			backgroundAsset = settingsObj.upStateAsset;
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
				case background:
					if(backgroundAsset)
					{
						background.source = backgroundAsset;
						background.mouseEnabled = false;
					}
						
					break;	
			}
		}
		
		public function get backgroundAsset():String
		{
			return _backgroundAsset;
		}
		
		public function set backgroundAsset(value:String):void
		{
			if(_backgroundAsset == value)
				return;
			_backgroundAsset = value;
			if(background)
				background.source = _backgroundAsset;
		}

		
	}
}