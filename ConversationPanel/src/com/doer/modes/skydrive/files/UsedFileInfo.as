package com.doer.modes.skydrive.files
{
	import com.metaedu.client.messages.nebula.NebulaFileStatus;
	import com.metaedu.client.messages.nebula.NebulaFileUsingType;
	
	import flash.events.EventDispatcher;

	public class UsedFileInfo
	{
		/**
		 * 上传中
		 * **/
		public static const UPLOADING:String = "UPLOADING";
		
		/**
		 * 转换中
		 * **/
		public static const TRANSING:String = "TRANSING";
		
		/**
		 * 就绪(表示可以被打开)
		 * **/
		public static const PREPARED:String = "PREPARED";
		
		/**
		 * 名字
		 * **/
		[Bindable]
		public var name:String = "";
		
		/**
		 * 文档状态
		 * **/
		[Bindable]
		public var statue:String = UPLOADING;
		
		/**
		 * 转换进度
		 * **/
		[Bindable]
		public var progress:Number = 0;
		
		/**
		 * 转换页数
		 * **/
		[Bindable]
		public var exchangeInfo:String = "0页";

		/** 
		 * 文档用途分类
		 *  */
		[Bindable]
		public var usingType:int = NebulaFileUsingType.DOCUMENT;
		
		/**
		 * 文件标示
		 * **/
		public var id:String = null;
		
		/**
		 * 文件fileId
		 * **/
		[Bindable]
		public var fileId:String = null;
		
		/**
		 * 文件后缀
		 * **/
		public var suffix:String = null;
		
		
		/**
		 * 文件总页数
		 * **/
		public var total:int = 0;
		
		private var _pages:int = 0;
		
		
		/**
		 * 当前转换了多少页
		 * **/
		public function get pages():int
		{
			return _pages;
		}

		/**
		 * @private
		 */
		public function set pages(value:int):void
		{
			_pages = value;
			
			if(value != 0)
			{
				statue = PREPARED;
				
				exchangeInfo = value + "页";
			}
			
		}
		
		/**
		 * 获取文件是否ppt
		 * **/
		public static function isPPT(suffix:String):Boolean
		{
			var value:String = suffix.toLocaleLowerCase();
			
			return value == "ppt" || value == "pptx";
		}

		/**
		 * 文件是否doc文档
		 * **/
		public static function isDoc(suffix:String):Boolean
		{
			var value:String = suffix.toLocaleLowerCase();
			
			return value == "doc" || value == "docx";
			
		}
		
		/**
		 * 是否是图片
		 * **/
		public static function isImage(suffix:String):Boolean
		{
			var value:String = suffix.toLocaleLowerCase();
			
			return value == "png" || value == "jpg" || value == "jpeg" || value == "gif";
		}
		
		/***
		 * 是否txt
		 * **/
		public static function isTxt(suffix:String):Boolean
		{
			var value:String = suffix.toLocaleLowerCase();
			
			return value == "txt";
		}
		
		/**
		 * 是否pdf
		 * **/
		public static function isPdf(suffix:String):Boolean
		{
			var value:String = suffix.toLocaleLowerCase();
			
			return value == "pdf";
		}
		
		/**
		 * 文件是否excel
		 * **/
		public static function isExcel(suffix:String):Boolean
		{
			var value:String = suffix.toLocaleLowerCase();
			
			return value == "xls" || value == "xlsx";
			
		}
		
		/**
		 * 是否音频文件*.mp3, *.wma, *.aac
		 * **/
		public static function isAudio(suffix:String):Boolean
		{
			var value:String = suffix.toLocaleLowerCase();
			
			return value == "mp3" || value == "wma" || value == "aac";
				
		}
		
		/**
		 * 是否视频文件*.flv,*.mp4,*.avi,*.wmv
		 * **/
		public static function isVideo(suffix:String):Boolean
		{
			var value:String = suffix.toLocaleLowerCase();
			
			return value == "flv" || value == "mp4" || value == "avi" || value == "wmv";
		}
		
	}
}




