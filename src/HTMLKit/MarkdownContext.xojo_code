#tag Class
Protected Class MarkdownContext
	#tag Method, Flags = &h0, Description = 41646473207468652070617373656420636C617373206E616D65732028652E672E2022636F6E74656E74222920746F20746865206C697374206F6620636C617373206E616D657320746861742077696C6C2062652069676E6F72656420647572696E6720636F6E76657273696F6E2E
		Sub AddExcludedClass(ParamArray classes() As String)
		  /// Adds the passed class names (e.g. "content") to the list of class names that will be ignored during conversion.
		  
		  If mExcludedClasses = Nil Then mExcludedClasses = New Dictionary
		  
		  For Each c As String In classes
		    mExcludedClasses.Value(c) = True
		  Next c
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 41646473207468652070617373656420656C656D656E74732028652E672E2022646976222C202270222920746F20746865206C697374206F6620656C656D656E747320746861742077696C6C2062652069676E6F72656420647572696E6720636F6E76657273696F6E2E
		Sub AddExcludedElement(ParamArray elements() As String)
		  /// Adds the passed elements (e.g. "div", "p") to the list of elements that will be ignored during conversion.
		  
		  If mExcludedElements = Nil Then mExcludedElements = New Dictionary
		  
		  For Each element As String In elements
		    mExcludedElements.Value(element) = True
		  Next element
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 416464732074686520706173736564204944732028652E672E20226D61696E2D636F6E74656E74222C2022736F6D654944222920746F20746865206C697374206F662049447320746861742077696C6C2062652069676E6F72656420647572696E6720636F6E76657273696F6E2E
		Sub AddExcludedID(ParamArray ids() As String)
		  /// Adds the passed IDs (e.g. "main-content", "someID") to the list of IDs that will be ignored during conversion.
		  
		  If mExcludedIDs = Nil Then mExcludedIDs = New Dictionary
		  
		  For Each id As String In ids
		    mExcludedIDs.Value(id) = True
		  Next id
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 41646473207468652070617373656420726F6C652028652E672E20226E617669676174696F6E222920746F20746865206C697374206F662022726F6C6522206174747269627574652076616C75657320746861742077696C6C2062652069676E6F72656420647572696E6720636F6E76657273696F6E2E
		Sub AddExcludedRole(ParamArray roles() As String)
		  /// Adds the passed role (e.g. "navigation") to the list of "role" attribute values that will be ignored during conversion.
		  
		  If mExcludedRoles = Nil Then mExcludedRoles = New Dictionary
		  
		  For Each role As String In roles
		    mExcludedRoles.Value(role) = True
		  Next role
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E732054727565206966207468652073706563696669656420636C617373206973206578636C756465642066726F6D2070726F63657373696E672E
		Function ClassIsExcluded(className As String) As Boolean
		  /// Returns True if the specified class is excluded from processing.
		  
		  className = className.Trim
		  
		  If className.Contains(" ") Then
		    Var names() As String = className.Split(" ")
		    For Each name As String In names
		      If mExcludedClasses.HasKey(name) Then Return True
		    Next name
		    Return False
		  Else
		    Return mExcludedClasses.HasKey(className)
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub Constructor(baseURL As String = "")
		  mExcludedClasses = New Dictionary
		  mExcludedElements = New Dictionary
		  mExcludedIDs = New Dictionary
		  mExcludedRoles = New Dictionary
		  
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

	#tag Method, Flags = &h0, Description = 52657475726E7320547275652069662074686520737065636966696564204944206973206578636C756465642066726F6D2070726F63657373696E672E
		Function IDIsExcluded(id As String) As Boolean
		  /// Returns True if the specified ID is excluded from processing.
		  
		  Return mExcludedIDs.HasKey(id)
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E732054727565206966207468652073706563696669656420726F6C652076616C7565206973206578636C756465642066726F6D2070726F63657373696E672E
		Function RoleIsExcluded(role As String) As Boolean
		  /// Returns True if the specified role value is excluded from processing.
		  
		  role = role.Trim
		  
		  If role.Contains(" ") Then
		    Var roles() As String = role.Split(" ")
		    For Each r As String In roles
		      If mExcludedRoles.HasKey(r) Then Return True
		    Next r
		    Return False
		  Else
		    Return mExcludedRoles.HasKey(role)
		  End If
		  
		End Function
	#tag EndMethod


	#tag Property, Flags = &h0, Description = 5573656420746F207265736F6C76652072656C61746976652055524C7320696E206C696E6B7320616E6420696D616765732E
		BaseURL As String
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 547261636B7320686F7720646565706C79206E65737465642077652061726520696E206C697374732028652E672E20756C202F206F6C20656C656D656E7473292E
		ListDepth As Integer = 0
	#tag EndProperty

	#tag Property, Flags = &h1, Description = 50726F7669646573206120717569636B206C6F6F6B757020746F20736B697020756E77616E74656420656C656D656E7420636C61737365732E204B6579203D20636C617373206E616D652028537472696E67292C2056616C7565203D205472756520286E6F74207573656429292E
		Protected mExcludedClasses As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1, Description = 50726F7669646573206120717569636B206C6F6F6B757020746F20736B697020756E77616E74656420656C656D656E747320286C696B65203C7363726970743E206F72203C7374796C653E2074616773292E204B6579203D20656C656D656E74206E616D652028537472696E67292C2056616C7565203D205472756520286E6F74207573656429292E
		Protected mExcludedElements As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1, Description = 50726F7669646573206120717569636B206C6F6F6B757020746F20736B697020756E77616E746564204944732E204B6579203D2049442028537472696E67292C2056616C7565203D205472756520286E6F74207573656429292E
		Protected mExcludedIDs As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1, Description = 50726F7669646573206120717569636B206C6F6F6B757020746F20736B697020656C656D656E7473207769746820612022726F6C6522206174747269627574652074686174206D61746368657320616E79206F66207468657365206B6579732028652E672E20726F6C65203D20226E617669676174696F6E22292E204B6579203D20726F6C65206E616D652028537472696E67292C2056616C7565203D205472756520286E6F74207573656429292E
		Protected mExcludedRoles As Dictionary
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
