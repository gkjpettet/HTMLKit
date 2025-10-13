# HTMLKit
A collection of Xojo classes for parsing HTML into a traversable tree and for handling URLs.

## About
HTMLKit consists of four classes:

- `HTMLDocument`: Parses an HTML string into a document of nodes.
- `HTMLNode`: Represents an atomic component of an HTML document (e.g. a `<div>` or `<a>` element).
- `HTMLException`: A `RuntimeException` subclass that contains information about errors or warnings that were encountered during the parsing process.
- `URL`: A helper class that represents an internet URL. Is constructed from a string and fetches the contents of that link.

This is all 100% native Xojo code with no external dependencies.

## Usage

```xojo
Var linkString As String = "https://garrypettet.com"

Var link As URL
Try
  link = New URL(linkString) // <-- makes a synchronous call to the URL.
Catch e As RuntimeException
  // Either the link timed out or something bad happened trying to get the contents.
End Try

Var doc As New HTMLDocument(False) // True would enable strict mode.
doc.TrackWarningsAndInfo = True // Useful for basic validation of the document.

doc.Parse(link.Contents) // We could just parse in raw HTML here too.

// We can now traverse nodes in the tree or access specific nodes.
Var head As HTMLNode = doc.Head
Var body As HTMLNode = doc.Body

// HTMLNode contains powerful CSS-like selectors.
// Example usage:
// 1. Has attribute (any value). Find all elements with an href attribute
Var links() As HTMLNode = doc.NodesWithSelector("[href]")

// 2. Exact match. Find all inputs with type="text"
Var textInputs() As HTMLNode = doc.NodesWithSelector("[type=text]")

// Also works with quotes:
Var textInputs2() As HTMLNode = doc.NodesWithSelector("[type='text']")
Var textInputs3() As HTMLNode = doc.NodesWithSelector("[type=""text""]")

// 3. Contains substring. Find all links that contain "example.com" anywhere in the href:
Var exampleLinks() As HTMLNode = doc.NodesWithSelector("[href*=example.com]")

// 4. Starts with. Find all links that start with "https://"
Var httpsLinks() As HTMLNode = doc.NodesWithSelector("[href^=https://]")

// Find all IDs that start with "user-"
Var userElements() As HTMLNode = doc.NodesWithSelector("[id^=user-]")

// 5. Ends with. Find all images with src ending in ".png"
Var pngImages() As HTMLNode = doc.NodesWithSelector("[src$=.png]")

// Find all links ending with ".pdf"
Var pdfLinks() As HTMLNode = doc.NodesWithSelector("[href$=.pdf]")

// 6. Contains word (space-separated). Find all elements with class containing "active" as a complete word:
// This would match class="btn active" but not class="inactive"
Var activeElements() As HTMLNode = doc.NodesWithSelector("[class~=active]")

// 7. Language/prefix match. Find all elements with lang="en" or lang="en-US" or lang="en-GB" etc:
Var englishElements() As HTMLNode = doc.NodesWithSelector("[lang|=en]")

// 8. Not equal (custom extension). Find all inputs that are NOT text type:
Var nonTextInputs() As HTMLNode = doc.NodesWithSelector("[type!=text]")
```
## Demo
This repo contains a simple demo app that takes a URL you enter, fetches it and then parses the contents into a document tree. There is a hierarchical listbox that displays a simple representation of the nodes and a validation report is generated.
