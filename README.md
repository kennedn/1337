# 1337x
A minimal command-line interface for interactively searching and retrieving magnet links from [1337x.to](https://1337x.to).  

## Prerequisites
Make sure the following tools are installed and available in your `PATH`:

- `bash` (recent version)
- `curl`
- [`jq`](https://stedolan.github.io/jq/)
- [`fzf`](https://github.com/junegunn/fzf)
- [`go`](https://golang.org/) (required to install `pup`)
- [`pup`](https://github.com/ericchiang/pup) (HTML parser)

### Debian/Ubuntu Installation
Install tools via apt:
```bash
sudo apt update
sudo apt install bash curl jq fzf golang
````

Install pup:

```bash
go install github.com/ericchiang/pup@latest
```

## Usage

```bash
  usage: 1337.sh [OPTION] [TERM]...
  Query 1337x.to for magnet links by category
  Example: 1337.sh -o "Debian"

  Options:
    -m,--movie (default)
          search for movies
    -t,--tv
          search for TV shows
    -g,--games
          search for games
    -u,--music
          search for music
    -a,--apps
          search for applications
    -d,--docs
          search for documentaries
    -n,--anime
          search for anime
    -o,--other
          search other content
    -x,--xxx
          search for adult content
    -h,--help
          print this message
```

### Example

```bash
./1337.sh -o "Debian"
```

<details>
  <summary>Output</summary>

```bash
❯ ./1337.sh -o "Debian"
  0        6.7 MB    Ubuntu Linux Toolbox - 1000+ Commands for Ubuntu and Debian Power Users                                                                                                  
  0        6.7 MB    Ubuntu Linux Toolbox - 1000+ Commands for Ubuntu and Debian Power Users                                                                                                  
  0        620.7 MB  RetroShare-Chat-Server-Live-CD                                                                                                                                           
  0        846.5 MB  Debian Linux Server Setup Essentials for Webhosting and More                                                                                                             
  0        7.1 MB    Create a complete and vulnerable Debian 8 server for hacking and pentesting (Make your own Free secu...                                                                  
  0        4.4 GB    Debian-7.5.0-armhf-DVD-1.iso                                                                                                                                             
  0        1.3 GB    debian-live-7.5.0-i386-gnome-desktop.iso                                                                                                                                 
  0        760.0 MB  debian-live-7.5.0-i386-rescue.iso                                                                                                                                        
  10       187.6 MB  Lynda - Learning Debian Linux [AhLaN]                                                                                                                                    
  15       122.4 MB  Debian 12.5 Bookworm - The Comprehensive Guide                                                                                                                           
> 46       5.6 MB    The Debian Administrator&#39;s Handbook [Bullseye - 11] by Raphaël Hertzog EPUB                                                                                          
  SEEDERS  SIZE      NAME                                                                                                                                                                     
  11/11                                                                                                                                                                                       
magnet:?xt=urn:btih:XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```
</details>

