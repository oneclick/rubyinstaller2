FROM microsoft/windowsservercore
# FROM microsoft/nanoserver

# Download base ruby
RUN powershell \
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-2.4.6-1/rubyinstaller-devkit-2.4.6-1-x64.exe -Outfile rubyinstaller.exe
# Download git
RUN powershell \
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest https://github.com/git-for-windows/git/releases/download/v2.20.1.windows.1/Git-2.20.1-64-bit.exe -Outfile git-installer.exe
# Download Inno Setup    
RUN powershell \
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest http://www.jrsoftware.org/download.php/is-unicode.exe -Outfile inno-setup.exe
    
# Install base ruby and initialize Devkit
RUN (cmd /c rubyinstaller.exe /verysilent /log=install.log) || (powershell get-content c:/install.log)
RUN powershell $env:PATH = [Environment]::GetEnvironmentVariable('PATH','Machine'); \
    $env:RUBYOPT = [Environment]::GetEnvironmentVariable('RUBYOPT','Machine')
RUN ruby --version
RUN ridk install 1

# Install git
RUN cmd /c git-installer.exe /verysilent
RUN git --version

# Install Inno Setup
RUN cmd /c inno-setup.exe /verysilent
RUN powershell [Environment]::SetEnvironmentVariable('PATH', $env:PATH + ';c:/Program Files (x86)/Inno Setup 5', 'Machine')
RUN iscc --version || (exit 0)

RUN ridk enable

# pacman fails with EXDEV error after download when /var/cache/pkg is bind mounted into the container.
# Therefore mount /var/cache directory an let pacman create the pkg directory.
RUN ridk exec rm -r c:/ruby24-x64/msys64/var/cache/pacman/pkg

# Import the git repository and unpack it in /build
WORKDIR /build
COPY gitrepo .git/
RUN dir
RUN git checkout -f

# Install required rubygems
RUN gem install bundler --no-doc
RUN bundle

WORKDIR /build/docker
CMD rake
