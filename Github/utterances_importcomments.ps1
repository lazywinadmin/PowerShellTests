############
# TODO
############
        ## Titles weird
        #   Pages title is missing 
        #   Title with single quote sucg as "I'm a PowerShell Hero" "SAPIEN MVP 2015" are showing weird character â€™
        #    Ã¢â‚¬Â¦ for !
        #    â€¦
        #   Remove "^LazyWinAdmin\:\s" from title

# URL
        #  remove the http ou https ou www from url

## FILTER OUT
        #http://localhost:4000/PowerShellPester_-_Make_sure_your_parameters_are_separated_by_an_empty_line/
        #http://localhost:4000/TestFontSize/
        #http://www.lazywinadmin.com/search?updated-min=2015-01-01T00:00:00-05:00&updated-max=2016-01-01T00:00:00-05:00&max-results=29

## Rename link
        #https://lazywinadmin.github.io/minimal-mistakes/2018/02/SpaceX_module.html # pas de commentaires
        #https://lazywinadmin.github.io/frpsug/2017/04/FrPSUG20170415.html
        #https://lazywinadmin.github.io/powershell/2017/03/MyInvocation_Commandused.html
        #https://lazywinadmin.github.io/2018/02/SpaceX_module.html?__s=2ocfjn3gwbuszpg4m21x

# Ensure included in output
        #http://www.lazywinadmin.com/p/scripts.html

# Weird links (page not found), probably the first version of my links
        # Disqus create a thread for each page accessed
        #https://lazywinadmin.github.io/PowerShellSCSM_-_Get_Review_Activities_Rejected_in_the_last_60_days/


# Import the functions
. C:\Users\fxavi\OneDrive\Scripts\Github\PSDisqusImport\src\Get-PSDisqusComment.ps1
. C:\Users\fxavi\OneDrive\Scripts\Github\PSDisqusImport\src\Get-PSDisqusThread.ps1

# Exported file from Disqus
$File = "C:\Users\fxavi\OneDrive\Scripts\Github\PSDisqusImport\data\lazywinadmin-2018-10-03T01_14_58.548194-all.xml"

# Retrieve Comments
$Comments = Get-PSDisqusComment -Path $File -Verbose

# Retrieve threads
$Threads = Get-PSDisqusThread -Path $File -Verbose -filter {$_.link -match "\.io\/\d{4}\/.+html$|\.com\/\d{4}\/.+html$|\.com\/p\/.+html$|\.io\/minimal-mistakes\/\d{4}\/.+html$|\.io\/powershell\/\d{4}\/.+html$|\.io\/usergroup\/\d{4}\/.+html$" -and $_.link -notmatch "googleusercontent\.com"}
# Add 2 properties for proper title and relative link '/2019/01/01/blogpost.html'

# Create 2 properties 'link2' and 'title2' that will contains the clean information
#  then group per link (per thread or post)
#  link2: trimed URL
#  title2: Remove prefix, weird brackets or weird characters
$threads|
Select-Object *,
@{L='link2';E={$_.link -replace "https://|http://|www\.|lazywinadmin\.com|lazywinadmin\.github\.io|superblackbook\.blogspot\.com|\/minimal-mistakes|\/powershell"}},
@{L='title2';E={$_.title -replace "^LazyWinAdmin:\s"-replace 'â€™',"'" -replace "Ã¢â‚¬Â¦|â€¦" -replace 'â€“','-' -replace '\/\[','[' -replace '\\\/\]',']' }}|
Group-Object -Property link2 -ov groups


