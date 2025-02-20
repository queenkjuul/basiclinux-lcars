/* ==================================================================
FILE:   System.js
DESCR:  System class for Netscape Help implementation.
NOTES:  
================================================================== */
// Dev. switches.
var TRACE           = false
var ASSERT          = true
var ERR_DLGS        = true
var ERRS_TO_CONSOLE = false

// "Constants."
var VERSION         = "2.0"
var LAYERED_TOPICS  = false
var JAVA_DEPENDENT  = false
var STAMP_CONSOLE   = false
var OK_NAV_VERSIONS = ".4."
var CHECK_HREFS     = false
var CONTENTS        = "CntTool.htm"
var INDEX           = "IdxTool.htm"
var SEARCH          = "SrhTool.htm"
var NAVUI           = "NavUI.htm"
var TOOLUI          = "ToolUI.htm"
var STATUS          = "Status.htm"
var MESSAGE_BGCOLOR = "#fafad2"
var TOOL_BGCOLOR    = "#99ccff"

//trace( "System.js" )

// Runtime error handling.
// window.onerror = errHandler

// Version stamp.
if ( STAMP_CONSOLE && navigator.javaEnabled() ) {
   java.lang.System.out.println( "System.js, version " + VERSION )
   java.lang.System.out.println( "Client: " + navigator.appVersion )
}

/*
DESCR:   Handles the onhelp event.
PARAMS:  URL  The URL to load.
RETURNS: 
NOTES:   
*/
function onHelpHandler( URL )
{
   //trace( "onHelpHandler(" + URL + ")" )
   //alert( "onHelpHandler(" + URL + ")" )

   systemObj.loadTopic( URL, false )
}

/*
DESCR:   Traces execution to the console.
PARAMS:  msg  The trace text.
RETURNS: 
NOTES:   
*/
function trace( msg )
{
   if ( TRACE ) java.lang.System.out.println( "System: " + msg )
}

// Create system object.
var systemObj = new system( JAVA_DEPENDENT, OK_NAV_VERSIONS )
assert( ( typeof( systemObj ) == "object" ), SYS_CONSTRUCT )

