#tag DesktopWindow
Begin DesktopWindow Window1
   Backdrop        =   0
   BackgroundColor =   &cFFFFFF
   Composite       =   False
   DefaultLocation =   2
   FullScreen      =   False
   HasBackgroundColor=   False
   HasCloseButton  =   True
   HasFullScreenButton=   False
   HasMaximizeButton=   True
   HasMinimizeButton=   True
   HasTitleBar     =   True
   Height          =   766
   ImplicitInstance=   True
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   1968154623
   MenuBarVisible  =   False
   MinimumHeight   =   64
   MinimumWidth    =   64
   Resizeable      =   True
   Title           =   "Untitled"
   Type            =   0
   Visible         =   True
   Width           =   1084
   Begin DesktopTextArea Output
      AllowAutoDeactivate=   True
      AllowFocusRing  =   True
      AllowSpellChecking=   True
      AllowStyledText =   True
      AllowTabs       =   False
      BackgroundColor =   &cFFFFFF
      Bold            =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Format          =   ""
      HasBorder       =   True
      HasHorizontalScrollbar=   False
      HasVerticalScrollbar=   True
      Height          =   726
      HideSelection   =   True
      Index           =   -2147483648
      Italic          =   False
      Left            =   20
      LineHeight      =   0.0
      LineSpacing     =   1.0
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      MaximumCharactersAllowed=   0
      Multiline       =   True
      ReadOnly        =   False
      Scope           =   2
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   ""
      TextAlignment   =   0
      TextColor       =   &c000000
      Tooltip         =   ""
      Top             =   20
      Transparent     =   False
      Underline       =   False
      UnicodeMode     =   1
      ValidationMask  =   ""
      Visible         =   True
      Width           =   1044
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Sub Opening()
		  ' Var parser As New HTMLParser
		  ' Var html As String = "<html><body><h1 class=""content fabulous"">Hello World</h1><p>This is <strong>bold</strong> text.</p></body></html>"
		  ' 
		  ' Var document As HTMLNode = parser.Parse(HTML_WITH_CDATA)
		  ' 
		  ' // Print the parsed structure.
		  ' Output.Text = document.ToString
		  ' 
		  ' // Traverse the tree.
		  ' Var s() As String
		  ' TraverseNodes(document, s)
		  ' 
		  ' Output.Text = String.FromArray(s, EndOfLine)
		  
		  // Basic usage.
		  Var parser As New HTMLParser(False) // Non-strict mode
		  Var html As String = "<div><p>Test<span>text</p></div>"
		  Var doc As HTMLNode = parser.Parse(html)
		  
		  // Check for errors.
		  If parser.HasErrors() Then
		    System.DebugLog("Parse errors found:")
		    For Each err As HTMLParserException In parser.Errors
		      System.DebugLog(err.ToString())
		    Next err
		  End If
		  
		  ' // Strict mode parsing.
		  ' Var strictParser As New HTMLParser(True)
		  ' Try
		  ' doc = strictParser.Parse("<img>") // Will raise exception for missing src
		  ' Catch e As RuntimeException
		  ' System.DebugLog("Fatal parse error: " + e.Message)
		  ' End Try
		  
		  // Validation report.
		  Var errors() As HTMLParserException = parser.Errors
		  Var errorCount As Integer = 0
		  Var warningCount As Integer = 0
		  Var infoCount As Integer = 0
		  
		  For Each err As HTMLParserException In errors
		    Select Case err.Severity
		    Case HTMLParserException.Severities.Error
		      errorCount = errorCount + 1
		    Case HTMLParserException.Severities.Warning
		      warningCount = warningCount + 1
		    Case HTMLParserException.Severities.Info
		      infoCount = infoCount + 1
		    End Select
		  Next err
		  
		  System.DebugLog("Validation Summary:")
		  System.DebugLog("  Errors: " + errorCount.ToString)
		  System.DebugLog("  Warnings: " + warningCount.ToString)
		  System.DebugLog("  Info: " + infoCount.ToString)
		  
		  ' Var report As String = GenerateValidationReport(parser.Errors)
		  ' Break
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21, Description = 47656E65726174657320616E642072657475726E7320616E2048544D4C2076616C69646174696F6E207265706F72742E
		Private Function GenerateValidationReport(errors() As HTMLParserException) As String
		  /// Generates and returns an HTML validation report.
		  
		  Var html As String = "<html><head><title>HTML Validation Report</title>"
		  html = html + "<style>"
		  html = html + ".error { color: red; }"
		  html = html + ".warning { color: orange; }"
		  html = html + ".info { color: blue; }"
		  html = html + "</style></head><body>"
		  html = html + "<h1>HTML Validation Report</h1>"
		  
		  If errors.Count = 0 Then
		    html = html + "<p>No issues found.</p>"
		  Else
		    html = html + "<ul>"
		    For Each err As HTMLParserException In errors
		      html = html + "<li class='" + err.SeverityString + "'>"
		      html = html + err.ToString
		      If err.Context <> "" Then
		        html = html + "<br><code>" + err.Context + "</code>"
		      End If
		      html = html + "</li>"
		    Next
		    html = html + "</ul>"
		  End If
		  
		  html = html + "</body></html>"
		  
		  Return html
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub TraverseNodes(node As HTMLNode, ByRef result() As String, depth As Integer = 0)
		  // Build indent string
		  Var indent As String = ""
		  For i As Integer = 1 To depth
		    indent = indent + "  "
		  Next i
		  
		  Select Case node.Type
		  Case HTMLNode.Types.CDATA
		    result.Add(indent + "CDATA: " + node.Content)
		    
		  Case HTMLNode.Types.Comment
		    result.Add(indent + "Comment: " + node.Content)
		    
		  Case HTMLNode.Types.DocType
		    result.Add(indent + "DOCTYPE: " + node.Content)
		    
		  Case HTMLNode.Types.Element
		    result.Add(indent + "Element: " + node.TagName)
		    
		    For Each key As Variant In node.Attributes_.Keys
		      result.Add(indent + "  Attr: " + key.StringValue + "=" + node.Attributes_.Value(key))
		    Next key
		    
		  Case HTMLNode.Types.Text
		    result.Add(indent + "Text: " + node.Content)
		    
		  End Select
		  
		  For Each child As HTMLNode In node.Children
		    TraverseNodes(child, result, depth + 1)
		  Next child
		  
		End Sub
	#tag EndMethod


	#tag Constant, Name = HTML_WITH_CDATA, Type = String, Dynamic = False, Default = \"<html><script><![CDATA[if (x < 5) { alert(\'Hello\'); }]]></script><div>Normal content</div><style><![CDATA[body > div { color: red; }]]></style></html>", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = MIXED_HTML, Type = String, Dynamic = False, Default = \"<script>var x \x3D 5;<![CDATA[if (x < 10 && y > 5) { }]]>var y \x3D 10;</script>", Scope = Protected
	#tag EndConstant


#tag EndWindowCode

