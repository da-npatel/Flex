package com.digitalaisle.frontend.enums
{
	public final class BinaryFormat
	{
		
		public static const PNG:int = 0;
		public static const JPG:int = 1;
		public static const FLV:int = 2;
		
		public function BinaryFormat()
		{
		}
		
		/**
		 * Returns a file suffix based on an ID (enum)
		 * @param id: ID of suffix which maps back to Enum table
		 * @return 
		 * 
		 */		
		public static function fetchBinaryExtensionById(id:int):String
		{
			var suffix:String;
			
			switch(id)
			{
				case PNG:
					suffix = ".png";
					break;
				case JPG:
					suffix = ".jpg";
					break;
				case FLV:
					suffix = ".flv";
					break;
				default:
					
					break;
			}
			
			return suffix;
		}
	}
}