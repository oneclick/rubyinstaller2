---
layout: download_archives
title: Download Archives
permalink: /downloads/archives/
---

<div>
<div class="span-6 border" markdown="1">

## RubyInstallers

<ul>
  {% assign dls = (site.data.downloads | where: "filetype", "rubyinstallerexe") %}
  {% for dl in dls %}
  <li class="{{ dl.filetype }}"><a href="{{ dl.href }}">{{ dl.name }}</a></li>
  {% endfor %}
</ul>

[« Back]({{ "/downloads" | relative_url }})
</div>
<div class="span-6 border" markdown="1">

## Archives
<ul>
  {% assign dls = (site.data.downloads | where: "filetype", "rubyinstaller7z") %}
  {% for dl in dls %}
  <li class="{{ dl.filetype }}"><a href="{{ dl.href }}">{{ dl.name }}</a></li>
  {% endfor %}
</ul>
</div>


<div class="span-6 border" markdown="1">
## Documentation
<ul>
  {% assign dls = (site.data.downloads | where: "filetype", "rubychm7z") %}
  {% for dl in dls %}
  <li class="{{ dl.filetype }}"><a href="{{ dl.href }}">{{ dl.name }}</a></li>
  {% endfor %}
</ul>
</div>


<div class="span-6 last" markdown="1">
## DevKits
<ul>
  {% assign dls = (site.data.downloads | where: "filetype", "devkitsfx") %}
  {% for dl in dls %}
  <li class="{{ dl.filetype }}"><a href="{{ dl.href }}">{{ dl.name }}</a></li>
  {% endfor %}
</ul>
</div>
</div>
