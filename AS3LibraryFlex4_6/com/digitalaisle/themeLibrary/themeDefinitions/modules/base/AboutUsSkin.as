package com.digitalaisle.themeLibrary.themeDefinitions.modules.base
{
	import com.digitalaisle.themeLibrary.base.ModuleSkinBase;
	import com.digitalaisle.themeLibrary.types.AssetSkinType;
	import com.digitalaisle.themeLibrary.types.ModuleSkinType;
	
	public class AboutUsSkin extends ModuleSkinBase
	{
		public function AboutUsSkin()
		{
			super();
			
			type = ModuleSkinType.ABOUT_US_DEFAULT;
			supportedAssets = [AssetSkinType.PRINT_BTN_IDLE,AssetSkinType.PRINT_BTN_DOWN, AssetSkinType.EMAIL_BTN_IDLE, AssetSkinType.EMAIL_BTN_DOWN];
			
		}
	}
}