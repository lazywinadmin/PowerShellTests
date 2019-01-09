git#C:\Users\Like a Boss\Documents\GitHub\PowerShellWork\XML

[xml]$file = Get-Content -Path "C:\Users\Like a Boss\Documents\GitHub\PowerShellWork\XML\blog-10-30-2016.xml"


# show all items
$file.feed

# Show all entries metadata
$file.feed.entry

# Show the Content of post
$file.feed.entry.content
$file.feed.entry.content.'#text'


# Some properties dont show in the output like the App:control which hold the draft information
#  you can access using
$file.feed.entry.innerxml

# Show all the extra properties
($file.feed.entry|where {$_.title.'#text' -eq 'PowerShell DSC - Generating a role base mof file'}).psbase



# SELECT-XML
#  https://www.petri.com/search-xml-files-powershell-using-select-xml

