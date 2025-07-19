#!/bin/bash

# Cleanup temporary files on exit
cleanup() {
  [ -f "${req}" ] && rm "${req}"
  [ -f "${torrent_req}" ] && rm "${torrent_req}"
}
trap cleanup EXIT

# Get the script name (for help text)
SCRIPT_NAME=$(basename "$0")

# Print help text and exit
help() {
  cat << EOF
  usage: $SCRIPT_NAME [OPTION] [TERM]...
  Query 1337x.to for magnet links by category
  Example: $SCRIPT_NAME -o "Debian"

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
EOF
  exit 1
}

# Show help if no arguments are given
[ "$#" -eq 0 ] && help

CATEGORY="Movies"  # Default search category
POSITIONAL=()      # Holds search terms

# Parse CLI options
while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help)
      help
      ;;
    -m|--movie)
      CATEGORY="Movies"
      shift
      ;;
    -t|--tv)
      CATEGORY="TV"
      shift
      ;;
    -g|--games)
      CATEGORY="Games"
      shift
      ;;
    -u|--music)
      CATEGORY="Music"
      shift
      ;;
    -a|--apps)
      CATEGORY="Apps"
      shift
      ;;
    -d|--docs)
      CATEGORY="Documentaries"
      shift
      ;;
    -n|--anime)
      CATEGORY="Anime"
      shift
      ;;
    -o|--other)
      CATEGORY="Other"
      shift
      ;;
    -x|--xxx)
      CATEGORY="XXX"
      shift
      ;;
    -*)
      echo "Unknown option: $1"
      exit 1
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

# Restore search terms into $@
set -- "${POSITIONAL[@]}"

# Build the search URL
terms=$*
base_url="https://1337x.to"
url="${base_url}/category-search/${terms// /%20}/${CATEGORY}/1/"

# Fetch the HTML page for the category search results
req=$(mktemp)
status=$(curl --connect-timeout 3 -sX GET -w "%{http_code}" -o "${req}" "${url}")
[ "${status}" -ne 200 ] && echo "Error: ${status}" && exit 1

# Parse the HTML page with pup and collate torrent links and metadata using jq
torrents_table=$(pup 'a[href*="/torrent/"], td.coll-4 json{}' < "${req}" | jq -r --arg base_url "${base_url}" '
  # Add header row
  (["HREF","SEEDERS","SIZE","NAME"] | join("\u001F")),
  (
    # Bottom half contains torrent hrefs, top half contains metadata, split array in half and transpose to combine related entries
    [.[:length/2], .[length/2:]] | transpose[] |
    # Extract relevant fields from each entry
    [
      # Details URL
      "\($base_url)\(.[0].href)",
      # Seeders value
      .[1].children[].text,
      # Torrent size
      .[1].text,
      # Torrent name 
      .[0].text
    ] | join("\u001F")
  )
' | column -s$'\x1F' -t)

# Exit if no torrents returned (just header)
[ "$(echo "${torrents_table}" | wc -l)" -lt 2 ] && echo "No torrents found in ${CATEGORY}" && exit 1

# Launch fzf to allow the user to pick a result, extract href parameter from selected row
selected_torrent_url=$(echo "${torrents_table}" | fzf --header-lines=1 --with-nth=2.. | awk '{print $1}')

# Exit silently if nothing was selected
[ -z "${selected_torrent_url}" ] && exit 1

# Fetch the selected torrent's details page
torrent_req=$(mktemp)
status=$(curl --connect-timeout 3 -sX GET -w "%{http_code}" -o "${torrent_req}" "${selected_torrent_url}")
[ "${status}" -ne 200 ] && echo "Error: ${status}" && exit 1

# Extract magnet link from the page (strip announce parameters to make for a clean URL to click in terminal)
pup 'a[href^="magnet"] attr{href}' < "${torrent_req}" | awk -F$'\u0026' 'NR == 1 {print $1}'

