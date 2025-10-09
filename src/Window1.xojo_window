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
		  Var parser As New HTMLParser
		  Var html As String = "<html><body><h1 class=""content fabulous"">Hello World</h1><p>This is <strong>bold</strong> text.</p></body></html>"
		  Var document As HTMLNode = parser.Parse(html)
		  
		  // Print the parsed structure.
		  Output.Text = document.ToString
		  
		  // Traverse the tree.
		  Var s() As String
		  TraverseNodes(document, s)
		  
		  Output.Text = String.FromArray(s, EndOfLine)
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h21
		Private Sub TraverseNodes(node As HTMLNode, ByRef result() As String, depth As Integer = 0)
		  // Build indent string
		  Var indent As String = ""
		  For i As Integer = 1 To depth
		    indent = indent + "  "
		  Next i
		  
		  Select Case node.Type
		  Case HTMLNode.Types.Element
		    result.Add(indent + "Element: " + node.TagName)
		    
		    For Each key As Variant In node.Attributes_.Keys
		      result.Add(indent + "  Attr: " + key.StringValue + "=" + node.Attributes_.Value(key))
		    Next key
		    
		  Case HTMLNode.Types.Text
		    result.Add(indent + "Text: " + node.Content)
		    
		  Case HTMLNode.Types.Comment
		    result.Add(indent + "Comment: " + node.Content)
		    
		  End Select
		  
		  For Each child As HTMLNode In node.Children
		    TraverseNodes(child, result, depth + 1)
		  Next child
		  
		End Sub
	#tag EndMethod


	#tag Constant, Name = TEST_HTML, Type = String, Dynamic = False, Default = \"<!doctype html>\n<html lang\x3D\"en\">\n<html translate\x3D\"no\">\n<meta name\x3D\"google\" content\x3D\"notranslate\">\n<meta http-equiv\x3D\"content-language\" content\x3D\"en\" />\n\t\n  <head>\n\t<meta charset\x3D\"utf-8\">\n\t<meta name\x3D\"viewport\" content\x3D\"width\x3Ddevice-width\x2C initial-scale\x3D1\">\n\t<meta name\x3D\"color-scheme\" content\x3D\"light dark\" />\n\t<meta name\x3D\"generator\" content\x3D\"Strike 1.6.2\"/>\n\t\n\t<!-- pico CSS -->\n\t<link rel\x3D\"stylesheet\" href\x3D\"/assets/css/pico.min.css\"/>\n\t\n\t<!-- Custom CSS -->\n\t<link rel\x3D\"stylesheet\" href\x3D\"/assets/css/neo.css\"/>\n\t\n\t<!-- Rainbow.js CSS -->\n\t<link rel\x3D\"stylesheet\" href\x3D\"/assets/css/rainbow-default.css\"/>\n\t<link rel\x3D\"stylesheet\" href\x3D\"/assets/css/rainbow-neo.css\"/>\n\t\n\t<title></title>\n  <link rel\x3D\"stylesheet\" href\x3D\"/neo-theme-colour-variants/notepad.css\"/>\n</head>\n  \n  <body>\n\t<main class\x3D\"container\">\n\t\t\n<nav>\n  <ul>\n\t<li><a href\x3D\"/\" class\x3D\"siteName-header-link\"><img class\x3D\"mainNav-logo\" src\x3D\"/assets/images/site-brand.png\" width\x3D\"64\" height\x3D\"64\">\n\t\t<strong>garrypettet.com</strong></a>\n\t</li>\n  </ul>\n  <ul><li class\x3D\"blog\"><a href\x3D\"/blog/index.html\">Blog</a></li><li class\x3D\"projects\"><a href\x3D\"/projects/index.html\">Projects</a></li><li class\x3D\"archives\"><a href\x3D\"/archive.html\">Archives</a></li></ul>\n</nav>\n\n<hr  />\n\t\t\n<section class\x3D\"post-content\">\n\t<h1>AIKit</h1>\n\t\n\t<p><code>AIKit</code> is a free\x2C open source\x2C Xojo module for interacting with large language models (LLMs) from a variety of open source and proprietary providers.</p>\n<h2>Repository</h2>\n<p><a href\x3D\"https://github.com/gkjpettet/AIKit\">https://github.com/gkjpettet/AIKit</a></p>\n<h2>About</h2>\n<p>LLMs are popular in the tech world as of the time of writing (March 2025) and many programmers are building impressive tools on top of them. <code>AIKit</code> provides a way for Xojo programmers to chat (using both text and images) with LLMs from Xojo code both synchronously and asynchronously using a standardised <code>Chat</code> object. The <code>Chat</code> object abstracts away the API complexities of different providers and even allows switching between providers within the same conversation.</p>\n<h2>Usage</h2>\n<p>Everything needed is contained within the <code>AIKit</code> module. There are no external code dependencies - the module is 100% native Xojo code and therefore should work on any platform Xojo supports.</p>\n<p>To get started\x2C simply copy the <code>AIKit</code> module into your project.</p>\n<h3>Basic synchronous usage</h3>\n<p>You can talk with a LLM synchronously like this:</p>\n<pre><code class\x3D\"language-xojo\">Const API_KEY \x3D &quot;Your Anthropic Key here&quot;\nConst MODEL \x3D &quot;claude-3-7-sonnet-20250219&quot;\nVar chat As New AIKit.Chat(MODEL\x2C AIKit.Providers.Anthropic\x2C API_KEY\x2C &quot;&quot;)\nVar response As AIKit.ChatResponse \x3D chat.Ask(&quot;What is 1 + 2\?&quot;)\n</code></pre>\n<p>This will either return an <code>AIKit.ChatResponse</code> object containing the model\'s response\x2C token usage\x2C etc or will raise an <code>AIKit.APIException</code> if something went wrong.</p>\n<p>You can follow up the conversation by just continuing to ask questions:</p>\n<pre><code class\x3D\"language-xojo\">response \x3D chat.Ask(&quot;Add 5 to that and give me the answer&quot;)\n</code></pre>\n<p>You can even switch models and/providers mid-conversation and the conversation history will be preserved:</p>\n<pre><code class\x3D\"language-xojo\">chat.WithModel(&quot;o1-mini&quot;\x2C AIKit.Providers.OpenAI\x2C OPENAI_API_KEY\x2C &quot;&quot;)\nresponse \x3D chat.Ask(&quot;Double that value please&quot;)\n</code></pre>\n<p>Since LLMs can take a while to respond\x2C it is highly recommended that you use <code>AIKit</code> asynchronously otherwise your app may hang whilst a response is awaited (unless you use a thread).</p>\n<h3>Asynchronous usage</h3>\n<p>When used asynchronously\x2C the <code>AIKit.Chat</code> object will call delegates (also known as callbacks) you provide when certain events occur. Delegates are methods that you &quot;attach&quot; to a <code>Chat</code> object. These methods must have a particular signature. You can read more about Xojo delegates in <a href\x3D\"https://documentation.xojo.com/api/data_types/additional_types/delegate.html\">Xojo\'s documentation</a> but an example is provided below:</p>\n<pre><code class\x3D\"language-xojo\">// Assume this code is in the Opening event of a window and the window has a property called `Chat` of\n// type `AIKit.Chat`.\n\n// Create a new chat instance with a local LLM using the Ollama provider.\nConst OLLAMA_ENDPOINT \x3D &quot;Your Ollama API endpoint ending with `/`&quot;\nChat \x3D New AIKit.Chat(&quot;deepseek-r1:14b&quot;\x2C AIKit.Providers.Ollama\x2C &quot;&quot;\x2C OLLAMA_ENDPOINT)\n\n// Attach delegates to handle the various events that the chat object will create.\n// You don\'t have to assign a delegate  to all of these. If you don\'t\x2C you simply \n// won\'t be notified when an event occurs.\n\n// APIError() is a method that will be called when an API error happens.\nChat.APIErrorDelegate \x3D AddressOf APIError\n\n// ContentReceived() is my method that will be called when new message content is received.\nChat.ContentReceivedDelegate \x3D AddressOf ContentReceived\n\n// MaxTokensReached() is my method that\'s called when the maximum token limit has been reached.\nChat.MaxTokensReachedDelegate \x3D AddressOf MaxTokensReached\n\n// MessageStarted() is a message called when a new message is beginning.\nChat.MessageStartedDelegate \x3D AddressOf MessageStarted\n\n// MessageFinished() will be called when a message has just been finished.\nChat.MessageFinishedDelegate \x3D AddressOf MessageFinished\n\n// ThinkingReceived() will be called by some models as thinking content is generated.\nChat.ThinkingReceivedDelegate \x3D AddressOf ThinkingReceived\n\n// Once the chat is setup\x2C we just ask away and handle the responses in the above methods\n// as they are received:\nchat.Ask(&quot;Hello&quot;)\n</code></pre>\n<h2>Default API keys &amp; endpoints</h2>\n<p>As demonstrated above\x2C you can pass the required API key (or in the case of Ollama\x2C the API endpoint) to a <code>Chat</code> instance. However\x2C if you omit both the API key and endpoint parameters\x2C the <code>Chat</code> object will attempt to use default keys for the requested provider. The default keys are stored in the <code>AIKit</code> module itself:</p>\n<pre><code class\x3D\"language-xojo\">// Set the keys you want to use in your app. A good place to do this is \n// in `App.Opening` but it\'ll work so long as they are set before you\n// create any `Chat` instances.\nAIKit.Credentials.Anthropic \x3D &quot;your-anthropic-key&quot;\nAIKit.Credentials.Gemini \x3D &quot;your-gemini-key&quot;\nAIKit.Credentials.Ollama \x3D &quot;the-ollama-endpoint-url&quot;\nAIKit.Credentials.OpenAI \x3D &quot;the-openai-key&quot;\n\n// Now creating a chat is much cleaner since we only pass two parameters:\nVar chatgpt As New Chat(&quot;o1-mini&quot;\x2C AIKit.Providers.OpenAI)\nchatgpt.Ask(&quot;Hi&quot;)\n\n// Switch models mid-conversation:\nchatgpt.WithModel(&quot;o3-mini&quot;\x2C AIKit.Providers.OpenAI)\nchatgpt.Ask(&quot;Are you smarter now\?&quot;)\n</code></pre>\n<h2>Provider support</h2>\n<p><code>AIKit</code> uses the concept of <em>Providers</em>. A Provider is a vendor of an LLM. At present\x2C the following providers are supported:</p>\n<ul>\n<li>Anthropic (specifically Claude) via <code>AnthropicProvider</code>\n</li>\n<li>Google\'s Gemini via <code>GeminiProvider</code>\n</li>\n<li>Ollama (for locally hosted LLMs) via <code>OllamaProvider</code>\n</li>\n<li>OpenAI (ChatGPT\x2C o1/o3\x2C etc) via <code>OpenAIProvider</code>\n</li>\n</ul>\n<p>I may add support for other providers in the future but I encourage you to add your own and create a pull request via GitHub so we can all benefit. Adding new providers is fairly easy. If you look at the included provider classes (e.g. <code>AnthropicProvider</code>) you\'ll see they all implement the <code>AIKit.ChatProvider</code> interface. There are a couple of other spots in the code that would need modifying (mostly in constructors and the <code>AIKit.Providers</code> enumeration).</p>\n<p>Most people won\'t need to interact with provider classes directly as they are abstracted away by the <code>Chat</code> object.</p>\n<h2>Demo application</h2>\n<p>Included in the repo is the <code>AIKit</code> module and a demo application that allows you to chat with any of the supported LLMs. You will need to provide your own API keys and Ollama endpoints for the demo to work correctly (since I don\'t want to share mine!). To do this\x2C create a folder called <code>ignore</code> in the same directory as the AIKit <code>src</code> folder. In this folder\x2C create a JSON file called <code>private.json</code> with this structure:</p>\n<pre><code class\x3D\"language-json\">{\n\t&quot;apiKeys&quot; : {\n\t\t&quot;anthropic&quot; : &quot;your-key&quot;\x2C\n\t\t&quot;openai&quot; : &quot;your-key&quot;\x2C\n\t\t&quot;gemini&quot; : &quot;your-key&quot;\n\t}\x2C\n\t&quot;endPoints&quot; : {\n\t\t&quot;ollama&quot; : &quot;the endpoint\x2C e.g http://localhost:11434/api/&quot;\n\t}\n}\n</code></pre>\n<p>This will provide the <code>KeySafe</code> module in the demo app with access to your API keys. This is not needed when using <code>AIKit</code> in your own projects - it\'s just to make the demo work. Here\'s a screenshot of where you should place the file:</p>\n<p><img src\x3D\"https://images.garrypettet.com/projects/aikit-private-json-file.png\" alt\x3D\"JSON file\" /></p>\n<p>If you don\'t have an API key or endpoint for one of the providers in the JSON file structure above\x2C just leave the value of the key as an empty string e.g:</p>\n<pre><code class\x3D\"language-json\">&quot;apiKeys&quot;: {\n\t&quot;anthropic&quot;: &quot;&quot;\n}\n</code></pre>\n<p>On macOS\x2C you\'ll need to add an entry to the plist for any project using <code>AIKit</code> to give permission to the app to call any URL. To do this I have bundled an <code>Info.plist</code> within the <code>resources/</code> folder of the repo. You can either drop this into your project and Xojo will include it in the build app plist or\x2C if you\'re using Xojo 2025r1 or greater\x2C I\'ve added the required plist keys in the IDE\'s plist editor. If you don\'t do this you\'ll see Xojo network exceptions.</p>\n\n</section>\n\n<div class\x3D\"grid pagination\">\n\t<div class\x3D\"previous\"><a class\x3D\"previous\" href\x3D\"#\">Previous Post</a></div>\n\t<div class\x3D\"next\"><a class\x3D\"next\" href\x3D\"/projects/encodekit.html\">Next Post</a></div>\n</div>\n\n<hr  />\n\n<footer>\t\n\t<div class\x3D\"published-date\">\n\t\t<svg xmlns\x3D\"http://www.w3.org/2000/svg\" height\x3D\"16\" width\x3D\"16\" viewBox\x3D\"0 0 576 512\" fill\x3D\"currentColor\" stroke-linecap\x3D\"round\" stroke-linejoin\x3D\"round\"><path d\x3D\"M128 0c13.3 0 24 10.7 24 24V64H296V24c0-13.3 10.7-24 24-24s24 10.7 24 24V64h40c35.3 0 64 28.7 64 64v16 48H400 384 48V448c0 8.8 7.2 16 16 16H262.5l-5.1 20.2c-2.3 9.4-1.8 19 1.4 27.8H64c-35.3 0-64-28.7-64-64V192 144 128C0 92.7 28.7 64 64 64h40V24c0-13.3 10.7-24 24-24zm-8 256H296c13.3 0 24 10.7 24 24s-10.7 24-24 24H120c-13.3 0-24-10.7-24-24s10.7-24 24-24zM96 376c0-13.3 10.7-24 24-24H232c13.3 0 24 10.7 24 24s-10.7 24-24 24H120c-13.3 0-24-10.7-24-24zM549.8 235.7l14.4 14.4c15.6 15.6 15.6 40.9 0 56.6l-29.4 29.4-71-71 29.4-29.4c15.6-15.6 40.9-15.6 56.6 0zM311.9 417L441.1 287.8l71 71L382.9 487.9c-4.1 4.1-9.2 7-14.9 8.4l-60.1 15c-5.5 1.4-11.2-.2-15.2-4.2s-5.6-9.7-4.2-15.2l15-60.1c1.4-5.6 4.3-10.8 8.4-14.9z\"></path></svg>\n\t\t<span class\x3D\"date\">Published April 4\x2C 2025</span>\n\t</div>\n\t\n\t<div class\x3D\"post-tags\">\n\t<svg xmlns\x3D\"http://www.w3.org/2000/svg\" height\x3D\"16\" width\x3D\"16\" viewBox\x3D\"0 0 448 512\" fill\x3D\"currentColor\" stroke-linecap\x3D\"round\" stroke-linejoin\x3D\"round\"><path d\x3D\"M345 39.1L472.8 168.4c52.4 53 52.4 138.2 0 191.2L360.8 472.9c-9.3 9.4-24.5 9.5-33.9 .2s-9.5-24.5-.2-33.9L438.6 325.9c33.9-34.3 33.9-89.4 0-123.7L310.9 72.9c-9.3-9.4-9.2-24.6 .2-33.9s24.6-9.2 33.9 .2zM0 229.5V80C0 53.5 21.5 32 48 32H197.5c17 0 33.3 6.7 45.3 18.7l168 168c25 25 25 65.5 0 90.5L277.3 442.7c-25 25-65.5 25-90.5 0l-168-168C6.7 262.7 0 246.5 0 229.5zM144 144a32 32 0 1 0 -64 0 32 32 0 1 0 64 0z\"/></svg>\n\t\n</div>\n\t\n\t<div class\x3D\"rss-link\">\n\t  <svg xmlns\x3D\"http://www.w3.org/2000/svg\" height\x3D\"16\" width\x3D\"16\" viewBox\x3D\"0 0 448 512\" fill\x3D\"currentColor\" stroke-linecap\x3D\"round\" stroke-linejoin\x3D\"round\"><path d\x3D\"M0 64C0 46.3 14.3 32 32 32c229.8 0 416 186.2 416 416c0 17.7-14.3 32-32 32s-32-14.3-32-32C384 253.6 226.4 96 32 96C14.3 96 0 81.7 0 64zM0 416a64 64 0 1 1 128 0A64 64 0 1 1 0 416zM32 160c159.1 0 288 128.9 288 288c0 17.7-14.3 32-32 32s-32-14.3-32-32c0-123.7-100.3-224-224-224c-17.7 0-32-14.3-32-32s14.3-32 32-32z\"></path>\n\t  </svg>\n\t  <a href\x3D\"/rss.xml\">Subscribe via RSS</a>\n  </div>\n</footer>\n\n\t\t</main>\n\t  \t<script src\x3D\"/assets/js/rainbow.min.js\"></script>\n<script src\x3D\"/assets/js/rainbow-languages.js\"></script>\n\t  </body>\t\n</html>", Scope = Private
	#tag EndConstant


#tag EndWindowCode