/*
DESCR:   Help implementation system class.
PARAMS:  bJavaDependent  Pass true if the system is Java dependent,
                         false if not.
         OKNavVersions   String representing valid versions of Navigator.
RETURNS: 
NOTES:   
*/
function system( bJavaDependent, OKNavVersions )
{
   //trace( "system constructor" )

   this.backStack    = new stack()
   this.forwardStack = new stack()

   this.navVersion
   this.topic
   this.contents

   //this.aSysSecWnds = new Array()  // Sys-owned secondary windows.

   this.currentTool       = CONTENTS  // Set default tool.
   this.bIdxTitlesPageUp  = false
   this.currentSubsystem  = ""
   this.visibleLayerIdx   = ""

   this.bToolUIloaded   = false
   this.bNavUIloaded    = false
   this.bContentsLoaded = false
   this.bIndexLoaded    = false
   this.bStarted        = false

   this.bNewSubsystem = false

   this.preproc           = preproc
   this.componentCallback = componentCallback
   this.idxTitlesUp       = idxTitlesUp
   this.loadTopic         = loadTopic
   this.newSubsystem      = newSubsystem
   this.exit              = exit
   this.print             = print
   this.back              = back
   this.forward           = forward
   //this.openSecWnd        = openSecWnd
   this.loadTool          = loadTool
   this.setToolButton     = setToolButton
   this.msg               = msg
   this.manageLayers      = manageLayers
   this.badURLerror       = badURLerror

   this.componentsReadyEvt = componentsReadyEvt
   this.loadEvt            = loadEvt
   this.unloadEvt          = unloadEvt

   this.stashPersistentData  = stashPersistentData
   this.snatchPersistentData = snatchPersistentData

   // Preprocessing.
   if ( !this.preproc( bJavaDependent, OKNavVersions ) ) {
      return
   }

   // Load components.
   top.StatusFrame.location.replace( STATUS )
   top.ToolUIFrame.location.replace( TOOLUI )
   top.NavFrame.location.replace( NAVUI )
   top.ToolFrame.location.replace( this.currentTool )
}

   /*
   DESCR:   Pre-Help processing.
   PARAMS:  bJavaDependent  Pass true if the system is Java dependent,
                            false if not.
            OKNavVersions   String representing valid versions of Navigator.
   RETURNS: 
   NOTES:   
   */
   function preproc( bJavaDependent, OKNavVersions )
   {
      //trace( "preproc()" )
      
      // Make sure Java is enabled if needed. Otherwise, abort.
      if ( bJavaDependent && !navigator.javaEnabled() ) {
         this.msg( NO_JAVA_ERR_MSG, "" )
         return false
      }

      // Validate version of navigator. Render in ".integer." form.
      var version = navigator.appVersion
      this.navVersion =
         "." + version.substring( 0, ( version.indexOf( "." ) + 1 ) )
      if ( OKNavVersions.indexOf( this.navVersion ) == -1 ) {
         this.msg( WRONG_NAV_VER_ERR_MSG, "" )
         return false
      }

      return true
   }

   /*
   DESCR:   Tracks component loading.
   PARAMS:  componentName  The document-name of the component.
   RETURNS: 
   NOTES:   Components call this method on load. Triggers ready
            event when all loaded.
   */
   function componentCallback( componentName )
   {
      //trace( "componentCallback(" + componentName + ")" )
      //alert( "componentCallback(" + componentName + ")" )

      // Track component loading.

      // Note: for some reason, can't write to status frame until Contents
      // is loaded, so we do this later.
      //if ( componentName == STATUS ) top.StatusFrame.setStatusWait()

      if ( componentName == TOOLUI ) this.bToolUIloaded = true

      if ( componentName == NAVUI ) this.bNavUIloaded = true

      if ( componentName == CONTENTS ) {

         // Keep house.
         top.StatusFrame.setStatusWait()
         top.ToolUIFrame.bDisableBtnBar = false
         this.bContentsLoaded = true
         this.bIndexLoaded = false

         // Create a Contents object.
         this.contents = new top.ToolFrame.contents( TOOL_BGCOLOR )
         assert( ( typeof( this.contents ) == "object" ), CNT_CONSTRUCT )

         // If this is not a system load and we're just changing to the
         // Contents tool, set the Content's dataset and update. Otherwise,
         // this will happen when a topic is loaded.
         if ( this.bStarted ) {
           this.contents.setDataset( this.currentSubsystem )
           this.contents.updateTree( this.topic.URL )

           top.StatusFrame.setStatusClear()
         }
      }

      if ( componentName == INDEX ) {
         top.ToolUIFrame.bDisableBtnBar = false
         this.bIndexLoaded = true
         this.bContentsLoaded = false

         if ( this.bStarted ) top.StatusFrame.setStatusClear()
      }

      // Set the blender button down for the current tool.
      if ( componentName == TOOLUI ) {
         this.setToolButton( ( this.currentTool == CONTENTS ? 0 : 1 ), 1 )
      }

      // Get moving if we're ready, but not already underway.
      if ( !this.bStarted &&
           this.bToolUIloaded && this.bNavUIloaded &&
           ( this.bContentsLoaded || this.bIndexLoaded ) ) {
         this.bStarted = true
         this.componentsReadyEvt()   
      }
   }

   /*
   DESCR:   Handles components ready "event."
   PARAMS:  
   RETURNS: 
   NOTES:   
   */
   function componentsReadyEvt()
   {
      //trace( "componentsReadyEvt()" )

      // Set onhelp handler.
      top.setOnhelpHandler( "onHelpHandler" )
   }

   /*
   DESCR:   Enables external state-setting of the tool UI button bar.
   PARAMS:  buttonIdx  Identifies the button on the bar.
            newState   The state to set.
   RETURNS: 
   NOTES:   
   */
   function setToolButton( buttonIdx, newState )
   {
      //trace( "setToolButton" )

      assert( defined( top.ToolUIFrame.btnBar ), TOOLUI )
      if ( defined( top.ToolUIFrame.btnBar ) ) {

         // Set.
         with ( top.ToolUIFrame.btnBar.aButtons[ buttonIdx ] ) {
            setState( newState )
            bOn = true
         }
      }
   }

   /*
   DESCR:   onload handler.
   PARAMS:  
   RETURNS: 
   NOTES:   
   */
   function loadEvt()
   {
      //trace( "loadEvt()" )
      //alert( "loadEvt()" )

      // Snatch important data for persistence on reload due to window resizing.
      this.snatchPersistentData()
   }

   /*
   DESCR:   onunload handler.
   PARAMS:  
   RETURNS: 
   NOTES:   
   */
   function unloadEvt()
   {
      //trace( "unloadEvt()" )
      //alert( "unloadEvt()" )

      // Stash important data for persistence on reload due to window resizing.
      this.stashPersistentData()

      // Clean up topic (topic-owned secondary windows, etc.).
      if ( defined( this.topic ) ) this.topic.destruct()

      // Close any system-owned secondary windows.
      //for ( var i = 0; i < this.aSysSecWnds.length; i++ ) {
      //   if ( defined( this.aSysSecWnds[ i ] ) ) this.aSysSecWnds[ i ].close()
      //}
   }

   /*
   DESCR:   Stores data needed to maintain state on reload due to resize.
   PARAMS:  
   RETURNS: 
   NOTES:   
   */
   function stashPersistentData()
   {
      //trace( "stashPersistentData" )

      if ( defined( top.aPersistentData ) ) {
         var i = 0
         top.aPersistentData[ i++ ] = this.currentTool
         top.aPersistentData[ i++ ] = this.forwardStack
         top.aPersistentData[ i++ ] = this.backStack
         //this.topic
         //this.visibleLayerIdx
      }
   }

   /*
   DESCR:   Retrieves data needed to maintain state on reload due to resize.
   PARAMS:  
   RETURNS: 
   NOTES:   
   */
   function snatchPersistentData()
   {
      //trace( "snatchPersistentData" )

      if ( defined( top.aPersistentData[ 0 ] ) ) {
         var i = 0
         this.currentTool  = top.aPersistentData[ i++ ]
         this.forwardStack = top.aPersistentData[ i++ ] 
         this.backStack    = top.aPersistentData[ i++ ]
      }
   }

   /*
   DESCR:   Loads the Contents, Index, or Find tool.
   PARAMS:  toolName  The document-name of the tool.
   RETURNS: 
   NOTES:   
   */
   function loadTool( toolName )
   {
      //trace( "loadTool(" + toolName + ")" )

      assert( ( toolName == CONTENTS ||
                toolName == INDEX ||
                toolName == SEARCH ), TOOLNAME )

      // Contents tool.
      if ( toolName == CONTENTS && !this.bContentsLoaded ) {

         // Keep house.
         top.StatusFrame.setStatusWait()
         top.ToolUIFrame.bDisableBtnBar = true

         top.ToolFrame.location.replace( toolName )
      }

      // Index tool.
      else if ( toolName == INDEX && !this.bIndexLoaded ) {

         // Keep house.
         top.StatusFrame.setStatusWait()
         top.ToolUIFrame.bDisableBtnBar = true

         top.ToolFrame.location.replace( toolName )
      }

      // Search tool.
      else if ( toolName == SEARCH ) {

         // We are using native find functionality in lieu of Search tool.
         // Be sure to invoke Find against the topic frame.
         top.TopicFrame.find()
      }

      // Track current tool, but exempt the search tool since we are just
      // using Find and we still have a Help tool loaded.
      if ( toolName != SEARCH ) this.currentTool = toolName
   }

   /*
   DESCR:   Closes the Help window.
   PARAMS:  
   RETURNS: 
   NOTES:   
   */
   function exit()
   {
      //trace( "exit()" )

      // Close frameset.
      top.close()
   }

   /*
   DESCR:   Moves back in Help history.
   PARAMS:  
   RETURNS: 
   NOTES:   Presumes button is disabled on empty stack.
   */
   function back()
   {
      //trace( "back()" )

      // Since the Index's titles page may be in the topic frame, but not
      // part of history, we don't really wan't to go Back. Just restore
      // the current topic without adding it to history.
      if ( this.bIdxTitlesPageUp ) {
         this.loadTopic( this.topic.URL, false )
         return
      }

      assert( !this.backStack.isEmpty(), BACK_STACK )
      this.forwardStack.push( this.topic.URL )
      this.loadTopic( this.backStack.pop(), true )
   }

   /*
   DESCR:   Moves forward in Help history.
   PARAMS:  
   RETURNS: 
   NOTES:   Presumes button is disabled on empty stack.
   */
   function forward()
   {
      //trace( "forward()" )

      assert( !this.forwardStack.isEmpty(), FORWARD_STACK )
      this.backStack.push( this.topic.URL )
      this.loadTopic( this.forwardStack.pop(), true )
   }

   /*
   DESCR:   Tracks the Index's topic titles page in the topic window.
   PARAMS:  
   RETURNS: 
   NOTES:   
   */
   function idxTitlesUp()
   {
      //trace ( "idxTitlesUp()" )
      
      this.bIdxTitlesPageUp = true

      // The Index titles page is not part of the topics history, so make
      // sure that Forward is disabled and Back is enabled.
      assert( defined( top.NavFrame.btnBar ), NAV_BAR )
      if ( defined( top.NavFrame.btnBar ) ) {
         top.NavFrame.btnBar.aButtons[ 0 ].enable( true )
         top.NavFrame.btnBar.aButtons[ 1 ].enable( false )
      }
   }

   /*
   DESCR:   Handles tasks when the Help subsystem changes.
   PARAMS:  newSubsystem  A simple filename representing the subsystem
                          (the topic filename).
   RETURNS: 
   NOTES:   
   */
   function newSubsystem( newSubsystem )
   {
      //trace( "newSubsystem('" + newSubsystem + "')" )
      //alert( "newSubsystem('" + newSubsystem + "')" )

      assert( ( newSubsystem.toLowerCase().indexOf( ".htm" ) > -1 ),
              SUBSYS_VALUE + newSubsystem )

      // Track the current subsystem.
      this.currentSubsystem = newSubsystem

      // Reinitialize the visible layer index, since nothing is visible yet.
      this.visibleLayerIdx = ""

      // Load the new header.
//      top.HeaderFrame.location.replace( this.topic.headerURL )

      // Set the Contents tool's dataset.
      if ( this.currentTool == CONTENTS ) {
         this.contents.setDataset( newSubsystem )
      }
   }

   /*
   DESCR:   Loads a topic.
   PARAMS:  URL           The non-nethelp version of the URL.
            bHistoryLoad  true if this is a load due to Back or Forward;
                          false, otherwise.
   RETURNS: 
   NOTES:   
   */
   function loadTopic( URL, bHistoryLoad )
   {
      //trace( "loadTopic(" + URL + ")" )

      assert( ( URL.toLowerCase().indexOf( ".htm" ) > -1 ), URL_VALUE + URL )

      // Update Index titles page flag. If we are loading a topic, it can't
      // be the URL in the topic window.
      this.bIdxTitlesPageUp = false

      // Keep house if there is an existing topic...
      if ( defined( this.topic ) ) {

         // Track as history, if this is _not_ a history load, and if we are
         // not reloading the same URL for some (good) reason. Note that
         // forward stack should be cleared.
         if ( !bHistoryLoad && ( this.topic.URL != URL ) ) {
            this.backStack.push( this.topic.URL )
            this.forwardStack.clear()
         }

         // "Destruct" the current topic.
         this.topic.destruct()
      } 

      // See if we need to change subsystems.
      var bNewSubsystem =
         ( makeSimpleFilename( URL ) != this.currentSubsystem ? true : false )

      // If we're loading a new topic file, set the wait indicator.
      if ( bNewSubsystem ) top.StatusFrame.setStatusWait()

      // Create new topic object. Must happen before updating subsystem.
      this.topic = new helpTopic( URL )
      assert( ( typeof( this.topic ) == "object" ), TOPIC_CONSTRUCT )

      // Update current subsystem. Must happen before updating Contents tree
      // or managing layers.
      if ( bNewSubsystem ) this.newSubsystem( makeSimpleFilename( URL ) )

      // Enable/disable history buttons.
      assert( defined( top.NavFrame.btnBar ), NAV_BAR )
      if ( defined( top.NavFrame.btnBar ) ) {
         var bEnable
         bEnable = ( this.backStack.isEmpty() ? false : true )
         top.NavFrame.btnBar.aButtons[ 0 ].enable( bEnable )
         bEnable = ( this.forwardStack.isEmpty() ? false : true )
         top.NavFrame.btnBar.aButtons[ 1 ].enable( bEnable )
      }

      // Update Contents tree.
      if ( this.currentTool == CONTENTS ) this.contents.updateTree( URL )

      // Layers are managed on topic file load (to ensure the layers exist),
      // but since an anchor "load" in the current URL generates no load
      // event, we need to call manageLayers() here under such conditions.
      if ( LAYERED_TOPICS && !this.bNewSubsystem ) this.manageLayers()
   }

   /*
   DESCR:   Manages layers if layered topics is turned on.
   PARAMS:  
   RETURNS: 
   NOTES:   This is called from the topic onload handler, to be sure the
            document is loaded, or it is called from loadTopic() if the
            subsystem has not changed, since such a load is via a named
            anchor and does not raise an onload event. 
   */
   function manageLayers()
   {
      //trace( "manageLayers()" )

      if ( !LAYERED_TOPICS ) return

      // Bail if there are no layered topics.
      if ( !defined( top.TopicFrame.document.layers[ 0 ] ) ) return

      // Hide any currently visible topic.
      if ( this.visibleLayerIdx != "" ) {
         top.TopicFrame.document.layers[ this.visibleLayerIdx ].hidden = true
      }

      // Unhide the topic layer.
      top.TopicFrame.document.layers[ this.topic.fragmentSpec ].hidden = false

      // Stash this index.
      this.visibleLayerIdx = this.topic.fragmentSpec
   }

   /*
   DESCR:   Creates an always-on-top message box with an OK button.
   PARAMS:  msgText     The message text.
            msgCaption  The window caption.
   RETURNS: 
   NOTES:   The message box is asynchronous, except that the OK button's
            window.close() will not execute until the JS in the calling
            window executes. Note that parser can't hack whitespace in
            third parm of open().
   */
   function msg( msgText, msgCaption )
   {
      //trace( "msg(" + msgText + ")" )

      if ( msgCaption == "" ) msgCaption = DEFAULT_MESSAGE_CAPTION

      var msgDlg =
         window.open( "", "",
                      "SCROLLBARS=no,WIDTH=350,HEIGHT=200,SCROLLBARS=yes,ALWAYSRAISED=yes,DEPENDENT=yes,TITLEBAR=no,MENUBAR=no,HOTKEYS=no" )

      var html
      html = "<HEAD><TITLE>" + msgCaption +
             "</TITLE></HEAD><BODY BGCOLOR = " + MESSAGE_BGCOLOR + ">"
      html += msgText
      html += "<BR><BR><BR><BR>"
      html += "<CENTER><FORM METHOD = POST>"
      html += "<INPUT TYPE = button NAME = 'OK' VALUE = '   " +
              OK_BTN_LABEL +
              "   ' ONCLICK = 'window.close()'></FORM></CENTER></BODY>"

      msgDlg.document.write( html )
      msgDlg.document.close()
   }

   /*
   DESCR:   Creates a secondary content window.
   PARAMS:  URL         The content URL.
            name        The window name.
            features    The feature string.
            bSystem     true if the window should be system-owned (i.e.,
                        window will not be closed when parent topic
                        closes, only when the system shuts down);
                        false, if topic-owned.
            bReturnObj  true if the window object should be returned.
   RETURNS: Optionally, the window object.
   NOTES:   
   */
   /*
   function openSecWnd( URL, name, features, bSystem, bReturnObj )
   {
      //trace( "openSecWnd(" + URL + ")" )

      // Create a system- or topic-owned seconadary window.
      var newWnd
      var bAlreadyExists = false
      if ( bSystem ) {
         newWnd = window.open( URL, name, features )

         // Add window to list only if it is a new window (user may create
         // a secondary more than once).
         for ( var i = 0; i < this.aSysSecWnds.length; i++ ) {
            if ( this.aSysSecWnds[ i ] == newWnd ) {
               if ( bReturnObj ) return newWnd
               else bAlreadyExists = true
            }
         }
         if ( !bAlreadyExists ) { 
            this.aSysSecWnds[ this.aSysSecWnds.length ] = newWnd
            if ( bReturnObj ) return newWnd
         }
      }
      else {
         newWnd = this.topic.addSecondary( URL, name, features )
         if ( bReturnObj ) return newWnd
      }
   }
   */

   /*
   DESCR:   Creates a bad URL type error.
   PARAMS:  href  The offending href.
   RETURNS: 
   NOTES:   
   */
   function badURLerror( href )
   {
      this.msg( BAD_HREF_ERR_MSG + "<P>" + href, "" )
   }

   /*
   DESCR:   Prints the content in the topic frame.
   PARAMS:  
   RETURNS: 
   NOTES:   
   */
   function print()
   {
      //trace( "print()" )

      top.TopicFrame.print()
   }