# Validate we have a title each time and select the proper one
# Also we might have multiple threads for the same post but with different URL
# This is due to the blog changing address during the migration
# Example: one address on blogspot.com (previous host), lazywinadmin.github.io (before moving DNS), http://*lazywinadmin.com (before moving to HTTPS)
# Disqus create a thread for each page user accessed
# if we can't find the proper title, we are doing a lookup with the URL using Invoke-WebRequest
# We add a property 'RealTitle' which contain the real title to each thread
$ThreadsUpdated = $groups|Sort-Object count |ForEach-Object -Process {

    # Capture current post
    $CurrentPost = $_

    # if one comment is found
    if($CurrentPost.count -eq 1)
    {
        if($CurrentPost.group.title2 -notmatch '^http')
        {
            # Add REALTitle property
            $RealTitle = $CurrentPost.group.title2
            # output object
            $CurrentPost.group | Select-Object *,@{L='RealTitle';e={$RealTitle}},@{L='ThreadCount';e={$CurrentPost.count}}

            #write-host "$($CurrentPost.count) - nolookup - $RealTitle" -ForegroundColor red
        }
        elseif($CurrentPost.group.title2 -match '^http')
        {
            # lookup online
            $result = Invoke-webrequest -Uri $CurrentPost.group.link -Method Get
            # add REALTitle prop
            $RealTitle = $result.ParsedHtml.title
            # output object
            $CurrentPost.group | Select-Object *,@{L='RealTitle';e={$RealTitle}},@{L='ThreadCount';e={$CurrentPost.count}}

            #write-host "$($CurrentPost.count) - lookup - $RealTitle" -ForegroundColor red
        }
    }
    if($CurrentPost.count -gt 1)
    {
        if($CurrentPost.group.title2 -notmatch '^http')
        {
            # add REALTitle prop
            $RealTitle = ($CurrentPost.group.title2|Where-Object {$_ -notmatch '^http'}|Select-Object -first 1)
            # output object
            $CurrentPost.group | Select-Object *,@{L='RealTitle';e={$RealTitle}},@{L='ThreadCount';e={$CurrentPost.count}}

            #write-host "$($CurrentPost.count) - nolookup - $RealTitle" -ForegroundColor red
        }
        elseif($CurrentPost.group.title2 -match '^http')
        {
            # get url of one
            $u = ($CurrentPost.group|Where-Object {$_.title2 -match '^http'}|Select-Object -first 1).link
            # lookup online
            $result = Invoke-webrequest -Uri $u -Method Get
            # add REALTitle prop
            $RealTitle = $result.ParsedHtml.title
            # output object
            $CurrentPost.group | Select-Object *,@{L='RealTitle';e={$RealTitle}}

            #write-host "$($CurrentPost.count) - lookup - $RealTitle" -ForegroundColor red
        }
        else {
            # add REALTitle prop
            $RealTitle = 'unknown'
            # output object
            $CurrentPost.group | Select-Object *,@{L='RealTitle';e={$RealTitle}}

            #write-host "$($CurrentPost.count) - Unknown - $RealTitle" -ForegroundColor red
        }
    }
}

# Append the thread information to the each comment object
# Here we just pass the realtitle and link2
$Comments | ForEach-Object -Process {
    $CommentItem = $_
    $ThreadInformation = $ThreadsUpdated | Where-Object -FilterScript {$_.id -match $CommentItem.ThreadId}
    $CommentItem | Select-Object -Property *,@{L='ThreadTitle';E={$ThreadInformation.Realtitle}},@{L='ThreadLink';E={$ThreadInformation.link2}} #,@{L='Threadraw';E={$ThreadInformation.raw}}
} -ov f |Group-Object -Property ThreadLink -ov g|
Where-Object {$_.name} -ov h # ignore some comments where i did not find the thread.

#$g = $g |?{$_.name}

# Load Git module and authenticate
Import-Module -Name powershellforgithub # ..\PowerShellForGitHub\PowerShellForGitHub.psd1 -verb
$key = '<secret>'
$cred = Get-Credential -UserName $null
Set-GitHubAuthentication -Credential $cred
Set-GitHubConfiguration -DisableLogging -DisableTelemetry
$issues = Get-GitHubIssue -Uri 'https://github.com/lazywinadmin/lazywinadmin.github.io' 


# $issues.title
# $g | sort name -Descending |select -first 2 | %{$_.group|sort createdAt}|select message, createdat, threadtitle|fl *
# Build the Github Issue


########## SHOULD BE ASCENDING, but for the test we try on the latest 2 posts with comments
$h | Sort-Object name -Descending |Select-Object -first 2 | ForEach-Object{

    # Capture current thread
    $BlogPost = $_

    # Adjust Title
    #  replace the first / and remove the html at the end of the name
    $IssueTitle = $BlogPost.name -replace '^\/' -replace '\.html'

    # lookup for existing issue
    $IssueObject = $issues|Where-Object {$_.title -eq $IssueTitle}

    if(-not $IssueObject)
    {
        # Build Header of the post
        $IssueHeader = $BlogPost.group.ThreadTitle | select-object -first 1

        # Blog post link
        $BlogPostLink = "https://lazywinadmin.com$($BlogPost.name)"
        # Body of issue
        $Body = @"
# $IssueHeader

[$BlogPostLink]($BlogPostLink)

<!--
Imported via PowerShell on $(Get-Date -Format o)
-->
"@
        # Create issue
        $IssueObject = New-GitHubIssue -OwnerName lazywinadmin -RepositoryName lazywinadmin.github.io -Title $IssueTitle -Body $body -Label 'blog comments'
    }


        # Sort comment by createdAt
        $BlogPost.group|Where-Object {$_.isspam -like '*false*'} | Sort-Object createdAt | ForEach-Object{
            $CurrenComment = $_
            $CommentBody = @"

**Author**: $($CurrenComment.AuthorName)
**Date**: $($CurrenComment.createdAt)
**Message**:
$($CurrenComment.message)


*Imported via PowerShell on $(Get-Date -Format o)*
<!--
$($CurrenComment|convertTo-Json)
-->
"@
            New-GitHubComment -OwnerName lazywinadmin -RepositoryName lazywinadmin.github.io -Issue $IssueObject.number -Body $CommentBody

        }
    }
}



# Validate post exist in Github
# if not
#  create issue
#    add issue
# if it does
#  add comment

|Sort-Object -Property Count -ov sort |Where-Object -Property Name -ne '' -ov BlogPost
$BlogPost.name
$BlogPost| Foreach-Object -Process {

}