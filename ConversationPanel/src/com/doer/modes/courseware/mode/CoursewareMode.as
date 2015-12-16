package com.doer.modes.courseware.mode
{
	import com.doer.common.Delegation;
	import com.doer.meta.paint.PaintStyle;
	import com.doer.meta.paint.ShapeStyle;
	import com.doer.modes.blackbord.BlackbordMode;
	import com.doer.utils.LocalCommandType;
	import com.metaedu.client.messages.nebula.ServerComplexAddFileInform;
	import com.metaedu.client.messages.nebula.ServerComplexAddFilePageInform;
	import com.metaedu.client.messages.nebula.complex.DocumentContainer;
	import com.metaedu.client.messages.nebula.complex.DocumentUnit;
	import com.metaedu.client.messages.nebula.complex.PageUnit;
	import com.metaedu.client.messages.nebula.complex.draw.DrawOperation;

	public class CoursewareMode 
	{
		private static var instance:CoursewareMode = null;
		
		/**
		 * 绘图数据
		 * **/
		public var paintData:Vector.<CoursewarePaintData> = null;
		
		/**
		 * 文档
		 * **/
		public var documents:Vector.<DocumentUnit> = new Vector.<DocumentUnit>();
		
		public static function getInstance():CoursewareMode
		{
			if(instance == null)
				instance = new CoursewareMode(new Inner());
			
			return instance;
		}
		
		public function CoursewareMode(inner:Inner)
		{
			paintData = new Vector.<CoursewarePaintData>();
		}
		
		/**
		 * 重置到最初状态
		 * **/
		public function reset():void
		{
			documents = new Vector.<DocumentUnit>();
			paintData = new Vector.<CoursewarePaintData>();
		
		}
		
		/**
		 * 获取文档信息
		 * **/
		public function getDocumentById(id:String):DocumentUnit
		{
			for each( var info:DocumentUnit in documents)
			{
				if(info.id == id)
					return info;
			}
			
			return null;
		}
		
		/**
		 * 添加文档
		 * **/
		public function addInvalidateDocments(documentInfo:DocumentContainer,delegation:Delegation):void
		{		
			
			if(!delegation.isSecondScreen)
			{
				delegation.curBookId = documentInfo.activeDocument;
				this.documents = documentInfo.contents;
				
				for(var i:int = 0; i < documents.length; i ++)
				{
					if(documents[i].id == delegation.curBookId)
					{
						delegation.curPage = documents[i].activePage;
						
						for each(var pa:PageUnit in documents[i].pages)
						{
							if(pa.index == delegation.curPage)
							{
								delegation.curFrame = pa.step;
								break;
							}
						}
						
					}
					
					documents[i].pages.sort(onSort);
					
					for(var j:int = 0; j < documents[i].pages.length; j ++)
					{
						for(var k:int = 0; k < documents[i].pages[j].draws.length; k ++)
						{
							var draws:DrawOperation = documents[i].pages[j].draws[k];
							
							var data:Object = {
								
								x : draws.x,
									y : draws.y,
									w : draws.width,
									h : draws.height,
									sw : draws.horizontalPixels,
									sh : draws.verticalPixels,
									r : draws.rotation,
									s : draws.method,
									t : draws.size,
									a : draws.url,
									c : draws.color,
									d : new Array()
									
							}
							
							for(var c:int = 0; c < draws.dots.length; c ++)
							{
								data.d.push({
									x : draws.dots[c].x,
									y : draws.dots[c].y,
									p : draws.dots[c].p
									
								});
							}
							
							savePaintData(data,documents[i].id,documents[i].pages[j].index);
							
						}
					}
				}
				
			}else
			{
				
				delegation.curBookId = documentInfo.activeDocument2;
				
				for(i = 0; i < documents.length; i ++)
				{
					if(documents[i].id == delegation.curBookId)
					{
						delegation.curPage = documents[i].activePage;
						
						for each(pa in documents[i].pages)
						{
							if(pa.index == delegation.curPage)
							{
								delegation.curFrame = pa.step;
								break;
							}
						}
						
						break;
					}
					
				}
			}
			
		}
		
		private var releaseQueue:Vector.<ServerComplexAddFilePageInform> = new Vector.<ServerComplexAddFilePageInform>();
		
		/**
		 * 添加文件消息
		 * **/
		public function addFileInfo(fileInfo:ServerComplexAddFileInform):void
		{
			var doc:DocumentUnit = new DocumentUnit();
			
			doc.name = fileInfo.name;
			doc.suffix = fileInfo.suffix;
			doc.id = fileInfo.id;
			doc.fileId = fileInfo.fileId;
			doc.detail = fileInfo.detail;
			
			documents.push(doc);
			
			var isContinue:Boolean = true;
			
			while(isContinue)
			{
				isContinue = false;
				
				for( var i:int = 0; i < releaseQueue.length; i ++)
				{
					if(releaseQueue[i].id == doc.id)
					{
						var pageUint:PageUnit = new PageUnit();
						pageUint.index = releaseQueue[i].page;
						
						doc.pages.push(pageUint);
						
						doc.pages.sort(onSort);
						
						releaseQueue.splice(i,1);
						
						isContinue = true;
						break;
					}
				}
			}
			
		}
		
		/**
		 * 添加可见页
		 * **/
		public function addPageInfo(info:ServerComplexAddFilePageInform):void
		{
			var isIn:Boolean = false;
			
			for(var i:int = 0; i < documents.length; i ++)
			{
				if(documents[i].id == info.id)
				{
					var pageUint:PageUnit = new PageUnit();
					pageUint.index = info.page;
					
					documents[i].pages.push(pageUint);
					
					documents[i].pages.sort(onSort);
					
					isIn = true;
					
					break;
				}
			}
			
			if(!isIn)
				releaseQueue.push(info);
			
		}
		
		private function onSort(page1:PageUnit,page2:PageUnit):int
		{
			if(page1.index < page2.index)
			{
				return -1;
			}else if(page1.index > page2.index)
			{
				return 1;
			}
			
			return 0;
		}
		
		/**
		 * 清除当前页的绘图数据
		 * **/
		public function clearPaintdata(bookId:String,page:int):void
		{
			for(var i:int = 0; i < paintData.length; i ++)
			{
				if(paintData[i].bookId == bookId && paintData[i].pageId == page)
				{
					paintData.splice(i,1);
					break;
				}
			}
		}
		
		/**
		 * 添加绘图数据
		 * **/
		public function savePaintData(data:Object,book:String,page:int):void
		{
			for each(var paint:CoursewarePaintData in paintData)
			{
				if(paint.bookId == book && paint.pageId == page)
				{
					paint.addPaintData(data);
					return;
				}	
			}
			
			var coursewarePaintData:CoursewarePaintData = new CoursewarePaintData(book,page);
			
			if(book != null)
				coursewarePaintData = new CoursewarePaintData(book,page);
			
			paintData.push(coursewarePaintData);
			coursewarePaintData.addPaintData(data);
			
		}
		
		/**
		 * 获取初始化绘图数据
		 * **/
		public function getInvalidatePaintData(bookId:String,pageId:int):Array
		{
			var arr:Array = new Array();
			
			for each(var paint:CoursewarePaintData in paintData)
			{
				if(paint.bookId == bookId && paint.pageId == pageId)
				{
					arr = paint.paintDatas;
					break;
				}
				
			}
			
			return arr;
		}
		
		
	}
}

class Inner{};