// End class definition: system.

/*
DESCR:   Help topic class.
PARAMS:  URL  The non-nethelp form of the URL.
RETURNS: 
NOTES:   
*/
function helpTopic( URL )
{
   //trace( "helpTopic constructor" )

   assert( ( URL.toLowerCase().indexOf( ".htm" ) > -1 ),
           TOPIC_URL_VALUE + URL )

   this.headerURL

   this.URL = URL

   this.fragmentSpec = URL.substring( URL.lastIndexOf( "#" ) + 1 )
   assert( this.fragmentSpec != "", FRAG_SPEC )

   //this.aSecWnds = new Array()  // Secondary windows.

   this.destruct         = destruct
   //this.addSecondary     = addSecondary
   //this.closeSecondaries = closeSecondaries

   // Determine header URL by naming convention.
   var extPos
   extentionPos = this.URL.indexOf( ".htm" )
   if ( extentionPos == -1 ) extentionPos = this.URL.indexOf( ".HTM" )
   assert( ( extentionPos != -1 ), TOPIC_FILENAME )
//   this.headerURL = this.URL.substring( 0, extentionPos ) + "Hdr.htm"

   // Load URL in the topic frame.
   top.TopicFrame.location.replace( this.URL )
}

   /*
   DESCR:   Adds a secondary window.
   PARAMS:  URL       The content URL.
            name      The window name.
            features  The feature string.
   RETURNS: 
   NOTES:   
   */
   /*
   function addSecondary( URL, name, features )
   {
      //trace( "addSecondary()" )

      var newWnd = window.open( URL, name, features )
      
      // Add window to list only if it is a new window (user may
      // create a secondary more than once).
      for ( var i = 0; i < this.aSecWnds.length; i++ ) {
         if ( this.aSecWnds[ i ] == newWnd ) return newWnd
      }
      this.aSecWnds[ this.aSecWnds.length ] = newWnd

      return newWnd
   }
   */

   /*
   DESCR:   Closes all secondary windows.
   PARAMS:  
   RETURNS: 
   NOTES:   
   */
   /*
   function closeSecondaries()
   {
      //trace( "closeSecondaries()" )

      for ( var i = 0; i < this.aSecWnds.length; i++ ) {
         if ( defined( this.aSecWnds[ i ] ) ) this.aSecWnds[ i ].close()
      }
   }
   */
   
   /*
   DESCR:   "Destructor."
   PARAMS:  
   RETURNS: 
   NOTES:   
   */
   function destruct()
   {
      //trace( "helpTopic destruct()" )

      // Close any secondary windows owned by current topic.
      //this.closeSecondaries()
   }

// End class definition: helpTopic.

/*
DESCR:   Popup class.
PARAMS:  
RETURNS: 
NOTES:   
*/

// End class definition: popup.
