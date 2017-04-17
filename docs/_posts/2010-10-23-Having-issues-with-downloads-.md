---
layout: post
title:  "Having issues with downloads?"
date:   2010-10-23
author: Luis Lavena
---
So, you’ve reach this website and want to try out Ruby for Windows… hit download and nothing happens… or things go weird and you start a download that will take 12 hours… <span class="caps">OMG</span>!
Well, if yours is one of the above cases, you’re suffering some sort of mirror glitch.
RubyInstaller downloads right now rely on [RubyForge](http://rubyforge.org) file hosting infrastructure and mirror system. Most of these mirrors are community provided, and due that, the differences between them can affect users trying to download files.
Until we work out or own file hosting solution, a simple workaround is append <code>/go</code> or <code>/noredirect</code> to the download <span class="caps">URL</span> from the [Downloads](/downloads) section.
E.g. If you want to download <code>rubyinstaller-1.9.2-p0.exe</code>, the original download <span class="caps">URL</span> is:
And when adding the above fix, the result <span class="caps">URL</span> is:
To do that, just right click in the download links, copy it to the clipboard and paste it in a new browser window/tab. Edit as shown above and hit enter for the download to start.
Hope this helps you out sort your download issues. Again, apologizes for been suffering from them and don’t forget you can find us at [RubyInstaller group](http://groups.google.com/group/rubyinstaller/)
