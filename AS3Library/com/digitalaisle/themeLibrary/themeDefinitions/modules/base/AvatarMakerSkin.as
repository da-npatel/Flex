package com.digitalaisle.themeLibrary.themeDefinitions.modules.base
{
	import com.digitalaisle.themeLibrary.base.ModuleSkinBase;
	import com.digitalaisle.themeLibrary.types.AssetSkinType;
	import com.digitalaisle.themeLibrary.types.ModuleSkinType;
	
	public class AvatarMakerSkin extends ModuleSkinBase
	{
		public function AvatarMakerSkin()
		{
			super();
			
			type = ModuleSkinType.ABOUT_US_DEFAULT;
			supportedAssets = [AssetSkinType.NUM_0, 
				AssetSkinType.NUM_1, 
				AssetSkinType.NUM_2, 
				AssetSkinType.NUM_3, 
				AssetSkinType.NUM_4, 
				AssetSkinType.NUM_5, 
				AssetSkinType.NUM_6, 
				AssetSkinType.NUM_7, 
				AssetSkinType.NUM_8, 
				AssetSkinType.NUM_9, 
				AssetSkinType.AGE_PROMPT,
				AssetSkinType.BOTTOM_BAR,
				AssetSkinType.CUSTOMIZE_ARMBAND,
				AssetSkinType.CUSTOMIZE_FACE,
				AssetSkinType.CUSTOMIZE_FACIAL_HAIR,
				AssetSkinType.CUSTOMIZE_GOGGLE,
				AssetSkinType.CUSTOMIZE_HAIR_STYLE,
				AssetSkinType.CUSTOMIZE_HEADBAND,
				AssetSkinType.CUSTOMIZE_JERSEY,
				AssetSkinType.CUSTOMIZE_JERSEY_NUMBER,
				AssetSkinType.CUSTOMIZE_JERSEY_PANTS,
				AssetSkinType.CUSTOMIZE_KNEE_BRACE,
				AssetSkinType.CUSTOMIZE_SHOES,
				AssetSkinType.CUSTOMIZE_SKIN_COLOR,
				AssetSkinType.DISPLAY_AREA,
				AssetSkinType.FACEBOOK_PROMPT,
				AssetSkinType.FINISH_SECTION_PROMPT,
				AssetSkinType.GENDER_PROMPT,
				AssetSkinType.GRATE,
				AssetSkinType.JERSEY_PRIMARY_ICON,
				AssetSkinType.JERSEY_SECONDARY_ICON,
				AssetSkinType.LOGO,
				AssetSkinType.QUIT_PROMPT,
				AssetSkinType.SHORTS_WS_ICON,
				AssetSkinType.START_OVER_PROMPT,
				AssetSkinType.TOP_BAR];
			
			
		}
	}
}