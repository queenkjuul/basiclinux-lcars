/* ==================================================================
FILE:   CntTool.js
DESCR:  Contents control library file for Netscape Help implementation.
NOTES:  Requires Utility.js
================================================================== */
var ASSERT = true

var contentsObj

var aDatasets      = new Array()
var aTmpContainers = new Array()
var aTmpItems      = new Array()

/*
DESCR:   Contents class.
PARAMS:  bgcolor  Background color for the Contents tool.
RETURNS: 
NOTES:   
*/
function contents( bgcolor )
{
   //top.SystemFrame.trace( "contents construct" )
   //alert( "contents construct" )

   this.bgcolor = bgcolor

   this.lastToggledContainerIndex

   this.bContainerToggle = false
   this.bItemSelected    = false
   this.currentDataset   = ""

   this.setDataset     = setDataset
   this.updateTree     = updateTree
   this.updateEntries  = updateEntries
   this.writeDocument  = writeDocument
   this.scrollDocument = scrollDocument
   this.containerClick = containerClick
   this.itemClick      = itemClick

   // Set global reference to this component.
   contentsObj = this

   // Load data.
   loadData()
}

   /*
   DESCR:   Selects a dataset for the tool.
   PARAMS:  indexName  The name that indexes the dataset in the
                       datasets array.
   RETURNS: 
   NOTES:   
   */
   function setDataset( indexName )
   {
      //alert( "setDataset, " + indexName )
      //top.SystemFrame.trace( "contents setDataset()" )

      this.currentDataset = indexName
   }

   /*
   DESCR:   Updates the Contents tree.
   PARAMS:  newURL  The current topic. Passing a URL expands its container
            as needed and selects the item representing the URL. If updating
            to just to toggle a container, pass null.
   RETURNS: 
   NOTES:   
   */
   function updateTree( newURL )
   {
      //top.SystemFrame.trace( "contents updateTree()" )
      //alert( "updateTree" )

      assert( ( this.currentDataset != "" ), DATASET )

      // Write a background color to the hidden frame, and bind its events to
      // the global handlers.
      frames[ 0 ].document.open()
      var html = "<BODY BGCOLOR = " + this.bgcolor + ">"
      html += "<SCRIPT LANGUAGE = 'JavaScript1.2'>"
      html += "top.bindDocEvts( document )"
      html += "</SCRIPT></BODY>"
      frames[ 0 ].document.write( html )
      frames[ 0 ].document.close()

      // Bind hidden frame events to global event handlers.
      top.bindDocEvts( frames[ 0 ].document )

      // Determine if this is an update just to toggle a container.
      this.bContainerToggle = ( ( typeof( newURL ) == "undefined" ) ? true : false )

      // Update the entry objects.
      if ( !this.bContainerToggle ) this.updateEntries( newURL )

      // Write the tree.
      this.writeDocument()

      // Bind event handlers.
      top.bindDocEvts( ContentsFrame.document )

      // Scroll the tree.
      if ( this.bItemSelected ) this.scrollDocument()
   }

   /*
   DESCR:   Updates the tree entry objects.
   PARAMS:  newURL  The URL from updateTree().
   RETURNS: 
   NOTES:  
   */
   function updateEntries( newURL )
   {
      //top.SystemFrame.trace( "contents updateEntries()" )
      //alert("updateEntries()")

      var aTmpContainers = aDatasets[ this.currentDataset ]

      // Check each item...
      var itemsSelected = 0  // Assert only.
      this.bItemSelected = false
      for ( var i = 0; i < aTmpContainers.length; i++ ) {
         for ( var j = 0; j < aTmpContainers[ i ].aItems.length; j++ ) {
            with ( aTmpContainers[ i ].aItems[ j ] ) {
               
               // ...and turn off any that are selected...
               if ( bSelected ) bSelected = false

               // ...and select the specified item...
               if ( URLsSansPathsAreSame( URL, newURL ) ) {

                  itemsSelected++
                  assert( ( itemsSelected < 2 ), ITEMS_SELECTED )

                  bSelected = true
                  this.bItemSelected = true

                  // ...making sure the selected item's container is expanded.
                  aTmpContainers[ i ].bExpanded = true
               }
            }
         }
      }
   }

   /*
   DESCR:   Scrolls the tree.
   PARAMS:  
   RETURNS: 
   NOTES:   If update is triggered outside of tool, we want to scroll as
            needed to the selected item to show where user is in the tree.
            Same for an item click, so the item is visible. For a container
            click, we only want to scroll to the clicked container, since
            the user is just looking for, or covering up, items.
   */
   function scrollDocument()
   {
      //top.SystemFrame.trace( "contents scrollDocument()" )
      //alert("scrollDocument")

      // Ignore scrolling if content does not exceed window.
      if ( frames[ 1 ].document.height < frames[ 1 ].innerHeight ) return

      // Calculate our best guess of pixel magnitude along the y axis of tree
      // window for the item we want to make visible.
      var aTmpContainers  = aDatasets[ this.currentDataset ]
      var y               = 0
      var containerHeight = 11
      var itemHeight      = 11
      var topMargin       = 4
      var bottomMargin    = 4
      var wrapLeading     = 4
      var charPerLine     = 14
            
      // Tally pixels for entries.
      for ( var i = 0; i < aTmpContainers.length; i++ ) {

         // Tally for the container. Tally must account for how
         // many lines the entry takes up, including the spacing between
         // lines that wrap.
         var lines = Math.ceil( aTmpContainers[ i ].text.length / charPerLine )
         y += topMargin +
              ( containerHeight * lines ) +
              ( wrapLeading * ( lines - 1 ) ) +
              bottomMargin

         // If just toggling a container, tally only to the newly
         // toggled container.
         if ( this.bContainerToggle && this.lastToggledContainerIndex == i ) {
            break
         }

         // Tally items in opened containers.
         if ( aTmpContainers[ i ].bExpanded ) {
            for ( var j = 0; j < aTmpContainers[ i ].aItems.length; j++ ) {
               
               // Tally for the item.
               var tmpItemLength = aTmpContainers[ i ].aItems[ j ].text.length
               lines = Math.ceil( tmpItemLength / charPerLine )
               y += topMargin +
                    ( itemHeight * lines ) +
                    ( wrapLeading * ( lines - 1 ) ) +
                    bottomMargin

               // If updating for a newly selected item, stop all tallying
               // when we get to the selected item.
               if ( !this.bContainerToggle &&
                    aTmpContainers[ i ].aItems[ j ].bSelected ) {
                  i = ( aTmpContainers.length )
                  break
               }
            }
         }
      }

      // Scroll to bring the entry to the middle of the window.
      var frameHeight = frames[ 1 ].innerHeight
      var center = ( frameHeight / 2 )
      if ( y > center ) frames[ 1 ].scrollTo( 0, y - center )
   }

   /*
   DESCR:   Writes the tree document.
   PARAMS:  
   RETURNS: 
   NOTES:   
   */
   function writeDocument()
   {
   

   
      //top.SystemFrame.trace( "contents writeDocument()" )
	  //alert("writeDocument");

      var aTmpContainers = aDatasets[ this.currentDataset ];
      var link;
      var platForm = navigator.platform;
      
	if ((platForm == "Win32")) {
	  var html = "<HTML><HEAD>"
      html += "<STYLE TYPE = 'text/javascript'>"
      html += "classes.container.a.fontFamily = 'helvetica, arial';"
      html += "classes.container.a.fontSize = '14px';"
      html += "classes.container.a.fontWeight = 'bold';"
      html += "classes.container.a.marginTop = '12';"
      html += "classes.container.a.marginBottom = '4';"
      html += "classes.container.a.color = '#000000';"
      
      html += "classes.unselectedItem.a.fontFamily = 'helvetica, arial';"
      html += "classes.unselectedItem.a.fontSize = '14px';"
      html += "classes.unselectedItem.a.marginLeft = '4';"
      html += "classes.unselectedItem.a.marginTop = '8';"
      html += "classes.unselectedItem.a.marginLeft = '8';"
      html += "classes.unselectedItem.a.marginBottom = '4';"
      html += "classes.unselectedItem.a.color = '#000066';"
      
      html += "classes.selectedItem.a.fontFamily = 'helvetica, arial';"
      html += "classes.selectedItem.a.fontSize = '14px';"
      html += "classes.selectedItem.a.fontWeight = 'bold';"
      html += "classes.selectedItem.a.marginLeft = '4';"
      html += "classes.selectedItem.a.marginTop = '8';"
      html += "classes.selectedItem.a.marginLeft = '8';"
      html += "classes.selectedItem.a.marginBottom = '4';"
      html += "classes.selectedItem.a.color = '#000066';"
      html += "classes.selectedItem.a.fontWeight = 'bold';"
      html += "tags.a.textDecoration = 'none';"
      html += "</STYLE>"
				
	}
				
	else if ((platForm == "MacPPC") || (platForm == "Mac68k")) {
				
	  var html = "<HTML><HEAD>"
      html += "<STYLE TYPE = 'text/javascript'>"
      html += "tags.body.fontFamily = 'helvetica, arial';"
      html += "tags.body.fontSize = '10px';"
      html += "classes.container.a.fontFamily = 'helvetica, arial';"
      html += "classes.container.a.fontSize = '12px';"
      html += "classes.container.a.fontWeight = 'bold';"
      html += "classes.container.a.marginTop = 12;"
      html += "classes.container.a.marginBottom = 4;"
      html += "classes.container.a.color = '#000000';"

      html += "classes.unselectedItem.a.fontFamily = 'helvetica, arial';"
      html += "classes.unselectedItem.a.fontSize = '12px';"
      html += "classes.unselectedItem.a.marginLeft = 4;"
      html += "classes.unselectedItem.a.marginTop = 8;"
      html += "classes.unselectedItem.a.marginLeft = 8;"
      html += "classes.unselectedItem.a.marginBottom = 4;"
      html += "classes.unselectedItem.a.color = '#000066';"

      html += "classes.selectedItem.a.fontFamily = 'helvetica, arial';"
      html += "classes.selectedItem.a.fontSize = '12px';"
      html += "classes.selectedItem.a.fontWeight = 'bold';"
      html += "classes.selectedItem.a.marginLeft = 4;"
      html += "classes.selectedItem.a.marginTop = 8;"
      html += "classes.selectedItem.a.marginLeft = 8;"
      html += "classes.selectedItem.a.marginBottom = 4;"
      html += "classes.selectedItem.a.color = '#000066';"
      html += "classes.selectedItem.a.fontWeight = 'bold';"
      html += "tags.a.textDecoration = 'none';"
      html += "</STYLE>"
				
	}
				
	else {
				
	  var html = "<HTML><HEAD>"
      html += "<STYLE TYPE = 'text/javascript'>"
      html += "tags.body.fontFamily = 'helvetica, arial';"
      html += "tags.body.fontSize = '10pt';"
      html += "classes.container.a.fontFamily = 'helvetica, arial';"
      html += "classes.container.a.fontSize = '12pt';"
      html += "classes.container.a.fontWeight = 'bold';"
      html += "classes.container.a.marginTop = 12;"
      html += "classes.container.a.marginBottom = 4;"
      html += "classes.container.a.color = '#000000';"

      html += "classes.unselectedItem.a.fontFamily = 'helvetica, arial';"
      html += "classes.unselectedItem.a.fontSize = '10pt';"
      html += "classes.unselectedItem.a.marginLeft = 4;"
      html += "classes.unselectedItem.a.marginTop = 8;"
      html += "classes.unselectedItem.a.marginLeft = 8;"
      html += "classes.unselectedItem.a.marginBottom = 4;"
      html += "classes.unselectedItem.a.color = '#000066';"

      html += "classes.selectedItem.a.fontFamily = 'helvetica, arial';"
      html += "classes.selectedItem.a.fontSize = '10pt';"
      html += "classes.selectedItem.a.fontWeight = 'bold';"
      html += "classes.selectedItem.a.marginLeft = 4;"
      html += "classes.selectedItem.a.marginTop = 8;"
      html += "classes.selectedItem.a.marginLeft = 8;"
      html += "classes.selectedItem.a.marginBottom = 4;"
      html += "classes.selectedItem.a.color = '#000066';"
      html += "classes.selectedItem.a.fontWeight = 'bold';"
      html += "tags.a.textDecoration = 'none';"
      html += "</STYLE>"
				
	}




      html += "</HEAD><BODY BGCOLOR = " + this.bgcolor +
              " LINK = '#000000' ALINK = '#000000' VLINK = '#000000'>"
   
   


      for ( var i = 0; i < aTmpContainers.length; i++ ) {

         link = "\"javascript:parent.contentsObj.containerClick('" + this.currentDataset + "', " + i + ")\""
         html += "<A CLASS = 'container' HREF = " + link + ">" + aTmpContainers[ i ].text + "</A>"

         if ( aTmpContainers[ i ].bExpanded ) {
            for ( var j = 0; j < aTmpContainers[ i ].aItems.length; j++ ) {
               with ( aTmpContainers[ i ].aItems[ j ] ) {

                  var ssClass = ( bSelected ? "selectedItem" : "unselectedItem" )
                  link = "\"javascript:parent.contentsObj.itemClick('" + this.currentDataset + "', " + i + ", " + j + ")\""
                  html += "<A CLASS = '" + ssClass + "' HREF = " + link + ">" + text + "</A>"
               }
            }
         }
      }

      html += "</BODY></HTML>"

      with ( frames[ 1 ].document ) {
         open()
         write( html )
         close()
      }
   }

   /*
   DESCR:   Container object click "event."
   PARAMS:  datasetIndex    The dataset index.
            containerIndex  The container index.
   RETURNS: 
   NOTES:   
   */
   function containerClick( datasetIndex, containerIndex )
   {
      // Toggle the container's state.
      var obj = aDatasets[ datasetIndex ][ containerIndex ]
      obj.bExpanded = ( obj.bExpanded ? false : true )
      this.lastToggledContainerIndex = containerIndex
            
      // Update the tree.
      this.updateTree()
   }

   
   /*
   DESCR:   Item object click "event."
   PARAMS:  datasetIndex    The dataset index.
            containerIndex  The container index.
            itemIndex       The item index.
   RETURNS: 
   NOTES:   
   */
   function itemClick( datasetIndex, containerIndex, itemIndex )
   {
      // Notify component owner of selection, and update tree on success.
      var obj = aDatasets[ datasetIndex ][ containerIndex ].aItems[ itemIndex ]
      
      // Load the topic (location doesn't matter since it's a nethelp URL.
      location = obj.netHelpURL
   }


// End class definition: contents.

/*
DESCR:   Container class.
PARAMS:  text    The container's text.
         aItems  Array of item objects.
RETURNS: 
NOTES:   
*/
function container( text, aItems )
{
   this.text     = text
   this.aItems   = aItems

   this.bExpanded = false
}

// End class definition: container.

/*
DESCR:   Item class.
PARAMS:  text        The item's text.
         URL         The URL in non-NetHelp form.
         netHelpURL  The URL in NetHelp form.
RETURNS: 
NOTES:   
*/
function item( text, URL, netHelpURL )
{
   this.text       = text
   this.URL        = URL
   this.netHelpURL = netHelpURL

   this.bSelected = false
}

// End class definition: item.
