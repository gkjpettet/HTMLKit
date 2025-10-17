#tag Class
Protected Class MarkdownContext
	#tag Method, Flags = &h0, Description = 41646473207468652070617373656420656C656D656E74732028652E672E2022646976222C202270222920746F20746865206C697374206F6620656C656D656E747320746861742077696C6C2062652069676E6F72656420647572696E6720636F6E76657273696F6E2E
		Sub AddExcludedElement(ParamArray elements() As String)
		  /// Adds the passed elements (e.g. "div", "p") to the list of elements that will be ignored during conversion.
		  
		  If mExcludedElements = Nil Then mExcludedElements = New Dictionary
		  
		  For Each element As String In elements
		    mExcludedElements.Value(element) = True
		  Next element
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(baseURL As String = "")
		  mExcludedElements = New Dictionary
		  
		  // By default, we will ignore <head>, <script> and <style> elements.
		  AddExcludedElement("head", "script", "style")
		  
		  Self.BaseURL = URL.NormaliseAndValidateURL(baseURL)
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E732054727565206966207468652073706563696669656420656C656D656E74206973206578636C756465642066726F6D2070726F63657373696E672E
		Function ElementIsExcluded(elementName As String) As Boolean
		  /// Returns True if the specified element is excluded from processing.
		  
		  Return mExcludedElements.HasKey(elementName)
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0, Description = 5573656420746F207265736F6C76652072656C61746976652055524C7320696E206C696E6B7320616E6420696D616765732E
		BaseURL As String
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 547261636B7320686F7720646565706C79206E65737465642077652061726520696E206C697374732028652E672E20756C202F206F6C20656C656D656E7473292E
		ListDepth As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h1, Description = 50726F7669646573206120717569636B206C6F6F6B757020746F20736B697020756E77616E74656420656C656D656E747320286C696B65203C7363726970743E206F72203C7374796C653E2074616773292E204B6579203D20656C656D656E74206E616D652028537472696E67292C2056616C7565203D205472756520286E6F74207573656429292E
		Protected mExcludedElements As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 49662054727565207468656E206F6E6C79206C696E6B20746578742077696C6C206265207072657365727665642C207468652055524C732077696C6C2062652073747269707065642E
		RemoveLinks As Boolean = False
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ListDepth"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="BaseURL"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RemoveLinks"
			Visible=false
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
