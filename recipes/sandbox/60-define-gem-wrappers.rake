# Define the bin executable wrappers that shall be shipped with the package.

self.gem_bin_wrappers.merge!({
#   package.install_gems.find{|g| g.start_with?("bundler-") } => ["bundle", "bundle.bat", "bundler", "bundler.bat"],
})
