/* 
	ValueObject for v1.0 greensock LoaderMax ImageLoader object 
*/

package com.greensock.valueObjects {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.system.LoaderContext;
	import flash.display.BlendMode;
	import com.greensock.events.LoaderEvent;
		
	dynamic public class ImageLoaderObject extends Object {
	
		// Variables
		[Inspectable(category="General")]	
		/**
		   A name that is used to identify the ImageLoader instance. This name can be fed to the <code>LoaderMax.getLoader()</code> or <code>LoaderMax.getContent()</code> methods or traced at any time. Each loader's name should be unique. If you don't define one, a unique name will be created automatically, like "loader21".
		*/
		public var name:String = "";
		
		[Inspectable(category="General")]
		/**
			A DisplayObjectContainer into which the <code>ContentDisplay</code> Sprite should be added immediately.
		*/		
		public var container:DisplayObjectContainer;
		[Inspectable(category="General")]
		/**
			When <code>smoothing</code> is <code>true</code> (the default), smoothing will be enabled for the image which typically leads to much better scaling results (otherwise the image can look crunchy/jagged). If your image is loaded from another domain where the appropriate crossdomain.xml file doesn't grant permission, Flash will not allow smoothing to be enabled (it's a security restriction).
		*/
		public var smoothing:Boolean = true;
		[Inspectable(category="General")]
		/**
			Sets the <code>ContentDisplay</code>'s <code>width</code> property (applied before rotation, scaleX, and scaleY).		
		*/
		public var width:Number = 0;
		[Inspectable(category="General")]
		/**
			Sets the <code>ContentDisplay</code>'s <code>height</code> property (applied before rotation, scaleX, and scaleY).	
		*/
		public var height:Number = 0;
		[Inspectable(category="General")]
		/**
			if <code>true</code>, the registration point will be placed in the center of the ContentDisplay which can be useful if, for example, you want to animate its scale and have it grow/shrink from its center.
		*/
		public var centerRegistration:Boolean;
		[Inspectable(category="General")]
		/**
			When a <code>width</code> and <code>height</code> are defined, the <code>scaleMode</code> controls how the loaded image will be scaled to fit the area. The following values are recognized (you may use the <code>com.greensock.layout.ScaleMode</code> constants if you prefer):
		    <ul>
		
		     <li><code>"stretch"</code> (the default) - The image will fill the width/height exactly.</li>
		     <li><code>"proportionalInside"</code> - The image will be scaled proportionally to fit inside the area defined by the width/height</li>
		     <li><code>"proportionalOutside"</code> - The image will be scaled proportionally to completely fill the area, allowing portions of it to exceed the bounds defined by the width/height.</li>
		     <li><code>"widthOnly"</code> - Only the width of the image will be adjusted to fit.</li>
		
		     <li><code>"heightOnly"</code> - Only the height of the image will be adjusted to fit.</li>
		     <li><code>"none"</code> - No scaling of the image will occur.</li>
		    </ul>
		*/
		public var scaleMode:String = "stretch";
		[Inspectable(category="General")]
		/**
		When a <code>width</code> and <code>height</code> is defined, the <code>hAlign</code> determines how the image is horizontally aligned within that area. The following values are recognized (you may use the <code>com.greensock.layout.AlignMode</code> constants if you prefer):
	    <ul>
	
	     <li><code>"center"</code> (the default) - The image will be centered horizontally in the area</li>
	     <li><code>"left"</code> - The image will be aligned with the left side of the area</li>
	     <li><code>"right"</code> - The image will be aligned with the right side of the area</li>
	    </ul>
		*/		
		public var hAlign:String = "center";		
		[Inspectable(category="General")]		
		/**
		 When a <code>width</code> and <code>height</code> is defined, the <code>vAlign</code> determines how the image is vertically aligned within that area. The following values are recognized (you may use the <code>com.greensock.layout.AlignMode</code> constants if you prefer):
	    <ul>
	
	     <li><code>"center"</code> (the default) - The image will be centered vertically in the area</li>
	     <li><code>"top"</code> - The image will be aligned with the top of the area</li>
	     <li><code>"bottom"</code> - The image will be aligned with the bottom of the area</li>
	    </ul>		
		*/
		public var vAlign:String = "center";
		[Inspectable(category="General")]
		/**
			When a <code>width</code> and <code>height</code> are defined, setting <code>crop</code> to <code>true</code> will cause the image to be cropped within that area (by applying a <code>scrollRect</code> for maximum performance). This is typically useful when the <code>scaleMode</code> is <code>"proportionalOutside"</code> or <code>"none"</code> so that any parts of the image that exceed the dimensions defined by <code>width</code> and <code>height</code> are visually chopped off. Use the <code>hAlign</code> and <code>vAlign</code> special properties to control the vertical and horizontal alignment within the cropped area.
		*/
		public var crop:Boolean;
		[Inspectable(category="General")]
		/**
			Sets the <code>ContentDisplay</code>'s <code>x</code> property (for positioning on the stage).
		*/
		public var x:Number;
		[Inspectable(category="General")]
		/**
			Sets the <code>ContentDisplay</code>'s <code>y</code> property (for positioning on the stage).
		*/
		public var y:Number;
		[Inspectable(category="General")]
		/**
			Sets the <code>ContentDisplay</code>'s <code>scaleX</code> property.
		*/
		public var scaleX:Number;
		[Inspectable(category="General")]
		/**
			Sets the <code>ContentDisplay</code>'s <code>scaleY</code> property.
		*/
		public var scaleY:Number;
		[Inspectable(category="General")]
		/**
			Sets the <code>ContentDisplay</code>'s <code>rotation</code> property.
		*/
		public var rotation:Number;
		[Inspectable(category="General")]
		/**
			Sets the <code>ContentDisplay</code>'s <code>alpha</code> property.
		*/
		public var alpha:Number;
		[Inspectable(category="General")]
		/**
			Sets the <code>ContentDisplay</code>'s <code>visible</code> property.
		*/
		public var visible:Boolean = true;
		[Inspectable(category="General")]
		/**
			Sets the <code>ContentDisplay</code>'s <code>blendMode</code> property.
		*/
		public var blendMode:String = BlendMode.NORMAL;
		[Inspectable(category="General")]
		/**
			When a <code>width</code> and <code>height</code> are defined, a rectangle will be drawn inside the <code>ContentDisplay</code> Sprite immediately in order to ease the development process. It is transparent by default, but you may define a <code>bgColor</code> if you prefer.
		*/
		public var bgColor:uint;
		[Inspectable(category="General")]
		/**
			Controls the alpha of the rectangle that is drawn when a <code>width</code> and <code>height</code> are defined.
		*/
		public var bgAlpha:Number;
		[Inspectable(category="General")]
		/**
			To control whether or not a policy file is checked (which is required if you're loading an image from another domain and you want to use it in BitmapData operations), define a <code>LoaderContext</code> object. By default, the policy file <strong>will</strong> be checked when running remotely, so make sure the appropriate crossdomain.xml file is in place. See Adobe's <code>LoaderContext</code> documentation for details and precautions.
		*/
		public var context:LoaderContext;
		[Inspectable(category="General")]
		/**
			Initially, the loader's <code>bytesTotal</code> is set to the <code>estimatedBytes</code> value (or <code>LoaderMax.defaultEstimatedBytes</code> if one isn't defined). Then, when the loader begins loading and it can accurately determine the bytesTotal, it will do so. Setting <code>estimatedBytes</code> is optional, but the more accurate the value, the more accurate your loaders' overall progress will be initially. If the loader will be inserted into a LoaderMax instance (for queue management), its <code>auditSize</code> feature can attempt to automatically determine the <code>bytesTotal</code> at runtime (there is a slight performance penalty for this, however - see LoaderMax's documentation for details).
		*/
		public var estimatedBytes:uint;
		[Inspectable(category="General")]
		/**
			If you define an <code>alternateURL</code>, the loader will initially try to load from its original <code>url</code> and if it fails, it will automatically (and permanently) change the loader's <code>url</code> to the <code>alternateURL</code> and try again. Think of it as a fallback or backup <code>url</code>. It is perfectly acceptable to use the same <code>alternateURL</code> for multiple loaders (maybe a default image for various ImageLoaders for example).
		*/
		public var alternateURL:String = "";
		[Inspectable(category="General")]
		/**
			If <code>true</code>, a "cacheBusterID" parameter will be appended to the url with a random set of numbers to prevent caching (don't worry, this info is ignored when you <code>LoaderMax.getLoader()</code> or <code>LoaderMax.getContent()</code> by <code>url</code> or when you're running locally)
		*/
		public var noCache:Boolean;
		[Inspectable(category="General")]
		/**
			LoaderMax supports <i>subloading</i>, where an object can be factored into a parent's loading progress. If you want LoaderMax to require this ImageLoader as part of its parent SWFLoader's progress, you must set the <code>requireWithRoot</code> property to your swf's <code>root</code>. For example, <code>var loader:ImageLoader = new ImageLoader("photo1.jpg", {name:"image1", requireWithRoot:this.root});</code>
		*/
		public var requireWithRoot:DisplayObject;
		[Inspectable(category="General")]
		/**
			When <code>autoDispose</code> is <code>true</code>, the loader will be disposed immediately after it completes (it calls the <code>dispose()</code> method internally after dispatching its <code>COMPLETE</code> event). This will remove any listeners that were defined in the vars object (like onComplete, onProgress, onError, onInit). Once a loader is disposed, it can no longer be found with <code>LoaderMax.getLoader()</code> or <code>LoaderMax.getContent()</code> - it is essentially destroyed but its content is not unloaded (you must call <code>unload()</code> or <code>dispose(true)</code> to unload its content). The default <code>autoDispose</code> value is <code>false</code>.
		*/
		public var autoDispose:Boolean;
		
		
		
		
		
		// Method Shortcuts
		
		[Inspectable(category="General")]
		/**
			A handler function for <code>LoaderEvent.OPEN</code> events which are dispatched when the loader begins loading. Make sure your onOpen function accepts a single parameter of type <code>LoaderEvent</code> (<code>com.greensock.events.LoaderEvent</code>).
		*/
		public var onOpen:Function = function(e:LoaderEvent):void { };
		[Inspectable(category="General")]
		/**
			A handler function for <code>LoaderEvent.INIT</code> events which are called when the image has downloaded and has been placed into the ContentDisplay Sprite. Make sure your onInit function accepts a single parameter of type <code>LoaderEvent</code> (<code>com.greensock.events.LoaderEvent</code>).
		*/
		public var onInit:Function = function(e:LoaderEvent):void { };
		[Inspectable(category="General")]
		/**
			A handler function for <code>LoaderEvent.PROGRESS</code> events which are dispatched whenever the <code>bytesLoaded</code> changes. Make sure your onProgress function accepts a single parameter of type <code>LoaderEvent</code> (<code>com.greensock.events.LoaderEvent</code>). You can use the LoaderEvent's <code>target.progress</code> to get the loader's progress value or use its <code>target.bytesLoaded</code> and <code>target.bytesTotal</code>.
		*/
		public var onProgress:Function = function(e:LoaderEvent):void { };
		[Inspectable(category="General")]
		/**
			A handler function for <code>LoaderEvent.COMPLETE</code> events which are dispatched when the loader has finished loading successfully. Make sure your onComplete function accepts a single parameter of type <code>LoaderEvent</code> (<code>com.greensock.events.LoaderEvent</code>).
		*/
		public var onComplete:Function = function(e:LoaderEvent):void { };
		[Inspectable(category="General")]
		/**
			A handler function for <code>LoaderEvent.CANCEL</code> events which are dispatched when loading is aborted due to either a failure or because another loader was prioritized or <code>cancel()</code> was manually called. Make sure your onCancel function accepts a single parameter of type <code>LoaderEvent</code> (<code>com.greensock.events.LoaderEvent</code>).
		*/
		public var onCancel:Function = function(e:LoaderEvent):void { };
		[Inspectable(category="General")]
		/**
			A handler function for <code>LoaderEvent.ERROR</code> events which are dispatched whenever the loader experiences an error (typically an IO_ERROR or SECURITY_ERROR). An error doesn't necessarily mean the loader failed, however - to listen for when a loader fails, use the <code>onFail</code> special property. Make sure your onError function accepts a single parameter of type <code>LoaderEvent</code> (<code>com.greensock.events.LoaderEvent</code>).
		*/
		public var onError:Function = function(e:LoaderEvent):void { };
		[Inspectable(category="General")]
		/**
			A handler function for <code>LoaderEvent.FAIL</code> events which are dispatched whenever the loader fails and its <code>status</code> changes to <code>LoaderStatus.FAILED</code>. Make sure your onFail function accepts a single parameter of type <code>LoaderEvent</code> (<code>com.greensock.events.LoaderEvent</code>).
		*/
		public var onFail:Function = function(e:LoaderEvent):void { };
		[Inspectable(category="General")]
		/**
			A handler function for <code>LoaderEvent.IO_ERROR</code> events which will also call the onError handler, so you can use that as more of a catch-all whereas <code>onIOError</code> is specifically for LoaderEvent.IO_ERROR events. Make sure your onIOError function accepts a single parameter of type <code>LoaderEvent</code> (<code>com.greensock.events.LoaderEvent</code>).
		*/
		public var onIOError:Function = function(e:LoaderEvent):void { };
		[Inspectable(category="General")]
		/**
			A handler function for <code>LoaderEvent.HTTP_STATUS</code> events. Make sure your onHTTPStatus function accepts a single parameter of type <code>LoaderEvent</code> (<code>com.greensock.events.LoaderEvent</code>). You can determine the httpStatus code using the LoaderEvent's <code>target.httpStatus</code> (LoaderItems keep track of their <code>httpStatus</code> when possible, although certain environments prevent Flash from getting httpStatus information).
		*/
		public var onHTTPStatus:Function = function(e:LoaderEvent):void { };
		[Inspectable(category="General")]
		/**
			A handler function for <code>LoaderEvent.SECURITY_ERROR</code> events which onError handles as well, so you can use that as more of a catch-all whereas onSecurityError is specifically for SECURITY_ERROR events. Make sure your onSecurityError function accepts a single parameter of type <code>LoaderEvent</code> (<code>com.greensock.events.LoaderEvent</code>).
		*/
		public var onSecurityError:Function = function(e:LoaderEvent):void { };
		[Inspectable(category="General")]
		/**
			A handler function for <code>LoaderEvent.SCRIPT_ACCESS_DENIED</code> events which are dispatched when the image is loaded from another domain and no crossdomain.xml is in place to grant full script access for things like smoothing or BitmapData manipulation. You can also check the loader's <code>scriptAccessDenied</code> property after the image has loaded. Make sure your function accepts a single parameter of type <code>LoaderEvent</code> (<code>com.greensock.events.LoaderEvent</code>).
		*/
		public var onScriptAccessDenied:Function = function(e:LoaderEvent):void { };
		
		
		public function ImageLoaderObject()	{
			super();
		}
	}
}