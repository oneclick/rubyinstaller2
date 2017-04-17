---
layout: downloads
title: Downloads
permalink: /downloads/
---
## RubyInstallers <a id="archive" href="{{ "/downloads/archives" | relative_url }}">Archives</a>


Not sure what version to download? Please read the right column for recommendations.

<ul>
  {% assign dls = (site.data.downloads | where: "filetype", "rubyinstallerexe" | where: "show", "true") %}
  {% for dl in dls %}
  <li class="{{ dl.filetype }}"><a href="{{ dl.href }}">{{ dl.name }}</a></li>
  {% endfor %}
</ul>

## Other Useful Downloads

### 7-Zip Archives

<ul>
  {% assign dls = (site.data.downloads | where: "filetype", "rubyinstaller7z" | where: "show", "true") %}
  {% for dl in dls %}
  <li class="{{ dl.filetype }}"><a href="{{ dl.href }}">{{ dl.name }}</a></li>
  {% endfor %}
</ul>


### Ruby Core & Standard Library Documentation

<ul>
  {% assign dls = (site.data.downloads | where: "filetype", "rubychm7z" | where: "show", "true") %}
  {% for dl in dls %}
  <li class="{{ dl.filetype }}"><a href="{{ dl.href }}">{{ dl.name }}</a></li>
  {% endfor %}
</ul>


### Development Kit

#### For use with Ruby 2.0 to 2.3 (32bits version only):

<ul>
  {% include fileicon.html text="DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe" filetype="devkitsfx" href="https://dl.bintray.com/oneclick/rubyinstaller/DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe" %}
</ul>


#### For use with Ruby 2.0 to 2.3 (x64 - 64bits only)

<ul>
  {% include fileicon.html text="DevKit-mingw64-64-4.7.2-20130224-1432-sfx.exe" filetype="devkitsfx" href="https://dl.bintray.com/oneclick/rubyinstaller/DevKit-mingw64-64-4.7.2-20130224-1432-sfx.exe" %}
</ul>

##  MD5 & SHA256 Checksums

For MD5 and SHA256 checksums of available downloads please check the corresponding **package/version**
_files tab_ or _release notes_ at the [RubyInstaller repository on Bintray](https://bintray.com/oneclick/rubyinstaller).
