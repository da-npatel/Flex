package com.digitalaisle.utils
{
	import com.greensock.dataTransfer.XMLManager;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import org.casalib.util.ArrayUtil;
	
	public class XMLQueLoaderUtil extends EventDispatcher
	{
		
		private var _remainingInQue:int;
		private var _isRunning:Boolean = false;
		private var _invalidXMLSources:Array = new Array();
		private var _xmlManager:XMLManager = new XMLManager();
		private var _xmlQue:Array = new Array();
		private var _xmlData:Array = new Array();
		private var _processedXML:Array = new Array();
		private var _totalCueCount:int = 0;
		private var _allXMLData:Array = new Array();
		private var _urlLoader:URLLoader = new URLLoader();
		
		public function XMLQueLoaderUtil()
		{
			_urlLoader.addEventListener(Event.COMPLETE, onXMLLoaded);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onXMLError);
			//_xmlManager.addEventListener(Event.COMPLETE, onXMLLoaded);
			//_xmlManager.addEventListener(IOErrorEvent.IO_ERROR, onXMLError);
		}
		
		/**
		 * Adds a url to the que to be loaded upon starting of the que
		 * 
		 * @param label Label used to identify the XML file.  Used to retrieve the loaded XML data.
		 * @param url The URL to load
		 * @param keepRootNode Controls whether or not the root node of the XML is ignored when parsing (doing so can make your code a bit shorter).
		 * @param parseLineBreaks If true, line breaks in XML will be recognized ("\n" added in the ActionScript).
		 * 
		 */		
		public function addToQue(label:String, url:String, keepRootNode:Boolean=false, parseLineBreaks:Boolean=false):void
		{
			trace(url);
			_totalCueCount++;
			_xmlQue.push({label:label, url:url, keepRootNode:keepRootNode, parseLineBreaks: parseLineBreaks});
			_remainingInQue = _xmlQue.length;
		}
		
		/**
		 * Starts the que
		 */		
		public function startQue():void
		{
			if(_xmlQue.length > 0)
			{
				// if running don't rerun
				_isRunning = true;
				processQue();
			}	
		}
		
		// TODO: Needs Implementation
		public function pauseQue():void
		{
			
		}
		
		public function empty():void
		{
			_xmlData = [];
		}
		
		/**
		 * Destroys instance XMLManager and xml data in turn releasing it for garbage collection.s
		 */		
		public function destroy():void
		{
			_urlLoader.removeEventListener(Event.COMPLETE, onXMLLoaded);
			_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onXMLError);
			//_xmlManager.destroy();
			 _urlLoader = null;
			_xmlData = _xmlQue = _invalidXMLSources = [];
		}
		
		/**
		 * Retreives the loaded XML Object based on it's label
		 * 
		 * @param label Label used to identify loaded XML url
		 * @return Parsed Object
		 */		
		public function getValueOf(label:String):Object
		{
			var targetObject:Object;
			
			for(var i:int = 0; i < _allXMLData.length; i++)
			{
				if(label == _allXMLData[i].label) 
				{
					targetObject = _allXMLData[i].data;
					break;
				}
			}
			
			if(targetObject) return targetObject;
			else trace("Warning: The requested xml data by the label of " + label + "is not available.  Please check the spelling and/or verify if the label is valid");
			
			return _xmlData[label];
		}
		
		/** @private Handles the processing of the XML urls in que **/
		private function processQue():void
		{
			if(_xmlQue.length > 0)
			{
				var currentPosition:int = _xmlQue.length - 1;
				_urlLoader.load(new URLRequest(_xmlQue[currentPosition].url));
				//_xmlManager.load(_xmlQue[currentPosition].url, _xmlQue[currentPosition].keepRootNode, _xmlQue[currentPosition].parseLineBreaks);
			}else
			{
				_isRunning = false;
				_totalCueCount = 0;
				
				ArrayUtil.addItemsAt(_allXMLData, _xmlData, _allXMLData.length);
				
				dispatchEvent(new Event(Event.COMPLETE));
			}	
		}
		
		/** @private **/
		private function onXMLLoaded(e:Event):void
		{
			var currentPosition:int = _xmlQue.length - 1;
			
			_xmlData.push({label: _xmlQue[currentPosition].label, data: new XML(e.target.data)/*e.target.parsedObject*/});
			_xmlQue.pop();
			processQue();
		}
		
		/** @private **/
		private function onXMLError(e:IOErrorEvent):void
		{
			var currentPosition:int = _xmlQue.length - 1;
			//Remove from que list and to invalid XML list
			_invalidXMLSources.push(_xmlQue[currentPosition]);
			dispatchEvent(e);
			_xmlQue.pop();
			processQue();
		}

//---- GETTERS / SETTERS --------------------------------------------------------------------

		/** Reamining XML urls in que **/
		public function get remainingInQue():int
		{
			_remainingInQue = _xmlQue.length;
			return _remainingInQue;
		}

		/** Whether the que is running **/
		public function get isRunning():Boolean
		{
			return _isRunning;
		}

		/** All XML urls that were not loaded **/
		public function get invalidXMLSources():Array
		{
			return _invalidXMLSources;
		}

		/** All availale XML data **/
		public function get xmlData():Array
		{
			return _xmlData;
		}

		public function get totalCueCount():int
		{
			return _totalCueCount;
		}

	}
}