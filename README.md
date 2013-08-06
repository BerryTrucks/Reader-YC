Reader|YC
=========

Reader|YC is a native hackernews client built with Cascades and Python (using Blackberry-tart). Instead of using often unstable APIs, this app directly scrapes Hackernews for posts (and soon comments) to ensure maximum uptime. Currently the app is at V0.8, almost ready for release.

The post scraping is based heavily off of Dimillian's Sublime plugin found [here](https://github.com/Dimillian/Sublime-Hacker-News-Reader)

Here is a current screenshot of the main page:
![image](https://raw.github.com/krruzic/Reader-YC/master/screenshot.png)

## Steps to build:
Since the release of tart V1.1, I have switched to the recommended method of building described [here](http://hg.microcode.ca/blackberry-py/wiki/Building%20HelloWorld)


**Install Blackberry Tart**
To do this you'll need to grab the tartV1 zip found [here](http://blackberry-py.microcode.ca/downloads/), then clone the Mercurial repo with `hg clone https://bitbucket.org/microcode/blackberry-py`. Take the bin directory and the tart.ini out of that, and place them in the same directory you extracted the zip into.

Now, clone this repo and place into that root directory too.

**REQUEST DEBUG TOKEN BAR FILE**
`blackberry-debugtokenrequest -storepass STOREPASS -devicepin DEVICEPIN debugtoken.bar`

note: the storepass is the password you used to first register for debug tokens with RIM

**BUILD DEBUG BAR:**
cd into the bin folder and execute the tart.sh or tart.cmd file with these parameters: `package -mdebug ../Reader-YC/`. If you want to change some details like permissions, just edit the tart-project.ini file in Reader-YC.

**BUILD RELEASE BAR:**
Same as above, except use `-mrelease` instead of `-mdebug`

**SIGN BAR FILE IF RELEASE:**
`blackberry-signer -storepass STOREPASS NAMEOFBAR`

**INSTALL APP TO DEVICE:**
`blackberry-deploy -installApp -password DEVICEPASS -device DEVICEIP -package NAMEOFBAR`


NOTE: The bars will be placed in the bin directory after being built.


## Features:
###Current Features:
* Get the main hackernews pages in a nice tabbed format
* Infinite scrolling, load more comments
* View articles, comments, and text posts

###Current Issues:
* ~~Sometimes the main page (top posts) doesn't load, and I'm not too sure why.~~
* ~~Does not handle a lack of internet connectivity. At all.~~
* If you close the app while it is making a request, the app will go into a greyed-out "zombie" state for a while (less than a minute with release only, but still)
* You can only request one page at a time. This isn't too big of an issue, but increases time spent waiting.

###Coming Feature roadmap (dates are really guesses):
* View text posts, comments and articles all from within the app V1.0 (Will be available on BB-World at this point)
  ~~ETA: July 1~~ MOVED TO August 15th
  NOTE: This is almost done, I just need to pretty things up a bit.

* Favouriting posts for later viewing from a 'Favourites' tab, as well as view user pages V1.1
	ETA: Week after V1.0

* ~~Comment caching for recent articles  V1.1~~
	ETA: Never, idea scrapped

* V1.2 
- A tutorial that shows when first launched, this will add some flair to the app
- Collapsable comments, Searching for posts and comments 
    ETA: End of Summer

* Logging in and upvoting/commenting V2.0
	ETA: Probably never, but I do hope to add this

