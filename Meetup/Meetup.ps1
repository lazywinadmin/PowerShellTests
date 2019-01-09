# API Documentation
https://www.meetup.com/meetup_api/docs/
# Testing API online
https://secure.meetup.com/meetup_api/console/?path=/:urlname/events


# Events
<#
/:urlname/events/
/:urlname/events/:id
/:urlname/events/:id/attendance
?&sign=true&photo-host=public&scroll=future_or_past&page=200&fields=scroll
#>
invoke-restmethod https://api.meetup.com/FrenchPSUG/events
$events = invoke-restmethod https://api.meetup.com/FrenchPSUG/events
$events|select name


invoke-restmethod 'https://api.meetup.com/FrenchPSUG/events?&sign=true&photo-host=public&scroll=future_or_past&page=200&fields=scroll'|measure
invoke-restmethod -uri 'https://api.meetup.com/FrenchPSUG/events?&scroll=future_or_past&page=5'
$events=invoke-restmethod -uri 'https://api.meetup.com/FrenchPSUG/events?status=past&page=100'
$events|ogv


$events=invoke-restmethod -uri 'https://api.meetup.com/FrenchPSUG/events?status=past&page=100'
$GroupInformation=invoke-restmethod -uri "https://api.meetup.com/FrenchPSUG/"
$GroupInformation
