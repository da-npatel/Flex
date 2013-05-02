package com.digitalaisle.frontend.valueObjects
{
	import mx.controls.Image;

	public class DASpindleObject extends Object
	{
		public static const CONTENT_TYPE_TEXT:String = "text";
		public static const CONTENT_TYPE_IMAGE:String = "image";
		private var _type:String;
		public var text:String;
		public var img:Image;
		public var uid:int;
		
		public function DASpindleObject(Content:Object, id:int)
		{
			super();
			if( !(Content is String) && !(Content is Image) ){
				throw new Error("DASpindle Objects must be strings or images");
			}else{
				if(Content is String){
					this._type = CONTENT_TYPE_TEXT;
					this.text = String(Content);
					this.uid = id;
				}else{
					this._type = CONTENT_TYPE_IMAGE;
					this.img = Content as Image;
					this.uid = id;
				}
			}
			
		}
		public function get type():String{
			return this._type;
		}
	}
}