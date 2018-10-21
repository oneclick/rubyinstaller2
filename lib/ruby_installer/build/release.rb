module RubyInstaller
module Build
class Release
  def hfile
    "CHANGELOG.md"
  end

  def version_regex
    '[\w]+-\d+\.\d+\.\d+(\.[a-z]\w*)?-[\d\w]+'
  end

  def headline_regex(rel=nil)
    "^(?<pre>[^\\w]*)(?<release>#{rel ? Regexp.escape(rel) : version_regex})(?<sp1>[^\\w]+)(?<date>[2Y][0Y][0-9Y][0-9Y]-[0-1M][0-9M]-[0-3D][0-9D])(?<sp2>[ \\w]*)$"
  end

  def reldate
    Time.now.strftime("%Y-%m-%d")
  end

  def release_text(rel)
    m = File.read(hfile).match(/(?<annotation>#{headline_regex(rel)}.*?)#{headline_regex}/m) || raise("Unable to find release #{rel.inspect} in #{hfile}")
    m[:annotation]
  end

  def release_name(rel)
    m = File.read(hfile).match(/#{headline_regex(rel)}/)
    "#{m[:release]}"
  end

  def update_history(rel)
    raise "invalid version string #{rel.inspect}" unless rel=~/^#{version_regex}$/
    hin = File.read(hfile)
    hout = hin.sub(/#{headline_regex(rel)}/) do
      $1 + $2 + $3 + reldate + $5
    end
    if hout != hin
      $stderr.puts "Updating #{hfile} for release."
      File.write(hfile, hout)
      Rake::FileUtilsExt.sh "git", "commit", hfile, "-m", "Update release date in #{hfile}"
    end
  end

  def tag_version(rel)
    $stderr.puts "Tag release #{rel} with annotation:"
    rt = release_text(rel).gsub(/\A[# ]+/, "")
    $stderr.puts(rt.gsub(/^/, "    "))
    IO.popen(["git", "tag", "--file=-", rel, "--cleanup=whitespace"], "w") do |fd|
      fd.write rt
    end
  end

  CONTENT_TYPE_FOR_EXT = {
    ".exe" => "application/vnd.microsoft.portable-executable",
    ".asc" => "application/pgp-signature",
    ".7z" => "application/zip",
    ".yml" => "application/x-yaml",
  }

  def upload_to_github(tag:, repo:, token: nil, files:)
    require "octokit"

    client = Octokit::Client.new(access_token: token)
    release = client.releases(repo).find{|r| r.tag_name==tag }
    $stderr.puts "#{ release ? "Add to" : "Create" } github release #{tag}"

    if tag =~ /head$/
      if release
        headline = release.name
        body = release.body
            .gsub(/[2Y][0Y][0-9Y][0-9Y]-[0-1M][0-9M]-[0-3D][0-9D] [0-2H][0-9H]:[0-6M][0-9M]:[0-6S][0-9S] UTC/, Time.now.utc.strftime("%Y-%m-%d %H:%M:%S UTC"))
            .gsub(/(Ruby version #{RUBY_PLATFORM}.*?```).*?(```)/m) do
              $1 + "\n" + `ruby --version` + "\n" + $2
            end
      else
        headline = tag
        body = "Latest build of #{tag}"
      end
    else
      headline = IO.popen(["git", "tag", "-l", tag, "--format=%(subject)"], &:read)
      body = IO.popen(["git", "tag", "-l", tag, "--format=%(body)"], &:read)
    end
    raise "invalid headline of tag #{tag.inspect} #{headline.inspect}" if headline.to_s.strip.empty?
    raise "invalid body of tag #{tag.inspect} #{body.inspect}" if body.to_s.strip.empty?

    if release
      release = client.update_release(release.url, name: headline, body: body)
    else
      release = client.create_release(repo, tag,
          target_commitish: "master",
          name: headline,
          body: body,
          draft: true,
          prerelease: true
      )
    end

    old_assets = client.release_assets(release.url)

    files.each do |fname|
      if old_asset=old_assets.find{|a| a.name == File.basename(fname) }
        $stderr.puts "Delete old #{old_asset.name}"
        client.delete_release_asset(old_asset.url)
      end

      $stderr.print "Uploading #{fname} (#{File.size(fname)} bytes) ... "
      client.upload_asset(release.url, fname, content_type: CONTENT_TYPE_FOR_EXT[File.extname(fname)])
      $stderr.puts "OK"
    end
  end
end
end
end
